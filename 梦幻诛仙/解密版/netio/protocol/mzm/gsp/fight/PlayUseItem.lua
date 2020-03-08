local OctetsStream = require("netio.OctetsStream")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local PlayUseItem = class("PlayUseItem")
function PlayUseItem:ctor(fighterid, releaserStatus, itemcfgid, targetStatus)
  self.fighterid = fighterid or nil
  self.releaserStatus = releaserStatus or FighterStatus.new()
  self.itemcfgid = itemcfgid or nil
  self.targetStatus = targetStatus or {}
end
function PlayUseItem:marshal(os)
  os:marshalInt32(self.fighterid)
  self.releaserStatus:marshal(os)
  os:marshalInt32(self.itemcfgid)
  local _size_ = 0
  for _, _ in pairs(self.targetStatus) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.targetStatus) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function PlayUseItem:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.releaserStatus = FighterStatus.new()
  self.releaserStatus:unmarshal(os)
  self.itemcfgid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FighterStatus")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.targetStatus[k] = v
  end
end
return PlayUseItem
