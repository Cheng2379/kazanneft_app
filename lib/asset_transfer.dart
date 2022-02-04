// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_final_fields

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:orientation/orientation.dart';

class AssetTransfer extends StatefulWidget {
  const AssetTransfer({Key? key}) : super(key: key);

  @override
  _AssetTransferState createState() => _AssetTransferState();
}

class _AssetTransferState extends State<AssetTransfer> {

  bool first = true;

  String department = "Destination";
  String location = "Destination";
  String dd = "??/";
  String gg = "gg/";
  String nnnn = "????";
  String assetSN = "??/gg/????";

  int departmentId = 0;
  int assetGroupId = 0;
  int locationId = 0;
  int departmentLocationId = 0;

  List departmentHttpList = [];
  List locationHttpList = [];

  Map assetMap = {};

  getAsset() {
    Object? object = ModalRoute.of(context)!.settings.arguments;
    if (object != null) {
      assetMap = object as Map;
      print('assetMap: $assetMap');
      assetSN = assetMap['assetSn'];
      assetGroupId = assetMap['assetGroupId'];
      departmentLocationId = assetMap['departmentLocationId'];

      List<String> asset = assetSN.split("/");
      gg = "${asset[1]}/";
      nnnn = asset[2];
      assetSN = dd + gg + nnnn;
    }
  }

