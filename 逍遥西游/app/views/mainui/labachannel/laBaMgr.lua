local laBaMgr = class("laBaMgr", nil)
function laBaMgr:ctor()
  self.m_needCount = 1
  self.m_todayCount = 0
end
function laBaMgr:flushLocalCount(count)
  if count and count >= 0 then
    self.m_todayCount = count
  end
end
function laBaMgr:addOneMsg(pid, pInfo, msg, yy, vip)
  if g_MessageMgr then
    g_MessageMgr:receiveLaBaMessage(pid, pInfo, msg, yy, vip)
  end
  local dmsg = string.format("#<II%d># %s：%s", ITEM_DEF_OTHER_LABA, pInfo.name, msg)
  ShowUpNotifyViews(dmsg, false)
end
function laBaMgr:showOneMsg()
end
function laBaMgr:flushLocalCD(timeleft)
  self.m_todayCount = self.m_todayCount + 1
  if g_labaview ~= nil then
    g_labaview:flushTips()
    g_labaview:flushCD(timeleft)
  end
  ShowNotifyTips("发送成功")
end
function laBaMgr:getCurrontCount()
  local s_indexs = {}
  for k, _ in pairs(data_HornCost) do
    s_indexs[#s_indexs + 1] = k
  end
  table.sort(s_indexs)
  local findex = s_indexs[#s_indexs]
  for k = 1, #s_indexs - 1 do
    print(k, s_indexs[k])
    if self.m_todayCount >= s_indexs[k] and self.m_todayCount < s_indexs[k + 1] then
      findex = s_indexs[k]
      break
    end
  end
  local cftb = data_HornCost[findex] or {}
  self.m_needCount = cftb.CostCnt or 2
  return self.m_needCount
end
function laBaMgr:Clear()
  self.m_needCount = 1
end
function laBaMgr:showInputView()
  g_labaview = nil
  g_labaview = laBaChannel.new()
  getCurSceneView():addSubView({
    subView = g_labaview,
    zOrder = MainUISceneZOrder.menuView
  })
end
g_LBMgr = laBaMgr.new()
gamereset.registerResetFunc(function()
  if g_LBMgr then
    g_LBMgr:Clear()
    g_LBMgr = nil
  end
  g_LBMgr = laBaMgr.new()
end)
