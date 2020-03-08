local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AnnouncementModule = Lplus.Extend(ModuleBase, "AnnouncementModule")
require("Main.module.ModuleId")
local def = AnnouncementModule.define
local instance
local AnnouncementType = require("netio.protocol.mzm.gsp.bulletin.SBulletinInfo")
local ParamType = require("netio.protocol.mzm.gsp.bulletin.BulletinParamKey")
local AnnouncementTip = require("GUI.AnnouncementTip")
local RareItemAnnouncementTip = require("GUI.RareItemAnnouncementTip")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ItemUtils = require("Main.Item.ItemUtils")
def.static("=>", AnnouncementModule).Instance = function()
  if instance == nil then
    instance = AnnouncementModule()
    instance.m_moduleId = ModuleId.ANNOUNCEMENT
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bulletin.SBulletinInfo", AnnouncementModule.onAnnouncement)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncVisibleMonsterFightTip", AnnouncementModule.onSSyncVisibleMonsterFightTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSendDefaultAwardInfo", AnnouncementModule.onSSendDefaultAwardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSendAwardInfoWithStorageExp", AnnouncementModule.onSSendAwardInfoWithStorageExp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SBrocastYaoShouItem", AnnouncementModule.onSBrocastYaoShouItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SBrocastShengXiaoItem", AnnouncementModule.onSBrocastShengXiaoItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bounty.SBrocastBountyItem", AnnouncementModule.onSBrocastBountyItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.changemodelcard.SChangeModelCardLotteryBrd", AnnouncementModule.onSChangeModelCardLotteryBrd)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AnnouncementModule.onLeaveWorld)
  ModuleBase.Init(self)
end
def.static("table", "table").onLeaveWorld = function(p1, p2)
  AnnouncementTip.HideImmediately()
end
def.static("table").onSSendDefaultAwardInfo = function(p)
  print("onSSendDefaultAwardInfo")
  local AwardUtils = require("Main.Award.AwardUtils")
  local htmlTexts = AwardUtils.GetHtmlTextsFromAwardBean(p.awardInfo, textRes.AnnounceMent[8])
  for i, v in ipairs(htmlTexts) do
    PersonalHelper.SendOut(v)
  end
end
def.static("table").onSSendAwardInfoWithStorageExp = function(p)
  if p.awardInfo then
    p.awardInfo.storageExp = p.addExp
    AnnouncementModule.onSSendDefaultAwardInfo(p)
  end
end
def.static("table").onSSyncVisibleMonsterFightTip = function(p)
  print("_OnSSyncVisibleMonsterFightTip")
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityCfg = ActivityInterface.GetActivityCfgById(p.activityId)
  local tipStr = string.format(textRes.activity[102], activityCfg.activityName)
  Toast(tipStr)
