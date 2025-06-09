import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/material.dart';

class AddressService {
  final PocketBase _pb = PocketBase('http://pocketbase.anhpc.online:8090');

  Future<List<Map<String, dynamic>>> fetchAddresses(String userId) async {
    try {
      final result = await _pb.collection('addresses').getFullList(
        filter: '_userid = "$userId"', // Use _userid as per the schema
        sort: '-created', // Sort by created date in descending order
      );
      return result.map((record) => record.toJson()).toList();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      return [];
    }
  }
}