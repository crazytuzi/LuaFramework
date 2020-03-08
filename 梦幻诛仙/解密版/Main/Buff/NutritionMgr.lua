local Lplus = require("Lplus")
local NutritionMgr = Lplus.Class("NutritionMgr")
local BuffData = require("Main.Buff.data.BuffData")
local BuffUtils = require("Main.Buff.BuffUtility")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local def = NutritionMgr.define
def.const("table").SupplementNutritionMethod = {UseItem = 1, UseSilver = 2}
local CResult = {
  Success = 1,
  SilverNotEnough = 2,
  NutritionReachMax = 3
}
def.const("table").CResult = CResult
local instance
def.static("=>", NutritionMgr).Instance = function()
  if instance == nil then
    instance = NutritionMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("=>", "table").GetSupplementNutritionItems = function(self)
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  local list = {}
  for key, item in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase.itemType == ItemType.BAO_SHI_DU then
      table.insert(list, {
        itemKey = key,
        item = item,
        itemBase = itemBase
      })
    end
  end
  table.sort(list, NutritionMgr.SupplementNutritionItemsSortFunction)
  return list
end
def.static("table", "table", "=>", "boolean").SupplementNutritionItemsSortFunction = function(left, right)
  local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
  local leftItemInfo = LivingSkillUtility.GetBaoShiDuItemInfo(left.item.id)
  local rightItemInfo = LivingSkillUtility.GetBaoShiDuItemInfo(right.item.id)
  if leftItemInfo.siftcfgid < rightItemInfo.siftcfgid then
    return true
  elseif leftItemInfo.siftcfgid == rightItemInfo.siftcfgid and leftItemInfo.drugPro < rightItemInfo.drugPro then
    return true
  else
    return false
  end
end
def.method("=>", "number").GetCurNutrition = function(self)
  local BuffMgr = require("Main.Buff.BuffMgr")
  local nutritionBuff = BuffMgr.Instance():GetBuff(BuffMgr.NUTRITION_BUFF_ID)
  return Int64.ToNumber(nutritionBuff.remainValue)
end
def.method("=>", "number").GetMaxNutrition = function(self)
  return require("Main.Hero.HeroUtility").Instance():GetRoleCommonConsts("BAOSHIDU_LIMIT")
end
def.method("=>", "number").GetCanSupplementNutrition = function(self)
  return self:GetMaxNutrition() - self:GetCurNutrition()
end
def.method("=>", "table").GetCurSilverMaxSupplement = function(self)
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local supplementCfg = BuffUtils.GetSupplementNutritionCfg(heroLevel)
  local neededSilverPerNutrition = supplementCfg.neededSilverPerNutrition
  local amount = Int64.div(haveSilver, neededSilverPerNutrition)
  local canSupplementAmount = self:GetCanSupplementNutrition()
  local result = {}
  if Int64.ge(amount, canSupplementAmount) or Int64.eq(amount, 0) then
    result.amount = canSupplementAmount
  else
    result.amount = Int64.ToNumber(amount)
  end
  result.useSilver = result.amount * neededSilverPerNutrition
  return result
end
def.method("=>", "number").SilverSupplementNutrition = function(self)
  local curSilverMaxSupplement = self:GetCurSilverMaxSupplement()
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local result
  if self:GetCanSupplementNutrition() == 0 then
    result = CResult.NutritionReachMax
  elseif Int64.lt(haveSilver, curSilverMaxSupplement.useSilver) then
    result = CResult.SilverNotEnough
  else
    self:C2S_SilverAddBaoShiDuReq()
    result = CResult.Success
  end
  return result
end
def.method("number", "=>", "number").ItemSupplementNutrition = function(self, itemKey)
  local result
  if self:GetCanSupplementNutrition() == 0 then
    result = CResult.NutritionReachMax
  else
    self:C2S_UseBaoShiDuItemReq(itemKey)
    result = CResult.Success
  end
  return result
end
def.method().C2S_SilverAddBaoShiDuReq = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.role.CSilverAddBaoShiDuReq").new())
end
def.method("number").C2S_UseBaoShiDuItemReq = function(self, itemKey)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.role.CUseBaoShiDuItemReq").new(itemKey))
end
return NutritionMgr.Commit()
