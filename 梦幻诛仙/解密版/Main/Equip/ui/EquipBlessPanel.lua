local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local EquipBlessPanel = Lplus.Extend(ECPanelBase, "EquipBlessPanel")
local Vector3 = require("Types.Vector3").Vector3
local GUIUtils = require("GUI.GUIUtils")
local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
local ItemModule = require("Main.Item.ItemModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local SkillUtility = require("Main.Skill.SkillUtility")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemData = require("Main.Item.ItemData")
local JewelMgr = require("Main.GodWeapon.JewelMgr")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local def = EquipBlessPanel.define
def.field("table").uiObjs = nil
def.field("number").selectedIndex = 0
def.field("table").godWeapons = nil
local instance
def.static("=>", EquipBlessPanel).Instance = function()
  if instance == nil then
    instance = EquipBlessPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  if _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIPMENT_BLESS) then
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_EQUIP_BLESS_PANEL, 1)
  else
    Toast(textRes.Equip[212])
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowEquipList()
  self:ChooseGodWeaponByIndex(1)
  require("Main.Equip.EquipBlessMgr").Instance():MarkViewedEquipBless()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, EquipBlessPanel.OnItemChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.selectedIndex = 0
  self.godWeapons = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, EquipBlessPanel.OnItemChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_EquipList = self.m_panel:FindDirect("Img_Bg/Group_EquipList")
  self.uiObjs.equipScrollView = self.uiObjs.Group_EquipList:FindDirect("Group_EquipList/Group_List/Scroll View_EquipList"):GetComponent("UIScrollView")
  self.uiObjs.Grid_EquipList = self.uiObjs.Group_EquipList:FindDirect("Group_EquipList/Group_List/Scroll View_EquipList/Grid_EquipList")
  self.uiObjs.Group_Limit = self.m_panel:FindDirect("Img_Bg/Group_Limit")
  self.uiObjs.Group_Content = self.m_panel:FindDirect("Img_Bg/Group_Content")
  self.uiObjs.Group_NoData = self.m_panel:FindDirect("Img_Bg/Group_NoData")
end
def.method().ShowEquipList = function(self)
  if self.uiObjs == nil then
    return
  end
  self.godWeapons = JewelMgr.GetData():GetHeroGodWeapons() or {}
  if #self.godWeapons == 0 then
    GUIUtils.SetActive(self.uiObjs.Group_EquipList, false)
    return
  end
  local uiList = self.uiObjs.Grid_EquipList:GetComponent("UIList")
  uiList.itemCount = #self.godWeapons
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #self.godWeapons do
    self:SetListEquipInfo(i, uiItems[i], self.godWeapons[i])
  end
  GUIUtils.SetActive(self.uiObjs.Group_EquipList, true)
end
def.method("number", "userdata", "table").SetListEquipInfo = function(self, index, equipItem, equipInfo)
  if nil == equipInfo then
    return
  end
  if nil == equipItem then
    return
  end
  local Icon_BgEquip = equipItem:FindDirect("Icon_BgEquip_" .. index)
  GUIUtils.SetSprite(Icon_BgEquip, ItemUtils.GetItemFrame(equipInfo, nil))
  local Icon_Equip = equipItem:FindDirect("Icon_Equip_" .. index)
  local uiTexture = Icon_Equip:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, equipInfo.icon)
  local Label_EquipName = equipItem:FindDirect("Label_EquipName_" .. index)
  GUIUtils.SetText(Label_EquipName, ItemUtils.GetItemName(equipInfo, nil))
  local Label_EquipLv00 = equipItem:FindDirect("Label_EquipLv00_" .. index)
  local Label_EquipLv01 = equipItem:FindDirect("Label_EquipLv01_" .. index)
  local curBlessLevel = equipInfo.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL] or 0
  GUIUtils.SetText(Label_EquipLv00, string.format(textRes.Equip[508], curBlessLevel))
  GUIUtils.SetActive(Label_EquipLv01, false)
  local Label_EquipType = equipItem:FindDirect("Label_EquipType_" .. index)
  GUIUtils.SetText(Label_EquipType, equipInfo.typeName)
  local Img_EquipMark = equipItem:FindDirect("Img_EquipMark_" .. index)
  GUIUtils.SetActive(Img_EquipMark, equipInfo.bEquiped)
  local Label_Num = equipItem:FindDirect("Label_Num_" .. index)
  local strenStr = equipInfo.strenLevel and "+" .. equipInfo.strenLevel or ""
  GUIUtils.SetText(Label_Num, strenStr)
  local Img_Red = equipItem:FindDirect("Img_Red_" .. index)
  GUIUtils.SetActive(Img_Red, false)
