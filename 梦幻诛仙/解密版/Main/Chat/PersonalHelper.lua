local Lplus = require("Lplus")
local PersonalHelper = Lplus.Class("PersonalHelper")
local def = PersonalHelper.define
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local block = false
local msgs = {}
def.static("string").SendOut = function(content)
  if block then
    table.insert(msgs, content)
  else
    Toast(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.PERSONAL, HtmlHelper.Style.Personal, {content = content})
  end
end
def.static("boolean").Block = function(isBlock)
  block = isBlock
  if not block then
    for k, v in ipairs(msgs) do
      PersonalHelper.SendOut(v)
    end
    msgs = {}
  end
end
def.const("table").Type = {
  Text = 1,
  ColorText = 2,
  Silver = 3,
  Gold = 4,
  Yuanbao = 5,
  RoleExp = 6,
  PetExpMap = 7,
  ItemMap = 8,
  XiuLianExp = 9,
  Gang = 10,
  Xiayi = 11,
  Shimen = 12,
  JJC = 13,
  Shengwang = 14,
  StorageExp = 15,
  OfflineExp = 16,
  JinDing = 17,
  Merit = 18,
  TurnedCardEssence = 19,
  TurnedCardScore = 20,
  PET_MARK_SCORE1 = 21,
  PET_MARK_SCORE2 = 22
}
function PersonalHelper.ToString(...)
  local strTable = {}
  local offset = 0
  for i = 1, select("#", ...) do
    local j = i + offset
    if j > select("#", ...) then
      break
    end
    local type = select(j, ...)
    if type == PersonalHelper.Type.Text then
      local text = select(j + 1, ...)
      table.insert(strTable, text)
      j = j + 1
    elseif type == PersonalHelper.Type.ColorText then
      local text = select(j + 1, ...)
      local color = select(j + 2, ...)
      table.insert(strTable, string.format("<font color=#%s>%s</font>", color, text))
      j = j + 2
    elseif type == PersonalHelper.Type.Silver then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Sliver"
      local colorCfg = GetNameColorCfg(701300018)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s>%s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.Gold then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Gold"
      local colorCfg = GetNameColorCfg(701300017)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s>%s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.JinDing then
      local count = select(j + 1, ...)
      local spriteName = "Img_JinDing"
      local colorCfg = GetNameColorCfg(701300017)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s>%s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.Yuanbao then
      local count = select(j + 1, ...)
      local spriteName = "Img_Money"
      local colorCfg = GetNameColorCfg(701300016)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s>&nbsp;%s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.RoleExp then
      local count = select(j + 1, ...)
      local spriteName = "Img_ExpRole"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, count))
      j = j + 1
    elseif type == PersonalHelper.Type.PetExpMap then
      local petExpMap = select(j + 1, ...)
      local spriteName = "Img_ExpPet"
      local colorCfg = GetNameColorCfg(701300013)
      local petColor = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      colorCfg = GetNameColorCfg(701300020)
      local expColor = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      for k, v in pairs(petExpMap) do
        local pet = require("Main.Pet.Interface").GetPet(k)
        table.insert(strTable, string.format("<font color=%s>%s</font>", petColor, pet.name))
        table.insert(strTable, textRes.PersonalTip[3])
        table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
        table.insert(strTable, string.format("<font color=%s> %d</font>", expColor, v))
      end
      j = j + 1
    elseif type == PersonalHelper.Type.ItemMap then
      local itemMap = select(j + 1, ...)
      local ItemUtils = require("Main.Item.ItemUtils")
      for k, v in pairs(itemMap) do
        local itemBase = ItemUtils.GetItemBase(k)
        table.insert(strTable, string.format("<font color=#%s>%s\195\151%d&nbsp;</font>", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name, v))
      end
      j = j + 1
    elseif type == PersonalHelper.Type.XiuLianExp then
      local count = select(j + 1, ...)
      local spriteName = "Img_XlEXP"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.BAGATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.Gang then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Bang"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.Xiayi then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Xia"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.Shimen then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Shi"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.JJC then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Jing"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.Shengwang then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Wang"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.StorageExp then
      local count = select(j + 1, ...)
      local spriteName = "Icon_ExpChu"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.OfflineExp then
      local count = select(j + 1, ...)
      local spriteName = "Icon_ExpLeave"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, count))
      j = j + 1
    elseif type == PersonalHelper.Type.Merit then
      local count = select(j + 1, ...)
      local spriteName = "Icon_De"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, count))
      j = j + 1
    elseif type == PersonalHelper.Type.TurnedCardEssence then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Xiang"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, textRes.TurnedCard[34] .. tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.TurnedCardScore then
      local count = select(j + 1, ...)
      local spriteName = "Icon_Xiang"
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, textRes.TurnedCard[35] .. tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.PET_MARK_SCORE1 then
      local count = select(j + 1, ...)
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, textRes.Pet.PetMark[34] .. tostring(count)))
      j = j + 1
    elseif type == PersonalHelper.Type.PET_MARK_SCORE2 then
      local count = select(j + 1, ...)
      local colorCfg = GetNameColorCfg(701300020)
      local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
      table.insert(strTable, string.format("<font color=%s> %s</font>", color, textRes.Pet.PetMark[35] .. tostring(count)))
      j = j + 1
    end
    offset = j - i
  end
  return table.concat(strTable)
