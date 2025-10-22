import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ParamsEditor extends StatefulWidget {
  final Map<String, String> params;
  final Function(Map<String, String>) onParamsChanged;

  const ParamsEditor({
    Key? key,
    required this.params,
    required this.onParamsChanged,
  }) : super(key: key);

  @override
  State<ParamsEditor> createState() => _ParamsEditorState();
}

class _ParamsEditorState extends State<ParamsEditor> {
  late Map<String, String> _params;
  final List<MapEntry<String, String>> _paramList = [];

  @override
  void initState() {
    super.initState();
    _params = Map.from(widget.params);
    _updateParamList();
  }

  void _updateParamList() {
    _paramList.clear();
    _paramList.addAll(_params.entries.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _paramList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.magnifyingGlass(),
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No parameters added',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _paramList.length,
                  itemBuilder: (context, index) {
                    final entry = _paramList[index];
                    return _ParamItem(
                      paramKey: entry.key,
                      paramValue: entry.value,
                      onChanged: (newKey, newValue) {
                        setState(() {
                          _params.remove(entry.key);
                          _params[newKey] = newValue;
                          _updateParamList();
                          widget.onParamsChanged(_params);
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _params.remove(entry.key);
                          _updateParamList();
                          widget.onParamsChanged(_params);
                        });
                      },
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: _addParam,
            icon: Icon(PhosphorIcons.plus()),
            label: const Text('Add Parameter'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }

  void _addParam() {
    setState(() {
      _params['param${_params.length + 1}'] = '';
      _updateParamList();
      widget.onParamsChanged(_params);
    });
  }
}

class _ParamItem extends StatefulWidget {
  final String paramKey;
  final String paramValue;
  final Function(String, String) onChanged;
  final VoidCallback onDelete;

  const _ParamItem({
    Key? key,
    required this.paramKey,
    required this.paramValue,
    required this.onChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_ParamItem> createState() => _ParamItemState();
}

class _ParamItemState extends State<_ParamItem> {
  late TextEditingController _keyController;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.paramKey);
    _valueController = TextEditingController(text: widget.paramValue);
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
                      widget.onChanged(value, _valueController.text);
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
                      widget.onChanged(_keyController.text, value);
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