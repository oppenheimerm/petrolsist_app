import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerMapLoading extends StatelessWidget {
  const ShimmerMapLoading({super.key});

  @override
  Widget build(BuildContext context) {

    double getScreenWidth() {
      double width = MediaQuery.of(context).size.width;
      var value = width * (80/width);
      debugPrint("Screen width: $value ");
      return value;
    }

    double getScreenHeight(){
      double height = MediaQuery.of(context).size.height;
      var value = height * (80/height);
      debugPrint("Screen height: $value ");
      return value;
    }



    //  A widget that aligns its child within itself and optionally sizes
    //  itself based on the child's size.  For example, to align a box at
    //  the bottom right, you would pass this box a tight constraint that
    //  is bigger than the child's natural size, with an alignment of
    //  Alignment.bottomRight.
    //
    //  https://api.flutter.dev/flutter/widgets/Align-class.html?gclid=CjwKCAiAs6-sBhBmEiwA1Nl8s7CpN_4ekXRnO5cInnBfLGOFj2raxRWztQWu_SF5-vD1Vib9sat7VBoCoAoQAvD_BwE&gclsrc=aw.ds
    return Align(
      //  If non-null, sets its height to the child's height multiplied by this factor.
      heightFactor: 1.0,
      child: SizedBox(
        //width: ()getScreenWidth() ?,
        child: Shimmer.fromColors(
          baseColor: Colors.white60,
            highlightColor: Colors.white70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: getScreenWidth(),
                height: getScreenHeight(),
                color: Colors.white,
              )
            ],
          )),
        ),
      );
  }
}

/*class SquareItem extends StatelessWidget{
  const SquareItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            'https://docs.flutter.dev/cookbook'
                '/img-files/effects/split-check/Avatar1.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

}*/