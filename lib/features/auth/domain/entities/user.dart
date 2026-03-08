class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String role;
  final List<String> assignedProjects;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.assignedProjects = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      assignedProjects: json['assignedProjects'] != null
          ? List<String>.from(json['assignedProjects'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'assignedProjects': assignedProjects,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
  bool get isViewer => role == 'viewer';
}
