local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroPropPanelNodeBase = require("Main.Hero.ui.HeroPropPanelNodeBase")
local HeroPropNode = Lplus.Extend(HeroPropPanelNodeBase, "HeroPropNode")
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HeroSecondProp = Lplus.ForwardDeclare("HeroSecondProp")
local HeroExtraProp = Lplus.ForwardDeclare("HeroExtraProp")
local HeroUtility = require("Main.Hero.HeroUtility")
local ECUIModel = require("Model.ECUIModel")
local GUIUtils = require("GUI.GUIUtils")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local GameUnitType = require("consts.mzm.gsp.common.confbean.GameUnitType")
local TitleInterface = require("Main.title.TitleInterface")
local titleInterface = TitleInterface.Instance()
local FightMgr = require("Main.Fight.FightMgr")
local ECModel = require("Model.ECModel")
local EC = {}
EC.Vector3 = require("Types.Vector3").Vector3
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = HeroPropNode.define
def.const("table").PropNameCfgKeyList = {
  PropertyType.PHYATK,
  PropertyType.MAGATK,
  PropertyType.PHYDEF,
  PropertyType.MAGDEF,
  PropertyType.SPEED,
  PropertyType.PHY_CRIT_LEVEL,
  PropertyType.MAG_CRT_LEVEL,
  PropertyType.PHY_CRT_DEF_LEVEL,
  PropertyType.MAG_CRT_DEF_LEVEL,
  PropertyType.SEAL_HIT,
  PropertyType.SEAL_RESIST,
  PropertyType.MAX_HP,
  PropertyType.MAX_MP,
  PropertyType.VIGOR
}
def.field("table").model = nil
def.field("boolean").isDrag = false
def.field("table").curServerInfo = nil
def.field("userdata").charRoot = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", HeroPropNode).Instance = function()
  if instance == nil then
    instance = HeroPropNode()
  end
  return instance
end
def.override("string").onClick = function(self, id)
  if id == "Btn_SX_ChangerName01" then
    self:Rename()
  elseif id == "Btn_SX_Use" then
    self:OnUseEnergyButtonClick()
  elseif id == "Btn_Tips" then
    self:OnServerLevelTipClick()
  elseif id == "Btn_AddAttribute" then
    self:OnAssignPropButtonClicked()
  elseif id == "Btn_Promote" then
    self:OnPromoteButtonClicked()
  elseif id == "Btn_Share" then
    self:OnShareButtonClicked()
  elseif id == "Btn_ChangeHead" or id == "Img_BgHead01" then
    require("Main.Avatar.ui.AvatarPanel").Instance():ShowPanel()
  end
end
def.override("string", "boolean").onPress = function(self, id, state)
  if string.sub(id, 1, 16) == "Img_SX_Attribute" then
    local index = tonumber(string.sub(id, 17, -1))
    self:OnAttrTipPressed(index, state)
  elseif id == "Label_SX_Blood" then
    self:OnAttrTipPressed(12, state)
  elseif id == "Label_SX_Blue" then
    self:OnAttrTipPressed(13, state)
  elseif id == "Label_SX_Active" then
    self:OnAttrTipPressed(14, state)
  end
end
def.override().OnShow = function(self)
  self:InitUI()
  self:Fill()
  self:SetHeadInfo()
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, HeroPropNode.OnSyncFightProp)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, HeroPropNode.OnLeaveFight)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.STORAGE_EXP_UPDATE, HeroPropNode.OnStorageExpUpdate)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, HeroPropNode.OnAvatarChange)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, HeroPropNode.OnAvatarChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, HeroPropNode.OnFunctionOpenChange)
end
def.override().OnHide = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
  if self.charRoot then
    GameObject.Destroy(self.charRoot)
    self.charRoot = nil
  end
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, HeroPropNode.OnSyncFightProp)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, HeroPropNode.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.STORAGE_EXP_UPDATE, HeroPropNode.OnStorageExpUpdate)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, HeroPropNode.OnAvatarChange)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, HeroPropNode.OnAvatarChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, HeroPropNode.OnFunctionOpenChange)
end
def.override("table", "table").OnSyncHeroProp = function(self, params, context)
  if self.uiObjs == nil then
    return
  end
  if require("Main.Fight.FightMgr").Instance().isInFight then
    return
  end
  self:UpdateProps()
end
def.static("table", "table").OnSyncFightProp = function(params)
  local self = instance
  if params.type == GameUnitType.ROLE then
    self:SetFightProp(params)
  end
end
def.static("table", "table").OnLeaveFight = function(params)
  local self = instance
  local prop = Lplus.ForwardDeclare("HeroModule").Instance():GetHeroProp()
  self:SetHPBar(prop.hp, prop.secondProp.maxHp)
  self:SetMPBar(prop.mp, prop.secondProp.maxMp)
