// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../Common/change_notifiers.dart';

import 'package:http/http.dart' as http;

enum _MenuOptions {
themeMode,
}

class Menu2 extends StatefulWidget {
  const Menu2({super.key});


  @override
  State<Menu2> createState() => _MenuState2();
}

class _MenuState2 extends State<Menu2> {

  @override
  Widget build(BuildContext context) {
    return /*IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
          ),
          onPressed: () {
            // do something
          },
        )*/


      PopupMenuButton<_MenuOptions>(
      position: PopupMenuPosition.under,
      onSelected: (value) async {
        switch (value) {
          case _MenuOptions.themeMode:
            var notifyer = context.read<AppThemeChangeNotify>();
            notifyer.toggle();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.themeMode,
          child: Text('Light/Dark mode'),
        ),
      ],

    );
  }
}
