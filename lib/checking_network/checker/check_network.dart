/*
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:score_win/generated/locale_kyes.g.dart';
import 'package:score_win/shared/resources/assets_manager.dart';

import '../../shared/resources/colors.dart';

networkConnectivityChecker({required Widget child}) {
  return OfflineBuilder(
    connectivityBuilder: (
      BuildContext context,
      ConnectivityResult connectivity,
      Widget child,
    ) {
      bool connected = connectivity != ConnectivityResult.none;
      return Scaffold(
        body: !connected
            ? Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top * 2.8,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        child,
                        Positioned(
                          height: MediaQuery.of(context).padding.top * 2.8,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: connected
                                  ? const Color(0xFF00EE44)
                                  : const Color(0xFFEE4400),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(24.r),
                                bottomLeft: Radius.circular(24.r),
                              ),
                            ),
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Text(
                                connected
                                    ? tr(LocaleKeys.connected)
                                    : tr(LocaleKeys.noConnection),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: ColorsManager.whiteColor,
                                    )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      AssetsManager.noSignal,
                      scale: 2,
                    ),
                  ),
                ],
              )
            : child,
      );
    },
    child: Scaffold(
      body: child,
    ),
  );
}
*/
