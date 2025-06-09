import 'package:flutter/material.dart';

class InputTextWidget extends StatefulWidget {
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool showUnderline;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool isPasswordField;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool disableValidator; // ✅ mới thêm

  const InputTextWidget({
    super.key,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
    required this.keyboardType,
    this.controller,
    this.showUnderline = false,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.isPasswordField = false,
    this.autofocus = false,
    this.focusNode,
    this.disableValidator = false, 
  });

  @override
  State<InputTextWidget> createState() => _InputTextWidgetState();
}

class _InputTextWidgetState extends State<InputTextWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ${widget.labelText.toLowerCase()}!';
    }
    if (widget.labelText.toLowerCase().contains('email')) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Email không hợp lệ!';
      }
    }
    if (widget.isPasswordField && value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Material(
        elevation: 8.0,
        shadowColor: Colors.black45,
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: _obscureText,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            onTap: widget.onTap,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              icon: Icon(widget.icon, color: Colors.black87, size: 28.0),
              labelText: widget.labelText,
              labelStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 16.0,
              ),
              enabledBorder: InputBorder.none,
              focusedBorder: widget.showUnderline
                  ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    )
                  : InputBorder.none,
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey[100],
              suffixIcon: widget.isPasswordField
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
            validator: widget.disableValidator
                ? null
                : (widget.validator ?? _defaultValidator),
          ),
        ),
      ),
    );

  }
}
