local Lplus = require("Lplus")
local TrumpetPanel, TrumpetMgr
local TrumpetQueue = Lplus.Class("TrumpetQueue")
local def = TrumpetQueue.define
local instance
def.static("=>", TrumpetQueue).Instance = function()
  if instance == nil then
    instance = TrumpetQueue()
  end
  return instance
end
def.const("number").TICK_INTERVAL = 0.25
def.const("number").MAX_CACHE_LENGTH = 3
def.field("boolean").m_bRestrictLength = false
def.field("table").m_queue = nil
def.field("number").m_timerID = 0
def.field("number").m_timeElapse = 0
def.method().Init = function(self)
  self:Reset()
  TrumpetMgr = require("Main.Chat.Trumpet.TrumpetMgr")
  TrumpetPanel = require("Main.Chat.Trumpet.ui.TrumpetPanel")
end
def.method("number", "table").Push = function(self, id, msg)
  if self:IsFull() then
    return
  end
  local trumpet = {}
  trumpet.msg = msg
  trumpet.cfg = TrumpetMgr.Instance():GetTrumpetCfgById(id)
  if nil == trumpet.cfg then
    warn("[TrumpetQueue:Push] trumpetCfg nil for id:", id)
    return
  end
  warn("[TrumpetQueue:Push] push new trumpet.")
  table.insert(self.m_queue, trumpet)
  if self:Length() == 1 then
    self:Next(false)
  end
  if self.m_timerID == 0 then
    self.m_timerID = GameUtil.AddGlobalTimer(TrumpetQueue.TICK_INTERVAL, false, function()
      self:Tick()
    end)
  end
end
def.method().Pop = function(self)
  if self:IsEmpty() then
    return
  end
  warn("[TrumpetQueue:Pop] pop top trumpet.")
  table.remove(self.m_queue, 1)
end
def.method("=>", "table").Top = function(self)
  return self.m_queue[1]
end
def.method("=>", "number").Length = function(self)
  return #self.m_queue
end
def.method("=>", "boolean").IsEmpty = function(self)
  return self:Length() <= 0
end
def.method("=>", "boolean").IsFull = function(self)
  return self.m_bRestrictLength and self:Length() == TrumpetQueue.MAX_CACHE_LENGTH
end
def.method().Reset = function(self)
  self.m_queue = {}
  self.m_timeElapse = 0
  if 0 < self.m_timerID then
    GameUtil.RemoveGlobalTimer(self.m_timerID)
    self.m_timerID = 0
  end
end
def.method().Tick = function(self)
  if not self:IsEmpty() then
    self.m_timeElapse = self.m_timeElapse + TrumpetQueue.TICK_INTERVAL
    if self:Length() > 1 then
      if self.m_timeElapse >= self:Top().cfg.durationNormal then
        warn("[TrumpetQueue:Tick] time up, self:Top().cfg.durationNormal=", self:Top().cfg.durationNormal)
        self:Next(true)
      end
    elseif self.m_timeElapse >= self:Top().cfg.durationIdle then
      warn("[TrumpetQueue:Tick] time up, self:Top().cfg.durationIdle=", self:Top().cfg.durationIdle)
      self:Next(true)
    end
  elseif self.m_timeElapse > 0 then
    self.m_timeElapse = 0
  end
end
def.method("boolean").Next = function(self, bPop)
  warn("[TrumpetQueue:Next] Show next trumpet.")
  if bPop then
    self:Pop()
  end
  self.m_timeElapse = 0
  if self:Top() then
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NEW_TRUMPET, {
      next = self:Top()
    })
  elseif TrumpetPanel.Instance():IsShow() then
    TrumpetPanel.Instance():DestroyPanel()
  end
end
TrumpetQueue.Commit()
return TrumpetQueue
