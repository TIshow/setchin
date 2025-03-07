import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const CustomSearchBar({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "絞り込み検索",
                  border: InputBorder.none,
                ),
              ),
            ),
            const Icon(Icons.search, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}