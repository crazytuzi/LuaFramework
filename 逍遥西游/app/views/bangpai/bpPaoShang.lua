BangPaiPaoShang = {}
BangPaiPaoShang.state = 0
BangPaiPaoShang.isCanAccept_ = false
function BangPaiPaoShang.init()
  BangPaiPaoShang.local_progess = 0
  BangPaiPaoShang.local_target = "五万两"
  BangPaiPaoShang.taskid = nil
  BangPaiPaoShang.goods = nil
  BangPaiPaoShang.target = nil
  BangPaiPaoShang.progress = nil
  BangPaiPaoShang.isCanAccept_ = true
  BangPaiPaoShang.circle = 0
  BangPaiPaoShang.commitOneTime = false
  BangPaiPaoShang.todayTimes = 0
end
function BangPaiPaoShang.setCircle(times)
  if times == nil then
    return
  end
  BangPaiPaoShang.circle = times
end
function BangPaiPaoShang.setTodayCanRun(hasRunCircle)
  local bpLevel = g_BpMgr:getBpLevel() or 1
  local leftTimes = data_Variables.PaoShangPersonalLimit[bpLevel] - hasRunCircle
  BangPaiPaoShang.todayTimes = leftTimes
end
function BangPaiPaoShang.getCircle(...)
  return BangPaiPaoShang.circle
end
function BangPaiPaoShang.isReachNeedLevel()
  local mainHeroIns = g_LocalPlayer:getMainHero()
  local cLV = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
  local nLV = data_Mission_BangPai[Business_MissionId].lv
  if cLV >= nLV then
    return true
  else
    print(" ====>>等级不够")
    return false
  end
end
function BangPaiPaoShang.setProgess(mnpcid, mitemid)
  local price = BangPaiPaoShang.goods[tostring(mnpcid)][tostring(mitemid)] or 0
  BangPaiPaoShang.local_progess = BangPaiPaoShang.local_progess + price
end
function BangPaiPaoShang.getAcceptedStatus(npcid)
  if BangPaiPaoShang.goods == nil then
    return
  end
  local objItem_list = BangPaiPaoShang.goods[tostring(90021)]
  local itemList_len = table.nums(objItem_list)
  if BangPaiPaoShang.progress < BangPaiPaoShang.target and itemList_len ~= 0 then
    return MapRoleStatus_TaskNotComplete
  elseif BangPaiPaoShang.progress >= BangPaiPaoShang.target then
    return MapRoleStatus_TaskCanCommit
  end
end
function BangPaiPaoShang.isCanAccetp()
  return BangPaiPaoShang.isCanAccept_
end
function BangPaiPaoShang.setAccepted(isAccepted)
  BangPaiPaoShang.isCanAccept_ = isAccepted
  g_MissionMgr:flushBangPaiPaoshangCanAccept()
end
function BangPaiPaoShang.GoToPaoShangNPC()
  g_MapMgr:AutoRouteToNpc(NPC_BangPaiShangRen_ID, function(isSucceed)
    if isSucceed and CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(NPC_BangPaiShangRen_ID)
    end
  end)
end
function BangPaiPaoShang.flushAcceptedData()
  local missionData
  local mainHeroIns = g_LocalPlayer:getMainHero()
  if mainHeroIns == nil then
    print(" mainHeroIns == nil")
    return
  end
  missionData = data_Mission_BangPai[Business_MissionId]
  if missionData == nil then
    print("=========================>>导表为空")
    return
  end
  local dst1 = missionData.dst1
  dst1.des = string.format("为帮派筹集不得低于#<Y>%s两#的资金", BangPaiPaoShang.local_target)
  local missionPro = 0
  if BangPaiPaoShang.taskid ~= nil and BangPaiPaoShang.progress >= BangPaiPaoShang.target then
    missionPro = 1
  end
  g_MissionMgr:Server_MissionUpdated(Business_MissionId, missionPro, {})
end
function BangPaiPaoShang.dataUpdate(param)
  print("===================>>更新跑商数据任务id", param.taskid, "目标:", param.target, "进度:", param.progress)
  local m_onlogin = param.onlogin
  g_BpMgr:send_getTodayBpPaoShangTimes()
  local isCurLVCanAcceptMission = BangPaiPaoShang.isReachNeedLevel()
  if g_BpMgr:localPlayerHasBangPai() and isCurLVCanAcceptMission and m_onlogin == nil and param.progress == 0 and param.new == true then
    BangPaiPaoShang.ShowTalk(701611, Business_MissionId)
  end
  local oldId = BangPaiPaoShang.taskid
  if param.taskid ~= nil then
    BangPaiPaoShang.flushAcceptedData()
    BangPaiPaoShang.taskid = param.taskid
    BangPaiPaoShang.setAccepted(false)
  end
  if param.goods ~= nil then
    BangPaiPaoShang.goods = param.goods
  end
  if param.progress ~= nil then
    BangPaiPaoShang.progress = param.progress
    BangPaiPaoShang.local_progess = BangPaiPaoShang.progress
    if BangPaiPaoShang.commitOneTime == true then
      BangPaiPaoShang.isSucceedToCommint()
    end
  else
    BangPaiPaoShang.local_progess = 0
  end
  if param.target ~= nil then
    BangPaiPaoShang.target = param.target
  end
  if BangPaiPaoShang.progress < BangPaiPaoShang.target and BangPaiPaoShang.taskid ~= nil then
    if table.nums(BangPaiPaoShang.goods[tostring(90021)]) == 0 then
      BangPaiPaoShang.setAccepted(true)
    else
      BangPaiPaoShang.setAccepted(false)
    end
  elseif BangPaiPaoShang.progress >= BangPaiPaoShang.target then
    BangPaiPaoShang.setAccepted(false)
    g_MissionMgr:flushMissionStatusForNpc()
    g_MissionMgr:flushBangPaiPaoshangCanAccept()
    BangPaiPaoShang.flushAcceptedData()
  end
  if oldId ~= BangPaiPaoShang.taskid then
    g_MissionMgr:NewMission(Business_MissionId)
  end
  BangPaiPaoShang.commitOneTime = false
