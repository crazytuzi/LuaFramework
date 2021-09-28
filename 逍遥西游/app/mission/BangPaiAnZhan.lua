BangPaiAnZhan = {}
BangPaiAnZhan_MissionId = 40007
function BangPaiAnZhan.init()
  BangPaiAnZhan.todayTime = -1
  BangPaiAnZhan.target_ = -1
  BangPaiAnZhan.taskid_ = -1
  BangPaiAnZhan.state_ = 0
  BangPaiAnZhan.warId_ = 0
  BangPaiAnZhan.loc_id_ = -1
  BangPaiAnZhan.bossid_ = -1
  BangPaiAnZhan.lastcircle = -1
  BangPaiAnZhan.MissionId = -1
  BangPaiAnZhan.curMapId = -1
  BangPaiAnZhan.createMonsterId = {}
  BangPaiAnZhan.hadDone = false
  BangPaiAnZhan.hadCommit = false
  BangPaiAnZhan.setIsAccepted(false)
  BangPaiAnZhan.setCanAcceptAnZhan(true)
  local mtb = data_Mission_BangPai[BangPaiAnZhan_MissionId]
  if mtb then
    BangPaiAnZhan.missionDes = mtb.missionDes
  end
end
function BangPaiAnZhan.getAcceptedStatus()
  local status = BangPaiAnZhan.state_
  if status == 1 then
    return MapRoleStatus_TaskNotComplete
  elseif status == 2 or status == 3 then
    return MapRoleStatus_TaskCanCommit
  end
  return nil
end
function BangPaiAnZhan.getMissionState()
  return BangPaiAnZhan.state_
end
function BangPaiAnZhan.getNpcId()
  return 90019
end
function BangPaiAnZhan.getIsAccepted()
  BangPaiAnZhan.isAccepted = BangPaiAnZhan.isAccepted or false
  return BangPaiAnZhan.isAccepted
end
function BangPaiAnZhan.setIsAccepted(boolV)
  boolV = boolV or false
  BangPaiAnZhan.isAccepted = boolV
end
function BangPaiAnZhan.getCanAcceptAnZhan()
  BangPaiAnZhan.canAccepted = BangPaiAnZhan.canAccepted or false
  if g_BpMgr:getOpenAnZhanFlag() ~= true or g_LocalPlayer:isNpcOptionUnlock(1065) == false or g_BpMgr:localPlayerHasBangPai() == false or BangPaiAnZhan.hadDone == true then
    BangPaiAnZhan.canAccepted = false
  else
    BangPaiAnZhan.canAccepted = true
  end
  return BangPaiAnZhan.canAccepted
end
function BangPaiAnZhan.getLevelLimited()
  if g_LocalPlayer:isNpcOptionUnlock(1065) == false then
    BangPaiAnZhan.m_levelLimited = false
  end
  return BangPaiAnZhan.m_levelLimited or false
end
function BangPaiAnZhan.setLevelLimited(boolV)
  boolV = boolV or false
  BangPaiAnZhan.m_levelLimited = boolV
end
function BangPaiAnZhan.setCanAcceptAnZhan(boolV)
  boolV = boolV or false
  BangPaiAnZhan.canAccepted = boolV
end
function BangPaiAnZhan.getUnLockLevel()
  local item = data_NpcTypeInfo[1065] or {}
  return item.zs, item.lv
end
function BangPaiAnZhan.dataUpdate(param)
  print("==============帮派暗战任务 刷新数据 ============ ")
  param = param or {}
  for k, v in pairs(param) do
    print(k, v)
  end
  if param.taskid then
    BangPaiAnZhan.taskid_ = param.taskid
  end
  if param.circle then
    param.circle = param.circle + 1
    BangPaiAnZhan.todayTime = param.circle
  end
  if param.target and param.circle then
    BangPaiAnZhan.target_ = param.target
    if param.circle - 1 >= param.target then
      param.state = 2
    elseif param.circle >= 1 then
      param.state = 1
    end
  end
  if param.state then
    BangPaiAnZhan.state_ = param.state
  end
  if param.bossid then
    BangPaiAnZhan.bossid_ = param.bossid
  end
  if param.locid then
    BangPaiAnZhan.locid_ = param.locid
  end
  if param.warid then
    BangPaiAnZhan.warId_ = param.warid
  end
  print("  ********************暗战数据刷新    ", param.state, BangPaiAnZhan.haveTalk, BangPaiAnZhan.todayTime)
  if param.taskid and param.taskid > -1 then
    if param.state == 1 or param.state == 2 then
      BangPaiAnZhan.flushAcceptedDate()
      BangPaiAnZhan.setIsAccepted(true)
      BangPaiAnZhan.setCanAcceptAnZhan(false)
      if param.new == true and param.state == 1 and BangPaiAnZhan.haveTalk ~= true and BangPaiAnZhan.todayTime == 1 then
        BangPaiAnZhan.haveTalk = true
        scheduler.performWithDelayGlobal(function()
          getCurSceneView():ShowTalkView(701631, function()
          end, BangPaiAnZhan_MissionId)
        end, 0.2)
      end
    elseif param.state == 3 then
      BangPaiAnZhan.setIsAccepted(false)
      BangPaiAnZhan.setCanAcceptAnZhan(false)
    end
    BangPaiAnZhan.flushCreateMonster()
    BangPaiAnZhan.hadDone = true
  end
