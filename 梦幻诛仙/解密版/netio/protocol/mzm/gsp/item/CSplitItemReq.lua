local CSplitItemReq = class("CSplitItemReq")
CSplitItemReq.TYPEID = 12584878
function CSplitItemReq:ctor(item_uuid, split_all)
  self.id = 12584878
  self.item_uuid = item_uuid or nil
  self.split_all = split_all or nil
end
function CSplitItemReq:marshal(os)
  os:marshalInt64(self.item_uuid)
  os:marshalInt32(self.split_all)
end
function CSplitItemReq:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
  self.split_all = os:unmarshalInt32()
end
function CSplitItemReq:sizepolicy(size)
  return size <= 65535
end
return CSplitItemReq
