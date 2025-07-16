import 'package:uuid/uuid.dart';

class UserData {
  final String id; // UUID para diferenciar usuarios
  final String firstName;
  final String lastName;
  final String gender;
  final String handUsed;
  final bool isDominantHand;
  final int age;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.handUsed,
    required this.isDominantHand,
    required this.age,
  }) : id = const Uuid().v4(); // genera UUID automáticamente

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'handUsed': handUsed,
        'isDominantHand': isDominantHand,
        'age': age,
      };
}
