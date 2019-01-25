import 'package:flutter_weather/commom_import.dart';

class GiftMziWatchPage extends StatefulWidget {
  final int index;
  final int length;
  final List<MziData> photos;
  final Stream<List<MziData>> photoStream;

  GiftMziWatchPage(
      {@required this.index,
      @required this.length,
      @required this.photos,
      @required this.photoStream});

  @override
  State createState() => GiftMziWatchState(
      index: index, length: length, photos: photos, photoStream: photoStream);
}

class GiftMziWatchState extends PageState<GiftMziWatchPage> {
  final Stream<List<MziData>> photoStream;
  final List<MziData> photos;
  final int length;
  final PageController _pageController;
  final PhotoWatchViewModel _viewModel;

  int _currentPage = 0;
  bool _showAppBar = false;

  GiftMziWatchState(
      {@required int index,
      @required this.length,
      @required this.photos,
      @required this.photoStream})
      : _pageController = PageController(initialPage: index, keepPage: false),
        _viewModel = PhotoWatchViewModel(photoStream: photoStream),
        _currentPage = index;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: _viewModel.data.stream,
        builder: (context, snapshot) {
          final List<MziData> list = (snapshot.data ?? photos).toList();

          if (list.length < length) {
            list.addAll(List.generate(length - list.length, (_) => null));
          }

          return StreamBuilder(
            stream: _viewModel.favList.stream,
            builder: (context, snapshot) {
              final List<MziData> favList = snapshot.data ?? List();
              final isFav = favList.any((v) =>
                  v.url == list[_currentPage]?.url &&
                  v.url == list[_currentPage]?.url);

              return Stack(
                children: <Widget>[
                  // 图片浏览
                  GestureDetector(
                    onTap: () => setState(() => _showAppBar = !_showAppBar),
                    child: PhotoViewGallery(
                      pageController: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      loadingChild: Center(
                        child: Image.asset("images/loading.gif"),
                      ),
                      pageOptions: list
                          .map(
                            (data) => data != null
                                ? PhotoViewGalleryPageOptions(
                                    heroTag: data.url,
                                    imageProvider: CachedNetworkImageProvider(
                                          data.url,
//                                      "http://pic.sc.chinaz.com/files/pic/pic9/201610/apic23847.jpg",
                                      headers: Map<String, String>()
                                        ..["Referer"] = data.refer,
                                    ),
                                    minScale: 0.1,
                                    maxScale: 5.0,
                                  )
                                : PhotoViewGalleryPageOptions(
                                    imageProvider:
                                        AssetImage("images/loading.gif"),
                                    minScale: 1.0,
                                    maxScale: 1.0,
                                  ),
                          )
                          .toList(),
                    ),
                  ),

                  // 标题栏
                  AnimatedOpacity(
                    opacity: _showAppBar ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomAppBar(
                      title: Text(""),
                      showShadowLine: false,
                      color: Colors.transparent,
                      leftBtn: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (!_showAppBar) return;

                          pop(context);
                        },
                      ),
                      rightBtns: <Widget>[
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            if (!_showAppBar) return;

                            FavHolder().autoFav(list[_currentPage]);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
