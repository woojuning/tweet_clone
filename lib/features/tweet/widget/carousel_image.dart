// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselImage extends StatefulWidget {
  List<String> imagesLink;
  CarouselImage({
    Key? key,
    required this.imagesLink,
  }) : super(key: key);

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            CarouselSlider(
              items: widget.imagesLink.map(
                (link) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    margin: EdgeInsets.all(10),
                    child: Image.network(
                      link,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ).toList(),
              options: CarouselOptions(
                viewportFraction: 1, //이게뭐임?
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imagesLink.asMap().entries.map((e) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      _current == e.key ? 0.9 : 0.4,
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        )
      ],
    );
  }
}
