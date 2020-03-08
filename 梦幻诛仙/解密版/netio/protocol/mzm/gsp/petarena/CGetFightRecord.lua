local CGetFightRecord = class("CGetFightRecord")
CGetFightRecord.TYPEID = 12628246
function CGetFightRecord:ctor()
  self.id = 12628246
end
function CGetFightRecord:marshal(os)
end
function CGetFightRecord:unmarshal(os)
end
function CGetFightRecord:sizepolicy(size)
  return size <= 65535
end
return CGetFightRecord
