local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local ChildEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = ChildEntity.define
local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local NpcModel = require("Main.Pubrole.NpcModel")
local ChildrenInteractivePanel = require("Main.Children.ui.ChildrenInteractivePanel")
local Vector = require("Types.Vector")
local ECGame = require("Main.ECGame")
local Child = require("Main.Children.Child")
local ChildrenInterface = require("Main.Children.ChildrenInterface")
def.const("number").DEFAULT_NAME_COLOR_ID = 701300008
def.const("table").State = {}
def.field("table").ecmodel = nil
def.field("string").name = ""
def.field("number").nameColorId = 0
def.field("number").state = 0
def.field("number").gender = 0
def.field("number").period = 0
def.field("number").fashionId = 0
def.field("number").modelCfgId = 0
def.field("number").weaponId = 0
def.field("number").weaponLightLevel = 0
def.field(ChildrenInteractivePanel).interactivePanel = nil
def.override().OnCreate = function(self)
  self.nameColorId = ChildEntity.DEFAULT_NAME_COLOR_ID
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  local name = extra_info.string_extra_infos[ExtraInfoType.MET_CHILDREN_NAME]
  self.name = name and _G.GetStringFromOcts(name) or self.name
  self.gender = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_GENDER] or self.gender
  self.period = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_PERIOD] or self.period
  self.fashionId = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_FASHION] or self.fashionId
  self.modelCfgId = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_MODEL_CFG_ID] or self.modelCfgId
  self.weaponId = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_WEAPON_ID] or self.weaponId
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:LoadModel()
end
def.override().OnLeaveView = function(self)
  if self.ecmodel and not self.ecmodel:IsDestroyed() then
    self.ecmodel:Destroy()
  end
  self.ecmodel = nil
  if self.interactivePanel then
    self.interactivePanel:DestroyPanel()
  end
  self.interactivePanel = nil
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  if self.cfgid ~= cfgid then
    self.cfgid = cfgid
    self:LoadModel()
  end
  if self.loc.x ~= loc.x or self.loc.y ~= loc.y then
    self.loc = loc
    self:MoveTo(loc.x, loc.y, 0, nil)
  end
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  local name = extra_info.string_extra_infos[ExtraInfoType.MET_CHILDREN_NAME]
  if name then
    name = _G.GetStringFromOcts(name) or ""
    self:Rename(name)
  end
  local period = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_PERIOD]
  local fashionId = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_FASHION]
  local modelCfgId = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_MODEL_CFG_ID]
  local weaponId = extra_info.int_extra_infos[ExtraInfoType.MET_CHILDREN_WEAPON_ID]
  local remove_fashion = remove_extra_info_keys[ExtraInfoType.MET_CHILDREN_FASHION]
  local remove_weapon = remove_extra_info_keys[ExtraInfoType.MET_CHILDREN_WEAPON_ID]
  if period then
    self.period = period
  end
  if remove_fashion then
    self:SetFashion(0)
  end
  if fashionId then
    self:SetFashion(fashionId)
  end
  if remove_weapon then
    self:SetWeapon(0)
  end
  if weaponId then
    self:SetWeapon(weaponId)
  end
  if modelCfgId then
    self.modelCfgId = modelCfgId
    self:UpdateChildInfo()
  end
end
def.override("number").Update = function(self, dt)
  self:UpdateInteractivePanelPos()
end
def.method().ShowInteractiveUI = function(self)
  if self.interactivePanel == nil then
    self.interactivePanel = ChildrenInteractivePanel.new(self.instanceid, self)
  end
  self.interactivePanel:ShowPanel()
  local pos = self:GetInteractivePanelPos()
  self.interactivePanel:SetPos(pos)
end
def.method().HideInteractiveUI = function(self)
  self.interactivePanel:DestroyPanel()
end
def.method().UpdateInteractivePanelPos = function(self)
  if self.interactivePanel == nil then
    return
  end
  if not self.interactivePanel:IsShow() then
    return
  end
  local pos = self:GetInteractivePanelPos()
  self.interactivePanel:SetPos(pos)
