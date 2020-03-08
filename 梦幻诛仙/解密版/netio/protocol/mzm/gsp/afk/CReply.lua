local CReply = class("CReply")
CReply.TYPEID = 12622338
function CReply:ctor(afk_detect_cfg_id)
  self.id = 12622338
  self.afk_detect_cfg_id = afk_detect_cfg_id or nil
end
function CReply:marshal(os)
  os:marshalInt32(self.afk_detect_cfg_id)
end
function CReply:unmarshal(os)
  self.afk_detect_cfg_id = os:unmarshalInt32()
end
function CReply:sizepolicy(size)
  return size <= 65535
end
return CReply
