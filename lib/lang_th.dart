import 'package:thai/thai.dart' as thai;

/*
# Word Tokenizer
# 'ก็จะรู้ความชั่วร้ายที่ทำไว้ และคงจะไม่ยอมให้ทำนาบนหลังคน'
#['ก็', 'จะ', 'รู้ความ', 'ชั่วร้าย', 'ที่', 'ทำ', 'ไว้', '     ', 'และ', 'คงจะ', 'ไม่', 'ยอมให้', 'ทำนาบนหลังคน', ' ']
#
#newmm and keep_whitespace=False:
#['ก็', 'จะ', 'รู้ความ', 'ชั่วร้าย', 'ที่', 'ทำ', 'ไว้', 'และ', 'คงจะ', 'ไม่', 'ยอมให้', 'ทำนาบนหลังคน']
# Syllable Tokenizer
#['ก็', 'จะ', 'รู้', 'ความ', 'ชั่ว', 'ร้าย', 'ที่', 'ทำ', 'ไว้', '   ', '  ', 'และ', 'คง', 'จะ', 'ไม่', 'ยอม', 'ให้', 'ทำ', 'นา', 'บน', 'หลัง', 'คน', ' ']
#['อับ', 'ดุล', 'เลาะ', ' อี', 'ซอ', 'มู', 'ซอ ', 'สมอง', 'บวม', 'รุน', 'แรง']
*/

