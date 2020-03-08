local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PetTeamProtocols = require("Main.PetTeam.PetTeamProtocols")
local PetTeamUtils = require("Main.PetTeam.PetTeamUtils")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local ItemModule = require("Main.Item.ItemModule")
local CommonUseItem = require("GUI.CommonUseItem")
local Vector = require("Types.Vector3")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemUtils = require("Main.Item.ItemUtils")
local FormationPanel = Lplus.Extend(ECPanelBase, "FormationPanel")
local def = FormationPanel.define
local instance
def.static("=>", FormationPanel).Instance = function()
  if instance == nil then
    instance = FormationPanel()
  end
  return instance
end
def.const("table").ShowState = {CHOOSE = 0, UPGRADE = 1}
local USE_ITEM_POS = Vector.Vector3.new(50, 0, 0)
local MAX_FORMATION_PER_PAGE = 5
def.field("table")._uiObjs = nil
def.field("number")._curState = 0
def.field("number")._curFormationId = 0
def.field("function")._callback = nil
def.field("table")._formationCfgList = nil
def.field("number")._selectedIdx = 1
def.field("table")._selectedFormationCfg = nil
def.field("number")._showLevel = 1
def.static("number", "number", "function").ShowPanel = function(state, curFormationId, callback)
  if not require("Main.PetTeam.PetTeamModule").Instance():IsOpen(true) then
    if FormationPanel.Instance():IsShow() then
      FormationPanel.Instance():DestroyPanel()
    end
    return
  end
  FormationPanel.Instance():_InitData(state, curFormationId, callback)
  if FormationPanel.Instance():IsShow() then
    FormationPanel.Instance():UpdateUI()
    return
  end
  FormationPanel.Instance():CreatePanel(RESPATH.PREFAB_PETTEAM_FORMATION_PANEL, 2)
end
def.method("number", "number", "function")._InitData = function(self, state, curFormationId, callback)
  self._curState = state
  self._curFormationId = curFormationId
  self._callback = callback
  self._selectedIdx = 1
  if self._curState == FormationPanel.ShowState.CHOOSE then
    self._formationCfgList = PetTeamData.Instance():GetOwnFormationCfgs()
  else
    self._formationCfgList = PetTeamData.Instance():GetAllFormationCfgs()
    if self._formationCfgList then
      for idx, formationCfg in ipairs(self._formationCfgList) do
        if formationCfg.id == curFormationId then
          self._selectedIdx = idx
          break
        end
      end
    end
  end
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_NoData = self.m_panel:FindDirect("Img_Bg0/Group_NoData")
  self._uiObjs.Img_List = self.m_panel:FindDirect("Img_Bg0/Img_List")
  self._uiObjs.Scroll_View = self._uiObjs.Img_List:FindDirect("Scroll View")
  self._uiObjs.uiScrollView = self._uiObjs.Scroll_View:GetComponent("UIScrollView")
  self._uiObjs.List_Book = self._uiObjs.Scroll_View:FindDirect("List_Book")
  self._uiObjs.uiList = self._uiObjs.List_Book:GetComponent("UIList")
  self._uiObjs.Group_Exp = self.m_panel:FindDirect("Img_Bg0/Group_Exp")
  self._uiObjs.LableExpTile = self._uiObjs.Group_Exp:FindDirect("Label")
  self._uiObjs.Slider_Exp = self._uiObjs.Group_Exp:FindDirect("Slider_Exp")
  self._uiObjs.Label_Num = self._uiObjs.Slider_Exp:FindDirect("Label_Num")
  self._uiObjs.Label_ExpFull = self._uiObjs.Group_Exp:FindDirect("Label_ExpFull")
  self._uiObjs.Img_Red = self._uiObjs.Group_Exp:FindDirect("Img_Red")
  self._uiObjs.Btn_Advance = self._uiObjs.Group_Exp:FindDirect("Btn_Advance")
  self._uiObjs.Group_Front = self.m_panel:FindDirect("Img_Bg0/Group_Front")
  self._uiObjs.Formation = {}
  for i = 1, constant.CPetFightConsts.MAX_POSITION_NUMBER do
    self._uiObjs.Formation[i] = self._uiObjs.Group_Front:FindDirect("Group_Site_" .. i)
  end
  self._uiObjs.Group_Info = self.m_panel:FindDirect("Img_Bg0/Group_Info")
  self._uiObjs.LabelFormationLevel = self._uiObjs.Group_Info:FindDirect("Group_Label/Label")
  self._uiObjs.Grid_Att = self._uiObjs.Group_Info:FindDirect("Grid_Att")
  self._uiObjs.FormationAttrs = {}
  for i = 1, constant.CPetFightConsts.MAX_PET_NUMBER_PER_TEAM do
    self._uiObjs.FormationAttrs[i] = self._uiObjs.Grid_Att:FindDirect("Group_Att0" .. i)
  end
  self._uiObjs.Btn_Act = self.m_panel:FindDirect("Img_Bg0/Btn_Act")
  self._uiObjs.LabelChoose = self._uiObjs.Btn_Act:FindDirect("Label_Btn")
  self._uiObjs.Btn_Learn = self.m_panel:FindDirect("Img_Bg0/Btn_Learn")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
    if self._selectedIdx > MAX_FORMATION_PER_PAGE and self:GetForamtionCount() > 0 then
      GameUtil.AddGlobalLateTimer(0.01, true, function()
        if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiScrollView) then
          local amountY = self._selectedIdx / self:GetForamtionCount()
          self._uiObjs.uiScrollView:SetDragAmount(0, amountY, false)
        end
      end)
    else
      self._uiObjs.uiScrollView:ResetPosition()
    end
  else
  end
