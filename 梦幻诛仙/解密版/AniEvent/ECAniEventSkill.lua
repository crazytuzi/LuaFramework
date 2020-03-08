local Lplus = require("Lplus")
local ECFxMan = require("Fx.ECFxMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECAniEvent = Lplus.ForwardDeclare("ECAniEvent")
local ECHostPlayer = require("Players.ECHostPlayer")
local EC = require("Types.Vector3")
local ECAniEventSkill = Lplus.Class("ECAniEventSkill")
local def = ECAniEventSkill.define
def.field(ECHostPlayer).mHostPlayer = nil
local instance
def.static("=>", ECAniEventSkill).Instance = function()
  if instance == nil then
    instance = ECAniEventSkill()
  end
  instance:Init()
  return instance
end
def.method().Init = function(self)
  if self.mHostPlayer == nil then
    self.mHostPlayer = ECGame.Instance().m_HostPlayer
  end
end
local ECObject = require("Object.ECObject")
def.method(ECObject, "number", "number", "=>", "boolean").OnAniEvent = function(self, sender, perform_id, param2)
  if sender == nil then
    return false
  end
  if sender.SkillHdl == nil or sender.SkillHdl.SkillInfo == nil then
    return false
  end
  local cur_skill = sender.SkillHdl.SkillInfo.Skill
  if not cur_skill:ContainsPerform(perform_id) then
    return false
  end
  local world = ECGame.Instance().m_CurWorld
  local skillmgr = ECGame.Instance().m_SkillMgr
  local cur_perform = skillmgr:GetPerform(perform_id)
  local att_ids = {
    cur_perform:get_skill_gfx_ids()
  }
  if att_ids == nil or #att_ids == 0 then
    return false
  end
  local att_id = att_ids[1]
  local AttData = require("Data.AttData")
  local data = AttData.Instance()
  local att_type = data:GetAttType(att_id)
  local gfxid = data:GetGfxID(att_id)
  local skillgfx = skillmgr:GetSkillGfx(gfxid)
  local gfx = skillgfx.FilePath
  if gfx == nil then
    return false
  end
  local sender_go = sender:GetGameObject()
  if sender_go == nil then
    return false
  end
  local sender_rot = sender_go.rotation
  local local_pos = skillgfx.Pos
  local local_rot = Quaternion.Euler(skillgfx.Rot)
  local as_child = Quaternion.Euler(skillgfx.AsChild)
  if att_type == AttData.ATT_TYPE.AT_NORMAL then
    if not as_child then
      ECFxMan.Instance():Play(gfx, sender_go:TransformPoint(local_pos), sender_rot * local_rot, 15, false, -1)
    else
      ECFxMan.Instance():PlayAsChild(gfx, sender_go, local_pos, local_rot, 15, false)
    end
  else
    if not sender.SkillHdl.SkillInfo.HasSkillTargetID then
      return false
    end
    local target = world:FindObjectOrHost(sender.SkillHdl.SkillInfo.SkillTargetID)
    if target == nil then
      return false
    end
    local target_go = target:GetGameObject()
    local target_is_exist = false
    local dest
    if target_go ~= nil then
      dest = target_go:FindChild("Bip01 Spine2")
      if dest ~= nil then
        target_is_exist = true
      end
    end
    if att_type == AttData.ATT_TYPE.AT_FLY then
      local att_speed = data:GetFlySpeed(att_id)
      local cb
      local start_pos = sender_go:TransformPoint(local_pos)
      if target_is_exist then
        local duration = GameUtil.Distance(start_pos, target:GetPos()) / att_speed
        ECFxMan.Instance():Fly(gfx, start_pos, dest, cb, att_speed, duration, 0.2, false)
      else
        local duration = 0.7
        dest = sender:GetPos() + sender:GetDir() * att_speed * duration
        ECFxMan.Instance():Fly(gfx, start_pos, dest, cb, att_speed, duration, 0.2, false)
      end
    elseif att_type == AttData.ATT_TYPE.AT_STATIC then
      local target_rot = target_go.rotation
      if target_is_exist then
        ECFxMan.Instance():Play(gfx, target_go:TransformPoint(local_pos), target_rot * local_rot, 15, false, -1)
      else
        local dis = 7
        dest = sender:GetPos() + sender:GetDir() * dis
        ECFxMan.Instance():Play(gfx, dest, local_rot, 15, false, -1)
      end
    elseif att_type == AttData.ATT_TYPE.AT_GRENADE then
    end
  end
  return true
end
ECAniEventSkill.Commit()
return ECAniEventSkill
