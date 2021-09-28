local netactivity = {}
function netactivity.allKejuExamPaper(param, ptc_main, ptc_sub)
  print("netactivity.allKejuExamPaper:", param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  activity.keju:recvKejuAllPapers(param.hid, param.question, param.lefttime, param.pos, param.score)
end
function netactivity.KejuScore(param, ptc_main, ptc_sub)
  print("netactivity.KejuScore:", param, ptc_main, ptc_sub)
end
function netactivity.exitKeju(param, ptc_main, ptc_sub)
  print("netactivity.exitKeju:", param, ptc_main, ptc_sub)
end
function netactivity.KejuStatus(param, ptc_main, ptc_sub)
  print("netactivity.KejuStatus:", param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  local huodong_name = param.huodong_name
  if huodong_name == "keju" then
    activity.keju:KejuStatusChanged(param.state)
  end
  if huodong_name == "leitai" then
    activity.leitai:setStatus(param.state)
  end
  if huodong_name == "huolicost" then
    activity.huoliHuodong:setStatus(param.state)
  end
  if huodong_name == "msgboard" then
    activity.leaveword:setStatus(param.state)
  end
  if huodong_name == "tianbing" then
    activity.tbsj:setStatus(param.state)
  end
  if huodong_name == "yizhandaodi" then
    activity.yzdd:setStatus(param.state)
  end
  if huodong_name == "dragonboat" then
    activity.duanWu:setStatus(param.state)
  end
  if huodong_name == "xuezhanshachang" then
    activity.xzsc:setStatus(param.state)
  end
  if huodong_name == "tianjiangbaoxiang" then
    activity.tjbx:setStatus(param.state)
  end
  if huodong_name == "tiandiqishu" then
    activity.tiandiqishu:setStatus(param.state)
  end
  if huodong_name == "guoqing" then
    activity.guoqingMgr:setStatus(param.state)
  end
end
function netactivity.KejuDianshiReady(param, ptc_main, ptc_sub)
  print("netactivity.KejuDianshiReady:", param, ptc_main, ptc_sub)
  activity.keju:showDianshiReady(param.lefttime)
end
function netactivity.KejuDianshiRank(param, ptc_main, ptc_sub)
  print("netactivity.KejuDianshiRank:", param, ptc_main, ptc_sub)
  if param then
    activity.keju:hadGetDianshiRank(param.rank)
  else
    activity.keju:hadGetDianshiRank(param)
  end
end
function netactivity.KejuDianshiAwardResult(param, ptc_main, ptc_sub)
  print("netactivity.KejuDianshiReady:", param, ptc_main, ptc_sub)
end
function netactivity.EventDataUpdate(param, ptc_main, ptc_sub)
  print("netactivity.EventDataUpdate:", param, ptc_main, ptc_sub)
  activity.event:update(param)
end
function netactivity.EventAwardReciveResult(param, ptc_main, ptc_sub)
  print("netactivity.EventAwardReciveResult:", param, ptc_main, ptc_sub)
  if param then
    activity.event:reciveResult(param.hid, param.result)
  end
end
function netactivity.TiantingUpdate(param, ptc_main, ptc_sub)
  print("netactivity.TiantingUpdate:", param, ptc_main, ptc_sub)
  if param then
    activity.tianting:UpdateData(param.taskid, param.taskdata, param.cnt, param.monsterlv)
  end
end
function netactivity.ExitTiantingFb(param, ptc_main, ptc_sub)
  print("netactivity.ExitTiantingFb:", param, ptc_main, ptc_sub)
  activity.tianting:ExitFb()
end
function netactivity.EnterTiantingFb(param, ptc_main, ptc_sub)
  print("netactivity.EnterTiantingFb:", param, ptc_main, ptc_sub)
  activity.tianting:EnterFbSucceed()
end
function netactivity.YueKaTimeUpdate(param, ptc_main, ptc_sub)
  print("netactivity.YueKaTimeUpdate:", param, ptc_main, ptc_sub)
  local restTime = param.lefttime
  if restTime ~= nil then
    activity.event:setYueKaEndTime(restTime)
  end
end
function netactivity.setLWZBMathState(param, ptc_main, ptc_sub)
  print("netactivity.setLWZBMathState:", param, ptc_main, ptc_sub)
  activity.leitai:setLWZBMathState(param)
end
function netactivity.updateLWZBRank(param, ptc_main, ptc_sub)
  print("netactivity.updateLWZBRank:", param, ptc_main, ptc_sub)
  activity.leitai:updateLWZBRank(param)
end
function netactivity.setLWZBEnemyInfo(param, ptc_main, ptc_sub)
  print("netactivity.setLWZBEnemyInfo:", param, ptc_main, ptc_sub)
  param.name = CheckStringIsLegal(param.name, true, REPLACECHAR_FOR_INVALIDNAME)
  activity.leitai:setLWZBEnemyInfo(param)
end
function netactivity.setLWZBBaseInfo(param, ptc_main, ptc_sub)
  print("netactivity.setLWZBBaseInfo:", param, ptc_main, ptc_sub)
  if param.lst ~= nil then
    for _, data in pairs(param.lst) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  activity.leitai:showLeiWangZhengBaDlgWithBaseInfo(param)
end
function netactivity.updateLWZBInfo(param, ptc_main, ptc_sub)
  print("netactivity.updateLWZBInfo:", param, ptc_main, ptc_sub)
  activity.leitai:updateLWZBInfo(param)
end
function netactivity.getTthjPro(param, ptc_main, ptc_sub)
  if param.lst ~= nil then
    for _, data in pairs(param.lst) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  activity.tthj:flushPlayerInfo(param)
end
function netactivity.warOver(param, ptc_main, ptc_sub)
  activity.tthj:warOverBack(param)
end
function netactivity.getXingXiuMonsterInf(param, ptc_main, ptc_sub)
  print("  刷新24星宿怪物  **************")
  dump(param)
  activity.xingxiu:getMonsterInfo(param)
end
function netactivity.delXingXiuMonster(param, ptc_main, ptc_sub)
  print(" 删除 24 星宿怪物 ***************** ")
  activity.xingxiu:delMoster(param)
end
function netactivity.closeLWZBMatchDlg(param, ptc_main, ptc_sub)
  print("netactivity.closeLWZBMatchDlg:", param, ptc_main, ptc_sub)
  CloseLBZBMatchingDlg()
end
function netactivity.huodongSchedule(param, ptc_main, ptc_sub)
  print("netactivity.huodongSchedule:", param, ptc_main, ptc_sub)
  print_lua_table(param)
  activity.hdschedule:setSchedule(param.lst)
end
function netactivity.huodongTianBingShenJiangCircleNum(param, ptc_main, ptc_sub)
  print("netactivity.huodongTianBingShenJiangCircleNum:", param, ptc_main, ptc_sub)
  activity.tbsj:SetTBSJCircleNum(param.circle)
end
function netactivity.keJueQuetionAnswer(param, ptc_main, ptc_sub)
  print("netactivity.huodongTianBingShenJiangCircleNum:", param, ptc_main, ptc_sub)
  SendMessage(MsgID_Keju_EachQuetionAnswer, param)
end
function netactivity.setYZDDMathState(param, ptc_main, ptc_sub)
  print("netactivity.setYZDDMathState:", param, ptc_main, ptc_sub)
  activity.yzdd:setYZDDMathState(param)
end
function netactivity.updateYZDDRank(param, ptc_main, ptc_sub)
  print("netactivity.updateYZDDRank:", param, ptc_main, ptc_sub)
  if param.lst ~= nil then
    for _, data in pairs(param.lst) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  activity.yzdd:updateYZDDRank(param)
end
function netactivity.setYZDDEnemyInfo(param, ptc_main, ptc_sub)
  print("netactivity.setYZDDEnemyInfo:", param, ptc_main, ptc_sub)
  param.name = CheckStringIsLegal(param.name, true, REPLACECHAR_FOR_INVALIDNAME)
  activity.yzdd:setYZDDEnemyInfo(param)
end
function netactivity.setYZDDBaseInfo(param, ptc_main, ptc_sub)
  print("netactivity.setYZDDBaseInfo:", param, ptc_main, ptc_sub)
  if param.lst ~= nil then
    for _, data in pairs(param.lst) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  activity.yzdd:showYZDDDlgWithBaseInfo(param)
end
function netactivity.updateYZDDInfo(param, ptc_main, ptc_sub)
  print("netactivity.updateYZDDInfo:", param, ptc_main, ptc_sub)
  activity.yzdd:updateYZDDInfo(param)
end
function netactivity.closeYZDDMatchDlg(param, ptc_main, ptc_sub)
  print("netactivity.closeYZDDMatchDlg:", param, ptc_main, ptc_sub)
  CloseYZDDMatchingDlg()
end
function netactivity.xzscBaseInfo(param, ptc_main, ptc_sub)
  print("netactivity.xzscBaseInfo:", param, ptc_main, ptc_sub)
  if param.lst ~= nil then
    for _, data in pairs(param.lst) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  activity.xzsc:showXZSCDlgWithBaseInfo(param)
end
function netactivity.xzscMatchState(param, ptc_main, ptc_sub)
  print("netactivity.xzscMatchState:", param, ptc_main, ptc_sub)
  print_lua_table(param)
  if param.lst ~= nil then
    for _, data in pairs(param.lst) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  local state = param.state
  local info = param.lst or {}
  local teamScore = param.team_score or 0
  activity.xzsc:setXZSCMathState(state, info, teamScore)
end
function netactivity.xzscMatchInfo(param, ptc_main, ptc_sub)
  print("netactivity.xzscMatchInfo:", param, ptc_main, ptc_sub)
  print_lua_table(param)
  if param.lst ~= nil then
    for _, data in pairs(param.lst) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  local info = param.lst or {}
  local teamScore = param.team_score or 0
  activity.xzsc:setXZSCEnemyInfo(info, teamScore)
end
function netactivity.enterXZSCMap(param, ptc_main, ptc_sub)
  print("netactivity.enterXZSCMap:", param, ptc_main, ptc_sub)
  activity.xzsc:EnterXZSC()
end
function netactivity.updateXZSC(param, ptc_main, ptc_sub)
  print("netactivity.updateXZSC:", param, ptc_main, ptc_sub)
  activity.xzsc:updateXZSC(param)
end
function netactivity.allowDule(param, ptc_main, ptc_sub)
  print("netactivity.allowDule:", param, ptc_main, ptc_sub)
  g_DuleMgr:allowDule(param.cd)
end
function netactivity.queryDulePlayerResult(param, ptc_main, ptc_sub)
  print("netactivity.queryDulePlayerResult:", param, ptc_main, ptc_sub)
  g_DuleMgr:queryDulePlayerResult(param.pid, param.name)
end
function netactivity.receiveDuleRequest(param, ptc_main, ptc_sub)
  print("netactivity.receiveDuleRequest:", param, ptc_main, ptc_sub)
  g_DuleMgr:receiveDuleRequest(param.pid, param.name, param.type, param.rt)
end
function netactivity.setDuleStatus(param, ptc_main, ptc_sub)
  print("netactivity.setDuleStatus:", param, ptc_main, ptc_sub)
  g_DuleMgr:setDuleStatus(param.status)
end
function netactivity.setDuleMatchInfo(param, ptc_main, ptc_sub)
  print("netactivity.setDuleMatchInfo:", param, ptc_main, ptc_sub)
  local rt = param.rt or 0
  local attack = param.attack
  local defend = param.defend
  g_DuleMgr:setDuleMatchInfo(rt, attack, defend)
end
function netactivity.updateDuleReadyStatus(param, ptc_main, ptc_sub)
  print("netactivity.updateDuleReadyStatus:", param, ptc_main, ptc_sub)
  g_DuleMgr:updateDuleReadyStatus(param.pid, param.ready)
end
function netactivity.newJoinPlayerToDuel(param, ptc_main, ptc_sub)
  print("netactivity.newJoinPlayerToDuel:", param, ptc_main, ptc_sub)
  g_DuleMgr:newJoinPlayerToDuel(param)
end
function netactivity.playerQuitDuel(param, ptc_main, ptc_sub)
  print("netactivity.playerQuitDuel:", param, ptc_main, ptc_sub)
  g_DuleMgr:playerQuitDuel(param.pid)
end
function netactivity.closeDuelMatchingDlg(param, ptc_main, ptc_sub)
  print("netactivity.closeDuelMatchingDlg:", param, ptc_main, ptc_sub)
  g_DuleMgr:closeDuelMatchingDlg()
end
function netactivity.enterDuelMap(param, ptc_main, ptc_sub)
  print("netactivity.enterDuelMap:", param, ptc_main, ptc_sub)
  g_DuleMgr:EnterDuleMap()
end
function netactivity.closeXZSCMatching(param, ptc_main, ptc_sub)
  print("netactivity.closeXZSCMatching:", param, ptc_main, ptc_sub)
  activity.xzsc:closeXZSCMatching()
end
function netactivity.popTBSJConfirmView(param, ptc_main, ptc_sub)
  print("netactivity.popTBSJConfirmView:", param, ptc_main, ptc_sub)
  local progress = param.progress
  if progress then
    activity.tbsj:popTBSJConfirmView(progress)
  end
end
function netactivity.qiXiLeaveWordsContent(param, ptc_main, ptc_sub)
  print("netactivity.qiXiLeaveWordsContent:", param, ptc_main, ptc_sub)
  if param then
    SendMessage(MsgID_Activity_ZhaoQinLeaveWords, param.t_msg)
  end
end
function netactivity.qiXiLocalLeaveWordsMsg(param, ptc_main, ptc_sub)
  print("netactivity.qiXiLocalLeaveWordsMsg:", param, ptc_main, ptc_sub)
  if param then
    SendMessage(MsgID_Activity_ZhaoQinLocalLeaveWords, param.msg)
  end
end
function netactivity.setExchangeSilverBoxTimes(param, ptc_main, ptc_sub)
  print("netactivity.setExchangeSilverBoxTimes:", param, ptc_main, ptc_sub)
  activity.tjbx:setExchangeSilverBoxTimes(param.silver_cnt)
end
function netactivity.openGoldBoxResult(param, ptc_main, ptc_sub)
  print("netactivity.openGoldBoxResult:", param, ptc_main, ptc_sub)
  ReadyToShowGoldBoxResult(param.itemid, param.index, param.num)
end
function netactivity.updateTianDiQiShuSmallMonster(param, ptc_main, ptc_sub)
  if param then
    activity.tiandiqishu:updataSmallMonsterData(param)
  end
end
function netactivity.updateTianDiQiShuBossMonster(param, ptc_main, ptc_sub)
  if param then
    activity.tiandiqishu:updataBossMonsterData(param)
  end
end
function netactivity.updateTianDiQiShuKillMonsterNum(param, ptc_main, ptc_sub)
  if param then
    local curNum = param.cur or 0
    local totalNum = param.total or 0
    activity.tiandiqishu:updataKillMonsterNum(curNum, totalNum)
  end
end
function netactivity.QianKunYiZhiResult(param, ptc_main, ptc_sub)
  print("netactivity.QianKunYiZhiResult:", param, ptc_main, ptc_sub)
  ShowQianKunYiZhiResult(param.t_npc, param.t_self)
end
function netactivity.enterTianDiQiShuFb(param, ptc_main, ptc_sub)
  activity.tiandiqishu:EnterFbSucceed(param.starttime)
end
function netactivity.ToLeaveTianDiQiShuFb(param, ptc_main, ptc_sub)
  activity.tiandiqishu:LeaveTianDiQiShuLeaveFb()
end
function netactivity.FinishedCount(param, ptc_main, ptc_sub)
  if g_DataMgr and param then
    g_DataMgr:receiveFinishEventData(param.lst)
  end
end
function netactivity.SetGuoQingSuiPianData(param, ptc_main, ptc_sub)
  if activity.guoqingMgr and activity.guoqingMgr.SetGuoQingSuiPianData and param then
    activity.guoqingMgr:SetGuoQingSuiPianData(param)
  end
end
function netactivity.SetGuoQingXFFLData(param, ptc_main, ptc_sub)
  if g_LocalPlayer and param then
    g_LocalPlayer:setXiaoFeiFanLiData(param.starttime, param.endtime, param.costgold, param.awardgold)
  end
end
function netactivity.getShituChanganMonsterInf(param, ptc_main, ptc_sub)
  print("  刷新师徒长安怪物  **************")
  dump(param)
  activity.shituchangan:getMonsterInfo(param)
end
function netactivity.delShituChanganMonster(param, ptc_main, ptc_sub)
  print(" 删除 师徒长安怪物 ***************** ")
  activity.shituchangan:delMoster(param)
end
function netactivity.openJiangJuanResult(param, ptc_main, ptc_sub)
  print("netactivity.openJiangJuanResult:", param, ptc_main, ptc_sub)
  ReadyToShowJiangJuanResult(param.itemid, param.index, param.num)
end
return netactivity
