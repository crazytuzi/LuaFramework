DatiRoom = class("DatiRoom", CcsSubView)
function DatiRoom:ctor(qid)
  DatiRoom.super.ctor(self, "views/dati.csb", {
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
  self.title_question = self:getNode("txt_free2")
  self.title_talk = self:getNode("title")
  self.m_MarkRight = nil
  self.m_MarkWrong = nil
  self.curTalkTitle = ""
  self.curQuestionID = qid
  self:flushQuestion()
  self.haveSelected = false
  self.curanswer = {}
end
function DatiRoom:OnBtn_ClickAnswer(answerType)
  self.haveSelected = true
  print("KejuRoom:OnBtn_ClickAnswer:", answerType)
  local answer = self:getCurAnswer()
  local isRight = answer == answerType
  if isRight then
    AwardPrompt.addPrompt("回答正确,你真是个人才#<E:51>#")
  else
    AwardPrompt.addPrompt("你的答案不对啊，加油!#<E:16>#")
  end
  self.curanswer[1] = answerType
  self.curanswer[2] = isRight
  self:ShowAnswerAction(isRight, answer, answerType)
end
function DatiRoom:ShowAnswerAction(isRight, answer, myAnswer)
  for i, k in ipairs({
    "A",
    "B",
    "C",
    "D"
  }) do
    local btn = self["btn_" .. k]
    btn:setTouchEnabled(false)
    if myAnswer == k then
      if k == answer then
        self.m_MarkRight = self:ShowMark(btn, self.m_MarkRight, true)
      elseif k == myAnswer then
        self.m_MarkWrong = self:ShowMark(btn, self.m_MarkWrong, false)
      end
    end
  end
  self:runAction(transition.sequence({
    CCDelayTime:create(2),
    CCCallFunc:create(function()
      if self.m_MarkRight then
        self.m_MarkRight:setVisible(false)
      end
      if self.m_MarkWrong then
        self.m_MarkWrong:setVisible(false)
      end
      self:showNewQuestion(myAnswer, isRight)
    end)
  }))
end
function DatiRoom:ShowMark(btn, markIns, isRight)
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
function DatiRoom:showNewQuestion(myAnswer, isRight)
  print(" 答题 错误 显示 ", myAnswer)
  if not isRight then
    SanJieLiLian.FlushQuestionData(myAnswer, function(qid)
      self:flushDate(qid)
      self.haveSelected = false
    end, true)
  else
    SanJieLiLian.FlushQuestionData(myAnswer, function()
      self.haveSelected = false
    end, false)
  end
end
function DatiRoom:flushDate(qid)
  if qid ~= nil and qid > 0 then
    self.curQuestionID = qid
    self:flushQuestion()
  end
end
function DatiRoom:flushQuestion()
  local qItem = data_TaskRunRing_QuestionLib[self.curQuestionID]
  if qItem then
    print("================ ", self.curQuestionID, "===================")
    print(qItem.Question)
    print("A:", qItem.A, "   B:", qItem.B, "   C:", qItem.C, "    D:", qItem.D)
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
    self.haveSelected = false
    self.curanswer = {}
  else
    print(" 答题 === 》 找不到相应的题目 ", self.curQuestionID)
  end
end
function DatiRoom:getCurAnswer()
  if self.curQuestionID then
    local qItem = data_TaskRunRing_QuestionLib[self.curQuestionID]
    if qItem then
      return qItem.Answer
    end
  end
  return nil
end
function DatiRoom:OnBtn_Close(btnObj, touchType, fo)
  if self.haveSelected and fo == nil then
    return
  end
  self:CloseSelf()
end
function DatiRoom:Clear()
  if SanJieLiLian.questionPanel == self then
    SanJieLiLian.questionPanel = nil
    SanJieLiLian.questionFlush = nil
  end
end
