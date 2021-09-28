CLWZBRewardDlg = class("CLWZBRewardDlg", CcsSubView)
function CLWZBRewardDlg:ctor(itemTypeId, itemNum, rewardType)
  CLWZBRewardDlg.super.ctor(self, "views/lwzbreward.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Closed),
      variName = "btn_close"
    },
    btn_get = {
      listener = handler(self, self.Btn_Get),
      variName = "btn_get"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local itempos = self:getNode("itempos")
  itempos:setVisible(false)
  local p = itempos:getParent()
  local x, y = itempos:getPosition()
  local item = createClickItem({itemID = itemTypeId, num = itemNum})
  p:addChild(item)
  item:setPosition(ccp(x, y))
  self.m_RewardType = rewardType
  if self.m_RewardType == 1 then
    self:getNode("title"):setText("首胜礼包")
  elseif self.m_RewardType == 2 then
    self:getNode("title"):setText("五战礼包")
  end
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_Scene)
end
function CLWZBRewardDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_LeiTaiUpdateReward then
    local arg = {
      ...
    }
    local info = arg[1]
    if info.firstwin_bonus == 1 and self.m_RewardType == 1 then
      self:CloseSelf()
    elseif info.fivewin_bonus == 1 and self.m_RewardType == 2 then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_Scene_War_Enter then
    self:CloseSelf()
  end
end
function CLWZBRewardDlg:Btn_Get(obj, objType)
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil and curTime - self.m_LastClickTime < 1 then
    return
  end
  self.m_LastClickTime = curTime
  netsend.netactivity.sendGetLWZBReward(self.m_RewardType)
end
function CLWZBRewardDlg:Btn_Closed(obj, objType)
  self:CloseSelf()
end
function CLWZBRewardDlg:Clear()
end
