local OctetsStream = require("netio.OctetsStream")
local VoteDatas = class("VoteDatas")
function VoteDatas:ctor(votedInfos)
  self.votedInfos = votedInfos or {}
end
function VoteDatas:marshal(os)
  os:marshalCompactUInt32(table.getn(self.votedInfos))
  for _, v in ipairs(self.votedInfos) do
    v:marshal(os)
  end
end
function VoteDatas:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.vote.VoteData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.votedInfos, v)
  end
end
return VoteDatas
