enum LottieAnimation {
  dataNotFound(name: 'data-not-found'),
  empty(name: 'empty'),
  loading(name: 'waiting-pigeon'),
  error(name: 'error'),
  smallError(name: 'small-error');

  final String name;
  const LottieAnimation({required this.name});
}
