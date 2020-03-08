local ShiTuTaskInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuTaskInfo")
local SSynShiTuTaskInfo = class("SSynShiTuTaskInfo")
SSynShiTuTaskInfo.TYPEID = 12601636
function SSynShiTuTaskInfo:ctor(shitu_task_info)
  self.id = 12601636
  self.shitu_task_info = shitu_task_info or ShiTuTaskInfo.new()
end
function SSynShiTuTaskInfo:marshal(os)
  self.shitu_task_info:marshal(os)
end
function SSynShiTuTaskInfo:unmarshal(os)
  self.shitu_task_info = ShiTuTaskInfo.new()
  self.shitu_task_info:unmarshal(os)
end
function SSynShiTuTaskInfo:sizepolicy(size)
  return size <= 65535
end
return SSynShiTuTaskInfo
