import 'package:flutter/material.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/presentation/widgets/persistent_date_header.dart';
import 'today_view_screen.dart';
import 'moments_timeline_screen.dart';
import 'visit_log_screen.dart';

class MemoryDiaryHomeScreen extends StatelessWidget {
  final String patientId;

  const MemoryDiaryHomeScreen({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.myMemoryDiary,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // PERSISTENT DATE HEADER
                  const PersistentDateHeader(),

                  const SizedBox(height: 24),

                  // SECTION HEADER
                  Text(
                    loc.whatWouldYouLikeToDo,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // MENU NAVIGATION BUTTONS (Grid in Landscape, Stack in Portrait)
                  if (isLandscape)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 2.3,
                      children: _buildMenuItems(context, loc),
                    )
                  else
                    ..._buildMenuItems(context, loc).map(
                          (widget) => Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: widget,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      _buildMenuButton(
        context: context,
        icon: Icons.wb_sunny_rounded,
        iconColor: colorScheme.tertiary,
        title: loc.myDayToday,
        subtitle: loc.myDayTodaySubtitle,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodayViewScreen(patientId: patientId),
            ),
          );
        },
      ),
      _buildMenuButton(
        context: context,
        icon: Icons.photo_library_rounded,
        iconColor: colorScheme.secondary,
        title: loc.beautifulMoments,
        subtitle: loc.beautifulMomentsSubtitle,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MomentsTimelineScreen(patientId: patientId),
            ),
          );
        },
      ),
      _buildMenuButton(
        context: context,
        icon: Icons.people_alt_rounded,
        iconColor: colorScheme.primary,
        title: loc.whoVisitedMe,
        subtitle: loc.whoVisitedMeSubtitle,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitLogScreen(patientId: patientId),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: iconColor.withValues(alpha: 0.1),
        highlightColor: iconColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // ICON CONTAINER WITH ADAPTIVE ACCENT TINT
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),

              // TITLE & SUBTITLE COLUMN
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // RTL-AWARE CHEVRON ACTION INDICATOR
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}