end
def.method("number").ChooseGodWeaponByIndex = function(self, idx)
  self.selectedIndex = idx
  local weapon = self.godWeapons[idx]
  self:MarkSelectedWeapon(idx)
  self:ShowGodWeaponDetails(weapon)
end
def.method("number").MarkSelectedWeapon = function(self, idx)
  local item = self.uiObjs.Grid_EquipList:FindDirect("Img_BgEquip_" .. idx)
  if item ~= nil then
    item:GetComponent("UIToggle").value = true
  end
end
def.method("table").ShowGodWeaponDetails = function(self, weapon)
  if weapon == nil then
    self:ShowEmptyDetails()
  else
    self:ShowBlessDetails(weapon)
  end
end
def.method().ShowEmptyDetails = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_NoData, true)
  GUIUtils.SetActive(self.uiObjs.Group_Limit, false)
  GUIUtils.SetActive(self.uiObjs.Group_Content, false)
end
def.method("table").ShowBlessDetails = function(self, weapon)
  if weapon == nil then
    return
  end
  local curBlessLevel = weapon.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL] or 0
  local isMaxLevel = EquipUtils.IsEquipBlessMaxLevel(weapon.wearPos, curBlessLevel)
  if isMaxLevel then
    self:ShowMaxBlessLevelInfo(weapon)
  else
    self:ShowCurrentAndNextBlessLevelInfo(weapon)
  end
