import 'model/card.dart';
import 'text_utils.dart';

import 'stripe_text_utils.dart';

const int LENGTH_COMMON_CARD = 16;
const int LENGTH_AMERICAN_EXPRESS = 15;
const int LENGTH_DINERS_CLUB = 14;

const int MAX_LENGTH_COMMON = 19;
// Note that AmEx and Diners Club have the same length
// because Diners Club has one more space, but one less digit.
const int MAX_LENGTH_AMEX_DINERS = 17;

/**
 * Checks the input string to see whether or not it is a valid card number, possibly
 * with groupings separated by spaces or hyphens.
 *
 * @param cardNumber a String that may or may not represent a valid card number
 * @return {@code true} if and only if the input value is a valid card number
 */
bool isValidCardNumber(String? cardNumber) {
  String? normalizedNumber = removeSpacesAndHyphens(cardNumber);
  return isValidLuhnNumber(normalizedNumber) &&
      isValidCardLength(normalizedNumber);
}

/**
 * Checks the input string to see whether or not it is a valid Luhn number.
 *
 * @param cardNumber a String that may or may not represent a valid Luhn number
 * @return {@code true} if and only if the input value is a valid Luhn number
 */
bool isValidLuhnNumber(String? cardNumber) {
  if (cardNumber == null) {
    return false;
  }

  bool isOdd = true;
  int sum = 0;

  for (int index = cardNumber.length - 1; index >= 0; index--) {
    var c = cardNumber[index];
    if (!isDigit(c)) {
      return false;
    }

    int? digitInteger = getNumericValue(c);
    isOdd = !isOdd;

    if (digitInteger !=null && isOdd) {
      digitInteger *= 2;
    }

    if (digitInteger !=null && digitInteger > 9) {
      digitInteger -= 9;
    }
    if(digitInteger !=null ) {
      sum += digitInteger;
    }
  }

  return sum % 10 == 0;
}

/// Checks to see whether the input number is of the correct length, given the assumed brand of
/// the card. This function does not perform a Luhn check.
///
/// @param cardNumber the card number with no spaces or dashes
/// @param cardBrand a {@link CardBrand} used to get the correct size
/// @return {@code true} if the card number is the correct length for the assumed brand
bool isValidCardLength(String? cardNumber, {String? cardBrand}) {
  cardBrand ??= getPossibleCardType(cardNumber, shouldNormalize: false);
  if (cardNumber == null || StripeCard.unknown == cardBrand) {
    return false;
  }

  int length = cardNumber.length;
  switch (cardBrand) {
    case StripeCard.americanExpress:
      return length == LENGTH_AMERICAN_EXPRESS;
    case StripeCard.dinersClub:
      return length == LENGTH_DINERS_CLUB;
    default:
      return length == LENGTH_COMMON_CARD;
  }
}

String getPossibleCardType(String ?cardNumber, {bool shouldNormalize = true}) {
  if (isBlank(cardNumber)) {
    return StripeCard.unknown;
  }

  String? spacelessCardNumber = cardNumber;
  if (shouldNormalize) {
    spacelessCardNumber = removeSpacesAndHyphens(cardNumber);
  }

  if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_AMERICAN_EXPRESS)) {
    return StripeCard.americanExpress;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_DISCOVER)) {
    return StripeCard.discover;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_JCB)) {
    return StripeCard.jcb;
  } else if (hasAnyPrefix(
      spacelessCardNumber, StripeCard.PREFIXES_DINERS_CLUB)) {
    return StripeCard.dinersClub;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_VISA)) {
    return StripeCard.visa;
  } else if (hasAnyPrefix(
      spacelessCardNumber, StripeCard.PREFIXES_MASTERCARD)) {
    return StripeCard.masterCard;
  } else if (hasAnyPrefix(spacelessCardNumber, StripeCard.PREFIXES_UNIONPAY)) {
    return StripeCard.unionPay;
  } else {
    return StripeCard.unknown;
  }
}

int getLengthForBrand(String cardBrand) {
  if (StripeCard.americanExpress == cardBrand ||
      StripeCard.dinersClub == cardBrand) {
    return MAX_LENGTH_AMEX_DINERS;
  } else {
    return MAX_LENGTH_COMMON;
  }
}
