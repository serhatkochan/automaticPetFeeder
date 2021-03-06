import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';


import 'package:bot_toast/bot_toast.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'dart:io' as Io;
import 'dart:convert';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
/*
  WidgetsFlutterBinding.ensureInitialized(); // Firebase çalışması için en baştan çağrılmalı
  runApp(MyApp());
  */
  runApp(MaterialApp(
    home: MyApp(), // first page
  ));
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(); // firebase initialize edildi, baslatildi

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FutureBuilder(
            future: _initialization,
            builder: (context, snapshot){// context'e bagliyor, future çözüldüğü zaman snapshot'a alıyor
              if(snapshot.hasError){
                // kullanıcıya hata mesajı
                return Center(child:Text('Beklenilmeyen bir hata oluştu.'));
              }
              else if(snapshot.hasData){
                // hata yoksa, firebase calisti
                return MyHomePage(title: 'Evcil Hayvan'); // MyHomePage(title: 'bccb')
              }
              else{
                return Center(child: CircularProgressIndicator());
              }
            }
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _imgData = 'data:image/jpeg;base64,%2F9j%2F4AAQSkZJRgABAQEAAAAAAAD%2F2wBDAAoHCAkIBgoJCAkLCwoMDxkQDw4ODx8WFxIZJCAmJiQgIyIoLToxKCs2KyIjMkQzNjs9QEFAJzBHTEY%2FSzo%2FQD7%2F2wBDAQsLCw8NDx0QEB0%2BKSMpPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj7%2FxAAfAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgv%2FxAC1EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR8CQzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4eLj5OXm5%2Bjp6vHy8%2FT19vf4%2Bfr%2FxAAfAQADAQEBAQEBAQEBAAAAAAAAAQIDBAUGBwgJCgv%2FxAC1EQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4%2BTl5ufo6ery8%2FT19vf4%2Bfr%2FwAARCAEoAZADASEAAhEBAxEB%2F9oADAMBAAIRAxEAPwDBKehp3VRXNpucYvHAqQdTkqPrxUu1wD15X2207AFT5FxY4Lx70vfFIq4oXmpOaJD8wC0opC3HY4pSKewxQKcBikwfkLilpNALijbTjYQu2jFIYmKQimAwrmkxTYxKaRzUoQwrTCtWFxhGQfrURGKYiuwqvKuOg5FXdoshdfSoz1o5khW1GOMLUZ6cUrl9Bh6VG%2FOKsTfYVQe2Ku6NFv1WM4yqZLflSla1ibnQYox61gQxp%2FWjFBm9RNtBHpTiNvoGKTHNHoS%2BwwgdaUDH1FXKxoAHPFO%2FlUdQFHWn9aGtQHd6UL8xOfwxR0AfS4NDfcscVpQKfQY78aKzRNh2KWrKFp2KmwgxS4pjDFGKQgxSEVVhjTTSKBiYpCKgkZ2pjc1ew7DMcVAwp7iIXqq%2FWnE0RE1REDPUGgCNs5FMNN36CGGonOD2xVrcIgoySD02mtfw6vz3j46IqD86KuwM2aSsuhixMUm2kIWkxxSJYYo20ySvtG7oM04D1Nas1k%2FeHA4p38P3aziHkItPBpvlFbsOzT%2B3FQyhcU%2Fmh6gmOooWiKF6U8VNhC4zS4qxgKcBQUPoxUiF20YpANxSYqwEIpKBCU0igBhqMihIdxhqFqcUBA9VJfvn%2FPancfUgbmoj61aKQxvrTG9q0a6A0Mwc9D%2BNRH%2FXMOmKz8hj0%2B%2FXQaCgGleYDnzJm%2FSonpoRIvmm4pGYGm0KNxXFpadiApKnYaKx9afgZ5p2cR3E2D8afRuAo64p2KzaGh1GOK00sVYkCmnhPel6CFNLS5ugx4Wn4xUeQxaMVSGKBinCkxjqcBTELim0WAQim1QCUlLqAmKSmLcYajakhEZHFRPVMorSDjAqo%2FzHJ%2B8aSBEJ61EavcpXI%2B9MI4%2FGnqOV2MaoV%2BlAbDuFVm%2FujNdbp8Rg0iyhc%2FMIsn6k5qZmcyTFGKRDuJRii4gxR3phe4YptS3pqSQUfd52s3OOBWmki0x%2BCQAetKKz05h8oA%2B1PFN2AdSjmixVh4p60hD6WswHUtUrDFFOpblC4p2KYABT6OYBaMUmSJTaEAmKYRmmUGKbii4huKjIpisRkVC9FhlWb3qm%2BQemKdhoiaoatIcSNxxTG9ardDGPx82M4qFRSQwkjZ0cKCSw213cq4fb%2FdAX9KKmruZSI8UmKzuS2NxRSJA0tUA2kpkMrccf0p38VDNvMU%2FWlFTygOpVz0oSBjx1p4qZMbY4CnikIcKXvQUOp1IB1KBVDHU7FQIXFOxVAGKXFIBuKMU7gJimEU7jEppoEMphpgRN0qFqCSnPzxzVVx6VXNYvoQv1qFqXUrm0GGoz7VoIhk%2FrSCtHsBc0hBLrdjHleZeQfTBrrKxZDG0mKhECUYqxBSUhDcUGjcRUAp6jsetJzNErIPanUkr6kp9x59qBQUSCnVJTHingUxWHUooLFFPpAKKeBSbAdTsUXJFAp1A0LikxSATFIaoBKSgBuKZimgGFaZTYEbVXfnNMkpTiqzipVi%2BhA2T3qNhn61Y%2BpGwxURp7jIZOq%2FpRWgI1%2FDcPmaw8va2gLfi3y10eKykRITFNIpGYmKTFMBKKbJYlNxSiBU57U%2BhJGkhR707GTSiiRe9PAplIcBmnVDQ7klOAosFxwFLim9yh4FOAqRD8UuKQIcBTgKTGOoxQMWlpiEpMUgExTaYxMUwiqJYzFRsKLgRsKgkFDQrFGWq0nShIZA1RH71VYtEclRGtAIG%2F1qn04pe9XcaVjofCkTBb%2B5OdrbIRx%2BNbWKxZjJiUhpEiUmKBsMcU2gkQ03FDYrFPPNPHXpxjrQ42LeoU%2FFV0HuLT6yuUOWpK02HYcOtPpEi9qdSvYscKeKi4h9OpgOp2KkYtLSELRTATFJjmgYU3FMQhFNNO4iI0xqAIiKry1VwKEnOarOPVt3%2FAcYpJgQnk1EeKpFIiPvzUR%2FSrsUQHOT0%2FPNSDrTWjFY6vw0m3w3E3%2FPWeWT6jOBWhWREhlFMgSigBpptO1hCUGgkogUq9aGVtsPpwpaj5R3XinYoSKY4Cn7aVxjgKeBUtlC1ItAh4p9JCFFSCgYoFLUgLS0wHUmKYC4pKAEpKAG0w0CGEVGaYiFhVeUUhlKRaqMCW5oRRA3SojWr2ugtYiIqNulNSGVx1pZ2K20jZHCnrWlxnfW8It7G2gTGxYlPHuM0tYsxG4puKYhO9FMBDSVLEJSU7MRSFL%2Fnmh7lJCjmnilyj9B9PFK4DlFPpDHAU%2BgY7tQKh7giQdqkAoGhcc0%2BgB9GKloAAp4FUA6jFAgpKBjaSqsAhplIBhFRtVEsgaq0tSxlGQDr3qq%2FFJSLuRHrUBFWBE3GaifpVqJJGo5qWOE3FxDbp1mkVKrYZ38%2FM7%2BmcCoazMmIaYaZQdqSgkQ02kISkNVflJ3KIp360nqXYcBThTWgojxwKcBUmhItPpCY4U8UMYU9ahlDxUgpkjqcKRQ6lxSGKBTxSJFxS1QCYooAZikNUA2mkUhDDUZFICu9VZulUMovVdqzdhkDA1C45q4jZE1V5q3iJCBTjjJrU0CLzfEll2WItMflz90Upaj2OtpuKgzGmkoEJSGmA2kpkjaSokgKHQU5aYx4BNO5paCHinjrSNCSlFERj6cKYh1OUVLKJFFSCkIXFPApDHUUwHCnUrgP7UUhBim0wEptMQ0im4oAYajNICvJVSfoaoZRkqs3WhajIiKgzk00gIn61Wf71bpjHp1zW74Rizc6hMQD5caRg%2BhJrKdynsdERSYqDAYetJWlgGmkpcoDaSmTYbSGmBn06k9Bp6D6dQUSCngUeYyRadU8o0OFPFJgKKcKkZIKkFADqdSAdS0CFpwqRjxS0wDFJimIbimkUANppoAjNRtQIry1TnqhlF6rtSuUQk1Axq7BYiNVjzITVhuSV1XhSIDQpJ%2B89y2f%2BAcVEgexrUlIyG00imMbSGmIYabTQCU2gRnduaevI4pFtDxTx1piuPFSCmMkp1QgQ5adSaKHU4VIiRakFAx1OqbgPFLinYAFOFQBIKWqEFNoTASm4pjGmmGgRGajamIrS1SnoKRTfrVZqRZC9QPViuRt97NVFIzVoY9jtQsewru9KhNtoWnwt97yfMb6tzUzJkizTakzY2kpgNIphqkA1ulMqiRKKkDLJGad5gJ%2B8tHL1HcWKWKRtsb7iOtWdtAx4FPpjuPFPFTzDH4pRUsEOxSimxkop4qRDqcKVwHin4oAWlxSGPpaQgptACUhp3AYaYaYDDUTU7iZWkqjN1oKKcneqxqehRC1QNzn61cRkMn3SahQCtgQrRGUeSq7jKfLx9a9JmXa%2B0fwAJ%2BQxWM9xSIqbSMxtJVCENRmqQDabigBtFCJObuGbBxn5RniqcsrmM5k4x1ZuBWvQ1S01Ol0a1jJjlx87RhFb%2B9wCRWrcQL9nZu6c1kiLlLvSjrTEPFOqCh4pwFAx1OAqB3JKkFAhaUcVIyQU8VTEO7UlIY8UtSIKSmAlNqgG02i4ERqJqQFaWs%2BWqGVJKgepvqO5A1QtVpDRWmzimx9K06DeiNHQoxJ4m0wHkLN5jA%2Big12p561k9yBtNoEIabVCsNNMNMQ002nuIQ03FVsBk2sBuxslzAWbC%2FxZqb7LY2bMfK8%2B8Tjz5B8qGhvWxepLHc3D6hHc3L%2FaJV6MwxgGrb3TSLtPANIgZThSGOFPqXoUOpwpAx1OU5qQ3JRTxQMdS0gHLUq0rjY6jFMQop1SIKQ0wG0lADaYaAIzULUwKs1UJutMZUfvVdqLWKsQvUDcVaAgm6D1zSDgGruM3vBy79Yu5sj9xbYUe7HFdMax6kMSmVQhKbQJjaYaYhtJVAJTKCSo8uyZXiCqd2elRs%2B5y38R5NL7RqxUqYUMgcD6VIKew0PFOFSIeKdUjH0oPNDGSrUlR1GOFLTYDlqRaQD6M0gFFLQIKQ0AJSUAMNMNUgIzULUgKk9UJaCkVJKrsaa2LIXHy9ahPfNaJkleb%2BHNOA4qrjOq8HxlNOvbjJ%2FfzCMfRa2TWTIG0lMkYaSmA00ynYQ2kNMBppB94D1p7agZfU06nKV2Fx1SLx3qRkgxmnigQ8U8Umhj1p4qQHik6UMokSpaQD6dU3AcKfQAtA60ASClpCEpKYCUhpIYw0w0xMjaoHpgU56oS0myolV6gbnrQmykyFqhatBXKrcy1IeI29fWqeg7nbaDD5HhuyQqVaTdOQR03GrtZEbsaaSmSNptUhjTTKYhtJVCG1JaJ5lz%2Fuc00Bi04VT7E3bH8dqetZFEop4qgHinikMeKkFQMdS9eKBCrUwqSh4p1MB1OpALTlqQJKKCRtFAxtJQA00w0wImqCSmgKM9UpKnqUmVn4qB6VxkD9cGomrZMZVP%2BsNOmBNo6D7zLsH1py1A9JZQgjTAGyNF49lFRmsYmY2m1QCU2quIZTaoQ2m0CErQ01f9GL%2F32x%2BVNMZzBp1UMeOKkqdxEgNSUihwNSCq0EOFSCpYyQUo61FhAFO4nPHpUq0iiQU6gB1LmkIBUopDHZooEJSGmMbRTEMNMNSBC1QSVQFKc1SkNSxorPUDU9GWQN61ETzVrUCvHya0NLjWfW9OgYD97cqOfzqJsLXO5dt7lvWmGhEDaSqENphFIBlJViGUlMBrHAzWzGnlwRp6CmiWcjTh0HrTkrBcWpRQMeKevWkwJKcKBkgqRaT2Cw8U6puA%2BnLUlElO7UhCZNOHNJlEop9MkWkqRCUU7juNpKEMYaYaAIWqu9MCjPVF%2BtIEyu3JqFvxo2LRAenrUL9SRWiAjiHvW34TiL6%2F53OLaBn%2FAD4FKVgOrNMqSBKSqEJTDQAym1QhtNosIfAvmXEa%2BprXY81aJZx2aXk0upVh461JSAeKkWmwHinCkh3HipRTkO48U%2BosIfSrUlD6eKTAdSihASU6hiCikAlFAhKZQMbmo2oGQtVeSrAozGqUvWsxlZyV6YqEnmr3HYhPtUEvArWAxIgx4UZ4zXS%2BDI%2F%2BQpc4I3eXAOOv8VZ1EFzfppqSBtNpiEpppxYDDTaYhKbTAtaeuZXY%2FwAIq8aqJmzj%2BKXNNvUuxIpyakU0bDHVKKV7APFKtTcB9SCgB4qQUwHCnd6gofTxRYQ6nCgY6nZqQFpDQISigBKaaAGGmMaQELGqstMZQmPNVJaNy0QNUDYNNOwEJPFV5TyKtB6i7Rxxmuw8MoU8NwlhgyzSSde2eKzm2FkaZphpEDabVCEptOwhtIaBjaaaoDRsP%2BPMHuzGpiaZn1OPIznFPOMnFVuNsctSihjuKKlWpAeOtPFAxwqQUAPp61LAfT6QxwNPpMY4U6gQopaQDqTNMEJmipASmmgBpqJqEBC1VZjTGijKeaqSVnsUiu2c1AR6cVqVcib0qufv%2FStETuEjFLaRh1216DbQfZLC1th%2FyzhX%2BWazl2Bj6YaVxDTTaZIlJQAykzTAYTTTyOO%2FFUBt9FA9ABTCaaMzkcUD%2FZ3fjWuwh4z3qQVmiySnigCQU6oiMcKkFaMZJThWZJIDTqLFDhT80gHCnUgHZpaQC0lMBDSVICZpM0ANNRtQBA5qpKetMaKMlVXzzis%2BpXUrvkmoX%2B7W6GRHpVf%2BJjjHPT1ppjRKIWuJobdBlppAgr0Sc%2FvTjoOBWcyWQ5ppqUSMzSZqxDabTQxuaSmSMJqW0G68i9FO40DNMmo2qzM5MNmnLV%2BQDqkHFTe2hQ%2BnikA%2FdTxTtYZIKdSAkFSCoAcKcKQDxT6AQop1SMcKdQwCm5oGGaKkQ2kzTGNJqJqBELmqkx44pjM%2BSqrn56RaIW61A55xVRYDGODUA61cdxmr4fTzPEVh38qQyt9AK67NZS0kJsbTTQSxlNoEJmkNVcQw02mMQmremD%2FXSfRKZFy2aYaoRylKPxptakj93OMN%2BFOB52%2FlTLJBUgpAOqQVLC48GnCmUPqQUhDs08GkA8GnCkUOpwNSIdS5psApKgYlFUA2kzSGMJpjGgRXeqk54oAoyVVbg0rFkLffNRGqQbkEtNFaWBG94PX%2FAEy%2Fl6%2BXAFz7lua6Ksm9RSG0wmpJQ2m5qgG0hqgG0maQiNjWtap5Vminr9786oQpNMJqyTlAKevArWRO49adWNjQkp61ZNh%2BaeDWZQ%2BnrVMY9TUmakQuaetAx4p2aQDqdUgLS1QxaSoASkpjEpM0hDGqJjQBA5qpO3FDGUZKquevShIqxA5%2Bamk%2Bta8oMrP3xSrQwOn8KoF0m4uBnNxcY%2F744rWJrF7iaG5phpEiUzNaIYmaQmpEITTM1QhAvmyJGP4mxWy59OlMmREaYTVkHLZPan9etbtJMscPrT6ykJjqeuaEO5JThSAeKkzSaKHinCkxj6UUCJAacKTEOp2aTGLmlpDFozSYhKTNAxuabTAYTUTGpsIhkNUp6kopyGqz1RUWQtUTVre4Fd%2FvYz%2BVOU%2Fl0rTYZ2Ghx%2BT4dsV2lSwMrZ9WNXCa5SBhNNJoATNNqiRKTNIY3NMJqgJ7Bd91u%2F55jdWi1PczZETTCatEnM9KUcY9K1k7saJPcd6WoWhVh6VIOtVLyJY%2BniskUOFPFWA8U6oGOU08GgB4NOzSYCin5pMaFzRmkAu6kzSYxM0m6gQmaaaGMYaiY0AQyGqM57VLVwKkh9KrPnrVx0KIjURatIjIOrHikmz9nfA5YY60SKO%2BPyKkY42Iq4%2FCmk1gu5I0mm0EgTTc0yRuaTNUMaTTM0hF%2FTRi3eT%2B%2B2Pyqwxq0ZkRNNzVAcyeTT9wxyefStH2KvcVevp9KdyD1pLswiSj1pytQDJM04HPapJH08UDQ4Gng1KKHA06mNjxS0gHA07NSxoXNGaQC5ozSJG5ozTGNzTS1IYzNRsaBEDnNUZjk5qUaWKjt7Y%2FGqzda1iK1iMmo24BNWNEOec1ZsEFxq1jATxJOoP0obA7Fn3uW9aTNYbiuNLU3NIQZpmaYDSaTNBI0mmFvSkBsIPLhSP%2B6tNJrVGZHmmE1Qzns%2Bx5orXYkd3wad3FSNMlpwOKHYY%2FtT88VkUtR6nmng1TYmLTxQA8GnZpFDs04VO4C0uaYDs0ZqQFzSE1QDaM0hobSUhDCajY0txleQ4qhKcsT2NToNFVz78VETWwyE%2FeqKTvVodyMfnWr4dTOtK4%2FwCWUbNUz2BnR03Nc5AhNNNIY3NJmrsIbmmk1LRIwmn2w33UQ7buapCNVmqNjWiJGZpuaYjAzScEVZQueBUhPy%2BlSL0Hjgn3Oaf2qRuQ4dKeKoY%2BnChgOFOpDHA1IKrQBwNLUdQFzS5qRi5pc0WAM0maaGJRmgBM00mkMjY1ExqSSvI1UnOV5pKJRVaomrYCKoZelaWGNHTFbnhkf8f8v%2B5F%2FwCzVjU2Hc2qaayRI2kzUgMJ5pM1SRI2mk09QGmrenDmRvwp9SS1mmk1qIZTc0iWYOeRyad9DmtZaDeo7NL3rOwosf1OeaeD6U5PoFh1PU8UupQ%2FdTgaYh2acDStcocDT%2FxoGOFLQK46jNIoWloAM0lRsMTNFFwEzTSaQEbVC1DArSHiqUj8miCGtSBmqE1rYrYjNQSH5q0iA4V0WgAJowYfekmdifX0rGqHQvbqTNYEjc0hNOwhuabuoENJppNUmxCVpWny2ie%2FzU0JjyaYTWiIGZpjGi4GLz1pQ2K3auK44UoPNQ46BuOzjmng0xvQk%2Fn7UvTrmp5bDiP3D%2BHqKWp1LsSClB5p6gOzzT84pPQQoNOzQMdS5qBi5ozTQWFzSZqQEpM0xjSaaaQbDCc1A5o5R3KsxIzVRjjrQo32GiAmoXrVbDIjUR%2B9V7BYfk7TgZPpXUWe2OwtokzhIwPx71zTG9iQmkJqdzNiZppNS3qAU3vVpiG000AJ1OK2D0o2JZGTTDVkDc0xqpEn%2F9kA';
  String _photoData = '';
  Uint8List myImage = new Uint8List(999);
  Future<void> _mamaVer() async {
    // butona basılınca calisir
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = FirebaseDatabase.instance.ref("servo");


    await ref.update({ // ref.set için ref tam adrese yazılmalı
      "servoStatus": 1
    });
    await Future.delayed(Duration(seconds: 1)); // bekleme
    BotToast.showText(
      text:"Mama Verildi",
      duration: Duration(seconds: 3),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );  //popup a text toast;
  }
  Future<void> _fotografGetir() async {
    // butona basılınca calisir
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = FirebaseDatabase.instance.ref("photo");

    DatabaseReference child = ref.child("photoData/photoData");
    DatabaseEvent event3 = await child.once();
    //print(event3.snapshot.value);
    final photoDataEvent = event3.snapshot.value.toString();
    print('_resimGetir()');
    print("photoData: " '$_photoData');

    DatabaseEvent event = await ref.once();
    print(event.snapshot.value); // { "name": "John" }

    await ref.update({ // ref.set için ref tam adrese yazılmalı
      "photoData/photoData": 0,
      "photoStatus": 1
    });
    await Future.delayed(Duration(seconds: 1)); // bekleme
    BotToast.showText(
      text:"Fotoğraf Getirildi",
      duration: Duration(seconds: 3),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );  //popup a text toast;


    // Convert to UriData
    final UriData? data = Uri.parse(_imgData).data;

    setState(() {
      _photoData = photoDataEvent; // ESP32-CAM çalıştığı takdirde  Image.memory kısmında myImage yerine _photoData yazılmalıdır.
      myImage = data!.contentAsBytes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(), //1. call BotToastInit
      navigatorObservers: [BotToastNavigatorObserver()],
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Evcil Hayvan"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 150),
                child: Image.memory(myImage),
                width: 400,
                height: 296,
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: new ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    OutlineButton(
                      child: Text("Anlık Fotoğrafı Gör"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular((15))
                      ),
                      textColor: Colors.black,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                      onPressed: _fotografGetir,
                      /*
                      onPressed: () async{
                        await showDialog(
                            context: context,
                            builder: (_) => ImageDialog()
                        );
                      }, //_resimGetir
                      */
                    ),
                    OutlineButton(
                      child: Text("Mama Ver"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular((15))
                      ),
                      textColor: Colors.black,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                      onPressed: _mamaVer, // mamaVer fonksiyonu
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}