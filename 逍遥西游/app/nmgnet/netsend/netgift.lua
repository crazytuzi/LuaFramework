local netgift = {}
function netgift.reqReflush()
  NetSend({}, S2C_Gift, "P1")
end
function netgift.reqGetOnlineReward()
  NetSend({}, S2C_Gift, "P2")
end
function netgift.reqGetLevelupReward()
  NetSend({}, S2C_Gift, "P3")
end
function netgift.reqGetCheckinReward()
  NetSend({}, S2C_Gift, "P4")
end
function netgift.reqGetReCheckin(daynum)
  NetSend({daynum = daynum}, S2C_Gift, "P5")
end
function netgift.reqGetGiftOfIdentify(giftId, str)
  NetSend({i_g = giftId, s = str}, S2C_Gift, "P6")
end
function netgift.reqGetGiftOfFestival(fId)
  NetSend({i_g = fId}, S2C_Gift, "P7")
end
function netgift.reqGetGiftOfFresh()
  NetSend({}, S2C_Gift, "P8")
end
function netgift.reqGetCheckInForNewTerm()
  NetSend({}, S2C_Gift, "P9")
end
function netgift.reqGetCheckInForGuoQing()
  NetSend({}, S2C_Gift, "P10")
end
function netgift.reqGetLoginGift()
  NetSend({}, S2C_Gift, "P12")
end
return netgift
