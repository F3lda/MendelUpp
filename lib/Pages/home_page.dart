import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mendelupp/Services/app_config_service.dart';

import 'package:mendelupp/WebViewRequest/webview_open_map.dart';
import 'package:mendelupp/WebViewRequest/webview_open_menza.dart';
import 'package:mendelupp/WebViewRequest/webview_open_student.dart';
import 'package:mendelupp/Services/localization_service.dart';
import 'package:mendelupp/main.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mendelupp/Menus/main_popup_menu.dart';

import 'package:flutter/foundation.dart';

import '../Common/utils.dart';
import '../WebViewGuest/webview_guest_menza.dart';
import '../WebViewGuest/webview_guest_student.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String loggedInUsername = "";

  Future<void> onLoggedIn() async {
    const storage = FlutterSecureStorage();

    print("START");
    loggedInUsername = (await storage.read(key: "Mfullname")) ?? "";
    print(loggedInUsername);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();



    onLoggedIn();
  }

  @override
  Widget build(BuildContext context) {//context.appConfigService.setPreference('app_version', '1.2.3');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //title: Text(widget.title),
        //title: Text('app.title'.tr(context)),
        title: Text(context.tr('app.title')+' '+context.appConfigService.get('app_version')),
        actions: <Widget>[MainPopupMenu(onLoginStateChange: onLoggedIn, loggedInUsername: loggedInUsername)]
      ),
      body: SingleChildScrollView(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Center(child: Padding(padding: const EdgeInsets.symmetric(vertical:15, horizontal: 10), child: Column(children: [
              Text(
                (loggedInUsername != "") ? '$loggedInUsername, welcome!' : 'Welcome!', textAlign: TextAlign.center,
                //(loggedInUsername != "") ? '$loggedInUsername, vítejte!' : 'Vítejte!\nPřihlašte se do aplikace.', textAlign: TextAlign.center,
                style: const TextStyle(
                  //color: Colors.white,
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              if (loggedInUsername == "") Text(
                'Log in to the app to access the Student Portal and the Menza.', textAlign: TextAlign.center,
                //(loggedInUsername != "") ? '$loggedInUsername, vítejte!' : 'Vítejte!\nPřihlašte se do aplikace.', textAlign: TextAlign.center,
                style: const TextStyle(
                  //color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold
                ),
              ),
            ]),
            ),),

            if (loggedInUsername != "") CardButton(
              color: null,
              image: const AssetImage("assets/images/StudentPortal.png"),
              text: "Student Portal", onTap: () {
                if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                  // Some android/ios specific code
                  if (loggedInUsername == 'GUEST') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewGuestStudent())).then((value) {
                      setState(() {});
                    });
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewStudentPage())).then((value) {
                      setState(() {});
                    });
                  }
                }
              }
            ),

            if (loggedInUsername != "") CardButton(
              color: null,
              image: const AssetImage("assets/images/menza.jpg"),
              text: "Menza - ISKAM", onTap: () {
                if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                  // Some android/ios specific code
                  if (loggedInUsername == 'GUEST') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewGuestMenza())).then((value) {
                      setState(() {});
                    });
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewMenzaPage())).then((value) {
                      setState(() {});
                    });
                  }
                }
              }
            ),

            CardButton(
              color: null,
              image: const AssetImage("assets/images/MyMendelu-map.png"),
              text: "Map Widget", onTap: () {
                if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                  // Some android/ios specific code
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewMapPage())).then((value) {
                    setState(() {});
                  });
                }
              }
            ),

            CardButton(
              color: null,
              image: const AssetImage("assets/images/MojeMendelu.png"),
              text: "Moje MEMNDELU", onTap: () {
                launchInBrowser(context, Uri.parse("https://moje.mendelu.cz/"));
              }
            ),

            //CardButton(color: const Color(0xFF7abf17), image: null, text: "Moje MENDELU", onTap: () {}),

          ],
        ),
      )),
    );
  }
}



class CardButton extends StatefulWidget {
  const CardButton({super.key, required this.color, required this.image, required this.text, required this.onTap});

  final String text;
  final Color? color;
  final ImageProvider<Object>? image;
  final Function onTap;

  @override
  State<CardButton> createState() => _CardButtonState();
}

class _CardButtonState extends State<CardButton> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Ink(
        height: 100,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(color: Colors.grey.shade600,width:0.3),
          borderRadius: BorderRadius.circular(10),
          image: (widget.color == null && widget.image != null) ? DecorationImage(
            image: widget.image!,
            fit: BoxFit.cover,
          ) : null,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 8.0,
              spreadRadius: 4.0,
              offset: Offset(4.0, 4.0), // shadow direction: bottom right
            ),
          ],
        ),
        child: InkWell(
          onTap: () => widget.onTap(), // Handle your callback
          child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            margin: const EdgeInsets.all(10),
            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        )
      )
    );
  }
}