end
def.static("table", "table").OnStorageExpUpdate = function(params)
  local self = instance
  local exp = params[0]
  self:SetStoredExp(exp)
end
def.static("table", "table").OnAvatarChange = function(p1, p2)
  if instance and instance.m_node and not instance.m_node.isnil then
    instance:SetHeadInfo()
  end
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  if instance and instance.m_node and not instance.m_node.isnil and param.feature == ModuleFunSwitchInfo.TYPE_FORBID_ADD_STORAGE_EXP then
    instance:UpdateStoredExp()
  end
end
def.method().Fill = function(self)
  self:UpdateProps()
  self:UpdateModel()
end
def.method().UpdateProps = function(self)
  local prop = Lplus.ForwardDeclare("HeroModule").Instance():GetHeroProp()
  local displayId = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(prop.id)
  self:SetDiplayID(tostring(displayId))
  self:SetName(prop.name)
  self:SetLevel(prop.level)
  self:SetOccupation(prop.occupation)
  self:SetFightingCapacity(prop.fightValue)
  local rtProp = self:GetRealTimeProp(prop)
  self:SetHPBar(rtProp.hp, rtProp.maxHp)
  self:SetMPBar(rtProp.mp, rtProp.maxMp)
  local maxEnergy = prop:GetMaxEnergy()
  self:SetEnergyBar(prop.energy, maxEnergy)
  self:SetExpBar(prop.exp, prop.nextLevelExp)
  local isEnergyFull = maxEnergy <= prop.energy
  if isEnergyFull then
    GUIUtils.SetLightEffect(self.uiObjs.Btn_SX_Use, GUIUtils.Light.Square)
  else
    GUIUtils.SetLightEffect(self.uiObjs.Btn_SX_Use, GUIUtils.Light.None)
  end
  self:SetSecondProp(prop.secondProp)
  self:SetExtraProp(prop.propMap)
  self:UpdateStoredExp()
end
def.method().UpdateStoredExp = function(self)
  local storedExp = require("Main.Award.mgr.StorageExpMgr").Instance():GetStorageExp()
  self:SetStoredExp(storedExp)
end
def.override().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Btn_SX_Use = self.m_node:FindDirect("Img_SX_BgRight/Label_SX_Active/Btn_SX_Use")
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
      GUIUtils.SetActive(self.m_node:FindDirect("Btn_Share", false))
    end
  end
end
def.method("table", "=>", "table").GetRealTimeProp = function(self, prop)
  local rtProp = {}
  rtProp.hp = prop.hp
  rtProp.mp = prop.mp
  rtProp.maxHp = prop.secondProp.maxHp
  rtProp.maxMp = prop.secondProp.maxMp
  if _G.PlayerIsInFight() then
    local hpMpInfo = FightMgr.Instance():GetHpMpInfo()
    local roleInfo
    for k, v in pairs(hpMpInfo) do
      if v.type == GameUnitType.ROLE then
        rtProp.hp, rtProp.mp, rtProp.maxHp, rtProp.maxMp = v.hp, v.mp, v.hpmax or rtProp.maxHp, v.mpmax or rtProp.maxMp
        break
      end
    end
  end
  return rtProp
end
def.method().Rename = function(self)
  HeroUtility.Instance():Rename()
end
def.method().OnUseEnergyButtonClick = function(self)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.OPEN_ENERGY_PANEL, nil)
end
def.static("table", "table").OnRenameSuccess = function()
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:HidePanel()
end
def.method("string").SetName = function(self, name)
  local label_name = self.m_node:FindDirect("Img_SX_BgLeft/Label_SX_Name"):GetComponent("UILabel")
  label_name.text = name
end
def.method("number").SetLevel = function(self, level)
  local label_level = self.m_node:FindDirect("Img_SX_BgLeft/Label_SX_Lv"):GetComponent("UILabel")
  label_level.text = string.format(textRes.Hero[1], level)
end
def.method("number").SetOccupation = function(self, occupation)
  local sprite_occupation = self.m_node:FindDirect("Img_SX_BgLeft/Img_SX_School"):GetComponent("UISprite")
  sprite_occupation.spriteName = require("GUI.GUIUtils").GetOccupationSmallIcon(occupation)
end
def.method("string").SetDiplayID = function(self, ID)
  local label_id = self.m_node:FindDirect("Img_SX_BgLeft/Label_SX_IdNum"):GetComponent("UILabel")
  label_id.text = string.format(textRes.Hero[2], ID)
end
def.method("number").SetFightingCapacity = function(self, power)
  local label_power = self.m_node:FindDirect("Img_SX_BgLeft/Img_SX_BgPower/Label_SX_PowerNumber"):GetComponent("UILabel")
  label_power.text = power
