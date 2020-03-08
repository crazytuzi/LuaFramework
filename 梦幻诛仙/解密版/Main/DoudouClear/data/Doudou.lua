local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Doudou = Lplus.Class(CUR_CLASS_NAME)
local def = Doudou.define
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local Instance_Id = 1
local DOUDOU_MODEL = 700304001
local DOUDOU_COLOR = {}
def.field("number").idx = 0
def.field("number").last_idx = 0
def.field("number").instanceId = 0
def.field("number").modelId = 0
def.field("number").color = 0
def.field(ECPlayer).model = nil
def.field("table").path = nil
def.field("number").cfgId = 0
def.field("boolean").isClearable = true
def.field("number").state = 0
def.static("number", "number", "string", "=>", Doudou).New = function(modelId, color, name)
  local obj = Doudou()
  obj.modelId = modelId
  obj.instanceId = Instance_Id
  Instance_Id = Instance_Id + 1
  obj.color = color
  obj.model = ECPlayer.new(Int64.new(obj.instanceId), modelId, tostring(obj.instanceId), GetColorData(701300008), RoleType.DOUDOU)
  return obj
end
def.static("number", "number", "number", "string", "=>", Doudou).Create = function(instanceId, modelId, color, name)
  local obj = Doudou()
  obj.modelId = modelId
  obj.instanceId = instanceId
  obj.color = color
  obj.model = ECPlayer.new(Int64.new(obj.instanceId), modelId, tostring(obj.instanceId), GetColorData(701300008), RoleType.DOUDOU)
  return obj
end
def.static("number").ResetInstanceId = function(id)
  Instance_Id = id
end
def.method("table").Load = function(self, pos)
  if self.model and self.model:IsObjLoaded() then
    self.model:Destroy()
  end
  local modelpath = GetModelPath(self.modelId)
  local model_color = DOUDOU_COLOR[self.color]
  if model_color then
    self.model:SetModelColor(model_color)
  else
    self.model.colorId = self.color
    self.model:SetColoration(nil)
    DOUDOU_COLOR[self.color] = self.model.m_color
  end
  self.model:LoadModel2(modelpath, pos.x, pos.y, 0, false)
end
def.method().Destroy = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method("=>", "boolean").IsDestroy = function(self)
  return self.model == nil
end
def.method("table", "function").RunPath = function(self, path, cb)
  if self.model == nil then
    return
  end
  self.model:RunPath(path, self.model.runSpeed, function()
    if cb then
      cb(self)
    end
  end)
end
def.method("=>", "boolean").IsDoudou = function(self)
  return self.modelId == DOUDOU_MODEL
end
def.method().TurnRound = function(self)
  if self.model == nil or self.model.m_model == nil then
    return
  end
  self.model:SetForward(self.model.m_model.forward * -1)
end
def.method("string").PlayEffect = function(self, respath)
  if self.model == nil then
    return
  end
  self.model:AddEffect(respath, BODY_PART.FEET)
end
def.method("string").SetMark = function(self, content)
  if self.model == nil then
    return
  end
  if self.model.m_topIcon then
    local label = self.model.m_topIcon:FindDirect("Pate/Label_Info")
    if label == nil then
      return
    end
    label:GetComponent("UILabel").text = content
  end
end
def.method("number").SetState = function(self, state)
  self.state = state
  local MonsterState = require("netio.protocol.mzm.gsp.hula.MonsterState")
  if self.state == MonsterState.STATE_ALIVE then
    if self.model then
      self.model:RemoveState(RoleState.BATTLE)
      self.model:SetBattleIcon("")
    end
  elseif self.state == MonsterState.STATE_DIE then
    self:Destroy()
  elseif self.state == MonsterState.STATE_FIGHTING and self.model then
    self.model:SetState(RoleState.BATTLE)
    self.model:SetBattleIcon(RESPATH.MODEL_BATTLE_ICON)
  end
end
Doudou.Commit()
return Doudou
