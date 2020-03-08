local CSaoDangReq = class("CSaoDangReq")
CSaoDangReq.TYPEID = 12591381
function CSaoDangReq:ctor(instanceCfgid, process, cost_item_num, cost_yuanbao_num)
  self.id = 12591381
  self.instanceCfgid = instanceCfgid or nil
  self.process = process or nil
  self.cost_item_num = cost_item_num or nil
  self.cost_yuanbao_num = cost_yuanbao_num or nil
end
function CSaoDangReq:marshal(os)
  os:marshalInt32(self.instanceCfgid)
  os:marshalInt32(self.process)
  os:marshalInt32(self.cost_item_num)
  os:marshalInt32(self.cost_yuanbao_num)
end
function CSaoDangReq:unmarshal(os)
  self.instanceCfgid = os:unmarshalInt32()
  self.process = os:unmarshalInt32()
  self.cost_item_num = os:unmarshalInt32()
  self.cost_yuanbao_num = os:unmarshalInt32()
end
function CSaoDangReq:sizepolicy(size)
  return size <= 65535
end
return CSaoDangReq
