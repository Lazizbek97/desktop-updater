import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'camera_cubit.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({required this.previewBuilder, super.key});
  final Widget Function(int) previewBuilder;
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(context.read<CameraCubit>().stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Camera DLL test')),
    body: BlocBuilder<CameraCubit, String>(
      builder: (context, status) {
        final cubit = context.read<CameraCubit>();
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Local preview only. No audio, photos, recording or upload.\n'
              'The camera opens only when you press Open camera and stops when you leave this screen or background the app.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: cubit.busy || cubit.cameraId != null
                      ? null
                      : cubit.start,
                  child: const Text('Open camera'),
                ),
                OutlinedButton(
                  onPressed: cubit.cameraId == null ? null : cubit.stop,
                  child: const Text('Stop camera'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SelectableText(status),
            if (cubit.cameraId != null)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: AspectRatio(
                    aspectRatio: cubit.aspect,
                    child: widget.previewBuilder(cubit.cameraId!),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
