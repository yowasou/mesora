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
    // 男性
    CharacterData("man001.jpg",         "man",          594, 747, 189,  98, true),
    // 女性
    CharacterData("woman001.jpg",       "woman",        645, 337, 151,  36, true),
    // 面接官
    CharacterData("interviewer003.jpg", "interviewer",  573, 236,  95,  22, true),
    // ヤンキー
    CharacterData("yankee010.jpeg",     "yankee",       673, 436, 366,  63, false),
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
            var hitTestRight = _hitTest(_rightImage, _rightX, _rightY, _rightCenterX, _rightCenterY, _baseWidth, _baseHeight);
            // チェック左
            _leftImage = DetectEyeData().leftEyeImage;
            var hitTestLeft = _hitTest(_leftImage, _leftX, _leftY, _leftCenterX, _leftCenterY, _baseWidth, _baseHeight );

            if(hitTestRight && hitTestLeft && character.checkMode){
              // 見つめているのでカウント
              MesoraAppData.addScore(MesoraAppData.encounter, 1);
            }else if(!hitTestRight && !hitTestLeft && !character.checkMode){
              // 眼をそらしているのででカウント
              MesoraAppData.addScore(MesoraAppData.encounter, 1);
            }

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
  /// @param x 眼の位置の矩形のX座標
  /// @param y 眼の位置の矩形のY座標
  /// @param width 眼の位置の矩形の幅
  /// @param height 眼の位置の矩形の高さ
  /// @param baseWidth 認識に利用した映像の幅
  /// @param baseHeight 認識に利用した映像の高さ
  bool _hitTest(img.Image? clipImage, int x, int y, int centerX, int centerY, int baseWidth, int baseHeight){

    // 切り抜き画像がnullかどうか
    if(clipImage == null){
      return false;
    }

    //　画像サイズが取れないので、固定値
    double targetWidth = 1024.0;
    //double tragetHeight = 1024.0;

    // 切り抜き画像のサイズ取得
    //int width = clipImage!.width;
    //int height = clipImage!.height;

    // 座標変換する
    double scale = targetWidth.toDouble() / baseWidth.toDouble();

    var scaleCenterX = centerX * scale;
    var scaleCenterY = centerY * scale;

    var character = MesoraAppData.getCurrentCharacterData();
    if(character.areaX <= scaleCenterX && scaleCenterX <= (character.areaX + character.areaWidth)){
      if(character.areaY <= scaleCenterY && scaleCenterY <= (character.areaY + character.areaHeight)){
        // 範囲に入っているので、みつめてるかチェック
        var buffer = clipImage.toList();

        // 中心が黒目かどうか簡易チェック
        var px = buffer[centerY - y * centerX - x];
        var grayScale = (px.r + px.g + px.b) / 3;
        if(grayScale > 128){
          // 見つめてる
          return true;
        }else{
          // 見つめてない
          return true;
        }
      }
    }
    return false;
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