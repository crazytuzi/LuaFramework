local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local MonthCardNode = Lplus.Extend(AwardPanelNodeBase, "MonthCardNode")
local ProductServiceType = require("consts.mzm.gsp.qingfu.confbean.ProductServiceType")
local MonthCardMgr = require("Main.Award.mgr.MonthCardMgr")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local PayNode = require("Main.Pay.ui.PayNode")
local PayData = require("Main.Pay.PayData")
local PayModule = require("Main.Pay.PayModule")
local def = MonthCardNode.define
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local showHighActivity = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  if _G.IsEfunVersion() and _G.platform == _G.Platform.ios then
    local buyBtn = self.m_node:FindDirect("Btn_Buy")
    buyBtn:SetActive(false)
  end
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_MONTH_CARD, MonthCardNode.OnUpdateUI)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_MONTH_CARD, MonthCardNode.OnUpdateUI)
end
def.override("=>", "boolean").IsOpen = function(self)
  if GameUtil.IsEvaluation() then
    return false
  end
  return MonthCardMgr.Instance():IsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Buy" then
    self:buy()
  elseif id == "Btn_Achieve" then
    self:archieve()
  elseif id == "Btn_Tips" then
    self:showtips()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return MonthCardMgr.Instance():IsHaveNotifyMessage()
end
def.override().InitUI = function(self)
  self.awardType = GiftType.GROW_FUND_AWARD
end
def.method().showtips = function(self)
  if self.m_node == nil then
    return
  end
  local monthCardInfo = MonthCardMgr.Instance():GetMonthCardInfo()
  if monthCardInfo == nil then
    return
  end
  for k, v in pairs(monthCardInfo) do
    local monthCardCfg = MonthCardMgr.GetMonthCardCfg(k, v.phase)
    if nil ~= monthCardCfg then
      require("GUI.CommonUITipsDlg").ShowCommonTip(monthCardCfg.tips, {x = 0, y = 0})
      break
    end
  end
end
def.method().archieve = function(self)
  local monthCardInfo = MonthCardMgr.Instance():GetMonthCardInfo()
  if monthCardInfo == nil then
    return
  end
  for k, v in pairs(monthCardInfo) do
    if v.status == require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo").STATUS_TODAY_NOT_AWARDED then
      if MonthCardMgr.Instance():IsOpenMonthCardPhase(k, v.phase) then
        do
          local req = require("netio.protocol.mzm.gsp.qingfu.CGetMonthCardActivityAward").new(k)
          gmodule.network.sendProtocol(req)
          warn("----------getMonthCardAward:", k)
        end
        break
      end
      Toast(textRes.Award[110])
      break
    end
  end
end
def.method().buy = function(self)
  local monthCardInfo = MonthCardMgr.Instance():GetMonthCardInfo()
  if monthCardInfo == nil then
    return
  end
  PayModule.Instance():SetPayTLogData(_G.TLOGTYPE.HALFMONTH, {})
  for k, v in pairs(monthCardInfo) do
    if v.status == require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo").STATUS_NOT_PURCHASE then
      if not MonthCardMgr.Instance():IsOpenMonthCardPhase(k, v.phase) then
        Toast(textRes.Award[110])
        return
      end
      if _G.IsEfunVersion() and _G.platform == _G.Platform.ios then
        local url = require("Main.Common.URLBtnHelper").GetURLByCfgId(347508005)
        warn("-----------monthCard url:", url)
        if url then
          Application.OpenURL(url)
        else
          warn("!!!!!!error url cfg id:", 347508005)
        end
        return
      end
      local monthCardCfg = MonthCardMgr.GetMonthCardCfg(k, v.phase)
      if monthCardCfg ~= nil then
        local cfgData = PayData.GetQingFuCfgByServerId(monthCardCfg.serviceId)
        if cfgData ~= nil and cfgData[1] then
          PayModule.Pay(cfgData[1])
          self.m_node:FindDirect("Btn_Buy"):GetComponent("UIButton"):set_isEnabled(false)
          return
        end
      else
        warn("---------monthCardCfg is nil:", k)
      end
    end
  end
