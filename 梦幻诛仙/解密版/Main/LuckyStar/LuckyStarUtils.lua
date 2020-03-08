local Lplus = require("Lplus")
local LuckyStarUtils = Lplus.Class("LuckyStarUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = LuckyStarUtils.define
def.static("number", "=>", "table").GetLuckyStarAwardInfoById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LUCKY_STAR_AWARD_CFG, id)
  if record == nil then
    warn("LuckyStar award not exist:" .. id)
    return nil
  end
  local award = {}
  award.id = record:GetIntValue("id")
  award.fix_award_Id = record:GetIntValue("fix_award_Id")
  award.buy_top_limit = record:GetIntValue("buy_top_limit")
  award.base_price = record:GetIntValue("base_price")
  award.sale_rate = record:GetIntValue("sale_rate")
  award.cost_currency_type = record:GetIntValue("cost_currency_type")
  local fixAwardCfg = ItemUtils.GetGiftAwardCfgByAwardId(award.fix_award_Id)
  if fixAwardCfg and #fixAwardCfg.itemList > 0 then
    award.awardItem = fixAwardCfg.itemList[1]
  else
    warn("lucky star fix award has no item:" .. award.fix_award_Id)
  end
  return award
end
LuckyStarUtils.Commit()
return LuckyStarUtils
