import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shop_quanao/screens/signup_screen.dart';
import 'package:shop_quanao/screens/verify_email_screen.dart';
import 'package:shop_quanao/screens/user_profile_screen.dart';
import 'package:shop_quanao/widgets/input_text_widget.dart';
import 'package:shop_quanao/services/auth_service.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';

class LoginScreen extends StatefulWidget {
  final String? email;
  const LoginScreen({super.key, this.email});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final PocketBase pb = PocketBase('http://pocketbase.anhpc.online:8090');

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _pwdController.text.trim();

      final result = await _authService.login(email, password);
      debugPrint('Checking login result: $result');
      if (result != null) {
        try {
          final user = await pb
              .collection('users')
              .getFirstListItem(
                'email="$email"',
                query: {'fields': 'verified'},
              );

          final isVerified = user.data['verified'] as bool;

          if (isVerified) {
            debugPrint('Tài khoản đã được xác minh');
            showCustomSnackBar(
              context,
              'Đăng nhập thành công',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              (route) => false,
            );
          } else {
            debugPrint('Tài khoản chưa được xác minh');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => VerifyEmailScreen(email: email, password: password),
              ),
            );
          }
        } catch (e) {
          showCustomSnackBar(
            context,
            'Không thể kiểm tra trạng thái tài khoản: $e',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
      else {
        showCustomSnackBar(
          context,
          'Đăng nhập không thành công. Vui lòng kiểm tra lại email và mật khẩu.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      showCustomSnackBar(
        context,
        'Vui lòng nhập email hợp lệ để đặt lại mật khẩu',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      await pb
          .collection('users')
          .getFirstListItem('email="$email"', fields: 'id');
      await pb.collection('users').requestPasswordReset(email);
      showCustomSnackBar(
        context,
        'Email đặt lại mật khẩu đã được gửi đến $email',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      if (e is ClientException && e.statusCode == 404) {
        showCustomSnackBar(
          context,
          'Email $email không tồn tại trong hệ thống',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        showCustomSnackBar(
          context,
          'Không thể gửi email đặt lại mật khẩu: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final widgetList = [
      const SizedBox(height: 16),
      Form(
        key: _formKey,
        child: Column(
          children: [
            InputTextWidget(
              controller: _emailController,
              labelText: "Email",
              icon: Icons.email,
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            InputTextWidget(
              controller: _pwdController,
              labelText: "Mật khẩu",
              icon: Icons.lock,
              obscureText: true,
              isPasswordField: true,
              keyboardType: TextInputType.text,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: _handlePasswordReset,
                  child: Text(
                    "Quên mật khẩu?",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _handleLogin,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: Size(screenWidth - 50, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blue.shade200,
                ),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              height: 56,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // TODO: Implement Facebook login
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Image.asset("assets/images/fb.png", height: 24),
                        const SizedBox(width: 12),
                        const Text(
                          "Đăng nhập bằng Facebook",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              height: 56,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // TODO: Implement Google login
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Image.asset("assets/images/google.png", height: 24),
                        const SizedBox(width: 12),
                        const Text(
                          "Đăng nhập bằng Google",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'StyleMen - Đăng nhập',
          style: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  (MediaQuery.of(context).padding.top +
                      kToolbarHeight +
                      kBottomNavigationBarHeight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Column(children: widgetList)],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bạn chưa có tài khoản? ',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              child: Text(
                'Đăng ký ngay',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }
}
