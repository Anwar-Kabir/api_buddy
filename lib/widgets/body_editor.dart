import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BodyEditor extends StatefulWidget {
  final String bodyType;
  final String body;
  final Function(String) onBodyTypeChanged;
  final Function(String) onBodyChanged;

  const BodyEditor({
    Key? key,
    required this.bodyType,
    required this.body,
    required this.onBodyTypeChanged,
    required this.onBodyChanged,
  }) : super(key: key);

  @override
  State<BodyEditor> createState() => _BodyEditorState();
}

class _BodyEditorState extends State<BodyEditor> {
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: widget.body);
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bodyTypes = ['none', 'raw', 'formdata', 'x-www-form-urlencoded'];

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                'Body Type:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: bodyTypes.map((type) {
                      final isSelected = widget.bodyType == type;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(type),
                          onSelected: (selected) {
                            if (selected) {
                              widget.onBodyTypeChanged(type);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.bodyType != 'none')
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bodyController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: _getBodyHint(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (value) {
                        widget.onBodyChanged(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getBodyHelp(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.prohibit(),
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No body selected',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a body type to add request body',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getBodyHint() {
    switch (widget.bodyType) {
      case 'raw':
        return '{\n  "key": "value"\n}';
      case 'formdata':
        return 'key1: value1\nkey2: value2';
      case 'x-www-form-urlencoded':
        return 'key1=value1&key2=value2';
      default:
        return '';
    }
  }

  String _getBodyHelp() {
    switch (widget.bodyType) {
      case 'raw':
        return 'Send raw data (usually JSON)';
      case 'formdata':
        return 'Send form data (multipart/form-data)';
      case 'x-www-form-urlencoded':
        return 'Send URL-encoded form data';
      default:
        return '';
    }
  }
}