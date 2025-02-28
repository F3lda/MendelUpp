import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mendelupp/Common/change_notifiers.dart';
import 'package:mendelupp/WebViewLogin/webview_login_page.dart';
import 'package:mendelupp/WebViewRequest/webview_open_map.dart';
import 'package:mendelupp/WebViewRequest/webview_open_menza.dart';
import 'package:mendelupp/WebViewRequest/webview_open_student.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'web_view_test_page.dart';
import 'package:mendelupp/Menus/main_menu.dart';

import 'package:flutter/foundation.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.callback});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  final void Function() callback;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String loggedin = "";

  int _counter = 0;

  Future<void> onLoggedIn() async {
    const storage = FlutterSecureStorage();

    print("START");
    loggedin = (await storage.read(key: "Mfullname")) ?? "";
    print(loggedin);
    setState(() {});
  }


  @override
  void initState() {
    super.initState();

    onLoggedIn();
  }



  void _incrementCounter(BuildContext context) {
    var counter = context.read<Counter>();
    counter.increment();
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result)  async {
        if (didPop) {
          var counter = context.read<PageLevelCounter>();
          if (counter.getValue() != 0) {
            counter.decrement();
          }
        } else {
          _showToast(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: <Widget>[Menu2()]
        ),
        body: SingleChildScrollView(child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: Padding(padding: const EdgeInsets.symmetric(vertical:15, horizontal: 10), child: Text(
          (loggedin != "") ? '$loggedin, vítejte!' : 'Vítejte!\nPřihlašte se do aplikace.', textAlign: TextAlign.center,
                style: const TextStyle(
                  //color: Colors.white,
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              ),
              ),
              /*const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Consumer<Counter>(
                builder: (context, counter, child) => Text(
                  '${counter.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 10),
              Consumer<PageLevelCounter>(
                builder: (context, counter, child) => Text(
                  '${counter.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _showToast(context),
                child: const Text('Show toast'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {var counter = context.read<PageLevelCounter>();
                  counter.increment();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "Page ${counter.getValue()}", callback: widget.callback,)));},
                child: const Text('NextPage'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  var counter = context.read<PageLevelCounter>();
                  if (counter.getValue() != 0) {
                    //counter.decrement();
                    Navigator.pop(context);
                  }
                  if (counter.getValue() != 0) {
                    //counter.decrement();
                    Navigator.pop(context);
                  }},
                child: const Text('Back'),
              ),*/
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                    // Some android/ios specific code
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewLoginPage())).then((value) async {
                      onLoggedIn();
                    });
                  }
                },
                child: const Text('Login Mendelu'),
              ),
              ElevatedButton(
                onPressed: () async {
                  const storage = FlutterSecureStorage();
                  await storage.write(key: "Mfullname", value: "");
                  await storage.write(key: "Musername", value: "");
                  await storage.write(key: "Mpassword", value: "");
                  onLoggedIn();
                },
                child: const Text('Logout'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                    // Some android/ios specific code
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewMenzaPage())).then((value) {
                      setState(() {});
                    });
                  }
                },
                child: const Text('Show Menza'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                    // Some android/ios specific code
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewStudentPage())).then((value) {
                      setState(() {});
                    });
                  }
                },
                child: const Text('Show Student Portal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                    // Some android/ios specific code
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewMapPage())).then((value) {
                      setState(() {});
                    });
                  }
                },
                child: const Text('Show Map Widget'),
              ),
              ElevatedButton(
                onPressed: () {
                  /*if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                    // Some android/ios specific code
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewMapPage())).then((value) {
                      setState(() {});
                    });
                  }*/
                  _launchInBrowser(Uri.parse("https://moje.mendelu.cz/"));
                },
                child: const Text('Open Moje Mendelu'),
              ),




              CardButton(
                  color: null,
                  image: const AssetImage("assets/images/StudentPortal.png"),
                  text: "Student Portal", onTap: () {}),

              CardButton(
                  color: null,
                  image: const AssetImage("assets/images/menza.jpg"),
                 text: "Menza - ISKAM", onTap: () {}),

              CardButton(
                  color: null,
                  image: const AssetImage("assets/images/MyMendelu-map.png"),
                  text: "Map Widget", onTap: () {}),

              CardButton(
                  color: null,
                  image: const AssetImage("assets/images/MojeMendelu.png"),
                  text: "Moje MEMNDELU", onTap: () {}),

              //CardButton(color: const Color(0xFF7abf17), image: null, text: "Moje MENDELU", onTap: () {}),






            ],
          ),
        )),

        /*floatingActionButton: FloatingActionButton(
          onPressed: () => _incrementCounter(context),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),*/ // This trailing comma makes auto-formatting nicer for build methods.
      )
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Added to favorite'),
        action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
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
          /* foregroundDecoration: BoxDecoration(
    color: Colors.grey,
    backgroundBlendMode: BlendMode.saturation,
  ),*/
          //color: const Color(0xFF7abf17),
            height: 100,
            width: double.maxFinite,
            //margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color,
              //color: const Color(0xFF7abf17),
              //border: Border.all(color: Colors.white),
              border: Border.all(color: Colors.grey.shade600,width:0.3),
              borderRadius: BorderRadius.circular(10),
              image: (widget.color == null && widget.image != null) ? DecorationImage(
                    image: widget.image!,

                        /*NetworkImage("https://www.smsticket.cz/cdn/events/2015/5056-absolventsky-networking-pefkaru/315.jpg"),*/
                    fit: BoxFit.cover,
                  ) : null,

              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 8.0,
                  spreadRadius: 4.0,
                  offset: Offset(4.0, 4.0), // shadow direction: bottom right
                ),
              ],
            ),
            child: InkWell(
              onTap: () => widget.onTap, // Handle your callback
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    widget.text,
                    //"Menza - ISKAM",
                    style: TextStyle(
                        fontSize: 32,
                        //color: const Color(0xff96f11b),
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                elevation: 3,
                margin: EdgeInsets.all(10),
              ),
            )))
    ;
  }
}
