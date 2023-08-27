import 'package:flutter/material.dart';
import 'package:instagram_clone/state/comments/models/comment.dart';
import 'package:instagram_clone/views/components/comment/comapct_comment_tile.dart';

class ComapctCommentColumn extends StatelessWidget {
  final Iterable<Comment> comments;
  const ComapctCommentColumn({
    super.key,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return comments.isEmpty
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: comments
                  .map((comment) => ComapctCommentTile(comment: comment))
                  .toList(),
            ),
          );
  }
}