void main() {
  /* old, but it is correct list
  List<String> strings = [
    'อับ',
    'ดุล',
    'เลาะ',
    ' อี',
    'ซอ',
    'มู',
    'ซอ ',
    'สมอง',
    'บวม',
    'รุน',
    'แรง',
  ];
 */
/* complete list
  List<String> strings = [
    'มี', 'นา ', 'นา', 'รี', 'รอ', 'ยา ', 'นา', 'วี', 'มา', 'ลี ', 'มา', 'ลาว', 'ยาว', 'นาน', 'ลอง', 'มอง', ' มี', 'งาน', 'นอน', 'นาน ', 'นาย', 'นา', 'วี', 'รอ', 'ยาย', ' นา', 'มี', 'งู', 'ยาย', 'รอ', 'นา', 'รี', 'ยาย', 'รอ', 'นา', 'รี', 'นาน', 'นา', 'มี', 'ลา', 'ลา', 'มี', 'งู', 'นาง', 'งาม'
  ];
*/
/*
  List<String> strings = [
    'เมอะ', 'เนาะ', 'เกะ', 'แขะ', 'โละ',
    'ลึ', 'นิ', 'นุ', 'มะ', 'งาน', 'นา', 'มี', 'งู', 'ยาย', 'รอ', 'ยาย', 'รอ', 'นา', 'รี'
  ];
*/
  List<String> strings = ['อยาก','พูด', 'เรื่อง', 'ไทย', 'รู้', 'จัก', 'ประ', 'เทศ', 'ไทย', 'มา', 'กรุง', 'เทพ', 'ฯ',
   'เดือน', 'เม', 'ษา', 'ยน', 'ปี', 'หน้า'];

  print(strings);


  final RegExp regSee = RegExp(r'เ.อะ');//#S 9
  final RegExp regSoo = RegExp(r'เ.าะ');//#S 8
  final RegExp regSA = RegExp(r'เ.ะ');  //#S 5
  final RegExp regSae = RegExp(r'แ.ะ'); //#S 6
  final RegExp regSo = RegExp(r'โ.ะ');  //#S 7
  final RegExp regSU = RegExp(r'.ึ');   //#S 3
  final RegExp regSE = RegExp(r'.ิ');   //#S 2
  final RegExp regSu = RegExp(r'.ุ');   //#S 4
  final RegExp regSaa = RegExp(r'.ะ');  //#S 1
  final RegExp regLee = RegExp(r'เ.อ'); // #L 9
  final RegExp regLoo = RegExp(r'.อ'); // #L 8
  final RegExp regLA = RegExp(r'เ.'); // #L 5
  final RegExp regLae = RegExp(r'แ.'); // #L 6
  final RegExp regLo = RegExp(r'โ.'); // $L 7
  final RegExp regLU = RegExp(r'.ื'); // $L 3
  final RegExp regLE = RegExp(r'.ี'); // $L 2
  final RegExp regLu = RegExp(r'.ู'); // $L 4
  final RegExp regLaa = RegExp(r'.า'); // $L 1

  final RegExp regBlendVowel_ia = RegExp(r'เ.ีย');
  final RegExp regBlendVowel_uea = RegExp(r'เ.ือ');
  final RegExp regBlendVowel_ua = RegExp(r'.ัว');

  final RegExp regFinalConsonents = RegExp(r'[งนมยวกดบรลฬญ]$');
  List<String> vowel = [];
  String consonent = '';
  String auaExp = '';
  String auaVowel = '';
  String withoutFinal = '';

  for (String str in strings) {
    if (thai.isThaiCharacter(str)) {
      print('11: $str');
      String withoutTone = thai.removeToneMarks(str);
      print(' 12:' + withoutTone);
      String match;
      if (regFinalConsonents.hasMatch(withoutTone) ) { // if the syllable contains ending consonents.
        withoutFinal = withoutTone.substring(0, withoutTone.length - 1);
        if('เ' == withoutFinal ) {
          match = withoutTone;
          // This is เ+final consonent
        } else {
          match = withoutFinal;
          print('  2#F $str has final consonent ');
          print('  2#F $withoutFinal which eliminated final consonent.');
        }
      } else {
        match = withoutTone;
      }

      if (regSee.hasMatch(match)) {
        print('  2#S9 : $str is เ-อะ');
        vowel = ['เ', 'อะ'];
        consonent = replaceVowels(match, vowel);
        print('  2#S9 : $str consonet is $consonent');
      } else if (regSoo.hasMatch(match)) {
        print('  2#S8: $str is เ-าะ');

      } else if (regBlendVowel_ia.hasMatch(match)) {
        print('  2#B ia: $str is เ.ีย');
      } else if (regBlendVowel_uea.hasMatch(match)) {
        String cc = match.substring(1, 2);
        print('  2#B uea: $str is เ.ือ and $cc');

        auaExp = replaceConsonentsExceptEnding(cc);

        vowel = ['เ', 'ื', 'อ'];
        auaVowel = 'ʉa'; // confirmed with the aua transcript site.
        consonent = replaceVowels(withoutFinal, vowel);

        print('  2#B: $str consonent is $consonent, aua_expression=$auaExp$auaVowel');
      } else if (regBlendVowel_ua.hasMatch(match)) {
        print('  2#B ua: $str is .ัว');
      } else if (regSA.hasMatch(match)) {
        print('  2#S5: $str is เ-ะ');
      } else if (regSae.hasMatch(match)) {
        print('  2#S6: $str is แ-ะ');
      } else if (regSo.hasMatch(match)) {
        print('  2#S7: $str is โ-ะ');
      } else if (regSU.hasMatch(match)) {
        print('  2#S3: $str is  ึ');
      } else if (regSE.hasMatch(match)) {
        print('  2#S2: $str is  ิ');
      } else if (regSu.hasMatch(match)) {
        print('  2#S4: $str is ุ  (consonent)+ú');
      } else if (regSaa.hasMatch(match)) {
        print('  2#S1: $str is -ะ');
        vowel = ['ะ'];
        auaVowel = 'à'; //  confirmed with the aua transcript site.
        consonent = replaceVowels(match, vowel);
        auaExp = replaceConsonentsExceptEnding(consonent);
        print('  2#S1: $str consonet is $consonent, aua_expression=$auaExp$auaVowel');
      } else if (regLee.hasMatch(match)) {
          //ToDo: This case is not tested yet. (2024-03-17)
        print('  2#L9: $str is เ-อ');
        vowel = ['เ', 'อ'];
        auaVowel = 'er';
        consonent = replaceVowels(match, vowel);
        auaExp = replaceConsonentsExceptEnding(consonent);
        print('  2#L9: $str consonet is $consonent, aua_expression=$auaExp$auaVowel');
      } else if (regLoo.hasMatch(match)) {
        print('  2#L8: $str is -อ');
      } else if (regLA.hasMatch(match)) {
        print('  2#L5: $str is เ-');
        vowel = ['เ'];
        auaVowel = 'a';
        consonent = replaceVowels(match, vowel);
        auaExp = replaceConsonentsExceptEnding(consonent);
        print('  2#L5: $str consonet is $consonent, aua_expression=$auaExp$auaVowel');
      } else if (regLae.hasMatch(match)) {
        print('  2#L6: $str is แ-');
      } else if (regLo.hasMatch(match)) {
        print('  2#L7: $str is โ-');
      } else if (regLU.hasMatch(match)) {
        print('  2#L3: $str is .ื');
      } else if (regLE.hasMatch(match)) {
        print('  2#L2: $str is .ี');
      } else if (regLu.hasMatch(match)) {
        print('  2#L4: $str is .ู');
        vowel = ['ู'];
        auaVowel = 'uu'; // confirmed with the aua transcript site.
        consonent = replaceVowels(match, vowel);
        auaExp = replaceConsonentsExceptEnding(consonent);
        print('    2#L4 : $str consonent is $consonent, aua_expression=$auaExp$auaVowel');
      } else if (regLaa.hasMatch(match)) {
        print('  2#L1: $str is .า');
        vowel = ['า'];
        auaVowel = 'aa';
        consonent = replaceVowels(match, vowel);
        auaExp = replaceConsonentsExceptEnding(consonent);
        print('    2#L1 : $str consonent is $consonent, aua_expression=$auaExp$auaVowel');
      }
    } else {
      print('$str is not Thai');
    }
  }
}

String replaceVowels( String chars, List<String> vowels) {
  String ret = chars;
  for(var vvv in vowels ) {
    // Will erase all vowels characters, and return only consonents.
    ret = ret.replaceFirst( vvv, '');
  }

  return ret;
}

String replaceConsonentsExceptEnding( String consonents ) {
  String ret = consonents;
  if ( ret == 'หน' ) {
    // I don't know this pattern yet.
  } else if( 1 == ret.length ) {
    ret = ret.replaceFirst('ก', 'k');
    ret = ret.replaceFirst('ม', 'm');
    ret = ret.replaceFirst('น', 'n');
    ret = ret.replaceFirst('ษ', 's');  //ToDo: rising tone character を付ける必要がある。
    ret = ret.replaceFirst('พ', 'ph');  // confirmed with the aua transcript site.
    ret = ret.replaceFirst('ร', 'r');   // confirmed with the aua transcript site.
    ret = ret.replaceFirst('ด', 'd');   // confirmed with the aua transcript site.
  } else {
    print('Error-80771 $consonents');
  }

  return ret;
}
