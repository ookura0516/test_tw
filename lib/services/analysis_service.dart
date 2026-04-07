import 'package:flutter/material.dart';
import '../models/person.dart';

class AnalysisService {
  String getRelationshipAdvice(Person person) {
    final m = person.metrics;
    final buf = StringBuffer();

    if (m.emotionalDrain >= 70) {
      buf.writeln('この関係はあなたに大きな精神的疲労をもたらしています。');
    } else if (m.emotionalDrain >= 40) {
      buf.writeln('この関係はある程度の精神的エネルギーを消費しています。');
    } else {
      buf.writeln('この関係はあなたに精神的な負担をあまりかけていません。');
    }

    if (m.positivity >= 70) {
      buf.writeln('やり取りは非常にポジティブで、お互いに高め合える関係です。');
    } else if (m.positivity >= 40) {
      buf.writeln('やり取りは普通程度のポジティブさです。');
    } else {
      buf.writeln('やり取りがネガティブに偏っています。改善の余地があります。');
    }

    if (m.frequency >= 70) {
      buf.writeln('頻繁に連絡を取り合っており、活発な関係です。');
    } else if (m.frequency >= 40) {
      buf.writeln('適度な頻度で連絡を取り合っています。');
    } else {
      buf.writeln('連絡の頻度が少なく、関係が薄れている可能性があります。');
    }

    return buf.toString().trim();
  }

  String getStressAnalysis(Person person) {
    final stress = person.metrics.replyStress;
    if (stress >= 80) {
      return '返信ストレスが非常に高いです。この人からのメッセージを見るだけで不安になる可能性があります。自分の境界線を明確にすることが重要です。';
    } else if (stress >= 60) {
      return '返信にかなりのストレスを感じています。返信のタイミングや内容に悩むことが多いかもしれません。';
    } else if (stress >= 40) {
      return '返信に多少のストレスを感じることがあります。';
    } else if (stress >= 20) {
      return '返信ストレスはほとんどありません。自然体でやり取りできています。';
    } else {
      return '返信ストレスはほぼゼロです。非常にリラックスした関係です。';
    }
  }

  List<String> getActionItems(Person person) {
    final m = person.metrics;
    final items = <String>[];

    if (m.emotionalDrain >= 60 && items.length < 3) {
      items.add('やり取りの後に自分のエネルギーレベルを記録してみましょう');
    }
    if (m.replyStress >= 60 && items.length < 3) {
      items.add('返信のタイミングを自分のペースに合わせることを意識しましょう');
    }
    if (m.initiationBalance >= 70 && items.length < 3) {
      items.add('相手からの連絡を待ってみて、関係のバランスを確認しましょう');
    }
    if (m.frequency <= 30 && m.positivity >= 60 && items.length < 3) {
      items.add('月1回程度の定期的な連絡を心がけてみましょう');
    }
    if (m.positivity <= 40 && items.length < 3) {
      items.add('ポジティブな話題を意識的に会話に取り入れてみましょう');
    }
    if (m.responseTime <= 30 && items.length < 3) {
      items.add('相手の返信が遅い理由を穏やかに確認してみましょう');
    }

    while (items.length < 2) {
      if (items.isEmpty) {
        items.add('現在の関係の良い点をリストアップしてみましょう');
      } else {
        items.add('定期的にこのアプリでメトリクスを更新して変化を追いましょう');
      }
    }

    return items.take(3).toList();
  }

  Color getRelationshipColor(Person person) {
    final d = person.metrics.emotionalDrain;
    final p = person.metrics.positivity;
    final health = p - d;

    if (health >= 30) return const Color(0xFF4CAF50);
    if (health >= 0) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String getRelationshipEmoji(Person person) {
    final m = person.metrics;
    if (m.emotionalDrain >= 70 && m.positivity <= 40) return '😰';
    if (m.positivity >= 80 && m.emotionalDrain <= 30) return '😊';
    if (m.replyStress >= 70) return '😟';
    if (m.frequency >= 70 && m.positivity >= 60) return '🌟';
    if (m.emotionalDrain >= 60) return '😓';
    if (m.positivity >= 60) return '😌';
    if (m.frequency <= 30) return '🌊';
    return '😐';
  }
}
