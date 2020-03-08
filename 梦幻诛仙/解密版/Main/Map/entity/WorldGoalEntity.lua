local Lplus = require("Lplus")
local WorldGoalMgr = require("Main.activity.WorldGoal.WorldGoalMgr")
local EntityBase = require("Main.Map.entity.EntityBase")
local WorldGoalEntity = Lplus.Extend(EntityBase, "WorldGoalEntity")
local def = WorldGoalEntity.define
def.field("number").m_CurScore = 0
def.field("number").m_ReachTime = 0
def.field("table").m_EntityModel = nil
def.field("table").m_Name2Part = nil
local SHADOW_PART_NAME = "characterShadow"
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:UpdateWorldGoalEntity()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    WorldGoalMgr.Instance():PlayWorldGoalFx(self.cfgid, self.m_CurScore, self.m_ReachTime)
  end)
end
def.override().OnLeaveView = function(self)
  WorldGoalMgr.Instance():RemoveWorldGoalFx(self.cfgid)
  if self.m_EntityModel and not self.m_EntityModel:IsDestroyed() then
    self.m_EntityModel:Destroy()
  end
  self.m_EntityModel = nil
  self.m_Name2Part = nil
end
def.override("table").UnmarshalExtraInfo = function(self, extraInfo)
  local EntityExtraInfoType = EntityBase.MapEntityExtraInfoType
  self.m_CurScore = extraInfo.int_extra_infos[EntityExtraInfoType.MGT_WORLD_GOAL_INFO_POINT] or 0
  self.m_ReachTime = extraInfo.int_extra_infos[EntityExtraInfoType.MGT_WORLD_GOAL_INFO_TIMESTAMP] or 0
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgId, location, extraInfo)
  self.cfgid = cfgId
  self.loc = location
  self:UnmarshalExtraInfo(extraInfo)
  self:UpdateWorldGoalEntity()
  WorldGoalMgr.Instance():PlayWorldGoalFx(self.cfgid, self.m_CurScore, self.m_ReachTime)
end
def.override("table", "table").OnExtraInfoChange = function(self, extraInfo, removeExtraKeys)
  self:UnmarshalExtraInfo(extraInfo)
  self:UpdateWorldGoalEntity()
end
def.method().UpdateWorldGoalEntity = function(self)
  local cfgInfo = require("Main.activity.WorldGoal.WorldGoalUtils").GetActivityInfoByCfgId(self.cfgid)
  if nil == cfgInfo then
    warn("~~~~ error world goal cfgid ,  cfgid is : ", self.cfgid)
    return
  end
  if cfgInfo.entityNpcId ~= 0 then
    if self.m_EntityModel and self.m_EntityModel.m_cfgId ~= cfgInfo.entityNpcId then
      self.m_EntityModel:Destroy()
      self.m_EntityModel = nil
    end
    if nil == self.m_EntityModel then
      do
        local npcData = {
          instanceid = self.instanceid,
          x = self.loc.x,
          y = self.loc.y,
          dir = 180,
          npcId = cfgInfo.entityNpcId,
          mapId = cfgInfo.mapId,
          extraInfo = {
            entityInstanceId = self.instanceid
          }
        }
        local npc = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):CreateUserNpc(npcData)
        self.m_EntityModel = npc
        self.m_EntityModel.extraInfo.npc = npc
        local function loadCallBack()
          if npc.m_model and not npc.m_model.isnil then
            self:UpdateModelName2Part(npc.m_model)
            self:UpdateEntityPart(npc.m_model)
          end
        end
        if npc:IsInLoading() then
          npc:AddOnLoadCallback("update_entity_part", loadCallBack)
        else
          loadCallBack()
        end
      end
    else
      self:UpdateEntityPart(self.m_EntityModel.m_model)
    end
  else
    self:UpdateCustomEntity()
  end
end
def.method("userdata").UpdateModelName2Part = function(self, model)
  if model and not model.isnil then
    local childCount = model:get_childCount()
    self.m_Name2Part = {}
    for i = 0, childCount - 1 do
      local child = model:GetChild(i)
      child:SetActive(false)
      self.m_Name2Part[child.name] = child
    end
  end
end
def.method("userdata").UpdateEntityPart = function(self, model)
  if model and not model.isnil then
    do
      local partInfo = require("Main.activity.WorldGoal.WorldGoalUtils").GetEntityModelPartInfo(self.cfgid)
      if partInfo and self.m_Name2Part then
        local function isNeedShow(partName)
          if SHADOW_PART_NAME == partName then
            return true
          end
          for k, v in pairs(partInfo) do
            if v == partName then
              return true
            end
          end
          return false
        end
        for k, v in pairs(self.m_Name2Part) do
          if isNeedShow(k) then
            v:SetActive(true)
          else
            v:SetActive(false)
          end
        end
      end
    end
  end
end
def.method("=>", "table").GetWorldGoalEntity = function(self)
  return self.m_EntityModel
end
def.method().UpdateCustomEntity = function(self)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_WorldGoal_Entity_Change, {
    self.cfgid,
    self.m_CurScore
  })
end
WorldGoalEntity.Commit()
return WorldGoalEntity
