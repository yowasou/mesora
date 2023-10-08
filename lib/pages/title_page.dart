import 'package:flutter/material.dart';

import '../AudioManager.dart';
import 'main_page.dart';

class TitlePage extends StatefulWidget {
  const TitlePage({super.key});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> with TickerProviderStateMixin {

  late final AnimationController _buttonAnimationController;
  late final Animation<double> _buttonAnimation;


  @override
  void initState() {
    super.initState();

    _buttonAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin:1.0, end:0.8).animate(_buttonAnimationController);
    _buttonAnimationController.addListener((){
      setState((){});
    });
    _buttonAnimationController.repeat();


    AudioManager.initialize().then((value){
      AudioManager.addBgmAsset("title", "audio/title.mp3");

      AudioManager.addSeAsset("man_001", "audio/man_001.mp3");
      AudioManager.addSeAsset("man_002", "audio/man_002.mp3");
      AudioManager.addSeAsset("man_003", "audio/man_003.mp3");
      AudioManager.addSeAsset("man_come", "audio/man_come.mp3");

      AudioManager.addSeAsset("woman_001", "audio/woman_001.mp3");
      AudioManager.addSeAsset("woman_002", "audio/woman_002.mp3");
      AudioManager.addSeAsset("woman_003", "audio/woman_003.mp3");
      AudioManager.addSeAsset("woman_come", "audio/woman_come.mp3");

      AudioManager.addSeAsset("interviewer_001", "audio/interview_001.mp3");
      AudioManager.addSeAsset("interviewer_002", "audio/interview_002.mp3");
      AudioManager.addSeAsset("interviewer_003", "audio/interview_003.mp3");
      AudioManager.addSeAsset("interviewer_come", "audio/interview_come.mp3");

      AudioManager.addSeAsset("yankee_001", "audio/yankee_001.mp3");
      AudioManager.addSeAsset("yankee_002", "audio/yankee_002.mp3");
      AudioManager.addSeAsset("yankee_003", "audio/yankee_003.mp3");
      AudioManager.addSeAsset("yankee_come", "audio/yankee_come.mp3");

      AudioManager.addSeAsset("finish", "audio/finish.mp3");
      AudioManager.addSeAsset("leave", "audio/leave.mp3");

      AudioManager.playBGM("title");
    });
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: SafeArea(
              child: Stack(
                  children:[
                    Image.asset('assets/image/background3.png'),
/*
                    Center(
                        child:Column(
                          children: [
                              Image.asset('assets/image/background2.png', width:double.infinity),
                          ],
                        )
                    ),
*/
                    Center(
                      child:Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top:200),
                              child: Image.asset('assets/image/title2.png', scale: 0.5),
                          ),
                        ],
                      )
                    ),

                    Center(
                      child:Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MaterialButton(
                            //child:Image.asset('assets/image/start_button.png', scale: _buttonAnimation.value),
                            child:Image.asset('assets/image/start_button.png', scale: 1.0),
                            onPressed: (){
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context)=> const MainPage()
                                  ),
                                  (route) => false
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ]
              )
          )
      )
    );
  }

}
