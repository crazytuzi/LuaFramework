local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local EntityModel = Lplus.Extend(ECModel, "EntityModel")
local ECFxMan = require("Fx.ECFxMan")
local def = EntityModel.define
def.field("number").m_type = 0
def.field("userdata").m_instanceId = nil
def.field("table").m_extraInfo = nil
def.final("number", "userdata", "number", "=>", EntityModel).new = function(type, id, modelId)
  local obj = EntityModel()
  obj.m_type = type
  obj.m_instanceId = id
  obj.defaultLayer = ClientDef_Layer.NPC
  obj.m_IsTouchable = true
  obj.m_create_node2d = true
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj:Init(id)
  obj.m_bUncache = true
  return obj
end
def.override().OnLoadGameObject = function(self)
  ECModel.OnLoadGameObject(self)
  if self.m_model == nil then
    return
  end
  GameUtil.AddGlobalTimer(0, true, function()
    local ECPate = require("GUI.ECPate")
    local pate = ECPate.new()
    pate:CreateNameBoard(self)
  end)
end
def.override("number").Update = function(self, ticks)
  ECModel.Update(self, ticks)
  local x, y, z = self.m_node2d:GetPosXYZ()
  if MapScene.IsTransparent(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, x, y) then
    self:SetAlpha(0.55)
  elseif self.m_IsAlpha == true then
    self:CloseAlpha()
  end
end
def.override().OnClick = function(self)
  ECModel.OnClick(self)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_ENTITY, {
    self.m_type,
    self.m_instanceId,
    self.m_extraInfo
  })
  warn("CLICK_ENTITY!!!")
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroMgr.selectEffect then
    ECFxMan.Instance():Stop(heroMgr.selectEffect)
  end
  local effres = GetEffectRes(702020020)
  if effres then
    heroMgr.selectEffect = ECFxMan.Instance():PlayAsChild(effres.path, self.m_model, EC.Vector3.new(0, 0, 0), Quaternion.identity, -1, false, ClientDef_Layer.Player)
    heroMgr.selectEffectTime = 3
  end
end
def.method("=>", "number").GetInstanceId = function(self)
  return self.m_instanceId
end
def.method("=>", "table").GetExtraInfo = function(self)
  return self.m_extraInfo
end
return EntityModel.Commit()
