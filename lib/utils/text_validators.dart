class TextValidators {
  static String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  static String validatePassword(String value) {
    if (value.isEmpty || value.length < 8) return 'Enter valid password';
    return null;
  }

  static String validateMandatory(String value) {
    if (value.isEmpty) return '*Mandatory field';
    return null;
  }

  static String validateAddress(String value) {
    if (value.isEmpty) return '*Mandatory field';
    if(value.length < 10) return '*Address should be atleast 10 charecters long.';
    return null;
  }

  static String validatePhone(String value) {
    if (value.isEmpty) return '*Mandatory field';
    if(value.length != 10) return '*Invalid Mobile Number';
    return null;
  }
}
