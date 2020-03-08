local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchBase = Lplus.Class(MODULE_NAME)
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local GoodsDataFactory = require("Main.TradingArcade.GoodsDataFactory")
local def = SearchBase.define
def.const("table").State = {Public = 0, OnSell = 1}
def.field("table").m_condition = nil
def.field("table").m_result = nil
def.field("boolean").m_firstSearch = true
def.method("table").SetSearchCondition = function(self, condition)
  self.m_condition = condition
  self.m_firstSearch = true
end
def.virtual("table").Search = function(self, params)
  if self.m_firstSearch then
    params.page = 0
  end
  self.m_firstSearch = false
end
def.virtual("table", "=>", "boolean").IsConditionEqual = function(self, condition)
  return self:CompareCondition(self.m_condition, condition)
end
def.virtual("table", "table", "=>", "boolean").CompareCondition = function(self, lc, rc)
  return false
end
def.method("table").AddPageItemInfo = function(self, pageItemInfo)
  self.m_result = {}
  self.m_result.totalPage = pageItemInfo.totalPageNum
  local subType = pageItemInfo.subid
  local datas = {}
  print("AddPageItemInfo", #pageItemInfo.marketItemList)
  for i, v in ipairs(pageItemInfo.marketItemList) do
    local data = GoodsDataFactory.Create(GoodsData.Type.Item)
    data:MarshalMarketBean(v)
    datas[#datas + 1] = data
  end
  self.m_result.pages = {}
  self.m_result.pages[pageItemInfo.pageIndex] = datas
end
def.method("table").AddPagePetInfo = function(self, pagePetInfo)
  self.m_result = {}
  self.m_result.totalPage = pagePetInfo.totalPageNum
  local subType = pagePetInfo.subid
  local datas = {}
  print("AddPagePetInfo", #pagePetInfo.marketPetList)
  for i, v in ipairs(pagePetInfo.marketPetList) do
    local data = GoodsDataFactory.Create(GoodsData.Type.Pet)
    data:MarshalMarketBean(v)
    datas[#datas + 1] = data
  end
  self.m_result.pages = {}
  self.m_result.pages[pagePetInfo.pageIndex] = datas
end
def.method("number", "=>", "table").GetResultsByPage = function(self, pageIndex)
  if self.m_result == nil then
    return nil
  end
  return self.m_result.pages[pageIndex]
end
def.method("=>", "number").GetResultTotalPage = function(self)
  if self.m_result == nil then
    return 0
  end
  return self.m_result.totalPage
end
def.method().ClearSearchDatas = function(self)
  self.m_condition = nil
  self.m_result = nil
end
return SearchBase.Commit()
