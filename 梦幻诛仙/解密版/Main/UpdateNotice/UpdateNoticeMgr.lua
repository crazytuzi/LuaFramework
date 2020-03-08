local Lplus = require("Lplus")
local UpdateNoticeMgr = Lplus.Class("UpdateNoticeMgr")
local UpdateNoticeModule = Lplus.ForwardDeclare("UpdateNoticeModule")
local def = UpdateNoticeMgr.define
local instance
def.final("=>", UpdateNoticeMgr).Instance = function()
  if instance == nil then
    instance = UpdateNoticeMgr()
  end
  return instance
end
def.virtual("number", "function").FetchNotice = function(self, sceneType, callback)
end
return UpdateNoticeMgr.Commit()
