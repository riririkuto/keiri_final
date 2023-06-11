import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../view_moedl/auth_view_model.dart';
import '../../view_moedl/kintai_view_model.dart';
import '../../widgets/alert_message.dart';
import '../../widgets/drawer.dart';
import '../../widgets/my_text_field.dart';
import '../a.dart';

class StaffKintai extends ConsumerStatefulWidget {
  const StaffKintai({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffKintai> createState() => _StaffKintaiState();
}

class _StaffKintaiState extends ConsumerState<StaffKintai> {
  String? name;
  late String uid;
  bool nameSuccess = false;
  bool search = false;
  DateTime now = DateTime.now();
  late Map information;
  late List<Map<dynamic, dynamic>> dayInfo;
  DateTime? selectedMonth;
  DateTime? selectedDate;
  int choiceIndex = 0;
  late Future<DateTime?> selectedDateF;

  @override
  void initState() {

    super.initState();
  }


  List<BannerAd> ads = [];
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = FocusNode();
    dayInfo = ref.watch(kintaiProvider);

    return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(title: Text('スタッフ出勤状況')),
        body: search
            ? Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.green,
                ))
            : SingleChildScrollView(
                child: Column(children: [

                  SizedBox(height: 10.h),
                  Text('名前で検索', style: TextStyle(fontSize: 20.sp)),
                  MyTextField(
                    controller: TextEditingController()..text = name ?? '',
                    onChanged: (String value) {
                      name = value;
                    },
                    hintText: '',
                  ),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        search = true;
                      });

                      uid = await ref
                          .read(authViewModelProvider.notifier)
                          .nameSearch(name!);
                      setState(() {
                        search = false;
                      });
                      if (uid == 'Data does not exist.') {
                        AlertMessageDialog.show(
                            context, 'あなたの名前は登録されていません。', '');
                      } else {
                        DateTime month = DateTime(now.year, now.month, 1);

                      nameSuccess = true;
                        await ref.read(kintaiProvider.notifier).get(uid, now);
                        //
                        // setState(() {
                        //   nameSuccess = true;
                        // });
                      }
                    },
                    child: Text('決定'),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      choiceContainer(0),
                      choiceContainer(1),
                    ],
                  ),
                  nameSuccess
                      ? choiceIndex == 1
                          ? information == {}
                              ? Text('この月のデータはまだありません。')
                              : Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                            style: ButtonStyle(),
                                            child: Text(
                                              '時給の変更',
                                              style: TextStyle(fontSize: 10.sp),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  String inputText = '';

                                                  return AlertDialog(
                                                    title: Text('時給'),
                                                    content: TextField(
                                                      keyboardType: TextInputType
                                                          .numberWithOptions(
                                                              signed: true,
                                                              decimal: true),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      onChanged: (text) {
                                                        inputText = text;
                                                      },
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('キャンセル',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text('OK'),
                                                        onPressed: () async {
                                                          await ref
                                                              .read(
                                                                  authViewModelProvider
                                                                      .notifier)
                                                              .upDateHourlyWage(
                                                                  uid,
                                                                  int.parse(
                                                                      inputText));
                                                          information = await ref
                                                              .read(
                                                                  kintaiProvider
                                                                      .notifier)
                                                              .getMonth(
                                                                  uid,
                                                                  selectedMonth ??
                                                                      DateTime(
                                                                          now.year,
                                                                          now.month,
                                                                          1));

                                                          setState(() {});

                                                          Navigator.of(context)
                                                              .pop(inputText);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }),
                                        SizedBox(width: 30.w),
                                        Text(
                                            selectedMonth == null
                                                ? '${now.year}年${now.month}月'
                                                : '${selectedMonth!.year}年${selectedMonth!.month}月',
                                            style: TextStyle(fontSize: 30.sp)),
                                        IconButton(
                                            icon: Icon(Icons.change_circle,
                                                color: Colors.blue,
                                                size: 20.sp),
                                            onPressed: () async {
                                              selectedMonth =
                                                  await showMonthPicker(
                                                locale:
                                                    const Locale("ja", "JP"),
                                                // 追加
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(
                                                    DateTime.now().year - 1),
                                                lastDate: DateTime(
                                                    DateTime.now().year + 1),
                                              );
                                              if (selectedMonth == null) return;
                                              information = await ref
                                                  .read(kintaiProvider.notifier)
                                                  .getMonth(
                                                      uid, selectedMonth!);
                                              setState(() {});
                                            }),
                                        Spacer(),
                                        choiceIndex == 1
                                            ? TextButton(
                                                child: Text(
                                                  'PDF出力',
                                                  style: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PDFView(
                                                              info: information,
                                                              name: name!,
                                                            )),
                                                  );
                                                },
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    SizedBox(
                                      width: double.infinity,
                                      child: DataTable(
                                        headingRowHeight: 0,
                                        columns: const [
                                          DataColumn(
                                            label: Text(''),
                                          ),
                                          DataColumn(label: Text('')),
                                        ],
                                        rows: [
                                          DataRow(
                                            cells: [
                                              DataCell(Text('合計出勤時間:')),
                                              DataCell(Text(
                                                  information['totalWork'])),
                                            ],
                                          ),
                                          DataRow(
                                            cells: [
                                              DataCell(Text('合計休憩時間')),
                                              DataCell(Text(
                                                  information['totalBreak'])),
                                            ],
                                          ),
                                          DataRow(
                                            cells: [
                                              DataCell(Text('まかない合計金額')),
                                              DataCell(Text(
                                                  information['totalMeal'])),
                                            ],
                                          ),
                                          DataRow(
                                            cells: [
                                              DataCell(Text('時給')),
                                              DataCell(Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(information[
                                                      'hourlyWage']),
                                                ],
                                              )),
                                            ],
                                          ),
                                          DataRow(
                                            cells: [
                                              DataCell(Text('出勤-休憩 時間')),
                                              DataCell(Text(
                                                  information['zissitsu'])),
                                            ],
                                          ),
                                          DataRow(
                                            cells: [
                                              DataCell(
                                                  Text('給料-まかない　(15分単位で切り捨て)')),
                                              DataCell(
                                                  Text(information['salary'])),
                                            ],
                                          ),
                                          DataRow(
                                            cells: [
                                              DataCell(
                                                  Text('給料　(15分単位で切り捨て)')),
                                              DataCell(
                                                  Text(information['salary1'])),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      '退勤が押されていない日(カウントしていません)',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                      child: ListView.builder(
                                        itemCount: information['waste'].length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Center(
                                              child: Column(
                                            children: [
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Text(information['waste'][index]),
                                            ],
                                          ));
                                        },
                                      ),
                                    )
                                  ],
                                )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      selectedDate == null
                                          ? '${now.month}月${now.day}日'
                                          : '${selectedDate!.month}月${selectedDate!.day}日',
                                      style: TextStyle(fontSize: 30.sp),
                                    ),
                                    IconButton(
                                        icon: Icon(
                                            color: Colors.blue,
                                            Icons.change_circle,
                                            size: 20.sp),
                                        onPressed: () async {
                                          selectedDateF = showDatePicker(
                                            locale: Locale('ja'),
                                            confirmText: '開始時刻へ',
                                            context: context,
                                            helpText: '勤務日',
                                            initialDate: selectedDate ?? now,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2050),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Theme(
                                                data:
                                                    ThemeData.light().copyWith(
                                                  colorScheme:
                                                      ColorScheme.light(
                                                    // primary: MyColors.primary,
                                                    primary: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    onPrimary: Colors.white,
                                                    surface: Colors.white,
                                                    onSurface: Colors.black,
                                                  ),
                                                  //.dialogBackgroundColor:Colors.blue[900],
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          selectedDateF.then((value) async {
                                            selectedDate = value!;
                                            await ref
                                                .read(kintaiProvider.notifier)
                                                .get(uid, selectedDate);
                                          }, onError: (error) {});
                                        }),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: DataTable(
                                    headingRowHeight: 0,
                                    rows: buildRow(),
                                    columns: [
                                      DataColumn(label: Text('')),
                                      DataColumn(label: Text(''))
                                    ],
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.add_box,
                                        color: Colors.lightBlue),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          String inputText = '';

                                          return AlertDialog(
                                            title: Text('何を追加しますか？'),
                                            content: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    kindButton(
                                                        '出勤',
                                                        Icons.input,
                                                        Colors.blue),
                                                    kindButton(
                                                        '退勤',
                                                        Icons.output,
                                                        Colors.red),
                                                  ],
                                                ),
                                                SizedBox(height: 5.h),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    kindButton(
                                                        '休憩開始',
                                                        Icons.forest,
                                                        Colors.green),
                                                    kindButton(
                                                        '休憩終了',
                                                        Icons.forest,
                                                        Colors.green),
                                                  ],
                                                ),
                                                SizedBox(height: 5.h),
                                                kindButton(
                                                    'まかない',
                                                    Icons.food_bank,
                                                    Colors.orange),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text('キャンセル',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(inputText);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((result) async {
                                        if (result != null) {}
                                      });
                                    }),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // foreground
                                  ),
                                  child: Text('情報を更新する'),
                                  onPressed: () async {
                                    await ref
                                        .read(kintaiProvider.notifier)
                                        .updateFire(uid, selectedDate ?? now);
                                    AlertMessageDialog.show(
                                        context, '更新が完了しました！', '');
                                  },
                                ),

                              ],
                            )
                      : SizedBox(),
                ]),
              ));
  }

  InkWell choiceContainer(int index) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () async {
        if (index == 0) {
        } else {
          DateTime month = DateTime(now.year, now.month, 1);
          information =
              await ref.read(kintaiProvider.notifier).getMonth(uid, month);
        }
        setState(() {
          choiceIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: 10.w, vertical: index == choiceIndex ? 7.h : 15.h),
        width: index == choiceIndex ? 100.w : 80.w,
        decoration: BoxDecoration(
          color: index == choiceIndex ? Colors.blueGrey : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
            child: Text(
          index == 0 ? '日' : '月',
          style: TextStyle(fontSize: index == choiceIndex ? 15.sp : 10.sp),
        )),
      ),
    );
  }

  Column kindButton(String kind, IconData icon, Color color) {
    return Column(
      children: [
        SizedBox(
          height: 80.h,
          width: 80.w,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.zero,
              shape: CircleBorder(),
            ),
            onPressed: () async {
              if (kind == 'まかない') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String inputText = '';

                    return AlertDialog(
                      title: Text('何円分のまかないですか？'),
                      content: TextField(
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (text) {
                          inputText = text;
                        },
                      ),
                      actions: [
                        TextButton(
                          child: Text('キャンセル',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(inputText);
                            Navigator.of(context).pop(inputText);
                          },
                        ),
                      ],
                    );
                  },
                ).then((result) async {
                  if (result != null) {
                    await ref
                        .read(kintaiProvider.notifier)
                        .addState(kind, null, int.parse(result));
                  }
                });
              } else {
                late Future<TimeOfDay?> selectedTime;
                selectedTime = showTimePicker(
                  helpText: '時刻を入力してください。',
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(now),
                  builder: (BuildContext context, Widget? child) {
                    final Widget mediaQueryWrapper = MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: false,
                      ),
                      child: child!,
                    );
                    // A hack to use the es_US dateTimeFormat value.
                    if (Localizations.localeOf(context).languageCode == 'es') {
                      return Localizations.override(
                        context: context,
                        locale: Locale('jp', 'JP'),
                        child: mediaQueryWrapper,
                      );
                    }
                    return mediaQueryWrapper;
                  },
                );

                selectedTime.then((value) async {
                  if (value == null) return;

                  await ref.read(kintaiProvider.notifier).addState(
                      kind,
                      selectedDate == null
                          ? DateTime(now!.year, now.month, now.day, value.hour,
                              value.minute)
                          : DateTime(selectedDate!.year, selectedDate!.month,
                              selectedDate!.day, value.hour, value.minute),
                      null);
                  Navigator.pop(context);
                }, onError: (error) {});
              }
            },
            child: Icon(icon, size: 50.sp),
          ),
        ),
        Text(
          kind,
          style: TextStyle(fontSize: 25.sp),
        )
      ],
    );
  }

  buildRow() {
    List<DataRow> rows = [];
    int count = 0;
    for (Map<dynamic, dynamic> d in dayInfo) {
      late String val;
      late bool timeStamp;
      DateTime? vald;
      if (d['val'] is Timestamp || d['val'] is DateTime) {
        timeStamp = true;

        if (d['val'] is Timestamp) {
          vald = d['val'].toDate();
        } else {
          vald = d['val'];
        }
        val = '${vald!.hour}時${vald.minute}分';
      } else {
        timeStamp = false;
        val = '${d['val']}円';
      }
      int index = dayInfo.indexOf(d);

      rows.add(
        DataRow(cells: [
          DataCell(Text(d['kind'])),
          DataCell(Row(
            children: [
              Text(val),
              Spacer(),
              TextButton(
                onPressed: () {
                  late Future<TimeOfDay?> selectedTime;
                  if (timeStamp) {
                    selectedTime = showTimePicker(
                      confirmText: '完了',
                      helpText: '時刻を入力してください。',
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(vald!),
                      builder: (BuildContext context, Widget? child) {
                        final Widget mediaQueryWrapper = MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: false,
                          ),
                          child: child!,
                        );
                        // A hack to use the es_US dateTimeFormat value.
                        if (Localizations.localeOf(context).languageCode ==
                            'es') {
                          return Localizations.override(
                            context: context,
                            locale: Locale('jp', 'JP'),
                            child: mediaQueryWrapper,
                          );
                        }
                        return mediaQueryWrapper;
                      },
                    );

                    selectedTime.then((value) {
                      if (value == null) return;
                      print(count);
                      print(index);

                      dayInfo[index]['val'] = DateTime(vald!.year, vald.month,
                          vald.day, value.hour, value.minute);
                      ref.read(kintaiProvider.notifier).update(dayInfo);
                    }, onError: (error) {});
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String inputText = '';

                        return AlertDialog(
                          title: Text('何円分のまかないですか？'),
                          content: TextField(
                            keyboardType: TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (text) {
                              inputText = text;
                            },
                          ),
                          actions: [
                            TextButton(
                              child: Text('キャンセル',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop(inputText);
                              },
                            ),
                          ],
                        );
                      },
                    ).then((result) async {
                      if (result != null) {
                        dayInfo[index]['val'] = int.parse(result);
                        ref.read(kintaiProvider.notifier).update(dayInfo);
                      }
                    });
                  }
                },
                child: Text('編集'),
              ),
              TextButton(
                  onPressed: () async {
                    await ref.read(kintaiProvider.notifier).delete(index);
                  },
                  child: Text(
                    '削除',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          ))
        ]),
      );
      count++;
    }

    return rows;
  }
}

data() {}

//秋山春子
