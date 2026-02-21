enum BlocStatus {
  initial,
  success,
  error,
  loading;

  bool get isInitial => this == BlocStatus.initial;

  bool get isSuccess => this == BlocStatus.success;

  bool get isError => this == BlocStatus.error;

  bool get isLoading => this == BlocStatus.loading;
}
