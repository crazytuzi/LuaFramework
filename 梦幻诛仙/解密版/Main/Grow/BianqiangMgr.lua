local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local BianqiangMgr = Lplus.Class(CUR_CLASS_NAME)
local GrowModule = Lplus.ForwardDeclare("GrowModule")
local def = BianqiangMgr.define
local instance
def.static("=>", BianqiangMgr).Instance = function()
  if instance == nil then
    instance = BianqiangMgr()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("=>", "boolean").IsUnlock = function(self)
  return true
end
def.method().OnReset = function(self)
end
return BianqiangMgr.Commit()
