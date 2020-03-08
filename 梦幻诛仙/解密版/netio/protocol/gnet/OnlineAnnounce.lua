local OnlineAnnounce = class("OnlineAnnounce")
OnlineAnnounce.TYPEID = 110
function OnlineAnnounce:ctor(userid, localsid, remain_time, zoneid, aid, algorithm, reconnect_token)
  self.id = 110
  self.userid = userid or nil
  self.localsid = localsid or nil
  self.remain_time = remain_time or nil
  self.zoneid = zoneid or nil
  self.aid = aid or nil
  self.algorithm = algorithm or nil
  self.reconnect_token = reconnect_token or nil
end
function OnlineAnnounce:marshal(os)
  os:marshalOctets(self.userid)
  os:marshalInt32(self.localsid)
  os:marshalInt32(self.remain_time)
  os:marshalInt32(self.zoneid)
  os:marshalInt32(self.aid)
  os:marshalInt32(self.algorithm)
  os:marshalOctets(self.reconnect_token)
end
function OnlineAnnounce:unmarshal(os)
  self.userid = os:unmarshalOctets()
  self.localsid = os:unmarshalInt32()
  self.remain_time = os:unmarshalInt32()
  self.zoneid = os:unmarshalInt32()
  self.aid = os:unmarshalInt32()
  self.algorithm = os:unmarshalInt32()
  self.reconnect_token = os:unmarshalOctets()
end
function OnlineAnnounce:sizepolicy(size)
  return size <= 65535
end
return OnlineAnnounce
