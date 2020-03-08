local FreePassInfo = require("netio.protocol.mzm.gsp.drawcarnival.FreePassInfo")
local SDrawRsp = class("SDrawRsp")
SDrawRsp.TYPEID = 12630018
function SDrawRsp:ctor(pass_type_id, pass_count, is_use_yuan_bao, free_pass_info, pass_award_info_list, cost_yuan_bao_count, add_point_count)
  self.id = 12630018
  self.pass_type_id = pass_type_id or nil
  self.pass_count = pass_count or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
  self.free_pass_info = free_pass_info or FreePassInfo.new()
  self.pass_award_info_list = pass_award_info_list or {}
  self.cost_yuan_bao_count = cost_yuan_bao_count or nil
  self.add_point_count = add_point_count or nil
end
function SDrawRsp:marshal(os)
  os:marshalInt32(self.pass_type_id)
  os:marshalInt32(self.pass_count)
  os:marshalUInt8(self.is_use_yuan_bao)
  self.free_pass_info:marshal(os)
  os:marshalCompactUInt32(table.getn(self.pass_award_info_list))
  for _, v in ipairs(self.pass_award_info_list) do
    v:marshal(os)
  end
  os:marshalInt32(self.cost_yuan_bao_count)
  os:marshalInt32(self.add_point_count)
end
function SDrawRsp:unmarshal(os)
  self.pass_type_id = os:unmarshalInt32()
  self.pass_count = os:unmarshalInt32()
  self.is_use_yuan_bao = os:unmarshalUInt8()
  self.free_pass_info = FreePassInfo.new()
  self.free_pass_info:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawcarnival.PassAwardInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.pass_award_info_list, v)
  end
  self.cost_yuan_bao_count = os:unmarshalInt32()
  self.add_point_count = os:unmarshalInt32()
end
function SDrawRsp:sizepolicy(size)
  return size <= 65535
end
return SDrawRsp
