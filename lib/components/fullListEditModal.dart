import 'package:flutter/material.dart';
import 'package:wakealert/components/fullWidthButton.dart';

class FullListEditModal extends StatefulWidget {
  final List<String> items;
  final String title, addText;
  final void Function(List<String>) onChanged;

  const FullListEditModal({
    super.key,
    required this.items,
    required this.title,
    required this.addText,
    required this.onChanged,
  });

  @override
  State<FullListEditModal> createState() => _FullListEditModalState();
}

class _FullListEditModalState extends State<FullListEditModal> {
  late List<String> items;
  late List<TextEditingController> controllers;

  late String title, addText;
  late void Function(List<String>) onChanged;

  @override
  void initState() {
    super.initState();

    items = List.from(widget.items);
    title = widget.title;
    addText = widget.addText;
    onChanged = widget.onChanged;

    controllers = items
        .map((e) => TextEditingController(text: e))
        .toList();
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _removeItem(int index) async {
    setState(() {
      items.removeAt(index);
      controllers.removeAt(index);
      onChanged(items);
    });
  }

  void _addItem() {
    setState(() {
      items.insert(0, "");
      controllers.insert(0, TextEditingController());
      onChanged(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE55A5A),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: controllers[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (value) {
                              items[index] = value;
                              onChanged(items);
                            },
                          ),
                        ),

                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                            splashRadius: 1,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onPressed: () => Future.delayed(const Duration(milliseconds: 30)).then((val) {
                              _removeItem(index);
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 8.0),
              child: FullWidthButton(
                text: addText,
                isBold: true,
                color: const Color(0xFFCC5959),
                onPressed: _addItem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}