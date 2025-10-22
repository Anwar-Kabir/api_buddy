import 'package:api_buddy/model/request_model.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; 

class AuthEditor extends StatefulWidget {
  final AuthModel? auth;
  final Function(AuthModel) onAuthChanged;

  const AuthEditor({
    Key? key,
    required this.auth,
    required this.onAuthChanged,
  }) : super(key: key);

  @override
  State<AuthEditor> createState() => _AuthEditorState();
}

class _AuthEditorState extends State<AuthEditor> {
  late AuthModel _auth;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? AuthModel();
    _usernameController = TextEditingController(text: _auth.username);
    _passwordController = TextEditingController(text: _auth.password);
    _tokenController = TextEditingController(text: _auth.token);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const authTypes = ['none', 'basic', 'bearer'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Authentication Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: authTypes.map((type) {
              return FilterChip(
                selected: _auth.type == type,
                label: Text(type.toUpperCase()),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _auth.type = type;
                      widget.onAuthChanged(_auth);
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          if (_auth.type == 'basic') ...[
            Text(
              'Basic Authentication',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon:   Icon(PhosphorIcons.user()),
              ),
              onChanged: (value) {
                _auth.username = value;
                widget.onAuthChanged(_auth);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon:   Icon(PhosphorIcons.lock()),
              ),
              obscureText: true,
              onChanged: (value) {
                _auth.password = value;
                widget.onAuthChanged(_auth);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Creates: Authorization: Basic [base64_encoded_credentials]',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ] else if (_auth.type == 'bearer') ...[
            Text(
              'Bearer Token',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Token (supports {{variable}})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon:   Icon(PhosphorIcons.key()),
              ),
              maxLines: 3,
              onChanged: (value) {
                _auth.token = value;
                widget.onAuthChanged(_auth);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Creates: Authorization: Bearer [your_token]',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ] else
            Center(
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
                    'No authentication',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}