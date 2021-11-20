import 'package:flutter/material.dart';
import 'package:stripe_api_2/stripe_api.dart';

class CreditCardMaskedTextController extends TextEditingController {
  CreditCardMaskedTextController({required String text}) : super(text: text) {
    _translator = CreditCardMaskedTextController._getDefaultTranslator();

    addListener(() {
      _updateText(this.text);
    });

    _updateText(this.text);
  }

  static const CARD_MASKS = {
    StripeCard.unknown: '0000 0000 0000 0000',
    StripeCard.americanExpress: '0000 000000 00000',
    StripeCard.discover: '0000 0000 0000 0000',
    StripeCard.jcb: '0000 0000 0000 0000',
    StripeCard.dinersClub: '0000 0000 0000 00',
    StripeCard.visa: '0000 0000 0000 0000',
    StripeCard.masterCard: '0000 0000 0000 0000',
    StripeCard.unionPay: '0000 0000 0000 0000',
  };

  late Map<String, RegExp> _translator;
  String _lastUpdatedText = '';

  void _updateText(String? text) {
    if (text != null) {
      final cardType = getPossibleCardType(text, shouldNormalize: true);
      final mask = CARD_MASKS[cardType];
      this.text = _applyMask(mask!, text);
    } else {
      this.text = '';
    }
    this._lastUpdatedText = this.text;
  }

  void _moveCursorToEnd() {
    var text = this._lastUpdatedText;
    this.selection = TextSelection.fromPosition(
      TextPosition(offset: (text ?? '').length),
    );
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      _moveCursorToEnd();
    }
  }

  static Map<String, RegExp> _getDefaultTranslator() {
    return {
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  String _applyMask(String mask, String value) {
    String result = '';

    int maskCharIndex = 0;
    int valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      var maskChar = mask[maskCharIndex];
      var valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (_translator.containsKey(maskChar)) {
        if (_translator[maskChar]!.hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}
