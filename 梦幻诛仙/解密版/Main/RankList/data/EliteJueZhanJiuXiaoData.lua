local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local JueZhanJiuXiaoData = import(".JueZhanJiuXiaoData")
local EliteJueZhanJiuXiaoData = Lplus.Extend(JueZhanJiuXiaoData, CUR_CLASS_NAME)
local def = EliteJueZhanJiuXiaoData.define
def.final("number", "=>", EliteJueZhanJiuXiaoData).New = function(type)
  local obj = EliteJueZhanJiuXiaoData()
  obj.type = type
  obj:Ctor()
  return obj
end
return EliteJueZhanJiuXiaoData.Commit()
