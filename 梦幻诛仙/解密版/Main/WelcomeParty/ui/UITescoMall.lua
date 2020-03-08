local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UITescoMall = Lplus.Extend(ECPanelBase, "UITescoMall")
local def = UITescoMall.define
local instance
local WelcomePartyModule = require("Main.WelcomeParty.WelcomePartyModule")
local WelcomePartyUtils = require("Main.WelcomeParty.WelcomePartyUtils")
local TescoMallMgr = require("Main.WelcomeParty.TescoMallMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.WelcomeParty
local const = constant.LeGouShangChengConsts
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._goodsList = nil
def.field("table")._cfg2BuyCount = nil
def.static("=>", UITescoMall).Instance = function()
  if instance == nil then
    instance = UITescoMall()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiStatus = {}
  self._uiStatus.bGotBuyInfo = true
  self._cfg2BuyCount = TescoMallMgr.GetBougthGoods()
  TescoMallMgr.SetShowRedDot(false)
  Event.RegisterEventWithContext(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.BuyGoodsFailed, UITescoMall.OnBuyFailed, self)
  Event.RegisterEventWithContext(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.BuyGoodsSuccess, UITescoMall.OnBuyGoodsSuccess, self)
  self:_initUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.BuyGoodsFailed, UITescoMall.OnBuyFailed)
  Event.UnregisterEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.BuyGoodsSuccess, UITescoMall.OnBuyGoodsSuccess)
  self._uiGOs = nil
  self._uiStatus = nil
  self._goodsList = nil
  self._cfg2BuyCount = nil
end
def.method()._initUI = function(self)
  self._uiGOs = {}
  self._uiGOs.GroupBuy = self.m_panel:FindDirect("Group_Buy")
