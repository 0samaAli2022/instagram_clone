import 'package:flutter/foundation.dart' show immutable;

@immutable
class FireBaseCollectionName {
  static const users = 'users';
  static const comments = 'comments';
  static const likes = 'likes';
  static const posts = 'posts';
  static const thumbnails = 'thumbnails';
  static const images = 'images';
  const FireBaseCollectionName._();
}
