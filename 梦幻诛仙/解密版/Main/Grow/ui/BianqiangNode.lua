local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GrowGuideNodeBase = require("Main.Grow.ui.GrowGuideNodeBase")
local GUIUtils = require("GUI.GUIUtils")
local BianqiangVDMgr = require("Main.Grow.viewdata.BianqiangVDMgr")
local GrowUtils = require("Main.Grow.GrowUtils")
local BianqiangNode = Lplus.Extend(GrowGuideNodeBase, MODULE_NAME)
local def = BianqiangNode.define
def.field("table").mUiObjs = nil
def.field("number").mCurTab = 0
def.field("table").mLeftData = nil
def.field("table").mRightData = nil
def.field("table").mViewData = nil
def.field("boolean").isShowing = false
def.field("table").mFilterData = nil
def.const("number").BIAN_QIANG_SPECIAL_INDEX = 1
local instance
def.static("=>", BianqiangNode).Instance = function()
  if instance == nil then
    instance = BianqiangNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, panelbase, node)
  GrowGuideNodeBase.Init(self, panelbase, node)
end
def.override().OnShow = function(self)
  if self.isShowing then
    if self.mCurTab == BianqiangNode.BIAN_QIANG_SPECIAL_INDEX then
      self:UpdateCurTabContent()
    end
    return
  end
  self.mCurTab = 1
  self.isShowing = true
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, BianqiangNode.OnRoleLvUp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_FIGHT_VALUE_CHANGED, BianqiangNode.OnFightValueChanged)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, BianqiangNode.OnRoleLvUp)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_FIGHT_VALUE_CHANGED, BianqiangNode.OnFightValueChanged)
  self.isShowing = false
  self:ResetUI()
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.override("string", "boolean").onToggle = function(self, id, isActive)
end
def.method().InitUI = function(self)
  self.mUiObjs = {}
  self.mUiObjs.BgView = self.m_node:FindDirect("Img_BgTab")
  self.mUiObjs.ThingScrollView = self.m_node:FindDirect("ScrollView")
  self.mUiObjs.Group_PowerGrade = self.m_node:FindDirect("Group_PowerGrade")
  self.mUiObjs.ThingListView = self.mUiObjs.ThingScrollView:FindDirect("Table")
  self.mUiObjs.ThingListView2 = self.mUiObjs.ThingScrollView:FindDirect("Table2")
  self.mUiObjs.ClassScrollView = self.m_node:FindDirect("Img_BgTab/Scroll View_Tab")
  self.mUiObjs.ClassListView = self.mUiObjs.ClassScrollView:FindDirect("List_Tab")
  GUIUtils.InitUIList(self.mUiObjs.ThingListView, 0, true)
end
def.method().ResetUI = function(self)
  self.mUiObjs = nil
  self.mViewData = nil
end
def.method().UpdateUI = function(self)
  self:UpdateListUI()
  self:LocateFocusTab()
  self:UpdateCurTabContent()
  self:UpdateFightValueInfo()
end
def.method("number").OnClickBianQiangSpecialIndex = function(self, index)
  local curTypeData = self.mViewData[index]
  if curTypeData == nil then
    return
  end
  local infoData = curTypeData.datas
  if nil == infoData or #infoData < 1 then
    return
  end
  self.mUiObjs.ThingListView:SetActive(false)
  self.mUiObjs.ThingListView2:SetActive(true)
  GameUtil.AddGlobalLateTimer(0, true, function()
    if self.mUiObjs and self.mUiObjs.ThingListView2 and not self.mUiObjs.ThingListView2.isnil then
      self:UpdateSpecialRightView(infoData)
    end
  end)