end
def.method().UpdateUI = function(self)
  if self:GetForamtionCount() > 0 then
    GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
    GUIUtils.SetActive(self._uiObjs.Img_List, true)
    GUIUtils.SetActive(self._uiObjs.Group_Exp, true)
    GUIUtils.SetActive(self._uiObjs.Group_Front, true)
    GUIUtils.SetActive(self._uiObjs.Group_Info, true)
    GUIUtils.SetActive(self._uiObjs.Btn_Act, true)
    GUIUtils.SetActive(self._uiObjs.Btn_Learn, true)
    self:ShowFormationList()
    self:SelectFormation(self._selectedIdx, true)
  else
    GUIUtils.SetActive(self._uiObjs.Group_NoData, true)
    GUIUtils.SetActive(self._uiObjs.Img_List, false)
    GUIUtils.SetActive(self._uiObjs.Group_Exp, false)
    GUIUtils.SetActive(self._uiObjs.Group_Front, false)
    GUIUtils.SetActive(self._uiObjs.Group_Info, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Act, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Learn, false)
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearList()
  self._uiObjs = nil
  self._curState = 0
  self._curFormationId = 0
  self._callback = nil
  self._formationCfgList = nil
  self._selectedIdx = 1
  self._selectedFormationCfg = nil
  self._showLevel = 1
end
def.method("=>", "number").GetForamtionCount = function(self)
  return self._formationCfgList and #self._formationCfgList or 0
end
def.method("number", "=>", "table").GetForamtionCfg = function(self, idx)
  return self._formationCfgList and self._formationCfgList[idx]
end
def.method().ShowFormationList = function(self)
  self:_ClearList()
  local formationCount = self:GetForamtionCount()
  if formationCount > 0 then
    self._uiObjs.uiList.itemCount = formationCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for idx, formationCfg in ipairs(self._formationCfgList) do
      self:ShowFormationInfo(idx, formationCfg)
    end
  end
end
def.method("number", "table").ShowFormationInfo = function(self, idx, formationCfg)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][FormationPanel:ShowFormationInfo] listItem nil at idx:", idx)
    return
  end
  if nil == formationCfg then
    warn("[ERROR][FormationPanel:ShowFormationInfo] formationCfg nil at idx:", idx)
    return
  end
  local Label_Name = listItem:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, formationCfg.name)
  local Img_Icon = listItem:FindDirect("Img_BgIcon/Icon_Book")
  GUIUtils.SetTexture(Img_Icon, formationCfg.iconId)
  self:UpdateFormationState(idx, listItem, formationCfg)
