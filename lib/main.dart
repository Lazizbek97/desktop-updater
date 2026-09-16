import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/probe/data/local_probe_repository.dart';
import 'features/probe/presentation/probe_cubit.dart';
import 'features/probe/presentation/probe_page.dart';
import 'features/update/data/velopack_repository.dart';
import 'features/update/presentation/update_cubit.dart';

class ErrorObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('$error\n$stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = ErrorObserver();
  final repository = VelopackRepository();
  try {
    if (kReleaseMode) await repository.initialize();
  } catch (error, stack) {
    debugPrint('Updater startup: $error\n$stack');
  }
  runApp(
    MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Updater Lab'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Updates'),
                Tab(text: 'Native & saved data'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              BlocProvider(
                create: (_) =>
                    UpdateCubit(repository)..start(enabled: kReleaseMode),
                child: const LabPage(),
              ),
              BlocProvider(
                create: (_) => ProbeCubit(
                  LocalProbeRepository(
                    SharedPreferencesAsync(),
                    const MethodChannel('updater_lab/native_probe'),
                  ),
                )..load(),
                child: const ProbePage(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class LabPage extends StatelessWidget {
  const LabPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Desktop Updater Lab • Fresh look')),
    body: Padding(
      padding: const EdgeInsets.all(32),
      child: BlocBuilder<UpdateCubit, String>(
        builder: (context, log) {
          final cubit = context.read<UpdateCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade800,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'A fresh look, delivered by an update\nVisual checkpoint for release ${String.fromEnvironment('APP_VERSION', defaultValue: 'development')}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Build ${String.fromEnvironment('APP_VERSION', defaultValue: 'development')}',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                'GitHub Releases • patched Velopack lab\nChecks on launch and every 4 hours. Downloads automatically.\nRestart only when you are ready. Debug builds are UI previews.',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: !kReleaseMode || cubit.busy ? null : cubit.check,
                    child: Text(cubit.busy ? 'Working…' : 'Check for updates'),
                  ),
                  ElevatedButton(
                    onPressed: cubit.busy || !cubit.readyToRestart
                        ? null
                        : cubit.restart,
                    child: const Text('Restart to update'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                cubit.readyToRestart
                    ? 'Update downloaded — restart when you are ready.'
                    : 'Update activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(child: SelectableText(log)),
              ),
            ],
          );
        },
      ),
    ),
  );
}
