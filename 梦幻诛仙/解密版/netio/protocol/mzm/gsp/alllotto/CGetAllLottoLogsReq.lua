local CGetAllLottoLogsReq = class("CGetAllLottoLogsReq")
CGetAllLottoLogsReq.TYPEID = 12626946
function CGetAllLottoLogsReq:ctor(activity_cfg_id, num)
  self.id = 12626946
  self.activity_cfg_id = activity_cfg_id or nil
  self.num = num or nil
end
function CGetAllLottoLogsReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.num)
end
function CGetAllLottoLogsReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CGetAllLottoLogsReq:sizepolicy(size)
  return size <= 65535
end
return CGetAllLottoLogsReq
