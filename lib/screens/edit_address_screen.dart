import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:shop_quanao/utils/generic_form_page.dart';
import 'package:shop_quanao/widgets/input_text_widget.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';

class EditShippingAddressPage extends StatefulWidget {
  final PocketBase pb;
  final String userId;
  final Map<String, dynamic> addressData;

  const EditShippingAddressPage({
    super.key,
    required this.pb,
    required this.userId,
    required this.addressData,
  });

  @override
  State<EditShippingAddressPage> createState() => _EditShippingAddressPageState();
}

class _EditShippingAddressPageState extends State<EditShippingAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fullnameController;
  late TextEditingController phoneController;
  late TextEditingController addressDetailController;
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> wards = [];

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController(text: widget.addressData['fullname'] ?? '');
    phoneController = TextEditingController(text: widget.addressData['phone'] ?? '');
    addressDetailController = TextEditingController(text: widget.addressData['addressDetail'] ?? '');
    selectedProvince = widget.addressData['province'];
    selectedDistrict = widget.addressData['district'];
    selectedWard = widget.addressData['ward'];
    _fetchProvinces();
    if (selectedProvince != null) _fetchDistricts(selectedProvince!);
    if (selectedDistrict != null) _fetchWards(selectedDistrict!);
  }

  Future<void> _fetchProvinces() async {
  try {
    final response = await http.get(Uri.parse('https://open.oapi.vn/location/provinces'));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      setState(() {
        provinces = (decodedResponse['data'] as List<dynamic>).cast<Map<String, dynamic>>();
      });
    }
  } catch (e) {
    debugPrint('Error fetching provinces: $e');
    showCustomSnackBar(context, 'Lỗi khi tải danh sách tỉnh', backgroundColor: Colors.red);
  }
}

Future<void> _fetchDistricts(String provinceId) async {
  try {
    final response = await http.get(Uri.parse('https://open.oapi.vn/location/districts/$provinceId'));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      setState(() {
        districts = (decodedResponse['data'] as List<dynamic>).cast<Map<String, dynamic>>();
      });
    }
  } catch (e) {
    debugPrint('Error fetching districts: $e');
    showCustomSnackBar(context, 'Lỗi khi tải danh sách quận', backgroundColor: Colors.red);
  }
}

Future<void> _fetchWards(String districtId) async {
  try {
    final response = await http.get(Uri.parse('https://open.oapi.vn/location/wards/$districtId'));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      setState(() {
        wards = (decodedResponse['data'] as List<dynamic>).cast<Map<String, dynamic>>();
      });
    }
  } catch (e) {
    debugPrint('Error fetching wards: $e');
    showCustomSnackBar(context, 'Lỗi khi tải danh sách phường', backgroundColor: Colors.red);
  }
}

  Future<void> _handleSave(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    try {
      await widget.pb.collection('addresses').update(
            widget.addressData['id'],
            body: {
              'fullname': fullnameController.text.trim(),
              'phone': phoneController.text.trim(),
              'addressDetail': addressDetailController.text.trim(),
              'province': selectedProvince,
              'district': selectedDistrict,
              'ward': selectedWard,
              'isDefault': widget.addressData['isDefault'] ?? false,
            },
          );
      showCustomSnackBar(context, 'Cập nhật địa chỉ thành công', backgroundColor: Colors.green);
      Navigator.pop(context);
    } catch (e) {
      showCustomSnackBar(context, 'Lỗi khi cập nhật địa chỉ', backgroundColor: Colors.red);
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
      title: 'Sửa Địa chỉ',
      save: 'HOÀN THÀNH',
      hasChanges: fullnameController.text != (widget.addressData['fullname'] ?? '') ||
          phoneController.text != (widget.addressData['phone'] ?? '') ||
          addressDetailController.text != (widget.addressData['addressDetail'] ?? ''),
      inputFields: [
        InputTextWidget(
          labelText: 'Họ và tên',
          icon: Icons.person,
          keyboardType: TextInputType.text,
          autofocus: true,
          controller: fullnameController,
          validator: (value) => value?.isEmpty ?? true ? 'Họ và tên không được để trống' : null,
        ),
        InputTextWidget(
          labelText: 'Số điện thoại',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          controller: phoneController,
          validator: (value) => value?.isEmpty ?? true ? 'Số điện thoại không được để trống' : null,
        ),
        InputTextWidget(
          labelText: 'Số nhà, tên đường...',
          keyboardType: TextInputType.text,
          icon: Icons.location_city,
          controller: addressDetailController,
          validator: (value) => value?.isEmpty ?? true ? 'Địa chỉ chi tiết không được để trống' : null,
        ),
      ],
      onSave: _handleSave,
      additionalWidgets: [
        ListTile(
          title: const Text('Tỉnh/Thành phố:'),
          trailing: DropdownButton<String>(
            value: selectedProvince,
            hint: const Text('Chọn Tỉnh/Thành'),
            items: provinces.map((province) {
              return DropdownMenuItem<String>(
                value: province['id'].toString(),
                child: Text(province['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedProvince = value;
                selectedDistrict = null;
                selectedWard = null;
                _fetchDistricts(value!);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Quận/Huyện:'),
          trailing: DropdownButton<String>(
            value: selectedDistrict,
            hint: const Text('Chọn Quận/Huyện'),
            items: districts.map((district) {
              return DropdownMenuItem<String>(
                value: district['id'].toString(),
                child: Text(district['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDistrict = value;
                selectedWard = null;
                _fetchWards(value!);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Phường/Xã:'),
          trailing: DropdownButton<String>(
            value: selectedWard,
            hint: const Text('Chọn Phường/Xã'),
            items: wards.map((ward) {
              return DropdownMenuItem<String>(
                value: ward['id'].toString(),
                child: Text(ward['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedWard = value;
              });
            },
          ),
        ),
        SwitchListTile(
          title: const Text('Đặt làm địa chỉ mặc định'),
          value: widget.addressData['isDefault'] ?? false,
          onChanged: (value) {
            // TODO: Cập nhật isDefault nếu cần
          },
        ),
      ],
    );
  }
}