CDoubleExpView = class("CDoubleExpView", CcsSubView)
function UseDoubleExpItem(itemId)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_DoubleExp)
  if openFlag == false then
    ShowNotifyTips(tips)
    return
  end
  local doubleExpData = g_LocalPlayer:getDoubleExpData()
  local useSBDTimes = doubleExpData.useSBDTimes or 0
  local curVipLv = g_LocalPlayer:getVipLv()
  local addGoldNum = g_LocalPlayer:getVipAddGold()
  if curVipLv >= data_getMaxVIPLv() then
    if useSBDTimes >= data_getCanUseSBDNum(curVipLv) then
      ShowNotifyTips(string.format("你今天使用双倍丹已达到上限%d次", data_getCanUseSBDNum(curVipLv)))
      return
    end
  elseif useSBDTimes >= data_getCanUseSBDNum(curVipLv) then
    local text = string.format("你当前为VIP%d已达到每日使用双倍丹的上限#<Y>%d#次，(再充值%d#<IR2>#升级为VIP%d可增加#<Y>%d#次使用双倍丹的次数)", curVipLv, data_getCanUseSBDNum(curVipLv), math.max(0, data_getVIPNeedGold(curVipLv + 1) - addGoldNum), curVipLv + 1, data_getCanUseSBDNum(curVipLv + 1) - data_getCanUseSBDNum(curVipLv))
    local tempPop = CPopWarning.new({
      title = nil,
      text = text,
      confirmFunc = function()
        ShowRechargeView({}, curVipLv + 1)
      end,
      align = CRichText_AlignType_Left,
      confirmText = "确定",
      cancelText = "取消"
    })
    tempPop:ShowCloseBtn(false)
    return
  end
  local sbdId = itemId or g_LocalPlayer:GetOneItemIdByType(ITEM_DEF_OTHER_SBD)
  if sbdId == nil or sbdId == 0 then
    netsend.netitem.requestUseItemByGold(ITEM_DEF_OTHER_SBD)
    return
  end
  local sbdIns = g_LocalPlayer:GetOneItem(sbdId)
  if sbdIns == nil then
    return
  end
  if sbdIns:getTypeId() ~= ITEM_DEF_OTHER_SBD then
    return
  end
  netsend.netitem.requestUseItem(sbdId)
end
function CDoubleExpView:ctor()
  CDoubleExpView.super.ctor(self, "views/double_exp.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_addDP = {
      listener = handler(self, self.OnBtn_AddDP),
      variName = "btn_addDP"
    },
    btn_1 = {
      listener = handler(self, self.OnBtn_QingLing),
      variName = "btn_qingLing"
    },
    btn_2 = {
      listener = handler(self, self.OnBtn_GetDP),
      variName = "btn_getDP"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:UpdatePoint()
  self:SetBtnText()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CDoubleExpView:UpdatePoint()
  local doubleExpData = g_LocalPlayer:getDoubleExpData()
  local deP = doubleExpData.deP or 0
  local deRestP = doubleExpData.deRestP or 0
  self:getNode("restPoint"):setText(tostring(deRestP))
  self:getNode("hasPoint"):setText(tostring(deP))
end
function CDoubleExpView:SetBtnText()
  local doubleExpData = g_LocalPlayer:getDoubleExpData()
  local deP = doubleExpData.deP or 0
  if deP <= 0 then
    self.btn_qingLing:loadTextureNormal("views/common/btn/btn_4words_disabled.png")
  else
    self.btn_qingLing:loadTextureNormal("views/common/btn/btn_4words.png")
  end
  if deP >= SBD_POINT_MAX_VALUE then
    self.btn_getDP:loadTextureNormal("views/common/btn/btn_4words_disabled.png")
  else
    self.btn_getDP:loadTextureNormal("views/common/btn/btn_4words.png")
  end
end
function CDoubleExpView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CDoubleExpView:OnBtn_QingLing(btnObj, touchType)
  local doubleExpData = g_LocalPlayer:getDoubleExpData()
  local deP = doubleExpData.deP or 0
  if deP <= 0 then
    return
  end
  netsend.netdoubleexp.requestClearDEP()
end
function CDoubleExpView:OnBtn_GetDP(btnObj, touchType)
  local doubleExpData = g_LocalPlayer:getDoubleExpData()
  local deP = doubleExpData.deP or 0
  if deP >= SBD_POINT_MAX_VALUE then
    ShowNotifyTips(string.format("最多只能领取%d点双倍点数", SBD_POINT_MAX_VALUE))
    return
  end
  netsend.netdoubleexp.requestGetDEP()
end
function CDoubleExpView:OnBtn_AddDP(btnObj, touchType)
  UseDoubleExpItem()
end
function CDoubleExpView:OnMessage(msgSID, ...)
  if msgSID == MsgID_DoubleExpUpdate then
    self:UpdatePoint()
    self:SetBtnText()
  end
end
function CDoubleExpView:Clear()
end
