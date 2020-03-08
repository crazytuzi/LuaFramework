local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GRCUtility = Lplus.Class(MODULE_NAME)
local def = GRCUtility.define
local RSA_PUBLICKEY_FILE_PATH = "Configs/grc_rsa_publickey.xml"
local _rsaPublicKey
def.static("string", "=>", "string").RSAEncryptToBase64 = function(content)
  return GRCUtility.RSAEncryptToBase64Ex(content, nil)
end
def.static("string", "table", "=>", "string").RSAEncryptToBase64Ex = function(content, params)
  if _G.CUR_CODE_VERSION < _G.RSA_CODE_VERSION then
    warn("[error] GRCUtility.RSAEncryptToBase64Ex: CUR_CODE_VERSION too low")
    return ""
  end
  params = params or {}
  local publicKey = GRCUtility.GetRSAPublicKey()
  if publicKey == "" then
    return ""
  end
  if not params.retainKeyCache then
    GRCUtility.ReleasePublicKeyCache()
  end
  return GameUtil.RSAEncryptToBase64WithPublicKey(publicKey, content) or ""
end
def.static("=>", "string").GetRSAPublicKey = function()
  if _rsaPublicKey then
    return _rsaPublicKey
  end
  local bytes = GameUtil.ReadFileAllContent(RSA_PUBLICKEY_FILE_PATH)
  _rsaPublicKey = bytes and bytes:get_string()
  if _rsaPublicKey == nil then
    warn(string.format("[error] GRCUtility.GetRSAPublicKey: GameUtil.ReadFileAllContent(%s) return nil", RSA_PUBLICKEY_FILE_PATH))
    return ""
  end
  return _rsaPublicKey
end
def.static().ReleasePublicKeyCache = function()
  _rsaPublicKey = nil
end
return GRCUtility.Commit()
