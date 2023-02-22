/// 저장이 가능한 객체임을 나타내는 추상 클래스.
abstract class Savable {
  Map<String, dynamic> toJson();
}