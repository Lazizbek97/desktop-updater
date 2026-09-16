import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'probe_cubit.dart';

class ProbePage extends StatefulWidget {
  const ProbePage({super.key});
  @override
  State<ProbePage> createState() => _ProbePageState();
}

class _ProbePageState extends State<ProbePage> {
  final _note = TextEditingController();
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ProbeCubit, String>(
    builder: (context, status) {
      final cubit = context.read<ProbeCubit>();
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            'Native code & saved data',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            '1. Run the native check. Windows should report native-probe-v1.\n'
            '2. Save a test note, quit and reopen the installed app, then load it.\n'
            '3. Keep the note for the next update; do not uninstall or clear app data.\n'
            'This tests preferences, not database migrations. Do not enter sensitive data.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _note,
            maxLength: 200,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Test note (for example: keep-me-106)',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: cubit.busy ? null : () => cubit.save(_note.text),
                child: const Text('Save note'),
              ),
              OutlinedButton(
                onPressed: cubit.busy ? null : cubit.load,
                child: const Text('Load saved note'),
              ),
              OutlinedButton(
                onPressed: cubit.busy ? null : cubit.nativeCheck,
                child: const Text('Run native C++ check'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SelectableText(status),
        ],
      );
    },
  );
}
