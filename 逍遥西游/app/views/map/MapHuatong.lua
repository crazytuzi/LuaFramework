MapHuatong = class("MapHuatong", MapJiehunObjBase)
local HuatongAniName_Sahua = "sa"
local HuatongAniName_Paobu = "pao"
local HuotongMoveSpeed = 300
function MapHuatong:ctor(gender)
  MapHuatong.super.ctor(self)
  self.m_gender = gender
  if gender == 1 then
    self.m_AniPrePath = "xiyou/huache/eff_huatong"
  else
    self.m_AniPrePath = "xiyou/huache/eff_huanv"
  end
  self.m_ShadowImg = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  self:addNode(self.m_ShadowImg, 5)
  self.m_ShadowImg:setScale(0.8)
  self.m_ShadowImg:setPosition(ccp(0, -50))
  self.m_LastDetectOpaqueGrid = {-100, -100}
  self.m_AniObj = nil
  self.m_Dir = nil
  self.m_AniName = HuatongAniName_Paobu
  self.m_PathNum = nil
  self.m_isSyncLoad = false
  self.m_ResPrePath = nil
  self.m_PngPath = nil
  self.m_PlistPath = nil
  self:setDir(DIRECTIOIN_LEFTDOWN)
  local mapView = g_MapMgr:getMapViewIns()
  mapView:addChild(self, 99999999)
  self.m_sahuaAni = nil
  self.m_moving = false
  self.m_firstSetPos = true
  self.m_moveHandler = scheduler.scheduleUpdateGlobal(handler(self, self.moveUpdate))
end
function MapHuatong:setPosition(...)
  Widget.setPosition(self, ...)
  self:flushAniObj()
  local x, y = self:getPosition()
  local mapView = g_MapMgr:getMapViewIns()
  if mapView then
    local gx, gy = mapView:getGridByPos(x, y)
    local lgx, lgy = unpack(self.m_LastDetectOpaqueGrid, 1, 2)
    if gx ~= lgx and gy ~= lgy then
      self.m_LastDetectOpaqueGrid = {gx, gy}
      if mapView:getGridIsOpaque(gx, gy) == true or mapView:GridCanGo({gx, gy}) == false then
        self.m_AniObj:setOpacity(150)
      else
        self.m_AniObj:setOpacity(255)
      end
    end
    local newZ = mapView:getRoleZOrderByPos(x, y)
    if self:getZOrder() ~= newZ then
      mapView:reorderChild(self, newZ)
    end
  end
end
function MapHuatong:moveToPos(x, y, dir)
  if self.m_firstSetPos == true then
    self.m_firstSetPos = false
    self:setPosition(ccp(x, y))
    self:setDir(dir)
    return
  end
  local cx, cy = self:getPosition()
  local dx = x - cx
  local dy = y - cy
  local dis = math.sqrt(dx * dx + dy * dy, 0.5)
  self.m_totalMoveTime = dis / HuotongMoveSpeed
  self.m_moveDeltaDis = {dx, dy}
  self.m_moveDstPos = {x, y}
  self.m_moveingTime = 0
  self.m_moving = true
  local dir
  if dx <= 0 then
    if dy <= 0 then
      dir = DIRECTIOIN_LEFTDOWN
    else
      dir = DIRECTIOIN_LEFTUP
    end
  elseif dy >= 0 then
    dir = DIRECTIOIN_RIGHTUP
  else
    dir = DIRECTIOIN_RIGHTDOWN
  end
  self:setDir(dir)
end
function MapHuatong:moveUpdate(dt)
  if self.m_moving == false then
    return
  end
  self.m_moveingTime = self.m_moveingTime + dt
  if self.m_moveingTime >= self.m_totalMoveTime then
    self:setPosition(ccp(self.m_moveDstPos[1], self.m_moveDstPos[2]))
    self.m_moving = false
  else
    local ddt = dt / self.m_totalMoveTime
    local dx = ddt * self.m_moveDeltaDis[1]
    local dy = ddt * self.m_moveDeltaDis[2]
    local x, y = self:getPosition()
    self:setPosition(ccp(x + dx, y + dy))
  end
