local Lplus = require("Lplus")
local EnterWorldAlertMgr = Lplus.Class("EnterWorldAlertMgr")
local def = EnterWorldAlertMgr.define
def.const("table").CustomOrder = {
  GameNotice = 10,
  LoginAwardAlert = 20,
  AwardPanel = 30,
  BindRecallFriend = 35,
  ReCallFriend = 40,
  QuickLaunch = 1000
}
local instance
def.static("=>", EnterWorldAlertMgr).Instance = function()
  if instance == nil then
    instance = EnterWorldAlertMgr()
    instance:Init()
  end
  return instance
end
def.field("table").m_funcs = nil
def.field("table").m_taskList = nil
def.field("number").m_curPos = 0
def.method().Init = function(self)
  self.m_funcs = {}
  self.m_taskList = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, EnterWorldAlertMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, EnterWorldAlertMgr.OnLeaveWorld)
end
def.static("table", "table").OnEnterWorld = function(params)
  local enterType = params and params.enterType
  local self = instance
  local list = {}
  for _, v in pairs(self.m_funcs) do
    if enterType ~= _G.EnterWorldType.RECONNECT or v.reconnectAlert then
      table.insert(list, v)
    end
  end
  table.sort(list, function(l, r)
    return l.order < r.order
  end)
  self.m_taskList = list
  self.m_curPos = 0
  self:Next()
end
def.static("table", "table").OnLeaveWorld = function()
  instance:Clear()
end
def.method("number", "function", "table").Register = function(self, order, func, context)
  self:RegisterEx(order, func, context, nil)
end
def.method("number", "function", "table", "table").RegisterEx = function(self, order, func, context, args)
  local record = {
    func = func,
    context = context,
    order = order
  }
  if args then
    for k, v in pairs(args) do
      record[k] = v
    end
  end
  self.m_funcs[func] = record
end
def.method("number", "function", "table").Unregister = function(self, func, context)
  self.m_funcs[func] = nil
end
def.method().Next = function(self)
  if self.m_taskList == nil then
    return
  end
  self.m_curPos = self.m_curPos + 1
  if self.m_curPos > #self.m_taskList then
    self:Clear()
    return
  end
  local v = self.m_taskList[self.m_curPos]
  print(string.format("EnterWorldAlert cur step=%d, order=%d", self.m_curPos, v.order))
  _G.SafeCall(v.func, v.context)
end
def.method().Clear = function(self)
  self.m_curPos = 0
  self.m_taskList = nil
end
return EnterWorldAlertMgr.Commit()