end
def.method("number", "userdata", "table").UpdateFormationState = function(self, idx, listItem, formationCfg)
  if nil == listItem then
    warn("[ERROR][FormationPanel:UpdateFormationState] listItem nil at idx:", idx)
    return
  end
  if nil == formationCfg then
    warn("[ERROR][FormationPanel:UpdateFormationState] formationCfg nil at idx:", idx)
    return
  end
  local Img_Red = listItem:FindDirect("Img_Red")
  local bUpgrade = PetTeamData.Instance():CanFormationUpgrade(formationCfg.id, true)
  GUIUtils.SetActive(Img_Red, self._curState ~= FormationPanel.ShowState.CHOOSE and bUpgrade)
  local formationInfo = PetTeamData.Instance():GetFormationInfo(formationCfg.id)
  local Group_Learned = listItem:FindDirect("Group_Learned")
  local Group_NoLearn = listItem:FindDirect("Group_NoLearn")
  if formationInfo then
    GUIUtils.SetActive(Group_Learned, true)
    GUIUtils.SetActive(Group_NoLearn, false)
    local Label_Lv = Group_Learned:FindDirect("Label_Lv")
    if formationInfo.level > 0 then
      GUIUtils.SetText(Label_Lv, string.format(textRes.PetTeam.FORMATION_LEVEL, formationInfo.level))
    else
      GUIUtils.SetActive(Label_Lv, false)
    end
    local Label_Advance = Group_Learned:FindDirect("Label_Advance")
    GUIUtils.SetActive(Label_Advance, bUpgrade)
    local Label_Full = Group_Learned:FindDirect("Label_Full")
    GUIUtils.SetActive(Label_Full, formationInfo.level >= PetTeamData.Instance():GetFormationMaxLevel(formationCfg.id))
    local Img_Use = Group_Learned:FindDirect("Img_Use")
    GUIUtils.SetActive(Img_Use, self._curState == FormationPanel.ShowState.CHOOSE and self._curFormationId == formationCfg.id)
  else
    GUIUtils.SetActive(Group_Learned, false)
    GUIUtils.SetActive(Group_NoLearn, true)
  end
end
def.method().UpdateAllFormationState = function(self)
  local formationCount = self:GetForamtionCount()
  if formationCount > 0 then
    for idx, formationCfg in ipairs(self._formationCfgList) do
      local listItem = self._uiObjs.uiList.children[idx]
      self:UpdateFormationState(idx, listItem, formationCfg)
    end
  end
end
def.method()._ClearList = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiList) then
    self._uiObjs.uiList.itemCount = 0
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
  end
end
def.method("number", "boolean").SelectFormation = function(self, idx, bForce)
  if not bForce and idx == self._selectedIdx then
    return
  end
  self._selectedIdx = idx
  if self._selectedIdx > 0 then
    local listItem = self._uiObjs.uiList.children[idx]
    if nil == listItem then
      warn("[ERROR][FormationPanel:SelectFormation] listItem nil at idx:", idx)
      return
    end
    GUIUtils.Toggle(listItem, true)
  end
  self._selectedFormationCfg = self:GetForamtionCfg(self._selectedIdx)
  if self._selectedFormationCfg then
    self._showLevel = PetTeamData.Instance():GetFormationLevel(self._selectedFormationCfg.id)
  end
  if 0 >= self._showLevel then
    self._showLevel = 1
  end
  self:UpdateUpgrade()
  self:ShowFormation()
  self:UpdateFormationAttr(self._showLevel, true)
  self:UpdateChoose()
end
def.method().UpdateUpgrade = function(self)
  if self._curState == FormationPanel.ShowState.CHOOSE or nil == self._selectedFormationCfg then
    GUIUtils.SetActive(self._uiObjs.Group_Exp, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Learn, false)
  else
    local selectedFormationId = self._selectedFormationCfg.id
    local bUpgrade = PetTeamData.Instance():CanFormationUpgrade(selectedFormationId, true)
    local curLevel = PetTeamData.Instance():GetFormationLevel(selectedFormationId)
    local maxLevel = PetTeamData.Instance():GetFormationMaxLevel(selectedFormationId)
    if curLevel >= maxLevel then
      GUIUtils.SetActive(self._uiObjs.Group_Exp, true)
      GUIUtils.SetActive(self._uiObjs.Btn_Learn, false)
      GUIUtils.SetActive(self._uiObjs.Slider_Exp, false)
      GUIUtils.SetActive(self._uiObjs.Label_Num, false)
      GUIUtils.SetActive(self._uiObjs.Label_ExpFull, true)
      GUIUtils.SetActive(self._uiObjs.Img_Red, false)
      GUIUtils.SetActive(self._uiObjs.LableExpTile, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Advance, false)
    elseif 0 == curLevel then
      GUIUtils.SetActive(self._uiObjs.Group_Exp, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Learn, true)
      local Img_Red = self._uiObjs.Btn_Learn:FindDirect("Img_Red")
      GUIUtils.SetActive(Img_Red, bUpgrade)
    else
      GUIUtils.SetActive(self._uiObjs.Group_Exp, true)
      GUIUtils.SetActive(self._uiObjs.Btn_Learn, false)
      GUIUtils.SetActive(self._uiObjs.Slider_Exp, true)
      GUIUtils.SetActive(self._uiObjs.Label_Num, true)
      GUIUtils.SetActive(self._uiObjs.Label_ExpFull, false)
      GUIUtils.SetActive(self._uiObjs.Img_Red, bUpgrade)
      GUIUtils.SetActive(self._uiObjs.LableExpTile, true)
      GUIUtils.SetActive(self._uiObjs.Btn_Advance, true)
      local upgradeExp = PetTeamData.Instance():GetFormationUpgradeExp(selectedFormationId, curLevel)
      local curExp = PetTeamData.Instance():GetFormationExp(selectedFormationId)
      local progress = upgradeExp > 0 and curExp / upgradeExp or 0
      GUIUtils.SetProgress(self._uiObjs.Slider_Exp, GUIUtils.COTYPE.SLIDER, progress)
      GUIUtils.SetText(self._uiObjs.Label_Num, curExp .. "/" .. upgradeExp)
    end
  end
