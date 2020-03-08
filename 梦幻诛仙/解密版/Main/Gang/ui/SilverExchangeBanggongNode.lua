local Lplus = require("Lplus")
local ExchangeBanggongNodeBase = require("Main.Gang.ui.ExchangeBanggongNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local SilverExchangeBanggongNode = Lplus.Extend(ExchangeBanggongNodeBase, "SilverExchangeBanggongNode")
local def = SilverExchangeBanggongNode.define
local GUIUtils = require("GUI.GUIUtils")
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local MallPanel = require("Main.Mall.ui.MallPanel")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local GangData = require("Main.Gang.data.GangData")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
def.field("table").m_exchangeList = nil
def.override().OnShow = function(self)
  self:InitExchangeInfo()
  self:UpdateInfo()
end
def.override().OnHide = function(self)
  self.m_exchangeList = nil
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Btn_Dui1_") == "Btn_Dui1_" then
    local index = tonumber(string.sub(id, #"Btn_Dui1_" + 1, -1))
    self:OnExchangeClick(index)
  end
end
def.method().InitExchangeInfo = function(self)
  self.m_exchangeList = GangUtility.GetAllSilverExchangeBangGongCfgs()
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:UpdateBasic()
end
def.method().UpdateTitle = function(self)
  local max = GangUtility.GetGangConsts("SILVER2BANGGONG_LIMIT")
  local have = GangData.Instance():GetRedeemBangGong()
  local leftExchangeNum = max - have
  self.m_base:SetLeftExchangeNum(leftExchangeNum)
end
def.method().UpdateBasic = function(self)
  local exchangeAmount = #self.m_exchangeList
  local List_Exchange = self.m_panel:FindDirect("Img_Bg/List"):GetComponent("UIList")
  List_Exchange:set_itemCount(exchangeAmount)
  List_Exchange:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not List_Exchange.isnil then
      List_Exchange:Reposition()
    end
  end)
  local exchanges = List_Exchange:get_children()
  for i = 1, exchangeAmount do
    local exchangeUI = exchanges[i]
    local exchangeInfo = self.m_exchangeList[i]
    self:FillExchangeDetial(exchangeUI, i, exchangeInfo)
  end
end
def.method("userdata", "number", "table").FillExchangeDetial = function(self, ui, index, exchangeInfo)
  local Img_BgNum1 = ui:FindDirect(string.format("Img_BgNum1_%d", index))
  local Label_Num1 = Img_BgNum1:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  local Img_Currency = Img_BgNum1:FindDirect(string.format("Img_Silver_%d", index))
  local Img_BgNum2 = ui:FindDirect(string.format("Img_BgNum2_%d", index))
  local Label_Num2 = Img_BgNum2:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  Label_Num1:set_text(exchangeInfo.costSilver)
  Label_Num2:set_text(exchangeInfo.redeemBangGong)
  local sprtieName = CurrencyFactory.GetInstance(MoneyType.SILVER):GetSpriteName()
  GUIUtils.SetSprite(Img_Currency, sprtieName)
end
def.method("number").OnExchangeClick = function(self, index)
  local exchangeInfo = self.m_exchangeList[index]
  local max = GangUtility.GetGangConsts("SILVER2BANGGONG_LIMIT")
  local hasExchange = GangData.Instance():GetRedeemBangGong()
  local canExchange = max - hasExchange
  if canExchange < exchangeInfo.redeemBangGong then
    Toast(string.format(textRes.Gang[109], canExchange))
    return
  end
  local need = exchangeInfo.costSilver
  local have = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  if Int64.lt(have, need) then
    CommonConfirmDlg.ShowConfirm("", textRes.Equip[51], function(s)
      if s == 1 then
        GoToBuySilver(false)
      end
    end, nil)
  else
    if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
      local ECMSDK = require("ProxySDK.ECMSDK")
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.GANGEXCHANGE, {index})
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CSilver2banggongReq").new(exchangeInfo.id))
  end
end
def.override("table", "table").OnExchangeBanggongChanged = function(self, params, tbl)
  self:UpdateTitle()
end
return SilverExchangeBanggongNode.Commit()