  getDepartment() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/Department"));
    if (response.statusCode == 200) {
      departmentHttpList = json.decode(response.body);
    } else {
      departmentHttpList = [];
    }
  }

  getLocation() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/Locations"));
    if (response.statusCode == 200) {
      locationHttpList = json.decode(response.body);
    } else {
      locationHttpList = [];
    }
  }

  @override
  void initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
  }

  @override
  Widget build(BuildContext context) {
    if (first) {
      getAsset();
      getDepartment();
      getLocation();
      first = false;
    }
    print('DepartmentId: $departmentId');

    return Scaffold(
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Color(0xff3f3f3f),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              //Asset Transfer
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 60,
                color: Color(0xff444444),
                margin: EdgeInsets.only(top: 1),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment(-0.8, 0),
                      child: Text("Asset Transfer",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0.75, 0),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Text("Back",
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xffd6e042)
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              //Select Asset
              Container(
                margin: EdgeInsets.only(top: 45, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Selected Asset
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text("Selected Asset",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),

                    Container(
                      height: 2,
                      color: Color(0xffadadad),
                      margin: EdgeInsets.only(top: 10),
                    )
                  ],
                ),
              ),

              //AssetName,CurrentDepartment
              //AssetSN
              Container(
                height: 270,
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Stack(
                  children: [
                    //Asset Name
                    Align(
                      alignment: Alignment(-1, -0.9),
                      child: Container(
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text("Asset Name:",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            Container(
                              width: 170,
                              margin: EdgeInsets.only(top: 20),
                              child: Text(assetMap['assetName'],
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            Container(
                              width: 170,
                              height: 2,
                              color: Colors.black,
                              margin: EdgeInsets.only(top: 10),
                            )
                          ],
                        ),
                      ),
                    ),

                    //Current Department
                    Align(
                      alignment: Alignment(0.9, -0.9),
                      child: Container(
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text("Current Department:",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Text(assetMap['departmentsName'],
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            Container(
                              width: 170,
                              height: 2,
                              color: Colors.black,
                              margin: EdgeInsets.only(top: 10),
                            )
                          ],
                        ),
                      ),
                    ),

                    //Asset SN
                    Align(
                      alignment: Alignment(-1, 0.5),
                      child: Container(
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text("Asset SN:",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Text(assetMap['assetSn'],
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            Container(
                              width: 170,
                              height: 2,
                              color: Colors.black,
                              margin: EdgeInsets.only(top: 10),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Destination Department
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text("Destination Department",
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                    ),

                    Container(
                      height: 2,
                      color: Color(0xffadadad),
                      margin: EdgeInsets.only(top: 10),
                    )
                  ],
                ),
              ),

              //Department Location
              Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                height: 200,
                child: Stack(
                  children: [
                    //Department
                    Align(
                        alignment: Alignment(-1, -1),
                        child: Container(
                          width: 205,
                          height: 50,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment(-1, 0),
                                child: Text(department,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),

                              Align(
                                alignment: Alignment(0.5, 0),
                                child: Text("Department",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),

                              Align(
                                alignment: Alignment(1, 0),
                                child: PopupMenuButton(
                                  itemBuilder: (context) =>
                                      List.generate(
                                          departmentHttpList.length,
                                              (index) =>
                                              PopupMenuItem(
                                                child: Text(
                                                    departmentHttpList[index]['name']),
                                                value: departmentHttpList[index],
                                              )
                                      ),
                                  icon: Icon(Icons.arrow_drop_down, size: 35,),
                                  onSelected: (value) {
                                    Map map = value as Map;
                                    setState(() {
                                      department = map['name'];
                                      departmentId = map['id'];
                                      if (departmentId > 0 &&
                                          departmentId < 10) {
                                        dd = "0$departmentId/";
                                      } else if (departmentId >= 10) {
                                        dd = "$departmentId/";
                                      } else {
                                        dd = "??/";
                                      }
                                      assetSN = "$dd$gg$nnnn";
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                    ),

                    //Location
                    Align(
                        alignment: Alignment(1, -1),
                        child: Container(
                          width: 205,
                          height: 50,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment(-1, 0),
                                child: Text(location,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),

                              Align(
                                alignment: Alignment(0.5, 0),
                                child: Text("Location",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),

                              Align(
                                alignment: Alignment(1, 0),
                                child: PopupMenuButton(
                                  itemBuilder: (context) =>
                                      List.generate(
                                          locationHttpList.length,
                                              (index) =>
                                              PopupMenuItem(
                                                child: Text(
                                                    locationHttpList[index]['name']),
                                                value: locationHttpList[index],
                                              )
                                      ),
                                  icon: Icon(Icons.arrow_drop_down, size: 35,),
                                  onSelected: (value) {
                                    Map map = value as Map;
                                    setState(() {
                                      location = map['name'];
                                      locationId = map['id'];
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                    ),

                    Align(
                      alignment: Alignment(-1, -0.5),
                      child: Container(
                        width: 190,
                        height: 2,
                        color: Colors.black,
                      ),
                    ),

                    Align(
                      alignment: Alignment(0.9, -0.5),
                      child: Container(
                        width: 195,
                        height: 2,
                        color: Colors.black,
                      ),
                    ),

                    //New Asset SN
                    Align(
                      alignment: Alignment(-1, -0.1),
                      child: Text("New/Asset SN:",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    Align(
                      alignment: Alignment(-1, 0.5),
                      child: Text(assetSN,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                    Align(
                      alignment: Alignment(-1, 0.7),
                      child: Container(
                        width: 195,
                        height: 2,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              //Submit Cancel
              Spacer(),
              Container(
                alignment: Alignment.centerRight,
                height: 70,
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          submit();
                        },
                        child: Text("Submit",
                          style: TextStyle(fontSize: 18,
                              color: Color(0xff5daeab)),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel",
                          style: TextStyle(fontSize: 18,
                              color: Color(0xff5daeab)),
                        ),
                      )
                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  submit() async{
    if (departmentId == 0) {
      Fluttertoast.showToast(msg: "请选择您要转移的部门");
    } else if (locationId == 0) {
      Fluttertoast.showToast(msg: "请选择您要转移的地址");
    } else if (departmentId == assetMap['departmentsId']) {
      Fluttertoast.showToast(msg: "请选择新的部门");
    } else if(locationId == assetMap['locationsId']){
      Fluttertoast.showToast(msg: "请选择新的地址");
    } else{
      var response = await http.post(
          Uri.parse("http://10.0.2.2:5000/asset/AssetsTransfer"),
          headers: {"content-type": "application/json"},
          body: json.encode({
            "assetId": assetMap['id'],
            "fromAssetSN": assetMap['assetSn'],
            "ToAssetSN": assetSN,
            "fromDepartmentLocationID": departmentLocationId
          })
      );
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "资产转移成功！");
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "转移失败");
      }
    }
  }

}
