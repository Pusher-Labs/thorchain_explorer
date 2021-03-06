import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:thorchain_explorer/_classes/tc_network.dart';
import 'package:thorchain_explorer/_gql_queries/gql_queries.dart';
import 'package:thorchain_explorer/_providers/_state.dart';
import 'package:thorchain_explorer/_widgets/container_box_decoration.dart';
import 'package:thorchain_explorer/_widgets/tc_scaffold.dart';
import 'package:thorchain_explorer/pool/pool_page.dart';

class NetworkPage extends HookWidget {
  final f = NumberFormat.currency(
    symbol: "",
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return TCScaffold(
        currentArea: PageOptions.Network,
        child: Query(
            options: networkPageQueryOptions(),
            // Just like in apollo refetch() could be used to manually trigger a refetch
            // while fetchMore() can be used for pagination purpose
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final network = TCNetwork.fromJson(result.data['network']);

              return LayoutBuilder(builder: (context, constraints) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Network",
                              style: Theme.of(context).textTheme.headline6),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(4.0),
                      child: Container(
                          decoration: containerBoxDecoration(context),
                          padding: EdgeInsets.all(16),
                          child: Table(
                              border: TableBorder.all(
                                  width: 1,
                                  color: Theme.of(context).dividerColor),
                              children: [
                                TableRow(children: [
                                  PaddedTableCell(
                                      child: SelectableText("Bonding APY")),
                                  PaddedTableCell(
                                      child: SelectableText(
                                          "${(network.bondingAPY * 100).toStringAsFixed(2)}%")),
                                ]),
                                TableRow(children: [
                                  PaddedTableCell(
                                      child: SelectableText("Liquidity APY")),
                                  PaddedTableCell(
                                      child: SelectableText(
                                          "${(network.liquidityAPY * 100).toStringAsFixed(2)}%")),
                                ]),
                                TableRow(children: [
                                  PaddedTableCell(
                                      child:
                                          SelectableText("Next Churn Height")),
                                  PaddedTableCell(
                                      child: SelectableText(
                                          network.nextChurnHeight.toString())),
                                ]),
                                TableRow(children: [
                                  PaddedTableCell(
                                      child: SelectableText(
                                          "Pool Activation Countdown")),
                                  PaddedTableCell(
                                      child: SelectableText(network
                                          .poolActivationCountdown
                                          .toString())),
                                ]),
                                TableRow(children: [
                                  PaddedTableCell(
                                      child:
                                          SelectableText("Pool Share Factor")),
                                  PaddedTableCell(
                                      child: SelectableText(
                                          "${(network.poolShareFactor * 100).toStringAsFixed(2)}%")),
                                ]),
                                TableRow(children: [
                                  PaddedTableCell(
                                      child: SelectableText("Total Reserve")),
                                  PaddedTableCell(
                                      child: SelectableText(f.format(
                                          (network.totalReserve / pow(10, 8))
                                              .ceil()))),
                                ]),
                                TableRow(children: [
                                  PaddedTableCell(
                                      child:
                                          SelectableText("Total Pooled RUNE")),
                                  PaddedTableCell(
                                      child: SelectableText(f.format(
                                          network.totalPooledRune /
                                              pow(10, 8).ceil()))),
                                ]),
                              ])),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    constraints.maxWidth < 900
                        ? Container(
                            child: Column(
                              children: [
                                BondsList(
                                    bonds: network.activeBonds,
                                    title: "Top Active Bonds",
                                    nodeCount: network.activeNodeCount,
                                    metrics: network.bondMetrics.active),
                                SizedBox(
                                  height: 32,
                                ),
                                BondsList(
                                    bonds: network.standbyBonds,
                                    nodeCount: network.standbyNodeCount,
                                    title: "Top Standby Bonds",
                                    metrics: network.bondMetrics.standby),
                              ],
                            ),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: BondsList(
                                    bonds: network.activeBonds,
                                    nodeCount: network.activeNodeCount,
                                    title: "Top Active Bonds",
                                    metrics: network.bondMetrics.active),
                              ),
                              SizedBox(
                                width: 32,
                              ),
                              Expanded(
                                child: BondsList(
                                    bonds: network.standbyBonds,
                                    nodeCount: network.standbyNodeCount,
                                    title: "Top Standby Bonds",
                                    metrics: network.bondMetrics.standby),
                              ),
                            ],
                          )
                  ],
                );
              });
            }));
  }
}

class BondsList extends StatelessWidget {
  final List<int> bonds;
  final BondMetricsStat metrics;
  final String title;
  final int nodeCount;

  BondsList({this.bonds, this.title, this.metrics, this.nodeCount});

  final f = NumberFormat.currency(
    symbol: "",
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    bonds.sort((a, b) => b.compareTo(a));
    final topBonds = bonds.sublist(0, (bonds.length > 10) ? 10 : bonds.length);

    return Column(
      children: [
        Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            )),
        Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            decoration: containerBoxDecoration(context),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "Total Bond",
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 12),
                          ),
                          SelectableText(
                              f.format((metrics.totalBond / pow(10, 8).ceil())))
                        ],
                      ),
                    ),
                    Container(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "Average Bond",
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 12),
                          ),
                          SelectableText(f.format(
                              (metrics.averageBond / pow(10, 8).ceil())))
                        ],
                      ),
                    ),
                    Container(
                      width: 100,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "Total Node Count",
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 12),
                          ),
                          SelectableText(nodeCount.toString())
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // padding: EdgeInsets.all(8),
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1, color: Theme.of(context).dividerColor))),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "Maximum Bond",
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 12),
                          ),
                          SelectableText(f.format(
                              (metrics.maximumBond / pow(10, 8).ceil())))
                        ],
                      ),
                    ),
                    Container(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "Median Bond",
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 12),
                          ),
                          SelectableText(f
                              .format((metrics.medianBond / pow(10, 8).ceil())))
                        ],
                      ),
                    ),
                    Container(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "Minimum Bond",
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 12),
                          ),
                          SelectableText(f.format(
                              (metrics.minimumBond / pow(10, 8).ceil())))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              ...topBonds.map((bond) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      border: (bonds.length > 10
                              ? bond != bonds[9]
                              : bond != bonds[bonds.length - 1])
                          ? Border(
                              bottom: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).dividerColor))
                          : null),
                  child: Row(
                    children: [
                      SelectableText(f.format((bond / pow(10, 8)).ceil())),
                    ],
                  ),
                );
              }).toList(),
            ]),
          ),
        ),
      ],
    );
  }
}
