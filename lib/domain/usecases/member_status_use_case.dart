import '../entities/member.dart';

const Map<String, int> memberDurations = {
  'يومي': 1,
  'شهري': 30,
  '3 أشهر': 90,
  '6 أشهر': 180,
  'سنوي': 365,
};

const Map<String, int> memberPrices = {
  'يومي': 50,
  'شهري': 200,
  '3 أشهر': 550,
  '6 أشهر': 1000,
  'سنوي': 1800,
};

DateTime calculateEndDate(Member member) {
  return member.start.add(Duration(days: memberDurations[member.type] ?? 30));
}

int calculateDaysLeft(Member member) {
  final endDate = calculateEndDate(member);
  final now = DateTime.now();
  final normalizedNow = DateTime(now.year, now.month, now.day);
  return endDate.difference(normalizedNow).inDays;
}

MemberStatus deriveMemberStatus(int daysLeft) {
  if (daysLeft < 0) return MemberStatus.expired;
  if (daysLeft <= 7) return MemberStatus.expiring;
  return MemberStatus.active;
}

extension MemberStatusExtensions on Member {
  DateTime get endDate => calculateEndDate(this);

  int get daysLeft => calculateDaysLeft(this);

  MemberStatus get status => deriveMemberStatus(daysLeft);
}
