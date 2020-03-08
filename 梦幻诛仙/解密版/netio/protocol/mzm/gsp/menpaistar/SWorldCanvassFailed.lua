local SWorldCanvassFailed = class("SWorldCanvassFailed")
SWorldCanvassFailed.TYPEID = 12612368
SWorldCanvassFailed.ERROR_NOT_CAMPAIGN = -1
SWorldCanvassFailed.ERROR_CD = -2
SWorldCanvassFailed.ERROR_YUANBAO_NOT_ENOUGH = -3
SWorldCanvassFailed.ERROR_ACTIVITY_IN_AWARD = -4
SWorldCanvassFailed.ERROR_SEND_CHANNEL_FAILED = -5
SWorldCanvassFailed.ERROR_SWITH_OCCUPATION = -6
function SWorldCanvassFailed:ctor(target_roleid, client_yuanbao, use_yuanbao, text, retcode)
  self.id = 12612368
  self.target_roleid = target_roleid or nil
  self.client_yuanbao = client_yuanbao or nil
  self.use_yuanbao = use_yuanbao or nil
  self.text = text or nil
  self.retcode = retcode or nil
end
function SWorldCanvassFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.client_yuanbao)
  os:marshalUInt8(self.use_yuanbao)
  os:marshalOctets(self.text)
  os:marshalInt32(self.retcode)
end
function SWorldCanvassFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.client_yuanbao = os:unmarshalInt64()
  self.use_yuanbao = os:unmarshalUInt8()
  self.text = os:unmarshalOctets()
  self.retcode = os:unmarshalInt32()
end
function SWorldCanvassFailed:sizepolicy(size)
  return size <= 65535
end
return SWorldCanvassFailed
