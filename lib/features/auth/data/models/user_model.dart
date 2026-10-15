import '../../../profile/data/models/provider_profile_model.dart';
import '../../../profile/domain/entities/provider_profile.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    super.phone,
    super.avatarUrl,
    super.providerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: _parseRole(json['role'] as String?),
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      providerProfile: json['providerProfile'] != null &&
              json['providerProfile'] is Map<String, dynamic>
          ? ProviderProfileModel.fromJson(
              json['providerProfile'] as Map<String, dynamic>)
          : null,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      providerProfile: user.providerProfile,
    );
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'provider':
        return UserRole.provider;
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (providerProfile != null)
        'providerProfile': providerProfile is ProviderProfileModel
            ? (providerProfile as ProviderProfileModel).toJson()
            : ProviderProfileModel.fromEntity(providerProfile!).toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? phone,
    String? avatarUrl,
    ProviderProfile? providerProfile,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      providerProfile: providerProfile ?? this.providerProfile,
    );
  }
}
