import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';
import '../providers/persons_provider.dart';
import '../services/analysis_service.dart';
import '../widgets/relationship_map_painter.dart';
import '../widgets/person_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnalysisService _analysis = AnalysisService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonsProvider>().loadPersons();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDetail(BuildContext context, Person person) {
    Navigator.pushNamed(context, '/person', arguments: person.id);
  }

  Future<void> _confirmDelete(
      BuildContext context, Person person, PersonsProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('${person.name}を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deletePerson(person.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '人間関係の距離感',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.hub), text: '関係マップ'),
            Tab(icon: Icon(Icons.list), text: 'リスト'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MapTab(onPersonTap: (p) => _openDetail(context, p)),
          _ListTab(
            onPersonTap: (p) => _openDetail(context, p),
            onPersonDelete: (p, provider) =>
                _confirmDelete(context, p, provider),
            analysis: _analysis,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('追加'),
      ),
    );
  }
}

class _MapTab extends StatelessWidget {
  final void Function(Person) onPersonTap;

  const _MapTab({required this.onPersonTap});

  @override
  Widget build(BuildContext context) {
    final persons = context.watch<PersonsProvider>().persons;
    return Column(
      children: [
        Expanded(
          child: persons.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hub_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('まだ人が追加されていません',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('「追加」ボタンから人を追加してください',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: RelationshipMap(
                    persons: persons,
                    onPersonTap: onPersonTap,
                  ),
                ),
        ),
        // Legend
        _Legend(),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = <(Color, String)>[
      (const Color(0xFF4CAF50), '親密 (0-20)'),
      (const Color(0xFF8BC34A), '近い (21-40)'),
      (const Color(0xFFFFEB3B), '普通 (41-60)'),
      (const Color(0xFFFF9800), '遠い (61-80)'),
      (const Color(0xFFF44336), '疎遠 (81-100)'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: items.map((item) {
          final (color, label) = item;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.black87)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ListTab extends StatelessWidget {
  final void Function(Person) onPersonTap;
  final void Function(Person, PersonsProvider) onPersonDelete;
  final AnalysisService analysis;

  const _ListTab({
    required this.onPersonTap,
    required this.onPersonDelete,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonsProvider>();
    final persons = provider.persons;

    if (persons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('まだ人が追加されていません',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: persons.length,
      itemBuilder: (context, index) {
        final person = persons[index];
        final color = analysis.getRelationshipColor(person);
        final emoji = analysis.getRelationshipEmoji(person);

        return Dismissible(
          key: Key(person.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            onPersonDelete(person, provider);
            return false;
          },
          background: Container(
            color: Colors.red[100],
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.red),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: PersonAvatar(person: person, radius: 22),
              title: Row(
                children: [
                  Text(person.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _CategoryBadge(
                          label: person.relationshipCategory.displayName,
                          color: color),
                      const SizedBox(width: 8),
                      Text(person.contactMethod.displayName,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('返信ストレス: ',
                          style: TextStyle(fontSize: 11)),
                      _StressIndicator(level: person.metrics.replyStress),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${person.psychologicalDistance.toInt()}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Text('距離', style: TextStyle(fontSize: 10)),
                ],
              ),
              isThreeLine: true,
              onTap: () => onPersonTap(person),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        border: Border.all(color: color.withAlpha(100)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StressIndicator extends StatelessWidget {
  final int level;

  const _StressIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    final filled = (level / 20).ceil().clamp(0, 5);
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          Icons.circle,
          size: 10,
          color: i < filled ? Colors.red[300] : Colors.grey[300],
        ),
      ),
    );
  }
}
