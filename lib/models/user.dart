class User {
  final String username;
  final String password;
  final String role;
  final String displayName;

  const User({
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
  });

  static const List<User> users = [
    User(
      username: 'bombero1',
      password: 'password123',
      role: 'bombero',
      displayName: 'Bombero',
    ),
    User(
      username: 'salud1',
      password: 'password123',
      role: 'personal de salud',
      displayName: 'Personal de Salud',
    ),
  ];

  static User? authenticate(String username, String password) {
    try {
      return users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  String get roleIcon {
    switch (role) {
      case 'bombero':
        return '🚒';
      case 'personal de salud':
        return '👩‍⚕️';
      default:
        return '👤';
    }
  }
} 