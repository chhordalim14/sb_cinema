import 'package:equatable/equatable.dart';

/// Base UseCase interface for Clean Architecture.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
