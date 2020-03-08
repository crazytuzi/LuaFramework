local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUIRoleHead = Lplus.Extend(ComponentBase, "MainUIRoleHead")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local GUIUtils = require("GUI.GUIUtils")
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local def = MainUIRoleHead.define
def.field("table").uiObjs = nil
local instance
def.static("=>", MainUIRoleHead).Instance = function()
  if instance == nil then
    instance = MainUIRoleHead()
    instance:Init()
  end
  return instance
end
def.override("=>", "boolean").CanShowInFight = function(self)
  return true
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, MainUIRoleHead.OnInitHeroProp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, MainUIRoleHead.OnSyncHeroProp)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, MainUIRoleHead.OnSyncFightProp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_NOTIFY_UPDATE, MainUIRoleHead.OnNotifyUpdate)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, MainUIRoleHead.OnAvatarChange)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, MainUIRoleHead.OnAvatarFrameChange)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_CArd_Item_Red_Point_Change, MainUIRoleHead.OnTurnedCardNotifyUpdate)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, MainUIRoleHead.OnInitHeroProp)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, MainUIRoleHead.OnSyncHeroProp)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, MainUIRoleHead.OnSyncFightProp)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_NOTIFY_UPDATE, MainUIRoleHead.OnNotifyUpdate)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, MainUIRoleHead.OnAvatarChange)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, MainUIRoleHead.OnAvatarFrameChange)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_CArd_Item_Red_Point_Change, MainUIRoleHead.OnTurnedCardNotifyUpdate)
  self:Clear()
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_IconRole = self.m_node:FindDirect("Img_IconRole")
  self.uiObjs.Label_LvRole = self.m_node:FindDirect("Label_LvRole")
  self.uiObjs.Slider_BloodRole = self.m_node:FindDirect("Slider_BloodRole")
  self.uiObjs.uiLabel_BloodRole = self.uiObjs.Slider_BloodRole:FindDirect("Label_BloodRole"):GetComponent("UILabel")
  self.uiObjs.Slider_BlueRole = self.m_node:FindDirect("Slider_BlueRole")
  self.uiObjs.uiLabel_BlueRole = self.uiObjs.Slider_BlueRole:FindDirect("Label_BlueRole"):GetComponent("UILabel")
  self.uiObjs.Slider_AngerRole = self.m_node:FindDirect("Slider_AngerRole")
  self.uiObjs.uiLabel_AngerRole = self.uiObjs.Slider_AngerRole:FindDirect("Label_AngerRole"):GetComponent("UILabel")
  self.uiObjs.Img_Red = self.m_node:FindDirect("Img_Red")
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
def.override().OnEnterFight = function(self)
end
def.override().OnLeaveFight = function(self)
  local isAutoProgress = true
  self:UpdateVolatileProp(isAutoProgress)
end
def.method().UpdateUI = function(self)
  self:SetPermanentProp()
  local isAutoProgress = false
  self:UpdateVolatileProp(isAutoProgress)
  self:UpdateBadge()
end
def.method().SetPermanentProp = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  self:UpdateRoleHeadImage()
end
def.method("boolean").UpdateVolatileProp = function(self, isAutoProgress)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  self:SetRoleLevel(heroProp.level)
  self:SetRoleHPBar(heroProp.hp, heroProp.secondProp.maxHp, isAutoProgress)
  self:SetRoleMPBar(heroProp.mp, heroProp.secondProp.maxMp, isAutoProgress)
  self:SetRoleAngerBar(heroProp.anger, heroProp:GetMaxAnger(), isAutoProgress)
end
def.static("table", "table").OnInitHeroProp = function(param1, param2)
  if instance.m_panel == nil then
    return
  end
  instance:UpdateUI()
end
def.static("table", "table").OnSyncHeroProp = function(param1, param2)
  if instance.m_panel == nil then
    return
  end
  if instance:IsInFight() then
    return
  end
  local isAutoProgress = true
  instance:UpdateVolatileProp(isAutoProgress)
end
def.static("table", "table").OnSyncFightProp = function(params)
  local self = instance
  if params.type == GameUnitType.ROLE then
    self:SetFightProp(params)
  end
end
def.method("table").SetFightProp = function(self, data)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local maxHp = data.hpmax or heroProp.secondProp.maxHp
  local maxMp = data.mpmax or heroProp.secondProp.maxMp
  self:SetRoleHPBar(data.hp, maxHp, true)
  self:SetRoleMPBar(data.mp, maxMp, true)
  self:SetRoleAngerBar(data.rage, heroProp:GetMaxAnger(), true)
end
def.method().UpdateRoleHeadImage = function(self)
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarId = AvatarInterface.Instance():getCurAvatarId()
  local avatarFrameId = AvatarInterface.Instance():getCurAvatarFrameId()
  _G.SetAvatarIcon(self.uiObjs.Img_IconRole, avatarId, avatarFrameId)
end
def.method("number").SetRoleLevel = function(self, level)
  local label_level = self.uiObjs.Label_LvRole:GetComponent("UILabel")
  label_level:set_text(level)
end
def.method("number", "number", "boolean").SetRoleHPBar = function(self, hp, maxHp, isAutoProgress)
  local slider_hp = self.uiObjs.Slider_BloodRole:GetComponent("UISlider")
  self:SetSliderBar(slider_hp, hp / maxHp, isAutoProgress)
  if self:IsInFight() then
    self.uiObjs.uiLabel_BloodRole:set_text(string.format("%d/%d", hp, maxHp))
  else
    self.uiObjs.uiLabel_BloodRole:set_text("")
  end
end
def.method("number", "number", "boolean").SetRoleMPBar = function(self, mp, maxMp, isAutoProgress)
  local slider_mp = self.uiObjs.Slider_BlueRole:GetComponent("UISlider")
  self:SetSliderBar(slider_mp, mp / maxMp, isAutoProgress)
  if self:IsInFight() then
    self.uiObjs.uiLabel_BlueRole:set_text(string.format("%d/%d", mp, maxMp))
  else
    self.uiObjs.uiLabel_BlueRole:set_text("")
  end
end
def.method("number", "number", "boolean").SetRoleAngerBar = function(self, anger, maxAnger, isAutoProgress)
  local slider_anger = self.uiObjs.Slider_AngerRole:GetComponent("UISlider")
  self:SetSliderBar(slider_anger, anger / maxAnger, isAutoProgress)
  if self:IsInFight() then
    self.uiObjs.uiLabel_AngerRole:set_text(string.format("%d/%d", anger, maxAnger))
  else
    self.uiObjs.uiLabel_AngerRole:set_text("")
  end
end
def.method().UpdateBadge = function(self)
  local hasNotify = HeroPropMgr.Instance():HasNotify()
  GUIUtils.SetActive(self.uiObjs.Img_Red, hasNotify)
end
def.static("table", "table").OnNotifyUpdate = function(params)
  instance:UpdateBadge()
end
def.static("table", "table").OnAvatarChange = function(p1, p2)
  if instance then
    instance:UpdateRoleHeadImage()
  end
end
def.static("table", "table").OnAvatarFrameChange = function(p1, p2)
  if instance then
    instance:UpdateRoleHeadImage()
  end
end
def.static("table", "table").OnTurnedCardNotifyUpdate = function(p1, p2)
  if instance then
    instance:UpdateBadge()
  end
end
MainUIRoleHead.Commit()
return MainUIRoleHead
