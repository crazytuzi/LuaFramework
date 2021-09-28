TiantingExit2 = class("TiantingExit2", CcsSubView)
function TiantingExit2:ctor(eventId)
  TiantingExit2.super.ctor(self, "views/tianting2.csb", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_level = {
      listener = handler(self, self.OnBtn_LeveWithAward),
      variName = "btn_level"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.txt_times = self:getNode("txt_times")
  self.txt_exp = self:getNode("txt_exp")
  self.rewards = self:getNode("rewards")
  local cur, sum = activity.tianting:getTimes()
  self.txt_times:setText(string.format("%d/%d", cur, sum))
  local exp = activity.tianting:getTotalExp()
  self.txt_exp:setText(string.format("%d", exp))
  local item = createClickItem({
    itemID = activity.tianting.awardObjId,
    autoSize = nil,
    num = activity.tianting.awardCount,
    LongPressTime = 0.5,
    clickListener = nil,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = nil
  })
  self.rewards:getParent():addChild(item, 10)
  local btnX, btnY = self.btn_level:getPosition()
  local btnSize = self.btn_level:getSize()
  local rewardTxtX, rewardTxtY = self.rewards:getPosition()
  local rewardTxtSize = self.rewards:getSize()
  local itemSize = item:getSize()
  item:setPosition(ccp(btnX - itemSize.width / 2, (btnY + btnSize.height / 2 + rewardTxtY - rewardTxtSize.height / 2) / 2 - itemSize.height / 2))
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_MapScene)
end
function TiantingExit2:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_ExitTianting then
    self:CloseSelf()
  elseif msgSID == MsgID_MapScene_ChangedMap then
    self:CloseSelf()
  end
end
function TiantingExit2:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function TiantingExit2:OnBtn_LeveWithAward(btnObj, touchType)
  print("OnBtn_LeveWithAward---->>")
  self:CloseSelf()
  activity.tianting:reqLeave(2)
end
