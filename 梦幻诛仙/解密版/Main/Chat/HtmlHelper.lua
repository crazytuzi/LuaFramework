local Lplus = require("Lplus")
local HtmlHelper = Lplus.Class("HtmlHelper")
local def = HtmlHelper.define
local ChatUtils = require("Main.Chat.ChatUtils")
local SpeechMgr = require("Main.Chat.SpeechMgr")
local BadgeModule = require("Main.Badge.BadgeModule")
local PetUtility = require("Main.Pet.PetUtility")
local ItemUtils = require("Main.Item.ItemUtils")
local ChannelType = require("consts.mzm.gsp.chat.confbean.ChannelType")
local AtUtils = require("Main.Chat.At.AtUtils")
local roleNameColor, trumpetRoleNameColor, fontColor, helpColor, petColor, taskColor, friendColor, popColor, wqMiniTitleColor, wqMiniQuestionColor, wqBigTitleColor, wqBigQuestionColor, wqAnnounceColor
local channelcfg = {}
def.const("table").NameColor = {
  [1] = "ffffff",
  [2] = "01b35b",
  [3] = "009fd6",
  [4] = "ea01fd",
  [5] = "fe7200"
}
def.static().LoadCfg = function()
  local roleNameColorR = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "roleNameColorR"):GetIntValue("value")
  local roleNameColorG = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "roleNameColorG"):GetIntValue("value")
  local roleNameColorB = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "roleNameColorB"):GetIntValue("value")
  local fontColorR = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "chatCommonFontColorR"):GetIntValue("value")
  local fontColorG = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "chatCommonFontColorG"):GetIntValue("value")
  local fontColorB = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "chatCommonFontColorB"):GetIntValue("value")
  local helpColorR = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "helpHintFontColorR"):GetIntValue("value")
  local helpColorG = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "helpHintFontColorG"):GetIntValue("value")
  local helpColorB = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "helpHintFontColorB"):GetIntValue("value")
  local petColorR = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "petFontColorR"):GetIntValue("value")
  local petColorG = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "petFontColorG"):GetIntValue("value")
  local petColorB = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "petFontColorB"):GetIntValue("value")
  local taskColorR = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "taskFontColorR"):GetIntValue("value")
  local taskColorG = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "taskFontColorG"):GetIntValue("value")
  local taskColorB = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "taskFontColorB"):GetIntValue("value")
  local friendColorR = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "friendPrivatechatFontColorR"):GetIntValue("value")
  local friendColorG = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "friendPrivatechatFontColorG"):GetIntValue("value")
  local friendColorB = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "friendPrivatechatFontColorB"):GetIntValue("value")
  local popColorR = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "chatBubbleFontColorR"):GetIntValue("value")
  local popColorG = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "chatBubbleFontColorG"):GetIntValue("value")
  local popColorB = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "chatBubbleFontColorB"):GetIntValue("value")
  local wqMiniTitleColorRecord = DynamicData.GetRecord(CFG_PATH.DATA_FONTANDCOLORTABLE_CFG, constant.WorldQuestionConsts.MINI_TILE_COLOR_CFG)
  local wqMiniTitleColorR = wqMiniTitleColorRecord:GetIntValue("R")
  local wqMiniTitleColorG = wqMiniTitleColorRecord:GetIntValue("G")
  local wqMiniTitleColorB = wqMiniTitleColorRecord:GetIntValue("B")
  local wqMiniQuestionColorRecord = DynamicData.GetRecord(CFG_PATH.DATA_FONTANDCOLORTABLE_CFG, constant.WorldQuestionConsts.MINI_QUSTION_COLOR_CFG)
  local wqMiniQuestionColorR = wqMiniQuestionColorRecord:GetIntValue("R")
  local wqMiniQuestionColorG = wqMiniQuestionColorRecord:GetIntValue("G")
  local wqMiniQuestionColorB = wqMiniQuestionColorRecord:GetIntValue("B")
  local wqBigTitleColorRecord = DynamicData.GetRecord(CFG_PATH.DATA_FONTANDCOLORTABLE_CFG, constant.WorldQuestionConsts.BIG_TITLE_COLOR_CFG)
  local wqBigTitleColorR = wqBigTitleColorRecord:GetIntValue("R")
  local wqBigTitleColorG = wqBigTitleColorRecord:GetIntValue("G")
  local wqBigTitleColorB = wqBigTitleColorRecord:GetIntValue("B")
  local wqBigQuestionColorRecord = DynamicData.GetRecord(CFG_PATH.DATA_FONTANDCOLORTABLE_CFG, constant.WorldQuestionConsts.BIG_QUESTION_COLOR_CFG)
  local wqBigQuestionColorR = wqBigQuestionColorRecord:GetIntValue("R")
  local wqBigQuestionColorG = wqBigQuestionColorRecord:GetIntValue("G")
  local wqBigQuestionColorB = wqBigQuestionColorRecord:GetIntValue("B")
  local wqAnnounceColorRecord = DynamicData.GetRecord(CFG_PATH.DATA_FONTANDCOLORTABLE_CFG, constant.WorldQuestionConsts.BULLETIN_COLOR_CFG)
  local wqAnnounceColorR = wqAnnounceColorRecord:GetIntValue("R")
  local wqAnnounceColorG = wqAnnounceColorRecord:GetIntValue("G")
  local wqAnnounceColorB = wqAnnounceColorRecord:GetIntValue("B")
  roleNameColor = string.format("#%02x%02x%02x", roleNameColorR, roleNameColorG, roleNameColorB)
  trumpetRoleNameColor = string.format("#%02x%02x%02x", constant.CTrumpetConsts.ROLE_NAME_COLOR_R, constant.CTrumpetConsts.ROLE_NAME_COLOR_G, constant.CTrumpetConsts.ROLE_NAME_COLOR_B)
  fontColor = string.format("#%02x%02x%02x", fontColorR, fontColorG, fontColorB)
  helpColor = string.format("#%02x%02x%02x", helpColorR, helpColorG, helpColorB)
  petColor = string.format("#%02x%02x%02x", petColorR, petColorG, petColorB)
  taskColor = string.format("#%02x%02x%02x", taskColorR, taskColorG, taskColorB)
  friendColor = string.format("#%02x%02x%02x", friendColorR, friendColorG, friendColorB)
  popColor = string.format("#%02x%02x%02x", popColorR, popColorG, popColorB)
  wqMiniTitleColor = string.format("#%02x%02x%02x", wqMiniTitleColorR, wqMiniTitleColorB, wqMiniTitleColorB)
  wqMiniQuestionColor = string.format("#%02x%02x%02x", wqMiniQuestionColorR, wqMiniQuestionColorG, wqMiniQuestionColorB)
  wqBigTitleColor = string.format("#%02x%02x%02x", wqBigTitleColorR, wqBigTitleColorG, wqBigTitleColorB)
  wqBigQuestionColor = string.format("#%02x%02x%02x", wqBigQuestionColorR, wqBigQuestionColorG, wqBigQuestionColorB)
  wqAnnounceColor = string.format("#%02x%02x%02x", wqAnnounceColorR, wqAnnounceColorG, wqAnnounceColorB)
  for k, v in pairs(ChannelType) do
    local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANEL_CFG, v)
    if record then
      local r = record:GetIntValue("R")
      local g = record:GetIntValue("G")
      local b = record:GetIntValue("B")
      local iconId = record:GetIntValue("iconId")
      channelcfg[v] = {
        color = string.format("#%02x%02x%02x", r, g, b),
        icon = "Channel_" .. iconId
      }
    end
  end