end
def.method("=>", "table").GetInteractivePanelPos = function(self)
  local pos = Vector.Vector2.zero
  if self.ecmodel == nil then
    return pos
  end
  local mapPos = self.ecmodel:GetPos()
  if mapPos == nil then
    return pos
  end
  local localPos = Vector.Vector3.new(mapPos.x, world_height - mapPos.y, 0)
  local cam2dpos = ECGame.Instance():Get2dCameraPos()
  local diff = localPos - cam2dpos
  local UIRoot = GUIRoot.GetUIRootObj()
  local boxHeight = self.ecmodel:GetBoxHeight()
  local offset = 60
  diff.y = diff.y + boxHeight / UIRoot.localScale.y / CommonCamera.game3DCamera.orthographicSize + offset
  pos = diff
  return pos
end
def.method().LoadModel = function(self)
  if self.ecmodel and not self.ecmodel:IsDestroyed() then
    self.ecmodel:Destroy()
  end
  if not self.loc then
    local pos = {x = 0, y = 0}
  end
  local dir = 180
  local child
  if 0 < self.weaponId then
    child = Child.CreateWithCostumeAndWeapon(self.modelCfgId, self.fashionId, self.weaponId)
  else
    child = Child.CreateWithCostume(self.modelCfgId, self.fashionId)
  end
  child:LoadModel(self.name, GetColorData(self.nameColorId), pos.x, pos.y, dir, nil, nil)
  self.ecmodel = child:GetModel()
  self.ecmodel:SetLayer(ClientDef_Layer.NPC)
  self.ecmodel.roleId = self.instanceid
  self.ecmodel.extraInfo = child.modelInfo
  self.ecmodel.extraInfo.entity = self
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):AddToUserNpcGroup(self.ecmodel)
end
def.method().UpdateChildInfo = function(self)
  self:LoadModel()
end
def.method("=>", "table").GetECModel = function(self)
  return self.ecmodel
end
def.method("number", "number", "number", "function").MoveTo = function(self, x, y, distance, cb)
  if self.ecmodel == nil or self.ecmodel:IsDestroyed() then
    return
  end
  local findpath = self:FindPath(x, y, distance)
  if findpath == nil or #findpath == 0 then
    return
  end
  self.ecmodel:RunPath(findpath, self.ecmodel.runSpeed, cb)
end
def.method("number", "number", "number", "=>", "table").FindPath = function(self, x, y, distance)
  if self.ecmodel == nil or self.ecmodel:IsDestroyed() then
    return nil
  end
  return gmodule.moduleMgr:GetModule(ModuleId.MAP):FindPath(self.ecmodel.m_node2d.localPosition.x, self.ecmodel.m_node2d.localPosition.y, x, y, distance)
end
def.method("string").Rename = function(self, name)
  self.name = name
  if self.ecmodel and not self.ecmodel:IsDestroyed() then
    self.ecmodel:SetName(self.name, nil)
  end
end
def.method("number").SetFashion = function(self, fashionId)
  self.fashionId = fashionId
  if self.ecmodel == nil then
    self:LoadModel()
  else
    _G.SetChildCostume(self.ecmodel, self.modelCfgId, self.fashionId)
  end
end
def.method("number").SetWeapon = function(self, weaponId)
  self.weaponId = weaponId
  if self.ecmodel == nil then
    self:LoadModel()
  else
    _G.SetChildWeapon(self.ecmodel, self.weaponId, self.weaponLightLevel)
  end
end
def.method().PlayRandomAnimation = function(self)
  local phase = self.period
  local animations = ChildrenInterface.GetChildAnimationByPhase(phase) or {}
  if #animations == 0 then
    warn("PlayRandomAnimation:No animations!")
    return
  end
  local animation = animations[math.random(#animations)]
  self:PlayAnimation(animation)
end
def.method("string").PlayAnimation = function(self, animation)
  local ecmodel = self.ecmodel
  if ecmodel == nil or ecmodel:IsDestroyed() then
    return
  end
  if ecmodel.movePath ~= nil then
    print("can't play animation when move")
    return
  end
  ecmodel:SetIdleTime()
  ecmodel:PlayAnimationThenStand(animation)
end
def.override("table").OnSyncMove = function(self, locs)
  if self.ecmodel == nil or self.ecmodel:IsDestroyed() then
    return
  end
  self.ecmodel:RunPath(locs, self.ecmodel.runSpeed, cb)
end
def.override("=>", "table").GetPos = function(self)
  if self.ecmodel == nil or self.ecmodel:IsDestroyed() then
    return self.loc
  end
  return self.ecmodel:GetPos()
end
return ChildEntity.Commit()
