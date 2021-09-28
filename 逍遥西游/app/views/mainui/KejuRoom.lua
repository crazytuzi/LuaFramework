KejuRoom = class("KejuRoom", CcsSubView)
function KejuRoom:ctor()
  KejuRoom.super.ctor(self, "views/keju.csb", {
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
  local t = activity.keju:getCurType()
  local txt = KejuTypeDes[t]
  if txt then
    self:getNode("title"):setText(txt)
  end
  self.m_CurShowType = t
  self:setAllAnswerVisible(false)
  self.m_CurShowIdx = 0
  self.m_TotalNum = 0
  local rightQuesSum = activity.keju:getRightQueSum()
  self.m_RightNum = rightQuesSum
  self.m_IsFinished = false
  self.m_QuestionNnumShow = self:getNode("txt_1")
  self.m_RightNnumShow = self:getNode("txt_2")
  self.m_CountDownTime = self:getNode("txt_3")
  self:setQuestionNum()
  self:setRightNum()
  self.m_MarkRight = nil
  self.m_MarkWrong = nil
  self.m_qid = nil
  self.m_Result = nil
  local kejuCtrl = data_KeJuControl[self.m_CurShowType]
  if not kejuCtrl.EndTime then
    local endTime = {23, 59}
  end
  self.m_EndTime = 0
  self.m_LastShowEndTime = -1
  self:ListenMessage(MsgID_Keju)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_ReConnect)
  self.m_DianshiCD = -1
  self.m_LastShowDianshiCD = -1
  self.m_IsStartAnswer = false
  print("self.m_CurShowType , KejuType_3:", self.m_CurShowType, KejuType_3)
  if self.m_CurShowType == KejuType_3 then
    self:setAllTipsVisible(false)
    local startTime = activity.keju:getDianshiStarttime()
    self.m_DianshiCD = startTime - g_DataMgr:getServerTime()
    self:updateDianshiCD(0)
  else
    self:Start()
  end
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  self:scheduleUpdate()
end
function KejuRoom:Start()
  self.m_IsFinished = false
  local curQuePos = activity.keju:getCurQuesPos()
  self.m_CurShowIdx = curQuePos - 1
  self.m_TotalNum = activity.keju:getQuestionSum()
  self:showNewQuestion()
  self.m_EndTime = activity.keju:getCurEndTime() - g_DataMgr:getServerTime()
  print("-->> self.m_EndTime:", self.m_EndTime)
  if self.m_EndTime < 0 then
    self.m_EndTime = 0
  end
  self.m_LastShowEndTime = -1
  self.m_IsStartAnswer = true
  self:updateEndTime(0)
end
function KejuRoom:OnMessage(msgSID, ...)
  if msgSID == MsgID_Keju_StatusChanged then
    if self.m_IsStartAnswer and self.m_IsFinished == false then
      local status = activity.keju:getStatus(self.m_CurShowType)
      if status ~= 1 then
        self.m_IsFinished = true
        print("===>> KejuRoom:OnMessage:self.m_IsFinished:", self.m_IsFinished)
        self:setAllAnswerVisible(false)
        self:showEndWarning()
      end
    end
  elseif msgSID == MsgID_ServerTime then
    if self.m_IsStartAnswer then
      self:flushEndTime()
    end
  elseif msgSID == MsgID_Keju_EachQuetionAnswer then
    local arg = {
      ...
    }
    local param = arg[1]
    self.m_qid = param.qid
    self.m_Result = param.result
    self:isCanAnswerNextQuetion()
  elseif msgSID == MsgID_ReConnect_Ready_ReLogin then
    self:CloseSelf()
  end
end
function KejuRoom:showEndWarning()
  local txt = KejuTypeDes[self.m_CurShowType] or "科举"
  local msg = string.format("%s考试时间已经结束", txt)
  CPopWarning.new({
    text = msg,
    confirmFunc = function()
      self:CloseSelf()
    end
  }):OnlyShowConfirmBtn(true)
  self:Finish(false)
end
function KejuRoom:frameUpdate(dt)
  if self.m_DianshiCD >= 0 then
    self:updateDianshiCD(dt)
  elseif self.m_IsStartAnswer then
    self:updateEndTime(dt)
  end
end
function KejuRoom:flushEndTime()
  self.m_EndTime = activity.keju:getCurEndTime() - g_DataMgr:getServerTime()
end
function KejuRoom:updateEndTime(dt)
  if self.m_EndTime > -1 then
    self.m_EndTime = self.m_EndTime - dt
    if self.m_EndTime <= 0 then
      self.m_EndTime = -1
      self:setAllAnswerVisible(false)
      self.m_IsFinished = true
      print("===>> KejuRoom:updateEndTime:self.m_IsFinished:", self.m_IsFinished)
      self:showEndWarning()
    else
      local c = math.floor(self.m_EndTime)
      if c ~= self.m_LastShowEndTime then
        self.m_LastShowEndTime = c
        local h = math.floor(c / 3600)
        c = c - h * 3600
        local m = math.floor(c / 60)
        local s = c - m * 60
        self.m_CountDownTime:setText(string.format("%02d:%02d:%02d", h, m, s))
      end
    end
  end
end
function KejuRoom:updateDianshiCD(dt)
  self.m_DianshiCD = self.m_DianshiCD - dt
  if self.m_DianshiCD <= 0 then
    self.m_DianshiCD = -1
  else
    local c = math.floor(self.m_DianshiCD)
    if c ~= self.m_LastShowDianshiCD then
      self.m_LastShowDianshiCD = c
      self:setDianshiCDTime(c)
    end
  end
end
function KejuRoom:setDianshiCDTime(cd)
  if self.m_DianshiCDTxt == nil then
    local p = self:getNode("bg")
    local size = p:getSize()
    self.m_DianshiCDTxt = CRichText.new({
      width = size.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 25,
      color = ccc3(255, 0, 0),
      align = CRichText_AlignType_Center
    })
    p:addChild(self.m_DianshiCDTxt, 10)
    self.m_DianshiCDTxt:setPosition(ccp(-size.width / 2, size.height / 2 - 120))
  end
  if cd < 0 then
    cd = 0
  end
  self.m_DianshiCDTxt:clearAll()
  self.m_DianshiCDTxt:addRichText(string.format("殿试将于%d秒后开始，请耐心等待", cd))
end
function KejuRoom:StartDianshiNow()
  self.m_DianshiCD = -1
  self:setAllTipsVisible(true)
  if self.m_DianshiCDTxt then
    self.m_DianshiCDTxt:setEnabled(false)
  end
  self:updateDianshiCD(0)
  self:Start()
end
function KejuRoom:showNewQuestion()
  self.m_CurShowIdx = self.m_CurShowIdx + 1
  local question = activity.keju:getQuestion(self.m_CurShowIdx)
  if question == nil then
    self:Finish()
    return
  end
  self:setQuestionNum()
  self:ShowQuestion(question)
end
function KejuRoom:Finish(needclose)
  self:setAllAnswerVisible(false)
  self.m_IsFinished = true
  print("===>> KejuRoom:Finish:self.m_IsFinished:", self.m_IsFinished)
  activity.keju:sendAllAnswer()
  if needclose ~= false then
    self:runAction(transition.sequence({
      CCDelayTime:create(1),
      CCCallFunc:create(function()
        self:CloseSelf()
      end)
    }))
  end
end
function KejuRoom:ShowQuestion(questionData)
  self.title_question:setText(questionData.Question or "")
  self:setOptionActions(self.title_question, true)
  local optionData = questionData.Option or {}
  for i, k in ipairs({
    "A",
    "B",
    "C",
    "D"
  }) do
    local option = self["option_" .. k]
    local btn = self["btn_" .. k]
    local optiontxt = self["optiontxt_" .. k]
    btn:setTouchEnabled(true)
    if optionData[k] == nil then
      for i, obj in ipairs({
        option,
        btn,
        optiontxt
      }) do
        self:setOptionActions(obj, false)
      end
    else
      optiontxt:setText(optionData[k])
      for i, obj in ipairs({
        option,
        btn,
        optiontxt
      }) do
        self:setOptionActions(obj, true)
      end
    end
  end
end
function KejuRoom:setOptionActions(obj, isShow)
  obj:setEnabled(isShow)
end
function KejuRoom:setAllAnswerVisible(isShow)
  self:setOptionActions(self.title_question, isShow)
  for i, k in ipairs({
    "A",
    "B",
    "C",
    "D"
  }) do
    self:setOptionActions(self["option_" .. k], isShow)
    self:setOptionActions(self["btn_" .. k], isShow)
    self:setOptionActions(self["optiontxt_" .. k], isShow)
  end
end
function KejuRoom:setAllTipsVisible(isShow)
  for i, keyName in ipairs({
    "txt1",
    "txt_1",
    "txt2",
    "txt_2",
    "txt3",
    "txt_3"
  }) do
    self:getNode(keyName):setEnabled(isShow)
  end
end
function KejuRoom:setQuestionNum()
  self.m_QuestionNnumShow:setText(string.format("%d/%d", self.m_CurShowIdx, self.m_TotalNum))
end
function KejuRoom:setRightNum()
  self.m_RightNnumShow:setText(string.format("%d", self.m_RightNum))
end
function KejuRoom:OnBtn_Close(btnObj, touchType)
  print("===>> KejuRoom:OnBtn_Close:self.m_IsFinished:", self.m_IsFinished)
  if self.m_IsFinished == false then
    local txt = KejuTypeDes[self.m_CurShowType] or "科举"
    local msg = string.format("确定退出%s?退出之后不能重新进入。", txt)
    CPopWarning.new({
      text = msg,
      confirmFunc = function()
        print("===>> KejuRoom:OnBtn_Close confirmFunc :self.m_IsFinished:", self.m_IsFinished)
        self.m_IsFinished = true
        activity.keju:sendAllAnswer()
        self:CloseSelf()
      end
    })
  else
    self:CloseSelf()
  end
end
function KejuRoom:OnBtn_ClickAnswer(answerType)
  print("KejuRoom:OnBtn_ClickAnswer:", answerType)
  self.m_isRight, self.m_answer, self.m_LocQid = activity.keju:answerQuestion(self.m_CurShowIdx, answerType)
  self.m_answerType = answerType
end
function KejuRoom:isCanAnswerNextQuetion()
  if self.m_qid == self.m_LocQid then
    if self.m_Result == true then
      self.m_RightNum = self.m_RightNum + 1
      self:setRightNum()
      AwardPrompt.addPrompt("回答正确,你真是个人才#<E:51>#")
    else
      AwardPrompt.addPrompt("你的答案不对啊，加油!#<E:16>#")
    end
    if self.m_answer ~= nil and self.m_answerType ~= nil then
      self:ShowAnswerAction(self.m_isRight, self.m_answer, self.m_answerType)
    end
    self.m_qid = nil
    self.m_Result = nil
    self.m_isRight = false
    self.m_answerType = nil
    self.m_LocQid = nil
  end
end
function KejuRoom:ShowAnswerAction(isRight, answer, myAnswer)
  for i, k in ipairs({
    "A",
    "B",
    "C",
    "D"
  }) do
    local btn = self["btn_" .. k]
    btn:setTouchEnabled(false)
    if k == answer then
      self.m_MarkRight = self:ShowMark(btn, self.m_MarkRight, true)
    elseif k == myAnswer then
      self.m_MarkWrong = self:ShowMark(btn, self.m_MarkWrong, false)
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
      self:showNewQuestion()
    end)
  }))
end
function KejuRoom:ShowMark(btn, markIns, isRight)
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
function KejuRoom:Clear()
  activity.keju:examRoomExit()
end
