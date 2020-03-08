local SSynDrawLineInfoList = class("SSynDrawLineInfoList")
SSynDrawLineInfoList.TYPEID = 12617251
function SSynDrawLineInfoList:ctor(drawLineInfo_list)
  self.id = 12617251
  self.drawLineInfo_list = drawLineInfo_list or {}
end
function SSynDrawLineInfoList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.drawLineInfo_list))
  for _, v in ipairs(self.drawLineInfo_list) do
    v:marshal(os)
  end
end
function SSynDrawLineInfoList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawandguess.DrawLineInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.drawLineInfo_list, v)
  end
end
function SSynDrawLineInfoList:sizepolicy(size)
  return size <= 65535
end
return SSynDrawLineInfoList
