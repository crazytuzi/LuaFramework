local LoadingTime = 3
local BreakTime = 1
local BgZOrder = 0
local BarZOrder = 5
local TextZOrder = 10
g_AllShowProgressBarList = nil
gamereset.registerResetFunc(function()
  g_AllShowProgressBarList = nil
end)
function ClearAllShowProgressBar()
  if g_AllShowProgressBarList == nil then
    return
  end
  for _, bar in pairs(g_AllShowProgressBarList) do
    bar:BreakLoading()
  end
  g_AllShowProgressBarList = nil
end
CShowProgressBar = class("CShowProgressBar", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CShowProgressBar:ctor(txt, loadFinishCallBack, loadingTime)
  self:setNodeEventEnabled(true)
  self.m_ShowText = txt
  self.m_CallBack = loadFinishCallBack
  self.m_BreakFlag = false
  local bg = display.newSprite("xiyou/pic/pic_award_prompt_bg.png")
  self:addNode(bg, BgZOrder)
  local bgSize = bg:getContentSize()
  self:setSize(CCSize(1, bgSize.height + 2))
  local x = display.width / 2
  local y = display.height * 0.3
  self:setPosition(ccp(x, y))
  local text = RichText.new({
    width = bgSize.width,
    verticalSpace = 0,
    color = ccc3(255, 255, 255),
    font = KANG_TTF_FONT,
    fontSize = 22,
    align = CRichText_AlignType_Center
  })
  self:addChild(text, TextZOrder)
  text:addRichText(txt)
  self.m_Txt = text
  local txtSize = text:getRichTextSize()
  text:setPosition(ccp(-txtSize.width / 2, -txtSize.height / 2 + 5))
  self.m_Bar = ProgressClip.new("views/warui/expbar.png", "views/warui/expbarbg.png", 0, 100, true)
  self:addChild(self.m_Bar, BarZOrder)
  local barSize = self.m_Bar:getContentSize()
  self.m_Bar:setPosition(ccp(-barSize.width / 2, -barSize.height / 2 - 10))
  CMainUIScene.Ins:addChild(self, MainUISceneZOrder.progressBarPrompt)
  if g_AllShowProgressBarList == nil then
    g_AllShowProgressBarList = {self}
  else
    g_AllShowProgressBarList[#g_AllShowProgressBarList + 1] = self
  end
  if loadingTime == nil then
    loadingTime = LoadingTime
  end
  self.m_Bar:progressTo(100, loadingTime, 100)
  scheduler.performWithDelayGlobal(function()
    if self.LoadFinish then
      self:LoadFinish()
    end
  end, loadingTime)
end
function CShowProgressBar:LoadFinish()
  if self.m_BreakFlag == true then
    return
  end
  if self.m_CallBack then
    self.m_CallBack()
  end
  self:DelSelf()
end
function CShowProgressBar:BreakLoading()
  self.m_BreakFlag = true
  self.m_Txt:clearAll()
  self.m_Txt:addRichText("打断")
  self.m_Bar:setVisible(false)
  scheduler.performWithDelayGlobal(function()
    if self.DelSelf then
      self:DelSelf()
    end
  end, BreakTime)
end
function CShowProgressBar:DelSelf()
  self:removeFromParent()
  if g_AllShowProgressBarList ~= nil then
    for i = 1, #g_AllShowProgressBarList do
      if g_AllShowProgressBarList[i] == self then
        table.remove(g_AllShowProgressBarList, i)
        break
      end
    end
  end
end
function CShowProgressBar:onCleanup()
  self.m_CallBack = nil
end
