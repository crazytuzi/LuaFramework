local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PlayerPKModule = Lplus.Extend(ModuleBase, "PlayerPKModule")
local instance
local def = PlayerPKModule.define
def.static("=>", PlayerPKModule).Instance = function()
  if instance == nil then
    instance = PlayerPKModule()
  end
  return instance
end
def.override().Init = function(self)
  require("Main.PlayerPK.PKMgr").Instance():Init()
  require("Main.PlayerPK.WantedMgr").Instance():Init()
  require("Main.PlayerPK.PrisonMgr").Instance():Init()
end
return PlayerPKModule.Commit()
