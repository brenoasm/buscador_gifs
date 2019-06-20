import 'dart:convert';

import 'package:flutter/material.dart';

import 'dart:async';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

import 'package:buscador_gifs/ui/gif_page.dart';

const trendingUrl =
    'https://api.giphy.com/v1/gifs/trending?api_key=PMJpwvFXd4zsXJFPDBTs8CbxCF1JVWhG&limit=20&rating=G';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_isNullOrEmpty(_search)) {
      response = await http.get(trendingUrl);
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=PMJpwvFXd4zsXJFPDBTs8CbxCF1JVWhG&q=$_search&limit=19&offset=$_offset&rating=G&lang=en');
    }

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Pesquise aqui',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5,
                        ),
                      );

                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        return _createGifTable(context, snapshot);
                      }
                  }
                }),
          )
        ],
      ),
    );
  }

  bool _isNullOrEmpty(String text) {
    return text == null || text.isEmpty;
  }

  int _getCount(List data) {
    if (_isNullOrEmpty(_search)) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_isNullOrEmpty(_search) || index < snapshot.data['data'].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  height: 300,
                  fit: BoxFit.cover,
                  image: snapshot
                      .data['data'][index]['images']['fixed_height']['url']),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data['data'][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data['data'][index]['images']
                ['fixed_height']['url']);
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70),
                    Text(
                      'Carregar mais...',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        });
  }
}
