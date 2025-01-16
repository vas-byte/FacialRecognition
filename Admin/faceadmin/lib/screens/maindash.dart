import 'package:flutter/material.dart';
import 'loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

class MainDashUI extends StatefulWidget {
  @override
  _MainDashUI createState() => _MainDashUI();
}

class _MainDashUI extends State<MainDashUI> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Dashboard"),
                backgroundColor: Colors.red,
              ),
              body: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    children: [
                      Center(
                          child: Container(
                        padding: EdgeInsets.only(top: 15, left: 20, right: 20),
                        width: double.infinity,
                        height: 110,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(padding: EdgeInsets.only(top: 5)),
                              Text(
                                "Total Check-ins",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 27),
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              Text(snapshot.data[0],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 27)),
                            ],
                          ),
                        ),
                      )),
                      (() {
                        if (int.parse(snapshot.data[0]) > 0) {
                          return Center(
                            child: Container(
                                padding: EdgeInsets.only(
                                    top: 15, left: 20, right: 20),
                                width: double.infinity,
                                child: Column(children: [
                                  Column(
                                    children: [
                                      Padding(padding: EdgeInsets.only(top: 5)),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text("User Sign-ins",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 27)),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: 12)),
                                      SizedBox(
                                          height: 190,
                                          child: PieChart(
                                            PieChartData(
                                              sections: snapshot.data[1],
                                            ),
                                            swapAnimationDuration:
                                                Duration(milliseconds: 150),
                                            swapAnimationCurve: Curves.linear,
                                          )),
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.only(
                                              top: 15, bottom: 6),
                                          shrinkWrap: true,
                                          itemCount: snapshot.data[2].length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 15),
                                                        child: Container(
                                                          width: 30.0,
                                                          height: 30.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: Colors.red[
                                                                snapshot.data[2]
                                                                    [index]],
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        )),
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5)),
                                                    Text(snapshot.data[3]
                                                        [index]),
                                                  ],
                                                ));
                                          })
                                    ],
                                  )
                                ])),
                          );
                        } else {
                          return Container();
                        }
                      }()),
                    ],
                  )),
            );
          } else {
            return Loading(
              key: UniqueKey(),
            );
          }
        });
  }

  Future getData() async {
    List<PieChartSectionData> data = [];
    List<String> names = [];
    List<int> primcolor = [];
    List<double> times = [];

    try {
      var checkinNum = await FirebaseFirestore.instance
          .collection('Group')
          .doc('History')
          .collection('Attendance')
          .get();

      var users = await FirebaseFirestore.instance
          .collection('Users')
          .where("isAdmin", isEqualTo: false)
          .get();
      var choice = [900, 700, 500, 300, 100];
      var colorr;
      for (var user in users.docs) {
        colorr = (choice..shuffle()).first;
        if (primcolor.contains(colorr)) {
          colorr = (choice..shuffle()).first;
          print('1');
        } else if (choice == primcolor) {
          print('2');
          break;
        } else if (primcolor.length == 4) {
          var rem = checkinNum.docs.length.toDouble() - times.sum;
          data.add(PieChartSectionData(
            value: rem,
            color: Colors.red[colorr],
            title: ((rem / checkinNum.docs.length) * 100).toString() + '%',
            radius: 50,
            titleStyle: TextStyle(
                fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          ));
        }

        var checkno = await FirebaseFirestore.instance
            .collection('Group')
            .doc('Members')
            .collection(user['uid'])
            .doc('Attendance')
            .collection('Record')
            .get();
        data.add(PieChartSectionData(
          value: checkno.docs.length.toDouble(),
          color: Colors.red[colorr],
          title: ((checkno.docs.length / checkinNum.docs.length) * 100)
                  .round()
                  .toString() +
              '%',
          radius: 50,
          titleStyle: TextStyle(
              fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
        ));
        names.add(user['FullName']);
        primcolor.add(colorr);
        choice.remove(colorr);
        times.add(checkno.docs.length.toDouble());
      }

      return [checkinNum.docs.length.toString(), data, primcolor, names];
    } catch (error) {
      return ["0"];
    }
  }
}
