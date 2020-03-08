local Lplus = require("Lplus")
local TurnedCardInterface = Lplus.Class("TurnedCardInterface")
local def = TurnedCardInterface.define
local TurnedCard = require("Main.TurnedCard.TurnedCard")
local QualityEnum = require("consts.mzm.gsp.changemodelcard.confbean.QualityEnum")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local ItemModule = require("Main.Item.ItemModule")
local instance
def.field("table").cardList = nil
def.field("number").curTurnedCardId = 0
def.field("number").curTurnedCardLevel = 0
def.field("boolean").isVisible = false
def.field("number").curCardFightCount = 0
def.field("userdata").curCardStartTime = nil
def.field("number").curCardOverlayCount = 0
def.const("table").qualityEnum = {
  [QualityEnum.SSS] = "U",
  [QualityEnum.SS] = "T",
  [QualityEnum.S] = "S",
  [QualityEnum.A] = "A",
  [QualityEnum.B] = "B",
  [QualityEnum.C] = "C",
  [QualityEnum.D] = "D"
}
def.static("=>", TurnedCardInterface).Instance = function()
  if instance == nil then
    instance = TurnedCardInterface()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().clearData = function(self)
  self.cardList = nil
  self.curTurnedCardId = 0
  self.curTurnedCardLevel = 0
  self.isVisible = false
  self.curCardFightCount = 0
  self.curCardStartTime = nil
  self.curCardOverlayCount = 0
end
def.method("userdata", TurnedCard).addTurnedCard = function(self, uuid, card)
  card:setUUID(uuid)
  self.cardList = self.cardList or {}
  self.cardList[tostring(uuid)] = card
end
def.method("userdata").removeTurenCard = function(self, uuid)
  if self.cardList then
    self.cardList[tostring(uuid)] = nil
  end
end
def.method("userdata", "=>", TurnedCard).getTurnedCardById = function(self, cardId)
  if self.cardList then
    return self.cardList[tostring(cardId)]
  end
  return nil
end
def.method("number").setCurTurnedCardId = function(self, id)
  self.curTurnedCardId = id
end
def.method("=>", "number").getCurTurnedCardId = function(self)
  return self.curTurnedCardId
end
def.method("=>", "number").getCurTurnedCardLevel = function(self)
  return self.curTurnedCardLevel
end
def.method("boolean").setCurTurnedCardVisible = function(self, isVisible)
  self.isVisible = isVisible
end
def.method("=>", "boolean").curCardIsVisible = function(self)
  return self.isVisible
end
def.method("number").setCurTurnedCardFightCount = function(self, count)
  self.curCardFightCount = count
end
def.method("=>", "number").getCurTurnedCardFightCount = function(self)
  return self.curCardFightCount
end
def.method("=>", "number").getCurTurnedCardLeftFightCount = function(self)
  if self.curTurnedCardId == 0 then
    return 0
  end
  local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(self.curTurnedCardId)
  if cardLevelCfg == nil then
    return 0
  end
  local level = self.curTurnedCardLevel
  local levelCfg = cardLevelCfg.cardLevels[level]
  if levelCfg == nil then
    Debug.LogError(string.format("No cardLevelCfg for cardId=%d, level=%d", self.curTurnedCardId, level))
    return 0
  end
  local count = self.curCardOverlayCount * levelCfg.effectPersistPVPFight - self.curCardFightCount
  return math.max(0, count)
end
def.method("userdata").setCurTurnedCardStartTime = function(self, time)
  self.curCardStartTime = time
end
def.method("=>", "userdata").getCurTurnedCardEndTime = function(self)
  if self.curTurnedCardId == 0 then
    return Zero_Int64
  end
  local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(self.curTurnedCardId)
  if cardLevelCfg == nil then
    return Zero_Int64
  end
  local level = self.curTurnedCardLevel
  local levelCfg = cardLevelCfg.cardLevels[level]
  if levelCfg == nil then
    Debug.LogError(string.format("No cardLevelCfg for cardId=%d, level=%d", self.curTurnedCardId, level))
    return 0
  end
  local durationSeconds = levelCfg.effectPersistMinute * 60 * self.curCardOverlayCount
  local endTime = self.curCardStartTime + durationSeconds * 1000
  return endTime
end
def.method("number").setCurTurnedCardOverlayCount = function(self, num)
  self.curCardOverlayCount = num
end
def.method("=>", "number").getCurTurnedCardOverlayCount = function(self)
  return self.curCardOverlayCount
end
def.method("number", "=>", "table").getTurnedCardList = function(self, class)
  local list = {}
  if self.cardList then
    for i, v in pairs(self.cardList) do
      local info = v:getCardInfo()
      if info then
        local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(info.card_cfg_id)
        if class == 0 or cardCfg.classType == class then
          table.insert(list, v)
        end
      end
    end
    local comp = function(card1, card2)
      local level1 = card1:getCardLevel()
      local level2 = card2:getCardLevel()
      if level1 == level2 then
        local cfgId1 = card1:getCardCfgId()
        local cfgId2 = card2:getCardCfgId()
        return cfgId1 < cfgId2
      else
        return level1 > level2
      end
    end
    table.sort(list, comp)
  end
  return list
end
def.method("=>", "table").getAllTurnedCards = function(self)
  return self.cardList
end
def.method("number", "=>", "string").getTurnedCardQualityStr = function(self, quality)
  return TurnedCardInterface.qualityEnum[quality]
end
def.method("=>", "boolean").isOpenTurnedCard = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    return false
  end
  return _G.GetHeroProp().level >= constant.CChangeModelCardConsts.OPEN_LEVEL
end
def.method("=>", "boolean").isShowTurnedCardBagRedPoint = function(self)
  local turnedCardItemNewMap = ItemModule.Instance()._newTurnedCardItemMap
  if turnedCardItemNewMap then
    for i, v in pairs(turnedCardItemNewMap) do
      if v then
        return true
      end
    end
  end
  return false
end
def.method("=>", "boolean").isShowTurnedCardRedPoint = function(self)
  if not self:isOpenTurnedCard() then
    return false
  end
  return self:isShowTurnedCardBagRedPoint()
end
def.method("number", "=>", "boolean").isOwnTurnedCardById = function(self, cfgId)
  if self.cardList then
    for i, v in pairs(self.cardList) do
      if v:getCardCfgId() == cfgId then
        return true
      end
    end
  end
  return false
end
def.method("number", "number", "=>", "table").GetOwndCardByCfgIdAndLv = function(self, cfgId, lv)
  if self.cardList then
    for i, v in pairs(self.cardList) do
      if v:getCardCfgId() == cfgId and v:getCardLevel() == lv then
        return v
      end
    end
  end
  return nil
end
def.method("=>", "table").getCurTurnedCardProperties = function(self)
  if self.curTurnedCardId == 0 then
    return {}
  end
  local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(self.curTurnedCardId)
  if cardLevelCfg == nil then
    return {}
  end
  local level = self.curTurnedCardLevel
  local levelCfg = cardLevelCfg.cardLevels[level]
  if levelCfg == nil then
    Debug.LogError(string.format("No cardLevelCfg for cardId=%d, level=%d", self.curTurnedCardId, level))
    return {}
  end
  return levelCfg.propertys
end
return TurnedCardInterface.Commit()