end
def.method("table").UpdateSpecialRightView = function(self, viewData)
  if self.mUiObjs and self.mUiObjs.ThingListView2 and not self.mUiObjs.ThingListView2.isnil and self.mUiObjs.ThingListView2:get_activeInHierarchy() then
    local realData = BianqiangVDMgr.Instance():FilterCfgDataByLevel(viewData)
    self.mFilterData = realData
    local dataNum = #realData
    local itemList = GUIUtils.InitUIList(self.mUiObjs.ThingListView2, dataNum, false)
    for i = 1, dataNum do
      local itemObj = itemList[i]
      itemObj.name = string.format("BianQiangItem_%d", i)
      local texture = itemObj:FindDirect(("Group_Items_%d/Img_BgIcon_%d/Texture_Item_%d"):format(i, i, i))
      local nameLabel = itemObj:FindDirect(("Group_Items_%d/Label_Name_%d"):format(i, i))
      local name = realData[i].name
      local icon = realData[i].icon
      nameLabel:GetComponent("UILabel"):set_text(name)
      GUIUtils.FillIcon(texture:GetComponent("UITexture"), icon)
      self:UpdateSliderStateAndDesc(itemObj, i, realData[i])
    end
    self.m_base.m_msgHandler:Touch(self.mUiObjs.ThingListView2)
    GUIUtils.Reposition(self.mUiObjs.ThingListView2, "UIList", 0)
    GameUtil.AddGlobalLateTimer(0.01, true, function()
      self.mUiObjs.ThingListView2:GetComponent("UIList"):DragToMakeVisible(0, 100)
      self.mUiObjs.ThingScrollView:GetComponent("UIScrollView"):ResetPosition()
    end)
  end
end
def.method("userdata", "number", "table").UpdateSliderStateAndDesc = function(self, itemObj, index, data)
  if itemObj and not itemObj.isnil and itemObj:get_activeInHierarchy() then
    local value = BianqiangVDMgr.Instance():CalcValueByProgressType(data.progressType)
    local spriteName, desc = BianqiangVDMgr.Instance():GetProgressColorAndDesc(value)
    if spriteName and desc then
      local slider = itemObj:FindDirect(("Group_Items_%d/Slider_Bg_%d"):format(index, index))
      local sliderSprite = slider:FindDirect(("Img_Slider_%d"):format(index))
      local descLabel = itemObj:FindDirect(("Group_Items_%d/Label_Tip_%d"):format(index, index))
      local rateValue = value / 10000
      slider:GetComponent("UISlider"):set_value(rateValue)
      sliderSprite:GetComponent("UISprite"):set_spriteName(spriteName)
      descLabel:GetComponent("UILabel"):set_text(desc)
    end
  end
end
def.override("userdata").onClickObj = function(self, clickObj)
  local goname = clickObj.name
  if #goname >= 5 and string.sub(goname, 1, 5) == "left_" then
    local index = self:GetIndexByName(clickObj.name)
    if index > 0 then
      if BianqiangNode.BIAN_QIANG_SPECIAL_INDEX == index then
        self:OnClickBianQiangSpecialIndex(index)
      else
        self.mUiObjs.ThingListView:SetActive(true)
        self.mUiObjs.ThingListView2:SetActive(false)
        do
          local curTabData = self.mViewData[index]
          if curTabData == nil then
            return
          end
          self.mCurTab = index
          local data = curTabData.datas
          self.mRightData = data
          GameUtil.AddGlobalLateTimer(0, true, function()
            self:UpdateStrongList(self.mUiObjs.ThingListView, data, self.UpdateOneStrong)
            GUIUtils.ResetPosition(self.mUiObjs.ThingScrollView)
          end)
        end
      end
    end
  elseif goname == "Btn_BQ_ZhuGo" then
    local index = self:GetIndexByName(clickObj.parent.parent.name)
    local data = self.mRightData[index]
    local childData = data.child
    if childData then
      data.expand = not data.expand
      self:UpdateOneStrong(clickObj.parent.parent, index, data)
      GUIUtils.Reposition(self.mUiObjs.ThingListView, GUIUtils.COTYPE.LIST, 0)
    else
      self:OnBtnGoClicked(index, 0)
    end
  elseif goname == "Btn_BQ_FuGo" then
    local index = self:GetIndexByName(clickObj.parent.name)
    local parentIndex = self:GetIndexByName(clickObj.parent.parent.parent.name)
    self:OnBtnGoClicked(parentIndex, index)
  elseif string.find(goname, "Btn_Go_") then
    self:OnClickBianQiangBtnGo(clickObj)
  end
