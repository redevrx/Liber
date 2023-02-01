import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:liber/core/constant/color.dart';
import 'package:liber/core/constant/divider.dart';
import 'package:liber/core/constant/font.dart';
import 'package:liber/widgets/sliver_box.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kDarked,
      body: CustomScrollView(
        slivers: [
          /**
           * navigation bar
           */
          _navigationBar(),

          ///user info block
          SliverBox(
              maxHeight: size.height * .9,
              maxWidth: double.maxFinite,
              child: Column(
                children: [
                  _statisticCard(context),
                  SizedBox(height: size.height * .02),

                  ///info
                  _infoCard(context),
                  SizedBox(height: size.height * .02),

                  /// friend list
                  LimitedBox(
                    maxHeight: kHeight * 1.6,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return index == 0
                            ? _btnAddFriend(context)
                            : _friendCard(context);
                      },
                    ),
                  ),
                  ///post content card
                  const Placeholder()
                ],
              ))
        ],
      ),
    );
  }

  Padding _friendCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kDefault / 2, vertical: kDefault / 4),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kHeight),
            child: CachedNetworkImage(
              imageUrl:
                  "https://w0.peakpx.com/wallpaper/405/732/HD-wallpaper-violet-evergarden-umbrella-braid-profile-view-anime.jpg",
              memCacheWidth: kHeight ~/ 1.2,
              memCacheHeight: kHeight ~/ 1.2,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefault / 4),
            child: Text(
              "Snake",
              style: kFontLabelSmall(context)?.copyWith(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Column _btnAddFriend(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: kDefault / 1.2, vertical: kDefault / 4),
            width: kHeight / 1.2,
            height: kHeight / 1.2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white)),
            child: const Icon(Icons.add,
                size: kDefault * 1.6, color: Colors.white),
          ),
          Text(
            "New",
            style: kFontLabelSmall(context)?.copyWith(color: Colors.white),
          )
        ]);
  }

  Widget _infoCard(BuildContext context) {
    return Column(
      children: [
        Text("Naked Snake",
            style: kFontMedium(context)
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefault / 3.6),
            child: Text("Flutter Development.",
                style: kFontLabelSmall(context)?.copyWith(color: Colors.grey))),
        Padding(
          padding: const EdgeInsets.only(top: kDefault / 2.6),
          child: Text("Freelance For World.",
              style: kFontLabelSmall(context)?.copyWith(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _statisticCard(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ///post count
        Padding(
          padding: const EdgeInsets.only(right: kDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "100K",
                style: kFontDisplay(context)?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                "post",
                style: kFontSmall(context)?.copyWith(color: Colors.grey),
              )
            ],
          ),
        ),

        ///image profile
        ClipRRect(
          borderRadius: BorderRadius.circular(kHeight),
          child: CachedNetworkImage(
              imageUrl:
                  "https://w0.peakpx.com/wallpaper/405/732/HD-wallpaper-violet-evergarden-umbrella-braid-profile-view-anime.jpg",
              memCacheHeight: (kHeight * 1.2).toInt(),
              memCacheWidth: (kHeight * 1.2).toInt()),
        ),

        ///friend count
        Padding(
          padding: const EdgeInsets.only(left: kDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "100K",
                style: kFontDisplay(context)?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                "Friend",
                style: kFontSmall(context)?.copyWith(color: Colors.grey),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _navigationBar() {
    return const SliverAppBar(
      backgroundColor: Colors.transparent,
      actions: [
        Padding(
          padding: EdgeInsets.only(left: kDefault),
          child: Icon(Icons.add_circle_outline,
              size: kDefault * 1.4, color: Colors.white),
        ),
        Spacer(),
        Padding(
          padding: EdgeInsets.only(right: kDefault),
          child: Icon(Icons.menu, size: kDefault * 1.4, color: Colors.white),
        ),
      ],
    );
  }
}
