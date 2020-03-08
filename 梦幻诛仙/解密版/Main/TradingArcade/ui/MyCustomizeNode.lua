local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchPanelTabNodeBase = require("Main.TradingArcade.ui.SearchPanelTabNodeBase")
local MyCustomizeNode = Lplus.Extend(SearchPanelTabNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
local def = MyCustomizeNode.define
def.field("table").m_UIGOs = nil
def.field("table").m_customizedSearchs = nil
def.field("number").m_selIndex = 0
local instance
def.static("=>", MyCustomizeNode).Instance = function(self)
  if instance == nil then
    instance = MyCustomizeNode()
  end
  return instance
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, MyCustomizeNode.OnCustomizeListUpdate)
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, MyCustomizeNode.OnCustomizeListUpdate)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg1 = self.m_node:FindDirect("Img_Bg1")
  self.m_UIGOs.Label_OrderNumber = self.m_UIGOs.Img_Bg1:FindDirect("Label_OrderNumber")
  self.m_UIGOs.ScrollView = self.m_UIGOs.Img_Bg1:FindDirect("Scroll View")
  self.m_UIGOs.List_Item1 = self.m_UIGOs.ScrollView:FindDirect("List_Item1")
  local Btn_Item_Customize = self.m_UIGOs.List_Item1:FindDirect("Item1/Btn_Item1")
  if Btn_Item_Customize then
    Btn_Item_Customize.name = "Btn_Item_Customize"
  else
    local Btn_Item_Customize = self.m_UIGOs.List_Item1:FindDirect("Item1/Btn_Item_Customize")
  end
  if Btn_Item_Customize then
    local uiToggle = Btn_Item_Customize:GetComponent("UIToggle")
    if uiToggle then
      uiToggle.group = 10
    end
  end
end
def.method().UpdateUI = function(self)
  self:UpdateCustomizeList()
  self:UpdateCustomizeCapacity()
end
def.method().UpdateCustomizeList = function(self)
  self.m_customizedSearchs = CustomizedSearchMgr.Instance():GetCustomizedSearchs()
  self:SetCustomizeList(self.m_customizedSearchs)
end
def.method("table").SetCustomizeList = function(self, customizeList)
  local uiList = self.m_UIGOs.List_Item1:GetComponent("UIList")
  local count = #customizeList
  if count < self.m_selIndex then
    self.m_selIndex = count
  end
  uiList.itemCount = count
  uiList:Resize()
  self.m_base.m_msgHandler:Touch(self.m_UIGOs.List_Item1)
  local itemObjs = uiList.children
  for i = 1, count do
    local itemObj = itemObjs[i]
    local customizeSearch = customizeList[i]
    self:SetCustomizeSearch(itemObj, customizeSearch, {index = i})
  end
  uiList:Reposition()
  GameUtil.AddGlobalTimer(0, true, function()
    if self.m_UIGOs == nil then
      return
    end
    if uiList.isnil then
      return
    end
    uiList:Reposition()
  end)
end
def.method("userdata", "table", "table").SetCustomizeSearch = function(self, itemObj, customizeSearch, params)
  local Label_Name = itemObj:FindDirect("Label_Name")
  local Label_Status = itemObj:FindDirect("Label_Status")
  local name = customizeSearch:GetDisplayName()
  local desc = customizeSearch:GetConditionDesc()
  GUIUtils.SetText(Label_Name, name)
  GUIUtils.SetText(Label_Status, desc)
  local Btn_Item1 = itemObj:FindDirect("Btn_Item_Customize")
  local isSelected = params.index == self.m_selIndex
  GUIUtils.Toggle(Btn_Item1, isSelected)
  local Img_Red = itemObj:FindDirect("Img_Red")
  local hasNotify = customizeSearch:HasNotify()
  GUIUtils.SetActive(Img_Red, hasNotify)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Check" then
    self:OnCheckBtnClick()
  elseif id == "Btn_Delete" then
    self:OnDeleteBtnClick()
  elseif id == "Btn_Item_Customize" then
    self:OnItemBtnObjClick(clickobj)
  end
end
def.method("userdata").OnItemBtnObjClick = function(self, obj)
  local parent = obj.parent
  local index = tonumber(string.sub(parent.name, #"item_" + 1, -1))
  if index == nil then
    return
  end
  self.m_selIndex = index
end
def.method().OnCheckBtnClick = function(self)
  if self:CheckSelect() == false then
    return
  end
  local customizeSearch = self.m_customizedSearchs[self.m_selIndex]
  customizeSearch:Search()
  customizeSearch:ResetPeriodState()
  self.m_base:DestroyPanel()
end
def.method().OnDeleteBtnClick = function(self)
  if self:CheckSelect() == false then
    return
  end
  local customizedSearch = self.m_customizedSearchs[self.m_selIndex]
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], textRes.TradingArcade[227], function(s)
    if s == 1 then
      CustomizedSearchMgr.Instance():DeleteCustomizedSearchReq(customizedSearch)
    end
  end, tag)
end
def.method("=>", "boolean").CheckSelect = function(self)
  if #self.m_customizedSearchs == 0 then
    Toast(textRes.TradingArcade[223])
    return false
  end
  if self.m_selIndex == 0 then
    Toast(textRes.TradingArcade[224])
    return false
  end
  return true
end
def.method().UpdateCustomizeCapacity = function(self)
  local count = #self.m_customizedSearchs
  local capacity = CustomizedSearchMgr.Instance():GetMaxCustomizedSearchNum()
  local text = string.format("%d/%d", count, capacity)
  GUIUtils.SetText(self.m_UIGOs.Label_OrderNumber, text)
end
def.static("table", "table").OnCustomizeListUpdate = function()
  instance:UpdateUI()
end
return MyCustomizeNode.Commit()
