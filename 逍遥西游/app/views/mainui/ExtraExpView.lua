CExtraExpView = class("CExtraExpView", CcsSubView)
function CExtraExpView:ctor(clickpos, clicksize)
  CExtraExpView.super.ctor(self, "views/extraexpdlg.json")
  self:setExtraData()
  tipssetposExtend.extend(self, {
    x = clickpos.x,
    y = clickpos.y,
    w = clicksize.width,
    h = clicksize.height,
    dirList = {TipsShow_LeftDown_Dir},
    zOrder = MainUISceneZOrder.menuView
  })
  self.m_UINode:setTouchEnabled(true)
  self.m_UINode:addTouchEventListener(function(touchObj, t)
    if (t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED) and g_CMainMenuHandler then
      g_CMainMenuHandler:ShowExtraExpView(false)
    end
  end)
  self.m_UpdateTimer = scheduler.scheduleGlobal(function()
    if self.setExtraData then
      self:setExtraData()
    end
  end, 1)
end
function CExtraExpView:setExtraData()
  if g_LocalPlayer == nil then
    return
  end
  local txt1 = ""
  if g_LocalPlayer:GetExtraExpFlag() == 1 then
    txt1 = "当前由于服务器等级较高,升级可享受额外的经验加成:\n#<G>经验加成:100%#"
  end
  local itemList = g_LocalPlayer:GetExtraExpItemList()
  local curTime = g_DataMgr:getServerTime()
  local txt2 = ""
  local index = 1
  for itemId, tp in pairs(itemList) do
    local restTime = tp - curTime
    if restTime > 0 then
      local itemName = data_getItemName(itemId)
      local itemDes = data_getItemDes(itemId)
      local d = math.floor(restTime / 3600 / 24)
      local h = math.floor(restTime / 3600 % 24)
      local m = math.floor(restTime % 3600 / 60)
      local s = math.floor(restTime % 60)
      local timeText = ""
      if d > 0 then
        timeText = string.format("剩余时间: %d天%.2d:%.2d:%.2d", d, h, m, s)
      else
        timeText = string.format("剩余时间: %.2d:%.2d:%.2d", h, m, s)
      end
      if index ~= 1 then
        txt2 = string.format([[
%s

%s:%s
#<G>%s#]], txt2, itemName, itemDes, timeText)
      else
        txt2 = string.format([[
%s%s:%s
#<G>%s#]], txt2, itemName, itemDes, timeText)
      end
      index = index + 1
    end
  end
  local allTxt = ""
  if txt1 == "" then
    allTxt = txt2
  elseif txt2 == "" then
    allTxt = txt1
  else
    allTxt = string.format([[
%s

%s]], txt1, txt2)
  end
  local bgSize = self:getNode("bg"):getSize()
  local delW = 40
  local delH = 50
  if self.m_RichText == nil then
    local titleTxt = CRichText.new({
      width = bgSize.width - delW,
      verticalSpace = 1,
      font = KANG_TTF_FONT,
      fontSize = 20,
      color = ccc3(255, 255, 255)
    })
    self.m_RichText = titleTxt
    self:addChild(titleTxt, 10)
  else
    self.m_RichText:clearAll()
  end
  self.m_RichText:addRichText(allTxt)
  local x = delW / 2 + 5
  local rSize = self.m_RichText:getContentSize()
  local y = delH / 2
  self.m_RichText:setPosition(ccp(x, y))
  self:getNode("bg"):setSize(CCSize(bgSize.width, rSize.height + delH))
end
function CExtraExpView:getViewSize()
  return self:getNode("bg"):getSize()
end
function CExtraExpView:Clear()
  if self.m_UpdateTimer then
    scheduler.unscheduleGlobal(self.m_UpdateTimer)
    self.m_UpdateTimer = nil
  end
end
