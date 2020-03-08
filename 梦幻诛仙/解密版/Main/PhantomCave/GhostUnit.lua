local Lplus = require("Lplus")
local GhostUnit = Lplus.Class("GhostUnit")
local def = GhostUnit.define
local ECModel = require("Model.ECModel")
local EC = require("Types.Vector3")
local ECFxMan = require("Fx.ECFxMan")
def.const("number").DEFAULT_DIR = 0
def.field(ECModel).model = nil
def.field("number").modelId = 0
def.field("number").colorId = 0
def.field("boolean").hasOranment = false
def.field("userdata").scene = nil
def.field("boolean").loadFinish = false
def.method("number", "number", "boolean", "userdata", "function").Create = function(self, modelId, colorId, hasOranment, scene, cb)
  self.modelId = modelId
  self.colorId = colorId
  self.hasOranment = hasOranment
  self.scene = scene
  local function OnLoadFinish()
    if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil then
      return
    end
    self.model.m_model:SetLayer(scene:get_layer())
    self.model.m_model.parent = scene
    self.model:SetScale(0.35)
    local colorCfg = GetModelColorCfg(self.colorId)
    self.model:SetColoration(colorCfg)
    self.model:SetOrnament(self.hasOranment)
    self:SetDir(GhostUnit.DEFAULT_DIR)
    self.model:SetActive(false)
    self.loadFinish = true
    if cb then
      cb()
    end
  end
  self.model = ECModel.new(self.modelId)
  local modelPath = GetModelPath(self.modelId)
  self.model:Load(modelPath, OnLoadFinish)
end
def.method("number", "number", "number").RunTo = function(self, x, y, duration)
  self.model:SetActive(true)
  local target = EC.Vector3.new(x, 0, y)
  if math.abs(x - self.model.m_model.localPosition.x) < 0.001 and 0.001 > math.abs(y - self.model.m_model.localPosition.z) then
    return
  end
  local dir = EC.Vector3.new(self.model.m_model.localPosition.x - x, 0, self.model.m_model.localPosition.z - y)
  self.model.m_model.transform.forward = dir
  TweenPosition.Begin(self.model.m_model, duration, target)
  self.model:Play("Run_c")
  GameUtil.AddGlobalTimer(duration, true, function()
    if self.model and self.model.m_model and not self.model.m_model.isnil then
      self:SetDir(GhostUnit.DEFAULT_DIR)
      self.model:Play("Stand_c")
    end
  end)
end
def.method("number", "number").Appear = function(self, x, y)
  self.model:SetActive(true)
  self:SetPos(x, y)
  self.model:Play("Stand_c")
end
def.method().Disappear = function(self)
  self.model:SetActive(false)
end
def.method().Destroy = function(self)
  self.model:Destroy()
end
def.method("number", "number").SetPos = function(self, x, y)
  if self.model and self.model.m_model and not self.model.m_model.isnil then
    self.model.m_model.localPosition = EC.Vector3.new(x, 0, y)
  end
end
def.method("number").SetDir = function(self, dir)
  if self.model and self.model.m_model and not self.model.m_model.isnil then
    local zero = EC.Vector3.new(-70, 0, 0)
    zero.y = dir
    self.model.m_model.localRotation = Quaternion.Euler(zero)
  end
end
GhostUnit.Commit()
return GhostUnit
