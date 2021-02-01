import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:thorchain_explorer/_classes/tc_action.dart';
import 'package:thorchain_explorer/_providers/_state.dart';
import 'package:thorchain_explorer/_providers/tc_actions_provider.dart';
import 'package:thorchain_explorer/_services/midgard_service.dart';
import 'package:thorchain_explorer/_widgets/abridge_text.dart';
import 'package:thorchain_explorer/_widgets/address_link.dart';
import 'package:thorchain_explorer/_widgets/app_bar.dart';
import 'package:thorchain_explorer/_widgets/asset_icon.dart';
import 'package:thorchain_explorer/_widgets/coin_amounts_list.dart';
import 'package:thorchain_explorer/_widgets/fluid_container.dart';
import "package:intl/intl_browser.dart";
import 'package:thorchain_explorer/_widgets/meta_tag.dart';
import 'package:thorchain_explorer/_widgets/tx_link.dart';

class TransactionPage extends HookWidget {

  final String query;
  // final String graphQlQuery;

  TransactionPage(this.query);

  final dateFormatter = new DateFormat.yMMMMd('en_US').add_jm();

  @override
  Widget build(BuildContext context) {

    final params = FetchActionParams(offset: 0, limit: 10, txId: query);

    return Scaffold(
        appBar: ExplorerAppBar(),
        body: HookBuilder(
          builder: (context) {

            final response = useProvider(actions(params));
            //
            return response.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (response) {
                print("RESPONSE IN VIEW $response");

                int count = int.parse(response.count);

                if (0 < count) {

                  TcAction action = response.actions[0];
                  DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(int.parse(action.date) ~/ 1000);

                  return SingleChildScrollView(
                      child: FluidContainer(
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SelectableText(
                              'Transaction',
                              style: TextStyle(
                                fontSize: 24
                              ),
                            ),
                            SizedBox(height: 8,),
                            SelectableText(
                              query,
                              style: TextStyle(
                                fontSize: 16
                              ),
                            ),
                            SizedBox(height: 8,),
                            SelectableText(dateFormatter.format(dateTime)),
                            SizedBox(height: 32,),
                            Material(
                              elevation: 4,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Column(
                                  children: [

                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            children: createActionTxItems(context, action.inputs, 'In'),
                                          ),
                                        ),
                                        // Container(
                                        //   child: createActionTxItems(context, action.inputs, 'In'),
                                        // )
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            children: createActionTxItems(context, action.outputs, 'Out'),
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            child: Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SelectableText(
                                                    "Block",
                                                    style: TextStyle(
                                                        color: Theme.of(context).hintColor,
                                                        fontSize: 12
                                                    ),
                                                  ),
                                                  SelectableText(action.height)
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SelectableText(
                                                    "Status",
                                                    style: TextStyle(
                                                        color: Theme.of(context).hintColor,
                                                        fontSize: 12
                                                    ),
                                                  ),
                                                  SelectableText(action.status)
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SelectableText(
                                                    "Type",
                                                    style: TextStyle(
                                                        color: Theme.of(context).hintColor,
                                                        fontSize: 12
                                                    ),
                                                  ),
                                                  SelectableText(action.type)
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )

                                    // Text(tx.txID),
                                    // Text(tx.address),
                                    // Text(tx.memo)
                                  ],
                                ),
                              ),
                            ),
                            // SizedBox(height: 8,),
                            // Material(
                            //   elevation: 4,
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       color: Theme.of(context).cardColor,
                            //       borderRadius: BorderRadius.circular(5.0),
                            //     ),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.stretch,
                            //       children: [
                            //         Text('Outputs'),
                            //       ],
                            //     ),
                            //   ),
                            // )
                          ],
                        )
                      )
                  );

                } else {
                  return Center(
                    child: Text("No Transaction Found"),
                  );
                }
              },
            );
          }
        ),
      );
  }

  List<Widget> createActionTxItems(BuildContext context, List<ActionTx> txs, String tag) {

    Color tagColor = tag == 'In' ? Colors.blue : Colors.green;

    return txs.map( (tx) =>
        Container(
          padding: EdgeInsets.all(16),
          // decoration: BoxDecoration(
          //   color: Theme.of(context).cardColor
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MetaTag(tag, tagColor),
                  SizedBox(width: 12,),
                  TxLink(tx.txID),
                  ClipOval(
                    child: Material(
                      color: Theme.of(context).cardColor,
                      child: IconButton(
                        iconSize: 12,
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: tx.txID));

                          final snackBar = SnackBar(content: Text('Transaction ID Copied'));

                          // Find the Scaffold in the widget tree and use it to show a SnackBar.
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        }
                      ),
                    ),
                  ),
                ],
              ),
              CoinAmountsList(tx.coins),
              // buildAmounts(tx.coins),
              // Text(tx.txID),
              // Text(tx.address),
              SizedBox(height: 12),
              AddressLink(tx.address),
              SelectableText(
                tx.memo,
                // overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        )
    ).toList();
  }

  // Widget buildAmounts(List<CoinAmount> amounts) {
  //   return Container(
  //     child: Column(
  //       children: amounts.map(
  //         (e) => Row(
  //           children: [
  //             AssetIcon(
  //               e.asset,
  //               width: 24,
  //             ),
  //             SizedBox(width: 8,),
  //             Text( (double.parse(e.amount) / pow(10, 8)).toStringAsFixed(4) )
  //           ],
  //         )
  //       ).toList(),
  //     ),
  //   );
  // }

  String buildGraphQlQuery() {
    if (this.query == '') {
      return '';
    } else {
      return '';
    }
  }
}