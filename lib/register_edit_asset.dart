// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_final_fields

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:orientation/orientation.dart';

class RegisterEditAsset extends StatefulWidget {
  const RegisterEditAsset({Key? key}) : super(key: key);

  @override
  _RegisterEditAssetState createState() => _RegisterEditAssetState();
}

class _RegisterEditAssetState extends State<RegisterEditAsset> {
  final FocusNode _assetNameFocus = FocusNode();
  var _assetNameText = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? file;
  XFile? image;

  bool first = true;
  bool isNull = true;

  String hintText = "Asset Name";
  String department = "Department";
  String location = "Location";
  String assetGroup = "Asset Group";
  String accountableParty = "Accountable Party";
  String expiredWarranty = "Expired Warranty";
  String dd = "dd/";
  String gg = "gg/";
  String nnnn = "nnnn";
  String assetSN = "dd/gg/nnnn";

  int departmentId = 0;
  int locationId = 0;
  int assetGroupId = 0;
  int employeeId = 0;

  List departmentHttpList = [];
  List locationHttpList = [];
  List aGHttpList = [];
  List aPHttpList = [];
  List imageList = [];
  List base64List = [];

  Map assetMap = {};
  Map employeeMap = {};
  Map submitMap ={};

  getAsset(){
    Object? object = ModalRoute.of(context)!.settings.arguments;
    if(object!=null){
      isNull = false;
      assetMap = object as Map;
      print("传入数据 => \nassetMap: $assetMap");

      //AssetName
      hintText = assetMap['assetName'];
      _assetNameText.text = assetMap['assetName'];
      department = assetMap['departmentsName'];
      departmentId = assetMap['departmentsId'];
      locationId = assetMap['locationsId'];
      assetGroup = assetMap['assetGroupsName'];
      employeeId = assetMap['employeeId'];
      // employeeMap = aPHttpList[employeeId];
      print('employeeId: $employeeId');

      List<String> date = assetMap['startDate'].split(" ");
      expiredWarranty = date[0];

      assetSN = assetMap['assetSn'];
      List<String> asset = assetSN.split("/");
      dd = "${asset[0]}/";
      gg = "${asset[1]}/";
      nnnn = asset[2];

    } else {
      isNull = true;
      print("传入数据为Null,注册");
    }

  }

