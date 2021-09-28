g_FubenHandler = nil
gamereset.registerResetFunc(function()
  g_FubenHandler = nil
end)
g_FbInterface = {}
function g_FbInterface.ShowFuBenCatch(fbId, catchId, iSuper)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中不能进入关卡副本")
    return
  end
  if g_FubenHandler ~= nil then
    return
  end
  local arrowToInfo
  if fbId == nil then
    local minFbId
    for tFbId, _ in pairs(data_Catch) do
      if g_LocalPlayer:getFubenCanGetAward(tFbId) and (minFbId == nil or tFbId < minFbId) then
        minFbId = tFbId
      end
    end
    fbId = minFbId
  else
    iSuper = g_FbInterface.correctMode(iSuper)
    if catchId ~= nil then
      arrowToInfo = {
        fbId,
        catchId,
        iSuper
      }
    end
  end
  local dlg = fbui.new(fbId, iSuper, arrowToInfo)
  if dlg:InitSuccess() then
    g_FubenHandler = getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.fubenView
    })
    SendMessage(MsgID_Scene_Fuben_Enter)
  end
  if g_CMainMenuHandler then
    g_CMainMenuHandler:reflushQuickUseBoardZOrder()
  end
  CMainUIScene.Ins:updateSubViewsCoverFlags()
end
function g_FbInterface.ShowMaxFuBenCatch(iSuper)
  iSuper = g_FbInterface.correctMode(iSuper)
  if g_FubenHandler ~= nil then
    g_FubenHandler:SetShowMaxFuBenCatch(iSuper)
  else
    g_FbInterface.ShowFuBenCatch(nil, nil, iSuper)
  end
end
function g_FbInterface.PointToFuBenCatch(fbId, catchId, iSuper)
  iSuper = g_FbInterface.correctMode(iSuper)
  if g_FubenHandler ~= nil then
    if iSuper == nil or iSuper == 0 then
      iSuper = false
    end
    if g_FubenHandler:getCurrFbID() == fbId and g_FubenHandler:getIsSuper() == iSuper then
      g_FubenHandler:SetPointToCatch(catchId)
    else
      g_FubenHandler:CloseSelf()
      g_FubenHandler = nil
      g_FbInterface.ShowFuBenCatch(fbId, catchId, iSuper)
    end
  else
    g_FbInterface.ShowFuBenCatch(fbId, catchId, iSuper)
  end
end
function g_FbInterface.CloseFueben()
  if g_FubenHandler == nil then
    return
  end
  g_FubenHandler:CloseSelf()
  g_FubenHandler = nil
  if g_CMainMenuHandler then
    g_CMainMenuHandler:reflushQuickUseBoardZOrder()
  end
  CMainUIScene.Ins:updateSubViewsCoverFlags()
end
function g_FbInterface.correctMode(iSuper)
  if iSuper == 1 or iSuper == true then
    return true
  else
    return false
  end
end
function g_FbInterface.getMaxOpenMap()
  local _getMaxMapID = function(fbId, iSuper)
    local catchList = data_getCatchDataList(fbId)
    if catchList == nil then
      return fbId
    end
    for cID, _ in ipairs(catchList) do
      if g_LocalPlayer:getCatchStars(fbId, cID, iSuper) <= 0 then
        if iSuper then
          local isDouble = data_getCatchIsDouble(fbId, cID)
          if isDouble then
            return fbId
          end
        else
          return fbId
        end
      end
    end
    if fbId >= date_getMaxFubenMapID() then
      return fbId
    end
    local mainHero = g_LocalPlayer:getMainHero()
    local zhuan = mainHero:getProperty(PROPERTY_ZHUANSHENG)
    local level = mainHero:getProperty(PROPERTY_ROLELEVEL)
    local zhuanNeed, levelNeed = data_getCatchUnlockInfo(fbId + 1, 1, iSuper)
    if zhuan > zhuanNeed or zhuan == zhuanNeed and level >= levelNeed then
      return fbId + 1
    else
      return fbId
    end
  end
  isSuper = g_FbInterface.correctMode(isSuper)
  local fbIdList = {}
  local fbData_Svr = g_LocalPlayer:getFubenBaseData()
  for id, _ in ipairs(fbData_Svr) do
    table.insert(fbIdList, 1, id)
  end
  local fbID_n = -1
  local fbID_s = -1
  for _, fbId in pairs(fbIdList) do
    if fbID_n < 0 and 0 < g_LocalPlayer:getCatchStars(fbId, 1, false) then
      fbID_n = _getMaxMapID(fbId, false)
    end
    if fbID_s < 0 then
      local catchId = data_getFirstDoubleCatchID(fbId)
      if 0 < g_LocalPlayer:getCatchStars(fbId, catchId, true) then
        fbID_s = _getMaxMapID(fbId, true)
      end
    end
  end
  if fbID_n < 0 then
    fbID_n = 1
  end
  if fbID_s < 0 then
    fbID_s = 1
  end
  return fbID_n, fbID_s
end
function g_FbInterface.detectCatchIsOpen(fbId, catchId, iSuper)
  iSuper = g_FbInterface.correctMode(iSuper)
  local fbID_n, fbID_s = g_FbInterface.getMaxOpenMap()
  if iSuper then
    if fbId > fbID_s then
      return false
    elseif fbId < fbID_s then
      return true
    end
    local catchData = data_getCatchDataList(fbId)
    if catchData == nil then
      return false
    end
    for cid, _ in ipairs(catchData) do
      if catchId <= cid then
        return true
      end
      local isDouble = data_getCatchIsDouble(fbId, cid)
      if isDouble and g_LocalPlayer:getCatchStars(fbId, cid, iSuper) <= 0 then
        if cid < catchId then
          return false
        else
          return true
        end
      end
    end
    return false
  else
    if fbId > fbID_n then
      return false
    elseif fbId < fbID_n then
      return true
    end
    if catchId <= 1 then
      return true
    end
    if 0 >= g_LocalPlayer:getCatchStars(fbId, catchId - 1, iSuper) then
      return false
    else
      return true
    end
  end
end
function g_FbInterface.getMaxCatch(fbId, iSuper)
  local catchData = data_getCatchDataList(fbId)
  if catchData == nil then
    return nil
  end
  iSuper = g_FbInterface.correctMode(iSuper)
  local fbID_n, fbID_s = g_FbInterface.getMaxOpenMap()
  if iSuper then
    if fbId > fbID_s then
      return nil
    end
    local maxCatchId = 1
    for cid, _ in ipairs(catchData) do
      local isDouble = data_getCatchIsDouble(fbId, cid)
      if isDouble then
        maxCatchId = cid
        if g_LocalPlayer:getCatchStars(fbId, cid, iSuper) < 0 then
          break
        end
      end
    end
    return maxCatchId
  else
    if fbId > fbID_n then
      return nil
    end
    local maxCatchId = 1
    for cid, _ in ipairs(catchData) do
      maxCatchId = cid
      if g_LocalPlayer:getCatchStars(fbId, cid, iSuper) < 0 then
        break
      end
    end
    return maxCatchId
  end
end