end
def.method()._updateUIGoodsList = function(self)
  local ctrlScrollView = self._uiGOs.GroupBuy:FindDirect("Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("Group_Items")
  if self._goodsList == nil then
    self._goodsList = WelcomePartyUtils.LoadAllGoodsCfg()
  end
  local goodsList = self._goodsList or {}
  local numGoods = #goodsList
  if not self._uiStatus.bGotBuyInfo then
    numGoods = 0
  end
  local ctrlGoods = GUIUtils.InitUIList(ctrlUIList, numGoods)
  self._uiStatus.ctrlGoods = ctrlGoods
  for i = 1, numGoods do
    self:_fillGoodsInfo(ctrlGoods[i], goodsList[i], i)
  end
end
def.method("number", "=>", "table").GetAwardCfg = function(self, awardId)
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
  return ItemUtils.GetGiftAwardCfg(key)
end
def.method("userdata", "table", "number")._fillGoodsInfo = function(self, item, goodsInfo, idx)
  local Btn_Buy = item:FindDirect("Btn_Buy_" .. idx)
  local Btn_NoItem = item:FindDirect("Btn_NoItem_" .. idx)
  local Label_Limit = item:FindDirect("Label_Limit_" .. idx)
  local Bg_Item = item:FindDirect("Bg_Item_" .. idx)
  local Label_Num = Bg_Item:FindDirect("Label_Num_" .. idx)
  local Texture = Bg_Item:FindDirect("Texture_" .. idx)
  local Img_Zhe = item:FindDirect("Img_Zhe_" .. idx)
  local Label_Zhe = Img_Zhe:FindDirect("Label_" .. idx)
  if goodsInfo == nil then
    item:SetActive(false)
    return
  end
  local awardCfg = self:GetAwardCfg(goodsInfo.fixAwardId)
  if awardCfg == nil then
    item:SetActive(false)
    return
  end
  local awardItemInfo = awardCfg.itemList[1] or nil
  goodsInfo.itemId = awardItemInfo.itemId
  if awardItemInfo ~= nil then
    local itemBase = ItemUtils.GetItemBase(awardItemInfo.itemId)
    GUIUtils.FillIcon(Texture:GetComponent("UITexture"), itemBase.icon)
    GUIUtils.SetText(Label_Num, awardItemInfo.num)
  else
    GUIUtils.FillIcon(Texture:GetComponent("UITexture"), 0)
    GUIUtils.SetText(Label_Num, 0)
  end
  if goodsInfo.bShowDiscount and 0 < goodsInfo.discount then
    GUIUtils.SetText(Label_Zhe, txtConst[3]:format(goodsInfo.discount / 10000 * 10))
  else
    GUIUtils.SetText(Label_Zhe, txtConst[1])
  end
  local iHasBuyNum = self._cfg2BuyCount[goodsInfo.id] or 0
  GUIUtils.SetText(Label_Limit, txtConst[2]:format(iHasBuyNum, goodsInfo.buyLimit))
  if awardItemInfo ~= nil and iHasBuyNum < goodsInfo.buyLimit then
    Btn_Buy:SetActive(true)
    Btn_NoItem:SetActive(false)
    local Label_NewNum = Btn_Buy:FindDirect("Label_NewNum_" .. idx)
    local Label_OldNum = Btn_Buy:FindDirect("Label_OldNum_" .. idx)
    local Img_Money = Btn_Buy:FindDirect("Img_Money_" .. idx)
    GUIUtils.SetText(Label_OldNum, goodsInfo.price)
    local newPrice = math.floor(goodsInfo.price * goodsInfo.discount / 10000)
    if newPrice > 0 then
      GUIUtils.SetText(Label_NewNum, newPrice)
    else
      GUIUtils.SetText(Label_NewNum, txtConst[1])
    end
    local CurrencyFactory = require("Main.Currency.CurrencyFactory")
    local moneyData = CurrencyFactory.Create(goodsInfo.moneyType)
    GUIUtils.SetSprite(Img_Money, moneyData:GetSpriteName())
  else
    Btn_Buy:SetActive(false)
    Btn_NoItem:SetActive(true)
  end
end
def.method()._updateUIActDate = function(self)
  local lblTime = self._uiGOs.GroupBuy:FindDirect("Label_Time")
  local startSrvTime = require("Main.Server.ServerModule").Instance():GetOpenServerStartDayTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local stblTime = AbsoluteTimer.GetServerTimeTable(startSrvTime)
  local etblTime = AbsoluteTimer.GetServerTimeTable(startSrvTime + (const.dayCount - 1) * 24 * 3600)
  GUIUtils.SetText(lblTime, txtConst[7]:format(stblTime.year, stblTime.month, stblTime.day, etblTime.year, etblTime.month, etblTime.day))
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:_updateUIGoodsList()
    self:_updateUIActDate()
  end
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_TESCO_MALL, 0)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("Tesco click id", id)
  if string.find(id, "Btn_Buy_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self._uiStatus.buyGoodsCfg = self._goodsList[idx]
    self._uiStatus.selectIdx = idx
    self:OnClickBtnBuy(idx)
  elseif string.find(id, "Texture_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[2])
    local goodsInfo = self._goodsList[idx]
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(goodsInfo.itemId, clickObj, 0, false)
  end
end
def.method("number").OnClickBtnBuy = function(self, idx)
  local cfg = self._uiStatus.buyGoodsCfg
  if cfg ~= nil then
    do
      local owndMoney = WelcomePartyUtils.GetMoneyNumByType(cfg.moneyType)
      local price = cfg.price
      if cfg.bShowDiscount then
        price = math.floor(cfg.price * cfg.discount / 10000)
      end
      local moneyData = require("Main.Currency.CurrencyFactory").Create(cfg.moneyType)
      local awardCfg = self:GetAwardCfg(cfg.fixAwardId)
      local itemBase = ItemUtils.GetItemBase(awardCfg.itemList[1].itemId)
      local strContent = txtConst[8]:format(price, moneyData:GetName(), itemBase.name)
      CommonConfirmDlg.ShowConfirm(txtConst[9], strContent, function(select)
        if select == 1 then
          if Int64.lt(owndMoney, price) then
            WelcomePartyUtils.GotoBuyMoney(cfg.moneyType, true)
            return
          end
          WelcomePartyModule.GetProtocols().SendBuyTescoGoodsReq(cfg.id)
        end
      end, nil)
    end
  end
end
def.method("table").OnBuyFailed = function(self, p)
  if p.type == 3 and self._uiStatus.buyGoodsCfg ~= nil then
    WelcomePartyUtils.GotoBuyMoney(self._uiStatus.moneyType)
  end
end
def.method("table").OnQueryBuyInfoRes = function(self, p)
  self._cfg2BuyCount = p
  self._uiStatus.bGotBuyInfo = true
  if not self:IsShow() then
    return
  end
  self:_updateUIGoodsList()
end
def.method("table").OnBuyGoodsSuccess = function(self, p)
  TescoMallMgr.Instance()._bSaleOut = nil
  self._cfg2BuyCount = self._cfg2BuyCount or {}
  self._cfg2BuyCount[p.cfgId or 0] = p.buyCount or 0
  if not self:IsShow() then
    return
  end
  if self._uiStatus.ctrlGoods then
    local idx = self._uiStatus.selectIdx
    self:_fillGoodsInfo(self._uiStatus.ctrlGoods[idx], self._uiStatus.buyGoodsCfg, idx)
  end
end
return UITescoMall.Commit()
