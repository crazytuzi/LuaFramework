MissionMgr = class(".MissionMgr")
local all_mission_kind = {
  MissionKind_Main,
  MissionKind_Branch,
  MissionKind_Shimen,
  MissionKind_Faction,
  MissionKind_Activity,
  MissionKind_Jingying,
  MissionKind_Guide,
  MissionKind_Shilian,
  MissionKind_SanJieLiLian,
  MissionKind_Jiehun,
  MissionKind_Jieqi
}
local needTipsItem = {
  [71997] = 1,
  [71998] = 1,
  [71999] = 1,
  [72000] = 1,
  [72001] = 1,
  [72002] = 1
}
function MissionMgr:ctor()
  self.m_AcceptedMissionId = {}
  self.m_CompletedMaxMission = {}
  self.m_CmpMissionId = {}
  for i, v in ipairs(all_mission_kind) do
    self.m_AcceptedMissionId[v] = {}
    self.m_CompletedMaxMission[v] = 0
  end
  self.m_LastAcceptMissionId = nil
  self.m_ReqCompletedMissions = {}
  self.m_CurTraceMissionId = 0
  self.m_MissionStatusForNpc = {}
  self.m_MissionStatusWithNpc = {}
  self.m_MissionCmpShotageObjId = {}
  self.m_MapMonsterForMissions = {}
  self.m_NeedMapMonsterMissions = {}
  self.m_AutoShowDoubleViewTimes = {}
  self.m_HasAddDoubleExpFlag = false
  self.m_CanUseObjType = {
    [MissionType_CollectInWar] = 1,
    [MissionType_KillInWar] = 1,
    [MissionType_WarForObjWithMonster] = 1,
    [MissionType_GetObjByNpc] = 1,
    [MissionType_UseObjInMap] = 1,
    [MissionType_GiveObjToNpc] = 1
  }
  self.m_NeedCreateMonsterType = {
    [MissionType_WarForObjWithMonster] = 1,
    [MissionType_WarWithMapMonster] = 1,
    [MissionType_Tianing] = 1,
    [MissionType_SanJieLiLian] = 1,
    [MissionType_BangPaiChuMo] = 1,
    [MissionType_BangPaiAnZhan] = 1
  }
  GuideMgrExtend.extend(self)
  self.m_GuideDetectIds = {}
  self.m_UpdateGuideDetectHandler = scheduler.scheduleGlobal(handler(self, self.updateGuideDetect), 1)
  self.m_NeedUpdateProgressOjbs = {}
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_Pvp)
  self:ListenMessage(MsgID_MapLoading)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_ItemInfo)
  self.m_NeedAutoTraceMissionId = nil
  self.m_tempMissionUpdate = {}
  self.guidefb = nil
end
function MissionMgr:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  local fid = self:GetFIDWithSID(msgSID)
  if fid == MsgID_MapLoading then
    self:MapLoadMessageForGuide(msgSID, ...)
  elseif msgSID == MsgID_HeroUpdate then
    local playerId = arg[1].pid
    local heroId = arg[1].heroId
    local player = g_DataMgr:getPlayer(playerId)
    if playerId ~= g_LocalPlayer:getPlayerId() then
      return
    end
    if player == nil or heroId == nil then
      return
    end
    local lv = arg[1].pro[PROPERTY_ROLELEVEL]
    local zs = arg[1].pro[PROPERTY_ZHUANSHENG]
    if lv ~= nil or zs ~= nil then
      print("missioncheck    ", zs, lv, "Z:" .. tostring(self.tempZs), "LV:" .. tostring(self.tempLv))
      if self.tempLv == nil then
        self.tempLv = lv
      elseif lv ~= nil and lv > self.tempLv then
        print("要升级了 ***************** ")
        local chumoUnZs, chumoUnLv = BangPaiChuMo.getUnLockLevel()
        local anzhanUnZs, anzhanUnLv = BangPaiAnZhan.getUnLockLevel()
        local mainHeroIns = g_LocalPlayer:getMainHero()
        if mainHeroIns then
          local cZS = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
          local cLV = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
          if chumoUnLv == lv and cZS == chumoUnZs then
            BangPaiChuMo.setLevelLimited(true)
            if g_BpMgr:localPlayerHasBangPai() == true then
              BangPaiChuMo.serviceState = true
            end
          end
          if anzhanUnLv == lv and anzhanUnZs == cZS then
            BangPaiAnZhan.setLevelLimited(true)
            if g_BpMgr:localPlayerHasBangPai() == true then
              BangPaiAnZhan.hadDone = false
            end
          end
        end
      end
      self:FlushCanAcceptMission()
      activity.tbsj:UpdateTBSJMissionState()
    end
  elseif msgSID == MsgID_NewZuoqi then
    g_MissionMgr:GuideIdComplete(GuideId_Zuoqi)
  elseif msgSID == MsgID_Pvp_WarCompleted then
    g_MissionMgr:GuideIdComplete(GuideId_Biwu)
  elseif msgSID == MsgID_MoneyUpdate then
    local argData = arg[1] or {}
    if argData.newGold ~= nil then
      self:objectNumChanged(RESTYPE_GOLD)
    end
    if argData.newCoin ~= nil then
      self:objectNumChanged(RESTYPE_COIN)
    end
    if argData.newSilver ~= nil then
      self:objectNumChanged(RESTYPE_SILVER)
    end
  elseif msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_DelItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    local itemType = arg[3]
    if msgSID == MsgID_ItemInfo_DelItem then
      itemType = arg[2]
    end
    if itemType then
      self:objectNumChanged(itemType)
    end
    self:FlushCanAcceptMission()
  elseif msgSID == MsgID_ItemInfo_TakeEquip or msgSID == MsgID_ItemInfo_TakeDownEquip then
    print("======装备 穿脱 ")
    local objId = arg[2]
    if objId then
      local itemIns = g_LocalPlayer:GetOneItem(objId)
      if itemIns then
        self:objectNumChanged(itemIns:getTypeId())
      end
    end
    if self.m_tempMissionUpdate and msgSID == MsgID_ItemInfo_TakeEquip then
      if self.m_tempMissionUpdate[70021] and g_LocalPlayer:getHasHoleItem() == true then
        local updateData = self.m_tempMissionUpdate[70021]
        if updateData[1] == 1 then
          self:Server_MissionUpdated(70021, updateData[1], updateData[2])
        elseif updateData[1] == 0 then
          self:Server_MissionAccepted(70021)
        end
        self.m_tempMissionUpdate[70021] = nil
      end
    elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
      local pro, tb, cp = self:getMissionProgress(70021)
      if pro ~= nil and tb ~= nil and cp ~= nil then
        self.m_tempMissionUpdate[70021] = {pro, tb}
        self:Server_GiveUpMission(70021)
      end
    end
  elseif msgSID == MsgID_ServerTime then
    print("--->> 服务器时间改变，重新刷新")
    self.m_ReqCompletedMissions = {}
    self:flushMissionStatusForNpc()
    SendMessage(MsgID_Mission_Common)
  elseif msgSID == MsgID_ServerDailyClean then
    print("--->> \n\n 服务器每天更新了!!")
    Shimen.today_times = 0
    Shimen.update({state = 0})
    CDaTingCangBaoTu.taskid = nil
    CDaTingCangBaoTu.loc_id = nil
    CDaTingCangBaoTu.war_data_id = nil
    CDaTingCangBaoTu.cnt = 0
    activity.event:reset()
  elseif msgSID == MsgID_BP_PaoShang then
    if arg[1] == nil then
      print("==========>> 跑商次数请求数据失败")
      return
    end
    BangPaiPaoShang.setCircle(arg[1])
    self:FlushCanAcceptMission()
  elseif msgSID == MsgID_BP_LocalInfo then
    print("刷新 帮派信息 ")
    self:FlushCanAcceptMission()
  elseif msgSID == MsgID_Scene_War_Exit then
    print("退出战斗")
    do
      local arg = {
        ...
      }
      local warType = arg[2]
      local isWatch = arg[3]
      local isReview = arg[4]
      local warResult = arg[5]
      self:_EndWarForAutoTrace()
      scheduler.performWithDelayGlobal(function()
        CDaTingCangBaoTu.ContinueMission(warType, isWatch, isReview, warResult)
      end, 0.5)
    end
  end
end
function MissionMgr:clearDynamicNpc()
  BangPaiTotem.taskDel()
  BangPaiChuMo.deleteTask()
  print(" 清除帮派任务的npc  //////////////////////  ", 1)
  if self.m_AcceptedMissionId ~= nil then
    print(" 清除帮派任务的npc  //////////////////////  ", 2)
    for i1, v1 in ipairs(all_mission_kind) do
      local md = self.m_AcceptedMissionId[v1]
      if md ~= nil then
        for k, v in pairs(md) do
          print(" 清除帮派任务的npc  ////////////////////// 3    ", k)
          local mapView = g_MapMgr:getMapViewIns()
          if mapView ~= nil then
            print(" 清除帮派任务的npc  //////////////////////  ", k)
            mapView:DeleteMonsterByMissionId(k)
          end
        end
      end
    end
  end
end
function MissionMgr:clearAcceptedMission()
  self:clearDynamicNpc()
  if self.m_AcceptedMissionId and type(self.m_AcceptedMissionId) == "table" then
    print(" 清除任务数据中 ........... ")
    for k, v in pairs(self.m_AcceptedMissionId) do
      self.m_AcceptedMissionId[k] = {}
    end
  end
end
function MissionMgr:getMissionProgress(missionId)
  local missionKind = getMissionKind(missionId)
  local md = self.m_AcceptedMissionId[missionKind]
  if md == nil then
    return nil
  end
  local missionPro = md[missionId]
  if missionPro == nil then
    return nil
  end
  return missionPro.finished, missionPro.param, missionPro.complete
end
function MissionMgr:getDstData(dataTable, missionPro)
  if dataTable == nil or missionPro == nil then
    return {}
  end
  if missionPro < 1 then
    return dataTable.dst1
  elseif missionPro == 1 then
    return dataTable.dst2
  end
end
function MissionMgr:getMissionKindName(missionId, missionKind)
  if self:isTiantingMissionId(missionId) or self:isDayantaMissionId(missionId) or self:isTianDiQiShuMissionId(missionId) then
    return "副本"
  end
  if missionId == TBSJ_MissionId then
    return "活动"
  end
  if missionKind == nil then
    missionKind = getMissionKind(missionId)
  end
  return MissionKind_Des[missionKind]
end
function MissionMgr:getMissionShowParam(missionId)
  print("getMissionShowParam-->", missionId)
  local dataTable, missionKind = self:getMissionData(missionId)
  local missionPro, curParam = self:getMissionProgress(missionId)
  curParam = curParam or {}
  local dst = self:getDstData(dataTable, missionPro)
  if dst == nil then
    print("[ERROR] getMissionShowParam 报错了!")
    print("missionId:", missionId)
    print("missionPro:", missionPro)
    dump(dataTable, "dataTable")
    dump("self.m_AcceptedMissionId", "self.m_AcceptedMissionId")
    return nil
  end
  local curType = dst.type
  local needWar = Mission_NeedWar[curType] == 1
  local dstDes = ""
  if curType == MissionType_ZhuaGui then
    local mapName = ""
    local mapId = g_LocalPlayer._zg_mapInfo[1]
    if mapId then
      local mapData = data_MapInfo[mapId]
      if mapData then
        mapName = mapData.name
      end
    end
    local monsterId = g_LocalPlayer:getZhuaGuiShowMonsterId()
    local _, monsterName = data_getRoleShapeAndName(monsterId)
    if mapName ~= nil and monsterName ~= nil then
      dstDes = string.format("去#<Y>%s#超度#<Y>%s#", mapName, monsterName)
    else
      dstDes = "去超度鬼魂"
    end
  elseif curType == MissionType_GuiWang then
    dstDes = GuiWang.MissionDes
  elseif curType == MissionType_XiuLuo then
    local mapName = ""
    if g_LocalPlayer and g_LocalPlayer._xl_mapInfo and g_LocalPlayer._xl_mapInfo[1] then
      local mapId = g_LocalPlayer._xl_mapInfo[1]
      local mapData = data_MapInfo[mapId]
      if mapData then
        mapName = mapData.name
      end
    end
    local monsterId = g_LocalPlayer:getXiuLuoShowMonsterId()
    local _, monsterName = data_getRoleShapeAndName(monsterId)
    if mapName ~= nil and monsterName ~= nil then
      dstDes = string.format("去#<Y>%s#消灭#<Y>%s#", mapName, monsterName)
    else
      dstDes = "去消灭修罗"
    end
  elseif curType == MissionType_BangPaiTotem then
    local totemId = g_LocalPlayer:getBangPaiTotemId()
    local locid = g_LocalPlayer:getBangPaiTotemLocId()
    local name = data_getTotemMonsterNameAndPos(totemId)
    local gong = ""
    if data_CustomMapPos[locid] then
      gong = data_CustomMapPos[locid].Name
    end
    dstDes = string.format("去#<Y>%s#唤醒#<Y>%s#", gong, name)
  elseif curType == MissionType_TBSJ then
    needWar = true
    dstDes = activity.tbsj:GetTBSJMissionItemTarget()
  elseif curType == MissionType_JiehunSjzf then
    dstDes = dst.des
    if g_HunyinMgr then
      local proc, target = g_HunyinMgr:getZhufuProc()
      if proc ~= nil and target ~= nil then
        if proc < target then
          dstDes = string.format("%s#<R>(%d/%d)#", dstDes, proc, target)
        else
          dstDes = string.format("%s#<G>(%d/%d)#", dstDes, proc, target)
        end
      end
    end
  elseif missionPro == MissionPro_NotAccept then
    dstDes = dataTable.acceptDes
    needWar = false
  elseif dst then
    dstDes = dst.des
    if Mission_Show_Objs[curType] == 1 then
      local objList = dst.param or {}
      for i, obj in ipairs(objList) do
        local objId, sum = obj[1], obj[2]
        local curNum = 0
        for idx, objListTemp in ipairs(curParam) do
          if objListTemp[1] == objId then
            curNum = objListTemp[2]
          end
        end
        if sum > curNum then
          dstDes = string.format("%s#<R>(%d/%d)#", dstDes, curNum, sum)
        else
          dstDes = string.format("%s#<G>(%d/%d)#", dstDes, curNum, sum)
        end
        if (Shimen.isMissionId(missionId) == true or SanJieLiLian.isMissionId(missionId) == true) and needTipsItem[objId] == 1 then
          dstDes = dstDes .. ",挂机地图可掉落"
        end
      end
    end
  end
  if SanJieLiLian.isMissionId(missionId) then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_SanJieLiLian)
    if openFlag ~= true then
      local data = data_FunctionUnlock[OPEN_Func_SanJieLiLian] or {}
      local lv = data.lv or 50
      return string.format("提升等级至%d", lv), needWar, dst
    end
  end
  return dstDes, needWar, dst