end
function BangPaiPaoShang.taskDel(taskid_)
  BangPaiPaoShang.taskid = nil
  BangPaiPaoShang.setAccepted(true)
  g_MissionMgr:delBangPaiPaoShang()
  SendMessage(MsgID_Mission_Common)
  g_MissionMgr:flushBangPaiPaoshangCanAccept()
  g_MissionMgr:Server_GiveUpMission(Business_MissionId)
end
function BangPaiPaoShang.ShowTalk(talkid, MissionId)
  getCurSceneView():ShowTalkView(talkid, nil, MissionId)
end
function BangPaiPaoShang.reqAccept()
  print("请求领取帮派跑商任务")
  netsend.netmission.reqAcceptByType(1003, BangPaiPaoShang.taskid)
end
function BangPaiPaoShang.reqCommit()
  print("请求交付帮派任务")
  netsend.netmission.reqCommitByType(1003, BangPaiPaoShang.taskid)
  g_BpMgr:send_getTodayBpPaoShangTimes()
end
function BangPaiPaoShang.reqGiveup()
  print("请求放弃帮派任务")
  netsend.netmission.reqGiveupByType(1003, BangPaiPaoShang.taskid)
  BangPaiPaoShang.setAccepted(true)
  g_MissionMgr:Server_GiveUpMission(Business_MissionId)
end
function BangPaiPaoShang.MissionCommit()
  if table.nums(BangPaiPaoShang.goods[tostring(90021)]) ~= 0 then
    BangPaiPaoShang.setAccepted(false)
    ShowNotifyTips("任务还没有完成")
    return
  end
  BangPaiPaoShang.reqCommit()
  g_MissionMgr:FlushCanAcceptMission()
  BangPaiPaoShang.setAccepted(true)
end
function BangPaiPaoShang.PoPView(itemId, npcId)
  local function confirmFunc()
    BangPaiPaoShang.CommitTraceMission(npcId, itemId)
  end
  local price = BangPaiPaoShang.goods[tostring(npcId)][tostring(itemId)]
  local npcName = data_NpcInfo[npcId].name
  local itemName = data_Org_PaoShangTask[itemId].Name
  if price == nil then
    print("玩家有病才会点那么快")
    return
  end
  local m_text = string.format("是否同意将#<Y>%s#以#<Y>%s两#的价格卖给#<Y>%s#", itemName, price, npcName)
  local tempView = CPopWarning.new({
    title = "提示",
    text = m_text,
    confirmFunc = confirmFunc,
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
function BangPaiPaoShang.CommitTraceMission(npcid, itemid)
  netsend.netmission.commitBusinessTrace(npcid, tonumber(itemid))
  BangPaiPaoShang.commitOneTime = true
  BangPaiPaoShang.m_itemId = itemid
  BangPaiPaoShang.m_npciId = npcid
end
function BangPaiPaoShang.isSucceedToCommint()
  if BangPaiPaoShang.m_itemId == nil then
    return
  else
    ShowNotifyTips("本次物品交易成功")
  end
  BangPaiPaoShang.setProgess(BangPaiPaoShang.m_npciId, BangPaiPaoShang.m_itemId)
  if table.nums(BangPaiPaoShang.goods[tostring(90021)]) == 0 and BangPaiPaoShang.local_progess < BangPaiPaoShang.target then
    BangPaiPaoShang.reqGiveup()
    g_MissionMgr:flushBangPaiPaoshangCanAccept()
    BangPaiPaoShang.popViewIsContinue()
  end
  SendMessage(MsgID_BP_PaoShang_DelItem)
  g_MissionMgr:FlushCanAcceptMission()
end
function BangPaiPaoShang.popViewIsContinue()
  local tempView = CPopWarning.new({
    title = "提示",
    text = "很遗憾#<E:36>#,本次跑商没有筹集到5万银两,任务失败。是否返回#<Y,>帮派商人#处继续任务?",
    cancelFunc = nil,
    confirmFunc = function()
      BangPaiPaoShang.GoToPaoShangNPC()
    end,
    cancelText = "取消",
    confirmText = "确定",
    hideInWar = true,
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
BangPaiPaoShang.init()
gamereset.registerResetFunc(function()
  BangPaiPaoShang.init()
end)
