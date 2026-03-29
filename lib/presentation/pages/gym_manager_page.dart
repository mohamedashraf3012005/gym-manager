import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/local_member_repository.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/member_status_use_case.dart';

enum GymPage { home, members, expiring, stats }

class GymManagerPage extends StatefulWidget {
  const GymManagerPage({super.key});

  @override
  State<GymManagerPage> createState() => _GymManagerPageState();
}

class _GymManagerPageState extends State<GymManagerPage> {
  final LocalMemberRepository _repository = LocalMemberRepository();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  List<Member> get _members => _repository.members;
  List<Member> get _filteredMembers {
    final query = _searchController.text.trim().toLowerCase();
    return _members.where((member) {
      final matchesQuery =
          member.name.contains(query) || member.phone.contains(query);
      final status = member.status;

      final matchesFilter =
          _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && status == MemberStatus.active) ||
          (_selectedFilter == 'expiring' && status == MemberStatus.expiring) ||
          (_selectedFilter == 'expired' && status == MemberStatus.expired);

      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<Member> get _recentMembers {
    final list = [..._members];
    list.sort((a, b) => b.id.compareTo(a.id));
    return list.take(6).toList();
  }

  List<Member> get _expiringSoon {
    final list = _members
        .where((member) => member.status == MemberStatus.expiring)
        .toList();
    list.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return list;
  }

  List<Member> get _expiredMembers => _members
      .where((member) => member.status == MemberStatus.expired)
      .toList();

  int get _activeCount =>
      _members.where((member) => member.status == MemberStatus.active).length;
  int get _expiringCount =>
      _members.where((member) => member.status == MemberStatus.expiring).length;
  int get _expiredCount =>
      _members.where((member) => member.status == MemberStatus.expired).length;
  int get _totalIncome => _members.fold(0, (sum, member) => sum + member.price);

  @override
  void initState() {
    super.initState();
    _priceController.text = memberPrices[_selectedType]!.toString();
    _renewPriceController.text = memberPrices[_renewType]!.toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _renewPriceController.dispose();
    super.dispose();
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
    _priceController.text = memberPrices[_selectedType]!.toString();
    _selectedStart = DateTime.now();
    _nameController.clear();
    _phoneController.clear();

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
                          items: memberPrices.keys.toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedType = value;
                              _priceController.text =
                                  memberPrices[_selectedType]!.toString();
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
                onPressed: _addMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('حفظ العميل'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addMember() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final price =
        int.tryParse(_priceController.text) ?? memberPrices[_selectedType]!;

    if (name.isEmpty) {
      return;
    }

    final member = Member(
      id: _repository.nextId(),
      name: name,
      phone: phone,
      type: _selectedType,
      price: price,
      start: _selectedStart,
    );

    setState(() {
      _repository.addMember(member);
    });

    Navigator.of(context).pop();
  }

  void _openRenewDialog(Member member) {
    _renewingMember = member;
    _renewType = member.type;
    _renewPriceController.text = memberPrices[_renewType]!.toString();

    showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('🔄 تجديد اشتراك'),
            content: Column(
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
                        items: memberPrices.keys.toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _renewType = value;
                            _renewPriceController.text =
                                memberPrices[_renewType]!.toString();
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
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: _confirmRenew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                ),
                child: const Text('تجديد'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRenew() {
    if (_renewingMember == null) {
      return;
    }

    final price =
        int.tryParse(_renewPriceController.text) ?? memberPrices[_renewType]!;

    setState(() {
      _repository.renewMember(
        _renewingMember!.id,
        _renewType,
        price,
        DateTime.now(),
      );
      _renewingMember = null;
    });

    Navigator.of(context).pop();
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    ).then((confirmed) {
      if (confirmed != true) return;
      setState(() {
        _repository.deleteMember(member.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 1000;
    final isMobile = screenWidth < 760;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: isMobile
            ? Drawer(child: SafeArea(child: _buildSidebar(drawerMode: true)))
            : null,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(now, isMobile),
              Expanded(
                child: isWide
                    ? Row(
                        children: [
                          _buildSidebar(),
                          Expanded(child: _buildPageContent()),
                        ],
                      )
                    : Column(
                        children: [
                          if (!isMobile) _buildSidebar(),
                          Expanded(child: _buildPageContent()),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(DateTime now, bool isMobile) {
    final formattedDate = _formatDate(now);
    final weekday = _formatWeekDay(now);

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.muted),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              const _BrandIcon(),
              const SizedBox(width: 10),
              const Text(
                'إدارة الجيم',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$weekday، $formattedDate',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _openAddMemberDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '+ إضافة عميل',
                  style: TextStyle(fontSize: 16, color: Color(0xffffffff)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool drawerMode = false}) {
    return Container(
      width: drawerMode ? null : 220,
      color: AppColors.card,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              'القوائم',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildSidebarButton(
            '🏠 الرئيسية',
            GymPage.home,
            drawerMode: drawerMode,
          ),
          _buildSidebarButton(
            '👥 العملاء',
            GymPage.members,
            drawerMode: drawerMode,
          ),
          _buildSidebarButton(
            '⏰ منتهية قريباً',
            GymPage.expiring,
            drawerMode: drawerMode,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Text(
              'تقارير',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildSidebarButton(
            '📊 الإحصائيات',
            GymPage.stats,
            drawerMode: drawerMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton(
    String label,
    GymPage page, {
    bool drawerMode = false,
  }) {
    final isActive = _selectedPage == page;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          _setPage(page);
          if (drawerMode) Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppColors.red : AppColors.card,
          foregroundColor: isActive ? Colors.white : AppColors.muted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
        _buildPageHeader('لوحة التحكم', 'أهلا بك فى هيرو جيم '),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
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
        const SizedBox(height: 24),
        if (_expiringCount > 0 || _expiredCount > 0) _buildAlertBar(),
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
                  _buildFilterGroup(),
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
        _buildPageHeader('⏰ قاربت على الانتهاء', ''),
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

    final totalCount = _members.isEmpty ? 1 : _members.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader('📊 الإحصائيات', 'نظرة عامة على أداء الجيم'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
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
                children: [
                  _buildStatusSummary(
                    'نشط',
                    _activeCount,
                    AppColors.green,
                    totalCount,
                  ),
                  _buildStatusSummary(
                    'ينتهي قريباً',
                    _expiringCount,
                    AppColors.orange,
                    totalCount,
                  ),
                  _buildStatusSummary(
                    'منتهي',
                    _expiredCount,
                    AppColors.red,
                    totalCount,
                  ),
                ],
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
            onPressed: _openAddMemberDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('+ عميل جديد'),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String icon,
    Color background,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = min(screenWidth - 56, 240.0);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: TextStyle(fontSize: 24, color: color)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBar() {
    final messages = <String>[];
    if (_expiringCount > 0) {
      messages.add('$_expiringCount عميل اشتراكهم ينتهي خلال 7 أيام');
    }
    if (_expiredCount > 0) {
      messages.add('$_expiredCount عميل اشتراكهم منتهي بالفعل');
    }

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
              'تنبيه: ${messages.join(' — ')} — تواصل معهم للتجديد!',
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

  Widget _buildStatsBox({required String title, required Widget child}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = min(screenWidth - 56, 420.0);
    return Container(
      width: boxWidth,
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
            ),
          ),
          const SizedBox(height: 16),
          child,
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

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: list.map((member) {
        final isCritical = member.daysLeft <= 2;
        final color = isCritical ? AppColors.red : AppColors.orange;
        final background = isCritical
            ? AppColors.redLight
            : AppColors.orangeLight;
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = min(screenWidth - 56, 260.0);

        return Container(
          width: cardWidth,
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
                      member.name.isNotEmpty
                          ? (member.name.length >= 2
                                ? member.name.substring(0, 2)
                                : member.name)
                          : '؟',
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
                member.daysLeft.toString(),
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
                  child: const Text('تجديد'),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('العميل')),
          DataColumn(label: Text('نوع الاشتراك')),
          DataColumn(label: Text('الأيام المتبقية')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('إجراء')),
        ],
        rows: list.map((member) {
          return DataRow(
            cells: [
              DataCell(_buildMemberCell(member)),
              DataCell(Text(member.type)),
              DataCell(
                Text(
                  member.daysLeft < 0 ? 'منتهي' : member.daysLeft.toString(),
                ),
              ),
              DataCell(_buildStatusBadge(member.status)),
              DataCell(
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _openRenewDialog(member),
                  child: const Text('تجديد', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          );
        }).toList(),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('العميل')),
          DataColumn(label: Text('نوع الاشتراك')),
          DataColumn(label: Text('المبلغ')),
          DataColumn(label: Text('انتهاء الاشتراك')),
          DataColumn(label: Text('الأيام المتبقية')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('إجراءات')),
        ],
        rows: list.map((member) {
          return DataRow(
            cells: [
              DataCell(_buildMemberCell(member)),
              DataCell(Text(member.type)),
              DataCell(Text('${member.price} ج')),
              DataCell(Text(_formatDate(member.endDate))),
              DataCell(
                Text(
                  member.daysLeft < 0 ? 'منتهي' : member.daysLeft.toString(),
                ),
              ),
              DataCell(_buildStatusBadge(member.status)),
              DataCell(
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => _openRenewDialog(member),
                      child: const Text(
                        'تجديد',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => _deleteMember(member),
                      child: const Text('حذف', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: expiredMode
            ? const [
                DataColumn(label: Text('العميل')),
                DataColumn(label: Text('نوع الاشتراك')),
                DataColumn(label: Text('انتهى منذ')),
                DataColumn(label: Text('إجراء')),
              ]
            : const [
                DataColumn(label: Text('العميل')),
                DataColumn(label: Text('نوع الاشتراك')),
                DataColumn(label: Text('الأيام المتبقية')),
                DataColumn(label: Text('إجراء')),
              ],
        rows: list.map((member) {
          return expiredMode
              ? DataRow(
                  cells: [
                    DataCell(_buildMemberCell(member)),
                    DataCell(Text(member.type)),
                    DataCell(Text('${member.daysLeft.abs()} يوم')),
                    DataCell(
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () => _openRenewDialog(member),
                        child: const Text(
                          'تجديد',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                )
              : DataRow(
                  cells: [
                    DataCell(_buildMemberCell(member)),
                    DataCell(Text(member.type)),
                    DataCell(Text('${member.daysLeft} يوم')),
                    DataCell(
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () => _openRenewDialog(member),
                        child: const Text(
                          'تجديد',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.light,
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

  Widget _buildFilterGroup() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildFilterChip('الكل', 'all'),
        _buildFilterChip('نشط', 'active'),
        _buildFilterChip('ينتهي قريباً', 'expiring'),
        _buildFilterChip('منتهي', 'expired'),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _setFilter(value),
      selectedColor: AppColors.redLight,
      backgroundColor: AppColors.card,
      labelStyle: TextStyle(
        color: selected ? AppColors.red : AppColors.muted,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
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

  Widget _buildMemberCell(Member member) {
    final color = _accentColor(member.id);
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
            member.name.isNotEmpty
                ? (member.name.length >= 2
                      ? member.name.substring(0, 2)
                      : member.name)
                : '؟',
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

  Widget _buildStatusSummary(
    String label,
    int count,
    Color color,
    int totalCount,
  ) {
    final percent = ((count / totalCount) * 100).round();
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
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
              value: percent / 100,
              color: color,
              backgroundColor: AppColors.border,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percent%',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthChart() {
    const months = ['أكت', 'نوف', 'ديس', 'يناير', 'فبر', 'مارس'];
    const heights = [45, 60, 70, 55, 80, 100];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
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
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
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
            fillColor: AppColors.card,
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
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(_formatDate(date)),
          ),
        ),
      ],
    );
  }

  Color _accentColor(int index) => const [
    Color(0xffe53935),
    Color(0xff3b82f6),
    Color(0xff1eb96a),
    Color(0xfff59e0b),
    Color(0xff8b5cf6),
    Color(0xff06b6d4),
    Color(0xfff43f5e),
    Color(0xff10b981),
  ][index % 8];

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

  String _formatDate(DateTime date) {
    final month = _arabicMonthName(date.month);
    return '${date.day} $month ${date.year}';
  }

  String _formatWeekDay(DateTime date) {
    const weekDays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return weekDays[date.weekday % 7];
  }

  String _arabicMonthName(int month) {
    const names = [
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
    return names[month - 1];
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
