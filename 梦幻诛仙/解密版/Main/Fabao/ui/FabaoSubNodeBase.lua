local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FabaoSubNodeBase = Lplus.Class("FabaoSubNodeBase")
local def = FabaoSubNodeBase.define
def.field("userdata").m_nodeRoot = nil
def.field(ECPanelBase).m_base = nil
def.field("table").m_CurFabao = nil
def.virtual(ECPanelBase, "userdata").Init = function(self, base, nodeRoot)
  self.m_nodeRoot = nodeRoot
  self.m_base = base
end
def.method("table").Show = function(self, curFabao)
  self.m_CurFabao = curFabao
  self:OnShow()
  self.m_nodeRoot:SetActive(true)
end
def.virtual().OnShow = function(self)
end
def.method().Hide = function(self)
  self:OnHide()
  self.m_nodeRoot:SetActive(false)
end
def.virtual().OnHide = function(self)
end
def.virtual().Update = function(self)
end
def.virtual("userdata").onClickObj = function(self, clickObj)
end
FabaoSubNodeBase.Commit()
return FabaoSubNodeBase
