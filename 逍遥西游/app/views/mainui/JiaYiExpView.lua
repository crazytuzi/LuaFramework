CJiaYiExpView = class("CJiaYiExpView", CcsSubView)
function CJiaYiExpView:ctor(clickpos, clicksize)
  CJiaYiExpView.super.ctor(self, "views/extraexpdlg.json")
  self:setJiaYiData()
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
      g_CMainMenuHandler:ShowJiaYiView(false)
    end
  end)
end
function CJiaYiExpView:setJiaYiData()
  if g_LocalPlayer == nil then
    return
  end
  local petId = g_LocalPlayer:GetJiaYiWanPetId()
  local restTime = g_LocalPlayer:GetJiaYiWanRestTime()
  if petId == nil or restTime == nil then
    return
  end
  local petObj = g_LocalPlayer:getObjById(petId)
  if petObj == nil then
    return
  end
  local petName = petObj:getProperty(PROPERTY_NAME)
  local zs = petObj:getProperty(PROPERTY_ZHUANSHENG)
  local color = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local minNum = math.floor(restTime / 60) + 1
  local allTxt = string.format("传功丹：将参战召唤兽所得经验转移给#<r:%d,g:%d,b:%d>%s#\n剩余时间:#<G>%d#分钟", color.r, color.g, color.b, petName, minNum)
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
function CJiaYiExpView:getViewSize()
  return self:getNode("bg"):getSize()
end
function CJiaYiExpView:Clear()
end