end
def.static("table", "=>", "string").ConvertMainChat = function(msg)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<img src='%s:Channel_%d' width=52 height=22>", RESPATH.COMMONATLAS, msg.id))
  if ChannelType.CHANNEL_TRUMPRT == msg.id then
    table.insert(strTable, string.format("<img src='%s:%s' width=28 height=24>", RESPATH.COMMONATLAS, constant.CTrumpetConsts.TRUMPET_ICON_NAME))
  end
  for i = 1, 2 do
    local badgeId = msg.badge[i]
    if badgeId then
      local sprite = BadgeModule.Instance():GetBadgeInfo(badgeId).spriteName
      table.insert(strTable, string.format("<img src='%s:%s' width=28 height=24>", RESPATH.BADGE_ATLAS, sprite))
    else
      break
    end
  end
  if ChannelType.CHANNEL_TRUMPRT == msg.id then
    table.insert(strTable, string.format("<a href='role' id=role_%d_%s><font color=%s>[%s]:&nbsp;</font></a>", msg.id, tostring(msg.roleId), trumpetRoleNameColor, msg.roleName))
  else
    table.insert(strTable, string.format("<a href='role' id=role_%d_%s><font color=%s>[%s]:&nbsp;</font></a>", msg.id, tostring(msg.roleId), roleNameColor, msg.roleName))
  end
  if ChannelType.CHANNEL_TRUMPRT == msg.id then
    local TrumpetMgr = require("Main.Chat.Trumpet.TrumpetMgr")
    local trumpetCfg = TrumpetMgr.Instance():GetTrumpetCfgById(msg.trumpetId)
    local color = channelcfg[msg.id].color
    if trumpetCfg then
      color = string.format("#%02x%02x%02x", trumpetCfg.contentColorR, trumpetCfg.contentColorG, trumpetCfg.contentColorB)
    else
      warn("[ERROR][HtmlHelper:ConvertMainChat] trumpetCfg nil for id:", msg.trumpetId)
    end
    table.insert(strTable, string.format("<font color=%s>%s</font>", color, msg.content))
    table.insert(strTable, "</font></p>")
  else
    table.insert(strTable, string.format("<font color=%s>%s</font>", channelcfg[msg.id].color, msg.content))
    table.insert(strTable, "</font></p>")
  end
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertPlainChat = function(msg)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<font color=%s>%s</font>", fontColor, msg.content))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertTrumpetPreviewChat = function(msg)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  local TrumpetMgr = require("Main.Chat.Trumpet.TrumpetMgr")
  local trumpetCfg = TrumpetMgr.Instance():GetTrumpetCfgById(msg.trumpetId)
  local color = channelcfg[msg.id].color
  if trumpetCfg then
    color = string.format("#%02x%02x%02x", trumpetCfg.contentColorR, trumpetCfg.contentColorG, trumpetCfg.contentColorB)
  else
    warn("[ERROR][HtmlHelper:ConvertTrumpetPreviewChat] trumpetCfg nil for id:", msg.trumpetId)
  end
  table.insert(strTable, string.format("<font color=%s>%s</font>", color, msg.content))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertChatRedGiftMainChat = function(msg)
  local strTable = {}
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  local channelSubType = 0
  if msg.type == ChatMsgData.MsgType.CHANNEL then
    channelSubType = msg.id
    table.insert(strTable, string.format("<img src='%s:Channel_%d' width=52 height=22>", RESPATH.COMMONATLAS, msg.id))
    for i = 1, 2 do
      local badgeId = msg.badge[i]
      if badgeId then
        local sprite = BadgeModule.Instance():GetBadgeInfo(badgeId).spriteName
        table.insert(strTable, string.format("<img src='%s:%s' width=28 height=24>", RESPATH.BADGE_ATLAS, sprite))
      else
        break
      end
    end
    table.insert(strTable, string.format("<a href='role' id=role_%d_%s><font color=%s>[%s]:&nbsp;</font></a>", msg.id, tostring(msg.roleId), roleNameColor, msg.roleName))
    table.insert(strTable, string.format("<font color=%s>%s</font>", channelcfg[msg.id].color, textRes.ChatRedGift[8]))
  elseif msg.type == ChatMsgData.MsgType.GROUP then
    channelSubType = ChatMsgData.Channel.GROUP
    table.insert(strTable, string.format("<font color=%s>%s</font>", fontColor, textRes.ChatRedGift[8]))
  end
  local btnname = string.format("ChatRedGift_%s_%d_%d", tostring(msg.redGiftId), msg.type, channelSubType)
  local button = string.format("<a href='%s' id=%s><font color=#ffe400><u>%s</u></font></a>", btnname, btnname, textRes.ChatRedGift[19])
  table.insert(strTable, button)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertChatRedGiftPlainChat = function(msg)
  local strTable = {}
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local channelSubType = 0
  if msg.type == ChatMsgData.MsgType.CHANNEL then
    channelSubType = msg.id
  elseif msg.type == ChatMsgData.MsgType.GROUP then
    channelSubType = ChatMsgData.Channel.GROUP
  end
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<font color=%s>%s</font>", fontColor, msg.content))
  local btnname = string.format("ChatRedGift_%s_%d_%d", tostring(msg.redGiftId), msg.type, channelSubType)
  local button = string.format("<a href='%s' id=%s><font color=#ffe400>%s</font></a>", btnname, btnname, textRes.ChatRedGift[18])
  table.insert(strTable, button)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertWorldQuestionMainChat = function(msg)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<img src='%s:Channel_%d' width=52 height=22>", RESPATH.COMMONATLAS, msg.id))
  table.insert(strTable, string.format("<font color=%s>%s</font><br><img width=52 height=22>", wqMiniTitleColor, msg.mainChatTips))
  table.insert(strTable, string.format("<font color=%s>%s</font>", wqMiniQuestionColor, msg.questionContent))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertWorldQuestionPlainChat = function(msg)
  msg.roleName = string.format("[%s]%s[-]", string.sub(wqBigTitleColor, 2), msg.roleName)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<font color=%s>%s</font>", wqBigQuestionColor, msg.questionContent))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "table").ConvertWorldQuestionSystemMsg = function(msg)
  local content = {}
  content.text = string.format("%s<br><img width=52 height=22>%s", msg.tips, msg.question)
  return content
