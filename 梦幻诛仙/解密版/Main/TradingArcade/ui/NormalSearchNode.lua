local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchPanelTabNodeBase = require("Main.TradingArcade.ui.SearchPanelTabNodeBase")
local NormalSearchNode = Lplus.Extend(SearchPanelTabNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SearchMgr = require("Main.TradingArcade.SearchMgr")
local TradingArcadeNode = require("Main.TradingArcade.ui.TradingArcadeNode")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local def = NormalSearchNode.define
local instance
def.static("=>", NormalSearchNode).Instance = function(self)
  if instance == nil then
    instance = NormalSearchNode()
  end
  return instance
end
def.field("table").m_UIGOs = nil
def.field("table").m_results = nil
def.field("number").m_targetNode = 0
def.field("table").m_searchHistorys = nil
def.field("string").m_lastSearchName = ""
def.override().OnShow = function(self)
  self:InitUI()
  self.m_targetNode = self.m_base.params.nodeId
  self:UpdateNodeToggle()
  self:UpdateSearchHistorys()
  self:SetInputValue(self.m_lastSearchName)
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  self.m_results = nil
  self.m_searchHistorys = nil
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Search" then
    self:OnSearchBtnClick()
  elseif id == "Btn_OnSell" then
    self:OnToggleOnSell()
  elseif id == "Btn_Public" then
    self:OnTogglePublic()
  elseif string.find(id, "Img_Bg_History_") then
    local index = tonumber(string.sub(id, #"Img_Bg_History_" + 1, -1))
    self:SelectSearchHistory(index)
  end
end
def.override("string", "userdata").onSubmit = function(self, id, ctrl)
  print("onSubmit", id, ctrl)
  if id == "Img_InputBg" then
    self:SubmitInput()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_InputBg = self.m_node:FindDirect("Img_InputBg")
  self.m_UIGOs.Group_SellStatus = self.m_node:FindDirect("Group_SellStatus")
  self.m_UIGOs.Btn_OnSell = self.m_UIGOs.Group_SellStatus:FindDirect("Btn_OnSell")
  self.m_UIGOs.Btn_OnSell.name = "Btn_OnSell_"
  self.m_UIGOs.Btn_Public = self.m_UIGOs.Group_SellStatus:FindDirect("Btn_OnSell")
  if self.m_UIGOs.Btn_Public == nil then
    self.m_UIGOs.Btn_Public = self.m_UIGOs.Group_SellStatus:FindDirect("Btn_Public")
  end
  self.m_UIGOs.Btn_Public.name = "Btn_Public"
  self.m_UIGOs.Btn_OnSell.name = "Btn_OnSell"
  self.m_UIGOs.List_History = self.m_node:FindDirect("Scroll View/List")
end
def.method("=>", "string").GetInputtedValue = function(self)
  local uiInput = self.m_UIGOs.Img_InputBg:GetComponent("UIInput")
  return uiInput.value
end
def.method("string").SetInputValue = function(self, value)
  local uiInput = self.m_UIGOs.Img_InputBg:GetComponent("UIInput")
  uiInput.value = value
  self.m_lastSearchName = value
end
def.method().SubmitInput = function(self)
  local searchName = self:GetInputtedValue()
  if searchName == "" then
    return
  end
  local results = SearchMgr.Instance():SearchByName(searchName)
  if #results > 0 then
    self:ShowCandidateResults(results)
  end
end
def.method("table").ShowCandidateResults = function(self, results)
  self.m_results = results
  self.m_bigPopupClickHandler = self.SelectCandidate
  self.m_base:SetBigPopupItems(#results, function(index)
    local name = results[index].name
    return {name = name}
  end)
end
def.method("number").SelectCandidate = function(self, index)
  local result = self.m_results[index]
  self:SetInputValue(result.name)
  self:TurnToSearchResult(result)
end
def.override().OnSearchBtnClick = function(self)
  local value = self:GetInputtedValue()
  if value == "" then
    Toast(textRes.TradingArcade[208])
    return
  end
  local results = SearchMgr.Instance():SearchByName(value)
  if #results == 0 then
    Toast(textRes.TradingArcade[209])
    return
  end
  local result = results[1]
  if result.name ~= value then
    self:ShowCandidateResults(results)
    return
  end
  self:TurnToSearchResult(result)
end
def.method("table").TurnToSearchResult = function(self, result)
  SearchMgr.Instance():AddToSearchHistory(result)
  local nodeId = self.m_targetNode
  require("Main.TradingArcade.ui.TradingArcadeNode").Instance():OpenSubTypePage(nodeId, result.subid, result.level)
  self.m_base:DestroyPanel()
end
def.method().UpdateNodeToggle = function(self)
  if self.m_targetNode == TradingArcadeNode.NodeId.PUBLIC then
    GUIUtils.Toggle(self.m_UIGOs.Btn_Public, true)
  else
    GUIUtils.Toggle(self.m_UIGOs.Btn_OnSell, true)
  end
end
def.method().OnToggleOnSell = function(self)
  self.m_targetNode = TradingArcadeNode.NodeId.BUY
end
def.method().OnTogglePublic = function(self)
  self.m_targetNode = TradingArcadeNode.NodeId.PUBLIC
end
def.method().UpdateSearchHistorys = function(self)
  self.m_searchHistorys = SearchMgr.Instance():GetSearchHistorys()
  self:SetSearchHistorys(self.m_searchHistorys)
end
def.method("table").SetSearchHistorys = function(self, historys)
  local uiList = self.m_UIGOs.List_History:GetComponent("UIList")
  local itemCount = #historys
  uiList.itemCount = #historys
  uiList:Resize()
  uiList:Reposition()
  local itemObjs = uiList.children
  for i = 1, itemCount do
    local itemObj = itemObjs[i]
    local index = itemCount - i + 1
    self:SetHistorySearchResult(index, itemObj, historys[index])
  end
  self.m_base.m_msgHandler:Touch(self.m_UIGOs.List_History)
end
def.method("number", "userdata", "table").SetHistorySearchResult = function(self, index, itemObj, result)
  local Img_Bg = itemObj:FindDirect("Img_Bg0")
  if Img_Bg == nil then
    Img_Bg = itemObj:FindDirect("Img_Bg_History_" .. index)
  else
    Img_Bg.name = "Img_Bg_History_" .. index
  end
  local Label = Img_Bg:FindDirect("Label")
  GUIUtils.SetText(Label, result.name)
  local cfg = TradingArcadeUtils.GetMarketSubTypeCfg(result.subid)
  local iconId = cfg and cfg.iconId or 0
  local Img_Icon = Img_Bg:FindDirect("Img_Kuang/Img_Icon")
  GUIUtils.SetTexture(Img_Icon, iconId)
end
def.method("number").SelectSearchHistory = function(self, index)
  local searchHistory = self.m_searchHistorys[index]
  if searchHistory == nil then
    return
  end
  self:SetInputValue(searchHistory.name)
end
return NormalSearchNode.Commit()