end
function PersonalHelper.CommonTableMsg(msgs)
  local params = PersonalHelper.DecompCommonTableMsg(msgs)
  local str = PersonalHelper.ToString(unpack(params))
  PersonalHelper.SendOut(str)
end
function PersonalHelper.DecompCommonTableMsg(msgs)
  local params = {}
  for i, t in ipairs(msgs) do
    for ii, v in ipairs(t) do
      table.insert(params, v)
    end
  end
  return params
end
function PersonalHelper.CommonMsg(...)
  local str = PersonalHelper.ToString(...)
  PersonalHelper.SendOut(str)
end
def.static("number", "string").GetMoneyMsgByType = function(moneyType, moneyCount)
  local ItemModule = require("Main.Item.ItemModule")
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  if moneyType == MoneyType.SILVER then
    PersonalHelper.GetMoneyMsg(ItemModule.MONEY_TYPE_SILVER, moneyCount)
  elseif moneyType == MoneyType.GOLD then
    PersonalHelper.GetMoneyMsg(ItemModule.MONEY_TYPE_GOLD, moneyCount)
  elseif moneyType == MoneyType.YUANBAO then
    PersonalHelper.GetYuanbaoMsg(tonumber(moneyCount))
  elseif moneyType == MoneyType.GANGCONTRIBUTE then
    PersonalHelper.GetGangContributionMsg(tonumber(moneyCount))
  end
