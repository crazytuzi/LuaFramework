local MODULE_NAME = (...)
local Lplus = require("Lplus")
local EquipBreakMgr = Lplus.Class(MODULE_NAME)
local ItemPriceHelper = require("Main.Item.ItemPriceHelper")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = EquipBreakMgr.define
local instance
def.static("=>", EquipBreakMgr).Instance = function()
  if instance == nil then
    instance = EquipBreakMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SEquipDisassembleRes", EquipBreakMgr.OnSEquipDisassembleRes)
end
def.method("=>", "boolean").IsOpen = function(self)
  if not self:IsFeatureOpen() then
    return false
  end
  return true
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIP_DISASSEMBLE) then
    return false
  end
  return true
end
def.method("table", "=>", "boolean").CanBreak = function(self, equip)
  local equipId = equip.id
  if not self:IsOpen() then
    return false
  end
  local componentsCfg = EquipUtils.GetEquipComponentsCfg(equipId)
  if componentsCfg == nil then
    return false
  end
  local itemBase = ItemUtils.GetItemBase(equipId)
  if itemBase == nil then
    return false
  end
  local useLevel = itemBase.useLevel
  local minLevel = EquipUtils.GetConstant("MIN_EQUIP_LEVEL_FOR_DISASSEMBLE")
  if useLevel < minLevel then
    return false
  end
  local namecolor = itemBase.namecolor
  local minColor = EquipUtils.GetConstant("MIN_EQUIP_COLOR_FOR_DISASSEMBLE")
  if namecolor < minColor then
    return false
  end
  local isItemBinded = ItemUtils.IsItemBind(equip)
  local canBindedItemBeBroke = EquipUtils.GetConstant("IS_BIND_EQUIP_CAN_DISASSEMBLE")
  if isItemBinded and not canBindedItemBeBroke then
    return false
  end
  return true
end
def.method("table").BreakEquip = function(self, equip)
  local equipId = equip.id
  local componentsCfg = EquipUtils.GetEquipComponentsCfg(equipId)
  if componentsCfg == nil then
    error(string.format("can't break equip(%d)", equipId))
  end
  local needItemIds = {}
  for i, v in ipairs(componentsCfg.components) do
    needItemIds[i] = v.itemId
  end
  ItemPriceHelper.GetItemsYuanbaoPriceAsync(needItemIds, function(itemid2yuanbao)
    local totalYuanbao = 0
    for i, v in ipairs(componentsCfg.components) do
      totalYuanbao = totalYuanbao + itemid2yuanbao[v.itemId] * v.itemNum
    end
    self:AskBreakEquipConfirm(equip, totalYuanbao)
  end)
end
def.method("table", "number").AskBreakEquipConfirm = function(self, equip, makeCostYuanbao)
  local equipId = equip.id
  local fragmentNum = self:CalcFragmentNumByYuanbao(makeCostYuanbao)
  local fragmentItemId = EquipUtils.GetConstant("EQUIP_DISASSEMBLE_OUT_PUT_ITEMID")
  local fragmentItemBase = ItemUtils.GetItemBase(fragmentItemId)
  local fragmentItemName
  if fragmentItemBase then
    fragmentItemName = fragmentItemBase.name
  else
    fragmentItemName = "$fragment_item_name"
  end
  local compoundCfg = ItemUtils.GetItemCompounCfg(fragmentItemId)
  local compoundItemName = "$compound_item_name"
  local needFragmentNum = "$need_fragment_num"
  if compoundCfg then
    compoundItemName = compoundCfg.showname
    local makeCfgId = compoundCfg.makeCfgId
    local makeItemTable = EquipUtils.GetMakeItemTable(makeCfgId)
    if makeItemTable then
      for k, v in pairs(makeItemTable.makeNeedItem) do
        if v.itemId == fragmentItemId then
          needFragmentNum = v.itemNum
          break
        end
      end
    end
  end
  local desc
  if fragmentNum > 0 then
    desc = textRes.Equip[403]:format(fragmentNum, fragmentItemName, needFragmentNum, compoundItemName)
  else
    desc = textRes.Equip[404]:format(fragmentItemName)
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Equip[402], desc, function(s)
    if s == 1 then
      local uuid = equip.uuid[1]
      self:CEquipDisassembleReq(uuid)
    end
  end, nil)
end
def.method("number", "=>", "number").CalcFragmentNumByYuanbao = function(self, yuanbao)
  local EQUIP_DISASSEMBLE_PRICE_RATE = EquipUtils.GetConstant("EQUIP_DISASSEMBLE_PRICE_RATE")
  local rate = EQUIP_DISASSEMBLE_PRICE_RATE / _G.NUMBER_WAN
  local res = require("Common.MathHelper").Floor(yuanbao * rate)
  return res
end
def.method("userdata").CEquipDisassembleReq = function(self, uuid)
  local p = require("netio.protocol.mzm.gsp.item.CEquipDisassembleReq").new(uuid)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSEquipDisassembleRes = function(p)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local coloredItemName = HtmlHelper.GetColoredItemName(p.itemid)
  local itemNum = p.itemnum
  local text
  if itemNum > 0 then
    text = textRes.Equip[405]:format(itemNum, coloredItemName)
  else
    text = textRes.Equip[406]:format(coloredItemName)
  end
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
return EquipBreakMgr.Commit()