end
def.method().ShowFormation = function(self)
  PetTeamUtils.ShowFormation(self._selectedFormationCfg, nil, self._uiObjs.Formation, false)
end
def.method("number", "boolean").UpdateFormationAttr = function(self, level, bForce)
  local maxLevel = PetTeamData.Instance():GetFormationMaxLevel(self._selectedFormationCfg.id)
  if level > maxLevel then
    level = maxLevel
  elseif level < 1 then
    level = 1
  end
  if not bForce and level == self._showLevel then
    return
  end
  self._showLevel = level
  local levelStr = string.format(textRes.PetTeam.FORMATION_LEVEL_ATTR, self._showLevel)
  local curLevel = PetTeamData.Instance():GetFormationLevel(self._selectedFormationCfg.id)
  if curLevel < self._showLevel then
    levelStr = string.format(textRes.PetTeam.FORMATION_LEVEL_NO, levelStr)
  end
  GUIUtils.SetText(self._uiObjs.LabelFormationLevel, levelStr)
  PetTeamUtils.ShowFormationAttrs(self._selectedFormationCfg.id, self._showLevel, nil, self._uiObjs.FormationAttrs)
end
def.method().UpdateChoose = function(self)
  if self._curState == FormationPanel.ShowState.CHOOSE and self._selectedFormationCfg then
    if self._selectedFormationCfg.id == constant.CPetFightConsts.DEFAULT_FORMATION_ID and self._curFormationId == self._selectedFormationCfg.id then
      GUIUtils.SetActive(self._uiObjs.Btn_Act, false)
    else
      GUIUtils.SetActive(self._uiObjs.Btn_Act, true)
      if self._curFormationId == self._selectedFormationCfg.id then
        GUIUtils.SetText(self._uiObjs.LabelChoose, textRes.PetTeam.FORMATION_CLOSE)
      else
        GUIUtils.SetText(self._uiObjs.LabelChoose, textRes.PetTeam.FORMATION_CHOOSE)
      end
    end
  else
    GUIUtils.SetActive(self._uiObjs.Btn_Act, false)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif string.find(id, "item") then
    self:OnListitem(id)
  elseif id == "Btn_Advance" then
    self:OnBtn_Advance()
  elseif id == "Btn_Learn" then
    self:OnBtn_Learn()
  elseif id == "Btn_Act" then
    self:OnBtn_Act()
  elseif id == "Btn_Left" then
    self:OnBtn_Left()
  elseif id == "Btn_Right" then
    self:OnBtn_Right()
  end
end
def.method().OnBtn_Close = function(self)
  if self._callback then
    self._callback(self._curFormationId)
  end
  self:DestroyPanel()
end
def.method("string").OnListitem = function(self, id)
  local togglePrefix = "item_"
  local idx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  self:SelectFormation(idx, false)
end
def.method().OnBtn_Advance = function(self)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  local selectedFormationId = self._selectedFormationCfg.id
  local items = PetTeamData.Instance():GetAllFormationUpgradeItemIds()
  local fragItemIdList = ItemUtils.GetItemTypeRefIdList(ItemType.PET_FIGHT_FORMATION_FRAGMENT)
  if fragItemIdList then
    if items then
      for _, itemId in ipairs(fragItemIdList) do
        table.insert(items, itemId)
      end
    else
      items = fragItemIdList
    end
  end
  CommonUseItem.Instance().initPos = USE_ITEM_POS
  CommonUseItem.Instance():SetModal(true)
  CommonUseItem.ShowCommonUseByItemIdEx(textRes.PetTeam.FORMATION_UPGRADE_TITLE, items, function(itemCfgId, useAll)
    local itemUuid
    local itemKey, itemInfo = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, itemCfgId)
    if itemKey >= 0 then
      itemUuid = itemInfo.uuid[1]
    end
    if itemUuid then
      PetTeamProtocols.SendCPetFightImproveFormationReq(selectedFormationId, itemUuid, useAll and 1 or 0)
    else
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      local itemName = HtmlHelper.GetColoredItemName(itemCfgId)
      Toast(string.format(textRes.PetTeam.FORMATION_UPGRADE_LACK_ITEM, itemName))
    end
    return true
  end, nil)
