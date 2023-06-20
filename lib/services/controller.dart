import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reels/services/reels.dart';
import 'package:video_player/video_player.dart';

class ReelController extends GetxController {
  final RxList<Reel> _reels = <Reel>[].obs;
  final RxBool _isLoading = false.obs;
  final _error = Rx<Exception?>(null);
  final _videoControllers = <VideoPlayerController?>[].obs;
  final RxBool _isMuted = false.obs;
  final _pageController = PageController().obs;
  RxInt count = 10.obs;

  List<Reel> get reels => _reels;
  bool get isLoading => _isLoading.value;
  Exception? get error => _error.value;
  List<VideoPlayerController?> get videoControllers => _videoControllers;
  bool get isMuted => _isMuted.value;
  PageController get pageController => _pageController.value;

  VideoPlayerController? getVideoController(int index) {
    if (index >= 0 && index < _videoControllers.length) {
      return _videoControllers[index];
    }
    return null;
  }

  void playVideo(int index) {
    final controller = _videoControllers[index];
    controller?.play();
  }

  void pauseVideo(int index) {
    final controller = _videoControllers[index];
    controller?.pause();
  }

  void toggleMute(int index) {
    _isMuted.toggle();
    final volume = _isMuted.value ? 0.0 : 1.0;
    for (final controller in _videoControllers) {
      controller?.setVolume(volume);
    }
  }

  void togglePlay(int index) {
    final videoController = _videoControllers[index];
    if (videoController != null) {
      if (videoController.value.isPlaying) {
        videoController.pause();
      } else {
        videoController.play();
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    gettingreels();
  }

  void gettingreels() async {
    Fluttertoast.showToast(msg: "Making Api Call", backgroundColor: Colors.blue, toastLength: Toast.LENGTH_SHORT);
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('reels').get();
      final reelsData = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Reel(
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          videoLink: data['videoLink'] ?? '',
          uid: data['uid'] ?? '',
          nLikes: data['nLikes'] ?? 0,
        );
      }).toList();

      final reels = List<Reel>.generate(10, (index) {
        return reelsData[index % 5];
      });

      print(reels.length);

      final controllers = reels.map((reel) {
        final videoController = VideoPlayerController.network(reel.videoLink);
        return videoController;
      }).toList();

      _videoControllers.addAll(controllers);
      await Future.wait(_videoControllers.map((controller) => controller!.initialize()));
      _videoControllers.forEach((controller) => controller!.value = controller.value.copyWith(isInitialized: true));

      _reels.value = reels;
      _pageController.value.addListener(() {
        if(pageController.page == 8 || pageController.page == 28 || pageController.page == 18){
          Fluttertoast.showToast(msg: "Making API Call", backgroundColor: Colors.red, toastLength: Toast.LENGTH_SHORT);
          while(_reels.length <= 30) {
            final reels = List<Reel>.generate(10, (index) {
              return reelsData[index % 5];
            });
            _reels.addAll(reels);
          }
        }
      });
      } catch (e) {
      _error.value = Exception('Failed to fetch reels: $e');
    }
  }

  @override
  void onClose() {
    for (final controller in _videoControllers) {
      controller?.dispose();
    }
    _pageController.value.dispose();
    super.onClose();
  }
}
