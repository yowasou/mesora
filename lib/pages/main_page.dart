import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show Uint8List, rootBundle;

import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:mesora/AudioManager.dart';
import 'package:mesora/logger.dart';
import 'package:mesora/pages/result_page.dart';

import '../Data/mesora_app_data.dart';
import '../data/character_data.dart';
import '../vision_detector_views/detect_eye_data.dart';
import '../vision_detector_views/face_detector_view.dart';

// ゲームメイン
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  // 進行状態を示す
  PlayStatus _stepFlag = PlayStatus.Calibration;

  DateTime _startTime = DateTime.now();

  final List<CharacterData> _characterAllList = [
    CharacterData("man001.jpg",         "man",          0, 0, 1024, 1024, true),
    CharacterData("man001.jpg",         "man",          0, 0, 1024, 1024, true),
    CharacterData("man001.jpg",         "man",          0, 0, 1024, 1024, true),
    CharacterData("man001.jpg",         "man",          0, 0, 1024, 1024, true),

//    CharacterData("man001.jpg",         "man",          399, 369, 249, 118, true),
//    CharacterData("man002.jpg",         "man",          367, 399, 351,  84, true),
//    CharacterData("man003.jpg",         "man",          242, 410, 343,  60, true),
    // 女性
//    CharacterData("woman001.jpg",       "woman",        492, 300, 154,  39, true),
//    CharacterData("woman002.jpg",       "woman",        337, 300, 271,  68, true),
//    CharacterData("woman003.jpg",       "woman",        459, 234, 212,  41, true),
    // 面接官
//    CharacterData("interviewer001.jpg", "interviewer",  425, 336, 372,  83, true),
//    CharacterData("interviewer002.jpg", "interviewer",  573, 236,  95,  22, true),
//    CharacterData("interviewer003.jpg", "interviewer",  478, 216,  99,  19, true),
    // ヤンキー
//    CharacterData("yankee004.jpeg",     "yankee",       499, 197, 130,  39, false),
//    CharacterData("yankee007.jpeg",     "yankee",       456, 217, 138,  38, false),
//    CharacterData("yankee010.jpeg",     "yankee",       277, 240, 419, 128, false),
  ];

  Image? _targetImage;

  // MLKitで扱っている画像のサイズ
  int _baseWidth = 0;
  int _baseHeight = 0;

  // MLKitで抜き出した画像左
  img.Image? _leftImage;
  int _leftX = 0;
  int _leftY = 0;
  int _leftCenterX = 0;
  int _leftCenterY = 0;

  // MLKitで抜き出した画像右
  img.Image? _rightImage;
  int _rightX = 0;
  int _rightY = 0;
  int _rightCenterX = 0;
  int _rightCenterY = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    MesoraAppData.initialize(MesoraAppData.max_step);
    BottomPainter.initialize();

    // プレイデータの初期化
    var random = math.Random();
    for(var i = 0; i < MesoraAppData.max_step; i++) {
      var idx = random.nextInt(_characterAllList.length);
      MesoraAppData.encounterList.add(_characterAllList[idx]);
    }

    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(milliseconds: 200),
      (Timer timer) {

        // 初期化待ち
        if(!BottomPainter.isInitialized()){
          return;
        }

        var character = MesoraAppData.getCurrentCharacterData();
        if(_stepFlag == PlayStatus.Calibration) {
          if (DetectEyeData.instance.mode == DetectMode.Detect) {
            _stepFlag = PlayStatus.Ready01;
            Logger.info("Next step => PlayStatus.Ready");
          }
        }else if(_stepFlag == PlayStatus.Ready01) {
          AudioManager.playSE(_getSeComeAssetName());
          _stepFlag = PlayStatus.Ready02;

        }else if(_stepFlag == PlayStatus.Ready02) {
          if(!AudioManager.isSePlay){
            _stepFlag = PlayStatus.Play;
            _startTime = DateTime.now();
            Logger.info("Next step => PlayStatus.Play");
          }

        }else if(_stepFlag == PlayStatus.Play) {
          // 5秒待つ
          var diff = DateTimeRange(start: _startTime, end: DateTime.now());
          if (diff.duration.inSeconds <= 5) {
            // チェックタイム
            // チェック右
            _rightImage = DetectEyeData().rightEyeImage;
            //var hitTestRight = _hitTest(_rightImage, _rightX, _rightY, _rightCenterX, _rightCenterY, _baseWidth, _baseHeight);

            if (_rightImage != null) {
              _rightCenterX = _rightImage!.width;
              _rightCenterY = _rightImage!.height;
              _baseWidth = _rightImage!.width;
              _baseHeight = _rightImage!.height;
            }
            var hitTestRight = _hitTest(_rightImage, 0, 0, _rightCenterX,
                _rightCenterY, _baseWidth, _baseHeight);

            if (hitTestRight && character.checkMode) {
              // 見つめているのでカウント
              MesoraAppData.addScore(MesoraAppData.encounter, 1);
            } else if (!hitTestRight && !character.checkMode) {
              // 眼をそらしているのででカウント
              MesoraAppData.addScore(MesoraAppData.encounter, 1);
            }


//            // チェック左
//            _leftImage = DetectEyeData().leftEyeImage;
//            var hitTestLeft = _hitTest(_leftImage, _leftX, _leftY, _leftCenterX, _leftCenterY, _baseWidth, _baseHeight );
//            if(hitTestRight && hitTestLeft && character.checkMode){
//              // 見つめているのでカウント
//              MesoraAppData.addScore(MesoraAppData.encounter, 1);
//            }else if(!hitTestRight && !hitTestLeft && !character.checkMode){
//              // 眼をそらしているのででカウント
//              MesoraAppData.addScore(MesoraAppData.encounter, 1);
//            }

          }else {
            // 次に
            if(!AudioManager.isSePlay) {
              _stepFlag = PlayStatus.Leave;
              AudioManager.playSE("leave");
              Logger.info("Next step => PlayStatus.Leave");
            }
          }

        }else if(_stepFlag == PlayStatus.Leave) {
          if(AudioManager.isSePlay) {
            return;
          }
          MesoraAppData.encounter++;
          if (MesoraAppData.encounter >=  MesoraAppData.max_step) {
            _stepFlag = PlayStatus.Next;
            Logger.info("Next step => PlayStatus.Next");
          }else{
            _stepFlag = PlayStatus.Ready01;
            Logger.info("Next step => PlayStatus.Play");
          }

        }else if(_stepFlag == PlayStatus.Next){
            if(MesoraAppData.encounter >= MesoraAppData.encounterList.length){
              MesoraAppData.encounter = 0;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context)=> const ResultPage()
                  ),
                  (route) => false
              );
              return;
            }
        }
        setState(() {});
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var score = MesoraAppData.getTotalScore();

    if(_stepFlag == PlayStatus.Play || _stepFlag == PlayStatus.Ready01 || _stepFlag == PlayStatus.Ready02){
      _targetImage = Image.asset(_getImageAssetName());
    }else{
      _targetImage = Image.asset('assets/image/empty.png');
    }

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: SafeArea(
                child: Stack(
                    children:[
                      FaceDetectorView(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("SCORE : $score", style: const TextStyle(fontSize: 30.0)),
                      ),
                      Center(
                        child:Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              //fit:BoxFit.contain,
                              width:double.infinity,
                              child:_targetImage
                            )
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child:CustomPaint(
                          size: const Size(double.infinity, 100),
                          painter: BottomPainter(),
                        )
                      )
                    ]
                )
            )
        )
    );
  }

  /// 眼の位置と画像の眼の位置の比較
  /// 比較は片目筒行います
  /// @param buff 眼の位置の画像のデータ
  /// @param x1 眼の位置の矩形のX座標
  /// @param y1 眼の位置の矩形のY座標
  /// @param x2 眼の位置の矩形の幅
  /// @param y2 眼の位置の矩形の高さ
  /// @param widh 認識に利用した映像の幅
  /// @param height 認識に利用した映像の高さ
  bool _hitTest(img.Image? clipImage, int x1, int y1, int x2, int y2, int width,
      int height) {
    // 切り抜き画像がnullかどうか
    if (clipImage == null) {
      return false;
    }
    var buffer = clipImage.toList();
    //中心座標
    double centerX = (x2 - x1) / 2;
    double centerY = (y2 - y1) / 2;
    var px = buffer[(width * centerY + centerX).toInt()];
    var grayScale = (px.r + px.g + px.b) / 3;
    Logger.info('grayScale:${grayScale.toString()}');
    if (grayScale < 128) {
      // 見つめてる
      return true;
    } else {
      // 見つめてない
      return false;
    }
  }


  String _getImageAssetName(){
    return "assets/image/${MesoraAppData.getCurrentCharacterData().imageAssetname}";
  }

  String _getSeComeAssetName(){
    var seAssetName = "${MesoraAppData.getCurrentCharacterData().seKeyNamePrefix}_come";
    return seAssetName;
  }

  String _getSeAssetName(){
    var random = math.Random();
    var idx = random.nextInt(3);
    var seAssetName = "${MesoraAppData.getCurrentCharacterData().seKeyNamePrefix}_${idx.toStringAsFixed(3).padLeft(3,'')}";
    return seAssetName;
  }
}

