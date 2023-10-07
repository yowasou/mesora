import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
                      Center(
                          child:Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top:20),
                                child: Image.asset('assets/image/title.png', scale: 0.5),
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
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image:AssetImage('assets/image/scorebox.png'),
                                        ),
                                      ),
                                      width: 446,
                                      height: 120,
                                      child: Row(
                                        mainAxisAlignment:MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(right:20.0),
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
                                        padding: const EdgeInsets.only(right:20.0),
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
}