end
def.static("table", "=>", "string").ConvertWorldQuestionNoticeMainChat = function(msg)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<img src='%s:Channel_%d' width=52 height=22>", RESPATH.COMMONATLAS, msg.id))
  if msg.mainChatRoleName ~= "" and msg.mainChatRoleName ~= "" then
    table.insert(strTable, string.format("<font color=%s>%s</font>:", wqMiniTitleColor, msg.mainChatRoleName))
  end
  table.insert(strTable, string.format("<font color=%s>%s</font>", wqAnnounceColor, msg.mainChatText))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertWorldQuestionNoticePlainChat = function(msg)
  msg.roleName = string.format("[%s]%s[-]", string.sub(wqBigTitleColor, 2), msg.roleName)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<font color=%s>%s</font>", wqBigQuestionColor, msg.plainChatText))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertYYJsonMain = function(msg)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<img src='%s:Channel_%d' width=52 height=22>", RESPATH.COMMONATLAS, msg.id))
  for i = 1, 2 do
    local badgeId = msg.badge[i]
    if badgeId then
      local sprite = BadgeModule.Instance():GetBadgeInfo(badgeId).spriteName
      table.insert(strTable, string.format("<img src='%s:%s' width=28 height=24>", RESPATH.BADGE_ATLAS, sprite))
    else
      break
    end
  end
  table.insert(strTable, string.format("<a href='role' id=role_%d_%s><font color=%s>[%s]:&nbsp;</font></a>", msg.id, tostring(msg.roleId), roleNameColor, msg.roleName))
  table.insert(strTable, string.format("<font color=%s>", channelcfg[msg.id].color))
  table.insert(strTable, string.format("<gameobj width=100 height=32 prefab='%s' id='voice_%d' boxcollider='true' componentname='NGUIVoiceButtonComponent' param='%s'>%s", RESPATH.PREFAB_HTML_VOICE, msg.unique, tostring(msg.second), msg.text))
  table.insert(strTable, string.format("</font>"))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "boolean", "=>", "string").ConvertYYJsonChat = function(msg, isMe)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<font color=%s>", fontColor))
  table.insert(strTable, string.format("<gameobj width=100 height=32 prefab='%s' id='voice_%d' boxcollider='true' componentname='NGUIVoiceButtonComponent' param='%s'>", RESPATH.PREFAB_HTML_VOICE, msg.unique, tostring(msg.second)))
  table.insert(strTable, string.format("<br/>%s", msg.text))
  table.insert(strTable, string.format("</font>"))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertSystemChat = function(msg)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format("<font color=%s>%s</font>", fontColor, msg.content))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertNotePlainChat = function(msg)
  local strTable = {}
  table.insert(strTable, "<p align=center valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<font color=%s>%s</font>", fontColor, msg.content))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("string", "=>", "string").GenerateRawPlainNote = function(html)
  local strTable = {}
  table.insert(strTable, "<p align=center valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<font color=%s>%s</font>", fontColor, html))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").ConvertNoteMainChat = function(msg)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<img src='%s:Channel_%d' width=52 height=22>", RESPATH.COMMONATLAS, msg.id))
  table.insert(strTable, string.format("<font color=%s>%s</font>", "#ffffff", msg.content))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.const("table").Style = {
  GM = 0,
  QiLing = 1,
  Help = 2,
  Personal = 3,
  TuXiWin = 4,
  TuXiLost = 5,
  CreateGang = 6,
  Tuxi = 7,
  ShengXiao = 8,
  BaoTu = 9,
  System = 10,
  BaoTuItem = 11,
  RoleRename = 12,
  Lottery = 13,
  JingJiLianSheng = 14,
  JingJiChuanShuo = 15,
  JiuXiaoWillClose = 16,
  Flower = 17,
  YaoShouShengXing = 18,
  ExchangeShenShou = 19,
  WorldBossRank = 20,
  WorldBossDamage = 21,
  WorldBossEnd = 22,
  KejuDianShiStart = 23,
  KejuTop = 24,
  Fight = 25,
  TuXiWinMaxStar = 26,
  PetComprehendSkill = 27,
  PetSkillLevelUp = 28,
  PhancaveGetAwardItem = 29,
  WorldGoalComplete = 30,
  FestivalCountDown = 31,
  Common = 1000
}
def.static("number", "table", "=>", "string").ConvertSystemMsg = function(style, content)
  local msgStr
  if style == HtmlHelper.Style.QiLing then
    msgStr = HtmlHelper.GenerateQiLinHtml(content)
  elseif style == HtmlHelper.Style.TuXiWin then
    msgStr = HtmlHelper.GenerateTuXiWinHtml(content)
  elseif style == HtmlHelper.Style.TuXiLost then
    msgStr = HtmlHelper.GenerateTuXiLostHtml(content)
  elseif style == HtmlHelper.Style.GM then
    msgStr = HtmlHelper.GenerateGMHtml(content)
  elseif style == HtmlHelper.Style.Help then
    msgStr = HtmlHelper.GenerateHelpHtml(content)
  elseif style == HtmlHelper.Style.Personal then
    msgStr = HtmlHelper.GeneratePersonalHtml(content)
  elseif style == HtmlHelper.Style.CreateGang then
    msgStr = HtmlHelper.GenerateGangHtml(content)
  elseif style == HtmlHelper.Style.Tuxi then
    msgStr = HtmlHelper.GenTuxiHtml(content)
  elseif style == HtmlHelper.Style.ShengXiao then
    msgStr = HtmlHelper.GenShengXiaoHtml(content)
  elseif style == HtmlHelper.Style.BaoTu then
    msgStr = HtmlHelper.GenBaoTuHtml(content)
  elseif style == HtmlHelper.Style.System then
    msgStr = HtmlHelper.GenSystemHtml(content)
  elseif style == HtmlHelper.Style.BaoTuItem then
    msgStr = HtmlHelper.GenBaoTuItemHtml(content)
  elseif style == HtmlHelper.Style.RoleRename then
    msgStr = HtmlHelper.GenerateRoleRenameHtml(content)
  elseif style == HtmlHelper.Style.Lottery then
    msgStr = HtmlHelper.GenerateLotteryHtml(content)
  elseif style == HtmlHelper.Style.JingJiLianSheng then
    msgStr = HtmlHelper.GenerateLianShengHtml(content)
  elseif style == HtmlHelper.Style.JingJiChuanShuo then
    msgStr = HtmlHelper.GenerateChuanShuoHtml(content)
  elseif style == HtmlHelper.Style.JiuXiaoWillClose then
    msgStr = HtmlHelper.GenerateJiuXiaoWillCloseHtml(content)
  elseif style == HtmlHelper.Style.Flower then
    msgStr = HtmlHelper.GenerateFlowerHtml(content)
  elseif style == HtmlHelper.Style.YaoShouShengXing then
    msgStr = HtmlHelper.GenerateYaoShouShengXingHtml(content)
  elseif style == HtmlHelper.Style.ExchangeShenShou then
    msgStr = HtmlHelper.GenerateExchangeShenShouHtml(content)
  elseif style == HtmlHelper.Style.WorldBossRank then
    msgStr = HtmlHelper.GenerateWorldBossRankHtml(content)
  elseif style == HtmlHelper.Style.WorldBossDamage then
    msgStr = HtmlHelper.GenerateWorldBossDamageHtml(content)
  elseif style == HtmlHelper.Style.WorldBossEnd then
    msgStr = HtmlHelper.GenerateWorldBossEndHtml(content)
  elseif style == HtmlHelper.Style.KejuDianShiStart then
    msgStr = HtmlHelper.GenerateKejuDianshiHtml(content)
  elseif style == HtmlHelper.Style.KejuTop then
    msgStr = HtmlHelper.generateKejuTopHtml(content)
  elseif style == HtmlHelper.Style.Fight then
    msgStr = HtmlHelper.GenerateFightHtml(content)
  elseif style == HtmlHelper.Style.TuXiWinMaxStar then
    msgStr = HtmlHelper.GenerateTuxiMaxStarHtml(content)
  elseif style == HtmlHelper.Style.Common then
    msgStr = HtmlHelper.GenerateCommonHtml(content)
  elseif style == HtmlHelper.Style.PetComprehendSkill then
    msgStr = HtmlHelper.GeneratePetComprehendSkill(content)
  elseif style == HtmlHelper.Style.PetSkillLevelUp then
    msgStr = HtmlHelper.GeneratePetLevelUp(content)
  elseif style == HtmlHelper.Style.PhancaveGetAwardItem then
    msgStr = HtmlHelper.GeneratePhancaveAward(content)
  elseif style == HtmlHelper.Style.WorldGoalComplete then
    msgStr = HtmlHelper.GenerateWorldGoalHtml(content)
  elseif style == HtmlHelper.Style.FestivalCountDown then
    msgStr = HtmlHelper.GenerateFestivalCountDownAnnounce(content)
  else
    return "System Info Type not found"
  end
  return HtmlHelper.ConvertEmoji(msgStr)
