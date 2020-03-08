local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TradingLogPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local ItemGoodsData = require("Main.TradingArcade.data.ItemGoodsData")
local PetGoodsData = require("Main.TradingArcade.data.PetGoodsData")
local PetUtility = require("Main.Pet.PetUtility")
local Vector = require("Types.Vector")
local def = TradingLogPanel.define
local TabId = {Buy = "Tab_Buy", Sell = "Tab_Sell"}
local instance
local function Instance()
  if instance == nil then
    instance = TradingLogPanel()
  end
  return instance
end
def.field("table").m_uiGOs = nil
def.field("string").m_lastTab = TabId.Buy
def.field("table").m_buyLogs = nil
def.field("table").m_sellLogs = nil
def.static("=>", TradingLogPanel).ShowPanel = function()
  local self = TradingLogPanel()
  self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_LOG, 2)
  self:SetModal(true)
  return self
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  do break end
  do break end
  self:onClick(id)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Sprite" then
    self:DestroyPanel()
  elseif string.find(id, "Tab_") then
    self:ShowTab(id)
  end
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_uiGOs = nil
end
def.method().InitUI = function(self)
  self.m_uiGOs = {}
  self.m_uiGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_uiGOs.Tab_Buy = self.m_uiGOs.Img_Bg0:FindDirect("Tab_Buy")
  self.m_uiGOs.Tab_Sell = self.m_uiGOs.Img_Bg0:FindDirect("Tab_Sell")
  self.m_uiGOs.ScrollView = self.m_uiGOs.Img_Bg0:FindDirect("Scroll View")
  self.m_uiGOs.List = self.m_uiGOs.ScrollView:FindDirect("Grid")
end
def.method().UpdateUI = function(self)
  self:ShowTab(self.m_lastTab)
end
def.method("string").ShowTab = function(self, tabId)
  self.m_lastTab = tabId
  GUIUtils.Toggle(self.m_uiGOs[tabId], true)
  if tabId == TabId.Buy then
    self:ShowBuyTab()
  else
    self:ShowSellTab()
  end
end
def.method().ShowBuyTab = function(self)
  if self.m_buyLogs then
    local viewDatas = self:GetBuyLogViewDatas(self.m_buyLogs)
    self:SetLogList(viewDatas)
  else
    self:SetLogList({})
  end
  local curtimestamp = os.time()
  if self.m_buyLogs == nil or math.abs(curtimestamp - self.m_buyLogs.timestamp) > 30 then
    TradingArcadeProtocol.CGetBuyLogReq(function(buyLogs)
      self.m_buyLogs = buyLogs
      self.m_buyLogs.timestamp = os.time()
      local viewDatas = self:GetBuyLogViewDatas(self.m_buyLogs)
      self:SetLogList(viewDatas)
    end)
  end
end
def.method().ShowSellTab = function(self)
  if self.m_sellLogs then
    local viewDatas = self:GetSellLogViewDatas(self.m_sellLogs)
    self:SetLogList(viewDatas)
  else
    self:SetLogList({})
  end
  local curtimestamp = os.time()
  if self.m_sellLogs == nil or math.abs(curtimestamp - self.m_sellLogs.timestamp) > 30 then
    TradingArcadeProtocol.CGetSellLogReq(function(buyLogs)
      self.m_sellLogs = buyLogs
      self.m_sellLogs.timestamp = os.time()
      local viewDatas = self:GetSellLogViewDatas(self.m_sellLogs)
      self:SetLogList(viewDatas)
    end)
  end
end
def.method("table", "=>", "table").GetBuyLogViewDatas = function(self, buyLogs)
  local viewDatas = {}
  for i, v in ipairs(buyLogs) do
    viewDatas[i] = self:GetBuyLogViewData(v)
  end
  return viewDatas
end
def.method("table", "=>", "table").GetBuyLogViewData = function(self, buyLog)
  local viewData = {}
  local convertData = self:ConvertMarketLog(buyLog)
  local sellerName = convertData.roleName
  local timeText = convertData.timeText
  local goodsNameText = convertData.goodsNameText
  local priceText = convertData.priceText
  viewData.desc = string.format(textRes.TradingArcade[300], timeText, priceText, goodsNameText)
  return viewData
end
def.method("table", "=>", "table").GetSellLogViewDatas = function(self, buyLogs)
  local viewDatas = {}
  for i, v in ipairs(buyLogs) do
    viewDatas[i] = self:GetSellLogViewData(v)
  end
  return viewDatas
end
def.method("table", "=>", "table").GetSellLogViewData = function(self, sellLog)
  local viewData = {}
  local convertData = self:ConvertMarketLog(sellLog)
  local purchaserName = convertData.roleName
  local timeText = convertData.timeText
  local goodsNameText = convertData.goodsNameText
  local priceText = convertData.priceText
  viewData.desc = string.format(textRes.TradingArcade[301], goodsNameText, timeText, priceText)
  return viewData
end
def.method("table", "=>", "table").ConvertMarketLog = function(self, marketLog)
  local data = {}
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local t = AbsoluteTimer.GetServerTimeTable(Int64.ToNumber(marketLog.time))
  local timeText = t and string.format(textRes.Common[42], t.year, t.month, t.day) or tostring(marketLog.time)
  marketLog.num = marketLog.num or 1
  local totalPrice = marketLog.num * marketLog.price
  local color = TradingArcadeUtils.GetTradingPriceColor(totalPrice)
  local priceText = string.format("[%s]%s[-]", color, tostring(totalPrice))
  local purchaserName = marketLog.roleName
  local goodsData
  local id = marketLog.itemIdOrPetCfgId
  if PetUtility.IsPetCfgId(id) then
    goodsData = PetGoodsData()
    goodsData.petCfgId = id
  else
    goodsData = ItemGoodsData()
    goodsData.itemId = id
  end
  data.roleName = marketLog.roleName
  data.priceText = priceText
  data.timeText = timeText
  data.goodsNameText = goodsData:GetName()
  return data
end
def.method("table").SetLogList = function(self, logList)
  local uiList = self.m_uiGOs.List:GetComponent("UIList")
  uiList.itemCount = #logList
  uiList:Resize()
  uiList:Reposition()
  local itemObjs = uiList.children
  for i, v in ipairs(logList) do
    local itemObj = itemObjs[i]
    local logInfo = logList[i]
    self:SetLogItemInfo(i, itemObj, logInfo)
  end
  self.m_msgHandler:Touch(uiList.gameObject)
end
def.method("number", "userdata", "table").SetLogItemInfo = function(self, index, itemObj, logInfo)
  local Label_Number = itemObj:FindDirect("Label_Number")
  local Label_Info = itemObj:FindDirect("Label_Info")
  GUIUtils.SetText(Label_Number, index)
  GUIUtils.SetText(Label_Info, logInfo.desc)
end
return TradingLogPanel.Commit()
