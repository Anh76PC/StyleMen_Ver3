import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_quanao/screens/account_settings_screen.dart';
import 'package:shop_quanao/screens/profile_edit_screen.dart';
import 'package:shop_quanao/services/auth_service.dart';
import 'package:shop_quanao/screens/login_screen.dart';
import 'package:shop_quanao/screens/signup_screen.dart';
import 'package:shop_quanao/screens/subcategory_products_screen.dart';
import 'package:shop_quanao/widgets/appbar_widget.dart';
import 'package:shop_quanao/widgets/bottom_widget.dart';
import 'package:shop_quanao/widgets/category_bar_widget.dart'; // Thêm import này
import 'package:shop_quanao/widgets/filter_bar_section.dart'; // Thêm import này
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/subcategory_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isSearchVisible = false;
  List<Category> _categories = [];
  bool _isLoading = true;
  final PageController _subCategoryController = PageController(initialPage: 0);
  int _selectedCategoryIndex = 0;
  List<String> selectedSizes = [];
  List<Color> selectedColors = [];
  RangeValues priceRange = const RangeValues(0, 2000000);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadInitialData();
    _setupRealtimeSubscription(); // Add subscription setup
  }

  Future<void> _checkLoginStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.checkLoginStatus();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final categoryService = CategoryService();
      final categories = await categoryService.fetchCategories();
      for (var category in categories) {
        final subcategoryService = SubcategoryService();
        final subs = await subcategoryService.getSubcategoriesWithProductStatus(
          category.id,
        );
        category.subcategories = subs;
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categories = [];
        _isLoading = false;
      });
    }
  }

  // New method to set up real-time subscription
  void _setupRealtimeSubscription() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isLoggedIn) {
      final userId = authService.pb.authStore.model?.id;
      if (userId != null) {
        authService.pb.collection('users').subscribe(userId, (e) {
          if (e.action == 'update') {
            // Update the auth store with the new record data
            authService.pb.authStore.save(
              authService.pb.authStore.token,
              e.record, // Update with the new record
            );
            if (mounted) {
              setState(() {}); // Trigger UI rebuild
            }
          }
        });
      }
    }
  }

  void _onCategorySelected(int index) {
    if (_categories.isEmpty) return;
    setState(() {
      _selectedCategoryIndex = index;
    });
    _subCategoryController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _handleSearchStateChanged(bool isActive) {
    setState(() {
      _isSearchVisible = isActive;
    });
  }

  void _handleSubcategoryPageChange(int pageIndex) {
    if (_categories.isEmpty) return;
    setState(() {
      _selectedCategoryIndex = pageIndex;
    });
    _subCategoryController.jumpToPage(pageIndex);
  }

  @override
  void dispose() {
    // Unsubscribe from real-time updates
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.pb.collection('users').unsubscribe(); // Unsubscribe all
    _subCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'StyleMen'),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              if (_isSearchVisible &&
                  !_isLoading &&
                  _categories.isNotEmpty) ...[
                CategoryBar(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: _onCategorySelected,
                ),
                FilterBarSection(
                  selectedSizes: selectedSizes,
                  selectedColors: selectedColors,
                  priceRange: priceRange,
                  setStateParent: setState,
                  onPriceRangeChanged: (v) => setState(() => priceRange = v),
                ),
              ],

              Expanded(
                child: Stack(
                  children: [
                    authService.isLoggedIn
                        ? _buildLoggedInUI(context, authService)
                        : _buildLoggedOutUI(context),
                    if (_isSearchVisible)
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PageView.builder(
                            controller: _subCategoryController,
                            itemCount: _categories.length,
                            onPageChanged: _handleSubcategoryPageChange,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, categoryIndex) {
                              final subcategories =
                                  _categories[categoryIndex].getSubcategories;
                              return Container(
                                color: Colors.white,
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 3,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                      ),
                                  itemCount: subcategories.length,
                                  itemBuilder: (context, index) {
                                    final subcategory = subcategories[index];
                                    return InkWell(
                                      onTap:
                                          subcategory.hasProducts
                                              ? () {
                                                setState(() {
                                                  _isSearchVisible = false;
                                                });
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            SubcategoryProductsScreen(
                                                              subcategoryId:
                                                                  subcategory
                                                                      .id,
                                                              subcategoryName:
                                                                  subcategory
                                                                      .name,
                                                              categories:
                                                                  _categories,
                                                            ),
                                                  ),
                                                );
                                              }
                                              : null,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            if (subcategory.image != null)
                                              Container(
                                                width: 60,
                                                height: 60,
                                                margin: const EdgeInsets.only(
                                                  right: 12,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    'http://pocketbase.anhpc.online:8090/api/files/subcategories/${subcategory.id}/${subcategory.image}',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons.image,
                                                          size: 30,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            Expanded(
                                              child: Text(
                                                subcategory.name,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      subcategory.hasProducts
                                                          ? Colors.black
                                                          : Colors.black54,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavigationBar(
              initialIndex: 2,
              onSearchStateChanged: _handleSearchStateChanged,
              showCloseIcon: _isSearchVisible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInUI(BuildContext context, AuthService authService) {
    final userData = authService.pb.authStore.model?.data ?? {};
    return ListView(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileEditPage(userData: userData),
                    ),
                  ).then((_) {
                    setState(
                      () {},
                    ); // Refresh UI after returning from edit page
                  });
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          (userData['avatar'] != null &&
                                  userData['avatar'] != '')
                              ? NetworkImage(
                                'http://pocketbase.anhpc.online:8090/api/files/users/${userData['id']}/${userData['avatar']}',
                              )
                              : null,
                      child:
                          (userData['avatar'] == null ||
                                  userData['avatar'] == '')
                              ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.black54,
                              )
                              : null,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['fullname'] ?? 'Người dùng',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userData['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Rest of the _buildLoggedInUI remains unchanged
        Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: Colors.grey[300]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đơn mua',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    child: Row(
                      children: const [
                        Text(
                          'Xem lịch sử mua hàng',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOrderItem(
                    Icons.assignment_late_outlined,
                    'Chờ xác nhận',
                  ),
                  _buildOrderItem(Icons.inventory_2_outlined, 'Chờ lấy hàng'),
                  _buildOrderItem(
                    Icons.local_shipping_outlined,
                    'Chờ giao hàng',
                  ),
                  _buildOrderItem(Icons.star_border, 'Đánh giá'),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey[300]),
        const Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: Text(
            'Tiện ích của tôi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildUtilityItem(
              Icons.account_balance_wallet_outlined,
              'Ví StyleMen',
            ),
            _buildUtilityItem(Icons.card_giftcard_outlined, 'Kho Voucher'),
            _buildUtilityItem(Icons.shopping_bag_outlined, 'Mua lại'),
          ],
        ),
        Divider(color: Colors.grey[300]),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.black),
          title: const Text(
            'Thiết lập tài khoản',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.black),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccountSettingsScreen(email: userData['email'], userId: userData['id']),
              ),
            );
          },
        ),

        Divider(color: Colors.grey[300]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              await authService.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // _buildLoggedOutUI, _buildOrderItem, and _buildUtilityItem remain unchanged
  Widget _buildLoggedOutUI(BuildContext context) {
    return ListView(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, size: 40, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue.shade700),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đơn mua',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Xem lịch sử mua hàng',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOrderItem(
                    Icons.assignment_late_outlined,
                    'Chờ xác nhận',
                    enabled: false,
                  ),
                  _buildOrderItem(
                    Icons.inventory_2_outlined,
                    'Chờ lấy hàng',
                    enabled: false,
                  ),
                  _buildOrderItem(
                    Icons.local_shipping_outlined,
                    'Chờ giao hàng',
                    enabled: false,
                  ),
                  _buildOrderItem(
                    Icons.star_border,
                    'Đánh giá',
                    enabled: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey[300]),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Tiện ích của tôi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildUtilityItem(
              Icons.account_balance_wallet_outlined,
              'Ví StyleMen',
              enabled: false,
            ),
            _buildUtilityItem(
              Icons.card_giftcard_outlined,
              'Kho Voucher',
              enabled: false,
            ),
            _buildUtilityItem(
              Icons.shopping_bag_outlined,
              'Mua lại',
              enabled: false,
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildOrderItem(IconData icon, String label, {bool enabled = true}) {
    return Column(
      children: [
        Icon(icon, size: 28, color: enabled ? Colors.black : Colors.black26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled ? Colors.black87 : Colors.black26,
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityItem(IconData icon, String title, {bool enabled = true}) {
    return Column(
      children: [
        Icon(icon, size: 28, color: enabled ? Colors.black : Colors.black26),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: enabled ? Colors.black87 : Colors.black26,
          ),
        ),
      ],
    );
  }
}
