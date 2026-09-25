import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/seat.dart';

class SeatMatrixWidget extends StatefulWidget {
  final List<Seat> allSeats;
  final List<Seat> selectedSeats;
  final Function(Seat) onSeatTapped;

  const SeatMatrixWidget({
    super.key,
    required this.allSeats,
    required this.selectedSeats,
    required this.onSeatTapped,
  });

  @override
  State<SeatMatrixWidget> createState() => _SeatMatrixWidgetState();
}

class _SeatRowGroup {
  final String rowName;
  final List<Seat> seats;

  const _SeatRowGroup({
    required this.rowName,
    required this.seats,
  });
}

class _SeatMatrixWidgetState extends State<SeatMatrixWidget> {
  List<_SeatRowGroup> _cachedRows = const [];
  List<Seat>? _lastProcessedSeats;

  // Cached static styling to avoid per-seat per-frame allocations
  static final BorderRadius _standardRadius = BorderRadius.circular(10);
  static final BorderRadius _vipRadius = BorderRadius.circular(12);
  static final BorderRadius _twinRadius = BorderRadius.circular(12);

  static final Border _standardAvailableBorder = Border.all(
    color: AppColors.seatAvailableBorder,
    width: 1.2,
  );

  static final Border _standardSelectedBorder = Border.all(
    color: AppColors.primaryLight,
    width: 1.2,
  );

  static const Border _reservedBorder = Border.fromBorderSide(
    BorderSide(color: Colors.transparent, width: 1.2),
  );

  static final Border _vipAvailableBorder = Border.all(
    color: AppColors.accentGold.withValues(alpha: 0.6),
    width: 1.2,
  );

  static final Border _vipSelectedBorder = Border.all(
    color: AppColors.primaryLight,
    width: 1.2,
  );

  static final Border _twinAvailableBorder = Border.all(
    color: AppColors.seatTwin.withValues(alpha: 0.6),
    width: 1.2,
  );

  static final Border _twinSelectedBorder = Border.all(
    color: AppColors.primaryLight,
    width: 1.2,
  );

  static final Color _twinAvailableColor = AppColors.seatTwin.withValues(alpha: 0.2);

