import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:shop_quanao/screens/login_screen.dart';
import 'package:shop_quanao/services/auth_service.dart';
import 'package:shop_quanao/utils/show_custom_confirm_dialog.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';
import 'package:shop_quanao/widgets/input_text_widget.dart';
import 'package:flutter/material.dart';

class GenericFormPage extends StatefulWidget {
  final String title;
  final String save;
  final List<InputTextWidget> inputFields;
  final Function(GlobalKey<FormState>)? onSave;
  final bool hasChanges;
  final List<Widget>? additionalWidgets;

  const   GenericFormPage({
    super.key,
    required this.title,
    required this.save,
    required this.inputFields,
    this.onSave,
    required this.hasChanges,
    this.additionalWidgets,
  });

  @override
  State<GenericFormPage> createState() => _GenericFormPageState();
}

class _GenericFormPageState extends State<GenericFormPage> {
  final _formKey = GlobalKey<FormState>();

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave?.call(_formKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: widget.hasChanges ? _handleSave : null,
            child: Text(
              widget.save,
              style: TextStyle(
                color: widget.hasChanges ? Colors.black : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Add spacing between input fields
              ...widget.inputFields
                  .asMap()
                  .entries
                  .map((entry) => Padding(
                        padding: EdgeInsets.only(
                          bottom: entry.key < widget.inputFields.length - 1 ? 20.0 : 0,
                        ),
                        child: entry.value,
                      ))
                  ,
              if (widget.additionalWidgets != null) ...widget.additionalWidgets!,
            ],
          ),
        ),
      ),
    );
  }
}
// FullnameEditPage
class FullnameEditPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String title;
  final String save;
  final Function(String) onSave;

  const FullnameEditPage({
    super.key,
    required this.userData,
    required this.title,
    required this.save,
    required this.onSave,
  });

  @override
  State<FullnameEditPage> createState() => _FullnameEditPageState();
}

