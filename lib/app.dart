import 'package:flutter/material.dart';
import 'package:test_guidio/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shared/core/constant/app_theme.dart';
import 'features/home/presentation/screens/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/cubit/camera_cubit.dart';

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return ScreenUtilInit(
			designSize: const Size(390, 844),
			minTextAdapt: true,
			splitScreenMode: true,
			useInheritedMediaQuery: true,
			builder: (context, child) {
				return MultiBlocProvider(
					providers: [
						BlocProvider(create: (_) => HomeBloc()),
						BlocProvider(create: (_) => CameraCubit()),
					],
					child: MaterialApp(
						title: 'Guidio',
						theme: AppTheme.light(),
						home: const HomePage(),
						localizationsDelegates: AppLocalizations.localizationsDelegates,
						supportedLocales: AppLocalizations.supportedLocales,
						localeResolutionCallback: (locale, supportedLocales) {
							if (locale == null) {
								return const Locale('id');
							}

							for (final supportedLocale in supportedLocales) {
								if (supportedLocale.languageCode == locale.languageCode) {
									return supportedLocale;
								}
							}

							return const Locale('id');
						},
					),
				);
			},
		);
	}
}
