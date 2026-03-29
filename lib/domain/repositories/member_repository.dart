import '../entities/member.dart';

abstract class MemberRepository {
  List<Member> get members;

  int nextId();

  void addMember(Member member);

  void deleteMember(int memberId);

  void renewMember(int memberId, String type, int price, DateTime start);
}
