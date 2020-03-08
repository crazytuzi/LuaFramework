local CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListData = import(".RankListData")
local PetsArenaRankListData = Lplus.Extend(RankListData, CLASS_NAME)
local Cls = PetsArenaRankListData
local def = Cls.define
def.field("number").myRank = 0
def.field("number").my_point = 0
def.const("number").tipId = constant.CPetArenaConst.RULE_TIPS
def.final("number", "=>", PetsArenaRankListData).New = function(type)
  local obj = PetsArenaRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.method().Ctor = function(self)
end
def.override("=>", "boolean").IsOpen = function(self)
  return require("Main.Pet.PetsArena.PetsArenaMgr").IsRanklistOpen()
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from - 1, to - from
  require("Main.Pet.PetsArena.PetsArenaMgr").GetProtocol().CSendRankListReq(startpos, num)
end
def.override("table").UnmarshalProtocol = function(self, p)
  if self.list == nil then
    self.list = {}
  end
  self.myRank = p.my_rank
  self.my_point = p.my_point
  for _, v in pairs(p.rank_datas or {}) do
    self.list[v.rank] = v
  end
  self:Callback()
end
def.override("function").OnReqSelfRankInfo = function(self, callback)
end
def.method("table").UnmarshalSelfRankProtocol = function(self, p)
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local displayInfoList = {}
  for i = from, to do
    local v = self.list[i]
    if v == nil then
      break
    end
    local name = v.name
    local displayInfo
    local stepInfo = {}
    stepInfo.step = 0
    if v.roleid:eq(0) then
      name = constant.CPetArenaConst.ROBOT_NAME
      displayInfo = {
        i,
        name,
        v.win_num,
        v.defend_win_num,
        stepInfo
      }
    else
      name = _G.GetStringFromOcts(v.name)
      displayInfo = {
        i,
        name,
        v.win_num,
        v.defend_win_num,
        stepInfo
      }
    end
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("=>", "boolean").IsShowTop3 = function(self)
  return false
end
def.override("=>", "boolean").IsShowMyRank = function(self)
  return true
end
def.override("=>", "number").GetSelfRank = function(self)
  return self.myRank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  return self.my_point
end
def.override("number").ReqTopNUnitInfo = function(self, number)
  if self.list == nil then
    warn("[ERROR:] Pets Arena rank list is not init")
    return
  end
end
def.override("number").ShowUnitInfo = function(self, index)
  local roleId = self:TryGetRoleId(index)
  warn("index", index, "roleId", roleId:tostring())
  if roleId and roleId:eq(0) then
    return
  end
  if roleId then
    local RankUnitInfoMgr = require("Main.RankList.RankUnitInfoMgr")
    RankUnitInfoMgr.Instance():ShowRoleInfo(roleId)
  end
end
return Cls.Commit()