class BottomPainter extends CustomPainter{

  static ui.Image? checkpoint001Image;
  static ui.Image? checkpoint002Image;
  static ui.Image? playerImage;

  static void initialize() async{
    checkpoint001Image = await _loadImage("assets/image/check_point_001.png");
    checkpoint002Image = await _loadImage("assets/image/check_point_002.png");
    playerImage = await _loadImage("assets/image/player.png");
  }

  static bool isInitialized(){
    if(checkpoint001Image == null){
      return false;
    }
    if(checkpoint001Image == null){
      return false;
    }
    if(playerImage == null){
      return false;
    }
    return true;
  }


  static Future<ui.Image?> _loadImage(String assetName) async {
    Logger.info("_loadImage $assetName 1");
    var data = await rootBundle.load(assetName);
    Logger.info("_loadImage $assetName 2");
    return await decodeImageFromList(data.buffer.asUint8List());
  }

  @override
  void paint(Canvas canvas, Size size) async {
    var character = MesoraAppData.getCurrentCharacterData();
    var split = size.width / 8;
    final Paint paint = Paint()..color = Colors.blue;
    var playerX = split * (MesoraAppData.encounter * 2) + split / 2 + 10;


    canvas.drawImage(MesoraAppData.encounter == 0 ? checkpoint001Image! :  checkpoint001Image!, Offset(split * 0 + split / 2, 30), paint);
    canvas.drawImage(MesoraAppData.encounter < 1 ? checkpoint002Image! :  checkpoint001Image!, Offset(split * 2 + split / 2, 30), paint);
    canvas.drawImage(MesoraAppData.encounter < 2 ? checkpoint002Image! :  checkpoint001Image!, Offset(split * 4 + split / 2, 30), paint);
    canvas.drawImage(MesoraAppData.encounter < 3 ? checkpoint002Image! :  checkpoint001Image!, Offset(split * 6 + split / 2, 30), paint);
    canvas.drawImage(playerImage!, Offset(playerX, 0), paint);
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

enum PlayStatus{
  // キャリブレーション
  Calibration,
  // 準備
  Ready01,
  // 準備
  Ready02,
  // プレイ
  Play,
  // 人物去った
  Leave,
  // 次のページ
  Next,
}