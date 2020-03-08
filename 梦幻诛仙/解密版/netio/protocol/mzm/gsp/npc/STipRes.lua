local STipRes = class("STipRes")
STipRes.TYPEID = 12586754
STipRes.SUCCESS = 0
STipRes.YUANBAO_NOT_ENOUGH = 1
STipRes.GOLD_NOT_ENOUGH = 2
STipRes.SILVER_NOT_ENOUGH = 3
STipRes.ITEMID_ERROR = 4
STipRes.NPCTRADE_ERROR = 5
STipRes.SERVICEID_ERROR = 6
STipRes.BAG_SPACE_ERROR = 7
STipRes.CLIENT_DATA_ERROR = 8
STipRes.EXCEED_MAXNUM_ERROR = 9
function STipRes:ctor(ret, itemid, count)
  self.id = 12586754
  self.ret = ret or nil
  self.itemid = itemid or nil
  self.count = count or nil
end
function STipRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
end
function STipRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function STipRes:sizepolicy(size)
  return size <= 65535
end
return STipRes