end
def.static("table").onAnnouncement = function(p)
  print("p.bulletinType", p.bulletinType)
  if p.bulletinType == AnnouncementType.ROLE_EQUIP_LING_LEVEL then
    AnnouncementModule.onRoleEquipLingLevel(p.params)
  elseif p.bulletinType == AnnouncementType.YAOSHOUTUXI_FIGHT_WIN then
    AnnouncementModule.onTuxiWin(p.params)
  elseif p.bulletinType == AnnouncementType.YAOSHOUTUXI_FIGHT_LOSE then
    AnnouncementModule.onTuxiLost(p.params)
  elseif p.bulletinType == AnnouncementType.GANG_CREATE then
    AnnouncementModule.onGangCreate(p.params)
  elseif p.bulletinType == AnnouncementType.BAOTU_TRIGGER_CTRL then
  elseif p.bulletinType == AnnouncementType.YAOSHOUTUXI_MONSTER_BORN then
    AnnouncementModule.onTuxiRefresh(p.params)
  elseif p.bulletinType == AnnouncementType.SHENGXIAO_MONSTER_BORN then
    AnnouncementModule.onShengXiao(p.params)
  elseif p.bulletinType == AnnouncementType.BAOTU_AWARD_ITEM then
    AnnouncementModule.onBaoTuAwardItem(p.params)
  elseif p.bulletinType == AnnouncementType.ROLE_RENAME then
    AnnouncementModule.onRoleRename(p.params)
  elseif p.bulletinType == AnnouncementType.ROLE_USE_LOTTERY then
    AnnouncementModule.onLotteryAwardItem(p.params)
  elseif p.bulletinType == AnnouncementType.ROLE_JINGJI_PVP_VICTORY then
    AnnouncementModule.onJingJiContinueWin(p.params)
  elseif p.bulletinType == AnnouncementType.ROLE_JINGJI_PVP_CHUANSHUO then
    AnnouncementModule.onJingJiLegend(p.params)
  elseif p.bulletinType == AnnouncementType.JIU_XIAO_END_TIP then
    AnnouncementModule.onJiuXiaoWillClose(p.params)
  elseif p.bulletinType == AnnouncementType.FLOWER_GIVE then
    AnnouncementModule.onFlowerSend(p.params)
  elseif p.bulletinType == AnnouncementType.YAOSHOUTUXI_STAR_LEVELUP then
    AnnouncementModule.onYaoShouShengXing(p.params)
  elseif p.bulletinType == AnnouncementType.SHENSHOU_REDEEM then
    AnnouncementModule.onExchangeShenShou(p.params)
  elseif p.bulletinType == AnnouncementType.BIGBOSS_RANK then
    AnnouncementModule.onWorldBossRank(p.params)
  elseif p.bulletinType == AnnouncementType.BIGBOSS_MONSTER then
    AnnouncementModule.onWorldBossDamage(p.params)
  elseif p.bulletinType == AnnouncementType.BIGBOSS_ACTIVITY_END then
    AnnouncementModule.onWorldBossEnd(p.params)
  elseif p.bulletinType == AnnouncementType.KEJU_DIANSHI_KAISHI then
    AnnouncementModule.onKejuDianshiStart()
  elseif p.bulletinType == AnnouncementType.MOSHOU_REDEEM then
    AnnouncementModule.onExchangeShenShou(p.params)
  elseif p.bulletinType == AnnouncementType.KEJU_TOP3 then
    AnnouncementModule.onShowKejuTop(p.params)
  elseif p.bulletinType == AnnouncementType.PET_HUASHENG then
    AnnouncementModule.onLuckyHuaShengBrd(p.params)
  elseif p.bulletinType == AnnouncementType.HB_TIME_DESC then
  elseif p.bulletinType == AnnouncementType.PET_COMPREHEND_SKILL then
    AnnouncementModule.onPetComprehendSkill(p.params)
  elseif p.bulletinType == AnnouncementType.PET_SKILL_LEVELUP then
    AnnouncementModule.onPetSkillLevelUp(p.params)
  elseif p.bulletinType == AnnouncementType.ONLINE_TREASURE_BOX then
    AnnouncementModule.onOnlineBoxAward(p.params)
  elseif p.bulletinType == AnnouncementType.MI_BAO_DRAW_LOTTERY then
    AnnouncementModule.onMibaoGetAward(p.params)
  elseif p.bulletinType == AnnouncementType.EXPLORE_CAT_BEST_PARTNER then
    AnnouncementModule.onExploreCatBestPartner(p.params)
  elseif p.bulletinType == AnnouncementType.REFRESH_LUCKY_BAG then
    AnnouncementModule.onJiuZhouFuDai(p.params)
  elseif p.bulletinType == AnnouncementType.PAY_NEW_YEAR then
    AnnouncementModule.OnAnnouncementPayNewYearAward(p.params)
  elseif p.bulletinType == AnnouncementType.SIGN_PRECIOUS then
    AnnouncementModule.OnAnnouncementSignPreciousAward(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_SELECTION_BEGIN then
    AnnouncementModule.OnAnnouncementCrossBattleSelectionBegin(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_SELECTION_RANK_UP then
    AnnouncementModule.OnAnnouncementCrossBattleSelectionRankUp(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_SELECTION_RANK_UP_FINAL then
    AnnouncementModule.OnAnnouncementCrossBattleSelectionRankUpFinal(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_COMPETE_SELECTION then
    AnnouncementModule.OnAnnouncementCrossBattleSelectionCompeleteChampion(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_SELECTION_WIN_TITLE then
    AnnouncementModule.OnAnnouncementCrossBattleSelectionWinTitle(p.params)
  elseif p.bulletinType == AnnouncementType.MYSTERY_SHOP_BUY then
    AnnouncementModule.OnAnnouncementBuyedMysteryGoods(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_FINAL_BEGIN then
    AnnouncementModule.OnAnnouncementCrossBattleFinalBegin(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_FINAL_RANK_UP then
    AnnouncementModule.OnAnnouncementCrossBattleFinalRankUp(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_COMPETE_FINAL then
    AnnouncementModule.OnAnnouncementCrossBattleCompeteFinal(p.params)
  elseif p.bulletinType == AnnouncementType.CROSS_BATTLE_FINAL_WIN_TITLE then
    AnnouncementModule.OnAnnouncementCrossBattleFinalWinTitle(p.params)
  elseif p.bulletinType == AnnouncementType.XIAO_HUI_KUAI_PAO_INNER_DRAW then
    AnnouncementModule.OnAnnouncementMonkeyRunInnerAward(p.params)
  elseif p.bulletinType == AnnouncementType.XIAO_HUI_KUAI_PAO_OUTER_DRAW then
    AnnouncementModule.OnAnnouncementMonkeyRunOutAward(p.params)
  elseif p.bulletinType == AnnouncementType.FRIENDS_CIRCLE_GIVE_GIFT then
    AnnouncementModule.OnAnnouncementSocialSpaceGiveGift(p.params)
  elseif p.bulletinType == AnnouncementType.AUCTION_END_BID then
    AnnouncementModule.OnAnnouncementAuctionBidEnd(p.params)
  elseif p.bulletinType == AnnouncementType.AUCTION_WIN_BID then
    AnnouncementModule.OnAnnouncementAuctionWinBid(p.params)
  elseif p.bulletinType == AnnouncementType.COMMON_VISIBLE_MONSTER_TRIGGER then
    AnnouncementModule.OnAnnouncementCommonVisibleMonster(p.params)
  elseif p.bulletinType == AnnouncementType.CHRISTMAS_STOCKING_AWARD then
    AnnouncementModule.OnAnnouncementChristmasStockingAward(p.params)
  elseif p.bulletinType == AnnouncementType.DRAW_CARNIVAL_ACTIVITY_DRAW then
    AnnouncementModule.OnAnnouncementDragonBitAward(p.params)
  else
    AnnouncementModule.notImpl(p.params)
  end
end
def.static("table").notImpl = function(p)
  warn("annoument not Impl!")
end
def.static("table").OnAnnouncementAuctionBidEnd = function(params)
  warn("[AnnouncementModule:OnAnnouncementAuctionBidEnd] OnAnnouncementAuctionBidEnd.")
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[113], itemBase.name)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementAuctionWinBid = function(params)
  warn("[AnnouncementModule:OnAnnouncementAuctionWinBid] OnAnnouncementAuctionWinBid.")
  local ItemUtils = require("Main.Item.ItemUtils")
  local rolename = params[ParamType.ROLE_NAME1] or ""
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[114], rolename, itemBase.name)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCommonVisibleMonster = function(params)
  local id1 = tonumber(params[ParamType.VISIBLE_MONSTER_TYPE_ID])
  local id2 = tonumber(params[ParamType.VISIBLE_MONSTER_TYPE_ID_2])
  local VisibleMonsterMgr = require("Main.activity.VisibleMonster.VisibleMonsterMgr")
  local monsterNameCfg1 = VisibleMonsterMgr.GetVisibleMonsterNameCfg(id1)
  local monsterNameCfg2 = VisibleMonsterMgr.GetVisibleMonsterNameCfg(id2)
  local str = string.format(textRes.AnnounceMent[117], monsterNameCfg1.monster_name, monsterNameCfg2.monster_name)
  AnnouncementTip.Announce(str)
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.static("table").OnAnnouncementSocialSpaceGiveGift = function(params)
  local giverRoleName = params[ParamType.ROLE_NAME1]
  local receiverRoleName = params[ParamType.ROLE_NAME2]
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local itemNum = tonumber(params[ParamType.ITEM_NUM])
  local fxId = tonumber(params[ParamType.EFFECT_ID])
  local msg = tostring(params[ParamType.MESSAGE])
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase == nil then
    return
  end
  local color = require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor]
  local richMsg = HtmlHelper.ConvertInfoPack(msg)
  local str = string.format(textRes.AnnounceMent[112], giverRoleName, receiverRoleName, itemNum, color, itemBase.name, richMsg)
  local NoticeType = require("consts.mzm.gsp.function.confbean.NoticeType")
  require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleId(str, NoticeType.SEND_FLOWER)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  if fxId and fxId > 0 then
    local effRes = GetEffectRes(fxId)
    if effRes then
      local name = tostring(fxId)
      require("Fx.GUIFxMan").Instance():PlayLayer(effRes.path, name, 0, 0, 1, 1, -1, false)
    end
  end
end
def.static("table").onJiuZhouFuDai = function(params)
  local str = textRes.AnnounceMent[86]
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").onExploreCatBestPartner = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local partnerCfgId = params[ParamType.EXPLORE_CAT_PARTNER_CFG_ID]
  local CatModule = require("Main.Cat.CatModule")
  local partnerCfg = CatModule.Instance():GetPartnerCfg(tonumber(partnerCfgId))
  local str = string.format(textRes.AnnounceMent[84], roleName, partnerCfg.name)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").onMibaoGetAward = function(params)
  local ItemUtils = require("Main.Item.ItemUtils")
  local roleName = params[ParamType.ROLE_NAME1]
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local itemNum = tonumber(params[ParamType.ITEM_NUM])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemcolor = HtmlHelper.NameColor[itemBase.namecolor]
  local coloredItemName = string.format("[%s]%s\195\151%d[-]", itemcolor, itemBase.name, itemNum)
  local str = string.format(textRes.AnnounceMent[75], roleName, coloredItemName)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").onLuckyHuaShengBrd = function(params)
  local ItemUtils = require("Main.Item.ItemUtils")
  local PetUtility = require("Main.Pet.PetUtility")
  local roleName = params[ParamType.ROLE_NAME1]
  local petId = params[ParamType.PET_ID]
  local skillNum = params[ParamType.HUASHENG_X_SKILL]
  local petName = petId
  local petNameColor = "00ff00"
  local petCfg = PetUtility.Instance():GetPetCfg(tonumber(petId))
  if petCfg and petCfg.templateId == tonumber(petId) then
    petName = petCfg.templateName
    petNameColor = PetUtility.GetPetTypeColor(petCfg.type)
  end
  local str = string.format(textRes.AnnounceMent[63], roleName, petNameColor, petName, skillNum)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").onJiuXiaoPreciousItemBrd = function(viewData)
  local ItemUtils = require("Main.Item.ItemUtils")
  local strTable = {}
  for k, v in pairs(viewData.item2Num) do
    local itemBase = ItemUtils.GetItemBase(k)
    table.insert(strTable, string.format("[%s]%s\195\151%d[-]", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name, v))
  end
  local itemInfos = table.concat(strTable, "\239\188\140")
  local str = string.format(textRes.AnnounceMent[55], viewData.roleName, viewData.activityName, viewData.bossName, itemInfos)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetAwardBulletinType(viewData.item2Num) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").onJiuXiaoFisrtWin = function(viewData)
  local roleNamesTable = {}
  for i, role in ipairs(viewData.roles) do
    table.insert(roleNamesTable, role.roleName)
  end
  local roleNames = table.concat(roleNamesTable, textRes.Common[19])
  local str = string.format(textRes.AnnounceMent[53], roleNames, viewData.mapName, viewData.bossName)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").onWorldBossRank = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local rank = params[ParamType.RANK]
  local str = string.format(textRes.AnnounceMent[37], roleName, rank)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.WorldBossRank, {name = roleName, rank = rank})
end
def.static("table").onWorldBossDamage = function(params)
  local monsterId = tonumber(params[ParamType.MONSTER_ID])
  local monsterCfg = require("Main.WorldBoss.WorldBossUtility").GetMonsterCfg(monsterId)
  local monsterName = monsterCfg.name
  local percent = params[ParamType.RATE]
  local str = string.format(textRes.AnnounceMent[39], monsterName, percent)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.WorldBossDamage, {name = monsterName, percent = percent})
end
def.static("table").onWorldBossEnd = function(params)
  local monsterId = tonumber(params[ParamType.MONSTER_ID])
  local monsterCfg = require("Main.WorldBoss.WorldBossUtility").GetMonsterCfg(monsterId)
  local monsterName = monsterCfg.name
  local str = string.format(textRes.AnnounceMent[41], monsterName)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.WorldBossEnd, {name = monsterName})
end
def.static("table").onExchangeShenShou = function(params)
  local PetUtility = require("Main.Pet.PetUtility")
  local roleName1 = params[ParamType.ROLE_NAME1]
  local itemNum = tonumber(params[ParamType.ITEM_NUM])
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local petId = tonumber(params[ParamType.PET_ID])
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemcolor = HtmlHelper.NameColor[itemBase.namecolor]
  local coloredItemName = string.format("[%s]%s[-]", itemcolor, itemBase.name)
  local petCfg = PetUtility.Instance():GetPetCfg(petId)
  local petTypeName = textRes.Pet.Type[petCfg.type]
  local petName = petCfg.templateName
  local str = string.format(textRes.AnnounceMent[34], roleName1, itemNum, coloredItemName, petTypeName, petName)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.ExchangeShenShou, {str = str})
end
def.static("table").onYaoShouShengXing = function(params)
  local roleName1 = params[ParamType.ROLE_NAME1]
  local monsterName = params[ParamType.MONSTER_NAME]
  local monsterName2 = params[ParamType.NEXT_MONSTER_NAME]
  local placeName = params[ParamType.PLACE_NAME]
  local str = string.format(textRes.AnnounceMent[27], monsterName, placeName, roleName1, monsterName2)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.YaoShouShengXing, {
    name = roleName1,
    monster = monsterName,
    monster2 = monsterName2,
    place = placeName
  })
