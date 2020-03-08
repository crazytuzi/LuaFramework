local Lplus = require("Lplus")
local PKInterface = Lplus.Class("PKInterface")
local def = PKInterface.define
local PKMgr = Lplus.ForwardDeclare("PKMgr")
local ItemModule = require("Main.Item.ItemModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
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
def.static("=>", "boolean").IsInProtectionST = function()
  return _G.PlayerIsInState(_G.RoleState.PLAYER_PK_PROTECTION)
end
def.static("=>", "boolean").IsInForceProtectionST = function()
  return _G.PlayerIsInState(_G.RoleState.PLAYER_PK_FORCE_PROTECTION)
end
def.static("=>", "boolean").IsInEnablePKST = function()
  return _G.PlayerIsInState(_G.RoleState.PLAYER_PK_ON)
end
def.static("number", "=>", "table").GetRevengeItemCfgById = function(itemId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_REVENGE_ITEMCFG, itemId)
  if record == nil then
    warn("Load DATA_REVENGE_ITEMCFG error, itemId =", itemId)
    return retData
  end
  retData = {}
  retData.id = record:GetIntValue("id")
  retData.maxQueryTime = record:GetIntValue("maxQueryTime")
  return retData
end
def.static("=>", "table").LoadBuyMeritPriceCfg = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PLAYERPK_MORAL_PRICE_CFG)
  if entries == nil then
    warn(">>>>Load DATA_PLAYERPK_MORAL_PRICE_CFG ERROR<<<<")
    return retData
  end
  retData = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local threshold = record:GetIntValue("threshold")
    local price = record:GetIntValue("yuanbao")
    table.insert(retData, {threshold = threshold, price = price})
  end
  table.sort(retData, function(a, b)
    if a.threshold < b.threshold then
      return true
    else
      return false
    end
  end)
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
return PKInterface.Commit()
