import 'package:api_buddy/model/request_model.dart';
import 'package:api_buddy/provider/enviroment_provider.dart';
import 'package:api_buddy/provider/request_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/method_selector.dart';
import '../widgets/headers_editor.dart';
import '../widgets/body_editor.dart';
import '../widgets/auth_editor.dart';
import '../widgets/response_viewer.dart';
import '../widgets/params_editor.dart';

class RequestBuilderScreen extends StatefulWidget {
  const RequestBuilderScreen({Key? key}) : super(key: key);

  @override
  State<RequestBuilderScreen> createState() => _RequestBuilderScreenState();
}

class _RequestBuilderScreenState extends State<RequestBuilderScreen>
    with TickerProviderStateMixin {
  late RequestModel _currentRequest;
  late TabController _tabController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _currentRequest = context.read<RequestProvider>().createNewRequest();
    _tabController = TabController(length: 5, vsync: this);

    // Create URL controller ONCE in initState
    _urlController = TextEditingController(text: _currentRequest.url);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Tester'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.download()),
            onPressed: _saveRequest,
            tooltip: 'Save Request',
          ),
        ],
      ),
      body: Column(
        children: [
          // URL Input Section
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Consumer<RequestProvider>(
                  builder: (context, provider, _) {
                    return MethodSelector(
                      selectedMethod: _currentRequest.method,
                      onMethodChanged: (method) {
                        setState(() {
                          _currentRequest.method = method;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(width: 12),

                Consumer2<RequestProvider, EnvironmentProvider>(
                  builder: (context, reqProvider, envProvider, _) {
                    return ElevatedButton.icon(
                      onPressed: () => _executeRequest(context),
                      icon: Icon(PhosphorIcons.play()),
                      label: const Text('Send'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 12),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://api.example.com/users',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: Icon(PhosphorIcons.link()),
                suffixIcon: _urlController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(PhosphorIcons.x()),
                        onPressed: () {
                          _urlController.clear();
                          setState(() {
                            _currentRequest.url = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _currentRequest.url = value;
                });
              },
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Params'),
              Tab(text: 'Headers'),
              Tab(text: 'Auth'),
              Tab(text: 'Body'),
              Tab(text: 'Response'),
            ],
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ParamsEditor(
                  params: _currentRequest.params,
                  onParamsChanged: (params) {
                    setState(() {
                      _currentRequest.params = params;
                    });
                  },
                ),
                HeadersEditor(
                  headers: _currentRequest.headers,
                  onHeadersChanged: (headers) {
                    setState(() {
                      _currentRequest.headers = headers;
                    });
                  },
                ),
                AuthEditor(
                  auth: _currentRequest.auth,
                  onAuthChanged: (auth) {
                    setState(() {
                      _currentRequest.auth = auth;
                    });
                  },
                ),
                BodyEditor(
                  bodyType: _currentRequest.bodyType,
                  body: _currentRequest.body,
                  onBodyTypeChanged: (type) {
                    setState(() {
                      _currentRequest.bodyType = type;
                    });
                  },
                  onBodyChanged: (body) {
                    setState(() {
                      _currentRequest.body = body;
                    });
                  },
                ),
                Consumer<RequestProvider>(
                  builder: (context, provider, _) {
                    return ResponseViewer(response: provider.lastResponse);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeRequest(BuildContext context) async {
    final envProvider = context.read<EnvironmentProvider>();
    final reqProvider = context.read<RequestProvider>();

    if (_currentRequest.url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a URL')));
      return;
    }

    await reqProvider.executeRequest(
      _currentRequest,
      envProvider.activeVariables,
    );
  }

  void _saveRequest() {
    final nameController = TextEditingController(text: _currentRequest.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Request'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Request name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _currentRequest.name = nameController.text;
              context.read<RequestProvider>().saveRequest(_currentRequest);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Request saved')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