  getDepartment() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/Department"));
    if(response.statusCode == 200){
      departmentHttpList.add({
        "id": 0,
        "name": "Department",
        "departmentLocations": []
      },);
      departmentHttpList.addAll(json.decode(response.body));
    }else{
      department = "Department";
      departmentHttpList = [];
    }
  }

  getLocation() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/Locations"));
    if(response.statusCode == 200){
      locationHttpList.add({
        "id": 0,
        "name": "Location",
        "departmentLocations": []
      },);
      locationHttpList.addAll(json.decode(response.body));
    }else{
      location = "Location";
      locationHttpList = [];
    }
  }

  getAssetGroup() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/AssetGroup"));
    if(response.statusCode == 200){
      aGHttpList.add({
        "id": 0,
        "name": "Asset Group",
        "assets": []
      },);
      aGHttpList.addAll(json.decode(response.body));
    }else{
      assetGroup = "Asset Group";
      aGHttpList = [];
    }
  }

  getAccountableParty() async {
    var response = await http.get(Uri.parse("http://10.0.2.2:5000/Employee"));
    if(response.statusCode == 200){
      employeeMap = {
        "id": 0,
        "firstName": "Accountable ",
        "lastName": "Party",
        "phone": "123456789",
        "assets": []
      };
      aPHttpList.add(employeeMap);
      aPHttpList.addAll(json.decode(response.body));
    }else{
      accountableParty = "Accountable Party";
      aPHttpList = [];
    }
  }
  
  getAssetSN() async{
    var response = await http.post(
      Uri.parse("http://10.0.2.2:5000/asset/GetAssetNo"),
      headers: {"content-type":"application/json"},
      body: json.encode({
        "assetGroupId": assetGroupId,
        "departmentsId": departmentId
      })
    );
    if(response.statusCode == 200){
      setState(() {
        nnnn = response.body;
        assetSN = "$dd$gg$nnnn";
      });
      print('nnnn: $nnnn');
    }
  }

  @override
  void initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    getDepartment();
    getLocation();
    getAssetGroup();
    getAccountableParty();
  }

  @override
  Widget build(BuildContext context) {
    if(first){
      getAsset();
      first = false;
    }
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
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            children: [
              //AssetInformation
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                color: Color(0xff444444),
                margin: EdgeInsets.only(top: 1),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment(-0.8,0),
                      child: Text("Asset Information",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0.75,0),
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

              //AssetName
              //Department,Location,Asset Group,Accountable Party
              Container(
                width: MediaQuery.of(context).size.width,
                height: 310,
                margin: EdgeInsets.only(top: 15,left: 10,right: 10),
                child: Stack(
                  children: [
                    //AssetName -> TextField
                    Align(
                      alignment: Alignment(-1,-0.95),
                      child: Container(
                        height: 70,
                        child: TextField(
                          focusNode: _assetNameFocus,
                          controller: _assetNameText,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w400
                          ),
                          autofocus: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: hintText,
                            hintStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0,-0.6),
                      child: Container(
                        height: 2.5,
                        color: Colors.black,
                      ),
                    ),

                    //Department
                    Align(
                      alignment: Alignment(-1,-0.35),
                      child: Container(
                        width: 190,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(department,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),

                            PopupMenuButton(
                              itemBuilder: (context) {
                                return List.generate(
                                    departmentHttpList.length,
                                        (index) => PopupMenuItem(
                                      child: Text(departmentHttpList[index]["name"],
                                      ),
                                      value: departmentHttpList[index],
                                    )
                                );
                              },
                              icon: Icon(Icons.arrow_drop_down,size: 35,),
                              onSelected: (value){
                                FocusScope.of(context).requestFocus(FocusNode());
                                setState(() {
                                  Map map = value as Map;
                                  department = map["name"];
                                  departmentId = map['id'];
                                  if(departmentId > 0 && departmentId < 10){
                                    dd = "0$departmentId/";
                                  }else if(departmentId >= 10){
                                    dd = "$departmentId/";
                                  }else{
                                    dd = "dd/";
                                  }

                                  if(departmentId != 0 && assetGroupId != 0){
                                    getAssetSN();
                                  }
                                  assetSN = "$dd$gg$nnnn";

                                });
                              },
                            ),
                          ],
                        ),
                      )
                    ),

                    Align(
                      alignment: Alignment(-1,-0.1),
                      child: Container(
                        width: 175,
                        height: 2.5,
                        color: Colors.black,
                      ),
                    ),

                    //Location
                    Align(
                      alignment: Alignment(0.9,-0.35),
                      child: Container(
                        width: 210,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(location,
                              style: TextStyle(
                                fontSize: 18
                              ),
                            ),

                            PopupMenuButton(
                                itemBuilder: (context){
                                  return List.generate(locationHttpList.length,
                                          (index) => PopupMenuItem(
                                              child: Text(locationHttpList[index]["name"]),
                                            value: locationHttpList[index],
                                          )
                                  );
                                },
                              icon: Icon(Icons.arrow_drop_down,size: 35),
                              onSelected: (value){
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  setState(() {
                                    Map map = value as Map;
                                    location = map['name'];
                                    locationId = map['id'];
                                    print('locationsId: $locationId');
                                  });
                              },
                            )
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0.8,-0.1),
                      child: Container(
                        width: 200,
                        height: 2.5,
                        color: Colors.black,
                      ),
                    ),

                    //Asset Group
                    Align(
                      alignment: Alignment(-1,0.3),
                      child: Container(
                        width: 190,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(assetGroup,
                              style: TextStyle(fontSize: 18),
                            ),
                            
                            PopupMenuButton(
                                itemBuilder: (context){
                                  return List.generate(aGHttpList.length, 
                                          (index) => PopupMenuItem(
                                            child: Text(aGHttpList[index]["name"]),
                                            value: aGHttpList[index],
                                          )
                                  );
                                },
                              icon: Icon(Icons.arrow_drop_down,size: 35),
                              onSelected: (value){
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  setState(() {
                                    Map map = value as Map;
                                    assetGroup = map["name"];
                                    assetGroupId = map['id'];
                                    if(assetGroupId>0 &&assetGroupId<10){
                                      gg = "0$assetGroupId/";
                                    }else if(assetGroupId>=10){
                                      gg = "$assetGroupId/";
                                    }else{
                                      gg = "dd/";
                                    }

                                    if(departmentId != 0 && assetGroupId != 0){
                                      getAssetSN();
                                    }
                                    assetSN = "$dd$gg$nnnn";
                                  });
                              },
                            )
                            
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(-1,0.45),
                      child: Container(
                        width: 175,
                        height: 2.5,
                        color: Colors.black,
                      ),
                    ),

                    //Accountable Party
                    Align(
                      alignment: Alignment(0.9,0.3),
                      child: Container(
                        width: 210,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(accountableParty,style: TextStyle(fontSize: 18)),

                            PopupMenuButton(
                                itemBuilder: (context){
                                  return List.generate(aPHttpList.length,
                                          (index) => PopupMenuItem(
                                            child: Text("${aPHttpList[index]["firstName"]}${aPHttpList[index]["lastName"]}"),
                                            value: aPHttpList[index],
                                          ),
                                  );
                                },
                              icon: Icon(Icons.arrow_drop_down,size: 35),
                              onSelected: (value){
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  setState(() {
                                    Map map = value as Map;
                                    accountableParty = map["firstName"]+map["lastName"];
                                    employeeId = map['id'];
                                    // if(employeeId >0 && employeeId < 10) {
                                    //   nnnn = "000$employeeId";
                                    // }else if(employeeId >= 10 && employeeId < 100) {
                                    //   nnnn = "00$employeeId";
                                    // }else {
                                    //   nnnn = "nnnn";
                                    // }
                                    // assetSN = "$dd$gg$nnnn";
                                  });
                              },
                            )
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0.8,0.45),
                      child: Container(
                        width: 200,
                        height: 2.5,
                        color: Colors.black,
                      ),
                    ),

                    //AssetDescription,Multi Line
                    Align(
                      alignment: Alignment(-1,0.9),
                      child: Text("Asset Description,\nMulti Line",
                          style: TextStyle(fontSize: 18)
                      ),
                    ),

                    Align(
                      alignment: Alignment(0,1),
                      child: Container(
                        height: 2.5,
                        color: Colors.black,
                        margin: EdgeInsets.only(right: 20),
                      )
                    ),
                  ],
                ),
              ),

              //Expired Warranty / Asset SN / Button
              Container(
                height: 150,
                margin: EdgeInsets.only(top: 20,left: 10),
                child: Stack(
                  children: [
                    //Image
                    Align(
                      alignment: Alignment(-1,-0.8),
                      child: Container(
                        width: 30,
                        height: 30,
                        child: Image.asset("images/calendar9.png",fit: BoxFit.fill,color: Colors.black,),
                      ),
                    ),

                    //Expired Warranty
                    Align(
                      alignment: Alignment(-0.7,-0.6),
                      child: InkWell(
                        child: Text(expiredWarranty,
                          style: TextStyle(fontSize: 18),
                        ),
                        onTap: () async{
                          var result = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2050)
                          ) as DateTime;

                          setState(() {
                            expiredWarranty = formatDate(result,[yyyy,'-',m,'-',d]);
                          });
                        },
                      ),
                    ),

                    Align(
                      alignment: Alignment(-0.7,-0.25),
                      child: Container(
                        width: 150,
                        height: 2.5,
                        color: Colors.black,
                      ),
                    ),

                    //AssetSN
                    Align(
                      alignment: Alignment(0.25,-0.5),
                      child: Text("AssetSN:",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),

                    //dd/gg/nnnn
                    Align(
                      alignment: Alignment(1.2,-0.5),
                      child: Container(
                        width: 150,
                        child: Row(
                          children: [
                            Text(assetSN,
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900
                              ),
                            ),
                          ],
                        ),
                      )
                    ),

                    //Button
                    Align(
                      alignment: Alignment(0,1),
                      child: Container(
                        margin: EdgeInsets.only(right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //Capture Image
                            Container(
                              width: 155,
                              height: 45,
                              margin: EdgeInsets.only(right: 1),
                              decoration: BoxDecoration(
                                color: Color(0xffe9e9e9),
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: MaterialButton(
                                child: Text("Capture Image",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                onPressed: (){
                                  //调用相机
                                  camera();
                                },

                              ),
                            ),

                            //Browse
                            Container(
                              width: 110,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Color(0xffe9e9e9),
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: MaterialButton(
                                child: Text("Browse",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                onPressed: (){
                                  selectImage();
                                },

                              ),
                            ),

                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              //ImageListView
              Container(
                height: 180,
                color: Color(0xffEEEEEE),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: imageList.length,
                    itemBuilder: (context,index){
                      return Container(
                        height: 75,
                        padding: EdgeInsets.only(left: 20),
                        margin: EdgeInsets.only(
                            top: 5,
                            bottom: 5
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment(-1,0),
                              child: Container(
                                width: 60,
                                height: 60,
                                child: Image.file(
                                  File(imageList[index]['path']),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),

                            Align(
                              alignment: Alignment(-0.6,0),
                              child: Text(imageList[index]['name'],
                                style: TextStyle(
                                  fontSize: 20
                                ),
                              ),
                            )

                          ],
                        ),
                      );
                    }
                ),
              ),

              //Submit / CANCEL
              Spacer(),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //Submit
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 40),
                        child: Text("Submit",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color(0xff70c1f3)
                          ),
                        ),
                      ),
                      onTap: (){
                        //提交
                        submit();
                      },
                    ),

                    //CANCEL
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 30),
                        child: Text("CANCEL",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color(0xff70c1f3)
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  camera() async{
    try{
      //调用相机拍照
      file = await _picker.pickImage(source: ImageSource.camera).then((value) async{
        List<int> bytes = await value!.readAsBytes();
        String base64 = base64Encode(bytes);

        // print('ImagePath: ${value.path}');
        String nowTime = formatDate(DateTime.now(),[HH,nn,ss]);
          setState(() {
            image = value;
            imageList.add({
              "path" : image!.path,
              "name" : nowTime,
            });
            base64List.add(base64);
            //降序输出
            imageList.sort((a,b) => b['name']!.compareTo('${a['name']}'));
            // print('imageList: $imageList');
            // print('base64List: $base64List');
          });
      });
    } catch(e){
      print('未保存图片');
    }
  }

  selectImage() async{
    try{
      //调用相册选择照片
      file = await _picker.pickImage(source: ImageSource.gallery).then((value) async{
        List<int> bytes = await value!.readAsBytes();
        String base64 = base64Encode(bytes);

        print('ImagePath: ${value.path}');
        String nowTime = formatDate(DateTime.now(), [HH,nn,ss]);
        setState(() {
          image = value;
          imageList.add({
            "path": image!.path,
            "name": nowTime
          });
          base64List.add(base64);
          //降序输出
          imageList.sort((a,b) => b['name']!.compareTo('${a['name']}'));
        });
      });
    } catch(e){
      print('未选择图片');
    }
  }

  submit() async{
    String assetName = _assetNameText.text;
    if(assetName.isEmpty){
      Fluttertoast.showToast(msg: "资产名称不能为空!");
    }else if(department == "Department"){
      Fluttertoast.showToast(msg: "请选择部门");
    }else if(location == "Location"){
      Fluttertoast.showToast(msg: "请选择地址");
    } else if(assetGroup == "Asset Group"){
      Fluttertoast.showToast(msg: "请选择分组");
    } else if(accountableParty == "Accountable Party"){
      Fluttertoast.showToast(msg: "请选择雇员信息");
    } else if(base64List.isEmpty){
      Fluttertoast.showToast(msg: "请至少选择一张照片！");
    } else if(nnnn == "0001"){
      Fluttertoast.showToast(msg: "资产序列号重复，请才重新选择!");
    } else {
      //判断是否重名
      Map assetRepeatMap = {};
      var response = await http.post(
          Uri.parse("http://10.0.2.2:5000/asset/GetAssetsByName"),
          headers: {"content-type": "application/json"},
          body: json.encode({"assetName":assetName})
      );
      if(response.statusCode == 200){
        assetRepeatMap = json.decode(response.body);
        if(assetName == assetRepeatMap['assetName']){
          Fluttertoast.showToast(msg: "名字重复，请重新输入！");
        }
      }else{
        print('资产名称不重复，可以注册');
        if(isNull){
          print("注册");
          postRegister();
        }else{
          print("更新");
          postUpdate();
        }
      }
    }
  }

  postRegister() async{
    String assetName = _assetNameText.text;
    submitMap = {
      "AssetName": assetName,
      "EmployeeId": employeeId,
      "AssetGroupId": assetGroupId,
      "Description": "12323",
      "DepartmentsId": departmentId,
      "LocationsId": locationId,
      "StartDate": "2020-01-19",
      "EndDate": formatDate(DateTime.now(), [yyyy,'-',mm,'-',d]),
      "Photos": base64List
    };
    print('submitMap: $submitMap');
    var response = await http.post(
        Uri.parse("http://10.0.2.2:5000/asset/AddAssetsReprint"),
        headers: {"content-type":"application/json"},
        body: json.encode(submitMap)
    );
    if(response.statusCode == 200){
      Fluttertoast.showToast(msg: "注册成功！");
      Navigator.pop(context);
    }else{
      Fluttertoast.showToast(msg: "提交失败");
    }
  }

  postUpdate() async{
    //更新

  }
}

