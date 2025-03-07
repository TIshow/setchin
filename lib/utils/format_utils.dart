class FormatUtils {
  // 種類をフォーマット
  static String formatToiletType(Map<String, dynamic> type) {
    List<String> types = [];
    if (type['female'] == true) types.add('女性用');
    if (type['male'] == true) types.add('男性用');
    if (type['multipurpose'] == true) types.add('多目的');
    if (type['other'] == true) types.add('その他');
    return types.join(', ');
  }

  // 設備をフォーマット
  static String formatFacilities(Map<String, dynamic> facilities) {
    List<String> facilityList = [];
    if (facilities['washlet'] == true) facilityList.add('ウォッシュレット');
    if (facilities['ostomate'] == true) facilityList.add('オストメイト');
    if (facilities['diaperChange'] == true) facilityList.add('おむつ替えシート');
    if (facilities['babyChair'] == true) facilityList.add('ベビーチェア');
    if (facilities['wheelchair'] == true) facilityList.add('車いす用手すり');
    return facilityList.join(', ');
  }
}
