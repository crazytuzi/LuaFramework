local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TurnedCardModule = Lplus.Extend(ModuleBase, "TurnedCardModule")
local TurnedCard = require("Main.TurnedCard.TurnedCard")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local turnedCardInterface = TurnedCardInterface.Instance()
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local instance
local def = TurnedCardModule.define
def.static("=>", TurnedCardModule).Instance = function()
  if instance == nil then
    instance = TurnedCardModule()
    instance.m_moduleId = ModuleId.TURNED_CARD
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SSynCardInfo", TurnedCardModule.OnSSynCardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SSynRoleCardInfo", TurnedCardModule.OnSSynRoleCardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SNotifyCardRemove", TurnedCardModule.OnSNotifyCardRemove)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SUnlockCardSuccess", TurnedCardModule.OnSUnlockCardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SUnlockCardFail", TurnedCardModule.OnSUnlockCardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SUseCardSuccess", TurnedCardModule.OnSUseCardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SUseCardFail", TurnedCardModule.OnSUseCardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardDecomposeSuccess", TurnedCardModule.OnSCardDecomposeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardDecomposeFail", TurnedCardModule.OnSCardDecomposeFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardItemDecomposeSuccess", TurnedCardModule.OnSCardItemDecomposeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardItemDecomposeFail", TurnedCardModule.OnSCardItemDecomposeFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardUpgradeWithCardSuccess", TurnedCardModule.OnSCardUpgradeWithCardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardUpgradeWithCardFail", TurnedCardModule.OnSCardUpgradeWithCardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardUpgradeWithItemSuccess", TurnedCardModule.OnSCardUpgradeWithItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardUpgradeWithItemFail", TurnedCardModule.OnSCardUpgradeWithItemFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardLotteryDrawSuccess", TurnedCardModule.OnSCardLotteryDrawSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCardLotteryDrawFail", TurnedCardModule.OnSCardLotteryDrawFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SSetCardVisibleSuccess", TurnedCardModule.OnSSetCardVisibleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SSetCardVisibleFail", TurnedCardModule.OnSSetCardVisibleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SSetCardInvisibleSuccess", TurnedCardModule.OnSSetCardInvisibleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SSetCardInvisibleFail", TurnedCardModule.OnSSetCardInvisibleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCancelCardSuccess", TurnedCardModule.OnSCancelCardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SCancelCardFail", TurnedCardModule.OnSCancelCardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SNotifyCardExpireSoon", TurnedCardModule.OnSNotifyCardExpireSoon)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TurnedCardModule.OnLeaveWorld)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  turnedCardInterface:clearData()
end
def.method("number").playEffectAndLottery = function(self, num)
  local scoreNum = require("Main.Item.ItemModule").Instance():GetCredits(TokenType.CHANGE_MODEL_CARD_SCORE) or Int64.new(0)
  local costScore = 0
  if num == 1 then
    costScore = constant.CChangeModelCardConsts.LOTTERY_COST
  else
    costScore = constant.CChangeModelCardConsts.TEN_LOTTERY_COST
  end
  if scoreNum:lt(Int64.new(costScore)) then
    Toast(textRes.TurnedCard[21])
    return
  end
  local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardLotteryDrawReq").new(num)
  gmodule.network.sendProtocol(p)
end
def.method("boolean").reqSetCardVisible = function(self, isVisible)
  local p
  if isVisible then
    p = require("netio.protocol.mzm.gsp.changemodelcard.CSetCardVisibleReq").new()
  else
    p = require("netio.protocol.mzm.gsp.changemodelcard.CSetCardInvisibleReq").new()
  end
  gmodule.network.sendProtocol(p)