end
def.method("table").ShowMaxBlessLevelInfo = function(self, weapon)
  if weapon == nil then
    return
  end
  GUIUtils.SetActive(self.uiObjs.Group_NoData, false)
  GUIUtils.SetActive(self.uiObjs.Group_Limit, true)
  GUIUtils.SetActive(self.uiObjs.Group_Content, false)
  local curBlessLevel = weapon.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL] or 0
  local curBlessCfg = EquipUtils.GetEquipBlessCfgByLevelAndPos(weapon.wearPos, curBlessLevel)
  local attrAType = EquipUtils.GetAttrAById(weapon.id)
  local attrAName = EquipModule.GetAttriName(attrAType)
  local attrBType = EquipUtils.GetAttrBById(weapon.id)
  local attrBName = EquipModule.GetAttriName(attrBType)
  local attrA = EquipModule.GetAttriValue(weapon.id, ItemXStoreType.ATTRI_A, weapon.extraMap[ItemXStoreType.ATTRI_A])
  local attrB = EquipModule.GetAttriValue(weapon.id, ItemXStoreType.ATTRI_B, weapon.extraMap[ItemXStoreType.ATTRI_B])
  local attrABless = attrA * curBlessCfg.propertyBuff
  local attrBBless = attrB * curBlessCfg.propertyBuff
  local Label_GWName = self.uiObjs.Group_Limit:FindDirect("GW_Name/Label_GWName")
  GUIUtils.SetText(Label_GWName, weapon.realName)
  local Img_BgPreview = self.uiObjs.Group_Limit:FindDirect("Img_BgPreview")
  local Icon_Bg = Img_BgPreview:FindDirect("Icon_Bg")
  local Icon_Equip = Icon_Bg:FindDirect("Icon_Equip")
  GUIUtils.SetTexture(Icon_Equip, weapon.icon)
  GUIUtils.SetSprite(Icon_Bg, weapon.frameName)
  local Group_CurAtt = Img_BgPreview:FindDirect("Group_CurAtt")
  local Label_CurNum = Group_CurAtt:FindDirect("Group_CurLv/Label_CurNum")
  local Label_CurEffect = Group_CurAtt:FindDirect("Group_CurEffect/Label_CurEffect")
  local Label_CurEffectNum = Group_CurAtt:FindDirect("Group_CurEffect/Label_CurEffectNum")
  local Label_AttName1 = Group_CurAtt:FindDirect("List_Cur/AttCur_1/Label_AttName")
  local Label_AttNum1 = Group_CurAtt:FindDirect("List_Cur/AttCur_1/Label_AttNum")
  local Label_AttName2 = Group_CurAtt:FindDirect("List_Cur/AttCur_2/Label_AttName")
  local Label_AttNum2 = Group_CurAtt:FindDirect("List_Cur/AttCur_2/Label_AttNum")
  GUIUtils.SetText(Label_CurNum, curBlessLevel)
  GUIUtils.SetText(Label_CurEffectNum, string.format("+%d%%", curBlessCfg.propertyBuff * 100))
  GUIUtils.SetText(Label_AttName1, attrAName)
  if attrAName == "" then
    GUIUtils.SetText(Label_AttNum1, "")
  elseif attrABless == 0 then
    GUIUtils.SetText(Label_AttNum1, string.format(" %d + 0", attrA))
  else
    GUIUtils.SetText(Label_AttNum1, string.format(" %d + %.1f", attrA, attrABless))
  end
  GUIUtils.SetText(Label_AttName2, attrBName)
  if attrBName == "" then
    GUIUtils.SetText(Label_AttNum2, "")
  elseif attrABless == 0 then
    GUIUtils.SetText(Label_AttNum2, string.format(" %d + 0", attrB))
  else
    GUIUtils.SetText(Label_AttNum2, string.format(" %d + %.1f", attrB, attrBBless))
  end
