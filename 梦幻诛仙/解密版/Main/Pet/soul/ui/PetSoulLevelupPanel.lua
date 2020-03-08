local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PetSoulMgr = require("Main.Pet.soul.PetSoulMgr")
local PetSoulUtils = require("Main.Pet.soul.PetSoulUtils")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local PetSoulPos = require("consts.mzm.gsp.petsoul.confbean.PetSoulPos")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local CommonUseItem = require("GUI.CommonUseItem")
local PetSoulProtocols = require("Main.Pet.soul.PetSoulProtocols")
local Vector = require("Types.Vector3")
local ItemUtils = require("Main.Item.ItemUtils")
local PetSoulChoosePanel = require("Main.Pet.soul.ui.PetSoulChoosePanel")
local PetSoulLevelupPanel = Lplus.Extend(ECPanelBase, "PetSoulLevelupPanel")
local def = PetSoulLevelupPanel.define
local instance
def.static("=>", PetSoulLevelupPanel).Instance = function()
  if instance == nil then
    instance = PetSoulLevelupPanel()
  end
  return instance
end
local PET_SOUL_UPGRADE_POS = Vector.Vector3.new(-285, 0, 0)
local PET_SOUL_UPGRADE_USEITEM_POS = Vector.Vector3.new(126, 0, 0)
local PET_SOUL_UPGRADE_CHOOSE_POS = Vector.Vector3.new(104, 0, 0)
def.field("table")._uiObjs = nil
def.field("userdata")._petId = nil
def.field("number")._selectedPos = -1
def.field("number")._useItemPos = -1
def.field("table")._soulProp = nil
def.field("number")._selectedPosLevel = 0
def.static("userdata", "number").ShowPanel = function(petId, pos)
  if not PetSoulMgr.Instance():IsOpen(true) then
    if PetSoulLevelupPanel.Instance():IsShow() then
      PetSoulLevelupPanel.Instance():DestroyPanel()
    end
    return
  end
  PetSoulLevelupPanel.Instance():InitData(petId, pos)
  if PetSoulLevelupPanel.Instance():IsShow() then
    PetSoulLevelupPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_PET_SOUL_LEVEL_UP_PANEL, 1)
end
def.method("userdata", "number").InitData = function(self, petId, pos)
  self._petId = petId
  self._selectedPos = pos
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.SoulPos2BtnMap = {}
  self._uiObjs.SoulPos2BtnMap[PetSoulPos.POS_JING] = self.m_panel:FindDirect("Img_PetSprite_Upgrade_Pre/Img_Bg0/Group_Sprite/Item_Sprite01")
  self._uiObjs.SoulPos2BtnMap[PetSoulPos.POS_QI] = self.m_panel:FindDirect("Img_PetSprite_Upgrade_Pre/Img_Bg0/Group_Sprite/Item_Sprite02")
  self._uiObjs.SoulPos2BtnMap[PetSoulPos.POS_SHEN] = self.m_panel:FindDirect("Img_PetSprite_Upgrade_Pre/Img_Bg0/Group_Sprite/Item_Sprite03")
  self._uiObjs.Btn2SoulPosMap = {}
  for pos, btn in pairs(self._uiObjs.SoulPos2BtnMap) do
    self._uiObjs.Btn2SoulPosMap[btn.name] = pos
  end
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  local pet = PetMgr.Instance():GetPet(self._petId)
  if pet then
    self._soulProp = pet and pet.soulProp
  else
    warn("[ERROR][PetSoulLevelupPanel:UpdateUI] pet nil for self._petId:", Int64.tostring(self._petId))
  end
  self:UpdateSouls()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    self:TryLevelUp(self._selectedPos)
  end)
end
def.override().OnDestroy = function(self)
  if PetSoulChoosePanel.Instance():IsShow() then
    PetSoulChoosePanel.Instance():DestroyPanel()
  end
  if CommonUseItem.Instance():IsShow() then
    CommonUseItem.Instance():DestroyPanel()
  end
  self:_Reset()
end
def.method()._Reset = function(self)
  self._petId = nil
  self._selectedPos = -1
  self._useItemPos = -1
  self._soulProp = nil
  self._selectedPosLevel = 0
end
def.method().UpdateSouls = function(self)
  if self._uiObjs.SoulPos2BtnMap then
    for pos, listItem in pairs(self._uiObjs.SoulPos2BtnMap) do
      self:ShowSoul(pos, listItem)
    end
  end
