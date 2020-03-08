local SSyncGangHelpList = class("SSyncGangHelpList")
SSyncGangHelpList.TYPEID = 793406
function SSyncGangHelpList:ctor(callHelpList)
  self.id = 793406
  self.callHelpList = callHelpList or {}
end
function SSyncGangHelpList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.callHelpList))
  for _, v in ipairs(self.callHelpList) do
    v:marshal(os)
  end
end
function SSyncGangHelpList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.GangHelp")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.callHelpList, v)
  end
end
function SSyncGangHelpList:sizepolicy(size)
  return size <= 65535
end
return SSyncGangHelpList
