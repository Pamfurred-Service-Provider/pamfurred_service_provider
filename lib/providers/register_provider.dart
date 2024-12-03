import 'package:flutter_riverpod/flutter_riverpod.dart';

final pinnedLatitudeProvider = StateProvider<double?>((ref) => null);
final pinnedLongitudeProvider = StateProvider<double?>((ref) => null);
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final floorUnitRoomProvider = StateProvider<String?>((ref) => '');
final streetProvider = StateProvider<String?>((ref) => '');
final barangayProvider = StateProvider<String?>((ref) => '');
final cityProvider = StateProvider<String?>((ref) => '');
final nameProvider = StateProvider<String?>((ref) => '');
final phoneNumberProvider = StateProvider<String?>((ref) => '');
