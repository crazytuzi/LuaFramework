local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local FashionDressConst = require("netio.protocol.mzm.gsp.fashiondress.FashionDressConst")
local DyeData = Lplus.Class("DyeData")
local def = DyeData.define
def.field("number").m_MaxCount = 0
def.field("number").m_CurID = 0
def.field("number").m_CurIndex = 0
def.field("number").m_CurCount = 0
def.field("table").m_ClothListData = nil
local instance
def.static("=>", DyeData).Instance = function()
  if not instance then
    instance = DyeData()
  end
  return instance
end
def.method("number").FindCurIndex = function(self, curid)
  if not self.m_ClothListData then
    return
  end
  local index = 0
  for k, v in pairs(self.m_ClothListData) do
    index = index + 1
    if v.colorid == curid then
      break
    end
  end
  self.m_CurIndex = index
end
def.method("table").SetClothData = function(self, data)
  self.m_MaxCount = data.maxcount
  self.m_ClothListData = data.clothesList
  self.m_CurID = data.curid
  local count = 0
  for k, v in pairs(data.clothesList) do
    count = count + 1
  end
  self:FindCurIndex(data.curid)
  self.m_CurCount = count
end
def.method("table").AddCloth = function(self, data)
  if self.m_ClothListData then
    self.m_CurCount = self.m_CurCount + 1
    table.insert(self.m_ClothListData, data)
    self:FindCurIndex(data.colorid)
    self.m_CurID = data.colorid
  end
end
def.method("table").DeleteCloth = function(self, data)
  if not self.m_ClothListData then
    return
  end
  for k, v in pairs(self.m_ClothListData) do
    if v.colorid == data.colorid then
      self.m_ClothListData[k] = nil
      self.m_CurCount = self.m_CurCount - 1 < 0 and 0 or self.m_CurCount - 1
    end
  end
  self:FindCurIndex(self.m_CurID)
end
def.method("=>", "table").GetCurClothData = function(self)
  if not self.m_ClothListData then
    return nil
  end
  for k, v in pairs(self.m_ClothListData) do
    if self.m_CurID == v.colorid then
      return {
        hairid = v.hairid,
        clothid = v.clothid,
        fashionDressCfgId = v.fashionDressCfgId
      }
    end
  end
  return nil
end
def.method("table").ReplaceCloth = function(self, data)
  self:FindCurIndex(data.colorid)
  self.m_CurID = data.colorid
  self:ReplaceDefaultCloth()
end
def.method().ReplaceDefaultCloth = function(self)
  local curCloth = self:GetCurClothData()
  if curCloth ~= nil and self.m_ClothListData ~= nil and #self.m_ClothListData > 0 then
    local defaultClothIdx = 1
    local defaultCloth = self.m_ClothListData[defaultClothIdx]
    local curFashionId = curCloth.fashionDressCfgId
    defaultCloth.fashionDressCfgId = curFashionId
    if curFashionId ~= FashionDressConst.NO_FASHION_DRESS then
      local fashionItem = require("Main.Fashion.FashionUtils").GetFashionItemDataById(curFashionId)
      defaultCloth.hairid = fashionItem.defaultHairDyeId
      defaultCloth.clothid = fashionItem.defaultClothDyeId
    else
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      local roleCfg = require("Main.Login.LoginUtility").GetCreateRoleCfg(heroProp.occupation, heroProp.gender)
      defaultCloth.hairid = roleCfg.defaultHairDryId
      defaultCloth.clothid = roleCfg.defaultClothDryId
    end
  end
end
def.method("=>", "number").GetClothMaxCount = function(self)
  return constant.RoleDyeConsts.maxRoleDyePlanNum
end
def.method("=>", "number").GetClothCurCount = function(self)
  return self.m_CurCount
end
def.method("=>", "number").GetClothCurIndex = function(self)
  return self.m_CurIndex == 0 and 1 or self.m_CurIndex
end
def.method("=>", "table").GetClothListData = function(self)
  if not self.m_ClothListData then
    return {}
  end
  local data = {}
  local index = 0
  for k, v in pairs(self.m_ClothListData) do
    index = index + 1
    data[index] = v
  end
  return data
end
def.static("=>", "table").GetAllColorFormula = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ROLE_CLOTH_COLOR)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  local index = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    index = i + 1
    cfgs[index] = {}
    cfgs[index].id = record:GetIntValue("id")
    cfgs[index].part = record:GetIntValue("part")
    cfgs[index].color = record:GetIntValue("color")
    cfgs[index].menpai = record:GetIntValue("menpai")
    cfgs[index].gender = record:GetIntValue("gender")
    cfgs[index].a = record:GetIntValue("a")
    cfgs[index].r = record:GetIntValue("r")
    cfgs[index].g = record:GetIntValue("g")
    cfgs[index].b = record:GetIntValue("b")
    cfgs[index].s = record:GetIntValue("s")
    cfgs[index].itemid1 = record:GetIntValue("itemid1")
    cfgs[index].itemcount1 = record:GetIntValue("itemcount1")
    cfgs[index].itemid2 = record:GetIntValue("itemid2")
    cfgs[index].itemcount2 = record:GetIntValue("itemcount2")
    cfgs[index].itemcount2 = record:GetIntValue("itemcount2")
    cfgs[index].fashionDressTypeId = record:GetIntValue("fashionDressTypeId")
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetColorFormula = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ROLE_CLOTH_COLOR, id)
  if not record then
    warn("GetColorFormula(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.part = record:GetIntValue("part")
  cfg.color = record:GetIntValue("color")
  cfg.a = record:GetIntValue("a")
  cfg.r = record:GetIntValue("r")
  cfg.g = record:GetIntValue("g")
  cfg.b = record:GetIntValue("b")
  return cfg
end
return DyeData.Commit()
