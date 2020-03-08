local OctetsStream = require("netio.OctetsStream")
local PassAwardInfo = class("PassAwardInfo")
function PassAwardInfo:ctor(draw_award_info_list)
  self.draw_award_info_list = draw_award_info_list or {}
end
function PassAwardInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.draw_award_info_list))
  for _, v in ipairs(self.draw_award_info_list) do
    v:marshal(os)
  end
end
function PassAwardInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawcarnival.DrawAwardInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.draw_award_info_list, v)
  end
end
return PassAwardInfo
