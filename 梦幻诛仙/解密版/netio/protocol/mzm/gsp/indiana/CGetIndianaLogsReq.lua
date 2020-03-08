local CGetIndianaLogsReq = class("CGetIndianaLogsReq")
CGetIndianaLogsReq.TYPEID = 12628998
function CGetIndianaLogsReq:ctor(activity_cfg_id)
  self.id = 12628998
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetIndianaLogsReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetIndianaLogsReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetIndianaLogsReq:sizepolicy(size)
  return size <= 65535
end
return CGetIndianaLogsReq