end
function MissionMgr:getCanTraceMission()
  local ids = {}
  local hasMainMission = false
  for i, mk in ipairs(all_mission_kind) do
    local md = self.m_AcceptedMissionId[mk] or {}
    for k, v in pairs(md) do
      if v.finished ~= MissionPro_NotAccept then
        ids[#ids + 1] = k
        if hasMainMission == false and mk == MissionKind_Main then
          hasMainMission = true
        end
      end
    end
  end
  table.sort(ids, function(id1, id2)
    if id1 == nil or id2 == nil then
      return false
    end
    local istt1 = g_MissionMgr:isTiantingMissionId(id1)
    local istt2 = g_MissionMgr:isTiantingMissionId(id2)
    if istt1 == true and istt2 == true then
      return id1 < id2
    elseif istt1 == true then
      return true
    elseif istt2 == true then
      return false
    else
      return id1 < id2
    end
  end)
  return ids, hasMainMission
end
function MissionMgr:getCanAcceptMission(appointKinds)
  if appointKinds then
    local d = {}
    for i, v in ipairs(appointKinds) do
      d[v] = true
    end
    appointKinds = d
  end
  local ids = {}
  for i, v in ipairs(all_mission_kind) do
    if appointKinds == nil or appointKinds[v] == true then
      local md = self.m_AcceptedMissionId[v]
      local _ids = {}
      for k, v in pairs(md) do
        if v.finished == MissionPro_NotAccept then
          _ids[#_ids + 1] = k
        end
      end
      table.sort(_ids)
      for i1, v1 in ipairs(_ids) do
        ids[#ids + 1] = v1
      end
    end
  end
  return ids
end
function MissionMgr:getNpcMissionOption(npcId)
  local options = {}
  local shimenNpcId = g_LocalPlayer:getShimenNpcId()
  for i, mk in ipairs(all_mission_kind) do
    if shimenNpcId == npcId and mk == MissionKind_Shimen then
    elseif SanJieLiLian.MissionNPCId == npcId and MissionKind_SanJieLiLian == mk then
    else
      local md = self.m_AcceptedMissionId[mk]
      local _ids = {}
      for k, finished in pairs(md) do
        _ids[#_ids + 1] = k
      end
      table.sort(_ids)
      for i1, missionId in ipairs(_ids) do
        if npcId == BangPaiChuMo.getNpcId() and (missionId == BangPaiChuMo_MissionId or missionId == BangPaiAnZhan_MissionId) then
        elseif npcId == 90020 and missionId == Business_MissionId then
        elseif missionId == TBSJ_MissionId then
          local dataTable = self:getMissionData(missionId)
          local missionPro = self:getMissionProgress(missionId)
          if missionPro == MissionPro_NotAccept then
          else
            local tbsjNpcId = activity.tbsj:GetTBSJNpcId()
            if npcId == tbsjNpcId then
              options[#options + 1] = {
                "发起挑战",
                missionId
              }
            end
          end
        else
          local dataTable = self:getMissionData(missionId)
          if dataTable ~= nil then
            local missionPro = self:getMissionProgress(missionId)
            if missionPro == MissionPro_NotAccept then
              if self:convertNpcId(dataTable.startNpc) == npcId then
                options[#options + 1] = {
                  self:convertMissionName(dataTable.mnName, missionId, true),
                  missionId
                }
              end
            else
              local dst = self:getDstData(dataTable, missionPro)
              if dst and Mission_NeedNpc[dst.type] and self:convertNpcId(dst.data) == npcId then
                options[#options + 1] = {
                  self:convertMissionName(dataTable.mnName, missionId, true),
                  missionId
                }
              end
            end
          end
        end
      end
    end
  end
  return options
end
function MissionMgr:getMissionName(missionId)
  print("MissionMgr:getMissionName:", missionId)
  local dataTable = self:getMissionData(missionId)
  if dataTable == nil then
    return nil
  end
  return self:convertMissionName(dataTable.mnName, missionId)
end
function MissionMgr:autoCmpNpcMissionOption(npcId)
  if g_LocalPlayer == nil then
    return false
  end
  local options = {}
  local shimenNpcId = g_LocalPlayer:getShimenNpcId()
  for missionId, status in pairs(self.m_MissionStatusWithNpc) do
    if status == MapRoleStatus_TaskCanCommit then
      local dataTable = self:getMissionData(missionId)
      if dataTable ~= nil then
        local missionPro, param, complete = self:getMissionProgress(missionId)
        local curDst = self:getDstData(dataTable, missionPro)
        local curType = curDst.type
        local isNeedShow = false
        if Mission_Show_Objs[curType] == 1 then
          if complete == true then
            isNeedShow = true
          end
        elseif missionPro ~= MissionPro_NotAccept then
          isNeedShow = true
        end
        if isNeedShow == true then
          local dst = self:getDstData(dataTable, missionPro)
          if dst and Mission_NeedNpc[dst.type] and self:convertNpcId(dst.data) == npcId and true == self:MissionOptionTouched(missionId, npcId, nil) then
            return true
          end
        end
      end
    end
  end
  return false
end
function MissionMgr:ShowNormalNpcView(npcId)
  if g_MissionMgr:autoCmpNpcMissionOption(npcId) == false then
    CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
  end
end
function MissionMgr:convertMissionName(name, missionId, isNpcOption, flag)
  local missionKind = getMissionKind(missionId)
  if self:isTiantingMissionId(missionId) then
    local cur, sum = activity.tianting:getWarWithMissionId(missionId)
    name = string.format("%s(%d/%d)", name, cur, sum)
  elseif missionKind == MissionKind_Shimen then
    local t = Shimen.today_times + 1
    name = string.format("%s(%d/%d)", name, t, Shimen.Limei_Times)
  elseif missionKind == MissionKind_SanJieLiLian then
    if flag then
      name = string.format("%s(%d/%d)", name, SanJieLiLian.today_times + 1, SanJieLiLian.Limei_Times)
    else
      name = SanJieLiLian.getDesTitle(missionId)
      name = string.format("%s(%d/%d)", name, SanJieLiLian.today_times + 1, SanJieLiLian.Limei_Times)
    end
  elseif missionKind == MissionKind_Faction then
    if missionId == Business_MissionId then
      name = string.format("%s", name)
    elseif missionId == BangPaiAnZhan.MissionId then
    end
  elseif missionId == ExchangeMissionId then
    local packageNum = g_LocalPlayer:GetItemNum(ITEM_DEF_STUFF_CYJZ)
    local needNum = 5
    name = string.format("%s(%d/%d)", name, packageNum, needNum)
  elseif missionId == DaTingCangBaoTu_MissionId then
    if CDaTingCangBaoTu.cnt == nil then
      local progress = 0
      name = string.format("%s(%d/%d)", name, progress, DaTingCangBaoTu_MaxCircle)
    else
      name = string.format("%s(%d/%d)", name, CDaTingCangBaoTu.cnt, DaTingCangBaoTu_MaxCircle)
    end
  elseif missionId == ZhuaGui_MissionId then
    local c = ZhuaGui.getCircel() or 1
    name = string.format("%s(%d/%d)", name, c, ZhuaGui_MaxCircle)
  elseif missionId == TBSJ_MissionId then
    local c = activity.tbsj:GetTBSJCircleNum() or 0
    if c < 0 then
      c = 0
    end
    if c > TBSJ_MaxCircle then
      c = TBSJ_MaxCircle
    end
    name = string.format("%s(%d/%d)", name, c, TBSJ_MaxCircle)
  elseif missionId == GuiWang_MissionId then
    local c = GuiWang.getCircel() or 1
    name = string.format("%s(%d/%d)", name, c, GuiWang_MaxCircle)
  elseif missionId == MissionKind_SanJieLiLian then
    local c = SanJieLiLian.getCircle() or 1
    name = string.format("%s(%d/%d)", name, c, SanJieLiLian.Limei_Times)
  elseif missionId == XiuLuo_MissionId then
    local c = XiuLuo.getCircel() or 1
    name = string.format("%s(%d/%d)", name, c, XiuLuo_MaxCircle)
  end
  return name
end
function MissionMgr:getNeedUpgradeStr()
  local dst = "提升更高等级继续任务"
  if g_LocalPlayer == nil then
    return dst
  end
  local mainHeroIns = g_LocalPlayer:getMainHero()
  if mainHeroIns then
    local lv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
    local zs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
    local nextLv = 0
    local nextZs = 0
    for k, mData in pairs(data_Mission_Main) do
      local t_zs = mData.zs
      local t_lv = mData.lv
      if t_zs == zs and lv < t_lv then
        if nextLv == 0 or nextLv > t_lv then
          nextLv = t_lv
        end
      elseif zs < t_zs then
        nextZs = t_zs
      end
    end
    if nextLv ~= 0 then
      if nextLv == lv then
        nextLv = lv + 1
      end
      dst = string.format("提升到#<r:0,g:255,b:0>%d级#继续任务", nextLv)
    elseif nextZs ~= 0 then
      dst = string.format("提升到#<r:0,g:255,b:0>%d转#继续任务", nextZs)
    end
  end
  return dst
end
function MissionMgr:canMissionObjUse(missionObjId)
  for i, mk in ipairs(all_mission_kind) do
    local md = self.m_AcceptedMissionId[mk]
    local _ids = {}
    for missionId, finished in pairs(md) do
      local missionPro = self:getMissionProgress(missionId)
      if missionPro ~= MissionPro_NotAccept then
        local dataTable = self:getMissionData(missionId)
        local dst = self:getDstData(dataTable, missionPro)
        if dst.type == MissionType_UseObjInMap then
          for i, param in ipairs(dst.param) do
            if param[1] == missionObjId then
              local mapInfo = dst.data
              if mapInfo[1] == g_MapMgr:getCurMapId() then
                local dx, dy = g_MapMgr:convertPosInMap({
                  mapInfo[2],
                  mapInfo[3]
                }, MapPosType_EditorGrid)
                local cx, cy = g_MapMgr:getLocalPlayerPos()
                if cx ~= nil and cy ~= nil and dx ~= nil and dy ~= nil then
                  local dis = math.sqrt(math.pow(dx - cx, 2) + math.pow(dy - cy, 2))
                  if dis <= 50 then
                    return true
                  end
                end
              end
              return false, missionId
            end
          end
        elseif self.m_CanUseObjType[dst.type] == 1 then
          for i, param in ipairs(dst.param) do
            if param[1] == missionObjId then
              return false, missionId
            end
          end
        end
      end
    end
  end
  return false
end
function MissionMgr:MissionOptionTouched(missionId, npcId, npcViewIns)
  local dataTable, missionKind = self:getMissionData(missionId)
  if dataTable == nil or missionKind == nil then
    return false
  end
  local missionPro, curParam = self:getMissionProgress(missionId)
  if missionPro == nil then
    return false
  end
  if self.m_ReqCompletedMissions[missionId] == 1 then
    printLog("WARNNING", "NPC窗口的选项被选择,[%s]任务正在请求完成中...", tostring(missionId))
    return false
  end
  local ret = false
  local isCloseNpcView = true
  if missionPro == MissionPro_NotAccept then
    if missionKind == MissionKind_Shimen then
      Shimen.GotoShimenNpc()
    elseif missionKind == MissionKind_SanJieLiLian then
      print("三界历练 ")
      SanJieLiLian.lastTalkNpcId = 90016
      SanJieLiLian.reqAccept()
    elseif missionKind == MissionKind_Faction then
      if missionId == Business_MissionId and BangPaiPaoShang.taskid ~= nil then
        BangPaiPaoShang.reqAccept()
      end
    else
      if missionId == ZhuaGui_MissionId then
        print("抓鬼任务")
        isCloseNpcView = ZhuaGui.reqAccept()
      elseif missionId == GuiWang_MissionId then
        print("鬼王任务")
        isCloseNpcView = GuiWang.reqAccept()
      elseif missionId == ExchangeMissionId then
        print("兑换奖章任务")
        activity.dayanta:reqAccept()
      elseif missionId == XiuLuo_MissionId then
        isCloseNpcView = XiuLuo.reqAccept()
      else
        self:_OptionDeal_NotAccept(missionId, dataTable)
      end
      ret = true
    end
  elseif g_HunyinMgr and g_HunyinMgr:canTraceMission(missionId) == false then
  else
    do
      local dst = self:getDstData(dataTable, missionPro)
      local missionType = dst.type
      local f = self["_OptionDeal_" .. tostring(missionType)]
      if f then
        local function callOptionDealFunc()
          f(self, missionId, missionPro, dataTable, dst, npcId, npcViewIns, curParam)
        end
        local talkId = dst.talkId
        if talkId then
          if (missionId == MarryMission_Bless or missionId == MarryMission_HunYan) and self:detectMissionDstColloctComplete(missionId, dst, curParam) == false then
            local tf = self["_TrackCtrl_" .. tostring(missionType)]
            if tf and type(tf) == "function" then
              tf(self, missionId, dataTable, dst, missionPro, curParam)
            end
            return
          end
          getCurSceneView():ShowTalkView(talkId, callOptionDealFunc, missionId)
        else
          callOptionDealFunc()
        end
        ret = true
      else
        printLog("ERROR", "NPC窗口中的任务类型还没有实现[%d]", missionType)
      end
    end
  end
  if isCloseNpcView and npcViewIns then
    if missionId ~= ExchangeMissionId then
      scheduler.performWithDelayGlobal(function()
        npcViewIns:CloseSelf()
      end, 0.01)
    else
      SendMessage(MsgID_Mission_NpcView)
    end
  end
  return ret
end
function MissionMgr:_OptionDeal_NotAccept(missionId, dataTable)
  local talkId = dataTable.acceptTalkId
  if talkId > 0 then
    getCurSceneView():ShowTalkView(talkId, function()
      self:sendReq_Accept(missionId)
    end, missionId)
  else
    self:sendReq_Accept(missionId)
  end
end
function MissionMgr:_OptionDeal_101(missionId, missionPro, dataTable, dst, npcId, npcViewIns, curParam)
  self:TalkFinishForTalkMission(missionId, dataTable, dst, npcId)
end
function MissionMgr:_OptionDeal_301(missionId, missionPro, dataTable, dst, npcId, npcViewIns, curParam)
  self:ReqMissionCmp(missionId, dst.type, dst.data)
end
function MissionMgr:_OptionDeal_402(missionId, missionPro, dataTable, dst, npcId, npcViewIns, curParam)
  print("================================>>>1   MissionMgr:_OptionDeal_402 ", missionId)
  if self:detectMissionDstColloctComplete(missionId, dst, curParam) then
    self:ReqMissionCmp(missionId, dst.type, dst.data)
  end
end
function MissionMgr:_OptionDeal_802(missionId, missionPro, dataTable, dst, npcId, npcViewIns, curParam)
  SanJieLiLian.reqAccept()
end
function MissionMgr:_OptionDeal_803(missionId, missionPro, dataTable, dst, npcId, npcViewIns, curParam)
  SanJieLiLian.startAnser()
end
function MissionMgr:_OptionDeal_603(missionId, missionPro, dataTable, dst, npcId, npcViewIns, curParam)
  activity.tbsj:fightTBSJ()
end
function MissionMgr:getMissionParamForWar(fbId, catchId, iSuper)
  if iSuper == 0 then
    iSuper = false
  elseif iSuper == 1 then
    iSuper = true
  end
  return self:getMissionParamForWar_(1, {
    fbId,
    catchId,
    iSuper
  })
end
function MissionMgr:getMissionParamForWarWithId(warid)
  print("getMissionParamForWarWithId==>:", warid)
  return self:getMissionParamForWar_(2, warid)
end
function MissionMgr:getMissionParamForWar_(warType, warParam)
  local talkId, wfTalkId
  for i, mk in ipairs(all_mission_kind) do
    local md = self.m_AcceptedMissionId[mk]
    local _ids = {}
    for k, finished in pairs(md) do
      _ids[#_ids + 1] = k
    end
    table.sort(_ids)
    for i1, missionId in ipairs(_ids) do
      local dataTable = self:getMissionData(missionId)
      if dataTable ~= nil then
        local missionKind = getMissionKind(missionId)
        local md = self.m_AcceptedMissionId[missionKind] or {}
        local missionProData = md[missionId] or {}
        local missionPro = missionProData.finished
        local dst = self:getDstData(dataTable, missionPro)
        if dst and Mission_NeedWar[dst.type] then
          if warType == 1 then
            fbId, catchId, iSuper = unpack(warParam)
            print("getMissionParamForWar-->fbId, catchId, iSuper:", fbId, catchId, iSuper)
            if isListEqual(dst.data, warParam) then
              if missionProData.showTalkBeforeWar ~= true then
                talkId = dst.talkId
                missionProData.showTalkBeforeWar = true
              end
              wfTalkId = dst.wftalkId
              break
            end
          else
            local dstData = dst.data
            if type(dstData) == "table" and #dstData > 0 and warParam == dstData[1] then
              if missionProData.showTalkBeforeWar ~= true then
                talkId = dst.talkId
                missionProData.showTalkBeforeWar = true
              end
              wfTalkId = dst.wftalkId
            end
          end
        end
      end
    end
  end
  print("getMissionParamForWar-->talkID, warCompleteTalkId:", talkId, wfTalkId)
  if talkId ~= nil or wfTalkId ~= nil then
    return {
      talkID = talkId,
      closeFbWhenEnterWar = true,
      warCompleteTalkId = wfTalkId
    }
  end
  return nil
end
function MissionMgr:FlushCanAcceptMission()
  print("===>>> FlushCanAcceptMission")
  if g_DataMgr:getIsSendFinished() == false then
    return
  end
  if g_LocalPlayer == nil then
    print("g_LocalPlayer == nil")
    return
  end
  local mainHeroIns = g_LocalPlayer:getMainHero()
  if mainHeroIns == nil then
    print(" mainHeroIns == nil")
    return
  end
  local lv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
  local zs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
  if lv == nil or zs == nil then
    print("lv == nil or zs == nil")
    return
  end
  for i, mk in ipairs({
    MissionKind_Branch,
    MissionKind_Jingying,
    MissionKind_Shilian
  }) do
    local progress = self.m_CompletedMaxMission[mk]
    local acceptedData = self.m_AcceptedMissionId[mk]
    for mId, proData in pairs(acceptedData) do
      if proData.finished == MissionPro_NotAccept then
        acceptedData[mId] = nil
      end
    end
    if progress >= 0 then
      local dataTable_all = self:getMissionDataTable(nil, mk)
      if dataTable_all then
        for missionId, missionData in pairs(dataTable_all) do
          local needCmped = true
          local missionKind = getMissionKind(missionId)
          if self.m_CmpMissionId[missionId] ~= 1 and acceptedData[missionId] == nil then
            if missionKind == MissionKind_Shilian then
              if missionData.needCmp[1] ~= 0 and self.m_CmpMissionId[missionData.needCmp[1]] ~= 1 then
                needCmped = false
              end
            elseif #missionData.needCmp ~= 0 then
              needCmped = true
              for k, v in ipairs(missionData.needCmp) do
                if v ~= 0 and self.m_CmpMissionId[v] ~= 1 then
                  needCmped = false
                end
              end
            end
            if needCmped then
              local needZS = missionData.zs
              local needLV = missionData.lv
              if zs > needZS or zs == needZS and lv >= needLV then
                if missionData.startNpc == 0 then
                  print("没有开启NPC，自动接受")
                  self:sendReq_Accept(missionId)
                else
                  acceptedData[missionId] = {
                    finished = MissionPro_NotAccept,
                    param = {}
                  }
                  self:MissionTempNpcDetect(missionId, MissionPro_NotAccept)
                end
              end
            end
          end
        end
      end
    end
  end
  self:flushZhuaGuiCanAccept()
  self:flushGuiwangCanAccept()
  self:flushShimenCanAccept()
  self:flushSanJieLiLianCanAccept()
  self:flushDayantaExchangeCanAccept()
  self:flushBangPaiTotemCanAccept()
  self:flushBangPaiChuMoCanAccept()
  self:flushBangPaiPaoshangCanAccept()
  self:flushBangPaiAnZhanCanAccept()
  self:flushCangBaoTuCanAccept()
  self:flushXiuLuoCanAccept()
  self:flushMissionStatusForNpc()
end
function MissionMgr:flushTianBingShenJiangMission()
  print("==> flushTianBingShenJiangMission", TBSJ_MissionId)
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  activityData[TBSJ_MissionId] = {
    finished = activity.tbsj:GetTBSJMissionState(),
    param = {}
  }
end
function MissionMgr:delTianBingShenJiang()
  print("==> delTianBingShenJiang")
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  activityData[TBSJ_MissionId] = nil
  SendMessage(MsgID_Mission_MissionDel, TBSJ_MissionId)
end
function MissionMgr:flushZhuaGuiCanAccept()
  print("==> flushZhuaGuiCanAccept")
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  local zhuaGui = activityData[ZhuaGui_MissionId]
  local pro
  if zhuaGui then
    pro = zhuaGui.finished
  end
  print("==>> pro:", pro)
  if pro == nil and ZhuaGui.CanAccept() == true then
    activityData[ZhuaGui_MissionId] = {
      finished = MissionPro_NotAccept,
      param = {}
    }
    print("=====>> 可以接的任务[抓鬼任务]:", ZhuaGui_MissionId)
  end
end
function MissionMgr:delZhuaGui()
  print("==> delZhuaGui")
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  activityData[ZhuaGui_MissionId] = nil
  self:flushZhuaGuiCanAccept()
  self:flushMissionStatusForNpc()
  SendMessage(MsgID_Mission_MissionDel, ZhuaGui_MissionId)
end
function MissionMgr:flushGuiwangCanAccept()
  print("==> flushGuiwangCanAccept")
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  local missionProData = activityData[GuiWang_MissionId]
  local pro
  if missionProData then
    pro = missionProData.finished
  end
  print("==>> pro:", pro)
  if pro == nil and GuiWang.CanAccept() == true then
    activityData[GuiWang_MissionId] = {
      finished = MissionPro_NotAccept,
      param = {}
    }
    print("=====>> 可以接的任务[鬼王任务]:", GuiWang_MissionId)
  end
end
function MissionMgr:delGuiWang()
  print("==> delGuiWang")
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  activityData[GuiWang_MissionId] = nil
  self:flushGuiwangCanAccept()
  self:flushMissionStatusForNpc()
  SendMessage(MsgID_Mission_MissionDel, GuiWang_MissionId)
end
function MissionMgr:flushXiuLuoCanAccept()
  print("==> flushXiuLuoCanAccept")
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  local missionProData = activityData[XiuLuo_MissionId]
  local pro
  if missionProData then
    pro = missionProData.finished
  end
  print("==>> pro:", pro)
  if pro == nil and XiuLuo.CanAccept() == true then
    activityData[XiuLuo_MissionId] = {
      finished = MissionPro_NotAccept,
      param = {}
    }
    print("=====>> 可以接的任务[修罗之争]:", XiuLuo_MissionId)
  end
end
function MissionMgr:delXiuLuo()
  print("==> delXiuLuo")
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  activityData[XiuLuo_MissionId] = nil
  self:flushXiuLuoCanAccept()
  self:flushMissionStatusForNpc()
  SendMessage(MsgID_Mission_MissionDel, XiuLuo_MissionId)
end
function MissionMgr:flushSanJieLiLianCanAccept()
  print(" ====>>  flushSanJieLiLianCanAccept  ")
  if self.m_AcceptedMissionId == nil then
    self.m_AcceptedMissionId = {}
  end
  local lilianData = self.m_AcceptedMissionId[MissionKind_SanJieLiLian] or {}
  local liLian = lilianData[SanJieLiLian.AcceptMissionId]
  if SanJieLiLian.isAccepted() == false and SanJieLiLian.today_times < 1 then
    if g_LocalPlayer:isNpcOptionUnlock(1044) == true and SanJieLiLian.isTimesLevel() == true then
      lilianData[SanJieLiLian.AcceptMissionId] = {
        finished = MissionPro_NotAccept,
        param = {}
      }
      print("=====>> 可以接的任务[三界历练]:", SanJieLiLian.AcceptMissionId)
    else
      lilianData[SanJieLiLian.AcceptMissionId] = nil
    end
  else
    print("  已经接了，不用这里处理  SanJieLiLian.missionId_ = ")
    lilianData[SanJieLiLian.AcceptMissionId] = nil
  end
end
function MissionMgr:delSanJieLiLian(missionId)
  local activityData = self.m_AcceptedMissionId[MissionKind_SanJieLiLian] or {}
  activityData[missionId] = nil
  SendMessage(MsgID_Mission_MissionDel, missionId)
end
function MissionMgr:flushShimenCanAccept()
  print("==> flushShimenCanAccept")
  local shimenData = self.m_AcceptedMissionId[MissionKind_Shimen] or {}
  local shiMen = shimenData[Shimen.AcceptMissionId]
  if Shimen.isAccepted() == false then
    if g_LocalPlayer:isNpcOptionUnlock(1031) == true and Shimen.isTimesLevel() == true then
      shimenData[Shimen.AcceptMissionId] = {
        finished = MissionPro_NotAccept,
        param = {}
      }
      print("=====>> 可以接的任务[师门任务]:", Shimen.AcceptMissionId)
    else
      shimenData[Shimen.AcceptMissionId] = nil
    end
  else
    shimenData[Shimen.AcceptMissionId] = nil
  end
end
function MissionMgr:delShimen(missionId)
  local activityData = self.m_AcceptedMissionId[MissionKind_Shimen] or {}
  activityData[missionId] = nil
  SendMessage(MsgID_Mission_MissionDel, missionId)
end
function MissionMgr:flushDayantaExchangeCanAccept()
  print("==> flushDayantaExchangeCanAccept:", activity.dayanta:CanAccept())
  local activityData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  if activity.dayanta:CanAccept() == true then
    activityData[ExchangeMissionId] = {
      finished = MissionPro_NotAccept,
      param = {}
    }
    print("=====>> 可以接的任务[除妖奖章]:", ExchangeMissionId)
  end
end
function MissionMgr:flushBangPaiTotemCanAccept()
  print("==> flushBangPaiTotemCanAccept")
  local totemData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  local bpTotem = totemData[Totem_MissionId]
  local pro
  if bpTotem then
    pro = bpTotem.finished
  end
  print("==>> pro:", pro)
  if pro == nil and BangPaiTotem.CanAccept() == true then
    totemData[Totem_MissionId] = {
      finished = MissionPro_NotAccept,
      param = {}
    }
    print("=====>> 可以接的任务[图腾任务]:", Totem_MissionId)
  end
end
function MissionMgr:delBangPaiTotem()
  print("==> delBangPaiTotem")
  local totemData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  totemData[Totem_MissionId] = nil
  self:flushBangPaiTotemCanAccept()
  self:flushMissionStatusForNpc()
  SendMessage(MsgID_Mission_MissionDel, Totem_MissionId)
end
function MissionMgr:delBangPaiTaskToken(taskId)
  local tokenData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  tokenData[taskId] = nil
  SendMessage(MsgID_Mission_MissionDel, taskId)
end
function MissionMgr:flushBangPaiChuMoCanAccept()
  print("==> flushBangPaiChuMoCanAccept")
  local chumoData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  local bpChuMo = chumoData[BangPaiChuMo_MissionId]
  local pro
  if bpChuMo then
    pro = bpChuMo.finished
  end
  print("==>> pro:", pro, g_LocalPlayer:isNpcOptionUnlock(1057), BangPaiChuMo.getCanAcceptChuMo())
  if pro == nil then
    if BangPaiChuMo.getCanAcceptChuMo() and g_LocalPlayer:isNpcOptionUnlock(1057) == true then
      chumoData[BangPaiChuMo_MissionId] = {
        finished = MissionPro_NotAccept,
        param = {}
      }
      print("=====>> 可以接的任务[帮派除魔任务]:", BangPaiChuMo_MissionId)
    end
  elseif pro == -1 and BangPaiChuMo.getCanAcceptChuMo() == false then
    print("  ===============要删除 除魔的可接任务 了 ")
    bpChuMo.finished = nil
    chumoData[BangPaiChuMo_MissionId] = nil
  end
end
function MissionMgr:delBangPaiChuMo()
  local chuMoData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  chuMoData[BangPaiChuMo_MissionId] = nil
  self:flushMissionStatusForNpc()
  SendMessage(MsgID_Mission_MissionDel, BangPaiChuMo_MissionId)
end
function MissionMgr:flushBangPaiAnZhanCanAccept()
  print("==> flushBangPaiAnZhanCanAccept")
  local anzhanData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  local bpAnZhan = anzhanData[BangPaiAnZhan_MissionId]
  local pro
  if bpAnZhan then
    pro = bpAnZhan.finished
  end
  print("==>> pro:", pro)
  if pro == nil then
    if BangPaiAnZhan.getCanAcceptAnZhan() and g_LocalPlayer:isNpcOptionUnlock(1065) then
      anzhanData[BangPaiAnZhan_MissionId] = {
        finished = MissionPro_NotAccept,
        param = {}
      }
      print("=====>> 可以接的任务[帮派暗战任务]:", BangPaiChuMo_MissionId)
    end
  elseif pro == -1 and BangPaiAnZhan.getCanAcceptAnZhan() == false then
    bpAnZhan.finished = nil
    anzhanData[BangPaiAnZhan_MissionId] = nil
  end
end
function MissionMgr:delBangPaiAnZhan()
  print("删除暗战任务 =====》 ")
  local anZhanData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  anZhanData[BangPaiAnZhan_MissionId] = nil
  self:flushMissionStatusForNpc()
  SendMessage(MsgID_Mission_MissionDel, BangPaiAnZhan_MissionId)
end
function MissionMgr:flushBangPaiPaoshangCanAccept()
  print("==> fulusBangPaiPaoshangCanAccept", BangPaiPaoShang.isCanAccetp())
  local PaoShangData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  local isReachLv = BangPaiPaoShang.isReachNeedLevel()
  local bpPaoShang = PaoShangData[Business_MissionId]
  local pro
  if bpPaoShang then
    pro = bpPaoShang.finished
  end
  print("======>:", pro)
  if pro == nil and BangPaiPaoShang.isCanAccetp() == true and isReachLv == true and BangPaiPaoShang.getCircle() > 1 and BangPaiPaoShang.todayTimes > 0 then
    PaoShangData[Business_MissionId] = {
      finished = MissionPro_NotAccept,
      param = {}
    }
    print("======>> 可以接受的跑商任务", Business_MissionId)
  end
end
function MissionMgr:delBangPaiPaoShang()
  print("=====>> 删除跑商任务 :", Business_MissionId)
  local paoShangData = self.m_AcceptedMissionId[MissionKind_Faction] or {}
  paoShangData[Business_MissionId] = nil
  self:flushMissionStatusForNpc()
  g_MissionMgr:Server_MissionUpdated(Business_MissionId, 1, nil)
  SendMessage(MsgID_Mission_MissionDel, Business_MissionId)
end
function MissionMgr:delDaTingCangBaoTu()
  print("=====>> 删除打听藏宝图任务 :", DaTingCangBaoTu_MissionId)
  local CangBaoTuData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  CangBaoTuData[DaTingCangBaoTu_MissionId] = nil
  self:flushMissionStatusForNpc()
  g_MissionMgr:Server_MissionUpdated(DaTingCangBaoTu_MissionId, 1, nil)
  SendMessage(MsgID_Mission_MissionDel, DaTingCangBaoTu_MissionId)
end
function MissionMgr:flushCangBaoTuCanAccept()
  print("==> flushCangBaoTuCanAccept", CDaTingCangBaoTu.isCanAcceptMission())
  local CangBaoTuData = self.m_AcceptedMissionId[MissionKind_Activity] or {}
  local isReachLv = CDaTingCangBaoTu.isCanAcceptMission()
  local ActivityCangBaoTu = CangBaoTuData[DaTingCangBaoTu_MissionId]
  local pro
  if ActivityCangBaoTu then
    pro = ActivityCangBaoTu.finished
  end
  if pro == nil and isReachLv == true and CDaTingCangBaoTu.taskid == nil and CDaTingCangBaoTu.cnt < DaTingCangBaoTu_MaxCircle then
    CangBaoTuData[DaTingCangBaoTu_MissionId] = {
      finished = MissionPro_NotAccept,
      param = {}
    }
    print("======>> 可以接受的藏宝图任务", DaTingCangBaoTu_MissionId)
  end
end
function MissionMgr:getMissionDataTable(missionId, missionKind)
  if missionKind == nil then
    missionKind = getMissionKind(missionId)
  end
  if missionKind == MissionKind_Main then
    return data_Mission_Main
  elseif missionKind == MissionKind_Branch then
    return data_Mission_Branch
  elseif missionKind == MissionKind_Activity then
    if missionId and self:isDayantaMissionId(missionId) then
      return data_Mission_Dayanta
    end
    return data_Mission_Activity
  elseif missionKind == MissionKind_Shimen then
    return data_Mission_Division
  elseif missionKind == MissionKind_Jingying then
    return data_Mission_Jingying
  elseif missionKind == MissionKind_Guide then
    return data_Mission_Guide
  elseif missionKind == MissionKind_Shilian then
    return data_Mission_Shilian
  elseif missionKind == MissionKind_SanJieLiLian then
    return data_Mission_SanJieLiLian
  elseif missionKind == MissionKind_Faction then
    return data_Mission_BangPai
  elseif missionKind == MissionKind_Jiehun then
    return data_Mission_Jiehun
  elseif missionKind == MissionKind_Jieqi then
    return data_Mission_Jieqi
  end
  return nil
end
function MissionMgr:isDayantaMissionId(missionId)
  local k2 = math.floor(missionId % 50000 / 1000)
  if k2 == 1 then
    return true
  else
    return false
  end
end
function MissionMgr:isTianDiQiShuMissionId(missionId)
  local k2 = math.floor(missionId % 50000 / 1000)
  if k2 == 3 then
    return true
  else
    return false
  end
end
function MissionMgr:isDayantaExchangeMissionId(missionId)
  return ExchangeMissionId == missionId
end
function MissionMgr:isTiantingMissionId(missionId)
  local k2 = math.floor(missionId % 50000 / 1000)
  if k2 == 2 then
    return true
  else
    return false
  end
end
function MissionMgr:getMissionData(missionId)
  local missionKind = getMissionKind(missionId)
  local dataTable = self:getMissionDataTable(missionId, missionKind)
  dataTable = dataTable and dataTable[missionId]
  return dataTable, missionKind
end
function MissionMgr:DetectMissionCanAccept(missionId)
  local dataTable, k = self:getMissionData(missionId)
  if dataTable == nil or k == nil then
    return
  end
  local md = self.m_AcceptedMissionId[k]
  if md == nil then
    return
  end
  if md[missionId] ~= nil then
    return
  end
  local mainHeroIns = g_LocalPlayer:getMainHero()
  if mainHeroIns == nil then
    printLog("ERROR", "找不到主英雄对象")
    return
  end
  local needZS = dataTable.zs
  local needLV = dataTable.lv
  local cZS = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
  local cLV = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
  if needZS < cZS or cZS == needZS and needLV <= cLV then
    local startNpc = dataTable.startNpc
    local pro = -1
    if startNpc == 0 then
      pro = 0
    end
    md[missionId] = {}
    md[missionId].finished = pro
    printLog("Mission", "接受任务[missionid:%d][pro=%d][startNpc=%d]", missionId, pro, startNpc)
    if pro == 0 then
      self:MissionAccepted(missionId, dataTable, k)
    end
  end
end
function MissionMgr:MissionAccepted(missionId, dataTable, k)
  if dataTable == nil or k == nil then
    local dataTable, k = self:getMissionData(missionId)
  end
  if dataTable == nil or k == nil then
    return
  end
  local acceptTalkId = dataTable.acceptTalkId
  if acceptTalkId ~= nil and acceptTalkId ~= 0 then
    getCurSceneView():ShowTalkView(acceptTalkId, nil, missionId)
  end
end
function MissionMgr:NewMission(missionId)
  if missionId == Shimen.ShiMenGuideID and Shimen.today_times > 0 then
    g_MissionMgr:GuideIdComplete(GuideId_Shimen)
    return
  end
  local missionKind = getMissionKind(missionId)
  print("  NewMission  missionId = ", missionId, "missionKind = ", missionKind)
  local md = self.m_AcceptedMissionId[missionKind]
  if md ~= nil then
    if missionKind == MissionKind_SanJieLiLian then
      for k, v in pairs(md) do
        if k ~= missionId then
          md[k] = nil
        end
        print(k, v)
      end
    end
    local missionProData = md[missionId]
    if missionProData ~= nil then
      self.m_LastAcceptMissionId = missionId
    end
  end
  SendMessage(MsgID_Mission_Common, missionId)
end
function MissionMgr:getLastAcceptMissionId()
  return self.m_LastAcceptMissionId
end
function MissionMgr:TraceMission(missionId)
  print("-->>TraceMission g_MapMgr:getIsMapLoading():", g_MapMgr:getIsMapLoading())
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr and g_MapMgr:getIsMapLoading() == true then
    printLog("MissionMgr", "正在加载地图不能追踪")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if not activity.yzdd:canJumpMap() then
    return
  end
  if not g_DuleMgr:canJumpMap() then
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("处于战斗中，不能跳转")
    return
  end
  if g_LocalPlayer:getNormalTeamer() == true then
    ShowNotifyTips("你已跟随队长中，不能跳转")
    return
  end
  ClearAllShowProgressBar()
  if self.m_ReqCompletedMissions[missionId] == 1 then
    printLog("WARNNING", "[%s]任务正在请求完成中...", tostring(missionId))
    return
  end
  if missionId == SanJieLiLian.AcceptMissionId then
    SanJieLiLian.GotoSanJieLiLianNpc()
    return
  end
  if missionId == Shimen.AcceptMissionId then
    Shimen.GotoShimenNpc()
    return
  end
  self:setAutoTraceMissionId(nil)
  if missionId == -1 then
    ShowNotifyTips("主线暂且告一段落，阁下努力升级吧！")
  end
  if missionId == Business_MissionId and BangPaiPaoShang.taskid ~= nil then
    if BangPaiPaoShang.progress >= 0 and BangPaiPaoShang.progress < BangPaiPaoShang.target then
      getCurSceneView():addSubView({
        subView = CPaoShangNPCList.new(),
        zOrder = MainUISceneZOrder.menuView
      })
      return
    elseif BangPaiPaoShang.progress >= BangPaiPaoShang.target then
      BangPaiPaoShang.GoToPaoShangNPC()
      return
    end
  end
  self.m_CurTraceMissionId = missionId
  local dataTable, k = self:getMissionData(missionId)
  if dataTable == nil or k == nil then
    print("任务类型还没有实现:", missionId)
    return
  end
  local missionPro, curParam = self:getMissionProgress(missionId)
  print("   ********  接受任务 ", missionPro, curParam)
  if missionPro == nil then
    return
  end
  local npcId = dataTable.startNpc
  if missionPro == -1 then
    if npcId == nil and npcId == 0 then
      self:MissionAccepted(missionId, dataTable, k)
    else
      do
        local npcId = self:convertNpcId(npcId)
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed then
            self:ShowNormalNpcView(npcId)
          end
        end)
      end
    end
  else
    print(" 分配任务 ======》》》》》  ", missionPro)
    dump(dataTable, "dataTable")
    local dst = self:getDstData(dataTable, missionPro)
    local missionType = dst.type or "-1"
    print("missionType:", missionType)
    local f = self["_TrackCtrl_" .. tostring(missionType)]
    if f then
      if SanJieLiLian.isMissionId(missionId) == true then
        local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_SanJieLiLian)
        if openFlag ~= true then
          ShowNotifyTips(tips)
          return
        end
      end
      f(self, missionId, dataTable, dst, missionPro, curParam)
    else
      printLog("ERROR", "追踪的的任务类型还没有实现[%d]", missionType)
    end
  end
end
function MissionMgr:setAutoTraceMissionId(missionId)
  self.m_NeedAutoTraceMissionId = missionId
  if missionId ~= nil then
    self:_detectAutoTraceMissionId()
  else
    self:_delHandlerForAutoTrace()
  end
end
function MissionMgr:_detectAutoTraceMissionId()
  if self.m_NeedAutoTraceMissionId ~= nil and JudgeIsInWar() ~= true then
    self:_delHandlerForAutoTrace()
    local missionId = self.m_NeedAutoTraceMissionId
    self.m_NeedAutoTraceMissionId = nil
    self:TraceMission(missionId)
  end
end
function MissionMgr:_EndWarForAutoTrace()
  self:_delHandlerForAutoTrace()
  self.m_AutoTraceTimerHandler = scheduler.performWithDelayGlobal(handler(self, self._detectAutoTraceMissionId), 2)
end
function MissionMgr:_delHandlerForAutoTrace()
  if self.m_AutoTraceTimerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_AutoTraceTimerHandler)
    self.m_AutoTraceTimerHandler = nil
  end
end
function MissionMgr:_TrackCtrl_101(missionId, dataTable, dst, missionPro)
  local npcId = dst.data
  if npcId then
    do
      local npcId = self:convertNpcId(npcId)
      g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
        if isSucceed then
          self:ShowNormalNpcView(npcId)
        end
      end)
    end
  else
    getCurSceneView():ShowTalkView(dataTable.cmpTalkId, function()
      self:TalkFinishForTalkMission(missionId, dataTable, dst, npcId)
    end, missionId)
  end
end
function MissionMgr:_TrackCtrl_102(missionId, dataTable, dst, missionPro)
  local mapInfo = dst.data
  local param = dst.param
  local jumpPos
  if param ~= nil then
    jumpPos = {
      param[2],
      param[3]
    }
  end
  g_MapMgr:AutoRoute(mapInfo[1], {
    mapInfo[2],
    mapInfo[3]
  }, function(isSucceed)
    print("====>> 寻路完成:", isSucceed)
    if isSucceed then
      self:ReqMissionCmp(missionId, dst.type, mapInfo)
    end
  end, nil, nil, jumpPos, nil, RouteType_Mission)
end
function MissionMgr:_TrackCtrl_201(missionId, dataTable, dst, missionPro)
  if missionId == 10003 then
    self:changeWarGuide()
  end
  self:__AutoRouteFB(dst.data, dst.talkId)
end
function MissionMgr:_TrackCtrl_202(missionId, dataTable, dst, missionPro)
  self:__AutoRouteFB(dst.data, dst.talkId)
end
function MissionMgr:_TrackCtrl_203(missionId, dataTable, dst, missionPro)
  self:__AutoRouteFB(dst.data, dst.talkId)
end
function MissionMgr:_TrackCtrl_204(missionId, dataTable, dst, missionPro)
  self:__AutoRouteFB(dst.data, dst.talkId)
end
function MissionMgr:_TrackCtrl_207(missionId, dataTable, dst, missionPro)
  local teamCaptainPro = g_LocalPlayer:getObjProperty(1, PROPERTY_ISCAPTAIN)
  if teamCaptainPro == TEAMCAPTAIN_YES then
    activity.dayanta:traceMission(missionId)
  end
end
function MissionMgr:_TrackCtrl_208(missionId, dataTable, dst, missionPro)
  print("战胜在地图上刷出的怪物, 跳转到地图的NPC, 208")
  self:_TrackForMonsterOfMission(missionId, dst)
end
function MissionMgr:_TrackCtrl_209(missionId, dataTable, dst, missionPro)
  print("战胜在地图上刷出的怪物, 跳转到地图的NPC, 209")
  self:_TrackForMonsterOfMission(missionId, dst)
end
function MissionMgr:_TrackForMonsterOfMission(missionId, dst)
  local data = dst.data or {}
  local customId = data[2]
  print(data[1], " **** 追踪 妖怪 ****", data[2])
  dump(dst, " DST******** ")
  if customId ~= nil then
    function cbListener(isSucceed)
      if isSucceed then
        self:ShowMonsterViewForMission(data_getBossForWar(dst.data[1]), missionId)
      end
    end
    g_MapMgr:AutoRouteWithCustomId(customId, cbListener, true, RouteType_Monster)
  end
end
function MissionMgr:_TrackCtrl_301(missionId, dataTable, dst, missionPro)
  local npcId = dst.data
  if npcId then
    do
      local npcId = self:convertNpcId(npcId)
      g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
        if isSucceed then
          self:ShowNormalNpcView(npcId)
        end
      end)
    end
  else
    printLog("ERROR", "任务[%d]没有填NPCID", missionId)
  end
