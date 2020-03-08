local Lplus = require("Lplus")
local ECCamCtrl = require("Camera.ECCamCtrl")
local ECMainCamCtrl = require("Camera.ECMainCamCtrl")
local ECCGCamCtrl = require("Camera.ECCGCamCtrl")
local EC = require("Types.Vector3")
local ECCamCtrlMan = Lplus.Class("ECCamCtrlMan")
local def = ECCamCtrlMan.define
def.field("userdata").m_Cam = nil
def.field(ECCamCtrl).m_CurCtrl = nil
def.field(ECMainCamCtrl).m_MainCamCtrl = nil
def.field(ECCGCamCtrl).m_CGCamCtrl = nil
def.method("number").Tick = function(self, dt)
  local ctrl = self.m_CurCtrl
  if ctrl then
    ctrl:Tick(dt)
  end
end
def.method().Init = function(self)
  local cam = ECMainCamCtrl.new(self)
  cam:Init()
  self.m_MainCamCtrl = cam
  local cg = ECCGCamCtrl.new(self)
  cg:Init()
  self.m_CGCamCtrl = cg
end
def.method("number", "=>", ECCamCtrl).GetCtrl = function(self, camtype)
  if camtype == ECCamCtrl.CAMCTRL_CLASS.Main then
    return self.m_MainCamCtrl
  elseif camtype == ECCamCtrl.CAMCTRL_CLASS.CG then
    return self.m_CGCamCtrl
  end
  return nil
end
def.method("number").SetCurCtrl = function(self, camtype)
  local camctrl = self:GetCtrl(camtype)
  self.m_CurCtrl = camctrl
end
ECCamCtrlMan.Commit()
return ECCamCtrlMan
