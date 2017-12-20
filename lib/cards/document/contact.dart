import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:share/share.dart' as share;
import 'package:image_picker/image_picker.dart';
import 'package:zoomable_image/zoomable_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase.dart' as firebase;

/// A Material Card with a contact's info
class ContactInfoCard extends StatelessWidget {
  final DocumentSnapshot contactData;

  ContactInfoCard(this.contactData);

  Future<Null> goPhotos() async {
    File imageFile = await ImagePicker.pickImage();
    firebase.uploadPhoto(imageFile).then((String url) async {
      Map<String, dynamic> newData = new Map<String, dynamic>.from(contactData.data);
      newData["photo"] = url;
      await contactData.reference.setData(newData);
    });
  }

  void goShare(){
    String shareString = "${contactData["name"]}";
    if (contactData["phone"] != null){
      shareString += "\n${contactData["phone"]}";
    }
    if (contactData["email"] != null)
      shareString += "\n${contactData["email"]}";
    share.share(shareString);
  }

  List<Widget> buildChildren(BuildContext context){
    Color color;
    List<Widget> children = <Widget>[];
    children.add(
      new Container( // Future: Make this a sliver
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: (){
                if (contactData["photo"] != null){
                  color = Colors.white;
                  return new GestureDetector(
                    child: new Image.network(contactData["photo"], fit: BoxFit.fitWidth),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        child: new ZoomableImage(
                          new NetworkImage(contactData["photo"]),
                          scale: 10.0,
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                } else {
                  color = Colors.black;
                  return new IconButton(
                    icon: new Icon(Icons.add_a_photo),
                    onPressed: goPhotos,
                  );
                }
              }()
            ),
            new Positioned(
              left: 8.0,
              bottom: 16.0,
              child: new Text(
                contactData["name"],
                style: new TextStyle(
                  color: color,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            new Positioned(
              right: 8.0,
              top: 8.0,
              child: new IconButton(
                icon: new Icon(Icons.share, color: color),
                iconSize: 36.0,
                onPressed: goShare,
              ),
            ),
          ],
        )
      ),
    );
    if (contactData["company"] != null){
      children.add(
        new ListTile(
          leading: new Icon(Icons.business),
          title: new Text(contactData["company"]),
        ),
      );
    }
    children.add(new Divider());
    if (contactData["phone"] != null){
      children.add(
        new ListTile(
          title: new Text(contactData["phone"]),
          trailing: new Row(
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.message),
                onPressed: (){
                  url_launcher.launch('sms:${contactData["phone"]}');
                },
              ),
              new IconButton(
                icon: new Icon(Icons.call),
                onPressed: (){
                  url_launcher.launch('tel:${contactData["phone"]}');
                },
              ),
            ],
          ),
        ),
      );
    }
    if (contactData["email"] != null){
      children.add(
        new ListTile(
          title: new Text(contactData["email"]),
          trailing: new IconButton(
            icon: new Icon(Icons.mail),
            onPressed: (){
              url_launcher.launch('mailto:${contactData["email"]}');
            },
          ),
        ),
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        children: buildChildren(context),
      ),
    );
  }
}