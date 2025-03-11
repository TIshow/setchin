import 'package:flutter/material.dart';

class SwipeUpMenu extends StatefulWidget {
  // チェックボックスの状態を管理するためのプロパティ
  final bool isExpanded;
  final Function() toggleMenu;
  final List<Map<String, dynamic>> nearbyToilets;
  final Function(Map<String, dynamic>) showToiletDetails;
  final bool female;
  final bool male;
  final bool multipurpose;
  final bool washlet;
  final bool ostomate;
  final bool diaperChange;
  final bool babyChair;
  final bool wheelchair;
  final Function(bool) onFilterChange;

  const SwipeUpMenu({
    Key? key,
    required this.isExpanded,
    required this.toggleMenu,
    required this.nearbyToilets,
    required this.showToiletDetails,
    required this.female,
    required this.male,
    required this.multipurpose,
    required this.washlet,
    required this.ostomate,
    required this.diaperChange,
    required this.babyChair,
    required this.wheelchair,
    required this.onFilterChange,
  }) : super(key: key);

  @override
  State<SwipeUpMenu> createState() => _SwipeUpMenuState();
}

class _SwipeUpMenuState extends State<SwipeUpMenu> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: widget.isExpanded
          ? MediaQuery.of(context).size.height * 0.6
          : 60,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: widget.toggleMenu,
              child: Padding(
                padding: EdgeInsets.only(
                  top: !widget.isExpanded ? 0 : 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'この付近のトイレ',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Icon(
                      widget.isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.isExpanded)
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    const Text("種類", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Checkbox(
                          value: widget.female,
                          onChanged: (value) =>
                              widget.onFilterChange(value!),
                        ),
                        const Text("女性用"),
                        Checkbox(
                          value: widget.male,
                          onChanged: (value) =>
                              widget.onFilterChange(value!),
                        ),
                        const Text("男性用"),
                        Checkbox(
                          value: widget.multipurpose,
                          onChanged: (value) =>
                              widget.onFilterChange(value!),
                        ),
                        const Text("多目的"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("設備", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        FilterChip(
                          label: const Text("ウォッシュレット"),
                          selected: widget.washlet,
                          onSelected: (value) =>
                              widget.onFilterChange(value),
                        ),
                        FilterChip(
                          label: const Text("オストメイト"),
                          selected: widget.ostomate,
                          onSelected: (value) =>
                              widget.onFilterChange(value),
                        ),
                        FilterChip(
                          label: const Text("おむつ替えシート"),
                          selected: widget.diaperChange,
                          onSelected: (value) =>
                              widget.onFilterChange(value),
                        ),
                        FilterChip(
                          label: const Text("ベビーチェア"),
                          selected: widget.babyChair,
                          onSelected: (value) =>
                              widget.onFilterChange(value),
                        ),
                        FilterChip(
                          label: const Text("車いす用手すり"),
                          selected: widget.wheelchair,
                          onSelected: (value) =>
                              widget.onFilterChange(value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("この付近のトイレ一覧", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...widget.nearbyToilets.map((toilet) => ListTile(
                          title: Text(toilet["name"]),
                          leading: const Icon(Icons.location_pin),
                          onTap: () => widget.showToiletDetails(toilet),
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}