local netmap = {}
function netmap.playerMove(param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local mapId = param.i_scene
  local pPos = param.t_loc
  local isHide = param.i_h
  local posType = param.i_p
  local forceJumpMap = param.i_f
  local flag = param.i_flag
  if isHide == 1 then
    isHide = true
  else
    isHide = false
  end
  if flag == nil then
    flag = 0
  end
  print("netmap.playerMove:", param, ptc_main, ptc_sub, forceJumpMap)
  if forceJumpMap == 1 and g_LocalPlayer ~= nil and pid == g_LocalPlayer:getPlayerId() then
    if posType == nil then
      posType = MapPosType_PixelPos
    end
    g_MapMgr:LoadMapById(mapId, pPos, posType, nil, true)
  else
    g_MapMgr:PlayerMove(pid, mapId, flag, pPos, isHide, posType, forceJumpMap)
  end
end
function netmap.playerInfo(param, ptc_main, ptc_sub)
  print("netmap.playerInfo:", param.i_pid, param.s_name, param.i_orgid, ptc_main, ptc_sub)
  local pid = param.i_pid
  local paramTable = {}
  paramTable.name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  paramTable.roleTypeId = param.i_rtype
  paramTable.roleZS = param.i_zs
  paramTable.roleLevel = param.i_level
  paramTable.orgjobid = param.i_orgjobid
  paramTable.orgname = CheckStringIsLegal(param.i_orgname, true, REPLACECHAR_FOR_INVALIDNAME)
  paramTable.orgid = param.i_orgid
  paramTable.chibang = param.i_c
  paramTable.bsTypeId = param.i_rtype2 or 0
  paramTable.bzhdTypeId = param.i_rtype3 or 0
  paramTable.zghdTypeId = param.i_zg or 0
  paramTable.zqTypeId = param.i_zqshape or 0
  paramTable.freezeTime = param.freezetime
  paramTable.t_re = param.t_re
  if pid == g_LocalPlayer:getPlayerId() then
    local role = g_LocalPlayer:getMainHero()
    if role then
      local bzhdTypeId = 0
      if paramTable.bzhdTypeId ~= nil then
        bzhdTypeId = paramTable.bzhdTypeId
        role:setProperty(PROPERTY_HUODONGBIANSHENG, bzhdTypeId)
      else
        role:setProperty(PROPERTY_HUODONGBIANSHENG, 0)
      end
      local zghdTypeId = 0
      if paramTable.zghdTypeId ~= nil then
        zghdTypeId = paramTable.zghdTypeId
        role:setProperty(PROPERTY_ZHENGGUBIANSHENG, zghdTypeId)
      else
        role:setProperty(PROPERTY_ZHENGGUBIANSHENG, 0)
      end
      if paramTable.freezeTime ~= nil then
        role:setProperty(PROPERTY_MAGICFREEZETIME, paramTable.freezeTime)
      else
        role:setProperty(PROPERTY_MAGICFREEZETIME, 0)
      end
      if paramTable.t_re ~= nil then
        role:setProperty(PROPERTY_ROLE_ZHUANGSHILIST, paramTable.t_re)
      else
        role:setProperty(PROPERTY_ROLE_ZHUANGSHILIST, 0)
      end
      local zqTypeId = 0
      if paramTable.zqTypeId ~= nil then
        role:setProperty(PROPERTY_MAPZuoqiTypeId, paramTable.zqTypeId)
      else
        role:setProperty(PROPERTY_MAPZuoqiTypeId, 0)
      end
      SendMessage(MsgID_HeroUpdate, {
        pid = pid,
        heroId = role:getObjId(),
        pro = {
          [PROPERTY_HUODONGBIANSHENG] = bzhdTypeId,
          [PROPERTY_ZHENGGUBIANSHENG] = zghdTypeId,
          [PROPERTY_MAPZuoqiTypeId] = zqTypeId
        }
      })
    end
  end
  if param.i_fly == nil or param.i_fly == 0 then
    paramTable.jsEndTime = 0
  else
    paramTable.jsEndTime = g_DataMgr:getServerTime() + param.i_fly
  end
  if param.t_r then
    paramTable.colorData = DeepCopyTable(param.t_r)
  end
  if pid == nil then
    printLog("ERROR", "数据出错，需要新号才能显示其他玩家")
  else
    g_MapMgr:recivePlayerInfo(pid, paramTable)
  end
  local wcId = param.i_t
  if pid ~= nil and wcId ~= nil then
    local player = g_DataMgr:getPlayer(pid)
    if player then
      player:syncChengweiInfo(wcId, param.s_mn)
    end
  end
end
function netmap.dynamicNpc(param, ptc_main, ptc_sub)
  print("netmap.dynamicNpc:", param, ptc_main, ptc_sub)
  g_MapMgr:updateDynamicNpc(param)
end
function netmap.updateStatus(param, ptc_main, ptc_sub)
  print("netmap.updateStatus:", param, ptc_main, ptc_sub)
  if param then
    g_MapMgr:PlayerWarStatusChanged(param.i_pid, param.i_s, param.i_t)
  end
end
function netmap.addMapTreasure(param, ptc_main, ptc_sub)
  print("netmap.addMapTreasure:", param, ptc_main, ptc_sub)
  g_BpWarMgr:addMapTreasure(param)
  g_MapMgr:addMapTreasure(param)
end
function netmap.delMapTreasure(param, ptc_main, ptc_sub)
  print("netmap.delMapTreasure:", param, ptc_main, ptc_sub)
  if param.id == nil then
    return
  end
  g_BpWarMgr:delMapTreasure(param.sceneid, param.id)
  g_MapMgr:delDynamicTreasure(param.sceneid, param.id)
  if param.reason == 1 then
    CloseGoldBoxViewDlg(param.id)
  end
end
function netmap.cangbaotuMonsterMessage(param, ptc_main, ptc_sub)
  print("netmap.cangbaotuMonsterMessage:", param, ptc_main, ptc_sub)
  local name = CheckStringIsLegal(param.s, true, REPLACECHAR_FOR_INVALIDNAME)
  local mapId = param.d
  local monsterId = param.m
  local x, y = g_MapMgr:TranslatePosFromEdirtorPos2GridPos(mapId, param.x, param.y)
  local _, monsterName = data_getRoleShapeAndName(monsterId)
  local mapinfo = data_MapInfo[mapId] or {}
  local mapName = mapinfo.name
  local msg = string.format("#<Y>%s#在挖宝中不小心把妖怪#<Y>%s#引出来了【#<Y>%s#(%d,%d)】", name, monsterName, mapName, x, y)
  g_MessageMgr:receiveKuaixunMessage(msg)
end
function netmap.updateSceneSyncTypes(param, ptc_main, ptc_sub)
  print("netmap.updateSceneSyncTypes:", param, ptc_main, ptc_sub)
  if param ~= nil and param.t_plots ~= nil and g_MapMgr then
    g_MapMgr:setSceneSyncType(param.t_plots)
  end
end
function netmap.onQueryPlayerBangPaiInfo(param, ptc_main, ptc_sub)
  print("netmap.onQueryPlayerBangPaiInfo:", param, ptc_main, ptc_sub)
  g_BpMgr:setBangPaiCacheData(param.pid, param.name)
  SendMessage(MsgID_BP_OtherPlayerBPInfo, param.pid, param.name)
end
return netmap