end
def.method("table").ShowCurrentAndNextBlessLevelInfo = function(self, weapon)
  if weapon == nil then
    return
  end
  GUIUtils.SetActive(self.uiObjs.Group_NoData, false)
  GUIUtils.SetActive(self.uiObjs.Group_Limit, false)
  GUIUtils.SetActive(self.uiObjs.Group_Content, true)
  local curBlessLevel = weapon.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL] or 0
  local curBlessCfg = EquipUtils.GetEquipBlessCfgByLevelAndPos(weapon.wearPos, curBlessLevel)
  local nextBlessCfg = EquipUtils.GetEquipBlessCfgByLevelAndPos(weapon.wearPos, curBlessLevel + 1)
  local attrAType = EquipUtils.GetAttrAById(weapon.id)
  local attrAName = EquipModule.GetAttriName(attrAType)
  local attrBType = EquipUtils.GetAttrBById(weapon.id)
  local attrBName = EquipModule.GetAttriName(attrBType)
  local attrA = EquipModule.GetAttriValue(weapon.id, ItemXStoreType.ATTRI_A, weapon.extraMap[ItemXStoreType.ATTRI_A])
  local attrB = EquipModule.GetAttriValue(weapon.id, ItemXStoreType.ATTRI_B, weapon.extraMap[ItemXStoreType.ATTRI_B])
  local Label_GWName = self.uiObjs.Group_Content:FindDirect("Group_GW/Label_GWName")
  GUIUtils.SetText(Label_GWName, weapon.realName)
  local Icon_Equip = self.uiObjs.Group_Content:FindDirect("Group_GW/Icon_Equip")
  local Icon_GWEquip = self.uiObjs.Group_Content:FindDirect("Group_GW/Icon_GWEquip")
  GUIUtils.SetTexture(Icon_Equip, weapon.icon)
  GUIUtils.SetSprite(Icon_GWEquip, weapon.frameName)
  local Group_CurAtt = self.uiObjs.Group_Content:FindDirect("Group_CurAtt")
  local Label_CurNum = Group_CurAtt:FindDirect("Group_CurLv/Label_CurNum")
  local Label_CurEffect = Group_CurAtt:FindDirect("Group_CurEffect/Label_CurEffect")
  local Label_CurEffectNum = Group_CurAtt:FindDirect("Group_CurEffect/Label_CurEffectNum")
  local Label_CurAttName1 = Group_CurAtt:FindDirect("List_Cur/AttCur_1/Label_AttName")
  local Label_CurAttNum1 = Group_CurAtt:FindDirect("List_Cur/AttCur_1/Label_AttNum")
  local Label_CurAttName2 = Group_CurAtt:FindDirect("List_Cur/AttCur_2/Label_AttName")
  local Label_CurAttNum2 = Group_CurAtt:FindDirect("List_Cur/AttCur_2/Label_AttNum")
  local attrABless = attrA * curBlessCfg.propertyBuff
  local attrBBless = attrB * curBlessCfg.propertyBuff
  GUIUtils.SetText(Label_CurNum, curBlessLevel)
  GUIUtils.SetText(Label_CurEffectNum, string.format("+%d%%", curBlessCfg.propertyBuff * 100))
  GUIUtils.SetText(Label_CurAttName1, attrAName)
  if attrAName == "" then
    GUIUtils.SetText(Label_CurAttNum1, "")
  elseif attrABless == 0 then
    GUIUtils.SetText(Label_CurAttNum1, string.format(" %d + 0", attrA))
  else
    GUIUtils.SetText(Label_CurAttNum1, string.format(" %d + %.1f", attrA, attrABless))
  end
  GUIUtils.SetText(Label_CurAttName2, attrBName)
  if attrBName == "" then
    GUIUtils.SetText(Label_CurAttNum2, "")
  elseif attrABless == 0 then
    GUIUtils.SetText(Label_CurAttNum2, string.format(" %d + 0", attrB))
  else
    GUIUtils.SetText(Label_CurAttNum2, string.format(" %d + %.1f", attrB, attrBBless))
  end
  local Group_NextAtt = self.uiObjs.Group_Content:FindDirect("Group_NextAtt")
  local Label_NextNum = Group_NextAtt:FindDirect("Group_NextLv/Label_NextNum")
  local Label_NextEffect = Group_NextAtt:FindDirect("Group_NextEffect/Label_NextEffect")
  local Label_NextEffectNum = Group_NextAtt:FindDirect("Group_NextEffect/Label_NextEffectNum")
  local Label_NextAttName1 = Group_NextAtt:FindDirect("List_Change/AttChange_1/Label_AttName")
  local Label_NextAttNum1 = Group_NextAtt:FindDirect("List_Change/AttChange_1/Label_AttNum")
  local Label_AttUpNu1 = Group_NextAtt:FindDirect("List_Change/AttChange_1/Label_AttUpNum")
  local Img_Up1 = Group_NextAtt:FindDirect("List_Change/AttChange_1/Img_Up")
  local Label_NextAttName2 = Group_NextAtt:FindDirect("List_Change/AttChange_2/Label_AttName")
  local Label_NextAttNum2 = Group_NextAtt:FindDirect("List_Change/AttChange_2/Label_AttNum")
  local Label_AttUpNu2 = Group_NextAtt:FindDirect("List_Change/AttChange_2/Label_AttUpNum")
  local Img_Up2 = Group_NextAtt:FindDirect("List_Change/AttChange_2/Img_Up")
  local nextAttrABless = attrA * nextBlessCfg.propertyBuff
  local nextAttrBBless = attrB * nextBlessCfg.propertyBuff
  GUIUtils.SetText(Label_NextNum, curBlessLevel + 1)
  GUIUtils.SetText(Label_NextEffectNum, string.format("+%d%%", nextBlessCfg.propertyBuff * 100))
  GUIUtils.SetText(Label_NextAttName1, attrAName)
  if attrAName == "" then
    GUIUtils.SetText(Label_NextAttNum1, "")
  elseif nextAttrABless == 0 then
    GUIUtils.SetText(Label_NextAttNum1, string.format(" %d + 0", attrA))
  else
    GUIUtils.SetText(Label_NextAttNum1, string.format(" %d + %.1f", attrA, nextAttrABless))
  end
  GUIUtils.SetText(Label_NextAttName2, attrBName)
  if attrBName == "" then
    GUIUtils.SetText(Label_NextAttNum2, "")
  elseif nextAttrBBless == 0 then
    GUIUtils.SetText(Label_NextAttNum2, string.format(" %d + 0", attrB))
  else
    GUIUtils.SetText(Label_NextAttNum2, string.format(" %d + %.1f", attrB, nextAttrBBless))
  end
  GUIUtils.SetActive(Label_AttUpNu1, false)
  GUIUtils.SetActive(Img_Up1, false)
  GUIUtils.SetActive(Label_AttUpNu2, false)
  GUIUtils.SetActive(Img_Up2, false)
  local Group_Slider = self.uiObjs.Group_Content:FindDirect("Group_Slider")
  local Label_Upgrade = Group_Slider:FindDirect("Label_Upgrade")
  local Label_UpgradeNum = Group_Slider:FindDirect("Label_UpgradeNum")
  local Slider_Pro = Group_Slider:FindDirect("Slider_Pro")
  local Label_Slider = Slider_Pro:FindDirect("Label_Slider")
  local Label_Tips = Group_Slider:FindDirect("Label_Tips")
  local curStage = weapon.godWeaponStage
  local needStage = curBlessCfg.requiredSuperEquipmentStage
  if curStage >= needStage then
    GUIUtils.SetActive(Slider_Pro, true)
    GUIUtils.SetActive(Label_Tips, true)
    GUIUtils.SetActive(Label_Upgrade, false)
    GUIUtils.SetActive(Label_UpgradeNum, false)
    local curExp = weapon.extraMap[ItemXStoreType.EQUIPMENT_BLESS_EXP] or 0
    local needExp = curBlessCfg.requiredExp
    GUIUtils.SetProgress(Slider_Pro, GUIUtils.COTYPE.SLIDER, curExp / needExp)
    GUIUtils.SetText(Label_Slider, curExp .. "/" .. needExp)
  else
    GUIUtils.SetActive(Slider_Pro, false)
    GUIUtils.SetActive(Label_Tips, false)
    GUIUtils.SetActive(Label_Upgrade, true)
    GUIUtils.SetActive(Label_UpgradeNum, true)
    GUIUtils.SetText(Label_UpgradeNum, curStage .. "/" .. needStage)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Icon_Bg" or id == "Icon_GWEquip" then
    self:OnClickWeapon(clickobj)
  elseif strs[1] == "Img" and strs[2] == "BgEquip" then
    local idx = tonumber(strs[3])
    if idx then
      self:ChooseGodWeaponByIndex(idx)
    end
  elseif id == "Btn_LvUp" then
    self:OnClickLevelUp()
  elseif id == "Btn_Tips" then
    self:OnClickTips()
  end
