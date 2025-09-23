import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:myresolve/Utils/feed_provider.dart';
import 'package:shimmer/shimmer.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch feed data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).fetchFeed();
    });
  }

  @override
  void dispose() {
    // Reset orientation when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FB),
          body: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
              ),
              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      child: Row(
                        children: [

                          Expanded(
                            child: Center(
                              child: Text(
                                'Feed',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(width: 24.sp), // Balance the back arrow
                        ],
                      ),
                    ),
                    // Feed content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Consumer<FeedProvider>(
                          builder: (context, feedProvider, child) {
                            if (feedProvider.isLoading) {
                              return _buildShimmerList();
                            }
                            
                            if (feedProvider.error.isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Failed to load feed',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    ElevatedButton(
                                      onPressed: () => feedProvider.fetchFeed(),
                                      child: Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            if (feedProvider.feedItems.isEmpty) {
                              return Center(
                                child: Text(
                                  'No feed items available',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }
                            
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              itemCount: feedProvider.feedItems.length,
                              itemBuilder: (context, index) {
                                final item = feedProvider.feedItems[index];
                                return _buildFeedCard(item, feedProvider, index);
                              },
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: true,
                              addSemanticIndexes: false,
                              cacheExtent: 500.0,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedCard(FeedModel item, FeedProvider provider, int index) {
    final cleanTitle = provider.extractTitle(item.title);
    final cleanContent = provider.extractContent(item.content);
    final timeAgo = provider.formatTimeAgo(item.createdAt);
    final hasVideo = provider.isYouTubeUrl(item.mediaUrl);
    
    return RepaintBoundary(
      key: ValueKey('feed_card_$index'),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Icon
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF377CFD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF377CFD),
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 4.w),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF377CFD).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF377CFD),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      // Title
                      Text(
                        cleanTitle,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      // Content preview
                      Text(
                        cleanContent.length > 150 
                            ? '${cleanContent.substring(0, 150)}...'
                            : cleanContent,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      // Time
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Video player (if video URL exists) - Lazy loaded
          if (hasVideo) ...[
            _buildLazyVideoPlayer(item.mediaUrl, provider, index),
          ],
          // Expand button for full content
          if (cleanContent.length > 150) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: InkWell(
                onTap: () => _showFullContent(cleanTitle, cleanContent, item.mediaUrl, provider),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF377CFD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Center(
                    child: Text(
                      'Read More',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF377CFD),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    )
    );
  }

  Widget _buildVideoPlayer(String videoUrl, FeedProvider provider) {
    final videoId = provider.getYouTubeVideoId(videoUrl);
    if (videoId.isEmpty) return SizedBox.shrink();

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        forceHD: false,
        controlsVisibleAtStart: true,
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 25.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.w),
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFF377CFD),
          onReady: () {
            print('YouTube player ready');
          },
          onEnded: (data) {
            print('Video ended');
          },
          actionsPadding: const EdgeInsets.all(8.0),
          bottomActions: [
            CurrentPosition(),
            ProgressBar(isExpanded: true),
            RemainingDuration(),
            PlaybackSpeedButton(),
            GestureDetector(
              onTap: () {
                _openFullScreenVideo(videoId, controller);
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
            ),
          ],
          topActions: [
            Expanded(
              child: Text(
                'Video Player',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenVideo(String videoId, YoutubePlayerController currentController) {
    // Get current playback position
    final currentPosition = currentController.value.position;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          videoId: videoId,
          startPosition: currentPosition,
        ),
      ),
    );
  }

  Widget _buildLazyVideoPlayer(String videoUrl, FeedProvider provider, int index) {
    final videoId = provider.getYouTubeVideoId(videoUrl);
    if (videoId.isEmpty) return SizedBox.shrink();

    return Container(
      key: ValueKey('video_$index'),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 25.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.w),
        child: _LazyVideoWidget(
          videoId: videoId,
          onFullScreenTap: (controller) {
            _openFullScreenVideo(videoId, controller);
          },
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerCard(index),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
    );
  }

  Widget _buildShimmerCard(int index) {
    return RepaintBoundary(
      key: ValueKey('shimmer_$index'),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    height: 2.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    width: double.infinity,
                    height: 2.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    width: double.infinity,
                    height: 1.5.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 60.w,
                    height: 1.5.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    width: 30.w,
                    height: 1.h,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }

  void _showFullContent(String title, String content, String mediaUrl, FeedProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    if (provider.isYouTubeUrl(mediaUrl)) ...[
                      SizedBox(height: 3.h),
                      _buildVideoPlayer(mediaUrl, provider),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Lazy Video Widget for better performance
class _LazyVideoWidget extends StatefulWidget {
  final String videoId;
  final Function(YoutubePlayerController) onFullScreenTap;

  const _LazyVideoWidget({
    Key? key,
    required this.videoId,
    required this.onFullScreenTap,
  }) : super(key: key);

  @override
  State<_LazyVideoWidget> createState() => _LazyVideoWidgetState();
}

class _LazyVideoWidgetState extends State<_LazyVideoWidget>
    with AutomaticKeepAliveClientMixin {
  YoutubePlayerController? _controller;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => _isInitialized;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (!_isInitialized) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          forceHD: false,
          controlsVisibleAtStart: true,
        ),
      );
      _isInitialized = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF377CFD),
            strokeWidth: 2.0,
          ),
        ),
      );
    }

    return YoutubePlayer(
      controller: _controller!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: const Color(0xFF377CFD),
      onReady: () {
        print('Lazy YouTube player ready');
      },
      actionsPadding: const EdgeInsets.all(8.0),
      bottomActions: [
        CurrentPosition(),
        ProgressBar(isExpanded: true),
        RemainingDuration(),
        PlaybackSpeedButton(),
        GestureDetector(
          onTap: () {
            widget.onFullScreenTap(_controller!);
          },
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.fullscreen,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      ],
      topActions: [
        Expanded(
          child: Text(
            'Video Player',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

// Dedicated Fullscreen Video Player Screen
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoId;
  final Duration startPosition;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoId,
    required this.startPosition,
  }) : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: true,
        startAt: widget.startPosition.inSeconds,
      ),
    );
  }

  @override
  void dispose() {
    // Reset orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Ensure orientation is reset when back button is pressed
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            onReady: () {
              print('Fullscreen player ready');
            },
            onEnded: (data) {
              // Auto-close fullscreen when video ends
              Navigator.of(context).pop();
            },
            bottomActions: [
              CurrentPosition(),
              ProgressBar(isExpanded: true),
              RemainingDuration(),
              PlaybackSpeedButton(),
              // Custom close button instead of fullscreen toggle
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.fullscreen_exit,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ],
            topActions: [
              // Custom back button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
              Spacer(),
              // Video title or info can go here
              Text(
                'Fullscreen Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}