g_MarryHuaChe = nil
function GetMarryHuaCheObj()
  return g_MarryHuaChe
end
function CreateMarryHuaCheObj()
  if g_MarryHuaChe == nil then
    g_MarryHuaChe = MapHuaChe:new()
  end
  return g_MarryHuaChe
end
function DelMarryHuaCheObj()
  if g_MarryHuaChe == nil then
    return
  end
  g_MarryHuaChe:deleteSelf()
  g_MarryHuaChe = nil
end
function GetHuochePostition()
  if g_MarryHuaChe then
    return g_MarryHuaChe:getPosition()
  end
end
local HuacheSpeed = 75
local HuachePosTable = {
  {
    {4325, 676},
    HuacheSpeed,
    DIRECTIOIN_RIGHTUP,
    1,
    2
  },
  {
    {5448, 1070},
    HuacheSpeed,
    DIRECTIOIN_RIGHTUP,
    0,
    0
  },
  {
    {6026, 1439},
    HuacheSpeed,
    DIRECTIOIN_LEFTUP,
    1,
    3
  },
  {
    {5122, 1892},
    HuacheSpeed,
    DIRECTIOIN_RIGHTUP,
    1,
    3
  },
  {
    {5485, 2251},
    HuacheSpeed,
    DIRECTIOIN_LEFTUP,
    1,
    3
  },
  {
    {4547, 2824},
    HuacheSpeed,
    DIRECTIOIN_LEFTDOWN,
    1,
    3
  },
  {
    {2470, 1678},
    HuacheSpeed,
    DIRECTIOIN_LEFTUP,
    1,
    3
  },
  {
    {1131, 2350},
    HuacheSpeed,
    DIRECTIOIN_LEFTDOWN,
    1,
    3
  },
  {
    {436, 1796},
    HuacheSpeed,
    DIRECTIOIN_RIGHTDOWN,
    1,
    3
  },
  {
    {1443, 1170},
    HuacheSpeed,
    DIRECTIOIN_RIGHTUP,
    1,
    3
  },
  {
    {2488, 1756},
    HuacheSpeed,
    DIRECTIOIN_RIGHTDOWN,
    1,
    3
  },
  {
    {4471, 709},
    HuacheSpeed,
    DIRECTIOIN_RIGHTDOWN,
    1,
    3
  }
}
local cosValue = math.cos(35 * math.pi / 180)
local sinValue = math.sin(35 * math.pi / 180)
local verctorForDir = {
  [DIRECTIOIN_RIGHTUP] = {cosValue, sinValue},
  [DIRECTIOIN_LEFTUP] = {
    -cosValue,
    sinValue
  },
  [DIRECTIOIN_RIGHTDOWN] = {
    cosValue,
    -sinValue
  },
  [DIRECTIOIN_LEFTDOWN] = {
    -cosValue,
    -sinValue
  }
}
local HuotongDeltaForDir = {
  [DIRECTIOIN_RIGHTUP] = {DIRECTIOIN_LEFTUP, DIRECTIOIN_RIGHTDOWN},
  [DIRECTIOIN_LEFTUP] = {DIRECTIOIN_LEFTDOWN, DIRECTIOIN_RIGHTUP},
  [DIRECTIOIN_RIGHTDOWN] = {DIRECTIOIN_RIGHTUP, DIRECTIOIN_LEFTDOWN},
  [DIRECTIOIN_LEFTDOWN] = {DIRECTIOIN_RIGHTDOWN, DIRECTIOIN_LEFTUP}
}
local huatongDisFromCenter = 80
local HuatongPosInFrontOfHuache = {
  [DIRECTIOIN_RIGHTUP] = {280, 155},
  [DIRECTIOIN_LEFTUP] = {-250, 170},
  [DIRECTIOIN_RIGHTDOWN] = {250, -135},
  [DIRECTIOIN_LEFTDOWN] = {-250, -155}
}
MapHuaChe = class("MapHuaChe", MapJiehunObjBase)
function MapHuaChe:ctor()
  MapHuaChe.super.ctor(self)
  self.m_MarryData = nil
  self.m_HuaCheObj = nil
  self.m_Dir = nil
  self.m_CurShowAniDir = nil
  self.m_PathNum = nil
  self.m_isSyncLoad = false
  self.m_PngPath = nil
  self.m_PlistPath = nil
  local mapView = g_MapMgr:getMapViewIns()
  mapView:addChild(self, 999999)
  self.m_CurMapView = mapView
  self.m_isLocalPlayerHuache = false
  if g_HunyinMgr:isInXunyouMap() and g_HunyinMgr:IsLocalRoleInHuaChe() then
    self.m_isLocalPlayerHuache = true
  end
  self.m_DongNan = MapHuatong.new(1)
  self.m_DongNv = MapHuatong.new(2)
  self.m_XunyouNameString = ""
  self.m_XunyouNameTxtIns = nil
end
function MapHuaChe:SetHuaCheData(data)
  self:setDir(1)
