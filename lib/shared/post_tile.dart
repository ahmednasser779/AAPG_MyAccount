import 'package:aapg_myaccount_flutter/models/post.dart';
import 'package:flutter/material.dart';
import 'custom_image.dart';
import 'package:aapg_myaccount_flutter/screens/pages/post_screen.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);

  showPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return PostScreen(userId: post.ownerId, postId: post.postId);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
