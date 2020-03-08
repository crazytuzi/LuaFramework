local ModuleBase = require("Main.module.ModuleBase")
local DyeingMgr = require("Main.Dyeing.DyeingMgr")
local Lplus = require("Lplus")
local DyeingModule = Lplus.Extend(ModuleBase, "DyeingModule")
local def = DyeingModule.define
local instance
def.static("=>", DyeingModule).Instance = function()
  if not instance then
    instance = DyeingModule()
    instance.m_moduleId = ModuleId.DYEING
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  DyeingMgr.Instance():Init()
end
def.override().OnReset = function(self)
  DyeingMgr.Instance:Reset()
end
DyeingModule.Commit()
return DyeingModule
