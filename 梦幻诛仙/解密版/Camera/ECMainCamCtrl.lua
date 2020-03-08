local Lplus = require("Lplus")
local ECCamCtrl = require("Camera.ECCamCtrl")
local EC = require("Types.Vector3")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECHostPlayer = Lplus.ForwardDeclare("ECHostPlayer")
local ECCamCtrlMan = Lplus.ForwardDeclare("ECCamCtrlMan")
local ECMainCamCtrl = Lplus.Extend(ECCamCtrl, "ECMainCamCtrl")
local def = ECMainCamCtrl.define
def.final(ECCamCtrlMan, "=>", ECMainCamCtrl).new = function(man)
  local obj = ECMainCamCtrl()
  obj.m_ClassID = ECCamCtrl.CAMCTRL_CLASS.Main
  obj.m_Mgr = man
  return obj
end
def.override("number").Tick = function(self, dt)
end
def.method().Init = function()
end
ECMainCamCtrl.Commit()
return ECMainCamCtrl