end
function MissionMgr:_TrackCtrl_401(missionId, dataTable, dst, missionPro)
  local mapInfo = dst.data
  g_MapMgr:AutoRouteWithWorldTeleporter(mapInfo[1], {
    mapInfo[2],
    mapInfo[3]
  }, function(isSucceed)
    print("====>> _TrackCtrl_401寻路完成:", isSucceed)
    if isSucceed and #dst.param > 0 then
      do
        local objId = dst.param[1][1]
        print("==>>objId:", objId)
        local itemId = g_LocalPlayer:GetOneItemIdByType(objId)
        print("====>> itemId:", itemId)
        if itemId > 0 then
          do
            local itemIns = g_LocalPlayer:GetOneItem(itemId)
            if itemIns == nil then
              return
            end
            local itemName = itemIns:getProperty(ITEM_PRO_NAME)
            local itemShapeTypeId = itemIns:getTypeId()
            local canUse, missionId = self:canMissionObjUse(itemShapeTypeId)
            if canUse then
              local function func()
                if itemShapeTypeId == ITEM_DEF_TASK_MENGPOTANG then
                  getCurSceneView():addSubView({
                    subView = CRebirthShow.new(),
                    zOrder = MainUISceneZOrder.menuView
                  })
                else
                  netsend.netitem.requestUseItem(itemId)
                end
              end
              CShowProgressBar.new(string.format("正在使用#<II%d>##<CI:%d>%s#", itemShapeTypeId, itemShapeTypeId, itemName), func)
            else
              printLog("ERROR", "任务追踪失败:%s", tostring(missionId))
            end
          end
        end
      end
    end
  end, RouteType_Mission)
