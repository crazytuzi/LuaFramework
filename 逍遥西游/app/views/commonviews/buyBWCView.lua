function BuyBWCNumWithGold()
  local player = g_DataMgr:getPlayer()
  local vipLv = player:getVipLv()
  local curBuyNum = g_PvpMgr:getBuyBWCNum()
  local maxBuyNum = data_getMaxBuyBWCNum()
  if curBuyNum >= maxBuyNum then
    ShowNotifyTips("今日的比武次数已用完，重置时间明天5:00")
    return
  end
  CBuyBWCNum.new()
end
CBuyBWCNum = class("CBuyBWCNum", CPopWarning)
function CBuyBWCNum:ctor(para)
  local text, confirmText, cancelText = self:getBuyBWCNumText()
  local para = {
    title = "",
    text = text,
    confirmFunc = function()
      self:BuyBWCNum()
    end,
    cancelFunc = nil,
    closeFunc = nil,
    confirmText = confirmText,
    cancelText = cancelText,
    confirmCloseFlag = false,
    align = CRichText_AlignType_Left,
    zOrder = MainUISceneZOrder.menuView
  }
  CBuyBWCNum.super.ctor(self, para)
  self:updateOnView()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ShowCloseBtn(false)
end
function CBuyBWCNum:getBuyBWCNumText()
  local player = g_DataMgr:getPlayer()
  local vipLv = player:getVipLv()
  local curBuyNum = g_PvpMgr:getBuyBWCNum()
  local todayMaxNum = data_getCurBuyBWCNumByVIP(vipLv)
  local price = data_getBuyBWCPrice(curBuyNum + 1)
  local text, confirmText, cancelText
  if todayMaxNum == 0 then
    local newVIPLv = data_getCanBuyBWCNumVipLv()
    local addGoldNum = g_LocalPlayer:getVipAddGold()
    local needAddGold = math.max(0, data_getVIPNeedGold(newVIPLv) - addGoldNum)
    text = string.format("今日比武次数已用完\n(再充值%d#<IR2>#升级为VIP%d可购买比武次数)\n是否前往充值？", needAddGold, newVIPLv)
    cancelText = "取消"
    confirmText = "确定"
  elseif curBuyNum >= todayMaxNum then
    local newVIPLv = vipLv + 1
    local addGoldNum = g_LocalPlayer:getVipAddGold()
    local needAddGold = math.max(0, data_getVIPNeedGold(newVIPLv) - addGoldNum)
    text = string.format("今日已购买比武场次数%d次,购买次数已用完\n(再充值%d#<IR2>#升级为VIP%d可增加更多次数)\n是否前往充值？", todayMaxNum, needAddGold, newVIPLv)
    cancelText = "取消"
    confirmText = "确定"
  else
    text = string.format("今日比武次数已用完,购买1次需要花费%d#<IR2>#\n是否马上购买？\n（今日已购买%d/%d)", price, curBuyNum, todayMaxNum)
    cancelText = "取消"
    confirmText = "确定"
  end
  return text, confirmText, cancelText
end
function CBuyBWCNum:updateOnView()
  local text, confirmText, cancelText = self:getBuyBWCNumText()
  self:setConfirmBtnText(confirmText)
  self:setCancelBtnText(cancelText)
  self:resetText(text)
end
function CBuyBWCNum:BuyBWCNum()
  local player = g_DataMgr:getPlayer()
  local vipLv = player:getVipLv()
  local curBuyNum = g_PvpMgr:getBuyBWCNum()
  local todayMaxNum = data_getCurBuyBWCNumByVIP(vipLv)
  local price = data_getBuyBWCPrice(curBuyNum + 1)
  local maxBuyNum = data_getMaxBuyBWCNum()
  if curBuyNum >= maxBuyNum then
    ShowNotifyTips("今日的比武次数已用完，重置时间明天5:00")
    return
  end
  if todayMaxNum == 0 then
    local newVIPLv = data_getCanBuyBWCNumVipLv()
    ShowRechargeView({}, newVIPLv)
    return
  end
  if curBuyNum >= todayMaxNum then
    ShowRechargeView({}, vipLv + 1)
    return
  end
  if price > player:getGold() then
    ShowNotifyTips("元宝不足")
    ShowRechargeView({}, vipLv + 1)
    return
  end
  netsend.netpvp.buyBWCNum()
  self:OnClose()
end
function CBuyBWCNum:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_VIPUpdate then
    self:updateOnView()
  end
end
