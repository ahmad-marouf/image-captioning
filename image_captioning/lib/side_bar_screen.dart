import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_captioning/IntroScreen.dart';
import 'package:image_captioning/slideAnimation.dart';

class SideBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // backgroundColor: Colors.white,
      child: ListView(
        children: [
          const Image(
              image: NetworkImage('https://imgs.search.brave.com/kAdF216PFQuQqFvPcNzPz-IyjvlNg-H01bwXFNIDoKY/rs:fit:1337:225:1/g:ce/aHR0cHM6Ly90c2Uz/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5v/aGZwT3JFY2c3SUV6/QkVkcFdPU2ZBSGFD/byZwaWQ9QXBp'),
            fit: BoxFit.cover,
          ),
          ListTile(
            leading: const Icon(
                Icons.home
            ),
            title: const Text(
              'About Us',
            ),
            onTap: (){},
          ),
          ListTile(
            leading: const Icon(
              Icons.info,
            ),
            title: const Text(
              'App guide'
            ),
            onTap: (){Navigator.of(context).push(
                SlideAnimation(
                    page: const IntroScreen(),
                    beginX: -1)
            );
              },
          ),
          /*ListTile(
            leading: Icon(
              Icons.settings,
            ),
            title: Text(
              'Settings',
            ),
            onTap: (){},
          ),*/
          ListTile(
            leading: const Icon(
                Icons.people
            ),
            title: const Text(
              'Contact us',
            ),
            onTap: (){},
          ),
          /*ListTile(
            leading: Icon(
              Icons.exit_to_app,
            ),
            title: Text(
              'Exit',
            ),
            onTap: (){
              exit(0);
            },
          ),*/
        ],
      ),
    );
  }
}