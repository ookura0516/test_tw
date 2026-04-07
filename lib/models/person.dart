import 'dart:math';

enum ContactMethod {
  line,
  sns,
  inPerson,
  phone;

  String get displayName {
    switch (this) {
      case ContactMethod.line:
        return 'LINE';
      case ContactMethod.sns:
        return 'SNS';
      case ContactMethod.inPerson:
        return '対面';
      case ContactMethod.phone:
        return '電話';
    }
  }
}

enum RelationshipCategory {
  innerCircle,
  close,
  casual,
  distant,
  fading;

  String get displayName {
    switch (this) {
      case RelationshipCategory.innerCircle:
        return '親密な関係';
      case RelationshipCategory.close:
        return '近い関係';
      case RelationshipCategory.casual:
        return '普通の関係';
      case RelationshipCategory.distant:
        return '距離のある関係';
      case RelationshipCategory.fading:
        return '疎遠な関係';
    }
  }
}

class RelationshipMetrics {
  final int frequency;
  final int responseTime;
  final int emotionalDrain;
  final int positivity;
  final int initiationBalance;
  final int replyStress;

  const RelationshipMetrics({
    this.frequency = 50,
    this.responseTime = 50,
    this.emotionalDrain = 30,
    this.positivity = 70,
    this.initiationBalance = 50,
    this.replyStress = 30,
  });

  RelationshipMetrics copyWith({
    int? frequency,
    int? responseTime,
    int? emotionalDrain,
    int? positivity,
    int? initiationBalance,
    int? replyStress,
  }) {
    return RelationshipMetrics(
      frequency: frequency ?? this.frequency,
      responseTime: responseTime ?? this.responseTime,
      emotionalDrain: emotionalDrain ?? this.emotionalDrain,
      positivity: positivity ?? this.positivity,
      initiationBalance: initiationBalance ?? this.initiationBalance,
      replyStress: replyStress ?? this.replyStress,
    );
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency,
        'responseTime': responseTime,
        'emotionalDrain': emotionalDrain,
        'positivity': positivity,
        'initiationBalance': initiationBalance,
        'replyStress': replyStress,
      };

  factory RelationshipMetrics.fromJson(Map<String, dynamic> json) {
    return RelationshipMetrics(
      frequency: (json['frequency'] as num?)?.toInt() ?? 50,
      responseTime: (json['responseTime'] as num?)?.toInt() ?? 50,
      emotionalDrain: (json['emotionalDrain'] as num?)?.toInt() ?? 30,
      positivity: (json['positivity'] as num?)?.toInt() ?? 70,
      initiationBalance: (json['initiationBalance'] as num?)?.toInt() ?? 50,
      replyStress: (json['replyStress'] as num?)?.toInt() ?? 30,
    );
  }
}

class Person {
  final String id;
  final String name;
  final int colorIndex;
  final ContactMethod contactMethod;
  final RelationshipMetrics metrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Person({
    required this.id,
    required this.name,
    this.colorIndex = 0,
    this.contactMethod = ContactMethod.line,
    required this.metrics,
    required this.createdAt,
    required this.updatedAt,
  });

  double get psychologicalDistance {
    final raw = (metrics.emotionalDrain * 0.3) +
        ((100 - metrics.frequency) * 0.25) +
        ((100 - metrics.positivity) * 0.25) +
        (metrics.initiationBalance * 0.1) +
        (metrics.replyStress * 0.1);
    return max(0, min(100, raw));
  }

  RelationshipCategory get relationshipCategory {
    final d = psychologicalDistance;
    if (d <= 20) return RelationshipCategory.innerCircle;
    if (d <= 40) return RelationshipCategory.close;
    if (d <= 60) return RelationshipCategory.casual;
    if (d <= 80) return RelationshipCategory.distant;
    return RelationshipCategory.fading;
  }

  String get suggestion {
    final m = metrics;

    if (m.emotionalDrain >= 70 && m.positivity <= 40) {
      return 'この関係に疲れているかもしれません。少し距離を置くことを検討してみてください。';
    }
    if (m.frequency >= 70 && m.positivity >= 70) {
      return '素晴らしい関係です！この絆を大切にしましょう。';
    }
    if (m.frequency <= 30 && m.positivity >= 70) {
      return '関係は良好ですが、もっと連絡してみると良いかもしれません。';
    }
    if (m.replyStress >= 70) {
      return '返信にストレスを感じているようです。正直に気持ちを伝えてみましょう。';
    }
    if (m.initiationBalance >= 75) {
      return 'あなたばかりが連絡しているようです。相手の気持ちを確認してみましょう。';
    }
    if (m.emotionalDrain >= 60) {
      return 'この関係があなたのエネルギーを消耗させています。境界線を設けることを考えてみてください。';
    }
    if (m.frequency >= 60 && m.emotionalDrain <= 40) {
      return '活発で健全な関係です。このペースを維持しましょう。';
    }
    return 'バランスの取れた関係です。現状を維持しましょう。';
  }

  Person copyWith({
    String? id,
    String? name,
    int? colorIndex,
    ContactMethod? contactMethod,
    RelationshipMetrics? metrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      contactMethod: contactMethod ?? this.contactMethod,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorIndex': colorIndex,
        'contactMethod': contactMethod.name,
        'metrics': metrics.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String,
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
      contactMethod: ContactMethod.values.firstWhere(
        (e) => e.name == json['contactMethod'],
        orElse: () => ContactMethod.line,
      ),
      metrics: RelationshipMetrics.fromJson(
          json['metrics'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
