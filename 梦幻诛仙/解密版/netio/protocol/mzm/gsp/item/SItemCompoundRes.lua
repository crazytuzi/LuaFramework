local SItemCompoundRes = class("SItemCompoundRes")
SItemCompoundRes.TYPEID = 12584753
function SItemCompoundRes:ctor(itemid, itemkey)
  self.id = 12584753
  self.itemid = itemid or nil
  self.itemkey = itemkey or nil
end
function SItemCompoundRes:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemkey)
end
function SItemCompoundRes:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.itemkey = os:unmarshalInt32()
end
function SItemCompoundRes:sizepolicy(size)
  return size <= 65535
end
return SItemCompoundRes
