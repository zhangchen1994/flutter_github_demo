// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$profileFromJson(Map<String, dynamic> json) {
  return Profile(
    json['user'] as String,
    json['token'] as String,
    json['theme'] as int,
    json['cache'] as String,
    json['lastLogin'] as String,
    json['locale'] as String,
  );
}

Map<String, dynamic> _$profileToJson(Profile instance) => <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
      'theme': instance.theme,
      'cache': instance.cache,
      'lastLogin': instance.lastLogin,
      'locale': instance.locale,
    };