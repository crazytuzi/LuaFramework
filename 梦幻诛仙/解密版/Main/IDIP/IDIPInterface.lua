local Lplus = require("Lplus")
local ItemIDIPData = require("Main.IDIP.data.ItemIDIPData")
local IDIPInterface = Lplus.Class("IDIPInterface")
local def = IDIPInterface.define
def.static("number", "number", "=>", "boolean").IsItemIDIPOpen = function(type, cfgId)
  return ItemIDIPData.Instance():GetItemIDIP(type, cfgId)
end
def.static().OutputItemIDIP = function()
  local itemIDIPMap = ItemIDIPData.Instance():GetItemIDIPMap()
  if itemIDIPMap then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local ChatModule = require("Main.Chat.ChatModule")
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.GM, {
      cmd = textRes.IDIP[16]
    }, false)
    for type, cfgMap in pairs(itemIDIPMap) do
      for cfgId, bOpen in pairs(cfgMap) do
        if bOpen == false then
          local name = IDIPInterface.GetItemCfgName(type, cfgId)
          local str = string.format("type[%d] cfgId[%d] name[%s] is closed.", type, cfgId, name)
          ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.GM, {cmd = str}, false)
        end
      end
    end
    ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.GM, {
      cmd = textRes.IDIP[15]
    }, false)
  end
end
def.static("number", "number", "=>", "string").GetItemCfgName = function(type, cfgId)
  local result = "unknown"
  local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
  if type == ItemSwitchInfo.WING then
    local WingUtils = require("Main.Wing.WingUtils")
    local ItemUtils = require("Main.Item.ItemUtils")
    local wingOutlook = WingUtils.GetWingViewCfg(cfgId)
    local wingItem = ItemUtils.GetItemBase(wingOutlook and wingOutlook.fakeItemId or 0)
    return wingItem and wingItem.name or ""
  elseif type == ItemSwitchInfo.MAGIC_MARK then
  elseif type == ItemSwitchInfo.FASHION then
    local fashionCfg = require("Main.Fashion.FashionUtils").GetFashionItemByFashionType(cfgId)
    result = not fashionCfg or fashionCfg.fashionDressName or result
  elseif type == ItemSwitchInfo.MOUNTS then
    local mountsCfg = require("Main.Mounts.MountsUtils").GetMountsCfgById(cfgId)
    result = not mountsCfg or mountsCfg.mountsName or result
  elseif type == ItemSwitchInfo.CHANGE_MODEL_CARD then
    local cardsCfg = require("Main.TurnedCard.TurnedCardUtils").GetChangeModelCardCfg(cfgId)
    if cardsCfg then
      return cardsCfg.cardName or ""
    end
  end
  return result
end
return IDIPInterface.Commit()
