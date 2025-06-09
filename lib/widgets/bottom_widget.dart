import 'package:flutter/material.dart';
import 'package:shop_quanao/screens/user_profile_screen.dart';
import 'package:shop_quanao/screens/home_screen.dart';

class CustomNavigationBar extends StatefulWidget {
  final Function(bool)? onSearchStateChanged;
  final bool showCloseIcon;
  final VoidCallback? onHomePressed;
  final void Function(int index)? onTabSelected;
  final int initialIndex;

  const CustomNavigationBar({
    super.key,
    this.onSearchStateChanged,
    this.showCloseIcon = false,
    this.onHomePressed,
    this.onTabSelected,
    this.initialIndex = 0,
  });

  @override
  CustomNavigationBarState createState() => CustomNavigationBarState();
}

class CustomNavigationBarState extends State<CustomNavigationBar> {
  late int _selectedIndex;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<IconData> iconsOutlined = [
    Icons.home_outlined,
    Icons.search,
    Icons.person_outline,
  ];

  final List<IconData> iconsFilled = [Icons.home, Icons.close, Icons.person];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        // Chuyển về HomeScreen
        _isSearchActive = false;
        _selectedIndex = index;
        widget.onSearchStateChanged?.call(false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else if (index == 1) {
        // Chỉ chuyển đổi trạng thái tìm kiếm, không thay đổi _selectedIndex
        _isSearchActive = !_isSearchActive;
        widget.onSearchStateChanged?.call(_isSearchActive);
      } else {
        // Chuyển về UserProfileScreen
        _isSearchActive = false;
        _selectedIndex = index;
        widget.onSearchStateChanged?.call(false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
          (route) => false,
        );
      }
      widget.onTabSelected?.call(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final verticalPadding = screenHeight * 0.02;
    final bottomExtra = screenHeight * 0.03;
    final dynamicPadding = screenHeight * 0.02;

    return Container(
      padding: EdgeInsets.fromLTRB(
        screenHeight * 0.02,
        verticalPadding,
        screenHeight * 0.02,
        verticalPadding + bottomExtra,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(iconsOutlined.length, (index) {
          final bool isSelected = _selectedIndex == index;
          final bool isSearchActive = index == 1 && _isSearchActive;
          final double containerSize = index == 1 ? screenHeight * 0.07 : screenHeight * 0.06;

          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Container(
              width: containerSize,
              height: containerSize,
              padding: EdgeInsets.all(dynamicPadding * 0.5),
              decoration: BoxDecoration(
                color: index == 1 && isSearchActive ? Colors.black : Colors.white, // Nền đen khi search active cho index 1
                shape: BoxShape.circle,
                border: Border.all(
                  color: index == 1 && isSearchActive ? Colors.black : Colors.transparent,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                index == 1
                    ? (isSearchActive ? Icons.close : Icons.search)
                    : (isSelected ? iconsFilled[index] : iconsOutlined[index]),
                size: screenHeight * 0.035,
                color: index == 1 && isSearchActive ? Colors.white : Colors.black, // Icon trắng khi search active cho index 1
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void didUpdateWidget(CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showCloseIcon != oldWidget.showCloseIcon) {
      setState(() {
        _isSearchActive = widget.showCloseIcon;
      });
    }
  }
}