import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:suwon_mate/api/keys.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({Key? key}) : super(key: key);

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  BannerAd? _bannerAd;
  bool _loadedBanner = false;
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
  void dispose() {
    super.dispose();
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
        title: const Text('기부하기'),
      ),
      body: Center(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            if (_bannerAd != null)
              Container(
                color: Colors.white,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            else
              Center(
                child: Row(
                  children: const [
                    CircularProgressIndicator.adaptive(),
                    Text('광고 불러오는 중...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
