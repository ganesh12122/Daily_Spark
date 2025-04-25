import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:confetti/confetti.dart';
import '../../core/models/discipline_manager.dart';
import '../../core/providers/discipline_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/notification_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/motivational_quote_widget.dart';
import '../widgets/discipline_item_widget.dart';

class DailySparkScreen extends StatefulWidget {
  const DailySparkScreen({super.key});

  @override
  State<DailySparkScreen> createState() => _DailySparkScreenState();
}

class _DailySparkScreenState extends State<DailySparkScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final NotificationService _notificationService;
  late Timer _secondsWastedTimer;
  late Timer _pomodoroTimer;
  int _secondsWasted = 0;
  int _pomodoroSeconds = 25 * 60;
  bool _pomodoroActive = false;
  bool _isPaused = false;
  late AnimationController _pulseController;
  late AnimationController _badgeScaleController;
  late AnimationController _quoteFadeController;
  late ConfettiController _confettiController;
  bool _showAchievement = false;
  String _achievementLevel = 'none';
  String _achievementMessage = '';
  bool _showMilestone = false;
  DisciplineManager? _milestoneDiscipline;
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  List<DisciplineManager> _displayedList = [];

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _badgeScaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _quoteFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _initializeNotifications();
    _startTimers();
    _checkAchievements();
    AnalyticsService.logEvent('app_opened');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DisciplineProvider>(context, listen: false);
      _displayedList = List.from(provider.list);
      _checkMilestones(provider);
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      final granted = await _notificationService.requestNotificationPermission();
      if (granted) {
        await _notificationService.scheduleDailyReminders();
      } else {
        debugPrint('Notification permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  void _startTimers() {
    _secondsWastedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) setState(() => _secondsWasted++);
    });

    _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_pomodoroActive && _pomodoroSeconds > 0) {
        setState(() => _pomodoroSeconds--);
        if (_pomodoroSeconds == 0) {
          _playPomodoroChime();
          _stopPomodoro();
        }
      }
    });
  }

  void _playPomodoroChime() {
    _audioPlayer.play(AssetSource('sounds/chime.mp3'));
    HapticFeedback.mediumImpact();
  }

  void _checkAchievements() {
    final provider = Provider.of<DisciplineProvider>(context, listen: false);
    final level = provider.achievementLevel;
    if (level != 'none') {
      setState(() {
        _showAchievement = true;
        _achievementLevel = level;
        _badgeScaleController.forward();
      });
      if (level == 'gold') {
        _achievementMessage = 'MASTER OF DISCIPLINE! You completed all tasks today!';
        _notificationService.showAchievementNotification(
          '🏆 Gold Badge Earned!',
          'You completed 100% of your disciplines today! Legendary!',
        );
        AnalyticsService.logEvent('gold_badge_earned');
      } else {
        _achievementMessage = 'Good progress! You completed most tasks today';
        _notificationService.showAchievementNotification(
          '🥈 Silver Badge Earned!',
          'You completed 75%+ of your disciplines today! Keep pushing!',
        );
        AnalyticsService.logEvent('silver_badge_earned');
      }
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showAchievement = false;
            _badgeScaleController.reset();
          });
        }
      });
    } else if (provider.list.isNotEmpty && provider.todayCompletionRate < 0.5) {
      _showFailureWarning();
    }
  }

  void _checkMilestones(DisciplineProvider provider) {
    for (var i = 0; i < provider.list.length; i++) {
      final discipline = provider.list[i];
      if (discipline.hasCommitment && discipline.streak >= 48 && discipline.stars >= 1 && discipline.stars == (discipline.streak / 48).floor()) {
        setState(() {
          _showMilestone = true;
          _milestoneDiscipline = discipline;
        });
        _confettiController.play();
        _notificationService.showAchievementNotification(
          '🌟 Milestone Achieved!',
          'You reached ${discipline.stars} star(s) for "${discipline.discipline}"! Keep forging your will!',
        );
        AnalyticsService.logEvent('milestone_achieved', params: {'stars': discipline.stars});
        break;
      } else if (!discipline.hasCommitment && discipline.streak >= 7 && discipline.stars == 1) {
        setState(() {
          _showMilestone = true;
          _milestoneDiscipline = discipline;
        });
        _confettiController.play();
        _notificationService.showAchievementNotification(
          '🎉 Quick Win Achieved!',
          'You nailed "${discipline.discipline}" for 7 days straight! Great job!',
        );
        AnalyticsService.logEvent('quick_win_achieved', params: {'discipline': discipline.discipline});
        break;
      }
    }
  }

  void _showFailureWarning() {
    final provider = Provider.of<DisciplineProvider>(context, listen: false);
    final completed = provider.list.where((d) => d.isDone).length;
    final total = provider.list.length;
    _notificationService.showAchievementNotification(
      '⚠️ Discipline Failure',
      'You only completed $completed/$total tasks! Try harder tomorrow!',
    );
    AnalyticsService.logEvent('failure_warning', params: {'completed': completed, 'total': total});
  }

  void _startPomodoro() {
    setState(() {
      _pomodoroActive = true;
      _pomodoroSeconds = 25 * 60;
      _isPaused = true;
    });
    HapticFeedback.lightImpact();
    AnalyticsService.logEvent('pomodoro_started');
  }

  void _stopPomodoro() {
    setState(() {
      _pomodoroActive = false;
      _isPaused = false;
    });
    HapticFeedback.lightImpact();
    AnalyticsService.logEvent('pomodoro_stopped');
  }

  void _resetPomodoro() {
    setState(() {
      _pomodoroSeconds = 25 * 60;
      _pomodoroActive = false;
      _isPaused = false;
    });
    HapticFeedback.lightImpact();
    AnalyticsService.logEvent('pomodoro_reset');
  }

  String _formatTime(int seconds) {
    final duration = Duration(seconds: seconds);
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>?> _showCommitmentWarning() async {
    bool commitTo48Days = true;
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Commitment Warning'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Do you want to commit to this discipline for 48 days? If you choose the commitment, '
                    'you can only delete it after achieving a 48-day streak. If not, you can delete it anytime, '
                    'but you’ll earn a Quick Win badge for shorter goals (7-day streak).',
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('Commit to 48 days'),
                value: commitTo48Days,
                onChanged: (value) => setState(() => commitTo48Days = value ?? true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop({
                'confirmed': true,
                'hasCommitment': commitTo48Days,
              }),
              child: const Text('I’m In!'),
            ),
          ],
        ),
      ),
    );
  }

  void _addDiscipline(DisciplineProvider provider, String discipline) async {
    final result = await _showCommitmentWarning();
    if (result != null && result['confirmed'] == true && mounted) {
      provider.addNewDiscipline(discipline, result['hasCommitment']);
      _displayedList.add(provider.list.last);
      _listKey.currentState?.insertItem(_displayedList.length - 1);
      HapticFeedback.lightImpact();
      AnalyticsService.logEvent('discipline_added', params: {'hasCommitment': result['hasCommitment']});
    }
  }

  void _removeDiscipline(DisciplineProvider provider, int index) {
    final removedDiscipline = _displayedList[index];
    _displayedList.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => DisciplineItemWidget(
        discipline: removedDiscipline,
        index: index,
        animation: animation,
        onToggle: (_) {},
        onDismiss: (direction) => _handleDismiss(direction, index, provider),
        onSetReminder: () => _handleSetReminder(index, provider),
      ),
      duration: const Duration(milliseconds: 300),
    );
    provider.removeDiscipline(index);
    HapticFeedback.lightImpact();
    AnalyticsService.logEvent('discipline_deleted');
  }

  Future<bool?> _handleDismiss(DismissDirection direction, int index, DisciplineProvider provider) async {
    if (direction == DismissDirection.startToEnd) {
      final discipline = _displayedList[index];
      if (!provider.canDeleteDiscipline(discipline)) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('You must achieve a 48-day streak before deleting "${discipline.discipline}"!')),
          );
        }
        return false;
      }
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Discipline Milestone'),
          content: Text(
            'You’ve reached a ${discipline.stars} star milestone for "${discipline.discipline}"! '
                'Do you want to delete this discipline or renew it for another 48 days?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop('renew'), child: const Text('Renew')),
            TextButton(onPressed: () => Navigator.of(ctx).pop('delete'), child: const Text('Delete')),
          ],
        ),
      );
      if (choice == 'delete') {
        _removeDiscipline(provider, index);
        return true;
      } else if (choice == 'renew') {
        discipline.streak = 0;
        discipline.isDone = false;
        discipline.lastCompleted = DateTime.now();
        provider.removeDiscipline(index);
        provider.addNewDiscipline(discipline.discipline, discipline.hasCommitment);
        return false;
      }
      return false;
    } else {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: _displayedList[index].reminderTime ?? TimeOfDay.now(),
      );
      if (!mounted) return false;
      if (selectedTime != null) {
        provider.updateReminder(index, selectedTime);
        _displayedList[index] = provider.list[index];
        HapticFeedback.lightImpact();
        AnalyticsService.logEvent('reminder_set');
      }
      return false;
    }
  }

  void _handleSetReminder(int index, DisciplineProvider provider) async {
    final initialTime = _displayedList[index].reminderTime ?? TimeOfDay.now();
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (!mounted) return;
    if (selectedTime != null) {
      provider.updateReminder(index, selectedTime);
      _displayedList[index] = provider.list[index];
      HapticFeedback.lightImpact();
      AnalyticsService.logEvent('reminder_set');
    }
  }

  void _showStatistics(BuildContext context, DisciplineProvider provider) {
    final completedToday = provider.list.where((d) => d.isDone).length;
    final totalTasks = provider.list.length;
    final completionRate = totalTasks > 0 ? (completedToday / totalTasks) * 100 : 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Discipline Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow(
                '🔥 Longest Streak',
                provider.list.isNotEmpty
                    ? provider.list.map((d) => d.streak).reduce((a, b) => a > b ? a : b).toString()
                    : '0',
                Colors.orange),
            _buildStatRow('✅ Completed Today', '$completedToday/$totalTasks',
                completionRate > 80 ? Colors.green : completionRate > 50 ? Colors.orange : Colors.red),
            _buildStatRow('📅 Total Disciplines', totalTasks.toString(), Colors.blue),
            _buildStatRow('🏅 Gold Medals', provider.totalMedals.toString(), Colors.amber),
            _buildStatRow('🎉 Quick Wins', provider.quickWins.toString(), Colors.purple),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: totalTasks > 0 ? completedToday / totalTasks : 0,
              backgroundColor: Colors.grey[300],
              color: completionRate > 80
                  ? Colors.green
                  : completionRate > 50
                  ? Colors.orange
                  : Colors.red,
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text(
              '${completionRate.toStringAsFixed(1)}% of today\'s goals',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CLOSE')),
        ],
      ),
    );
    AnalyticsService.logEvent('stats_viewed');
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About SparkVow'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔥 THE ULTIMATE DISCIPLINE BUILDER 🔥\n'
                  'This app is designed for warriors who refuse to waste time.\n'
                  'Every second counts. Every discipline matters.\n'
                  'Features:\n'
                  '- Track daily disciplines\n'
                  '- Build unbreakable streaks\n'
                  '- Time wasting counter\n'
                  '- Focus timer\n'
                  '- Hardcore motivation\n'
                  'Version: ${packageInfo.version}\n'
                  'Beta Release',
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final url = Uri.parse('https://raw.githubusercontent.com/ganesh12122/Spark_Vow/refs/heads/main/privacy_policy.md');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final url = Uri.parse(
                'mailto:peacemakers.dev@gmail.com?subject=SparkVow%20Beta%20Feedback&body=Hi%20SparkVow%20Team,%0D%0A%0D%0AI%27m%20using%20version%20${packageInfo.version}.%20Here%27s%20my%20feedback:%0D%0A',
              );
              if (await canLaunchUrl(url) && mounted) {
                await launchUrl(url);
              }
              AnalyticsService.logEvent('feedback_prompt_opened');
              Navigator.of(ctx).pop();
            },
            child: const Text('SEND FEEDBACK'),
          ),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CLOSE')),
        ],
      ),
    );
    AnalyticsService.logEvent('about_viewed');
  }

  @override
  void dispose() {
    _secondsWastedTimer.cancel();
    _pomodoroTimer.cancel();
    _pulseController.dispose();
    _badgeScaleController.dispose();
    _quoteFadeController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disciplineProvider = Provider.of<DisciplineProvider>(context);
    final theme = Theme.of(context);
    final today = DateTime.now();
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Warrior Greeting with improved design
                    Stack(
                      children: [
                        // Text shadow for depth
                        Text(
                          '"HELLO WARRIOR"',
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Roboto', // Use a more impactful font
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.deepPurple,
                          ),
                        ),
                        // Main text
                      ],
                    ),
                    // Action buttons with better styling
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Theme toggle button
                          IconButton(
                            icon: Icon(
                              disciplineProvider.darkMode
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              size: 24,
                            ),
                            tooltip: 'Toggle theme',
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: () {
                              disciplineProvider.toggleDarkMode();
                              HapticFeedback.lightImpact();
                              AnalyticsService.logEvent('theme_toggled',
                                  params: {'dark_mode': disciplineProvider.darkMode});
                            },
                          ),
                          // Stats button
                          IconButton(
                            icon: const Icon(
                              Icons.leaderboard_rounded,
                              size: 24,
                            ),
                            tooltip: 'View stats',
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: () {
                              _showStatistics(context, disciplineProvider);
                            },
                          ),
                          // Info button
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              size: 24,
                            ),
                            tooltip: 'About app',
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: () {
                              _showAboutDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TIME WASTED:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$_secondsWasted s',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text(
                            'FOCUS TIMER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(_pomodoroSeconds),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _pomodoroActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_pomodoroActive)
                                ScaleTransition(
                                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                    CurvedAnimation(
                                      parent: _pulseController,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _startPomodoro,
                                    child: const Text('START'),
                                  ),
                                )
                              else
                                ScaleTransition(
                                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                    CurvedAnimation(
                                      parent: _pulseController,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _stopPomodoro,
                                    child: const Text('STOP'),
                                  ),
                                ),
                              const SizedBox(width: 10),
                              ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _pulseController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _resetPomodoro,
                                  child: const Text('RESET'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          DateFormat('EEEE, MMMM d, y').format(today),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Add a new discipline (e.g., "Morning Run")',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle, size: 32),
                            onPressed: () {
                              if (_controller.text.trim().isNotEmpty) {
                                _addDiscipline(disciplineProvider, _controller.text.trim());
                                _controller.clear();
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _addDiscipline(disciplineProvider, value.trim());
                            _controller.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _quoteFadeController,
                    child: MotivationalQuoteWidget(),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 80.0),
              sliver: _displayedList.isEmpty
                  ? SliverFillRemaining(
                child: EmptyStateWidget(),
              )
                  : SliverAnimatedList(
                key: _listKey,
                initialItemCount: _displayedList.length,
                itemBuilder: (context, index, animation) {
                  return DisciplineItemWidget(
                    discipline: _displayedList[index],
                    index: index,
                    animation: animation,
                    onToggle: (value) async {
                      final provider = Provider.of<DisciplineProvider>(context, listen: false);
                      if (value == false && _displayedList[index].isDone) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Reset Completion'),
                            content: const Text(
                              'This will reset your streak if this was today\'s completion!',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                      }
                      provider.toggleCompletion(index);
                      _displayedList[index] = provider.list[index];
                      _checkAchievements();
                      _checkMilestones(provider);
                      HapticFeedback.lightImpact();
                      AnalyticsService.logEvent('discipline_toggled', params: {'is_done': value});
                    },
                    onDismiss: (direction) => _handleDismiss(direction, index, disciplineProvider),
                    onSetReminder: () => _handleSetReminder(index, disciplineProvider),
                  );
                },
              ),
            ),
          ],
        ),
        if (_showAchievement)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _badgeScaleController,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _achievementLevel == 'gold' ? '🏆 GOLD BADGE' : '🥈 SILVER BADGE',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _achievementMessage,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _achievementLevel == 'gold'
                                  ? Colors.amber[700]
                                  : Colors.grey[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showAchievement = false;
                                _badgeScaleController.reset();
                              });
                            },
                            child: Text(_achievementLevel == 'gold'
                                ? 'I AM UNSTOPPABLE!'
                                : 'I WILL DO BETTER!'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_showMilestone && _milestoneDiscipline != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _badgeScaleController,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _milestoneDiscipline!.hasCommitment
                                    ? '🌟 ${'★' * _milestoneDiscipline!.stars} ACHIEVED!'
                                    : '🎉 QUICK WIN ACHIEVED!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _milestoneDiscipline!.hasCommitment
                                    ? 'You’re a Discipline Titan! You earned ${_milestoneDiscipline!.stars} star(s) '
                                    'and ${_milestoneDiscipline!.stars == 1 ? 100 : 50} gold medals for '
                                    '"${_milestoneDiscipline!.discipline}"!'
                                    : 'You nailed "${_milestoneDiscipline!.discipline}" for 7 days straight! '
                                    'Earned a Quick Win badge!',
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              if (_milestoneDiscipline!.hasCommitment && _milestoneDiscipline!.stars >= 3)
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    '🛡️ IRON WILL BADGE UNLOCKED!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showMilestone = false;
                                    _milestoneDiscipline = null;
                                    _badgeScaleController.reset();
                                  });
                                },
                                child: const Text('KEEP FORGING!'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      colors: const [Colors.purple, Colors.green, Colors.amber],
                      numberOfParticles: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 80,
          right: 16,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  _addDiscipline(disciplineProvider, _controller.text.trim());
                  _controller.clear();
                  FocusScope.of(context).unfocus();
                } else {
                  FocusScope.of(context).requestFocus(_focusNode);
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}