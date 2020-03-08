local Lplus = require("Lplus")
local ECCamCtrlMan = Lplus.ForwardDeclare("ECCamCtrlMan")
local ECCamCtrl = Lplus.Class("ECCamCtrl")
local def = ECCamCtrl.define
def.const("table").CAMCTRL_CLASS = {
  Login = 1,
  Main = 2,
  CG = 3
}
def.field("number").m_ClassID = 0
def.field(ECCamCtrlMan).m_Mgr = nil
def.virtual("number").Tick = function(dt)
end
ECCamCtrl.Commit()
return ECCamCtrl
