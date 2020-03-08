local SGangCanvassFailed = class("SGangCanvassFailed")
SGangCanvassFailed.TYPEID = 12612373
SGangCanvassFailed.ERROR_NOT_CAMPAIGN = -1
SGangCanvassFailed.ERROR_CD = -2
SGangCanvassFailed.ERROR_ACTIVITY_IN_AWARD = -3
SGangCanvassFailed.ERROR_SWITH_OCCUPATION = -4
function SGangCanvassFailed:ctor(target_roleid, text, retcode)
  self.id = 12612373
  self.target_roleid = target_roleid or nil
  self.text = text or nil
  self.retcode = retcode or nil
end
function SGangCanvassFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalOctets(self.text)
  os:marshalInt32(self.retcode)
end
function SGangCanvassFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.text = os:unmarshalOctets()
  self.retcode = os:unmarshalInt32()
end
function SGangCanvassFailed:sizepolicy(size)
  return size <= 65535
end
return SGangCanvassFailed
