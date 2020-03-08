local crypto = {}
function crypto.encryptAES256(plaintext, key)
  plaintext = tostring(plaintext)
  key = tostring(key)
  return CCCrypto:encryptAES256(plaintext, string.len(plaintext), key, string.len(key))
end
function crypto.decryptAES256(ciphertext, key)
  ciphertext = tostring(ciphertext)
  key = tostring(key)
  return CCCrypto:decryptAES256(ciphertext, string.len(ciphertext), key, string.len(key))
end
function crypto.encryptXXTEA(plaintext, key)
  plaintext = tostring(plaintext)
  key = tostring(key)
  return CCCrypto:encryptXXTEA(plaintext, string.len(plaintext), key, string.len(key))
end
function crypto.decryptXXTEA(ciphertext, key)
  ciphertext = tostring(ciphertext)
  key = tostring(key)
  return CCCrypto:decryptXXTEA(ciphertext, string.len(ciphertext), key, string.len(key))
end
function crypto.encodeBase64(plaintext)
  plaintext = tostring(plaintext)
  return CCCrypto:encodeBase64(plaintext, string.len(plaintext))
end
function crypto.decodeBase64(ciphertext)
  ciphertext = tostring(ciphertext)
  return CCCrypto:decodeBase64(ciphertext)
end
function crypto.md5(input, isRawOutput)
  input = tostring(input)
  if type(isRawOutput) ~= "boolean" then
    isRawOutput = false
  end
  return CCCrypto:MD5(input, isRawOutput)
end
function crypto.md5file(path)
  if not path then
    printError("crypto.md5file() - invalid filename")
    return nil
  end
  path = tostring(path)
  if DEBUG > 1 then
    printInfo("crypto.md5file() - filename: %s", path)
  end
  return CCCrypto:MD5File(path)
end
return crypto