end
def.method().reqCancelCard = function(self)
  local p = require("netio.protocol.mzm.gsp.changemodelcard.CCancelCardReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSSynCardInfo = function(p)
  warn("------OnSSynCardInfo----->:", p.current_card_cfg_id)
  for i, v in pairs(p.card_info_map) do
    local card = TurnedCard.New(v)
    turnedCardInterface:addTurnedCard(i, card)
  end
  turnedCardInterface.curTurnedCardId = p.current_card_cfg_id
  turnedCardInterface.curTurnedCardLevel = p.current_card_level
  turnedCardInterface.isVisible = p.visible == 1
  turnedCardInterface.curCardFightCount = p.fight_count
  turnedCardInterface.curCardStartTime = p.start_time
  turnedCardInterface.curCardOverlayCount = p.overlay_count
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Init_Data_Finish, nil)
end
def.static("table").OnSSynRoleCardInfo = function(p)
  warn("------OnSSynRoleCardInfo:", p.current_card_cfg_id, p.current_card_level)
  if p.current_card_cfg_id == 0 then
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(turnedCardInterface.curTurnedCardId)
    if cardCfg then
      Toast(string.format(textRes.TurnedCard[26], cardCfg.cardName))
    end
  end
  turnedCardInterface.curTurnedCardId = p.current_card_cfg_id
  turnedCardInterface.curTurnedCardLevel = p.current_card_level
  turnedCardInterface.curCardFightCount = p.fight_count
  turnedCardInterface.curCardStartTime = p.start_time
  turnedCardInterface.curCardOverlayCount = p.overlay_count
  if p.visible then
    turnedCardInterface.isVisible = p.visible == 1
  end
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Use_Turned_Card_Change, {
    p.current_card_cfg_id
  })
end
def.static("table").OnSNotifyCardRemove = function(p)
  for i, v in ipairs(p.card_ids) do
    turnedCardInterface:removeTurenCard(v)
  end
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Remove_Turned_Card, {
    p.card_ids
  })
end
def.static("table").OnSUnlockCardSuccess = function(p)
  warn("-------OnSUnlockCardSuccess:", p.card_id)
  local card = TurnedCard.New(p.card_info)
  turnedCardInterface:addTurnedCard(p.card_id, card)
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Get_Turned_Card, {
    p.card_id
  })
  Toast(textRes.TurnedCard[27])
end
def.static("table").OnSUnlockCardFail = function(p)
  warn("!!!!!!OnSUnlockCardFail:", p.error_code)
end
def.static("table").OnSUseCardSuccess = function(p)
  warn("-----OnSUseCardSuccess:", p.card_id, p.use_count)
  local card = turnedCardInterface:getTurnedCardById(p.card_id)
  if card then
    card:setCardUseCount(p.use_count)
  end
  local cfgId = p.card_cfg_id
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Use_Success, {
    p.card_id,
    cfgId
  })
end
def.static("table").OnSUseCardFail = function(p)
  warn("!!!!!!!OnSUseCardFail:", p.error_code)
  local str = textRes.TurnedCard.UseCardFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSCardDecomposeSuccess = function(p)
  warn("-----OnSCardDecomposeSuccess:", p.get_score)
  Toast(string.format(textRes.TurnedCard[15], tostring(p.get_score)))
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Decompose_Turned_Card_Success, {
    p.card_id
  })
end
def.static("table").OnSCardDecomposeFail = function(p)
  warn("!!!!!!OnSCardDecomposeFail:", p.error_code)
  local str = textRes.TurnedCard.CardDecomposeFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSCardItemDecomposeSuccess = function(p)
  warn("-----OnSCardItemDecomposeSuccess:", p.get_score)
  Toast(string.format(textRes.TurnedCard[15], tostring(p.get_score)))
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Decompose_Turned_Card_Item_Success, {
    p.card_id
  })
end
def.static("table").OnSCardItemDecomposeFail = function(p)
  warn("!!!!!!!OnSCardItemDecomposeFail:", p.error_code)
  local str = textRes.TurnedCard.CardItemDecomposeFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSCardUpgradeWithCardSuccess = function(p)
  warn("---OnSCardUpgradeWithCardSuccess:", p.main_card_id, p.now_level, p.now_exp)
  TurnedCardModule.setLevelInfo(p.main_card_id, p.now_level, p.now_exp, p.add_exp)
end
def.static("userdata", "number", "number", "number").setLevelInfo = function(id, nowLevel, nowExp, addExp)
  local curCard = turnedCardInterface:getTurnedCardById(id)
  local oldLevel = curCard:getCardLevel()
  curCard:setCardLevel(nowLevel)
  curCard:setExp(nowExp)
  local cfgId = curCard:getCardCfgId()
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
  Toast(string.format(textRes.TurnedCard[20], textRes.TurnedCard.levelColor[nowLevel], cardCfg.cardName, addExp))
  if nowLevel ~= oldLevel then
    Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Level_Change, {oldLevel = oldLevel, nowLevel = nowLevel})
  end
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Exp_Change, {id})
end
def.static("table").OnSCardUpgradeWithCardFail = function(p)
  warn("!!!!!OnSCardUpgradeWithCardFail:", p.error_code)
  local str = textRes.TurnedCard.CardUpgradeWithCardFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSCardUpgradeWithItemSuccess = function(p)
  warn("------OnSCardUpgradeWithItemSuccess:", p.main_card_id)
  TurnedCardModule.setLevelInfo(p.main_card_id, p.now_level, p.now_exp, p.add_exp)
