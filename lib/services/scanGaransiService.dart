import '../core.dart';
import 'package:http/http.dart' as http;

class ScanGaransiService {
  Future<Garansi> getGaransiDetails(String barcode) async {
    String apiURL =
        "https://api.firmanindonesia.com/firman/v1/public/halo_firman/garansi/" +
            barcode;
    var headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer fHLBqZDzIiXN9bEAIxbCFOWnqiTWXLjMFAdgiA"
    };
    http.Response apiResult =
        await http.get(Uri.parse(apiURL), headers: headers);
    if (apiResult.statusCode == 200) {
      return garansiFromJson(apiResult.body);
    } else {
      return null;
    }
  }
}
