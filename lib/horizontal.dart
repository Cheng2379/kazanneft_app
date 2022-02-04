// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:orientation/orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Horizontal extends StatefulWidget {
  const Horizontal({Key? key}) : super(key: key);

  @override
  _HorizontalState createState() => _HorizontalState();
}

class _HorizontalState extends State<Horizontal> {
  bool first = false;

  List assetList = [];

  getAsset(){
    Object? object = ModalRoute.of(context)!.settings.arguments;
    if(object != null){
      print("object: $object");
      assetList = json.decode(json.encode(object));
    }
  }

  portrait(){
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        print("已竖屏");
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
  }

  @override
  Widget build(BuildContext context) {
    if(first){
      first = false;
    }
    getAsset();
    print("assetList: $assetList");

    portrait();
    return Scaffold(
      //拒绝在appBar后面拓展Body
      extendBodyBehindAppBar: false,
      //防止键盘从底部插入
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Color(0xff3f3f3f),
      ),

      body: Container(
        child: Column(
          children: [

            //Your assets
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                left: 15,
                top: 15
              ),
              child: Text("Your assets:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            //ListView
            Container(
              width: MediaQuery.of(context).size.width,
              height: 260,
              margin: EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: assetList.length,
                itemBuilder: (context,index){
                  return Container(
                    height: 90,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment(-1,0),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: Image.asset("images/title.PNG",fit: BoxFit.fill),
                          ),
                        ),

                        Align(
                          alignment: Alignment(-0.7,0),
                          child: Container(
                            width: 350,
                            alignment: Alignment.centerLeft,
                            child: Text(assetList[index]["assetName"],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment(0.25,0),
                          child:  Container(
                            child: Text(assetList[index]["assetSn"],
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xffd56d65)
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment(0.95,0),
                          child: Container(
                            width: 30,
                            height: 30,
                            child: Image.asset("images/edit.PNG",fit: BoxFit.fill),
                          ),
                        )
                      ],
                    ),
                  );
                  },

              ),
            ),

            //注册资产
            Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.only(right: 10),
              child: InkWell(
                child: Container(
                  width: 80,
                  height: 80,
                  child: Image.asset("images/add.PNG",fit: BoxFit.fill),
                ),
                onTap: (){

                },
              ),
            )

          ],
        ),
      ),
    );
  }
}


