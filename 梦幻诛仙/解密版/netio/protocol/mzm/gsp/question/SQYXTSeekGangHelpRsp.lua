local SQYXTSeekGangHelpRsp = class("SQYXTSeekGangHelpRsp")
SQYXTSeekGangHelpRsp.TYPEID = 12594751
function SQYXTSeekGangHelpRsp:ctor(useGangHelpTimes)
  self.id = 12594751
  self.useGangHelpTimes = useGangHelpTimes or nil
end
function SQYXTSeekGangHelpRsp:marshal(os)
  os:marshalInt32(self.useGangHelpTimes)
end
function SQYXTSeekGangHelpRsp:unmarshal(os)
  self.useGangHelpTimes = os:unmarshalInt32()
end
function SQYXTSeekGangHelpRsp:sizepolicy(size)
  return size <= 65535
end
return SQYXTSeekGangHelpRsp
