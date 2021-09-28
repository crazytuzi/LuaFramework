local netmarry = {}
function netmarry.requestJiehun(pid)
  NetSend({tid = pid}, S2C_MARRY, "P1")
end
function netmarry.replyRequest(pid, choice)
  NetSend({choice = choice, pid = pid}, S2C_MARRY, "P2")
end
function netmarry.answerQeustion(qid, answer)
  NetSend({qid = qid, answer = answer}, S2C_MARRY, "P3")
end
function netmarry.requestGiveGuozi()
  NetSend({}, S2C_MARRY, "P4")
end
function netmarry.requestDati()
  NetSend({}, S2C_MARRY, "P5")
end
function netmarry.marryGiveItem()
  NetSend({}, S2C_MARRY, "P6")
end
function netmarry.requestEndMarry()
  NetSend({}, S2C_MARRY, "P7")
end
function netmarry.requestMarryTreeInfo(id)
  NetSend({id = id}, S2C_MARRY, "P8")
end
function netmarry.collectMarryTree()
  NetSend({}, S2C_MARRY, "P9")
end
function netmarry.blessMarry(mid)
  NetSend({id = mid}, S2C_MARRY, "P10")
end
function netmarry.requestGiveup(taskId)
  NetSend({id = taskId}, S2C_MARRY, "P11")
end
function netmarry.donatePresent(pid, itemid, num)
  NetSend({
    pid = pid,
    itemid = itemid,
    num = num
  }, S2C_MARRY, "P12")
end
function netmarry.requestSaXiTang(x, y)
  NetSend({x = x, y = y}, S2C_MARRY, "P14")
end
function netmarry.requestLihun()
  NetSend({}, S2C_MARRY, "P15")
end
function netmarry.requestJieqi(pid)
  NetSend({pid = pid}, S2C_MARRY, "P16")
end
function netmarry.replyJieqiRequest(pid, choice)
  NetSend({choice = choice, pid = pid}, S2C_MARRY, "P17")
end
function netmarry.GiveupJieqiTask(taskId)
  NetSend({id = taskId}, S2C_MARRY, "P18")
end
function netmarry.StartJieqiFight()
  NetSend({}, S2C_MARRY, "P19")
end
function netmarry.FinishJieqiLing()
  NetSend({}, S2C_MARRY, "P20")
end
function netmarry.XinShouLingqi()
  NetSend({}, S2C_MARRY, "P21")
end
function netmarry.FinishedXinShouLQ()
  NetSend({}, S2C_MARRY, "P22")
end
function netmarry.FinishedJieTi()
  NetSend({}, S2C_MARRY, "P23")
end
function netmarry.BreakupJieTi()
  NetSend({}, S2C_MARRY, "P24")
end
function netmarry.giveupDati()
  NetSend({}, S2C_MARRY, "P25")
end
function netmarry.checkSjzfMission(mId)
  NetSend({id = mId}, S2C_MARRY, "P26")
end
function netmarry.FinishJieqiFight()
  NetSend({}, S2C_MARRY, "P27")
end
return netmarry
