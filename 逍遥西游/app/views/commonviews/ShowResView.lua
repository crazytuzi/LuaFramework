local DirrectConvert = {
  [6] = 4,
  [7] = 3,
  [8] = 2
}
function TestcreateTxtClickObj(parent, x, y, txt, clickListener, color, alpha, zOrder)
  local clickObj = Widget:create()
  clickObj:setAnchorPoint(ccp(0.5, 0.5))
  clickObj:ignoreContentAdaptWithSize(false)
  color = color or ccc3(255, 0, 0)
  local txtIns = ui.newTTFLabel({
    text = txt,
    font = KANG_TTF_FONT,
    size = 30,
    color = color
  })
  clickObj:addNode(txtIns)
  if alpha then
    txtIns:setOpacity(alpha)
  end
  clickObj:setSize(txtIns:getContentSize())
  print("txtIns:", txtIns, txtIns:getContentSize().width, txtIns:getContentSize().height)
  clickObj:setTouchEnabled(true)
  clickObj:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_ENDED then
      if clickListener then
        clickListener(touchObj, t)
      end
      clickObj:setScale(1)
    elseif t == TOUCH_EVENT_CANCELED then
      clickObj:setScale(1)
    elseif t == TOUCH_EVENT_BEGAN then
      clickObj:setScale(1.1)
    end
  end)
  clickObj:setPosition(ccp(x, y))
  zOrder = zOrder or 100
  parent:addChild(clickObj, zOrder)
  return clickObj
