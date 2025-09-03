import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),

              const SizedBox(height: 16),
              _SectionTitle('Manage your task'),
              const SizedBox(height: 8),
              _ManageCard(),

              const SizedBox(height: 16),
              _SectionTitle('Current tasks'),
              const SizedBox(height: 8),
              _CurrentTasksCard(),

              const SizedBox(height: 8),
              const _TagsRow(tags: ['#shipping', '#innovation', '#planning']),

              const SizedBox(height: 16),
              _WebinarCard(),

              const SizedBox(height: 12),
              _MiniInfoStrip(
                leading: Icons.auto_awesome, // Platzhalter
                title: 'By Habits Journal',
                subtitle: 'Productive routine.',
                actionIcon: Icons.more_horiz,
              ),

              const SizedBox(height: 12),
              _CommunityCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------ UI BLÖCKE ------------------------

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Hello, Jenny! 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Welcome back', style: TextStyle(fontSize: 13, color: _Palette.textSecondary)),
            ],
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        Stack(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
            Positioned(
              right: 10, top: 10,
              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: _Palette.accent, shape: BoxShape.circle)),
            ),
          ],
        ),
        const CircleAvatar(radius: 18, backgroundColor: _Palette.card, child: Icon(Icons.person, color: _Palette.textSecondary)),
      ],
    );
  }
}

class _ManageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadows,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatusPill(label: 'In Progress', count: 2, selected: true)),
              const SizedBox(width: 8),
              Expanded(child: _StatusPill(label: 'In Review', count: 8)),
              const SizedBox(width: 8),
              _RoundBtn(icon: Icons.add),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentTasksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadows,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.calendar_today_outlined, size: 16),
            SizedBox(width: 6),
            Text('Thu 10', style: TextStyle(fontWeight: FontWeight.w600)),
            Spacer(),
            _RoundBtn(icon: Icons.add),
          ]),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: Text(
                  'You have 3 tasks for today',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              _Chip(text: 'High'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebinarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.darkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadows,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _Palette.darkCard2, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.play_arrow_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Webinar', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 4),
                Text('Implementation of habits...', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const _Chip(text: '09:00–10:00', inverted: true),
        ],
      ),
    );
  }
}

class _MiniInfoStrip extends StatelessWidget {
  final IconData leading;
  final String title;
  final String subtitle;
  final IconData? actionIcon;
  const _MiniInfoStrip({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadows,
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _Palette.tint, borderRadius: BorderRadius.circular(12)),
            child: Icon(leading, color: _Palette.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: _Palette.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (actionIcon != null) Icon(actionIcon, color: _Palette.textSecondary),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bild-Platzhalter
          Container(height: 120, color: _Palette.tint),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Community', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Productive routine.', style: TextStyle(color: _Palette.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------ KLEINTEILE ------------------------

class _StatusPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  const _StatusPill({required this.label, required this.count, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _Palette.primary : _Palette.chipBg;
    final fg = selected ? Colors.white : _Palette.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? _Palette.primary : _Palette.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: fg)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count', style: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : _Palette.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  const _RoundBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: const BoxDecoration(color: _Palette.primary, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool inverted;
  const _Chip({required this.text, this.inverted = false});

  @override
  Widget build(BuildContext context) {
    final bg = inverted ? Colors.white : _Palette.accent;
    final fg = inverted ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _TagsRow extends StatelessWidget {
  final List<String> tags;
  const _TagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tags.map((t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _Palette.border),
          boxShadow: _shadowsLight,
        ),
        child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      )).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
      onTap: (_) {},
    );
  }
}

/// ------------------------ STYLE ------------------------

class _Palette {
  const _Palette();
  static const bg            = Color(0xFFF1F2F2);
  static const card          = Colors.white;
  static const darkCard      = Color(0xFF4B475A);
  static const darkCard2     = Color(0xFF2E2B38);
  static const tint          = Color(0xFFEBECF8);
  static const primary       = Color(0xFF615BA5); // Lila
  static const accent        = Color(0xFFABDD9C); // Grün
  static const chipBg        = Color(0xFFF5F6F7);
  static const border        = Color(0xFFE3E5E8);
  static const textPrimary   = Color(0xFF070708);
  static const textSecondary = Color(0xFF8E93A0);
}

const _shadows = [
  BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 8)),
];
const _shadowsLight = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 4)),
];