end
function BangPaiAnZhan.flushAcceptedDate()
  if BangPaiAnZhan.taskid_ >= 0 then
    BangPaiAnZhan.MissionId = 40007
    local anzhanData = data_Mission_BangPai[BangPaiAnZhan.MissionId]
    if anzhanData == nil then
      print("暗战 没有填写导表吧  ")
      return
    end
    local dataAnZhan = data_Org_AnZhan[BangPaiAnZhan.bossid_]
    if dataAnZhan == nil then
      print(" 暗战 === 》 找不到  data_Org_AnZhan  表里的相关数据 ")
      return
    end
    local mName = dataAnZhan.BossName
    local mapData = data_CustomMapPos[BangPaiAnZhan.locid_]
    if mapData == nil then
      print(" 暗战 === 》 找不到  data_CustomMapPos  表里的相关数据 ")
      return
    end
    local rewardtable = data_Org_AnZhanAward or {}
    anzhanData.rewardCoin = rewardtable.Money or 0
    anzhanData.rewardExp = rewardtable.Exp or 0
    anzhanData.missionDes = string.format("击杀逃窜至#<Y,>%s#的#<Y,>敌帮劫匪#。（完成%d次击杀，可以找#<Y,>帮派师爷#获取相应奖励）", mapData.SceneName, data_getAnZhanLimit())
    local dst1 = anzhanData.dst1 or {}
    dst1.data = {
      BangPaiAnZhan.warId_,
      BangPaiAnZhan.locid_
    }
    dst1.des = string.format("追击#<Y,>%s#", tostring(mName))
    local showcircle = BangPaiAnZhan.todayTime
    if BangPaiAnZhan.todayTime >= data_getAnZhanLimit() + 1 then
      showcircle = data_getAnZhanLimit()
    end
    dst1.des = string.format("%s#<R>(%d/%d)#", dst1.des, showcircle, BangPaiAnZhan.target_)
    local missionPro = 0
    if BangPaiAnZhan.state_ == 2 then
      missionPro = 1
    end
    g_MissionMgr:Server_MissionUpdated(BangPaiAnZhan.MissionId, missionPro, {})
  end
end
function BangPaiAnZhan.deleteTask(taskid)
  print("帮派暗战任务  服务器通知删除   BangPaiAnZhan.state_ ", BangPaiAnZhan.state_, BangPaiAnZhan.hadCommit, BangPaiAnZhan.hadDone)
  if BangPaiAnZhan.taskid_ ~= nil and BangPaiAnZhan.taskid_ >= 0 then
    g_MissionMgr:delBangPaiAnZhan()
    if (BangPaiAnZhan.state_ == 1 or BangPaiAnZhan.state_ == 2) and BangPaiAnZhan.hadCommit ~= true then
      BangPaiAnZhan.hadDone = false
    end
    g_MissionMgr:Server_GiveUpMission(BangPaiAnZhan.MissionId)
    BangPaiAnZhan.setIsAccepted(false)
    BangPaiAnZhan.haveTalk = false
    BangPaiAnZhan.state_ = 0
    local mtb = data_Mission_BangPai[BangPaiAnZhan_MissionId]
    if mtb then
      mtb.missionDes = BangPaiAnZhan.missionDes or "帮派暗战"
    end
  end
end
function BangPaiAnZhan.getAnZhanMission()
  print("点击NPC 选项 开始请求暗战任务 ")
  BangPaiAnZhan.reqAccept()
end
function BangPaiAnZhan.reqAccept()
  netsend.netmission.reqAcceptByType(1004)
end
function BangPaiAnZhan.reqFinish()
  print("帮派暗战任务 请求完成 ")
  if BangPaiAnZhan.taskid_ ~= nil and BangPaiAnZhan.taskid_ >= 0 then
    netsend.netmission.reqFinishByType(1004, BangPaiAnZhan.taskid_)
  end
end
function BangPaiAnZhan.reqGaveUp()
  if BangPaiAnZhan.taskid_ ~= nil and BangPaiAnZhan.taskid_ >= 0 then
    BangPaiAnZhan.setIsAccepted(false)
    netsend.netmission.reqGiveupByType(1004, BangPaiAnZhan.taskid_)
    BangPaiAnZhan.hadDone = false
    BangPaiAnZhan.hadCommit = false
  end
end
function BangPaiAnZhan.reqCommit()
  if BangPaiAnZhan.taskid_ and BangPaiAnZhan.taskid_ > -1 then
    print("  ============== >>>   BangPaiAnZhan.reqCommit ", BangPaiAnZhan.state_, BangPaiAnZhan.hadCommit)
    if BangPaiAnZhan.state_ == 2 then
      BangPaiAnZhan.hadCommit = true
      getCurSceneView():ShowTalkView(701632, function()
        netsend.netmission.reqCommitByType(1004, BangPaiAnZhan.taskid_)
      end, BangPaiAnZhan.MissionId)
    else
      netsend.netmission.reqCommitByType(1004, BangPaiAnZhan.taskid_)
    end
  elseif BangPaiAnZhan.taskid_ == -1 then
  end
end
function BangPaiAnZhan.TouchMoster()
  print("  点到怪物了  ", BangPaiAnZhan.taskid_)
  if BangPaiAnZhan.taskid_ and BangPaiAnZhan.taskid_ > -1 then
    netsend.netteamwar.requestBangPaiAnZhan(BangPaiAnZhan.taskid_)
  end
end
function BangPaiAnZhan.TrackMission(missionid)
end
function BangPaiAnZhan.flushCreateMonster()
  return
end
BangPaiAnZhan.init()
gamereset.registerResetFunc(function()
  BangPaiAnZhan.init()
end)
