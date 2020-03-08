local CGetCrossBattleTopThreeInfo = class("CGetCrossBattleTopThreeInfo")
CGetCrossBattleTopThreeInfo.TYPEID = 12617084
function CGetCrossBattleTopThreeInfo:ctor(session)
  self.id = 12617084
  self.session = session or nil
end
function CGetCrossBattleTopThreeInfo:marshal(os)
  os:marshalInt32(self.session)
end
function CGetCrossBattleTopThreeInfo:unmarshal(os)
  self.session = os:unmarshalInt32()
end
function CGetCrossBattleTopThreeInfo:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleTopThreeInfo
