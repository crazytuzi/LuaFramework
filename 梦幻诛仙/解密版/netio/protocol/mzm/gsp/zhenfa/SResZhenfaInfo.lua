local ZhenfaBean = require("netio.protocol.mzm.gsp.zhenfa.ZhenfaBean")
local SResZhenfaInfo = class("SResZhenfaInfo")
SResZhenfaInfo.TYPEID = 12593156
function SResZhenfaInfo:ctor(zhenfaBean)
  self.id = 12593156
  self.zhenfaBean = zhenfaBean or ZhenfaBean.new()
end
function SResZhenfaInfo:marshal(os)
  self.zhenfaBean:marshal(os)
end
function SResZhenfaInfo:unmarshal(os)
  self.zhenfaBean = ZhenfaBean.new()
  self.zhenfaBean:unmarshal(os)
end
function SResZhenfaInfo:sizepolicy(size)
  return size <= 65535
end
return SResZhenfaInfo
