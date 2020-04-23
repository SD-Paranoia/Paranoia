import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<http.Response> sendMsg(String msg, String fingerPrint, String signedChallenge, String groupID, String ipPort) async{
  var client = http.Client();
   http.Response uriResponse;
  try {
    uriResponse = await client.post(ipPort+"/write",
      headers: {"Content-Type": "application/json"},
      body: json.encode({"FingerPrint": fingerPrint, "SignedChallenge":signedChallenge,"GroupID":groupID,"Content":msg})
    );

    if (uriResponse.statusCode == 200){
      //Potentially do something else here
      print("Message sent successfully!");

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

Future<http.Response> registerUser(String pubKey, String signature, String ipPort) async {
  var client = http.Client();
  http.Response uriResponse;

  try {
    uriResponse = await client.post("http://" +ipPort+"/reg",
        headers: {"Content-Type": "application/json"},
        body: json.encode({'Public': pubKey, 'Sig': signature})
    );

    if (uriResponse.statusCode == 200){
      print("User registered!");
    }
    else {
      //print();
      print("Failed to register chat");
      print(uriResponse.body.toString());
    }
  }
  finally{
    client.close();
  }
  return uriResponse;
}

Future<http.Response> challengeUser(String fingerPrint, String ipPort) async {
  var client = http.Client();
  http.Response uriResponse;

  try {
    uriResponse = await client.post("http://"+ipPort+"/chal",
        headers: {"Content-Type": "application/json"},
        body: json.encode({'FingerPrint': fingerPrint})
    );

    if (uriResponse.statusCode == 200){
      //TODO -- do something here
      //print(jsonDecode(uriResponse.body));
      Map<String, dynamic> uuid = jsonDecode(uriResponse.body);
      print(uuid.values.toString());
    }
    else {
      print("Failed challenge stage");
    }
  }
  finally{
    client.close();
  }
  return uriResponse;
}

Future<http.Response> createGroup(String members, String fingerPrint, String signedChallenge, String ipPort) async {
  var client = http.Client();
  http.Response uriResponse;

  try {
    uriResponse = await client.post(ipPort+"/convo",
        headers: {"Content-Type": "application/json"},
        body: json.encode({'UUID': "", "Members":[members],"FingerPrint":fingerPrint, "SignedChallenge":signedChallenge})
    );

    if (uriResponse.statusCode == 200){
      //TODO -- do something here
      String response = uriResponse.toString();
      print(response);
    }
    else {
      print("Failed to create group");
    }
  }
  finally{
    client.close();
  }
  return uriResponse;
}

Future<http.Response> getMsg(String fingerPrint, String signedChallenge, String ipPort) async {
  var client = http.Client();
  http.Response uriResponse;

  try {
    uriResponse = await client.post(ipPort+"/read",
        headers: {"Content-Type": "application/json"},
        body: json.encode({'Fingerprint': fingerPrint,"SignedChallenge":signedChallenge})
    );

    if (uriResponse.statusCode == 200){
      //TODO -- do something here
      String response = uriResponse.toString();
      print(response);
    }
    else {
      print("Failed to read message");
    }
  }
  finally{
    client.close();
  }
  return uriResponse;
}
