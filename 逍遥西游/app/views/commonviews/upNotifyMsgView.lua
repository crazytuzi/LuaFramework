local upNotifyMsg = {}
local enterTime = 0.5
local showTime = 9.5
local newShowTime = 5
function upNotifyMsg.init()
  upNotifyMsg.layerC = nil
  upNotifyMsg.msgTxt = nil
  upNotifyMsg.showSeq = {}
  upNotifyMsg.canReplaceFlag = false
  MessageEventExtend.extend(upNotifyMsg)
  upNotifyMsg:ListenMessage(MsgID_Scene)
end
function upNotifyMsg.stopCurShowNotifyMsg()
  if upNotifyMsg.msgTxt then
    upNotifyMsg.msgTxt:removeFromParentAndCleanup(true)
    upNotifyMsg.msgTxt = nil
  end
  if upNotifyMsg.layerC then
    upNotifyMsg.layerC:removeFromParentAndCleanup(true)
    upNotifyMsg.layerC = nil
  end
  g_DataMgr.m_curPointY = -1
end
function upNotifyMsg.showNewNotifyMsg()
  upNotifyMsg.showSeq = upNotifyMsg.showSeq or {}
  dump(upNotifyMsg.showSeq, "upNotifyMsg.showSeq >>>>>>>>> ")
  if #upNotifyMsg.showSeq > 0 then
    if g_WarScene == nil then
      local d = table.remove(upNotifyMsg.showSeq, 1)
      if d then
        local msg, showNow = unpack(d)
        upNotifyMsg.ShowTheNotifyMsg(msg, showNow)
        return
      end
    else
      print_lua_table(upNotifyMsg.showSeq)
      for index, d in ipairs(upNotifyMsg.showSeq) do
        local msg, showNow, hideInWar = unpack(d)
        if hideInWar ~= true then
          table.remove(upNotifyMsg.showSeq, index)
          upNotifyMsg.ShowTheNotifyMsg(msg, showNow)
          return
        end
      end
    end
  end
end
function upNotifyMsg.ShowTheNotifyMsg(msg, showNow)
  upNotifyMsg.stopCurShowNotifyMsg()
  upNotifyMsg.msgTxt = CRichText.new({
    width = display.width,
    color = ccc3(255, 255, 255),
    fontSize = 22,
    align = CRichText_AlignType_Center
  })
  upNotifyMsg.msgTxt:addRichText(msg)
  local delY = upNotifyMsg.msgTxt:getContentSize().height
  local minLineHeight = 40
  local height = math.max(minLineHeight, delY + 20)
  local y = height / 2 - delY / 2
  local txtSize = upNotifyMsg.msgTxt:getContentSize()
  local w = txtSize.width
  upNotifyMsg.msgTxt:setPosition(ccp(display.width, y))
  local setCanReplaceFlagFunc = CCCallFunc:create(function()
    upNotifyMsg.canReplaceFlag = true
    upNotifyMsg.showNewNotifyMsg(false)
  end)
  local actFinish = CCCallFunc:create(function()
    upNotifyMsg.stopCurShowNotifyMsg()
    upNotifyMsg.showNewNotifyMsg()
  end)
  upNotifyMsg.canReplaceFlag = false
  local act
  if w > display.width then
    local act1 = CCMoveTo:create(0.3, ccp(display.width / 2, y))
    local act2 = CCMoveTo:create(2.5, ccp(display.width / 2 - w, y))
    local act3 = CCDelayTime:create(3)
    local act4 = CCDelayTime:create(2)
    act = transition.sequence({
      act1,
      act2,
      act3,
      setCanReplaceFlagFunc,
      act4,
      actFinish
    })
  else
    local act1 = CCMoveTo:create(enterTime, ccp(display.width / 2 - w / 2, y))
    local act2 = CCDelayTime:create(showTime)
    local act3 = CCDelayTime:create(newShowTime)
    act = transition.sequence({
      act1,
      act2,
      setCanReplaceFlagFunc,
      act3,
      actFinish
    })
  end
  upNotifyMsg.msgTxt:runAction(act)
  upNotifyMsg.layerC = CCLayerColor:create(ccc4(0, 0, 0, 130))
  upNotifyMsg.layerC:setContentSize(CCSize(display.width, height))
  local offsetY = 40
  if g_DataMgr and g_DataMgr.m_textHeight then
    offsetY = math.max(minLineHeight, g_DataMgr.m_textHeight)
  end
  g_DataMgr.m_curPointY = display.height * 0.7 + offsetY + 1
  if g_DataMgr.m_curPointY < display.height * 0.7 + minLineHeight - 2 then
    g_DataMgr.m_curPointY = display.height * 0.7 + minLineHeight + 2
  elseif g_DataMgr.m_curPointY + height > display.height then
    g_DataMgr.m_curPointY = display.height - height
  end
  upNotifyMsg.layerC:setPosition(ccp(0, g_DataMgr.m_curPointY))
  local zOrder = MainUISceneZOrder.downTipsView
  local p = getCurSceneView()
  if p.m_UINode then
    p = p.m_UINode
  end
  addNodeToTopLayer(upNotifyMsg.layerC, TopLayerZ_NotifyMsg)
  upNotifyMsg.layerC:addChild(upNotifyMsg.msgTxt)
  upNotifyMsg.layerC._msg = msg
end
function upNotifyMsg.StartShowNotifyMsg(msg, showNow, hideInWar)
  if showNow == true then
    table.insert(upNotifyMsg.showSeq, 1, {
      msg,
      showNow,
      hideInWar
    })
    upNotifyMsg.stopCurShowNotifyMsg()
  elseif upNotifyMsg.layerC and upNotifyMsg.layerC._msg == msg then
    table.insert(upNotifyMsg.showSeq, 1, {
      msg,
      true,
      hideInWar
    })
    upNotifyMsg.stopCurShowNotifyMsg()
  else
    if #upNotifyMsg.showSeq > 0 and upNotifyMsg.showSeq[#upNotifyMsg.showSeq][1] == msg then
      print("和当前未显示的最后一条公告一样，不再重复显示", msg)
      return
    end
    upNotifyMsg.showSeq[#upNotifyMsg.showSeq + 1] = {
      msg,
      showNow,
      hideInWar
    }
  end
  if upNotifyMsg.layerC == nil then
    upNotifyMsg.showNewNotifyMsg()
  end
  if upNotifyMsg.canReplaceFlag == true then
    upNotifyMsg.showNewNotifyMsg()
  end
end
function upNotifyMsg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Scene_War_Exit and upNotifyMsg.layerC == nil then
    upNotifyMsg.showNewNotifyMsg()
  end
end
upNotifyMsg.init()
gamereset.registerResetFunc(function()
  upNotifyMsg.stopCurShowNotifyMsg()
  upNotifyMsg.showSeq = {}
end)
function ShowUpNotifyViews(msg, showNow)
  if type(msg) ~= "string" then
    return
  end
  if showNow == nil then
    showNow = false
  end
  upNotifyMsg.StartShowNotifyMsg(msg, showNow, false)
end