end
def.static("table").onFlowerSend = function(params)
  local roleName1 = params[ParamType.ROLE_NAME1]
  local roleName2 = params[ParamType.ROLE_NAME2]
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local itemNum = tonumber(params[ParamType.ITEM_NUM])
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  local flowerCfg = ItemUtils.GetFlowerItemCfg(itemId)
  if itemBase == nil then
    return
  end
  local color = require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor]
  local str = string.format(textRes.AnnounceMent[25], roleName1, color, itemBase.name, itemNum, roleName2)
  if flowerCfg.isservereffect then
    local NoticeType = require("consts.mzm.gsp.function.confbean.NoticeType")
    require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleId(str, NoticeType.SEND_FLOWER)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Flower, {
    name1 = roleName1,
    name2 = roleName2,
    itemName = itemBase.name,
    itemColor = color,
    num = itemNum
  })
end
def.static("table").onJingJiContinueWin = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local virtoryCount = params[ParamType.VICTORY_COUNT]
  local str = string.format(textRes.AnnounceMent[20], roleName, virtoryCount)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.JingJiLianSheng, {name = roleName, count = virtoryCount})
end
def.static("table").onJingJiLegend = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local str = string.format(textRes.AnnounceMent[22], roleName)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.JingJiChuanShuo, {name = roleName})
end
def.static("table").onLotteryAwardItem = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local lotteryId = tonumber(params[ParamType.LOTTERY_ID])
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local ItemUtils = require("Main.Item.ItemUtils")
  local lotteryItem = ItemUtils.GetItemBase(lotteryId)
  local item = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[18], roleName, lotteryItem.name, require("Main.Chat.HtmlHelper").NameColor[item.namecolor], item.name)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Lottery, {
    name = roleName,
    lottery = lotteryItem.name,
    color = item.namecolor,
    item = item.name
  })