end
function MissionMgr:_TrackCtrl_402(missionId, dataTable, dst, missionPro, curParam)
  print("================================>>>1   MissionMgr:_TrackCtrl_402 ", missionId)
  print("_TrackCtrl_402    ", dst.des, dst.data)
  if g_HunyinMgr and g_HunyinMgr:canTraceMission(missionId) == false then
    return
  end
  if self:detectMissionDstColloctComplete(missionId, dst, curParam) then
    local npcId = dst.data
    if npcId then
      do
        local npcId = self:convertNpcId(npcId)
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed then
            self:ShowNormalNpcView(npcId)
          end
        end)
      end
    else
      printLog("ERROR", "任务[%d]没有填NPCID", missionId)
    end
  end
end
function MissionMgr:_TrackCtrl_501(missionId, dataTable, dst, missionPro)
  local guideId = dst.data
  if guideId then
    MissionGuideFuncStart(guideId)
  else
    printLog("ERROR", "任务[%d]没有填指引ID", missionId)
  end
end
function MissionMgr:_TrackCtrl_601(missionId, dataTable, dst, missionPro)
  print("抓鬼任务，跳转地图")
  ZhuaGui.TrackMission()
end
function MissionMgr:_TrackCtrl_602(missionId, dataTable, dst, missionPro)
  print("追踪鬼王任务")
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    return
  end
  if JudgeIsInWar() then
    return
  end
  GuiWang.TrackMission()
