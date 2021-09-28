Shimen = {}
Shimen.Type_Talk = 1
Shimen.Type_War = 2
Shimen.Type_Objs = 3
Shimen.Type_ZhuaChong = 4
Shimen.Limei_Times = 20
Shimen.AcceptMissionId = 30004
Shimen.ShiMenGuideID = 70010
function Shimen.init()
  Shimen.today_times = 0
  Shimen.isAccepted_ = false
  Shimen.taskid_ = -1
  Shimen.type_ = -1
  Shimen.dataid_ = -1
  Shimen.status_ = -1
  Shimen.item_progress_ = nil
  Shimen.missionId_ = -1
  Shimen.giveTime = nil
  Shimen.isLifeSkillObj = false
end
function Shimen.isAccepted()
  return Shimen.isAccepted_
end
function Shimen.flushGiveUpTime(time)
  Shimen.giveTime = time
end
function Shimen.getAcceptedStatus()
  local status = Shimen.status_
  if status == 1 then
    return MapRoleStatus_TaskNotComplete
  elseif status == 2 or status == 3 then
    return MapRoleStatus_TaskCanCommit
  end
end
function Shimen.setAccepted(isAccepted)
  Shimen.isAccepted_ = isAccepted
  g_MissionMgr:flushShimenCanAccept()
end
function Shimen.GotoShimenNpc()
  local shimenNpcId = g_LocalPlayer:getShimenNpcId()
  if shimenNpcId then
    g_MapMgr:AutoRouteToNpc(shimenNpcId, function(isSucceed)
      if isSucceed and CMainUIScene.Ins then
        CMainUIScene.Ins:ShowNormalNpcViewById(shimenNpcId)
      end
    end)
  end
end
function Shimen.getTaskPetId()
  return Shimen.petid, Shimen.missionId_
end
function Shimen.setTaskPetId(value)
  Shimen.petid = value
end
function Shimen.update(param)
  print("Shimen.update  *************** ")
  local oldId = Shimen.taskid_
  if param.taskid ~= nil then
    Shimen.taskid_ = param.taskid
  end
  if param.type ~= nil then
    Shimen.type_ = param.type
  end
  if param.data_id ~= nil then
    Shimen.dataid_ = param.data_id
  end
  if param.circle ~= nil then
    Shimen.today_times = param.circle
  end
  Shimen.item_progress_ = param.item_progress
  local state = param.state
  if state ~= nil then
    Shimen.status_ = state
    print("-->state:", state)
    if state == 0 then
      Shimen.setAccepted(false)
      Shimen.deleteMission()
    elseif state == 3 then
      AwardPrompt.ShowMissionCmp()
      Shimen.setAccepted(false)
      Shimen.deleteMission()
      g_MissionMgr:flushMissionStatusForNpc()
      g_MissionMgr:GuideIdComplete(GuideId_Shimen)
    else
      Shimen.setAccepted(true)
      Shimen.flushAcceptedData()
      if oldId ~= Shimen.taskid_ then
        g_MissionMgr:NewMission(Shimen.dataid_)
      end
    end
  end
end
function Shimen.flushTodayTimes(times)
  print("Shimen.flushTodayTimes:", times)
  if times ~= nil then
    Shimen.today_times = times
    g_MissionMgr:flushShimenCanAccept()
    g_MissionMgr:flushMissionStatusForNpc()
  end
end
function Shimen.deleteMission()
  if Shimen.missionId_ > 0 then
    g_MissionMgr:delShimen(Shimen.missionId_)
    Shimen.missionId_ = -1
  end
end
function Shimen.isTimesLevel()
  return Shimen.today_times < Shimen.Limei_Times
