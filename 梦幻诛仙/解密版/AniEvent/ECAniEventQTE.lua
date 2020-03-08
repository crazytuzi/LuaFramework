local Lplus = require("Lplus")
local ECFxMan = require("Fx.ECFxMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECAniEvent = Lplus.ForwardDeclare("ECAniEvent")
local ECAniEventQTE = Lplus.Class("ECAniEventQTE")
local def = ECAniEventQTE.define
local Fx_AnimEvt_Pre = {
  iceball = "iceball",
  icebullet = "icebullet",
  blizzard = "blizzard"
}
local Fx_Img_Prefab = {
  icebullet_hit = RESPATH.icebullet_hit,
  qte_explosion = RESPATH.qte_explosion,
  iceball_hit = RESPATH.iceball_hit,
  blizzard = RESPATH.blizzard,
  iceshell = RESPATH.iceshell,
  icebullet = RESPATH.icebullet,
  iceball = RESPATH.iceball
}
local function OnMageButtletHit(go, target, str)
  local tt = ECAniEventQTE.Instance().mTarget
  ECFxMan.Instance():Play(Fx_Img_Prefab.icebullet_hit, tt.position, Quaternion.identity, 0.5, false, -1)
end
local function OnMageBalltHit(go, target, str)
  local tt = ECAniEventQTE.Instance().mTarget
  ECFxMan.Instance():Play(Fx_Img_Prefab.qte_explosion, tt.position, Quaternion.identity, 2, false, -1)
  ECFxMan.Instance():Play(Fx_Img_Prefab.iceball_hit, tt.position, Quaternion.identity, 0.5, false, -1)
  local ECCamRig = require("QTE.ECCamRig")
  ECCamRig.Instance():Shake(CameraShakeType.Normal)
end
def.method("string", "=>", "boolean").AniEvent_QTE = function(self, str)
  if self.mHostPlayer == nil or self.mTarget == nil then
    return false
  end
  if string.find(str, Fx_AnimEvt_Pre.blizzard) == 1 then
    ECFxMan.Instance():Play(Fx_Img_Prefab.blizzard, self.mTarget.position, Quaternion.identity, 1, false, -1)
    ECFxMan.Instance():Play(Fx_Img_Prefab.iceshell, self.mHostPlayer.position, Quaternion.identity, 1.5, false, -1)
    return true
  else
    local pos = self.mHostPlayer.position
    pos.y = pos.y + 1
    local dest = self.mTarget:FindChild("Bip01 Spine2")
    if not dest then
      return false
    end
    if string.find(string.lower(str), Fx_AnimEvt_Pre.iceball) == 1 then
      ECFxMan.Instance():Fly(Fx_Img_Prefab.icebullet, pos, dest, OnMageButtletHit, 15, 3, 0.3, false)
    else
      ECFxMan.Instance():Fly(Fx_Img_Prefab.iceball, pos, dest, OnMageBalltHit, 15, 3, 0.3, false)
    end
    return true
  end
  return false
end
def.method("number", "number", "=>", "boolean").OnAniEvent = function(self, id, gfx_id)
  local skillmgr = ECGame.Instance().m_SkillMgr
  if skillmgr == nil then
    return false
  end
  local cur_perform = skillmgr:GetPerform(id)
  if cur_perform == nil then
    return false
  end
  local having_this_gfx = cur_perform:IsHavingThisGfx(gfx_id)
  if having_this_gfx then
    local skill_gfx = skillmgr:GetSkillGfx(gfx_id)
    local gfx_path
    if skill_gfx ~= nil then
      gfx_path = skill_gfx.FilePath
    end
    if gfx_path ~= nil then
      return true
    end
  else
    return false
  end
end
def.method().Init = function(self)
  if self.mHostPlayer == nil then
    local playerT = ECGame.Instance().m_HostPlayer.m_ECModel.m_model
    self.mHostPlayer = playerT
  end
end
def.field("userdata").mHostPlayer = nil
def.field("userdata").mTrigger = nil
def.field("userdata").mTarget = nil
def.method("userdata").Set_AniEvent_Trigger = function(self, trigger)
  self.mTrigger = trigger
end
def.method("userdata").Set_AniEvent_Target = function(self, target)
  self.mTarget = target
  local world = ECGame.Instance().m_CurWorld
  if world then
    world.m_NPCMan.m_Qteobj = target
  end
end
local s_init
def.static("=>", ECAniEventQTE).Instance = function()
  if s_init == nil then
    s_init = ECAniEventQTE()
  end
  s_init:Init()
  return s_init
end
ECAniEventQTE.Commit()
return ECAniEventQTE
