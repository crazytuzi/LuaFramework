local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BaseSharePanel = Lplus.Extend(ECPanelBase, "BaseSharePanel")
local RelationShipChainMgr = Lplus.ForwardDeclare("RelationShipChainMgr")
local def = BaseSharePanel.define
def.override().OnCreate = function(self)
  RelationShipChainMgr.PrepareShare(true, function()
    return self
  end, function()
    self:OnShare()
  end)
end
def.virtual().OnShare = function(self)
end
BaseSharePanel.Commit()
return BaseSharePanel