end
def.static("table").OnSCardUpgradeWithItemFail = function(p)
  warn("!!!!!OnSCardUpgradeWithItemFail:", p.error_code)
  local str = textRes.TurnedCard.CardUpgradeWithCardFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSCardLotteryDrawSuccess = function(p)
  local len = #p.new_card_item_infos
  warn("------OnSCardLotteryDrawSuccess:", len)
  local effres = _G.GetEffectRes(constant.CChangeModelCardConsts.LOTTERY_EFFECT_ID)
  if effres then
    require("Fx.GUIFxMan").Instance():Play(effres.path, "lotteryEffect", 0, 0, -1, false)
  else
    warn("!!!!!!!!!invalid effectId:", constant.CChangeModelCardConsts.LOTTERY_EFFECT_ID)
  end
  GameUtil.AddGlobalLateTimer(constant.CChangeModelCardConsts.LOTTERY_ANIMATION_DURATION, true, function()
    if len == 1 then
      local DrawOneTurnedCardPanel = require("Main.TurnedCard.ui.DrawOneTurnedCardPanel")
      DrawOneTurnedCardPanel.Instance():ShowPanel(p.new_card_item_infos[1])
    elseif len == 10 then
      local DrawTenTurnedCardPanel = require("Main.TurnedCard.ui.DrawTenTurnedCardPanel")
      DrawTenTurnedCardPanel.Instance():ShowPanel(p.new_card_item_infos)
    end
  end)
end
def.static("table").OnSCardLotteryDrawFail = function(p)
  warn("!!!!!OnSCardLotteryDrawFail:", p.error_code)
  local str = textRes.TurnedCard.CardLotteryDrawFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSSetCardVisibleSuccess = function(p)
  turnedCardInterface:setCurTurnedCardVisible(true)
  Toast(textRes.TurnedCard[100])
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Use_Turned_Card_Change, {
    turnedCardInterface.curTurnedCardId
  })
end
def.static("table").OnSSetCardVisibleFail = function(p)
  warn("!!!!!OnSSetCardVisibleFail:", p.error_code)
  local str = textRes.TurnedCard.SetCardVisibleFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSSetCardInvisibleSuccess = function(p)
  turnedCardInterface:setCurTurnedCardVisible(false)
  Toast(textRes.TurnedCard[101])
  Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Use_Turned_Card_Change, {
    turnedCardInterface.curTurnedCardId
  })
end
def.static("table").OnSSetCardInvisibleFail = function(p)
  warn("!!!!!OnSSetCardInvisibleFail:", p.error_code)
  local str = textRes.TurnedCard.SetCardInvisibleFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSCancelCardSuccess = function(p)
  turnedCardInterface:setCurTurnedCardVisible(false)
  Toast(textRes.TurnedCard[103])
end
def.static("table").OnSCancelCardFail = function(p)
  warn("!!!!!OnSCancelCardFail:", p.error_code)
  local str = textRes.TurnedCard.SCancelCardFail[p.error_code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSNotifyCardExpireSoon = function(p)
  warn("------OnSNotifyCardExpireSoon:", p.notify_type)
  local str
  if p.notify_type == p.EXPIRE_BY_TIME then
    str = string.format(textRes.TurnedCard[37], constant.CChangeModelCardConsts.EXPIRE_NOTIFY_REMAIN_MINUTES)
  elseif p.notify_type == p.EXPIRE_BY_PVP_COUNT then
    str = string.format(textRes.TurnedCard[36], constant.CChangeModelCardConsts.EXPIRE_NOTIFY_REMAIN_PVP_COUNT)
  end
  if str then
    local callback = function(id)
      if id == 1 then
        if _G.CheckCrossServerAndToast() then
          return
        end
        local HeroPropPanel = require("Main.Hero.ui.HeroPropPanel")
        HeroPropPanel.Instance():OpenPanelToTab(HeroPropPanel.NodeId.TurnedCard)
      end
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", str, callback, {})
  end
end
return TurnedCardModule.Commit()
