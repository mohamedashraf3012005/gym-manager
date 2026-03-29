import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة الجيم',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.red,
        fontFamily: 'Arial',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.text),
          bodyMedium: TextStyle(color: AppColors.text),
        ),
      ),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xffe2e8f0),
          body: Center(
            child: Container(
              width: 390,
              height: 844,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black, width: 8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      home: const GymManagerPage(),
    );
  }
}

class AppColors {
  static const background = Color(0xfff5f6fa);
  static const card = Color(0xffffffff);
  static const border = Color(0xffe8eaf0);
  static const text = Color(0xff1a1d2e);
  static const muted = Color(0xff8b8fa8);
  static const red = Color(0xffe53935);
  static const redLight = Color(0xfffff5f5);
  static const green = Color(0xff1eb96a);
  static const greenLight = Color(0xfff0fdf6);
  static const orange = Color(0xfff59e0b);
  static const orangeLight = Color(0xfffffbeb);
  static const blue = Color(0xff3b82f6);
  static const blueLight = Color(0xffeff6ff);
}

const Map<String, int> kPrices = {
  'يومي': 40,
  'شهري': 400,
  '3 أشهر': 1100,
  '6 أشهر': 2200,
  'سنوي': 4000,
};

const Map<String, int> kDurations = {
  'يومي': 1,
  'شهري': 30,
  '3 أشهر': 90,
  '6 أشهر': 180,
  'سنوي': 365,
};

const List<String> kMonthNames = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

const List<String> kWeekDays = [
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

const List<Color> kAccentColors = [
  Color(0xffe53935),
  Color(0xff3b82f6),
  Color(0xff1eb96a),
  Color(0xfff59e0b),
  Color(0xff8b5cf6),
  Color(0xff06b6d4),
  Color(0xfff43f5e),
  Color(0xff10b981),
];

enum GymPage { home, members, expiring, stats }

enum MemberStatus { active, expiring, expired }

class Member {
  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.price,
    required this.start,
  });

  final int id;
  String name;
  String phone;
  String type;
  int price;
  DateTime start;
}

class GymManagerPage extends StatefulWidget {
  const GymManagerPage({super.key});

  @override
  State<GymManagerPage> createState() => _GymManagerPageState();
}

class _GymManagerPageState extends State<GymManagerPage> {
  GymPage _selectedPage = GymPage.home;
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _renewPriceController = TextEditingController();
  String _selectedType = 'شهري';
  String _renewType = 'شهري';
  DateTime _selectedStart = DateTime.now();
  Member? _renewingMember;
  late List<Member> _members;

  @override
  void initState() {
    super.initState();
    _members = _sampleMembers();
    _priceController.text = kPrices[_selectedType]!.toString();
    _renewPriceController.text = kPrices[_renewType]!.toString();
  }

  List<Member> _sampleMembers() {
    final now = DateTime.now();
    return [
      Member(
        id: 1,
        name: 'محمد أحمد',
        phone: '01012345678',
        type: 'شهري',
        price: 400,
        start: now.subtract(const Duration(days: 25)),
      ),
      Member(
        id: 2,
        name: 'سارة علي',
        phone: '01098765432',
        type: '3 أشهر',
        price: 1100,
        start: now.subtract(const Duration(days: 85)),
      ),
      Member(
        id: 3,
        name: 'عمر خالد',
        phone: '01123456789',
        type: 'شهري',
        price: 400,
        start: now.subtract(const Duration(days: 28)),
      ),
      Member(
        id: 4,
        name: 'نور حسن',
        phone: '01234567890',
        type: 'سنوي',
        price: 4000,
        start: now.subtract(const Duration(days: 300)),
      ),
      Member(
        id: 5,
        name: 'أحمد محمود',
        phone: '01087654321',
        type: '6 أشهر',
        price: 2200,
        start: now.subtract(const Duration(days: 170)),
      ),
      Member(
        id: 6,
        name: 'هدى فاروق',
        phone: '01011223344',
        type: 'شهري',
        price: 400,
        start: now.subtract(const Duration(days: 4)),
      ),
      Member(
        id: 7,
        name: 'يوسف سامي',
        phone: '01055667788',
        type: '3 أشهر',
        price: 1100,
        start: now.subtract(const Duration(days: 35)),
      ),
      Member(
        id: 8,
        name: 'ريم طارق',
        phone: '01099887766',
        type: 'شهري',
        price: 400,
        start: now.subtract(const Duration(days: 33)),
      ),
    ];
  }

