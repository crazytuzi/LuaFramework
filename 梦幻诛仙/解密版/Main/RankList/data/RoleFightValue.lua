local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local RoleFightValueRankListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = RoleFightValueRankListData.define
def.final("number", "=>", RoleFightValueRankListData).New = function(type)
  local obj = RoleFightValueRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local p = require("netio.protocol.mzm.gsp.role.CGetRoleFightValueRankReq").new(from, to)
  gmodule.network.sendProtocol(p)
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local list = self.list
  local displayInfoList = {}
  local listNum = #list
  for i = from, to do
    local v = list[i]
    if v == nil then
      break
    end
    local stepInfo = self:GetStepInfo(v.step)
    local occupationName = _G.GetOccupationName(v.occupationId)
    local displayInfo = {
      v.no,
      v.name,
      occupationName,
      tostring(v.fightValue),
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  local heroProp = _G.GetHeroProp()
  return heroProp.fightValue
end
return RoleFightValueRankListData.Commit()
