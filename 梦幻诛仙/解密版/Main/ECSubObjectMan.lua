local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECManager = require("Main.ECManager")
local ECFxMan = require("Fx.ECFxMan")
local ECSoundMan = require("Sound.ECSoundMan")
local ECObjectSkillHdl = require("Object.ECObjectSkillHdl")
local ECSubObjectMan = Lplus.Extend(ECManager, "ECSubObjectMan")
local def = ECSubObjectMan.define
def.field("table").SubObjMap = nil
def.final("=>", ECSubObjectMan).new = function()
  local obj = ECSubObjectMan()
  obj:Init(ECManager.EC_MAN_ENUM.MAN_SUBOBJECT)
  obj.SubObjMap = {}
  return obj
end
def.method("table").SubObjectEntre = function(self, data)
  if self.SubObjMap == nil then
    self.SubObjMap = {}
  end
  if self.SubObjMap[data.id] == nil then
    self.SubObjMap[data.id] = {}
  end
  self.SubObjMap[data.id].Owner = data.owner_id
  self.SubObjMap[data.id].GFX = nil
  local skillmgr = ECGame.Instance().m_SkillMgr
  local subobjskill = skillmgr:GetSubObjectSkill(data.tid)
  if subobjskill ~= nil then
    local params = subobjskill.PerformList[1]
    if params ~= nil then
      local gfxparam = skillmgr:GetSkillGfx(params.SkillGfxIDs[1])
      if gfxparam ~= nil then
        local gfxpath = gfxparam.FilePath
        local gfx = ECFxMan.Instance():Play(gfxpath, data.pos, Quaternion.identity, -1, false, -1)
        self.SubObjMap[data.id].GFX = gfx
      end
    end
  end
end
def.method("string").SubObjectLeave = function(self, id)
  local obj = self.SubObjMap[id]
  if obj ~= nil and obj.GFX ~= nil and not obj.GFX.isnil then
    ECFxMan.Instance():Stop(obj.GFX)
  end
  self.SubObjMap[id] = nil
end
def.method("table").SubObjectTakeEffect = function(self, cmd)
  local performid = cmd.perform_id
  local targetids = cmd.target_id_list
  if performid == 0 or targetids == nil or #targetids == 0 then
    return
  end
  local skillmgr = ECGame.Instance().m_SkillMgr
  local perform = skillmgr:GetSubObjectPerform(performid)
  if perform == nil then
    return
  end
  local hitgfx_id = perform.HitGfxID
  local hitsfx_id = perform.HitSfxID
  local gfxparam = skillmgr:GetSkillGfx(hitgfx_id)
  local gfxpath = ""
  if gfxparam ~= nil then
    gfxpath = gfxparam.FilePath
  end
  local world = ECGame.Instance().m_CurWorld
  for k, v in pairs(targetids) do
    local target = world:FindObject(v)
    if target ~= nil and target:GetGameObject() ~= nil and not target:IsDead() then
      local go = ECObjectSkillHdl.FindHitHookObject(target)
      if gfxpath ~= "" and go ~= nil then
        ECFxMan.Instance():Play(gfxpath, go.position, go.rotation, 1, false, -1)
      end
      if hitsfx_id ~= 0 then
        ECSoundMan.Instance():Play3DSoundByID(hitsfx_id, target:GetPos())
      end
    end
  end
end
def.override("string", "boolean").OnCmd_ObjectLeaveScene = function(self, id, outofsight)
  self:SubObjectLeave(id)
end
def.override("boolean").Release = function(self, bReleaseScene)
  self.SubObjMap = nil
end
def.method("string", "=>", "string").GetSubObjOwner = function(self, subobj_id)
  if self.SubObjMap == nil then
    return ZeroUInt64
  end
  if self.SubObjMap[subobj_id] == nil then
    return ZeroUInt64
  end
  return self.SubObjMap[subobj_id].Owner
end
ECSubObjectMan.Commit()
return ECSubObjectMan
