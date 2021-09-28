local crypt = require("cryptext")
function func1()
  local serverkey = crypt.randomkey()
  local clientkey = crypt.randomkey()
  local secret = crypt.dhsecret(serverkey, clientkey)
  local etoken = crypt.desencode(secret, "i'm text i'm text i'm text i'm text")
  local token = crypt.desdecode(secret, etoken)
  print(token)
end
function func2()
  local challenge = crypt.randomkey()
  local clientkey = crypt.randomkey()
  local exchangeC = crypt.dhexchange(clientkey)
  local serverkey = crypt.randomkey()
  local exchangeS = crypt.dhexchange(serverkey)
  local secret1 = crypt.dhsecret(exchangeC, serverkey)
  local secret2 = crypt.dhsecret(exchangeS, clientkey)
  print(crypt.base64encode(secret1), crypt.base64encode(secret2))
end
function func3()
  print([[


 func3:]])
  local encryptedData = "Yp1FN+qPeezv/ZVT7T9sa7Vjtqa7EpBITCWJyrJYiRFnG2eVFHH2d7T3pZXQaUXM9RQOaSo1xGvfGfkgGMO2lQ=="
  local secret = "PMfzDNKpalc="
  local decodeBase64 = crypt.base64decode(encryptedData)
  print("decodeBase64:", decodeBase64)
  local decodeDes = crypt.desdecode(crypt.base64decode(secret), decodeBase64)
  print("data:", decodeDes)
end
func3()
