// import 'package:facebook_audience_network/facebook_audience_network.dart';
// import 'package:flutter/material.dart';
//
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// class BannerAds extends StatefulWidget {
//   const BannerAds({Key? key, this.adUnitId = '', this.isFacebookAds = false})
//       : super(key: key);
//
//   final String adUnitId;
//   final bool isFacebookAds;
//
//   @override
//   State<BannerAds> createState() => _BannerAdsState();
// }
//
// class _BannerAdsState extends State<BannerAds> {
//   late BannerAd myBanner;
//   Widget facebookAd = const SizedBox();
//   bool isBannerLoaded = false;
//
//   @override
//   void initState() {
//     FacebookAudienceNetwork.init(
//       testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6",
//       // iOSAdvertiserTrackingEnabled: true,
//     );
//     myBannerAd();
//     super.initState();
//   }
//
//   void myBannerAd() async {
//     setState(() {
//       isBannerLoaded = false;
//     });
//
//     myBanner = BannerAd(
//       adUnitId: widget.adUnitId != ''
//           ? widget.adUnitId
//           : 'ca-app-pub-3940256099942544/6300978111',
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(onAdLoaded: (ad) {
//         myBanner = ad as BannerAd;
//         isBannerLoaded = true;
//         setState(() {});
//       }, onAdFailedToLoad: (ad, error) {
//         setState(() {
//           isBannerLoaded = false;
//         });
//         ad.dispose();
//       }),
//     );
//
//     await myBanner.load();
//   }
//
//   @override
//   void dispose() {
//     myBanner.dispose();
//     super.dispose();
//   }
//
//   Widget facebookAds() {
//     return FacebookBannerAd(
//       placementId: "IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID", //testid
//       bannerSize: BannerSize.STANDARD,
//       listener: (result, value) {
//         switch (result) {
//           case BannerAdResult.LOADED:
//             print('LOADED $value');
//             break;
//           case BannerAdResult.ERROR:
//             print('ERROR $value');
//             break;
//           case BannerAdResult.CLICKED:
//             print('CLICKED $value');
//             break;
//           case BannerAdResult.LOGGING_IMPRESSION:
//             print('LOGGING_IMPRESSION $value');
//             break;
//         }
//         print("Banner Ad: $result -->  $value");
//       },
//     );
//
//     // await facebookAd.load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size2 = MediaQuery.of(context).size;
//     // var isDark = Theme.of(context).brightness == Brightness.dark;
//     return isBannerLoaded
//         ? AnimatedContainer(
//             duration: const Duration(milliseconds: 400),
//             alignment: Alignment.center,
//             width: size2.width,
//             height: widget.isFacebookAds ? 50 : myBanner.size.height.toDouble(),
//             color: Theme.of(context).cardColor,
//             child: isBannerLoaded
//                 ? widget.isFacebookAds
//                     ? facebookAds()
//                     : AdWidget(ad: myBanner)
//                 : const CircularProgressIndicator(),
//           )
//         : AnimatedContainer(
//             duration: const Duration(milliseconds: 400),
//             width: size2.width,
//             color: Theme.of(context).cardColor,
//             alignment: Alignment.center,
//             height: myBanner.size.height.toDouble(),
//             child: const CircularProgressIndicator(
//               strokeWidth: 2,
//             ),
//           );
//   }
// }
