import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/state/comments/extensions/comment_sorting_by_request.dart';
import 'package:instagram_clone/state/comments/models/comment.dart';
import 'package:instagram_clone/state/comments/models/post_with_comments.dart';
import 'package:instagram_clone/state/comments/models/posts_comments_requests.dart';
import 'package:instagram_clone/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone/state/constants/firebase_field_name.dart';
import 'package:instagram_clone/state/posts/models/post.dart';

final specificPostWithCommentsProvider = StreamProvider.family
    .autoDispose<PostWithComments, RequestForPostsAndComments>(
        (ref, requestForPostsAndComments) {
  final controller = StreamController<PostWithComments>();
  Post? post;
  Iterable<Comment>? comments;

  void notify() {
    final localPost = post;
    if (localPost == null) {
      return;
    }
    final outputComments = (comments ?? []).applySortingFrom(
      requestForPostsAndComments,
    );
    final result = PostWithComments(
      post: localPost,
      comments: outputComments,
    );
    controller.sink.add(result);
  }

  final postSub = FirebaseFirestore.instance
      .collection(FireBaseCollectionName.posts)
      .where(
        FieldPath.documentId,
        isEqualTo: requestForPostsAndComments.postId,
      )
      .limit(1)
      .snapshots()
      .listen(
    (snapshot) {
      if (snapshot.docs.isEmpty) {
        post = null;
        comments = null;
        notify();
        return;
      }
      final doc = snapshot.docs.first;
      if (doc.metadata.hasPendingWrites) return;
      post = Post(
        postId: doc.id,
        json: doc.data(),
      );
      notify();
    },
  );

  final commentsQuery = FirebaseFirestore.instance
      .collection(FireBaseCollectionName.comments)
      .where(
        FireBaseFieldName.postId,
        isEqualTo: requestForPostsAndComments.postId,
      )
      .orderBy(
        FireBaseFieldName.createdAt,
        descending: true,
      );

  final limitedCommentsQuery = requestForPostsAndComments.limit != null
      ? commentsQuery.limit(requestForPostsAndComments.limit!)
      : commentsQuery;

  final commentsSub = limitedCommentsQuery.snapshots().listen(
    (snapshot) {
      if (snapshot.docs.isEmpty) {
        comments = null;
        notify();
        return;
      }
      comments = snapshot.docs
          .where(
            (doc) => !doc.metadata.hasPendingWrites,
          )
          .map(
            (doc) => Comment(
              id: doc.id,
              doc.data(),
            ),
          )
          .toList();
      notify();
    },
  );

  ref.onDispose(() {
    postSub.cancel();
    commentsSub.cancel();
    controller.close();
  });
  return controller.stream;
});
