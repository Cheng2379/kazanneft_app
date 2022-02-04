// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, unused_field, prefer_final_fields

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientation/orientation.dart';
import 'horizontal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_edit_asset.dart';
import 'asset_transfer.dart';
import 'transfer_history.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: Home()
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FocusNode _searchNode = FocusNode();
  var _searchText = TextEditingController();

  bool first = true;

  String department = "Department";
  String assetGroup = "Asset Group";
  String startDate = "Start date";
  String endDate = "End date";
  String text = "";

  int departmentId = 0;
  int assetGroupId = 0;

  Map assetMap = {};

  List assetList = [];
  List departmentHttpList = [];
  List assetGroupHttpList = [];

  getDepartment() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/Department"));
    if (response.statusCode == 200) {
      departmentHttpList.add({
        "id": 0,
        "name": "Department",
        "departmentLocations": []
      },);
      departmentHttpList.addAll(json.decode(response.body));
    } else {
      department = "Department";
      departmentHttpList = [];
    }
  }
  
  getAssetGroup() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/AssetGroup"));
    if(response.statusCode == 200){
      assetGroupHttpList.add({
        "id": 0,
        "name": "Asset Group",
        "assets": []
      },);
      assetGroupHttpList.addAll(json.decode(response.body));
    }else{
      assetGroup = "Asset Group";
      assetGroupHttpList = [];
    }
  }

  getAsset() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/Asset"));
    if (response.statusCode == 200) {
      setState(() {
        assetList = json.decode(response.body);
        print('已获取资产信息');
      });
     } else {
      assetList = [];
    }
  }

  postAsset() async {
    assetMap = {
      "DepartmentsName": department,
      "AssetGroupsName": assetGroup,
      "StartDate": startDate == "Start date" ? null:startDate,
      "EndDate": endDate == "End date" ? null:endDate
    };

    print("assetMap: $assetMap");
    var response = await http.post(
        Uri.parse("http://10.0.2.2:5000/asset/getAsset"),
        headers:{"content-type": "application/json"},
        body: json.encode(assetMap)
    );

    if(response.statusCode == 200){
      assetList = json.decode(response.body);
      print("assetList: $assetList");
    } else {
      assetList = [];
      print("下拉框请求失败");
    }
  }
  
  postAssetSearch() async {
    assetMap = {
      "assetName": text
    };

    var response = await http.post(
      Uri.parse("http://10.0.2.2:5000/asset/getAssetInfoReprint"),
      headers: {"content-type": "application/json"},
      body: json.encode(assetMap)
    );
    if(response.statusCode == 200){
      assetList = json.decode(response.body);
    }else{
      assetList = [];
      print("搜索框请求失败");
    }
  }

  getSearchText(){
    _searchText.addListener(() {
      setState(() {
        text = _searchText.text;
        if(text.isNotEmpty){
          print("输入内容：$text");
          postAssetSearch();
        }else{
          getAsset();
        }
      });
    });
  }

  horizontal() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (MediaQuery.of(context).orientation == Orientation.landscape) {
        print("已横屏");
          // Navigator.push(context, MaterialPageRoute(
          //     builder: (context) => Horizontal(),
          //     settings: RouteSettings(arguments: assetList)
          // ));
      }
    });
  }

  onResume(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('主页面');
      if(first){
        getAsset();
        first = false;
      }
    }
  }

  @override
  void didChangeDependencies() {
    first = true;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    getDepartment();
    getAssetGroup();
    getSearchText();
  }

  @override
  Widget build(BuildContext context) {

    onResume(AppLifecycleState.resumed);
    horizontal();

    return Scaffold(
      //拒绝在appBar后面拓展Body
      extendBodyBehindAppBar: false,
      //防止键盘从底部插入
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Color(0xff3f3f3f),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        //清除焦点
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            children: [
              //Department / Asset Group
              Container(
                width: MediaQuery.of(context).size.width,
                height: 70,
                margin: EdgeInsets.only(top: 15, left:10),
                child: Stack(
                  children: [
                    //Department
                    Align(
                      alignment: Alignment(-1,0),
                      child: Container(
                        width: 165,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(department,
                              style: TextStyle(
                                  fontSize: 17
                              ),
                            ),

                            PopupMenuButton(
                              itemBuilder: (context) => List.generate(
                                  departmentHttpList.length,
                                      (index) => PopupMenuItem(
                                        child: Text(departmentHttpList[index]["name"]),
                                        value: departmentHttpList[index],
                                      ),
                                ),
                              icon: Icon(Icons.arrow_drop_down, size: 35,),
                              onSelected: (value){
                                FocusScope.of(context).requestFocus(FocusNode());
                                setState(() {
                                  Map departmentMap = value as Map;
                                  department = departmentMap["name"];
                                  departmentId = departmentMap["id"];

                                  if(departmentId>0 && assetGroupId>0){
                                    postAsset();
                                  }
                                  if(departmentId==0 && assetGroupId==0){
                                    getAsset();
                                  }

                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(-1,0.8),
                      child: Container(
                        width: 150,
                        height: 2,
                        color: Colors.black,
                      ),
                    ),

                    //AssetGroup
                    Align(
                      alignment: Alignment(0.35,0),
                      child: Container(
                        width: 165,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(assetGroup,
                              style: TextStyle(fontSize: 17),
                            ),

                            PopupMenuButton(
                              icon: Icon(Icons.arrow_drop_down,size: 35),
                              itemBuilder: (context) => List.generate(
                                  assetGroupHttpList.length,
                                      (index) => PopupMenuItem(
                                        child: Text(assetGroupHttpList[index]["name"]),
                                        value: assetGroupHttpList[index],
                                      )
                              ),
                              onSelected: (value) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                setState(() {
                                  Map assetGroupMap = value as Map;
                                  assetGroup = assetGroupMap["name"];
                                  assetGroupId = assetGroupMap["id"];

                                  if(departmentId>0 && assetGroupId>0){
                                    postAsset();
                                  }
                                  if(departmentId==0 && assetGroupId==0){
                                    getAsset();
                                  }

                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0.28,0.8),
                      child: Container(
                        width: 150,
                        height: 2,
                        color: Colors.black,
                      ),
                    ),

                  ],
                ),
              ),

              //Warranty date range
              Container(
                width: MediaQuery.of(context).size.width,
                height: 170,
                margin: EdgeInsets.only(
                    top: 20,
                    left: 10,
                    right: 10,
                ),
                child: Stack(
                  children: [
                    //Warranty date range
                    Align(
                      alignment: Alignment(-0.85,-0.9),
                      child: Container(
                        child: Text("Warranty date range:",
                          style: TextStyle(
                            fontSize: 20
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0,-0.5),
                      child: Container(
                        height: 2.5,
                        color: Color(0xffa4a4a4),
                      ),
                    ),

                    Align(
                      alignment: Alignment(-1,-0.2),
                      child: Container(
                        width: 35,
                        height: 35,
                        child: Image.asset("images/calendar9.png",fit: BoxFit.fill),
                      ),
                    ),

                    //StartDate
                    Align(
                      alignment: Alignment(-0.7,0.2),
                      child: Container(
                        width: 120,
                        height: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            InkWell(
                              child: Text(startDate,
                                style: TextStyle(
                                    fontSize: 17
                                ),
                            ),
                            onTap: () async{
                              var result = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2030)
                              ) as DateTime;
                              setState(() {
                                startDate = formatDate(result, [yyyy,'-',m,'-',d]);
                                print("startDate: $startDate");
                              });
                              },
                            ),

                            Container(
                              height: 2,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0,-0.2),
                      child: Container(
                        width: 35,
                        height: 35,
                        child: Image.asset("images/calendar9.png",fit: BoxFit.fill),
                      ),
                    ),

                    //StartDate
                    Align(
                      alignment: Alignment(0.65,0.2),
                      child: Container(
                        width: 120,
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            InkWell(
                              child: Text(endDate,
                                style: TextStyle(
                                    fontSize: 17
                                ),
                              ),
                              onTap: () async{
                                var result = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2030)
                                ) as DateTime;

                                setState(() {
                                  // DateTime start = DateTime.parse(startDate);
                                  DateTime end = DateTime.parse(endDate);
                                  // print("start: $start");
                                  print("end: $result");

                                  endDate = formatDate(result, [yyyy,'-',m,'-',d]);
                                });
                              },
                            ),

                            Container(
                              height: 2,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    )

                  ],
                ),
              ),

              //Search -> TextField
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 60,
                color: Color(0xffeeeeee),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    //bookImage
                    Container(
                      width: 40,
                      height:40,
                      margin: EdgeInsets.only(left: 10),
                      child: Image.asset("images/book.png",fit: BoxFit.fill,color: Colors.black),
                    ),

                    //SearchTextField
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 40,
                          maxWidth: 300,
                        ),
                        child: TextField(
                          focusNode: _searchNode,
                          controller: _searchText,
                          style: TextStyle(
                              fontSize: 23
                          ),
                          autofocus: false,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 20,
                              ),
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  fontSize: 23
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              filled: true,
                              fillColor: Color(0xffeeeeee)
                          ),
                        ),
                      ),
                    ),

                    //SearchImage
                    Container(
                      width: 40,
                      height:40,
                      margin: EdgeInsets.only(right: 10),
                      child: Image.asset("images/search.PNG",fit: BoxFit.fill),
                    ),

                  ],
                )
              ),

              //Asset list
              Visibility(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 350,
                    margin: EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10
                    ),
                    padding: EdgeInsets.only(
                        top: 10,left: 5
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Asset list:",
                          style: TextStyle(fontSize: 18),
                        ),

                        Container(
                          height: 300,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: assetList.length,
                            itemBuilder: (context,index){
                              return Container(
                                height: 100,
                                child: Stack(
                                  children: [
                                    //Image
                                    Align(
                                      alignment: Alignment(-1,0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        child: Image.asset("images/title.PNG",
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),

                                    //AssetName,Department,AssetSN
                                    Align(
                                        alignment: Alignment(-0.1,0),
                                        child: Container(
                                          width: 260,
                                          margin: EdgeInsets.only(left: 0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(assetList[index]["assetName"],
                                                style: TextStyle(
                                                    fontSize: 15
                                                ),
                                              ),
                                              Text(assetList[index]["departmentsName"],
                                                style: TextStyle(
                                                    fontSize: 15
                                                ),
                                              ),
                                              Text(assetList[index]["assetSn"],
                                                style: TextStyle(
                                                    fontSize: 15
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    ),

                                    //Edit =>Button
                                    Align(
                                        alignment: Alignment(0.65,0),
                                        child: InkWell(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset("images/edit.PNG",fit: BoxFit.fill),
                                          ),
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => RegisterEditAsset(),
                                              settings: RouteSettings(
                                                arguments: assetList[index]
                                              )
                                            ));
                                          },
                                        )
                                    ),

                                    //TransferHistory =>Button
                                    Align(
                                        alignment: Alignment(0.85,0),
                                        child: InkWell(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset("images/history.PNG",fit: BoxFit.fill),
                                          ),
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => AssetTransfer(),
                                              settings: RouteSettings(
                                                arguments: assetList[index]
                                              )
                                            ));

                                          },
                                        )
                                    ),

                                    //detail =>Button
                                    Align(
                                        alignment: Alignment(1,0),
                                        child: InkWell(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset("images/detail.PNG",fit: BoxFit.fill),
                                          ),
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => TransferHistory(),
                                                settings: RouteSettings(
                                                    arguments: assetList[index]
                                                )
                                            ));
                                          },
                                        )
                                    ),

                                  ],
                                ),
                              );
                            },
                          ),
                        )

                      ],
                    ),
                  ),
                visible: assetList.isNotEmpty ? true : false,
              ),

              //暂无资产信息
              Visibility(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text("暂无资产信息",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                visible: assetList.isNotEmpty ? false : true,
              ),

              //Bottom -> length,RadiusButton
              Spacer(),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                margin: EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${assetList.length} assets from 35",
                      style: TextStyle(
                        fontSize: 16
                      ),
                    ),

                    //注册资产
                    InkWell(
                      child: Container(
                        width: 80,
                        height: 80,
                        child: Image.asset("images/add.PNG",fit: BoxFit.fill),
                      ),
                      onTap: (){
                        Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => RegisterEditAsset(),
                        ));
                      },
                    )

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
