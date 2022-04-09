import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwon_mate/api/keys.dart';
import 'package:suwon_mate/styles/style_widget.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({Key? key}) : super(key: key);

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _loadedBanner = false;

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3872045471700602/3738423083',
        request: const AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: ((InterstitialAd ad) {
          _interstitialAd = ad;
        }), onAdFailedToLoad: ((LoadAdError err) {
          _interstitialAd = null;
        })));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
      ad.dispose();
      _createInterstitialAd();
    }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, _) {
      ad.dispose();
      _createInterstitialAd();
    });
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  Future<int> getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getInt('donate') ?? 1;
  }

  Future<void> _createBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
            Orientation.portrait, MediaQuery.of(context).size.width.truncate());
    if (size == null) {
      return;
    }
    final BannerAd bannerAd = BannerAd(
        size: size,
        adUnitId: adUintId,
        listener: BannerAdListener(
          onAdLoaded: ((ad) {
            setState(() {
              _bannerAd = ad as BannerAd?;
            });
          }),
          onAdFailedToLoad: ((ad, error) {
            ad.dispose();
          }),
        ),
        request: const AdRequest());
    return bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    int _donate = _pref.getInt('donate') ?? 1;
    _pref.setInt('donate', ++_donate);
    _bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedBanner) {
      _createBanner(context);
      _loadedBanner = true;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('광고보기'),
        ),
        body: FutureBuilder(
            future: getData(),
            builder: ((BuildContext context, AsyncSnapshot<int> snaphost) {
              if (!snaphost.hasData) {
                return Container();
              } else if (snaphost.hasError) {
                return const DataLoadingError();
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          CardInfo(
                              icon: Icons.favorite_outline,
                              title: '도움을 준 횟수',
                              detail: Text(
                                  '이 페이지를 방문하므로써 저에게 도움을 ${snaphost.data}번 주셨네요! 감사합니다 :D')),
                          CardInfo(
                              icon: Icons.image_outlined,
                              title: '팝업 광고보기',
                              detail: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('팝업 광고를 시청하여 개발자를 지원해주세요!'),
                                  TextButton(
                                      onPressed: (() => _showInterstitialAd()),
                                      child: const Text('광고 시청'))
                                ],
                              )),
                          CardInfo(
                              icon: Icons.settings,
                              title: '하단 광고배너 설정',
                              detail: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                      '광고 설정에서 하단 배너에 광고 표시 기능을 켜서 개발자를 지원해줄 수 있습니다.'
                                      '\n기본값: 켜짐'),
                                  TextButton(
                                      onPressed: (() => Navigator.of(context)
                                          .pushNamed('/settings')),
                                      child: const Text('설정으로 이동'))
                                ],
                              )),
                        ],
                      ),
                      if (_bannerAd != null)
                        SizedBox(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        )
                      else
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator.adaptive(),
                              Padding(padding: EdgeInsets.only(right: 8.0)),
                              Text('광고 불러오는 중...'),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }
            })));
  }
}