end
def.static("number", "string").GetMoneyMsg = function(moneyType, moneyCount)
  local ItemModule = require("Main.Item.ItemModule")
  local spriteName = ""
  local color = ""
  if moneyType == ItemModule.MONEY_TYPE_GOLD then
    spriteName = "Icon_Gold"
    local colorCfg = GetNameColorCfg(701300017)
    color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  elseif moneyType == ItemModule.MONEY_TYPE_SILVER then
    spriteName = "Icon_Sliver"
    local colorCfg = GetNameColorCfg(701300018)
    color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  end
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[1])
  table.insert(strTable, textRes.PersonalTip[3])
  table.insert(strTable, "&nbsp;")
  table.insert(strTable, string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, string.format("<font color=%s>&nbsp;%s</font>", color, moneyCount))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("number", "string").UseMoneyMsg = function(moneyType, moneyCount)
  local ItemModule = require("Main.Item.ItemModule")
  local spriteName = ""
  local color = ""
  if moneyType == ItemModule.MONEY_TYPE_GOLD then
    spriteName = "Icon_Gold"
    local colorCfg = GetNameColorCfg(701300017)
    color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  elseif moneyType == ItemModule.MONEY_TYPE_SILVER then
    spriteName = "Icon_Sliver"
    local colorCfg = GetNameColorCfg(701300018)
    color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  end
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[1])
  table.insert(strTable, textRes.PersonalTip[6])
  table.insert(strTable, "&nbsp;")
  table.insert(strTable, string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, string.format("<font color=%s>&nbsp;%s</font>", color, moneyCount))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("string", "string", "string", "string", "number").GetCommerceMoneyMsg = function(str1, str2, num1, str3, num2)
  local ItemModule = require("Main.Item.ItemModule")
  local spriteName = "Icon_Gold"
  local strTable = {}
  table.insert(strTable, str1)
  table.insert(strTable, "&nbsp;&nbsp;")
  table.insert(strTable, string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, str2)
  table.insert(strTable, num1)
  table.insert(strTable, str3)
  table.insert(strTable, num2)
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("number").GetYuanbaoMsg = function(yuanbaoCount)
  local spriteName = "Img_Money"
  local colorCfg = GetNameColorCfg(701300016)
  local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[1])
  table.insert(strTable, textRes.PersonalTip[3])
  table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, string.format("<font color=%s>&nbsp;%d</font>", color, yuanbaoCount))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("number").GetGangContributionMsg = function(gangContribution)
  local spriteName = "Icon_Bang"
  local colorCfg = GetNameColorCfg(701300016)
  local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[1])
  table.insert(strTable, textRes.PersonalTip[3])
  table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, string.format("<font color=%s>&nbsp;%d</font>", color, gangContribution))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("number").GetExpMsg = function(exp)
  local spriteName = "Img_ExpRole"
  local colorCfg = GetNameColorCfg(701300020)
  local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[1])
  table.insert(strTable, textRes.PersonalTip[3])
  table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, string.format("<font color=%s>&nbsp;%d</font>", color, exp))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("string", "number").GetPetExp = function(petName, exp)
  local spriteName = "Img_ExpPet"
  local colorCfg = GetNameColorCfg(701300013)
  local petColor = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  colorCfg = GetNameColorCfg(701300020)
  local expColor = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[2])
  table.insert(strTable, string.format("<font color=#%s>%s</font>", petColor, petName))
  table.insert(strTable, textRes.PersonalTip[3])
  table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, string.format("<font color=%s>&nbsp;%d</font>", expColor, exp))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("number", "number").GetItemMsg = function(itemId, num)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[1])
  table.insert(strTable, textRes.PersonalTip[3])
  table.insert(strTable, string.format("<font color=#%s>&nbsp;%s\195\151%d</font>", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name, num))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("string", "number").PetLevelUp = function(petName, level)
  local colorCfg = GetNameColorCfg(701300013)
  local petColor = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  colorCfg = GetNameColorCfg(701300020)
  local levelColor = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  local levelText = string.format(textRes.Common[3], level)
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[2])
  table.insert(strTable, string.format("<font color=%s>%s</font>", petColor, petName))
  table.insert(strTable, textRes.PersonalTip[4])
  table.insert(strTable, string.format("<font color=%s>&nbsp;%s</font>", levelColor, levelText))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("string", "string", "string").PetPropIncCommon = function(petName, propName, prop)
  local colorCfg = GetNameColorCfg(701300013)
  local petColor = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  local propColor = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  local propText = string.format("+%s", prop)
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[2])
  table.insert(strTable, string.format("<font color=%s>%s</font>", petColor, petName))
  table.insert(strTable, propName)
  table.insert(strTable, string.format("<font color=%s>&nbsp;%s</font>", propColor, propText))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
def.static("string", "string").GetPet = function(petName, color)
  local nameColor = string.format("#%s", color)
  local strTable = {}
  table.insert(strTable, textRes.PersonalTip[5])
  table.insert(strTable, string.format("<font color=%s>%s</font>", nameColor, petName))
  local str = table.concat(strTable)
  PersonalHelper.SendOut(str)
end
PersonalHelper.Commit()
return PersonalHelper
