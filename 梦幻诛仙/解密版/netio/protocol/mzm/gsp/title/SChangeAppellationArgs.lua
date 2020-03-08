local SChangeAppellationArgs = class("SChangeAppellationArgs")
SChangeAppellationArgs.TYPEID = 12593926
function SChangeAppellationArgs:ctor(changeId, appArgs)
  self.id = 12593926
  self.changeId = changeId or nil
  self.appArgs = appArgs or {}
end
function SChangeAppellationArgs:marshal(os)
  os:marshalInt32(self.changeId)
  os:marshalCompactUInt32(table.getn(self.appArgs))
  for _, v in ipairs(self.appArgs) do
    os:marshalString(v)
  end
end
function SChangeAppellationArgs:unmarshal(os)
  self.changeId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.appArgs, v)
  end
end
function SChangeAppellationArgs:sizepolicy(size)
  return size <= 65535
end
return SChangeAppellationArgs