end
def.static("table").onBaoTuAwardItem = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local baotuId = tonumber(params[ParamType.BAOTU_ID])
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local ItemUtils = require("Main.Item.ItemUtils")
  local baotu = ItemUtils.GetItemBase(baotuId)
  local item = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[15], roleName, baotu.name, require("Main.Chat.HtmlHelper").NameColor[item.namecolor], item.name)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.BaoTuItem, {
    name = roleName,
    baotu = baotu.name,
    color = item.namecolor,
    item = item.name
  })
end
def.static("table").onTuxiRefresh = function(params)
  AnnouncementTip.Announce(textRes.AnnounceMent[7])
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Tuxi, {
    text = textRes.AnnounceMent[14]
  })
end
def.static("table").onShengXiao = function(params)
  AnnouncementTip.Announce(textRes.AnnounceMent[6])
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.ShengXiao, {
    text = textRes.AnnounceMent[6]
  })
end
def.static("table").onBaoTuTriggerCtrl = function(params)
  local rolelName = params[ParamType.ROLE_NAME1]
  local mapName = params[ParamType.PLACE_NAME]
  local type = tonumber(params[ParamType.IS_SUPER])
  if type == 1 then
    AnnouncementTip.Announce(string.format(textRes.AnnounceMent[10], rolelName, mapName))
  elseif type == 0 then
    AnnouncementTip.Announce(string.format(textRes.AnnounceMent[5], rolelName, mapName))
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.BaoTu, {
    name = rolelName,
    mapname = mapName,
    type = type
  })