end
def.method("userdata").OnClickBianQiangBtnGo = function(self, btnGo)
  if btnGo and not btnGo.isnil and btnGo:get_activeInHierarchy() then
    local parentObj = btnGo.parent.parent
    local parentName = parentObj.name
    if string.find(parentName, "BianQiangItem_") then
      local index = self:GetIndexByName(parentName)
      if self.mFilterData and self.mFilterData[index] then
        local operateId = self.mFilterData[index].operateId
        local close = GrowUtils.ApplyOperation(operateId)
        if close then
          self.m_base:DestroyPanel()
        end
      end
    end
  end
end
def.override("string").onClick = function(self, id)
  print("onclick ", id)
end
def.method("string", "=>", "number").GetIndexByName = function(self, name)
  local strs = string.split(name, "_")
  return tonumber(strs[2])
end
def.method().UpdateListUI = function(self)
  if self.mUiObjs.ClassListView == nil then
    return
  end
  local data = BianqiangVDMgr.Instance():GetBianqiangPanelViewData()
  self.mViewData = data
  self.mLeftData = data
  if data == nil then
    return
  end
  local baodianNum = #data
  local baodianList = GUIUtils.InitUIList(self.mUiObjs.ClassListView, baodianNum, true)
  local template = self.mUiObjs.ClassListView:FindDirect("Tab_CZ")
  template:SetActive(false)
  for i = 1, baodianNum do
    local itemObj = baodianList[i]
    itemObj.name = string.format("left_%d", i)
    local uiLabel = itemObj:FindDirect("Label_Tab"):GetComponent("UILabel")
    uiLabel.text = data[i].name
    self.m_base.m_msgHandler:Touch(itemObj)
  end
  GUIUtils.Reposition(self.mUiObjs.ClassListView, "UIList", 0)
end
def.method().UpdateCurTabContent = function(self)
  local itemObj = self.mUiObjs.ClassListView:FindDirect(string.format("left_%d", self.mCurTab))
  if itemObj == nil then
    return
  end
  GUIUtils.Toggle(itemObj, true)
  self:onClickObj(itemObj)
end
def.method("userdata", "table", "function").UpdateStrongList = function(self, uilist, data, updateFunc)
  local count = #data
  local baodianList = GUIUtils.InitUIList(uilist, count, true)
  local template = uilist:FindDirect("Group_1")
  template:SetActive(false)
  for i = 1, count do
    local itemObj = baodianList[i]
    itemObj.name = string.format("BDItem_%d", i)
    updateFunc(self, itemObj, i, data[i])
    self.m_base.m_msgHandler:Touch(itemObj)
  end
  GUIUtils.Reposition(uilist, "UIList", 0)
end
def.method("userdata", "number", "table").UpdateOneStrong = function(self, itemObj, index, data)
  local obj1 = itemObj:FindDirect("Group_Zhu")
  local obj2 = itemObj:FindDirect("Table_Fu")
  obj2:SetActive(true)
  GUIUtils.SetText(obj1:FindDirect("Label_Name"), data.name)
  GUIUtils.SetText(obj1:FindDirect("Label_Describe"), data.desc)
  local lvText = string.format(textRes.Grow[43], data.level)
  GUIUtils.SetText(obj1:FindDirect("Label_Lv"), lvText)
  local icon = data.icon or 0
  GUIUtils.SetTexture(obj1:FindDirect("Img_BgIcon/Texture_Item"), icon)
  local List_Star = obj1:FindDirect("List_Star")
  GUIUtils.InitUIList(List_Star, data.star, false)
  if not data.child then
    obj1:FindDirect("Btn_BQ_ZhuGo/Label_Btn"):GetComponent("UILabel").text = textRes.Grow[41]
    obj1:FindDirect("Btn_BQ_ZhuGo/Img_BgUp"):SetActive(false)
    obj1:FindDirect("Btn_BQ_ZhuGo/Img_BgDown"):SetActive(false)
  else
    local text = textRes.Grow[42]
    if data.expand then
      text = textRes.Grow[44]
    end
    obj1:FindDirect("Btn_BQ_ZhuGo/Label_Btn"):GetComponent("UILabel").text = text
    obj1:FindDirect("Btn_BQ_ZhuGo/Img_BgUp"):SetActive(data.expand)
    obj1:FindDirect("Btn_BQ_ZhuGo/Img_BgDown"):SetActive(not data.expand)
  end
  if not data.child or not data.expand then
    obj2:SetActive(false)
  else
    self:UpdateStrongList(obj2, data.child, self.UpdateOneStrongChild)
  end
