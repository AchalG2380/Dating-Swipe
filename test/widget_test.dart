import 'package:flutter_test/flutter_test.dart';
import 'package:task/dashboard/models/dummy_user.dart';

void main() {
  group('DummyUser Model Tests', () {
    test(
      'DummyUser.fromJson creates a valid user object with nested address',
      () {
        final json = {
          'id': 1,
          'firstName': 'John',
          'lastName': 'Doe',
          'image': 'https://example.com/john.png',
          'age': 25,
          'gender': 'male',
          'address': {'city': 'New York'},
        };

        final user = DummyUser.fromJson(json);

        expect(user.id, 1);
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.fullName, 'John Doe');
        expect(user.image, 'https://example.com/john.png');
        expect(user.age, 25);
        expect(user.gender, 'male');
        expect(user.city, 'New York');
      },
    );

    test('DummyUser.fromJson fallback values check', () {
      final json = {
        'id': 2,
        'firstName': 'Jane',
        // missing lastName, age, gender, address
      };

      final user = DummyUser.fromJson(json);

      expect(user.id, 2);
      expect(user.firstName, 'Jane');
      expect(user.lastName, '');
      expect(user.fullName, 'Jane ');
      expect(user.age, 20); // Default fallback age
      expect(user.gender, 'unknown'); // Default fallback gender
      expect(user.city, 'Unknown'); // Default fallback city
    });

    test('DummyUser serialization to and from SQLite map', () {
      final user = DummyUser(
        id: 5,
        firstName: 'Terry',
        lastName: 'Smith',
        image: 'https://example.com/terry.png',
        age: 30,
        gender: 'male',
        city: 'Miami',
      );

      final swipeMap = user.toMap('accepted');
      expect(swipeMap['id'], 5);
      expect(swipeMap['status'], 'accepted');

      final fromMapUser = DummyUser.fromMap(swipeMap);
      expect(fromMapUser.id, 5);
      expect(fromMapUser.firstName, 'Terry');
      expect(fromMapUser.lastName, 'Smith');
      expect(fromMapUser.city, 'Miami');
    });
  });
}