end
function MissionMgr:_TrackCtrl_603(missionId, dataTable, dst, missionPro)
  print("追踪天兵神将")
  activity.tbsj:TrackTBSJMission()
end
function MissionMgr:_TrackCtrl_604(missionId, dataTable, dst, missionPro)
  print("修罗任务，跳转地图")
  XiuLuo.TrackMission()
end
function MissionMgr:_TrackCtrl_605(missionId, dataTable, dst, missionPro)
  if activity.tiandiqishu.ActiveEnd == true then
    ShowNotifyTips("活动已经结束，请下周六再来吧")
    return
  end
  if activity.tiandiqishu:getIsCanStarActive() == false and activity.tiandiqishu.ActiveEnd == false then
    ShowNotifyTips("活动即将开始，请少侠稍等片刻")
    return
  end
  if missionId == TianDiQiShu_BossMissionId and activity.tiandiqishu:isAtKillingBoss() == false then
    ShowNotifyTips("BOSS还没有出现，侠士们需要努力呀")
    return
  end
  if missionId ~= TianDiQiShu_BossMissionId and activity.tiandiqishu:isAtKillingBoss() == true then
    ShowNotifyTips("离小怪刷出还有一段时间，请耐心等候")
    return
  end
  local data = dst.data or {}
  local locid = 21001
  local MissionToIndex, MonsterTable, MonsterBossTable = activity.tiandiqishu:getMonsterTable()
  if missionId ~= 53004 then
    local inxex = MissionToIndex[missionId]
    locid = MonsterTable[inxex].locid
  else
    locid = MonsterBossTable.locid
  end
  local customId = locid
  if customId ~= nil then
    function cbListener(isSucceed)
      if isSucceed then
        activity.tiandiqishu:monsterOptionTouch(missionId)
      end
    end
    g_MapMgr:AutoRouteWithCustomId(customId, cbListener, true, RouteType_Monster)
  end
end
function MissionMgr:_TrackCtrl_702(missionId, dataTable, dst, missionPro)
  local data = dst.data or {}
  local customId = data[2]
  if customId ~= nil then
    function cbListener(isSucceed)
      if isSucceed then
        activity.tianting:monsterOptionTouch(missionId)
      end
    end
    g_MapMgr:AutoRouteWithCustomId(customId, cbListener, true, RouteType_Monster)
  end
end
function MissionMgr:_TrackCtrl_703(missionId, dataTable, dst, missionPro)
  activity.dayanta:traceExchangeMission()
end
function MissionMgr:_TrackCtrl_801(missionId, dataTable, dst, missionPro)
  print(" 运行到  =====》》》》  _TrackCtrl_801 ", missionId, SanJieLiLian.loc_id_, dst[1], dst[2])
  self:_TrackForMonsterOfMission(missionId, dst)
end
function MissionMgr:_TrackCtrl_804(missionId, dataTable, dst, missionPro)
  local npcId = dst.data
  if npcId then
    npcId = g_MissionMgr:convertNpcId(npcId)
    g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
      if isSucceed then
        CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
      end
    end)
  end
end
function MissionMgr:_TrackCtrl_803(missionId, dataTable, dst, missionPro)
  local npcId = dst.data
  if npcId then
    local npcId = self:convertNpcId(npcId)
    g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
      if isSucceed then
        SanJieLiLian.startAnser()
      end
    end)
  end
end
function MissionMgr:_TrackCtrl_901(missionId, dataTable, dst, missionPro)
  print("图腾任务，跳转地图")
  BangPaiTotem.TrackMission()
end
function MissionMgr:_TrackCtrl_902(missionId, dataTable, dst, missionPro)
  print("图腾任务，跳转地图")
  BangPaiRenWuLing.TrackMission(TaskToken_MuJi_MissionId, 90020)
end
function MissionMgr:_TrackCtrl_903(missionId, dataTable, dst, missionPro)
  print("图腾任务，跳转地图")
  BangPaiRenWuLing.TrackMission(TaskToken_AnZhan_MissionId)
end
function MissionMgr:_TrackCtrl_904(missionId, dataTable, dst, missionPro)
  print("图腾任务，跳转地图")
  BangPaiRenWuLing.TrackMission(TaskToken_ChuMo_MissionId)
end
function MissionMgr:_TrackCtrl_906(missionId, dataTable, dst, missionPro)
  print("帮派除魔 追踪 ")
  BangPaiChuMo.TrackMission(missionid)
end
function MissionMgr:_TrackCtrl_907(missionId, dataTable, dst, missionPro)
  print("帮派暗战任务 追踪 ")
  self:_TrackForMonsterOfMission(missionId, dst)
end
function MissionMgr:_TrackCtrl_908(missionId, dataTable, dst, missionPro)
  CDaTingCangBaoTu.TraceMission(missionId)
end
function MissionMgr:_TrackCtrl_1001(missionId, dataTable, dst, missionPro)
  print("------>>> _TrackCtrl_1001")
  if g_HunyinMgr then
    g_HunyinMgr:missionRequestComplete(missionId, 1001)
  end
end
function MissionMgr:_TrackCtrl_1002(missionId, dataTable, dst, missionPro)
  print("------>>> _TrackCtrl_1002")
  if g_HunyinMgr then
    g_HunyinMgr:missionRequestComplete(missionId, 1002)
  end
end
function MissionMgr:_TrackCtrl_1003(missionId, dataTable, dst, missionPro)
  print("------>>> _TrackCtrl_1003")
  if g_HunyinMgr then
    g_HunyinMgr:missionRequestComplete(missionId, 1003)
  end
end
function MissionMgr:_TrackCtrl_1101(missionId, dataTable, dst, missionPro)
  if g_JieqiMgr then
    g_JieqiMgr:missionRequestComplete(missionId, 1101)
  end