end
def.method("userdata", "number", "table").UpdateOneStrongChild = function(self, itemObj, index, data)
  local obj1 = itemObj
  GUIUtils.SetText(obj1:FindDirect("Label_Name"), data.name)
  GUIUtils.SetText(obj1:FindDirect("Label_Describe"), data.desc)
  local lvText = string.format(textRes.Grow[43], data.level)
  GUIUtils.SetText(obj1:FindDirect("Label_Lv"), lvText)
  local icon = data.icon or 0
  GUIUtils.SetTexture(obj1:FindDirect("Img_BgIcon/Texture_Item"), icon)
  local List_Star = obj1:FindDirect("List_Star")
  GUIUtils.InitUIList(List_Star, data.star, false)
end
def.method("number", "number").OnBtnGoClicked = function(self, mainIndex, subIndex)
  local data = self.mRightData[mainIndex]
  local operateId
  local unlockLevel = 0
  if subIndex == 0 then
    operateId = data.operateId
    unlockLevel = data.level
  elseif data.child and data.child[subIndex] then
    operateId = data.child[subIndex].operateId
    unlockLevel = data.child[subIndex].level
  end
  if operateId == nil then
    warn("Missing operateId: OnBtnGoClicked ", mainIndex, ",", subIndex)
    return
  end
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  if unlockLevel > heroLevel then
    Toast(string.format(textRes.Grow.Achievement[2], unlockLevel))
    return
  end
  local close = GrowUtils.ApplyOperation(operateId)
  if close then
    self.m_base:DestroyPanel()
  end
end
def.method().LocateFocusTab = function(self)
  if self.onShowParams == nil or self.onShowParams.bqType == nil then
    return
  end
  if self.mViewData == nil then
    return
  end
  local bqType = self.onShowParams.bqType
  for i, v in ipairs(self.mViewData) do
    if v.bqType == bqType then
      self.mCurTab = i
      break
    end
  end
end
def.method().UpdateFightValueInfo = function(self)
  local Label_PowerNow = self.mUiObjs.Group_PowerGrade:FindDirect("Label_PowerNow")
  local Label_Lv = self.mUiObjs.Group_PowerGrade:FindDirect("Label_Lv")
  local Label_PowerRecommend = self.mUiObjs.Group_PowerGrade:FindDirect("Label_PowerRecommend")
  local Label_PowerGrade = self.mUiObjs.Group_PowerGrade:FindDirect("Label_PowerGrade")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local gradeCfg = GrowUtils.GetFightValueGrade(heroProp.level, heroProp.fightValue)
  GUIUtils.SetText(Label_PowerNow, heroProp.fightValue)
  GUIUtils.SetText(Label_Lv, heroProp.level)
  GUIUtils.SetText(Label_PowerRecommend, gradeCfg.recommend)
  GUIUtils.SetText(Label_PowerGrade, gradeCfg.gradeName)
end
def.static("table", "table").OnRoleLvUp = function()
  instance:UpdateFightValueInfo()
end
def.static("table", "table").OnFightValueChanged = function()
  instance:UpdateFightValueInfo()
end
BianqiangNode.Commit()
return BianqiangNode
