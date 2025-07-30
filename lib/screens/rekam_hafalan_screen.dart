import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/audio_helper.dart';
import '../api_config.dart';

class RekamHafalanScreen extends StatefulWidget {
  final String kodeSantri;
  final String kodeGuru;
  const RekamHafalanScreen({super.key, required this.kodeSantri, required this.kodeGuru});

  @override
  State<RekamHafalanScreen> createState() => _RekamHafalanScreenState();
}

class _RekamHafalanScreenState extends State<RekamHafalanScreen> {
  String? _recordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    AudioHelper.playerStateStream?.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    AudioHelper.playerCompleteStream?.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    AudioHelper.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Request microphone and storage permissions
      if (await Permission.microphone.request().isGranted &&
          await Permission.storage.request().isGranted) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final filePath = '${appDocDir.path}/hafalan_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          RecordConfig(encoder: AudioEncoder.wav),
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
    } catch (e) {
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
    try {
      print('Attempting to play recording from path: $path');
      
      final success = await AudioHelper.playAudio(path);
      
      if (success) {
        print('Playback started successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memutar rekaman...')),
      );
      } else {
        print('Failed to start playback');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memutar rekaman.')),
        );
      }
    } catch (e) {
      print('Error playing recording: $e');
      final errorMessage = AudioHelper.getErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _stopPlaying() async {
    try {
      await AudioHelper.stopAudio();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  Future<void> _uploadRecording(String path) async {
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada rekaman untuk diunggah.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunggah rekaman...')),
    );

    var uri = Uri.parse('${ApiConfig.baseUrl}/upload_recording');
    var request = http.MultipartRequest('POST', uri)
      ..fields['kodeSantri'] = widget.kodeSantri;
    
    // Hanya kirim kodeGuru jika tidak kosong
    if (widget.kodeGuru.isNotEmpty) {
      request.fields['kodeGuru'] = widget.kodeGuru;
    }

    print('Uploading recording...');
    print('kodeSantri: ${widget.kodeSantri}');
    print('kodeGuru: ${widget.kodeGuru}');
    print('File path: $path');

    request.files.add(await http.MultipartFile.fromPath('recording', path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rekaman berhasil diunggah!')),
        );
        print('Upload successful!');
        // Tambahkan notifikasi dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Upload Berhasil'),
            content: const Text('Rekaman berhasil diupload. Silakan minta guru untuk menekan tombol Refresh agar rekaman muncul di list.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Baca response body untuk mendapatkan pesan error yang lebih detail
        final responseBody = await response.stream.bytesToString();
        print('Upload failed with status: ${response.statusCode}, response: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah rekaman: ${response.statusCode}'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat mengunggah: $e')),
      );
      print('Error during upload: $e');
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        String? filePath = result.files.first.path;
        if (filePath != null) {
          setState(() {
            _recordingPath = filePath;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File audio dipilih: ${result.files.first.name}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih file audio: $e')),
      );
      print('Error picking audio file: $e');
    }
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
            if (_isPlaying)
              Text(
                'Memutar rekaman...',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            if (_recordingPath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'File: ${_recordingPath!.split('/').last}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: _isRecording 
                    ? SvgPicture.asset(
                        'assets/icons/Stop Record.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      )
                    : SvgPicture.asset(
                        'assets/icons/Start Record.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                  label: Text(_isRecording ? 'Berhenti Merekam' : 'Mulai Merekam'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ElevatedButton(
                    onPressed: _isRecording ? null : _pickAudioFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pilih File'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_recordingPath != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? _stopPlaying : () => _playRecording(_recordingPath!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.orange : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isPlaying 
                      ? const Icon(Icons.stop, size: 20)
                      : const Icon(Icons.play_arrow, size: 20),
                    label: Text(_isPlaying ? 'Stop' : 'Putar Rekaman'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ElevatedButton.icon(
                      onPressed: _isPlaying ? null : () => _uploadRecording(_recordingPath!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      icon: SvgPicture.asset(
                        'assets/icons/Upload File.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      label: const Text('Upload Rekaman'),
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