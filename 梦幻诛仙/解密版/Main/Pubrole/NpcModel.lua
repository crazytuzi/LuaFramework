local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPlayer = require("Model.ECPlayer")
local NpcModel = Lplus.Extend(ECPlayer, "NpcModel")
local NPC_STATE = require("consts.mzm.gsp.npc.confbean.NPCState")
local FlyMount = require("Main.Fight.FlyMount")
local def = NpcModel.define
def.field("number").m_cfgId = 0
def.field("number").stance = NPC_STATE.NORMAL
def.field("table").autoTalks = nil
def.field("number").talkCd = 10
def.field("table").initModelInfo = nil
def.field("number").modelScale = 1
def.field("table").flyMount = nil
def.field("number").displayMapId = 0
def.final("number", "number", "string", "userdata", "number", "=>", NpcModel).new = function(npcId, modelId, name, nameColor, roleType)
  local obj = NpcModel()
  obj.m_roleType = roleType
  obj.defaultLayer = ClientDef_Layer.NPC
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj.clickPriority = 2
  obj:Init(modelId)
  if npcId > 0 then
    obj.roleId = Int64.new(npcId)
  end
  obj:SetName(name, nameColor)
  obj.talkCd = 10 + math.random(30)
  return obj
end
def.override().OnLoadGameObject = function(self)
  local model = self.m_model
  if model == nil then
    warn("load game object: npc model is nil for id: ", self.mModelId, self.m_Name)
    return
  end
  ECPlayer.OnLoadGameObject(self)
  self:SetStance()
  self:SetModelScaleValue(self.modelScale)
  if _G.PlayerIsInFight() then
    self:SetVisible(false)
  end
end
def.override().Destroy = function(self)
  if self:IsInLoading() then
    self:RemoveOnLoadCallback("NPCLoadFlyMount")
  end
  if self.flyMount then
    self.flyMount:Destroy()
    self.flyMount = nil
  end
  if self.m_model then
    local flyTw = self.m_model:GetComponent("FlyFightTweener")
    if flyTw then
      Object.Destroy(flyTw)
    end
    self.m_model.localScale = EC.Vector3.one
  end
  ECPlayer.Destroy(self)
end
def.method("=>", "number").GetId = function(self)
  if self.roleId then
    return self.roleId:ToNumber()
  end
  return -1
end
def.override().PlayIdle = function(self)
  if self.stance == NPC_STATE.NORMAL then
    ECPlayer.PlayIdle(self)
  end
end
def.method("number").SetStanceValue = function(self, stance)
  self.stance = stance
  self:SetStance()
end
def.override().SetStance = function(self)
  if self.m_model == nil then
    return
  end
  if self.stance == NPC_STATE.DEAD then
    self:Play(ActionName.Death3)
  elseif self.stance == NPC_STATE.NORMAL then
    self:Play(ActionName.Stand)
  elseif self.stance == NPC_STATE.MAGIC then
    self:Play(ActionName.Magic_State)
  end
end
def.method("table").SetAutoTalk = function(self, talks)
  if talks == nil or #talks == 0 then
    return
  end
  self.autoTalks = {}
  for i = 1, #talks do
    self.autoTalks[i] = talks[i]
  end
end
def.override("number").Update = function(self, ticks)
  if self.mount then
    self.mount:Update(ticks)
  else
    ECPlayer.Update(self, ticks)
  end
  self:UpdateTalk(ticks)
end
def.method("number").UpdateTalk = function(self, tick)
  if self.talkCd <= 0 then
    return
  end
  self.talkCd = self.talkCd - tick
  if self.talkCd <= 0 then
    if self.autoTalks == nil or #self.autoTalks == 0 then
      return
    end
    local idx = math.random(#self.autoTalks)
    local talkContent = self.autoTalks[idx]
    if self.m_visible and not self:IsInState(RoleState.BATTLE) and talkContent and talkContent ~= "" then
      local len = string.len(talkContent) - 30
      if len < 0 then
        len = 0
      end
      self:Talk(self.autoTalks[idx], 5 + len / 20)
    end
    self.talkCd = 10 + math.random(30)
  end
end
def.method("=>", "number").GetChangedModelId = function(self)
  if self.initModelInfo then
    return self.initModelInfo.modelid
  end
  return self.mModelId
end
def.method("number").SetModelScaleValue = function(self, s)
  self.modelScale = s
  if self.m_model and not self.m_model.isnil then
    self.m_model.localScale = self.m_model.localScale * s
  end
end
local FlyScaleVector = EC.Vector3.new(1.25, 1.25, 1.25)
def.method().SetFlyMode = function(self)
  self.defaultLayer = ClientDef_Layer.FlyNpc
  self.flyMount = FlyMount.new()
  self.flyMount.layer = self.defaultLayer
  local function loadFlyMount()
    if self.m_model == nil or self.m_model.isnil then
      return
    end
    self.m_model:SetLayer(self.defaultLayer)
    self.flyMount:SetParent(self.m_model)
    local tw = self.m_model:AddComponent("FlyFightTweener")
    tw:Init(math.random() * 2)
    self:LoadFlyMount()
    local modelPosition = self.m_model.transform.localPosition
    local modelToPositin = EC.Vector3.new(modelPosition.x, modelPosition.y + 3, modelPosition.z)
    self.m_model.transform.localPosition = modelToPositin
    self.m_model.transform.localScale = FlyScaleVector
    self.flyMount:ShowShadow(true)
  end
  if self.m_model then
    loadFlyMount()
  else
    self:AddOnLoadCallback("NPCLoadFlyMount", loadFlyMount)
  end
end
def.method().LoadFlyMount = function(self)
  local FightUtils = require("Main.Fight.FightUtils")
  local respath
  if self.feijianId > 0 then
    respath = FightUtils.GetFlyMountModelPath(self.feijianId)
  end
  if respath == nil then
    respath = FightUtils.GetFlyMountModelPath(constant.NpcConsts.DEFAULT_FEIJIAN_CFG_ID)
  end
  if respath then
    self.flyMount:Load(respath)
    self.nameOffset = -1
    require("GUI.ECPate").ResetPosition(self.m_uiNameHandle, self.nameOffset)
  end
end
def.method("=>", "number").GetDisplayMapId = function(self)
  return self.displayMapId
end
return NpcModel.Commit()
