local netactivity = {}
function netactivity.joinKeju(i_hid)
  NetSend({hid = i_hid}, S2C_Activity, "P1")
end
function netactivity.levelKeju(i_hid)
  NetSend({hid = i_hid}, S2C_Activity, "P2")
end
function netactivity.commitAll(i_hid, t_answer)
  print("--->>netactivity.commitAll:", i_hid, t_answer)
  NetSend({hid = i_hid, answer = t_answer}, S2C_Activity, "P3")
end
function netactivity.commitOne(i_hid, i_paperId, s_answer)
  NetSend({
    hid = i_hid,
    id = i_paperId,
    answer = s_answer
  }, S2C_Activity, "P4")
end
function netactivity.getDianshiAward()
  NetSend({}, S2C_Activity, "P5")
end
function netactivity.getDianshiRank()
  NetSend({}, S2C_Activity, "P6")
end
function netactivity.reqReciveAward(evetnId)
  NetSend({hid = evetnId}, S2C_Activity, "P7")
end
function netactivity.reqEnterTiantingFb()
  NetSend({}, S2C_Activity, "P8")
end
function netactivity.reqExitTiantingFb(exitType, tempLevelFalg)
  local choice
  if exitType == 1 then
    choice = "giveup"
  elseif exitType == 2 then
    choice = "bonus"
  end
  NetSend({choice = choice, type = tempLevelFalg}, S2C_Activity, "P9")
end
function netactivity.sendDianshiResult(choice)
  NetSend({choice = choice}, S2C_Activity, "P10")
end
function netactivity.startTthjWar(mbossid)
  NetSend({bossid = mbossid}, S2C_Activity, "P11")
end
function netactivity.openTthjEntrance()
  NetSend({}, S2C_Activity, "P12")
end
function netactivity.sendUpdateLWZBRank(ver)
  NetSend({ver = ver}, S2C_Activity, "P13")
end
function netactivity.sendMatchLWZB(choice)
  NetSend({choice = choice}, S2C_Activity, "P14")
end
function netactivity.sendGetLWZBReward(choice)
  NetSend({choice = choice}, S2C_Activity, "P15")
end
function netactivity.sendRequestLWZBBaseInfo()
  NetSend({}, S2C_Activity, "P16")
end
function netactivity.sendReqXXWar(bid)
  NetSend({bossid = bid}, S2C_Activity, "P17")
end
function netactivity.fightTianBingShenJiang()
  NetSend({}, S2C_Activity, "P18")
end
function netactivity.getTianBingShenJiangMission()
  NetSend({}, S2C_Activity, "P19")
end
function netactivity.joinYZDD()
  NetSend({}, S2C_Activity, "P20")
end
function netactivity.sendUpdateYZDDRank(ver)
  NetSend({ver = ver}, S2C_Activity, "P21")
end
function netactivity.sendMatchYZDD(choice)
  NetSend({choice = choice}, S2C_Activity, "P22")
end
function netactivity.sendRequestYZDDBaseInfo()
  NetSend({}, S2C_Activity, "P23")
end
function netactivity.sendQuitYZDD()
  NetSend({}, S2C_Activity, "P24")
end
function netactivity.sendYZDDAutoMatch()
  NetSend({}, S2C_Activity, "P25")
end
function netactivity.enterXZSC()
  NetSend({}, S2C_Activity, "P26")
end
function netactivity.getXZSCBaseInfo()
  NetSend({}, S2C_Activity, "P27")
end
function netactivity.matchXZSC(choice)
  NetSend({choice = choice}, S2C_Activity, "P28")
end
function netactivity.requestDuel()
  NetSend({}, S2C_Activity, "P30")
end
function netactivity.queryDuelPlayer(pid)
  NetSend({pid = pid}, S2C_Activity, "P31")
end
function netactivity.launchDule(pid, way, notice, word)
  NetSend({
    pid = pid,
    way = way,
    notice = notice,
    word = word
  }, S2C_Activity, "P32")
end
function netactivity.responseDuel(choice)
  NetSend({choice = choice}, S2C_Activity, "P33")
end
function netactivity.declareDuel(choice)
  NetSend({choice = choice}, S2C_Activity, "P34")
end
function netactivity.getDuelMatchInfo()
  NetSend({}, S2C_Activity, "P35")
end
function netactivity.leaveDuelScene()
  NetSend({}, S2C_Activity, "P36")
end
function netactivity.enterDuelScene()
  NetSend({}, S2C_Activity, "P37")
end
function netactivity.confirmTBSJProgress(choice, progress)
  NetSend({choice = choice, progress = progress}, S2C_Activity, "P38")
end
function netactivity.localLeaveMsg(msg)
  NetSend({msg = msg}, S2C_Activity, "P39")
end
function netactivity.flushLeaveWords()
  NetSend({}, S2C_Activity, "P40")
end
function netactivity.requestLocalLeaveWords()
  NetSend({}, S2C_Activity, "P41")
end
function netactivity.exchangeSilverBox()
  NetSend({}, S2C_Activity, "P42")
end
function netactivity.requestEnterTianDiQiShuFb()
  NetSend({}, S2C_Activity, "P46")
end
function netactivity.requestToLeaveTianDiQiShuFb()
  NetSend({}, S2C_Activity, "P47")
end
function netactivity.requestStarToFightTianDiQiShu(id)
  NetSend({id = id}, S2C_Activity, "P48")
end
function netactivity.reqQianKunYiZhi()
  NetSend({}, S2C_Activity, "P49")
end
function netactivity.reqEventFinishCount()
  NetSend({}, S2C_Activity, "P50")
end
function netactivity.openGuoQingSuiPianView()
  NetSend({}, S2C_Activity, "P51")
end
function netactivity.getGuoQingSuiPian()
  NetSend({}, S2C_Activity, "P52")
end
function netactivity.changeGuoQingJSCJ(target)
  NetSend({target = target}, S2C_Activity, "P53")
end
function netactivity.openGuoQingXFFLView()
  NetSend({}, S2C_Activity, "P54")
end
function netactivity.changeChongYangItem(target)
  NetSend({target = target}, S2C_Activity, "P55")
end
function netactivity.sendReqSTCAWar(bid)
  NetSend({bossid = bid}, S2C_Activity, "P56")
end
return netactivity