end
def.static("table").onGangCreate = function(params)
  local gangName = params[ParamType.GANG_NAME]
  AnnouncementTip.Announce(string.format(textRes.AnnounceMent[4], gangName))
  local hasGang = require("Main.Gang.GangModule").Instance():HasGang()
  if hasGang then
    return
  end
  local gangId = string.format("applyGang_%s", params[ParamType.GANG_ID])
  local button = string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", gangId, gangId, link_defalut_color, textRes.Gang[258])
  local content = string.format(textRes.Gang[153], gangName)
  local str = string.format("%s%s", content, button)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  ChatModule.Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.NEWER)
end
def.static("table").onRoleEquipLingLevel = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local itemId = tonumber(params[ParamType.ITEM_ID])
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local level = itemBase.useLevel
  local type = itemBase.itemTypeName
  local itemName = itemBase.name
  local qlLevel = params[ParamType.EQUIP_LING_LEVEL]
  local content = string.format(textRes.AnnounceMent[1], roleName, level, type, itemName, qlLevel)
  AnnouncementTip.Announce(content)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.QiLing, {
    name = roleName,
    wearLevel = level,
    wearPos = type,
    itemName = itemName,
    qilingLevel = qlLevel
  })
end
def.static("table").onTuxiWin = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local monsterName = params[ParamType.MONSTER_NAME]
  local content = string.format(textRes.AnnounceMent[2], monsterName, roleName)
  AnnouncementTip.Announce(content)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.TuXiWin, {name = roleName, monsterName = monsterName})
end
def.static("table").onTuxiLost = function(params)
  local roleName = params[ParamType.ROLE_NAME1]
  local monsterName = params[ParamType.MONSTER_NAME]
  local placeName = params[ParamType.PLACE_NAME]
  if placeName then
    local content = string.format(textRes.AnnounceMent[3], roleName, placeName, monsterName)
    AnnouncementTip.Announce(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.TuXiLost, {
      name = roleName,
      monsterName = monsterName,
      place = placeName
    })
  else
    local content = string.format(textRes.AnnounceMent[35], roleName, monsterName)
    AnnouncementTip.Announce(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.TuXiLost, {name = roleName, monsterName = monsterName})
  end
