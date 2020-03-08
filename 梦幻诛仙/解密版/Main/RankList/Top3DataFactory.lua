local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Top3DataFactory = Lplus.Class(CUR_CLASS_NAME)
local Top3Data = import(".data.Top3Data")
local def = Top3DataFactory.define
local instance
def.static("=>", Top3DataFactory).Instance = function()
  if instance == nil then
    instance = Top3DataFactory()
  end
  return instance
end
local CreateAndInit = function(class, type)
  local obj = class()
  obj.type = type
  return obj
end
def.method("number", "=>", Top3Data).Create = function(self, type)
  local RankListClass
  RankListClass = import(".data.Top3Data", CUR_CLASS_NAME)
  return CreateAndInit(RankListClass, type)
end
return Top3DataFactory.Commit()
