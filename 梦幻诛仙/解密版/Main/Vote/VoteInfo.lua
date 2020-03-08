local Lplus = require("Lplus")
local VoteInfo = Lplus.Class("VoteInfo")
local def = VoteInfo.define
def.field("number").m_activityId = 0
def.field("table").m_voteRecords = nil
def.method("number").Init = function(self, activityId)
  self.m_activityId = activityId
end
def.method("=>", "number").GetVotedTimes = function(self)
  if self.m_voteRecords == nil then
    return 0
  end
  return #self.m_voteRecords
end
def.method("=>", "table").GetVoteRecords = function(self)
  return self.m_voteRecords or {}
end
def.method("table").AddVoteRecord = function(self, voteRecord)
  if voteRecord == nil then
    return
  end
  if self.m_voteRecords == nil then
    self.m_voteRecords = {voteRecord}
  else
    self.m_voteRecords[#self.m_voteRecords + 1] = voteRecord
  end
end
return VoteInfo.Commit()
