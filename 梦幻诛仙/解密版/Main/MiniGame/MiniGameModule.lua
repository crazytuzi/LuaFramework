local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local MiniGameModule = Lplus.Extend(ModuleBase, "MiniGameModule")
local def = MiniGameModule.define
local instance
def.static("=>", MiniGameModule).Instance = function()
  if instance == nil then
    instance = MiniGameModule()
    instance.m_moduleId = ModuleId.MINI_GAME
  end
  return instance
end
def.override().Init = function(self)
  require("Main.MiniGame.MusicGameMgr").Instance():Init()
  require("Main.MiniGame.BubbleGameMgr").Instance():Init()
  require("Main.MiniGame.MemoryGame.MemoryGameMgr").Instance():Init()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  require("Main.MiniGame.MusicGameMgr").Instance():OnReset()
  require("Main.MiniGame.BubbleGameMgr").Instance():OnReset()
  require("Main.MiniGame.MemoryGame.MemoryGameMgr").Instance():OnReset()
end
return MiniGameModule.Commit()
