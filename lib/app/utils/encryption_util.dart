// lib/app/utils/encryption_util.dart
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'dart:convert';
import 'dart:typed_data';

/// 加密工具类，用于实现RSA加密和解密功能
class EncryptionUtil {
  /// 使用公钥加密消息
  static String encryptMessage(String message, String publicKeyString) {
    try {
      if (publicKeyString.isEmpty) {
        print('公钥为空，无法加密');
        return message;
      }

      // 移除 0x 前缀
      String hex = publicKeyString.replaceAll('0x', '').toLowerCase();

      // 只移除一个前导的 00 字节（如果存在），这通常是后端为避免符号问题添加的
      if (hex.startsWith('00')) {
        hex = hex.substring(2);
      }
      if (hex.isEmpty) hex = '0'; // 防止全0

      final modulus = BigInt.parse(hex, radix: 16);
      final exponent = BigInt.from(65537);

      final publicKey = RSAPublicKey(modulus, exponent);

      final encrypter = Encrypter(RSA(
        publicKey: publicKey,
        encoding: RSAEncoding.PKCS1, // 与后端保持一致
      ));

      final encrypted = encrypter.encrypt(message);
      print('加密成功，密文: ${encrypted.base64}');
      return encrypted.base64;
    } catch (e) {
      print('加密失败: $e');
      return message; // 失败返回明文，便于调试
    }
  }

  /// 使用私钥解密消息
  static String decryptMessage(
      String encryptedMessage, String privateKeyString) {
    try {
      // 确保私钥字符串不为空
      if (privateKeyString.isEmpty) {
        print('私钥为空，无法解密');
        return encryptedMessage;
      }

      // 确保密文不为空
      if (encryptedMessage.isEmpty) {
        print('密文为空，无需解密');
        return '';
      }

      // 创建RSA解密器
      final privateKey = 
          RSAKeyParser().parse(privateKeyString) as RSAPrivateKey;
      final encrypter = 
          Encrypter(RSA(privateKey: privateKey, encoding: RSAEncoding.PKCS1));

      // 解密消息，先尝试Base64，失败则尝试十六进制
      String decrypted;
      try {
        // 先尝试Base64解密
        decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedMessage));
        print('Base64解密成功: $decrypted');
      } catch (base64Error) {
        print('Base64解密失败，尝试十六进制解密: $base64Error');
        
        // 移除十六进制前缀（如果有）
        String hex = encryptedMessage.replaceAll('0x', '').toLowerCase();
        
        // 转换十六进制字符串为字节数组
        final bytes = _hexToBytes(hex);
        
        // 使用字节数组解密
        decrypted = encrypter.decrypt(Encrypted(bytes));
        print('十六进制解密成功: $decrypted');
      }

      return decrypted;
    } catch (e) {
      print('解密失败: $e');
      print('密文内容: $encryptedMessage');
      print('私钥: ${privateKeyString.substring(0, 50)}...'); // 只打印部分私钥
      return encryptedMessage; // 解密失败时返回密文
    }
  }

  /// 将十六进制字符串转换为字节数组
  static Uint8List _hexToBytes(String hexString) {
    // 移除可能的前缀
    hexString = hexString.replaceAll('0x', '');

    // 确保字符串长度为偶数
    if (hexString.length % 2 != 0) {
      hexString = '0$hexString';
    }

    // 转换为字节数组
    final bytes = Uint8List(hexString.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      final hex = hexString.substring(i * 2, (i + 1) * 2);
      bytes[i] = int.parse(hex, radix: 16);
    }

    return bytes;
  }
}