end
function MissionMgr:_TrackCtrl_1102(missionId, dataTable, dst, missionPro)
  if g_JieqiMgr then
    g_JieqiMgr:missionRequestComplete(missionId, 1102)
  end
end
function MissionMgr:_TrackCtrl_1103(missionId, dataTable, dst, missionPro)
  if g_JieqiMgr then
    g_JieqiMgr:missionRequestComplete(missionId, 1103)
  end
end
function MissionMgr:_TrackCtrl_1104(missionId, dataTable, dst, missionPro)
  if g_JieqiMgr then
    g_JieqiMgr:missionRequestComplete(missionId, 1104)
  end
end
function MissionMgr:addShotageObj(objid, mid)
  print(" **************  MissionMgr:addShotageObj  ", objid, mid)
  if objid == nil then
    return
  end
  objid = tostring(objid)
  if self.m_MissionCmpShotageObjId == nil then
    self.m_MissionCmpShotageObjId = {}
  end
  if self.m_MissionCmpShotageObjId[objid] == nil then
    self.m_MissionCmpShotageObjId[objid] = {}
  end
  self.m_MissionCmpShotageObjId[objid][#self.m_MissionCmpShotageObjId[objid] + 1] = mid
end
function MissionMgr:removeShotageObj(objid, mid)
  print(" ************** MissionMgr:removeShotageObj  ", objid, mid)
  if objid == nil then
    return
  end
  objid = tostring(objid)
  if self.m_MissionCmpShotageObjId == nil then
    return
  end
  if self.m_MissionCmpShotageObjId[objid] == nil then
    return
  end
  if #self.m_MissionCmpShotageObjId[objid] == 1 then
    self.m_MissionCmpShotageObjId[objid] = nil
    return
  end
  for k, v_mid in pairs(self.m_MissionCmpShotageObjId[objid]) do
    if mid == v_mid then
      self.m_MissionCmpShotageObjId[objid][k] = nil
    end
  end
end
function MissionMgr:_TrackCtrl_705(missionId, dataTable, dst, missionPro, curParam)
  print("师门任务 抓宠  ", missionId)
  dump(dataTable, "dataTable")
  print("********************")
  dump(dst, "dst")
  if dst and dst.param then
    for k, v in pairs(dst.param) do
      local m_subView = CPetList.new(PetShow_InitShow_TuJianView, nil, nil, v[1])
      getCurSceneView():addSubView({
        subView = m_subView,
        zOrder = MainUISceneZOrder.menuView
      })
      break
    end
  end
end
function MissionMgr:__AutoRouteFB(catInfo, talkId)
  local isInTeamAndIsNotCaptain = false
  if g_LocalPlayer:getPlayerIsInTeam() and not g_LocalPlayer:getPlayerInTeamAndIsCaptain() then
    isInTeamAndIsNotCaptain = true
  end
  local talkId = talkId
  local mapId = catInfo[1]
  local catchId = catInfo[2]
  local hasMonsterFlag = g_LocalPlayer:isHasCatchMonster(mapId, catchId)
  if hasMonsterFlag then
    g_MapMgr:AutoRouteFB({mapId, catchId})
  else
    netsend.netguanka.askToCreateNpc(mapId, catchId)
  end
end
function MissionMgr:TalkFinishForTalkMission(missionId, dataTable, dst, npcId)
  print("==>> 对话完成:", missionId, dataTable, dst, npcId)
  self:ReqMissionCmp(missionId, dst.type, dst.data)
end
function MissionMgr:ReqMissionCmp(missionId, type, data)
  print("--->> 请求任务完成:", missionId, missionId == SanJieLiLian.missionId_, type, data)
  local missionKind = getMissionKind(missionId)
  print("  missionKind =" .. missionKind, MissionKind_Shimen)
  if missionKind == MissionKind_Shimen then
    Shimen.missionCmp()
  elseif missionId == ZhuaGui_MissionId then
    ZhuaGui.TrackMission()
  elseif missionId == GuiWang_MissionId then
    GuiWang.TrackMission()
  elseif missionId == SanJieLiLian.missionId_ then
    SanJieLiLian.missionCmp()
  elseif missionId == BangPaiChuMo.MissionId or missionId == BangPaiAnZhan.MissionId then
    if CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(NPC_BangPaiShiYe_ID)
    end
  elseif missionId == Business_MissionId then
    CMainUIScene.Ins:ShowNormalNpcViewById(NPC_BangPaiShangRen_ID)
  elseif missionKind == MissionKind_Jiehun then
    if g_HunyinMgr then
      g_HunyinMgr:missionRequestComplete(missionId, type)
    end
  elseif missionKind == MissionKind_Jieqi then
    if g_JieqiMgr then
      g_JieqiMgr:missionRequestComplete(missionId, type)
    end
  elseif missionId == XiuLuo_MissionId then
    XiuLuo.TrackMission()
  else
    self.m_ReqCompletedMissions[missionId] = 1
    netsend.netmission.reqComplete(type, data, missionId)
  end
end
function MissionMgr:GuideIdComplete(guideId)
  print("==>>GuideIdComplete:", guideId)
  for i, mk in ipairs(all_mission_kind) do
    local md = self.m_AcceptedMissionId[mk]
    local _ids = {}
    for missionId, finished in pairs(md) do
      local missionPro = self:getMissionProgress(missionId)
      print("missionId, missionPro:", missionId, missionPro)
      if missionPro ~= MissionPro_NotAccept then
        local dataTable = self:getMissionData(missionId)
        local dst = self:getDstData(dataTable, missionPro)
        print("MissionType_Guide, guideId, type, data:", MissionType_Guide, guideId, dst.type, dst.data)
        if dst.type == MissionType_Guide and dst.data == guideId then
          self:ReqMissionCmp(missionId, dst.type, dst.data)
          return true
        end
      end
    end
  end
end
function MissionMgr:convertNpcId(npcId)
  if npcId == Role_SpecialID_Shimen then
    return g_LocalPlayer:getShimenNpcId()
  end
  return npcId
end
function MissionMgr:packAwardData(dataTable)
  local rewardCoin = dataTable.rewardCoin
  local rewardGold = dataTable.rewardGold
  local rewardExp = dataTable.rewardExp
  local rewardObj = dataTable.rewardObj
  local rewardSilver = dataTable.rewardSilver
  local awardData = {}
  if rewardCoin and rewardCoin > 0 then
    awardData[#awardData + 1] = {RESTYPE_COIN, rewardCoin}
  end
  if rewardGold and rewardGold > 0 then
    awardData[#awardData + 1] = {RESTYPE_GOLD, rewardGold}
  end
  if rewardSilver and rewardSilver > 0 then
    awardData[#awardData + 1] = {RESTYPE_SILVER, rewardSilver}
  end
  if rewardExp and rewardExp > 0 then
    awardData[#awardData + 1] = {RESTYPE_EXP, rewardExp}
    local mainHeroIns = g_LocalPlayer:getObjById(1)
    if mainHeroIns then
      local tempPetId = mainHeroIns:getProperty(PROPERTY_PETID)
      if tempPetId ~= nil and tempPetId ~= 0 then
        awardData[#awardData + 1] = {
          RESTYPE_EXP,
          rewardExp * 1.35,
          true
        }
      end
    end
  end
  if rewardObj then
    for i, k in ipairs(rewardObj) do
      awardData[#awardData + 1] = {
        [k[1]] = k[2]
      }
    end
  end
  return awardData
end
function MissionMgr:MissionTempNpcDetect(missionId, curPro, oldPro)
  local delNpcId, createNpcId
  local oldPro = oldPro or curPro - 1
  local npcId = self:getNpcIdWithMissionIdAndPro(missionId, oldPro)
  if npcId and data_TempNpcForMission[npcId] ~= nil then
    delNpcId = npcId
  end
  local npcId2 = self:getNpcIdWithMissionIdAndPro(missionId, curPro)
  if npcId2 and data_TempNpcForMission[npcId2] ~= nil then
    createNpcId = npcId2
  end
  if delNpcId == createNpcId then
    delNpcId = nil
  end
  local _, name1 = data_getRoleShapeAndName(delNpcId)
  local _, name2 = data_getRoleShapeAndName(createNpcId)
  if delNpcId then
    g_MapMgr:ReqDeleteNpc(delNpcId)
    local missionIds, hasMainMission = g_MissionMgr:getCanTraceMission()
    local canAcceptedBranchIds = g_MissionMgr:getCanAcceptMission({
      MissionKind_Main,
      MissionKind_Branch,
      MissionKind_Jingying,
      MissionKind_Shilian
    }) or {}
    for i, v in ipairs(canAcceptedBranchIds) do
      missionIds[#missionIds + 1] = v
    end
    local cur_npcId, finish, param, complete
    for k, m_missionid in pairs(missionIds) do
      if m_missionid ~= missionId then
        finish, param, complete = g_MissionMgr:getMissionProgress(m_missionid)
        cur_npcId = self:getNpcIdWithMissionIdAndPro(m_missionid, finish)
        if cur_npcId and data_TempNpcForMission[cur_npcId] ~= nil and delNpcId == cur_npcId then
          createNpcId = cur_npcId
          g_MapMgr:ReqLoadNpc(createNpcId)
        end
      end
    end
  end
  if createNpcId then
    g_MapMgr:ReqLoadNpc(createNpcId)
  end
end
function MissionMgr:getNpcIdWithMissionIdAndPro(missionId, missionPro)
  local dataTable, missionKind = self:getMissionData(missionId)
  if dataTable == nil or missionKind == nil then
    return nil
  end
  if missionPro == MissionPro_NotAccept then
    return dataTable.startNpc
  end
  local dst = self:getDstData(dataTable, missionPro)
  if dst then
    if Mission_NeedNpc[dst.type] == nil then
      return nil
    end
    return dst.data
  end
  return nil
end
function MissionMgr:detectMissionDstColloctComplete(missionId, dst, curParam)
  local objList = dst.param
  local getAllObjs = true
  local shotageCoin = 0
  local shotageObjId
  local needCount = 0
  if type(objList) == "table" and type(curParam) == "table" then
    for i, obj in ipairs(objList) do
      local objId, sum = obj[1], obj[2]
      for idx, objListTemp in ipairs(curParam) do
        if objListTemp[1] == objId and sum > objListTemp[2] then
          getAllObjs = false
          if objId == 1 then
            shotageCoin = sum - objListTemp[2]
          end
          needCount = sum - objListTemp[2]
          shotageObjId = objId
          break
        end
      end
    end
  end
  if getAllObjs == false then
    if shotageCoin > 0 then
      netsend.netbaseptc.requestExchangeByGold(1, shotageCoin, 1)
    else
      JumpToItemSourceFromTask(shotageObjId, SanJieLiLian.isMissionId(missionId), missionId)
    end
    return false
  else
    return true
  end
end
local needNpcType = {
  [MissionType_TalkNpc] = true,
  [MissionType_GetObjByNpc] = true,
  [MissionType_GiveObjToNpc] = true
}
local needUpdateObjProgress = {
  [MissionType_CollectInWar] = true,
  [MissionType_WarForObjWithMonster] = true,
  [MissionType_GiveObjToNpc] = true,
  [MissionType_ShiMenZC] = true
}
function MissionMgr:flushMissionStatusForNpc()
  print("flushMissionStatusForNpc--->>")
  if g_DataMgr:getIsSendFinished() == false then
    print("\t\t还没有更新完，不刷新")
    return
  end
  self.m_MissionStatusForNpc = {}
  self.m_MissionStatusWithNpc = {}
  self.m_MapMonsterForMissions = {}
  self.m_NeedUpdateProgressOjbs = {}
  self.m_MissionCmpShotageObjId = {}
  Shimen.CheckMissionPet()
  SanJieLiLian.CheckMissionPet()
  self.m_GuideDetectIds = {}
  self:flushGuideForMissionStart()
  for missionKind, missionKindData in pairs(self.m_AcceptedMissionId) do
    for missionId, processData in pairs(missionKindData) do
      local finished = processData.finished
      local missionData = self:getMissionData(missionId)
      self:flushGuideForMission(missionId, finished)
      processData.complete = false
      if missionData == nil then
        printLog("ERROR", "找不到任务的数据:%s", missionId)
      elseif finished == MissionPro_NotAccept then
        if missionData.startNpc ~= 0 then
          self:addMissionStatusForNpc_(missionData.startNpc, MapRoleStatus_TaskCanAccept, missionId, true)
        end
      else
        local curDst = self:getDstData(missionData, finished)
        local curType = curDst.type
        if needNpcType[curType] == true and Mission_Show_Objs[curType] ~= 1 then
          local _, name = data_getRoleShapeAndName(curDst.data)
          self:addMissionStatusForNpc_(curDst.data, MapRoleStatus_TaskCanCommit, missionId, true)
        end
        if needUpdateObjProgress[curType] == true then
          for idx, obj in pairs(curDst.param) do
            local objId = tostring(obj[1])
            local objIdList = self.m_NeedUpdateProgressOjbs[objId]
            if objIdList == nil then
              objIdList = {}
              self.m_NeedUpdateProgressOjbs[objId] = objIdList
            end
            objIdList[#objIdList + 1] = missionId
          end
          for k, v in pairs(processData) do
            print(k, v)
          end
          self:UpdateMissionProgress(missionId, processData, curDst)
        end
        local lastType = 0
        if finished < 1 then
          local lastDst = self:getDstData(missionData, 1)
          lastType = lastDst.type
          if lastType ~= 0 and needNpcType[lastType] == true then
            local _, name = data_getRoleShapeAndName(lastDst.data)
            self:addMissionStatusForNpc_(lastDst.data, MapRoleStatus_TaskNotComplete, missionId, false)
          end
        end
        if lastType == 0 and needNpcType[curType] == true then
          processData.complete = true
          if Mission_Show_Objs[curType] == 1 then
            local curParam = processData.param
            for idx, obj in pairs(curDst.param) do
              local objId, sum = obj[1], obj[2]
              for idx, objListTemp in ipairs(curParam) do
                if objListTemp[1] == objId then
                  curNum = objListTemp[2]
                  if sum > curNum then
                    processData.complete = false
                    local k = tostring(objId)
                    if self.m_MissionCmpShotageObjId[k] == nil then
                      self.m_MissionCmpShotageObjId[k] = {missionId}
                    else
                      self.m_MissionCmpShotageObjId[k][#self.m_MissionCmpShotageObjId[k] + 1] = missionId
                    end
                  end
                end
              end
            end
            if processData.complete then
              self:addMissionStatusForNpc_(curDst.data, MapRoleStatus_TaskCanCommit, missionId, true)
            else
              self:addMissionStatusForNpc_(curDst.data, MapRoleStatus_TaskNotComplete, missionId, true)
            end
          end
        end
        if self.m_NeedCreateMonsterType[curType] == 1 then
          if curDst.data and type(curDst.data) == "table" then
            local specialMapPosId = curDst.data[2]
            if specialMapPosId ~= nil then
              local d = data_CustomMapPos[specialMapPosId]
              if d and d.SceneID then
                local ct = MapMonsterType_Mission
                if curType == MissionType_Tianing then
                  ct = MapMonsterType_Tianing
                end
                self:addMapMonsterForMissions(missionId, d.SceneID, curDst.data[1], curDst.data[2], ct)
              end
            end
          end
        elseif missionId == DaTingCangBaoTu_MissionId then
          if CDaTingCangBaoTu.war_data_id ~= nil and CDaTingCangBaoTu.loc_id ~= nil then
            local d = data_BaotuTask_Loc[CDaTingCangBaoTu.loc_id]
            if d and d.SceneId then
              local ct = MapMonsterType_Mission
              self:addMapMonsterForMissions(missionId, d.SceneId, CDaTingCangBaoTu.war_data_id, d.Loc, ct)
            end
          end
        elseif self:isDayantaMissionId(missionId) then
          self:addMapMonsterForMissions(missionId, activity.dayanta:getMissionMapId(missionId), curDst.data[1], curDst.data[2], MapMonsterType_Dayanta)
        elseif self:isTianDiQiShuMissionId(missionId) then
          local warid = 23751
          local customId = 21031
          local BossId = 801
          local MissionIdToIdx, SmallMonsterdata, BossMonsterdata = activity.tiandiqishu:getMonsterTable()
          local inxex = MissionIdToIdx[missionId]
          if missionId ~= TianDiQiShu_BossMissionId then
            BossId = SmallMonsterdata[inxex].TypeId
            print("99999999999999999999999999ddddf", BossId)
            if data_QiShuMonster[BossId] ~= nil then
              warid = data_QiShuMonster[BossId].WarDataId
              customId = SmallMonsterdata[inxex].locid
            end
          else
            BossId = BossMonsterdata.TypeId
            if data_QiShuMonster[BossId] ~= nil then
              warid = data_QiShuMonster[BossId].WarDataId
              customId = BossMonsterdata.locid
            end
          end
          self:addMapMonsterForMissions(missionId, activity.tiandiqishu.mapId, warid, customId, MapMonsterType_TiandiQiShu)
        end
        if missionId == GuiWang_MissionId and GuiWang.needCreateMonster() then
          local d = data_CustomMapPos[g_LocalPlayer._gw_locId]
          if d == nil then
            printLog("ERROR", "鬼王任务数据出错g_LocalPlayer._gw_locId = %s", tostring(g_LocalPlayer._gw_locId))
          else
            self:addMapMonsterForMissions(missionId, d.SceneID, g_LocalPlayer._gw_warId, g_LocalPlayer._gw_locId, MapMonsterType_GuiWang)
          end
        elseif missionId == TBSJ_MissionId then
          local tbsjNpcId = activity.tbsj:GetTBSJNpcId()
          if tbsjNpcId then
            self:addMissionStatusForNpc_(tbsjNpcId, MapRoleStatus_TaskCanCommit, missionId, true)
          end
        end
        if curType == MissionType_Guide then
          local guideId = curDst.data
          if guideId == GuideId_setHeroPro then
            if g_LocalPlayer then
              local mainHeroIns = g_LocalPlayer:getObjById(1)
              if mainHeroIns then
                local lv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
                if lv and lv > 0 then
                  local lv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
                  for i, pro in ipairs({
                    PROPERTY_GenGu,
                    PROPERTY_Lingxing,
                    PROPERTY_LiLiang,
                    PROPERTY_MinJie
                  }) do
                    local value = mainHeroIns:getProperty(pro)
                    if value and lv < value then
                      g_MissionMgr:GuideIdComplete(GuideId_setHeroPro)
                    end
                  end
                end
              end
            end
          elseif GuideId_NeedUpdateDetect[guideId] then
            self.m_GuideDetectIds[#self.m_GuideDetectIds + 1] = {missionId, guideId}
          end
        end
      end
    end
  end
  self:flushGuideForMissionEnd()
  SendMessage(MsgID_Mission_NpcStatusChanged, self.m_MissionStatusForNpc)
  dump(self.m_MissionCmpShotageObjId, "self.m_MissionCmpShotageObjId")
end
function MissionMgr:addMissionStatusForNpc_(npcId, status, missionId, isCurNpc)
  npcId = self:convertNpcId(npcId)
  if npcId == nil then
    print("==>>> MissionMgr:addMissionStatusForNpc_  nipid  is nil  missionId= ", missionId)
    return
  end
  if self.m_MissionStatusForNpc[npcId] == nil then
    self.m_MissionStatusForNpc[npcId] = {}
  end
  self.m_MissionStatusForNpc[npcId][status] = true
  local oldStatus = self.m_MissionStatusWithNpc[missionId]
  if oldStatus == nil or isCurNpc == true then
    self.m_MissionStatusWithNpc[missionId] = status
  end
end
function MissionMgr:clearNpcStatus(npcid)
  self.m_MissionStatusForNpc[npcid] = {}
end
function MissionMgr:getMissionStatusForNpc()
  return self.m_MissionStatusForNpc
end
function MissionMgr:getMissionStatusWithNpcByMissionId(missionId)
  print("missionId-:", missionId)
  return self.m_MissionStatusWithNpc[missionId]
end
function MissionMgr:getMapMonsterForMissions()
  return self.m_MapMonsterForMissions
end
function MissionMgr:addMapMonsterForMissions(missionId, mapId, warId, param, type)
  if missionId == BangPaiAnZhan_MissionId then
    local mapView = g_MapMgr:getMapViewIns()
    if mapView then
      mapView:DeleteMonsterByMissionId(missionId)
    end
  end
  local data = self.m_MapMonsterForMissions[mapId]
  if data == nil then
    data = {}
    self.m_MapMonsterForMissions[mapId] = data
  end
  data[missionId] = {
    warId,
    param,
    type
  }
end
function MissionMgr:ShowMonsterViewForMission(monsterTypeId, missionId)
  print("---->ShowMonsterViewForMission:", monsterTypeId, missionId)
  local missionKind = getMissionKind(missionId)
  if missionKind == MissionKind_Branch or missionKind == MissionKind_Shilian then
    print("支线或试炼任务不提示开战对话框直接进入战斗")
    self:StartWarForMonster(missionId)
  elseif missionKind == MissionKind_SanJieLiLian then
    if (SanJieLiLian.today_times + 1) % 50 == 0 then
      CMainUIScene.Ins:ShowMonsterView(monsterTypeId, MapMonsterType_Mission, function()
        print("=========>>>> 三界历练50环怪")
        self:StartWarForMonster(missionId)
      end, name, nil, true)
    else
      self:StartWarForMonster(missionId)
    end
  elseif missionId == BangPaiAnZhan_MissionId then
    BangPaiAnZhan.TouchMoster()
  elseif missionId == DaTingCangBaoTu_MissionId then
    self:StartWarForMonster(missionId)
  elseif missionKind == MissionKind_Jieqi then
    if g_JieqiMgr then
      g_JieqiMgr:missionRequestComplete(missionId, monsterTypeId)
    end
  else
    CMainUIScene.Ins:ShowMonsterView(monsterTypeId, MapMonsterType_Mission, function()
      print("=========>>>> 遇怪战斗点击")
      self:StartWarForMonster(missionId)
    end, name, nil, nil, missionId)
  end
end
function MissionMgr:StartWarForMonster(missionId)
  local dataTable, missionKind = self:getMissionData(missionId)
  local missionPro, curParam = self:getMissionProgress(missionId)
  local dst = self:getDstData(dataTable, missionPro)
  local data = dst.data
  local talkId = dst.talkId
  if data then
    local isCanWar = true
    if isCanWar then
      print("-->>:", data[1], data[2])
      if SanJieLiLian.isMissionId(missionId) then
        netsend.netwar.mapMonsterWarForSanJieLiLian(data[1], data[2])
      elseif missionKind == MissionKind_Activity and missionId == DaTingCangBaoTu_MissionId then
        netsend.netwar.daTingCangBaoTu(data[1])
      else
        netsend.netwar.mapMonsterWar(data[1], data[2])
      end
    end
  end
end
function MissionMgr:isObjShortage(objId)
  return self.m_MissionCmpShotageObjId[tostring(objId)] ~= nil
end
function MissionMgr:getAcceptedMainMissionIds_Pro1()
  local ids = {}
  local md = self.m_AcceptedMissionId[MissionKind_Main] or {}
  for k, v in pairs(md) do
    if v.finished == MissionPro_0 then
      ids[#ids + 1] = k
    end
  end
  return ids
end
function MissionMgr:getAcceptedMainJingyingIds_Pro1()
  local ids = {}
  local md = self.m_AcceptedMissionId[MissionKind_Jingying] or {}
  for k, v in pairs(md) do
    if v.finished == MissionPro_0 then
      ids[#ids + 1] = k
    end
  end
  return ids
end
function MissionMgr:getMissionShortageObjs(mid, objId, includelife)
  if mid == nil or objId == nil then
    return
  end
  local missionPro, curParam, complete = self:getMissionProgress(mid)
  if complete == true then
    return
  end
  curParam = curParam or {}
  local mdata, mk = self:getMissionData(mid)
  if mdata == nil then
    return nil
  end
  local dst1 = mdata.dst1 or {}
  local dstParam = dst1.param or {}
  for k, v in pairs(dstParam) do
    if v ~= nil and v[1] ~= nil then
      misobjid = v[1]
      break
    end
  end
  local showBigType = false
  if GetItemTypeByItemTypeId(objId) == ITEM_LARGE_TYPE_LIFEITEM and includelife == true then
    local itemta = GetItemDataByItemTypeId(misobjid)
    local itemtb = GetItemDataByItemTypeId(objId)
    local itematype = GetLifeSkillItemType(misobjid)
    local itembtype = GetLifeSkillItemType(objId)
    if itematype == itembtype and itemta ~= nil and itemtb ~= nil and itemtb[objId].MainCategoryId == itemta[misobjid].MainCategoryId then
      if itematype == LIFESKILL_PRODUCE_RUNE then
        if itemtb[objId].MainCategoryId == 5 then
          showBigType = false
        elseif itemtb[objId].MainCategoryId == 1 or itemtb[objId].MainCategoryId == 2 or itemtb[objId].MainCategoryId == 3 or itemtb[objId].MainCategoryId == 4 or itemtb[objId].MainCategoryId == 6 then
          showBigType = true
        end
      elseif itematype == LIFESKILL_PRODUCE_FOOD then
        if itemtb[objId].MainCategoryId == 2 or itemtb[objId].MainCategoryId == 3 or itemtb[objId].MainCategoryId == 5 then
          showBigType = true
        elseif itemtb[objId].MainCategoryId == 1 then
          showBigType = false
        end
      else
        showBigType = false
      end
    end
  end
  local needcount, misobjid
  for k, v in pairs(dstParam) do
    if v ~= nil and v[1] ~= nil then
      for k_p, v_p in pairs(curParam) do
        if v_p[1] == v[1] and (objId == v[1] or showBigType) then
          needcount = v[2] - v_p[2]
          return needcount
        end
      end
    end
  end
  print(" ========================    ", objId, needcount)
end
function MissionMgr:getAllShortageObjs()
  local objIds = {}
  for k, v in pairs(self.m_MissionCmpShotageObjId) do
    objIds[#objIds + 1] = checkint(k)
  end
  return objIds
end
function MissionMgr:setHasCompletMids(hasCmpMids)
  self.m_hasCmpMids = hasCmpMids
end
function MissionMgr:gethasCompletMids()
  return self.m_hasCmpMids
end
function MissionMgr:updateGuideDetect(dt)
  if #self.m_GuideDetectIds > 0 then
    for i, data in ipairs(self.m_GuideDetectIds) do
      local missionId, guideId = data[1], data[2]
      local isCmp = false
      if guideId == GuideId_GetPet then
        local temp = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
        if #temp > 0 then
          isCmp = true
        end
      elseif guideId == GuideId_GetMate then
        local temp = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
        if #temp > 1 then
          isCmp = true
        end
      elseif guideId == GuideId_Zuoqi then
        local temp = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI) or {}
        if #temp > 0 then
          isCmp = true
        end
      end
      if isCmp then
        self:ReqMissionCmp(missionId, MissionType_Guide, guideId)
        break
      end
    end
  end
end
function MissionMgr:UpdateMissionProgress(missionId, processData, curDst)
  if processData == nil then
    local missionKind = getMissionKind(missionId)
    local md = self.m_AcceptedMissionId[missionKind]
    if md ~= nil then
      processData = md[missionId] or {}
    else
      printLog("ERROR", "UpdateMissionProgress 任务没有进度数据:%s", tostring(missionId))
      return
    end
  end
  if curDst == nil then
    local finished = processData.finished
    local missionData = self:getMissionData(missionId)
    if missionData == nil then
      printLog("ERROR", "UpdateMissionProgress 找不到任务的数据:%s", missionId)
      return
    end
    curDst = self:getDstData(missionData, finished)
  end
  if curDst.param == nil then
    print("[ERROR] curDst.param == nil, missionId:", missionId)
    curDst.param = {}
  end
  local curParam = {}
  for idx, obj in pairs(curDst.param) do
    local objId, sum = obj[1], obj[2]
    local curNum = g_LocalPlayer:getObjNumById(objId) or 0
    if GetItemTypeByItemTypeId(objId) == ITEM_LARGE_TYPE_LIFEITEM then
      local itemtb = GetItemDataByItemTypeId(objId)
      if itemtb ~= nil and itemtb[objId] ~= nil then
        local cursum = 0
        local LifeItemType = GetLifeSkillItemType(objId)
        local showBigType = false
        if LifeItemType == LIFESKILL_PRODUCE_RUNE then
          if itemtb[objId].MainCategoryId == 5 then
            showBigType = false
          elseif itemtb[objId].MainCategoryId == 1 or itemtb[objId].MainCategoryId == 2 or itemtb[objId].MainCategoryId == 3 or itemtb[objId].MainCategoryId == 4 or itemtb[objId].MainCategoryId == 6 then
            showBigType = true
          end
        elseif LifeItemType == LIFESKILL_PRODUCE_FOOD then
          if itemtb[objId].MainCategoryId == 2 or itemtb[objId].MainCategoryId == 3 or itemtb[objId].MainCategoryId == 5 then
            showBigType = true
          elseif itemtb[objId].MainCategoryId == 1 then
            showBigType = false
          end
        else
          showBigType = false
        end
        if showBigType == true then
          for itemk, itemv in pairs(itemtb) do
            if itemtb[objId].MainCategoryId == itemv.MainCategoryId then
              local numtemp = g_LocalPlayer:getObjNumById(itemk) or 0
              cursum = cursum + numtemp
            end
          end
        else
          for itemk, itemv in pairs(itemtb) do
            if itemtb[objId].MainCategoryId == itemv.MainCategoryId and itemtb[objId].MinorCategoryId == itemv.MinorCategoryId then
              local numtemp = g_LocalPlayer:getObjNumById(itemk) or 0
              cursum = cursum + numtemp
            end
          end
        end
        curNum = cursum
      end
      print(" **************  UpdateMissionProgress haha ", curNum)
    end
    curParam[#curParam + 1] = {objId, curNum}
    print("\t\t objId, curNum:", objId, curNum)
  end
  processData.param = curParam
end
function MissionMgr:objectNumChanged(objId)
  if g_DataMgr:getIsSendFinished() == false then
    print("还没有更新完，objectNumChanged不刷新")
    return
  end
  dump(self.m_NeedUpdateProgressOjbs, "self.m_NeedUpdateProgressOjbs")
  local missionIds = DeepCopyTable(self.m_NeedUpdateProgressOjbs[tostring(objId)])
  if GetItemTypeByItemTypeId(objId) == ITEM_LARGE_TYPE_LIFEITEM then
    self.m_NeedUpdateProgressOjbs = self.m_NeedUpdateProgressOjbs or {}
    local objtempNum = math.floor(objId / 1000)
    for itemk, mids in pairs(self.m_NeedUpdateProgressOjbs) do
      local tempNum = math.floor(itemk / 1000)
      print(" objchange *** ****      ", objtempNum, tempNum)
      if objtempNum == tempNum then
        missionIds = mids
      end
    end
  end
  if missionIds then
    for i, missionId in ipairs(missionIds) do
      self:UpdateMissionProgress(missionId)
      self.m_ReqCompletedMissions[missionId] = nil
    end
    self:flushMissionStatusForNpc()
    SendMessage(MsgID_Mission_Common)
    SendMessage(MsgID_Stall_UpdateOneKindGoods, {goodId = objId})
  end
end
function MissionMgr:sendReq_Accept(missionId)
  printLog("MSG", "发送接受任务请求[%d]", missionId)
  if missionId == 90005 then
    SanJieLiLian.reqAccept()
  elseif missionId == TBSJ_MissionId then
  else
    netsend.netmission.reqAccept(missionId)
  end
end
function MissionMgr:Server_MissionAccepted(missionId)
  if missionId == nil then
    printLog("ERROR", "Server_MissionAccepted的任务ID为空")
    return
  end
  if missionId == 70021 then
    local hashole = g_LocalPlayer:getHasHoleItem()
    print(" *********************  hashole ", hashole)
    if hashole ~= true then
      self.m_tempMissionUpdate = self.m_tempMissionUpdate or {}
      self.m_tempMissionUpdate[missionId] = {0, nil}
      return
    end
  end
  local k = getMissionKind(missionId)
  local md = self.m_AcceptedMissionId[k]
  if md == nil then
    md = {}
    self.m_AcceptedMissionId[k] = md
  end
  md[missionId] = {finished = 0}
  self.m_ReqCompletedMissions[missionId] = nil
  if self:isDayantaMissionId(missionId) then
    activity.dayanta:EnterDYTMap(missionId)
  end
  if self:isDayantaExchangeMissionId(missionId) then
    activity.dayanta:flushDayantaExchangeExp(missionId)
  end
  print(" 服务器通知任务接受了  ======> ", missionId)
  self:NewMission(missionId)
  self:MissionTempNpcDetect(missionId, MissionPro_0)
  self:flushMissionStatusForNpc()
end
function MissionMgr:Server_MissionUpdated(missionId, pro, data)
  if missionId == 70021 then
    local hashole = g_LocalPlayer:getHasHoleItem()
    print(" *********************  hashole ", hashole)
    if hashole ~= true then
      self.m_tempMissionUpdate = self.m_tempMissionUpdate or {}
      self.m_tempMissionUpdate[missionId] = {pro, data}
      return
    end
  end
  print("  服务器通知任务  更新 ", missionId, pro, data)
  local k = getMissionKind(missionId)
  local md = self.m_AcceptedMissionId[k]
  if md == nil then
    md = {}
    self.m_AcceptedMissionId[k] = md
  end
  md[missionId] = {finished = pro, param = data}
  local m_LifeSkillID, _ = g_LocalPlayer:getBaseLifeSkill()
  if m_LifeSkillID ~= 0 then
    g_MissionMgr:GuideIdComplete(GuideId_ShengHuoJiNeng)
  end
  self.m_ReqCompletedMissions[missionId] = nil
  SendMessage(MsgID_Mission_Common)
  self:MissionTempNpcDetect(missionId, pro)
  self:flushMissionStatusForNpc()
end
function MissionMgr:Server_MissionCmp(missionId)
  print(" 服务器 通知完成 =========》。 missionId ", missionId)
  self.m_CmpMissionId[missionId] = 1
  local dataTable, k = self:getMissionData(missionId)
  if dataTable == nil or k == nil then
    return
  end
  local md = self.m_AcceptedMissionId[k]
  if md == nil then
    return
  end
  local pro = md[missionId]
  pro = pro and pro.finished
  if pro ~= nil and pro ~= MissionPro_NotAccept then
    md[missionId] = nil
    local showCmpSpriteFlag = true
    if data_Mission_Dayanta[missionId] ~= nil then
      showCmpSpriteFlag = false
    end
    if showCmpSpriteFlag then
      AwardPrompt.ShowMissionCmp()
    end
    self.m_ReqCompletedMissions[missionId] = nil
    SendMessage(MsgID_Mission_Common)
    self:MissionTempNpcDetect(missionId, MissionPro_2, pro)
  end
  local progress = self.m_CompletedMaxMission[k]
  if progress == nil or missionId > progress then
    self.m_CompletedMaxMission[k] = missionId
    self:FlushCanAcceptMission()
  else
    self:flushMissionStatusForNpc()
  end
end
function MissionMgr:Server_GiveUpMission(missionId)
  print("==>>Server_GiveUpMission:", missionId)
  if missionId == nil then
    printLog("ERROR", "Server_GiveUpMission 的任务ID为空")
    return
  end
  local missionKind = getMissionKind(missionId)
  local md = self.m_AcceptedMissionId[missionKind]
  if md == nil then
    return nil
  end
  md[missionId] = nil
  if self:isDayantaMissionId(missionId) then
    activity.dayanta:missionGiveUp()
  end
  self:FlushCanAcceptMission()
  SendMessage(MsgID_Mission_MissionDel, missionId)
  SendMessage(MsgID_Mission_Common)
end
function MissionMgr:setCurTimePoint(time)
  self.m_JuBaoLeftTime = 300
  self.m_SchedulerHandler = scheduler.scheduleGlobal(handler(self, self.CaculaTime), 1)
end
function MissionMgr:CaculaTime()
  self.m_JuBaoLeftTime = self.m_JuBaoLeftTime - 1
  if self.m_JuBaoLeftTime <= 0 and self.m_SchedulerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_SchedulerHandler)
    self.m_JuBaoLeftTime = 0
  end
end
function MissionMgr:setDonateDaoJuTimes(tiems)
  self.m_hasDonateTimes = tiems
end
function MissionMgr:getDonateDaoJuTimes()
  return self.m_hasDonateTimes
end
function MissionMgr:Server_SyncTalkIdBeforeWar(missionId, missionPro)
  print("MissionMgr:Server_SyncTalkIdBeforeWar:", missionId, missionPro)
  if missionId == nil or missionPro == nil then
    return
  end
  local dataTable, missionKind = self:getMissionData(missionId)
  local dst = self:getDstData(dataTable, missionPro)
  local data = dst.data
  local talkId = dst.talkId
  dump(dst, "dst")
  dump(data, "data")
  dump(talkId, "talkId")
  if data ~= nil and talkId ~= nil then
    local md = self.m_AcceptedMissionId[missionKind] or {}
    local missionProData = md[missionId]
    if missionProData ~= nil then
      missionProData.showTalkBeforeWar = true
      getCurSceneView():ShowTalkView(talkId, function()
        print("\n\n\n\n\t-->>战斗前对话结束:", missionId)
        self:StartWarForMonster(missionId)
      end, missionId)
    end
  end
end
function MissionMgr:ShowDoubleExpSetView(num, type)
  if g_DataMgr:getIsSendFinished() == true then
    if num > g_LocalPlayer:getDoubleExpPoint() then
      local showTimes = self.m_AutoShowDoubleViewTimes[type]
      if showTimes == nil then
        showTimes = 0
      end
      self.m_AutoShowDoubleViewTimes[type] = showTimes + 1
      if showTimes == 0 then
        self.m_HasAddDoubleExpFlag = false
        getCurSceneView():addSubView({
          subView = CDoubleExpView.new(),
          zOrder = MainUISceneZOrder.menuView
        })
      elseif self.m_HasAddDoubleExpFlag == true then
        self.m_HasAddDoubleExpFlag = false
        getCurSceneView():addSubView({
          subView = CDoubleExpView.new(),
          zOrder = MainUISceneZOrder.menuView
        })
      end
    else
      local showTimes = self.m_AutoShowDoubleViewTimes[type]
      if showTimes == nil then
        showTimes = 0
      else
        showTimes = 1
      end
    end
  end
end
function MissionMgr:SetMissionHasAddDoubleExpFlag(flag)
  self.m_HasAddDoubleExpFlag = flag
end
function MissionMgr:ShowCommitPetView(mtype, tid, petList)
  if petList == nil then
    print(" ShowCommitPetView  没有数据 ")
    return
  elseif #petList <= 0 then
    return
  end
  local param = {}
  param.petObjIdList = petList
  if mtype == 701 then
    function param.commitListener(petid)
      Shimen.reqCommit({petid = petid})
    end
  elseif mtype == 901 then
    function param.commitListener(petid)
      SanJieLiLian.reqCommit({petid = petid})
    end
  else
    print(" 没有设置递交宠物回调   mtype ,tid ", mtype, tid)
  end
  OpenMissionCommitPetView(param)
end
function MissionMgr:Clean()
  self:ClearGuideExtend()
  self:RemoveAllMessageListener()
  if self.m_UpdateGuideDetectHandler then
    scheduler.unscheduleGlobal(self.m_UpdateGuideDetectHandler)
    self.m_UpdateGuideDetectHandler = nil
  end
end
if g_MissionMgr then
  g_MissionMgr:RemoveAllMessageListener()
  if g_MissionMgr.m_UpdateGuideDetectHandler then
    scheduler.unscheduleGlobal(g_MissionMgr.m_UpdateGuideDetectHandler)
    g_MissionMgr.m_UpdateGuideDetectHandler = nil
  end
  g_MissionMgr:delGuideAni()
  if g_TouchEvent then
    g_TouchEvent:unRegisterGlobalTouchEvent(g_MissionMgr)
  end
  if g_MissionMgr.m_UpdateHandler then
    scheduler.unscheduleGlobal(g_MissionMgr.m_UpdateHandler)
    g_MissionMgr.m_UpdateHandler = nil
  end
  if g_MissionMgr.m_ScheduleHandle ~= nil then
    scheduler.unscheduleGlobal(g_MissionMgr.m_ScheduleHandle)
    g_MissionMgr.m_ScheduleHandle = nil
  end
end
g_MissionMgr = MissionMgr.new()
gamereset.registerResetFunc(function()
  if g_MissionMgr then
    g_MissionMgr:Clean()
  end
  g_MissionMgr = MissionMgr.new()
end)
