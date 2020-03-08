local OctetsStream = require("netio.OctetsStream")
local CatInfo = class("CatInfo")
CatInfo.STATE_NORMAL = 1
CatInfo.STATE_EXPLORE = 2
CatInfo.STATE_RESET = 3
function CatInfo:ctor(id, item_cfgid, name, explore_num, total_explore_num, vigor, state, is_award, explore_end_timestamp, partner_cfgid)
  self.id = id or nil
  self.item_cfgid = item_cfgid or nil
  self.name = name or nil
  self.explore_num = explore_num or nil
  self.total_explore_num = total_explore_num or nil
  self.vigor = vigor or nil
  self.state = state or nil
  self.is_award = is_award or nil
  self.explore_end_timestamp = explore_end_timestamp or nil
  self.partner_cfgid = partner_cfgid or nil
end
function CatInfo:marshal(os)
  os:marshalInt64(self.id)
  os:marshalInt32(self.item_cfgid)
  os:marshalOctets(self.name)
  os:marshalInt32(self.explore_num)
  os:marshalInt32(self.total_explore_num)
  os:marshalInt32(self.vigor)
  os:marshalUInt8(self.state)
  os:marshalUInt8(self.is_award)
  os:marshalInt32(self.explore_end_timestamp)
  os:marshalInt32(self.partner_cfgid)
end
function CatInfo:unmarshal(os)
  self.id = os:unmarshalInt64()
  self.item_cfgid = os:unmarshalInt32()
  self.name = os:unmarshalOctets()
  self.explore_num = os:unmarshalInt32()
  self.total_explore_num = os:unmarshalInt32()
  self.vigor = os:unmarshalInt32()
  self.state = os:unmarshalUInt8()
  self.is_award = os:unmarshalUInt8()
  self.explore_end_timestamp = os:unmarshalInt32()
  self.partner_cfgid = os:unmarshalInt32()
end
return CatInfo