end
function Shimen.flushAcceptedData()
  if Shimen.isAccepted_ == false then
    return
  end
  Shimen.isLifeSkillObj = false
  local objs, missionData
  if Shimen.type_ == Shimen.Type_Talk then
    Shimen.missionId_ = 30001
    local talkData = data_ShiMen_TalkTask[Shimen.dataid_]
    missionData = data_Mission_Division[Shimen.missionId_]
    local dst1 = missionData.dst1
    dst1.data = talkData.NpcId
    dst1.talkId = talkData.TalkId
    local _, name = data_getRoleShapeAndName(talkData.NpcId)
    dst1.des = string.format("去找#<Y,>%s#打探一番", name)
    print("dst1.des-->", dst1.des)
  elseif Shimen.type_ == Shimen.Type_War then
    Shimen.missionId_ = 30002
    local mapData = data_CustomMapPos[Shimen.dataid_]
    if mapData == nil then
      return
    end
    missionData = data_Mission_Division[Shimen.missionId_]
    local dst1 = missionData.dst1
    dst1.data = {
      mapData.SceneID,
      mapData.WarPos[1],
      mapData.WarPos[2]
    }
    dst1.param = {
      mapData.SceneID,
      mapData.JumpPos[1],
      mapData.JumpPos[2]
    }
    local mapData = data_MapInfo[mapData.SceneID] or {}
    local mapName = mapData.name or ""
    dst1.des = string.format("去%s巡逻", mapName)
    dump(missionData)
  elseif Shimen.type_ == Shimen.Type_Objs then
    Shimen.missionId_ = 30003
    local objData = data_ShiMen_GiveItemTask[Shimen.dataid_]
    missionData = data_Mission_Division[Shimen.missionId_]
    local dst1 = missionData.dst1
    local p = objData.NeedItem or {}
    dst1.param = {}
    for k, v in pairs(p) do
      dst1.param[#dst1.param + 1] = {k, v}
      if GetItemTypeByItemTypeId(k) == ITEM_LARGE_TYPE_LIFEITEM then
        Shimen.isLifeSkillObj = true
      end
      dst1.des = string.format("找到#<CI:%d>%s#", k, data_getItemName(k))
      break
    end
    local objPro = Shimen.item_progress_
    if objPro then
      objs = {}
      for k, v in pairs(objPro) do
        objs[#objs + 1] = {
          tonumber(k),
          v
        }
      end
    end
  elseif Shimen.type_ == Shimen.Type_ZhuaChong then
    Shimen.missionId_ = 30005
    missionData = data_Mission_Division[Shimen.missionId_]
    local dst1 = missionData.dst1 or {}
    local dst2 = missionData.dst2 or {}
    local objData = data_ShiMen_CatchPetTask[Shimen.dataid_]
    local p = objData.NeedPet or {}
    dst1.param = {}
    Shimen.petid = nil
    for k, v in pairs(p) do
      dst1.param[#dst1.param + 1] = {k, v}
      local petData = data_getRoleData(k) or {}
      if petData.NAME ~= nil then
        Shimen.petid = k
        dst1.des = string.format("捕抓#<Y,>%s#", petData.NAME)
        if Shimen.status_ == 2 then
          dst2.des = string.format("捕抓#<Y,>%s#", petData.NAME)
        end
        break
      end
      print("读取不到导表相关的数据************* ")
      break
    end
  end
  local coin, exp = Shimen.getAward(Shimen.today_times + 1)
  print("-->coin:", coin)
  missionData.rewardCoin = math.floor(coin)
  missionData.rewardExp = math.floor(exp)
  local missionPro = 0
  if Shimen.status_ == 2 and Shimen.type_ ~= Shimen.Type_Objs then
    missionPro = 1
  end
  g_MissionMgr:Server_MissionUpdated(Shimen.missionId_, missionPro, objs)
end
function Shimen.CheckMissionPet()
  if Shimen.missionId_ == 30005 and Shimen.petid ~= nil then
    if Shimen.status_ == 1 then
      g_MissionMgr:addShotageObj(Shimen.petid, Shimen.missionId_)
      SendMessage(MsgID_Stall_UpdateOneKindGoods, {
        goodId = Shimen.petid
      })
    else
      g_MissionMgr:removeShotageObj(Shimen.petid, Shimen.missionId_)
      SendMessage(MsgID_Stall_UpdateOneKindGoods, {
        goodId = Shimen.petid
      })
      Shimen.petid = nil
    end
  end
end
function Shimen.isMissionId(mid)
  return mid == 30001 or mid == 30002 or mid == 30003
end
function Shimen.isShimenFightMissionId(mid)
  return mid == 30002
end
function Shimen.getAward(circle)
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local awardData = data_TaskExpShiMen[lv] or {}
  exp = awardData.BaseExp or 0
  exp = math.floor(exp * circle / 55)
  local coin = awardData.BaseCoin or 0
  coin = math.floor(coin * circle / 55)
  return coin, exp
end
local coinAdd = {
  {
    -100,
    49,
    500
  },
  {
    50,
    59,
    1500
  },
  {
    60,
    79,
    2500
  },
  {
    80,
    99,
    3000
  },
  {
    100,
    119,
    3500
  },
  {
    120,
    139,
    4000
  },
  {
    140,
    159,
    4500
  },
  {
    160,
    100000,
    5000
  }
}
function Shimen._getCoinAdd(lv)
  for i, d in ipairs(coinAdd) do
    if lv >= d[1] and lv <= d[2] then
      return d[3]
    end
  end
  return 500
end
function Shimen.delete(taskid)
  Shimen.setAccepted(false)
  if Shimen.missionId_ ~= -1 then
    g_MissionMgr:Server_GiveUpMission(Shimen.missionId_)
    Shimen.missionId_ = -1
  end
end
function Shimen.reqAccept()
  local serviceTime = g_DataMgr:getServerTime()
  if serviceTime == nil or serviceTime < 0 then
    return
  end
  if Shimen.giveTime ~= nil and type(Shimen.giveTime) == "number" and serviceTime - Shimen.giveTime <= 300 then
    local timedec = 300 - (serviceTime - Shimen.giveTime)
    local titem = data_MissionTalk[300010] or {}
    titem = titem[1] or {}
    local strdec = tostring(checkint(timedec)) .. "秒"
    if timedec >= 60 then
      local v1, v2 = math.modf(timedec / 60)
      strdec = tostring(v1) .. "分钟"
    end
    titem[2] = string.format("目前没有事情交代你去处理，你等#<Y,>%s#后再来吧。", strdec)
    getCurSceneView():ShowTalkView(300010, function()
    end, SanJieLiLian.missionId_)
    return
  end
  Shimen.giveTime = nil
  print("请求领取师门任务")
  netsend.netmission.reqAcceptByType(701, Shimen.taskid_)
end
function Shimen.missionCmp()
  if Shimen.type_ == Shimen.Type_Talk then
    if Shimen.status_ == 1 then
      Shimen.reqFinish()
    else
      Shimen.reqCommit()
    end
  elseif Shimen.type_ == Shimen.Type_War then
    if Shimen.status_ == 1 then
      local mapViewIns = g_MapMgr:getMapViewIns()
      if mapViewIns then
        mapViewIns:startAutoXunluo_new(function(isSucceed)
          print("---> 请求战斗")
          netsend.netwar.shimenWar(Shimen.taskid_)
        end)
      end
    else
      Shimen.reqCommit()
    end
  elseif Shimen.type_ == Shimen.Type_Objs then
    Shimen.reqCommit()
  elseif Shimen.type_ == Shimen.Type_ZhuaChong then
    netsend.netmission.reqCommitPetList(701, Shimen.taskid_)
  end
end
function Shimen.reqFinish()
  netsend.netmission.reqFinishByType(701, Shimen.taskid_)
end
function Shimen.reqCommit(extr)
  print("请求交付师门任务")
  netsend.netmission.reqCommitByType(701, Shimen.taskid_, extr)
end
function Shimen.reqGiveup()
  print("请求放弃师门任务")
  netsend.netmission.reqGiveupByType(701, Shimen.taskid_)
end
Shimen.init()
gamereset.registerResetFunc(function()
  Shimen.init()
end)