end
def.method("userdata").OnClickWeapon = function(self, source)
  if self.godWeapons == nil then
    return
  end
  local weapon = self.godWeapons[self.selectedIndex]
  if weapon == nil then
    return
  end
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UISprite")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(weapon.bagId, weapon.key)
  ItemTipsMgr.Instance():ShowTips(item, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
end
def.method().OnClickLevelUp = function(self)
  if self.godWeapons == nil then
    return
  end
  local weapon = self.godWeapons[self.selectedIndex]
  if not self:CheckEquipCanBlessAndToast(weapon) then
    return
  end
  local items = EquipUtils.GetEquipBlessItemsByWearpos(weapon.wearPos)
  local CommonUseItemWithOneKeyUse = require("GUI.CommonUseItemWithOneKeyUse")
  CommonUseItemWithOneKeyUse.ShowCommonUseByItemId(textRes.Equip[502], items, function(itemId, isUseAll)
    if self.godWeapons == nil then
      return false
    end
    local weapon = self.godWeapons[self.selectedIndex]
    if weapon == nil then
      return false
    end
    if isUseAll then
      return self:UseAllItemToAddBlessExp(weapon, itemId)
    else
      return self:UseOneItemToAddBlessExp(weapon, itemId)
    end
  end, nil)
  CommonUseItemWithOneKeyUse.Instance():SetModal(true)
end
def.method("table", "=>", "boolean").CheckEquipCanBlessAndToast = function(self, weapon)
  if weapon == nil then
    warn("CheckEquipCanBlessAndToast is nil")
    return false
  end
  local curBlessLevel = weapon.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL] or 0
  local curBlessCfg = EquipUtils.GetEquipBlessCfgByLevelAndPos(weapon.wearPos, curBlessLevel)
  local curStage = weapon.godWeaponStage
  local needStage = curBlessCfg.requiredSuperEquipmentStage
  if curStage < needStage then
    Toast(textRes.Equip[503])
    return false
  end
  local isMaxLevel = EquipUtils.IsEquipBlessMaxLevel(weapon.wearPos, curBlessLevel)
  if isMaxLevel then
    Toast(textRes.Equip[504])
    return false
  end
  return true