end
def.method().OnBtn_Learn = function(self)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  if self._curState == FormationPanel.ShowState.UPGRADE and self._selectedFormationCfg then
    local selectedFormationId = self._selectedFormationCfg.id
    local bUpgrade = PetTeamData.Instance():CanFormationUpgrade(selectedFormationId, true)
    local curLevel = PetTeamData.Instance():GetFormationLevel(selectedFormationId)
    local maxLevel = PetTeamData.Instance():GetFormationMaxLevel(selectedFormationId)
    if 0 == curLevel and curLevel < maxLevel then
      local itemUuid, tmpItemId
      local upgradeCfg = PetTeamData.Instance():GetFormationUpgradeCfg(selectedFormationId)
      if upgradeCfg and upgradeCfg.items and 0 < #upgradeCfg.items then
        for _, itemId in ipairs(upgradeCfg.items) do
          tmpItemId = itemId
          local itemKey, itemInfo = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, itemId)
          if itemKey >= 0 then
            itemUuid = itemInfo.uuid[1]
            break
          end
        end
      end
      if itemUuid then
        PetTeamProtocols.SendCPetFightImproveFormationReq(selectedFormationId, itemUuid, 0)
      elseif tmpItemId then
        local HtmlHelper = require("Main.Chat.HtmlHelper")
        local itemName = HtmlHelper.GetColoredItemName(tmpItemId)
        Toast(string.format(textRes.PetTeam.FORMATION_UPGRADE_LACK_ITEM, itemName))
        local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
        ItemTipsMgr.Instance():ShowBasicTipsWithGO(tmpItemId, self._uiObjs.Btn_Learn, 0, true)
      end
    else
      self:UpdateUpgrade()
    end
  else
    self:UpdateUpgrade()
  end
end
def.method().OnBtn_Act = function(self)
  if self._curState == FormationPanel.ShowState.CHOOSE and self._selectedFormationCfg then
    local selectedFormationId = self._selectedFormationCfg.id
    local preFormationId = self._curFormationId
    if self._curFormationId == selectedFormationId then
      self._curFormationId = constant.CPetFightConsts.DEFAULT_FORMATION_ID
    else
      self._curFormationId = selectedFormationId
    end
    if preFormationId ~= self._curFormationId then
      local formationCfg = PetTeamData.Instance():GetFormationCfg(self._curFormationId)
      Toast(string.format(textRes.PetTeam.FORMATION_CHOOSE_SUCESS, formationCfg and formationCfg.name or ""))
      self:UpdateAllFormationState()
      self:UpdateChoose()
    end
  else
    self:UpdateChoose()
  end
end
def.method().OnBtn_Left = function(self)
  self:UpdateFormationAttr(self._showLevel - 1, false)
end
def.method().OnBtn_Right = function(self)
  self:UpdateFormationAttr(self._showLevel + 1, false)
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_FORMATION_CHANGE, FormationPanel.OnFormationChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FormationPanel.OnBagChange)
  end
end
def.static("table", "table").OnFormationChange = function(params, context)
  local formationId = params.formationId
  warn("[FormationPanel:OnFormationChange] OnFormationChange, formationId:", formationId)
  local self = FormationPanel.Instance()
  if self and self:IsShow() and self:GetForamtionCount() > 0 then
    self:UpdateAllFormationState()
    if formationId == self._selectedFormationCfg.id then
      self:UpdateUpgrade()
      local curLevel = PetTeamData.Instance():GetFormationLevel(formationId)
      self:UpdateFormationAttr(curLevel, true)
    end
  end
end
def.static("table", "table").OnBagChange = function(params, context)
  warn("[FormationPanel:OnBagChange] OnBagChange.")
  local self = FormationPanel.Instance()
  if self and self:IsShow() and self:GetForamtionCount() > 0 then
    self:UpdateAllFormationState()
    self:UpdateUpgrade()
  end
end
FormationPanel.Commit()
return FormationPanel
