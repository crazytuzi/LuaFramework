local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FurnitureBag = Lplus.Class(MODULE_NAME)
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = FurnitureBag.define
def.field("table").m_furnitures = nil
local instance
def.final("=>", FurnitureBag).Instance = function(self)
  if instance == nil then
    instance = FurnitureBag()
  end
  return instance
end
def.method("number", "=>", "table").GetFurnituresById = function(self, id)
  if self.m_furnitures == nil then
    return {}
  end
  local furnitures = {}
  for k, v in pairs(self.m_furnitures) do
    if v.id == id then
      furnitures[#furnitures + 1] = v
    end
  end
  return furnitures
end
def.method("number", "=>", "number").GetFurnitureNumbersById = function(self, id)
  if self.m_furnitures == nil then
    return 0
  end
  local nums = 0
  for k, v in pairs(self.m_furnitures) do
    if v.id == id then
      nums = nums + 1
    end
  end
  return nums
end
def.method("=>", "number").GetTotalFurnitureNumbers = function(self)
  if self.m_furnitures == nil then
    return 0
  end
  return table.nums(self.m_furnitures)
end
def.method("=>", "number").GetHouseFurnitureNumbers = function(self)
  return self:GetFurnitureNumbersByArea(HomelandModule.Area.House)
end
def.method("=>", "number").GetCourtyardFurnitureNumbers = function(self)
  return self:GetFurnitureNumbersByArea(HomelandModule.Area.Courtyard)
end
def.method("=>", "boolean").GetHouseHasNew = function(self)
  return self:GetHasNewByArea(HomelandModule.Area.House)
end
def.method("=>", "boolean").GetCourtyardHasNew = function(self)
  return self:GetHasNewByArea(HomelandModule.Area.Courtyard)
end
def.method("number", "=>", "boolean").GetHasNewByArea = function(self, area)
  local allfurnitures = ItemUtils.GetAllFurnitures()
  local FurnitureBagPanel = require("Main.Homeland.ui.FurnitureBagPanel")
  local hasNew = false
  for i, v in pairs(allfurnitures) do
    if v.area == area and v.isNewProduct == true and HomelandUtils.CheckItemInfo(v.id) then
      hasNew = true
      break
    end
  end
  return hasNew
end
def.method("number", "=>", "number").GetFurnitureNumbersByArea = function(self, area)
  if self.m_furnitures == nil then
    return 0
  end
  local nums = 0
  for i, v in pairs(self.m_furnitures) do
    if v.area == area then
      nums = nums + 1
    end
  end
  return nums
end
def.method("number", "=>", "number").GetFurnitureNumbersByStyle = function(self, style)
  return self:GetFurnitureNumbersByStyleAndType(style, nil)
end
def.virtual("number", "dynamic", "=>", "number").GetFurnitureNumbersByStyleAndType = function(self, style, fType)
  if self.m_furnitures == nil then
    return 0
  end
  local nums = 0
  for k, v in pairs(self.m_furnitures) do
    local furnitureCfg = ItemUtils.GetFurnitureCfg(v.id)
    if furnitureCfg and furnitureCfg.styleId == style and (fType == nil or furnitureCfg.furnitureType == fType) then
      nums = nums + 1
    end
  end
  return nums
end
def.method("table").AddFurniture = function(self, furnitureInfo)
  self.m_furnitures = self.m_furnitures or {}
  local uuid = furnitureInfo.uuid
  self.m_furnitures[tostring(uuid)] = furnitureInfo
end
def.method("userdata").RemoveFurniture = function(self, uuid)
  if self.m_furnitures == nil then
    return
  end
  self.m_furnitures[tostring(uuid)] = nil
end
def.method().Clear = function(self)
  self.m_furnitures = nil
end
return FurnitureBag.Commit()
