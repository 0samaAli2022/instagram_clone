import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/state/comments/models/comment.dart';
import 'package:instagram_clone/state/user_info/providers/user_info_model_provider.dart';
import 'package:instagram_clone/views/components/animations/animation_views.dart';
import 'package:instagram_clone/views/components/rich_two_parts_text_view.dart';

class ComapctCommentTile extends ConsumerWidget {
  final Comment comment;
  const ComapctCommentTile({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoModel = ref.watch(
      userInfoModelProvider(
        comment.fromUserId,
      ),
    );
    return userInfoModel.when(
      data: (userInfoModel) {
        return RichTwoPartsText(
          leftPart: userInfoModel.displayName,
          rightPart: comment.comment,
        );
      },
      error: (error, stackTrace) => const SmallErrorAnimationView(),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
