local CCanvassInCrossBattleReq = class("CCanvassInCrossBattleReq")
CCanvassInCrossBattleReq.TYPEID = 12616968
function CCanvassInCrossBattleReq:ctor(activity_cfg_id, target_corps_id, text)
  self.id = 12616968
  self.activity_cfg_id = activity_cfg_id or nil
  self.target_corps_id = target_corps_id or nil
  self.text = text or nil
end
function CCanvassInCrossBattleReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.target_corps_id)
  os:marshalOctets(self.text)
end
function CCanvassInCrossBattleReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.target_corps_id = os:unmarshalInt64()
  self.text = os:unmarshalOctets()
end
function CCanvassInCrossBattleReq:sizepolicy(size)
  return size <= 65535
end
return CCanvassInCrossBattleReq
