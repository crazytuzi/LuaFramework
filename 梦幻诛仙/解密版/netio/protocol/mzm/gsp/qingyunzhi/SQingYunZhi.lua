local SQingYunZhi = class("SQingYunZhi")
SQingYunZhi.TYPEID = 12590337
function SQingYunZhi:ctor(chapterNum, nodeNum)
  self.id = 12590337
  self.chapterNum = chapterNum or nil
  self.nodeNum = nodeNum or nil
end
function SQingYunZhi:marshal(os)
  os:marshalInt32(self.chapterNum)
  os:marshalInt32(self.nodeNum)
end
function SQingYunZhi:unmarshal(os)
  self.chapterNum = os:unmarshalInt32()
  self.nodeNum = os:unmarshalInt32()
end
function SQingYunZhi:sizepolicy(size)
  return size <= 65535
end
return SQingYunZhi
