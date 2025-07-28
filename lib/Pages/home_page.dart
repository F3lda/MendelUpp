import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mendelupp/Services/config_service.dart';

import 'package:mendelupp/WebViewRequest/webview_open_map.dart';
import 'package:mendelupp/WebViewRequest/webview_open_menza.dart';
import 'package:mendelupp/WebViewRequest/webview_open_student.dart';
import 'package:mendelupp/Services/localization_service.dart';
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
    print("START");
    const storage = FlutterSecureStorage();
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
  Widget build(BuildContext context) {
    Color appColor = Color(int.tryParse(context.appConfigService.get<String>('app_color')) ?? 0);
    return Scaffold(
      appBar: AppBar(
        // use this when loading other pages (Theme.of(context).colorScheme is already loaded)
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // use this when loading first page (Theme.of(context).colorScheme is not fully loaded)
        backgroundColor: (Theme.of(context).colorScheme.inversePrimary != ColorScheme.fromSeed(seedColor: appColor).inversePrimary
          && Theme.of(context).colorScheme.inversePrimary != ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: appColor).inversePrimary)
            ? (MediaQuery.of(context).platformBrightness == Brightness.light
              ? ColorScheme.fromSeed(seedColor: appColor).inversePrimary
              : ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: appColor).inversePrimary)
            : Theme.of(context).colorScheme.inversePrimary,
        title: Text(context.tr('app.title')),
        actions: <Widget>[MainPopupMenu(onLoginStateChange: onLoggedIn, loggedInUsername: loggedInUsername)]
      ),
      body: SingleChildScrollView(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Center(child: Padding(padding: const EdgeInsets.symmetric(vertical:15, horizontal: 10), child: Column(children: [
              Text(
                (loggedInUsername != "") ? context.tr('home_page.greeting', params: {'name' : loggedInUsername}) : context.tr('home_page.welcome'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  //color: Colors.white,
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              if (loggedInUsername == "") Text(
                context.tr('home_page.message'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  //color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold
                ),
              ),
            ]),),),

            if (loggedInUsername != "") CardButton(
              color: null,
              image: AssetImage(context.appConfigService.get('student_portal_img')),
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
              image: AssetImage(context.appConfigService.get('menza_iskam_img')),
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
              image: AssetImage(context.appConfigService.get('map_widget_img')),
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
              image: AssetImage(context.appConfigService.get('moje_mendelu_img')),
              text: "Moje MEMNDELU", onTap: () {
                launchInBrowser(context, Uri.parse(context.appConfigService.get('moje_mendelu_url')));
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
