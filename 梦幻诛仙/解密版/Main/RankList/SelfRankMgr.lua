local Lplus = require("Lplus")
local SelfRankMgr = Lplus.Class("SelfRankMgr")
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local def = SelfRankMgr.define
def.const("number").OUT_OF_RANK_LIST = 0
local instance
def.static("=>", SelfRankMgr).Instance = function()
  if instance == nil then
    instance = SelfRankMgr()
  end
  return instance
end
return SelfRankMgr.Commit()
