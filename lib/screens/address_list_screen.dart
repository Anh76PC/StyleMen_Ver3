import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shop_quanao/screens/add_address_screen.dart';
import 'package:shop_quanao/screens/edit_address_screen.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';

class ShippingAddressListPage extends StatefulWidget {
  final PocketBase pb;
  final String userId;

  const ShippingAddressListPage({
    super.key,
    required this.pb,
    required this.userId,
  });

  @override
  State<ShippingAddressListPage> createState() =>
      _ShippingAddressListPageState();
}

class _ShippingAddressListPageState extends State<ShippingAddressListPage> {
  late List<Map<String, dynamic>> addresses = [];
  int currentPage = 1; // Start from page 1
  int perPage = 10; // Reasonable perPage value
  int totalItems = 0;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    debugPrint('User ID: ${widget.userId}'); // Debug userId
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoading && !hasError && addresses.isEmpty) {
      _fetchAddresses();
    }
  }

  Future<void> _fetchAddresses() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final result = await widget.pb
          .collection('addresses')
          .getList(
            page: currentPage,
            perPage: perPage,
            filter: '_userid ~ "${widget.userId}"',
            sort: '-isDefault,-created',
          );
      debugPrint('Fetched ${result.items.length} records');
      setState(() {
        addresses = result.items.map((record) => record.toJson()).toList();
        totalItems = result.totalItems;
        isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Error fetching addresses: $e');
      debugPrint('Stack: $stack');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Lỗi khi tải danh sách địa chỉ: $e';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomSnackBar(context, errorMessage, backgroundColor: Colors.red);
      });
    }
  }

  void _loadNextPage() {
    if (currentPage * perPage < totalItems && !isLoading) {
      setState(() => currentPage++);
      _fetchAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ của Tôi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Địa chỉ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5.0),
              Expanded(
                child:
                    hasError
                        ? Center(child: Text(errorMessage))
                        : addresses.isEmpty && !isLoading
                        ? const Center(
                          child: Text(
                            'Chưa có địa chỉ nào. Vui lòng thêm địa chỉ mới!',
                          ),
                        )
                        : NotificationListener<ScrollNotification>(
                          onNotification: (scrollDetails) {
                            if (scrollDetails.metrics.pixels ==
                                    scrollDetails.metrics.maxScrollExtent &&
                                !isLoading) {
                              _loadNextPage();
                            }
                            return false;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              itemCount:
                                  addresses.length +
                                  (totalItems > addresses.length ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == addresses.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final address = addresses[index];
                                final isFirstAddress = index == 0;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                        horizontal: 12.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${address['fullname'] ?? ''}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' | ',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '${address['phone'] ?? ''}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            address['addressDetail'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            '${address['ward'] ?? ''}, ${address['district'] ?? ''}, ${address['province'] ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (isFirstAddress) ...[
                                            const SizedBox(height: 8.0),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 4.0,
                                                  ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.orange.shade700,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                color: Colors.white,
                                              ),
                                              child: Text(
                                                'Mặc định',
                                                style: TextStyle(
                                                  color: Colors.orange.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (index < addresses.length - 1)
                                      Divider(
                                        color: Colors.grey[300],
                                        height: 1.0,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddShippingAddressPage(
                              pb: widget.pb,
                              userId: widget.userId,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent.shade700,
                  ),
                  child: const Text(
                    'Thêm Địa Chỉ Mới',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
