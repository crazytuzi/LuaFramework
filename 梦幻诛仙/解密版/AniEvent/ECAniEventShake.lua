local Lplus = require("Lplus")
local ECCamRig = require("QTE.ECCamRig")
local ECAniEventShake = Lplus.Class("ECAniEventShake")
local def = ECAniEventShake.define
def.field("userdata").mAnimationForShake = nil
local m_Inst
def.static("=>", ECAniEventShake).Instance = function()
  if m_Inst == nil then
    m_Inst = ECAniEventShake()
  end
  m_Inst:Init(ECCamRig.Instance().mAnim)
  return m_Inst
end
def.method("userdata").Init = function(self, CameraShakeComp)
  self.mAnimationForShake = CameraShakeComp
end
def.method("number", "number", "=>", "boolean").OnAniEvent = function(self, param1, param2)
  return true
end
return ECAniEventShake.Commit()
