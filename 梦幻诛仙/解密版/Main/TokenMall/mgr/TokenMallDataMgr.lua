local Lplus = require("Lplus")
local TokenMallDataMgr = Lplus.Class("TokenMallDataMgr")
local def = TokenMallDataMgr.define
def.field("table").tokenMallMap = nil
local instance
def.static("=>", TokenMallDataMgr).Instance = function()
  if instance == nil then
    instance = TokenMallDataMgr()
  end
  return instance
end
def.method().Init = function(self)
  self.tokenMallMap = {}
end
def.method().Clear = function(self)
  self.tokenMallMap = {}
end
def.method("number", "table").SetTokenMallData = function(self, mallCfgId, mallData)
  self.tokenMallMap[mallCfgId] = mallData
end
def.method("number", "=>", "table").GetTokenMallData = function(self, mallCfgId)
  return self.tokenMallMap[mallCfgId]
end
return TokenMallDataMgr.Commit()
