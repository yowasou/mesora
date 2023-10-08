import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:mesora/pages/title_page.dart';

import '../Data/mesora_app_data.dart';

// 結果画面
class ResultPage extends StatefulWidget {
  const ResultPage({super.key});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  @override
  Widget build(BuildContext context) {
    var score = MesoraAppData.getTotalScore();
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: SafeArea(
                child: Stack(
                    children:[
                      Image.asset('assets/image/background4.png'),
                      Center(
                          child:Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top:20),
                                child: Image.asset('assets/image/title2.png', scale: 0.5),
                              ),
                            ],
                          )
                      ),

                      Center(
                        child:Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                for(int i = 0; i < MesoraAppData.max_step; i++) ... {
                                  Container(
                                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image:AssetImage("assets/image/scorebox${i+1}.png"),
                                        ),
                                      ),
                                      width: 446,
                                      height: 120,
                                      child: Stack(
                                        children: [
                                          Row(
                                            mainAxisAlignment:MainAxisAlignment.end,
                                            children: [
                                              Container(
                                            padding: const EdgeInsets.only(right:48.0, bottom: 8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "${MesoraAppData.getScore(i)}",
                                                      style: const TextStyle(
                                                        fontSize: 60,
                                                      )
                                                    )
                                                  ]
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _buildImageLeft(i),
                                              _buildImageRiget(i),
                                            ],
                                          ),
                                        ],
                                      ),
                                  )
                                },
                                Container(
                                  padding: const EdgeInsets.only(right: 16, bottom: 16),
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image:AssetImage('assets/image/scoretotalbox.png'),
                                    ),
                                  ),
                                  width: 446,
                                  height: 120,
                                  child: Row(
                                    mainAxisAlignment:MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(right:48.0, bottom: 8.0),
                                        child: Row(
                                            children: [
                                              Text(
                                                  "${MesoraAppData.getTotalScore()}",
                                                  style: const TextStyle(
                                                    fontSize: 60,
                                                  )
                                              )
                                            ]
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),

                      Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 48.0),
                          child: MaterialButton(
                              child:Image.asset('assets/image/end_button.png'),
                              onPressed: (){
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context)=> const TitlePage()
                                    ),
                                        (route) => false
                                );
                              },
                          )
                      ),

                    ]
                )
            )
        )
    );
  }

  // 画像表示(左目)
  Widget _buildImageLeft(int index) {
    var image;
    if (MesoraAppData.imageLeft[index] != null) {
      image = Image.memory(
        img.encodeJpg(MesoraAppData.imageLeft[index]!).buffer.asUint8List()
      );
    } else {
      image = Container();
    }
    return Container(
      margin: EdgeInsets.only(left: 15, top: 5, right: 15),
      padding: EdgeInsets.all(2),
      width: 120,
      child: image,
    );
  }

  // 画像表示(右目)
  Widget _buildImageRiget(int index) {
    var image;
    if (MesoraAppData.imageRight[index] != null) {
      image = Image.memory(
        img.encodeJpg(MesoraAppData.imageRight[index]!).buffer.asUint8List()
      );
    } else {
      image = Container();
    }
    return Container(
      margin: EdgeInsets.only(left: 15, top: 5, right: 15),
      padding: EdgeInsets.all(2),
      width: 120,
      child: image,
    );
  }
}
