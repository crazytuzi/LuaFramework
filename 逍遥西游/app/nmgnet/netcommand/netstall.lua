local netstall = {}
function netstall.updateGoods(param, ptc_main, ptc_sub)
  print("netstall.updateGoods:", param, ptc_main, ptc_sub)
  if g_BaitanDataMgr then
    g_BaitanDataMgr:UpdateOneGood(param)
  end
end
function netstall.delGoods(param, ptc_main, ptc_sub)
  local id = param.id
  if g_BaitanDataMgr then
    g_BaitanDataMgr:DelOneGood(id)
  end
end
function netstall.getGoodsDir(param, ptc_main, ptc_sub)
  local dirKey = param.dir
  local leftTime = param.lefttime
  local curTime = g_DataMgr:getServerTime()
  local goodsList = param.list or {}
  if g_BaitanDataMgr then
    g_BaitanDataMgr:SetOneDirGoods(dirKey, goodsList)
    g_BaitanDataMgr:SetBaitanTime(leftTime, curTime)
  end
end
function netstall.stallBaseData(param, ptc_main, ptc_sub)
  if g_BaitanDataMgr then
    g_BaitanDataMgr:SetBaseData(param)
  end
end
function netstall.putOneGoodToStall(param, ptc_main, ptc_sub)
  local id = param.id
  g_BaitanDataMgr:NewOneGood(0, param)
  if g_BaitanDataMgr then
    g_BaitanDataMgr:UpdateOneGood(param)
  end
  SendMessage(MsgID_Stall_StallOneGood, {goodId = id})
end
function netstall.frushMainUINewTag(param, ptc_main, ptc_sub)
  g_BaitanDataMgr:SetRedIconFlag(true)
end
function netstall.getAllMoneyFinished(param, ptc_main, ptc_sub)
  if g_BaitanDataMgr then
    g_BaitanDataMgr:SetIsSellingFlag(false)
  end
end
return netstall