end
ShowResView = class("ShowResView", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function ShowResView:ctor()
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self:setSize(CCSize(display.width, display.height))
  local layerC = display.newColorLayer(ccc4(255, 255, 255, 255))
  self:addNode(layerC)
  self:addTouchEventListener(handler(self, self.Touch))
  local btn_x = display.width - 100
  local btn_y = display.height - 30
  local dy = 38
  local warColor = ccc3(255, 255, 0)
  for i, v in ipairs({
    {
      "退 出",
      handler(self, self.Quit)
    },
    {
      "选地图",
      handler(self, self.SelectMap)
    },
    {
      "选主角",
      handler(self, self.SelectRole)
    },
    10,
    {
      "方向+",
      handler(self, self.DirAdd),
      ccc3(0, 255, 0)
    },
    {
      "方向-",
      handler(self, self.DirRec),
      ccc3(0, 255, 0)
    },
    {
      "站立状态",
      handler(self, self.StandStatus),
      ccc3(0, 255, 0)
    },
    {
      "行走状态",
      handler(self, self.WalkStatus),
      ccc3(0, 255, 0)
    },
    10,
    {
      "战斗方向4",
      handler(self, self.WarDir4),
      warColor
    },
    {
      "战斗方向8",
      handler(self, self.WarDir8),
      warColor
    },
    {
      "战斗状态",
      handler(self, self.AttackStatus),
      warColor
    },
    {
      "警戒状态",
      handler(self, self.HurtStatus),
      warColor
    },
    {
      "防守状态",
      handler(self, self.GuardStatus),
      warColor
    },
    {
      "死亡状态",
      handler(self, self.DeadStatus),
      warColor
    },
    {
      "施法状态",
      handler(self, self.MagicStatus),
      warColor
    }
  }) do
    if type(v) == "number" then
      btn_y = btn_y - v
    else
      TestcreateTxtClickObj(self, btn_x, btn_y, v[1], v[2], v[3], v[4])
      btn_y = btn_y - dy
    end
  end
  local tips = "带有_war为战斗对象。非战斗对象有8个方向和站立/行走两个状态；\n战斗对象有4/8两个方向，5个状态:战斗,警戒,防守,死亡,施法"
  local txtIns = ui.newTTFLabel({
    text = tips,
    font = KANG_TTF_FONT,
    size = 22,
    color = ccc3(255, 255, 255)
  })
  self:addNode(txtIns, 100)
  txtIns:setPosition(cc.p(display.width / 2, display.height - 50))
  self.m_Tips = ui.newTTFLabel({
    text = txt,
    font = KANG_TTF_FONT,
    size = 30,
    color = ccc3(255, 0, 0)
  })
  self:addNode(self.m_Tips, 100)
  self.m_Tips:setPosition(ccp(display.width / 2, 100))
  self.m_MapBg = nil
  self:LoadMapBg("1001")
  self.m_Dir = 1
  self.m_Status = ROLE_STATE_STAND
  local nameList = {}
  for name, d in pairs(data_Shape) do
    nameList[#nameList + 1] = name
  end
  table.sort(nameList)
  self.m_ShapeNameList = {}
  for k, nameId in ipairs(nameList) do
    self.m_ShapeNameList[#self.m_ShapeNameList + 1] = nameId
    local warName = string.format("xiyou/shape/shape%s_war.png", nameId)
    warName = CCFileUtils:sharedFileUtils():fullPathForFilename(warName)
    if os.exists(warName) then
      self.m_ShapeNameList[#self.m_ShapeNameList + 1] = string.format("%d_war", nameId)
    end
  end
  self.m_Ani = nil
  self.m_AniParent = display.newNode()
  self:addNode(self.m_AniParent, 20)
  self.m_AniParent:setPosition(ccp(500, display.height / 2))
  self.m_IsMoving = false
  self.m_LastPos = {}
end
function ShowResView:Touch(touchObj, t)
  local x, y
  if t == TOUCH_EVENT_BEGAN then
    local pt = self:getTouchStartPos()
    x = pt.x
    y = pt.y
    self.m_IsMoving = true
    self.m_LastPos = {x, y}
  elseif t == TOUCH_EVENT_MOVED then
    local pt = self:getTouchMovePos()
    x = pt.x
    y = pt.y
    self:MoveBg(x, y)
  elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
    local pt = self:getTouchEndPos()
    x = pt.x
    y = pt.y
    self:MoveBg(x, y)
    self.m_IsMoving = false
  end
end
function ShowResView:MoveBg(x, y)
  local dx = x - self.m_LastPos[1]
  local dy = y - self.m_LastPos[2]
  if self.m_MapBg then
    local x1, y1 = self.m_MapBg:getPosition()
    local dstx, dsty = x1 + dx, y1 + dy
    self.m_MapBg:setPosition(ccp(dstx, dsty))
  end
  self.m_LastPos = {x, y}
end
function ShowResView:LoadMapBg(mapFileName)
  print("LoadMapBg( mapFileName ):", mapFileName)
  local img = display.newSprite(string.format("xiyou/mapbg/pic_mapscenebg%s.jpg", mapFileName))
  if img then
    self:addNode(img, 10)
    img:setPosition(display.width / 2, display.height / 2)
    if self.m_MapBg then
      self.m_MapBg:removeSelf()
    end
    self.m_MapBg = img
  end
end
function ShowResView:LoadAni(aniName)
  print("LoadMapBg( mapFileName ):", aniName)
  if self.m_Ani ~= nil then
    self.m_Ani:removeFromParentAndCleanup(true)
  end
  local ani = CreateSeqAnimation(string.format("xiyou/shape/shape%s.plist", aniName), -1)
  if ani then
    self.m_AniParent:addChild(ani, 20)
    if self.m_Ani then
      self.m_AniParent:removeChild(self.m_Ani, true)
    end
    self.m_Ani = ani
    self.m_AniName = aniName
  end
  if string.find(self.m_AniName, "_war") == nil then
    self.m_Dir = 5
    self.m_Status = "stand"
  else
    self.m_Dir = 4
    self.m_Status = "guard"
  end
  self:flushAni()
end
function ShowResView:flushAni(isConvert)
  if self.m_Ani then
    local d = self.m_Dir
    if string.find(self.m_AniName, "_war") == nil then
      if d >= 6 then
        d = DirrectConvert[d]
        self.m_Ani:setScaleX(-1)
      else
        self.m_Ani:setScaleX(1)
      end
    end
    local aniName = string.format("%s_%d", self.m_Status, d)
    self.m_Ani:playAniWithName(aniName, -1)
    print("---->aniName:", self.m_Status, self.m_Dir, aniName)
    self.m_Tips:setString(string.format("[%s] 方向:%d, 动作:%s", self.m_AniName, self.m_Dir, self.m_Status))
  end
end
function ShowResView:DirAdd()
  print("==>>ShowResView:DirAdd")
  self.m_Dir = self.m_Dir + 1
  if self.m_Dir > 8 then
    self.m_Dir = 1
  end
  self:flushAni()
end
function ShowResView:DirRec()
  print("==>>ShowResView:DirRec")
  self.m_Dir = self.m_Dir - 1
  if self.m_Dir < 1 then
    self.m_Dir = 8
  end
  self:flushAni()
end
function ShowResView:WarDir4()
  print("==>>ShowResView:DirRec")
  self.m_Dir = 4
  self:flushAni(false)
end
function ShowResView:WarDir8()
  print("==>>ShowResView:DirRec")
  self.m_Dir = 8
  self:flushAni(false)
end
function ShowResView:StandStatus()
  print("==>>ShowResView:StandStatus")
  self.m_Status = ROLE_STATE_STAND
  self:flushAni()
end
function ShowResView:WalkStatus()
  print("==>>ShowResView:WalkStatus")
  self.m_Status = ROLE_STATE_WALK
  self:flushAni()
end
function ShowResView:AttackStatus()
  print("==>>ShowResView:AttackStatus")
  self.m_Status = "attack"
  self:flushAni()
end
function ShowResView:HurtStatus()
  print("==>>ShowResView:HurtStatus")
  self.m_Status = "hurt"
  self:flushAni()
end
function ShowResView:GuardStatus()
  self.m_Status = "guard"
  self:flushAni()
end
function ShowResView:DeadStatus()
  self.m_Status = "dead"
  self:flushAni()
end
function ShowResView:MagicStatus()
  self.m_Status = "magic"
  self:flushAni()
end
function ShowResView:TestMomo()
  print("-->>TestMomo")
  require("app.views.commonviews.ShowMomoTest")
  self:addChild(ShowMomoTest.new(), 99999)
end
function ShowResView:Quit()
  self:removeSelf()
end
function ShowResView:SelectMap()
  print("==>>ShowResView:SelectMap")
  local NameList = {
    1001,
    1003,
    1004,
    1005,
    1006,
    1007,
    1008,
    1009,
    1010,
    1011,
    1012,
    1013
  }
  self:ShowSelectScroller(NameList, handler(self, self.LoadMapBg))
end
function ShowResView:SelectRole()
  print("==>>ShowResView:SelectRole")
  self:ShowSelectScroller(self.m_ShapeNameList, handler(self, self.LoadAni))
end
function ShowResView:ShowSelectScroller(listData, selectListener)
  local scroller
  local function callFunc(item, idx)
    print("==>> item, idx :", item, idx)
    if selectListener then
      if selectListener then
        selectListener(listData[idx])
      end
      scroller:removeSelf()
    end
  end
  local p = display.getRunningScene()
  scroller = require("universal.ScrollView").new(display.width, display.height, callFunc, false)
  p:addChild(scroller, getMaxZ(p) + 1)
  for i, d in ipairs(listData) do
    local txtIns = ui.newTTFLabel({
      text = d,
      font = KANG_TTF_FONT,
      size = 30,
      color = ccc3(255, 0, 0)
    })
    local size = txtIns:getContentSize()
    local itemSize = CCSize(display.width, size.height + 10)
    local c = ccc4(0, 255, 0, 150)
    if i % 2 == 0 then
      c = ccc4(0, 0, 255, 150)
    end
    local layerC = display.newColorLayer(c)
    layerC:addChild(txtIns)
    layerC:setContentSize(itemSize)
    txtIns:setPosition(ccp(itemSize.width / 2, itemSize.height / 2))
    scroller:appendItem(layerC, itemSize)
  end
end
