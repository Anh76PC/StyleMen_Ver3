import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:shop_quanao/utils/generic_form_page.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';
import 'package:shop_quanao/widgets/input_text_widget.dart';

class AddShippingAddressPage extends StatefulWidget {
  final PocketBase pb;
  final String userId;

  const AddShippingAddressPage({
    super.key,
    required this.pb,
    required this.userId,
  });

  @override
  State<AddShippingAddressPage> createState() => _AddShippingAddressPageState();
}

class _AddShippingAddressPageState extends State<AddShippingAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fullnameController;
  late TextEditingController phoneController;
  late TextEditingController addressDetailController;
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  String? selectedProvinceCode;
  String? selectedDistrictCode;
  String? selectedWardCode;
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> wards = [];
  bool isDefault = false;
  bool isLoadingProvinces = false;
  bool isLoadingDistricts = false;
  bool isLoadingWards = false;

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController();
    phoneController = TextEditingController();
    addressDetailController = TextEditingController();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    if (isLoadingProvinces) return;
    setState(() {
      isLoadingProvinces = true;
    });
    try {
      final response = await http
          .get(
            Uri.parse('https://provinces.open-api.vn/api/?depth=1'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        debugPrint('Provinces response: $decodedResponse');
        setState(() {
          provinces = List<Map<String, dynamic>>.from(decodedResponse);
          isLoadingProvinces = false;
        });
      } else {
        throw Exception('Failed to fetch provinces: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching provinces: $e');
      if (mounted) {
        showCustomSnackBar(
          context,
          'Lỗi khi tải danh sách tỉnh: $e',
          backgroundColor: Colors.red,
        );
        setState(() {
          isLoadingProvinces = false;
        });
      }
    }
  }

  Future<void> _fetchDistricts(String provinceCode) async {
    if (isLoadingDistricts) return;
    setState(() {
      isLoadingDistricts = true;
    });
    try {
      final response = await http
          .get(
            Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        debugPrint('Districts response: $decodedResponse');
        setState(() {
          districts = List<Map<String, dynamic>>.from(decodedResponse['districts']);
          selectedDistrict = null;
          selectedDistrictCode = null;
          selectedWard = null;
          selectedWardCode = null;
          wards = [];
          isLoadingDistricts = false;
        });
      } else {
        throw Exception('Failed to fetch districts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
      if (mounted) {
        showCustomSnackBar(
          context,
          'Lỗi khi tải danh sách quận: $e',
          backgroundColor: Colors.red,
        );
        setState(() {
          isLoadingDistricts = false;
        });
      }
    }
  }

  Future<void> _fetchWards(String districtCode) async {
    if (isLoadingWards) return;
    setState(() {
      isLoadingWards = true;
    });
    try {
      final response = await http
          .get(
            Uri.parse('https://provinces.open-api.vn/api/d/$districtCode?depth=2'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        debugPrint('Wards response: $decodedResponse');
        setState(() {
          wards = List<Map<String, dynamic>>.from(decodedResponse['wards']);
          selectedWard = null;
          selectedWardCode = null;
          isLoadingWards = false;
        });
      } else {
        throw Exception('Failed to fetch wards: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching wards: $e');
      if (mounted) {
        showCustomSnackBar(
          context,
          'Lỗi khi tải danh sách phường: $e',
          backgroundColor: Colors.red,
        );
        setState(() {
          isLoadingWards = false;
        });
      }
    }
  }

  Future<void> _handleSave(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedProvince == null || selectedDistrict == null || selectedWard == null) {
      showCustomSnackBar(
        context,
        'Vui lòng chọn đầy đủ tỉnh, quận, và phường',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      await widget.pb.collection('addresses').create(
            body: {
              '_userid': widget.userId,
              'fullname': fullnameController.text.trim(),
              'phone': phoneController.text.trim(),
              'addressDetail': addressDetailController.text.trim(),
              'province': selectedProvince,
              'district': selectedDistrict,
              'ward': selectedWard,
              'provinceCode': selectedProvinceCode,
              'districtCode': selectedDistrictCode,
              'wardCode': selectedWardCode,
              'isDefault': isDefault,
            },
          );
      showCustomSnackBar(
        context,
        'Thêm địa chỉ thành công',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error saving address: $e');
      showCustomSnackBar(
        context,
        'Lỗi khi thêm địa chỉ: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _updateDefaultAddress(bool value) async {
    try {
      // Fetch all addresses for the user
      final records = await widget.pb.collection('addresses').getFullList(
            filter: '(_userid = "${widget.userId}" && isDefault = true)',
          );

      // Update existing default addresses to false
      for (var record in records) {
        await widget.pb.collection('addresses').update(
              record.id,
              body: {'isDefault': false},
            );
      }

      // Set the new address's isDefault state
      setState(() {
        isDefault = value;
      });
    } catch (e) {
      debugPrint('Error updating default address: $e');
      if (mounted) {
        showCustomSnackBar(
          context,
          'Lỗi khi cập nhật địa chỉ mặc định: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    phoneController.dispose();
    addressDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GenericFormPage(
      title: 'Địa chỉ mới',
      save: 'HOÀN THÀNH',
      hasChanges: fullnameController.text.trim().isNotEmpty ||
          phoneController.text.trim().isNotEmpty ||
          addressDetailController.text.trim().isNotEmpty ||
          selectedProvince != null ||
          selectedDistrict != null ||
          selectedWard != null ||
          isDefault,
      inputFields: [
        InputTextWidget(
          labelText: 'Họ và tên',
          keyboardType: TextInputType.text,
          icon: Icons.person,
          controller: fullnameController,
          validator: (value) =>
              value?.trim().isEmpty ?? true ? 'Họ và tên không được để trống' : null,
        ),
        InputTextWidget(
          labelText: 'Số điện thoại',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          controller: phoneController,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Số điện thoại không được để trống';
            }
            if (!RegExp(r'^\+?\d{10,12}$').hasMatch(value!.trim())) {
              return 'Số điện thoại không hợp lệ';
            }
            return null;
          },
        ),
        InputTextWidget(
          labelText: 'Số nhà, tên đường...',
          keyboardType: TextInputType.text,
          icon: Icons.location_city,
          controller: addressDetailController,
          validator: (value) =>
              value?.trim().isEmpty ?? true ? 'Địa chỉ chi tiết không được để trống' : null,
        ),
      ],
      onSave: _handleSave,
      additionalWidgets: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0), // 30px top margin
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tỉnh/Thành phố pair on its own line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tỉnh/Thành phố:',
                      style: TextStyle(fontSize: 14.0, color: Colors.black87),
                    ),
                    const SizedBox(height: 8.0),
                    isLoadingProvinces
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              padding: const EdgeInsets.only(left: 10),
                              value: selectedProvince,
                              hint: const Text(
                                'Chọn Tỉnh/Thành phố',
                                style: TextStyle(fontSize: 14.0, color: Colors.grey),
                              ),
                              style: const TextStyle(fontSize: 14.0, color: Colors.black),
                              underline: const SizedBox(),
                              items: provinces.map((province) {
                                return DropdownMenuItem<String>(
                                  value: province['name'],
                                  child: Text(
                                    province['name'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  onTap: () {
                                    selectedProvinceCode = province['code'].toString();
                                  },
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedProvince = value;
                                    final selected = provinces.firstWhere((p) => p['name'] == value);
                                    selectedProvinceCode = selected['code'].toString();
                                    selectedDistrict = null;
                                    selectedDistrictCode = null;
                                    selectedWard = null;
                                    selectedWardCode = null;
                                    _fetchDistricts(selectedProvinceCode!);
                                  });
                                }
                              },
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0), // Vertical spacing between lines
              // Quận/Huyện pair on its own line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quận/Huyện:',
                      style: TextStyle(fontSize: 14.0, color: Colors.black87),
                    ),
                    const SizedBox(height: 8.0),
                    isLoadingDistricts
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              padding: const EdgeInsets.only(left: 10),
                              value: selectedDistrict,
                              hint: const Text(
                                'Chọn Quận/Huyện',
                                style: TextStyle(fontSize: 14.0, color: Colors.grey),
                              ),
                              style: const TextStyle(fontSize: 14.0, color: Colors.black),
                              underline: const SizedBox(),
                              items: districts.map((district) {
                                return DropdownMenuItem<String>(
                                  value: district['name'],
                                  child: Text(
                                    district['name'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  onTap: () {
                                    selectedDistrictCode = district['code'].toString();
                                  },
                                );
                              }).toList(),
                              onChanged: districts.isNotEmpty
                                  ? (value) {
                                      setState(() {
                                        selectedDistrict = value;
                                        final selected = districts.firstWhere((d) => d['name'] == value);
                                        selectedDistrictCode = selected['code'].toString();
                                        selectedWard = null;
                                        selectedWardCode = null;
                                        _fetchWards(selectedDistrictCode!);
                                      });
                                    }
                                  : null,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0), // Vertical spacing between lines
              // Phường/Xã pair on its own line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phường/Xã:',
                      style: TextStyle(fontSize: 14.0, color: Colors.black87),
                    ),
                    const SizedBox(height: 8.0),
                    isLoadingWards
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              padding: const EdgeInsets.only(left: 10),
                              value: selectedWard,
                              hint: const Text(
                                'Chọn Phường/Xã',
                                style: TextStyle(fontSize: 14.0, color: Colors.grey),
                              ),
                              style: const TextStyle(fontSize: 14.0, color: Colors.black),
                              underline: const SizedBox(),
                              items: wards.map((ward) {
                                return DropdownMenuItem<String>(
                                  value: ward['name'],
                                  child: Text(
                                    ward['name'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  onTap: () {
                                    selectedWardCode = ward['code'].toString();
                                  },
                                );
                              }).toList(),
                              onChanged: wards.isNotEmpty
                                  ? (value) {
                                      setState(() {
                                        selectedWard = value;
                                        final selected = wards.firstWhere((w) => w['name'] == value);
                                        selectedWardCode = selected['code'].toString();
                                      });
                                    }
                                  : null,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0), // Vertical spacing before SwitchListTile
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                title: const Text(
                  'Đặt làm địa chỉ mặc định',
                  style: TextStyle(fontSize: 14.0, color: Colors.black87),
                ),
                value: isDefault,
                activeColor: Colors.white, // Màu của nút gạt khi bật
                activeTrackColor: Colors.orangeAccent, // Màu nền của track khi bật
                onChanged: (value) async {
                  await _updateDefaultAddress(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}