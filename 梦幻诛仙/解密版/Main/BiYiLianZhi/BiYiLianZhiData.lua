local Lplus = require("Lplus")
local BiYiLianZhiData = Lplus.Class("BiYiLianZhiData")
local def = BiYiLianZhiData.define
local instance
def.field("userdata")._currentSession = nil
def.field("boolean")._isReceivedAward = false
def.static("=>", BiYiLianZhiData).Instance = function()
  if instance == nil then
    instance = BiYiLianZhiData()
  end
  return instance
end
def.method("userdata").SetCurrentSession = function(self, session)
  self._currentSession = session
end
def.method("=>", "userdata").GetCurrentSession = function(self)
  return self._currentSession
end
def.method("boolean").SetReceivedAward = function(self, b)
  self._isReceivedAward = b
end
def.method("=>", "boolean").IsReceivedAward = function(self)
  return self._isReceivedAward
end
def.method().ClearSession = function(self)
  self._currentSession = nil
end
def.method().ClearData = function(self)
  self._currentSession = nil
  self._isReceiveAward = false
end
BiYiLianZhiData.Commit()
return BiYiLianZhiData
