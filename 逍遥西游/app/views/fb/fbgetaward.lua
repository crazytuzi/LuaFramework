function ShowFuBenGetAward(fbId, cbListener)
  if fbId == nil then
    return
  end
  getCurSceneView():addSubView({
    subView = CFBGetAward.new(fbId, cbListener),
    zOrder = MainUISceneZOrder.menuView
  })
end
CFBGetAward = class("CFBGetAward", CcsSubView)
function CFBGetAward:ctor(fbId, cbListener)
  self.m_FbId = fbId
  self.m_cbListener = cbListener
  CFBGetAward.super.ctor(self, "views/fb_getaward.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetData()
  self:ListenMessage(MsgID_FubenInfo)
end
function CFBGetAward:SetData()
  for i = 1, 4 do
    local pos = self:getNode(string.format("box_%d", i))
    if pos ~= nil and pos.m_Icon ~= nil then
      pos.m_Icon:removeFromParent()
      pos.m_Icon = nil
    end
  end
  self.m_StarPointList = {}
  local itemList = {}
  local getStar, allStar = g_LocalPlayer:getFubenStarNum(self.m_FbId)
  local fubenAwardInfo = g_LocalPlayer:getFubenAwardInfo()
  for i, d in ipairs(data_CatchAward) do
    if d.mapID == self.m_FbId then
      itemList[#itemList + 1] = {
        awardId = i,
        itemId = d.itemID,
        itemNum = d.itemNum,
        canGet = getStar >= d.needStar,
        hasGet = fubenAwardInfo[i] == true,
        needStar = d.needStar
      }
    end
  end
  for i, d in ipairs(itemList) do
    if i <= 4 then
      self.m_StarPointList[#self.m_StarPointList + 1] = d.needStar
      self:getNode(string.format("starText_%d", i)):setText(string.format("%d", d.needStar))
      local pos = self:getNode(string.format("box_%d", i))
      local s = pos:getContentSize()
      local function clickListener()
        local fubenAwardInfo = g_LocalPlayer:getFubenAwardInfo()
        if fubenAwardInfo[d.awardId] == true then
          return
        end
        netsend.netguanka.getGuanKaAwardId(d.awardId)
      end
      icon = createClickItem({
        itemID = d.itemId,
        autoSize = nil,
        num = d.itemNum,
        LongPressTime = 0.5,
        clickListener = clickListener,
        LongPressListener = nil,
        LongPressEndListner = nil,
        clickDel = nil,
        noBgFlag = false
      })
      local size = icon:getContentSize()
      icon:setPosition(ccp(10, 0))
      pos:addChild(icon)
      pos.m_Icon = icon
      if d.hasGet == true then
        local tempSprite = display.newSprite("views/common/btn/selected.png")
        tempSprite:setAnchorPoint(ccp(-0.3, -0.5))
        icon:addNode(tempSprite, 1)
      elseif d.canGet == true then
        local eff = CreateSeqAnimation("xiyou/ani/btn_circle.plist", -1)
        eff:setPosition(ccp(s.width / 2 - 10, s.height / 2 - 5))
        icon:addNode(eff, 1)
      end
    end
  end
  self:setStarBar()
end
function CFBGetAward:setStarBar()
  local fbId = self.m_FbId
  local getStar, allStar = g_LocalPlayer:getFubenStarNum(fbId)
  local tempPosList = {
    0,
    20,
    47,
    73,
    100
  }
  for i = 1, 4 do
    if self.m_StarPointList[i] == nil then
      self.m_StarPointList[i] = allStar
    end
  end
  local v = 100
  if getStar == 0 then
    v = 0
  elseif getStar <= self.m_StarPointList[1] then
    v = tempPosList[1] + (tempPosList[2] - tempPosList[1]) * (getStar - 0) / (self.m_StarPointList[1] - 0)
  elseif getStar <= self.m_StarPointList[2] then
    v = tempPosList[2] + (tempPosList[3] - tempPosList[2]) * (getStar - self.m_StarPointList[1]) / (self.m_StarPointList[2] - self.m_StarPointList[1])
  elseif getStar <= self.m_StarPointList[3] then
    v = tempPosList[3] + (tempPosList[4] - tempPosList[3]) * (getStar - self.m_StarPointList[2]) / (self.m_StarPointList[3] - self.m_StarPointList[2])
  elseif getStar <= self.m_StarPointList[4] then
    v = tempPosList[4] + (tempPosList[5] - tempPosList[4]) * (getStar - self.m_StarPointList[3]) / (self.m_StarPointList[4] - self.m_StarPointList[3])
  end
  if self.m_StarBar == nil then
    self.m_StarBar = ProgressClip.new("views/fb/getawardbar.png", "views/fb/getawardbar.png", 0, 100, true)
    local x, y = self:getNode("barbg"):getPosition()
    local size = self:getNode("barbg"):getContentSize()
    self.m_StarBar:setPosition(ccp(x - size.width / 2, y - 4))
    self:addChild(self.m_StarBar)
    self.m_StarBar:bg():setVisible(false)
  end
  self.m_StarBar:progressTo(v, nil, 100)
  if self.m_BarPoint == nil then
    self.m_BarPoint = display.newSprite("views/fb/pic_barcircle.png")
    self.m_BarPoint:setAnchorPoint(ccp(0.5, 0.5))
    self:addNode(self.m_BarPoint, 10)
    self.m_BarPoint.StarNum = ui.newTTFLabel({
      text = "0",
      font = KANG_TTF_FONT,
      size = 20,
      color = ccc3(205, 58, 36)
    })
    local tempSize = self.m_BarPoint:getContentSize()
    self.m_BarPoint.StarNum:setPosition(ccp(tempSize.width / 2, tempSize.height / 2))
    self.m_BarPoint:addChild(self.m_BarPoint.StarNum)
  end
  local x, y = self:getNode("barbg"):getPosition()
  local size = self:getNode("barbg"):getContentSize()
  local barSize = self.m_StarBar:getContentSize()
  self.m_BarPoint:setPosition(ccp(x - size.width / 2 + v * barSize.width / 100, y))
  self.m_BarPoint.StarNum:setString(string.format("%d", getStar))
end
function CFBGetAward:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CFBGetAward:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_FubenInfo_BaseInfo then
    self:SetData()
  elseif msgSID == MsgID_FubenInfo_CatchInfo then
    self:SetData()
  elseif msgSID == MsgID_FubenInfo_UpdateAward then
    self:SetData()
  end
end
function CFBGetAward:Clear()
  if self.m_cbListener then
    self.m_cbListener()
  end
  self.m_cbListener = nil
end
