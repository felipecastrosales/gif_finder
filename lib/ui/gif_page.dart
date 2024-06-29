import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  const GifPage({
    super.key,
    required this.gifData,
  });

  final Map gifData;

  @override
  Widget build(BuildContext context) {
    final image = gifData['images']['fixed_height']['url'];

    return Scaffold(
      appBar: AppBar(
        title: Text(gifData['title']),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(image),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(image),
      ),
    );
  }
}