end
def.static("table").onRoleRename = function(params)
  local oldName = params[ParamType.ROLE_NAME1]
  local newName = params[ParamType.ROLE_NAME2]
  local content = string.format(textRes.AnnounceMent[17], oldName, newName)
  AnnouncementTip.Announce(content)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.RoleRename, {oldName = oldName, newName = newName})
end
def.static("table").onJiuXiaoWillClose = function(params)
  local leftMinute = params[ParamType.JIU_XIAO_LEFT_MINUTE]
  local content = string.format(textRes.AnnounceMent[24], leftMinute)
  AnnouncementTip.Announce(content)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.JiuXiaoWillClose, {leftMinute = leftMinute})
end
def.static().onKejuDianshiStart = function()
end
def.static("table").onShowKejuTop = function(params)
  local firstName = params[ParamType.ROLE_NAME1] or " "
  local secondName = params[ParamType.ROLE_NAME2] or " "
  local thirdName = params[ParamType.ROLE_NAME3] or " "
  local content = textRes.Keju[54]
  if firstName ~= " " then
    content = string.format(textRes.AnnounceMent[57], firstName)
    if secondName ~= " " then
      content = string.format(textRes.AnnounceMent[58], firstName, secondName)
      if thirdName ~= " " then
        content = string.format(textRes.AnnounceMent[46], firstName, secondName, thirdName)
      end
    end
  end
  AnnouncementTip.Announce(content)
  local chatSystemContent = {
    name1 = firstName,
    name2 = secondName,
    name3 = thirdName
  }
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.KejuTop, chatSystemContent)
end
def.static("table").onSBrocastYaoShouItem = function(p)
  local name = p.roleName
  local itemStr = AnnouncementModule.ItemsToDescription(p.itemid2count)
  local content = string.format(textRes.AnnounceMent[64], name, itemStr)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetAwardBulletinType(p.itemid2count) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(content)
  else
    AnnouncementTip.Announce(content)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
end
def.static("table").onSBrocastShengXiaoItem = function(p)
  local name = p.roleName
  local itemStr = AnnouncementModule.ItemsToDescription(p.itemid2count)
  local content = string.format(textRes.AnnounceMent[65], name, itemStr)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetAwardBulletinType(p.itemid2count) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(content)
  else
    AnnouncementTip.Announce(content)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
end
def.static("table").onSBrocastBountyItem = function(p)
  local name = p.roleName
  local taskCfg = require("Main.task.TaskInterface").GetTaskCfg(p.taskId)
  if taskCfg == nil then
    return
  end
  local taskName = taskCfg.taskName
  local itemStr = AnnouncementModule.ItemsToDescription(p.itemid2count)
  local content = string.format(textRes.AnnounceMent[66], name, taskName, itemStr)
  AnnouncementTip.Announce(content)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
end
def.static("table").onSChangeModelCardLotteryBrd = function(p)
  local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
  local cardItemCfg = TurnedCardUtils.GetChangeModelCardItemCfg(p.item_cfg_id)
  if cardItemCfg then
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardItemCfg.cardCfgId)
    local content = string.format(textRes.AnnounceMent[116], p.role_name, textRes.TurnedCard.levelColor[cardItemCfg.cardLevel], cardCfg.cardName)
    AnnouncementTip.Announce(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
  end
end
def.static("table", "=>", "string").ItemsToDescription = function(itemIds2Count)
  local ItemUtils = require("Main.Item.ItemUtils")
  local strTable = {}
  for k, v in pairs(itemIds2Count) do
    local itemBase = ItemUtils.GetItemBase(k)
    if itemBase then
      if #strTable > 0 then
        table.insert(strTable, textRes.AnnounceMent[52])
      end
      local str = string.format("[%s]%s\195\151%d[-]", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name, v)
      table.insert(strTable, str)
    end
  end
  return table.concat(strTable)
end
def.static("table").onRedGiftTimeCount = function(p)
  local time = p[ParamType.HB_TIME]
  local content = string.format(textRes.AnnounceMent[67], time)
  AnnouncementTip.Announce(content)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
end
def.static("table").onPetComprehendSkill = function(p)
  local roleName = p[ParamType.ROLE_NAME1] or " "
  local petId = tonumber(p[ParamType.PET_ID]) or 0
  local skillId = tonumber(p[ParamType.SKILL_ID]) or 0
  local petName = require("Main.Pet.PetUtility").Instance():GetPetCfg(petId).templateName
  local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
  local skillName = " "
  if skillCfg then
    skillName = skillCfg.name
  end
  local content = string.format(textRes.AnnounceMent[69], roleName, petName, skillName)
  AnnouncementTip.Announce(content)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.PetComprehendSkill, {
    roleName = roleName,
    petName = petName,
    skillName = skillName
  })
