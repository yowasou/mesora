class CharacterData{

  // イメージのアセットの名前
  String _imageAssetname = "";
  String get imageAssetname => _imageAssetname;

  // SEのアセットのフィックス
  String _seKeyNamePrefix = "";
  String get seKeyNamePrefix => _seKeyNamePrefix;

  // 眼の判定エリア 開始X座標
  int _areaX = 0;
  int get areaX => _areaX;

  // 眼の判定エリア 開始Y座標
  int _areaY = 0;
  int get areaY => _areaY;

  // 眼の判定エリア 幅
  int _areaWidth = 0;
  int get areaWidth => _areaWidth;

  // 眼の判定エリア 高さ
  int _areaHeight = 0;
  int get areaHeight => _areaHeight;

  // 眼の判定エリア 高さ
  bool _checkMode = true;
  bool get checkMode => _checkMode;

  CharacterData(this._imageAssetname, this._seKeyNamePrefix, this._areaX, this._areaY, this._areaWidth, this._areaHeight, this._checkMode);

}