import 'package:flutter/material.dart';
import 'dart:convert';

class ResponseViewer extends StatefulWidget {
  final dynamic response;
  const ResponseViewer({Key? key, this.response}) : super(key: key);

  @override
  State<ResponseViewer> createState() => _ResponseViewerState();
}

class _ResponseViewerState extends State<ResponseViewer> {
  int _selectedTabIndex = 0; // 0=Formatted, 1=Raw JSON

  @override
  Widget build(BuildContext context) {
    if (widget.response == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No Response Yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Send a request to see the response here',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (widget.response is Map && widget.response['error'] != null) {
      return _buildErrorView(widget.response['error']);
    }

    dynamic data = widget.response is Map ? widget.response['data'] : widget.response;

    return Column(
      children: [
        // TAB SELECTOR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              _buildTab('Formatted', 0),
              _buildTab('Raw JSON', 1),
            ],
          ),
        ),
        // TAB CONTENT
        Expanded(
          child: _selectedTabIndex == 0
              ? _buildFormattedView(data)
              : _buildRawJsonView(data),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedView(dynamic data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.response is Map && widget.response['status'] != null) ...[
            _buildStatusBadge(widget.response['status']),
            const SizedBox(height: 16),
          ],
          if (data is Map)
            _buildMapView(data as Map<dynamic, dynamic>)
          else if (data is List)
            _buildListView(data as List<dynamic>)
          else
            _buildPlainTextView(data.toString()),
        ],
      ),
    );
  }

  Widget _buildRawJsonView(dynamic data) {
    String jsonString;
    try {
      if (data is String) {
        try {
          jsonString = jsonEncode(jsonDecode(data), toEncodable: _toEncodable);
        } catch (e) {
          jsonString = data;
        }
      } else {
        jsonString = jsonEncode(data, toEncodable: _toEncodable);
      }
      jsonString = _prettyPrintJson(jsonString);
    } catch (e) {
      jsonString = data.toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Raw JSON Response',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyToClipboard(jsonString),
                tooltip: 'Copy JSON',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.withOpacity(0.05),
            ),
            child: SelectableText(
              jsonString,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('Total: ${jsonString.length} characters',
                style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  String _prettyPrintJson(String jsonString) {
    try {
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final dynamic jsonData = jsonDecode(jsonString);
      return encoder.convert(jsonData);
    } catch (e) {
      return jsonString;
    }
  }

  dynamic _toEncodable(dynamic object) {
    if (object is DateTime) return object.toIso8601String();
    return object.toString();
  }

  void _copyToClipboard(String text) {
    print('Copied ${text.length} characters');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Raw JSON copied!'), duration: Duration(seconds: 2)),
    );
  }

  Widget _buildStatusBadge(int status) {
    Color color;
    String label;
    if (status >= 200 && status < 300) {
      color = Colors.green;
      label = 'Success ($status)';
    } else if (status >= 300 && status < 400) {
      color = Colors.blue;
      label = 'Redirect ($status)';
    } else if (status >= 400 && status < 500) {
      color = Colors.orange;
      label = 'Client Error ($status)';
    } else if (status >= 500) {
      color = Colors.red;
      label = 'Server Error ($status)';
    } else {
      color = Colors.grey;
      label = 'Unknown ($status)';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildErrorView(dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(error.toString(),
                  style: const TextStyle(color: Colors.red, fontFamily: 'monospace')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(Map<dynamic, dynamic> map) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Response (Object)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${map.length} fields', style: const TextStyle(fontSize: 12, color: Colors.blue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: map.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final key = map.keys.elementAt(index);
              final value = map[key];
              return _buildKeyValueTile(key.toString(), value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListView(List<dynamic> list) {
    final itemsToShow = list.length > 10 ? 10 : list.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Response (Array)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${list.length} items', style: const TextStyle(fontSize: 12, color: Colors.green)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemsToShow,
          separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
          itemBuilder: (context, index) {
            final item = list[index];
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[Item $index]',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 4),
                  if (item is Map)
                    _buildCompactMapView(item as Map<dynamic, dynamic>)
                  else
                    SelectableText(item.toString(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                ],
              ),
            );
          },
        ),
        if (list.length > 10)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('... and ${list.length - 10} more items (see Raw JSON tab)',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  Widget _buildCompactMapView(Map<dynamic, dynamic> map) {
    final entries = map.entries.toList();
    final displayCount = entries.length > 5 ? 5 : entries.length;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < displayCount; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: '${entries[i].key}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'monospace',
                          fontSize: 10,
                        )),
                    TextSpan(
                        text: ': ',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'monospace',
                          fontSize: 10,
                        )),
                    TextSpan(
                        text: _formatValue(entries[i].value),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontFamily: 'monospace',
                          fontSize: 10,
                        )),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (entries.length > displayCount)
            Text('... +${entries.length - displayCount} more',
                style: const TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildKeyValueTile(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          if (value is List)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: SelectableText('Array[${value.length}]',
                  style: TextStyle(color: Colors.green.shade700, fontFamily: 'monospace', fontSize: 11)),
            )
          else if (value is Map)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: SelectableText('Object{${value.length}}',
                  style: TextStyle(color: Colors.blue.shade700, fontFamily: 'monospace', fontSize: 11)),
            )
          else
            SelectableText(_formatValue(value),
                style: const TextStyle(color: Colors.black87, fontFamily: 'monospace', fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPlainTextView(String text) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Response (Text)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.withOpacity(0.05),
            ),
            child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value.length > 50 ? '${value.substring(0, 50)}...' : value;
    if (value is bool) return value ? 'true' : 'false';
    if (value is num) return value.toString();
    if (value is List) return 'Array[${value.length}]';
    if (value is Map) return 'Object{${value.length}}';
    return value.toString();
  }
}













// import 'package:flutter/material.dart';
// import 'dart:convert';

// class ResponseViewer extends StatefulWidget {
//   final dynamic response;

//   const ResponseViewer({
//     Key? key,
//     this.response,
//   }) : super(key: key);

//   @override
//   State<ResponseViewer> createState() => _ResponseViewerState();
// }

// class _ResponseViewerState extends State<ResponseViewer> {
//   @override
//   Widget build(BuildContext context) {
//     if (widget.response == null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.hourglass_empty,
//               size: 64,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No Response Yet',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Send a request to see the response here',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       );
//     }

//     // Check if response has an error
//     if (widget.response is Map && widget.response['error'] != null) {
//       return _buildErrorView(widget.response['error']);
//     }

//     // Get the actual data
//     dynamic data =
//         widget.response is Map ? widget.response['data'] : widget.response;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Response status
//           if (widget.response is Map && widget.response['status'] != null) ...[
//             _buildStatusBadge(widget.response['status']),
//             const SizedBox(height: 16),
//           ],

//           // Response content based on type
//           if (data is Map)
//             _buildMapView(data as Map<dynamic, dynamic>)
//           else if (data is List)
//             _buildListView(data as List<dynamic>)
//           else
//             _buildPlainTextView(data.toString()),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(int status) {
//     Color color;
//     String label;

//     if (status >= 200 && status < 300) {
//       color = Colors.green;
//       label = '✅ Success ($status)';
//     } else if (status >= 300 && status < 400) {
//       color = Colors.blue;
//       label = '➡️ Redirect ($status)';
//     } else if (status >= 400 && status < 500) {
//       color = Colors.orange;
//       label = '⚠️ Client Error ($status)';
//     } else if (status >= 500) {
//       color = Colors.red;
//       label = '❌ Server Error ($status)';
//     } else {
//       color = Colors.grey;
//       label = 'Unknown ($status)';
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         border: Border.all(color: color),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: color,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorView(dynamic error) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Error',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.red,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 border: Border.all(color: Colors.red),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: SelectableText(
//                 error.toString(),
//                 style: const TextStyle(
//                   color: Colors.red,
//                   fontFamily: 'monospace',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMapView(Map<dynamic, dynamic> map) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Response (Object)',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: map.length,
//             separatorBuilder: (context, index) =>
//                 Divider(height: 1, color: Colors.grey.shade200),
//             itemBuilder: (context, index) {
//               final key = map.keys.elementAt(index);
//               final value = map[key];
//               return _buildKeyValueTile(key.toString(), value);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildListView(List<dynamic> list) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Response (Array) - ${list.length} items',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         const SizedBox(height: 12),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: list.length,
//           separatorBuilder: (context, index) =>
//               Divider(color: Colors.grey.shade200),
//           itemBuilder: (context, index) {
//             final item = list[index];
//             return Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '[Item $index]',
//                     style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                           color: Colors.grey,
//                         ),
//                   ),
//                   const SizedBox(height: 4),
//                   if (item is Map)
//                     _buildCompactMapView(item as Map<dynamic, dynamic>)
//                   else
//                     SelectableText(
//                       item.toString(),
//                       style: const TextStyle(fontFamily: 'monospace'),
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildCompactMapView(Map<dynamic, dynamic> map) {
//     final entries = map.entries.toList();
//     final displayCount = entries.length > 3 ? 3 : entries.length;

//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.grey.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for (int i = 0; i < displayCount; i++)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: '${entries[i].key}: ',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         fontFamily: 'monospace',
//                       ),
//                     ),
//                     TextSpan(
//                       text: _formatValue(entries[i].value),
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontFamily: 'monospace',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           if (entries.length > 3) ...[
//             const SizedBox(height: 4),
//             Text(
//               '... +${entries.length - 3} more fields',
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyValueTile(String key, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   key,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 if (value is List)
//                   Text(
//                     'Array[${value.length}]',
//                     style: TextStyle(
//                       color: Colors.blue,
//                       fontFamily: 'monospace',
//                       fontSize: 12,
//                     ),
//                   )
//                 else if (value is Map)
//                   Text(
//                     'Object{${value.length} fields}',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontFamily: 'monospace',
//                       fontSize: 12,
//                     ),
//                   )
//                 else
//                   SelectableText(
//                     _formatValue(value),
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontFamily: 'monospace',
//                       fontSize: 12,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlainTextView(String text) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Response (Plain Text)',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.grey.withOpacity(0.05),
//           ),
//           child: SelectableText(
//             text,
//             style: const TextStyle(
//               fontFamily: 'monospace',
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatValue(dynamic value) {
//     if (value == null) return 'null';
//     if (value is String) return '"$value"';
//     if (value is bool) return value ? 'true' : 'false';
//     if (value is num) return value.toString();
//     if (value is List) return 'Array[${value.length}]';
//     if (value is Map) return 'Object{${value.length}}';
//     return value.toString();
//   }
// }