local downNotifyMsg = {}
function downNotifyMsg.init()
  downNotifyMsg.layerC = nil
  downNotifyMsg.msgTxt = nil
  downNotifyMsg.showSeq = {}
  downNotifyMsg.canReplaceFlag = false
  MessageEventExtend.extend(downNotifyMsg)
  downNotifyMsg:ListenMessage(MsgID_Scene)
end
function downNotifyMsg.StopCurShowNotifyMsg()
  if downNotifyMsg.msgTxt then
    downNotifyMsg.msgTxt:removeFromParentAndCleanup(true)
    downNotifyMsg.msgTxt = nil
  end
  if downNotifyMsg.layerC then
    downNotifyMsg.layerC:removeFromParentAndCleanup(true)
    downNotifyMsg.layerC = nil
  end
end
function downNotifyMsg.ShowNewNotifyMsg(checkLongKeepMsgFlag)
  if checkLongKeepMsgFlag == nil then
    checkLongKeepMsgFlag = true
  end
  if #downNotifyMsg.showSeq > 0 then
    if g_WarScene == nil then
      local d = table.remove(downNotifyMsg.showSeq, 1)
      if d then
        local msg, showNow = unpack(d)
        downNotifyMsg.ShowTheNotifyMsg(msg, showNow)
        return
      end
    else
      print_lua_table(downNotifyMsg.showSeq)
      for index, d in ipairs(downNotifyMsg.showSeq) do
        local msg, showNow, hideInWar = unpack(d)
        if hideInWar ~= true then
          table.remove(downNotifyMsg.showSeq, index)
          downNotifyMsg.ShowTheNotifyMsg(msg, showNow)
          return
        end
      end
    end
  end
  if checkLongKeepMsgFlag then
    downNotifyMsg.CheckLongKeepMsg()
  end
end
function downNotifyMsg.CheckLongKeepMsg()
  if activity.yzdd ~= nil then
    local tip = activity.yzdd:checkNeedMatchingTip()
    if tip ~= nil then
      ShowDownNotifyViews(tip)
      return
    end
  end
  if g_TeamMgr and g_TeamMgr:getLocalPlayerTeamId() == 0 then
    local matchFlag = g_TeamMgr:GetIsAutoMatching()
    local matchTarget = g_TeamMgr:GetIsAutoMatchingTarget()
    if matchFlag == 1 or matchFlag == true then
      if matchTarget == 0 then
        ShowDownNotifyViews("系统正在为你自动匹配队伍，请耐心等待")
        return
      else
        local targetName = data_getPromulgateDesc(matchTarget)
        ShowDownNotifyViews(string.format("系统正在为你自动匹配#<Y>%s#，请耐心等待", targetName))
        return
      end
    end
  end
end
function downNotifyMsg.ShowTheNotifyMsg(msg, showNow)
  downNotifyMsg.StopCurShowNotifyMsg()
  downNotifyMsg.msgTxt = CRichText.new({
    width = display.width - 40,
    color = ccc3(255, 255, 255),
    fontSize = 18,
    align = CRichText_AlignType_Center
  })
  downNotifyMsg.msgTxt:addRichText(msg)
  local delY = downNotifyMsg.msgTxt:getContentSize().height
  local height = math.max(30, delY)
  local y = height / 2 - delY / 2
  local txtSize = downNotifyMsg.msgTxt:getContentSize()
  local w = txtSize.width
  downNotifyMsg.msgTxt:setPosition(ccp(display.width / 2 - w / 2, -delY / 2))
  local setCanReplaceFlagFunc = CCCallFunc:create(function()
    downNotifyMsg.canReplaceFlag = true
    downNotifyMsg.ShowNewNotifyMsg(false)
  end)
  local actFinish = CCCallFunc:create(function()
    downNotifyMsg.StopCurShowNotifyMsg()
    downNotifyMsg.ShowNewNotifyMsg()
  end)
  downNotifyMsg.canReplaceFlag = false
  local act
  if w > display.width - 40 then
    local act1 = CCMoveTo:create(0.3, ccp(display.width / 2, y))
    local act2 = CCMoveTo:create(2.5, ccp(display.width / 2 - w, y))
    local act3 = CCDelayTime:create(1)
    local act4 = CCDelayTime:create(14)
    act = transition.sequence({
      act1,
      act2,
      act3,
      setCanReplaceFlagFunc,
      act4,
      actFinish
    })
  else
    local act1 = CCMoveTo:create(0.5, ccp(display.width / 2 - w / 2, y))
    local act2 = CCDelayTime:create(1)
    local act3 = CCDelayTime:create(9)
    act = transition.sequence({
      act1,
      act2,
      setCanReplaceFlagFunc,
      act3,
      actFinish
    })
  end
  downNotifyMsg.msgTxt:runAction(act)
  downNotifyMsg.layerC = CCLayerColor:create(ccc4(0, 0, 0, 130))
  downNotifyMsg.layerC:setContentSize(CCSize(display.width, height))
  downNotifyMsg.layerC:setPosition(ccp(0, 0))
  local zOrder = MainUISceneZOrder.downTipsView
  local p = getCurSceneView()
  if p.m_UINode then
    p = p.m_UINode
  end
  p:addNode(downNotifyMsg.layerC, zOrder)
  downNotifyMsg.layerC:addChild(downNotifyMsg.msgTxt)
  downNotifyMsg.layerC._msg = msg
end
function downNotifyMsg.StartShowNotifyMsg(msg, showNow, hideInWar)
  if showNow == true then
    table.insert(downNotifyMsg.showSeq, 1, {
      msg,
      showNow,
      hideInWar
    })
    downNotifyMsg.StopCurShowNotifyMsg()
  elseif downNotifyMsg.layerC and downNotifyMsg.layerC._msg == msg then
    table.insert(downNotifyMsg.showSeq, 1, {
      msg,
      true,
      hideInWar
    })
    downNotifyMsg.StopCurShowNotifyMsg()
  else
    if #downNotifyMsg.showSeq > 0 and downNotifyMsg.showSeq[#downNotifyMsg.showSeq][1] == msg then
      print("和当前未显示的最后一条公告一样，不再重复显示", msg)
      return
    end
    downNotifyMsg.showSeq[#downNotifyMsg.showSeq + 1] = {
      msg,
      showNow,
      hideInWar
    }
  end
  if downNotifyMsg.layerC == nil then
    downNotifyMsg.ShowNewNotifyMsg()
  end
  if downNotifyMsg.canReplaceFlag == true then
    downNotifyMsg.ShowNewNotifyMsg()
  end
end
function downNotifyMsg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Scene_War_Exit and downNotifyMsg.layerC == nil then
    downNotifyMsg.ShowNewNotifyMsg()
  end
end
downNotifyMsg.init()
gamereset.registerResetFunc(function()
  downNotifyMsg.StopCurShowNotifyMsg()
  downNotifyMsg.showSeq = {}
end)
function ShowDownNotifyViews(msg, showNow)
  if type(msg) ~= "string" then
    return
  end
  if showNow == nil then
    showNow = false
  end
  downNotifyMsg.StartShowNotifyMsg(msg, showNow, false)
end
function GetDownNotifyViewsIsBlank()
  return downNotifyMsg.layerC == nil
end
