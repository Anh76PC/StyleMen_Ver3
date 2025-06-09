import 'package:flutter/material.dart';
import 'filter_bar_widget.dart';

class FilterBarSection extends StatelessWidget {
  final List<String> selectedSizes;
  final List<Color> selectedColors;
  final RangeValues priceRange;
  final void Function(void Function()) setStateParent;
  final void Function(RangeValues) onPriceRangeChanged;

  const FilterBarSection({
    super.key,
    required this.selectedSizes,
    required this.selectedColors,
    required this.priceRange,
    required this.setStateParent,
    required this.onPriceRangeChanged,
  });

  Color getTickColor(Color color) {
    if (color == Colors.white) return Colors.black;
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return FilterBarWidget(
      selectedCount: selectedSizes.length + selectedColors.length +
          ((priceRange.start > 0 || priceRange.end < 2000000) ? 1 : 0),
      hasSize: selectedSizes.isNotEmpty,
      hasColor: selectedColors.isNotEmpty,
      hasPrice: priceRange.start > 0 || priceRange.end < 2000000,
      onFilter: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            RangeValues tempPriceRange = priceRange;
            return StatefulBuilder(
              builder: (context, setStateModal) => Padding(
                padding: EdgeInsets.only(
                  left: 16, right: 16, top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 16),
                      Align(alignment: Alignment.centerLeft, child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                      Wrap(
                        spacing: 12,
                        children: ['XS', 'S', 'M', 'L', 'XL', 'XXL'].map((size) {
                          final selected = selectedSizes.contains(size);
                          return ChoiceChip(
                            label: Text(size),
                            selected: selected,
                            onSelected: (val) {
                              setStateModal(() {
                                setStateParent(() {
                                  if (selected) {
                                    selectedSizes.remove(size);
                                  } else {
                                    selectedSizes.add(size);
                                  }
                                });
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Align(alignment: Alignment.centerLeft, child: Text('Color', style: TextStyle(fontWeight: FontWeight.bold))),
                      Wrap(
                        spacing: 12,
                        children: [
                          Colors.white, Colors.grey, Colors.black, Colors.pink, Colors.red, Colors.brown, Colors.green, Colors.blue
                        ].map((color) {
                          final selected = selectedColors.contains(color);
                          return GestureDetector(
                            onTap: () {
                              setStateModal(() {
                                setStateParent(() {
                                  if (selected) {
                                    selectedColors.remove(color);
                                  } else {
                                    selectedColors.add(color);
                                  }
                                });
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? Colors.black : Colors.grey,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: color,
                                radius: 16,
                                child: selected
                                    ? Icon(
                                        Icons.check,
                                        color: getTickColor(color),
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Align(alignment: Alignment.centerLeft, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                      RangeSlider(
                        min: 0,
                        max: 2000000,
                        values: tempPriceRange,
                        onChanged: (v) {
                          setStateModal(() {
                            tempPriceRange = v;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${tempPriceRange.start.toInt()} VND'),
                          Text('${tempPriceRange.end.toInt()} VND'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setStateModal(() {
                                tempPriceRange = const RangeValues(0, 2000000);
                                setStateParent(() {
                                  selectedSizes.clear();
                                  selectedColors.clear();
                                  onPriceRangeChanged(const RangeValues(0, 2000000));
                                });
                              });
                            },
                            child: const Text('Xoá tất cả'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              setStateParent(() {
                                onPriceRangeChanged(tempPriceRange);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('APPLY'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      onSize: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (context, setStateModal) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Wrap(
                    spacing: 12,
                    children: ['XS', 'S', 'M', 'L', 'XL', 'XXL'].map((size) =>
                      ChoiceChip(
                        label: Text(size),
                        selected: selectedSizes.contains(size),
                        onSelected: (val) {
                          setStateModal(() {
                            setStateParent(() {
                              if (selectedSizes.contains(size)) {
                                selectedSizes.remove(size);
                              } else {
                                selectedSizes.add(size);
                              }
                            });
                          });
                        },
                      )).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('APPLY')),
                ],
              ),
            ),
          ),
        );
      },
      onColor: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (context, setStateModal) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Wrap(
                    spacing: 12,
                    children: [
                      Colors.white, Colors.grey, Colors.black, Colors.pink, Colors.red, Colors.brown, Colors.green, Colors.blue
                    ].map((color) =>
                      GestureDetector(
                        onTap: () {
                          setStateModal(() {
                            setStateParent(() {
                              if (selectedColors.contains(color)) {
                                selectedColors.remove(color);
                              } else {
                                selectedColors.add(color);
                              }
                            });
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColors.contains(color) ? Colors.black : Colors.grey,
                              width: selectedColors.contains(color) ? 2 : 1,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 16,
                            child: selectedColors.contains(color)
                                ? Icon(
                                    Icons.check,
                                    color: getTickColor(color),
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                      )).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('APPLY')),
                ],
              ),
            ),
          ),
        );
      },
      onPrice: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (context, setStateModal) {
              RangeValues tempPriceRange = priceRange;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    StatefulBuilder(
                      builder: (context, setStateInner) => Column(
                        children: [
                          RangeSlider(
                            min: 0,
                            max: 2000000,
                            values: tempPriceRange,
                            onChanged: (v) {
                              setStateInner(() {
                                tempPriceRange = v;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${tempPriceRange.start.toInt()} VND'),
                              Text('${tempPriceRange.end.toInt()} VND'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setStateParent(() {
                                onPriceRangeChanged(tempPriceRange);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('APPLY'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      onSort: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: const Text('Sản phẩm mới'), onTap: () => Navigator.pop(context)),
              ListTile(title: const Text('Giá thấp đến cao'), onTap: () => Navigator.pop(context)),
              ListTile(title: const Text('Giá cao đến thấp'), onTap: () => Navigator.pop(context)),
              ListTile(title: const Text('Lượt đánh giá'), onTap: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }
}