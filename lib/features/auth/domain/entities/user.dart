import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/provider_profile.dart';

enum UserRole { customer, provider, admin }

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;

  final String? phone;
  final String? avatarUrl;
  final ProviderProfile? providerProfile;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.providerProfile,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, email, firstName, lastName, role, phone, avatarUrl, providerProfile];
}
