finishCountView = class("finishCountView", CcsSubView)
finishCountView.__g_viewIns = nil
function finishCountView:ctor(cancelListener)
  finishCountView.super.ctor(self, "views/event_finish_cnt.csb", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  finishCountView.__g_viewIns = self
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:loadFinishCountData()
  self:ListenMessage(MsgID_Activity)
end
function finishCountView:loadFinishCountData()
  local fontSize = 18
  local fontName = KANG_TTF_FONT
  local finishData, notFinishCount = g_DataMgr:getFinishEventData()
  finishData = finishData or {}
  local scroller = self:getNode("scroller_cnt")
  local orgInnerSize = scroller:getInnerContainerSize()
  local orgInnerWidth = orgInnerSize.width
  local orgInnerHeight = orgInnerSize.height
  local txtWidth = orgInnerWidth - 10
  local firstObjX = 5
  local secondObjX = 190
  local thirdObjX = 257
  local pos_y = 0
  local allTxtIns = {}
  for i, data in ipairs(finishData) do
    local name = data.name
    local cnt = data.cnt
    local limit = data.limit
    local nameTxtIns = CCLabelTTF:create(name, fontName, fontSize)
    nameTxtIns:setHorizontalAlignment(kCCTextAlignmentLeft)
    nameTxtIns:setAnchorPoint(ccp(0, 0))
    nameTxtIns:setColor(ccc3(255, 255, 255))
    scroller:addNode(nameTxtIns)
    allTxtIns[#allTxtIns + 1] = nameTxtIns
    local nameTxtInsSize = nameTxtIns:getContentSize()
    pos_y = pos_y - nameTxtInsSize.height - 5
    nameTxtIns:setPosition(ccp(firstObjX, pos_y))
    local countTxtIns = CCLabelTTF:create(string.format("%d/%d", cnt, limit), fontName, fontSize)
    countTxtIns:setHorizontalAlignment(kCCTextAlignmentLeft)
    countTxtIns:setAnchorPoint(ccp(0, 0))
    countTxtIns:setColor(ccc3(255, 255, 255))
    countTxtIns:setPosition(ccp(secondObjX, pos_y))
    scroller:addNode(countTxtIns)
    allTxtIns[#allTxtIns + 1] = countTxtIns
    if cnt == limit then
      local completeTxtIns = CCLabelTTF:create("(完成)", fontName, fontSize)
      completeTxtIns:setHorizontalAlignment(kCCTextAlignmentLeft)
      completeTxtIns:setAnchorPoint(ccp(0, 0))
      completeTxtIns:setColor(ccc3(0, 255, 0))
      completeTxtIns:setPosition(ccp(thirdObjX, pos_y))
      scroller:addNode(completeTxtIns)
      allTxtIns[#allTxtIns + 1] = completeTxtIns
    end
  end
  pos_y = pos_y - 20
  local realH = -pos_y
  if orgInnerHeight > realH then
    realH = orgInnerHeight
  end
  scroller:setInnerContainerSize(CCSize(orgInnerWidth, realH))
  for i, v in ipairs(allTxtIns) do
    local x, y = v:getPosition()
    v:setPosition(CCPoint(x, y + realH))
  end
end
function finishCountView:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_FinishCountUpdate then
    CloseFinishCountView()
    scheduler.performWithDelayGlobal(function()
      ShowFinishCountView()
    end, 0.001)
  end
end
function finishCountView:OnBtn_Close()
  CloseFinishCountView()
end
function finishCountView:Clear()
  if SafetylockSetPwd.__g_viewIns == self then
    SafetylockSetPwd.__g_viewIns = nil
  end
end
function ShowFinishCountView()
  getCurSceneView():addSubView({
    subView = finishCountView.new(),
    zOrder = MainUISceneZOrder.popSafetylock
  })
end
function CloseFinishCountView()
  if finishCountView.__g_viewIns ~= nil then
    finishCountView.__g_viewIns:CloseSelf()
  end
end