end
def.static("table").onPetSkillLevelUp = function(p)
  local roleName = p[ParamType.ROLE_NAME1] or " "
  local petId = tonumber(p[ParamType.PET_ID]) or 0
  local skillId1 = tonumber(p[ParamType.SKILL_ID]) or 0
  local skillId2 = tonumber(p[ParamType.SKILL_ID2]) or 0
  local petName = require("Main.Pet.PetUtility").Instance():GetPetCfg(petId).templateName
  local skillName1 = " "
  local skillName2 = " "
  local skillCfg1 = require("Main.Skill.SkillUtility").GetSkillCfg(skillId1)
  local skillCfg2 = require("Main.Skill.SkillUtility").GetSkillCfg(skillId2)
  if skillCfg1 then
    skillName1 = skillCfg1.name
  end
  if skillCfg2 then
    skillName2 = skillCfg2.name
  end
  local content = string.format(textRes.AnnounceMent[70], roleName, petName, skillName1, skillName2)
  AnnouncementTip.Announce(content)
  local chatContent = {
    roleName = roleName,
    petName = petName,
    skillName1 = skillName1,
    skillName2 = skillName2
  }
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.PetSkillLevelUp, chatContent)
end
def.static("table").onOnlineBoxAward = function(p)
  local itemId = tonumber(p[ParamType.ITEM_ID])
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemDesc = string.format("[%s]%s[-]", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  local str = string.format(textRes.AnnounceMent[73], p[ParamType.ROLE_NAME1], itemDesc)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("string").OnWorldGoalSectionComplete = function(mapName)
  if nil == mapName then
    return
  end
  AnnouncementTip.Announce(string.format(textRes.WorldGoal[6], mapName))
  local mapInfo = string.format(textRes.WorldGoal[7], mapName)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.WorldGoalComplete, {mapInfo = mapInfo})
end
def.static("string").AnnounceFestivalCountDown = function(announceDesc)
  AnnouncementTip.Announce(announceDesc)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.FestivalCountDown, {announceMent = announceDesc})
