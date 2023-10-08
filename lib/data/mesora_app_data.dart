import 'package:mesora/data/character_data.dart';
import 'package:image/image.dart' as img;

// アプリデータ
class MesoraAppData{

  // 得点
  static final List<int> _scoreList = [];

  // エンカウントリスト
  static final List<CharacterData> encounterList = [];

  // ゲームの蒼エンカウント数
  static const int max_step = 4;

  // エンカウンター
  static int encounter = 0;

  // 抽出画像
  static List<img.Image?> imageLeft = [];
  static List<img.Image?> imageRight = [];

  // 初期化
  static void initialize(int length){
    encounter = 0;
    _scoreList.clear();
    encounterList.clear();
    for(int i = 0; i < length; i++){
      _scoreList.add(0);
    }
    imageLeft.clear();
    imageLeft = []..length = length;
    imageRight.clear();
    imageRight = []..length = length;
  }

  // スコア加算
  static void addScore(int index, int score){
    _scoreList[index] += score;
  }

  // スコア取得
  static int getScore(int index){
    if(index >= _scoreList.length){
      return -1;
    }
    return _scoreList[index];
  }

  static int getTotalScore(){
    int totalScore = 0;
    for (var score in _scoreList) {
      totalScore += score;
    }
    return totalScore;
  }

  static CharacterData getCurrentCharacterData(){
    var idx = MesoraAppData.encounter >= 4 ? 3 : MesoraAppData.encounter;
    return MesoraAppData.encounterList[idx];
  }

  static void setImageLeft(int index, img.Image? image) {
    imageLeft[index] = image;
  }

  static void setImageRight(int index, img.Image? image) {
    imageRight[index] = image;
  }
}