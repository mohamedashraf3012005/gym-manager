import 'dart:math';

import '../domain/entities/member.dart';
import '../domain/repositories/member_repository.dart';

class LocalMemberRepository implements MemberRepository {
  final List<Member> _members = [];

  LocalMemberRepository() {
    final now = DateTime.now();
    _members.addAll([
      Member(
        id: 1,
        name: 'محمد أحمد',
        phone: '01012345678',
        type: 'شهري',
        price: 200,
        start: now.subtract(const Duration(days: 25)),
      ),
      Member(
        id: 2,
        name: 'سارة علي',
        phone: '01098765432',
        type: '3 أشهر',
        price: 550,
        start: now.subtract(const Duration(days: 85)),
      ),
      Member(
        id: 3,
        name: 'عمر خالد',
        phone: '01123456789',
        type: 'شهري',
        price: 200,
        start: now.subtract(const Duration(days: 28)),
      ),
      Member(
        id: 4,
        name: 'نور حسن',
        phone: '01234567890',
        type: 'سنوي',
        price: 1800,
        start: now.subtract(const Duration(days: 300)),
      ),
      Member(
        id: 5,
        name: 'أحمد محمود',
        phone: '01087654321',
        type: '6 أشهر',
        price: 1000,
        start: now.subtract(const Duration(days: 170)),
      ),
      Member(
        id: 6,
        name: 'هدى فاروق',
        phone: '01011223344',
        type: 'شهري',
        price: 200,
        start: now.subtract(const Duration(days: 4)),
      ),
      Member(
        id: 7,
        name: 'يوسف سامي',
        phone: '01055667788',
        type: '3 أشهر',
        price: 550,
        start: now.subtract(const Duration(days: 35)),
      ),
      Member(
        id: 8,
        name: 'ريم طارق',
        phone: '01099887766',
        type: 'شهري',
        price: 200,
        start: now.subtract(const Duration(days: 33)),
      ),
    ]);
  }

  @override
  List<Member> get members => List.unmodifiable(_members);

  @override
  int nextId() => _members.isEmpty
      ? 1
      : _members.map((member) => member.id).reduce(max) + 1;

  @override
  void addMember(Member member) {
    _members.add(member);
  }

  @override
  void deleteMember(int memberId) {
    _members.removeWhere((member) => member.id == memberId);
  }

  @override
  void renewMember(int memberId, String type, int price, DateTime start) {
    final member = _members.firstWhere((member) => member.id == memberId);
    member.type = type;
    member.price = price;
    member.start = start;
  }
}
