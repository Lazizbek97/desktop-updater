import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    await repository.initialize();
  } catch (error, stack) {
    debugPrint('Updater startup: $error\n$stack');
  }
  runApp(
    MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: BlocProvider(
        create: (_) => UpdateCubit(repository)..check(),
        child: const LabPage(),
      ),
    ),
  );
}

class LabPage extends StatelessWidget {
  const LabPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Desktop Updater Lab')),
    body: Padding(
      padding: const EdgeInsets.all(32),
      child: BlocBuilder<UpdateCubit, String>(
        builder: (context, log) {
          final cubit = context.read<UpdateCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Build ${String.fromEnvironment('APP_VERSION', defaultValue: 'development')}',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                'GitHub Releases • stock velopack_flutter 0.3.2\nDownload first, then restart. Failures appear below.',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: cubit.busy ? null : cubit.check,
                    child: const Text('Check'),
                  ),
                  ElevatedButton(
                    onPressed: cubit.busy ? null : cubit.download,
                    child: const Text('Download'),
                  ),
                  ElevatedButton(
                    onPressed: cubit.busy ? null : cubit.restart,
                    child: const Text('Apply & restart'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
