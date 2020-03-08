local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local SearchPanelTabNodeBase = Lplus.Extend(TabNode, MODULE_NAME)
local SearchBase = require("Main.TradingArcade.SearchBase")
local TradingArcadeNode = require("Main.TradingArcade.ui.TradingArcadeNode")
local def = SearchPanelTabNodeBase.define
def.field("function").m_bigPopupClickHandler = nil
def.field("function").m_smallPopupClickHandler = nil
def.field("dynamic").m_customizeType = nil
def.virtual().OnRestBtnClick = function(self)
end
def.virtual().OnSearchBtnClick = function(self)
end
def.virtual().OnCustomizeBtnClick = function(self)
end
def.virtual().OnMyCustomizationBtnClick = function(self)
end
def.virtual("number").OnBigPopupItemClick = function(self, index)
  if self.m_bigPopupClickHandler then
    self:m_bigPopupClickHandler(index)
  end
end
def.virtual("number").OnSmallPopupItemClick = function(self, index)
  if self.m_smallPopupClickHandler then
    self:m_smallPopupClickHandler(index)
  end
end
def.virtual("=>", "number").GetSearchState = function(self)
  local targetNode = self.m_base.params.nodeId
  local state
  if targetNode == TradingArcadeNode.NodeId.PUBLIC then
    state = SearchBase.State.Public
  else
    state = SearchBase.State.OnSell
  end
  return state
end
def.method("table", "table").InvokeSearch = function(self, searchMgr, condition)
  require("Main.TradingArcade.SearchMgr").Instance():SetCurSearchMgr(searchMgr)
  searchMgr:SetSearchCondition(condition)
  local targetNode = self.m_base.params.nodeId
  TradingArcadeNode.Instance():SetSearchMgr(targetNode, searchMgr)
  TradingArcadeNode.Instance():OpenSubTypePage(targetNode, condition.subid, 0)
  self.m_base:DestroyPanel()
end
def.virtual().UpdateCustomizeNotify = function(self)
  local Btn_MyOrder = self.m_node:FindDirect("Btn_MyOrder")
  if Btn_MyOrder and self.m_customizeType then
    local hasNotify = require("Main.TradingArcade.CustomizedSearchMgr").Instance():HasCustomizeTypeNotify(self.m_customizeType)
    local Img_Red = Btn_MyOrder:FindDirect("Img_Red")
    if Img_Red then
      Img_Red:SetActive(hasNotify)
    end
  end
end
return SearchPanelTabNodeBase.Commit()
