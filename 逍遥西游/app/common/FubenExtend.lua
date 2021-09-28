FubenExtend = {}
function FubenExtend.extend(object)
  object.m_MyFubenMonsterData = {}
  object.m_FubenAwardInfo = {}
  object.m_FubenData = {}
  object.m_UnlockMap = 0
  function object:addFubenNpcData(mapId, catchId, leftTime)
    if object.m_MyFubenMonsterData[mapId] == nil then
      object.m_MyFubenMonsterData[mapId] = {}
    end
    if object.m_MyFubenMonsterData[mapId][catchId] == nil then
      object.m_MyFubenMonsterData[mapId][catchId] = {}
    end
    object.m_MyFubenMonsterData[mapId][catchId].time = leftTime
    local mapView = g_MapMgr:getMapViewIns()
    local bigMapId = data_getCatchGotoMapId(mapId, catchId)
    if mapView ~= nil and g_MapMgr:getCurMapId() == bigMapId then
      local monsterId = object.m_MyFubenMonsterData[mapId][catchId].mId
      if monsterId ~= nil then
        mapView:DeleteMonster(monsterId)
      end
      local monsterTypeId = data_getCatchMonsterType(mapId, catchId)
      local mapPos = data_getCatchMonsterPos(mapId, catchId)
      local newMonsterId = mapView:CreateMonster(monsterTypeId, {
        mapPos[1],
        mapPos[2]
      }, MapPosType_EditorGrid, mapPos[3], MapMonsterType_GuanKa, {mapId, catchId})
      object.m_MyFubenMonsterData[mapId][catchId].mId = newMonsterId
    end
    SendMessage(MsgID_FubenInfo_AddOneFubenNPC, mapId, catchId)
  end
  function object:delFubenNpcData(mapId, catchId)
    local mapView = g_MapMgr:getMapViewIns()
    local bigMapId = data_getCatchGotoMapId(mapId, catchId)
    if mapView ~= nil and g_MapMgr:getCurMapId() == bigMapId and object.m_MyFubenMonsterData[mapId] and object.m_MyFubenMonsterData[mapId][catchId] then
      local monsterId = object.m_MyFubenMonsterData[mapId][catchId].mId
      mapView:DeleteMonster(monsterId)
    end
    if object.m_MyFubenMonsterData[mapId] then
      object.m_MyFubenMonsterData[mapId][catchId] = nil
    end
    SendMessage(MsgID_FubenInfo_DelOneFubenNPC, mapId, catchId)
  end
  function object:getFubenNpcData()
    return object.m_MyFubenMonsterData
  end
  function object:delAllFubenNpcData()
    local mapView = g_MapMgr:getMapViewIns()
    if mapView ~= nil then
      for mapId, tData in pairs(object.m_MyFubenMonsterData) do
        for catchId, _ in pairs(tData) do
          if object.m_MyFubenMonsterData[mapId][catchId] then
            local bigMapId = data_getCatchGotoMapId(mapId, catchId)
            if g_MapMgr:getCurMapId() == bigMapId then
              local monsterId = object.m_MyFubenMonsterData[mapId][catchId].mId
              mapView:DeleteMonster(monsterId)
            end
          end
        end
      end
    end
    object.m_MyFubenMonsterData = {}
  end
  function object:updateFubenAwardInfo(awardId)
    object.m_FubenAwardInfo[awardId] = true
    SendMessage(MsgID_FubenInfo_UpdateAward)
  end
  function object:setFubenAwardInfo(awardList)
    object.m_FubenAwardInfo = {}
    for i, awarId in pairs(awardList) do
      object.m_FubenAwardInfo[awarId] = true
    end
  end
  function object:getFubenAwardInfo()
    return object.m_FubenAwardInfo
  end
  function object:updateFubenAwardInfo(awardId)
    object.m_FubenAwardInfo[awardId] = true
    SendMessage(MsgID_FubenInfo_UpdateAward)
  end
  function object:setUnlockMap(mapId)
    if mapId == nil then
      mapId = 0
    end
    object.m_UnlockMap = mapId
  end
  function object:getUnlockMap()
    return object.m_UnlockMap
  end
  function object:setFubenBaseData(data)
    object.m_FubenData = data
    SendMessage(MsgID_FubenInfo_BaseInfo)
  end
  function object:getFubenBaseData()
    return object.m_FubenData
  end
  function object:setFubenCatchInfo(mapID, catchID, nStar, sStar)
    if object.m_FubenData[mapID] == nil then
      object.m_FubenData[mapID] = {}
    end
    local catchInfo = object.m_FubenData[mapID][catchID]
    if catchInfo == nil then
      catchInfo = {}
      object.m_FubenData[mapID][catchID] = catchInfo
    end
    catchInfo.nstar = nStar or 0
    catchInfo.sstar = sStar or 0
    SendMessage(MsgID_FubenInfo_CatchInfo, mapID, catchID, nStar, sStar)
  end
  function object:getCatchStars(fbID, catchID, iSuper)
    local data = object.m_FubenData[fbID]
    if data == nil then
      return 0
    end
    local d = data[catchID]
    if d == nil then
      return 0
    end
    if iSuper == true or iSuper == 1 then
      return d.sstar or 0
    else
      return d.nstar or 0
    end
  end
  function object:flushCatchMonster()
    local mapView = g_MapMgr:getMapViewIns()
    local mapId = g_MapMgr:getCurMapId()
    if mapView == nil then
      return
    end
    for mapId, tData in pairs(object.m_MyFubenMonsterData) do
      for catchId, d in pairs(tData) do
        if object.m_MyFubenMonsterData[mapId][catchId] then
          local bigMapId = data_getCatchGotoMapId(mapId, catchId)
          if g_MapMgr:getCurMapId() == bigMapId then
            if d.mId ~= nil then
              mapView:DeleteMonster(d.mId)
            end
            local monsterTypeId = data_getCatchMonsterType(mapId, catchId)
            local mapPos = data_getCatchMonsterPos(mapId, catchId)
            local newMonsterId = mapView:CreateMonster(monsterTypeId, {
              mapPos[1],
              mapPos[2]
            }, MapPosType_EditorGrid, mapPos[3], MapMonsterType_GuanKa, {mapId, catchId})
            d.mId = newMonsterId
          end
        end
      end
    end
  end
  function object:isHasCatchMonster(mapId, catchId)
    if self.m_MyFubenMonsterData[mapId] and self.m_MyFubenMonsterData[mapId][catchId] then
      return true
    end
    return false
  end
  function object:getFubenStarNum(mapId)
    local allStar = 0
    local getStar = 0
    if data_Catch[mapId] == nil or data_Catch[mapId].catchID == nil then
      return 0, 0
    end
    for cId, d in pairs(data_Catch[mapId].catchID) do
      if d.isDouble == 1 then
        allStar = allStar + 3
        if object.m_FubenData[mapId] ~= nil then
          local catchInfo = object.m_FubenData[mapId][cId]
          if catchInfo ~= nil then
            local s = catchInfo.nstar or 0
            getStar = getStar + s
          end
        end
      end
    end
    return getStar, allStar
  end
  function object:getFubenCanGetAward(mapId)
    local getStar, allStar = object:getFubenStarNum(mapId)
    for i, d in pairs(data_CatchAward) do
      if d.mapID == mapId and getStar >= d.needStar and object.m_FubenAwardInfo[i] ~= true then
        return true
      end
    end
    return false
  end
end
gamereset.registerResetFuncForReconnect(function()
  if g_LocalPlayer and g_LocalPlayer.delAllFubenNpcData then
    g_LocalPlayer:delAllFubenNpcData()
  end
end)
