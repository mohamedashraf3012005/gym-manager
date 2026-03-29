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

enum MemberStatus { active, expiring, expired }
