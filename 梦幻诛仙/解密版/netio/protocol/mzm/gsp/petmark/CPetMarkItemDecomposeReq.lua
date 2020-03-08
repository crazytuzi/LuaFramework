local CPetMarkItemDecomposeReq = class("CPetMarkItemDecomposeReq")
CPetMarkItemDecomposeReq.TYPEID = 12628498
function CPetMarkItemDecomposeReq:ctor(item_cfg_id, decompose_all)
  self.id = 12628498
  self.item_cfg_id = item_cfg_id or nil
  self.decompose_all = decompose_all or nil
end
function CPetMarkItemDecomposeReq:marshal(os)
  os:marshalInt32(self.item_cfg_id)
  os:marshalUInt8(self.decompose_all)
end
function CPetMarkItemDecomposeReq:unmarshal(os)
  self.item_cfg_id = os:unmarshalInt32()
  self.decompose_all = os:unmarshalUInt8()
end
function CPetMarkItemDecomposeReq:sizepolicy(size)
  return size <= 65535
end
return CPetMarkItemDecomposeReq