end
def.static("table").OnAnnouncementPayNewYearAward = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local rolename = p[ParamType.ROLE_NAME1] or ""
  local itemId = tonumber(p[ParamType.ITEM_ID])
  local itemNum = tonumber(p[ParamType.ITEM_NUM])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[88], rolename, itemBase.name)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementSignPreciousAward = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local rolename = p[ParamType.ROLE_NAME1] or ""
  local itemId = tonumber(p[ParamType.ITEM_ID])
  local itemNum = tonumber(p[ParamType.ITEM_NUM])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[89], rolename, itemBase.name)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleSelectionBegin = function(p)
  local str = textRes.AnnounceMent[92]
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], str), 0, "Group_3")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleSelectionRankUp = function(p)
  local corpsName = p[ParamType.CORPS_NAME] or ""
  local stage = tonumber(p[ParamType.RANK_UP_SELECTION_STAGE] or 0)
  local stageStr
  local CrossBattleSelectionStageEnum = require("consts.mzm.gsp.crossbattle.confbean.CrossBattleSelectionStageEnum")
  local tipsStr = {
    [16] = textRes.AnnounceMent[95],
    [8] = textRes.AnnounceMent[96],
    [4] = textRes.AnnounceMent[97],
    [2] = textRes.AnnounceMent[98]
  }
  stageStr = tipsStr[stage]
  if corpsName == "" or stageStr == nil then
    warn("OnAnnouncementCrossBattleSelectionRankUp data is error")
    return
  end
  local str = string.format(textRes.AnnounceMent[94], corpsName, stageStr)
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], str), 0, "Group_3")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleSelectionRankUpFinal = function(p)
  local corpsName = p[ParamType.CORPS_NAME] or ""
  local str = string.format(textRes.AnnounceMent[102], corpsName)
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], str), 0, "Group_3")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleSelectionCompeleteChampion = function(p)
  local corpsName = p[ParamType.CORPS_NAME] or ""
  local str = string.format(textRes.AnnounceMent[115], corpsName)
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], str), 0, "Group_3")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleSelectionWinTitle = function(p)
  local corpsName = p[ParamType.CORPS_NAME] or ""
  local zone = tonumber(p[ParamType.SELECTION_FIGHT_ZONE] or 0)
  local rank = tonumber(p[ParamType.SELECTION_TITLE] or 0)
  local titleStr
  if rank == 1 then
    titleStr = textRes.AnnounceMent[99]
  elseif rank == 2 then
    titleStr = textRes.AnnounceMent[100]
  elseif rank == 3 then
    titleStr = textRes.AnnounceMent[101]
  end
  if corpsName == "" or titleStr == nil then
    warn("OnAnnouncementCrossBattleSelectionWinTitle data is error")
    return
  end
  local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
  local str = string.format(textRes.AnnounceMent[103], corpsName, PointsRaceUtils.GetZoneName(zone), titleStr)
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], str), 0, "Group_3")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementBuyedMysteryGoods = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemId = tonumber(p[ParamType.ITEM_ID])
  local rolename = p[ParamType.ROLE_NAME1] or ""
  local discount = p[ParamType.RATE] / 1000
  local itemBase = ItemUtils.GetItemBase(itemId)
  local str = textRes.AnnounceMent[93]:format(rolename, discount, itemBase.name)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleFinalBegin = function(p)
  local str = textRes.AnnounceMent[105]
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], str), 0, "Group_3")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleFinalRankUp = function(p)
  local corpsName = p[ParamType.CORPS_NAME] or ""
  local stage = tonumber(p[ParamType.RANK_UP_SELECTION_STAGE] or 0)
  local stageStr
  local tipsStr = {
    [8] = textRes.AnnounceMent[96],
    [4] = textRes.AnnounceMent[97],
    [2] = textRes.AnnounceMent[98]
  }
  stageStr = tipsStr[stage]
  if corpsName == "" or stageStr == nil then
    warn("OnAnnouncementCrossBattleFinalRankUp data is error")
    return
  end
  local str = string.format(textRes.AnnounceMent[106], corpsName, stageStr)
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], str), 0, "Group_3")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleCompeteFinal = function(p)
  local corpsName = p[ParamType.CORPS_NAME] or ""
  local zoneId = tonumber(p[ParamType.ZONE_ID] or 0)
  if corpsName == "" then
    warn("OnAnnouncementCrossBattleCompeteFinal corpsName is error")
    return
  end
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(zoneId)
  local serverName = serverCfg and serverCfg.name or ""
  local str = string.format(textRes.AnnounceMent[109], serverName, corpsName)
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], str), 0, "Group_3")
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementCrossBattleFinalWinTitle = function(p)
  local corpsName = p[ParamType.CORPS_NAME] or ""
  local rank = tonumber(p[ParamType.SELECTION_TITLE] or 0)
  local zoneId = tonumber(p[ParamType.ZONE_ID] or 0)
  local tipsStr
  if corpsName == "" then
    warn("OnAnnouncementCrossBattleFinalWinTitle corps data is error")
    return
  end
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(zoneId)
  local serverName = serverCfg and serverCfg.name or ""
  if rank == 1 then
    tipsStr = string.format(textRes.AnnounceMent[107], serverName, corpsName, textRes.AnnounceMent[99])
  elseif rank == 2 then
    tipsStr = string.format(textRes.AnnounceMent[108], serverName, corpsName, textRes.AnnounceMent[100])
  elseif rank == 3 then
    tipsStr = string.format(textRes.AnnounceMent[108], serverName, corpsName, textRes.AnnounceMent[101])
  end
  if tipsStr == nil then
    warn("OnAnnouncementCrossBattleFinalWinTitle rank data is error")
    return
  end
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(string.format(textRes.CrossBattle[109], tipsStr), 0, "Group_3")
  AnnouncementTip.Announce(tipsStr)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tipsStr})
end
def.static("table").OnAnnouncementMonkeyRunInnerAward = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local rolename = p[ParamType.ROLE_NAME1] or ""
  local itemId = tonumber(p[ParamType.ITEM_ID])
  local itemNum = tonumber(p[ParamType.ITEM_NUM])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[111], rolename, itemBase.name, itemNum)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementMonkeyRunOutAward = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local rolename = p[ParamType.ROLE_NAME1] or ""
  local itemId = tonumber(p[ParamType.ITEM_ID])
  local itemNum = tonumber(p[ParamType.ITEM_NUM])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[110], rolename, itemBase.name, itemNum)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementChristmasStockingAward = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local rolename = p[ParamType.ROLE_NAME1] or ""
  local itemId = tonumber(p[ParamType.ITEM_ID])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local str = string.format(textRes.AnnounceMent[118], rolename, itemBase.name)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnAnnouncementDragonBitAward = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local rolename = p[ParamType.ROLE_NAME1] or ""
  local itemId = tonumber(p[ParamType.ITEM_ID])
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemNum = p[ParamType.ITEM_NUM]
  local color = require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor]
  local str = string.format(textRes.AnnounceMent[119], rolename, color, itemBase.name .. "X" .. itemNum)
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetItemBulletinType(itemId) == BulletinType.UNUSUAL then
    RareItemAnnouncementTip.AnnounceRareItem(str)
  else
    AnnouncementTip.Announce(str)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
AnnouncementModule.Commit()
return AnnouncementModule