end
function MapHuatong:setDir(dir, flushAniObj)
  self.m_Dir = dir
  if flushAniObj ~= false then
    self:flushAniObj()
  end
end
function MapHuatong:playSahua(isSahua)
  if isSahua then
    self.m_AniName = HuatongAniName_Sahua
    self:showSahuaEffect()
  else
    self.m_AniName = HuatongAniName_Paobu
  end
  self:flushAniObj()
end
function MapHuatong:showSahuaEffect()
  self:delSahuaEffect()
  local plistpath = "xiyou/huache/eff_sahua.plist"
  local ani = CreateSeqAnimation(plistpath, 1, handler(self, self.delSahuaEffect))
  local z = 99
  local flix = 1
  local x = 0
  local y = 0
  if self.m_Dir == DIRECTIOIN_LEFTUP then
    z = -1
    x = -30
  elseif self.m_Dir == DIRECTIOIN_RIGHTUP then
    flix = -1
    z = -1
    x = 30
  elseif self.m_Dir == DIRECTIOIN_LEFTDOWN then
    flix = -1
    x = 10
  elseif self.m_Dir == DIRECTIOIN_RIGHTDOWN then
  end
  self:addNode(ani, z)
  ani:setPosition(ccp(x, y))
  ani:setScaleX(flix)
  self.m_sahuaAni = ani
end
function MapHuatong:delSahuaEffect()
  if self.m_sahuaAni then
    self.m_sahuaAni:removeSelf()
    self.m_sahuaAni = nil
  end
end
function MapHuatong:flushAniObj()
  if self.m_Dir == DIRECTIOIN_RIGHTUP or self.m_Dir == DIRECTIOIN_LEFTUP then
    self.m_PathNum = 1
  else
    self.m_PathNum = 2
  end
  local prePath = string.format("%s%s_%s", self.m_AniPrePath, self.m_PathNum, self.m_AniName)
  local isCreate = false
  if self.m_ResPrePath ~= prePath or self.m_AniObj == nil then
    isCreate = true
  end
  if isCreate == false then
    self:flushHuacheAniDirShow_()
    return
  end
  if self.m_AniObj ~= nil then
    self.m_AniObj:removeSelf()
    self.m_AniObj = nil
  end
  self.m_ResPrePath = prePath
  self.m_isSyncLoad = true
  self.m_PngPath = prePath .. ".png"
  self.m_PlistPath = prePath .. ".plist"
  print("MapHuatong:flushAniObj self.m_PngPath:", self.m_PngPath)
  if self.m_AniName == HuatongAniName_Paobu then
    self.m_AniObj = CreateSeqAnimation(self.m_PlistPath, -1, nil, nil, nil, nil, true)
    self:addNode(self.m_AniObj, 10)
  else
    self.m_AniObj = CreateSeqAnimation(self.m_PlistPath, 1, handler(self, self.sahuaAniPlayFinished), nil, nil, nil, true)
    self:addNode(self.m_AniObj, 10)
  end
  self:flushHuacheAniDirShow_()
end
function MapHuatong:sahuaAniPlayFinished()
  self:playSahua(false)
end
function MapHuatong:flushHuacheAniDirShow_()
  if self.m_AniObj then
    if self.m_Dir == DIRECTIOIN_LEFTDOWN then
      self.m_AniObj:setScaleX(-1)
    elseif self.m_Dir == DIRECTIOIN_LEFTUP then
      self.m_AniObj:setScaleX(-1)
    else
      self.m_AniObj:setScaleX(1)
    end
  end
end
function MapHuatong:Clear()
  self.m_ShadowImg = nil
  self:delSahuaEffect()
  if self.m_moveHandler then
    scheduler.unscheduleGlobal(self.m_moveHandler)
    self.m_moveHandler = nil
  end
end
