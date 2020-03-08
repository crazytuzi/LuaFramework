local Lplus = require("Lplus")
local client_cfg = dofile("Configs/client_cfg.lua")
local charge_cfg = dofile("Configs/charge_cfg.lua")
local local_cfg = dofile("data/luacfg/local_data.lua")
local ClientCfg = Lplus.Class("Configs.ClientCfg")
do
  local def = ClientCfg.define
  def.const("table").SDKTYPE = {
    NON = 0,
    MSDK = 1,
    UNISDK = 2
  }
  def.static("=>", "string").GetCfgEnv = function()
    if not StreamingAssetHelper or not StreamingAssetHelper.ReadFileText then
      return "release"
    end
    local content = StreamingAssetHelper.ReadFileText("zlconfig.ini")
    if not content then
      return "release"
    end
    local json = require("Utility.json")
    local config = json.decode(content)
    return config.midasDebug and "test" or "release"
  end
  def.static("=>", "table").GetPayCfgData = function(payID)
    return charge_cfg
  end
  def.static("=>", "number").GetSDKType = function()
    return _G.platform == 0 and ClientCfg.SDKTYPE.NON or client_cfg.sdktype
  end
  def.static("=>", "boolean").IsSpeechTranslate = function()
    return client_cfg.translate
  end
  def.static("=>", "boolean").IsSurportApollo = function()
    return client_cfg.apollo
  end
  def.static("=>", "boolean").IsOtherChannel = function()
    if not StreamingAssetHelper or not StreamingAssetHelper.ReadFileText then
      return false
    end
    local content = StreamingAssetHelper.ReadFileText("zlconfig.ini")
    if not content then
      return false
    end
    local json = require("Utility.json")
    local config = json.decode(content)
    if config.officialChannel == nil then
      return false
    end
    return not config.officialChannel
  end
  def.static("number", "=>", "string").GetStoreUrl = function(platform)
    local store_url = local_cfg.store_url
    if store_url then
      return store_url[platform] or ""
    else
      return ""
    end
  end
end
return ClientCfg.Commit()
