import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:thorchain_explorer/_classes/pool_volume_history.dart';
import 'package:thorchain_explorer/_classes/stats.dart';
import 'package:thorchain_explorer/_classes/tc_network.dart';
import 'package:thorchain_explorer/_gql_queries/gql_queries.dart';
import 'package:thorchain_explorer/_widgets/app_bar.dart';
import 'package:thorchain_explorer/_widgets/fluid_container.dart';
import 'package:thorchain_explorer/dashboard/network_widget.dart';
import 'package:thorchain_explorer/dashboard/stats_widget.dart';
import 'package:thorchain_explorer/dashboard/volume_chart.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    DateTime currentDate = DateTime.now();
    DateTime startDate = currentDate.subtract(Duration(days: 14));

    return Scaffold(
        appBar: ExplorerAppBar(),
        // appBar: AppBar(
        //   title: Text('Network'),
        // ),
        body: Query(
          options: dashboardQueryOptions(startDate, currentDate),
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
          TCNetwork network = TCNetwork.fromJson(result.data['network']);
          PoolVolumeHistory volumeHistory = PoolVolumeHistory.fromJson(result.data['volumeHistory']);
          Stats stats = Stats.fromJson(result.data['stats']);

          return
              LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                  child: FluidContainer(
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Container(
                                child: VolumeChart(volumeHistory),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 16,),
                        constraints.maxWidth < 900
                        ? Container(
                          child: Column(
                            children: [
                              StatsWidget(stats),
                              SizedBox(height: 16,),
                              NetworkWidget(network),
                            ],
                          ),
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: StatsWidget(stats),
                            ),
                            SizedBox(width: 16,),
                            Expanded(
                              child: NetworkWidget(network),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
              );
           });
        })
    );
  }
}
