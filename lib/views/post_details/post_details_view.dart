import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/enums/date_sorting.dart';
import 'package:instagram_clone/state/comments/models/posts_comments_requests.dart';
import 'package:instagram_clone/state/posts/models/post.dart';
import 'package:instagram_clone/state/posts/providers/can_current_user_delete_post_provider.dart';
import 'package:instagram_clone/state/posts/providers/delete_post_provider.dart';
import 'package:instagram_clone/state/posts/providers/specific_post_with_comments_provider.dart';
import 'package:instagram_clone/utils/loading_dialog.dart';
import 'package:instagram_clone/views/components/animations/animation_views.dart';
import 'package:instagram_clone/views/components/comment/comapct_comment_column.dart';
import 'package:instagram_clone/views/components/dialogs/alert_dialog_model.dart';
import 'package:instagram_clone/views/components/dialogs/delete_dialog.dart';
import 'package:instagram_clone/views/components/like_button.dart';
import 'package:instagram_clone/views/components/post/post_date_view.dart';
import 'package:instagram_clone/views/components/post/post_display_name_and_message_view.dart';
import 'package:instagram_clone/views/components/post/post_image_or_video_view.dart';
import 'package:instagram_clone/views/components/post/posts_likes_count_view.dart';
import 'package:instagram_clone/views/constants/strings.dart';
import 'package:instagram_clone/views/post_comment/post_comment_view.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailsView extends ConsumerStatefulWidget {
  final Post post;
  const PostDetailsView({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostDetailsViewState();
}

class _PostDetailsViewState extends ConsumerState<PostDetailsView> {
  @override
  Widget build(BuildContext context) {
    final request = RequestForPostsAndComments(
      postId: widget.post.postId,
      limit: 3,
      sortByCreatedAt: true,
      dateSorting: DateSorting.oldestOnTop,
    );

    // get the actual post along with its comments.
    final postWithComments = ref.watch(
      specificPostWithCommentsProvider(
        request,
      ),
    );

    // can we delete this post?
    final canDeletePost = ref.watch(
      canCurrentUserDeletePostProvider(
        widget.post,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.postDetails),
        actions: [
          postWithComments.when(
            data: (postWithComments) {
              return IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final url = postWithComments.post.fileUrl;
                  Share.share(
                    url,
                    subject: Strings.checkOutThisPost,
                  );
                },
              );
            },
            error: (error, stackTrace) => const SmallErrorAnimationView(),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          // delete button or no delete button if user cannot delete this post
          if (canDeletePost.value ?? false)
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final shouldDeletePost = await DeleteDialog(
                    titleOfObjectToDelete: Strings.post,
                  ).present(context).then(
                        (shouldDelete) => shouldDelete ?? false,
                      );
                  if (shouldDeletePost) {
                    // ignore: use_build_context_synchronously
                    loadingScrean(context, 'Deleting post..');
                    await ref
                        .read(deletePostProvider.notifier)
                        .deletePost(post: widget.post);
                    if (mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  }
                },
              );
            })
        ],
      ),
      body: postWithComments.when(
        data: (postWithComments) {
          final postId = postWithComments.post.postId;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PostImageOrVideoView(
                  post: postWithComments.post,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (postWithComments.post.allowsLikes)
                      LikeButton(
                        postId: postId,
                      ),
                    if (postWithComments.post.allowsComments)
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostCommentView(
                                postId: postId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.mode_comment,
                        ),
                      ),
                  ],
                ),
                // post detail (show divider at bottom)
                PostDisplayNameAndMessageView(post: postWithComments.post),
                PostDateView(dateTime: postWithComments.post.createdAt),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(
                    color: Colors.white70,
                  ),
                ),
                ComapctCommentColumn(comments: postWithComments.comments),
                // display like count
                if (postWithComments.post.allowsLikes)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        PostLikesCountView(
                          postId: postId,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => const ErrorAnimationView(),
        loading: () => const LoadingAnimationView(),
      ),
    );
  }
}