end
def.method("number", "number").SetHPBar = function(self, cur, max)
  local hp = self.m_node:FindDirect("Img_SX_BgRight/Label_SX_Blood/Slider_SX_BgBlood")
  local slider_hp = hp:GetComponent("UISlider")
  if max == 0 then
    max = 1.0E-5
  end
  slider_hp:set_sliderValue(cur / max)
  local label_hp = hp:GetComponentInChildren("UILabel")
  label_hp.text = string.format("%d/%d", cur, max)
end
def.method("number", "number").SetMPBar = function(self, cur, max)
  local mp = self.m_node:FindDirect("Img_SX_BgRight/Label_SX_Blue/Slider_SX_BgBlue")
  local slider_mp = mp:GetComponent("UISlider")
  if max == 0 then
    max = 1.0E-5
  end
  slider_mp:set_sliderValue(cur / max)
  local label_mp = mp:GetComponentInChildren("UILabel")
  label_mp.text = string.format("%d/%d", cur, max)
end
def.method("number", "number").SetEnergyBar = function(self, cur, max)
  local energy = self.m_node:FindDirect("Img_SX_BgRight/Label_SX_Active/Slider_SX_BgActive")
  local slider_energy = energy:GetComponent("UISlider")
  if max == 0 then
    max = 1.0E-5
  end
  slider_energy:set_sliderValue(cur / max)
  local label_energy = energy:GetComponentInChildren("UILabel")
  label_energy.text = string.format("%d/%d", cur, max)
end
def.method("number", "number").SetExpBar = function(self, cur, max)
  local exp = self.m_node:FindDirect("Label_SX_EXP/Slider_SX_EXP")
  local slider_exp = exp:GetComponent("UISlider")
  if max == 0 then
    max = 1.0E-5
  end
  slider_exp:set_sliderValue(cur / max)
  local label_exp = exp:GetComponentInChildren("UILabel")
  label_exp.text = string.format("%d/%d", cur, max)
end
def.method(HeroSecondProp).SetSecondProp = function(self, secondProp)
  local propRoot = self.m_node:FindDirect("Img_SX_BgRight/Img_SX_BgAttribute/Group_BasicAttribute/Grid_SX_Attribute01")
  local label_phyAtk = propRoot:FindDirect("Img_SX_Attribute01/Label_SX_AttributeNum01"):GetComponent("UILabel")
  label_phyAtk.text = secondProp.phyAtk
  local label_phyDef = propRoot:FindDirect("Img_SX_Attribute03/Label_SX_AttributeNum03"):GetComponent("UILabel")
  label_phyDef.text = secondProp.phyDef
  local label_magAtk = propRoot:FindDirect("Img_SX_Attribute02/Label_SX_AttributeNum02"):GetComponent("UILabel")
  label_magAtk.text = secondProp.magAtk
  local label_magDef = propRoot:FindDirect("Img_SX_Attribute04/Label_SX_AttributeNum04"):GetComponent("UILabel")
  label_magDef.text = secondProp.magDef
  local label_speed = propRoot:FindDirect("Img_SX_Attribute05/Label_SX_AttributeNum05"):GetComponent("UILabel")
  label_speed.text = secondProp.speed
end
def.method("table").SetExtraProp = function(self, propMap)
  local propRoot = self.m_node:FindDirect("Img_SX_BgRight/Img_SX_BgAttribute/Group_HighAttribute/Grid_SX_Attribute01")
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local propTable = {
    propMap[PropertyType.PHY_CRIT_LEVEL],
    propMap[PropertyType.MAG_CRT_LEVEL],
    propMap[PropertyType.PHY_CRT_DEF_LEVEL],
    propMap[PropertyType.MAG_CRT_DEF_LEVEL],
    propMap[PropertyType.SEAL_HIT],
    propMap[PropertyType.SEAL_RESIST]
  }
  for i, v in ipairs(propTable) do
    local labelName = string.format("Img_SX_Attribute0%d/Label_SX_AttributeNum0%d", i, i)
    local label_prop = propRoot:FindDirect(labelName):GetComponent("UILabel")
    label_prop:set_text(v)
  end
end
def.method("userdata").SetStoredExp = function(self, exp)
  exp = exp or Int64.new(0)
  local Label_StoreExp = self.m_node:FindDirect("Img_SX_BgRight/Label_StoreExp")
  local Label_StoreExpNum = self.m_node:FindDirect("Img_SX_BgRight/Label_StoreExpNum")
  local bShow = Int64.gt(exp, 0) or not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_FORBID_ADD_STORAGE_EXP)
  GUIUtils.SetActive(Label_StoreExp, bShow)
  GUIUtils.SetActive(Label_StoreExpNum, bShow)
  GUIUtils.SetText(Label_StoreExpNum, Int64.tostring(exp))
end
def.method().OnServerLevelTipClick = function(self)
  require("Main.Server.ServerUtility").ShowServerLevelTip()
