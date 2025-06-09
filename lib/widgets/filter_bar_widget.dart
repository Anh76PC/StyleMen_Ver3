import 'package:flutter/material.dart';

class FilterBarWidget extends StatelessWidget {
  final int selectedCount;
  final bool hasSize;
  final bool hasColor;
  final bool hasPrice;
  final VoidCallback? onFilter;
  final VoidCallback? onSize;
  final VoidCallback? onColor;
  final VoidCallback? onPrice;
  final VoidCallback? onSort;

  const FilterBarWidget({
    super.key,
    required this.selectedCount,
    required this.hasSize,
    required this.hasColor,
    required this.hasPrice,
    this.onFilter,
    this.onSize,
    this.onColor,
    this.onPrice,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Row(
        children: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
                onPressed: onFilter,
              ),
              if (selectedCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$selectedCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: hasSize
                          ? const BorderSide(color: Colors.black, width: 2)
                          : const BorderSide(color: Colors.black26, width: 1),
                    ),
                    onPressed: onSize,
                    child: const Text('Size', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: hasColor
                          ? const BorderSide(color: Colors.black, width: 2)
                          : const BorderSide(color: Colors.black26, width: 1),
                    ),
                    onPressed: onColor,
                    child: const Text('Màu sắc', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: hasPrice
                          ? const BorderSide(color: Colors.black, width: 2)
                          : const BorderSide(color: Colors.black26, width: 1),
                    ),
                    onPressed: onPrice,
                    child: const Text('Giá', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onSort,
                    icon: const Icon(Icons.sort, color: Colors.black),
                    label: const Text('Sort by', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}