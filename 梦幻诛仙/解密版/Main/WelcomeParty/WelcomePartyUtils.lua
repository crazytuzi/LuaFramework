local MODULE_NAME = (...)
local Lplus = require("Lplus")
local WelcomePartyUtils = Lplus.Class(MODULE_NAME)
local instance
local def = WelcomePartyUtils.define
local ItemModule = require("Main.Item.ItemModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
def.static("number", "=>", "table").GetGoodsInfoById = function(id)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TESCOMALL_CFG, id)
  if record == nil then
    warn("Load DATA_TESCOMALL_CFG error, id", id)
    return retData
  end
  local constShowType = require("consts.mzm.gsp.legoushangcheng.confbean.ShowDiscountType")
  retData.id = record:GetIntValue("id")
  retData.bShowDiscount = record:GetIntValue("isShowDiscount") == constShowType.SHOW_DISCOUNT
  retData.fixAwardId = record:GetIntValue("fix_award_Id")
  retData.buyLimit = record:GetIntValue("buy_top_limit")
  retData.price = record:GetIntValue("base_price")
  retData.discount = record:GetIntValue("sale_rate")
  retData.moneyType = record:GetIntValue("moneyType")
  return retData
end
def.static("=>", "table").LoadAllGoodsCfg = function()
  local retData
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TESCOMALL_CFG)
  if entries == nil then
    warn(">>>>Load DATA_TESCOMALL_CFG ERROR<<<<")
    return retData
  end
  local constShowType = require("consts.mzm.gsp.legoushangcheng.confbean.ShowDiscountType")
  retData = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = {}
    data.id = record:GetIntValue("id")
    data.bShowDiscount = record:GetIntValue("isShowDiscount") == constShowType.SHOW_DISCOUNT
    data.fixAwardId = record:GetIntValue("fix_award_Id")
    data.buyLimit = record:GetIntValue("buy_top_limit")
    data.price = record:GetIntValue("base_price")
    data.discount = record:GetIntValue("sale_rate")
    data.moneyType = record:GetIntValue("cost_currency_type")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "userdata").GetMoneyNumByType = function(mtype)
  if mtype == MoneyType.YUANBAO then
    return ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  else
    if mtype == MoneyType.SILVER then
      mtype = ItemModule.MONEY_TYPE_SILVER
    elseif mtype == MoneyType.GOLD then
      mtype = ItemModule.MONEY_TYPE_GOLD
    elseif mtype == MoneyType.GOLD_INGOT then
      mtype = ItemModule.MONEY_TYPE_GOLD_INGOT
    end
    return ItemModule.Instance():GetMoney(mtype) or Int64.new(0)
  end
end
def.static("number", "boolean").GotoBuyMoney = function(mtype, bconfirm)
  if mtype == MoneyType.YUANBAO then
    _G.GotoBuyYuanbao()
  elseif mtype == MoneyType.GOLD then
    _G.GoToBuyGold(bconfirm)
  elseif mtype == MoneyType.SILVER then
    _G.GoToBuySilver(bconfirm)
  elseif mtype == MoneyType.GOLD_INGOT then
    _G.GoToBuyGoldIngot(bconfirm)
  end
end
return WelcomePartyUtils.Commit()
