function ShowTTHJView()
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_TTHJ)
  if openFlag == false then
    ShowNotifyTips(tips)
    return
  end
  if g_tthjEnter ~= nil then
    g_tthjEnter:removeFromParent()
    g_tthjEnter = nil
  end
  activity.tthj:reqPlayerinfo()
  if g_CMainMenuHandler then
    local eventId = 11002
    if g_CMainMenuHandler:JudgeEventNeedRemind(eventId) then
      g_CMainMenuHandler:SetEventRemind(eventId)
    end
  end
end
local tthjMgr = class("tthjMgr")
function tthjMgr:ctor()
  self.m_listener = nil
  self.playerInfo = {}
  self.curpro = 0
end
function tthjMgr:reqPlayerinfo()
  netsend.netactivity.openTthjEntrance()
end
function tthjMgr:flushPlayerInfo(param)
  param = param or {}
  self.playerInfo = DeepCopyTable(param)
  dump(param, "****************** ")
  if g_tthjEnter ~= nil then
    g_tthjEnter:removeFromParentAndCleanup(true)
    g_tthjEnter = nil
    self.m_listener = nil
  end
  g_tthjEnter = TthjEntrance.new(param)
  getCurSceneView():addSubView({
    subView = g_tthjEnter,
    zOrder = MainUISceneZOrder.menuView
  })
end
function tthjMgr:appendListener(listener)
  self.m_listener = listener
end
function tthjMgr:starWar(index)
  netsend.netactivity.startTthjWar(index)
  self.m_listener = nil
  if g_tthjEnter ~= nil then
    g_tthjEnter:removeFromParentAndCleanup(true)
    g_tthjEnter = nil
  end
end
function tthjMgr:warOverBack(param)
  print("战斗后 回调************ ")
  param = param or {}
  local msgText = "战斗结束。"
  local bossid = param.bossid
  if param.result == 1 and param.bossid ~= 6 then
    msgText = "恭喜，队伍挑战成功#<E:51>#。是否进入下一关挑战？"
    bossid = param.bossid + 1
  elseif param.result == 0 then
    msgText = string.format("很遗憾#<E:6>#,队伍挑战失败。是否重新发起第%d关的挑战？", param.bossid)
  end
  if param.result == 1 and param.bossid ~= 6 or param.result == 0 then
    local dlg = CPopWarning.new({
      title = "提示",
      text = msgText,
      confirmFunc = function()
        tthjMgr:starWar(bossid)
      end,
      cancelText = "取消",
      confirmText = "确定",
      hideInWar = true
    })
    dlg:ShowCloseBtn(false)
    if g_tthjEnter ~= nil then
      g_tthjEnter:removeFromParentAndCleanup(true)
      g_tthjEnter = nil
    end
    self:reqPlayerinfo()
  end
end
return tthjMgr
