local OctetsStream = require("netio.OctetsStream")
local RunningInfo = class("RunningInfo")
function RunningInfo:ctor(playerIdx, actionInfos)
  self.playerIdx = playerIdx or nil
  self.actionInfos = actionInfos or {}
end
function RunningInfo:marshal(os)
  os:marshalInt32(self.playerIdx)
  os:marshalCompactUInt32(table.getn(self.actionInfos))
  for _, v in ipairs(self.actionInfos) do
    v:marshal(os)
  end
end
function RunningInfo:unmarshal(os)
  self.playerIdx = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gangrace.ActionInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.actionInfos, v)
  end
end
return RunningInfo
