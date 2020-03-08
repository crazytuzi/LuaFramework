local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ItemModel = Lplus.Extend(ECModel, "ItemModel")
local ECFxMan = require("Fx.ECFxMan")
local def = ItemModel.define
def.field("table").m_cfgInfo = nil
def.field("number").m_instanceId = -1
def.final("number", "number", "string", "userdata", "=>", ItemModel).new = function(id, modelId, name, nameColor)
  local obj = ItemModel()
  obj.m_instanceId = id
  obj.defaultLayer = ClientDef_Layer.NPC
  obj.m_IsTouchable = true
  obj.m_create_node2d = true
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj:Init(id)
  obj:SetName(name, nameColor)
  obj.m_bUncache = true
  return obj
end
def.override().OnLoadGameObject = function(self)
  ECModel.OnLoadGameObject(self)
  if self.m_model == nil then
    return
  end
  if _G.PlayerIsInFight() then
    self:SetVisible(false)
  end
  GameUtil.AddGlobalTimer(0, true, function()
    if _G.PlayerIsInFight() then
      self:SetVisible(false)
    end
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
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_ITEM, {
    self.m_instanceId
  })
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
def.method("=>", "number").GetCfgId = function(self)
  if self.m_cfgInfo == nil then
    return 0
  end
  return self.m_cfgInfo.id
end
def.method("=>", "number").GetInstanceId = function(self)
  return self.m_instanceId
end
return ItemModel.Commit()
