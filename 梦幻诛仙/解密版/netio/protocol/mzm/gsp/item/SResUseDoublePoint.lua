local SResUseDoublePoint = class("SResUseDoublePoint")
SResUseDoublePoint.TYPEID = 12584728
function SResUseDoublePoint:ctor(itemid, result, canusecount, daycanusecount)
  self.id = 12584728
  self.itemid = itemid or nil
  self.result = result or nil
  self.canusecount = canusecount or nil
  self.daycanusecount = daycanusecount or nil
end
function SResUseDoublePoint:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.result)
  os:marshalInt32(self.canusecount)
  os:marshalInt32(self.daycanusecount)
end
function SResUseDoublePoint:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.result = os:unmarshalInt32()
  self.canusecount = os:unmarshalInt32()
  self.daycanusecount = os:unmarshalInt32()
end
function SResUseDoublePoint:sizepolicy(size)
  return size <= 65535
end
return SResUseDoublePoint
