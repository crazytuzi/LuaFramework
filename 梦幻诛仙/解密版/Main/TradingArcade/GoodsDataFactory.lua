local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GoodsDataFactory = Lplus.Class(MODULE_NAME)
local GoodsData = import(".data.GoodsData")
local def = GoodsDataFactory.define
local function create(className, type)
  local class = import(".data." .. className, MODULE_NAME)
  local obj = class()
  obj.type = type
  return obj
end
def.static("number", "=>", GoodsData).Create = function(goodsType)
  if goodsType == GoodsData.Type.Item then
    return create("ItemGoodsData", goodsType)
  elseif goodsType == GoodsData.Type.Pet then
    return create("PetGoodsData", goodsType)
  else
    return GoodsData()
  end
end
return GoodsDataFactory.Commit()
