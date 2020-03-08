local Lplus = require("Lplus")
local TAPanelVDMgr = Lplus.Class("TAPanelVDMgr")
local def = TAPanelVDMgr.define
local instance
def.static("=>", TAPanelVDMgr).Instance = function()
  if instance == nil then
    instance = TAPanelVDMgr()
  end
  return instance
end
def.method("=>", "table").Get = function(self)
  local viewData = {
    {
      icon = 233,
      subTypeList = {}
    },
    {
      icon = 234,
      subTypeList = {}
    },
    {
      icon = 235,
      subTypeList = {}
    },
    {
      icon = 236,
      subTypeList = {}
    }
  }
  return viewData
end
return TAPanelVDMgr.Commit()
