local OctetsStream = require("netio.OctetsStream")
local CorpsBriefInfo = require("netio.protocol.mzm.gsp.corps.CorpsBriefInfo")
local CorpsSynInfo = class("CorpsSynInfo")
function CorpsSynInfo:ctor(corpsBriefInfo, members)
  self.corpsBriefInfo = corpsBriefInfo or CorpsBriefInfo.new()
  self.members = members or {}
end
function CorpsSynInfo:marshal(os)
  self.corpsBriefInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.members) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.members) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function CorpsSynInfo:unmarshal(os)
  self.corpsBriefInfo = CorpsBriefInfo.new()
  self.corpsBriefInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.corps.CorpsMemberSynInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.members[k] = v
  end
end
return CorpsSynInfo
