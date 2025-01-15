// ignore_for_file: prefer_interpolation_to_compose_strings, deprecated_member_use, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors_in_immutables, avoid_print, must_be_immutable, unnecessary_import
// RECIPE GENERATOR
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nexusgo/pages/model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeGen extends StatefulWidget {
  const RecipeGen({super.key});

  @override
  _RecipeGenState createState() => _RecipeGenState();
}

class _RecipeGenState extends State<RecipeGen> {
  List<Model> list = <Model>[];
  String? text;
  final url =
      'https://api.edamam.com/search?q=rice&app_id=232d458a&app_key=d7140a99e3fb5e29c6d811f46685ea0f&from=0&to=10&calories=591-722&health=alcohol-free';
  getApiData() async {
    var response = await http.get(Uri.parse(url));
    Map json = jsonDecode(response.body);
    json['hits'].forEach((e) {
      Model model = Model(
          image: e['recipe']['image'],
          url: e['recipe']['url'],
          source: e['recipe']['source'],
          label: e['recipe']['label']);
      setState(() {
        list.add(model);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getApiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Recipe Generator'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(
              onChanged: (v) {
                text = v;
              },
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage(
                                      search: text,
                                    )));
                      },
                      icon: const Icon(Icons.search)),
                  hintText: "Search For Recipe",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.green.withOpacity(0.04),
                  filled: true),
            ),
            const SizedBox(
              height: 15,
            ),
            GridView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              primary: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final x = list[i];
                return InkWell(
                    onTap: () {
                      print("Navigating to URL: ${x.url}");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebPage(
                                    url: x.url,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(x.image.toString()))),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: const EdgeInsets.all(3),
                                height: 40,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text(x.label.toString()),
                                )),
                            Container(
                                padding: const EdgeInsets.all(3),
                                height: 40,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text("source: " + x.source.toString()),
                                )),
                          ]),
                    ));
              },
            )
          ]),
        ),
      ),
    );
  }
}

class WebPage extends StatelessWidget {
  final String? url;
  WebPage({
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      launch(url!);
    }
    return Scaffold(
        body: SafeArea(
            child: WebView(
      initialUrl: url,
      javascriptMode: JavascriptMode.unrestricted,
    )));
  }
}

class SearchPage extends StatefulWidget {
  String? search;
  SearchPage({this.search});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Model> list = <Model>[];
  String? text;

  getApiData(search) async {
    final url =
        'https://api.edamam.com/search?q=$search&app_id=232d458a&app_key=d7140a99e3fb5e29c6d811f46685ea0f&from=0&to=10&calories=591-722&health=alcohol-free';

    var response = await http.get(Uri.parse(url));
    Map json = jsonDecode(response.body);
    json['hits'].forEach((e) {
      Model model = Model(
          image: e['recipe']['image'],
          url: e['recipe']['url'],
          source: e['recipe']['source'],
          label: e['recipe']['label']);
      setState(() {
        list.add(model);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getApiData(widget.search);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Recipe'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            GridView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              primary: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final x = list[i];
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebPage(
                                    url: x.url,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(x.image.toString()))),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: const EdgeInsets.all(3),
                                height: 40,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text(x.label.toString()),
                                )),
                            Container(
                                padding: const EdgeInsets.all(3),
                                height: 40,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text("source: " + x.source.toString()),
                                )),
                          ]),
                    ));
              },
            )
          ]),
        ),
      ),
    );
  }
}
