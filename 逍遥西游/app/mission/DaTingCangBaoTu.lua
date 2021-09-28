CDaTingCangBaoTu = {}
function CDaTingCangBaoTu.init()
  CDaTingCangBaoTu.cnt = 0
  CDaTingCangBaoTu.requireAccpte = false
end
function CDaTingCangBaoTu.setTalkWords()
  local sayWords = data_MissionTalk[701701]
  local monsterName, mapName = CDaTingCangBaoTu.getMosterNameAndLoc()
  if monsterName == nil then
    monsterName = "贼王"
  end
  local word = string.format("听闻#<Y,>%s#拥有一份贼王埋藏宝藏路线的地图，谁要是能找到他，那真是要发呀。", monsterName)
  sayWords[1][2] = word
end
function CDaTingCangBaoTu.isCanAcceptMission()
  local mainHeroIns = g_LocalPlayer:getMainHero()
  local cLV = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
  local nLV = data_Mission_Activity[DaTingCangBaoTu_MissionId].lv
  if cLV >= nLV then
    return true
  else
    print(" ====>>等级不够")
    return false
  end
end
function CDaTingCangBaoTu.getMosterNameAndLoc()
  if CDaTingCangBaoTu.war_data_id ~= nil and CDaTingCangBaoTu.loc_id ~= nil then
    local _, name = data_getBossForWar(CDaTingCangBaoTu.war_data_id)
    monsterName = name
    mapName = data_BaotuTask_Loc[CDaTingCangBaoTu.loc_id].Name
  end
  return monsterName, mapName
end
function CDaTingCangBaoTu.delMonster()
  local mapView = g_MapMgr:getMapViewIns()
  mapView:DeleteMonster(monsterId)
end
function CDaTingCangBaoTu.updateBaoTuMission(param)
  CDaTingCangBaoTu.taskid = param.taskid
  CDaTingCangBaoTu.loc_id = param.loc_id
  CDaTingCangBaoTu.war_data_id = param.war_data_id
  CDaTingCangBaoTu.cnt = param.cnt or 0
  CDaTingCangBaoTu.onlogin = param.onlogin
  if CDaTingCangBaoTu.taskid ~= nil then
    CDaTingCangBaoTu.frushTableData()
    if CDaTingCangBaoTu.onlogin ~= 1 and CDaTingCangBaoTu.requireAccpte == true then
      getCurSceneView():ShowTalkView(701701, function()
        CDaTingCangBaoTu.TraceMission(DaTingCangBaoTu_MissionId)
      end, 50004)
      CDaTingCangBaoTu.requireAccpte = false
    end
    g_MissionMgr:Server_MissionAccepted(DaTingCangBaoTu_MissionId)
  end
  g_MissionMgr:flushCangBaoTuCanAccept()
  g_MissionMgr:flushMissionStatusForNpc()
end
function CDaTingCangBaoTu.flushTodayCanAccpte(baotu_cnt)
  CDaTingCangBaoTu.cnt = baotu_cnt
  g_MissionMgr:flushCangBaoTuCanAccept()
  if CDaTingCangBaoTu.cnt >= DaTingCangBaoTu_MaxCircle then
    g_MissionMgr:delDaTingCangBaoTu()
    g_MissionMgr:Server_GiveUpMission(DaTingCangBaoTu_MissionId)
  end
  g_MissionMgr:flushMissionStatusForNpc()
end
function CDaTingCangBaoTu.frushTableData()
  missionData = data_Mission_Activity[DaTingCangBaoTu_MissionId]
  local dst1 = missionData.dst1
  dst1.data = {
    CDaTingCangBaoTu.war_data_id,
    CDaTingCangBaoTu.loc_id
  }
  CDaTingCangBaoTu.setTalkWords()
end
function CDaTingCangBaoTu.delBaoTuMission(param)
  CDaTingCangBaoTu.type = param.type
  print(" #1--提交触发的，2--放弃触发的,3--失效触发的::删除藏宝图任务", CDaTingCangBaoTu.type)
  CDaTingCangBaoTu.taskid = nil
  CDaTingCangBaoTu.loc_id = nil
  CDaTingCangBaoTu.war_data_id = nil
  SendMessage(MsgID_Mission_Common)
  g_MissionMgr:delDaTingCangBaoTu()
  g_MissionMgr:flushCangBaoTuCanAccept()
  g_MissionMgr:Server_GiveUpMission(DaTingCangBaoTu_MissionId)
  SendMessage(MsgID_Mission_MissionDel, DaTingCangBaoTu_MissionId)
end
function CDaTingCangBaoTu.requestBaoTuMission()
  print("请求宝图任务")
  netsend.netmission.reqAcceptByType(1101)
  CDaTingCangBaoTu.requireAccpte = true
end
function CDaTingCangBaoTu.reqGiveup()
  print("请求放弃藏宝图任务")
  netsend.netmission.reqGiveupByType(1101, CDaTingCangBaoTu.taskid)
  CDaTingCangBaoTu.taskid = nil
  CDaTingCangBaoTu.loc_id = nil
  CDaTingCangBaoTu.war_data_id = nil
  CDaTingCangBaoTu.requireAccpte = false
end
function CDaTingCangBaoTu.ContinueMission(warType, isWatch, isReview, warResult)
  if isWatch then
    return
  end
  if isReview then
    return
  end
  if warType ~= WARTYPE_BAOTU_TASK then
    return
  end
  if warResult ~= WARRESULT_ATTACK_WIN then
    return
  end
  if CDaTingCangBaoTu.taskid ~= nil then
    CDaTingCangBaoTu.TraceMission(DaTingCangBaoTu_MissionId)
  end
end
function CDaTingCangBaoTu.TraceMission()
  local data = data_BaotuTask_Loc[CDaTingCangBaoTu.loc_id]
  function cbListener(isSucceed)
    if isSucceed then
      g_MissionMgr:ShowMonsterViewForMission(data_getBossForWar(CDaTingCangBaoTu.war_data_id), DaTingCangBaoTu_MissionId)
    end
  end
  if data == nil then
    if cbListener then
      cbListener(true)
    end
    return
  end
  g_MapMgr:AutoRoute(data.SceneId, {
    data.Loc[1],
    data.Loc[2]
  }, cbListener, nil, {
    data.Loc[1],
    data.Loc[2]
  }, {
    data.JumpLoc[1],
    data.JumpLoc[2]
  }, nil, RouteType_Monster)
end
CDaTingCangBaoTu.init()
gamereset.registerResetFunc(function()
  CDaTingCangBaoTu.init()
end)
