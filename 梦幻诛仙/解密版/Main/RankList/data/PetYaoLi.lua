local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local PetYaoLiRankListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = PetYaoLiRankListData.define
def.final("number", "=>", PetYaoLiRankListData).New = function(type)
  local obj = PetYaoLiRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local p = require("netio.protocol.mzm.gsp.pet.CGetPetYaoliRankReq").new(from, to)
  gmodule.network.sendProtocol(p)
end
def.override("number").ReqTopNUnitInfo = function(self, number)
  if self.list == nil then
    warn("ranklist not init type = " .. self.type)
    return
  end
  local PetOwner = require("netio.protocol.mzm.gsp.chart.PetOwner")
  local idList = {}
  for i = 1, number do
    if self.list[i] then
      table.insert(idList, PetOwner.new(self.list[i].roleId, self.list[i].petId))
    end
  end
  local Top3Mgr = require("Main.RankList.Top3Mgr")
  Top3Mgr.Instance():ReqPetModelList(self.type, idList)
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local list = self.list
  local function getDisplayName(v)
    local displayName
    if v.templateId then
      local petCfg = PetUtility.Instance():GetPetCfg(v.templateId)
      displayName = petCfg.templateName
    else
      displayName = v.petName
    end
    return displayName
  end
  local displayInfoList = {}
  local listNum = #list
  for i = from, to do
    local v = list[i]
    if v == nil then
      break
    end
    local stepInfo = self:GetStepInfo(v.step)
    local displayInfo
    if v.isExit ~= 0 then
      displayInfo = {
        v.no,
        getDisplayName(v),
        v.roleName,
        tostring(v.yaoLi),
        stepInfo
      }
    else
      displayInfo = {
        v.no,
        textRes.RankList[10],
        textRes.RankList[10],
        textRes.RankList[10],
        stepInfo
      }
    end
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  return self:GetMyPetMaxYaoLi()
end
def.method("=>", "table", "number").GetSelfMaxYaoLiPetIds = function(self)
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local PetStorageMgr = require("Main.Pet.mgr.PetStorageMgr")
  local maxYaoLi = 0
  local idMap = {}
  local pets = PetMgr.Instance():GetPets()
  for petId, pet in pairs(pets) do
    local yaoLi = pet:GetYaoLi()
    if maxYaoLi < yaoLi then
      idMap = {}
      idMap[petId] = true
      maxYaoLi = yaoLi
    elseif yaoLi == maxYaoLi then
      idMap[petId] = true
    end
  end
  return idMap, maxYaoLi
end
def.method("=>", "number").GetMyPetMaxYaoLi = function(self)
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local PetStorageMgr = require("Main.Pet.mgr.PetStorageMgr")
  local _, maxYaoLi = self:GetSelfMaxYaoLiPetIds()
  return maxYaoLi
end
def.override("number").ShowUnitInfo = function(self, index)
  local rankData = self.list[index]
  local RankUnitInfoMgr = require("Main.RankList.RankUnitInfoMgr")
  RankUnitInfoMgr.Instance():ShowPetInfo(rankData.roleId, rankData.petId)
end
return PetYaoLiRankListData.Commit()
