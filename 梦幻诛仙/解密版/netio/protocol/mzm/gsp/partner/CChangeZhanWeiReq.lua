local CChangeZhanWeiReq = class("CChangeZhanWeiReq")
CChangeZhanWeiReq.TYPEID = 12588040
function CChangeZhanWeiReq:ctor(lineUpNum, srcpos, dstpos)
  self.id = 12588040
  self.lineUpNum = lineUpNum or nil
  self.srcpos = srcpos or nil
  self.dstpos = dstpos or nil
end
function CChangeZhanWeiReq:marshal(os)
  os:marshalInt32(self.lineUpNum)
  os:marshalInt32(self.srcpos)
  os:marshalInt32(self.dstpos)
end
function CChangeZhanWeiReq:unmarshal(os)
  self.lineUpNum = os:unmarshalInt32()
  self.srcpos = os:unmarshalInt32()
  self.dstpos = os:unmarshalInt32()
end
function CChangeZhanWeiReq:sizepolicy(size)
  return size <= 65535
end
return CChangeZhanWeiReq