end
function MapHuaChe:Clear()
  if g_MarryHuaChe == self then
    g_MarryHuaChe = nil
  end
  self.m_XunyouNameTxtIns = nil
  self.m_DongNan = nil
  self.m_DongNv = nil
  if self.m_UpdateHandler_Base then
    scheduler.unscheduleGlobal(self.m_UpdateHandler_Base)
    self.m_UpdateHandler_Base = nil
  end
end
function MapHuaChe:deleteSelf()
  if self.m_DongNan then
    self.m_DongNan:removeSelf()
    self.m_DongNan = nil
  end
  if self.m_DongNv then
    self.m_DongNv:removeSelf()
    self.m_DongNv = nil
  end
  self:removeSelf()
end
function MapHuaChe:StratXunYou(passTime)
  local passTime = passTime
  if self.m_DongNan == nil then
    self.m_DongNan = MapHuatong.new(1)
  end
  if self.m_DongNv == nil then
    self.m_DongNv = MapHuatong.new(2)
  end
  self:startPosMove(HuachePosTable, passTime)
end
function MapHuaChe:setDir(dir)
  self.m_Dir = dir
  self:flushHuocheAni()
end
function MapHuaChe:setPosition(...)
  Widget.setPosition(self, ...)
  self:flushHuocheAni()
  self:flushHuatongPos()
  if self.m_isLocalPlayerHuache and self.m_CurMapView then
    local x, y = self:getPosition()
    self.m_CurMapView:localPlayerHuachePosChanged(x, y)
  end
end
function MapHuaChe:flushHuatongPos()
  local dis = HuatongPosInFrontOfHuache[self.m_Dir] or 130
  if dis == nil then
    return
  end
  local x, y = self:getPosition()
  local frontX = x + dis[1]
  local frontY = y + dis[2]
  local dirs = HuotongDeltaForDir[self.m_Dir]
  if self.m_DongNan then
    local disNan = verctorForDir[dirs[1]]
    local nanX = frontX + disNan[1] * huatongDisFromCenter
    local nanY = frontY + disNan[2] * huatongDisFromCenter
    self.m_DongNan:moveToPos(nanX, nanY, self.m_Dir)
  end
  if self.m_DongNv then
    local disNv = verctorForDir[dirs[2]]
    local nvX = frontX + disNv[1] * huatongDisFromCenter
    local nvY = frontY + disNv[2] * huatongDisFromCenter
    self.m_DongNv:moveToPos(nvX, nvY, self.m_Dir)
  end
end
function MapHuaChe:flushHuocheAni()
  local isCreate = true
  if self.m_HuaCheObj ~= nil and self.m_CurShowAniDir == self.m_Dir then
    isCreate = false
  end
  if isCreate ~= true then
    self:flushHuacheAniDirShow_()
    return
  end
  if self.m_HuaCheObj ~= nil then
    self.m_HuaCheObj:removeSelf()
    self.m_HuaCheObj = nil
  end
  self.m_CurShowAniDir = self.m_Dir
  self.m_PathNum = nil
  self.m_isSyncLoad = false
  if self.m_isSyncLoad == true then
    return
  end
  self.m_isSyncLoad = true
  if self.m_Dir == DIRECTIOIN_RIGHTUP or self.m_Dir == DIRECTIOIN_LEFTUP then
    self.m_PathNum = 1
  else
    self.m_PathNum = 2
  end
  self.m_PngPath = string.format("xiyou/huache/eff_huache%d.png", self.m_PathNum)
  self.m_PlistPath = string.format("xiyou/huache/eff_huache%d.plist", self.m_PathNum)
  if false then
    addDynamicLoadTexture(self.m_PngPath, function(handlerName, texture)
      print("setDir:addDynamicLoadTexture 1")
      self.m_isSyncLoad = false
      if self.m_IsExist and self.m_HuaCheObj == nil then
        print("setDir:addDynamicLoadTexture 2")
        self.m_HuaCheObj = CreateSeqAnimation(self.m_PlistPath, -1)
        self:addNode(self.m_HuaCheObj)
      end
      self:flushHuacheAniDirShow_()
    end, {pixelFormat = kCCTexture2DPixelFormat_RGBA4444})
  else
    self.m_HuaCheObj = CreateSeqAnimation(self.m_PlistPath, -1, nil, nil, nil, nil, true)
    self:addNode(self.m_HuaCheObj)
    self:flushHuacheAniDirShow_()
  end
end
function MapHuaChe:flushHuacheAniDirShow_()
  if self.m_HuaCheObj then
    if self.m_Dir == DIRECTIOIN_LEFTDOWN then
      self.m_HuaCheObj:setScaleX(-1)
    elseif self.m_Dir == DIRECTIOIN_LEFTUP then
      self.m_HuaCheObj:setScaleX(-1)
    else
      self.m_HuaCheObj:setScaleX(1)
    end
  end
