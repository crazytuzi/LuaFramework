local Lplus = require("Lplus")
local ECCamCtrl = require("Camera.ECCamCtrl")
local EC = require("Types.Vector3")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECHostPlayer = Lplus.ForwardDeclare("ECHostPlayer")
local ECCamCtrlMan = Lplus.ForwardDeclare("ECCamCtrlMan")
local ECCGCamCtrl = Lplus.Extend(ECCamCtrl, "ECCGCamCtrl")
local def = ECCGCamCtrl.define
def.final(ECCamCtrlMan, "=>", ECCGCamCtrl).new = function(man)
  local obj = ECCGCamCtrl()
  obj.m_ClassID = ECCamCtrl.CAMCTRL_CLASS.CG
  obj.m_Mgr = man
  return obj
end
def.override("number").Tick = function(self, dt)
end
def.method().Init = function()
end
ECCGCamCtrl.Commit()
return ECCGCamCtrl