  static final List<BoxShadow> _selectedShadow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.5),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> _vipAvailableShadow = [
    BoxShadow(
      color: AppColors.accentGold.withValues(alpha: 0.35),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> _twinSelectedShadow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.4),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static final TextStyle _rowLetterStyle = AppTypography.labelSmall.copyWith(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w800,
  );

  @override
  void initState() {
    super.initState();
    _computeRowGroups();
  }

  @override
  void didUpdateWidget(SeatMatrixWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.allSeats, _lastProcessedSeats) && widget.allSeats != _lastProcessedSeats) {
      _computeRowGroups();
    }
  }

  /// Groups seats by row and pre-sorts them once so that toggling seat selections
  /// does not incur repeated Map allocations and sorting overhead.
  void _computeRowGroups() {
    _lastProcessedSeats = widget.allSeats;
    if (widget.allSeats.isEmpty) {
      _cachedRows = const [];
      return;
    }

    final Map<String, List<Seat>> rowMap = {};
    for (final seat in widget.allSeats) {
      rowMap.putIfAbsent(seat.row, () => []).add(seat);
    }

    final sortedRowNames = rowMap.keys.toList()..sort();
    final List<_SeatRowGroup> groups = [];
    for (final rowName in sortedRowNames) {
      final seatsInRow = List<Seat>.from(rowMap[rowName]!)
        ..sort((a, b) => a.number.compareTo(b.number));
      groups.add(_SeatRowGroup(rowName: rowName, seats: seatsInRow));
    }
    _cachedRows = groups;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allSeats.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // O(1) lookup set for selected seats
    final selectedSeatIds = {for (final s in widget.selectedSeats) s.id};

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _cachedRows.asMap().entries.map((entry) {
            final isLast = entry.key == _cachedRows.length - 1;
            return _buildRow(
              entry.value.rowName,
              entry.value.seats,
              selectedSeatIds,
              isLast: isLast,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRow(
    String rowName,
    List<Seat> seats,
    Set<String> selectedSeatIds, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left Row Letter
          SizedBox(
            width: 24,
            child: Text(
              rowName,
              style: _rowLetterStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // Seats in this row
          ..._buildSeatsWithAisle(seats, selectedSeatIds),

          const SizedBox(width: 12),
          // Right Row Letter
          SizedBox(
            width: 24,
            child: Text(
              rowName,
              style: _rowLetterStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSeatsWithAisle(List<Seat> seats, Set<String> selectedSeatIds) {
    final List<Widget> list = [];

    // Twin Bed Row (Row H)
    if (seats.first.type == SeatType.twinBed) {
      for (var i = 0; i < seats.length; i += 2) {
        if (i + 1 < seats.length) {
          final seat1 = seats[i];
          final seat2 = seats[i + 1];
          final isSelected = selectedSeatIds.contains(seat1.id) || selectedSeatIds.contains(seat2.id);
          final isReserved = seat1.status == SeatStatus.reserved;

          list.add(_TwinBedSeatWidget(
            key: ValueKey(seat1.id),
            seat: seat1,
            isSelected: isSelected,
            isReserved: isReserved,
            onTap: isReserved ? null : () => widget.onSeatTapped(seat1),
          ));
          if (i == 2) {
            list.add(const SizedBox(width: 28)); // Center Aisle
          } else {
            list.add(const SizedBox(width: 10));
          }
        }
      }
      return list;
    }

    // VIP Row (Row G)
    if (seats.first.type == SeatType.vipCouch) {
      for (var i = 0; i < seats.length; i++) {
        final seat = seats[i];
        final isSelected = selectedSeatIds.contains(seat.id);
        final isReserved = seat.status == SeatStatus.reserved;

        list.add(_VipSeatWidget(
          key: ValueKey(seat.id),
          seat: seat,
          isSelected: isSelected,
          isReserved: isReserved,
          onTap: isReserved ? null : () => widget.onSeatTapped(seat),
        ));
        if (i == 3) {
          list.add(const SizedBox(width: 28)); // Center Aisle
        } else {
          list.add(const SizedBox(width: 8));
        }
      }
      return list;
    }

    // Standard / Prime Rows (A to F)
    final midpoint = (seats.length / 2).ceil();
    for (var i = 0; i < seats.length; i++) {
      final seat = seats[i];
      final isSelected = selectedSeatIds.contains(seat.id);
      final isReserved = seat.status == SeatStatus.reserved;

      list.add(_StandardSeatWidget(
        key: ValueKey(seat.id),
        seat: seat,
        isSelected: isSelected,
        isReserved: isReserved,
        onTap: isReserved ? null : () => widget.onSeatTapped(seat),
      ));

      if (i == midpoint - 1) {
        list.add(const SizedBox(width: 26)); // Center Aisle
      } else {
        list.add(const SizedBox(width: 7));
      }
    }

    return list;
  }
}

class _StandardSeatWidget extends StatelessWidget {
  final Seat seat;
  final bool isSelected;
  final bool isReserved;
  final VoidCallback? onTap;

  const _StandardSeatWidget({
    super.key,
    required this.seat,
    required this.isSelected,
    required this.isReserved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeInOut,
          width: 32,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isReserved ? AppColors.seatReserved : AppColors.seatAvailable),
            borderRadius: _SeatMatrixWidgetState._standardRadius,
            border: isReserved
                ? _SeatMatrixWidgetState._reservedBorder
                : (isSelected
                    ? _SeatMatrixWidgetState._standardSelectedBorder
                    : _SeatMatrixWidgetState._standardAvailableBorder),
            boxShadow: isSelected ? _SeatMatrixWidgetState._selectedShadow : const [],
          ),
          alignment: Alignment.center,
          child: isReserved
              ? const Icon(Icons.close_rounded, size: 12, color: AppColors.textTertiary)
              : (seat.type == SeatType.wheelchair
                  ? Icon(
                      Icons.accessible_rounded,
                      size: 15,
                      color: isSelected ? Colors.white : AppColors.accentCyan,
                    )
                  : Text(
                      '${seat.number}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    )),
        ),
      ),
    );
  }
}


class _VipSeatWidget extends StatelessWidget {
  final Seat seat;
  final bool isSelected;
  final bool isReserved;
  final VoidCallback? onTap;

  const _VipSeatWidget({
    super.key,
    required this.seat,
    required this.isSelected,
    required this.isReserved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeInOut,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isReserved
                ? AppColors.seatReserved
                : (isSelected ? AppColors.primary : AppColors.accentGold),
            borderRadius: _SeatMatrixWidgetState._vipRadius,
            border: isReserved
                ? _SeatMatrixWidgetState._reservedBorder
                : (isSelected
                    ? _SeatMatrixWidgetState._vipSelectedBorder
                    : _SeatMatrixWidgetState._vipAvailableBorder),
            boxShadow: isSelected
                ? _SeatMatrixWidgetState._selectedShadow
                : (!isReserved ? _SeatMatrixWidgetState._vipAvailableShadow : const []),
          ),
          alignment: Alignment.center,
          child: isReserved
              ? const Icon(Icons.close_rounded, size: 14, color: AppColors.textTertiary)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                    Text(
                      '${seat.number}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TwinBedSeatWidget extends StatelessWidget {
  final Seat seat;
  final bool isSelected;
  final bool isReserved;
  final VoidCallback? onTap;

  const _TwinBedSeatWidget({
    super.key,
    required this.seat,
    required this.isSelected,
    required this.isReserved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeInOut,
          width: 78,
          height: 38,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isReserved ? AppColors.seatReserved : _SeatMatrixWidgetState._twinAvailableColor),
            borderRadius: _SeatMatrixWidgetState._twinRadius,
            border: isReserved
                ? _SeatMatrixWidgetState._reservedBorder
                : (isSelected
                    ? _SeatMatrixWidgetState._twinSelectedBorder
                    : _SeatMatrixWidgetState._twinAvailableBorder),
            boxShadow: isSelected ? _SeatMatrixWidgetState._twinSelectedShadow : const [],
          ),
          alignment: Alignment.center,
          child: isReserved
              ? const Icon(Icons.close_rounded, size: 14, color: AppColors.textTertiary)
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 13,
                          color: isSelected ? Colors.white : AppColors.seatTwin,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Twin Bed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.seatTwin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