end
def.method("number").OnAttrTipClick = function(self, index)
  local key = HeroPropNode.PropNameCfgKeyList[index]
  local tipCfg = _G.GetCommonPropNameCfg(key)
  print("Tip: ", tipCfg.propTips)
  local tmpPosition = {
    x = 0,
    y = 0,
    z = 0
  }
  require("GUI.CommonUITipsDlg").Instance():ShowDlg(tipCfg.propTips, tmpPosition)
end
def.method("number", "boolean").OnAttrTipPressed = function(self, index, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local sourceObjName
  if index < 12 then
    if self.m_node:FindDirect("Img_SX_BgRight/Tab_BasicAttribute"):GetComponent("UIToggle").value == true then
      sourceObjName = string.format("Img_SX_BgAttribute/Group_BasicAttribute/Grid_SX_Attribute01/Img_SX_Attribute0%d/Sprite", index)
    else
      sourceObjName = string.format("Img_SX_BgAttribute/Group_HighAttribute/Grid_SX_Attribute01/Img_SX_Attribute0%d/Label_SX_Attribute0%d", index, index)
      index = index + 5
    end
  elseif index == 12 then
    sourceObjName = "Label_SX_Blood"
  elseif index == 13 then
    sourceObjName = "Label_SX_Blue"
  elseif index == 14 then
    sourceObjName = "Label_SX_Active"
  end
  local ui_Img_SX_BgRight = self.m_node:FindDirect("Img_SX_BgRight")
  local sourceObj = ui_Img_SX_BgRight:FindDirect(sourceObjName)
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local key = HeroPropNode.PropNameCfgKeyList[index]
  local tipCfg = _G.GetCommonPropNameCfg(key)
  CommonUISmallTip.Instance():ShowTip(tipCfg.propTips, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
end
def.method().UpdateModel = function(self)
  local Img_Model = self.m_node:FindDirect("Img_SX_BgLeft/Img_Model")
  Img_Model.transform.localPosition = EC.Vector3.new(2, 71, 0)
  local uiWidget = Img_Model:GetComponent("UIWidget")
  uiWidget.width = 546
  uiWidget.height = 550
  local uiModel = Img_Model:GetComponent("UIModel")
  uiModel.mDepressionAngle = 0
  if uiModel.mCanOverflow ~= nil then
    uiModel.mCanOverflow = true
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local occupation, gender = heroProp.occupation, heroProp.gender
  local modelPath = require("GUI.GUIUtils").GetHeroHalfBodyPath(occupation, gender)
  if self.model ~= nil then
    self.model:Destroy()
  end
  self.model = ECUIModel.new(0)
  local occupation = heroProp.occupation
  self.model:LoadUIModel(modelPath, function(ret)
    if ret == nil then
      return
    end
    self.model:SetDir(180)
    self.model:SetScale(0.75)
    uiModel.modelGameObject = self.model.m_model
    uiModel.mOffsetY = 0.2
    uiModel.mOffsetX = 0.1
    local camera = uiModel:get_modelCamera()
    camera:set_orthographic(true)
    camera.transform.localRotation = Quaternion.Euler(EC.Vector3.zero)
  end)
end
def.method("table").SetFightProp = function(self, data)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local maxHp = data.hpmax or heroProp.secondProp.maxHp
  local maxMp = data.mpmax or heroProp.secondProp.maxMp
  self:SetHPBar(data.hp, maxHp)
  self:SetMPBar(data.mp, maxMp)
end
def.method().OnAssignPropButtonClicked = function(self)
  require("Main.Hero.ui.HeroAssignPropPanel").Instance():ShowPanel()
end
def.method().OnPromoteButtonClicked = function(self)
  require("Main.Hero.HeroUIMgr").OpenHeroBianqingDlg()
end
def.method().OnShareButtonClicked = function(self)
  Event.DispatchEvent(ModuleId.SHARE, gmodule.notifyId.Share.ShareCharacter, nil)
end
def.method().SetHeadInfo = function(self)
  local Group_ChangeHead = self.m_node:FindDirect("Group_ChangeHead")
  local isOpen = require("Main.Avatar.ui.AvatarPanel").Instance():IsOpen()
  if not isOpen then
    Group_ChangeHead:SetActive(false)
    return
  end
  Group_ChangeHead:SetActive(true)
  local Icon_Head = Group_ChangeHead:FindDirect("Img_BgHead01/Icon_Head")
  local Img_Red = Group_ChangeHead:FindDirect("Img_BgHead01/Img_Red")
  local avatarInterface = require("Main.Avatar.AvatarInterface").Instance()
  Img_Red:SetActive(avatarInterface:isAvatarNotify())
  _G.SetAvatarIcon(Icon_Head)
end
return HeroPropNode.Commit()
