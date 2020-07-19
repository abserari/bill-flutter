import 'dart:io';
import 'package:bookkeeping/main/main_page.dart';
import 'package:bookkeeping/res/colours.dart';
import 'package:bookkeeping/routers/application.dart';
import 'package:bookkeeping/routers/routers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:minio/io.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

bool ifasync(int username) {
  return true;
}

void main() async {
  // 定时上传功能
  // 确保 minio 链接初始化
  WidgetsFlutterBinding.ensureInitialized();

  // minio 客户端配置
  final minio = Minio(
    endPoint: 'play.min.io',
    accessKey: 'Q3AM3UQ867SPQQA43P2F',
    secretKey: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
    useSSL: true,
    // enableTrace: true,
  );

  final bucket = 'billing-test-sql';
  final object = 'username-account.db';
  if (!await minio.bucketExists(bucket)) {
    await minio.makeBucket(bucket);
    print('bucket $bucket created');
  } else {
    print('bucket $bucket already exists');
  }
  var username = 1000;
  Directory document = await getApplicationDocumentsDirectory();
  String path = join(document.path, 'AccountDb', 'Account.db');
  // 同步云端数据到本地
  await minio.fGetObject(bucket, object, path);

  // 定时同步时间间隔
  const period = const Duration(seconds: 20);

  // 如果需要同步, 就同步到服务器端
  if (ifasync(username)) {
    new Timer.periodic(
        period,
        (Timer t) async =>
            print("同步成功" + await minio.fPutObject(bucket, object, path)));
  }

  //透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    // 初始化路由
    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        // showPerformanceOverlay: true,
        // debugShowMaterialGrid: true,
        title: '小记账',
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colours.app_main,
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(),
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.dark,
              primaryContrastingColor: Colors.white,
              primaryColor: Colors.white,
              scaffoldBackgroundColor: Colors.white,
              barBackgroundColor: Colours.app_main,
            )),
        home: MainPage(),
      ),
      backgroundColor: Colors.black54,
      textPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      radius: 20,
      position: ToastPosition.bottom,
    );
  }
}
