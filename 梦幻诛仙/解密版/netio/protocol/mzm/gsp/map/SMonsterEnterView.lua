local EnterPosition = require("netio.protocol.mzm.gsp.map.EnterPosition")
local SMonsterEnterView = class("SMonsterEnterView")
SMonsterEnterView.TYPEID = 12590871
function SMonsterEnterView:ctor(monsterInstanceId, monsterId, isActive, monsterName, posinit, is_fighting)
  self.id = 12590871
  self.monsterInstanceId = monsterInstanceId or nil
  self.monsterId = monsterId or nil
  self.isActive = isActive or nil
  self.monsterName = monsterName or nil
  self.posinit = posinit or EnterPosition.new()
  self.is_fighting = is_fighting or nil
end
function SMonsterEnterView:marshal(os)
  os:marshalInt32(self.monsterInstanceId)
  os:marshalInt32(self.monsterId)
  os:marshalInt32(self.isActive)
  os:marshalString(self.monsterName)
  self.posinit:marshal(os)
  os:marshalUInt8(self.is_fighting)
end
function SMonsterEnterView:unmarshal(os)
  self.monsterInstanceId = os:unmarshalInt32()
  self.monsterId = os:unmarshalInt32()
  self.isActive = os:unmarshalInt32()
  self.monsterName = os:unmarshalString()
  self.posinit = EnterPosition.new()
  self.posinit:unmarshal(os)
  self.is_fighting = os:unmarshalUInt8()
end
function SMonsterEnterView:sizepolicy(size)
  return size <= 65535
end
return SMonsterEnterView