class _FullnameEditPageState extends State<FullnameEditPage> {
  late TextEditingController controller;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.userData['fullname']?.toString() ?? '',
    );
    controller.addListener(() {
      setState(() {
        hasChanges = controller.text.trim() != (widget.userData['fullname']?.toString() ?? '');
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GenericFormPage(
      title: "Sửa ${widget.title}",
      save: widget.save,
      hasChanges: hasChanges,
      inputFields: [
        InputTextWidget(
          labelText: 'Họ và Tên',
          icon: Icons.person,
          keyboardType: TextInputType.text,
          controller: controller,
          autofocus: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Họ và tên không được để trống';
            }
            return null;
          },
        ),
      ],
      onSave: (formKey) {
        if (controller.text.trim().isNotEmpty) {
          widget.onSave(controller.text.trim());
          Navigator.pop(context);
        } else {
          showCustomSnackBar(
            context,
            'Họ và tên không được để trống',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
    );
  }
}

// CCCDEditPage
class CCCDEditPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String title;
  final String save;
  final Function(int?) onSave;

  const CCCDEditPage({
    super.key,
    required this.userData,
    required this.title,
    required this.save,
    required this.onSave,
  });

  @override
  State<CCCDEditPage> createState() => _CCCDEditPageState();
}

class _CCCDEditPageState extends State<CCCDEditPage> {
  late TextEditingController controller;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.userData['cccd']?.toString() ?? '',
    );
    controller.addListener(() {
      setState(() {
        hasChanges = controller.text.trim() != (widget.userData['cccd']?.toString() ?? '');
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GenericFormPage(
      title: "Sửa ${widget.title}",
      save: widget.save,
      hasChanges: hasChanges,
      inputFields: [
        InputTextWidget(
          labelText: 'Số CCCD',
          autofocus: true,
          icon: Icons.badge,
          keyboardType: TextInputType.number,
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'CCCD không được để trống';
            }
            if (value.length != 12 || int.tryParse(value) == null) {
              return 'CCCD phải đủ 12 chữ số';
            }
            return null;
          },
        ),
      ],
      onSave: (formKey) {
        final cccd = int.tryParse(controller.text.trim());
        if (cccd != null && controller.text.trim().length == 12) {
          widget.onSave(cccd);
          Navigator.pop(context);
        } else {
          showCustomSnackBar(
            context,
            'CCCD phải đủ 12 chữ số',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
    );
  }
}

class EmailEditPage extends StatefulWidget {
  final String email;
  final String title;
  final String save;

  const EmailEditPage({
    super.key,
    required this.email,
    required this.title,
    required this.save,
  });

  @override
  State<EmailEditPage> createState() => _EmailEditPageState();
}

class _EmailEditPageState extends State<EmailEditPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hasChanges = false;
  String? emailError;
  final PocketBase pb = PocketBase('http://pocketbase.anhpc.online:8090');

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateChanges);
    passwordController.addListener(_updateChanges);
  }

  void _updateChanges() {
    if (mounted) {
      setState(() {
        hasChanges = emailController.text.trim().isNotEmpty &&
            passwordController.text.trim().isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailChange(GlobalKey<FormState> _formKey) async {
  // Reset lỗi trước khi kiểm tra
  setState(() {
    emailError = null;
  });

  // Kiểm tra hợp lệ
  if (!_formKey.currentState!.validate()) {
    debugPrint('Form validation failed');
    return;
  }

  try {
    // Xác thực người dùng với email và mật khẩu hiện tại
    final authResponse = await pb.collection('users').authWithPassword(
          widget.email,
          passwordController.text.trim(),
        );

    // Kiểm tra token để đảm bảo xác thực thành công
    if (authResponse.token.isEmpty) {
      throw Exception('Xác thực thất bại: Token rỗng');
    }

    

    // Hỏi xác nhận từ người dùng trước khi logout
    final confirmLogout = await showCustomConfirmDialog(
      context: context,
      title: 'Xác nhận thay đổi email',
      content:
          'StyleMen sẽ gửi một email xác nhận đến ${emailController.text.trim()}.\nVui lòng kiểm tra email và xác nhận để hoàn tất thay đổi.',
      confirmText: 'Đăng xuất',
      confirmTextColor: Colors.green,
      cancelText: 'Hủy',
      cancelTextColor: Colors.red,
      backgroundColor: Colors.white,
    );

    if (confirmLogout != true) return;
    // Gửi yêu cầu thay đổi email
    await pb.collection('users').requestEmailChange(emailController.text.trim());
    debugPrint('Email change request sent');
    // Logout ngay sau khi gửi yêu cầu đổi email
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    debugPrint('Logged out');
    // Chuyển sang màn login và xóa toàn bộ stack
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(email: emailController.text.trim()),
        ),
        (route) => false,
      );
    }
  } catch (e) {
    debugPrint('Error: $e');
    if (mounted) {
      setState(() {
        if (e is ClientException && e.statusCode == 400) {
          showCustomSnackBar(
            context,
            'Mật khẩu không đúng, vui lòng kiểm tra lại.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        } else {
          emailError = 'Đã xảy ra lỗi khi gửi yêu cầu đổi email. Vui lòng thử lại.';
          showCustomSnackBar(
            context,
            'Đã xảy ra lỗi, vui lòng thử lại.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
        hasChanges = emailController.text.trim().isNotEmpty &&
            passwordController.text.trim().isNotEmpty;
      });
      _formKey.currentState?.validate(); // Gọi lại validate để hiển thị lỗi mới
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return GenericFormPage(
      title: widget.title,
      save: widget.save,
      hasChanges: hasChanges,
      inputFields: [
        InputTextWidget(
          labelText: 'Mật khẩu',
          icon: Icons.lock,
          controller: passwordController,
          isPasswordField: true,
          autofocus: true,
          keyboardType: TextInputType.text,
          obscureText: true,
          disableValidator: true,

        ),
        InputTextWidget(
          labelText: 'Email mới',
          icon: Icons.email,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return emailError;
          },
        ),
      ],
      onSave: _handleEmailChange,
    );
  }
}