end
def.method("table", "number", "=>", "boolean").UseOneItemToAddBlessExp = function(self, weapon, itemId)
  if not self:CheckEquipCanBlessAndToast(weapon) then
    return false
  end
  require("Main.Equip.EquipBlessMgr").Instance():UseSingleEquipmentBlessItem(weapon.uuid, itemId)
  return true
end
def.method("table", "number", "=>", "boolean").UseAllItemToAddBlessExp = function(self, weapon, itemId)
  if not self:CheckEquipCanBlessAndToast(weapon) then
    return false
  end
  require("Main.Equip.EquipBlessMgr").Instance():UseMultipleEquipmentBlessItem(weapon.uuid, itemId)
  return true
end
def.method("number").RefreshEquipBlessInfo = function(self, index)
  if self.godWeapons == nil then
    return
  end
  local oldWeapon = self.godWeapons[self.selectedIndex]
  self:ShowEquipList()
  self:ChooseGodWeaponByIndex(index)
  local newWeapon = self.godWeapons[index]
  if oldWeapon ~= nil and newWeapon ~= nil then
    local oldBlessLevel = oldWeapon.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL] or 0
    local newBlessLevel = newWeapon.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL] or 0
    if oldBlessLevel < newBlessLevel then
      Toast(string.format(textRes.Equip[507], newBlessLevel))
    end
  end
end
def.static("table", "table").OnItemChange = function(params, context)
  local self = instance
  if self == nil then
    return
  end
  if self.godWeapons == nil then
    return
  end
  local weapon = self.godWeapons[self.selectedIndex]
  if weapon == nil then
    return
  end
  local changeItems = params.chgItems
  if #changeItems == 0 then
    self:RefreshEquipBlessInfo(self.selectedIndex)
    local newWeapon = self.godWeapons[self.selectedIndex]
  end
end
def.method().OnClickTips = function(self)
  GUIUtils.ShowHoverTip(constant.CEquipmentBlessConsts.HOVER_TIP_ID, 0, 0)
end
return EquipBlessPanel.Commit()
