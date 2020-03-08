local JiuXiaoMapDataBean = require("netio.protocol.mzm.gsp.jiuxiao.JiuXiaoMapDataBean")
local SUpdateLayerDataRes = class("SUpdateLayerDataRes")
SUpdateLayerDataRes.TYPEID = 12595462
function SUpdateLayerDataRes:ctor(mapDataBean)
  self.id = 12595462
  self.mapDataBean = mapDataBean or JiuXiaoMapDataBean.new()
end
function SUpdateLayerDataRes:marshal(os)
  self.mapDataBean:marshal(os)
end
function SUpdateLayerDataRes:unmarshal(os)
  self.mapDataBean = JiuXiaoMapDataBean.new()
  self.mapDataBean:unmarshal(os)
end
function SUpdateLayerDataRes:sizepolicy(size)
  return size <= 65535
end
return SUpdateLayerDataRes
