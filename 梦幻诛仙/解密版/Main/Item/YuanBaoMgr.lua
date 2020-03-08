local Lplus = require("Lplus")
local YuanBaoMgr = Lplus.Class("YuanBaoMgr")
local def = YuanBaoMgr.define
local ItemUtils = require("Main.Item.ItemUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local instance
def.static("=>", YuanBaoMgr).Instance = function()
  if instance == nil then
    instance = YuanBaoMgr()
    instance.yuanbaoToGold = DynamicData.GetRecord(CFG_PATH.DATA_MONEYEXCHANGE_CFG, "YUANBAO_TO_GOLD_NUM"):GetIntValue("value")
    instance.yuanbaoToSilver = DynamicData.GetRecord(CFG_PATH.DATA_MONEYEXCHANGE_CFG, "YUANBAO_TO_SILVER_NUM"):GetIntValue("value")
  end
  return instance
end
def.field("boolean").isShow = false
def.field("function").callback = nil
def.field("number").yuanbaoToGold = 1
def.field("number").yuanbaoToSilver = 1
def.method("table", "number", "number", "string", "string", "function", "table").YubaoBuzu = function(self, laskItems, laskGold, laskSilver, title, desc, callback, tag)
  if self.isShow then
    return
  end
  local yuanBaoNeed = 0
  for k, v in pairs(laskItems) do
    yuanBaoNeed = yuanBaoNeed + self:ItemToYuanbao(k, v)
  end
  yuanBaoNeed = yuanBaoNeed + self:GoldToYuanbao(laskGold)
  yuanBaoNeed = yuanBaoNeed + self:SilverToYuanbao(laskSilver)
  local integerYuanbao = math.ceil(yuanBaoNeed)
  local description = self:GetDescription(integerYuanbao, laskItems, laskGold, laskSilver, desc)
  self.callback = callback
  CommonConfirmDlg.ShowConfirm(title, description, YuanBaoMgr.result, tag)
  self.isShow = true
end
def.method("number", "number", "=>", "number").ItemToYuanbao = function(self, itemId, number)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local soldSilver = itemBase.sellSilver
  local ratio = self.yuanbaoToSilver
  return soldSilver / ratio
end
def.method("number", "=>", "number").GoldToYuanbao = function(self, gold)
  local ratio = self.yuanbaoToGold
  return gold / ratio
end
def.method("number", "=>", "number").SilverToYuanbao = function(self, silver)
  local ratio = self.yuanbaoToSilver
  return silver / ratio
end
def.method("number", "table", "number", "number", "string", "=>", "string").GetDescription = function(self, yuanBaoNeed, items, gold, silver, desc)
  local strTable = {}
  table.insert(strTable, string.format(textRes.YuanBao[1], yuanBaoNeed))
  for k, v in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(k)
    table.insert(strTable, string.format(textRes.YuanBao[5], itemBase.name, v))
  end
  if gold > 0 then
    table.insert(strTable, string.format(textRes.YuanBao[2], gold))
  end
  if silver > 0 then
    table.insert(strTable, string.format(textRes.YuanBao[3], silver))
  end
  table.insert(strTable, string.format(textRes.YuanBao[4], desc))
  return table.concat(strTable)
end
def.static("number", "table").result = function(select, tag)
  instance.isShow = false
  if instance.callback then
    instance.callback(select, tag)
  end
end
YuanBaoMgr.Commit()
return YuanBaoMgr
