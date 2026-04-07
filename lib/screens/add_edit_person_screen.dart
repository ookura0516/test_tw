import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';
import '../providers/persons_provider.dart';
import '../widgets/person_avatar.dart';

class AddEditPersonScreen extends StatefulWidget {
  final String? personId;

  const AddEditPersonScreen({super.key, this.personId});

  @override
  State<AddEditPersonScreen> createState() => _AddEditPersonScreenState();
}

class _AddEditPersonScreenState extends State<AddEditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _colorIndex = 0;
  ContactMethod _contactMethod = ContactMethod.line;
  int _frequency = 50;
  int _responseTime = 50;
  int _emotionalDrain = 30;
  int _positivity = 70;
  int _initiationBalance = 50;
  int _replyStress = 30;

  bool get _isEditing => widget.personId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final person =
            context.read<PersonsProvider>().getPersonById(widget.personId!);
        if (person != null) _populateForm(person);
      });
    }
  }

  void _populateForm(Person person) {
    setState(() {
      _nameController.text = person.name;
      _colorIndex = person.colorIndex;
      _contactMethod = person.contactMethod;
      _frequency = person.metrics.frequency;
      _responseTime = person.metrics.responseTime;
      _emotionalDrain = person.metrics.emotionalDrain;
      _positivity = person.metrics.positivity;
      _initiationBalance = person.metrics.initiationBalance;
      _replyStress = person.metrics.replyStress;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  RelationshipMetrics get _currentMetrics => RelationshipMetrics(
        frequency: _frequency,
        responseTime: _responseTime,
        emotionalDrain: _emotionalDrain,
        positivity: _positivity,
        initiationBalance: _initiationBalance,
        replyStress: _replyStress,
      );

  double get _previewDistance {
    final raw = (_emotionalDrain * 0.3) +
        ((100 - _frequency) * 0.25) +
        ((100 - _positivity) * 0.25) +
        (_initiationBalance * 0.1) +
        (_replyStress * 0.1);
    return raw.clamp(0.0, 100.0);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PersonsProvider>();
    final now = DateTime.now();

    if (_isEditing) {
      final existing = provider.getPersonById(widget.personId!);
      if (existing != null) {
        await provider.updatePerson(existing.copyWith(
          name: _nameController.text.trim(),
          colorIndex: _colorIndex,
          contactMethod: _contactMethod,
          metrics: _currentMetrics,
          updatedAt: now,
        ));
      }
    } else {
      await provider.addPerson(Person(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        colorIndex: _colorIndex,
        contactMethod: _contactMethod,
        metrics: _currentMetrics,
        createdAt: now,
        updatedAt: now,
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編集' : '人を追加'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview card
            _PreviewCard(distance: _previewDistance, colorIndex: _colorIndex, name: _nameController.text),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '名前',
                hintText: '例: 田中さん',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? '名前を入力してください' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Color picker
            _SectionCard(
              title: 'アバターカラー',
              child: Wrap(
                spacing: 8,
                children: List.generate(avatarColors.length, (i) {
                  final color = avatarColors[i];
                  return GestureDetector(
                    onTap: () => setState(() => _colorIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorIndex == i ? Colors.black87 : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: _colorIndex == i
                            ? [BoxShadow(color: color.withAlpha(120), blurRadius: 8)]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // Contact method
            _SectionCard(
              title: '連絡手段',
              child: Wrap(
                spacing: 8,
                children: ContactMethod.values.map((m) {
                  final selected = _contactMethod == m;
                  return ChoiceChip(
                    label: Text(m.displayName),
                    selected: selected,
                    onSelected: (_) => setState(() => _contactMethod = m),
                    selectedColor: Theme.of(context).colorScheme.primary.withAlpha(40),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Sliders
            _SectionCard(
              title: 'メトリクス',
              child: Column(
                children: [
                  _MetricSlider(
                    label: '連絡頻度',
                    description: 'どのくらいの頻度で連絡しますか？',
                    value: _frequency,
                    leftEmoji: '🌊',
                    rightEmoji: '🔥',
                    onChanged: (v) => setState(() => _frequency = v),
                  ),
                  _MetricSlider(
                    label: '返信速度',
                    description: '相手はどのくらい早く返信しますか？',
                    value: _responseTime,
                    leftEmoji: '🐢',
                    rightEmoji: '⚡',
                    onChanged: (v) => setState(() => _responseTime = v),
                  ),
                  _MetricSlider(
                    label: '精神的疲労度',
                    description: 'この人と話した後、どのくらい疲れますか？',
                    value: _emotionalDrain,
                    leftEmoji: '😊',
                    rightEmoji: '😩',
                    onChanged: (v) => setState(() => _emotionalDrain = v),
                  ),
                  _MetricSlider(
                    label: 'ポジティブ度',
                    description: 'この人とのやり取りはポジティブですか？',
                    value: _positivity,
                    leftEmoji: '😐',
                    rightEmoji: '🌟',
                    onChanged: (v) => setState(() => _positivity = v),
                  ),
                  _MetricSlider(
                    label: '連絡イニシアチブ',
                    description: '連絡をするのは主にあなたですか？',
                    value: _initiationBalance,
                    leftEmoji: '👈',
                    rightEmoji: '👉',
                    onChanged: (v) => setState(() => _initiationBalance = v),
                  ),
                  _MetricSlider(
                    label: '返信ストレス',
                    description: '返信する時にストレスを感じますか？',
                    value: _replyStress,
                    leftEmoji: '😌',
                    rightEmoji: '😰',
                    onChanged: (v) => setState(() => _replyStress = v),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final double distance;
  final int colorIndex;
  final String name;

  const _PreviewCard(
      {required this.distance, required this.colorIndex, required this.name});

  Color get _color {
    if (distance <= 20) return const Color(0xFF4CAF50);
    if (distance <= 40) return const Color(0xFF8BC34A);
    if (distance <= 60) return const Color(0xFFFFEB3B);
    if (distance <= 80) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarColors[colorIndex % avatarColors.length],
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : '（名前未入力）',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('心理的距離: ${distance.toInt()}',
                      style: TextStyle(color: _color, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _color.withAlpha(30),
                border: Border.all(color: _color, width: 2),
              ),
              child: Center(
                child: Text(
                  '${distance.toInt()}',
                  style: TextStyle(
                      color: _color, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.indigo)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricSlider extends StatelessWidget {
  final String label;
  final String description;
  final int value;
  final String leftEmoji;
  final String rightEmoji;
  final void Function(int) onChanged;
  final bool isLast;

  const _MetricSlider({
    required this.label,
    required this.description,
    required this.value,
    required this.leftEmoji,
    required this.rightEmoji,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text('$value',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Text(description, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Row(
          children: [
            Text(leftEmoji, style: const TextStyle(fontSize: 16)),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Text(rightEmoji, style: const TextStyle(fontSize: 16)),
          ],
        ),
        if (!isLast) const Divider(),
      ],
    );
  }
}
