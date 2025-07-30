import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioHelper {
  static AudioPlayer? _audioPlayer;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized || _audioPlayer == null) {
      try {
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setReleaseMode(ReleaseMode.stop);
        _isInitialized = true;
        print('AudioHelper initialized successfully');
      } catch (e) {
        print('Error initializing AudioHelper: $e');
        _isInitialized = false;
        _audioPlayer = null;
      }
    }
  }

  static Future<bool> playAudio(String filePath) async {
    try {
      await initialize();
      
      if (_audioPlayer == null) {
        print('AudioPlayer is null, cannot play audio');
        return false;
      }
      
      // Stop playback yang sedang berlangsung
      await _audioPlayer!.stop();
      
      Source source;
      
      // Periksa apakah ini URL atau file lokal
      if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
        // URL remote
        print('Playing remote audio: $filePath');
        source = UrlSource(filePath);
      } else {
        // File lokal
        final file = File(filePath);
        if (!await file.exists()) {
          print('Audio file does not exist: $filePath');
          return false;
        }

        final fileSize = await file.length();
        if (fileSize == 0) {
          print('Audio file is empty: $filePath');
          return false;
        }
        
        print('Playing local audio: $filePath');
        source = DeviceFileSource(filePath);
      }
      
      await _audioPlayer!.play(source);
      print('Audio playback started: $filePath');
      return true;
    } catch (e) {
      print('Error playing audio: $e');
      return false;
    }
  }

  static Future<void> stopAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        print('Audio playback stopped');
      }
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  static Future<void> pauseAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.pause();
        print('Audio playback paused');
      }
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  static Future<void> resumeAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.resume();
        print('Audio playback resumed');
      }
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  static Stream<PlayerState>? get playerStateStream => _audioPlayer?.onPlayerStateChanged;
  static Stream<void>? get playerCompleteStream => _audioPlayer?.onPlayerComplete;

  static Future<void> dispose() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.dispose();
        _audioPlayer = null;
        _isInitialized = false;
        print('AudioHelper disposed');
      }
    } catch (e) {
      print('Error disposing AudioHelper: $e');
    }
  }

  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('FileSystemException')) {
      return 'File rekaman tidak dapat diakses';
    } else if (error.toString().contains('FormatException')) {
      return 'Format file rekaman tidak didukung';
    } else if (error.toString().contains('Permission')) {
      return 'Izin akses file ditolak';
    } else {
      return 'Terjadi kesalahan saat memutar rekaman: $error';
    }
  }
} 