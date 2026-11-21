import 'package:flutter/material.dart';
import 'admin_panel.dart';

void main() => runApp(const MahdiMessengerApp());

class MahdiMessengerApp extends StatefulWidget {
  const MahdiMessengerApp({super.key});
  @override
  State<MahdiMessengerApp> createState() => _MahdiMessengerAppState();
}

class _MahdiMessengerAppState extends State<MahdiMessengerApp> {
  ThemeMode mode = ThemeMode.dark;

  void toggleTheme() => setState(() {
    mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  });

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6C63FF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mahdi Messenger',
      themeMode: mode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF11131A),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: MessengerHome(onToggleTheme: toggleTheme, isDark: mode == ThemeMode.dark),
    );
  }
}

class Chat {
  Chat(this.name, this.message, this.time, this.unread, this.color);
  final String name, message, time;
  final int unread;
  final Color color;
}

class MessengerHome extends StatefulWidget {
  const MessengerHome({super.key, required this.onToggleTheme, required this.isDark});
  final VoidCallback onToggleTheme;
  final bool isDark;
  @override
  State<MessengerHome> createState() => _MessengerHomeState();
}

class _MessengerHomeState extends State<MessengerHome> {
  final search = TextEditingController();
  final chats = <Chat>[
    Chat('گفتگوی شخصی', 'سلام! به پیام‌رسان خوش اومدی 👋', '۱۰:۴۲', 2, const Color(0xFF7C6CF2)),
    Chat('تیم طراحی', 'فایل‌های طرح اولیه آماده شد', 'دیروز', 0, const Color(0xFF21A179)),
    Chat('پشتیبانی', 'چطور می‌تونیم کمکت کنیم؟', 'دوشنبه', 0, const Color(0xFFE39A42)),
    Chat('دوستان', 'عالیه، پس هماهنگ شدیم', 'یکشنبه', 0, const Color(0xFFCF668B)),
  ];
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final filtered = chats.where((c) => c.name.contains(search.text) || c.message.contains(search.text)).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.forum_rounded, color: Color(0xFF8B80FF)),
          SizedBox(width: 10),
          Text('Mahdi Messenger', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'روشن' : 'تاریک',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          IconButton(tooltip: 'پنل مدیریت', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPanelPage())), icon: const Icon(Icons.admin_panel_settings_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: wide
          ? Row(children: [
              SizedBox(width: 340, child: _chatList(filtered)),
              const VerticalDivider(width: 1),
              Expanded(child: ChatView(chat: chats[selected.clamp(0, chats.length - 1)])),
            ])
          : _chatList(filtered),
      ),
      floatingActionButton: wide ? null : FloatingActionButton(
        onPressed: () => _showInfo(context),
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }

  Widget _chatList(List<Chat> list) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'جست‌وجوی گفتگوها',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final c = list[i];
            return ListTile(
              selected: selected == chats.indexOf(c),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: c.color.withValues(alpha: .18),
                child: Text(c.name.characters.first, style: TextStyle(color: c.color, fontWeight: FontWeight.bold)),
              ),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(c.message, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(c.time, style: Theme.of(context).textTheme.labelSmall),
                if (c.unread > 0) ...[
                  const SizedBox(height: 5),
                  CircleAvatar(radius: 9, backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text('${c.unread}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ]),
              onTap: () {
                setState(() => selected = chats.indexOf(c));
                if (MediaQuery.sizeOf(context).width < 760) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatView(chat: c)));
                }
              },
            );
          },
        ),
      ),
    ],
  );

  void _showInfo(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('گفتگوی جدید'),
      content: const Text('اتصال به حساب‌ها و جست‌وجوی کاربران در مرحله بعد اضافه می‌شود.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('باشه'))],
    ));
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.chat});
  final Chat chat;
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final messages = <String>['سلام! به Mahdi Messenger خوش اومدی 👋', 'این نسخه، نمونه اولیه رابط کاربریه.'];
  @override
  void dispose() { input.dispose(); scroll.dispose(); super.dispose(); }

  void send() {
    final value = input.text.trim();
    if (value.isEmpty) return;
    setState(() { messages.add(value); input.clear(); });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      leading: CircleAvatar(child: Text(widget.chat.name.characters.first)),
      title: Text(widget.chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('نمونه محلی • هنوز متصل به سرور نیست'),
      trailing: const Icon(Icons.more_vert),
    ),
    const Divider(height: 1),
    Expanded(
      child: ListView.builder(
        controller: scroll,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (_, i) => Align(
          alignment: i == 0 ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: i == 0 ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(messages[i], style: TextStyle(color: i == 0 ? null : Colors.white)),
          ),
        ),
      ),
    ),
    SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file_rounded)),
          Expanded(child: TextField(
            controller: input,
            onSubmitted: (_) => send(),
            minLines: 1, maxLines: 4,
            decoration: InputDecoration(
              hintText: 'پیام بنویس...',
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
            ),
          )),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: send, icon: const Icon(Icons.send_rounded)),
        ]),
      ),
    ),
  ]);
}
