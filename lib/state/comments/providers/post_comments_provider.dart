import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/state/comments/extensions/comment_sorting_by_request.dart';
import 'package:instagram_clone/state/comments/models/comment.dart';
import 'package:instagram_clone/state/comments/models/posts_comments_requests.dart';
import 'package:instagram_clone/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone/state/constants/firebase_field_name.dart';

final postCommentsProvider = StreamProvider.family
    .autoDispose<Iterable<Comment>, RequestForPostsAndComments>((ref, request) {
  final controller = StreamController<Iterable<Comment>>();
  final sub = FirebaseFirestore.instance
      .collection(FireBaseCollectionName.comments)
      .where(FireBaseFieldName.postId, isEqualTo: request.postId)
      .snapshots()
      .listen(
    (snapshot) {
      final docs = snapshot.docs;
      final limitedDocs =
          request.limit != null ? docs.take(request.limit!) : docs;
      final comments = limitedDocs
          .where(
            (doc) => !doc.metadata.hasPendingWrites,
          )
          .map(
            (doc) => Comment(
              doc.data(),
              id: doc.id,
            ),
          );
      final result = comments.applySortingFrom(request);
      controller.sink.add(result);
    },
  );
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