end
def.static("table", "=>", "string").GenerateCommonHtml = function(content)
  local formatStr = string.gsub(content.str, "%[([0-9a-fA-F]+)%](.-)(%[%-%])", "<font color=#%1>%2</font>")
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, formatStr)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateFightHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_8' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format("<font color=#ffffff>%s</font>", content.content))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateWorldBossRankHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[38], content.name, content.rank))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateWorldBossDamageHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[40], content.name, content.percent))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateWorldBossEndHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[42], content.name))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateExchangeShenShouHtml = function(content)
  local formatStr = string.gsub(content.str, "%[([0-9a-fA-F]+)%](.-)(%[%-%])", "<font color=#%1>%2</font>")
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, formatStr)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateYaoShouShengXingHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[28], content.monster, content.place, content.name, content.monster2))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateFlowerHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[26], content.name1, content.itemColor, content.itemName, content.num, content.name2))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateLianShengHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[21], content.name, content.count))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateChuanShuoHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[23], content.name))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateJiuXiaoWillCloseHtml = function(content)
  local formatStr = string.gsub(textRes.AnnounceMent[24], "(%[[0-9a-fA-F]+%])(%%s)(%[%-%])", "<font color=#00ff00>%2</font>")
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(formatStr, content.leftMinute))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateLotteryHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[19], content.name, content.lottery, HtmlHelper.NameColor[content.color], content.item))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenBaoTuItemHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[16], content.name, content.baotu, HtmlHelper.NameColor[content.color], content.item))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenSystemHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format("<font color=#ff803a>%s</font>", content.text))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenBaoTuHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  if content.type == 1 then
    table.insert(strTable, string.format(textRes.AnnounceMent[32], content.name, content.mapname))
  elseif content.type == 2 then
    table.insert(strTable, string.format(textRes.AnnounceMent[33], content.name, content.mapname))
  elseif content.type == 3 then
    table.insert(strTable, string.format(textRes.AnnounceMent[83], content.name, content.mapname))
  end
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenShengXiaoHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, content.text)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenTuxiHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, content.text)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateQiLinHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[31], content.name, content.wearLevel, content.wearPos, content.itemName, content.qilingLevel))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateTuXiWinHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(textRes.AnnounceMent[29], content.monsterName, content.name))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateTuXiLostHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  if content.place then
    table.insert(strTable, string.format(textRes.AnnounceMent[30], content.name, content.place, content.monsterName))
  else
    table.insert(strTable, string.format(textRes.AnnounceMent[36], content.name, content.monsterName))
  end
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateGMHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format("<font color=#ff0000>\227\128\144GM\227\128\145:%s</font>", content.cmd))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateHelpHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_7' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format("<font color=%s>%s</font>", helpColor, content.content))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GeneratePersonalHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_6' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, content.content)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateGangHtml = function(content)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_6' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, content.content)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateRoleRenameHtml = function(content)
  local formatStr = string.gsub(textRes.AnnounceMent[17], "(%[[0-9a-fA-F]+%])(%%s)(%[%-%])", "%2")
  local coloredOldName = string.format("<font color=%s>%s</font>", roleNameColor, content.oldName)
  local coloredNewName = string.format("<font color=%s>%s</font>", roleNameColor, content.newName)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, string.format(formatStr, coloredOldName, coloredNewName))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateKejuDianshiHtml = function(content)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=18>")
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, content.DianShiNotify)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").generateKejuTopHtml = function(content)
  local kejuTopStr = textRes.Keju[54]
  if content.name1 ~= " " then
    kejuTopStr = string.format(textRes.AnnounceMent[59], content.name1)
    if content.name2 ~= " " then
      kejuTopStr = string.format(textRes.AnnounceMent[60], content.name1, content.name2)
      if content.name3 ~= " " then
        kejuTopStr = string.format(textRes.AnnounceMent[47], content.name1, content.name2, content.name3)
      end
    end
  end
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, kejuTopStr)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateTuxiMaxStarHtml = function(content)
  local tuxiStr = textRes.AnnounceMent[62]:format(content.name, content.otherNames, content.monsterStar, content.monsterName)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, tuxiStr)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GeneratePetComprehendSkill = function(content)
  local ComprehendSkillStr = textRes.AnnounceMent[71]:format(content.roleName, content.petName, content.skillName)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, ComprehendSkillStr)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GeneratePetLevelUp = function(content)
  local petSkillLevelUpStr = textRes.AnnounceMent[72]:format(content.roleName, content.petName, content.skillName1, content.skillName2)
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, petSkillLevelUpStr)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GeneratePhancaveAward = function(content)
  if nil == content then
    return " "
  end
  if nil == content.awardStr then
    return " "
  end
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, content.awardStr)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateWorldGoalHtml = function(content)
  if nil == content then
    return ""
  end
  if nil == content.mapInfo then
    return ""
  end
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, content.mapInfo)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "=>", "string").GenerateFestivalCountDownAnnounce = function(content)
  if nil == content then
    return ""
  end
  if nil == content.announceMent then
    return ""
  end
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle linespacing=6><font size=18 color=%s>", fontColor))
  table.insert(strTable, string.format("<img src='%s:Channel_0' width=52 height=22>", RESPATH.COMMONATLAS))
  table.insert(strTable, content.announceMent)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("string", "=>", "string").ConvertInfoPack = function(content)
  local linkPostfix = 0
  local html = ""
  html = string.gsub(content, "{color:.-,.-}", function(str)
    local strs = string.split(string.sub(str, 8, -2), ",")
    return string.format("<font color=#%s>%s</font>", strs[2], strs[1])
  end)
  html = string.gsub(html, "{e:%w+}", function(str)
    local emojiName = string.sub(str, 4, -2)
    return string.format("<img src='%s:%s' width=32 height=32 fps=5>", RESPATH.EMOJIATLAS, emojiName)
  end)
  html = string.gsub(html, "{i:.-,%w+,%w+,%w+,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 4, -2), ",")
    return string.format("<a href='item_%d' id=item_%s_%s><font color=#%s><effect name='shadow'>[%sx%s]</effect></font></a>", linkPostfix, strs[4], strs[5], HtmlHelper.NameColor[tonumber(strs[3])], strs[1], strs[2])
  end)
  html = string.gsub(html, "{w:.-,%w+,%w+,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 4, -2), ",")
    return string.format("<a href='wing_%d' id=wing_%s_%s><font color=#%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[3], strs[4], HtmlHelper.NameColor[tonumber(strs[2])], strs[1])
  end)
  html = string.gsub(html, "{a:.-,%w+,%w+,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 4, -2), ",")
    return string.format("<a href='aircraft_%d' id=aircraft_%s_%s><font color=#%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[3], strs[4], HtmlHelper.NameColor[tonumber(strs[2])], strs[1])
  end)
  html = string.gsub(html, "{p:.-,%w+,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 4, -2), ",")
    local encodeChar = strs[4] or ""
    local yaoliName = string.format("<gameobj width=30 height=18 prefab='%s' id='pet_yaoli_level' componentname='NGUITextButtonComponent' param='%s'>", RESPATH.PREFAB_HTML_PET_YAOLI_LEVEL, encodeChar)
    local petTypeColor = petColor
    if strs[5] then
      local petType = tonumber(strs[5])
      if petType then
        petTypeColor = "#" .. PetUtility.GetPetTypeColor(petType)
      end
    end
    return string.format("<a href='pet_%d' id=pet_%s_%s><font color=%s><effect name='shadow'>[%s%s]</effect></font></a>", linkPostfix, strs[2], strs[3], petTypeColor, strs[1], yaoliName)
  end)
  html = string.gsub(html, "{t:.-,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 4, -2), ",")
    return string.format("<a href='task_%d' id=task_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[2], taskColor, strs[1])
  end)
  html = string.gsub(html, "{f:.-,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 4, -2), ",")
    return string.format("<a href='fashion_%d' id=fashion_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[2], "#fe7200", strs[1])
  end)
  html = string.gsub(html, "{tp:.-,%w+,%w+,%w+,%w+,%w+}", function(str)
    local strs = string.split(string.sub(str, 5, -2), ",")
    local name = strs[1]
    local text = string.format(textRes.TeamPlatform[20], name, strs[2], strs[3])
    local btnname = string.format("Btn_TeamPlatform_Apply_%s_%s_%s", strs[4], strs[5], strs[6])
    local button = string.format("<a href='%s' id=%s><font color=#%s><u>[%s]</u></font></a>", btnname, btnname, link_defalut_color, textRes.TeamPlatform[29])
    return string.format("%s%s", text, button)
  end)
  html = string.gsub(html, "{fb:.-,%w+,%w+,%w+,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 5, -2), ",")
    return string.format("<a href='fabao_%d' id=fabao_%s_%s><font color=#%s><effect name='shadow'>[%sx%s]</effect></font></a>", linkPostfix, strs[4], strs[5], HtmlHelper.NameColor[tonumber(strs[3])], strs[1], strs[2])
  end)
  html = string.gsub(html, "{fbs:.-,%w+,%w+,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 6, -2), ",")
    return string.format("<a href='fabaospirit_%d' id=fabaospirit_%s_%s><font color=#%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[4], strs[2], HtmlHelper.NameColor[tonumber(strs[3])], strs[1])
  end)
  html = string.gsub(html, "{z:.-,%w+,.-}", function(str)
    local strs = string.split(string.sub(str, 4, -2), ",")
    return string.format("<a href='zone' id='zone_%s_%s'><font color=#%s><effect name='shadow'>[%s]</effect></font></a>", strs[2], strs[3], "ff00ff", strs[1])
  end)
  html = string.gsub(html, "{mgd:.-,%w+,%w+}", function(str)
    local strs = string.split(string.sub(str, 6, -2), ",")
    local params = {
      marketId = Int64.ParseString(strs[1]),
      refId = tonumber(strs[2]),
      price = tonumber(strs[3]),
      gotoText = textRes.TradingArcade[81],
      gotoTextColor = HtmlHelper.NameColor[2]
    }
    local goodsHtml = HtmlHelper.ConvertMarketGoodsLink(params)
    local gotoHtml = HtmlHelper.ConvertMarketGotoLink(params)
    local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
    local color = TradingArcadeUtils.GetTradingPriceColor(params.price)
    local priceHtml = HtmlHelper.ConvertIngotHtml({
      count = params.price,
      color = color
    })
    local content = string.format("%s%s&nbsp;%s", goodsHtml, priceHtml, gotoHtml)
    return string.format(textRes.TradingArcade[80], content)
  end)
  html = string.gsub(html, "{wmgd:.-,%w+,%w+}", function(str)
    local strs = string.split(string.sub(str, 7, -2), ",")
    local params = {
      marketId = Int64.ParseString(strs[1]),
      refId = tonumber(strs[2]),
      price = tonumber(strs[3]),
      gotoText = textRes.TradingArcade[81],
      gotoTextColor = HtmlHelper.NameColor[2]
    }
    local goodsHtml = HtmlHelper.ConvertMarketGoodsLink(params)
    return string.format(textRes.TradingArcade[83], goodsHtml)
  end)
  html = string.gsub(html, "{ssmoment:.-,%w+,%w+}", function(str)
    local strs = string.split(string.sub(str, 11, -2), ",")
    local params = {
      ownerName = strs[1],
      ownerId = Int64.ParseString(strs[2]),
      msgId = Int64.ParseString(strs[3])
    }
    local momentHtml = HtmlHelper.ConvertSpaceMomentLink(params)
    return momentHtml
  end)
  html = string.gsub(html, "{chengwei:.-,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 11, -2), ",")
    return string.format("<a href='chengwei_%d' id=chengwei_%s_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[2], strs[1], "#fe7200", strs[1])
  end)
  html = string.gsub(html, "{touxian:.-,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 10, -2), ",")
    return string.format("<a href='touxian_%d' id=touxian_%s_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[2], strs[1], "#fe7200", strs[1])
  end)
  html = string.gsub(html, "{mounts:.-,%w+,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 9, -2), ",")
    return string.format("<a href='mounts_%d' id=mounts_%s_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[2], strs[3], "#fe7200", strs[1])
  end)
  html = string.gsub(html, "{child:.-,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 8, -2), ",")
    return string.format("<a href='child_%d' id=child_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[2], "#fe7200", strs[1])
  end)
  html = string.gsub(html, "{msv:%w+,.-}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 6, -2), ",")
    return string.format("<a href='msv_%d' id=msv_%s><font color=%s><effect name='shadow'>%s</effect></font></a>", linkPostfix, strs[1], "#fe7200", strs[2])
  end)
  html = string.gsub(html, "{crossbattle:%w+,.-}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 14, -2), ",")
    return string.format("<a href='crossbattle_%d' id=crossbattle_%s><font color=%s><effect name='shadow'>%s</effect></font></a>", linkPostfix, strs[1], "#44daff", strs[2])
  end)
  html = string.gsub(html, "{corpscheck:%w+,.-}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 13, -2), ",")
    return string.format("<a href='corpscheck_%d' id=corpscheck_%s><font color=%s><effect name='shadow'><u>%s</u></effect></font></a>", linkPostfix, strs[1], "#ffff00", strs[2])
  end)
  html = string.gsub(html, "{achieve:.-,.-,%w+,%w+,%w+,.-}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 10, -2), ",")
    return string.format("<a href='achieve_%d' id=achieve_%s_%s_%s_%s_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[3], strs[4], strs[5], strs[6], strs[2], "#ff00ff", strs[1])
  end)
  html = string.gsub(html, "{shoppingGroup:.-,%w+,%w+}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 16, -2), ",")
    return string.format("<a href='shoppingGroup_%d' id=shoppingGroup_%s_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[2], strs[3], "#ff00ff", strs[1])
  end)
  html = string.gsub(html, "{breakegg:.-,.-,.-}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 11, -2), ",")
    return string.format("<a href='btn_%d' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", linkPostfix, strs[1], strs[2], strs[3])
  end)
  html = string.gsub(html, "{gangteam:.-,%w+,.-,.-,.-,.-}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 11, -2), ",")
    local msgType = tonumber(strs[5])
    if msgType == 1 then
      local hyperLinkStr = string.format("<a href='gangteam_%s' id=gangteam_%s><font color=%s><u>[%s]</u></font></a>", strs[2], strs[2], strs[6], strs[3])
      local retStr = textRes.Gang.GangTeam[72]:format(strs[4], hyperLinkStr)
      return retStr
    else
      local hyperLinkStr = string.format("<a href='gangteam_%s' id=gangteam_%s><font color=%s><u>[%s]</u></font></a>%s", strs[2], strs[2], strs[6], strs[3], textRes.Gang.GangTeam[48])
      return hyperLinkStr
    end
  end)
  html = string.gsub(html, "{TurnedCard:%w+,.-,.-}", function(str)
    linkPostfix = linkPostfix + 1
    local strs = string.split(string.sub(str, 13, -2), ",")
    local level = tonumber(strs[3])
    local colorStr = "#" .. textRes.TurnedCard.levelColor[level]
    return string.format("<a href='TurnedCard_%d' id=TurnedCard_%s_%s><font color=%s><effect name='shadow'>[%s]</effect></font></a>", linkPostfix, strs[1], strs[3], colorStr, strs[2])
  end)
  if require("Main.Chat.At.AtMgr").Instance():IsOpen(false) then
    html = string.gsub(html, AtUtils.GetChatAtRolenameFormat(), function(str)
      local rolename = string.sub(str, 2)
      if AtUtils.ValidRolename(rolename) then
        linkPostfix = linkPostfix + 1
        local packColor = AtUtils.GetAtRolePackColor()
        local htmlId = AtUtils.GetAtRolenameHTMLId(rolename)
        return string.format("<a href='role_%d' id=%s><font color=%s><effect name='shadow'>%s</effect></font></a>", linkPostfix, htmlId, packColor, str)
      else
        return str
      end
    end)
  end
  html = string.gsub(html, AtUtils.GetChatAtInfoPackFormat(), function(str)
    linkPostfix = linkPostfix + 1
    local prefixLen = string.len(AtUtils.AT_PREFIX)
    local strs = string.split(string.sub(str, prefixLen + 3, -2), ",")
    local packColor = AtUtils.GetAtRolePackColor()
    local htmlId = AtUtils.GetAtInfoPackHTMLId(strs[1], strs[2], strs[3], strs[4])
    return string.format("<a href='role_%d' id=%s><font color=%s><effect name='shadow'>@%s</effect></font></a>", linkPostfix, htmlId, packColor, strs[2])
  end)
  return html
end
def.static("string", "=>", "string").ConvertHistory = function(content)
  local infoPackStr = HtmlHelper.ConvertInfoPack(content)
  local infoPackStrWithOutLink = string.gsub(infoPackStr, "<a.->", "")
  infoPackStrWithOutLink = string.gsub(infoPackStrWithOutLink, "</a>", "")
  return string.format("<font size=22>%s</font>", infoPackStrWithOutLink)
end
def.static("string", "=>", "string").ConvertFriendChat = function(html)
  local ret = string.gsub(html, fontColor, friendColor)
  return ret
end
def.static("string", "=>", "string").ConvertPopChat = function(html)
  local ret = string.gsub(html, fontColor, popColor)
  return ret
end
def.static("string", "=>", "string").ConvertMailContent = function(mailContent)
  local newContent = HtmlHelper.ConvertReturnSpace(mailContent)
  newContent = HtmlHelper.ConvertNPCLink(newContent)
  newContent = HtmlHelper.ConvertFirstChargeLink(newContent)
  newContent = HtmlHelper.ConvertReturnHomeLink(newContent)
  newContent = HtmlHelper.ConvertSwornVoteLink(newContent)
  newContent = HtmlHelper.ConvertAwardLink(newContent)
  newContent = HtmlHelper.ConvertCorpsLink(newContent)
  newContent = HtmlHelper.ConvertItemLink(newContent)
  newContent = HtmlHelper.ConvertAuctionLink(newContent)
  local strTable = {}
  table.insert(strTable, "<p align=left valign=middle linespacing=6><font size=21 color=#4F3018>")
  table.insert(strTable, newContent)
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("string", "=>", "string").ConvertAuctionLink = function(content)
  if not string.find(content, "auction") then
    return content
  end
  local index = 0
  local newContent = string.gsub(content, "<auction:.-,.-,.-,.->", function(str)
    index = index + 1
    local strs = string.split(string.sub(str, 10, -2), ",")
    return string.format("<a href='auction_%d' id=auction_%s_%s_%s><font color=#fe7200><effect name='shadow'><u>%s</u></effect></font></a>", index, strs[1], strs[2], strs[3], strs[4])
  end)
  return newContent
end
def.static("string", "=>", "string").ConvertNPCLink = function(content)
  if not string.find(content, "npc") then
    return content
  end
  local index = 0
  local newContent = string.gsub(content, "<npc:.->", function(str)
    index = index + 1
    local strs = string.split(string.sub(str, 6, -2), ",")
    return string.format("<a href='npc_%d' id=npc_%s><font color=#fe7200><effect name='shadow'><u>%s</u></effect></font></a>", index, strs[1], strs[2])
  end)
  return newContent
end
def.static("string", "=>", "string").ConvertCorpsLink = function(content)
  if not string.find(content, "corps") then
    return content
  end
  local index = 0
  local newContent = string.gsub(content, "<corps:.-,.->", function(str)
    index = index + 1
    local strs = string.split(string.sub(str, 8, -2), ",")
    return string.format("<a href='corps_%d' id=corps_%s><font color=#fe7200><effect name='shadow'><u>%s</u></effect></font></a>", index, strs[2], strs[1])
  end)
  return newContent
end
def.static("string", "=>", "string").ConvertItemLink = function(content)
  if not string.find(content, "item") then
    return content
  end
  local index = 0
  local newContent = string.gsub(content, "<item:.-,.->", function(str)
    index = index + 1
    local strs = string.split(string.sub(str, 7, -2), ",")
    local num = tonumber(strs[2])
    local itemId = tonumber(strs[1])
    if itemId and num then
      local itemBase = ItemUtils.GetItemBase(itemId)
      if itemBase then
        if num > 0 then
          return string.format("%sx%d", itemBase.name, num)
        else
          return string.format("%s", itemBase.name)
        end
      else
        return ""
      end
    else
      return ""
    end
  end)
  return newContent
end
def.static("string", "=>", "string").ConvertFirstChargeLink = function(content)
  if not string.find(content, "FirstCharge") then
    return content
  end
  local index = 0
  local newContent = string.gsub(content, "<FirstCharge:.->", function(str)
    index = index + 1
    local str = string.sub(str, 14, -2)
    return string.format("<a href='FirstCharge_%d' id=FirstCharge><font color=#fe7200><effect name='shadow'><u>%s</u></effect></font></a>", index, str)
  end)
  return newContent
end
def.static("string", "=>", "string").ConvertReturnHomeLink = function(content)
  if not string.find(content, "ReturnHome") then
    return content
  end
  local index = 0
  local newContent = string.gsub(content, "<ReturnHome:.->", function(str)
    index = index + 1
    local str = string.sub(str, 13, -2)
    return string.format("<a href='ReturnHome_%d' id=ReturnHome><font color=#fe7200><effect name='shadow'><u>%s</u></effect></font></a>", index, str)
  end)
  return newContent
end
def.static("string", "=>", "string").ConvertSwornVoteLink = function(content)
  if not string.find(content, "SwornVote") then
    return content
  end
  local newContent = string.gsub(content, "<SwornVote.->", function(str)
    local colonIndex = str:find(":")
    local words = str:sub(colonIndex + 1, -2)
    local idIndex = tonumber(str:sub(11, colonIndex - 1))
    return string.format("<a href='SwornVote' id=SwornVote%d><font color=#fe7200><effect name='shadow'><u>%s</u></effect></font></a>", idIndex, words)
  end)
  return newContent
end
def.static("string", "=>", "string").ConvertAwardLink = function(content)
  if not string.find(content, "AwardLink") then
    return content
  end
  local newContent = string.gsub(content, "<AwardLink:.->", function(str)
    local strs = string.split(string.sub(str, 12, -2), ",")
    if #strs == 2 then
      return string.format("<a href='award_%s' id=award_%s><font color=#fe7200><effect name='shadow'><u>%s</u></effect></font></a>", strs[1], strs[1], strs[2])
    end
  end)
  return newContent
end
def.static("string", "=>", "string").ConvertReturnSpace = function(content)
  local newContent = string.gsub(content, "\\n", "<br>")
  return newContent
end
def.static("string", "=>", "string").ConvertAnnouncement = function(content)
  local newContent = string.gsub(content, "%[([0-9a-fA-F]+)%](.-)(%[%-%])", "<font color=#%1>%2</font>")
  newContent = string.gsub(newContent, "{e:%w+}", function(str)
    local emojiName = string.sub(str, 4, -2)
    return string.format("<img src='%s:%s' width=24 height=24 fps=5>", RESPATH.EMOJIATLAS, emojiName)
  end)
  newContent = string.format("<font size=18>%s</font>", newContent)
  return newContent
end
def.static("string", "=>", "string").ConvertEmoji = function(content)
  local html = string.gsub(content, "{e:%w+}", function(str)
    local emojiName = string.sub(str, 4, -2)
    return string.format("<img src='%s:%s' width=24 height=24 fps=5>", RESPATH.EMOJIATLAS, emojiName)
  end)
  return html
end
def.static("table", "=>", "string").ConvertMarketGoodsLink = function(params)
  local PetUtility = require("Main.Pet.PetUtility")
  local goodsName = ""
  local goodsColor = "fffff"
  local id = params.refId
  if PetUtility.IsPetCfgId(id) then
    local petCfg = PetUtility.Instance():GetPetCfg(id)
    if petCfg then
      goodsName = petCfg.templateName
      goodsColor = PetUtility.GetPetTypeColor(petCfg.type)
    end
  else
    local ItemUtils = require("Main.Item.ItemUtils")
    local itemBase = ItemUtils.GetItemBase(id)
    if itemBase then
      goodsName = itemBase.name
      goodsColor = HtmlHelper.NameColor[itemBase.namecolor]
    end
  end
  local html = string.format("<a href='marketGoods_%d' id=marketGoods_%s_%s_%s><font color=#%s><effect name='shadow'>[%s]</effect></font></a>", 1, tostring(params.marketId), params.refId, params.price, goodsColor, goodsName)
  return html
end
def.static("table", "=>", "string").ConvertMarketGotoLink = function(params)
  local id = params.refId
  local html = string.format("<a href='marketGoto_%d' id=marketGoto_%s_%s_%s><font color=#%s><effect name='shadow'>[%s]</effect></font></a>", 2, tostring(params.marketId), id, params.price, params.gotoTextColor, params.gotoText)
  return html
end
def.static("table", "=>", "string").ConvertSpaceMomentLink = function(params)
  local linkText = textRes.SocialSpace[37]:format(params.ownerName)
  local linkTextColor = HtmlHelper.NameColor[2]
  local html = string.format("<a href='spaceMoment' id=spaceMoment_%s_%s><font color=#%s><effect name='shadow'>[%s]</effect></font></a>", tostring(params.ownerId), tostring(params.msgId), linkTextColor, linkText)
  return html
end
def.static("table", "=>", "string").ConvertIngotHtml = function(params)
  local count = params.count
  local color = params.color or "fffff"
  local spriteName = "Img_JinDing"
  local color = string.format("#%s", color)
  local strTable = {}
  table.insert(strTable, string.format("&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, string.format("<font color=%s>&nbsp;%s</font>", color, tostring(count)))
  local html = table.concat(strTable)
  return html
end
def.static("number", "=>", "string").GetColoredItemName = function(itemId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase == nil then
    return ""
  end
  local name = itemBase.name
  local namecolor = itemBase.namecolor
  local color = HtmlHelper.NameColor[namecolor]
  local coloredName = string.format("<font color=#%s>%s</font>", color, name)
  return coloredName
end
def.static("string", "=>", "string").ConvertHtmlColorToBBCode = function(text)
  text = string.gsub(text, "<font color=#([0-9a-fA-F]+)>(.-)</font>", "%[%1%]%2%[-%]")
  return text
end
def.static("string", "=>", "string").ConvertBBCodeColorToHtml = function(text)
  text = string.gsub(text, "%[([0-9a-fA-F]+)%](.-)(%[%-%])", "<font color=#%1>%2</font>")
  return text
end
def.static("string", "=>", "string").ConvertHtmlKeyWord = function(content)
  content = string.gsub(content, ">", "&gt;")
  content = string.gsub(content, "<", "&lt;")
  content = string.gsub(content, "\"", "&quot;")
  return content
end
def.static("string", "=>", "string").RemoveHtmlTag = function(html)
  local text = string.gsub(html, "<br/>", "\n")
  text = string.gsub(text, "</br>", "\n")
  text = string.gsub(text, "<br>", "\n")
  text = string.gsub(text, "<.->", "")
  return text
end
HtmlHelper.Commit()
return HtmlHelper
