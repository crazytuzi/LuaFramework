local Lplus = require("Lplus")
local QingYunZhiUtils = Lplus.Class("QingYunZhiUtils")
local instance
local def = QingYunZhiUtils.define
def.static("=>", QingYunZhiUtils).Instance = function()
  if nil == instance then
    instance = QingYunZhiUtils()
  end
  return instance
end
QingYunZhiUtils.Commit()
return QingYunZhiUtils
