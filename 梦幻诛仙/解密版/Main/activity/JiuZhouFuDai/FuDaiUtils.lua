local Lplus = require("Lplus")
local FuDaiData = require("Main.activity.JiuZhouFuDai.data.FuDaiData")
local ItemUtils = require("Main.Item.ItemUtils")
local JiuZhouFuDaiMgr = require("Main.activity.JiuZhouFuDai.JiuZhouFuDaiMgr")
local FuDaiUtils = Lplus.Class("FuDaiUtils")
local def = FuDaiUtils.define
def.static("number", "=>", "number", "number").GetFixAwardInfo = function(type)
  local itemId = 0
  local count = 0
  local fudaiCfg = FuDaiData.Instance():GetFuDaiCfgByType(type)
  if fudaiCfg then
    if fudaiCfg.fixAwardItemList and fudaiCfg.fixAwardItemList[1] then
      itemId = fudaiCfg.fixAwardItemList[1].itemId
      count = fudaiCfg.fixAwardItemList[1].num
    end
    warn(string.format("[FuDaiUtils:GetFixAwardInfo] get awardId[%d] with itemid[%s] num[%d]!", fudaiCfg.fixAwardId, itemId, count))
  else
    warn("[FuDaiUtils:GetFixAwardInfo] fudaiCfg nil for type:", type)
  end
  return itemId, count
end
def.static("number", "=>", "number").GetFixAwardItemNum = function(type)
  local LuckyBagType = require("consts.mzm.gsp.luckybag.confbean.LuckyBagType")
  if type == LuckyBagType.BRASS then
    return 1
  elseif type == LuckyBagType.JADE then
    return 1
  elseif type == LuckyBagType.BOX then
    return 0
  else
    return 0
  end
end
def.static("number", "number", "=>", "number", "number").GetCostItemInfo = function(fudaiType, drawType)
  local itemId = 0
  local count = 0
  local fudaiCfg = FuDaiData.Instance():GetFuDaiCfgByType(fudaiType)
  if fudaiCfg then
    if drawType == JiuZhouFuDaiMgr.DrawType.TEN then
      itemId = fudaiCfg.costItemId
      count = fudaiCfg.costItemNum10
    else
      itemId = fudaiCfg.costItemId
      count = fudaiCfg.costItemNum
    end
  end
  return itemId, count
end
def.static("number", "=>", "table").GetTurntableItemInfos = function(type)
  local items = {}
  local fudaiCfg = FuDaiData.Instance():GetFuDaiCfgByType(type)
  if fudaiCfg then
    local viewCfg = ItemUtils.GetLotteryViewRandomCfg(fudaiCfg.turntableAwardsId)
    for i, itemId in ipairs(viewCfg.itemIds) do
      local itemInfo = {}
      itemInfo.id = itemId
      itemInfo.num = 1
      table.insert(items, itemInfo)
    end
  end
  return items
end
FuDaiUtils.Commit()
return FuDaiUtils
