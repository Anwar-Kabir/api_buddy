import 'package:api_buddy/model/enviroment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; 

class EnvironmentProvider with ChangeNotifier {
  late Box<EnvironmentModel> _environmentBox;
  
  List<EnvironmentModel> _environments = [];
  EnvironmentModel? _activeEnvironment;

  List<EnvironmentModel> get environments => _environments;
  EnvironmentModel? get activeEnvironment => _activeEnvironment;
  Map<String, String> get activeVariables =>
      _activeEnvironment?.variables ?? {};

  EnvironmentProvider() {
    _initBox();
  }

  Future<void> _initBox() async {
    _environmentBox = await Hive.openBox<EnvironmentModel>('environments');
    _loadEnvironments();
  }

  void _loadEnvironments() {
    _environments = _environmentBox.values.toList();
    _activeEnvironment = _environments.firstWhere(
      (env) => env.isActive,
      orElse: () => EnvironmentModel(
        id: 'default',
        name: 'Default',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> saveEnvironment(EnvironmentModel environment) async {
    final finalEnv = environment
      ..id = environment.id.isEmpty ? const Uuid().v4() : environment.id;

    await _environmentBox.put(finalEnv.id, finalEnv);
    _loadEnvironments();
  }

  Future<void> deleteEnvironment(String id) async {
    await _environmentBox.delete(id);
    _loadEnvironments();
  }

  Future<void> setActiveEnvironment(EnvironmentModel environment) async {
    // Deactivate all
    for (var env in _environments) {
      env.isActive = false;
      await _environmentBox.put(env.id, env);
    }

    // Activate selected
    environment.isActive = true;
    await _environmentBox.put(environment.id, environment);
    _loadEnvironments();
  }

  Future<void> updateVariable(String key, String value) async {
    if (_activeEnvironment != null) {
      _activeEnvironment!.variables[key] = value;
      await _environmentBox.put(_activeEnvironment!.id, _activeEnvironment!);
      notifyListeners();
    }
  }

  EnvironmentModel createNewEnvironment() {
    return EnvironmentModel(
      id: '',
      name: 'New Environment',
      variables: {'base_url': '', 'token': ''},
      isActive: false,
      createdAt: DateTime.now(),
    );
  }
}