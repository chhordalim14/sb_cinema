import '../../../../core/usecases/usecase.dart';
import '../entities/ticket.dart';
import '../repositories/booking_repository.dart';

class GetActiveTickets implements UseCase<List<Ticket>, NoParams> {
  final BookingRepository repository;

  GetActiveTickets(this.repository);

  @override
  Future<List<Ticket>> call(NoParams params) {
    return repository.getActiveTickets();
  }
}