end
def.method().UpdateUI = function(self)
  if self.m_node == nil then
    return
  end
  if _G.platform == 1 then
    showHighActivity = true
  end
  local monthCardInfo = MonthCardMgr.Instance():GetMonthCardInfo()
  if monthCardInfo == nil then
    return
  end
  self.m_node:FindDirect("Label_NotBuy"):SetActive(false)
  for k, v in pairs(monthCardInfo) do
    local monthCardCfg = MonthCardMgr.GetMonthCardCfg(k, v.phase)
    local backgroundRes = self.m_node:FindDirect("Texture")
    local backgroundResTexture = backgroundRes:GetComponent("UITexture")
    GUIUtils.FillIcon(backgroundResTexture, monthCardCfg.res_background)
    if v.status == require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo").STATUS_NOT_PURCHASE then
      self.m_node:FindDirect("Btn_Buy"):SetActive(true)
      self.m_node:FindDirect("Btn_Buy"):GetComponent("UIButton"):set_isEnabled(true)
      self.m_node:FindDirect("Img_Achieved"):SetActive(false)
      self.m_node:FindDirect("Btn_Achieve"):SetActive(false)
      self.m_node:FindDirect("Label_Countdown"):SetActive(false)
      self.m_node:FindDirect("Label_Deadline"):SetActive(false)
      self.m_node:FindDirect("Img_NotBuy"):SetActive(true)
      self.m_node:FindDirect("Img_Countdown"):SetActive(false)
      do
        local priceRes, ruleRes
        if showHighActivity == false then
          priceRes = self.m_node:FindDirect("Img_NotBuy/Texture_Android")
          ruleRes = self.m_node:FindDirect("Group_TipsInfo/Texture_Android")
          self.m_node:FindDirect("Img_NotBuy/Texture_Android"):SetActive(true)
          self.m_node:FindDirect("Img_NotBuy/Texture_IOS"):SetActive(false)
          self.m_node:FindDirect("Group_TipsInfo/Texture_Android"):SetActive(true)
          self.m_node:FindDirect("Group_TipsInfo/Texture_IOS"):SetActive(false)
        else
          priceRes = self.m_node:FindDirect("Img_NotBuy/Texture_IOS")
          ruleRes = self.m_node:FindDirect("Group_TipsInfo/Texture_IOS")
          self.m_node:FindDirect("Img_NotBuy/Texture_Android"):SetActive(false)
          self.m_node:FindDirect("Img_NotBuy/Texture_IOS"):SetActive(true)
          self.m_node:FindDirect("Group_TipsInfo/Texture_Android"):SetActive(false)
          self.m_node:FindDirect("Group_TipsInfo/Texture_IOS"):SetActive(true)
        end
        local priceResTexture = priceRes:GetComponent("UITexture")
        GUIUtils.FillIcon(priceResTexture, monthCardCfg.res_price)
        local ruleResTexture = ruleRes:GetComponent("UITexture")
        GUIUtils.FillIcon(ruleResTexture, monthCardCfg.res_rule)
      end
      break
    end
    self.m_node:FindDirect("Btn_Buy"):SetActive(false)
    self.m_node:FindDirect("Btn_Achieve"):SetActive(true)
    self.m_node:FindDirect("Img_Countdown"):SetActive(true)
    self.m_node:FindDirect("Img_NotBuy"):SetActive(false)
    if v.status == require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo").STATUS_TODAY_NOT_AWARDED then
      self.m_node:FindDirect("Btn_Achieve/Label"):GetComponent("UILabel"):set_text(textRes.Award[62])
      self.m_node:FindDirect("Img_Achieved"):SetActive(false)
      self.m_node:FindDirect("Btn_Achieve"):SetActive(true)
    else
      self.m_node:FindDirect("Btn_Achieve/Label"):GetComponent("UILabel"):set_text(textRes.Award[63])
      self.m_node:FindDirect("Btn_Achieve"):SetActive(false)
      self.m_node:FindDirect("Img_Achieved"):SetActive(true)
    end
    self.m_node:FindDirect("Label_NotBuy"):SetActive(false)
    self.m_node:FindDirect("Label_Countdown"):SetActive(true)
    self.m_node:FindDirect("Label_Countdown"):GetComponent("UILabel"):set_text(string.format(textRes.Award[64], v.remain_days))
    self.m_node:FindDirect("Label_Deadline"):SetActive(true)
    do
      local nowSecond = _G.GetServerTime()
      local oneday = 86400
      local endTime = nowSecond + oneday * (v.remain_days - 1)
      local endYear = tonumber(os.date("%y", endTime))
      local endMonth = tonumber(os.date("%m", endTime))
      local endDay = tonumber(os.date("%d", endTime))
      if endYear < 100 then
        endYear = endYear + 2000
      end
      local str = string.format("%d.%02d.%02d", endYear, endMonth, endDay)
      self.m_node:FindDirect("Label_Deadline"):GetComponent("UILabel"):set_text(string.format(textRes.Award[65], str))
      local ruleRes
      if showHighActivity == false then
        ruleRes = self.m_node:FindDirect("Group_TipsInfo/Texture_Android")
        self.m_node:FindDirect("Group_TipsInfo/Texture_Android"):SetActive(true)
        self.m_node:FindDirect("Group_TipsInfo/Texture_IOS"):SetActive(false)
      else
        ruleRes = self.m_node:FindDirect("Group_TipsInfo/Texture_IOS")
        self.m_node:FindDirect("Group_TipsInfo/Texture_Android"):SetActive(false)
        self.m_node:FindDirect("Group_TipsInfo/Texture_IOS"):SetActive(true)
      end
      local ruleResTexture = ruleRes:GetComponent("UITexture")
      GUIUtils.FillIcon(ruleResTexture, monthCardCfg.res_rule)
    end
    break
  end
end
def.static("table", "table").OnUpdateUI = function(params)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  local instance = AwardPanel.Instance().nodes[AwardPanel.NodeId.MonthCard]
  instance:UpdateUI()
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
return MonthCardNode.Commit()
