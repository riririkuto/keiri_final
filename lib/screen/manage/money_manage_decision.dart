import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../view_moedl/money_view_model.dart';
import '../../widgets/drawer.dart';

class MoneyManageDecision extends ConsumerStatefulWidget {
  final DateTime now;

  const MoneyManageDecision({Key? key, required this.now}) : super(key: key);

  @override
  ConsumerState<MoneyManageDecision> createState() =>
      _MoneyManageDecisionState();
}

class _MoneyManageDecisionState extends ConsumerState<MoneyManageDecision> {
  int choiceIndex = 0;
  int sum = 1484;
  int rieki = 1000;
  int rieki2 = -1;
  List<FocusNode> focuss = [];
  DateTime? date;
  DateTime? selectedMonth;

  late Future<DateTime?> selectedDate;

  @override
  void initState() {
    // TODO: implement initState
    ad();
    super.initState();
  }

  void ad() {
    var index = 0;

    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-5187414655441156/3688733803'
            : 'ca-app-pub-5187414655441156/3688733803',
        listener: BannerAdListener(onAdLoaded: (Ad ad) {
          setState(() {
            loaded = true;
          });
        }),
        request: AdRequest())
      ..load();

    index++;
  }

  BannerAd? bannerAd;
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    List dataList = ref.watch(moneyProvider);

    List<DataRow>? rows;
    print('s$dataList');

    if (dataList.isNotEmpty) {
      print('fafdsa');
      int sum = 0;
      rows = dataList.map((d) {
        String title = d['optionTitle'];
        print(d['optionValue'].runtimeType);
        int nun = d['optionValue'];

        sum = (title == '券売機' || title == 'レジ') ? sum + nun : sum - nun;

        String value = nun.toString();
        FocusNode focusNode = FocusNode();
        focuss.add(focusNode);
        return DataRow(
          cells: [
            DataCell(Align(
                alignment: Alignment.centerRight,
                child: Text(title == '券売機' || title == 'レジ' ? title : ''))),
            DataCell(Align(
                alignment: Alignment.centerRight,
                child: Text(title == '券売機' || title == 'レジ' ? '' : title))),
            DataCell(choiceIndex == 0
                ? TextFormField(
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    focusNode: focusNode,
                    controller: TextEditingController()..text = value,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(hintText: value),
                    onChanged: (String val) {
                      print(dataList);
                      int index = dataList.indexOf(d);
                      Map<String, dynamic> store = dataList[index];
                      print('afdds$index');
                      print('asa$store');

                      store['optionValue'] = int.parse(val);
                      print('fasdf$store');
                      dataList[index] = store;
                    },
                    onFieldSubmitted: (val) {
                      print('onSubmited $val');
                    },
                  )
                : Align(alignment: Alignment.centerRight, child: Text(value))),
            DataCell(Align(
                alignment: Alignment.centerRight,
                child: Text(
                    (title == '券売機' || title == 'レジ' ? '+' : '-') + value))),
          ],
        );
      }).toList();
      rows.add(DataRow(
        cells: [
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Align(alignment: Alignment.centerRight, child: Text('合計'))),
          DataCell(Align(
              alignment: Alignment.centerRight, child: Text(sum.toString()))),
        ],
      ));
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('売上・仕入申請確認')),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // loaded
            //     ? SizedBox(
            //     height: bannerAd?.size.height.toDouble(),
            //     width: bannerAd?.size.width.toDouble(),
            //     child: AdWidget(ad: bannerAd!))
            //     : SizedBox(),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                choiceContainer(0, widget.now),
                choiceContainer(1, widget.now),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120.w,
                ),
                choiceIndex == 0
                    ? Text(
                        date == null
                            ? '${widget.now.month}月${widget.now.day}日'
                            : '${date!.month}月${date!.day}日',
                        style: TextStyle(fontSize: 30.sp),
                      )
                    : Text(
                        selectedMonth == null
                            ? '${widget.now.year}年${widget.now.month}月'
                            : '${selectedMonth!.year}年${selectedMonth!.month}月',
                        style: TextStyle(fontSize: 30.sp)),
                IconButton(
                    icon: Icon(
                        color: Colors.blue, Icons.change_circle, size: 20.sp),
                    onPressed: () async {
                      if (choiceIndex == 0) {
                        selectedDate = showDatePicker(
                          locale: Locale('ja'),
                          confirmText: '完了',
                          context: context,
                          helpText: '勤務日',
                          initialDate: date == null ? widget.now : date!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  // primary: MyColors.primary,
                                  primary:
                                      Theme.of(context).colorScheme.primary,
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
                        selectedDate.then((value) async {
                          ad();
                          setState(() {
                            date = value!;
                          });

                          DateTime zeroed =
                              DateTime(date!.year, date!.month, date!.day);
                          await ref.read(moneyProvider.notifier).getDay(zeroed);
                        }, onError: (error) {});
                      } else {
                        ad();
                        selectedMonth = await showMonthPicker(
                          locale: const Locale("ja", "JP"),
                          // 追加
                          context: context,
                          initialDate: date!,
                          firstDate: DateTime(DateTime.now().year - 1),
                          lastDate: DateTime(DateTime.now().year + 1),
                        );
                        if (selectedMonth == null) return;

                        await ref
                            .read(moneyProvider.notifier)
                            .getMonth(selectedMonth!);
                      }
                    }),
              ],
            ),
            choiceIndex == 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          child: Text('元に戻す'),
                          onPressed: () {
                            for (FocusNode focus in focuss) {
                              focus.unfocus();
                            }
                            setState(() {
                              print('sa');
                            });
                          }),
                      TextButton(
                          child: Text(
                            '変更する',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            for (FocusNode focus in focuss) {
                              focus.unfocus();
                            }
                            setState(() {
                              ref.read(moneyProvider.notifier).update(
                                  dataList,
                                  date == null
                                      ? DateTime(widget.now.year,
                                          widget.now.month, widget.now.day)
                                      : DateTime(
                                          date!.year, date!.month, date!.day));
                            });
                          }),
                    ],
                  )
                : SizedBox(height: 10.h),
            dataList.isEmpty
                ? choiceIndex == 0
                    ? Text('この日のデータはありません。')
                    : Text('この月のデータはありません。')
                : SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          '売上',
                          textAlign: TextAlign.right,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          '仕入',
                          textAlign: TextAlign.right,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          '金額',
                          textAlign: TextAlign.right,
                        ))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                          '利益',
                          textAlign: TextAlign.right,
                        ))),
                      ],
                      rows: rows!,
                    ),
                  ),


          ],
        ),
      ),
    );
  }

  InkWell choiceContainer(int index, DateTime zeroed) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () async {
        if (index == 0) {
          print(date);
          print(zeroed);
          await ref.read(moneyProvider.notifier).getDay(date ?? zeroed);
        } else {
          await ref.read(moneyProvider.notifier).getMonth(
              selectedMonth ?? DateTime(widget.now.year, widget.now.month, 1));
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
}
