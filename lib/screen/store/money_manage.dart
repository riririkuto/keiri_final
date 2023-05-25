import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../view_moedl/money_view_model.dart';
import '../../widgets/alert_message.dart';
import '../../widgets/drawer.dart';

class MoneyManage extends ConsumerStatefulWidget {
  const MoneyManage({Key? key}) : super(key: key);

  @override
  ConsumerState<MoneyManage> createState() => _MoneyManageState();
}

class _MoneyManageState extends ConsumerState<MoneyManage> {
  String? isSelectedItem = 'aaa';
  int? kenbaiki;
  int? rezi;
  int? nikuya;
  int? yaoya;
  int? seimenya;
  int? yorozuya;
  List<Map<String, dynamic>> options = [];
  bool onTap = false;
  late Future<DateTime?> selectedDate;
  @override
  Widget build(BuildContext context) {

    DateTime now = DateTime.now();
    return Scaffold(

      drawer: CustomDrawer(),
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('売上・仕入申請')),
      body: onTap
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: Colors.green,
              ))
          : SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                  children: [
                    Text(
                      '今日(${now.month}月${now.day}日)の記録',
                      style: TextStyle(fontSize: 30.sp),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      '券売機での売り上げはいくらですか？',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 200.w,
                          child: TextField(
                            onChanged: (String optionValue) {
                              int? searchIndex;
                              try {
                                searchIndex = options.indexWhere((e) {
                                  print(e);
                                  return e['n'] == -2;
                                });
                              } catch (e) {
                                searchIndex = -1;
                              }

                              if (searchIndex != -1) {
                                Map<String, dynamic> get = options[searchIndex];
                                get['optionValue'] = int.parse(optionValue);
                                options[searchIndex] = get;
                              } else {
                                options.add({
                                  'n': -2,
                                  'optionValue': int.parse(optionValue),
                                  'optionTitle': '券売機',
                                });
                              }
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: TextEditingController(
                                text: decide(-2, false)),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                          ),
                        ),
                        Text('円')
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'レジでの売り上げはいくらですか？',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 200.w,
                          child: TextField(
                            controller: TextEditingController(
                                text: decide(-1, false)),
                            onChanged: (String optionValue) {
                              int? searchIndex;
                              try {
                                searchIndex = options.indexWhere((e) {
                                  print(e);
                                  return e['n'] == -1;
                                });
                              } catch (e) {
                                searchIndex = -1;
                              }

                              if (searchIndex != -1) {
                                Map<String, dynamic> get = options[searchIndex];
                                get['optionValue'] = int.parse(optionValue);
                                options[searchIndex] = get;
                              } else {
                                options.add({
                                  'n': -1,
                                  'optionValue': int.parse(optionValue),
                                  'optionTitle': 'レジ',
                                });
                              }
                            },
                            keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),

                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                          ),
                        ),
                        Text('円')
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      '仕入はいくらですか？',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 255.h,
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          String title;
                          switch (index) {
                            case 0:
                              title = '肉';
                              break;
                            case 1:
                              title = '八百';
                              break;
                            case 2:
                              title = '製麺';
                              break;
                            case 3:
                              title = '萬味';
                              break;
                            case 4:
                              title = '酒';
                              break;
                            case 5:
                              title = 'ガソリン';
                              break;
                            case 6:
                              title = '駐車場';
                              break;

                            default:
                              title = 'オプション';
                              break;
                          }
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  title == 'オプション'
                                      ? SizedBox(
                                          width: 100.w,
                                          child: TextField(
                                            onChanged: (String optionTitle) {
                                              int? searchIndex;

                                              try {
                                                searchIndex =
                                                    options.indexWhere((e) {
                                                  print(e);
                                                  return e['n'] == index;
                                                });
                                              } catch (e) {
                                                searchIndex = -1;
                                              }
                                              if(optionTitle==''&&options[searchIndex]['optionValue']==0){
                                                setState(() {
                                                  options.removeWhere(
                                                          (map) => map['n'] == index);
                                                });
                                              }
                                              if (searchIndex != -1) {
                                                Map<String, dynamic> get =
                                                    options[searchIndex];
                                                get['optionTitle'] = optionTitle;
                                                options[searchIndex] = get;
                                              } else {
                                                options.add({
                                                  'n': index,
                                                  'optionTitle': optionTitle
                                                });
                                              }
                                            },
                                            controller: TextEditingController(
                                                text: decide(index, true)),
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            )),
                                          ),
                                        )
                                      : Text(
                                          '$title屋',
                                          style: TextStyle(fontSize: 20.sp),
                                        ),
                                  Spacer(),
                                  SizedBox(
                                    width: 200.w,
                                    child: TextField(
                                      onChanged: (String optionValue) {
                                        int? searchIndex;

                                        try {
                                          searchIndex = options.indexWhere((e) {
                                            print(e);
                                            return e['n'] == index;
                                          });
                                        } catch (e) {
                                          searchIndex = -1;
                                        }
                                        if (optionValue == '') {
                                          if (title != 'オプション' ||
                                              options[searchIndex]['optionTitle'] ==
                                                  '' ||
                                              options[searchIndex]['optionTitle'] ==
                                                  null) {
                                            setState(() {
                                              options.removeWhere(
                                                  (map) => map['n'] == index);
                                            });
                                          } else {
                                            optionValue = '0';
                                          }
                                        }
                                        if (searchIndex != -1) {
                                          Map<String, dynamic> get =
                                              options[searchIndex];
                                          get['optionValue'] =
                                              int.parse(optionValue);
                                          options[searchIndex] = get;
                                        } else {
                                          title == 'オプション'
                                              ? options.add({
                                                  'n': index,
                                                  'optionValue':
                                                      int.parse(optionValue),
                                                })
                                              : options.add({
                                                  'n': index,
                                                  'optionValue':
                                                      int.parse(optionValue),
                                                  'optionTitle': '$title屋'
                                                });
                                        }
                                      },
                                      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      controller: TextEditingController(
                                          text: decide(index, false)),
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                    ),
                                  ),
                                  Text('円')
                                ],
                              ),

                              // SizedBox(
                              //   height: 50.h,
                              //   child: ListTile(
                              //     tileColor: Colors.grey,
                              //     title: Text(
                              //         '${strInfo[index]}:${timeInfo[index].hour}時${timeInfo[index].minute}分'),
                              //   ),
                              // ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 30)),
                        child:
                            const Text("申請", style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          setState(() {
                            onTap = true;
                          });
                          List re =
                              await ref.read(moneyProvider.notifier).addRequest(options);
                          if (isAllNull(re)) {
                            AlertMessageDialog.show(context, '申請が完了しました！', '');
                            setState(() {
                              onTap = false;
                            });
                          } else {
                            AlertMessageDialog.show(context, '未入力の項目があります。',
                                'オプションでどちらも入力しているか確認してください。');
                            setState(() {
                              onTap = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ),
          ),
    );
  }

  bool containsValue(
      List<Map<String, dynamic>> list, String field, dynamic value) {
    return list.any((map) => map[field] == value);
  }

  decide(int index, bool a) {
    int searchIndex = options.indexWhere((e) {
      return e['n'] == index;
    });
    if (searchIndex != -1) {
      print('hha');
      return options[searchIndex][a ? 'optionTitle' : 'optionValue'].toString();
    } else {
      print('haf');
      return null;
    }
  }
}

bool isAllNull(List list) {
  return list.every((element) => element == null);
}
