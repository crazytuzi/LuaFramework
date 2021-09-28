local netmarry = {}
function netmarry.answerQuestionFailTimes(param, ptc_main, ptc_sub)
  print("netmarry.answerQuestionFailTimes:", param, ptc_main, ptc_sub)
  if param then
    local num = param.num
    if num ~= nil then
      g_HunyinMgr:answerQuestionWrongTimes(num)
    end
  end
end
function netmarry.requestMarryTree(param, ptc_main, ptc_sub)
  if g_marryTreeView and param then
    local cnt = param.cnt
    local list = param.lst
    g_marryTreeView:requestTreeData(cnt, list)
  end
end
function netmarry.missionDataUpdate(param, ptc_main, ptc_sub)
  print("netmarry.missionDataUpdate:", param, ptc_main, ptc_sub)
  if param then
    g_HunyinMgr:missionDataUpdate(param)
  end
end
function netmarry.missionDeleted(param, ptc_main, ptc_sub)
  print("netmarry.missionDataUpdate:", param, ptc_main, ptc_sub)
  g_HunyinMgr:serverDeletedMission(param)
end
function netmarry.requestMarry(param, ptc_main, ptc_sub)
  print("netmarry.requestMarry:", param, ptc_main, ptc_sub)
  if param then
    g_HunyinMgr:getRequest(param.pid, param.name, param.zs, param.lv, param.rtype)
  end
end
function netmarry.setMyBanLv(param, ptc_main, ptc_sub)
  print("netmarry.setMyBanLv:", param, ptc_main, ptc_sub)
  local BanLvId = param.pid
  g_FriendsMgr:setBanLvId(BanLvId)
end
function netmarry.updateHuaCheData(param, ptc_main, ptc_sub)
  print("netmarry.updateHuaCheData:", param, ptc_main, ptc_sub)
  local lefttime = param.lefttime
  if g_HunyinMgr then
    g_HunyinMgr:setHuaCheYouXingData(lefttime, param)
  end
end
function netmarry.flushMarrytree(param, ptc_main, ptc_sub)
  dump(param, "flushMarrytree  ")
  if g_marryTreeView and param then
    g_marryTreeView:flushMarryData(param)
  end
end
function netmarry.deleteMarryTreeItem(param, ptc_main, ptc_sub)
  if param and g_marryTreeView then
    g_marryTreeView:deleteOneItem(param.id)
  end
end
function netmarry.updateJieqiMission(param, ptc_main, ptc_sub)
  if param and g_JieqiMgr then
    g_JieqiMgr:missionDataUpdate(param)
  end
end
function netmarry.delJieqiMission(param, ptc_main, ptc_sub)
  if param and g_JieqiMgr then
    g_JieqiMgr:serverDeletedMission(param)
  end
end
function netmarry.requestJieqi(param, ptc_main, ptc_sub)
  if param then
    g_JieqiMgr:getRequest(param.pid, param.name, param.zs, param.lv, param.rtype)
  end
end
function netmarry.requestJieqiSucceed(param, ptc_main, ptc_sub)
  if param then
    g_JieqiMgr:requestJieqiSucceed()
  end
end
function netmarry.closeJiehunDatiView(param, ptc_main, ptc_sub)
  g_HunyinMgr:closeJiehunDatiView()
end
return netmarry
