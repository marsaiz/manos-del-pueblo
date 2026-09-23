import 'package:flutter/material.dart';

void main() {}

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: "id1",
      enableFilter: true,
      enableSearch: true,
      expandedInsets: EdgeInsets.zero,
      leadingIcon: const Icon(Icons.person),
      hintText: "Escribe...",
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onSelected: (val) {},
      dropdownMenuEntries: [
        DropdownMenuEntry(value: "id1", label: "Art 1")
      ],
    );
  }
}
