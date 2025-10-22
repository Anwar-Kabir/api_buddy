import 'package:api_buddy/model/enviroment_model.dart';
import 'package:api_buddy/provider/enviroment_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; 

class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environments'),
        elevation: 0,
        actions: [
          IconButton(
            icon:   Icon(PhosphorIcons.plus()),
            onPressed: () => _showCreateEnvironment(context),
            tooltip: 'Create Environment',
          ),
        ],
      ),
      body: Consumer<EnvironmentProvider>(
        builder: (context, provider, _) {
          if (provider.environments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.gear(),
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No environments',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.environments.length,
            itemBuilder: (context, index) {
              final env = provider.environments[index];
              return _EnvironmentCard(environment: env);
            },
          );
        },
      ),
    );
  }

  void _showCreateEnvironment(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Environment'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Environment name',
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
              if (nameController.text.isNotEmpty) {
                final env = EnvironmentModel(
                  id: '',
                  name: nameController.text,
                  variables: {'base_url': '', 'token': ''},
                  isActive: false,
                  createdAt: DateTime.now(),
                );
                context.read<EnvironmentProvider>().saveEnvironment(env);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _EnvironmentCard extends StatefulWidget {
  final EnvironmentModel environment;

  const _EnvironmentCard({required this.environment});

  @override
  State<_EnvironmentCard> createState() => _EnvironmentCardState();
}

class _EnvironmentCardState extends State<_EnvironmentCard> {
  late EnvironmentModel _editingEnv;

  @override
  void initState() {
    super.initState();
    _editingEnv = widget.environment;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.environment.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.environment.variables.length} variables',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Radio<bool>(
                  value: true,
                  groupValue: widget.environment.isActive,
                  onChanged: (value) {
                    if (value == true) {
                      context
                          .read<EnvironmentProvider>()
                          .setActiveEnvironment(widget.environment);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.environment.variables.isNotEmpty) ...[
              Text(
                'Variables:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              ...widget.environment.variables.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditVariables(context),
                  icon:   Icon(PhosphorIcons.pencil()),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () {
                    context
                        .read<EnvironmentProvider>()
                        .deleteEnvironment(widget.environment.id);
                  },
                  icon:   Icon(PhosphorIcons.trash()),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditVariables(BuildContext context) {
    final controllers = <String, TextEditingController>{};
    widget.environment.variables.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Variables'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controllers.forEach((key, controller) {
                _editingEnv.variables[key] = controller.text;
              });
              context
                  .read<EnvironmentProvider>()
                  .saveEnvironment(_editingEnv);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}