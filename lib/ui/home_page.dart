import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'gif_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const limit = 19;

  late Future<Map> gifsFuture;

  String _search = '';
  int _offset = 0;

  Future<Map> _getGifs() async {
    if (_search.isEmpty) {
      return {};
    }

    http.Response response;
    response = await http.get(Uri.parse(
        'https://api.giphy.com/v1/gifs/search?api_key=IyO7FLT2n9WFb7wJA4qx1cXf68IoBq42&q=$_search&limit=$limit&offset=$_offset&rating=g&lang=pt'));

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    gifsFuture = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        centerTitle: true,
        title: Image.network(
          'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif',
        ),
      ),
      backgroundColor: Colors.black38,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquise seu gif:',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });

                gifsFuture = _getGifs();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: gifsFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    debugPrint('TESTE: ${snapshot.data}');
                    if (snapshot.hasError || snapshot.data?['data'] == null) {
                      return const SizedBox();
                    } else {
                      final data = snapshot.data!['data'];

                      if (data.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum gif encontrado!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: data.length + 1,
                        itemBuilder: (context, index) {
                          if (index == data.length) {
                            return GestureDetector(
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 60.0,
                                  ),
                                  Text(
                                    'Carregar mais...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (data.length < limit) {
                                  return;
                                }

                                setState(() {
                                  _offset += limit;
                                });

                                gifsFuture = _getGifs();
                              },
                            );
                          }

                          final image =
                              data[index]['images']['fixed_height']['url'];

                          return GestureDetector(
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: image,
                              height: 300.0,
                              fit: BoxFit.cover,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GifPage(
                                    gifData: data[index],
                                  ),
                                ),
                              );
                            },
                            onLongPress: () => Share.share(image),
                          );
                        },
                      );
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
