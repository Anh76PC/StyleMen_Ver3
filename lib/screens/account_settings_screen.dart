import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:shop_quanao/screens/address_list_screen.dart';
import 'package:shop_quanao/screens/login_screen.dart';
import 'package:shop_quanao/services/auth_service.dart';
import 'package:shop_quanao/utils/generic_form_page.dart';
import 'package:shop_quanao/utils/show_custom_confirm_dialog.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';

class AccountSettingsScreen extends StatelessWidget {
  final String email;
  final String userId;
  final PocketBase pb = PocketBase('http://pocketbase.anhpc.online:8090');

  AccountSettingsScreen({super.key, required this.email, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết lập tài khoản'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          Divider(color: Colors.grey[300]),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.black),
            title: const Text(
              'Thay đổi mật khẩu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.black),
            onTap: () async {
              try {
                final shouldLogout = await showCustomConfirmDialog(
                  context: context,
                  title: 'Đặt lại mật khẩu',
                  content:
                      'Bạn cần đăng xuất để nhập mật khẩu mới.\nEmail đặt lại mật khẩu sẽ được gửi đến: $email',

                  cancelText: 'Huỷ',
                  cancelTextColor: Colors.black,
                  confirmText: 'Đăng xuất',
                  confirmTextColor: Colors.red,
                  backgroundColor: Colors.white,
                );

                if (shouldLogout == true) {
                  // Gửi email đặt lại mật khẩu
                  await pb.collection('users').requestPasswordReset(email);

                  // Đăng xuất và chuyển sang màn hình đăng nhập
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  await authService.logout();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(email: email),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                showCustomSnackBar(
                  context,
                  'Không thể gửi email đặt lại mật khẩu. Vui lòng thử lại sau.',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
          ),

          Divider(color: Colors.grey[300]),

          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.black),
            title: const Text(
              'Thay đổi email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.black),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EmailEditPage(
                        email: email, // Pass the current email
                        title: 'Thay đổi email',
                        save: 'Cập nhật',
                      ),
                ),
              );
            },
          ),

          Divider(color: Colors.grey[300]),

          ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
              color: Colors.black,
            ),
            title: const Text(
              'Địa chỉ giao hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.black),
            onTap: () {
              // Điều hướng đến ShippingAddressListPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ShippingAddressListPage(
                        pb: pb, // Thay bằng URL của bạn
                        userId:
                            userId, // Thay bằng userId thực tế (ví dụ: từ AuthService)
                      ),
                ),
              );
            },
          ),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }
}
