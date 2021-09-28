local DuanWuMgr = class("DuanWuMgrMgr")
function DuanWuMgr:ctor()
  self.m_Status = 2
  self.m_NpcId = 95118
end
function DuanWuMgr:setStatus(status)
  self.m_Status = status
  if g_MapMgr then
    local state = 0
    if self.m_Status == 1 then
      state = 1
    end
    g_MapMgr:updateDynamicActiveNpc({
      npcId = self.m_NpcId,
      state = state
    })
  end
end
function DuanWuMgr:getStatus()
  return self.m_Status
end
return DuanWuMgr
