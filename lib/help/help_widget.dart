import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '/auth/firebase_auth/auth_util.dart';
// import '/backend/backend.dart';
// import '/backend/firebase_storage/storage.dart';
import '../index.dart';
import '../localDB.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'help_model.dart';
import '../../appwrite_interface.dart';
import 'package:appwrite/models.dart' as models;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../conditional.dart';
export 'help_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '/../custom_code/widgets/toast.dart';
// import '../../map_display/map_display_widget.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../paypal/paypal_widget.dart';

class HelpWidget extends StatefulWidget {
  const HelpWidget({super.key});

  @override
  _HelpWidgetState createState() => _HelpWidgetState();
}

class _HelpWidgetState extends State<HelpWidget> {
  late HelpModel _model;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // late VideoPlayerController videoPlayercontroller;
  bool videoIsInitialized = false;
  AnimatedTextController? animatedTextController;

  /* Future<void> initVideo() async {
    videoIsInitialized = false;
    videoPlayercontroller = await VideoPlayerController.networkUrl(Uri.parse(
        // 'https://tin.syi.mybluehost.me/images/woodland7.mp4',
        // 'https://fra.cloud.appwrite.io/v1/storage/buckets/6976480a000f753c7f66/files/69764845002270220aa0/view?project=696ddda6001b28f2352e&mode=admin',
        'https://fra.cloud.appwrite.io/v1/storage/buckets/6976480a000f753c7f66/files/697b914d000bc9a390e2/view?project=696ddda6001b28f2352e&mode=admin'))
      ..initialize().then((_) {
        startupVideo();
        // video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    ;
    print(
        '(SA1) ${videoPlayercontroller!.value.isInitialized}++++${videoIsInitialized}');
    videoPlayercontroller!.setLooping(true);
    videoIsInitialized = true;
  }*/

/*
  Future<void> startupVideo() async {
    print(
        '(SA4) ${videoPlayercontroller!.value.isInitialized}++++${videoIsInitialized}');
    videoPlayercontroller!.setVolume(0);
    await videoPlayercontroller!.play();
    print(
        '(SA7) ${videoPlayercontroller!.value.isInitialized}++++${videoIsInitialized}');
    videoPlayercontroller!.setLooping(true);
  }
*/

  @override
  void initState() {
    print('(SA40)');
    super.initState();
    _model = createModel(context, () => HelpModel());
    animatedTextController = AnimatedTextController();
    // initVideo();
    _model.textController ??= TextEditingController(text: currentUserDisplayName);
    print('(SA41)');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await initVideo();
      print('(SA42)');

      setState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle kPanelTextStyleSmaller = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 18,
      /*shadows: <Shadow>[
        Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 3.0,
          color: Colors.grey,
        ),
        Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 8.0,
          color: Colors.grey,
        ),
      ],*/
      fontFamily: 'Rubik',
    );

    final TextStyle kPanelTextStyleLarger = TextStyle(
      color: Colors.amber,
      fontWeight: FontWeight.bold,
      fontSize: 32,
      shadows: <Shadow>[
        Shadow(
          offset: Offset(5.0, 5.0),
          blurRadius: 3.0,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        Shadow(
          offset: Offset(5.0, 5.0),
          blurRadius: 8.0,
          color: Color.fromARGB(125, 0, 0, 255),
        ),
      ],
      fontFamily: 'Rubik',
    );

    Widget svgLogo() {
      return SvgPicture.asset(
        'assets/images/paintbrush2.svg',
        width: 50,
        height: 50,
      );
    }

    const String helpAirStudio =

    '''An AIR (Art Intervention Recording) is a video of the artwork created by an Art Therapist's client together withv their responses to a series of questions.  AIR Studio is an app developed to allow Art Therapists to produce AIRs with the minimum of effort, handling all aspects of the creation of the desired video.
1. Start on the 'Login' page: click on 'Create account', enter your email address and a password.  You will be directed to the 'Profile' page where you should enter name (as you wish it to be displayed in the app).
2. On returning to the 'Login' page, enter your email adress and password, and click 'Login'.
3. You will enter the 'AIRs' page which will list all the AIRs you have worked on, with the most recent at the head of the list.
4. Before creating a new AIR, you will need to ensure that you have entered your client's name in the Client list.  Click on the 'Menu' button on the 'AIRs' page and select 'Clients'.
5. The 'Clients' page will show a list of your clients.  Additions can me made by clicking the 'Add client' button.  
6. To create a new AIR, click the 'Create AIR' button at the top of the page.  You will be asked to select a Template and a Client for this new AIR.  The template can either be predefined or user-generated (please see Step 16).
7. To start or continue the editin of an AIR, click on the 'Edit' button,  Which will take you to the 'Edit AIR' page.
8. Each AIR is composed of a series of steps, each step is labeled with a question (defined in the template chosen in the creation of the AIR)
9. For each step, take a photo of the client's artwork, ask the client the question amd click on the microphone icon to record their response.
10. Click the 'Select photo' button and choose the image from the phone's photo gallery.
11. You can click the 'Transcribe' button to see your client's words as text.  Please be aware that this may take some time.
12. You can also click the 'Edit recording' button if you wish to trim the audio recording.
13. On returning to the 'AIRs' page, you can click the 'Make video' button which will create a video from the recordings and images (this can take several minutes).
14. If the next button is labled 'Load video', then clicking it will show the created video in a pop-up window.
15. Clicking the final button in this list will result in an email being sent to your email address.  The video will include a link which, when click, will download the created video.
16. To create your own template, click on the 'Menu' button on the 'AIRs' page.  This will take you to the 'Templates' page which lists all the templates 


        ''';

    Widget showHelpTextWidget() {
      return Text(helpAirStudio,
        softWrap: true,
        style: kPanelTextStyleSmaller,
      );
    }

    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Air Studio Help',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Rubik',
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: showHelpTextWidget(),
          ),
        ));
  }
}
