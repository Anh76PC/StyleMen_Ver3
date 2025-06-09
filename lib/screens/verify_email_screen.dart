import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'login_screen.dart';
import '../utils/snackbar_utils.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String password;
  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final PocketBase pb = PocketBase('http://pocketbase.anhpc.online:8090');
  bool _isLoading = false;
  bool _emailSent = false;
  late String _currentEmail;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email;
  }

  Future<void> _requestVerification() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('Sending verification request for $_currentEmail');
      await pb.collection('users').requestVerification(_currentEmail);
      setState(() {
        _emailSent = true;
      });
      showCustomSnackBar(
        context,
        'Email xác thực đã được gửi đến $_currentEmail',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Verification error: $e');
      showCustomSnackBar(
        context,
        'Không thể gửi email xác thực: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showChangeEmailDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Thay đổi Email',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nhập email mới để thay đổi.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email mới',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.black54),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Hủy đổi Email',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newEmail = emailController.text.trim();
                  if (newEmail.isEmpty || !GetUtils.isEmail(newEmail)) {
                    showCustomSnackBar(
                      context,
                      'Vui lòng nhập email hợp lệ!',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                    return;
                  }
                  setState(() => _isLoading = true);
                  try {
                    await pb
                        .collection('users')
                        .authWithPassword(widget.email, widget.password);
                    await pb.collection('users').requestEmailChange(newEmail);
                    Get.back();
                    setState(() {
                      _currentEmail = newEmail;
                    });
                    showCustomSnackBar(
                      context,
                      'Yêu cầu đổi email đã được gửi đến $newEmail',
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  } catch (e) {
                    debugPrint('Email change error: $e');
                    showCustomSnackBar(
                      context,
                      'Không thể gửi yêu cầu đổi email: $e',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Xác nhận Email',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // Changed from gradient to solid white
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/gmail.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),

                Card(
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'StyleMen đã gửi một email xác nhận đến:\n$_currentEmail\n\nVui lòng kiểm tra hộp thư (bao gồm thư mục spam) và nhấn vào đường liên kết xác nhận.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black26,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Gửi lại email xác nhận',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isLoading ? null : _showChangeEmailDialog,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Colors.blue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đổi email xác nhận',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            debugPrint(
                              'Navigating to LoginScreen with email: $_currentEmail',
                            );
                            Get.offAll(() => LoginScreen(email: _currentEmail));
                          },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black26,
                  ),
                  child: const Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
