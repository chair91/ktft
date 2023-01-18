import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitty/bloc/date_bloc/date_bloc.dart';
import 'package:kitty/models/entry_model/entry.dart';
import 'package:kitty/resources/app_colors.dart';
import 'package:kitty/resources/app_text_styles.dart';
import 'package:kitty/widgets/month_picker/overlay_calendar_window.dart';

class MonthPicker extends StatefulWidget {
  const MonthPicker({
    Key? key,
    required this.entries,
  }) : super(key: key);
  final List<Entry> entries;

  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  OverlayEntry? _overlayEntry;
  OverlayState? _overlay;

  @override
  void dispose() {
    _overlayDispose();
    super.dispose();
  }

  void _overlayDispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  final List<String> listOfMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final DateBloc provider = DateBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => provider..add(InitialDateEvent(widget.entries)),
      child: BlocBuilder<DateBloc, DateState>(
        builder: (context, state) {
          if (state.selectedYear == 0) {
            return Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppColors.basicGrey),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.subTitle,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${listOfMonths[DateTime.now().month - 1]}, ${DateTime.now().year}',
                      style: AppStyles.buttonBlack,
                    )
                  ],
                ),
              ),
            );
          }
          final bool back = state.allYears.contains(state.selectedYear - 1) ||
              state.selectedMonth != state.activeMonths.last &&
                  state.selectedYear == state.year;

          final bool forward =
              state.allYears.contains(state.selectedYear + 1) ||
                  state.selectedMonth != state.activeMonths.first &&
                      state.selectedYear == state.year;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: back
                    ? () {
                        context
                            .read<DateBloc>()
                            .add(CallMonthDateEvent('back'));
                      }
                    : null,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: back ? AppColors.subTitle : Colors.white,
                ),
              ),
              InkWell(
                onTap: () {
                  _showOverlay(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppColors.basicGrey),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.subTitle,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '${listOfMonths[state.selectedMonth - 1]}, ${state.selectedYear}',
                        style: AppStyles.buttonBlack,
                      )
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: forward
                    ? () {
                        context
                            .read<DateBloc>()
                            .add(CallMonthDateEvent('forward'));
                      }
                    : null,
                icon: Icon(Icons.arrow_forward_ios,
                    color: forward ? AppColors.subTitle : Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  _showOverlay(BuildContext context) {
    _overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(builder: (_) {
      return BlocProvider.value(
        value: BlocProvider.of<DateBloc>(context),
        child: Stack(children: [
          InkWell(
            onTap: () {
              // context.read<DateBloc>().add(ToSelectedDateEvent());
              _overlayDispose();
            },
          ),
          Positioned(
              width: size.width,
              top: offset.dy + size.height,
              left: offset.dx,
              child: OverlayCalendarWindow(
                listOfMonths: listOfMonths,
              ))
        ]),
      );
    });
    _overlay!.insert(_overlayEntry!);
  }
}
