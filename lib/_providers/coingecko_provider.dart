import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:thorchain_explorer/_classes/coingecko_price.dart';

class CoinGeckoProviderState {

  final double runePrice;

  CoinGeckoProviderState(this.runePrice);
}

class CoinGeckoProvider extends StateNotifier<CoinGeckoProviderState> {

  CoinGeckoProvider() : super(CoinGeckoProviderState(null)) {
    fetchRunePrice();
  }

  Future<void> fetchRunePrice() async {

    print('fetching RUNE price');

    final response = await http.get('https://api.coingecko.com/api/v3/simple/price?ids=thorchain&vs_currencies=usd');

    if (response.statusCode == 200) {
      final price = CoinGeckoPrice.fromJson(jsonDecode(response.body));
      state = CoinGeckoProviderState(price.thorchain.usd);
    } else {
      throw Exception('Failed to load album');
    }

  }

}
