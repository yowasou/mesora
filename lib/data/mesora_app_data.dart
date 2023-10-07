import 'package:mesora/data/character_data.dart';

class MesoraAppData{

  // 得点
  static final List<int> _scoreList = [];

  // エンカウントリスト
  static final List<CharacterData> encounterList = [];

  static const int max_step = 4;

  static int encounter = 0;

  static void initialize(int length){
    encounter = 0;
    _scoreList.clear();
    encounterList.clear();
    for(int i = 0; i < length; i++){
      _scoreList.add(0);
    }
  }

  static void addScore(int index, int score){
    _scoreList[index] += score;
  }

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


}