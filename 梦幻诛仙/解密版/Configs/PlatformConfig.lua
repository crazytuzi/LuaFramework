local Lplus = require("Lplus")
local all_platform_config = dofile("Configs/all_platform_config.lua")
local PlatformConfig = Lplus.Class("Configs.PlatformConfig")
do
  local def = PlatformConfig.define
  local _platform = all_platform_config.platform or "default"
  if _platform == "default" then
    if _G.platform == _G.Platform.android then
      _platform = "android"
    elseif _G.platform == _G.Platform.ios then
      _platform = "ios"
    elseif _G.platform == _G.Platform.win then
      _platform = "pc"
    end
  end
  def.static("string", "=>", "table").GetConfig = function(configName)
    if all_platform_config[_platform] == nil then
      return nil
    end
    return all_platform_config[_platform][configName]
  end
end
return PlatformConfig.Commit()
