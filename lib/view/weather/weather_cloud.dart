import 'package:flutter_weather/commom_import.dart';
import 'weather_sunny.dart';

class WeatherCloud extends StatefulWidget {
  WeatherCloud({Key key}) : super(key: key);

  @override
  State createState() => WeatherCloudState();
}

class WeatherCloudState extends PageState<WeatherCloud>
    with TickerProviderStateMixin {
  /// 白云移动动画
  AnimationController _cloudController;
  Animation<double> _cloudAnim;

  /// 白云上下动画
  AnimationController _cloudTopController;
  Animation<double> _cloudTopAnim;

  @override
  void dispose() {
    _cloudController?.dispose();
    _cloudTopController?.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _cloudController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..forward();
    _cloudAnim = Tween(begin: 0.0, end: getScreenWidth(context) / 2)
        .animate(CurvedAnimation(parent: _cloudController, curve: Curves.ease));
    _cloudTopController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _cloudTopAnim = Tween(begin: 245.0, end: 235.0).animate(
        CurvedAnimation(parent: _cloudTopController, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    final isDay = DateTime.now().hour >= 6 && DateTime.now().hour < 18;

    return Stack(
      children: <Widget>[
        // 晴天
        WeatherSunny(),

        // 白云
        AnimatedBuilder(
          animation: _cloudAnim,
          builder: (context, child) {
            return AnimatedBuilder(
              animation: _cloudTopAnim,
              builder: (context, child) {
                return Positioned(
                  child: Opacity(
                    opacity: isDay ? 0.9 : 0.7,
                    child: Image.asset(
                      "images/ic_cloud.png",
                      width: 80,
                      height: 80,
                    ),
                  ),
                  bottom: _cloudTopAnim.value,
                  left: _cloudAnim.value,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
