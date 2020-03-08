local ModuleBase = require("Main.module.ModuleBase")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local Lplus = require("Lplus")
local RelationShipChainModule = Lplus.Extend(ModuleBase, "RelationShipChainModule")
local def = RelationShipChainModule.define
local instance
def.static("=>", RelationShipChainModule).Instance = function()
  if not instance then
    instance = RelationShipChainModule()
    instance.m_moduleId = ModuleId.RELATIONSHIPCHAIN
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  RelationShipChainMgr.Instance():Init()
end
def.override().OnReset = function(self)
  RelationShipChainMgr.Instance:Reset()
end
RelationShipChainModule.Commit()
return RelationShipChainModule
