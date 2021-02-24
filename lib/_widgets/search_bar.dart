import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:thorchain_explorer/_widgets/fluid_container.dart';

class ExplorerSearchBar extends HookWidget {
  // final search = useTextEditingController.fromValue(TextEditingValue.empty);

  @override
  Widget build(BuildContext context) {
    final controller =
        useTextEditingController.fromValue(TextEditingValue.empty);
    // final searchListenable = useValueListenable(controller);

    // useEffect(() {
    //   controller.text = update;
    //   return null; // we don't need to have a special dispose logic
    // }, [search]);

    return FluidContainer(
      child: Container(
        child: Row(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.black.withOpacity(0.3)),
              child: TextField(
                onSubmitted: (val) {
                  navigate(context, controller.value.text);
                },
                decoration: InputDecoration.collapsed(
                  hintText: "Enter Transaction ID or Address",
                  border: InputBorder.none,
                ),
                controller: controller,
              ),
            )),
            SizedBox(
              width: 6,
            ),
          ],
        ),
      ),
    );
  }

  void navigate(BuildContext context, String query) {
    final queryCaps = query.toUpperCase();

    if ( // ADDRESS QUERY
        queryCaps.contains('THOR', 0) ||
            queryCaps.contains('TTHOR', 0) // THORCHAIN
            ||
            queryCaps.contains('BNB', 0) ||
            queryCaps.contains('TBNB', 0) // BINANCE CHAIN
            ||
            queryCaps.contains('bc1') ||
            queryCaps.contains('TB1') // BITCOIN
        ) {
      Navigator.pushNamed(context, '/address/$query');
    } else {
      // TX QUERY
      Navigator.pushNamed(context, '/txs/$query');
    }
  }
}
