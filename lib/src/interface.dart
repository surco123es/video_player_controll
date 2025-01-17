import 'package:flutter/material.dart';

//Controll button theme
class ThemeControllData {
  Color colorButtonIcon, activeColorVolumen, colorVolumen, colorVolumenThumb;
  Duration transitionDuration;
  double iconSize,
      seekBarHeigth,
      seekBarHeigthHover,
      paddingResolution,
      subPaddingResolution;
  EdgeInsets paddingButtonIcon;
  BoxDecoration barControll,
      resolutionDecoration,
      subResolutionDecoration,
      subResolutionDecorationItem,
      activeItemListMenu,
      activeItemMenu;
  TextStyle resolutionStyleText, resolutionStyleTextItems, activeItemMenuText;
  ThemeControllData({
    this.colorButtonIcon = Colors.white,
    this.activeColorVolumen = Colors.orange,
    this.colorVolumenThumb = Colors.orangeAccent,
    this.colorVolumen = Colors.white,
    this.iconSize = 18,
    this.seekBarHeigth = 4,
    this.seekBarHeigthHover = 6,
    this.paddingResolution = 5,
    this.subPaddingResolution = 5,
    this.resolutionStyleText = const TextStyle(
      color: Colors.white,
      fontSize: 18,
    ),
    this.activeItemMenuText = const TextStyle(
        fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
    this.resolutionStyleTextItems = const TextStyle(
      color: Colors.white,
    ),
    this.barControll = const BoxDecoration(
      color: Color.fromARGB(82, 0, 0, 0),
    ),
    this.subResolutionDecoration = const BoxDecoration(
      color: Color.fromARGB(97, 0, 0, 0),
    ),
    this.activeItemMenu = const BoxDecoration(
      color: Color.fromARGB(255, 255, 125, 3),
    ),
    this.activeItemListMenu = const BoxDecoration(
      color: Color.fromARGB(255, 162, 0, 255),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    this.subResolutionDecorationItem = const BoxDecoration(),
    this.resolutionDecoration = const BoxDecoration(
      color: Color.fromARGB(169, 0, 0, 0),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          color: Colors.black,
          blurStyle: BlurStyle.outer,
        )
      ],
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    this.paddingButtonIcon = const EdgeInsets.all(5),
    this.transitionDuration = const Duration(milliseconds: 500),
  });
}

typedef getToken = Function(int token);
