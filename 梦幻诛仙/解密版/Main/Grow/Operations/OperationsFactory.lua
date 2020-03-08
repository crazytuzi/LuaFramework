local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OperationsFactory = Lplus.Class(CUR_CLASS_NAME)
local Operation = import(".Operation")
local StrongerSubType = require("consts.mzm.gsp.grow.confbean.StrongerSubType")
local def = OperationsFactory.define
local function GetType(attr)
  return StrongerSubType[attr] or 0
end
local operationNames = {
  [GetType("OPEN_UI_PETTJ_FIRST")] = ".OpenPetTuJianSpeBaoBao",
  [GetType("OPEN_UI_PET_FS")] = ".OpenPetPanelFanSheng",
  [GetType("OPEN_UI_PET_ATTRIBUTE")] = ".OpenPetAndAssignPropPanel",
  [GetType("OPEN_UI_PET_HS")] = ".OpenPetPanelHuaSheng",
  [GetType("OPEN_UI_PET_JN")] = ".OpenPetPanelSkill",
  [GetType("OPEN_UI_PET_DECORATION")] = ".OpenPetAndDecoratePanel",
  [GetType("OPEN_PET")] = ".OpenPetPanel",
  [GetType("OPEN_PET_JN")] = ".OpenPetPanelSkill",
  [GetType("OPEN_PETTJ_BASIC")] = ".OpenPetTuJianSpeBaoBao",
  [GetType("OPEN_PETTJ_SPEC")] = ".OpenPetTuJianCurBianYi",
  [GetType("PATH_FINDING_MAIN")] = ".FinishMajorTask",
  [GetType("FRIEND_OWN")] = ".OpenFriendList",
  [GetType("OPEN_UI_PARTNER_FIRST")] = ".OpenPartnerPanelFirstUnivited",
  [GetType("OPEN_UI_PARTNER_FIRST_XL")] = ".OpenPartnerPanelFirstJoined",
  [GetType("OPEN_UI_PARTNER_BZ")] = ".OpenPartnerPanelBZ",
  [GetType("OPEN_GANG1")] = ".OpenGangPanel",
  [GetType("OPEN_GANG2")] = ".OpenGangPanel",
  [GetType("OPEN_GANG_FL")] = ".OpenGangPanelWelfare",
  [GetType("OPEN_CHAT_GANG")] = ".OpenGangPanelChat",
  [GetType("OPEN_CHAT_TEAM")] = ".ChatWithTeamMenbers",
  [GetType("OPEN_CHAT_WORLD")] = ".ChatInWorld",
  [GetType("OPEN_CHAT_FRIEND")] = ".ChatWithFriends",
  [GetType("OPEN_UI_BUY_GOLD")] = ".OpenBuyGoldPanel",
  [GetType("OPEN_UI_BUY_SILVER")] = ".OpenBuySilverPanel",
  [GetType("OPEN_UI_COMMERCE")] = ".OpenCommercePanel",
  [GetType("OPEN_UI_COMMERCE_SELL")] = ".OpenPitchPanelSell",
  [GetType("OPEN_UI_COMMERCE_ITEM")] = ".OpenCommercePanel",
  [GetType("OPEN_COMMERCE_TAN")] = ".OpenPitchPanelSell",
  [GetType("OPEN_COMMERCE_TAN_BUY")] = ".OpenPitchPanelBuy",
  [GetType("OPEN_JIAOYIHANG_BUY")] = ".OpenTradingArcadeBuy",
  [GetType("OPEN_JIAOYIHANG_SELL")] = ".OpenTradingArcadeSell",
  [GetType("OPEN_Mall_XPG")] = ".OpenMallPrecious",
  [GetType("OPEN_Mall_MZXG")] = ".OpenMallWeeklyLimit",
  [GetType("OPEN_Mall_PAY")] = ".OpenChargePanel",
  [GetType("OPEN_Mall_TO_XX")] = ".OpenMallToNode",
  [GetType("OPEN_JI_FEN_DUI_HUAN")] = ".OpenJiFenDuiHuan",
  [GetType("OPEN_UI_SKILL_SCHOOL")] = ".OpenSkillPanel",
  [GetType("OPEN_UI_SKILL_EXERCISE")] = ".OpenSkillPanelExercise",
  [GetType("OPEN_UI_SKILL_GANG")] = ".OpenSkillPanelGang",
  [GetType("OPEN_SKILL_LIFE")] = ".OpenSkillPanelLiving",
  [GetType("OPEN_HUOLI")] = ".OpenHeroEnergyPanelFWorking",
  [GetType("PATH_FINDING_ACT_NPC")] = ".ParticipateActivity",
  [GetType("PATH_LSYM_LV_MAP")] = ".GoToLuanShiYaoMoMap",
  [GetType("OPEN_UI_ACTIVTY_LOCAL")] = ".OpenActivityAndTipPanel",
  [GetType("OPEN_UI_ACTIVTY_WEEKLY_LOCAL")] = ".OpenActivityWeeklyAndTipPanel",
  [GetType("OPEN_UI_ACTIVTY_WEEKLY_NIGHT")] = ".OpenActivityWeeklyAndTipPanelByTime",
  [GetType("OPEN_UI_JJC")] = ".OpenArenaPanel",
  [GetType("PATH_FINDING_ACTIVITY")] = ".ParticipateActivity",
  [GetType("OPEN_EXCHANGE")] = ".OpenActivityExchangePanel",
  [GetType("OPEN_ACTIVITY_2_FESTIVAL")] = ".OpenActivityPanelFestival",
  [GetType("OPEN_GUAJI")] = ".OpenOnHookPanel",
  [GetType("OPEN_UI_EQUIP_DZ")] = ".OpenEquipSocialPanel",
  [GetType("OPEN_UI_EQUIP_QL")] = ".OpenEquipSocialPanelQL",
  [GetType("OPEN_UI_EQUIP_XH")] = ".OpenEquipSocialPanelXH",
  [GetType("OPEN_UI_EQUIP_FH")] = ".OpenEquipSocialPanelFH",
  [GetType("OPEN_UI_CHARACTER_ATTRIBUTE")] = ".OpenHeroPropAndAsignPropPanel",
  [GetType("OPEN_CHARACTER")] = ".OpenHeroPanelFAsignProp",
  [GetType("OPEN_UI_CREDITSSHOP_CLASS_1")] = ".OpenCreditsShopPanelXiaYi",
  [GetType("OPEN_UI_CREDITSSHOP_CLASS_3")] = ".OpenCreditsShopPanelREP",
  [GetType("OPEN_PEIZE_QD")] = ".OpenAwardPanelSignIn",
  [GetType("OPEN_PEIZE_LD")] = ".OpenAwardPanelLogin",
  [GetType("OPEN_PEIZE_LVUP")] = ".OpenAwardPanelLevelUp",
  [GetType("OPEN_DOUBLE_WEEK_CARD_TAB")] = ".OpenAwardPanelDbFareCard",
  [GetType("OPEN_GROW_LEVEL_FUND_TAB")] = ".OpenAwardPanelGrowFund",
  [GetType("OPEN_DAILY_GIFT_TAB")] = ".OpenAwardPanelDailyGift",
  [GetType("OPEN_LUCKY_BOX_TAB")] = ".OpenFuYuanBox",
  [GetType("OPEN_UI_WING")] = ".OpenWingsPanel",
  [GetType("OPEN_UI_FABAO")] = ".OperationOpenFabaoPanel",
  [GetType("OPEN_FABAO_CZ")] = ".OpenFabaoPanelGrow",
  [GetType("OPEN_ZHENFA")] = ".OpenFormationPanel",
  [GetType("OPEN_LIFESKILL_FOOD")] = ".LocateCookingSkill",
  [GetType("OPEN_LIFESKILL_DRUG")] = ".LocateMakeDrugSkill",
  [GetType("OPEN_FUMO")] = ".OpenMakeEnchantingItemPanel",
  [GetType("OPEN_SEND_ITEM")] = ".OpenPresentPanelItem",
  [GetType("OPEN_SEND_FLOWER")] = ".OpenPresentPanelGift",
  [GetType("OPEN_STRONGER_PANEL")] = ".OpenStrongerLevelUpPanel",
  [GetType("OPEN_STRONGER")] = ".OpenStrongerPanel",
  [GetType("OPEN_BAG_PANEL")] = ".OpenBagPanel",
  [GetType("OPEN_TIME_LIMIT_FEED_BACK")] = ".OpenCustomActivityPanel",
  [GetType("OPEN_HOME_LAND")] = ".OpenBackHomelandPanel",
  [GetType("OPEN_MOUNTS")] = ".OpenMountsPanel",
  [GetType("OPEN_DIRECTIONAL_FLOW")] = ".OpenSpecialTrafficURL",
  [GetType("H5IAP_ACTIVITY")] = ".OpenIAPWebview"
}
local CreateAndInit = function(class, id)
  local obj = class()
  obj:Init(id)
  return obj
end
local function GetOperationClass(operationType)
  local operationName = operationNames[operationType]
  if operationName then
    return import(operationName, CUR_CLASS_NAME)
  else
    return Operation
  end
end
def.static("number", "=>", Operation).CreateOperation = function(operationType)
  local OperationClass = GetOperationClass(operationType)
  return CreateAndInit(OperationClass, operationType)
end
return OperationsFactory.Commit()
