import 'package:audioplayers/audioplayers.dart';
import 'package:mesora/logger.dart';

class AudioManager{

  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sePlayer = AudioPlayer();

  static final Map<String, Source> _bgmMap = {};
  static final Map<String, Source> _seMap = {};

  static bool _isBgmPlay = false;
  static bool get isBgmPlay  => _isBgmPlay;

  static bool _isSePlay = false;
  static bool get isSePlay  => _isSePlay;

  static Future<void> initialize() async{
    await _bgmPlayer.setVolume(0.2);
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    //_bgmPlayer.onPlayerComplete
    //_sePlayer.onPlayerComplete

    _sePlayer.onPlayerComplete.listen((event) {
    });

    _sePlayer.onPlayerStateChanged.listen((state) {
      if(state == PlayerState.playing){
        _isSePlay = true;
      }else{
        _isSePlay = false;
      }
    });

    _bgmPlayer.onPlayerComplete.listen((event) {
    });

    _bgmPlayer.onPlayerStateChanged.listen((state) {
      if(state == PlayerState.playing){
        _isBgmPlay = true;
      }else{
        _isBgmPlay = false;
      }
    });
  }

  static void addSeAsset(String keyName, String assetName){
    Logger.info("addSeAsset keyName=$keyName / assetName=$assetName");
    _seMap[keyName] = AssetSource(assetName);
  }

  static void addBgmAsset(String keyName, String assetName) async{
    Logger.info("addBgmAsset keyName=$keyName / assetName=$assetName");
    _bgmMap[keyName] = AssetSource(assetName);

    /* これダメだった
    var data = await _bgmPlayer.audioCache.loadAsset(assetName);
    var buff = BytesSource(data.buffer.asUint8List());
    _bgmMap[keyName] = buff;
     */
  }

  static void playSE(String keyName){
    Logger.info("SE : $keyName");
    if(_seMap.containsKey(keyName)){
      _sePlayer.play(_seMap[keyName]!);
    }else{
      Logger.info("SE : $keyName not found");
    }
  }

  static void playBGM(String keyName){
    Logger.info("BGM : $keyName");
    _bgmPlayer.play(_bgmMap[keyName]!);
  }

  static void stopBGM(){
    _bgmPlayer.stop();
  }

}
