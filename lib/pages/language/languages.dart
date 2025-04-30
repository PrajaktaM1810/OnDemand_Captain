import 'package:flutter/material.dart';
import 'package:flutter_driver/pages/login/login.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';


class Languages extends StatefulWidget {
  const Languages({super.key});

  @override
  State<Languages> createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  @override
  void initState() {
    choosenLanguage = 'en';
    languageDirection = 'ltr';
    super.initState();
  }

  navigate() {
    if (ownermodule == '1') {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Login()));
      });
    } else {
      ischeckownerordriver = 'driver';
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Login()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.all(media.width * 0.05),
          width: double.infinity,
          height: double.infinity,
          color: page,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                height: media.width * 0.11 + MediaQuery.of(context).padding.top,
                width: double.infinity,
                alignment: Alignment.center,
                child: MyText(
                  text: (choosenLanguage.isEmpty)
                      ? 'Choose Language'
                      : languages[choosenLanguage]['text_choose_language'],
                  size: media.width * sixteen,
                  fontweight: FontWeight.bold,
                ),
              ),

              SizedBox(height: media.width * 0.05),

              // Image
              SizedBox(
                width: media.width * 0.9,
                height: media.height * 0.16,
                child: Image.asset('assets/images/selectLanguage.png', fit: BoxFit.contain),
              ),

              SizedBox(height: media.width * 0.1),

              // Language List
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: languages.entries.map((entry) {
                      final i = entry.key;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            choosenLanguage = i;
                            languageDirection = ['ar', 'ur', 'iw'].contains(i) ? 'rtl' : 'ltr';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          margin: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyText(
                                text: languagesCode
                                    .firstWhere((e) => e['code'] == i)['name']
                                    .toString(),
                                size: media.width * sixteen,
                              ),
                              Container(
                                height: media.width * 0.05,
                                width: media.width * 0.05,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Color(0xff222222), width: 1.2),
                                ),
                                alignment: Alignment.center,
                                child: choosenLanguage == i
                                    ? Container(
                                  height: media.width * 0.03,
                                  width: media.width * 0.03,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff222222),
                                  ),
                                )
                                    : SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Confirm Button
              if (choosenLanguage != '')
                Button(
                  onTap: () async {
                    await getlangid();
                    pref.setString('languageDirection', languageDirection);
                    pref.setString('choosenLanguage', choosenLanguage);
                    navigate();
                  },
                  text: languages[choosenLanguage]['text_confirm'],
                ),
            ],
          ),
        ),

      ),
    );
  }
}
