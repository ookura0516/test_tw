import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';
import '../providers/persons_provider.dart';
import '../services/analysis_service.dart';
import '../widgets/distance_meter.dart';
import '../widgets/metric_bar.dart';
import '../widgets/person_avatar.dart';

class PersonDetailScreen extends StatelessWidget {
  final String personId;

  const PersonDetailScreen({super.key, required this.personId});

  static const _metricDescriptions = <String, String>{
    '連絡頻度': '日常的な連絡の多さ',
    '返信速度': '相手の返信の早さ',
    '精神的疲労度': '会話後の疲れ',
    'ポジティブ度': 'やり取りのポジティブさ',
    '連絡イニシアチブ': '連絡を始める側',
    '返信ストレス': '返信時のプレッシャー',
  };

  Color _metricColor(String label, int value) {
    final isNegative = label == '精神的疲労度' || label == '返信ストレス' || label == '連絡イニシアチブ';
    if (isNegative) {
      if (value >= 70) return Colors.red;
      if (value >= 40) return Colors.orange;
      return Colors.green;
    } else {
      if (value >= 70) return Colors.green;
      if (value >= 40) return Colors.orange;
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = context.watch<PersonsProvider>().getPersonById(personId);
    if (person == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('詳細')),
        body: const Center(child: Text('データが見つかりません')),
      );
    }

    final analysis = AnalysisService();
    final color = analysis.getRelationshipColor(person);
    final emoji = analysis.getRelationshipEmoji(person);
    final advice = analysis.getRelationshipAdvice(person);
    final stressAnalysis = analysis.getStressAnalysis(person);
    final actionItems = analysis.getActionItems(person);

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '編集',
            onPressed: () =>
                Navigator.pushNamed(context, '/edit', arguments: person.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Center(
            child: Column(
              children: [
                PersonAvatar(person: person, radius: 48),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(person.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 6),
                _CategoryBadge(
                    label: person.relationshipCategory.displayName, color: color),
                const SizedBox(height: 4),
                Text(
                  person.contactMethod.displayName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Distance meter
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('心理的距離',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Center(
                    child: DistanceMeter(
                        distance: person.psychologicalDistance, size: 220),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.suggestion,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Metrics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('メトリクス',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  MetricBar(
                    label: '連絡頻度',
                    value: person.metrics.frequency,
                    color: _metricColor('連絡頻度', person.metrics.frequency),
                    description: _metricDescriptions['連絡頻度'],
                  ),
                  MetricBar(
                    label: '返信速度',
                    value: person.metrics.responseTime,
                    color: _metricColor('返信速度', person.metrics.responseTime),
                    description: _metricDescriptions['返信速度'],
                  ),
                  MetricBar(
                    label: '精神的疲労度',
                    value: person.metrics.emotionalDrain,
                    color: _metricColor('精神的疲労度', person.metrics.emotionalDrain),
                    description: _metricDescriptions['精神的疲労度'],
                  ),
                  MetricBar(
                    label: 'ポジティブ度',
                    value: person.metrics.positivity,
                    color: _metricColor('ポジティブ度', person.metrics.positivity),
                    description: _metricDescriptions['ポジティブ度'],
                  ),
                  MetricBar(
                    label: '連絡イニシアチブ',
                    value: person.metrics.initiationBalance,
                    color: _metricColor(
                        '連絡イニシアチブ', person.metrics.initiationBalance),
                    description: _metricDescriptions['連絡イニシアチブ'],
                  ),
                  MetricBar(
                    label: '返信ストレス',
                    value: person.metrics.replyStress,
                    color: _metricColor('返信ストレス', person.metrics.replyStress),
                    description: _metricDescriptions['返信ストレス'],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // AI Analysis
          Card(
            color: Colors.indigo[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.psychology, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('AI分析',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AnalysisSection(title: 'アドバイス', content: advice),
                  const SizedBox(height: 12),
                  _AnalysisSection(title: '返信ストレス分析', content: stressAnalysis),
                  const SizedBox(height: 12),
                  _ActionItemsSection(items: actionItems),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Future feature placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.timeline, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('距離の変化履歴',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('（近日公開予定）',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Delete button
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('削除の確認'),
                  content: Text('${person.name}を削除しますか？'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('キャンセル')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('削除'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<PersonsProvider>().deletePerson(person.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('削除', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style:
              TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  final String title;
  final String content;

  const _AnalysisSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.indigo)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
      ],
    );
  }
}

class _ActionItemsSection extends StatelessWidget {
  final List<String> items;

  const _ActionItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('アクションアイテム',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo)),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.indigo, fontSize: 14)),
                  Expanded(
                    child: Text(item,
                        style: const TextStyle(fontSize: 13, height: 1.5)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
