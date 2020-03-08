local SModuleFunSwitchCloseTip = class("SModuleFunSwitchCloseTip")
SModuleFunSwitchCloseTip.TYPEID = 12599044
function SModuleFunSwitchCloseTip:ctor(moduleid, funid, params)
  self.id = 12599044
  self.moduleid = moduleid or nil
  self.funid = funid or nil
  self.params = params or {}
end
function SModuleFunSwitchCloseTip:marshal(os)
  os:marshalInt32(self.moduleid)
  os:marshalInt32(self.funid)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SModuleFunSwitchCloseTip:unmarshal(os)
  self.moduleid = os:unmarshalInt32()
  self.funid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SModuleFunSwitchCloseTip:sizepolicy(size)
  return size <= 65535
end
return SModuleFunSwitchCloseTip
