import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../repository/shift_repository.dart';

final shiftProvider =
    StateNotifierProvider<appointmentViewModel, List<Appointment>>((ref) {
  return appointmentViewModel(
    ref.read,
  );
});

class appointmentViewModel extends StateNotifier<List<Appointment>> {
  final _read;

  appointmentViewModel(this._read) : super([]);

  Future<void> shiftRequest(List<Map<String, DateTime>> shifts) async {
    await _read(shiftRepositoryProvider).addShift(shifts);
  }

  Future<void> shiftManage(int year, int month) async {
    state = await _read(shiftRepositoryProvider).shiftManage(year, month);
  }

  Future<void> shiftView(int year, int month, int day) async {
    state = await _read(shiftRepositoryProvider).shiftView(year, month, day);
  }

  Future<void> statusChange(String id, int status) async {
    await _read(shiftRepositoryProvider).statusChange(id, status);

    state = [
      for (final apo in state)
        if (apo.notes != id) apo,
    ];
  }


}
