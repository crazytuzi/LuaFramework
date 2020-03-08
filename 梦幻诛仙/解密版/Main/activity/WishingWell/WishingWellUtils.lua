local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local WishingWellUtils = Lplus.Class("WishingWellUtils")
local def = WishingWellUtils.define
def.static("number", "=>", "table").GetAwardItems = function(awardId)
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
  local cfg = ItemUtils.GetGiftAwardCfg(key)
  local itemList = ItemUtils.GetAwardItemsFromAwardCfg(cfg)
  if itemList and itemList[1] then
    return itemList
  else
    return nil
  end
end
def.static("number", "=>", "boolean").IsPastDay = function(wishTime)
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local curTime = _G.GetServerTime()
  local wishTimeTable = AbsoluteTimer.GetServerTimeTable(wishTime)
  local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
  if wishTimeTable.year == curTimeTable.year and wishTimeTable.month == curTimeTable.month and wishTimeTable.day == curTimeTable.day then
    return false
  else
    return true
  end
end
WishingWellUtils.Commit()
return WishingWellUtils
