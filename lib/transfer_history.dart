// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_final_fields

import 'package:orientation/orientation.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';


class TransferHistory extends StatefulWidget {
  const TransferHistory({Key? key}) : super(key: key);

  @override
  _TransferHistoryState createState() => _TransferHistoryState();
}

class _TransferHistoryState extends State<TransferHistory> {
  bool first = true;

  int id = 0;

  Map assetMap = {};

  List logList = [];

  getAsset() {
    Object? object = ModalRoute.of(context)!.settings.arguments;
    if(object != null){
      setState(() {
        assetMap = object as Map;
        id = assetMap['id'];
      });
    }
  }

  getTransferHistory() async{
    var response = await http.post(
      Uri.parse("http://10.0.2.2:5000/asset/GetLogs"),
      headers: {"content-type":"application/json"},
      body: json.encode({
        "id": id
      })
    );
    if(response.statusCode == 200){
      setState(() {
        logList = json.decode(response.body);
      });
      // print('日志：$logList');
    }
  }

  @override
  void initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
  }

  @override
  Widget build(BuildContext context) {
    if(first){
      getAsset();
      getTransferHistory();
      first == false;
    }

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
          child: Column(
            children: [
              //Transfer History
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 15,top: 15),
                child: Text("Transfer History",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),

              //资产转移记录 => ListView.builder
              Visibility(
                child: Container(
                  height: 270,
                  margin: EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    itemCount: logList.length,
                    itemBuilder: (context,index){
                      return Container(
                        height: 90,
                        margin: EdgeInsets.only(left: 10),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment(-1,-0.5),
                              child: Container(
                                width: 40,
                                height: 40,
                                child: Image.asset("images/plane.PNG",fit: BoxFit.fill),
                              ),
                            ),

                            Align(
                              alignment: Alignment(-0.6,0),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Relocation date
                                    Container(
                                      width: 500,
                                      child: Row(
                                        children: [
                                          Text("Relocation date: ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          Text("${logList[index]['transferDate']}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    //Center Office
                                    Container(
                                      width: 500,
                                      child: Row(
                                        children: [
                                          Text("Center Office: ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          Text("${logList[index]['fromAssetSn']}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff9e6b6c),
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    //Yelabuga
                                    Container(
                                      width: 500,
                                      child: Row(
                                        children: [
                                          Text("Yelabuga: ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          Text("${logList[index]['toAssetSn']}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff9e6b6c),
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    shrinkWrap: true,
                  ),
                ),
                visible: logList.isNotEmpty ? true : false,
              ),

              //暂无资产转移记录
              Visibility(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 100),
                  child: Text("暂无资产转移记录",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.red
                    ),
                  ),
                ),
                visible: logList.isNotEmpty ? false : true,
              ),

              //Back
              Spacer(),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 20,bottom: 10),
                child: Container(
                  width: 180,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xffe9e9e9),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 2,
                      color: Colors.black
                    )
                  ),
                  child: MaterialButton(
                    onPressed: (){
                      Navigator.pop(context);
                      //竖屏
                      OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text("Back",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
