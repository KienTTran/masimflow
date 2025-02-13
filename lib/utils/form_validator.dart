
import 'package:flutter/widgets.dart';
import 'package:masimflow/utils/utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FormUtil {
  static String? validateDate(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return "Date is required";
    }
    try {
      DateTime date = DateFormat('yyyy/MM/dd').parseStrict(value);

      if(date.year.toString().length != 4){
        return "Format yyyy/MM/dd";
      }
    } catch (e) {
      return "Format yyyy/MM/dd";
    }
    return null;
  }

  static String? validateIntRange(BuildContext context, String? value, {int lower = -1, int upper = -1}) {
    if (value == null || value.isEmpty) {
      return "Number is required";
    }
    try {
      for( var number in value.split(',')) {
        number = Utils.removeExtraChars(number);
        int numberInt = int.parse(number);
        if(lower != upper){
          if(lower != -1 && upper == -1){
            if (numberInt < lower) {
              return "Integer number must be bigger than or equal to $lower";
            }
          }
          else if(lower == -1 && upper != -1){
            if (numberInt > upper) {
              return "Integer number must be smaller or equal to $lower";
            }
          }          
          else if(numberInt < lower || numberInt > upper) {
            return "Integer number must be between $lower and $upper";
          }
        }
      }
      return null;
    } catch (e) {
      return "Number must be integer between $lower and $upper";
    }
    return null;
  }

  static String? validateIntArrayRange(BuildContext context, String? value,{int lower = -1, int upper = -1}) {
    if (value == null || value.isEmpty) {
      return "Number is required";
    }
    try {
      value = Utils.removeExtraChars(value);
      List<int> numbers = value.split(',').map((e) => int.parse(e)).toList();
      for( var number in numbers) {
        if(lower != upper){
          if(lower != -1 && upper == -1){
            if (number < lower) {
              return "Integer number must be bigger than or equal to $lower";
            }
          }
          else if(lower == -1 && upper != -1){
            if (number > upper) {
              return "Integer number must be smaller or equal to $lower";
            }
          }
          else if (number < lower || number > upper) {
            return "Integer number must be between $lower and $upper";
          }
        }
      }
      return null;
    } catch (e) {
      return "Number must be integer between $lower and $upper";
    }
    return null;
  }

  static String? validateGenotype(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return "Genotype is required";
    }
    return null;
  }

  static String? validateString(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return "Genotype is required";
    }
    return null;
  }

  static String? validateDoubleRange(BuildContext context, String? value,{double lower = -1.0, double upper = -1.0}) {
    if (value == null || value.isEmpty) {
      return "Number is required";
    }
    try {
      double number = double.parse(value);
      if(lower != upper){
        if(lower != -1.0 && upper == -1.0){
          if (number < lower) {
            return "Double number must be bigger than or equal to $lower";
          }
        }
        else if(lower == -1.0 && upper != -1.0){
          if (number > upper) {
            return "Double number must be smaller or equal to $lower";
          }
        }
        else if (number < lower || number > upper) {
          return "Double number must be between $lower and $upper";
        }
      }
      return null;
    } catch (e) {
      return "Number must be double between $lower and $upper";
    }
    return null;
  }

  static String? validateDoubleArrayRange(BuildContext context, String? value,
      {double lower = -1.0, double upper = -1.0,int length = 0}) {
    if (value == null || value.isEmpty) {
      return "Number or number array is required";
    }
    try {
      value = Utils.removeExtraChars(value);
      List<double> numbers = value.split(',').map((e) => double.parse(e)).toList();
      for( var number in numbers) {
        if(lower != upper){
          if(lower != -1.0 && upper == -1.0){
            if (number < lower) {
              return "Double number must be bigger than or equal to $lower";
            }
          }
          else if(lower == -1.0 && upper != -1.0){
            if (number > upper) {
              return "Double number must be smaller or equal to $lower";
            }
          }
          else if (number < lower || number > upper) {
            return "Double number must be between $lower and $upper";
          }
        }
      }
      if(length != 0){
        if(value.split(',').length != length){
          return "Array must have $length elements";
        }
      }
      return null;
    } catch (e) {
      return "Number must be double between $lower and $upper";
    }
    return null;
  }

  static bool checkValidDate(BuildContext context, DateTime date, DateTime start, DateTime end, {bool isStart = false, bool isEnd = false}) {
    if(isStart){
      if(date.isAfter(end)){
        showShadDialog(
            context: context,
            builder: (context){
              return ShadDialog(
                title: const Text('Invalid Date'),
                actions: [
                  ShadButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  )
                ],
                child: const Text('Date cannot be after starting date. Extend ending date first.'),
              );
            }
        );
        return false;
      }
      return true;
    }
    else if(isEnd){
      if(date.isBefore(start)){
        showShadDialog(
            context: context,
            builder: (context){
              return ShadDialog(
                title: const Text('Invalid Date'),
                actions: [
                  ShadButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  )
                ],
                child: const Text('Date cannot be before ending date. Extend starting date first.'),
              );
            }
        );
        return false;
      }
      return true;
    }
    else{
      if(date.isAfter(end) || date.isBefore(start)){
        showShadDialog(
            context: context,
            builder: (context){
              return ShadDialog(
                title: const Text('Invalid Date'),
                actions: [
                  ShadButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  )
                ],
                child: const Text('Date cannot be before starting date or after ending date.'),
              );
            }
        );
        return false;
      }
      else{
        return true;
      }
    }
  }
}