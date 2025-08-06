import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import '../api_config.dart';

class DaftarRekamanSantriScreen extends StatefulWidget {
  final String kodeGuru;
  final String kodeSantri;
  const DaftarRekamanSantriScreen({
    Key? key,
    required this.kodeGuru,
    required this.kodeSantri,
  }) : super(key: key);

  @override
  State<DaftarRekamanSantriScreen> createState() => _DaftarRekamanSantriScreenState();
}

class _DaftarRekamanSantriScreenState extends State<DaftarRekamanSantriScreen> {
  List<String> rekamanFiles = [];
  bool isLoading = true;
  String? error;
  AudioPlayer audioPlayer = AudioPlayer();
  String? currentlyPlaying;

  @override
  void initState() {
    super.initState();
    fetchRekaman();
  }

  Future<void> fetchRekaman() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final url = '${ApiConfig.baseUrl}/api/rekaman_guru/${widget.kodeGuru}?kode_santri=${widget.kodeSantri}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rekamanFiles = List<String>.from(data['files']);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Gagal memuat rekaman: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Terjadi error: $e';
        isLoading = false;
      });
    }
  }

  void playAudio(String filename) async {
    final url = '${ApiConfig.baseUrl}/static/recordings/$filename';
    await audioPlayer.stop();
    await audioPlayer.play(UrlSource(url));
    setState(() {
      currentlyPlaying = filename;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Rekaman Santri'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : rekamanFiles.isEmpty
                  ? const Center(child: Text('Tidak ada rekaman untuk santri ini.'))
                  : ListView.builder(
                      itemCount: rekamanFiles.length,
                      itemBuilder: (context, index) {
                        final file = rekamanFiles[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.audiotrack, color: Colors.blue),
                            title: Text(file),
                            trailing: IconButton(
                              icon: Icon(
                                currentlyPlaying == file ? Icons.pause : Icons.play_arrow,
                                color: currentlyPlaying == file ? Colors.orange : Colors.green,
                              ),
                              onPressed: () {
                                if (currentlyPlaying == file) {
                                  audioPlayer.pause();
                                  setState(() {
                                    currentlyPlaying = null;
                                  });
                                } else {
                                  playAudio(file);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}