  int _daysLeft(Member member) {
    final end = member.start.add(Duration(days: kDurations[member.type]!));
    final now = DateTime.now();
    final diff = end.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff;
  }

  MemberStatus _memberStatus(Member member) {
    final days = _daysLeft(member);
    if (days < 0) return MemberStatus.expired;
    if (days <= 7) return MemberStatus.expiring;
    return MemberStatus.active;
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${kMonthNames[date.month - 1]} ${date.year}';
  }

  String _formatWeekDay(DateTime date) {
    final index = date.weekday % 7;
    return kWeekDays[index];
  }

  void _setPage(GymPage page) {
    setState(() {
      _selectedPage = page;
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _openAddMemberDialog() {
    _selectedType = 'شهري';
    _priceController.text = kPrices[_selectedType]!.toString();
    _selectedStart = DateTime.now();
    _nameController.text = '';
    _phoneController.text = '';

    showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('➕ إضافة عميل جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInputField(
                    label: 'الاسم',
                    controller: _nameController,
                    hint: 'اسم العميل',
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: 'رقم الهاتف',
                    controller: _phoneController,
                    hint: '01xxxxxxxxx',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'نوع الاشتراك',
                          value: _selectedType,
                          items: kPrices.keys.toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedType = value;
                              _priceController.text = kPrices[_selectedType]!
                                  .toString();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInputField(
                          label: 'المبلغ المدفوع (جنيه)',
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDatePicker(
                    label: 'تاريخ بداية الاشتراك',
                    date: _selectedStart,
                    onSelect: (date) {
                      setState(() {
                        _selectedStart = date;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                onPressed: () {
                  final name = _nameController.text.trim();
                  final phone = _phoneController.text.trim();
                  final price =
                      int.tryParse(_priceController.text) ??
                      kPrices[_selectedType]!;
                  if (name.isEmpty) return;
                  setState(() {
                    _members.add(
                      Member(
                        id: _members.isEmpty
                            ? 1
                            : _members.map((e) => e.id).reduce(max) + 1,
                        name: name,
                        phone: phone,
                        type: _selectedType,
                        price: price,
                        start: _selectedStart,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('حفظ العميل'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openRenewDialog(Member member) {
    _renewingMember = member;
    _renewType = member.type;
    _renewPriceController.text = kPrices[_renewType]!.toString();

    showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('🔄 تجديد اشتراك'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تجديد اشتراك: ${member.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'نوع الاشتراك الجديد',
                          value: _renewType,
                          items: kPrices.keys.toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _renewType = value;
                              _renewPriceController.text = kPrices[_renewType]!
                                  .toString();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInputField(
                          label: 'المبلغ (جنيه)',
                          controller: _renewPriceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                ),
                onPressed: () {
                  if (_renewingMember == null) return;
                  final price =
                      int.tryParse(_renewPriceController.text) ??
                      kPrices[_renewType]!;
                  setState(() {
                    _renewingMember!.type = _renewType;
                    _renewingMember!.price = price;
                    _renewingMember!.start = DateTime.now();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('تجديد'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteMember(Member member) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('هل تريد حذف هذا العميل؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _members.removeWhere((m) => m.id == member.id);
        });
      }
    });
  }

  List<Member> get _filteredMembers {
    final text = _searchController.text.trim().toLowerCase();
    return _members.where((member) {
      final matchesSearch =
          member.name.contains(text) || member.phone.contains(text);
      final status = _memberStatus(member);
      final matchesFilter =
          _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && status == MemberStatus.active) ||
          (_selectedFilter == 'expiring' && status == MemberStatus.expiring) ||
          (_selectedFilter == 'expired' && status == MemberStatus.expired);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<Member> get _expiringSoon {
    return _members
        .where((member) => _memberStatus(member) == MemberStatus.expiring)
        .toList()
      ..sort((a, b) => _daysLeft(a).compareTo(_daysLeft(b)));
  }

  List<Member> get _expiredMembers {
    return _members
        .where((member) => _memberStatus(member) == MemberStatus.expired)
        .toList();
  }

  List<Member> get _recentMembers {
    final list = [..._members];
    list.sort((a, b) => b.id.compareTo(a.id));
    return list.take(6).toList();
  }

  int get _activeCount =>
      _members.where((m) => _memberStatus(m) == MemberStatus.active).length;
  int get _expiringCount =>
      _members.where((m) => _memberStatus(m) == MemberStatus.expiring).length;
  int get _expiredCount =>
      _members.where((m) => _memberStatus(m) == MemberStatus.expired).length;
  int get _totalIncome => _members.fold(0, (sum, m) => sum + m.price);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.card,
          elevation: 0,
          title: Row(
            children: const [
              _BrandIcon(),
              SizedBox(width: 10),
              Text(
                'إدارة الجيم',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_formatWeekDay(now)}، ${_formatDate(now)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _buildPageContent(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: GymPage.values.indexOf(_selectedPage),
          onTap: (index) => _setPage(GymPage.values[index]),
          selectedItemColor: AppColors.red,
          unselectedItemColor: AppColors.muted,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'العملاء'),
            BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'تنبيهات'),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'احصائيات',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.red,
          onPressed: _openAddMemberDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedPage == GymPage.home) _buildHomePage(),
            if (_selectedPage == GymPage.members) _buildMembersPage(),
            if (_selectedPage == GymPage.expiring) _buildExpiringPage(),
            if (_selectedPage == GymPage.stats) _buildStatsPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader('لوحة التحكم', 'أهلا بك فى هيرو جيم'),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildSummaryCard(
              'إجمالي العملاء',
              _members.length.toString(),
              '👥',
              AppColors.blueLight,
              AppColors.blue,
            ),
            _buildSummaryCard(
              'اشتراكات نشطة',
              _activeCount.toString(),
              '✅',
              AppColors.greenLight,
              AppColors.green,
            ),
            _buildSummaryCard(
              'تنتهي قريباً',
              _expiringCount.toString(),
              '⏰',
              AppColors.orangeLight,
              AppColors.orange,
            ),
            _buildSummaryCard(
              'اشتراكات منتهية',
              _expiredCount.toString(),
              '🚨',
              AppColors.redLight,
              AppColors.red,
            ),
          ],
        ),
        if (_expiringCount > 0 || _expiredCount > 0) ...[
          const SizedBox(height: 24),
          _buildAlertBar(),
        ],
        const SizedBox(height: 24),
        _buildSectionCard(
          title: '⏰ هينتهي اشتراكهم قريباً (أقل من 7 أيام)',
          child: _buildExpireGrid(_expiringSoon),
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: '👥 آخر العملاء المضافين',
          child: _buildRecentMembersTable(_recentMembers),
        ),
      ],
    );
  }

  Widget _buildMembersPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader('👥 كل العملاء', '${_filteredMembers.length} عميل'),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'جدول العملاء',
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildFilterChip('الكل', 'all'),
                      _buildFilterChip('نشط', 'active'),
                      _buildFilterChip('ينتهي قريباً', 'expiring'),
                      _buildFilterChip('منتهي', 'expired'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMembersDataTable(_filteredMembers),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiringPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          '⏰ قاربت على الانتهاء',
          "          عملاء يحتاجوا تجديد",
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: '🚨 منتهي بالفعل',
          child: _buildSimpleDataTable(_expiredMembers, expiredMode: true),
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: '⚠️ ينتهي خلال 7 أيام',
          child: _buildSimpleDataTable(_expiringSoon),
        ),
      ],
    );
  }

  Widget _buildStatsPage() {
    final typeCounts = <String, int>{};
    for (final member in _members) {
      typeCounts[member.type] = (typeCounts[member.type] ?? 0) + 1;
    }

    final totals = [
      {'label': 'نشط', 'count': _activeCount, 'color': AppColors.green},
      {
        'label': 'ينتهي قريباً',
        'count': _expiringCount,
        'color': AppColors.orange,
      },
      {'label': 'منتهي', 'count': _expiredCount, 'color': AppColors.red},
    ];

    final totalCount = _members.isEmpty ? 1 : _members.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader('📊 الإحصائيات', 'نظرة عامة على أداء الجيم'),
        const SizedBox(height: 24),
        Column(
          children: [
            _buildStatsBox(
              title: 'أنواع الاشتراكات',
              child: Column(
                children: typeCounts.entries.map((entry) {
                  final color = _typeColor(entry.key);
                  final maxCount = typeCounts.values.isEmpty
                      ? 1
                      : typeCounts.values.reduce(max);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: entry.value / maxCount,
                            color: color,
                            backgroundColor: AppColors.border,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            _buildStatsBox(
              title: 'إجمالي الإيرادات',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_totalIncome جنيه',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'من ${_members.length} عميل مسجل',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMonthChart(),
                ],
              ),
            ),
            _buildStatsBox(
              title: 'توزيع حالة الاشتراكات',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: totals.map((status) {
                  final count = status['count'] as int;
                  final pct = ((count / totalCount) * 100).round();
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: status['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status['label'] as String,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            color: status['color'] as Color,
                            backgroundColor: AppColors.border,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pct%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
        if (_selectedPage == GymPage.members)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _openAddMemberDialog,
            child: const Text(
              '+ عميل جديد',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    String icon,
    Color background,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: TextStyle(fontSize: 20, color: color)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xfffff3cd),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffffc107)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تنبيه: ${_expiringCount > 0 ? '$_expiringCount عميل اشتراكهم ينتهي خلال 7 أيام' : ''}${_expiringCount > 0 && _expiredCount > 0 ? ' — ' : ''}${_expiredCount > 0 ? '$_expiredCount عميل اشتراكهم منتهي بالفعل' : ''} — تواصل معهم للتجديد!',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff856404),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildExpireGrid(List<Member> list) {
    if (list.isEmpty) {
      return const Text(
        'لا يوجد عملاء ينتهي اشتراكهم قريباً 🎉',
        style: TextStyle(color: AppColors.muted, fontSize: 14),
      );
    }
    return Column(
      children: list.map((member) {
        final days = _daysLeft(member);
        final isCritical = days <= 2;
        final color = isCritical ? AppColors.red : AppColors.orange;
        final background = isCritical
            ? AppColors.redLight
            : AppColors.orangeLight;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCritical ? AppColors.red : AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      member.name.substring(0, 2),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$days',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'يوم متبقي',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              Text(
                '${member.type} — ${member.price} جنيه',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _openRenewDialog(member),
                  child: const Text(
                    'تجديد',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentMembersTable(List<Member> list) {
    if (list.isEmpty) {
      return const Text(
        'لا يوجد عملاء حتى الآن.',
        style: TextStyle(color: AppColors.muted),
      );
    }
    return Column(
      children: list.map((member) {
        final status = _memberStatus(member);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildMemberCell(member)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(status),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () => _openRenewDialog(member),
                      child: const Text(
                        'تجديد',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xffffffff),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMemberCell(Member member) {
    final color = kAccentColors[member.id % kAccentColors.length];
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withAlpha(38),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            member.name.substring(0, 2),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              member.phone,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(MemberStatus status) {
    switch (status) {
      case MemberStatus.active:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'نشط',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.green,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      case MemberStatus.expiring:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.orangeLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ينتهي قريباً',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.orange,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      case MemberStatus.expired:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.redLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'منتهي',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.card,
        hintText: 'ابحث باسم العميل...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final active = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => _setFilter(value),
      selectedColor: AppColors.redLight,
      labelStyle: TextStyle(
        color: active ? AppColors.red : AppColors.muted,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _buildMembersDataTable(List<Member> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'لا توجد نتائج مطابقة',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }
    return Column(
      children: list.map((member) {
        final status = _memberStatus(member);
        final days = _daysLeft(member);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildMemberCell(member)),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${member.type} — ${member.price} ج'),
                    Text(
                      days < 0 ? 'منتهي' : 'متبقي $days يوم',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _openRenewDialog(member),
                        child: const Text(
                          'تجديد',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xffffffff),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: const BorderSide(color: AppColors.red),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                      ),
                      onPressed: () => _deleteMember(member),
                      child: const Icon(Icons.delete, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimpleDataTable(List<Member> list, {bool expiredMode = false}) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'لا توجد بيانات',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }
    return Column(
      children: list.map((member) {
        final days = _daysLeft(member);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildMemberCell(member)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      expiredMode
                          ? 'انتهى منذ ${days.abs()} يوم'
                          : 'متبقي $days يوم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: expiredMode ? AppColors.red : AppColors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: () => _openRenewDialog(member),
                      child: const Text(
                        'تجديد',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xffffffff),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsBox({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 1,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'شهري':
        return AppColors.red;
      case '3 أشهر':
        return AppColors.blue;
      case '6 أشهر':
        return AppColors.green;
      case 'سنوي':
        return AppColors.orange;
      default:
        return AppColors.blue;
    }
  }

  Widget _buildMonthChart() {
    final months = ['أكت', 'نوف', 'ديس', 'يناير', 'فبر', 'مارس'];
    final heights = [45, 60, 70, 55, 80, 100];
    return Row(
      children: List.generate(months.length, (index) {
        final isCurrent = index == months.length - 1;
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 100,
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: heights[index].toDouble(),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.green : AppColors.red,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                months[index],
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('ar'),
            );
            if (picked != null) {
              onSelect(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(_formatDate(date)),
          ),
        ),
      ],
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Text(
        '💪',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
