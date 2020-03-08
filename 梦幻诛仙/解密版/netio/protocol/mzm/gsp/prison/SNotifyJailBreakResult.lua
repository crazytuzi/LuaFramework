local SNotifyJailBreakResult = class("SNotifyJailBreakResult")
SNotifyJailBreakResult.TYPEID = 12620033
SNotifyJailBreakResult.SUCCESS = 1
SNotifyJailBreakResult.FAIL = 2
function SNotifyJailBreakResult:ctor(result, nameList)
  self.id = 12620033
  self.result = result or nil
  self.nameList = nameList or {}
end
function SNotifyJailBreakResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.nameList))
  for _, v in ipairs(self.nameList) do
    os:marshalOctets(v)
  end
end
function SNotifyJailBreakResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.nameList, v)
  end
end
function SNotifyJailBreakResult:sizepolicy(size)
  return size <= 65535
end
return SNotifyJailBreakResult
