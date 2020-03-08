local SyncSingleBattalAppellation = class("SyncSingleBattalAppellation")
SyncSingleBattalAppellation.TYPEID = 12621580
function SyncSingleBattalAppellation:ctor()
  self.id = 12621580
end
function SyncSingleBattalAppellation:marshal(os)
end
function SyncSingleBattalAppellation:unmarshal(os)
end
function SyncSingleBattalAppellation:sizepolicy(size)
  return size <= 65535
end
return SyncSingleBattalAppellation
