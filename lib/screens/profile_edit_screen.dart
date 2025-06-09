import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_quanao/utils/generic_form_page.dart';
import 'package:shop_quanao/utils/show_custom_confirm_dialog.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';
import 'package:shop_quanao/widgets/input_text_widget.dart';

class ProfileEditPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileEditPage({super.key, required this.userData});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late Map<String, dynamic> _editedData;
  final pb = PocketBase('http://pocketbase.anhpc.online:8090');
  bool _hasChanges = false;
  File? _selectedImage;
  bool _deleteAvatar = false;
  late BuildContext scaffoldContext; // Lưu context của Scaffold

  @override
  void initState() {
    super.initState();
    _editedData = Map.from(widget.userData);
    if (_editedData['gender'] == null) _editedData['gender'] = 'Nam';
  }

  void _navigateToEditPage(String field, String title, String save) {
    if (field == 'fullname') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FullnameEditPage(
                title: title,
                save: save,
                userData: _editedData,
                onSave: (value) {
                  setState(() {
                    _editedData['fullname'] = value;
                    _hasChanges =
                        _editedData['fullname'] != widget.userData['fullname'];
                  });
                },
              ),
        ),
      );
    } else if (field == 'cccd') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CCCDEditPage(
                title: title,
                save: save,
                userData: _editedData,
                onSave: (value) {
                  setState(() {
                    _editedData['cccd'] = value;
                    _hasChanges =
                        _editedData['cccd'] != widget.userData['cccd'];
                  });
                },
              ),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.photos.request();
      }

      if (!status.isGranted) {
        showCustomSnackBar(
          context,
          'Vui lòng cấp quyền ${source == ImageSource.camera ? "máy ảnh" : "thư viện ảnh"}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _deleteAvatar = false;
          _hasChanges = true;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null && !_deleteAvatar) return;

    try {
      final uri = Uri.parse(
        'http://pocketbase.anhpc.online:8090/api/collections/users/records/${widget.userData['id']}',
      );
      final request = http.MultipartRequest('PATCH', uri);

      if (_deleteAvatar) {
        // Delete avatar by setting field to empty string
        request.fields['avatar'] = '';
        debugPrint('Sending delete avatar request: avatar=""');
      } else if (_selectedImage != null) {
        // Upload new avatar
        final fileName =
            '${widget.userData['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final mimeType =
            _selectedImage!.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            _selectedImage!.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
        debugPrint('Uploading file: $fileName, MIME: $mimeType');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      debugPrint(
        'Response status: ${response.statusCode}, body: $responseBody',
      );

      if (response.statusCode == 200) {
        final updatedRecord = jsonDecode(responseBody);
        setState(() {
          _editedData['avatar'] = updatedRecord['avatar'] ?? '';
          _selectedImage = null;
          _deleteAvatar = false;
          _hasChanges = false;
        });
      } else {
        final errorData = jsonDecode(responseBody);
        final errorMessage =
            errorData['data']?['avatar']?['message'] ??
            errorData['message'] ??
            'Unknown error';
        throw Exception('Upload failed: $errorMessage');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  void _showGenderDialog() {
    String? selectedGender = _editedData['gender']?.toString();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Chỉnh sửa giới tính',
                style: const TextStyle(color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Nam'),
                    value: 'Nam',
                    groupValue: selectedGender,
                    onChanged:
                        (value) => setStateDialog(() => selectedGender = value),
                  ),
                  RadioListTile<String>(
                    title: const Text('Nữ'),
                    value: 'Nữ',
                    groupValue: selectedGender,
                    onChanged:
                        (value) => setStateDialog(() => selectedGender = value),
                  ),
                  RadioListTile<String>(
                    title: const Text('Khác'),
                    value: 'Khác',
                    groupValue: selectedGender,
                    onChanged:
                        (value) => setStateDialog(() => selectedGender = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedGender != null) {
                      setState(() {
                        _editedData['gender'] = selectedGender;
                        _hasChanges =
                            _editedData['gender'] != widget.userData['gender'];
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDatePicker() {
    DateTime initialDate;
    String? birthdayStr = _editedData['birthday'];

    try {
      if (birthdayStr != null && birthdayStr.isNotEmpty) {
        List<String> parts = birthdayStr.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          initialDate = DateTime(year, month, day);
        } else {
          initialDate = DateTime.now();
        }
      } else {
        initialDate = DateTime.now();
      }

      if (initialDate.isAfter(DateTime.now())) {
        initialDate = DateTime.now();
      }
    } catch (e) {
      initialDate = DateTime.now();
    }

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        final now = DateTime.now();
        final age =
            now.year -
            selectedDate.year -
            ((now.month < selectedDate.month ||
                    (now.month == selectedDate.month &&
                        now.day < selectedDate.day))
                ? 1
                : 0);

        if (age < 16) {
          showCustomSnackBar(
            context,
            'Tuổi phải lớn hơn 16',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }

        setState(() {
          _editedData['birthday'] =
              "${selectedDate.day.toString().padLeft(2, '0')}/"
              "${selectedDate.month.toString().padLeft(2, '0')}/"
              "${selectedDate.year}";
          _hasChanges = _editedData['birthday'] != widget.userData['birthday'];
        });
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      // Upload image or delete avatar if needed
      if (_selectedImage != null || _deleteAvatar) {
        await _uploadImage();
      }

      final body = <String, dynamic>{
        'fullname': _editedData['fullname']?.toString(),
        'cccd':
            _editedData['cccd'] != null
                ? int.parse(_editedData['cccd'].toString())
                : null,
        'gender': _editedData['gender']?.toString(),
        'birthday': _editedData['birthday']?.toString(),
      };

      // Remove null or empty fields to avoid sending invalid data
      body.removeWhere(
        (key, value) => value == null || value.toString().isEmpty,
      );

      // Only send update if there are non-file changes
      if (body.isNotEmpty) {
        final updatedRecord = await pb
            .collection('users')
            .update(widget.userData['id'].toString(), body: body);

        setState(() {
          _editedData = Map.from(updatedRecord.data);
          _hasChanges = false;
        });
      }
      showCustomSnackBar(
        context,
        'Cập nhật hồ sơ thành công',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Error saving changes: $e');
      showCustomSnackBar(
        context,
        'Lỗi khi cập nhật hồ sơ, vui lòng thử lại sau!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          // Show confirmation dialog when there are unsaved changes
          bool? shouldPop = await showCustomConfirmDialog(
            context: context,
            title: 'Cảnh báo',
            content: 'Cập nhật chưa được lưu. Bạn có chắc muốn huỷ thay đổi?',
            cancelText: 'Thoát',
            cancelTextColor: Colors.black,
            confirmText: 'Huỷ thay đổi',
            confirmTextColor: Colors.red,
            backgroundColor: Colors.white,
          );

          return shouldPop ?? false; // Default to false if dialog is dismissed
        }
        return true; // Allow navigation if no changes
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          title: const Text('Sửa hồ sơ'),
          actions: [
            TextButton(
              onPressed: _hasChanges ? _saveChanges : null,
              style: TextButton.styleFrom(
                foregroundColor: _hasChanges ? Colors.black : Colors.grey,
              ),
              child: const Text('Lưu', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Chụp ảnh'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await _pickImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Chọn sẵn có'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await _pickImage(ImageSource.gallery);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Xóa ảnh đại diện'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _selectedImage = null;
                                      _deleteAvatar = true;
                                      _hasChanges = true;
                                    });
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.cancel),
                                  title: const Text('Hủy'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 50,
                          backgroundImage:
                              _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (_editedData['avatar'] != null &&
                                      _editedData['avatar'].isNotEmpty &&
                                      !_deleteAvatar)
                                  ? NetworkImage(
                                    'http://pocketbase.anhpc.online:8090/api/files/users/${widget.userData['id']}/${_editedData['avatar']}',
                                  )
                                  : null,
                          child:
                              (_selectedImage == null &&
                                      (_editedData['avatar'] == null ||
                                          _editedData['avatar'].isEmpty ||
                                          _deleteAvatar))
                                  ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.black54,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Sửa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.grey[300]),
                ListTile(
                  title: const Text('Họ và Tên'),
                  subtitle: Text(_editedData['fullname']?.toString() ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap:
                      () => _navigateToEditPage(
                        'fullname',
                        'họ và tên',
                        'Cập nhật',
                      ),
                ),
                Divider(color: Colors.grey[300]),
                ListTile(
                  title: const Text('Số CCCD'),
                  subtitle: Text(_editedData['cccd']?.toString() ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap:
                      () => _navigateToEditPage('cccd', 'số CCCD', 'Cập nhật'),
                ),
                Divider(color: Colors.grey[300]),
                ListTile(
                  title: const Text('Giới tính'),
                  subtitle: Text(_editedData['gender']?.toString() ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showGenderDialog(),
                ),
                Divider(color: Colors.grey[300]),
                ListTile(
                  title: const Text('Ngày sinh'),
                  subtitle: Text(_editedData['birthday']?.toString() ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showDatePicker(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
