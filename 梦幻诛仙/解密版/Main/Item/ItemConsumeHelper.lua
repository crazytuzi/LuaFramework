local Lplus = require("Lplus")
local ItemConsumeHelper = Lplus.Class("ItemConsumeHelper")
local def = ItemConsumeHelper.define
local ItemModule = require("Main.Item.ItemModule")
local ItemData = require("Main.Item.ItemData")
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local _instance
def.field("number").itemId = 0
def.field("string").title = ""
def.field("string").desc = ""
def.field("number").needNum = 0
def.field("number").hasNum = 0
def.field("number").yuanbao = 0
def.field("function").callback = nil
def.static("=>", ItemConsumeHelper).Instance = function()
  if _instance == nil then
    _instance = ItemConsumeHelper()
    _instance:Init()
  end
  return _instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SItemYuanbaoPriceRes", ItemConsumeHelper._onYuanbaoPrice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResItemYuanbaoPriceWithId", ItemConsumeHelper.OnYuanbaoPrice)
end
def.method("string", "string", "number", "number", "function").ShowItemConsumeAllBag = function(self, title, desc, itemId, needNum, cb)
  self.title = title
  self.desc = desc
  self.itemId = itemId
  self.needNum = needNum
  self.callback = cb
  local hasNum = ItemData.Instance():GetItemCountById(self.itemId)
  self.hasNum = hasNum
  if self.hasNum >= self.needNum then
    self.yuanbao = 0
    self:ShowDlg()
  else
    self:AskYuanbaoPrice()
  end
end
def.method("string", "string", "number", "number", "function").ShowItemConsume = function(self, title, desc, itemId, needNum, cb)
  self.title = title
  self.desc = desc
  self.itemId = itemId
  self.needNum = needNum
  self.callback = cb
  local hasNum = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, self.itemId)
  self.hasNum = hasNum
  if self.hasNum >= self.needNum then
    self.yuanbao = 0
    self:ShowDlg()
  else
    self:AskYuanbaoPrice()
  end
end
def.method("string", "string", "number", "number", "number", "function").ShowItemConsumeByItemType = function(self, title, desc, showItemId, itemType, needNum, cb)
  self.title = title
  self.desc = desc
  self.itemId = showItemId
  self.needNum = needNum
  self.callback = cb
  local hasNum = 0
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  for k, v in pairs(items) do
    hasNum = hasNum + v.number
  end
  self.hasNum = hasNum
  if self.hasNum >= self.needNum then
    self.yuanbao = 0
    self:ShowDlg()
  else
    self:AskYuanbaoPrice()
  end
end
def.method().ShowDlg = function(self)
  local title = self.title
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  local name = itemBase.name
  local numStr = ""
  local desc = ""
  local iconId = itemBase.icon
  local yuanbao = self.yuanbao
  if self.yuanbao <= 0 then
    numStr = string.format("%d/%d", self.hasNum, self.needNum)
    desc = string.format(textRes.Item[33], self.needNum, HtmlHelper.NameColor[itemBase.namecolor], name, self.desc)
  else
    numStr = string.format("[ff0000]%d[-]/%d", self.hasNum, self.needNum)
    desc = string.format(textRes.Item[34], yuanbao, self.needNum - self.hasNum, HtmlHelper.NameColor[itemBase.namecolor], name, self.desc)
  end
  local ItemConsumeDlg = require("Main.Item.ui.ItemConsumeDlg")
  ItemConsumeDlg.ShowItemConsume(self.itemId, title, name, numStr, desc, iconId, yuanbao, function(select)
    local myYuanbao = ItemModule.Instance():GetAllYuanBao()
    if select < 0 then
      self.callback(select)
    elseif select == 0 then
      self.callback(select)
    elseif myYuanbao:lt(select) then
      _G.GotoBuyYuanbao()
    else
      self.callback(select)
    end
  end)
end
def.method().AskYuanbaoPrice = function(self)
  local yuanbaoPrice = require("netio.protocol.mzm.gsp.item.CItemYuanbaoPriceReq").new(self.itemId)
  gmodule.network.sendProtocol(yuanbaoPrice)
end
def.static("table")._onYuanbaoPrice = function(p)
  if p.itemid == _instance.itemId then
    _instance.yuanbao = p.yuanbaoPrice * (_instance.needNum - _instance.hasNum)
    _instance:ShowDlg()
  end
end
def.field("table").askData = nil
def.method("number", "function").GetItemYuanBaoPrice = function(self, itemId, callback)
  if self.askData == nil then
    self.askData = {}
  end
  if self.askData[itemId] == nil then
    self.askData[itemId] = {}
    table.insert(self.askData[itemId], callback)
    local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(0, {itemId})
    gmodule.network.sendProtocol(p)
  else
    table.insert(self.askData[itemId], callback)
  end
end
def.static("table").OnYuanbaoPrice = function(p)
  local self = _instance
  local id = p.uid
  if id == 0 then
    for k, v in pairs(p.itemid2yuanbao) do
      if self.askData[k] then
        for k1, v1 in ipairs(self.askData[k]) do
          v1(v)
        end
        self.askData[k] = nil
      end
    end
  end
end
ItemConsumeHelper.Commit()
return ItemConsumeHelper
