// lib/app/utils/encryption_util.dart

import 'dart:typed_data';
import 'dart:math'; // 用于 Random.secure()

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart' as pc; // 关键：统一用 export.dart

/// 加密工具类，用于实现RSA非对称加密
class EncryptionUtil {
  static Map<String, String> generateRSAKeyPair() {
  final secureRandom = pc.FortunaRandom();
  final seed = List<int>.generate(32, (_) => Random.secure().nextInt(256));
  secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seed)));

  final keyGen = pc.RSAKeyGenerator();
  keyGen.init(
    pc.ParametersWithRandom(
      pc.RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
      secureRandom,
    ),
  );

  final pair = keyGen.generateKeyPair();
  final publicKey = pair.publicKey as pc.RSAPublicKey;
  final privateKey = pair.privateKey as pc.RSAPrivateKey;

  final modulus = publicKey.modulus ?? BigInt.zero;
  final d = privateKey.privateExponent ?? BigInt.zero;
  final p = privateKey.p ?? BigInt.zero;
  final q = privateKey.q ?? BigInt.zero;

  return {
    'publicKey': modulus.toRadixString(16),
    'privateKey': d.toRadixString(16),
    'p': p.toRadixString(16),
    'q': q.toRadixString(16),
  };
}

  /// 使用公钥加密消息
  static String encryptMessage(String message, String publicKeyHex) {
    if (message.isEmpty || publicKeyHex.isEmpty) {
      print('加密失败：消息或公钥为空');
      return message;
    }
    try {
      String hex = publicKeyHex.replaceAll('0x', '').toLowerCase();
      while (hex.startsWith('00')) {
        hex = hex.substring(2);
      }
      if (hex.isEmpty) hex = '0';

      final modulus = BigInt.parse(hex, radix: 16);
      final publicKey = RSAPublicKey(modulus, BigInt.from(65537));

      final encrypter =
          Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1));
      return encrypter.encrypt(message).base64;
    } catch (e) {
      print('加密失败: $e');
      return message;
    }
  }

  static String decryptMessage(
    String encryptedBase64,
    String privateKeyDHex,
    String modulusNHex,
  ) {
    if (encryptedBase64.isEmpty) return '';
    if (privateKeyDHex.isEmpty || modulusNHex.isEmpty) {
      print('解密失败：私钥或模数为空');
      return '[密钥缺失]';
    }

    try {
      // 处理模数 n
      String nHex = modulusNHex.replaceAll('0x', '').toLowerCase();
      while (nHex.startsWith('00')) {
        nHex = nHex.substring(2);
      }
      if (nHex.isEmpty) nHex = '0';
      final modulus = BigInt.parse(nHex, radix: 16);

      // 处理私钥 d
      String dHex = privateKeyDHex.replaceAll('0x', '').toLowerCase();
      if (dHex.length % 2 != 0) dHex = '0$dHex';
      // 去掉前导零（可选，但保持一致）
      while (dHex.startsWith('00') && dHex.length > 2) {
        dHex = dHex.substring(2);
      }
      if (dHex.isEmpty) dHex = '0';
      final d = BigInt.parse(dHex, radix: 16);

      if (modulus == BigInt.zero || d == BigInt.zero) {
        print('解密失败：解析后的 modulus 或 d 为零');
        return '[密钥无效]';
      }

      final privateKey = RSAPrivateKey(modulus, d, null, null);

      final encrypter = Encrypter(RSA(
        privateKey: privateKey,
        encoding: RSAEncoding.PKCS1,
      ));

      final decrypted =
          encrypter.decrypt(Encrypted.fromBase64(encryptedBase64));
      return decrypted;
    } catch (e, stack) {
      print('解密详细错误: $e');
      print('密文: $encryptedBase64');
      print('dHex 长度: ${privateKeyDHex.length}');
      print('nHex 长度: ${modulusNHex.length}');
      print(stack);
      return '[解密失败: $e]';
    }
  }

  /// Hex 转 Bytes（备用）
  static Uint8List hexToBytes(String hexString) {
    hexString = hexString.replaceAll('0x', '').toLowerCase();
    if (hexString.length % 2 != 0) {
      hexString = '0$hexString';
    }
    final bytes = Uint8List(hexString.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(hexString.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }
}
