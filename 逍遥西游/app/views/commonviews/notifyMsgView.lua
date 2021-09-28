local notifyMsg = {}
function notifyMsg.init()
  notifyMsg.layerC = nil
  notifyMsg.msgTxt = nil
  notifyMsg.showSeq = {}
  MessageEventExtend.extend(notifyMsg)
  notifyMsg:ListenMessage(MsgID_Scene)
end
function notifyMsg.StopCurShowNotifyMsg()
  if notifyMsg.msgTxt then
    notifyMsg.msgTxt:removeFromParentAndCleanup(true)
    notifyMsg.msgTxt = nil
  end
  if notifyMsg.layerC then
    notifyMsg.layerC:removeFromParentAndCleanup(true)
    notifyMsg.layerC = nil
  end
  g_DataMgr.m_textHeight = 0
end
function notifyMsg.ShowNewNotifyMsg()
  if #notifyMsg.showSeq > 0 then
    if g_WarScene == nil then
      local d = table.remove(notifyMsg.showSeq, 1)
      if d then
        local msg, showNow = unpack(d)
        notifyMsg.ShowTheNotifyMsg(msg, showNow)
      end
    else
      print_lua_table(notifyMsg.showSeq)
      for index, d in ipairs(notifyMsg.showSeq) do
        local msg, showNow, hideInWar = unpack(d)
        if hideInWar ~= true then
          table.remove(notifyMsg.showSeq, index)
          notifyMsg.ShowTheNotifyMsg(msg, showNow)
          break
        end
      end
    end
  end
end
function notifyMsg.ShowTheNotifyMsg(msg, showNow)
  notifyMsg.StopCurShowNotifyMsg()
  notifyMsg.msgTxt = CRichText.new({
    width = display.width - 40,
    color = ccc3(255, 255, 255),
    fontSize = 22,
    align = CRichText_AlignType_Center
  })
  notifyMsg.msgTxt:addRichText(msg)
  local delY = notifyMsg.msgTxt:getContentSize().height
  local height = math.max(40, delY + 20)
  g_DataMgr.m_textHeight = height
  local y = height / 2 - delY / 2
  local txtSize = notifyMsg.msgTxt:getContentSize()
  local w = txtSize.width
  notifyMsg.msgTxt:setPosition(ccp(display.width, y))
  local actFinish = CCCallFunc:create(function()
    notifyMsg.StopCurShowNotifyMsg()
    notifyMsg.ShowNewNotifyMsg()
  end)
  local act
  if w > display.width - 40 then
    local act1 = CCMoveTo:create(0.3, ccp(display.width / 2, y))
    local act2 = CCMoveTo:create(2.5, ccp(display.width / 2 - w, y))
    local act3 = CCDelayTime:create(15)
    act = transition.sequence({
      act1,
      act2,
      act3,
      actFinish
    })
  else
    local act1 = CCMoveTo:create(0.5, ccp(display.width / 2 - w / 2, y))
    local act2 = CCDelayTime:create(10)
    act = transition.sequence({
      act1,
      act2,
      actFinish
    })
  end
  notifyMsg.msgTxt:runAction(act)
  notifyMsg.layerC = CCLayerColor:create(ccc4(0, 0, 0, 130))
  notifyMsg.layerC:setContentSize(CCSize(display.width, height))
  local setPointY = display.height * 0.7
  if g_DataMgr and g_DataMgr.m_curPointY then
    if g_DataMgr.m_curPointY < display.height * 0.7 + height then
      setPointY = g_DataMgr.m_curPointY - height - 1
    end
    if setPointY < display.height * 0.5 or setPointY + height > display.height then
      setPointY = display.height * 0.7
    end
  end
  notifyMsg.layerC:setPosition(ccp(0, setPointY))
  addNodeToTopLayer(notifyMsg.layerC, TopLayerZ_NotifyMsg)
  notifyMsg.layerC:addChild(notifyMsg.msgTxt)
  notifyMsg.layerC._msg = msg
end
function notifyMsg.StartShowNotifyMsg(msg, showNow, hideInWar)
  if showNow == true then
    table.insert(notifyMsg.showSeq, 1, {
      msg,
      showNow,
      hideInWar
    })
    notifyMsg.StopCurShowNotifyMsg()
  elseif notifyMsg.layerC and notifyMsg.layerC._msg == msg then
    table.insert(notifyMsg.showSeq, 1, {
      msg,
      true,
      hideInWar
    })
    notifyMsg.StopCurShowNotifyMsg()
  else
    if #notifyMsg.showSeq > 0 and notifyMsg.showSeq[#notifyMsg.showSeq][1] == msg then
      print("和当前未显示的最后一条公告一样，不再重复显示", msg)
      return
    end
    notifyMsg.showSeq[#notifyMsg.showSeq + 1] = {
      msg,
      showNow,
      hideInWar
    }
  end
  if notifyMsg.layerC == nil then
    notifyMsg.ShowNewNotifyMsg()
  end
end
function notifyMsg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Scene_War_Exit and notifyMsg.layerC == nil then
    notifyMsg.ShowNewNotifyMsg()
  end
end
notifyMsg.init()
gamereset.registerResetFunc(function()
  notifyMsg.StopCurShowNotifyMsg()
  notifyMsg.showSeq = {}
end)
function ShowNotifyViews(msg, showNow)
  if type(msg) ~= "string" then
    return
  end
  if showNow == nil then
    showNow = false
  end
  notifyMsg.StartShowNotifyMsg(msg, showNow, false)
end
function ShowNotifyViewsNotInWar(msg, showNow)
  if type(msg) ~= "string" then
    return
  end
  if showNow == nil then
    showNow = false
  end
  notifyMsg.StartShowNotifyMsg(msg, showNow, true)
end
function ShowNotifyTips(msg, sound)
  if type(msg) ~= "string" or string.len(msg) <= 0 then
    return
  end
  AwardPrompt.addPrompt(msg, nil, sound)
end
function ShowNotifyTipsAfterWar(msg, sound)
  if type(msg) ~= "string" or string.len(msg) <= 0 then
    return
  end
  AwardPrompt.addPrompt(msg, AwardPromptType_NotShowInWar, sound)
end
function ShowWarningInWar(txt)
  if JudgeIsInWar() then
    txt = txt or "战斗结束后生效"
    scheduler.performWithDelayGlobal(function()
      ShowNotifyTips(txt)
    end, 0.5)
  end
end
