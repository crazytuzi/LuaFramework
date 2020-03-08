local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FuDaiData = require("Main.activity.JiuZhouFuDai.data.FuDaiData")
local JiuZhouFudaiPanel = require("Main.activity.JiuZhouFuDai.ui.JiuZhouFudaiPanel")
local LuckyBagType = require("consts.mzm.gsp.luckybag.confbean.LuckyBagType")
local JiuZhouFuDaiMgr = require("Main.activity.JiuZhouFuDai.JiuZhouFuDaiMgr")
local FudaiAwardPanel = require("Main.activity.JiuZhouFuDai.ui.FudaiAwardPanel")
local FuDaiProtocols = Lplus.Class("FuDaiProtocols")
local def = FuDaiProtocols.define
def.static().RegisterEvents = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckybag.SOpenLuckyBagSuccess", FuDaiProtocols.OnSOpenLuckyBagSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckybag.SOpenLuckyBagFailed", FuDaiProtocols.OnSOpenLuckyBagFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckybag.SBrocastLuckyBagItem", FuDaiProtocols.OnSBrocastLuckyBagItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckybag.SOpenMultipleLuckyBagSuccess", FuDaiProtocols.OnSOpenMultipleLuckyBagSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckybag.SyncExchangeScore", FuDaiProtocols.OnSyncExchangeScore)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckybag.SExchangeScoreSuccess", FuDaiProtocols.OnSExchangeScoreSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckybag.SExchangeScoreFailed", FuDaiProtocols.OnSExchangeScoreFailed)
end
def.static("number", "number", "userdata", "userdata").SendCOpenLuckyBag = function(instanceId, useYuanbao, haveNum, needNum)
  warn("[FuDaiProtocols:SendCOpenLuckyBag] Send COpenLuckyBag.")
  local fudaiType = FuDaiProtocols._GetFudaiTypeByInst(instanceId)
  JiuZhouFuDaiMgr.Instance():SetLastFudaiType(fudaiType)
  local p = require("netio.protocol.mzm.gsp.luckybag.COpenLuckyBag").new(instanceId, useYuanbao, haveNum, needNum)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSOpenLuckyBagSuccess = function(p)
  warn("[FuDaiProtocols:OnSOpenLuckyBagSuccess] On SOpenLuckyBagSuccess, p.instanceid:", p.instanceid)
  JiuZhouFudaiPanel.OnSOpenLuckyBagSuccess(p)
  FuDaiProtocols._ShowGetCreditTip(p.instanceid, JiuZhouFuDaiMgr.DrawType.SINGLE)
end
def.static("table").OnSOpenLuckyBagFailed = function(p)
  warn("[FuDaiProtocols:OnSOpenLuckyBagFailed] On SOpenLuckyBagFailed, p.instanceid:", p.instanceid)
  JiuZhouFudaiPanel.OnSOpenLuckyBagFailed(p)
  FudaiAwardPanel.OnSOpenLuckyBagFailed(p)
  local text = textRes.JiuZhouFuDai.SOpenLuckyBagFailed[p.retcode]
  if text then
    local SOpenLuckyBagFailed = require("netio.protocol.mzm.gsp.luckybag.SOpenLuckyBagFailed")
    if p.retcode == SOpenLuckyBagFailed.ERROR_LUCKY_BAG_NOT_EXIST or p.retcode == SOpenLuckyBagFailed.ERROR_BAG_FULL then
      if constant.CLuckyBagCfgConsts.BOX_MAP_ITEM_HANDLER_TYPE == FuDaiProtocols._GetHandlerTypeByInst(p.instanceid) then
        text = string.format(text, textRes.JiuZhouFuDai[9])
      else
        text = string.format(text, textRes.JiuZhouFuDai[8])
      end
    end
    Toast(text)
  else
    warn(string.format("[FuDaiProtocols:OnSOpenLuckyBagFailed] not handle retcode=%d", p.retcode))
  end
