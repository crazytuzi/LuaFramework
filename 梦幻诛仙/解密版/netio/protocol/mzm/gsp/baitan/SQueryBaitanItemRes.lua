local PageInfo = require("netio.protocol.mzm.gsp.baitan.PageInfo")
local SQueryBaitanItemRes = class("SQueryBaitanItemRes")
SQueryBaitanItemRes.TYPEID = 12584993
function SQueryBaitanItemRes:ctor(pageresult)
  self.id = 12584993
  self.pageresult = pageresult or PageInfo.new()
end
function SQueryBaitanItemRes:marshal(os)
  self.pageresult:marshal(os)
end
function SQueryBaitanItemRes:unmarshal(os)
  self.pageresult = PageInfo.new()
  self.pageresult:unmarshal(os)
end
function SQueryBaitanItemRes:sizepolicy(size)
  return size <= 65535
end
return SQueryBaitanItemRes
