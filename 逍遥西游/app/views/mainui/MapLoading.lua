local loadingPaths = {
  {
    "loading01.jpg",
    80,
    55,
    0
  },
  {
    "loading02.jpg",
    80,
    55,
    0
  }
}
CMapLoading = class("CMapLoading", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  widget:setSize(CCSize(display.width, display.height))
  widget:setContentSize(CCSize(display.width, display.height))
  return widget
end)
function CMapLoading:ctor()
  local size = self:getContentSize()
  self:setNodeEventEnabled(true)
  local selInfo = loadingPaths[math.random(1, #loadingPaths)]
  local jpgPath, offx, offy, offType = unpack(selInfo, 1, 4)
  local bgPath = "xiyou/loading/" .. jpgPath
  local bg = display.newSprite(bgPath)
  bg:setPosition(ccp(size.width / 2, size.height / 2))
  self:addNode(bg)
  local bgSize = bg:getContentSize()
  local sx = size.width / bgSize.width
  local sy = size.height / bgSize.height
  if sx > 1 or sy > 1 then
    local s = math.min(sx, sy)
    bg:setScale(1 / s)
    offx = offx * (1 / s)
    offy = offy * (1 / s)
  end
  local wx, wy = 0, 0
  if offType == 0 then
    wx = offx
    wy = offy
  elseif offType == 1 then
    wx = display.width - offx
    wy = offy
  end
  local barPos = bg:convertToNodeSpace(ccp(wx, wy))
  self.m_ProgressBar = ProgressClip.new("xiyou/loading/loadingbar.png", "xiyou/loading/loadingbarbg.png", 0, 100, true)
  bg:addChild(self.m_ProgressBar, 5)
  self.m_ProgressBar:barOffset(0, 2)
  self.m_ProgressBar:setPosition(ccp(barPos.x, barPos.y))
  local barSize = self.m_ProgressBar:getContentSize()
  local barFrame = display.newSprite(getLoadingbarframeSpriteFilePath())
  bg:addChild(barFrame, 20)
  barFrame:setPosition(ccp(barPos.x + barSize.width / 2 + 1, barPos.y + 85))
  self.m_ProgressTxt = ui.newTTFLabel({
    text = "98%",
    font = KANG_TTF_FONT,
    size = 20,
    color = ccc3(81, 140, 11)
  })
  bg:addChild(self.m_ProgressTxt, 10)
  local proSize = self.m_ProgressTxt:getContentSize()
  self.m_ProgressTxt:setPosition(ccp(barPos.x + barSize.width / 2, barPos.y + proSize.height / 2 + 37))
end
function CMapLoading:setLoadProgress(pro)
  self.m_ProgressTxt:setString(string.format("%d%%", checkint(pro * 100)))
  self.m_ProgressBar:value(checkint(pro * 100))
end
function CMapLoading:onCleanup()
  print("=======>>>  CMapLoading:onCleanup")
end
