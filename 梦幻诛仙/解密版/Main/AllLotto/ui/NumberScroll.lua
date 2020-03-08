local Lplus = require("Lplus")
local NumberScroll = Lplus.Class("NumberScroll")
local def = NumberScroll.define
def.const("number").STARTSPEED = 0.8
def.const("number").MAXSPEED = 4
def.const("number").ENDSPEED = 0.4
def.const("number").ACCELERATION = 0.1
def.const("number").ACFREQUENCY = 0.01
def.const("number").DECELERATION = 0.04
def.const("number").DEFREQUENCY = 0.01
def.const("number").ANIMATIONINTERVAL = 0.1
def.const("table").NUMBERTOUI = {
  [0] = "a",
  [1] = "a",
  [2] = "a",
  [3] = "a",
  [4] = "b",
  [5] = "b",
  [6] = "b",
  [7] = "b",
  [8] = "b",
  [9] = "a"
}
def.field("userdata").m_uiGo = nil
def.field("userdata").m_animA = nil
def.field("userdata").m_animB = nil
def.field("userdata").m_stateA = nil
def.field("userdata").m_stateB = nil
def.field("number").m_timer = 0
def.field("number").m_curSpeed = 1
def.static("userdata", "=>", NumberScroll).New = function(uiGo)
  local ns = NumberScroll()
  ns:Init(uiGo)
  return ns
end
def.method("userdata").Init = function(self, uiGo)
  self.m_uiGo = uiGo
  self.m_animA = self.m_uiGo:FindDirect("a"):GetComponent("Animation")
  self.m_animB = self.m_uiGo:FindDirect("b"):GetComponent("Animation")
  self.m_stateA = self.m_animA:State("tiger_a")
  self.m_stateB = self.m_animB:State("tiger_b")
end
def.method().Destroy = function(self)
  self:ClearTimer()
end
def.method("number").SetNumber = function(self, num)
  num = num % 10
  self:StopAt(num * NumberScroll.ANIMATIONINTERVAL)
end
def.method().Begin = function(self)
  self:ClearTimer()
  self.m_curSpeed = NumberScroll.STARTSPEED
  self:Stop()
  self:Start()
  self.m_timer = GameUtil.AddGlobalTimer(NumberScroll.ACFREQUENCY, false, function()
    if self.m_curSpeed < NumberScroll.MAXSPEED then
      local newSpeed = self.m_curSpeed + NumberScroll.ACCELERATION
      if newSpeed <= NumberScroll.MAXSPEED then
        self:ChangeSpeed(newSpeed)
      else
        newSpeed = NumberScroll.MAXSPEED
        self:ChangeSpeed(newSpeed)
        self:ClearTimer()
      end
    else
      self:ChangeSpeed(NumberScroll.MAXSPEED)
      self:ClearTimer()
    end
  end)
end
def.method().Start = function(self)
  if self.m_stateA.isnil or self.m_animA.isnil or self.m_stateB.isnil or self.m_animB.isnil then
    return
  end
  self.m_stateA:set_speed(self.m_curSpeed)
  self.m_animA:Play()
  self.m_stateB:set_speed(self.m_curSpeed)
  self.m_animB:Play()
end
def.method("number").ChangeSpeed = function(self, speed)
  if self.m_stateA.isnil or self.m_stateB.isnil then
    return
  end
  self.m_curSpeed = speed
  self.m_stateA:set_speed(self.m_curSpeed)
  self.m_stateB:set_speed(self.m_curSpeed)
end
def.method().Stop = function(self)
  if self.m_animA.isnil or self.m_animB.isnil then
    return
  end
  self.m_animA:Stop()
  self.m_animB:Stop()
end
def.method("number").StopAt = function(self, time)
  if self.m_animA.isnil or self.m_animB.isnil or self.m_stateA.isnil or self.m_stateB.isnil then
    return
  end
  self.m_stateA:set_time(time)
  self.m_stateB:set_time(time)
  self.m_stateA:set_speed(0)
  self.m_stateB:set_speed(0)
  self.m_animA:Play()
  self.m_animB:Play()
end
def.method("number", "function").End = function(self, id, cb)
  local endTime = id * NumberScroll.ANIMATIONINTERVAL
  if endTime == nil then
    return
  end
  local endUI = NumberScroll.NUMBERTOUI[id]
  local state
  if endUI == "a" then
    state = self.m_stateA
  elseif endUI == "b" then
    state = self.m_stateB
  end
  if state == nil then
    return
  end
  self:ClearTimer()
  self.m_timer = GameUtil.AddGlobalTimer(NumberScroll.DEFREQUENCY, false, function()
    if self.m_curSpeed > NumberScroll.ENDSPEED then
      local newSpeed = self.m_curSpeed - NumberScroll.DECELERATION
      if newSpeed > NumberScroll.ENDSPEED then
        self:ChangeSpeed(newSpeed)
      else
        newSpeed = NumberScroll.ENDSPEED
        self:ChangeSpeed(newSpeed)
      end
    elseif state and not state.isnil then
      local time = state:get_time()
      time = time - math.floor(time)
      if time >= endTime and time < endTime + NumberScroll.ANIMATIONINTERVAL then
        self:StopAt(endTime)
        self:ClearTimer()
        if cb then
          cb()
        end
      end
    end
  end)
end
def.method().ClearTimer = function(self)
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_timer = 0
end
NumberScroll.Commit()
return NumberScroll
