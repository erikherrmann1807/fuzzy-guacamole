import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/providers/meetings_provider.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';
import 'package:gap/gap.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';

class MonthlyScreen extends ConsumerStatefulWidget {
  const MonthlyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends ConsumerState<MonthlyScreen> {
  late DateTime currentMonth;
  late List<DateTime> datesGrid;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    datesGrid = _generateDatesGrid(currentMonth);
    selectedDate = DateTime.now();
  }

  List<DateTime> _generateDatesGrid(DateTime month) {
    int numDays = DateTime(month.year, month.month + 1, 0).day;
    // In Dart: weekday 1 = Monday ... 7 = Sunday. Wir wollen Anzahl "Vortage" (Montag-start)
    int firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1..7
    // Convert to how many previous days to show: if firstWeekday == 1 (Mon) -> 0
    int prevDaysToShow = (firstWeekday - 1);
    List<DateTime> dates = [];

    DateTime previousMonth = DateTime(month.year, month.month - 1);
    int previousMonthLastDay =
        DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
    for (int i = prevDaysToShow; i > 0; i--) {
      dates.add(DateTime(previousMonth.year, previousMonth.month,
          previousMonthLastDay - i + 1));
    }

    for (int day = 1; day <= numDays; day++) {
      dates.add(DateTime(month.year, month.month, day));
    }

    int remainingBoxes = 42 - dates.length; // 6 weeks * 7 days
    for (int day = 1; day <= remainingBoxes; day++) {
      dates.add(DateTime(month.year, month.month + 1, day));
    }

    return dates;
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
      datesGrid = _generateDatesGrid(currentMonth);
    });
  }

  Map<DateTime, List<T>> _buildMeetingsMap<T extends Object>(List<T> meetings, DateTime Function(T) getStartDate) {
    final Map<DateTime, List<T>> map = {};
    for (final m in meetings) {
      final start = getStartDate(m);
      final key = DateTime(start.year, start.month, start.day);
      map.putIfAbsent(key, () => []).add(m);
    }
    for (final list in map.values) {
      list.sort((a, b) {
        final aDt = getStartDate(a);
        final bDt = getStartDate(b);
        return aDt.compareTo(bDt);
      });
    }
    return map;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final meetingsAsync = ref.watch(meetingStreamProvider);
    Size size = MediaQuery.sizeOf(context);

    return meetingsAsync.when(
      data: (meetings) {
        final meetingsByDay = _buildMeetingsMap(meetings, (m) {
          final dyn = m as dynamic;
          return dyn.start as DateTime;
        });

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      '${_monthName(currentMonth.month)} ${currentMonth.year}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                //const Gap(5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      7,
                          (index) => Text(
                        ['Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.', 'So.'][index],
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ),
                ),
                //const Gap(12),
                Expanded(
                    child: GridView.builder(
                      //physics: AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7),
                      itemCount: datesGrid.length,
                      itemBuilder: (context, index) {
                        DateTime date = datesGrid[index];
                        bool isCurrentMonth = date.month == currentMonth.month;
                        bool isSelected = selectedDate.year == date.year &&
                            selectedDate.month == date.month &&
                            selectedDate.day == date.day;
                        final key = DateTime(date.year, date.month, date.day);
                        final todayMeetings = meetingsByDay[key] ?? [];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected
                                      ? MyColors.raisinBlack
                                      : (isCurrentMonth ? MyColors.grey : Colors.transparent),
                                  child: Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : (isCurrentMonth ? Colors.black : Colors.grey),
                                    ),
                                  ),
                                ),
                                if (todayMeetings.isNotEmpty)
                                  Positioned(
                                    bottom: 7,
                                    right: 7,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        todayMeetings.length.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ),
                const Divider(),
                SizedBox(
                  height: size.height * 0.3,
                  child: Container(
                    width: size.width,
                    //margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(1.5, 2),
                            spreadRadius: 2,
                            blurStyle: BlurStyle.solid),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agenda für ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                          style: agendaDateText,
                        ),
                        const Gap(4),
                        Expanded(
                          child: Builder(builder: (_) {
                            final key = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                            final today = meetingsByDay[key] ?? [];
                            if (today.isEmpty) {
                              return const Center(child: Text('Keine Termine'));
                            }
                            return ListView.separated(
                              itemCount: today.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, idx) {
                                final mt = today[idx];
                                final startTime = _formatTime(mt.start);
                                final endTime = _formatTime(mt.end);
                                final description = mt.description;
                                final backgroundColor = mt.backgroundColor;
                                return SizedBox(
                                  height: 60,
                                  child: Container(
                                    color: backgroundColor,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.snowboarding),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(mt.eventName),
                                            Text('$startTime-$endTime${description.isNotEmpty ? ' • $description' : ''}'),
                                          ],
                                        ),
                                        Icon(Icons.flag)
                                      ],
                                    ),
                                  )
                                  /*
                                  Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Icon(Icons.ac_unit),
                                      ),
                                      tileColor: backgroundColor,
                                      title: Text(mt.eventName),
                                      subtitle: Text('$startTime-$endTime${description.isNotEmpty ? ' • $description' : ''}'),
                                      onTap: () {
                                        //TODO: Implement opening editor with current values
                                      },
                                    ),
                                  ),

                                   */
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Fehler beim Laden: $err')),
    );
  }

  String _monthName(int monthNumber) {
    return [
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
      'December'
    ][monthNumber - 1];
  }
}