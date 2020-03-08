local SSendCatToExploreSuccess = class("SSendCatToExploreSuccess")
SSendCatToExploreSuccess.TYPEID = 12605705
function SSendCatToExploreSuccess:ctor(explore_end_timestamp, is_best_partner)
  self.id = 12605705
  self.explore_end_timestamp = explore_end_timestamp or nil
  self.is_best_partner = is_best_partner or nil
end
function SSendCatToExploreSuccess:marshal(os)
  os:marshalInt32(self.explore_end_timestamp)
  os:marshalUInt8(self.is_best_partner)
end
function SSendCatToExploreSuccess:unmarshal(os)
  self.explore_end_timestamp = os:unmarshalInt32()
  self.is_best_partner = os:unmarshalUInt8()
end
function SSendCatToExploreSuccess:sizepolicy(size)
  return size <= 65535
end
return SSendCatToExploreSuccess
