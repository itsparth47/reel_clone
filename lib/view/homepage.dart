import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reels/services/controller.dart';
import 'package:reels/view/uploadpage.dart';
import 'package:video_player/video_player.dart';

class MainScreen extends StatelessWidget {
  final ReelController _reelController = Get.put(ReelController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
            () {
          if (_reelController.error != null) {
            return Center(child: Text('Error: ${_reelController.error.toString()}'));
          }
          if (_reelController.isLoading && _reelController.reels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _reelController.pageController,
                scrollDirection: Axis.vertical,
                itemCount: _reelController.reels.length,
                itemBuilder: (context, index) {
                  _reelController.pageController.addListener(() {
                    if (_reelController.pageController.page == index.toDouble()) {
                      _reelController.playVideo(index);
                    } else {
                      _reelController.pauseVideo(index);
                    }
                  });
                  final reel = _reelController.reels[index];
                  final videoController = _reelController.getVideoController(index);
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GestureDetector(
                        onTap: (){
                          _reelController.toggleMute(_reelController.pageController.page?.round() ?? 0);
                        },
                      onLongPress: (){
                        _reelController.togglePlay(_reelController.pageController.page?.round() ?? 0);
                      },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: VideoPlayer(videoController!)
                        ),
                      ),
                      Container(
                        color: Colors.white.withOpacity(.6),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: ListTile(
                            leading: Text(reel.uid),
                            title: Text(reel.title),
                            subtitle: Text(reel.description),
                            trailing: Column(
                              children: [
                                const Icon(Icons.favorite),
                                Text(reel.nLikes.toString()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              InkWell(
                onTap: () {
                  Get.to(() => UploadScreen());
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 40,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
