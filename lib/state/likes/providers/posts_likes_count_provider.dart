import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone/state/constants/firebase_field_name.dart';
import 'package:instagram_clone/state/posts/typedefs/post_id.dart';

final postLikesCountProvider =
    StreamProvider.family.autoDispose<int, PostId>((ref, postId) {
  final controller = StreamController<int>.broadcast();

  controller.onListen = () {
    controller.sink.add(0);
  };

  final sub = FirebaseFirestore.instance
      .collection(FireBaseCollectionName.likes)
      .where(FireBaseFieldName.postId, isEqualTo: postId)
      .snapshots()
      .listen(
    (snapshots) {
      controller.sink.add(
        snapshots.docs.length,
      );
    },
  );

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
