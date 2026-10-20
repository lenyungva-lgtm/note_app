import 'package:flutter/material.dart';

Widget cardTargatAndSaving(
  IconData icon,
  String title,
  String value,
  Color color,
) {
  return Container(
    width: 190,
    height: 140,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(width: 2, color: Colors.grey.shade300),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(backgroundColor: color, child: Icon(icon)),
        Text(title, style: TextStyle(fontSize: 23)),
        Text(
          value,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