end
function MapHuaChe:startPosMove(posTable, passTime)
  self.m_PosTable = {}
  local realTotalTime = 0
  local len = #posTable
  for i = 1, len do
    local posData = posTable[i]
    local pos, speed, dir, sahuaTimes, sahuaDeltaTime = unpack(posData, 1, 5)
    local walkTime = 0
    local dPos
    if i ~= len then
      local netxtPosData = posTable[i + 1]
      local nextPos = netxtPosData[1]
      local dx = nextPos[1] - pos[1]
      local dy = nextPos[2] - pos[2]
      local dis = math.pow(dx * dx + dy * dy, 0.5)
      dPos = {dx, dy}
      walkTime = dis / speed
    end
    self.m_PosTable[#self.m_PosTable + 1] = {
      pos = pos,
      speed = speed,
      dir = dir,
      walkTime = walkTime,
      dPos = dPos,
      sahuaTimes = sahuaTimes,
      sahuaDeltaTime = sahuaDeltaTime
    }
    realTotalTime = realTotalTime + walkTime + sahuaTimes * 0.7
  end
  self.m_isLocalPlayerHuache = false
  if g_HunyinMgr:isInXunyouMap() and g_HunyinMgr:IsLocalRoleInHuaChe() then
    self.m_isLocalPlayerHuache = true
  end
  print("realTotalTime:", realTotalTime)
  self.m_posMovePassTime = passTime
  self.m_CurPosTableIndex = -1
  self.m_sahuaTimes = 0
  self.m_sahuaDeltaTime = 0
  self.m_sahuaDeltaTimer = 0
  self.m_sahuaPlayingTimer = 0
  if self.m_UpdateHandler_Base == nil then
    self.m_UpdateHandler_Base = scheduler.scheduleUpdateGlobal(handler(self, self.frameUpdate_))
  end
  self:updatePos(0)
end
function MapHuaChe:frameUpdate_(dt)
  self:updatePos(dt)
end
function MapHuaChe:updatePos(dt)
  if self.m_IsExist ~= true then
    return
  end
  if self.m_sahuaPlayingTimer > 0 then
    self.m_sahuaPlayingTimer = self.m_sahuaPlayingTimer - dt
    print("----------->>> 正在撒花")
    return
  end
  if 0 < self.m_sahuaTimes then
    self.m_sahuaDeltaTimer = self.m_sahuaDeltaTimer - dt
    if 0 >= self.m_sahuaDeltaTimer then
      self.m_sahuaTimes = self.m_sahuaTimes - 1
      self.m_sahuaDeltaTimer = self.m_sahuaDeltaTime
      self.m_sahuaPlayingTimer = 0.7
      if self.m_DongNan then
        self.m_DongNan:playSahua(true)
      end
      if self.m_DongNv then
        self.m_DongNv:playSahua(true)
      end
    end
  end
  self.m_posMovePassTime = self.m_posMovePassTime + dt
  local totalTime = 0
  local len = #self.m_PosTable
  for i, posData in ipairs(self.m_PosTable) do
    if i == len then
      if g_HunyinMgr then
        g_HunyinMgr:EndXunyou()
      end
      netsend.netmarry.requestEndMarry()
    else
      local walkTime = posData.walkTime
      local dt = totalTime + walkTime - self.m_posMovePassTime
      if dt > 0 then
        local startPos = posData.pos
        local dPos = posData.dPos
        local d = (self.m_posMovePassTime - totalTime) / walkTime
        local px = startPos[1] + dPos[1] * d
        local py = startPos[2] + dPos[2] * d
        self:setDir(posData.dir)
        self:setPosition(ccp(px, py))
        if self.m_CurPosTableIndex ~= i then
          self.m_CurPosTableIndex = i
          self.m_sahuaTimes = posData.sahuaTimes
          self.m_sahuaDeltaTime = posData.sahuaDeltaTime
          self.m_sahuaDeltaTimer = self.m_sahuaDeltaTime
        end
        break
      else
      end
      totalTime = totalTime + walkTime
    end
  end
end
function MapHuaChe:test()
  self:setDir(2)
  local passTime = 0
  local speed = 1
  local posTable = {
    {
      {4325, 676},
      speed,
      DIRECTIOIN_RIGHTUP
    },
    {
      {5448, 1070},
      speed,
      DIRECTIOIN_RIGHTUP
    },
    {
      {6026, 1439},
      speed,
      DIRECTIOIN_LEFTUP
    },
    {
      {5122, 1892},
      speed,
      DIRECTIOIN_RIGHTUP
    },
    {
      {5485, 2251},
      speed,
      DIRECTIOIN_LEFTUP
    },
    {
      {4547, 2824},
      speed,
      DIRECTIOIN_LEFTDOWN
    },
    {
      {2470, 1678},
      speed,
      DIRECTIOIN_LEFTUP
    },
    {
      {1131, 2350},
      speed,
      DIRECTIOIN_LEFTDOWN
    },
    {
      {436, 1796},
      speed,
      DIRECTIOIN_RIGHTDOWN
    },
    {
      {1443, 1170},
      speed,
      DIRECTIOIN_RIGHTUP
    },
    {
      {2488, 1756},
      speed,
      DIRECTIOIN_RIGHTDOWN
    },
    {
      {4471, 709},
      speed,
      DIRECTIOIN_RIGHTDOWN
    }
  }
  self:StratXunYou(10)
end
