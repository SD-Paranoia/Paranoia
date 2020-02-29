import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<http.Response> sendMsg(String msg, String fingerPrint, String ipPort) async{
  var client = http.Client();
   http.Response uriResponse;
  try {
    uriResponse = await client.post(ipPort,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'Message': msg, 'Recipient': fingerPrint})
    );

    if (uriResponse.statusCode == 200){
      //Potentially do something else here
      //print("Message sent successfully!");

    }
    else{
      print("Message failed to send! Code: " + uriResponse.statusCode.toString());
    }
  }
  finally{
    client.close();
  }
  return uriResponse;
}

