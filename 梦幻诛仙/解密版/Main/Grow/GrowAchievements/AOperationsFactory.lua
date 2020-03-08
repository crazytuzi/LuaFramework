local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OperationsFactory = Lplus.Class(CUR_CLASS_NAME)
local Operation = import("..Operations.Operation")
local GoalGuideType = require("consts.mzm.gsp.grow.confbean.GoalGuideType")
local def = OperationsFactory.define
local function GetType(attr)
  return GoalGuideType[attr] or 0
end
local operationNames = {
  [GetType("OPEN_PET")] = "OpenPetPanel",
  [GetType("OPEN_PET_JN")] = "OpenPetPanelSkill",
  [GetType("OPEN_PET_HS")] = "OpenPetPanelHuaSheng",
  [GetType("OPEN_PET_FS")] = "OpenPetPanelFanSheng",
  [GetType("OPEN_PETTJ_BASIC")] = "OpenPetTuJianSpeBaoBao",
  [GetType("OPEN_PETTJ_SPEC")] = "OpenPetTuJianCurBianYi",
  [GetType("FRIEND_OWN")] = "OpenFriendList",
  [GetType("PATH_FINDING_MAIN")] = "FinishMajorTask",
  [GetType("OPEN_PARTNER")] = "OpenPartnerPanel",
  [GetType("OPEN_GANG1")] = "OpenGangPanel",
  [GetType("OPEN_GANG2")] = "OpenGangPanel",
  [GetType("OPEN_GANG_FL")] = "OpenGangPanelWelfare",
  [GetType("OPEN_CHAT_GANG")] = "OpenGangPanelChat",
  [GetType("OPEN_CHAT_TEAM")] = "ChatWithTeamMenbers",
  [GetType("OPEN_CHAT_WORLD")] = "ChatInWorld",
  [GetType("OPEN_CHAT_FRIEND")] = "ChatWithFriends",
  [GetType("OPEN_COMMERCE_TAN")] = "OpenPitchPanelSell",
  [GetType("OPEN_COMMERCE_TAN_BUY")] = "OpenPitchPanelBuy",
  [GetType("OPEN_JIAOYIHANG_BUY")] = "OpenTradingArcadeBuy",
  [GetType("OPEN_JIAOYIHANG_SELL")] = "OpenTradingArcadeSell",
  [GetType("OPEN_ZHENFA")] = "OpenFormationPanel",
  [GetType("OPEN_Mall_XPG")] = "OpenMallPrecious",
  [GetType("OPEN_Mall_MZXG")] = "OpenMallWeeklyLimit",
  [GetType("OPEN_LIFESKILL_FOOD")] = "LocateCookingSkill",
  [GetType("OPEN_LIFESKILL_DRUG")] = "LocateMakeDrugSkill",
  [GetType("OPEN_FUMO")] = "OpenMakeEnchantingItemPanel",
  [GetType("OPEN_SEND_ITEM")] = "OpenPresentPanelItem",
  [GetType("OPEN_SEND_FLOWER")] = "OpenPresentPanelGift",
  [GetType("OPEN_SKILL_SCHOOL")] = "OpenSkillPanel",
  [GetType("OPEN_SKILL_LIFE")] = "OpenSkillPanelLiving",
  [GetType("OPEN_SKILL_EXERCISE")] = "OpenSkillPanelExercise",
  [GetType("OPEN_HUOLI")] = "OpenHeroEnergyPanelFWorking",
  [GetType("PATH_FINDING_ACTIVITY")] = "ParticipateActivity",
  [GetType("OPEN_GUAJI")] = "OpenOnHookPanel",
  [GetType("OPEN_EQUIP_DZ")] = "OpenEquipSocialPanel",
  [GetType("OPEN_EQUIP_QL")] = "OpenEquipSocialPanelQL",
  [GetType("OPEN_EQUIP_FH")] = "OpenEquipSocialPanelFH",
  [GetType("OPEN_EQUIP_XH")] = "OpenEquipSocialPanelXH",
  [GetType("OPEN_CHARACTER")] = "OpenHeroPanelFAsignProp",
  [GetType("OPEN_PEIZE_QD")] = "OpenAwardPanelSignIn",
  [GetType("OPEN_PEIZE_LD")] = "OpenAwardPanelLogin",
  [GetType("OPEN_PEIZE_LVUP")] = "OpenAwardPanelLevelUp",
  [GetType("OPEN_CHARACTER_YY")] = "OpenWingsPanel",
  [GetType("OPEN_FABAO")] = "OpenFabaoPanel",
  [GetType("OPEN_FABAO_CZ")] = "OpenFabaoPanelGrow"
}
local CreateAndInit = function(class, id)
  local obj = class()
  obj:Init(id)
  return obj
end
local function GetOperationClass(operationType)
  local operationName = operationNames[operationType]
  if operationName then
    operationName = string.format("..Operations.%s", operationName)
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
