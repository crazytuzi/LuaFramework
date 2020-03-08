local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ValentineFlowerModel = Lplus.Extend(ECModel, "ValentineFlowerModel")
local ECFxMan = require("Fx.ECFxMan")
local def = ValentineFlowerModel.define
def.final("=>", ValentineFlowerModel).new = function()
  local obj = ValentineFlowerModel()
  obj.defaultLayer = ClientDef_Layer.NPC
  obj.m_create_node2d = true
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj.m_bUncache = true
  return obj
end
def.method("number", "number", "number").LoadFlowerModel = function(self, modelId, posx, posy)
  self:Init(modelId)
  self:LoadCurrentModel(posx, posy, -180)
end
def.method().DestroyFlower = function(self)
  if self:IsDestroyed() or self.m_model == nil then
    return
  end
  self:Destroy()
end
def.method("number", "number", "number", "=>", ValentineFlowerModel).ReplaceFlowerModel = function(self, modelId, posx, posy)
  if self.mModelId ~= modelId then
    local newFlower = ValentineFlowerModel.new()
    newFlower:LoadFlowerModel(modelId, posx, posy)
    self:DestroyFlower()
    return newFlower
  end
  return self
end
return ValentineFlowerModel.Commit()
