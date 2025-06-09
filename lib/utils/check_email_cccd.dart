import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://pocketbase.anhpc.online:8090');

Future<bool> checkCccdExists(String cccd) async {
  try {
    final record = await pb
        .collection('users')
        .getFirstListItem('cccd="$cccd"');
    // Nếu tìm thấy thì trả về true
    return record != null;
  } catch (e) {
    // Nếu không tìm thấy hoặc lỗi 404, trả về false
    return false;
  }
}

Future<bool> checkEmailExists(String email) async {
  try {
    final record = await pb
        .collection('users')
        .getFirstListItem('email="$email"');
    return record != null;
  } catch (e) {
    return false;
  }
}
