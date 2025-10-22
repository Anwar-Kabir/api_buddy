import 'package:api_buddy/model/request_model.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; 

class HeadersEditor extends StatefulWidget {
  final List<HeaderModel> headers;
  final Function(List<HeaderModel>) onHeadersChanged;

  const HeadersEditor({
    Key? key,
    required this.headers,
    required this.onHeadersChanged,
  }) : super(key: key);

  @override
  State<HeadersEditor> createState() => _HeadersEditorState();
}

class _HeadersEditorState extends State<HeadersEditor> {
  late List<HeaderModel> _headers;

  @override
  void initState() {
    super.initState();
    _headers = List.from(widget.headers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _headers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.textT(),
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No headers added',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _headers.length,
                  itemBuilder: (context, index) {
                    return _HeaderItem(
                      header: _headers[index],
                      onChanged: (header) {
                        setState(() {
                          _headers[index] = header;
                          widget.onHeadersChanged(_headers);
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _headers.removeAt(index);
                          widget.onHeadersChanged(_headers);
                        });
                      },
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: _addHeader,
            icon: Icon(PhosphorIcons.plus()),
            label: const Text('Add Header'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }

  void _addHeader() {
    setState(() {
      _headers.add(HeaderModel(key: '', value: ''));
      widget.onHeadersChanged(_headers);
    });
  }
}

class _HeaderItem extends StatefulWidget {
  final HeaderModel header;
  final Function(HeaderModel) onChanged;
  final VoidCallback onDelete;

  const _HeaderItem({
    required this.header,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_HeaderItem> createState() => _HeaderItemState();
}

class _HeaderItemState extends State<_HeaderItem> {
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.header.key);
    _valueController = TextEditingController(text: widget.header.value);
    _isEnabled = widget.header.isEnabled;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isEnabled = value ?? true;
                      widget.header.isEnabled = _isEnabled;
                      widget.onChanged(widget.header);
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      hintText: 'Key',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (value) {
                      widget.header.key = value;
                      widget.onChanged(widget.header);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      hintText: 'Value',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (value) {
                      widget.header.value = value;
                      widget.onChanged(widget.header);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: Icon(PhosphorIcons.trash()),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}