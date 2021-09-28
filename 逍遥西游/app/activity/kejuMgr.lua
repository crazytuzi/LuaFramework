local keju = class("kejuMgr")
function keju:ctor()
  self.m_Status = {}
  self.m_Papers = {
    paperType = 0,
    paperQues = nil,
    endTime = 0
  }
  self.m_MyAnswer = {}
  self.m_DianshiStartTime = 0
  self.m_DianshiEntraceIns = nil
end
function keju:GotoNpc()
  local npcId = 90101
  g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
    if isSucceed and CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
    end
  end)
end
function keju:Join(aType)
  local des = KejuTypeDes[aType]
  if des then
    printLog("KEJU", "玩家点击参与科举[%s]", des)
  end
  netsend.netactivity.joinKeju(aType)
  return true
end
function keju:ShowDianshiRank()
  netsend.netactivity.getDianshiRank()
  getCurSceneView():addSubView({
    subView = KejuRank.new(),
    zOrder = MainUISceneZOrder.menuView
  })
  return true
end
function keju:hadGetDianshiRank(data)
  SendMessage(MsgID_Keju_HadGetRank, data)
end
function keju:getCurType()
  return self.m_Papers.paperType
end
function keju:getCurEndTime()
  return self.m_Papers.endTime
end
function keju:recvKejuAllPapers(pType, questions, lefttime, pos, score)
  print("------------------------->recvKejuAllPapers:", pType, questions, pos, score)
  self.question_num = #questions
  self.rightQuesNum = score
  self.questionPos = pos
  local function show()
    self.m_Papers.paperType = pType
    local qs = {}
    local d = {}
    local data = {}
    if questions == nil then
      return
    end
    for i, qId in ipairs(questions) do
      if pos ~= 1 then
        if i < pos then
          data = self:getQuestionDataWithId(qId, pTye)
          if data then
            d = {
              ID = qId,
              Question = data.Question,
              Option = data.Option,
              Answer = data.Answer
            }
            qs[#qs + 1] = d
          end
        elseif i >= pos then
          data = self:getQuestionDataWithId(qId, pType)
          if data then
            d = {
              ID = qId,
              Question = data.Question,
              Option = data.Option,
              Answer = data.Answer
            }
            qs[#qs + 1] = d
          end
        end
      elseif pos == 1 then
        data = self:getQuestionDataWithId(qId, pType)
        if data then
          d = {
            ID = qId,
            Question = data.Question,
            Option = data.Option,
            Answer = data.Answer
          }
          qs[#qs + 1] = d
        end
      end
    end
    self.m_Papers.paperQues = qs
    self.m_Papers.endTime = g_DataMgr:getServerTime() + lefttime
    self.m_MyAnswer = {_r = 1}
    if self.m_Papers.paperType ~= KejuType_3 then
      self:openExamRoom()
    else
      if self.m_romeView == nil then
        self:openExamRoom()
      end
      self.m_romeView:StartDianshiNow()
    end
  end
  if self.m_UpdateHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_UpdateHandler)
    self.m_UpdateHandler = nil
  end
  self.m_UpdateHandler = scheduler.scheduleUpdateGlobal(function()
    if g_DataMgr:getIsSendFinished() and CMainUIScene.Ins ~= nil and g_MapMgr:isMapLoaded() then
      show()
      if self.m_UpdateHandler then
        scheduler.unscheduleGlobal(self.m_UpdateHandler)
        self.m_UpdateHandler = nil
      end
    end
  end)
end
function keju:getQuestionDataWithId(id, type)
  local data
  if paperType == KejuType_1 then
    data = data_CountryQuestionLib[id]
  elseif paperType == KejuType_2 then
    data = data_ProvinceQuestionLib[id]
  else
    data = data_CapticalQuestionLib[id]
  end
  if data == nil then
    for i, d in ipairs({
      data_CountryQuestionLib,
      data_ProvinceQuestionLib,
      data_CapticalQuestionLib
    }) do
      data = d[id]
      if data then
        return data
      end
    end
  end
  return data
end
function keju:getQuestionSum()
  if self.question_num then
    return self.question_num
  end
  return 0
end
function keju:getRightQueSum()
  if self.rightQuesNum then
    return self.rightQuesNum
  end
  return 0
end
function keju:getCurQuesPos()
  if self.questionPos then
    return self.questionPos
  end
end
function keju:getQuestion(idx)
  if self.m_Papers.paperQues then
    return self.m_Papers.paperQues[idx]
  end
end
function keju:getStatus(kejuType)
  return self.m_Status[kejuType]
end
function keju:openExamRoom()
  if self.m_romeView == nil then
    self.m_romeView = KejuRoom.new()
    getCurSceneView():addSubView({
      subView = self.m_romeView,
      zOrder = MainUISceneZOrder.menuView + 1
    })
  end
  self:checkIsShowDianshiReadyBtn()
end
function keju:examRoomExit()
  self.m_romeView = nil
end
function keju:sendAllAnswer()
  printLog("KEJU", "sendAllAnswer")
  netsend.netactivity.commitAll(self.m_Papers.paperType, self.m_MyAnswer)
end
function keju:getDianshiStarttime()
  return self.m_DianshiStartTime
end
function keju:getIsNeedShowDianshiReadyBtn()
  if self.m_romeView ~= nil then
    return false
  end
  if self.m_DianshiStartTime > 0 then
    local svrtime = g_DataMgr:getServerTime()
    if svrtime ~= nil and svrtime > 0 then
      return svrtime < self.m_DianshiStartTime
    end
  end
  return false
end
function keju:checkIsShowDianshiReadyBtn()
  if g_DataMgr:getIsSendFinished() ~= true then
    print("checkIsShowDianshiReadyBtn  发包没有结束，等待...")
    return
  end
  local isShow = activity.keju:getIsNeedShowDianshiReadyBtn()
  print("checkIsShowDianshiReadyBtn--->>:", isShow)
  if isShow then
    self:ShowKejuEntranceBtn()
  else
    self:HideKejuEntranceBtn()
  end
end
function keju:ShowKejuEntranceBtn()
  local curScene = getCurSceneView()
  if self.m_DianshiEntraceIns == nil and curScene ~= nil then
    local view = KejuEntrance.new()
    curScene:addSubView({
      subView = view,
      zOrder = MainUISceneZOrder.kejuEntrance
    })
    self.m_DianshiEntraceIns = view
    local size = view:getSize()
    view:setPosition(ccp((display.width - size.width) / 2, 130))
  end
end
function keju:HideKejuEntranceBtn()
  if self.m_DianshiEntraceIns ~= nil then
    self.m_DianshiEntraceIns:CloseSelf()
  end
end
function keju:KejuEntranceBtnClose(ins)
  if self.m_DianshiEntraceIns == ins then
    self.m_DianshiEntraceIns = nil
  end
end
function keju:answerQuestion(idx, myAnswer)
  local d = self.m_Papers.paperQues
  if d == nil or d[idx] == nil then
    printLog("KEJU", "ERROR:提交答案是错误[%d]", idx)
    return false
  end
  local data = d[idx]
  local id = data.ID
  local answer = data.Answer
  self.m_MyAnswer[id] = myAnswer
  netsend.netactivity.commitOne(self.m_Papers.paperType, id, myAnswer)
  return answer == myAnswer, answer, id
end
function keju:KejuStatusChanged(status)
  self.m_Status = status
  SendMessage(MsgID_Keju_StatusChanged)
end
function keju:showDianshiReady(lefttime)
  print("showDianshiReady:", lefttime, g_CMainMenuHandler)
  self.m_Papers.paperType = KejuType_3
  self.m_DianshiStartTime = g_DataMgr:getServerTime() + lefttime
  self:checkIsShowDianshiReadyBtn()
end
function keju:giveupDianshi()
  self.m_DianshiStartTime = 0
  self:checkIsShowDianshiReadyBtn()
end
function keju:comfirmDianshi()
  netsend.netactivity.sendDianshiResult(1)
  self:openExamRoom()
  self:checkIsShowDianshiReadyBtn()
end
function keju:ShowDianshiCD(cd)
end
function keju:closeCDView(isNeedCloseView)
  print(":=--=isNeedCloseView:", isNeedCloseView)
  if self.m_DianshiCDTimerHandle then
    scheduler.unscheduleGlobal(self.m_DianshiCDTimerHandle)
  end
  self.m_DianshiCDTimerHandle = nil
  if self.m_DianshiCDView and isNeedCloseView == true then
    do
      local view = self.m_DianshiCDView
      scheduler.performWithDelayGlobal(function()
        print("==>>关闭view:", tostring(view), view.m_UINode)
        if view then
          view:CloseSelf()
        end
      end, 0.001)
    end
  end
  self.m_DianshiCDView = nil
end
function keju:clean()
  if self.m_DianshiCDTimerHandle then
    scheduler.unscheduleGlobal(self.m_DianshiCDTimerHandle)
    self.m_DianshiCDTimerHandle = nil
  end
  if self.m_UpdateHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_UpdateHandler)
    self.m_UpdateHandler = nil
  end
end
function keju:test()
  local question = {
    30001,
    30002,
    30003,
    30004
  }
  self:recvKejuAllPapers(3, question)
end
return keju