end
def.method("number", "userdata").ShowSoul = function(self, pos, listItem)
  if nil == listItem then
    warn("[ERROR][PetSoulLevelupPanel:ShowSoul] listItem nil at idx:", idx)
    return
  end
  local posCfg = PetSoulData.Instance():GetPosCfg(pos)
  if nil == posCfg then
    warn("[ERROR][PetSoulLevelupPanel:ShowSoul] posCfg nil at pos:", pos)
    GUIUtils.SetActive(listItem, false)
    return
  end
  local soulInfo = self._soulProp and self._soulProp:GetSoulInfoByPos(pos)
  if nil == soulInfo then
    soulInfo = {}
    soulInfo.pos = pos
  end
  GUIUtils.SetActive(listItem, true)
  local Img_Icon = listItem:FindDirect("Img_BgEquip01/Img_IconEquip01")
  GUIUtils.SetTexture(Img_Icon, posCfg.img)
  local level = soulInfo.level and soulInfo.level or 0
  local Label_Level = listItem:FindDirect("Group_EquipLabel01/Label_SpriteProperty")
  local levelStr = string.format(textRes.Pet.Soul.LEVEL_UP_LEVEL, level)
  GUIUtils.SetText(Label_Level, levelStr)
  local propIdx = soulInfo.propIndex and soulInfo.propIndex or 0
  local prop = PetSoulData.Instance():GetSoulPropByIdx(soulInfo.pos, level, propIdx)
  local attrStr = PetSoulUtils.GetAttrString(prop)
  local Label_Attr = listItem:FindDirect("Group_EquipLabel01/Label_BuffNum")
  GUIUtils.SetText(Label_Attr, attrStr)
  local labelMax = listItem:FindDirect("Label_Upgrade_Over")
  local expSlider = listItem:FindDirect("Slider_Upgrade01")
  local maxLevel = PetSoulData.Instance():GetSoulMaxLevel(pos)
  if level >= maxLevel then
    GUIUtils.SetActive(labelMax, true)
    GUIUtils.SetActive(expSlider, false)
    GUIUtils.SetText(labelMax, textRes.Pet.Soul.SOUL_MAX_LEVEL)
  else
    GUIUtils.SetActive(labelMax, false)
    GUIUtils.SetActive(expSlider, true)
    local curExp = soulInfo.exp and soulInfo.exp or 0
    local maxExp = PetSoulData.Instance():GetSoulLevelExp(pos, level + 1)
    local progress = 0
    if maxExp > 0 then
      progress = math.min(1, curExp / maxExp)
    end
    GUIUtils.SetProgress(expSlider, GUIUtils.COTYPE.SLIDER, progress)
    local Label_Slider = listItem:FindDirect("Slider_Upgrade01/Label_Slider01")
    GUIUtils.SetText(Label_Slider, curExp .. "/" .. maxExp)
  end
end
def.method("number").TryLevelUp = function(self, pos)
  if pos >= 0 then
    local soulInfo = self._soulProp and self._soulProp:GetSoulInfoByPos(pos)
    if nil == soulInfo then
      soulInfo = {}
      soulInfo.pos = pos
    end
    local level = soulInfo.level and soulInfo.level or 0
    if level > 0 then
      level = level + 1
      self:ShowLevelUp(pos, level)
    else
      self:ShowChoose(pos)
    end
  end
  self._selectedPos = pos
  for p, listItem in pairs(self._uiObjs.SoulPos2BtnMap) do
    if not _G.IsNil(listItem) then
      local Img_Select = listItem:FindDirect("Img_Select01")
      GUIUtils.SetActive(Img_Select, p == pos)
    else
      warn("[ERROR][PetSoulLevelupPanel:TryLevelUp] listItem nil at pos:", p)
    end
  end
end
def.method("number", "number").ShowLevelUp = function(self, pos, level)
  if PetSoulChoosePanel.Instance():IsShow() then
    PetSoulChoosePanel.Instance():DestroyPanel()
  end
  if self._useItemPos ~= pos or not CommonUseItem.Instance():IsShow() or self._selectedPosLevel ~= level then
    self._useItemPos = pos
    self._selectedPosLevel = level
    self.m_panel.localPosition = PET_SOUL_UPGRADE_POS
    local soulCfg = PetSoulData.Instance():GetSoulCfg(pos, level)
    local itemTypeList = soulCfg and soulCfg.itemTypeList or {}
    CommonUseItem.Instance().initPos = PET_SOUL_UPGRADE_USEITEM_POS
    CommonUseItem.ShowCommonUse(textRes.Pet.Soul.LEVEL_UP_TITLE, itemTypeList, function(itemCfgId, useAll)
      PetSoulProtocols.SendCPetSoulAddExpReq(self._petId, pos, itemCfgId, useAll and 1 or 0)
      return true
    end, function()
      self:HideLevelUpCB()
    end)
  end
end
def.method("number").ShowChoose = function(self, pos)
  if CommonUseItem.Instance():IsShow() then
    CommonUseItem.Instance():DestroyPanel()
    self._useItemPos = -1
  end
  self.m_panel.localPosition = PET_SOUL_UPGRADE_POS
  PetSoulChoosePanel.Instance().initPos = PET_SOUL_UPGRADE_CHOOSE_POS
  PetSoulChoosePanel.ShowPanel(self._petId, pos, function()
    self:HideLevelUpCB()
  end)
end
def.method().HideLevelUpCB = function(self, pos, level)
  if self.m_panel then
    self.m_panel.localPosition = Vector.Vector3.zero
    self:TryLevelUp(-1)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Upgrade01" then
    self:OnBtn_Levelup(clickObj)
  end
end
def.method("userdata").OnBtn_Levelup = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent then
    local id = parent.name
    local pos = self._uiObjs.Btn2SoulPosMap[id]
    if pos and pos >= 0 then
      self:TryLevelUp(pos)
    end
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetSoulLevelupPanel.OnPetInfoUpdate)
    eventFunc(ModuleId.PET, gmodule.notifyId.Pet.PET_DELETED, PetSoulLevelupPanel.OnPetDeleted)
  end
end
def.static("table", "table").OnPetInfoUpdate = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  if self._petId == petId then
    self:UpdateUI()
  end
end
def.static("table", "table").OnPetDeleted = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  if self._petId == petId then
    self:DestroyPanel()
  end
end
PetSoulLevelupPanel.Commit()
return PetSoulLevelupPanel
