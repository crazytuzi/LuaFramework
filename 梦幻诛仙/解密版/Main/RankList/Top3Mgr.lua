local Lplus = require("Lplus")
local Top3Mgr = Lplus.Class("Top3Mgr")
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local def = Top3Mgr.define
def.const("table").Top3Type = {Model = 1}
local instance
def.static("=>", Top3Mgr).Instance = function()
  if instance == nil then
    instance = Top3Mgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chart.STopModelListRes", Top3Mgr.OnSTopModelListRes)
end
def.method("number", "table").ReqRoleModelList = function(self, chartType, idList)
  if idList == nil or #idList == 0 then
    return
  end
  local p = require("netio.protocol.mzm.gsp.chart.CGetRoleModelList").new(idList, chartType)
  gmodule.network.sendProtocol(p)
end
def.method("number", "table").ReqPetModelList = function(self, chartType, idList)
  if idList == nil or #idList == 0 then
    return
  end
  local p = require("netio.protocol.mzm.gsp.chart.CGetPetModelList").new(idList, chartType)
  gmodule.network.sendProtocol(p)
end
def.method("number", "table").ReqChildrenModelList = function(self, chartType, idList)
  if idList == nil or #idList == 0 then
    return
  end
  local p = require("netio.protocol.mzm.gsp.chart.CGetChildrenModelList").new(idList, chartType)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSTopModelListRes = function(p)
  local rankListData = RankListModule.Instance():GetRankListData(p.chartType)
  local top3Data = require("Main.RankList.Top3DataFactory").Instance():Create(Top3Mgr.Top3Type.Model)
  top3Data.list = p.dataList
  rankListData.top3Data = top3Data
  Event.DispatchEvent(ModuleId.RANK_LIST, gmodule.notifyId.RankList.RECEIVED_TOP_3_DATA, {
    p.chartType
  })
end
def.method("table", "=>", "table").GetTop3DisplayData = function(self, rankList)
  if rankList.list == nil then
    return nil
  end
  if rankList.type == RankListModule.RankListType.ROLE_FIGHT_VALUE then
    return self:GetTop3DRoleDisplayData(rankList, "fightValue")
  elseif rankList.type == RankListModule.RankListType.ROLE_LEVEL then
    return self:GetTop3DRoleDisplayData(rankList, "level")
  elseif rankList.type == RankListModule.RankListType.PET_YAOLI then
    return self:GetTop3DPetDisplayData(rankList)
  elseif rankList.type == RankListModule.RankListType.CHILDREN_RATING then
    return self:GetTop3ChildDisplayData(rankList)
  else
    return nil
  end
end
def.method("table", "string", "=>", "table").GetTop3DRoleDisplayData = function(self, rankList, valueName)
  local displayDataList = {}
  for i, top3Data in ipairs(rankList.top3List) do
    local rankData = rankList.list[i]
    local displayData = self:GetRoleDisplayData(top3Data, rankData, valueName)
    displayData.type = rankList.type
    table.insert(displayDataList, displayData)
  end
  return displayDataList
end
def.method("table", "table", "string", "=>", "table").GetRoleDisplayData = function(self, top3Data, rankData, valueName)
  local occupation = rankData.occupationId
  local gender = top3Data.intProp[RankListModule.TopThreeData.ROLE_GENDER]
  print(occupation, gender, RankListModule.TopThreeData.ROLE_GENDER)
  local occupationCfg = _G.GetOccupationCfg(occupation, gender)
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  local modelInfo = ModelInfo.new(occupationCfg.modelId, nil, {
    [ModelInfo.WEAPON] = top3Data.intProp[RankListModule.TopThreeData.WEAPON_ID],
    [ModelInfo.QILING_LEVEL] = top3Data.intProp[RankListModule.TopThreeData.WEAPON_QILING_LEVEL],
    [ModelInfo.WING] = top3Data.intProp[RankListModule.TopThreeData.WING_ID],
    [ModelInfo.FABAO] = top3Data.intProp[RankListModule.TopThreeData.FABAO_ID]
  })
  local displayData = {}
  displayData.modelInfo = modelInfo
  displayData.name = rankData.name
  displayData.value = rankData[valueName]
  return displayData
end
def.method("table", "=>", "table").GetTop3DPetDisplayData = function(self, rankList)
  local displayDataList = {}
  for i, top3Data in ipairs(rankList.top3List) do
    local rankData = rankList.list[i]
    local displayData = self:GetPetDisplayData(top3Data, rankData)
    displayData.type = rankList.type
    table.insert(displayDataList, displayData)
  end
  return displayDataList
end
def.method("table", "table", "=>", "table").GetPetDisplayData = function(self, top3Data, rankData)
  local PetUtility = require("Main.Pet.PetUtility")
  local petCfgId = top3Data.intProp[RankListModule.TopThreeData.PET_CFG_ID]
  local petCfg = PetUtility.Instance():GetPetCfg(petCfgId)
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  local modelInfo = ModelInfo.new(petCfg.modelId, petCfg.colorId, {})
  local displayData = {}
  displayData.modelInfo = modelInfo
  displayData.name = rankData.petName
  displayData.value = rankData.yaoLi
  return displayData
end
def.method("table", "=>", "table").GetTop3ChildDisplayData = function(self, rankList)
  local displayDataList = {}
  for i, top3Data in ipairs(rankList.top3List) do
    local rankData = rankList.list[i]
    local displayData = self:GetChildDisplayData(top3Data, rankData)
    displayData.type = rankList.type
    table.insert(displayDataList, displayData)
  end
  return displayDataList
end
def.method("table", "table", "=>", "table").GetChildDisplayData = function(self, top3Data, rankData)
  local displayData = {}
  displayData.modelInfo = top3Data
  displayData.name = _G.GetStringFromOcts(rankData.child_name)
  displayData.value = rankData.rating
  return displayData
end
return Top3Mgr.Commit()
