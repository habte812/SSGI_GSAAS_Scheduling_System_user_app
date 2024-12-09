
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSliderWidget extends StatefulWidget {
  const CarouselSliderWidget({super.key});

  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {

  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

Future<void> _fetchImages() async {
  List<String> imageUrls = [];
  try {
    for (int i = 0; i < 3; i++) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('grid_item_$i') // Collection name
          .doc('image') // Document ID
          .get();

      if (docSnapshot.exists) {
        final imageUrl = docSnapshot.get('url'); // Field name where the image URL is stored
        imageUrls.add(imageUrl);
      } else {
        print('Document does not exist for grid_item_$i');
      }
    }
    setState(() {
      _imageUrls = imageUrls;
    });
  } catch (e) {
    print('Error fetching images: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: _imageUrls.isEmpty
          ? [0, 1, 2].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );
            }).toList()
          : _imageUrls.map((url) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
    );
  }
}