end
def.static("table").OnSBrocastLuckyBagItem = function(p)
  warn("[FuDaiProtocols:OnSBrocastLuckyBagItem] On SBrocastLuckyBagItem.")
  local Octets = require("netio.Octets")
  local ItemUtils = require("Main.Item.ItemUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  local RareItemAnnouncementTip = require("GUI.RareItemAnnouncementTip")
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local awardStr = ""
  local mapItemCfg = require("Main.Map.MapItemModule").GetMapItemInfo(p.map_item_cfgid)
  if mapItemCfg and mapItemCfg.handlerType == constant.CLuckyBagCfgConsts.BOX_MAP_ITEM_HANDLER_TYPE then
    awardStr = textRes.AnnounceMent[90]
  else
    awardStr = textRes.AnnounceMent[87]
  end
  local octets = Octets.new(p.role_name)
  for k, v in pairs(p.items) do
    local itemId = k
    local itemNum = v
    local itemBase = ItemUtils.GetItemBase(itemId)
    local color = HtmlHelper.NameColor[itemBase.namecolor]
    local str = string.format(awardStr, octets:toString(), color, itemBase.name, itemNum)
    if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
      RareItemAnnouncementTip.AnnounceRareItem(str)
    else
      AnnouncementTip.Announce(str)
    end
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  end
end
def.static("number", "number", "userdata", "userdata").SendCOpenMultipleLuckyBag = function(instanceId, useYuanbao, haveNum, needNum)
  warn("[FuDaiProtocols:SendCOpenMultipleLuckyBag] Send COpenMultipleLuckyBag.")
  local fudaiType = FuDaiProtocols._GetFudaiTypeByInst(instanceId)
  JiuZhouFuDaiMgr.Instance():SetLastFudaiType(fudaiType)
  local p = require("netio.protocol.mzm.gsp.luckybag.COpenMultipleLuckyBag").new(instanceId, useYuanbao, haveNum, needNum)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSOpenMultipleLuckyBagSuccess = function(p)
  warn("[FuDaiProtocols:OnSOpenMultipleLuckyBagSuccess] On SOpenMultipleLuckyBagSuccess, p.instanceid:", p.instanceid)
  JiuZhouFudaiPanel.OnSOpenMultipleLuckyBagSuccess(p)
  local fudaiType = JiuZhouFuDaiMgr.Instance():GetLastFudaiType()
  FudaiAwardPanel.Instance():ShowPanel(fudaiType, p.award_items, p.use_yuanbao)
  FuDaiProtocols._ShowGetCreditTip(p.instanceid, JiuZhouFuDaiMgr.DrawType.TEN)
end
def.static("number", "number", "number").SendCExchangeScore = function(cfgId, currentScore, num)
  warn("[FuDaiProtocols:SendCExchangeScore] Send CExchangeScore, cfgId, currentScore, num:", cfgId, currentScore, num)
  local p = require("netio.protocol.mzm.gsp.luckybag.CExchangeScore").new(cfgId, currentScore, num)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSyncExchangeScore = function(p)
  warn("[FuDaiProtocols:OnSyncExchangeScore] score:", p.score)
  FuDaiData.Instance():OnSyncCredit(p.score)
end
def.static("table").OnSExchangeScoreSuccess = function(p)
  warn("[FuDaiProtocols:OnSExchangeScoreSuccess] score:", p.score, p.num)
  FuDaiData.Instance():OnSyncCredit(p.score)
end
def.static("table").OnSExchangeScoreFailed = function(p)
  warn("[FuDaiProtocols:OnSExchangeScoreFailed] p.retcode:", p.retcode)
  local SExchangeScoreFailed = require("netio.protocol.mzm.gsp.luckybag.SExchangeScoreFailed")
  if p.retcode == SExchangeScoreFailed.ERROR_SCORE_NOT_ENOUGH then
    Toast(textRes.JiuZhouFuDai.FuYuanExchange.ERROR_SCORE_NOT_ENOUGH)
  elseif p.retcode == SExchangeScoreFailed.ERROR_BAG_FULL then
    Toast(textRes.JiuZhouFuDai.FuYuanExchange.ERROR_BAG_FULL)
  elseif p.retcode == SExchangeScoreFailed.ERROR_CAN_NOT_JOIN_ACTIVITY then
    Toast(textRes.JiuZhouFuDai.FuYuanExchange.ERROR_CAN_NOT_JOIN_ACTIVITY)
  elseif p.retcode == SExchangeScoreFailed.ERROR_BAG_NOT_ENOUGH then
    Toast(textRes.JiuZhouFuDai.FuYuanExchange.ERROR_BAG_NOT_ENOUGH)
  end
end
def.static("table").OnSMapCommonResult = function(p)
  local SMapCommonResult = require("netio.protocol.mzm.gsp.map.SMapCommonResult")
  if p.result == SMapCommonResult.MAPITEM_ALREADY_GATHERED then
    local text = textRes.JiuZhouFuDai.SOpenLuckyBagFailed[-3]
    if LuckyBagType.BOX == JiuZhouFudaiPanel.Instance():GetCurFudaiType() then
      text = string.format(text, textRes.JiuZhouFuDai[9])
    else
      text = string.format(text, textRes.JiuZhouFuDai[8])
    end
    Toast(text)
    JiuZhouFudaiPanel.Instance():DestroyPanel()
  end
end
def.static("number", "number")._ShowGetCreditTip = function(instanceId, drawType)
  if constant.CLuckyBagCfgConsts.BOX_MAP_ITEM_HANDLER_TYPE == FuDaiProtocols._GetHandlerTypeByInst(instanceId) then
    local credit = 0
    local fudaiCfg = FuDaiData.Instance():GetFuDaiCfgByType(LuckyBagType.BOX)
    if fudaiCfg then
      credit = fudaiCfg.fuyuanAward
    else
      warn("[FuDaiProtocols:_ShowGetCreditTip] fudaiCfg nil for LuckyBagType.BOX.")
    end
    if drawType == JiuZhouFuDaiMgr.DrawType.TEN then
      credit = credit * 10
    end
    if credit > 0 then
      Toast(string.format(textRes.JiuZhouFuDai.FuYuanExchange.GET_FUYUAN_CREDIT, credit))
    end
  else
  end
end
def.static("number", "=>", "number")._GetHandlerTypeByInst = function(instanceId)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local theItem = pubroleModule:GetMapItem(instanceId)
  local itemBase = theItem and theItem.m_cfgInfo or nil
  return itemBase and itemBase.handlerType or 0
end
def.static("number", "=>", "number")._GetFudaiTypeByInst = function(instanceId)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local theItem = pubroleModule:GetMapItem(instanceId)
  local itemBase = theItem and theItem.m_cfgInfo or nil
  local handlerType = itemBase and itemBase.handlerType or 0
  local fudaiType = 0
  if handlerType == constant.CLuckyBagCfgConsts.BOX_MAP_ITEM_HANDLER_TYPE then
    fudaiType = LuckyBagType.BOX
  elseif handlerType == constant.CLuckyBagCfgConsts.JADE_MAP_ITEM_HANDLER_TYPE then
    fudaiType = LuckyBagType.JADE
  elseif handlerType == constant.CLuckyBagCfgConsts.BRASS_MAP_ITEM_HANDLER_TYPE then
    fudaiType = LuckyBagType.BRASS
  end
  return fudaiType
end
FuDaiProtocols.Commit()
return FuDaiProtocols
