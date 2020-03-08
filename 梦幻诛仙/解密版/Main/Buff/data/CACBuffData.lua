local Lplus = require("Lplus")
local CustomBuffData = require("Main.Buff.data.CustomBuffData")
local CACBuffData = Lplus.Extend(CustomBuffData, "CACBuffData")
local BuffMgr = Lplus.ForwardDeclare("BuffMgr")
local def = CACBuffData.define
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
def.final("=>", CACBuffData).New = function()
  local obj = CACBuffData()
  obj:OnInit()
  return obj
end
def.method().OnInit = function(self)
  self.id = BuffMgr.CAC_BUFF_ID
  self.canDelete = true
  local cardCfgId = TurnedCardInterface.Instance():getCurTurnedCardId()
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardCfgId)
  if cardCfg then
    self.name = textRes.TurnedCard[104]:format(cardCfg.cardName)
    self.icon = cardCfg.iconId
  end
end
def.override("=>", "string").GetDescription = function(self)
  local turnedCardInterface = TurnedCardInterface.Instance()
  local cardCfgId = turnedCardInterface:getCurTurnedCardId()
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardCfgId)
  if cardCfg == nil then
    return "?"
  end
  local classType = cardCfg.classType
  local cardClassCfg = TurnedCardUtils.GetCardClassCfg(classType)
  if cardClassCfg == nil then
    return "??"
  end
  local leftFightCount = turnedCardInterface:getCurTurnedCardLeftFightCount()
  local endTime = turnedCardInterface:getCurTurnedCardEndTime() / 1000
  local curTime = _G.GetServerTime()
  local leftSeconds = math.max(0, (endTime - curTime):ToNumber())
  local leftTimeText = _G.SeondsToTimeText(leftSeconds)
  local descTable = {}
  table.insert(descTable, textRes.TurnedCard[107]:format(cardClassCfg.className))
  table.insert(descTable, textRes.TurnedCard[108]:format(leftTimeText))
  table.insert(descTable, textRes.TurnedCard[109]:format(leftFightCount))
  local properties = turnedCardInterface:getCurTurnedCardProperties()
  local propertiesTextTable = {}
  for i, prop in ipairs(properties) do
    local propertyCfg = _G.GetCommonPropNameCfg(prop.propType)
    if propertyCfg and prop.value ~= 0 then
      local valueText = _G.PropValueToText(prop.value, propertyCfg.valueType)
      if 0 < prop.value then
        valueText = textRes.TurnedCard[110]:format(valueText)
      elseif 0 > prop.value then
        valueText = textRes.TurnedCard[111]:format(valueText)
      end
      local propText = string.format(textRes.Common[32], propertyCfg.propName, valueText)
      table.insert(propertiesTextTable, propText)
    end
  end
  local propertiesText = table.concat(propertiesTextTable, textRes.Common.comma)
  if propertiesText ~= "" then
    table.insert(descTable, propertiesText)
  end
  return table.concat(descTable, "\n")
end
def.override("=>", "boolean").HasCustomAction = function(self)
  return true
end
def.override("=>", "string").GetCustomActionName = function(self)
  local isVisible = TurnedCardInterface.Instance():curCardIsVisible()
  if isVisible then
    return textRes.TurnedCard[105]
  else
    return textRes.TurnedCard[106]
  end
end
def.override().OnCustomAction = function(self)
  local isVisible = TurnedCardInterface.Instance():curCardIsVisible()
  gmodule.moduleMgr:GetModule(ModuleId.TURNED_CARD):reqSetCardVisible(not isVisible)
end
def.override().OnDelete = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local cardCfgId = TurnedCardInterface.Instance():getCurTurnedCardId()
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardCfgId)
  local cardName = cardCfg and cardCfg.cardName or "???"
  local content = textRes.TurnedCard[102]:format(cardName)
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], content, function(s)
    if s == 1 then
      gmodule.moduleMgr:GetModule(ModuleId.TURNED_CARD):reqCancelCard()
    end
  end, nil)
end
def.override("=>", "boolean").NeedTickDescription = function(self)
  return true
end
return CACBuffData.Commit()
