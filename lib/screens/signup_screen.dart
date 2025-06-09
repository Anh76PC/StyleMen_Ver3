import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shop_quanao/screens/verify_email_screen.dart';
import 'package:shop_quanao/screens/user_profile_screen.dart';
import 'package:shop_quanao/utils/check_email_cccd.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';
import 'package:shop_quanao/widgets/input_text_widget.dart';
import 'package:shop_quanao/screens/login_screen.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final pb = PocketBase('http://pocketbase.anhpc.online:8090');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double r = (175 / 360);
    final coverHeight = screenWidth * r;
    const bool _pinned = false;
    const bool _snap = false;
    const bool _floating = false;

    final widgetList = [
      const Row(
        children: [
          SizedBox(width: 28),
          Text(
            'StyleMen - Đăng ký',
            style: TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
      const SizedBox(height: 12.0),
      Form(
        key: _formKey,
        child: Column(
          children: [
            InputTextWidget(
              controller: _fullnameController,
              labelText: "Họ và tên",
              icon: Icons.person,
              autofocus: true,
              obscureText: false,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12.0),
            InputTextWidget(
              labelText: 'Ngày sinh',
              icon: Icons.calendar_today,
              obscureText: false,
              keyboardType: TextInputType.none,
              controller: _birthdayController,
              readOnly: true,
              onTap: () async {
                DateTime initialDate;
                if (_birthdayController.text.isNotEmpty) {
                  try {
                    initialDate = DateFormat(
                      'dd/MM/yyyy',
                    ).parseStrict(_birthdayController.text);
                  } catch (e) {
                    initialDate = DateTime.now();
                  }
                } else {
                  initialDate = DateTime.now();
                }

                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  _birthdayController.text = DateFormat(
                    'dd/MM/yyyy',
                  ).format(pickedDate);
                }
              },
              validator: (val) {
                if (val == null || val.isEmpty)
                  return 'Vui lòng nhập ngày sinh!';
                try {
                  DateTime birthday = DateFormat('dd/MM/yyyy').parseStrict(val);
                  final today = DateTime.now();
                  final age =
                      today.year -
                      birthday.year -
                      ((today.month < birthday.month ||
                              (today.month == birthday.month &&
                                  today.day < birthday.day))
                          ? 1
                          : 0);
                  if (age < 16) return 'Bạn phải từ 16 tuổi trở lên!';
                } catch (e) {
                  return 'Ngày sinh không hợp lệ!';
                }
                return null;
              },
            ),
            const SizedBox(height: 12.0),
            InputTextWidget(
              controller: _genderController,
              labelText: 'Giới tính',
              icon: Icons.wc,
              obscureText: false,
              keyboardType: TextInputType.none,
              readOnly: true,
              onTap: () async {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Nam'),
                            onTap: () => Navigator.pop(context, 'Nam'),
                          ),
                          ListTile(
                            title: const Text('Nữ'),
                            onTap: () => Navigator.pop(context, 'Nữ'),
                          ),
                          ListTile(
                            title: const Text('Khác'),
                            onTap: () => Navigator.pop(context, 'Khác'),
                          ),
                        ],
                      ),
                    );
                  },
                );
                if (selected != null) {
                  setState(() {
                    _genderController.text = selected;
                  });
                }
              },
              validator: (val) {
                if (val == null || val.isEmpty)
                  return 'Vui lòng chọn giới tính!';
                return null;
              },
            ),

            const SizedBox(height: 12.0),
            InputTextWidget(
              controller: _cccdController,
              labelText: "Số CCCD",
              icon: Icons.credit_card,
              obscureText: false,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập số CCCD!';
                if (!RegExp(r'^\d{12}$').hasMatch(val)) {
                  return 'CCCD phải gồm đúng 12 chữ số!';
                }
                return null;
              },
            ),
            const SizedBox(height: 12.0),
            InputTextWidget(
              controller: _emailController,
              labelText: "Địa chỉ Email",
              icon: Icons.email,
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12.0),
            InputTextWidget(
              controller: _pass,
              labelText: "Mật khẩu",
              icon: Icons.lock,
              isPasswordField: true,
              obscureText: true,
              keyboardType: TextInputType.text,
              validator: (val) {
                if (val == null || val.isEmpty)
                  return 'Vui lòng nhập mật khẩu!';
                if (val.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự!';
                return null;
              },
            ),
            const SizedBox(height: 15.0),
            InputTextWidget(
              controller: _confirmPass,
              labelText: "Mật khẩu xác nhận",
              icon: Icons.lock,
              obscureText: true,
              isPasswordField: true,
              keyboardType: TextInputType.text,
              validator: (val) {
                if (val == null || val.isEmpty)
                  return 'Vui lòng nhập mật khẩu xác nhận!';
                if (val != _pass.text) return 'Mật khẩu xác nhận không khớp!';
                return null;
              },
            ),
            const SizedBox(height: 15.0),
            SizedBox(
              height: 55.0,
              width: screenWidth - 60,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final cccdExists = await checkCccdExists(
                      _cccdController.text.trim(),
                    );
                    if (cccdExists) {
                      showCustomSnackBar(
                        context,
                        'Số CCCD đã được đăng ký trước đó!',
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      _cccdController.clear();
                      return;
                    }

                    final emailExists = await checkEmailExists(
                      _emailController.text.trim(),
                    );
                    if (emailExists) {
                      showCustomSnackBar(
                        context,
                        'Email đã được đăng ký trước đó!',
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      _emailController.clear();
                      return;
                    }

                    try {
                      final body = {
                        "email": _emailController.text.trim(),
                        "emailVisibility": true,
                        "fullname": _fullnameController.text.trim(),
                        "password": _pass.text,
                        "passwordConfirm": _confirmPass.text,
                        "birthday": _birthdayController.text.trim(),
                        "cccd": _cccdController.text.trim(),
                        "gender":
                            _genderController.text.trim(), // 👈 Thêm dòng này
                        "status": "new",
                      };

                      await pb.collection('users').create(body: body);
                      await pb
                          .collection('users')
                          .requestVerification(_emailController.text.trim());

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => VerifyEmailScreen(
                                email: _emailController.text.trim(),
                                password: _pass.text.trim(),
                              ),
                        ),
                      );
                    } catch (e) {
                      showCustomSnackBar(
                        context,
                        'Đăng ký thất bại! Vui lòng thử lại sau.',
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      _emailController.clear();
                      return;
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  shadowColor: Colors.black12,
                  minimumSize: Size(screenWidth - 60, 55),
                ),
                child: const Text(
                  "Tiếp tục",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 15.0),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: _pinned,
            snap: _snap,
            floating: _floating,
            expandedHeight: coverHeight - 25,
            backgroundColor: const Color(0xFFdccdb4),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Image.asset(
                "assets/images/register.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFFdccdb4), Color(0xFFd8c3ab)],
                ),
              ),
              width: screenWidth,
              height: 25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: screenWidth,
                    height: 25,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              return widgetList[index];
            }, childCount: widgetList.length),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bạn đã có tài khoản? ",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                "Đăng nhập ngay!",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
  _pass.dispose();
  _confirmPass.dispose();
  _emailController.dispose();
  _fullnameController.dispose();
  _birthdayController.dispose();
  _cccdController.dispose();
  _genderController.dispose(); 
  super.dispose();
}

}
