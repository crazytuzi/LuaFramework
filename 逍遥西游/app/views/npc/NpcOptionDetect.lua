local npcfuncs = {
  [1097] = function(npcTypeId, npcId)
    if g_JiehunJieqiRelease and g_FriendsMgr:getBanlvInfo() == 0 and g_HunyinMgr:hadMission() ~= true and g_JieqiMgr:hadMission() ~= true then
      return true
    end
  end,
  [1098] = function(npcTypeId, npcId)
    if g_JiehunJieqiRelease and g_FriendsMgr:getBanlvInfo() == 0 and g_HunyinMgr:hadMission() ~= true and g_JieqiMgr:hadMission() ~= true then
      return true
    end
  end,
  [1099] = function(npcTypeId, npcId)
    if g_JiehunJieqiRelease and g_FriendsMgr:getBanlvInfo() == 1 and g_HunyinMgr:hadMission() ~= true and g_JieqiMgr:hadMission() ~= true then
      return true
    end
  end,
  [1100] = function(npcTypeId, npcId)
    if g_JiehunJieqiRelease and g_FriendsMgr:getBanlvInfo() == 2 and g_HunyinMgr:hadMission() ~= true and g_JieqiMgr:hadMission() ~= true then
      return true
    end
  end,
  [1101] = function(npcTypeId, npcId)
    if g_HunyinMgr and g_HunyinMgr:isShowDatiOption() == true then
      return true
    end
  end,
  [1103] = function(npcTypeId, npcId)
    if g_JiehunJieqiRelease and g_HunyinMgr:isJuBanHunYan() then
      g_HunyinMgr:touchNpcOption_Hunyan()
      return true
    end
  end
}
function DetectNpcOptionNeedShow(npcTypeId, npcId)
  local npcfunc = npcfuncs[npcTypeId]
  local t = type(npcfunc)
  if t == "function" then
    return npcfunc(npcTypeId, npcId)
  end
  printLog("ERROR", "NPC功能还没有实现[%d]", npcTypeId)
  return false, nil
end
