local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BattlefieldMapMgrBase = Lplus.Class(MODULE_NAME)
local def = BattlefieldMapMgrBase.define
def.field("table").m_miniMap = nil
def.method("table").Create = function(self, params)
  self.m_miniMap = params.miniMap
  self:OnCreate()
end
def.virtual().OnCreate = function(self)
end
def.method().Destroy = function(self)
  self.m_miniMap = nil
  self:OnDestroy()
end
def.virtual().OnDestroy = function(self)
end
return BattlefieldMapMgrBase.Commit()
