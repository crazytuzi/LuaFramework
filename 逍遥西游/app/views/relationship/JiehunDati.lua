JiehunDati = class("JiehunDati", CcsSubView)
function JiehunDati:ctor(closeListener)
  JiehunDati.super.ctor(self, "views/dati_jiehun.csb", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_a = {
      listener = function()
        self:OnBtn_ClickAnswer("A")
      end,
      variName = "btn_A"
    },
    btn_b = {
      listener = function()
        self:OnBtn_ClickAnswer("B")
      end,
      variName = "btn_B"
    },
    btn_c = {
      listener = function()
        self:OnBtn_ClickAnswer("C")
      end,
      variName = "btn_C"
    },
    btn_d = {
      listener = function()
        self:OnBtn_ClickAnswer("D")
      end,
      variName = "btn_D"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.option_A = self:getNode("A")
  self.option_B = self:getNode("B")
  self.option_C = self:getNode("C")
  self.option_D = self:getNode("D")
  self.optiontxt_A = self:getNode("optiontxt_A")
  self.optiontxt_B = self:getNode("optiontxt_B")
  self.optiontxt_C = self:getNode("optiontxt_C")
  self.optiontxt_D = self:getNode("optiontxt_D")
  self.m_questionNum = self:getNode("txt_2_0")
  self.m_rightNum = self:getNode("txt_2_0_1")
  self.m_leftTimeNode = self:getNode("txt_3_0")
  self.m_leftTimeListener = scheduler.scheduleGlobal(handler(self, self.updateLefttime), 0.2)
  self.title_question = self:getNode("txt_free2")
  self.title_talk = self:getNode("title")
  self.m_CloseListener = closeListener
  self.m_IsFinished = false
  self.m_answerType = nil
  self.curQuestionID = nil
  self.m_curQuestionIndex = nil
  self.curAnswer = nil
  self.m_MarkWrong = nil
  self.m_MarkRight = nil
  self.m_ClosePopwarningView = nil
end
function JiehunDati:sendAswer()
  if self.m_answerType then
    netsend.netmarry.answerQeustion(self.curQuestionID, self.m_answerType)
  end
end
function JiehunDati:hadAnswer()
  self:sendAswer()
end
function JiehunDati:flushData(qid, curNum, totalNum, rightNum, leftTime)
  self.curQuestionID = qid
  self.m_curQuestionIndex = curNum
  self.m_lettTime = leftTime or 30
  self:flushLefttimeShow()
  if self.m_MarkWrong then
    self.m_MarkWrong:setVisible(false)
  end
  if self.m_MarkRight then
    self.m_MarkRight:setVisible(false)
  end
  self:clearCloseWarningView()
  self.m_questionNum:setText(string.format("%d/%d", checkint(curNum), checkint(totalNum)))
  self.m_rightNum:setText(string.format("%d", checkint(rightNum)))
  local qItem = data_MarryQuestion[self.curQuestionID]
  if qItem then
    if self.title_question == nil then
      return
    end
    self.title_question:setText(qItem.Question)
    self.optiontxt_A:setText(qItem.A)
    self.optiontxt_B:setText(qItem.B)
    self.optiontxt_C:setText(qItem.C)
    self.optiontxt_D:setText(qItem.D)
    for i, k in ipairs({
      "A",
      "B",
      "C",
      "D"
    }) do
      local btn = self["btn_" .. k]
      btn:setTouchEnabled(true)
    end
    self.curAnswer = qItem.Answer
    self.m_IsFinished = false
  else
    print(" 答题 === 》 找不到相应的题目 ", self.curQuestionID)
  end
end
function JiehunDati:OnBtn_ClickAnswer(answerType)
  self.m_IsFinished = true
  self.m_answerType = answerType
  self:hadAnswer()
  AwardPrompt.addPrompt("请耐心等待对方作选择")
  print("KejuRoom:OnBtn_ClickAnswer:", answerType)
  local isRight = answerType == self.curAnswer
  for i, k in ipairs({
    "A",
    "B",
    "C",
    "D"
  }) do
    local btn = self["btn_" .. k]
    btn:setTouchEnabled(false)
    if isRight == false and k == answerType then
      self.m_MarkWrong = self:ShowMark(btn, self.m_MarkWrong, false)
    end
    if k == self.curAnswer then
      self.m_MarkRight = self:ShowMark(btn, self.m_MarkRight, true)
    end
  end
end
function JiehunDati:updateLefttime(dt)
  if self.m_IsFinished ~= true then
    self.m_lettTime = self.m_lettTime - dt
    self:flushLefttimeShow()
    if self.m_lettTime <= 0 then
      print("答题超时")
      self.m_IsFinished = true
      self.m_answerType = nil
      self:hadAnswer()
      for i, k in ipairs({
        "A",
        "B",
        "C",
        "D"
      }) do
        local btn = self["btn_" .. k]
        btn:setTouchEnabled(false)
      end
    end
  end
end
function JiehunDati:flushLefttimeShow()
  if self.m_lettTime < 0 then
    self.m_lettTime = 0
  end
  local h, m, s = getHMSWithSeconds(self.m_lettTime)
  self.m_leftTimeNode:setText(string.format("%02d:%02d:%02d", h, m, s))
end
function JiehunDati:OnBtn_Close(btnObj, touchType)
  print("===>> JiehunDati:OnBtn_Close:self.m_IsFinished:", self.m_IsFinished)
  self:clearCloseWarningView()
  self.m_ClosePopwarningView = CPopWarning.new({
    title = "提示",
    text = "你确定要放弃此次答题，重新再来么?",
    confirmFunc = function()
      print("--->> 重来答题")
      for i, k in ipairs({
        "A",
        "B",
        "C",
        "D"
      }) do
        local btn = self["btn_" .. k]
        btn:setTouchEnabled(false)
      end
      netsend.netmarry.giveupDati()
    end,
    clearFunc = function()
      self.m_ClosePopwarningView = nil
    end
  })
end
function JiehunDati:clearCloseWarningView()
  if self.m_ClosePopwarningView then
    self.m_ClosePopwarningView:OnClose()
    self.m_ClosePopwarningView = nil
  end
end
function JiehunDati:ShowMark(btn, markIns, isRight)
  if markIns == nil then
    if isRight then
      markIns = display.newSprite("views/pic/pic_mark_right.png")
    else
      markIns = display.newSprite("views/pic/pic_mark_wrong.png")
    end
    btn:getParent():addNode(markIns, 100)
  end
  markIns:setVisible(true)
  local x, y = btn:getPosition()
  local size = btn:getSize()
  local tSize = markIns:getContentSize()
  if isRight then
    markIns:setPosition(ccp(x - size.width / 2 + tSize.width / 2 - 20, y))
  else
    markIns:setPosition(ccp(x - size.width / 2 + tSize.width / 2 - 15, y))
  end
  return markIns
end
function JiehunDati:Clear()
  self.m_MarkWrong = nil
  self.m_MarkRight = nil
  if self.m_CloseListener then
    self.m_CloseListener()
    self.m_CloseListener = nil
  end
  if self.m_leftTimeListener then
    scheduler.unscheduleGlobal(self.m_leftTimeListener)
    self.m_leftTimeListener = nil
  end
  self:clearCloseWarningView()
end
