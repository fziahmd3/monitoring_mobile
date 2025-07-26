import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class RekamHafalanScreen extends StatefulWidget {
  final String kodeSantri;
  const RekamHafalanScreen({super.key, required this.kodeSantri});

  @override
  State<RekamHafalanScreen> createState() => _RekamHafalanScreenState();
}

class _RekamHafalanScreenState extends State<RekamHafalanScreen> {
  String? _recordingPath;
  bool _isRecording = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Request microphone and storage permissions
      if (await Permission.microphone.request().isGranted &&
          await Permission.storage.request().isGranted) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final filePath = '${appDocDir.path}/hafalan_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _recordingPath = filePath;
          _recordDuration = 0;
        });
        _startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin mikrofon atau penyimpanan ditolak.')),
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memulai rekaman: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        _recordDuration = 0;
      });
      if (path != null) {
        print('Recording stopped. File path: $path');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rekaman berhasil disimpan di: $path')),
        );
      } else {
        print('Recording stopped, but path is null.');
      }
    }
    catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghentikan rekaman: $e')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _playRecording(String path) async {
    // This will be implemented when we integrate a player
    // For now, just a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur putar rekaman akan ditambahkan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekam Hafalan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Santri: ${widget.kodeSantri}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Rekam Hafalan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_isRecording)
              Text(
                'Merekam: ${_formatDuration(_recordDuration)}',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  child: Text(_isRecording ? 'Berhenti Merekam' : 'Mulai Merekam'),
                ),
                if (!_isRecording && _recordingPath != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _playRecording(_recordingPath!); // Call the play function
                      },
                      child: const Text('Putar Rekaman'),
                    ),
                  ),
                if (!_isRecording && _recordingPath != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // _uploadRecording(_recordingPath!); // Fungsi ini akan diimplementasikan nanti
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur upload rekaman akan ditambahkan.')),
                        );
                      },
                      child: const Text('Upload Rekaman'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 