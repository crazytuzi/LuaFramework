local SItemYuanbaoPriceRes = class("SItemYuanbaoPriceRes")
SItemYuanbaoPriceRes.TYPEID = 12584729
function SItemYuanbaoPriceRes:ctor(itemid, yuanbaoPrice)
  self.id = 12584729
  self.itemid = itemid or nil
  self.yuanbaoPrice = yuanbaoPrice or nil
end
function SItemYuanbaoPriceRes:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.yuanbaoPrice)
end
function SItemYuanbaoPriceRes:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.yuanbaoPrice = os:unmarshalInt32()
end
function SItemYuanbaoPriceRes:sizepolicy(size)
  return size <= 65535
end
return SItemYuanbaoPriceRes
