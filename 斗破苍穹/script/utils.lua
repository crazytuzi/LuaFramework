require"Lang"
utils = { }
GlobalLastFightCheckData = nil -- 保存最近战斗的校验数据
require "formula"
require "FightTaskInfo"
require "fightTaskData"
require "PVPUtils"
require "guideInfo"

-- 导入静态常量类
require "StaticMsgRule"
require "StaticEquip_Type"
require "StaticFightProp"
require "StaticTableType"
require "StaticCardBaseProp"
require "StaticThing"
require "StaticSysConfig"
require "StaticEquip_Quality"
require "StaticQuality"
require "StaticPillQuality"
require "StaticPillType"
require "StaticBag_Type"
require "StaticGemLevel"
require "StaticRecruit_Type"
require "StaticKungFuQuality"
require "StaticFunctionOpen"
require "StaticFireSkillQuality"
require "StaticMagicQuality"
require "StaticThing_Type"
require "StaticPlayerBaseProp"
require "StaticCardType"
require "StaticSysConfig_Str"
require "StaticSysConfigStr"
require "StaticTryToPracticeType"
require "StaticUnionSkillNoFightProp"


-- 导入字典数据类
-- require "DictAcupointNode"
require "DictAdvance"
require "DictCard"
require "DictCardExp"
require "DictCardLuck"
require "DictCardType"
require "DictCardExpAdd"
require "DictCardBaseProp"
require "DictCardJump"
require "DictCardJumpPos"
require "DictEquipment"
require "DictEquipType"
require "DictEquipWash"
require "DictEquipStrengthen"
require "DictFightProp"
require "DictFightType"
require "DictInitCard"
-- require "DictKungFu"
-- require "DictKungFuQuality"
-- require "DictKungFuTierAdd"
-- require "DictKungFuType"
require "DictQuality"
require "DictStarLevel"
require "DictTableType"
require "DictThing"
require "DictTitle"
require "DictTitleDetail"
require "DictTrainProp"
require "DictUI"
require "DictFireGainRule"
require "DictFire"
require "DictFireExp"
require "DictFireSkill"
require "DictFireSkillQuality"
require "DictSysConfig"
require "DictEquipQuality"
require "DictQuality"
require "DictPlayerBaseProp"
require "DictConstell"
require "DictPill"
require "DictPillQuality"
require "DictPillRecipe"
require "DictPillThing"
require "DictPillType"
require "DictBagType"
require "DictHoleConsume"
require "DictPagodaCard"
require "DictPagodaDrop"
require "DictPagodaFormation"
require "DictPagodaStorey"
require "DictRecruitCard"
require "DictChapter"
require "DictBarrier"
require "DictBarrierLevel"
require "DictLevelProp"
require "DictBarrierDrop"
require "DictCardSoul"
require "DictChip"
require "DictManualSkill"
require "DictManualSkillExp"
require "DictRestore"
require "DictBarrierCard"
require "DictVIP"
require "DictAuctionShop"
require "DictActivityLevelBag"
require "DictActivityOpenServiceBag"
require "DictCoefficient"
require "DictArenaConvert"
require "DictFunctionOpen"
require "DictMagic"
require "DictMagicLevel"
require "DictMagicQuality"
require "DictDailyTask"
require "DictAchievement"
require "DictAchievementType"
require "DictGenerBoxThing"
require "DictSpecialBoxThing"
require "DictBeautyCard"
require "DictBeautyCardFight"
require "DictBeautyCardExp"
require "DictSysConfigStr"
if device.platform == "ios" then
    -- 暂以平台区分
    require "DictRechargeForIOS"
else
    require "DictRecharge"
end
require "DictActivityFlashSale"
require "DictActivityFund"
require "DictActivityStarStore"
require "DictTryToPractice"
require "DictTryToPracticeType"
require "DictTryToPracticeBarrierCard"
require "DictEquipAdvance"
require "DictPagodaStore"
require "DictThingExtend"
require "DictUnionGrade"
require "DictUnionLevelPriv"
require "DictUnionBuild"
require "DictUnionBox"
require "DictEquipSuitRefer"
require "DictEquipSuit"
require "DictDantaLayer"
require "DictDantaMonster"
require "DictDantaDayAward"
require "DictFightSoul"
require "DictFightSoulQuality"
require "DictFightSoulHuntRule"
require "DictFightSoulUpgradeProp"
require "DictFightSoulUpgradeExp"
require "DictYFire"
require "DictYFireChip"
require "DictWing"
require "DictWingAdvance"
require "DictWingStrengthen"
require "DictWingLuck"
require "CustomDictYFireProp"
require "CustomDictWorldBoss"
require "CustomDictAllianceBoss"
require "DictWorldBossTimesReward"
require "DictEquipAdvancered"
require "DictHoldStarGrade"
require "DictHoldStarRewardPos"
require "DictHoldStarZodiac"
require "DictHoldStarStep"
require "DictHoldStarRewardRefreshTimes"
require "DictMagicrefining"
require "DictUnionMaterial"
require "DictUnionPractice"
require "DictUnionFam"
require "DictUnionFlag"
require "DictUnionPracticeUpgrade"
require "DictUnionPracticeConsum"
require "DictUnionSkillNoFightProp"
require "DictPartnerLuckPos"
require "DictRunShow"
require "DictUnionLootConfig"
require "DictUnionLootPer"
require "DictActivityPerfectVictory"
require "DictActivityshare"
require "DictUnionLootStealTimes"
require "DictEnchantment"
require "DictEquipBox"
require "DictChallengeLevelDanNickname"
require "DictChallengeRewardDaily"
require "DictChallengeRewardWeekly"
require "DictChallengeRewardMonthly"
require "DictChallengeBuyPrice"
require "DictChallengeRewardEvery"
require "DictArenaStrongMan"
utils.enterBackgroundTime = 0
utils.intervalTime = 0
utils.countDownScheduleId = nil
utils.LevelUpgrade = false
utils.time_stamp = nil

--- 战力值的转换比例
utils.FightValueFactor = { }
utils.FightValueFactor[StaticFightProp.blood] = 1 -- 生命
utils.FightValueFactor[StaticFightProp.wAttack] = 0.53 -- 物攻
utils.FightValueFactor[StaticFightProp.fAttack] = 0.53 -- 法攻
utils.FightValueFactor[StaticFightProp.dodge] = 1 -- 闪避
utils.FightValueFactor[StaticFightProp.crit] = 1 -- 暴击
utils.FightValueFactor[StaticFightProp.hit] = 4 -- 命中
utils.FightValueFactor[StaticFightProp.flex] = 4 -- 抗暴
utils.FightValueFactor[StaticFightProp.wDefense] = 0.2 -- 物防
utils.FightValueFactor[StaticFightProp.fDefense] = 0.2 -- 法防

--- 获取卡牌品质框图片
local function getCardQualityImage(cardQualityId, flag, isBar)
    local colorName = nil
    if tonumber(cardQualityId) == tonumber(StaticQuality.white) then
        colorName = "white"
    elseif tonumber(cardQualityId) == tonumber(StaticQuality.green) then
        colorName = "green"
    elseif tonumber(cardQualityId) == tonumber(StaticQuality.blue) then
        colorName = "blue"
    elseif tonumber(cardQualityId) == tonumber(StaticQuality.purple) then
        colorName = "purple"
    elseif tonumber(cardQualityId) == tonumber(StaticQuality.red) then
        colorName = "red"
    elseif tonumber(cardQualityId) == tonumber(StaticQuality.gold) then
        colorName = "gold"
    end
    if colorName then
        if flag == dp.QualityImageType.small then
            if isBar then
                return "ui/quality_small_bar_" .. colorName .. ".png"
            else
                return "ui/card_small_" .. colorName .. ".png"
            end
        elseif flag == dp.QualityImageType.middle then
            if isBar then
                return "ui/quality_middle_bar_" .. colorName .. ".png"
            else
                return "ui/quality_middle_" .. colorName .. ".png"
            end
        elseif flag == dp.QualityImageType.big then
            return "ui/quality_big_" .. colorName .. ".png"
        end
    end
    return ""
end

--- 获取装备品质框图片
local function getEquipQualityImage(equipQualityId, flag, isBar)
    local colorName = nil
    if tonumber(equipQualityId) == tonumber(StaticEquip_Quality.white) then
        colorName = "white"
    elseif tonumber(equipQualityId) == tonumber(StaticEquip_Quality.green) then
        colorName = "green"
    elseif tonumber(equipQualityId) == tonumber(StaticEquip_Quality.blue) then
        colorName = "blue"
    elseif tonumber(equipQualityId) == tonumber(StaticEquip_Quality.purple) then
        colorName = "purple"
    elseif tonumber(equipQualityId) == tonumber(StaticEquip_Quality.golden) then
        colorName = "red"
    end
    if colorName then
        if flag == dp.QualityImageType.small then
            if isBar then
                return "ui/quality_small_bar_" .. colorName .. ".png"
            else
                return "ui/quality_small_" .. colorName .. ".png"
            end
        elseif flag == dp.QualityImageType.middle then
            if isBar then
                return "ui/quality_middle_bar_" .. colorName .. ".png"
            else
                return "ui/quality_middle_" .. colorName .. ".png"
            end
        elseif flag == dp.QualityImageType.big then
            return "ui/quality_big_" .. colorName .. ".png"
        end
    end
end

--- 获取功法品质框图片
local function getGongfaQualityImage(gongfaQualityId, flag, isBar)
    local _frameImg = nil
    if isBar then
        _frameImg = "ui/quality_middle_bar_%s.png"
    else
        _frameImg = "ui/quality_small_%s.png"
    end
    if tonumber(gongfaQualityId) == StaticMagicQuality.HJ then
        _frameImg = string.format(_frameImg, "white")
    elseif tonumber(gongfaQualityId) == StaticMagicQuality.XJ then
        _frameImg = string.format(_frameImg, "green")
    elseif tonumber(gongfaQualityId) == StaticMagicQuality.DJ then
        _frameImg = string.format(_frameImg, "blue")
    elseif tonumber(gongfaQualityId) == StaticMagicQuality.TJ then
        _frameImg = string.format(_frameImg, "purple")
    end
    return _frameImg
end

--- 获取异火品质框图片
local function getFireQualityImage(dictFireId, flag, isBar)
    local _fireFrameImg = nil
    if flag == dp.QualityImageType.small then
        if isBar then
            _fireFrameImg = "ui/quality_small_bar_%s.png"
        else
            _fireFrameImg = "ui/quality_small_%s.png"
        end
    elseif flag == dp.QualityImageType.middle then
        _fireFrameImg = "ui/yh_sq_%s.png"
    end
    if dictFireId >= 1 and dictFireId <= 3 then
        _fireFrameImg = string.format(_fireFrameImg, "gold")
    elseif dictFireId >= 4 and dictFireId <= 9 then
        _fireFrameImg = string.format(_fireFrameImg, "purple")
    elseif dictFireId >= 10 and dictFireId <= 15 then
        _fireFrameImg = string.format(_fireFrameImg, "blue")
    elseif dictFireId >= 16 and dictFireId <= 23 then
        _fireFrameImg = string.format(_fireFrameImg, "green")
    else
        _fireFrameImg = string.format(_fireFrameImg, "white")
    end
    return _fireFrameImg
end

--- 获取异火技能品质框图片
local function getFireSkillQualityImage(fireSkillQualityId)
    if tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.hD) then
        return "ui/low_small_green.png", cc.c3b(127, 255, 0)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.hZh) then
        return "ui/middle_small_green.png", cc.c3b(127, 255, 0)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.hG) then
        return "ui/high_small_green.png", cc.c3b(127, 255, 0)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.xD) then
        return "ui/quality_small_purple.png", cc.c3b(0, 213, 255)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.xZh) then
        return "ui/middle_small_blue.png", cc.c3b(0, 213, 255)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.xG) then
        return "ui/high_small_blue.png", cc.c3b(0, 213, 255)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.dD) then
        return "ui/low_small_purple.png", cc.c3b(186, 148, 255)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.dZh) then
        return "ui/middle_small_purple.png", cc.c3b(186, 148, 255)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.dG) then
        return "ui/high_small_purple.png", cc.c3b(186, 148, 255)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.tD) then
        return "ui/low_small_orange.png", cc.c3b(253, 255, 0)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.tZh) then
        return "ui/middle_small_orange.png", cc.c3b(253, 255, 0)
    elseif tonumber(fireSkillQualityId) == tonumber(StaticFireSkillQuality.tG) then
        return "ui/high_small_orange.png", cc.c3b(253, 255, 0)
    end
end

--- 获取卡牌的类型图片
function utils.getCardTypeImage(cardTypeId)
    if tonumber(cardTypeId) == StaticCardType.defense then
        return "ui/kpxx_roudunxing.png"
    elseif tonumber(cardTypeId) == StaticCardType.attack then
        return "ui/kpxx_qianggongxing.png"
    elseif tonumber(cardTypeId) == StaticCardType.blood then
        return "ui/kpxx_zhiliaoxing.png"
    elseif tonumber(cardTypeId) == StaticCardType.balance then
        return "ui/kpxx_junhengxing.png"
    elseif tonumber(cardTypeId) == StaticCardType.control then
        return "ui/kpxx_kongzhixing.png"
    end
end

-- 获取手动技能类型的图片 攻 辅 控 毒
local function getSkillTypeImage(type)
    if type == 1 then
        return "ui/gong.png", "ui/quality_small_red.png"
    elseif type == 2 then
        return "ui/fu.png", "ui/quality_small_blue.png"
    elseif type == 3 then
        return "ui/kong.png", "ui/quality_small_purple.png"
    elseif type == 4 then
        return "ui/du.png", "ui/quality_small_green.png"
    end
end

--- 获取称号的品阶图片
-- @_dictTitle : 称号字典表数据
function utils.getTitleQualityImage(_dictTitle)
    if _dictTitle then
        return string.format("ui/title_%s.png", _dictTitle.sname)
    end
end

--- 获取品质图片
-- @quality : 品质表(参考dp.Quality)
-- @qualityId : 品质ID
-- @qualityImageType : 品质图片的类型(参考dp.QualityImageType)
-- @isBar : 是否为条状的(主要用于卡牌)
function utils.getQualityImage(quality, qualityId, qualityImageType, isBar)
    if quality == dp.Quality.card then
        return getCardQualityImage(qualityId, qualityImageType, isBar)
    elseif quality == dp.Quality.equip then
        return getEquipQualityImage(qualityId, qualityImageType, isBar)
    elseif quality == dp.Quality.gongFa then
        return getGongfaQualityImage(qualityId, qualityImageType, isBar)
    elseif quality == dp.Quality.fire then
        return getFireQualityImage(qualityId, qualityImageType, isBar)
    elseif quality == dp.Quality.fireSkill then
        return getFireSkillQualityImage(qualityId)
    elseif quality == dp.Quality.skill then
        return getSkillTypeImage(qualityImageType)
    end
end

--- 获取装备品质角标图片
function utils.getEquipQualitySuperscript(qualityId)
    local colorName = nil
    if tonumber(qualityId) == tonumber(StaticEquip_Quality.white) then
        colorName = "green"
    elseif tonumber(qualityId) == tonumber(StaticEquip_Quality.green) then
        colorName = "blue"
    elseif tonumber(qualityId) == tonumber(StaticEquip_Quality.blue) then
        colorName = "purple"
    elseif tonumber(qualityId) == tonumber(StaticEquip_Quality.purple) then
        colorName = "orange"
    elseif tonumber(qualityId) == tonumber(StaticEquip_Quality.golden) then
        colorName = "red"
    end
    if colorName then
        return "ui/quality_lv_" .. colorName .. ".png"
    end
end

--- 获取物品的品质图片
function utils.getThingQualityImg(qualityId)
    local colorName = nil
    if tonumber(qualityId) == tonumber(StaticEquip_Quality.white) then
        colorName = "white"
    elseif tonumber(qualityId) == tonumber(StaticEquip_Quality.green) then
        colorName = "green"
    elseif tonumber(qualityId) == tonumber(StaticEquip_Quality.blue) then
        colorName = "blue"
    elseif tonumber(qualityId) == tonumber(StaticEquip_Quality.purple) then
        colorName = "purple"
    elseif tonumber(qualityId) == tonumber(StaticEquip_Quality.golden) then
        colorName = "red"
    end
    if colorName then
        return "ui/quality_small_" .. colorName .. ".png"
    end
end

function utils.getPillQualityImg(qualityId)
    local colorName = nil
    if tonumber(qualityId) == StaticPillQuality.one or tonumber(qualityId) == StaticPillQuality.two then
        colorName = "green"
    elseif tonumber(qualityId) == StaticPillQuality.three or tonumber(qualityId) == StaticPillQuality.four then
        colorName = "blue"
    elseif tonumber(qualityId) == StaticPillQuality.five or tonumber(qualityId) == StaticPillQuality.six then
        colorName = "purple"
    else
        colorName = "white"
    end
    if colorName then
        return "ui/quality_small_" .. colorName .. ".png"
    end
end

--- 获取品质的RGB颜色值
function utils.getQualityColor(qualityId, _isMagic)
    if _isMagic then
        if qualityId == 1 then
            qualityId = StaticQuality.purple
        elseif qualityId == 2 then
            qualityId = StaticQuality.blue
        elseif qualityId == 3 then
            qualityId = StaticQuality.green
        elseif qualityId == 4 then
            qualityId = StaticQuality.white
        end
    end
    if qualityId == StaticQuality.white then
        -- return cc.c3b(7, 105, 0)
        return cc.c4b(7, 105, 0, 255)
    elseif qualityId == StaticQuality.green then
        -- return cc.c3b(0, 61, 255)
        return cc.c4b(0, 61, 255, 255)
    elseif qualityId == StaticQuality.blue then
        -- return cc.c3b(122, 0, 123)
        return cc.c4b(122, 0, 123, 255)
    elseif qualityId == StaticQuality.purple then
        -- return cc.c3b(217, 88, 3)
        return cc.c4b(216, 72, 0, 255)
    elseif qualityId == StaticQuality.red then
        return cc.c4b(255, 0, 0, 255)
    elseif qualityId == StaticQuality.gold then
        return cc.c4b(228, 129, 0, 255)
    end
end

--- 获取属性图标
-- @dictFightPropId : 战斗属性字典ID
-- @flag : 大、小图标标识符（大图标：big  小图标：small）
-- @isExpOrPot : 是否经验或潜力属性
function utils.getPropImage(dictFightPropId, flag, isExpOrPot)
    if isExpOrPot then
        if tonumber(dictFightPropId) == StaticCardBaseProp.exp then
            return "image/superscript_" .. flag .. "_exp.png"
        elseif tonumber(dictFightPropId) == StaticCardBaseProp.potential then
            return "image/superscript_" .. flag .. "_potential.png"
        end
    else
        if tonumber(dictFightPropId) == StaticFightProp.blood then
            return "image/superscript_" .. flag .. "_blood.png"
        elseif tonumber(dictFightPropId) == StaticFightProp.wAttack then
            return "image/superscript_" .. flag .. "_wu_attack.png"
        elseif tonumber(dictFightPropId) == StaticFightProp.fAttack then
            return "image/superscript_" .. flag .. "_fa_attack.png"
        elseif tonumber(dictFightPropId) == StaticFightProp.dodge then
            return "image/superscript_" .. flag .. "_dodge.png"
        elseif tonumber(dictFightPropId) == StaticFightProp.crit then
            return "image/superscript_" .. flag .. "_crit.png"
        elseif tonumber(dictFightPropId) == StaticFightProp.hit then
            return "image/superscript_" .. flag .. "_hit.png"
        elseif tonumber(dictFightPropId) == StaticFightProp.flex then
            return "image/superscript_" .. flag .. "_flex.png"
        elseif tonumber(dictFightPropId) == StaticFightProp.wDefense then
            return "image/superscript_" .. flag .. "_wu_defense.png"
        elseif tonumber(dictFightPropId) == StaticFightProp.fDefense then
            return "image/superscript_" .. flag .. "_fa_defense.png"
        end
    end
end

-- {name,smallIcon,bigIcon,frameIcon,qualityColor,flagIcon--[[角标--]],count,tableTypeId,tableFieldId}
function utils.getItemProp(_things, _fieldId, withPlayerCount)
    local itemProp = { }
    local _tableTypeId, _tableFieldId = nil, _fieldId
    if type(_things) == "number" and _fieldId then
        itemProp.count = 0
        _tableTypeId, _tableFieldId = _things, _fieldId
    else
        local _thingData = utils.stringSplit(_things, "_")
        -- [1]:tableType, [2]:tableField, [3]:value
        if (not _thingData) or #_thingData < 3 then
            cclog("===========ERROR: utils.getItemProp(_things)方法的参数错误")
            return itemProp
        end
        _tableTypeId, _tableFieldId = tonumber(_thingData[1]), tonumber(_thingData[2])
        itemProp.count = tonumber(_thingData[3])
        _thingData = nil
    end
    itemProp.tableTypeId = _tableTypeId
    itemProp.tableFieldId = _tableFieldId
    if withPlayerCount then itemProp.playerCount = 0 end
    if _tableTypeId == StaticTableType.DictPill then
        local dictData = DictPill[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            itemProp.frameIcon = "ui/quality_small_purple.png"
            itemProp.qualityColor = utils.getQualityColor(StaticQuality.purple)
            if withPlayerCount then
                itemProp.playerCount = utils.getPillCount(dictData.id)
            end
        end
    elseif _tableTypeId == StaticTableType.DictThing then
        local dictData = DictThing[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            if dictData.id >= 200 and dictData.id < 300 then
                itemProp.flagIcon = "ui/suipian.png"
                local tempData = DictEquipment[tostring(dictData.equipmentId)]
                if tempData then
                    itemProp.frameIcon = utils.getQualityImage(dp.Quality.equip, tempData.equipQualityId, dp.QualityImageType.small)
                    itemProp.qualityColor = utils.getQualityColor(tempData.equipQualityId)
                    --                    utils.getThingCount(dictData.id)
                    --                    DictEquipQuality[tostring(tempData.equipQualityId)].thingNum
                end
            else
                itemProp.frameIcon = utils.getThingQualityImg(dictData.bkGround)
                itemProp.qualityColor = utils.getQualityColor(dictData.bkGround)
            end
            if withPlayerCount then
                itemProp.playerCount = utils.getThingCount(dictData.id)
            end
        end
    elseif _tableTypeId == StaticTableType.DictPlayerBaseProp then
        local dictData = DictPlayerBaseProp[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            itemProp.frameIcon = "ui/quality_small_purple.png"
            itemProp.qualityColor = utils.getQualityColor(StaticQuality.purple)
            if withPlayerCount then
                itemProp.playerCount = utils.getPlayerBaseProp[dictData.id]()
            end
        end
    elseif _tableTypeId == StaticTableType.DictCardBaseProp then
    elseif _tableTypeId == StaticTableType.DictFightProp then
    elseif _tableTypeId == StaticTableType.DictEquipment then
        local dictData = DictEquipment[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            itemProp.frameIcon = utils.getQualityImage(dp.Quality.equip, dictData.equipQualityId, dp.QualityImageType.small)
            itemProp.qualityColor = utils.getQualityColor(dictData.equipQualityId)
            if withPlayerCount then
                itemProp.playerCount = utils.getSimpleEquipmentCount(dictData.id)
            end
        end
    elseif _tableTypeId == StaticTableType.DictCard then
        local dictData = DictCard[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            itemProp.frameIcon = utils.getQualityImage(dp.Quality.card, dictData.qualityId, dp.QualityImageType.small)
            itemProp.qualityColor = utils.getQualityColor(dictData.qualityId)
            if withPlayerCount then
                itemProp.playerCount = utils.getSimpleCardCount(dictData.id, dictData.qualityId)
            end
        end
    elseif _tableTypeId == StaticTableType.DictConstell then
    elseif _tableTypeId == StaticTableType.DictCardSoul then
        local dictData = DictCardSoul[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            local tempData = DictCard[tostring(dictData.cardId)]
            if tempData then
                if tempData.smallUiId and DictUI[tostring(tempData.smallUiId)] then
                    itemProp.smallIcon = "image/" .. DictUI[tostring(tempData.smallUiId)].fileName
                end
                if tempData.bigUiId and DictUI[tostring(tempData.bigUiId)] then
                    itemProp.bigIcon = "image/" .. DictUI[tostring(tempData.bigUiId)].fileName
                end
                itemProp.frameIcon = utils.getQualityImage(dp.Quality.card, tempData.qualityId, dp.QualityImageType.small)
                itemProp.qualityColor = utils.getQualityColor(tempData.qualityId)
                if withPlayerCount then
                    itemProp.playerCount = utils.getCardSoulCount(dictData.id)
                end
            end
            itemProp.flagIcon = "ui/hun.png"
        end
    elseif _tableTypeId == StaticTableType.DictChip then
        local dictData = DictChip[tostring(_tableFieldId)]
        -- name, type(1-技能 2-功法 3-法宝), skillOrKungFuId(技能/功法/法宝Id)
        if dictData then
            itemProp.name = dictData.name
            local tempData =(dictData.type == 1 and DictManualSkill[tostring(dictData.skillOrKungFuId)] or DictMagic[tostring(dictData.skillOrKungFuId)])
            if tempData then
                if tempData.smallUiId and DictUI[tostring(tempData.smallUiId)] then
                    itemProp.smallIcon = "image/" .. DictUI[tostring(tempData.smallUiId)].fileName
                end
                if tempData.bigUiId and DictUI[tostring(tempData.bigUiId)] then
                    itemProp.bigIcon = "image/" .. DictUI[tostring(tempData.bigUiId)].fileName
                end
            end
            if dictData.type == 1 then
                itemProp.frameIcon = "ui/quality_small_blue.png"
                itemProp.qualityColor = utils.getQualityColor(StaticQuality.blue)
            elseif tempData then
                itemProp.frameIcon = utils.getQualityImage(dp.Quality.gongFa, tempData.magicQualityId, dp.QualityImageType.small)
                itemProp.qualityColor = utils.getQualityColor(tempData.magicQualityId, true)
            end
            if withPlayerCount then
                itemProp.playerCount = utils.getChipCount(dictData.id)
            end
            itemProp.flagIcon = "ui/suipian.png"
        end
    elseif _tableTypeId == StaticTableType.DictPillThing then
        local dictData = DictPillThing[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            itemProp.frameIcon = "ui/quality_small_blue.png"
            itemProp.qualityColor = utils.getQualityColor(StaticQuality.purple)
            if withPlayerCount then
                itemProp.playerCount = utils.getPillThingCount(dictData.id)
            end
        end
    elseif _tableTypeId == StaticTableType.DictManualSkill then
    elseif _tableTypeId == StaticTableType.DictMagic then
        local dictData = DictMagic[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            itemProp.frameIcon = utils.getQualityImage(dp.Quality.gongFa, dictData.magicQualityId, dp.QualityImageType.small)
            itemProp.qualityColor = utils.getQualityColor(dictData.magicQualityId, true)
            if withPlayerCount then
                itemProp.playerCount = utils.getSimpleMagicCount(dictData.id)
            end
        end
    elseif _tableTypeId == StaticTableType.DictBarrier then
    elseif _tableTypeId == StaticTableType.DictYFire then
        local dictData = DictYFire[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/fireImage/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/fireImage/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            itemProp.frameIcon = "ui/quality_small_purple.png"
            itemProp.qualityColor = utils.getQualityColor(StaticQuality.purple)
        end
    elseif _tableTypeId == StaticTableType.DictYFireChip then
        local dictData = DictYFireChip[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/fireImage/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/fireImage/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
            itemProp.frameIcon = "ui/quality_small_purple.png"
            itemProp.qualityColor = utils.getQualityColor(StaticQuality.purple)
            itemProp.flagIcon = "ui/fire_seed.png"
            if withPlayerCount then
                itemProp.playerCount = utils.getYFireChipCount(dictData.id)
            end
        end
    elseif _tableTypeId == StaticTableType.DictWing then
        local dictData = DictWing[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            for key, value in pairs(DictWingAdvance) do
                if value.wingId == dictData.id then
                    if value.smallUiId and DictUI[tostring(value.smallUiId)] then
                        itemProp.smallIcon = "image/" .. DictUI[tostring(value.smallUiId)].fileName
                    end
                    if value.bigUiId and DictUI[tostring(value.bigUiId)] then
                        itemProp.bigIcon = "image/" .. DictUI[tostring(value.bigUiId)].fileName
                    end
                    break
                end
            end
            itemProp.frameIcon = "ui/quality_small_purple.png"
            itemProp.qualityColor = utils.getQualityColor(StaticQuality.purple)
            if withPlayerCount then
                itemProp.playerCount = utils.getSimpleWingCount(dictData.id)
            end
        end
    elseif _tableTypeId == StaticTableType.DictFightSoul then
        local dictData = DictFightSoul[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            itemProp.smallIcon = "ui/fight_soul_quality_blue.png"
            if dictData.fightSoulQualityId == 1 then
                itemProp.frameIcon = "ui/quality_small_purple.png"
                itemProp.smallIcon = "ui/fight_soul_quality_orange.png"
                itemProp.qualityColor = cc.c4b(217, 88, 3, 255)
            elseif dictData.fightSoulQualityId == 2 then
                itemProp.frameIcon = "ui/quality_small_blue.png"
                itemProp.smallIcon = "ui/fight_soul_quality_purple.png"
                itemProp.qualityColor = cc.c4b(122, 0, 123, 255)
            elseif dictData.fightSoulQualityId == 3 then
                itemProp.frameIcon = "ui/quality_small_green.png"
                itemProp.qualityColor = cc.c4b(0, 61, 255, 255)
            elseif dictData.fightSoulQualityId == 4 then
                itemProp.frameIcon = "ui/quality_small_white.png"
                itemProp.qualityColor = cc.c4b(7, 105, 0, 255)
            elseif dictData.fightSoulQualityId == 5 then
                itemProp.frameIcon = "ui/qd_k.png"
                itemProp.qualityColor = cc.c4b(0, 0, 255, 255)
            end
            if withPlayerCount then
                itemProp.playerCount = utils.getSimpleFightSoulCount(dictData.id)
            end
        end
    elseif _tableTypeId == StaticTableType.DictUnionMaterial then
        local dictData = DictUnionMaterial[tostring(_tableFieldId)]
        if dictData then
            itemProp.name = dictData.name
            if dictData.smallUiId and DictUI[tostring(dictData.smallUiId)] then
                itemProp.smallIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            if dictData.bigUiId and DictUI[tostring(dictData.bigUiId)] then
                itemProp.bigIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
        end
    end
    return itemProp
end

local magicPercent = nil

--- 判断卡牌缘分（返回true缘分点亮，否则未点亮）
-- @dictCardLuck : 卡牌缘分字典数据
-- @_instCardId : ID
-- @isFilterFriend : 是否过滤小伙伴
function utils.isCardLuckNew(dictCardLuck, _instCardId, isFilterFriend)
    local _isLuck = false
    local lucks = utils.stringSplit(dictCardLuck.lucks, ";")
    if lucks and #lucks > 0 then
        local _luckFlags = { }
        for key, obj in pairs(lucks) do
            _luckFlags[key] = false
            local temp = utils.stringSplit(obj, "_")
            local tableTypeId, tableFieldId = tonumber(temp[1]), tonumber(temp[2])
            if tableTypeId == StaticTableType.DictCard then
                for k, ipf in pairs(net.InstPlayerFormation) do
                    if ipf.int["4"] == 1 or ipf.int["4"] == 2 then
                        if tableFieldId == ipf.int["6"] then
                            -- cardId,卡牌字典Id
                            _luckFlags[key] = true
                            break
                        end
                    end
                end
                if not isFilterFriend and net.InstPlayerFormation then
                    for k, ipp in pairs(net.InstPlayerFormation) do
                        if ipp.int["4"] == 3 then
                            if tableFieldId == ipp.int["6"] then
                                -- cardId,卡牌字典Id
                                _luckFlags[key] = true
                                break
                            end
                        end
                    end
                end
            elseif tableTypeId == StaticTableType.DictMagic then
                if net.InstPlayerMagic and _instCardId then
                    for k, ipm in pairs(net.InstPlayerMagic) do
                        -------------------------------------------instCardId,卡牌实例Id-----------------------------------------法宝功法Id
                        if _instCardId == ipm.int["8"] and tableFieldId == ipm.int["3"] then
                            _luckFlags[key] = true
                            break
                        end
                    end
                end
            end
        end
        _isLuck = true
        for key, obj in pairs(_luckFlags) do
            if not obj then
                _isLuck = false
                break
            end
        end
    end
    return _isLuck
end

--- 判断卡牌缘分 3v3（返回true缘分点亮，否则未点亮）
-- @dictCardLuck : 卡牌缘分字典数据
-- @_instFormationId : 阵型实例ID
-- @isFilterFriend : 是否过滤小伙伴
function utils.isCardLuck3v3(dictCardLuck, _instFormationId, isFilterFriend ,team )
    local function inTeam( instId )
        for key ,value in pairs( team ) do
            if tonumber( value ) == instId then
                return true
            end
        end
        return false
    end
    local _isLuck = false
    local lucks = utils.stringSplit(dictCardLuck.lucks, ";")
    if lucks and #lucks > 0 then
        local _luckFlags = { }
        for key, obj in pairs(lucks) do
            _luckFlags[key] = false
            local temp = utils.stringSplit(obj, "_")
            local tableTypeId, tableFieldId = tonumber(temp[1]), tonumber(temp[2])
            if tableTypeId == StaticTableType.DictCard then
                for k, ipf in pairs(net.InstPlayerFormation) do
                    if inTeam( tonumber( ipf.int[ "3" ] ) ) and ( ipf.int["4"] == 1 or ipf.int["4"] == 2 ) then
                        if tableFieldId == ipf.int["6"] then
                            -- cardId,卡牌字典Id
                            _luckFlags[key] = true
                            break
                        end
                    end
                end
                if not isFilterFriend and net.InstPlayerFormation then
                    for k, ipp in pairs(net.InstPlayerFormation) do
                        if inTeam( tonumber( ipp.int[ "3" ] ) ) and ipp.int["4"] == 3 then
                            if tableFieldId == ipp.int["6"] then
                                -- cardId,卡牌字典Id
                                _luckFlags[key] = true
                                break
                            end
                        end
                    end
                end
            elseif tableTypeId == StaticTableType.DictMagic then
                if net.InstPlayerMagic and _instFormationId then
                    for k, ipm in pairs(net.InstPlayerMagic) do
                        -------------------------------------------instCardId,卡牌实例Id-----------------------------------------法宝功法Id
                        if net.InstPlayerFormation[tostring(_instFormationId)].int["3"] == ipm.int["8"] and tableFieldId == ipm.int["3"] then
                            _luckFlags[key] = true
                            break
                        end
                    end
                end
            end
        end
        _isLuck = true
        for key, obj in pairs(_luckFlags) do
            if not obj then
                _isLuck = false
                break
            end
        end
    end
    return _isLuck
end

--- 判断卡牌缘分（返回true缘分点亮，否则未点亮）
-- @dictCardLuck : 卡牌缘分字典数据
-- @_instFormationId : 阵型实例ID
-- @isFilterFriend : 是否过滤小伙伴
function utils.isCardLuck(dictCardLuck, _instFormationId, isFilterFriend)
    local _isLuck = false
    local lucks = utils.stringSplit(dictCardLuck.lucks, ";")
    if lucks and #lucks > 0 then
        local _luckFlags = { }
        for key, obj in pairs(lucks) do
            _luckFlags[key] = false
            local temp = utils.stringSplit(obj, "_")
            local tableTypeId, tableFieldId = tonumber(temp[1]), tonumber(temp[2])
            if tableTypeId == StaticTableType.DictCard then
                for k, ipf in pairs(net.InstPlayerFormation) do
                    if ipf.int["4"] == 1 or ipf.int["4"] == 2 then
                        if tableFieldId == ipf.int["6"] then
                            -- cardId,卡牌字典Id
                            _luckFlags[key] = true
                            break
                        end
                    end
                end
                if not isFilterFriend and net.InstPlayerFormation then
                    for k, ipp in pairs(net.InstPlayerFormation) do
                        if ipp.int["4"] == 3 then
                            if tableFieldId == ipp.int["6"] then
                                -- cardId,卡牌字典Id
                                _luckFlags[key] = true
                                break
                            end
                        end
                    end
                end
            elseif tableTypeId == StaticTableType.DictMagic then
                if net.InstPlayerMagic and _instFormationId then
                    for k, ipm in pairs(net.InstPlayerMagic) do
                        -------------------------------------------instCardId,卡牌实例Id-----------------------------------------法宝功法Id
                        if net.InstPlayerFormation[tostring(_instFormationId)].int["3"] == ipm.int["8"] and tableFieldId == ipm.int["3"] then
                            _luckFlags[key] = true
                            break
                        end
                    end
                end
            end
        end
        _isLuck = true
        for key, obj in pairs(_luckFlags) do
            if not obj then
                _isLuck = false
                break
            end
        end
    end
    return _isLuck

    --[[
	if dictCardLuck.tableTypeId == StaticTableType.DictCard then
		for k, ipf in pairs(net.InstPlayerFormation) do
			if dictCardLuck.tableFieldId == ipf.int["6"] then
				return true
			end
		end

		if not isFilterFriend and net.InstPlayerPartner then
			for k, ipp in pairs(net.InstPlayerPartner) do
				if dictCardLuck.tableFieldId == ipp.int["4"] then
					return true
				end
			end
		end
	elseif dictCardLuck.tableTypeId == StaticTableType.DictMagic then
		if net.InstPlayerMagic and _instFormationId then
			for k, ipm in pairs(net.InstPlayerMagic) do
				if net.InstPlayerFormation[tostring(_instFormationId)].int["3"] == ipm.int["8"] and dictCardLuck.tableFieldId == ipm.int["3"] then
					return true
				end
			end
		end
	elseif dictCardLuck.tableTypeId == StaticTableType.DictEquipment then
		if net.InstPlayerLineup then
			for k, ipl in pairs(net.InstPlayerLineup) do
				if _instFormationId == ipl.int["3"] and dictCardLuck.tableFieldId == net.InstPlayerEquip[tostring(ipl.int["5"])].int["4"] then
					return true
				end
			end
		end
	end
--]]
end

--- 判断dictCardId是否上阵
-- @dictCardId : 卡牌字典ID
function utils.isTeam(dictCardId)
    if net.InstPlayerFormation then
        for key, obj in pairs(net.InstPlayerFormation) do
            -- 增加蓝色萧炎和紫色萧炎重复判断
            if dictCardId == 88 then
                if obj.int["6"] == 154 then
                    return true
                end
            end
            if dictCardId == 154 then
                if obj.int["6"] == 88 then
                    return true
                end
            end
            if obj.int["4"] == 1 or obj.int["4"] == 2 then
                if dictCardId == obj.int["6"] then
                    -- cardId,卡牌实例Id
                    return true
                end
            end
        end
    end
    if net.InstPlayerFormation then
        for key, obj in pairs(net.InstPlayerFormation) do
            if obj.int["4"] == 3 then
                if dictCardId == obj.int["6"] then
                    -- cardId,卡牌实例Id
                    return true
                end
            end
        end
    end
end

--- 获取装备洗练属性
-- @instEquipId : 装备实例ID
local function getEquipWashAttribute(instEquipId)
    local attribute = { }
    for key, obj in pairs(DictFightProp) do
        attribute[obj.id] = 0
    end
    if net.InstPlayerEquip and instEquipId then
        if net.InstPlayerWash then
            local washIndex, washCount = 0, 4
            -- 最大洗练个数
            for key, obj in pairs(net.InstPlayerWash) do
                local instWashEquipId = obj.int["3"]
                -- 装备实例ID
                if instEquipId == instWashEquipId then
                    local fightPropId = obj.int["4"]
                    -- 战斗属性ID
                    local equipWashId = obj.int["5"]
                    -- 洗练字典ID
                    local dictDquipWashData = DictEquipWash[tostring(equipWashId)]
                    attribute[fightPropId] = attribute[fightPropId] + dictDquipWashData.value
                    washIndex = washIndex + 1
                    if washIndex >= washCount then
                        break
                    end
                end
            end
        end
    end
    return attribute
end

--- 获取装备镶嵌宝石属性
-- @instEquipId : 装备实例ID
local function getEquipGemAttribute(instEquipId, isPvp)
    local attribute = { }
    for key, obj in pairs(DictFightProp) do
        attribute[obj.id] = 0
    end
    if net.InstPlayerEquip and instEquipId and not isPvp then
        local instEquipData = net.InstPlayerEquip[tostring(instEquipId)]
        local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
        -- 装备字典表
        local dictEquipQualityData = DictEquipQuality[tostring(dictEquipData.equipQualityId)]
        -- 装备品质字典表
        local holeNum = dictEquipQualityData.holeNum
        -- 拥有宝石孔数
        local geamIndex = 0
        if net.InstEquipGem then
            for key, obj in pairs(net.InstEquipGem) do
                if instEquipId == obj.int["3"] then
                    local _thingId = obj.int["4"]
                    -- 物品Id 0表示未镶嵌宝石
                    if _thingId > 0 then
                        local dictThingData = DictThing[tostring(_thingId)]
                        attribute[dictThingData.fightPropId] = attribute[dictThingData.fightPropId] + dictThingData.fightPropValue
                    end
                    geamIndex = geamIndex + 1
                    if geamIndex >= holeNum then
                        break
                    end
                end
            end
        end
    elseif pvp.InstPlayerEquip and instEquipId and isPvp then
        local instEquipData = pvp.InstPlayerEquip[tostring(instEquipId)]
        local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
        -- 装备字典表
        local dictEquipQualityData = DictEquipQuality[tostring(dictEquipData.equipQualityId)]
        -- 装备品质字典表
        local holeNum = dictEquipQualityData.holeNum
        -- 拥有宝石孔数
        local geamIndex = 0
        if net.InstEquipGem then
            for key, obj in pairs(net.InstEquipGem) do
                if instEquipId == obj.int["3"] then
                    local _thingId = obj.int["4"]
                    -- 物品Id 0表示未镶嵌宝石
                    if _thingId > 0 then
                        local dictThingData = DictThing[tostring(_thingId)]
                        attribute[dictThingData.fightPropId] = attribute[dictThingData.fightPropId] + dictThingData.fightPropValue
                    end
                    geamIndex = geamIndex + 1
                    if geamIndex >= holeNum then
                        break
                    end
                end
            end
        end
    end
    return attribute
end
local isInSuit = { }
--- 获取装备套装属性(返回的是一组table属性值,table下标就是属性ID)
-- @instEquipId : 装备实例ID

function utils.getEquipSuitAttribute(_instFormationId, _instEquipId, isPvp)
    local attribute = { }
    for key, obj in pairs(DictFightProp) do
        attribute[obj.id] = 0
    end
    if net.InstPlayerEquip and _instEquipId then
        local suitEquipData, suitEquipRedData = utils.getEquipSuit(tostring(net.InstPlayerEquip[tostring(_instEquipId)].int["4"]))
        if not suitEquipData then
            -- cclog("utils 此物品无套装")
            return { }
        end
        local suitEquipTable = utils.stringSplit(suitEquipData.suitEquipIdList, ";")
        local curSuitEquipData = { 0, 0, 0, 0 }

        local suitCount = 0
        local suitStarLvl = 5
        local suitRedStarLvl = 5
        function addSuitCountAndStarLvl(equipId, isSuitEquip, starLvl, index)
            if _instEquipId ~= equipId and isSuitEquip then
                suitCount = suitCount + 1
                table.insert(isInSuit, equipId)
            end

            local instEquipData = net.InstPlayerEquip[tostring(equipId)]
            local _equipAdvanceId = instEquipData.int["8"]
            local tempLvl = starLvl
            if _equipAdvanceId > 0 then
                local dictEquipAdvanceData = _equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(_equipAdvanceId)] or DictEquipAdvance[tostring(_equipAdvanceId)]
                if dictEquipAdvanceData.equipQualityId == StaticEquip_Quality.golden then
                    if suitRedStarLvl > tempLvl then
                        suitRedStarLvl = tempLvl
                    end
                    tempLvl = 5
                else
                    suitRedStarLvl = -1
                end
            else
                suitRedStarLvl = -1
            end
            if tempLvl < suitStarLvl then
                suitStarLvl = tempLvl
            end
        end
        local count = 0
        for key, obj in pairs(net.InstPlayerLineup) do
            if _instFormationId and tonumber(_instFormationId) == tonumber(obj.int["3"]) then
                local equipTypeId = obj.int["4"]
                -- 装备类型Id
                local instEquipId = obj.int["5"]
                -- 装备实例Id
                local instEquipData = net.InstPlayerEquip[tostring(instEquipId)]
                -- 装备实例数据
                local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
                -- 装备字典数据
                local equipLevel = instEquipData.int["5"]
                -- 装备等级
                local qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small)
                local qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipData.equipQualityId)
                local equipStarLvl = 0
                local equipAdvanceId = instEquipData.int["8"]
                if tonumber(equipAdvanceId) > 0 then
                    local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]
                    -- 装备进阶字典表
                    if dictEquipAdvanceData then
                        equipStarLvl = dictEquipAdvanceData.starLevel
                    end
                end

                if equipTypeId == StaticEquip_Type.outerwear then
                    -- 护甲
                    local isSuit = false
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[2]) then
                        isSuit = false
                    else
                        isSuit = true
                        curSuitEquipData[2] = instEquipId
                    end
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 2)
                elseif equipTypeId == StaticEquip_Type.pants then
                    -- 头盔
                    local isSuit = false
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[3]) then
                        isSuit = false
                    else
                        isSuit = true
                        curSuitEquipData[3] = instEquipId
                    end
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 3)
                elseif equipTypeId == StaticEquip_Type.necklace then
                    -- 饰品
                    local isSuit = false
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[4]) then
                        isSuit = false
                    else
                        isSuit = true
                        curSuitEquipData[4] = instEquipId
                    end
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 4)
                elseif equipTypeId == StaticEquip_Type.equip then
                    -- 武器
                    local isSuit = false
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[1]) then
                        isSuit = false
                    else
                        isSuit = true
                        curSuitEquipData[1] = instEquipId
                    end
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 1)
                end
                if count >= 4 then
                    break
                end
            end
        end
        --     cclog("utils suitCount : "..suitCount .. " suitStarLvl :"..suitStarLvl)
        local function getAddProp(propId, data)
            local propAdd = 0
            local baseProp = 0
            local tempAttr = { }
            if propId == 1 then
                -- 首饰

                if curSuitEquipData[4] == 0 then
                    return 0
                end
                tempAttr = utils.getEquipAttribute(curSuitEquipData[4])
            elseif propId == 2 or propId == 3 then
                -- 武器

                if curSuitEquipData[1] == 0 then
                    return 0
                end
                tempAttr = utils.getEquipAttribute(curSuitEquipData[1])
            elseif propId == 8 then
                -- 护甲

                if curSuitEquipData[2] == 0 then
                    return 0
                end
                tempAttr = utils.getEquipAttribute(curSuitEquipData[2])
            elseif propId == 9 then
                -- 头盔

                if curSuitEquipData[3] == 0 then
                    return 0
                end
                tempAttr = utils.getEquipAttribute(curSuitEquipData[3])
            end
            baseProp = tempAttr[propId]
            propAdd = baseProp * data
            return propAdd
        end
        for i = 2, 4 do
            local propStr = nil
            if i == 2 then
                propStr = suitEquipData.suit2NumProp
            elseif i == 3 then
                propStr = suitEquipData.suit3NumProp
            elseif i == 4 then
                propStr = suitEquipData.suit4NumProp
            end
            if i < 2 + suitCount then
                local propTable = utils.stringSplit(propStr, ";")
                for key, value in pairs(propTable) do
                    local data = utils.stringSplit(value, "_")
                    if tonumber(data[2]) < 1 then
                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + math.floor(getAddProp(tonumber(data[1]), tonumber(data[2])))
                    else
                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + tonumber(data[2])
                    end
                end
            end
        end
        for i = 1, 5 do
            local propStr = nil
            if i == 1 then
                propStr = suitEquipData.suit1StarProp
            elseif i == 2 then
                propStr = suitEquipData.suit2StarProp
            elseif i == 3 then
                propStr = suitEquipData.suit3StarProp
            elseif i == 4 then
                propStr = suitEquipData.suit4StarProp
            elseif i == 5 then
                propStr = suitEquipData.suit5StarProp
            end
            if suitCount >= 3 and i <= suitStarLvl then
                local propTable = utils.stringSplit(propStr, ";")
                for key, value in pairs(propTable) do
                    local data = utils.stringSplit(value, "_")
                    if tonumber(data[2]) < 1 then
                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + math.floor(getAddProp(tonumber(data[1]), tonumber(data[2])))
                    else
                        -- cclog( "data[2] : "..data[ 2 ])
                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + tonumber(data[2])
                    end
                end
            end
        end
        if suitEquipRedData then
            for i = 1, 6 do
                local propStr = suitEquipRedData[string.format("Redsuit%dStarProp", i - 1)]
--                if i == 1 then
--                    propStr = suitEquipRedData.suit0StarProp
--                elseif i == 2 then
--                    propStr = suitEquipRedData.suit1StarProp
--                elseif i == 3 then
--                    propStr = suitEquipRedData.suit2StarProp
--                elseif i == 4 then
--                    propStr = suitEquipRedData.suit3StarProp
--                elseif i == 5 then
--                    propStr = suitEquipRedData.suit4StarProp
--                elseif i == 6 then
--                    propStr = suitEquipRedData.suit5StarProp
--                end
                if suitCount >= 3 and 5 <= suitStarLvl and i - 1 <= suitRedStarLvl then
                    local propTable = utils.stringSplit(propStr, ";")
                    for key, value in pairs(propTable) do
                        local data = utils.stringSplit(value, "_")
                        if tonumber(data[2]) < 1 then
                            attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + math.floor(getAddProp(tonumber(data[1]), tonumber(data[2])))
                        else
                            cclog("data[2] : " .. data[1] .. "  " .. data[2] .. " suitRedStarLvl : " .. suitRedStarLvl)
                            attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + tonumber(data[2])
                        end
                    end
                end
            end
        end
    end
    return attribute
end

--获取器匣加成属性百分比值
function utils.getQixiaAddPropPerValue(_instFormationId, _equipTypeId)
    local _ipebAddPropPer = 0
    if net.InstPlayerEquipBox then
        local _ipebInstData = nil
        for _ipebKey, _ipebObj in pairs(net.InstPlayerEquipBox) do
            if _instFormationId == _ipebObj.int["3"] then
                if _equipTypeId == StaticEquip_Type.equip then
                    _ipebInstData = utils.stringSplit(_ipebObj.string["4"], ";")
                elseif _equipTypeId == StaticEquip_Type.outerwear then
                    _ipebInstData = utils.stringSplit(_ipebObj.string["5"], ";")
                elseif _equipTypeId == StaticEquip_Type.pants then
                    _ipebInstData = utils.stringSplit(_ipebObj.string["6"], ";")
                elseif _equipTypeId == StaticEquip_Type.necklace then
                    _ipebInstData = utils.stringSplit(_ipebObj.string["7"], ";")
                end
                break
            end
        end
        if _ipebInstData and #_ipebInstData > 0 then
            for _iii, _ooo in pairs(_ipebInstData) do
                local _tempOOO = utils.stringSplit(_ooo, "_")
                local _lvId = _tempOOO[1]
                local _state = tonumber(_tempOOO[2]) --0可精炼 1普通 2优良 3完美
                if _state > 0 then
                    if _state == 1 then
                        _ipebAddPropPer = _ipebAddPropPer + DictEquipBox[_lvId].goodAdd
                    elseif _state == 2 then
                        _ipebAddPropPer = _ipebAddPropPer + DictEquipBox[_lvId].betterAdd
                    elseif _state == 3 then
                        _ipebAddPropPer = _ipebAddPropPer + DictEquipBox[_lvId].bestAdd
                    end
                end
            end
        end
    end
    return _ipebAddPropPer
end

--- 获取装备属性(返回的是一组table属性值,table下标就是属性ID)
-- @instEquipId : 装备实例ID
-- @isFilter : 是否过滤镶嵌宝石属性
function utils.getEquipAttribute(instEquipId, isFilter, isPvp)
    local attribute = { }
    for key, obj in pairs(DictFightProp) do
        attribute[obj.id] = 0
    end
    if net.InstPlayerEquip and instEquipId and not isPvp then
        local instEquipData = net.InstPlayerEquip[tostring(instEquipId)]
        local equipTypeId = instEquipData.int["3"]
        -- 装备类型ID
        local dictEquipId = instEquipData.int["4"] --装备字典ID
        local equipLv = instEquipData.int["5"]
        -- 装备等级
        local equipAdvanceId = instEquipData.int["8"]
        -- 装备进阶字典ID
        local dictEquipData = DictEquipment[tostring(dictEquipId)]
        -- 装备字典表
        local equipPropData = { }
        local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
        for key, obj in pairs(propData) do
            equipPropData[key] = utils.stringSplit(obj, "_")
            -- [1]:fightPropId, [2]:initValue, [3]:addValue
        end
        local attAddValue = 0
        -- 装备进阶
        for key, obj in pairs(DictEquipAdvance) do
            if equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId and equipAdvanceId >= obj.id then
                attAddValue = attAddValue + obj.propAndAdd
            end
        end
        if equipAdvanceId >= 1000 then --红装
            for key, obj in pairs(DictEquipAdvancered) do
                if dictEquipId == obj.equipId and DictEquipAdvancered[tostring(equipAdvanceId)].starLevel >= obj.starLevel then
                    attAddValue = attAddValue + obj.propAndAdd
                end
            end
        end
        -- 装备强化
        for key, obj in pairs(equipPropData) do
            local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
            attribute[fightPropId] = attribute[fightPropId] + formula.getEquipAttribute(equipLv, initValue, addValue + attAddValue)
        end

        if not isFilter then
            -- 装备镶嵌
            --[[
			local _washAttribute = getEquipWashAttribute(instEquipId)
			for _fightPropId, _value in pairs(_washAttribute) do
				attribute[_fightPropId] = attribute[_fightPropId] + _value
			end
			--]]
            local _gemAttribute = getEquipGemAttribute(instEquipId)
            for _fightPropId, _value in pairs(_gemAttribute) do
                attribute[_fightPropId] = attribute[_fightPropId] + _value
            end
        end

    elseif instEquipId and isPvp and pvp.InstPlayerEquip then
        local instEquipData = pvp.InstPlayerEquip[tostring(instEquipId)]
        local equipTypeId = instEquipData.int["3"]
        -- 装备类型ID
        local dictEquipId = instEquipData.int["4"] --装备字典ID
        local equipLv = instEquipData.int["5"]
        -- 装备等级
        local equipAdvanceId = instEquipData.int["8"]
        if equipAdvanceId == nil then
            equipAdvanceId = 0
        end
        -- 装备进阶字典ID
        local dictEquipData = DictEquipment[tostring(dictEquipId)]
        -- 装备字典表
        local equipPropData = { }
        local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
        for key, obj in pairs(propData) do
            equipPropData[key] = utils.stringSplit(obj, "_")
            -- [1]:fightPropId, [2]:initValue, [3]:addValue
        end
        local attAddValue = 0
        for key, obj in pairs(DictEquipAdvance) do
            if equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId and equipAdvanceId >= obj.id then
                attAddValue = attAddValue + obj.propAndAdd
            end
        end
        if equipAdvanceId >= 1000 then
            for key, obj in pairs(DictEquipAdvancered) do
                if dictEquipId == obj.equipId and DictEquipAdvancered[tostring(equipAdvanceId)].starLevel >= obj.starLevel then
                    attAddValue = attAddValue + obj.propAndAdd
                end
            end
        end
        for key, obj in pairs(equipPropData) do
            local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
            attribute[fightPropId] = attribute[fightPropId] + formula.getEquipAttribute(equipLv, initValue, addValue + attAddValue)
        end

        if not isFilter then
            --[[
			local _washAttribute = getEquipWashAttribute(instEquipId)
			for _fightPropId, _value in pairs(_washAttribute) do
				attribute[_fightPropId] = attribute[_fightPropId] + _value
			end
			--]]
            local _gemAttribute = getEquipGemAttribute(instEquipId, true)
            for _fightPropId, _value in pairs(_gemAttribute) do
                attribute[_fightPropId] = attribute[_fightPropId] + _value
            end
        end
    end
    return attribute
end

--- 获取卡牌属性(返回的是一组table属性值,table下标就是属性ID)
-- @instCardId : 卡牌实例ID attr 是否有已算出结界属性
function utils.getCardAttribute(instCardId, fightSoulValue , is3V3 , noFire , attr )
    local attribute = { }
    for key, obj in pairs(DictFightProp) do
        attribute[obj.id] = 0
    end
    magicPercent = { }

    if instCardId and net.InstPlayerCard[tostring(instCardId)] then
        local instCardData = net.InstPlayerCard[tostring(instCardId)]
        local dictCardId = instCardData.int["3"]
        -- 卡牌字典ID
        local cardQualityId = instCardData.int["4"]
        -- 卡牌品阶ID
        local cardStarLevelId = instCardData.int["5"]
        -- 卡牌星级ID
        local cardTitleDetailId = instCardData.int["6"]
        -- 卡牌具体称号字典ID
        local cardLevel = instCardData.int["9"]
        -- 卡牌等级
        local inTeam = instCardData.int["10"]
        -- 是否在队伍中 0-不在 1-在
        local instGongFaId = instCardData.int["12"]
        -- 功法实例ID
        local instConstellsId = instCardData.string["13"]
        -- 命宫实例ID
        local trainDatas = instCardData.string["20"] --培养进度  格式：属性Id_数值;
        local dictCardData = DictCard[tostring(dictCardId)]
        -- 卡牌字典数据

        -------------基础属性数据（等级+卡边颜色）---------------
        attribute[StaticFightProp.blood] = formula.getCardBlood(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
        attribute[StaticFightProp.wAttack] = formula.getCardGasAttack(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
        attribute[StaticFightProp.wDefense] = formula.getCardGasDefense(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
        attribute[StaticFightProp.fAttack] = formula.getCardSoulAttack(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
        attribute[StaticFightProp.fDefense] = formula.getCardSoulDefense(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
        attribute[StaticFightProp.dodge] = formula.getCardDodge(cardLevel, dictCardData)
        attribute[StaticFightProp.hit] = formula.getCardHit(cardLevel, dictCardData)
        attribute[StaticFightProp.crit] = formula.getCardCrit(cardLevel, dictCardData)
        attribute[StaticFightProp.flex] = formula.getCardTenacity(cardLevel, dictCardData)

        -------------称号属性数据---------------
        for tddKey, tddObj in pairs(DictTitleDetail) do
            if cardTitleDetailId >= tddObj.id then
                local _tempData = utils.stringSplit(tddObj.effects, ";")
                for key, obj in pairs(_tempData) do
                    local _fightPropData = utils.stringSplit(obj, "_")
                    -- [1]:fightPropId, [2]:value
                    local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
                    attribute[_fightPropId] = attribute[_fightPropId] + _value
                end
                if cardTitleDetailId ~= tddObj.id then
                    local _tempTrainData = utils.stringSplit(tddObj.train, ";")
                    for key, obj in pairs(_tempTrainData) do
                        local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [3]:value
                        local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[3])
				        attribute[_fightPropId] = attribute[_fightPropId] + _value
                    end
                end
            end
        end
        local _trainDatas = utils.stringSplit(trainDatas, ";")
        for key, obj in pairs(_trainDatas) do
            local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:value
            local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
            attribute[_fightPropId] = attribute[_fightPropId] + _value
        end

        if inTeam == 1 then

            local isFriend = 1 --是否是小伙伴 1是 0否

            for key, obj in pairs(net.InstPlayerFormation) do
                local _instFormationId = obj.int["1"]
                local _instCardId = obj.int["3"]
                if instCardId == _instCardId then

                    if tonumber( obj.int[ "4" ] ) == 3 then
                        isFriend = 1
                    else
                        isFriend = 0
                    end

                    -------------装备基础属性数据（不包括镶嵌宝石）---------------
                    if net.InstPlayerLineup then
                        local equipCount = 0
                        for lineupKey, lineupObj in pairs(net.InstPlayerLineup) do
                            if _instFormationId == lineupObj.int["3"] then
                                equipCount = equipCount + 1
                                local _instEquipId = lineupObj.int["5"]
                                local tempAttribute = utils.getEquipAttribute(_instEquipId, true)
                                -------------装备精炼属性数据（不包括镶嵌宝石）---------------
                                local _ipebAddPropPer = utils.getQixiaAddPropPerValue(_instFormationId, lineupObj.int["4"])
                                -------------装备精炼属性数据（不包括镶嵌宝石）---------------
                                for attKey, attObj in pairs(tempAttribute) do
                                    attribute[attKey] = attribute[attKey] + attObj * (1 + _ipebAddPropPer / 100)
                                end
                                if equipCount >= 4 then
                                    break
                                end
                            end
                        end
                    end

                    ------------斗魂属性数据-------------------
                    if net.InstPlayerFightSoul then
                        for soulKey, soulValue in pairs(net.InstPlayerFightSoul) do
                            -- cclog("------------->".._instCardId .. "  ".._instFormationId.."  "..soulValue.int["7"] )
                            if soulValue.int["7"] == _instCardId then
                                local pro = nil
                                for key, value in pairs(DictFightSoulUpgradeProp) do
                                    if value.fightSoulId == soulValue.int["3"] and value.level == soulValue.int["5"] then
                                        pro = value
                                        break
                                    end
                                end
                                if pro then
                                    attribute[pro.fightPropId] = attribute[pro.fightPropId] + pro.fightPropValue
                                    if fightSoulValue then
                                        fightSoulValue = fightSoulValue + pro.fightValue
                                    end
                                end
                            end
                            --  cclog("<------------------")
                        end
                    end

                    ------------翅膀属性数据-------------------
                    if net.InstPlayerWing then
                        for wingKey, wingValue in pairs(net.InstPlayerWing) do
                            if wingValue.int["6"] == _instCardId then
                                local wingId = wingValue.int["3"]
                                local level = wingValue.int["4"]
                                local starNum = wingValue.int["5"]
                                local pro = nil
                                local thingData = nil
                                for key, value in pairs(DictWingStrengthen) do
                                    if value.wingId == wingId and value.level == level then
                                        thingData = value
                                        break
                                    end
                                end
                                local advanceData = nil
                                 cclog("wingId ======"..wingId .."  starNum : "..starNum)
                                for key, value in pairs(DictWingAdvance) do
                                    if value.wingId == wingId and value.starNum == starNum then
                                        advanceData = value
                                        break
                                    end
                                end
                                local proShow = utils.stringSplit(advanceData.openFightPropIdList, ";")
                                local pro = utils.stringSplit(thingData.fightPropValueList, ";")
                                local function getShowValue(id)
                                    for key, value in pairs(pro) do
                                        local data = utils.stringSplit(value, "_")
                                        if data[1] == id then
                                            return data[2]
                                        end
                                    end
                                    return 0
                                end
                                for key, value in pairs(proShow) do
                                    attribute[tonumber(value)] = attribute[tonumber(value)] + getShowValue(value)
                                end
                            end
                        end
                    end

                    -------------修炼属性数据---------------
                    if net.InstPlayerTrain then
                        for trainKey, trainObj in pairs(net.InstPlayerTrain) do
                            if instCardId == trainObj.int["3"] then
                                local _fightPropId = trainObj.int["4"]
                                local _value = trainObj.int["5"]
                                attribute[_fightPropId] = attribute[_fightPropId] +(_value * utils.FightValueFactor[_fightPropId])
                            end
                        end
                    end

                    -------------装备套装属性---------------
                    if net.InstPlayerLineup then
                        local equipCount = 0
                        isInSuit = { }
                        for lineupKey, lineupObj in pairs(net.InstPlayerLineup) do
                            if _instFormationId == lineupObj.int["3"] then
                                local _instEquipId = lineupObj.int["5"]
                                local instEquipData = net.InstPlayerEquip[tostring(_instEquipId)]
                                local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
                                -- 装备字典表
                                equipCount = equipCount + 1
                                if dictEquipData.equipQualityId >= 3 then
                                    -- 只有紫色、橙色可能有套装属性
                                    -- cclog("utils 套装属性 .. _instEquipId :".._instEquipId.." _instFormationId : ".._instFormationId)

                                    local isSame = false
                                    for key, value in pairs(isInSuit) do
                                        if tonumber(value) == tonumber(_instEquipId) then
                                            isSame = true
                                            break
                                        end
                                    end
                                    if not isSame then
                                        --  cclog("utils isSame")
                                        local tempAttribute = utils.getEquipSuitAttribute(_instFormationId, _instEquipId, true)
                                        for attKey, attObj in pairs(tempAttribute) do
                                            -- cclog("attKey:"..attKey.."  attObj:"..attObj)
                                            attribute[attKey] = attribute[attKey] + attObj
                                        end
                                    end
                                end
                                if equipCount >= 4 then
                                    break
                                end
                            end
                        end
                    end

                    -------------缘分属性数据---------------
                    if is3V3 then
                        --要单独算
                        local tempCount = 0
                        for luckKey, luckObj in pairs(DictCardLuck) do
                            if luckObj.cardId == dictCardId then
                                tempCount = tempCount + 1
                                if utils.isCardLuck3v3(luckObj, _instFormationId , false , is3V3 ) then
                                    local luckFightValues = utils.stringSplit(luckObj.fightValues, ";")
                                    if luckFightValues and #luckFightValues > 0 then
                                        for lfvKey, lfvObj in pairs(luckFightValues) do
                                            local temp = utils.stringSplit(lfvObj, "_")
                                            -- fightPropId_value
                                            local luckFightPropId, luckAddValue = tonumber(temp[1]), tonumber(temp[2])
                                            attribute[luckFightPropId] = attribute[luckFightPropId] + math.floor(attribute[luckFightPropId] *(luckAddValue / 100))
                                            temp = nil
                                        end
                                    end
                                    luckFightValues = nil
                                    -- attribute[luckObj.fightPropId] = attribute[luckObj.fightPropId] + math.floor(attribute[luckObj.fightPropId] * (luckObj.addValue / 100))
                                end
                                if tempCount >= 6 then
                                    break
                                end
                            end
                        end
                    else
                        local tempCount = 0
                        for luckKey, luckObj in pairs(DictCardLuck) do
                            if luckObj.cardId == dictCardId then
                                tempCount = tempCount + 1
                                if utils.isCardLuck(luckObj, _instFormationId) then
                                    local luckFightValues = utils.stringSplit(luckObj.fightValues, ";")
                                    if luckFightValues and #luckFightValues > 0 then
                                        for lfvKey, lfvObj in pairs(luckFightValues) do
                                            local temp = utils.stringSplit(lfvObj, "_")
                                            -- fightPropId_value
                                            local luckFightPropId, luckAddValue = tonumber(temp[1]), tonumber(temp[2])
                                            attribute[luckFightPropId] = attribute[luckFightPropId] + math.floor(attribute[luckFightPropId] *(luckAddValue / 100))
                                            temp = nil
                                        end
                                    end
                                    luckFightValues = nil
                                    -- attribute[luckObj.fightPropId] = attribute[luckObj.fightPropId] + math.floor(attribute[luckObj.fightPropId] * (luckObj.addValue / 100))
                                end
                                if tempCount >= 6 then
                                    break
                                end
                            end
                        end
                    end

                    -------------装备镶嵌宝石属性数据---------------
                    if net.InstPlayerLineup then
                        local equipCount = 0
                        for lineupKey, lineupObj in pairs(net.InstPlayerLineup) do
                            if _instFormationId == lineupObj.int["3"] then
                                equipCount = equipCount + 1
                                local _instEquipId = lineupObj.int["5"]
                                --[[
							    local tempAttribute = getEquipWashAttribute(_instEquipId)
							    for attKey, attObj in pairs(tempAttribute) do
								    attribute[attKey] = attribute[attKey] + attObj
							    end
							    --]]
                                local tempAttribute = getEquipGemAttribute(_instEquipId)
                                for attKey, attObj in pairs(tempAttribute) do
                                    attribute[attKey] = attribute[attKey] + attObj
                                end
                                if equipCount >= 4 then
                                    break
                                end
                            end
                        end
                    end

                    -------------法宝和功法属性数据（具体值）---------------
                    if net.InstPlayerMagic then
                        local _magicCount = 0
                        -- cclog("执行几次啊")
                        for magicKey, magicObj in pairs(net.InstPlayerMagic) do
                            if instCardId == magicObj.int["8"] then
                                _magicCount = _magicCount + 1
                                local magicLv = DictMagicLevel[tostring(magicObj.int["6"])].level
                                local dictMagicData = DictMagic[tostring(magicObj.int["3"])]
                                for _valueI = 1, 6 do
                                    local _tValues = utils.stringSplit(dictMagicData["value" .. _valueI], "_")
                                    if string.len(dictMagicData["value" .. _valueI]) > 0 and _tValues and #_tValues > 0 then
                                        if _valueI <= 3 then
                                            local fightPropId = tonumber(_tValues[2])
                                            local fightAddValue = formula.getMagicValue1(magicLv, tonumber(_tValues[3]), tonumber(_tValues[4]))
                                            if tonumber(_tValues[1]) == 1 then
                                                magicPercent[fightPropId] =(magicPercent[fightPropId] and magicPercent[fightPropId] or 0) + fightAddValue
                                            else
                                                attribute[fightPropId] = attribute[fightPropId] + fightAddValue
                                            end
                                        else
                                            if (_valueI == 4 and magicLv >= 10) or(_valueI == 5 and magicLv >= 20) or(_valueI == 6 and magicLv >= 40) then
                                                magicPercent[tonumber(_tValues[1])] =(magicPercent[tonumber(_tValues[1])] and magicPercent[tonumber(_tValues[1])] or 0) + tonumber(_tValues[2])
                                            end
                                        end
                                    end
                                end

                                local magicAdvanceId = magicObj.int["10"]
                                if magicAdvanceId and magicAdvanceId > 0 then
                                    local magic_refining = { }
                                    if dictMagicData.magicQualityId <= StaticMagicQuality.DJ then
                                        for key, value in pairs(DictMagicrefining) do
                                            if dictMagicData.id == value.MagicId then
                                                magic_refining[value.starLevel] = value.id
                                            end
                                        end
                                    end
                                    local magicRifingingLevel = DictMagicrefining[tostring(magicAdvanceId)].starLevel
                                    for key, value in pairs(magic_refining) do
                                        if key <= magicRifingingLevel then
                                            local proValue = DictMagicrefining[tostring(value)]
                                            --    cclog("magic refining : "..proValue.fightPropId .. "  "..proValue.value)
                                            attribute[proValue.fightPropId] = attribute[proValue.fightPropId] + tonumber(proValue.value)
                                        end
                                    end
                                end

                                if _magicCount >= 2 then
                                    break
                                end
                            end
                        end
                    end
                    break
                end
            end

            -------------命宫属性数据---------------
            local instConstellId_table = utils.stringSplit(instConstellsId, ";")
            for key, id in pairs(instConstellId_table) do
                local _instConstellData = net.InstPlayerConstell[tostring(id)]
                -- 命宫实例数据
                local _dictConstellId = _instConstellData.int["4"]
                -- 命宫字典ID
                local _isUse = _instConstellData.string["5"]
                -- 命宫丹药状态 0-未服用 1-服用（全为1表示该命宫点亮）
                local _dictConstellData = DictConstell[tostring(_dictConstellId)]
                local _pills = _dictConstellData.pills
                -- 丹药 丹药字典Id用分号隔开
                local _isUses = utils.stringSplit(_isUse, ";")
                local _dictPillIds = utils.stringSplit(_pills, ";")
                for key, pillId in pairs(_dictPillIds) do
                    local _dictPillData = DictPill[tostring(pillId)]
                    if tonumber(_isUses[key]) == 1 then
                        if _dictPillData.tableTypeId == StaticTableType.DictFightProp then
                            attribute[_dictPillData.tableFieldId] = attribute[_dictPillData.tableFieldId] + _dictPillData.value
                        end
                    end
                end
            end



            --[[
		    -------------功法属性数据---------------
		    if instGongFaId > 0 and net.InstPlayerKungFu then
			    local _instGongFaData = net.InstPlayerKungFu[tostring(instGongFaId)]
			    local _fightProps = {}
			    _fightProps[1] = _instGongFaData.string["8"]
			    _fightProps[2] = _instGongFaData.string["9"]
			    _fightProps[3] = _instGongFaData.string["10"]
			    _fightProps[4] = _instGongFaData.string["12"]
			    _fightProps[5] = _instGongFaData.string["13"]
			    _fightProps[6] = _instGongFaData.string["14"]

			    for fpKey = 1, 6 do
				    if _fightProps[fpKey] and string.len(_fightProps[fpKey]) > 0 then
					    local _propData = utils.stringSplit(_fightProps[fpKey], "_") --[1]:fightPropId, [2]:value
					    local _fightPropId, _value = tonumber(_propData[1]), tonumber(_propData[2])
					    attribute[_fightPropId] = attribute[_fightPropId] + _value
				    end
			    end
		    end
		    --]]

            -------------红颜系统属性数据---------------
            -- local tempInstBeautyCard = {}
            -- if net.InstPlayerBeautyCard then
            -- 	for ipbKey, ipbObj in pairs(net.InstPlayerBeautyCard) do
            -- 		tempInstBeautyCard[ipbObj.int["3"]] = ipbObj
            -- 	end
            -- end
            -- for dictKey, dictObj in pairs(DictBeautyCardFight) do
            -- 	local _curBeautyCardExpId = 1 --默认为1级
            -- 	local instBeautyCard = tempInstBeautyCard[dictObj.beautyCardId]
            -- 	if instBeautyCard then
            -- 		_curBeautyCardExpId = instBeautyCard.int["4"]
            -- 	end
            -- 	if _curBeautyCardExpId >= dictObj.beautyCardExpId then
            -- 		local _fightPropId = dictObj.fightPropId
            -- 		local _value = dictObj.value
            -- 		attribute[_fightPropId] = attribute[_fightPropId] + _value
            -- 	end
            -- end
            -- tempInstBeautyCard = nil

            -------------法宝和功法属性数据（百分比）---------------
            if magicPercent then
                for _fightPropKey, _fightPropId in pairs(StaticFightProp) do
                    if magicPercent[_fightPropId] then
                        if (_fightPropId == StaticFightProp.blood or _fightPropId == StaticFightProp.wAttack or _fightPropId == StaticFightProp.fAttack or _fightPropId == StaticFightProp.wDefense or _fightPropId == StaticFightProp.fDefense) then
                            attribute[_fightPropId] = math.floor(attribute[_fightPropId] *(1 + magicPercent[_fightPropId] / 100))
                        else
                            ----------即将传入战斗中的XX率-----------
                            -- cclog("---------->>>@ " .. DictFightProp[tostring(_fightPropId)].name .. "率：" .. magicPercent[_fightPropId] .. "%%")
                        end
                    end
                end
            end

            --[[
		    -------------旧异火系统属性数据---------------
		    local instPlayerFireId = net.InstPlayer.int["18"] --玩家异火实例ID 0-未装备异火
		    if net.InstPlayerFire and instPlayerFireId > 0 then
			    local fireData = net.InstPlayerFire[tostring(instPlayerFireId)]
			    local dictFireId = fireData.int["3"] --异火字典ID
			    local fireLv = fireData.int["4"] --异火等级
			    local bySkillIds = fireData.string["6"] --被动技能
			    local dictFireData = DictFire[tostring(dictFireId)]
			    local fireSkillAddPercent = formula.getFireSkillAttribute(fireLv, dictFireData.fireSkillAdd)
			    local ids_ = utils.stringSplit(bySkillIds, ";")

			    for key, obj in pairs(ids_) do
				    local temp = utils.stringSplit(obj, "_") --[1]:位置, [2]:异火技能字典ID
				    local fireSkillId = tonumber(temp[2])

				    if fireSkillId > 0 then
					    local dictFireSkillData = DictFireSkill[tostring(fireSkillId)]
					    attribute[dictFireSkillData.fightPropId] = attribute[dictFireSkillData.fightPropId] + dictFireSkillData.fightPropValue * (fireSkillAddPercent / 100)
				    end
			    end
		    end
		    --]]


            ----------------异火属性数据---------------
            if not is3V3 and not noFire then
                local _fireFightProps = { }
                local _equipFireInstData = utils.getEquipFireInstData(instCardId)
                for _keyYF, _objYF in pairs(CustomDictYFireProp) do
                    local _condition = 0
                    -- 0.未达成, 1.达成
                    if cardQualityId >= _objYF.qualityId then
                        if cardQualityId == _objYF.qualityId then
                            if cardStarLevelId >= _objYF.starLevelId then
                                _condition = 1
                            end
                        else
                            _condition = 1
                        end
                    end
                    if _condition == 1 and #_equipFireInstData >= _objYF.equipFireCount then
                        local fightPropId = utils.stringSplit(_objYF.fightPropId, ";")
                        local fightPropValue = utils.stringSplit(_objYF.fightPropValue, ";")
                        for _k, _fightPropId in pairs(fightPropId) do
                            if _fireFightProps[tonumber(_fightPropId)] == nil then
                                _fireFightProps[tonumber(_fightPropId)] = 0
                            end
                            _fireFightProps[tonumber(_fightPropId)] = _fireFightProps[tonumber(_fightPropId)] + fightPropValue[_k]
                        end
                        fightPropValue = nil
                        fightPropId = nil
                    end
                end
                for _keyAtt, _objAtt in pairs(attribute) do
                    if _fireFightProps[_keyAtt] then
                        attribute[_keyAtt] = _objAtt *(1 + _fireFightProps[_keyAtt] / 100)
                    end
                end
                _fireFightProps = nil
                _equipFireInstData = nil
            end
            ----------------异火属性数据---------------


            ----------------境界称号的生命加成属性数据---------------
            local _titleHPAdd = 0
            local _dictTitleDetailData = DictTitleDetail[tostring(cardTitleDetailId)]
            if _dictTitleDetailData then
                local _dictTitleData = DictTitle[tostring(_dictTitleDetailData.titleId)]
                if _dictTitleData then
                    _titleHPAdd = tonumber((_dictTitleData.description == "") and "0" or _dictTitleData.description)
                end
            end
            ----------------翅膀天赋属性数据--------------
            if net.InstPlayerWing then
                for wingKey, wingValue in pairs(net.InstPlayerWing) do
                    if wingValue.int["6"] == instCardId then
                        for key, value in pairs(DictWingLuck) do
                            if value.cardId == dictCardId then
                                local lucks = utils.stringSplit(value.lucks, ";")
                                local values = utils.stringSplit(value.fightValues, ";")
                                if wingValue.int["5"] >= tonumber(lucks[1]) then
                                    local data = utils.stringSplit(values[1], "_")
                                    -- cclog(" data "..data[ 2 ])
                                    if tonumber(data[1]) == StaticFightProp.blood then
                                        _titleHPAdd = _titleHPAdd + tonumber(data[2]) * 100

                                    else
                                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + tonumber(data[2]) / 2
                                    end
                                end
                                if wingValue.int["5"] >= tonumber(lucks[2]) then
                                    -- cclog(" data "..data[ 2 ])
                                    local data = utils.stringSplit(values[2], "_")
                                    if tonumber(data[1]) == StaticFightProp.blood then
                                        _titleHPAdd = _titleHPAdd + tonumber(data[2]) * 100
                                    else
                                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + tonumber(data[2]) / 2
                                    end
                                end
                                break
                            end
                        end
                        break
                    end
                end
            end

            -- 称号和翅膀生命统一加百分比
            attribute[StaticFightProp.blood] = attribute[StaticFightProp.blood] * (1 + _titleHPAdd / 100)


            --------------联盟修炼技能的属性数据--------------
            if net.InstUnionPractice then
                -- 修炼Id_当前等级_当前经验;
                local practice = utils.stringSplit(net.InstUnionPractice.string["3"], ";")
                for key, obj in pairs(practice) do
                    local _tempObj = utils.stringSplit(obj, "_")
                    local _id = tonumber(_tempObj[1])
                    local _level = tonumber(_tempObj[2])
                    local _dictUnionPracticeData = DictUnionPractice[tostring(_id)]
                    if _dictUnionPracticeData then
                        local _tempData = utils.stringSplit(_dictUnionPracticeData.propEffect, "_")
                        local _tableTypeId = tonumber(_tempData[1])
                        local _fightPropId = tonumber(_tempData[2])
                        if _tableTypeId == StaticTableType.DictFightProp then
                            if _fightPropId < StaticFightProp.cutCrit then
                                attribute[_fightPropId] = attribute[_fightPropId] * (1 + (_level * _dictUnionPracticeData.levelAdd) / 100)
                            else
                                attribute[_fightPropId] = attribute[_fightPropId] + (_level * _dictUnionPracticeData.levelAdd) / 100
                            end
                        end
                    end
                    _tempObj = nil
                end
                practice = nil
            end

            if isFriend == 0 and not is3V3 then --非小伙伴加
                --结界属性数据
                if attr then
                    for key ,value in pairs( attr ) do
                        attribute[key] = attribute[key] + value
                    end
                elseif net.InstPlayerEnchantment then
                    local enchantIndex = tonumber( net.InstPlayerEnchantment.int["3"] )
                    local slots = net.InstPlayerEnchantment.string[ "4" ]
                    if slots then
                        local slotsData = utils.stringSplit( slots , ";" )
                        local slotsPro = utils.stringSplit( DictEnchantment[ tostring( enchantIndex ) ].slots , ";" )
                        for key ,value in pairs( slotsData ) do
                            if tonumber( value ) > 0 then
                                local propData = utils.stringSplit( slotsPro[ key ] , "_" )
                                local _fightPropId = tonumber(propData[1])
                               -- print( "value :" , value )
                                local attProp = utils.getCardAttribute( tonumber( value ) , nil , nil , true )
                                attribute[_fightPropId] = attribute[_fightPropId] + attProp[ _fightPropId ] * tonumber( propData[2] )
                                if tonumber( key ) == #slotsData then --界门
                                    local conditionData = utils.stringSplit( DictEnchantment[ tostring( enchantIndex ) ].addition , ";" )
                                    for i = 1 , #conditionData do
                                        local obj = utils.stringSplit( conditionData[ i ] , "_" )
                                        local conditionIndex1 = tonumber( obj[ 3 ] )
                                        local conditionIndex2 = tonumber( obj[ 4 ] )
                                        local condition1 = ""
                                        local condition2 = ""
                                        local cardData = {}
                                        local comCount = 0
                                        if conditionIndex1 == 0 then
                                            cardData[ #cardData + 1 ] = slotsData[ #slotsData ]
                                            comCount = 1
                                        elseif conditionIndex1 == #slotsData then
                                            cardData = slotsData
                                            comCount = conditionIndex1
                                        else
                                            cardData = slotsData
                                            comCount = conditionIndex1
                                        end
                                        local isEnough = false
                                        if conditionIndex2 == 1 then
                                            local aa = 0
                                            for key ,value in pairs( cardData ) do
                                                if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "9" ] >= tonumber( obj[ 5 ] ) then
                                                    aa = aa + 1
                                                end
                                            end
                                            if aa >= comCount then
                                                isEnough = true
                                            else
                                                isEnough = false
                                            end
                                        elseif conditionIndex2 == 2 then
                                            local aa = 0
                                            for key ,value in pairs( cardData ) do
                                                if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "6" ] >= tonumber( obj[ 5 ] ) then
                                                    aa = aa + 1
                                                end
                                            end
                                            if aa >= comCount then
                                                isEnough = true
                                            else
                                                isEnough = false
                                            end
                                        elseif conditionIndex2 == 3 then
                                            local aa = 0
                                            for key ,value in pairs( cardData ) do
                                                if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "4" ] == tonumber( obj[ 5 ] ) and net.InstPlayerCard[ tostring( value ) ].int[ "5" ] >= tonumber( obj[ 6 ] ) then
                                                    aa = aa + 1
                                                elseif tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "4" ] > tonumber( obj[ 5 ] ) then
                                                    aa = aa + 1
                                                end
                                            end
                                            if aa >= comCount then
                                                isEnough = true
                                            else
                                                isEnough = false
                                            end
                                        end
                                        if isEnough then
                                            attribute[tonumber( obj[ 1 ] )] = attribute[tonumber( obj[ 1 ] )] + attProp[ tonumber( obj[ 1 ] ) ] * tonumber( obj[ 2 ] ) 
                                        end
                                    end

                                end
                            end
                        end
                    end
                end
            end

        end       
    end
    if fightSoulValue then
        return attribute, fightSoulValue
    else
        return attribute
    end
end
--获取结界加的属性		
function utils.getEnchantmentPro()
	local attribute = {}
	if net.InstPlayerEnchantment then
        local enchantIndex = tonumber( net.InstPlayerEnchantment.int["3"] )
        local slots = net.InstPlayerEnchantment.string[ "4" ]
        if slots then
            local slotsData = utils.stringSplit( slots , ";" )
            local slotsPro = utils.stringSplit( DictEnchantment[ tostring( enchantIndex ) ].slots , ";" )
            for key ,value in pairs( slotsData ) do
                if tonumber( value ) > 0 then
                    local propData = utils.stringSplit( slotsPro[ key ] , "_" )
                    local _fightPropId = tonumber(propData[1])
                    local attProp = utils.getCardAttribute( tonumber( value ) , nil , nil , true , {} )
					if attribute[_fightPropId] then
						attribute[_fightPropId] = attribute[_fightPropId] + attProp[ _fightPropId ] * tonumber( propData[2] )
					else
						attribute[_fightPropId] = attProp[ _fightPropId ] * tonumber( propData[2] )
					end
                    if tonumber( key ) == #slotsData then --界门
                        local conditionData = utils.stringSplit( DictEnchantment[ tostring( enchantIndex ) ].addition , ";" )
                        for i = 1 , #conditionData do
                            local obj = utils.stringSplit( conditionData[ i ] , "_" )
                            local conditionIndex1 = tonumber( obj[ 3 ] )
                            local conditionIndex2 = tonumber( obj[ 4 ] )
                            local condition1 = ""
                            local condition2 = ""
                            local cardData = {}
                            local comCount = 0
                            if conditionIndex1 == 0 then
                                cardData[ #cardData + 1 ] = slotsData[ #slotsData ]
                                comCount = 1
                            elseif conditionIndex1 == #slotsData then
                                cardData = slotsData
                                comCount = conditionIndex1
                            else
                                cardData = slotsData
                                comCount = conditionIndex1
                            end
                            local isEnough = false
                            if conditionIndex2 == 1 then
                                local aa = 0
                                for key ,value in pairs( cardData ) do
                                    if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "9" ] >= tonumber( obj[ 5 ] ) then
                                        aa = aa + 1
                                    end
                                end
                                if aa >= comCount then
                                    isEnough = true
                                else
                                    isEnough = false
                                end
                            elseif conditionIndex2 == 2 then
                                local aa = 0
                                for key ,value in pairs( cardData ) do
                                    if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "6" ] >= tonumber( obj[ 5 ] ) then
                                        aa = aa + 1
                                    end
                                end
                                if aa >= comCount then
                                    isEnough = true
                                else
                                    isEnough = false
                                end
                            elseif conditionIndex2 == 3 then
                                local aa = 0
                                for key ,value in pairs( cardData ) do
                                    if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "4" ] == tonumber( obj[ 5 ] ) and net.InstPlayerCard[ tostring( value ) ].int[ "5" ] >= tonumber( obj[ 6 ] ) then
                                        aa = aa + 1
                                    elseif tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "4" ] > tonumber( obj[ 5 ] ) then
                                        aa = aa + 1
                                    end
                                end
                                if aa >= comCount then
                                    isEnough = true
                                else
                                    isEnough = false
                                end
                            end
                            if isEnough then
								if attribute[tonumber( obj[ 1 ] )]  then
									attribute[tonumber( obj[ 1 ] )] = attribute[tonumber( obj[ 1 ] )] + attProp[ tonumber( obj[ 1 ] ) ] * tonumber( obj[ 2 ] ) 
								else
									attribute[tonumber( obj[ 1 ] )] = attProp[ tonumber( obj[ 1 ] ) ] * tonumber( obj[ 2 ] ) 
								end
                            end
                        end

                    end
                end
            end
        end
    end
	return attribute
end
--- 获取玩家战力值
function utils.getFightValue()
    local fightValue = 0
    if net.InstPlayerFormation then
        local attr = utils.getEnchantmentPro()
        for key, obj in pairs(net.InstPlayerFormation) do
            if obj.int["4"] == 1 or obj.int["4"] == 2 then
                local instCardId = obj.int["3"]
                -- 卡牌实例ID
                local attribute, fightSoulValue = utils.getCardAttribute(instCardId, 0 , nil , nil , attr )
                for _fightPropId, _fightPropValue in pairs(attribute) do
                    if utils.FightValueFactor[_fightPropId] then
                        fightValue = fightValue +(_fightPropValue / utils.FightValueFactor[_fightPropId])
                    end
                end
                fightValue = fightValue + fightSoulValue
            end
        end

        --------------联盟修炼技能的战力数据--------------
        if net.InstUnionPractice then
            -- 修炼Id_当前等级_当前经验;
            local practice = utils.stringSplit(net.InstUnionPractice.string["3"], ";")
            for key, obj in pairs(practice) do
                local _tempObj = utils.stringSplit(obj, "_")
                local _id = tonumber(_tempObj[1])
                local _level = tonumber(_tempObj[2])
                local _dictUnionPracticeData = DictUnionPractice[tostring(_id)]
                if _dictUnionPracticeData then
                    local _tempData = utils.stringSplit(_dictUnionPracticeData.propEffect, "_")
                    local _tableTypeId = tonumber(_tempData[1])
                    local _fightPropId = tonumber(_tempData[2])
                    if _tableTypeId == StaticTableType.DictFightProp and _fightPropId >= StaticFightProp.cutCrit then
                        for _k, _o in pairs(DictUnionPracticeUpgrade) do
                            if _o.unionPracticeId == _dictUnionPracticeData.id and _o.level == _level then
                                fightValue = fightValue + _o.fightValueAdd
                                break
                            end
                        end
                    end
                    _tempData = nil
                end
                _tempObj = nil
            end
            practice = nil
        end

    end
    --    if net.InstPlayerManualSkillLine and net.InstPlayerManualSkill then
    --        for i = 1, 4 do
    --            local _id = net.InstPlayerManualSkillLine.int[tostring(i + 2)]
    --            if _id > 0 and net.InstPlayerManualSkill[tostring(_id)] then
    --                local _instManualSkill = net.InstPlayerManualSkill[tostring(_id)]
    --                local _dictManualSkillData = DictManualSkill[tostring(_instManualSkill.int["4"])]
    --                local _skillLv = _instManualSkill.int["5"]
    --                fightValue = fightValue + formula.getManualSkillFightValue(_skillLv, _dictManualSkillData.fightValue, _dictManualSkillData.fightValueAdd)
    --            end
    --        end
    --    end
    return math.floor(fightValue)
end

--- 判断该协议是否会改变战力值
-- @header : 协议号
function utils.isChangeFightValue(header)
    for key, code in pairs(dp.changeFightValueHeader) do
        if code == header then
            return true
        end
    end
    return false
end

--- 战斗胜利后需要验证的数据
function utils.fightVerifyData()
    local str = ""
    local _count = 0
    if net.InstPlayerCard then
        for key, value in pairs(net.InstPlayerCard) do
            if value.int["10"] == 1 then
                _count = _count + value.int["1"] + value.int["3"] + value.int["9"]
            end
        end
    end
    str = str .. "1:" .. _count
    _count = 0
    if net.InstPlayerEquip then
        for key, value in pairs(net.InstPlayerEquip) do
            if value.int["6"] ~= 0 then
                _count = _count + value.int["1"] + value.int["5"] + value.int["8"] + value.int["4"]
            end
        end
    end
    str = str .. ";2:" .. _count
    _count = 0
    if net.InstPlayerMagic then
        for key, obj in pairs(net.InstPlayerMagic) do
            if obj.int["8"] ~= 0 then
                _count = _count + obj.int["1"] + obj.int["6"]
            end
        end
    end
    str = str .. ";3:" .. _count
    --   cclog("str : ----------------->"..str)

    --    if net.InstPlayerFormation then
    --        str = str .. "1:"
    --        local _tempIndex = 0
    --        for key, obj in pairs(net.InstPlayerFormation) do
    --            _tempIndex = _tempIndex + 1
    --            local instCardId = obj.int["3"]
    --            local dictCardId = obj.int["6"]
    --            local cardLevel = 0
    --            if net.InstPlayerCard then
    --                cardLevel = net.InstPlayerCard[tostring(instCardId)].int["9"]
    --            end
    --            str = str .. instCardId .. "_" .. cardLevel .. "_" .. dictCardId .. "|"
    --        end
    --        if string.sub(str, string.len(str), string.len(str)) == "|" then
    --            str = string.sub(str, 1, string.len(str) -1)
    --        end
    --    end
    --    if net.InstPlayerLineup then
    --        str = str .. ";2:"
    --        for key, obj in pairs(net.InstPlayerLineup) do
    --            local instEquipId = obj.int["5"]
    --            local equipLevel = 0
    --            local advanceId = 0
    --            local dictEquipid = 0
    --            if net.InstPlayerEquip then
    --                local InstPlayerEquip = net.InstPlayerEquip[tostring(instEquipId)]
    --                equipLevel = InstPlayerEquip.int["5"]
    --                advanceId = InstPlayerEquip.int["8"]
    --                dictEquipid = InstPlayerEquip.int["4"]
    --            end
    --            str = str .. instEquipId .. "_" .. equipLevel .. "_" .. advanceId  .. "_" .. dictEquipid .. "|"
    --        end
    --        local strLastChar = string.sub(str, string.len(str), string.len(str))
    --        if strLastChar == ":" then
    --            str = string.sub(str, 1, string.len(str) -3)
    --        elseif strLastChar == "|" then
    --            str = string.sub(str, 1, string.len(str) -1)
    --        end
    --    end
    --    if net.InstPlayerMagic then
    --        str = str .. ";3:"
    --        for key, obj in pairs(net.InstPlayerMagic) do
    --            if obj.int["8"] > 0 then
    --                local instMagicId = obj.int["1"]
    --                local magicLevelId = obj.int["6"]
    --                str = str .. instMagicId .. "_" .. magicLevelId .. "|"
    --            end
    --        end
    --        local strLastChar = string.sub(str, string.len(str), string.len(str))
    --        if strLastChar == ":" then
    --            str = string.sub(str, 1, string.len(str) -3)
    --        elseif strLastChar == "|" then
    --            str = string.sub(str, 1, string.len(str) -1)
    --        end
    --    end
    if net.InstPlayerTrain then
        str = str .. ";4:"
        local _trainValue = 0
        for key, obj in pairs(net.InstPlayerTrain) do
            local instTrainId = obj.int["1"]
            --            local instCardId = obj.int["3"]
            local fightPropValue = obj.int["5"]
            _trainValue = _trainValue +(instTrainId + fightPropValue)
            --            for _ipfKey, _ipfObj in pairs(net.InstPlayerFormation) do
            --                if instCardId == _ipfObj.int["3"] then
            --                    str = str .. instTrainId .. "_" .. fightPropValue .. "|"
            --                    break
            --                end
            --            end
        end
        str = str .. _trainValue
        local strLastChar = string.sub(str, string.len(str), string.len(str))
        if strLastChar == ":" then
            str = string.sub(str, 1, string.len(str) -3)
        elseif strLastChar == "|" then
            str = string.sub(str, 1, string.len(str) -1)
        end
    end
    if net.InstPlayerFightSoul then
        str = str .. ";5:"
        local _fightSoulValue = 0
        for key, obj in pairs(net.InstPlayerFightSoul) do
            local instFightSoulId = obj.int["1"]
            local fightSoulLevel = obj.int["5"]
            local instCardId = obj.int["7"]
            if instCardId > 0 then
                _fightSoulValue = _fightSoulValue +(instFightSoulId + fightSoulLevel)
            end
            --            for _ipfKey, _ipfObj in pairs(net.InstPlayerFormation) do
            --                if instCardId == _ipfObj.int["3"] then
            --                    str = str .. instFightSoulId .. "_" .. fightSoulLevel .. "|"
            --                    break
            --                end
            --            end
        end
        str = str .. _fightSoulValue
        local strLastChar = string.sub(str, string.len(str), string.len(str))
        if strLastChar == ":" then
            str = string.sub(str, 1, string.len(str) -3)
        elseif strLastChar == "|" then
            str = string.sub(str, 1, string.len(str) -1)
        end
    end
    --验证翅膀
    if net.InstPlayerWing then
        local _wingValue = 0
        for key ,value in pairs ( net.InstPlayerWing ) do
            if value.int[ "6" ] > 0 then
                _wingValue = _wingValue + value.int[ "1" ] + value.int[ "3" ] + value.int[ "4" ] + value.int[ "5" ] 
            end
        end
        str = str .. ";6:" .. _wingValue
    end
    --验证魔核镶嵌
    if net.InstEquipGem then
        local _gemValue = 0
        for key ,value in pairs ( net.InstEquipGem ) do
            if value.int[ "4" ] > 0 then
                _gemValue = _gemValue + value.int[ "1" ] + value.int[ "3" ] + value.int[ "4" ]
            end
        end
        str = str .. ";7:" .. _gemValue      
    end
    return str
end

function utils.addParticleEffect(node, add, config)
    local size = node:getContentSize()
    local anchorSize = config and config.anchorSize or 0
    local offset = config and config.offset or 0
    local t = config and config.t or 0.8
    if node:getChildByName("particle1") then
        node:removeChildByName("particle1")
        node:removeChildByName("particle2")
    end
    if add then
        for _i = 1, 2 do
            local effect = cc.ParticleSystemQuad:create("particle/ui_anim8_effect.plist")
            effect:setName("particle" .. _i)
            node:addChild(effect)
            effect:setPositionType(cc.POSITION_TYPE_RELATIVE)
            if _i == 1 then
                effect:setPosition(anchorSize + offset, offset)
                effect:runAction(utils.MyPathFun(anchorSize + offset, size.height - 2 * offset, size.width - 2 * anchorSize - 2 * offset, t, 1))
            else
                effect:setPosition(size.width - anchorSize - offset, size.height - offset)
                effect:runAction(utils.MyPathFun(anchorSize + offset, size.height - 2 * offset, size.width - 2 * anchorSize - 2 * offset, t, 0))
            end
        end
    end
end

-- 加入套装粒子光效
function utils.addFrameParticle(item, add, sc, six, offsetW, offsetH)
    if item then
        if item:getChildByName("particle1") then
            item:removeChildByName("particle1")
            item:removeChildByName("particle2")
        end
    end
    if add then
        local size = item:getContentSize()
        local offX, offY = 0, 0
        if offsetW then
            size = cc.size(size.width - offsetW, size.height - offsetH)
            offX = offsetW / 2
            offY = offsetH / 2
        end
        local particle1 = cc.ParticleSystemQuad:create("particle/ui_anim8_effect.plist")
        particle1:setPositionType(cc.POSITION_TYPE_RELATIVE)
        local path1 = nil
        if six then
            path1 = utils.MyPathFunSix(size.width, size.height, 0.8, 1)
            particle1:setPosition(cc.p(size.width / 4 - 2, -2))
            particle1:setName("particle1")
        else
            path1 = utils.MyPathFun(offX, size.height, size.width, 0.8, 1)
            particle1:setPosition(cc.p(offX, offY))
            particle1:setName("particle1")
        end
        if sc then
            particle1:setScale(sc)
        end
        item:addChild(particle1)
        particle1:runAction(path1)
        local particle2 = cc.ParticleSystemQuad:create("particle/ui_anim8_effect.plist")
        particle2:setPositionType(cc.POSITION_TYPE_RELATIVE)
        local path2 = nil
        if six then
            path2 = utils.MyPathFunSix(size.width, size.height, 0.8, 2)
            particle2:setPosition(cc.p(size.width * 3 / 4 + 2, size.height + 2))
            particle2:setName("particle2")
        else
            path2 = utils.MyPathFun(offX, size.height, size.width, 0.8, 2)
            particle2:setPosition(cc.p(size.width + offX, size.height + offY))
            particle2:setName("particle2")
        end
        if sc then
            particle2:setScale(sc)
        end
        item:addChild(particle2)
        particle2:runAction(path2)
    end
end

function utils.addThingParticle(thing, item, add)
    local _thingData = utils.stringSplit(thing, "_")
    -- [1]:tableType, [2]:tableField, [3]:value
    _tableTypeId, _tableFieldId = tonumber(_thingData[1]), tonumber(_thingData[2])
    local flag = false
    if _tableTypeId == StaticTableType.DictEquipment then
        -- 装备
        local dictData = DictEquipment[tostring(_tableFieldId)]
        if dictData then
            if dictData.equipQualityId == 4 then
                flag = true
            end
        end
    elseif _tableTypeId == StaticTableType.DictMagic then
        -- 功法法宝
        local dictData = DictMagic[tostring(_tableFieldId)]
        if dictData then
            if dictData.magicQualityId == 1 then
                flag = true
            end
        end
    elseif _tableTypeId == StaticTableType.DictCard then
        -- 卡片
        local dictData = DictCard[tostring(_tableFieldId)]
        if dictData then
            if dictData.qualityId == 4 then
                flag = true
            end
        end
    elseif _tableTypeId == StaticTableType.DictThing then
        local dictData = DictThing[tostring(_tableFieldId)]
        if dictData then
            if dictData.level >= 6 then flag = true end
            if dictData.bagTypeId == 3 then
                -- 装备碎片
                local tempData = DictEquipment[tostring(dictData.equipmentId)]
                if tempData then
                    if tempData.equipQualityId == 4 then
                        flag = true
                    end
                end
            elseif dictData.bagTypeId == 1 then
                -- 橙色功法法宝礼盒
                if _tableFieldId == 1000 or _tableFieldId == 1001
                    or _tableFieldId == 1003 or _tableFieldId == 1004
                    or _tableFieldId == 1006 or _tableFieldId == 1008 then
                    flag = true
                end
            end
        end
    elseif _tableTypeId == StaticTableType.DictChip then
        -- 功法法宝碎片
        local dictData = DictChip[tostring(_tableFieldId)]
        if dictData then
            local tempData = DictMagic[tostring(dictData.skillOrKungFuId)]
            if tempData then
                if tempData.magicQualityId == 1 then
                    flag = true
                end
            end
        end
    elseif _tableTypeId == StaticTableType.DictCardSoul then
        -- 卡牌魂魄
        local dictData = DictCardSoul[tostring(_tableFieldId)]
        if dictData then
            local tempData = DictCard[tostring(dictData.cardId)]
            if tempData then
                if tempData.qualityId == 4 then
                    flag = true
                end
            end
        end
    end
    if flag then
        utils.addFrameParticle(item, add)
    else
        if item:getChildByName("particle1") then
            item:removeChildByName("particle1")
            item:removeChildByName("particle2")
        end
    end
end

-- 获取物品的图片
-- @flag false 为小图片  true 为大图
-- @thingId : 物品字典ID
function utils.getThingImage(thingId, flag)
    local dictData = DictThing[tostring(thingId)]
    -- 装备字典表
    local imageName = nil
    if flag == false then
        imageName = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
    else
        imageName = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
    end
    return imageName
end

-- 获取物品的数量
-- @thingId : 物品字典ID
function utils.getThingCount(thingId)
    local _thingCount = 0
    if net.InstPlayerThing then
        for key, obj in pairs(net.InstPlayerThing) do
            if obj.int["3"] == tonumber(thingId) then
                _thingCount = obj.int["5"]
                break
            end
        end
    end
    return _thingCount
end


-- 获取丹药的数量
-- @pillId : 丹药字典ID
function utils.getPillCount(pillId)
    local _pillCount = 0
    if net.InstPlayerPill then
        for key, obj in pairs(net.InstPlayerPill) do
            if obj.int["3"] == tonumber(pillId) then
                _pillCount = obj.int["4"]
                break
            end
        end
    end
    return _pillCount
end

-- 获取丹药药方的数量
-- @pillRecipeId : 丹药药方字典ID
function utils.getPillRecipeCount(pillRecipeId)
    local _pillRecipeCount = 0
    if net.InstPlayerPillRecipe then
        for key, obj in pairs(net.InstPlayerPillRecipe) do
            if obj.int["3"] == tonumber(pillRecipeId) then
                _pillRecipeCount = obj.int["4"]
                break
            end
        end
    end
    return _pillRecipeCount
end

-- 获取丹药材料的数量
-- @pillThingId : 丹药材料字典ID
function utils.getPillThingCount(pillThingId)
    local _pillThingCount = 0
    if net.InstPlayerPillThing then
        for key, obj in pairs(net.InstPlayerPillThing) do
            if obj.int["3"] == tonumber(pillThingId) then
                _pillThingCount = obj.int["4"]
                break
            end
        end
    end
    return _pillThingCount
end

function utils.getPercent(_curV, _maxV)
    local _percent = _curV / _maxV * 100
    if _percent > 100 then
        _percent = 100
    end
    return _percent
end

--- 富文本格式化（内容格式：<color=0,0,0>文本内容</color>）
-- 返回一个table
-- table.color : c3b对象, table.text : 要显示的文本内容
function utils.richTextFormat(_msgContent)
    local contentData = { }
    local root = utils.stringSplit(_msgContent, "<color=")
    for key, rootObj in pairs(root) do
        local a = utils.stringSplit(rootObj, "</color>")
        for _aKey, _aObj in pairs(a) do
            local b = utils.stringSplit(_aObj, ">")
            if #b == 2 then
                local c = utils.stringSplit(b[1], ",")
                contentData[#contentData + 1] = {
                    color = cc.c3b(c[1],c[2],c[3]),
                    text = b[2]
                }
            else
                contentData[#contentData + 1] = {
                    color = cc.c3b(255,255,255),
                    text = b[1]
                }
            end
        end
    end
    return contentData
end

--- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function utils.stringSplit(str, split_char)
    local sub_str_tab = { };
    if str == nil then
        return sub_str_tab
    end
    while (true) do
        local pos, pos1 = string.find(str, split_char);
        if (not pos) then
            if str ~= "" then
                sub_str_tab[#sub_str_tab + 1] = str;
            end
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        if pos1 + 1 > #str then break end
        str = string.sub(str, pos1 + 1, #str);
    end

    return sub_str_tab;
end
--- 字符串的长度(包括中文)
function utils.utf8len(str)
    local len = #str
    local left = len
    local cnt = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(str, - left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end
--- 获得指定字符串长度(包括中文)---
function utils.getUTF8Str(str, index)
    local _str = nil

    local cnt = 0
    local len = #str
    local left = len
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(str, - left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
        if cnt == index then
            _str = string.sub(str, - left - i, - left - 1)
            break
        end
    end
    return _str
end
--- 截取指定字符串(包括中文)
--- index_l 左指针
--- index_r 右指针
function utils.UTF8StrSub(str, index_l, index_r)
    local _str = nil
    local _index_l = nil
    local _index_r = nil
    local cnt = 0
    local len = #str
    local left = len
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(str, - left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
        if cnt == index_l then
            _index_l = - left - i
            if not index_r then
                _str = string.sub(str, _index_l, len)
                break
            end
        elseif cnt == index_r then
            _index_r = - left
            _str = string.sub(str, _index_l, _index_r - 1)
            break
        end
    end
    return _str
end
--- 参数:时间字符串 less 减少几个小时(24小时内)
-- FormatTime  yyyy-MM-dd HH:mm:ss
-- 返回table表
function utils.changeTimeFormat(FormatTime, less)
    local time_tab = { }
    local temp = utils.stringSplit(FormatTime, " ")
    local date = utils.stringSplit(temp[1], "-")
    local time = utils.stringSplit(temp[2], ":")
    if less then
        time[1] = time[1] - less
        if time[1] < 0 then
            time[1] =(time[1] % 24)
            date[3] = date[3] -1
        end
    end
    table.insert(time_tab, date[1])
    -- 年
    table.insert(time_tab, date[2])
    -- 月
    table.insert(time_tab, date[3])
    -- 日
    table.insert(time_tab, tonumber(time[1]) * 3600 + tonumber(time[2]) * 60 + tonumber(time[3]))
    table.insert(time_tab, time[1])
    -- 时
    table.insert(time_tab, time[2])
    -- 分
    table.insert(time_tab, time[3])
    -- 秒
    return time_tab
end

---- 通过日期获取秒 yyyy-MM-dd HH:mm:ss less 减少几个小时(24小时内)
function utils.GetTimeByDate(FormatTime, less)
    local temp = utils.stringSplit(FormatTime, " ")
    local date = utils.stringSplit(temp[1], "-")
    local time = utils.stringSplit(temp[2], ":")
    if less then
        time[1] = time[1] - less
        if time[1] < 0 then
            time[1] = time[1] % 24
            date[3] = date[3] -1
        end
    end
    local t = os.time( { year = date[1], month = date[2], day = date[3], hour = time[1], min = time[2], sec = time[3] })

    return t
end
-----获得当前时间 单位秒-----
function utils.getCurrentTime()
    --[[
	local serverTime =utils.GetTimeByDate(net.serverLoginTime)
	local subtime = os.time()  - net.LoginTime  ---从登录到切换到该界面已经过去的时间
	if subtime < 0 or os.time() < utils.time_stamp then --如果玩家更改本地时间就提示
		utils.netErrorDialog(Lang.utils1, true)
	else
		utils.time_stamp = os.time()
	end

	local currentTime = serverTime +subtime
	return currentTime
    ]]
    return(utils.GetTimeByDate(net.serverLoginTime) + dp.curTimerNumber)
end

local lasttime, timenow = nil, nil

-- 返回m~n之间的随机数
function utils.random(m, n)
    while (true) do
        timenow = os.time()
        if timenow ~= lasttime then
            return math.random(m, n)
        end
        lasttime = timenow
    end
end

--- 返回size个m~n之间不同的随机数
function utils.randoms(m, n, size)
    local function isContains(t_, v_)
        if t_ and table.getn(t_) > 0 then
            for i = 1, table.getn(t_) do
                if t_[i] == v_ then
                    return true
                end
            end
        else
            return false
        end
    end

    local rnd = { }
    for i = 1, size do
        local value = utils.random(m, n)
        while (isContains(rnd, value)) do
            value = utils.random(m, n)
        end
        rnd[i] = value
    end

    return rnd
end

--- 快速排序
-- @_table : 需要排序的表
-- @compareFunc : 比较函数
function utils.quickSort(_table, compareFunc)

    local function partion(_table, left, right, compareFunc)
        local key = _table[left]
        local index = left
        _table[index], _table[right] = _table[right], _table[index]
        local i = left
        while i < right do
            if compareFunc(key, _table[i]) then
                _table[index], _table[i] = _table[i], _table[index]
                index = index + 1
            end
            i = i + 1
        end
        _table[right], _table[index] = _table[index], _table[right]
        return index
    end

    local function quick(_table, left, right, compareFunc)
        if left < right then
            local index = partion(_table, left, right, compareFunc)
            quick(_table, left, index - 1, compareFunc)
            quick(_table, index + 1, right, compareFunc)
        end
    end

    quick(_table, 1, #_table, compareFunc)
end

function cc.release(_node)
    if _node then
        UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),
        cc.CallFunc:create( function() _node:release() end)))
    end
end






--- 副本掉落的弹出提示框
-- @_dictData : 字典数据 type 1:魔王试炼 2:活动副本 3:主线副本，4：商店 5：炼气塔 7：远古遗迹:
function utils.storyDropOutDialog(_dictData, type)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:retain()
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 450))
    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
    local bgSize = bg_image:getPreferredSize()
    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setTouchEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width * 0.3, bgSize.height - closeBtn:getContentSize().height * 0.3))
    local childs = UIManager.uiLayer:getChildren()
    local function closeBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.uiLayer:removeChild(bg_image, true)
            cc.release(bg_image)
            for i = 1, #childs do
                childs[i]:setEnabled(true)
            end
        end
    end
    closeBtn:addTouchEventListener(closeBtnEvent)
    bg_image:addChild(closeBtn, 3)

    local thingFrameBg = ccui.ImageView:create()
    thingFrameBg:loadTexture("ui/mg_kuang_red.png")
    thingFrameBg:setPosition(cc.p(thingFrameBg:getContentSize().width * 0.8, bgSize.height - thingFrameBg:getContentSize().height * 0.8))
    bg_image:addChild(thingFrameBg)
    local thingFrame = ccui.ImageView:create()
    thingFrame:loadTexture("ui/quality_small_purple.png")
    thingFrame:setPosition(thingFrameBg:getPosition())
    bg_image:addChild(thingFrame)
    local thingIcon = ccui.ImageView:create()
    thingIcon:loadTexture("image/" .. DictUI[tostring(_dictData.smallUiId)].fileName)
    thingIcon:setPosition(thingFrame:getPosition())
    bg_image:addChild(thingIcon)
    local thingName = ccui.Text:create()
    thingName:setString(_dictData.name)
    thingName:setFontName(dp.FONT)
    thingName:setFontSize(23)
    thingName:setTextColor(cc.c4b(255, 255, 255, 255))
    thingName:setPosition(cc.p(thingFrameBg:getPositionX(), thingFrameBg:getPositionY() - thingFrameBg:getContentSize().height / 2 - thingName:getContentSize().height / 2))
    bg_image:addChild(thingName)

    local ui_title = ccui.Text:create()
    ui_title:setString(Lang.utils2)
    ui_title:setFontName(dp.FONT)
    ui_title:setFontSize(23)
    ui_title:setTextColor(cc.c4b(255, 255, 255, 255))
    ui_title:setPosition(cc.p(thingFrameBg:getContentSize().width +(bgSize.width - thingFrameBg:getContentSize().width) / 2, thingFrameBg:getPositionY() + thingFrameBg:getContentSize().height / 2 - ui_title:getContentSize().height / 2))
    bg_image:addChild(ui_title)

    local outBarrierIds = utils.stringSplit(_dictData.outBarrier, ";")
    local count = #outBarrierIds
    local y = ui_title:getPositionY()
    for key, barrierId in pairs(outBarrierIds) do
        local ui_button = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png", "ui/tk_btn_big_hui.png")
        ui_button:setPressedActionEnabled(true)
        ui_button:setTouchEnabled(true)
        ui_button:setTitleFontSize(23)
        ui_button:setTitleFontName(dp.FONT)
        ui_button:setTitleText(DictBarrier[barrierId].name)
        ui_button:setTitleColor(cc.c3b(51, 25, 4))
        local function btnEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                closeBtnEvent(closeBtn, eventType)
                UIFightTask.isFromMedicine = true
                UIFightTask.showFightTaskChooseById(tonumber(barrierId), true)
            end
        end
        ui_button:addTouchEventListener(btnEvent)
        ui_button:setEnabled(false)
        ui_button:setBright(false)
        for ipbKey, ipbObj in pairs(net.InstPlayerBarrier) do
            if tonumber(barrierId) == ipbObj.int["3"] then
                ui_button:setEnabled(true)
                ui_button:setBright(true)
                break
            end
        end
        y = y - ui_button:getContentSize().height - 20
        ui_button:setPosition(cc.p(ui_title:getPositionX(), y))
        bg_image:addChild(ui_button)
    end

    if type then
        if type then
            local ui_button = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png", "ui/tk_btn_big_hui.png")
            ui_button:setPressedActionEnabled(true)
            ui_button:setTouchEnabled(true)
            ui_button:setTitleFontSize(23)
            ui_button:setTitleFontName(dp.FONT)
            if type == 1 then
                ui_button:setTitleText(Lang.utils3)
                if net.InstPlayer.int["4"] < DictChapter[tostring(tonumber(_dictData.id) -6)].openLeve then
                    ui_button:setEnabled(false)
                    ui_button:setBright(false)
                end
            elseif type == 2 then
                ui_button:setTitleText(Lang.utils4)
                local openLevel = 1
                for key, obj in pairs(DictBarrier) do
                    if obj.chapterId == DictSysConfig[tostring(StaticSysConfig.shcx)].value and obj.type == 1 then
                        openLevel = obj.openLevel
                        break
                    end
                end
                if net.InstPlayer.int["4"] < openLevel then
                    ui_button:setEnabled(false)
                    ui_button:setBright(false)
                end
            elseif type == 3 then
                ui_button:setTitleText(Lang.utils5)
            elseif type == 4 then
                ui_button:setTitleText(Lang.utils6)
            elseif type == 5 then
                ui_button:setTitleText(Lang.utils7)
            elseif type == 7 then
                ui_button:setTitleText(Lang.utils8)
                local lootOpen = false
                if net.InstPlayerBarrier then
                    for key, obj in pairs(net.InstPlayerBarrier) do
                        if obj.int["3"] == 20 then
                            -- 17关开启
                            lootOpen = true
                            break;
                        end
                    end
                end
                if not lootOpen then
                    ui_button:setEnabled(false)
                    ui_button:setBright(false)
                end
            end
            ui_button:setTitleColor(cc.c3b(51, 25, 4))
            local function btnEvent(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    closeBtnEvent(closeBtn, eventType)
                    --                    UIFightTask.isFromMedicine = true
                    --                    UIFightTask.showFightTaskChooseById(tonumber(barrierId), true)
                    if type == 1 then
                        UIFight.setFlag(1, 2)
                        if UILineup.Widget and UILineup.Widget:getParent() then
                            UIFightPreView.wingTo = true
                        end
                        UIManager.showScreen("ui_notice", "ui_team_info", "ui_fight", "ui_menu")
                        UIFightPreView.setChapterId(DictChapter[tostring(tonumber(_dictData.id) -6)].id)
                        UIManager.pushScene("ui_fight_preview")
                    elseif type == 2 then
                        UIFight.setFlag(3)
                        if UILineup.Widget and UILineup.Widget:getParent() then
                            UIFightActivityChoose.wingTo = true
                        end
                        UIManager.showScreen("ui_notice", "ui_team_info", "ui_fight", "ui_menu")
                        UIFightActivityChoose.setChapter(DictSysConfig[tostring(StaticSysConfig.shcx)].value, 3)
                        UIManager.pushScene("ui_fight_activity_choose")
                    elseif type == 3 then
                        UIFight.setFlag(2)
                        UIManager.showWidget("ui_notice", "ui_team_info", "ui_fight", "ui_menu")
                        UIManager.pushScene("ui_fight")
                    elseif type == 4 then
                        UIManager.hideWidget("ui_team_info")
                        UIShop.reset(2)
                        UIShop.getShopList(1, true)
                    elseif type == 5 then
                        UITowerShop.setTag(2)
                        UIManager.pushScene("ui_tower_shop")
                    elseif type == 7 then
                        UIManager.hideWidget("ui_team_info")
                        UILoot.show(1, 1)
                    end
                end
            end
            ui_button:addTouchEventListener(btnEvent)
            --            ui_button:setEnabled(false)
            --            ui_button:setBright(false)
            --            for ipbKey, ipbObj in pairs(net.InstPlayerBarrier) do
            --                if tonumber(barrierId) == ipbObj.int["3"] then
            --                    ui_button:setEnabled(true)
            --                    ui_button:setBright(true)
            --                    break
            --                end
            --            end
            y = y - ui_button:getContentSize().height - 20
            ui_button:setPosition(cc.p(ui_title:getPositionX(), y))
            bg_image:addChild(ui_button)
        end
    end

    UIManager.uiLayer:addChild(bg_image, 10000)
    for i = 1, #childs do
        if childs[i]:getTag() ~= bg_image then
            childs[i]:setEnabled(false)
        end
    end
end

--- 网络错误提示框
function utils.netErrorDialog(msg, _flag)
    if not _flag then
        if dp.RELEASE then
            if UILogin.Widget and UILogin.Widget:getParent() then
                return
            end
        else
            if TestLogin.Widget and TestLogin.Widget:getParent() then
                return
            end
        end
        if utils.disCount == nil then
            utils.disCount = 0
        end
        utils.disCount = utils.disCount + 1
        if utils.disCount < 3 then
            UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
                net.connect(net.ip, net.port, net.openId, net.params)
            end )))
            return
        end
    end
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
    dialog:retain()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(450, 300))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.utils9)
    title:setFontName(dp.FONT)
    title:setFontSize(30)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.83))
    bg_image:addChild(title)

    local msgLabel = ccui.Text:create()
    msgLabel:setString(msg)
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextAreaSize(cc.size(325, 200))
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(23)
    msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.6))
    bg_image:addChild(msgLabel)

    local sureBtn = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png")
    if _flag then
        sureBtn:setTitleText(_flag == -1 and Lang.utils10 or Lang.utils11)
    else
        sureBtn:setTitleText(Lang.utils12)
    end
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(0, 0, 0))
    sureBtn:setTitleFontSize(23)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    if not _flag then
        sureBtn:setPosition(cc.p(bgSize.width * 0.25, bgSize.height * 0.2))
    else
        sureBtn:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.2))
    end
    bg_image:addChild(sureBtn)
    local backBtn = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png")
    if not _flag then
        backBtn:setTitleText(Lang.utils13)
        backBtn:setTitleFontName(dp.FONT)
        backBtn:setTitleColor(cc.c3b(0, 0, 0))
        backBtn:setTitleFontSize(23)
        backBtn:setPressedActionEnabled(true)
        backBtn:setTouchEnabled(true)
        backBtn:setPosition(cc.p(bgSize.width * 0.75, bgSize.height * 0.2))
        bg_image:addChild(backBtn)
    end
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.uiLayer:removeChild(dialog, true)
            cc.release(dialog)
            if sender == backBtn then
                dp.Logout()
            else
                if _flag then
                    -- 停服操作应该是强制退出游戏，此处暂且不释放界面，直接跳转到登录界面
                    if _flag == -1 then
                        dp.Logout()
                    else
                        if device.platform == "android" then
                            cc.JNIUtils:exitGame()
                        else
                            dp.Logout()
                        end
                    end
                else
                    net.connect(net.ip, net.port, net.openId, net.params)
                end
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    backBtn:addTouchEventListener(btnEvent)
    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(dialog, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end

-- 确定提示框
function utils.showSureDialog(msg, callBackFunc)
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
    dialog:retain()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(450, 300))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getPreferredSize()

    local _fontSize, _fontColor = 25, cc.c3b(255, 255, 255)
    local title = ccui.Text:create()
    title:setString(Lang.utils14)
    title:setFontName(dp.FONT)
    title:setFontSize(30)
    title:setTextColor(cc.c3b(255, 255, 0))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title)
    local msgLabel = ccui.Text:create()
    msgLabel:setString(msg)
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextAreaSize(cc.size(325, 200))
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(_fontSize)
    msgLabel:setTextColor(_fontColor)
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.56))
    bg_image:addChild(msgLabel)
    local sureBtn = ccui.Button:create("ui/tk_btn_red.png", "ui/tk_btn_red.png")
    sureBtn:setTitleText(Lang.utils15)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(35)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(cc.p(bgSize.width * 0.5, bgSize.height * 0.2))
    bg_image:addChild(sureBtn)
    sureBtn:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.uiLayer:removeChild(dialog, true)
            cc.release(dialog)
            if callBackFunc then
                if type(callBackFunc) == "table" then
                    for _k, _func in pairs(callBackFunc) do
                        if _func then _func() end
                    end
                else
                    callBackFunc()
                end
            end
        end
    end )
    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(dialog, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end

--- 确定取消提示框
function utils.showDialog(msg, callBackFunc)
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
    dialog:retain()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(450, 300))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getPreferredSize()

    local _fontSize, _fontColor = 25, cc.c3b(255, 255, 255)
    local title = ccui.Text:create()
    title:setString(Lang.utils16)
    title:setFontName(dp.FONT)
    title:setFontSize(30)
    title:setTextColor(cc.c3b(255, 255, 0))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title)

    local _msgTable = utils.stringSplit(msg, "\n")
    if _msgTable and #_msgTable > 1 then
        local upLabel = ccui.Text:create()
        upLabel:setString(_msgTable[1])
        upLabel:setFontName(dp.FONT)
        upLabel:setFontSize(_fontSize)
        upLabel:setTextColor(_fontColor)
        bg_image:addChild(upLabel)
        local middleLabel = ccui.Text:create()
        middleLabel:setString(_msgTable[2])
        middleLabel:setFontName(dp.FONT)
        middleLabel:setFontSize(_fontSize)
        middleLabel:setTextColor(cc.c3b(255, 255, 0))
        bg_image:addChild(middleLabel)
        local downLabel = ccui.Text:create()
        downLabel:setString(_msgTable[3])
        downLabel:setFontName(dp.FONT)
        downLabel:setFontSize(_fontSize)
        downLabel:setTextColor(_fontColor)
        bg_image:addChild(downLabel)
        middleLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.56))
        upLabel:setPosition(cc.p(bgSize.width / 2, middleLabel:getPositionY() + upLabel:getContentSize().height))
        downLabel:setPosition(cc.p(bgSize.width / 2, middleLabel:getPositionY() - downLabel:getContentSize().height))
    else
        local msgLabel = ccui.Text:create()
        msgLabel:setString(msg)
        msgLabel:setFontName(dp.FONT)
        msgLabel:setTextAreaSize(cc.size(325, 200))
        msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setFontSize(_fontSize)
        msgLabel:setTextColor(_fontColor)
        msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.56))
        bg_image:addChild(msgLabel)
    end

    local sureBtn = ccui.Button:create("ui/tk_btn_red.png", "ui/tk_btn_red.png")
    sureBtn:setTitleText(Lang.utils17)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(35)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(cc.p(bgSize.width * 0.75, bgSize.height * 0.2))
    bg_image:addChild(sureBtn)
    local cancelBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    cancelBtn:setTitleText(Lang.utils18)
    cancelBtn:setTitleFontName(dp.FONT)
    cancelBtn:setTitleColor(cc.c3b(255, 255, 255))
    cancelBtn:setTitleFontSize(35)
    cancelBtn:setPressedActionEnabled(true)
    cancelBtn:setTouchEnabled(true)
    cancelBtn:setPosition(cc.p(bgSize.width * 0.25, bgSize.height * 0.2))
    bg_image:addChild(cancelBtn)
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.uiLayer:removeChild(dialog, true)
            cc.release(dialog)
            if sender == sureBtn and callBackFunc then
                if type(callBackFunc) == "table" then
                    for _k, _func in pairs(callBackFunc) do
                        if _func then _func() end
                    end
                else
                    callBackFunc()
                end
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    cancelBtn:addTouchEventListener(btnEvent)
    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(dialog, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end

--- 确定取消提示框（可以带文字 ，确定回调，取消回调）
function utils.showDialogSureAndCancel(msg, buttonMsg , callBackFunc , cancleCallBackFunc )
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
    dialog:retain()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(450, 300))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getPreferredSize()

    local _fontSize, _fontColor = 25, cc.c3b(255, 255, 255)
    local title = ccui.Text:create()
    title:setString(Lang.utils19)
    title:setFontName(dp.FONT)
    title:setFontSize(30)
    title:setTextColor(cc.c3b(255, 255, 0))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title)

    local _msgTable = utils.stringSplit(msg, "\n")
    if _msgTable and #_msgTable > 1 then
        local upLabel = ccui.Text:create()
        upLabel:setString(_msgTable[1])
        upLabel:setFontName(dp.FONT)
        upLabel:setFontSize(_fontSize)
        upLabel:setTextColor(_fontColor)
        bg_image:addChild(upLabel)
        local middleLabel = ccui.Text:create()
        middleLabel:setString(_msgTable[2])
        middleLabel:setFontName(dp.FONT)
        middleLabel:setFontSize(_fontSize)
        middleLabel:setTextColor(cc.c3b(255, 255, 0))
        bg_image:addChild(middleLabel)
        local downLabel = ccui.Text:create()
        downLabel:setString(_msgTable[3])
        downLabel:setFontName(dp.FONT)
        downLabel:setFontSize(_fontSize)
        downLabel:setTextColor(_fontColor)
        bg_image:addChild(downLabel)
        middleLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.56))
        upLabel:setPosition(cc.p(bgSize.width / 2, middleLabel:getPositionY() + upLabel:getContentSize().height))
        downLabel:setPosition(cc.p(bgSize.width / 2, middleLabel:getPositionY() - downLabel:getContentSize().height))
    else
        local msgLabel = ccui.Text:create()
        msgLabel:setString(msg)
        msgLabel:setFontName(dp.FONT)
        msgLabel:setTextAreaSize(cc.size(325, 200))
        msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setFontSize(_fontSize)
        msgLabel:setTextColor(_fontColor)
        msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.56))
        bg_image:addChild(msgLabel)
    end

    local sureBtn = ccui.Button:create("ui/tk_btn_red.png", "ui/tk_btn_red.png")
    if buttonMsg and buttonMsg.sure then
        sureBtn:setTitleText(buttonMsg.sure)
    else
        sureBtn:setTitleText(Lang.utils20)
    end
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(35)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(cc.p(bgSize.width * 0.75, bgSize.height * 0.2))
    bg_image:addChild(sureBtn)
    local cancelBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    if buttonMsg and buttonMsg.cancel then
        cancelBtn:setTitleText(buttonMsg.cancel)
    else
        cancelBtn:setTitleText(Lang.utils21)
    end
    cancelBtn:setTitleFontName(dp.FONT)
    cancelBtn:setTitleColor(cc.c3b(255, 255, 255))
    cancelBtn:setTitleFontSize(35)
    cancelBtn:setPressedActionEnabled(true)
    cancelBtn:setTouchEnabled(true)
    cancelBtn:setPosition(cc.p(bgSize.width * 0.25, bgSize.height * 0.2))
    bg_image:addChild(cancelBtn)
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.uiLayer:removeChild(dialog, true)
            cc.release(dialog)
            if sender == sureBtn and callBackFunc then
                callBackFunc()
            elseif sender == cancelBtn and cancleCallBackFunc then
                cancleCallBackFunc()
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    cancelBtn:addTouchEventListener(btnEvent)
    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(dialog, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end

function utils.showOpenBoxAnimationUI(_dictBoxDatas)
    local uiLayout = ccui.Layout:create()
    uiLayout:setContentSize(UIManager.screenSize)
    uiLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    uiLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    uiLayout:setBackGroundColorOpacity(180)
    uiLayout:setTouchEnabled(true)
    uiLayout:retain()

    local uiItems = { }
    for key, obj in pairs(_dictBoxDatas) do
        local itemProps = utils.getItemProp(obj.tableTypeId .. "_" .. obj.tableFieldId .. "_" .. obj.value)
        local uiFrame = ccui.ImageView:create()
        uiFrame:loadTexture("ui/quality_small_purple.png")
        if itemProps.frameIcon then
            uiFrame:loadTexture(itemProps.frameIcon)
        end
        if itemProps.smallIcon then
            local uiIcon = ccui.ImageView:create()
            uiIcon:loadTexture(itemProps.smallIcon)
            uiIcon:setPosition(cc.p(uiFrame:getContentSize().width / 2, uiFrame:getContentSize().height / 2))
            uiFrame:addChild(uiIcon)
        end
        if itemProps.name then
            local uiName = ccui.Text:create()
            uiName:setFontName(dp.FONT)
            uiName:setString(itemProps.name)
            uiName:setFontSize(22)
            uiName:setTextColor(cc.c4b(255, 255, 255, 255))
            uiName:setPosition(cc.p(uiFrame:getContentSize().width / 2, - uiName:getContentSize().height))
            uiFrame:addChild(uiName)
        end
        if itemProps.count then
            local uiCount = ccui.Text:create()
            uiCount:setFontName(dp.FONT)
            uiCount:setString("×" .. itemProps.count)
            uiCount:setFontSize(22)
            uiCount:setAnchorPoint(cc.p(1, 0))
            uiCount:setTextColor(cc.c4b(255, 255, 255, 255))
            uiCount:setPosition(cc.p(uiFrame:getContentSize().width, 0))
            uiFrame:addChild(uiCount)
        end
        uiFrame:setLocalZOrder(1)
        uiFrame:setPosition(cc.p(uiLayout:getContentSize().width / 2, uiLayout:getContentSize().height * 0.75))
        uiFrame:setVisible(false)
        uiLayout:addChild(uiFrame)
        uiItems[key] = uiFrame
    end

    local sureBtn = ccui.Button:create("ui/tk_btn_red.png", "ui/tk_btn_red.png")
    sureBtn:setTitleText(Lang.utils22)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(35)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setVisible(false)
    sureBtn:setPosition(cc.p(uiLayout:getContentSize().width / 2, uiLayout:getContentSize().height * 0.18))
    uiLayout:addChild(sureBtn)

    UIManager.uiLayer:addChild(uiLayout, 9999)

    local function palyGetThingAnimation(_thingData, _callFunc)
        local _boxAnim = ActionManager.getEffectAnimation(63, function(armature)
            armature:getAnimation():stop()
            --            armature:removeFromParent()
            --            if _callFunc then
            --                _callFunc()
            --            end
        end , 1)
        _boxAnim:setLocalZOrder(4)
        _boxAnim:setPosition(cc.p(uiLayout:getContentSize().width / 2, uiLayout:getContentSize().height / 2))
        if _thingData.bigIcon then
            _boxAnim:getBone("guge2"):addDisplay(ccs.Skin:create(_thingData.bigIcon), 0)
        elseif _thingData.smallIcon then
            _boxAnim:getBone("guge2"):addDisplay(ccs.Skin:create(_thingData.smallIcon), 0)
        end
        if _thingData.name then
            local _name = ccui.Text:create()
            _name:setFontName(dp.FONT)
            _name:setString(_thingData.name)
            _name:setFontSize(30)
            _name:setTextColor(cc.c4b(255, 255, 255, 255))
            _boxAnim:getBone("guge1"):addDisplay(_name, 0)
        end
        _boxAnim:setName("ui_boxAnim")
        --        uiLayout:addChild(_boxAnim)
        local tempBgLayout = ccui.Layout:create()
        tempBgLayout:setContentSize(UIManager.screenSize)
        tempBgLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        tempBgLayout:setBackGroundColor(cc.c3b(0, 0, 0))
        tempBgLayout:setBackGroundColorOpacity(180)
        tempBgLayout:setTouchEnabled(false)
        tempBgLayout:setLocalZOrder(3)
        tempBgLayout:addChild(_boxAnim)
        tempBgLayout:setName("ui_boxAnim")
        uiLayout:addChild(tempBgLayout)
    end

    local _showIndex, _posIndex = 0, 0
    local _openBoxAnim = ActionManager.getEffectAnimation(63, function(armature)
        --        armature:getAnimation():stop()

    end , 0)
    _openBoxAnim:setScale(0.8)
    _openBoxAnim:setPosition(cc.p(uiLayout:getContentSize().width / 2, uiLayout:getContentSize().height * 0.75))
    uiLayout:addChild(_openBoxAnim)
    local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
        if evt == "open_event" then
            _showIndex = _showIndex + 1
            _posIndex = _posIndex + 1
            local _posX = _posIndex *(uiLayout:getContentSize().width / 5) -(uiLayout:getContentSize().width / 5 / 2)
            if #uiItems == 1 then
                _posX = uiLayout:getContentSize().width / 2
            end
            local _posY = uiLayout:getContentSize().height / 2 + uiItems[_showIndex]:getContentSize().height - 15 - 100
            if _showIndex > 5 then
                _posY = uiLayout:getContentSize().height / 2 - uiItems[_showIndex]:getContentSize().height + 15 - 100
            end
            uiItems[_showIndex]:setScale(0.3)
            uiItems[_showIndex]:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.3, 1), cc.RotateBy:create(0.3, 360), cc.MoveTo:create(0.3, cc.p(_posX, _posY))), cc.CallFunc:create( function()
                local _animCallbackFunc = function()
                    if _showIndex < #uiItems then
                        --                        _openBoxAnim:getAnimation():stop()
                        --                        _openBoxAnim:getAnimation():playWithIndex(0)
                        onFrameEvent(nil, "open_event")
                    else
                        sureBtn:setVisible(true)
                    end
                end
                local obj = _dictBoxDatas[_showIndex]
                --                if utils.random(0, 1) == 1 then
                if obj.description == "1" then
                    palyGetThingAnimation(utils.getItemProp(obj.tableTypeId .. "_" .. obj.tableFieldId .. "_" .. obj.value), _animCallbackFunc)
                else
                    _animCallbackFunc()
                end
            end )))
            uiItems[_showIndex]:setVisible(true)
            if _posIndex > 0 and _posIndex % 5 == 0 then
                _posIndex = 0
            end
        end
    end
    _openBoxAnim:getAnimation():setFrameEventCallFunc(onFrameEvent)

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == sureBtn then
                AudioEngine.playEffect("sound/button.mp3")
                UIManager.uiLayer:removeChild(uiLayout, true)
                cc.release(uiLayout)
            elseif sender == uiLayout then
                if uiLayout:getChildByName("ui_boxAnim") then
                    uiLayout:getChildByName("ui_boxAnim"):removeFromParent()
                    if _showIndex < #uiItems then
                        --                        _openBoxAnim:getAnimation():playWithIndex(0)
                        onFrameEvent(nil, "open_event")
                    else
                        sureBtn:setVisible(true)
                    end
                end
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    uiLayout:addTouchEventListener(btnEvent)
end

--- 副本或者分解等 玩家获取的物品
-- @tableTypeId : 表类型  tableFieldId 表Id  imageType  "big" 大图标 “small” 小图标
function utils.getDropThing(tableTypeId, tableFieldId, imageType)
    local thingName, thingIcon, description = nil, nil
    local dictData = nil
    -- cclog("tableTypeId=".. tableTypeId .. ",tableFieldId=" .. tableFieldId)
    if tonumber(tableTypeId) == StaticTableType.DictPill then
        -- 丹药字典表
        dictData = DictPill[tostring(tableFieldId)]
        thingName = dictData.name
        if imageType == "big" then
            thingIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
        else
            thingIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
        end
        local dictTableType = DictTableType[tostring(dictData.tableTypeId)]
        if dictTableType.id == StaticTableType.DictFightProp then
            local dictFightProp = DictFightProp[tostring(dictData.tableFieldId)]
            description = Lang.utils23 .. dictFightProp.name .. "+" .. dictData.value
        elseif dictTableType.id == StaticTableType.DictCardBaseProp then
            local dictCardBaseProp = DictCardBaseProp[tostring(dictData.tableFieldId)]
            description = Lang.utils24 .. dictCardBaseProp.name .. "+" .. dictData.value
        end
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictThing then
        -- 物品字典表
        dictData = DictThing[tostring(tableFieldId)]
        thingName = dictData.name
        thingIcon = "ui/frame_tianjia.png"
        if imageType == "big" then
            if DictUI[tostring(dictData.bigUiId)] then
                thingIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            end
        else
            if DictUI[tostring(dictData.smallUiId)] then
                thingIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
        end
        if dictData.bagTypeId == 3 then
            local _equipQualityId = DictEquipment[tostring(dictData.equipmentId)].equipQualityId
            local collectNum = DictEquipQuality[tostring(_equipQualityId)].thingNum
            description = Lang.utils25 .. collectNum .. Lang.utils26
        else
            description = dictData.description
        end
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictPlayerBaseProp then
        -- 玩家基本属性字典表
        dictData = DictPlayerBaseProp[tostring(tableFieldId)]
    elseif tonumber(tableTypeId) == StaticTableType.DictCard then
        -- 卡牌字典表
        dictData = DictCard[tostring(tableFieldId)]
    elseif tonumber(tableTypeId) == StaticTableType.DictEquipment then
        -- 装备字典表
        dictData = DictEquipment[tostring(tableFieldId)]
    elseif tonumber(tableTypeId) == StaticTableType.DictChip then
        -- 装备碎片字典表
        dictData = DictChip[tostring(tableFieldId)]
        thingName = dictData.name
        local skillOrKungFuId = dictData.skillOrKungFuId
        local type = dictData.type
        local skillOrKungFuData = nil
        if type == 1 then
            -- 技能
            skillOrKungFuData = DictManualSkill[tostring(skillOrKungFuId)]
        elseif type == 2 or type == 3 then
            -- 功法
            skillOrKungFuData = DictMagic[tostring(skillOrKungFuId)]
        end
        if imageType == "big" then
            thingIcon = "image/" .. DictUI[tostring(skillOrKungFuData.bigUiId)].fileName
        else
            thingIcon = "image/" .. DictUI[tostring(skillOrKungFuData.smallUiId)].fileName
        end
        description = dictData.description
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictCardSoul then
        -- 魂魄字典表
        dictData = DictCardSoul[tostring(tableFieldId)]
        thingName = dictData.name
        local cardId = dictData.cardId
        local dictCardData = DictCard[tostring(cardId)]
        if imageType == "big" then
            thingIcon = "image/" .. DictUI[tostring(dictCardData.bigUiId)].fileName
        else
            thingIcon = "image/" .. DictUI[tostring(dictCardData.smallUiId)].fileName
        end
        local qualityId = DictCard[tostring(cardId)].qualityId
        local soulNum = DictQuality[tostring(qualityId)].soulNum
        description = Lang.utils27 .. soulNum .. Lang.utils28
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictFightSoul then
        dictData = DictFightSoul[tostring(tableFieldId)]
        if dictData then
            thingName = dictData.name
            thingIcon = "ui/fight_soul_quality_blue.png"
            if dictData.fightSoulQualityId == 1 then
                thingIcon = "ui/fight_soul_quality_orange.png"
            elseif dictData.fightSoulQualityId == 2 then
                thingIcon = "ui/fight_soul_quality_purple.png"
            elseif dictData.fightSoulQualityId == 3 then
            elseif dictData.fightSoulQualityId == 4 then
            elseif dictData.fightSoulQualityId == 5 then
            end
            local pro = nil
            for key, value in pairs(DictFightSoulUpgradeProp) do
                if value.fightSoulId == dictData.id and value.level == 1 then
                    pro = value
                    break
                end
            end
            description = ""
            if pro then
                if pro.fightPropValue >= 1 then
                    description = DictFightProp[tostring(pro.fightPropId)].name .. "+" .. pro.fightPropValue
                else
                    description = DictFightProp[tostring(pro.fightPropId)].name .. "+" ..(pro.fightPropValue * 100) .. "%"
                end
            end
        end
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictPillThing then
        -- 丹材字典表
        dictData = DictPillThing[tostring(tableFieldId)]
    elseif tonumber(tableTypeId) == StaticTableType.DictManualSkill then
        dictData = DictManualSkill[tostring(tableFieldId)]
        description = SkillManager[tonumber(tableFieldId)].desc(1)
        thingName = dictData.name
        if imageType == "big" then
            thingIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
        else
            thingIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
        end
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictMagic then
        dictData = DictMagic[tostring(tableFieldId)]
        if dictData.value1 == "3" then
            thingName = dictData.name
            description = string.format("%s+%d%s", Lang.utils29, dictData.exp, "")
            if imageType == "big" then
                thingIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
            else
                thingIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
            return thingName, thingIcon, description
        end
    elseif tonumber(tableTypeId) == StaticTableType.DictYFire then
        dictData = DictYFire[tostring(tableFieldId)]
        if dictData then
            thingName = dictData.name
            description = DictYFireChip[tostring(tableFieldId)].description
            if imageType == "big" then
                thingIcon = "image/fireImage/" .. DictUI[tostring(dictData.bigUiId)].fileName
            else
                thingIcon = "image/fireImage/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
        end
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictYFireChip then
        dictData = DictYFireChip[tostring(tableFieldId)]
        if dictData then
            thingName = dictData.name
            description = dictData.description
            if imageType == "big" then
                thingIcon = "image/fireImage/" .. DictUI[tostring(dictData.bigUiId)].fileName
            else
                thingIcon = "image/fireImage/" .. DictUI[tostring(dictData.smallUiId)].fileName
            end
        end
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictWing then
        dictData = DictWing[tostring(tableFieldId)]
        if dictData then
            thingName = dictData.name
            description = dictData.description
            for key, value in pairs(DictWingAdvance) do
                if value.wingId == dictData.id then
                    if imageType == "big" then
                        thingIcon = "image/" .. DictUI[tostring(value.bigUiId)].fileName
                    else
                        thingIcon = "image/" .. DictUI[tostring(value.smallUiId)].fileName
                    end
                    break
                end
            end
        end
        return thingName, thingIcon, description
    elseif tonumber(tableTypeId) == StaticTableType.DictUnionMaterial then
        -- 装备字典表
        dictData = DictUnionMaterial[tostring(tableFieldId)]
    elseif tonumber(tableTypeId) == StaticTableType.DictUnionSkillNoFightProp then
        dictData = DictUnionSkillNoFightProp[tostring(tableFieldId)]
        thingName = dictData.name
        description = dictData.description
        if tonumber(tableFieldId) == StaticUnionSkillNoFightProp.unionFund then
            if imageType == "big" then
            else
                thingIcon = "image/union_zijin.png"
            end
        end
        return thingName, thingIcon, description
    end
    if not dictData then
        if DictTableType[tostring(tableTypeId)] then
            cclog("出错：tableTypeId = 表" .. DictTableType[tostring(tableTypeId)].sname .. " ,tableFieldId = " .. tableFieldId)
        else
            cclog("出错：tableTypeId 的值有问题，在DictTableType表中不存在！ ----> tableTypeId = " .. tableTypeId)
        end
        return nil
    end
    thingName = dictData.name
    description = dictData.description
    if imageType == "big" then
        thingIcon = "image/" .. DictUI[tostring(dictData.bigUiId)].fileName
    else
        thingIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
    end

    return thingName, thingIcon, description
end

----显示一些简单的提示框  带有关闭  确定和取消
-- @ callBackFunc  点击确定后的回调函数
-- @info   弹框上面的提示信息
----@params   回调函数的参数
-- @[zorder]	z轴序，默认值1000
function utils.PromptDialog(callBackFunc, info, params, zorder)
    zorder = zorder or 10000
    local visibleSize = cc.Director:getInstance():getVisibleSize()

    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:retain()
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 300))
    bg_image:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.utils30)
    title:setFontSize(35)
    title:setFontName(dp.FONT)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title)
    local msgLabel = ccui.Text:create()
    msgLabel:setString(info)
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextAreaSize(cc.size(425, 300))
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(26)
    msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.6))
    bg_image:addChild(msgLabel)

    local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    sureBtn:setTitleText(Lang.utils31)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(25)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(noCloseCancel and bgSize.width / 2 or bgSize.width / 4 * 3, bgSize.height * 0.25)
    bg_image:addChild(sureBtn)

    local cancelBtn = ccui.Button:create("ui/tk_btn_purple.png", "ui/tk_btn_purple.png")
    cancelBtn:setTitleText(Lang.utils32)
    cancelBtn:setTitleFontName(dp.FONT)
    cancelBtn:setTitleColor(cc.c3b(255, 255, 255))
    cancelBtn:setTitleFontSize(25)
    cancelBtn:setPressedActionEnabled(true)
    cancelBtn:setTouchEnabled(true)
    cancelBtn:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.25))
    bg_image:addChild(cancelBtn)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setTouchEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width * 0.5, bgSize.height - closeBtn:getContentSize().height * 0.5))
    bg_image:addChild(closeBtn, 2)

    local childs = UIManager.uiLayer:getChildren()
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == sureBtn then
                if callBackFunc ~= nil then
                    callBackFunc(params)
                end
            end
            UIManager.uiLayer:removeChild(bg_image, true)
            cc.release(bg_image)
            for i = 1, #childs do
                childs[i]:setEnabled(true)
            end
        end
    end

    sureBtn:addTouchEventListener(btnEvent)
    closeBtn:addTouchEventListener(btnEvent)
    cancelBtn:addTouchEventListener(btnEvent)

    UIManager.uiLayer:addChild(bg_image, zorder)
    for i = 1, #childs do
        if childs[i] ~= bg_image then
            childs[i]:setEnabled(false)
        end
    end
end

--- widget 要变灰色的对象
-- flag  true 变灰  false  恢复原色
function utils.GrayWidget(widget, flag)
    local className = tolua.type(widget)
    if className == "ccui.Button" then
        widget:setBright(not flag)
    elseif className == "ccui.ImageView" then
        widget:getVirtualRenderer():setState(flag and 1 or 0)
    end
end

function utils.updateHorzontalScrollView(uiItem, scrollView, listItem, thingData, setScrollViewItem, config)
    config = config or { }
    local space = config.space or 0
    local leftSpace = config.leftSpace or 0
    local rightSpace = config.rightSpace or 0
    local listItemSize = listItem:getContentSize()
    local scrollViewSize = scrollView:getContentSize()
    local innerWidth = leftSpace +(listItemSize.width + space) * #thingData - space + rightSpace
    innerWidth = innerWidth < scrollViewSize.width and scrollViewSize.width or innerWidth
    scrollView:setInnerContainerSize(cc.size(innerWidth, scrollViewSize.height))

    local bufferCount = math.ceil(scrollViewSize.width /(listItemSize.width + space)) + 1
    bufferCount = math.min(#thingData, bufferCount)
    local left = 1
    local right = math.min(left + bufferCount - 1, #thingData)

    local children = scrollView:getChildren()

    while #children > bufferCount do
        children[#children]:removeFromParent()
        children[#children] = nil
    end
    while #children < bufferCount do
        children[#children + 1] = listItem:clone()
        scrollView:addChild(children[#children])
    end

    local function getPositionX(i)
        return leftSpace +(i - 1) *(listItemSize.width + space) + listItemSize.width / 2
    end

    local function scrollingEvent(scrollUpdate)
        if scrollView:getChildrenCount() <= 0 then return end

        local containerX = scrollView:getInnerContainer():getPositionX()

        local showLeft = math.floor((0 - containerX - leftSpace) /(listItemSize.width + space)) + 1
        local showRight = math.floor((scrollViewSize.width - containerX - leftSpace) /(listItemSize.width + space)) + 1

        showLeft = math.max(1, math.min(#thingData, showLeft))
        showRight = math.max(1, math.min(#thingData, showRight))

        scrollUpdate = scrollUpdate or(showRight < left or showLeft > right)

        if scrollUpdate then
            if showLeft + right - left > #thingData then
                left = left - right + showRight
                right = showRight
            else
                right = showLeft + right - left
                left = showLeft
            end

            for tag = left, right do
                local i = math.ceil((tag - 1) % bufferCount) + 1
                local child = children[i]
                if config.setTag then child:setTag(tag) end
                child:setPositionX(getPositionX(tag))
                child:setLocalZOrder(tag)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[tag])
                else
                    setScrollViewItem(child, thingData[tag])
                end
            end
        else
            while showLeft < left do
                left = left - 1
                local child = children[math.ceil((right - 1) % bufferCount) + 1]
                if config.setTag then child:setTag(left) end
                child:setPositionX(getPositionX(left))
                child:setLocalZOrder(left)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[left])
                else
                    setScrollViewItem(child, thingData[left])
                end
                right = right - 1
            end

            while showRight > right do
                right = right + 1
                local child = children[math.ceil((left - 1) % bufferCount) + 1]
                if config.setTag then child:setTag(right) end
                child:setPositionX(getPositionX(right))
                child:setLocalZOrder(right)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[right])
                else
                    setScrollViewItem(child, thingData[right])
                end
                left = left + 1
            end
        end
    end

    scrollView:addEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            scrollingEvent()
        end
    end )

    if uiItem.isFlush then
        uiItem.isFlush = nil
        scrollingEvent(true)
    else
        local jumpTo = config.jumpTo or 1
        local max = innerWidth - scrollViewSize.width
        local thumb =(jumpTo - 1) *(listItemSize.width + space) + leftSpace
        local percent = 100 * math.min(1, math.max(0, thumb / max))
        scrollView:jumpToPercentHorizontal(percent)
        scrollingEvent(true)
    end
end

function utils.updateScrollView(uiItem, scrollView, listItem, thingData, setScrollViewItem, config)
    config = config or { }
    local space = config.space or 0
    local topSpace = config.topSpace or 5
    local bottomSpace = config.bottomSpace or 0
    local listItemSize = listItem:getContentSize()
    local scrollViewSize = scrollView:getContentSize()
    local innerHeight = topSpace +(listItemSize.height + space) * #thingData - space + bottomSpace
    innerHeight = innerHeight < scrollViewSize.height and scrollViewSize.height or innerHeight
    scrollView:setInnerContainerSize(cc.size(scrollViewSize.width, innerHeight))

    local bufferCount = math.ceil(scrollViewSize.height /(listItemSize.height + space)) + 1
    bufferCount = math.min(#thingData, bufferCount)
    local top = 1
    local bottom = math.min(top + bufferCount - 1, #thingData)

    local children = scrollView:getChildren()

    while #children > bufferCount do
        children[#children]:removeFromParent()
        children[#children] = nil
    end
    while #children < bufferCount do
        children[#children + 1] = listItem:clone()
        scrollView:addChild(children[#children])
    end

    local function getPositionY(i)
        return innerHeight - topSpace -(i - 1) *(listItemSize.height + space) - listItemSize.height / 2
    end

    local function scrollingEvent(scrollUpdate)
        if scrollView:getChildrenCount() <= 0 then return end

        local containerY = scrollView:getInnerContainer():getPositionY()

        local showTop = math.floor((containerY + innerHeight - topSpace - scrollViewSize.height) /(listItemSize.height + space)) + 1
        local showBottom = math.floor((containerY + innerHeight - topSpace) /(listItemSize.height + space)) + 1

        showTop = math.max(1, math.min(#thingData, showTop))
        showBottom = math.max(1, math.min(#thingData, showBottom))

        scrollUpdate = scrollUpdate or(showBottom < top or showTop > bottom)

        if scrollUpdate then
            if showTop + bottom - top > #thingData then
                top = top - bottom + showBottom
                bottom = showBottom
            else
                bottom = showTop + bottom - top
                top = showTop
            end

            for tag = top, bottom do
                local i = math.ceil((tag - 1) % bufferCount) + 1
                local child = children[i]
                if config.setTag then child:setTag(tag) end
                child:setPosition(config.noAction and 0 or scrollViewSize.width / 2, getPositionY(tag))
                child:setLocalZOrder(tag)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[tag])
                else
                    setScrollViewItem(child, thingData[tag])
                end
            end
        else
            while showTop < top do
                top = top - 1
                local child = children[math.ceil((bottom - 1) % bufferCount) + 1]
                if config.setTag then child:setTag(top) end
                child:setPosition(config.noAction and 0 or scrollViewSize.width / 2, getPositionY(top))
                child:setLocalZOrder(top)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[top])
                else
                    setScrollViewItem(child, thingData[top])
                end
                bottom = bottom - 1
            end

            while showBottom > bottom do
                bottom = bottom + 1
                local child = children[math.ceil((top - 1) % bufferCount) + 1]
                if config.setTag then child:setTag(bottom) end
                child:setPosition(config.noAction and 0 or scrollViewSize.width / 2, getPositionY(bottom))
                child:setLocalZOrder(bottom)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[bottom])
                else
                    setScrollViewItem(child, thingData[bottom])
                end
                top = top + 1
            end
        end
    end

    scrollView:addEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            scrollingEvent()
        end
    end )

    if uiItem.isFlush then
        uiItem.isFlush = nil
        scrollingEvent(true)
    else
        local jumpTo = config.jumpTo or 1
        local max = innerHeight - scrollViewSize.height
        local thumb =(jumpTo - 1) *(listItemSize.height + space) + topSpace
        local percent = 100 * math.min(1, math.max(0, thumb / max))
        scrollView:jumpToPercentVertical(percent)
        scrollingEvent(true)

        if not UIGuidePeople.guideFlag then
            if not config.noAction then
                ActionManager.ScrollView_SplashAction(scrollView, false, true)
            end
        end
    end

    return scrollingEvent
end

----更新scrollView
--- uiItem      ui界面类型
--- thingData   数据字典表
--- setScrollViewItem   操作item函数
--- flag        ui界面的标识
--- 备用参数
function utils.updateView(uiItem, scrollView, listItem, thingData, setScrollViewItem, flag, param)
    local config = { }

    if uiItem == UIFight then
        config.space = 7
    end

    if uiItem == UIResolve_list then
        if flag == nil then flag = 2 end
    end

    if uiItem == UIResolve_list or uiItem == UIGongfaChoose or UIGemList == uiItem
        or UIBagEquipment == uiItem or UIBagEquipmentSell == uiItem or UICardChange == uiItem then
        config.setTag = true
    end

    config.flag = flag

    if uiItem == UIBag then
        if flag == 2 and #thingData > 3 then
            config.bottomSpace = listItem:getContentSize().height +(config.space or 0)
        end
    end

    local ret = utils.updateScrollView(uiItem, scrollView, listItem, thingData, setScrollViewItem, config)

    if uiItem == UIBag and flag == 2 then
        --- 背包中添加跳转到商城魔核的按钮
        scrollView:addChild(param)
        local function btnItemFunc(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIManager.hideWidget("ui_team_info")
                UIShop.reset(3)
                UIShop.getShopList(2, true)
            end
        end
        param:addTouchEventListener(btnItemFunc)
        param:setTitleColor(cc.c3b(51, 25, 4))
        param:setPressedActionEnabled(true)
        param:setPosition(cc.p(scrollView:getContentSize().width / 2, 40))
    end

    return ret
end

----扩充背包
--- _bagTypeId 背包类型
-- netCallbackFunc  回调函数
function utils.sendExpandData(_bagTypeId, netCallbackFunc)
    local sendData = {
        header = StaticMsgRule.bagExpand,
        msgdata =
        {
            int =
            {
                bagTypeId = _bagTypeId,
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

local function getCardPropFormula(_cardLv)
    if DictCardExp[tostring(_cardLv)] then
        return DictCardExp[tostring(_cardLv)].propFormula
    end
    return 0
end

local function getTitleDamageAdd(_titleDetailId)
    local dictTitleDetailData = DictTitleDetail[tostring(_titleDetailId)]
    if dictTitleDetailData then
        local dictTitleData = DictTitle[tostring(dictTitleDetailData.titleId)]
        if dictTitleData then
            return dictTitleData.linden
        end
    end
    return 0
end
--重新刷字典表
function utils.reloadModelAll()
    reloadModule("DictAdvance")
    reloadModule("DictCard")
    reloadModule("DictCardLuck")
    reloadModule("DictEquipment")
    reloadModule("DictEquipAdvance")
    reloadModule("DictEquipSuit")
    reloadModule("DictMagic")
    reloadModule("DictPill")
    reloadModule("DictQuality")
    reloadModule("DictThing")
    reloadModule("DictTitleDetail")
    reloadModule("DictTitle")
    --    reloadModule("DictBarrierCard")
    --    reloadModule("DictBarrierLevel")
    reloadModule("DictDantaMonster")
    reloadModule("DictEquipAdvance")
    reloadModule("DictFightSoulUpgradeProp")
    reloadModule("DictPagodaCard")
    reloadModule("DictSysConfig")
    reloadModule("CustomDictYFireProp")
    reloadModule("DictWingStrengthen")
    reloadModule("DictWingLuck")
    reloadModule("DictEquipAdvancered")
    reloadModule("DictEquipBox")
end

--- 获取玩家战力值
function utils.getFightValueByTeam( team1 )
    local team = {}
        --得到实力id
    local function getInstPlayerCardId( formationId )
        if tonumber( formationId ) == 0 then
            return nil
        end
        return net.InstPlayerFormation[ tostring( formationId) ].int[ "3" ]
    end
    for key ,value in pairs ( team1  ) do
        team[ key ] = getInstPlayerCardId( tonumber( value ) )
    end
    local fightValue = 0
    if team then
        local isNull = true
        for key, obj in pairs( team ) do
            if obj then
                isNull = false
                local instCardId = obj
                -- 卡牌实例ID
                local attribute, fightSoulValue = utils.getCardAttribute(instCardId, 0 ,team)
                for _fightPropId, _fightPropValue in pairs(attribute) do
                    if utils.FightValueFactor[_fightPropId] then
                        fightValue = fightValue +(_fightPropValue / utils.FightValueFactor[_fightPropId])
                    end
                end
                fightValue = fightValue + fightSoulValue
            end
        end

        --------------联盟修炼技能的战力数据--------------
        if net.InstUnionPractice and not isNull then
            -- 修炼Id_当前等级_当前经验;
            local practice = utils.stringSplit(net.InstUnionPractice.string["3"], ";")
            for key, obj in pairs(practice) do
                local _tempObj = utils.stringSplit(obj, "_")
                local _id = tonumber(_tempObj[1])
                local _level = tonumber(_tempObj[2])
                local _dictUnionPracticeData = DictUnionPractice[tostring(_id)]
                if _dictUnionPracticeData then
                    local _tempData = utils.stringSplit(_dictUnionPracticeData.propEffect, "_")
                    local _tableTypeId = tonumber(_tempData[1])
                    local _fightPropId = tonumber(_tempData[2])
                    if _tableTypeId == StaticTableType.DictFightProp and _fightPropId >= StaticFightProp.cutCrit then
                        for _k, _o in pairs(DictUnionPracticeUpgrade) do
                            if _o.unionPracticeId == _dictUnionPracticeData.id and _o.level == _level then
                                fightValue = fightValue + _o.fightValueAdd
                                break
                            end
                        end
                    end
                    _tempData = nil
                end
                _tempObj = nil
            end
            practice = nil
        end
    end
    return math.floor(fightValue)
end
--- 战斗接口
--- param 界面传来的参数
--- _fightType 战斗类型
function utils.sendFightData(param, _fightType, callBackFunc, cbOfCalcResult)
    if UITalkFly.layer then
        UITalkFly.hide()
    end
    local myFightValue = 0
    if _fightType == dp.FightType.FIGHT_3V3 then
        myFightValue = utils.getFightValueByTeam( utils.stringSplit( param.myTeam , "_" ) )
    else
        myFightValue = utils.getFightValue()
    end
    local Fight_INIT_DATA = {
        allowSpeed3 = false,
        isPVE = true,
        isSelfFirst = true,
        skipEmbattle = false,
        allowSkipFight = false,
        myData =
        {
            -- todo rename renxing
            mainForce = { },
            substitute = { },
            skillCards = { },
            power = myFightValue
        },
        otherData = { },
        record = nil,
    }
    ---------------------------------------------
    ------            敌方
    ------   10         11        12
    ------   7          8         9
    ------            我方
    ------   4          5         6
    ------   1          2         3
    ---------------------------------------------
    if net.InstPlayer.int["4"] >= 30 then
        Fight_INIT_DATA.allowSpeed3 = true
    end
    utils.reloadModelAll()
    ------敌方上阵卡牌-----
    if _fightType == dp.FightType.FIGHT_TASK.ELITE or _fightType == dp.FightType.FIGHT_TASK.COMMON or _fightType == dp.FightType.FIGHT_TASK.ACTIVITY or _fightType == dp.FightType.FIGHT_WING then
        local backGroundWar = DictChapter[tostring(param.chapterId)].backGroundWar
        local backGroundWar_T = utils.stringSplit(backGroundWar, ";")
        if backGroundWar_T[1] and backGroundWar_T[2] then
            Fight_INIT_DATA.bgImagePath0 = "image/backgroundWar/" .. backGroundWar_T[1]
            Fight_INIT_DATA.bgImagePath1 = "image/backgroundWar/" .. backGroundWar_T[2]
        else
            cclog("DictChapter's backGroundWar not found")
        end
        if _fightType == dp.FightType.FIGHT_TASK.COMMON then
            Fight_INIT_DATA.skipEmbattle = true
            if net.InstPlayerBarrier then
                for key, obj in pairs(net.InstPlayerBarrier) do
                    local _chapterId = obj.int["5"]
                    local _barrierId = obj.int["3"]
                    local _barrierLevel = obj.int["6"]
                    local level = DictBarrierLevel[tostring(param.barrierLevelId)].level
                    if _chapterId == tonumber(param.chapterId) and _barrierId == tonumber(param.barrierId) then
                        Fight_INIT_DATA.allowSkipFight = true
                        break
                    end
                end
            end
        else
            local flag = false
            if net.InstPlayerChapter then
                for key, obj in pairs(net.InstPlayerChapter) do
                    local _chapterId = obj.int["3"]
                    if param.chapterId == _chapterId then
                        flag = true
                        break
                    end
                end
            end
            Fight_INIT_DATA.allowSkipFight = flag
        end
        local waveNum = DictBarrierLevel[tostring(param.barrierLevelId)].waveNum
        local fightAdd = DictBarrierLevel[tostring(param.barrierLevelId)].fightAdd
        for _waveNum = 1, waveNum do
            local enemyData = { mainForce = { }, substitute = { }, skillCards = { } }
            for key, obj in pairs(DictBarrierCard) do
                if obj.barrierLevelId == param.barrierLevelId and obj.waveNum == _waveNum then
                    local enemyCardData = { }
                    local sks = { }
                    local position = obj.position
                    local cardId = obj.cardId
                    local cardLevel = obj.cardLevel
                    local dictCardData = DictCard[tostring(cardId)]
                    local qualityId =(obj.qualityId > 0) and obj.qualityId or dictCardData.qualityId
                    local starLevelId =(obj.starLevelId > 0) and obj.starLevelId or dictCardData.starLevelId
                    enemyCardData.name = dictCardData.name
                    enemyCardData.showBanner = true
                    enemyCardData.cardID = dictCardData.id
                    enemyCardData.isBoss = tonumber(obj.isBoss) == 1 and true or false
                    enemyCardData.frameID = qualityId
                    if qualityId >= StaticQuality.purple then
                        enemyCardData.jjCur = DictStarLevel[tostring(starLevelId)].level
                        enemyCardData.jjMax = DictQuality[tostring(qualityId)].maxStarLevel
                    end
                    enemyCardData.hp = fightAdd * formula.getCardBlood(cardLevel, qualityId, starLevelId, dictCardData) * obj.bloodAdd
                    enemyCardData.hit = fightAdd * formula.getCardHit(cardLevel, dictCardData)
                    enemyCardData.dodge = fightAdd * formula.getCardDodge(cardLevel, dictCardData)
                    enemyCardData.crit = formula.getCardCrit(cardLevel, dictCardData)
                    enemyCardData.renxing = formula.getCardTenacity(cardLevel, dictCardData)
                    enemyCardData.attPhsc = formula.getCardGasAttack(cardLevel, qualityId, starLevelId, dictCardData) * obj.wuAttackAdd
                    enemyCardData.attMana = formula.getCardSoulAttack(cardLevel, qualityId, starLevelId, dictCardData) * obj.faAttackAdd
                    enemyCardData.defPhsc = formula.getCardGasDefense(cardLevel, qualityId, starLevelId, dictCardData) * obj.wuDefenseAdd
                    enemyCardData.defMana = formula.getCardSoulDefense(cardLevel, qualityId, starLevelId, dictCardData) * obj.faDefenseAdd
                    enemyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
                    enemyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
                    enemyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
                    enemyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
                    enemyCardData.shuxingzengzhi = getCardPropFormula(cardLevel)
                    enemyCardData.damageIncrease = getTitleDamageAdd(dictCardData.titleDetailId)
                    local skill1 = { }
                    local skill2 = { }
                    local skill3 = { }
                    skill1.lv = 1
                    --- 技能没有等级了 写死了
                    skill2.lv = 1
                    skill3.lv = 1
                    skill1.id = dictCardData.skillOne
                    skill2.id = dictCardData.skillTwo
                    skill3.id = dictCardData.skillThree
                    if dictCardData.id == 88 and qualityId >= StaticQuality.red then
                        skill1.id = 1618
                        skill2.id = 1619
                        skill3.id = 1620
                    end
                    table.insert(sks, skill1)
                    table.insert(sks, skill2)
                    if DictBarrierLevel[tostring(param.barrierLevelId)].level == 4 then
                        table.insert(sks, skill3)
                    end
                    enemyCardData.sks = sks
                    enemyData.mainForce[position] = enemyCardData
                end
            end
            table.insert(Fight_INIT_DATA.otherData, enemyData)
        end
        SDK.doEnterLevel(tostring(param.barrierId))
    elseif _fightType == dp.FightType.FIGHT_CHIP.NPC then
        Fight_INIT_DATA.isPVE = true
        Fight_INIT_DATA.allowSkipFight = true
        local position_table = { 1, 2, 3, 4, 5, 6 }
        local inTeamCardNum = DictLevelProp[tostring(param[2])].inTeamCard
        local benchCardNum = DictLevelProp[tostring(param[2])].benchCard
        --- 替补数
        local enemyData = { mainForce = { }, substitute = { }, skillCards = { } }

        for key, obj in pairs(param[1]) do
            local objData = utils.stringSplit(obj, "_")
            local cardId, qualityId = tonumber(objData[1]), tonumber(objData[2])
            local enemyCardData = { }
            local sks = { }
            local index = math.random(1, #position_table > 0 and #position_table or 1)
            local position = position_table[index]
            table.remove(position_table, index)
            local cardLevel = param[2]
            if UIGuidePeople.guideFlag then
                cardLevel = 1
            end
            local dictCardData = DictCard[tostring(cardId)]
            local starLevelId = dictCardData.starLevelId
            enemyCardData.name = dictCardData.name
            enemyCardData.showBanner = true
            enemyCardData.cardID = dictCardData.id
            enemyCardData.frameID = qualityId
            enemyCardData.hp = formula.getCardBlood(cardLevel, qualityId, starLevelId, dictCardData)
            enemyCardData.hit = formula.getCardHit(cardLevel, dictCardData)
            enemyCardData.dodge = formula.getCardDodge(cardLevel, dictCardData)
            enemyCardData.crit = formula.getCardCrit(cardLevel, dictCardData)
            enemyCardData.renxing = formula.getCardTenacity(cardLevel, dictCardData)
            enemyCardData.attPhsc = formula.getCardGasAttack(cardLevel, qualityId, starLevelId, dictCardData)
            enemyCardData.attMana = formula.getCardSoulAttack(cardLevel, qualityId, starLevelId, dictCardData)
            enemyCardData.defPhsc = formula.getCardGasDefense(cardLevel, qualityId, starLevelId, dictCardData)
            enemyCardData.defMana = formula.getCardSoulDefense(cardLevel, qualityId, starLevelId, dictCardData)
            enemyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
            enemyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
            enemyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
            enemyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
            enemyCardData.shuxingzengzhi = getCardPropFormula(cardLevel)
            enemyCardData.damageIncrease = getTitleDamageAdd(dictCardData.titleDetailId)
            if UIGuidePeople.guideFlag then
                enemyCardData.hp = enemyCardData.hp / 3
                enemyCardData.hit = enemyCardData.hit / 3
                enemyCardData.attPhsc = enemyCardData.attPhsc / 3
                enemyCardData.attMana = enemyCardData.attMana / 3
                enemyCardData.defPhsc = enemyCardData.defPhsc / 3
                enemyCardData.defMana = enemyCardData.defMana / 3
            end
            local skill1 = { }
            local skill2 = { }
            local skill3 = { }
            skill1.lv = 1
            --- 技能没有等级了 写死了
            skill2.lv = 1
            skill3.lv = 1
            skill1.id = dictCardData.skillOne
            skill2.id = dictCardData.skillTwo
            skill3.id = dictCardData.skillThree
            if dictCardData.id == 88 and qualityId >= StaticQuality.red then
                skill1.id = 1618
                skill2.id = 1619
                skill3.id = 1620
            end
            table.insert(sks, skill1)
            table.insert(sks, skill2)
            table.insert(sks, skill3)
            enemyCardData.sks = sks
            if key <= inTeamCardNum then
                enemyData.mainForce[position] = enemyCardData
            elseif key > inTeamCardNum and key <= inTeamCardNum + benchCardNum then
                table.insert(enemyData.substitute, enemyCardData)
            end
        end
        table.insert(Fight_INIT_DATA.otherData, enemyData)
    elseif _fightType == dp.FightType.FIGHT_MINE or _fightType == dp.FightType.FIGHT_CHIP.PC or _fightType == dp.FightType.FIGHT_ARENA or _fightType == dp.FightType.FIGHT_3V3
        or _fightType == dp.FightType.FIGHT_ESCORT or _fightType == dp.FightType.FIGHT_BAG_OPEN_BOX or _fightType == dp.FightType.FIGHT_TOWER_UP
		or _fightType == dp.FightType.FIGHT_OVERLORD_WAR then
        Fight_INIT_DATA.isPVE = false
        Fight_INIT_DATA.allowSkipFight = true
        local pvpTeam = {}
        if _fightType == dp.FightType.FIGHT_ARENA or _fightType == dp.FightType.FIGHT_ESCORT or _fightType == dp.FightType.FIGHT_BAG_OPEN_BOX or _fightType == dp.FightType.FIGHT_OVERLORD_WAR then
            if param ~= nil and _fightType == dp.FightType.FIGHT_ESCORT then
                Fight_INIT_DATA.isSelfFirst = param
            else
                local enemyFightValue = pvp.getFightValue()
                local myFightValue = utils.getFightValue()

                if _fightType == dp.FightType.FIGHT_OVERLORD_WAR then
                    myFightValue = myFightValue * (param.attBuff + 100) / 100
                    enemyFightValue = enemyFightValue * (param.defBuff + 100) / 100
                end

                if enemyFightValue > myFightValue then
                    Fight_INIT_DATA.isSelfFirst = false
                else
                    Fight_INIT_DATA.isSelfFirst = true
                end
            end
        elseif _fightType == dp.FightType.FIGHT_TOWER_UP then
            Fight_INIT_DATA.maxBigRound = 10
        elseif _fightType == dp.FightType.FIGHT_3V3 then
            pvpTeam = utils.stringSplit( param.pvpTeam , "_" )
            local enemyFightValue = pvp.getFightValueByTeam( pvpTeam )
            local myFightValue = utils.getFightValueByTeam( utils.stringSplit( param.myTeam , "_" ) )
            if enemyFightValue > myFightValue then
                Fight_INIT_DATA.isSelfFirst = false
            else
                Fight_INIT_DATA.isSelfFirst = true
            end
        end
        --3v3判断阵容内
        local function inPvpTeam( id )
            if _fightType ~= dp.FightType.FIGHT_3V3 then
                return 0
            end
            for key ,value in pairs( pvpTeam ) do
              --  cclog( "value :" .. value .. "  id : " .. id )
                if tonumber( value ) == tonumber( id ) then
                    return tonumber( key )
                end
            end
            return 0
        end
        local enemyFightValue = 0
        if _fightType == dp.FightType.FIGHT_3V3 then
            enemyFightValue = pvp.getFightValueByTeam( pvpTeam )
        else
            enemyFightValue = pvp.getFightValue()
        end
        local enemyData = { mainForce = { }, substitute = { }, skillCards = { }, power = enemyFightValue }
        local enemyAttr = pvp.getEnchantmentPro()
        for key, obj in pairs(pvp.InstPlayerFormation) do
            local pos = inPvpTeam( tonumber( obj.int["1"] ) )
            if ( _fightType ~= dp.FightType.FIGHT_3V3 and obj.int["4"] == 1 ) or ( _fightType == dp.FightType.FIGHT_3V3 and pos > 0 and pos < 7 )then
                --- 1 上阵的 2 替补的
                local enemyCardData = { }
                local sks = { }
                local position = pos > 0 and pos or obj.int["5"]
                local instCardId = obj.int["3"]
                local instCardData = pvp.InstPlayerCard[tostring(instCardId)]
                local cardId = instCardData.int["3"]
                local isAwake = instCardData.int["18"]
                local dictCardData = DictCard[tostring(cardId)]
                local cardAttribute, cardMagicPercent = pvp.getCardAttribute(instCardId , false , _fightType == dp.FightType.FIGHT_3V3 and pvpTeam or false , nil , enemyAttr )

                ----------------翅膀天赋属性数据--------------
                local wingId = nil
                local wingLv = nil
                local wingEn = false
                local yokeId = nil
                if pvp.InstPlayerWing then
                    for wingKey, wingValue in pairs(pvp.InstPlayerWing) do
                        if wingValue.int["6"] == instCardId then
                            wingId = wingValue.int["3"]
                            wingLv = wingValue.int["5"]
                            for key, value in pairs(DictWingLuck) do
                                if value.cardId == cardId then
                                    local lucks = utils.stringSplit(value.lucks, ";")
                                    local values = utils.stringSplit(value.fightValues, ";")
                                    yokeId = tonumber(lucks[3])
                                    if wingValue.int["3"] == tonumber(lucks[3]) or wingValue.int["3"] >= 5 then
                                        wingEn = true
                                        -- cclog("true")
                                        break
                                    end
                                    break
                                end
                            end
                            break
                        end
                    end
                end
                enemyCardData.wingID = wingId
                enemyCardData.yokeID = yokeId
                enemyCardData.yokeLV = wingLv
                enemyCardData.yokeEnable = wingEn

                enemyCardData.name = (isAwake == 1 and Lang.utils33 or "") .. dictCardData.name
                enemyCardData.showBanner = true
                enemyCardData.cardID = dictCardData.id
                enemyCardData.frameID = instCardData.int["4"]
                if instCardData.int["4"] >= StaticQuality.purple then
                    enemyCardData.jjCur = DictStarLevel[tostring(instCardData.int["5"])].level
                    enemyCardData.jjMax = DictQuality[tostring(instCardData.int["4"])].maxStarLevel
                end
                enemyCardData.hp = cardAttribute[StaticFightProp.blood]
                enemyCardData.hit = cardAttribute[StaticFightProp.hit]
                enemyCardData.dodge = cardAttribute[StaticFightProp.dodge]
                enemyCardData.crit = cardAttribute[StaticFightProp.crit]
                enemyCardData.renxing = cardAttribute[StaticFightProp.flex]
                if cardMagicPercent then
                    enemyCardData.hitRatio = cardMagicPercent[StaticFightProp.hit] and cardMagicPercent[StaticFightProp.hit] or 0
                    enemyCardData.dodgeRatio = cardMagicPercent[StaticFightProp.dodge] and cardMagicPercent[StaticFightProp.dodge] or 0
                    enemyCardData.critRatio = cardMagicPercent[StaticFightProp.crit] and cardMagicPercent[StaticFightProp.crit] or 0
                    enemyCardData.renxingRatio = cardMagicPercent[StaticFightProp.flex] and cardMagicPercent[StaticFightProp.flex] or 0
                end
                enemyCardData.attPhsc = cardAttribute[StaticFightProp.wAttack]
                enemyCardData.attMana = cardAttribute[StaticFightProp.fAttack]
                enemyCardData.defPhsc = cardAttribute[StaticFightProp.wDefense]
                enemyCardData.defMana = cardAttribute[StaticFightProp.fDefense]
                enemyCardData.critRatioDHAdd = cardAttribute[StaticFightProp.addCrit]
                enemyCardData.critRatioDHSub = cardAttribute[StaticFightProp.cutCrit]
                enemyCardData.critPercentAdd = cardAttribute[StaticFightProp.addCritDam]
                enemyCardData.critPercentSub = cardAttribute[StaticFightProp.cutCritDam]
                enemyCardData.bufBurnReduction = cardAttribute[StaticFightProp.cutFireDam]
                enemyCardData.bufPoisonReduction = cardAttribute[StaticFightProp.cutPoisonDam]
                enemyCardData.bufCurseReduction = cardAttribute[StaticFightProp.cutCurseDam]
                enemyCardData.immunityPhscRatio = cardAttribute[StaticFightProp.cutwAttack]
                enemyCardData.immunityManaRatio = cardAttribute[StaticFightProp.cutfAttack]
                enemyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
                enemyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
                enemyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
                enemyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
                enemyCardData.shuxingzengzhi = getCardPropFormula(instCardData.int["9"])
                enemyCardData.damageIncrease = getTitleDamageAdd(instCardData.int["6"])
                if _fightType == dp.FightType.FIGHT_TOWER_UP then
                    enemyCardData.hp = enemyCardData.hp * param.lifeUp
                    enemyCardData.attPhsc = enemyCardData.attPhsc * param.fightUp
                    enemyCardData.attMana = enemyCardData.attMana * param.fightUp
                end
                if UIGuidePeople.guideFlag then
                    enemyCardData.hp = enemyCardData.hp / 3
                    enemyCardData.hit = enemyCardData.hit / 3
                    enemyCardData.attPhsc = enemyCardData.attPhsc / 3
                    enemyCardData.attMana = enemyCardData.attMana / 3
                    enemyCardData.defPhsc = enemyCardData.defPhsc / 3
                    enemyCardData.defMana = enemyCardData.defMana / 3
                end
                local skill1 = { }
                local skill2 = { }
                local skill3 = { }
                skill1.lv = 1
                skill2.lv = 1
                skill3.lv = 1
                if isAwake == 1 then
                    enemyCardData.awoken = true
                    local _tempNewSkillIds = utils.stringSplit(dictCardData.awakeNewSkills, ";")
                    skill1.id = tonumber(_tempNewSkillIds[1])
                    skill2.id = tonumber(_tempNewSkillIds[2])
                    skill3.id = tonumber(_tempNewSkillIds[3])
                    table.insert(sks, { lv = 1, id = dictCardData.awakeSkill })
                else
                    skill1.id = dictCardData.skillOne
                    skill2.id = dictCardData.skillTwo
                    skill3.id = dictCardData.skillThree
                    if dictCardData.id == 88 and instCardData.int["4"] >= StaticQuality.red then
                        skill1.id = 1618
                        skill2.id = 1619
                        skill3.id = 1620
                    end
                end
                table.insert(sks, skill1)
                table.insert(sks, skill2)
                if enemyCardData.frameID >= StaticQuality.purple then
                    table.insert(sks, skill3)
                end
                enemyCardData.sks = sks
                if _fightType ~= dp.FightType.FIGHT_3V3 then
                    local _fireInstData = pvp.getEquipFireInstData(instCardId, true)
                    for _fireKey, _fireObj in pairs(_fireInstData) do
                        if enemyCardData.pyros == nil then
                            enemyCardData.pyros = { }
                        end
                        enemyCardData.pyros[#enemyCardData.pyros + 1] = {
                            id = _fireObj.int["3"],
                            lv = pvp.getEquipFireState(_fireObj.int["1"])
                        }
                    end
                    _fireInstData = nil
                end
                enemyData.mainForce[position] = enemyCardData
            elseif ( _fightType ~= dp.FightType.FIGHT_3V3 and obj.int["4"] == 2 ) or ( _fightType == dp.FightType.FIGHT_3V3 and pos >= 7 ) then
                --- 1 上阵的 2 替补的
                local enemyCardData = { }
                local sks = { }
                local instCardId = obj.int["3"]
                local position = pos >0 and pos or obj.int["5"]
                local instCardData = pvp.InstPlayerCard[tostring(instCardId)]
                local cardId = instCardData.int["3"]
                local isAwake = instCardData.int["18"]
                local dictCardData = DictCard[tostring(cardId)]
                local cardAttribute, cardMagicPercent = pvp.getCardAttribute(instCardId , false , _fightType == dp.FightType.FIGHT_3V3 and pvpTeam or false , nil , enemyAttr )

                ----------------翅膀天赋属性数据--------------
                local wingId = nil
                local wingLv = nil
                local wingEn = false
                local yokeId = nil
                if pvp.InstPlayerWing then
                    for wingKey, wingValue in pairs(pvp.InstPlayerWing) do
                        if wingValue.int["6"] == instCardId then
                            wingId = wingValue.int["3"]
                            wingLv = wingValue.int["5"]
                            for key, value in pairs(DictWingLuck) do
                                if value.cardId == cardId then
                                    local lucks = utils.stringSplit(value.lucks, ";")
                                    local values = utils.stringSplit(value.fightValues, ";")
                                    yokeId = tonumber(lucks[3])
                                    if wingValue.int["3"] == tonumber(lucks[3]) or wingValue.int["3"] >= 5 then
                                        wingEn = true
                                        -- cclog("true")
                                        break
                                    end
                                    break
                                end
                            end
                            break
                        end
                    end
                end
                enemyCardData.wingID = wingId
                enemyCardData.yokeID = yokeId
                enemyCardData.yokeLV = wingLv
                enemyCardData.yokeEnable = wingEn

                enemyCardData._id = position
                enemyCardData.name = (isAwake == 1 and Lang.utils34 or "") .. dictCardData.name
                enemyCardData.showBanner = true
                enemyCardData.cardID = dictCardData.id
                enemyCardData.frameID = instCardData.int["4"]
                if instCardData.int["4"] >= StaticQuality.purple then
                    enemyCardData.jjCur = DictStarLevel[tostring(instCardData.int["5"])].level
                    enemyCardData.jjMax = DictQuality[tostring(instCardData.int["4"])].maxStarLevel
                end
                enemyCardData.hp = cardAttribute[StaticFightProp.blood]
                enemyCardData.hit = cardAttribute[StaticFightProp.hit]
                enemyCardData.dodge = cardAttribute[StaticFightProp.dodge]
                enemyCardData.crit = cardAttribute[StaticFightProp.crit]
                enemyCardData.renxing = cardAttribute[StaticFightProp.flex]
                if cardMagicPercent then
                    enemyCardData.hitRatio = cardMagicPercent[StaticFightProp.hit] and cardMagicPercent[StaticFightProp.hit] or 0
                    enemyCardData.dodgeRatio = cardMagicPercent[StaticFightProp.dodge] and cardMagicPercent[StaticFightProp.dodge] or 0
                    enemyCardData.critRatio = cardMagicPercent[StaticFightProp.crit] and cardMagicPercent[StaticFightProp.crit] or 0
                    enemyCardData.renxingRatio = cardMagicPercent[StaticFightProp.flex] and cardMagicPercent[StaticFightProp.flex] or 0
                end
                enemyCardData.attPhsc = cardAttribute[StaticFightProp.wAttack]
                enemyCardData.attMana = cardAttribute[StaticFightProp.fAttack]
                enemyCardData.defPhsc = cardAttribute[StaticFightProp.wDefense]
                enemyCardData.defMana = cardAttribute[StaticFightProp.fDefense]
                enemyCardData.critRatioDHAdd = cardAttribute[StaticFightProp.addCrit]
                enemyCardData.critRatioDHSub = cardAttribute[StaticFightProp.cutCrit]
                enemyCardData.critPercentAdd = cardAttribute[StaticFightProp.addCritDam]
                enemyCardData.critPercentSub = cardAttribute[StaticFightProp.cutCritDam]
                enemyCardData.bufBurnReduction = cardAttribute[StaticFightProp.cutFireDam]
                enemyCardData.bufPoisonReduction = cardAttribute[StaticFightProp.cutPoisonDam]
                enemyCardData.bufCurseReduction = cardAttribute[StaticFightProp.cutCurseDam]
                enemyCardData.immunityPhscRatio = cardAttribute[StaticFightProp.cutwAttack]
                enemyCardData.immunityManaRatio = cardAttribute[StaticFightProp.cutfAttack]
                enemyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
                enemyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
                enemyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
                enemyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
                enemyCardData.shuxingzengzhi = getCardPropFormula(instCardData.int["9"])
                enemyCardData.damageIncrease = getTitleDamageAdd(instCardData.int["6"])
                if _fightType == dp.FightType.FIGHT_TOWER_UP then
                    enemyCardData.hp = enemyCardData.hp * param.lifeUp
                    enemyCardData.attPhsc = enemyCardData.attPhsc * param.fightUp
                    enemyCardData.attMana = enemyCardData.attMana * param.fightUp
                end
                if UIGuidePeople.guideFlag then
                    enemyCardData.hp = enemyCardData.hp / 3
                    enemyCardData.hit = enemyCardData.hit / 3
                    enemyCardData.attPhsc = enemyCardData.attPhsc / 3
                    enemyCardData.attMana = enemyCardData.attMana / 3
                    enemyCardData.defPhsc = enemyCardData.defPhsc / 3
                    enemyCardData.defMana = enemyCardData.defMana / 3
                end
                local skill1 = { }
                local skill2 = { }
                local skill3 = { }
                skill1.lv = 1
                skill2.lv = 1
                skill3.lv = 1
                if isAwake == 1 then
                    enemyCardData.awoken = true
                    local _tempNewSkillIds = utils.stringSplit(dictCardData.awakeNewSkills, ";")
                    skill1.id = tonumber(_tempNewSkillIds[1])
                    skill2.id = tonumber(_tempNewSkillIds[2])
                    skill3.id = tonumber(_tempNewSkillIds[3])
                    table.insert(sks, { lv = 1, id = dictCardData.awakeSkill })
                else
                    skill1.id = dictCardData.skillOne
                    skill2.id = dictCardData.skillTwo
                    skill3.id = dictCardData.skillThree
                    if dictCardData.id == 88 and instCardData.int["4"] >= StaticQuality.red then
                        skill1.id = 1618
                        skill2.id = 1619
                        skill3.id = 1620
                    end
                end
                table.insert(sks, skill1)
                table.insert(sks, skill2)
                if enemyCardData.frameID >= StaticQuality.purple then
                    table.insert(sks, skill3)
                end
                enemyCardData.sks = sks
                if _fightType ~= dp.FightType.FIGHT_3V3 then
                    local _fireInstData = pvp.getEquipFireInstData(instCardId, true)
                    for _fireKey, _fireObj in pairs(_fireInstData) do
                        if enemyCardData.pyros == nil then
                            enemyCardData.pyros = { }
                        end
                        enemyCardData.pyros[#enemyCardData.pyros + 1] = {
                            id = _fireObj.int["3"],
                            lv = pvp.getEquipFireState(_fireObj.int["1"])
                        }
                    end
                    _fireInstData = nil
                end
                table.insert(enemyData.substitute, enemyCardData)
            end
        end
        utils.quickSort(enemyData.substitute, function(obj1, obj2) if obj1._id > obj2._id then return true end end)
        -- for i = 1,4 do
        -- 	local skill ={}
        -- 	local skillOpenLevel = DictSysConfig[tostring(StaticSysConfig["manualSkillPosition" .. i])].value
        --       	if pvp.InstPlayer.int["4"] >= skillOpenLevel then
        --       		local manualSkillId = 0
        --       		if pvp.InstPlayerManualSkillLine then
        --        		manualSkillId = pvp.InstPlayerManualSkillLine.int[tostring(i+2)]
        --        	end
        --       		if manualSkillId ~= 0 then
        --       			if pvp.InstPlayerManualSkill then
        -- 				skill.id = pvp.InstPlayerManualSkill[tostring(manualSkillId)].int["4"]
        -- 				skill.lv = pvp.InstPlayerManualSkill[tostring(manualSkillId)].int["5"]
        -- 				skill.iconID = DictManualSkill[tostring(skill.id)].smallUiId
        -- 			end
        -- 			table.insert(enemyData.skillCards,skill)
        --       		else
        --       			table.insert(enemyData.skillCards,skill)
        --       		end
        --       	end
        -- end
        table.insert(Fight_INIT_DATA.otherData, enemyData)
    elseif _fightType == dp.FightType.FIGHT_PAGODA then
        Fight_INIT_DATA.isPVE = true
        Fight_INIT_DATA.allowSkipFight = true
        local enemyData = { mainForce = { }, substitute = { }, skillCards = { } }
        for key, obj in pairs(DictPagodaCard) do
            if obj.pagodaStoreyId == param then
                local dictCardData = DictCard[tostring(obj.cardId)]
                local qualityId =(obj.qualityId > 0) and obj.qualityId or dictCardData.qualityId
                local enemyCardData = { }
                local sks = { }
                local position = obj.position
                local cardLevel = obj.cardLevel
                local starLevelId =(obj.starLevelId > 0) and obj.starLevelId or dictCardData.starLevelId
                enemyCardData.name = dictCardData.name
                enemyCardData.showBanner = true
                enemyCardData.cardID = dictCardData.id
                enemyCardData.frameID = qualityId
                if qualityId >= StaticQuality.purple then
                    enemyCardData.jjCur = DictStarLevel[tostring(starLevelId)].level
                    enemyCardData.jjMax = DictQuality[tostring(qualityId)].maxStarLevel
                end
                enemyCardData.hp = formula.getCardBlood(cardLevel, qualityId, starLevelId, dictCardData) * obj.bloodAdd
                enemyCardData.hit = formula.getCardHit(cardLevel, dictCardData)
                enemyCardData.dodge = formula.getCardDodge(cardLevel, dictCardData)
                enemyCardData.crit = formula.getCardCrit(cardLevel, dictCardData)
                enemyCardData.renxing = formula.getCardTenacity(cardLevel, dictCardData)
                enemyCardData.attPhsc = formula.getCardGasAttack(cardLevel, qualityId, starLevelId, dictCardData) * obj.wuAttackAdd
                enemyCardData.attMana = formula.getCardSoulAttack(cardLevel, qualityId, starLevelId, dictCardData) * obj.faAttackAdd
                enemyCardData.defPhsc = formula.getCardGasDefense(cardLevel, qualityId, starLevelId, dictCardData) * obj.wuDefenseAdd
                enemyCardData.defMana = formula.getCardSoulDefense(cardLevel, qualityId, starLevelId, dictCardData) * obj.faDefenseAdd
                enemyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
                enemyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
                enemyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
                enemyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
                enemyCardData.shuxingzengzhi = getCardPropFormula(cardLevel)
                enemyCardData.damageIncrease = getTitleDamageAdd(dictCardData.titleDetailId)
                local skill1 = { }
                local skill2 = { }
                local skill3 = { }
                skill1.lv = 1
                --- 技能没有等级了 写死了
                skill2.lv = 1
                skill3.lv = 1
                skill1.id = dictCardData.skillOne
                skill2.id = dictCardData.skillTwo
                skill3.id = dictCardData.skillThree
                if dictCardData.id == 88 and qualityId >= StaticQuality.red then
                    skill1.id = 1618
                    skill2.id = 1619
                    skill3.id = 1620
                end
                table.insert(sks, skill1)
                table.insert(sks, skill2)
                table.insert(sks, skill3)
                enemyCardData.sks = sks
                enemyData.mainForce[position] = enemyCardData
            end
        end
        table.insert(Fight_INIT_DATA.otherData, enemyData)
    elseif _fightType == dp.FightType.FIGHT_BOSS then
        reloadModule("CustomDictWorldBoss")
        reloadModule("CustomDictAllianceBoss")
--         if net.SysActivity then
--             for key, obj in pairs(net.SysActivity) do
--                 if obj.string["9"] == "Christmas" then
--                     local _startTime = obj.string["4"]
--                     local _endTime = obj.string["5"]
--                    local _currentTime = utils.getCurrentTime()
--                     if _startTime and _endTime and _startTime ~= "" and _endTime ~= "" and utils.GetTimeByDate(_startTime) <= _currentTime and _currentTime <= utils.GetTimeByDate(_endTime) then
--                         for key , value in pairs( CustomDictWorldBoss ) do
--                             CustomDictWorldBoss[key].cardId = 2003
--                         end
--                     end
--                     break
--                 end
--             end
--         end
        Fight_INIT_DATA.isPVE = true
        Fight_INIT_DATA.isBoss = true
        Fight_INIT_DATA.skipEmbattle = true
        Fight_INIT_DATA.allowSkipFight = true
        if param == nil then
            return UIManager.showToast(Lang.utils35)
        end
        local dictCardData = DictCard[tostring(param.cardId)]
        local qualityId =(param.qualityId > 0) and param.qualityId or dictCardData.qualityId
        local starLevelId =(param.starLevelId > 0) and param.starLevelId or dictCardData.starLevelId
        local _bossSks = { }
        local sksIds = utils.stringSplit(param.sksIds, ";")
        for key, _sksId in pairs(sksIds) do
            _bossSks[#_bossSks + 1] = {
                id = tonumber(_sksId),
                lv = 1
            }
        end
        Fight_INIT_DATA.otherData = {
            {
                mainForce =
                {
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    {
                        name = dictCardData.name,
                        isBoss = false,
                        showBanner = true,
                        cardID = dictCardData.id,
                        frameID = qualityId,
                        jjCur = DictStarLevel[tostring(starLevelId)].level,
                        jjMax = DictQuality[tostring(qualityId)].maxStarLevel,
                        hp = 10000000000000,
                        hit = 100000000,
                        dodge = param.dodge,
                        crit = param.crit,
                        renxing = 50,
                        attPhsc = param.attPhsc,
                        attMana = param.attMana,
                        defPhsc = param.defPhsc,
                        defMana = param.defMana,
                        attPhscRatio = 1,
                        attManaRatio = 1,
                        defPhscRatio = 1,
                        defManaRatio = 1,
                        shuxingzengzhi = 10,
                        damageIncrease = 0,
                        sks = _bossSks
                    },
                }
            }
        }
    elseif _fightType == dp.FightType.FIGHT_TRY_PRACTICE then
        Fight_INIT_DATA.isPVE = false
        Fight_INIT_DATA.allowSkipFight = false
        local enemyData = { mainForce = { }, substitute = { }, skillCards = { } }
        local fightIds = utils.stringSplit(param.fightId, ";")
        for key, dttpbcId in pairs(fightIds) do
            local obj = DictTryToPracticeBarrierCard[tostring(dttpbcId)]
            if obj then
                local dictCardData = DictCard[tostring(obj.cardId)]
                local qualityId =(obj.qualityId > 0) and obj.qualityId or dictCardData.qualityId
                local enemyCardData = { }
                local sks = { }
                local position = obj.position
                local cardLevel = obj.cardLevel
                local starLevelId =(obj.starLevelId > 0) and obj.starLevelId or dictCardData.starLevelId
                enemyCardData.name = dictCardData.name
                enemyCardData.showBanner = true
                enemyCardData.cardID = dictCardData.id
                enemyCardData.frameID = qualityId
                if qualityId >= StaticQuality.purple then
                    enemyCardData.jjCur = DictStarLevel[tostring(starLevelId)].level
                    enemyCardData.jjMax = DictQuality[tostring(qualityId)].maxStarLevel
                end
                enemyCardData.hp = formula.getCardBlood(cardLevel, qualityId, starLevelId, dictCardData) * obj.bloodAdd
                enemyCardData.hit = formula.getCardHit(cardLevel, dictCardData)
                enemyCardData.dodge = formula.getCardDodge(cardLevel, dictCardData)
                enemyCardData.crit = formula.getCardCrit(cardLevel, dictCardData)
                enemyCardData.renxing = formula.getCardTenacity(cardLevel, dictCardData)
                enemyCardData.attPhsc = formula.getCardGasAttack(cardLevel, qualityId, starLevelId, dictCardData) * obj.wuAttackAdd
                enemyCardData.attMana = formula.getCardSoulAttack(cardLevel, qualityId, starLevelId, dictCardData) * obj.faAttackAdd
                enemyCardData.defPhsc = formula.getCardGasDefense(cardLevel, qualityId, starLevelId, dictCardData) * obj.wuDefenseAdd
                enemyCardData.defMana = formula.getCardSoulDefense(cardLevel, qualityId, starLevelId, dictCardData) * obj.faDefenseAdd
                enemyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
                enemyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
                enemyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
                enemyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
                enemyCardData.shuxingzengzhi = getCardPropFormula(cardLevel)
                enemyCardData.damageIncrease = getTitleDamageAdd(dictCardData.titleDetailId)
                local skill1 = { }
                local skill2 = { }
                local skill3 = { }
                skill1.lv = 1
                --- 技能没有等级了 写死了
                skill2.lv = 1
                skill3.lv = 1
                skill1.id = dictCardData.skillOne
                skill2.id = dictCardData.skillTwo
                skill3.id = dictCardData.skillThree
                if dictCardData.id == 88 and qualityId >= StaticQuality.red then
                    skill1.id = 1618
                    skill2.id = 1619
                    skill3.id = 1620
                end
                table.insert(sks, skill1)
                table.insert(sks, skill2)
                table.insert(sks, skill3)
                enemyCardData.sks = sks
                enemyData.mainForce[position] = enemyCardData
            end
        end
        table.insert(Fight_INIT_DATA.otherData, enemyData)
    elseif _fightType == dp.FightType.FIGHT_PILL_TOWER then
        -- 丹塔战斗敌方数据
        Fight_INIT_DATA.isPVE = false
        Fight_INIT_DATA.isSelfFirst = param.isSelfFirst
        Fight_INIT_DATA.allowSkipFight = true
        local enemyData = { mainForce = { }, substitute = { }, skillCards = { } }
        local monsterIds = utils.stringSplit(param.dntaMonsterIds, ",")
        for key, monsterId in pairs(monsterIds) do
            local obj = DictDantaMonster[tostring(monsterId)]
            if obj then
                local dictCardData = DictCard[tostring(obj.cardId)]
                local qualityId =(obj.qualityId > 0) and obj.qualityId or dictCardData.qualityId
                local enemyCardData = { }
                local sks = { }
                local position = obj.position
                local cardLevel = obj.cardLevel
                local starLevelId =(obj.starLevelId > 0) and obj.starLevelId or dictCardData.starLevelId
                enemyCardData.isBoss =(obj.isBoss == 1) and true or false
                enemyCardData.name = dictCardData.name
                enemyCardData.showBanner = true
                enemyCardData.cardID = dictCardData.id
                enemyCardData.frameID = qualityId
                if qualityId >= StaticQuality.purple then
                    enemyCardData.jjCur = DictStarLevel[tostring(starLevelId)].level
                    enemyCardData.jjMax = DictQuality[tostring(qualityId)].maxStarLevel
                end
                enemyCardData.hp = math.floor(formula.getCardBlood(cardLevel, qualityId, starLevelId, dictCardData) * obj.bloodAdd)
                enemyCardData.hit = formula.getCardHit(cardLevel, dictCardData)
                enemyCardData.dodge = formula.getCardDodge(cardLevel, dictCardData)
                enemyCardData.crit = formula.getCardCrit(cardLevel, dictCardData)
                enemyCardData.renxing = formula.getCardTenacity(cardLevel, dictCardData)
                enemyCardData.attPhsc = formula.getCardGasAttack(cardLevel, qualityId, starLevelId, dictCardData) * obj.wuAttackAdd
                enemyCardData.attMana = formula.getCardSoulAttack(cardLevel, qualityId, starLevelId, dictCardData) * obj.faAttackAdd
                enemyCardData.defPhsc = formula.getCardGasDefense(cardLevel, qualityId, starLevelId, dictCardData) * obj.wuDefenseAdd
                enemyCardData.defMana = formula.getCardSoulDefense(cardLevel, qualityId, starLevelId, dictCardData) * obj.faDefenseAdd
                enemyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
                enemyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
                enemyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
                enemyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
                enemyCardData.shuxingzengzhi = getCardPropFormula(cardLevel)
                enemyCardData.damageIncrease = getTitleDamageAdd(dictCardData.titleDetailId)
                local skill1 = { }
                local skill2 = { }
                local skill3 = { }
                skill1.lv = 1
                --- 技能没有等级了 写死了
                skill2.lv = 1
                skill3.lv = 1
                skill1.id = dictCardData.skillOne
                skill2.id = dictCardData.skillTwo
                skill3.id = dictCardData.skillThree
                if dictCardData.id == 88 and qualityId >= StaticQuality.red then
                    skill1.id = 1618
                    skill2.id = 1619
                    skill3.id = 1620
                end
                table.insert(sks, skill1)
                table.insert(sks, skill2)
                table.insert(sks, skill3)
                enemyCardData.sks = sks

                local fireIds = utils.stringSplit(obj.fireIds, ";")
                for _fireIdKey, _fireIdObj in pairs(fireIds) do
                    if dp.FireEquipGrid[_fireIdKey] == nil then
                        break
                    end
                    local _gridState = 0
                    -- 0:无效,1:有效
                    if qualityId >= dp.FireEquipGrid[_fireIdKey].qualityId then
                        if qualityId == dp.FireEquipGrid[_fireIdKey].qualityId then
                            if starLevelId >= dp.FireEquipGrid[_fireIdKey].starLevelId then
                                _gridState = 1
                            end
                        else
                            _gridState = 1
                        end
                    end
                    if _gridState == 1 then
                        if enemyCardData.pyros == nil then
                            enemyCardData.pyros = { }
                        end
                        enemyCardData.pyros[#enemyCardData.pyros + 1] = {
                            id = tonumber(_fireIdObj),
                            lv = 2
                        }
                    end
                end
                fireIds = nil

                if position > 6 then
                    -- 替补
                    enemyCardData._id = position
                    table.insert(enemyData.substitute, enemyCardData)
                else
                    -- 首发
                    enemyData.mainForce[position] = enemyCardData
                end
            end
        end
        table.insert(Fight_INIT_DATA.otherData, enemyData)
    end
    if _fightType == dp.FightType.FIGHT_PILL_TOWER then
        -- 丹塔战斗我方数据
        for key, obj in pairs(param.myCardData) do
            local myCardData, sks = { }, { }
            local position = obj.position
            local instCardData = net.InstPlayerCard[tostring(obj.instCardId)]
            local dictCardData = DictCard[tostring(instCardData.int["3"])]
            local cardAttribute = utils.getCardAttribute(obj.instCardId)
            local isAwake = instCardData.int["18"]

            ----------------翅膀天赋属性数据--------------
            local wingId = nil
            local wingLv = nil
            local wingEn = false
            local yokeId = nil
            if net.InstPlayerWing then
                for wingKey, wingValue in pairs(net.InstPlayerWing) do
                    if wingValue.int["6"] == obj.instCardId then
                        wingId = wingValue.int["3"]
                        wingLv = wingValue.int["5"]
                        for key, value in pairs(DictWingLuck) do
                            if value.cardId == dictCardData.id then
                                local lucks = utils.stringSplit(value.lucks, ";")
                                local values = utils.stringSplit(value.fightValues, ";")
                                yokeId = tonumber(lucks[3])
                                if wingValue.int["3"] == tonumber(lucks[3]) or wingValue.int["3"] >= 5 then
                                    wingEn = true
                                    -- cclog("true")
                                    break
                                end
                                break
                            end
                        end
                        break
                    end
                end
            end
            myCardData.wingID = wingId
            myCardData.yokeID = yokeId
            myCardData.yokeLV = wingLv
            myCardData.yokeEnable = wingEn

            myCardData.name = (isAwake == 1 and Lang.utils36 or "") .. dictCardData.name
            myCardData.showBanner = true
            myCardData.cardID = dictCardData.id
            myCardData.frameID = instCardData.int["4"]
            if instCardData.int["4"] >= StaticQuality.purple then
                myCardData.jjCur = DictStarLevel[tostring(instCardData.int["5"])].level
                myCardData.jjMax = DictQuality[tostring(instCardData.int["4"])].maxStarLevel
            end
            myCardData.hp = math.floor(cardAttribute[StaticFightProp.blood])
            myCardData.hpCur =(obj.hpCur > myCardData.hp) and myCardData.hp or obj.hpCur
            myCardData.hit = cardAttribute[StaticFightProp.hit]
            myCardData.dodge = cardAttribute[StaticFightProp.dodge]
            myCardData.crit = cardAttribute[StaticFightProp.crit]
            myCardData.renxing = cardAttribute[StaticFightProp.flex]
            if magicPercent then
                myCardData.hitRatio = magicPercent[StaticFightProp.hit] and magicPercent[StaticFightProp.hit] or 0
                myCardData.dodgeRatio = magicPercent[StaticFightProp.dodge] and magicPercent[StaticFightProp.dodge] or 0
                myCardData.critRatio = magicPercent[StaticFightProp.crit] and magicPercent[StaticFightProp.crit] or 0
                myCardData.renxingRatio = magicPercent[StaticFightProp.flex] and magicPercent[StaticFightProp.flex] or 0
            end
            myCardData.attPhsc = cardAttribute[StaticFightProp.wAttack]
            myCardData.attMana = cardAttribute[StaticFightProp.fAttack]
            myCardData.defPhsc = cardAttribute[StaticFightProp.wDefense]
            myCardData.defMana = cardAttribute[StaticFightProp.fDefense]
            myCardData.critRatioDHAdd = cardAttribute[StaticFightProp.addCrit]
            myCardData.critRatioDHSub = cardAttribute[StaticFightProp.cutCrit]
            myCardData.critPercentAdd = cardAttribute[StaticFightProp.addCritDam]
            myCardData.critPercentSub = cardAttribute[StaticFightProp.cutCritDam]
            myCardData.bufBurnReduction = cardAttribute[StaticFightProp.cutFireDam]
            myCardData.bufPoisonReduction = cardAttribute[StaticFightProp.cutPoisonDam]
            myCardData.bufCurseReduction = cardAttribute[StaticFightProp.cutCurseDam]
            myCardData.immunityPhscRatio = cardAttribute[StaticFightProp.cutwAttack]
            myCardData.immunityManaRatio = cardAttribute[StaticFightProp.cutfAttack]
            myCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
            myCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
            myCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
            myCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
            myCardData.shuxingzengzhi = getCardPropFormula(instCardData.int["9"])
            myCardData.damageIncrease = getTitleDamageAdd(instCardData.int["6"])
            local skill1 = { }
            local skill2 = { }
            local skill3 = { }
            skill1.lv = 1
            skill2.lv = 1
            skill3.lv = 1
            if isAwake == 1 then
                myCardData.awoken = true
                local _tempNewSkillIds = utils.stringSplit(dictCardData.awakeNewSkills, ";")
                skill1.id = tonumber(_tempNewSkillIds[1])
                skill2.id = tonumber(_tempNewSkillIds[2])
                skill3.id = tonumber(_tempNewSkillIds[3])
                table.insert(sks, { lv = 1, id = dictCardData.awakeSkill })
            else
                skill1.id = dictCardData.skillOne
                skill2.id = dictCardData.skillTwo
                skill3.id = dictCardData.skillThree
                if dictCardData.id == 88 and instCardData.int["4"] >= StaticQuality.red then
                    skill1.id = 1618
                    skill2.id = 1619
                    skill3.id = 1620
                end
            end
            table.insert(sks, skill1)
            table.insert(sks, skill2)
            if myCardData.frameID >= StaticQuality.purple then
                table.insert(sks, skill3)
            end
            myCardData.sks = sks
            local _fireInstData = utils.getEquipFireInstData(obj.instCardId, true)
            for _fireKey, _fireObj in pairs(_fireInstData) do
                if myCardData.pyros == nil then
                    myCardData.pyros = { }
                end
                myCardData.pyros[#myCardData.pyros + 1] = {
                    id = _fireObj.int["3"],
                    lv = utils.getEquipFireState(_fireObj.int["1"])
                }
            end
            _fireInstData = nil
            if position > 6 then
                -- 替补
                myCardData._id = position
                table.insert(Fight_INIT_DATA.myData.substitute, myCardData)
            else
                -- 首发
                Fight_INIT_DATA.myData.mainForce[position] = myCardData
            end
        end
    else
        local myTeam = {}
        if _fightType == dp.FightType.FIGHT_3V3 then
            myTeam = utils.stringSplit( param.myTeam , "_" )
        end
        --3v3判断阵容内
        local function inMyTeam( id )
            if _fightType ~= dp.FightType.FIGHT_3V3 then
                return 0
            end
            for key ,value in pairs( myTeam ) do
                if tonumber( value ) == tonumber( id ) then
                    return tonumber( key )
                end
            end
            return 0
        end
        -----我方上阵卡牌-----
        local myAttr = utils.getEnchantmentPro()
        for key, obj in pairs(net.InstPlayerFormation) do
            local pos = inMyTeam( tonumber( obj.int["1"] ) )
            if ( _fightType ~= dp.FightType.FIGHT_3V3 and obj.int["4"] == 1 ) or ( _fightType == dp.FightType.FIGHT_3V3 and pos > 0 and pos < 7 ) then
                --- 1 上阵的 2 替补的
                local MyCardData = { }
                local sks = { }
                local position = pos > 0 and pos or obj.int["5"]
                local instCardId = obj.int["3"]
                local instCardData = net.InstPlayerCard[tostring(instCardId)]
                local cardId = instCardData.int["3"]
                local isAwake = instCardData.int["18"]
                local dictCardData = DictCard[tostring(cardId)]
                local cardAttribute = utils.getCardAttribute(instCardId  , false , _fightType == dp.FightType.FIGHT_3V3 and myTeam or false , nil , myAttr )

                ----------------翅膀天赋属性数据--------------
                local wingId = nil
                local wingLv = nil
                local wingEn = false
                local yokeId = nil
                if net.InstPlayerWing then
                    for wingKey, wingValue in pairs(net.InstPlayerWing) do
                        if wingValue.int["6"] == instCardId then
                            wingId = wingValue.int["3"]
                            wingLv = wingValue.int["5"]
                            for key, value in pairs(DictWingLuck) do
                                if value.cardId == cardId then
                                    local lucks = utils.stringSplit(value.lucks, ";")
                                    local values = utils.stringSplit(value.fightValues, ";")
                                    yokeId = tonumber(lucks[3])
                                    if wingValue.int["3"] == tonumber(lucks[3]) or wingValue.int["3"] >= 5 then
                                        wingEn = true
                                        -- cclog("true")
                                        break
                                    end
                                    break
                                end
                            end
                            break
                        end
                    end
                end
                MyCardData.wingID = wingId
                MyCardData.yokeID = yokeId
                MyCardData.yokeLV = wingLv
                MyCardData.yokeEnable = wingEn

                MyCardData.name = (isAwake == 1 and Lang.utils37 or "") .. dictCardData.name
                MyCardData.showBanner = true
                MyCardData.cardID = dictCardData.id
                MyCardData.frameID = instCardData.int["4"]
                if instCardData.int["4"] >= StaticQuality.purple then
                    MyCardData.jjCur = DictStarLevel[tostring(instCardData.int["5"])].level
                    MyCardData.jjMax = DictQuality[tostring(instCardData.int["4"])].maxStarLevel
                end
                MyCardData.hp = cardAttribute[StaticFightProp.blood]
                MyCardData.hit = cardAttribute[StaticFightProp.hit]
                if _fightType ~= dp.FightType.FIGHT_BOSS then
                    MyCardData.dodge = cardAttribute[StaticFightProp.dodge]
                else
                    MyCardData.dodge = 0
                end
                MyCardData.crit = cardAttribute[StaticFightProp.crit]
                MyCardData.renxing = cardAttribute[StaticFightProp.flex]
                if magicPercent then
                    MyCardData.hitRatio = magicPercent[StaticFightProp.hit] and magicPercent[StaticFightProp.hit] or 0
                    MyCardData.dodgeRatio = magicPercent[StaticFightProp.dodge] and magicPercent[StaticFightProp.dodge] or 0
                    MyCardData.critRatio = magicPercent[StaticFightProp.crit] and magicPercent[StaticFightProp.crit] or 0
                    MyCardData.renxingRatio = magicPercent[StaticFightProp.flex] and magicPercent[StaticFightProp.flex] or 0
                end
                MyCardData.attPhsc = cardAttribute[StaticFightProp.wAttack]
                MyCardData.attMana = cardAttribute[StaticFightProp.fAttack]
                MyCardData.defPhsc = cardAttribute[StaticFightProp.wDefense]
                MyCardData.defMana = cardAttribute[StaticFightProp.fDefense]
                MyCardData.critRatioDHAdd = cardAttribute[StaticFightProp.addCrit]
                MyCardData.critRatioDHSub = cardAttribute[StaticFightProp.cutCrit]
                MyCardData.critPercentAdd = cardAttribute[StaticFightProp.addCritDam]
                MyCardData.critPercentSub = cardAttribute[StaticFightProp.cutCritDam]
                MyCardData.bufBurnReduction = cardAttribute[StaticFightProp.cutFireDam]
                MyCardData.bufPoisonReduction = cardAttribute[StaticFightProp.cutPoisonDam]
                MyCardData.bufCurseReduction = cardAttribute[StaticFightProp.cutCurseDam]
                MyCardData.immunityPhscRatio = cardAttribute[StaticFightProp.cutwAttack]
                MyCardData.immunityManaRatio = cardAttribute[StaticFightProp.cutfAttack]
                MyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
                MyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
                MyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
                MyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
                MyCardData.shuxingzengzhi = getCardPropFormula(instCardData.int["9"])
                MyCardData.damageIncrease = getTitleDamageAdd(instCardData.int["6"])
                local skill1 = { }
                local skill2 = { }
                local skill3 = { }
                skill1.lv = 1
                skill2.lv = 1
                skill3.lv = 1
                if isAwake == 1 then
                    MyCardData.awoken = true
                    local _tempNewSkillIds = utils.stringSplit(dictCardData.awakeNewSkills, ";")
                    skill1.id = tonumber(_tempNewSkillIds[1])
                    skill2.id = tonumber(_tempNewSkillIds[2])
                    skill3.id = tonumber(_tempNewSkillIds[3])
                    table.insert(sks, { lv = 1, id = dictCardData.awakeSkill })
                else
                    skill1.id = dictCardData.skillOne
                    skill2.id = dictCardData.skillTwo
                    skill3.id = dictCardData.skillThree
                    if dictCardData.id == 88 and instCardData.int["4"] >= StaticQuality.red then
                        skill1.id = 1618
                        skill2.id = 1619
                        skill3.id = 1620
                    end
                end
                table.insert(sks, skill1)
                table.insert(sks, skill2)
                if MyCardData.frameID >= StaticQuality.purple then
                    table.insert(sks, skill3)
                end
                MyCardData.sks = sks
                if _fightType ~= dp.FightType.FIGHT_3V3 then
                    local _fireInstData = utils.getEquipFireInstData(instCardId, true)
                    for _fireKey, _fireObj in pairs(_fireInstData) do
                        if MyCardData.pyros == nil then
                            MyCardData.pyros = { }
                        end
                        MyCardData.pyros[#MyCardData.pyros + 1] = {
                            id = _fireObj.int["3"],
                            lv = utils.getEquipFireState(_fireObj.int["1"])
                        }
                    end
                    _fireInstData = nil
                end
                Fight_INIT_DATA.myData.mainForce[position] = MyCardData
            elseif ( _fightType ~= dp.FightType.FIGHT_3V3 and obj.int["4"] == 2 ) or ( _fightType == dp.FightType.FIGHT_3V3 and pos >= 7 ) then
                --- 1 上阵的 2 替补的
                local MyCardData = { }
                local sks = { }
                local instCardId = obj.int["3"]
                local position = pos > 0 and pos or obj.int["5"]
                local instCardData = net.InstPlayerCard[tostring(instCardId)]
                local cardId = instCardData.int["3"]
                local isAwake = instCardData.int["18"]
                local dictCardData = DictCard[tostring(cardId)]
                local cardAttribute = utils.getCardAttribute(instCardId , false , _fightType == dp.FightType.FIGHT_3V3 and myTeam or false , nil , myAttr )
                ----------------翅膀天赋属性数据--------------
                local wingId = nil
                local wingLv = nil
                local wingEn = false
                local yokeId = nil
                if net.InstPlayerWing then
                    for wingKey, wingValue in pairs(net.InstPlayerWing) do
                        if wingValue.int["6"] == instCardId then
                            wingId = wingValue.int["3"]
                            wingLv = wingValue.int["5"]
                            for key, value in pairs(DictWingLuck) do
                                if value.cardId == cardId then
                                    local lucks = utils.stringSplit(value.lucks, ";")
                                    local values = utils.stringSplit(value.fightValues, ";")
                                    yokeId = tonumber(lucks[3])
                                    if wingValue.int["3"] == tonumber(lucks[3]) or wingValue.int["3"] >= 5 then
                                        wingEn = true
                                        -- cclog("true")
                                        break
                                    end
                                    break
                                end
                            end
                            break
                        end
                    end
                end
                MyCardData.wingID = wingId
                MyCardData.yokeID = yokeId
                MyCardData.yokeLV = wingLv
                MyCardData.yokeEnable = wingEn

                MyCardData._id = position
                MyCardData.name = (isAwake == 1 and Lang.utils38 or "") .. dictCardData.name
                MyCardData.showBanner = true
                MyCardData.cardID = dictCardData.id
                MyCardData.frameID = instCardData.int["4"]
                if instCardData.int["4"] >= StaticQuality.purple then
                    MyCardData.jjCur = DictStarLevel[tostring(instCardData.int["5"])].level
                    MyCardData.jjMax = DictQuality[tostring(instCardData.int["4"])].maxStarLevel
                end
                MyCardData.hp = cardAttribute[StaticFightProp.blood]
                MyCardData.hit = cardAttribute[StaticFightProp.hit]
                MyCardData.dodge = cardAttribute[StaticFightProp.dodge]
                MyCardData.crit = cardAttribute[StaticFightProp.crit]
                MyCardData.renxing = cardAttribute[StaticFightProp.flex]
                if magicPercent then
                    MyCardData.hitRatio = magicPercent[StaticFightProp.hit] and magicPercent[StaticFightProp.hit] or 0
                    MyCardData.dodgeRatio = magicPercent[StaticFightProp.dodge] and magicPercent[StaticFightProp.dodge] or 0
                    MyCardData.critRatio = magicPercent[StaticFightProp.crit] and magicPercent[StaticFightProp.crit] or 0
                    MyCardData.renxingRatio = magicPercent[StaticFightProp.flex] and magicPercent[StaticFightProp.flex] or 0
                end
                MyCardData.attPhsc = cardAttribute[StaticFightProp.wAttack]
                MyCardData.attMana = cardAttribute[StaticFightProp.fAttack]
                MyCardData.defPhsc = cardAttribute[StaticFightProp.wDefense]
                MyCardData.defMana = cardAttribute[StaticFightProp.fDefense]
                MyCardData.critRatioDHAdd = cardAttribute[StaticFightProp.addCrit]
                MyCardData.critRatioDHSub = cardAttribute[StaticFightProp.cutCrit]
                MyCardData.critPercentAdd = cardAttribute[StaticFightProp.addCritDam]
                MyCardData.critPercentSub = cardAttribute[StaticFightProp.cutCritDam]
                MyCardData.bufBurnReduction = cardAttribute[StaticFightProp.cutFireDam]
                MyCardData.bufPoisonReduction = cardAttribute[StaticFightProp.cutPoisonDam]
                MyCardData.bufCurseReduction = cardAttribute[StaticFightProp.cutCurseDam]
                MyCardData.immunityPhscRatio = cardAttribute[StaticFightProp.cutwAttack]
                MyCardData.immunityManaRatio = cardAttribute[StaticFightProp.cutfAttack]
                MyCardData.defPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wDefensePer
                MyCardData.defManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fDefensePer
                MyCardData.attPhscRatio = DictCoefficient[tostring(dictCardData.coefficientId)].wAttackPer
                MyCardData.attManaRatio = DictCoefficient[tostring(dictCardData.coefficientId)].fAttackPer
                MyCardData.shuxingzengzhi = getCardPropFormula(instCardData.int["9"])
                MyCardData.damageIncrease = getTitleDamageAdd(instCardData.int["6"])
                local skill1 = { }
                local skill2 = { }
                local skill3 = { }
                skill1.lv = 1
                skill2.lv = 1
                skill3.lv = 1
                if isAwake == 1 then
                    MyCardData.awoken = true
                    local _tempNewSkillIds = utils.stringSplit(dictCardData.awakeNewSkills, ";")
                    skill1.id = tonumber(_tempNewSkillIds[1])
                    skill2.id = tonumber(_tempNewSkillIds[2])
                    skill3.id = tonumber(_tempNewSkillIds[3])
                    table.insert(sks, { lv = 1, id = dictCardData.awakeSkill })
                else
                    skill1.id = dictCardData.skillOne
                    skill2.id = dictCardData.skillTwo
                    skill3.id = dictCardData.skillThree
                    if dictCardData.id == 88 and instCardData.int["4"] >= StaticQuality.red then
                        skill1.id = 1618
                        skill2.id = 1619
                        skill3.id = 1620
                    end
                end
                table.insert(sks, skill1)
                table.insert(sks, skill2)
                if MyCardData.frameID >= StaticQuality.purple then
                    table.insert(sks, skill3)
                end
                MyCardData.sks = sks
                if _fightType ~= dp.FightType.FIGHT_3V3 then
                    local _fireInstData = utils.getEquipFireInstData(instCardId, true)
                    for _fireKey, _fireObj in pairs(_fireInstData) do
                        if MyCardData.pyros == nil then
                            MyCardData.pyros = { }
                        end
                        MyCardData.pyros[#MyCardData.pyros + 1] = {
                            id = _fireObj.int["3"],
                            lv = utils.getEquipFireState(_fireObj.int["1"])
                        }
                    end
                    _fireInstData = nil
                end
                --                if _fightType ~= dp.FightType.FIGHT_BOSS then
                table.insert(Fight_INIT_DATA.myData.substitute, MyCardData)
                --                end
            end
        end
    end
    utils.quickSort(Fight_INIT_DATA.myData.substitute, function(obj1, obj2) if obj1._id > obj2._id then return true end end)

    if _fightType == dp.FightType.FIGHT_OVERLORD_WAR then
        local c = (param.defBuff + 100) / 100
        for position, cardData in pairs(Fight_INIT_DATA.otherData[1].mainForce) do
            cardData.hp = cardData.hp * c
            cardData.hit = cardData.hit * c
            cardData.dodge = cardData.dodge * c
            cardData.crit = cardData.crit * c
            cardData.critRatioDHSub = cardData.critRatioDHSub * c
            cardData.attPhsc = cardData.attPhsc * c
            cardData.attMana = cardData.attMana * c
            cardData.defPhsc = cardData.defPhsc * c
            cardData.defMana = cardData.defMana * c
        end

        for position, cardData in pairs(Fight_INIT_DATA.otherData[1].substitute) do
            cardData.hp = cardData.hp * c
            cardData.hit = cardData.hit * c
            cardData.dodge = cardData.dodge * c
            cardData.crit = cardData.crit * c
            cardData.critRatioDHSub = cardData.critRatioDHSub * c
            cardData.attPhsc = cardData.attPhsc * c
            cardData.attMana = cardData.attMana * c
            cardData.defPhsc = cardData.defPhsc * c
            cardData.defMana = cardData.defMana * c
        end

        c = (param.attBuff + 100) / 100
        for position, cardData in pairs(Fight_INIT_DATA.myData.mainForce) do
            cardData.hp = cardData.hp * c
            cardData.hit = cardData.hit * c
            cardData.dodge = cardData.dodge * c
            cardData.crit = cardData.crit * c
            cardData.critRatioDHSub = cardData.critRatioDHSub * c
            cardData.attPhsc = cardData.attPhsc * c
            cardData.attMana = cardData.attMana * c
            cardData.defPhsc = cardData.defPhsc * c
            cardData.defMana = cardData.defMana * c
        end
        for position, cardData in pairs(Fight_INIT_DATA.myData.substitute) do
            cardData.hp = cardData.hp * c
            cardData.hit = cardData.hit * c
            cardData.dodge = cardData.dodge * c
            cardData.crit = cardData.crit * c
            cardData.critRatioDHSub = cardData.critRatioDHSub * c
            cardData.attPhsc = cardData.attPhsc * c
            cardData.attMana = cardData.attMana * c
            cardData.defPhsc = cardData.defPhsc * c
            cardData.defMana = cardData.defMana * c
        end
    end


    -- if  _fightType ~= dp.FightType.FIGHT_BOSS then
    -- 	for i = 1,4 do
    -- 		local skill ={}
    -- 		local skillOpenLevel = DictSysConfig[tostring(StaticSysConfig["manualSkillPosition" .. i])].value
    --        	if net.InstPlayer.int["4"] >= skillOpenLevel then
    --        		local manualSkillId = 0
    --        		if net.InstPlayerManualSkillLine then
    --        			manualSkillId =net.InstPlayerManualSkillLine.int[tostring(i+2)]
    --        		end
    --        		if manualSkillId ~= 0 then
    --        			if net.InstPlayerManualSkill then
    -- 					skill.id = net.InstPlayerManualSkill[tostring(manualSkillId)].int["4"]
    -- 					skill.lv = net.InstPlayerManualSkill[tostring(manualSkillId)].int["5"]
    -- 					skill.iconID = DictManualSkill[tostring(skill.id)].smallUiId
    -- 				end
    -- 				table.insert(Fight_INIT_DATA.myData.skillCards,skill)
    --        		else
    --        			table.insert(Fight_INIT_DATA.myData.skillCards,skill)
    --        		end
    --        	end
    -- 	end
    -- end
    --    local function recursionTab(t, kkk)
    --        for key, value in pairs(t) do
    --            if type(value) == "table" then
    --                recursionTab(value, kkk .. "." .. key)
    --            else
    --                cclog(kkk .. "." .. key .. "=" .. tostring(value))
    --            end
    --        end
    --    end
    --    recursionTab(Fight_INIT_DATA, "Fight_INIT_DATA")
    UIFightMain.setData(Fight_INIT_DATA, param, _fightType, callBackFunc, cbOfCalcResult)
end

----根据表类型添加边框的方法
-- 返回值 qualityId
function utils.addBorderImage(tableTypeId, tableFieldId, image_frame_good)
    local littleImageTag = 100
    local qualityId = nil
    if image_frame_good:getChildByTag(littleImageTag) ~= nil then
        image_frame_good:removeChildByTag(littleImageTag)
    end
    if tableTypeId == StaticTableType.DictFightSoul then
        qualityId = DictFightSoul[tostring(tableFieldId)].fightSoulQualityId
        -- cclog("fightSoul -------->"..qualityId)
        borderImage = utils.getSoulBorderImage(tonumber(qualityId), 1)
        image_frame_good:loadTexture(borderImage)
    elseif tonumber(tableTypeId) == StaticTableType.DictCardSoul then
        --- 是魂魄的话要加上角标
        local dictData = DictCardSoul[tostring(tableFieldId)]
        local cardId = dictData.cardId
        qualityId = DictCard[tostring(cardId)].qualityId
        local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
        image_frame_good:loadTexture(borderImage)
        local littleImage = ccui.ImageView:create("ui/hun.png")
        littleImage:setAnchorPoint(cc.p(0.2, 0.8))
        littleImage:setPosition(cc.p(0, image_frame_good:getContentSize().height))
        image_frame_good:addChild(littleImage, littleImageTag, littleImageTag)
    elseif tonumber(tableTypeId) == StaticTableType.DictCard then
        qualityId = DictCard[tostring(tableFieldId)].qualityId
        local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
        image_frame_good:loadTexture(borderImage)
    elseif tonumber(tableTypeId) == StaticTableType.DictChip then
        local littleImage = ccui.ImageView:create("ui/suipian.png")
        littleImage:setAnchorPoint(cc.p(0.2, 0.8))
        littleImage:setPosition(cc.p(0, image_frame_good:getContentSize().height))
        image_frame_good:addChild(littleImage, littleImageTag, littleImageTag)
        local dicData = DictChip[tostring(tableFieldId)]
        local dictMagicData = nil
        local dictSkillData = nil
        if dicData.type == 1 then
            dictSkillData = DictManualSkill[tostring(dicData.skillOrKungFuId)]
        else
            dictMagicData = DictMagic[tostring(dicData.skillOrKungFuId)]
        end
        if dictMagicData then
            qualityId = dictMagicData.magicQualityId
            local borderImage = utils.getQualityImage(dp.Quality.gongFa, qualityId, dp.QualityImageType.small)
            image_frame_good:loadTexture(borderImage)
        end
        if dictSkillData then
            local type = dictSkillData.type
            local typeImage, borderImage = utils.getQualityImage(dp.Quality.skill, 0, type)
            image_frame_good:loadTexture(borderImage)
        end
        if not dictMagicData and not dictSkillData then
            UIManager.showToast(Lang.utils39)
        end
    elseif tonumber(tableTypeId) == StaticTableType.DictEquipment then
        qualityId = DictEquipment[tostring(tableFieldId)].equipQualityId
        local borderImage = utils.getQualityImage(dp.Quality.equip, qualityId, dp.QualityImageType.small)
        image_frame_good:loadTexture(borderImage)
    elseif tonumber(tableTypeId) == StaticTableType.DictPill then
        local dictPillData = DictPill[tostring(tableFieldId)]
        local dictTableType = DictTableType[tostring(dictPillData.tableTypeId)]
        local littleImageName = nil
        if dictTableType.id == StaticTableType.DictFightProp then
            littleImageName = utils.getPropImage(dictPillData.tableFieldId, "small")
        elseif dictTableType.id == StaticTableType.DictCardBaseProp then
            littleImageName = utils.getPropImage(dictPillData.tableFieldId, "small", true)
        end
        image_frame_good:loadTexture("ui/quality_small_purple.png")
        local littleImage = ccui.ImageView:create(littleImageName)
        littleImage:setAnchorPoint(cc.p(0, 1))
        littleImage:setPosition(cc.p(0, image_frame_good:getContentSize().height))
        image_frame_good:addChild(littleImage, littleImageTag, littleImageTag)
    elseif tonumber(tableTypeId) == StaticTableType.DictThing then
        local dictData = DictThing[tostring(tableFieldId)]
        if dictData.equipmentId ~= 0 then
            -- 装备碎片
            local littleImage = ccui.ImageView:create("ui/suipian.png")
            littleImage:setAnchorPoint(cc.p(0.2, 0.8))
            littleImage:setPosition(cc.p(0, image_frame_good:getContentSize().height))
            image_frame_good:addChild(littleImage, littleImageTag, littleImageTag)
            qualityId = DictEquipment[tostring(dictData.equipmentId)].equipQualityId
            local borderImage = utils.getQualityImage(dp.Quality.equip, qualityId, dp.QualityImageType.small)
            image_frame_good:loadTexture(borderImage)
        else
            qualityId = dictData.bkGround
            local borderImage = utils.getThingQualityImg(qualityId)
            image_frame_good:loadTexture(borderImage)
        end
    elseif tonumber(tableTypeId) == StaticTableType.DictPillThing then
        image_frame_good:loadTexture("ui/quality_small_purple.png")
    elseif tonumber(tableTypeId) == StaticTableType.DictManualSkill then
        local dicData = DictManualSkill[tostring(tableFieldId)]
        if dicData then
            local type = dicData.type
            local typeImage, borderImage = utils.getQualityImage(dp.Quality.skill, 0, type)
            image_frame_good:loadTexture(borderImage)
        else
            cclog("斗技表无这条数据")
        end
    elseif tonumber(tableTypeId) == StaticTableType.DictMagic then
        local dicData = DictMagic[tostring(tableFieldId)]
        if dicData then
            qualityId = dicData.magicQualityId
            local borderImage = utils.getQualityImage(dp.Quality.gongFa, qualityId, dp.QualityImageType.small)
            image_frame_good:loadTexture(borderImage)
        else
            cclog("功法表无这条数据")
        end
    elseif tonumber(tableTypeId) == StaticTableType.DictPlayerBaseProp then
        local dicData = DictPlayerBaseProp[tostring(tableFieldId)]
        if dicData then
            image_frame_good:loadTexture("ui/quality_small_purple.png")
        else
            cclog("玩家属性表无这条数据")
        end
    elseif tonumber(tableTypeId) == StaticTableType.DictYFire then
        local dicData = DictYFire[tostring(tableFieldId)]
        if dictData then
            image_frame_good:loadTexture("ui/quality_small_purple.png")
        end
    elseif tonumber(tableTypeId) == StaticTableType.DictYFireChip then
        local dicData = DictYFireChip[tostring(tableFieldId)]
        if dictData then
            image_frame_good:loadTexture("ui/quality_small_purple.png")
        end
        local littleImage = ccui.ImageView:create("ui/fire_seed.png")
        littleImage:setAnchorPoint(cc.p(0.2, 0.8))
        littleImage:setPosition(cc.p(0, image_frame_good:getContentSize().height))
        image_frame_good:addChild(littleImage, littleImageTag, littleImageTag)
    end
    return qualityId
end

----引导添加粒子旋转的路线 flag 向左 flag向右
function utils.MyPathFun(controlX, controlY, width, time, flag)
    local time2 = controlY == 0 and time or(width * time / controlY)
    local path = nil
    local bezier = {
        cc.p(- controlX,0),-- 控制点1
        cc.p(- controlX,controlY),-- 控制点2
        cc.p(0,controlY),-- 控制点3
    }
    local bezierBy1 = cc.BezierBy:create(time, bezier)
    local move1 = cc.MoveBy:create(time2, cc.p(width, 0))
    local bezier_1 = {
        cc.p(controlX,0),
        cc.p(controlX,- controlY),
        cc.p(0,- controlY),
    }
    local bezierBy2 = cc.BezierBy:create(time, bezier_1)
    local move2 = cc.MoveBy:create(time2, cc.p(- width, 0))
    if width ~= 0 then
        if flag == 1 then
            path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, move1, bezierBy2, move2))
        else
            path = cc.RepeatForever:create(cc.Sequence:create(bezierBy2, move2, bezierBy1, move1))
        end
    else
        if flag == 1 then
            path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, bezierBy2))
        else
            path = cc.RepeatForever:create(cc.Sequence:create(bezierBy2, bezierBy1))
        end
    end
    return path
end
----引导添加粒子旋转的路线 flag 向左 flag向右
function utils.MyPathFunSix(width, height, time, flag)
    local path = nil
    local move1 = cc.MoveBy:create(time / 6, cc.p(width / 2 + 2, 0))
    local move2 = cc.MoveBy:create(time / 6, cc.p(width / 4 + 1, height / 2 + 2))
    local move3 = cc.MoveBy:create(time / 6, cc.p(- width / 4 - 1, height / 2 + 2))
    local move4 = cc.MoveBy:create(time / 6, cc.p(- width / 2 - 2, 0))
    local move5 = cc.MoveBy:create(time / 6, cc.p(- width / 4 - 1, - height / 2 - 2))
    local move6 = cc.MoveBy:create(time / 6, cc.p(width / 4 + 1, - height / 2 - 2))
    if flag == 1 then
        path = cc.RepeatForever:create(cc.Sequence:create(move1, move2, move3, move4, move5, move6))
    else
        path = cc.RepeatForever:create(cc.Sequence:create(move4, move5, move6, move1, move2, move3))
    end
    return path
end
------设置卡牌的称号----------
-- titleId 称号Id
-- starValue DictTitleDetail表的value
function utils.setChengHaoImage(image_di, starValue, titleId)
    if image_di:getChildByTag(99) then
        image_di:getChildByTag(99):removeFromParent()
    end
    if image_di:getChildByTag(100) then
        image_di:getChildByTag(100):removeFromParent()
    end
    local starImage = nil
    local titleImage = nil
    if starValue > 0 then
        -- if starValue == 9 then
        --   starImage = ccui.ImageView:create("ui/zi_chenhao3.png")
        -- else
        starImage = ccui.ImageView:create("ui/zi_chenhao1.png")
        starImage:setTextureRect(cc.rect(0,(starValue - 1) * 38, 66, 38))
        -- end
        starImage:setPosition(cc.p(33, 20))
        image_di:addChild(starImage, 0, 99)
    end
    if titleId > 0 then
        titleImage = ccui.ImageView:create("ui/zi_chenhao2.png")
        titleImage:setTextureRect(cc.rect(0,(titleId - 1) * 38, 93, 38))
        if starValue == 0 then
            titleImage:setPosition(cc.p(60, 20))
        else
            titleImage:setPosition(cc.p(100, 20))
        end
        image_di:addChild(titleImage, 0, 100)
    end
end
---------根据品质改变颜色----------
function utils.changeNameColor(uiName, qualityId, qualityType, isFollowType)
    if qualityType == dp.Quality.gongFa or(qualityType == dp.Quality.fightSoul and not isFollowType) then
        if qualityId == 4 then
            uiName:setTextColor(cc.c4b(7, 105, 0, 255))
        elseif qualityId == 3 then
            uiName:setTextColor(cc.c4b(0, 61, 255, 255))
        elseif qualityId == 2 then
            uiName:setTextColor(cc.c4b(122, 0, 123, 255))
        elseif qualityId == 1 then
            uiName:setTextColor(cc.c4b(217, 88, 3, 255))
        else
            uiName:setTextColor(cc.c4b(0, 0, 255, 255))
        end
    elseif qualityType == dp.Quality.fightSoul and isFollowType then
        if qualityId == 4 then
            uiName:setTextColor(cc.c4b(0, 255, 156, 255))
        elseif qualityId == 3 then
            uiName:setTextColor(cc.c4b(78, 195, 255, 255))
        elseif qualityId == 2 then
            uiName:setTextColor(cc.c4b(194, 88, 255, 255))
        elseif qualityId == 1 then
            uiName:setTextColor(cc.c4b(217, 88, 3, 255))
        else
            uiName:setTextColor(cc.c4b(255, 255, 255, 255))
        end
    else
        if qualityId == 1 then
            uiName:setTextColor(cc.c4b(7, 105, 0, 255))
        elseif qualityId == 2 then
            uiName:setTextColor(cc.c4b(0, 61, 255, 255))
        elseif qualityId == 3 then
            uiName:setTextColor(cc.c4b(122, 0, 123, 255))
        elseif qualityId == 4 then
            uiName:setTextColor(cc.c4b(216, 72, 0, 255))
        elseif qualityId == 5 then
            uiName:setTextColor(cc.c4b(255, 0, 0, 255))
        elseif qualityId == 6 then
            uiName:setTextColor(cc.c4b(228, 129, 0, 255))
        else
            uiName:setTextColor(cc.c4b(0, 0, 255, 255))
        end
    end

end
--- 获得字典表的个数---------
--- tableName 表名
function utils.getDictTableNum(tableName)
    local i = 0
    if tableName then
        for key, obj in pairs(tableName) do
            i = i + 1
        end
    end
    return i
end

local function chargeCallBack(pack)
    if pack.msgdata.int and pack.msgdata.int["1"] then
        dp.rechargeGold = pack.msgdata.int["1"]
    else
        return
    end
    if pack.msgdata.string and pack.msgdata.string["2"] then
        UIGiftRecharge.retList = pack.msgdata.string["2"]
    else
        return
    end
    if UIGiftVip.Widget and UIGiftVip.Widget:getParent() then
        UIManager.replaceScene("ui_gift_recharge")
    else
        UIManager.pushScene("ui_gift_recharge")
    end
end

--- type 是否要充值列表首充状态 0-不要 1-要 3活动累计充值的钱数 4 每日充值的钱数
function utils.checkGOLD(_type, _callBack)
    UIManager.showLoading()
    local data = {
        header = StaticMsgRule.lookSaveAmt,
        msgdata =
        {
            int =
            {
                type = _type,
            }
        }
    }
    if _callBack then
        netSendPackage(data, _callBack)
    else
        netSendPackage(data, chargeCallBack)
    end
end
--enabled是否不恢复按键 false是 true否
function utils.showGetThings(_param, inTime, stillTime, outTime, walkImage , enabled , touched )
    inTime = inTime or 0.1
    stillTime = stillTime or 0.3
    outTime = outTime or 0.1
    local childs = UIManager.uiLayer:getChildren()
    if touched then
    else
        for key, obj in pairs(childs) do
            if not tolua.isnull(obj) then
                obj:setEnabled(false)
            end
        end
    end
    local param = utils.stringSplit(_param, ";")
    local function Toast(str)
        local data = utils.stringSplit(str, "_")
        -- [1]:TableTypeId [2]:FieldId [3]:Nums
        local name, icon = utils.getDropThing(data[1], data[2])
        local tableTypeId, tableFieldId, value = data[1], data[2], data[3]
        local toast_bg = cc.Scale9Sprite:create("ui/quality_middle.png")
        toast_bg:setAnchorPoint(cc.p(0.5, 0.5))
        toast_bg:setPreferredSize(cc.size(474, 105))
        toast_bg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
        local node = cc.Node:create()
        local image_di = ccui.ImageView:create("ui/quality_small_purple.png")
        local image = ccui.ImageView:create(icon)
        image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
        image_di:addChild(image)
        image_di:setPosition(cc.p(image_di:getContentSize().width, 0))
        image_di:setScale(0.9)
        if walkImage then walkImage(image_di, str) end
        local description = ccui.Text:create()
        description:setFontSize(25)
        description:setFontName(dp.FONT)
        description:setAnchorPoint(cc.p(0, 0.7))
        description:setString(name .. "×" .. value)
        description:setPosition(cc.p(cc.p(image_di:getPosition()).x + image_di:getContentSize().width / 2, 0))
        utils.addBorderImage(tableTypeId, tableFieldId, image_di)
        node:addChild(image_di)
        node:addChild(description)
        node:setPosition(cc.p(image_di:getContentSize().width / 2, toast_bg:getPreferredSize().height / 2))
        toast_bg:addChild(node, 10)
        UIManager.gameLayer:addChild(toast_bg, 100)
        toast_bg:retain()
        local function hideToast()
            if toast_bg then
                UIManager.gameLayer:removeChild(toast_bg, true)
                cc.release(toast_bg)
                if #param >= 2 then
                    table.remove(param, 1)
                    Toast(param[1])
                else
                    if enabled then
                    else
                        for key, obj in pairs(childs) do
                            if not tolua.isnull(obj) then
                                obj:setEnabled(true)
                            end
                        end
                    end
                end
            end
        end
        if #param == 1 then
            toast_bg:runAction(cc.Sequence:create(cc.MoveBy:create(inTime, cc.p(0, 100)), cc.DelayTime:create(stillTime), cc.MoveBy:create(outTime, cc.p(0, 60)), cc.CallFunc:create(hideToast)))
        else
            toast_bg:runAction(cc.Sequence:create(cc.MoveBy:create(inTime, cc.p(0, 100)), cc.DelayTime:create(stillTime), cc.CallFunc:create(hideToast)))
        end
    end
    if #param >= 1 then
        Toast(param[1])
    end
end
--- 点击小图标弹出详情-----------
function utils.showThingsInfo(uiImage, tableTypeId, tableFieldId)
    local function showInfo()
        if tonumber(tableTypeId) == StaticTableType.DictWing then
            UIWingInfoAll.setId(tableFieldId)
            UIManager.pushScene("ui_wing_info_all")
        elseif tonumber(tableTypeId) == StaticTableType.DictCard then
            -- 卡牌字典表
            UICardInfo.setDictCardId(tableFieldId)
            UIManager.pushScene("ui_card_info")
        elseif tonumber(tableTypeId) == StaticTableType.DictMagic then
            local dicData = DictMagic[tostring(tableFieldId)]
            local value = dicData.value1
            if value ~= "3" then
                UIGongfaInfo.setDictMagicId(dicData.id)
                UIManager.pushScene("ui_gongfa_info")
            else
                local param = { }
                param.tableTypeId = tableTypeId
                param.tableFieldId = tableFieldId
                UIGoodInfo.setParam(param)
                UIManager.pushScene("ui_good_info")
            end
        else
            local param = { }
            param.tableTypeId = tableTypeId
            param.tableFieldId = tableFieldId
            UIGoodInfo.setParam(param)
            UIManager.pushScene("ui_good_info")
        end
    end
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            showInfo()
        end
    end
    uiImage:setTouchEnabled(true)
    uiImage:addTouchEventListener(btnTouchEvent)
end

--- 购买耐力开始----
local buyVigorNum = 0
local vigorPillPrice = 0

local function netCallbackFunc(pack)
    if tonumber(pack.header) == StaticMsgRule.thingUse or tonumber(pack.header) == StaticMsgRule.goldEnergyOrVigor then
        if tonumber(pack.header) == StaticMsgRule.thingUse then
            UIManager.showToast(Lang.utils40 .. DictSysConfig[tostring(StaticSysConfig.vigorPillVigor)].value .. Lang.utils41)
        else
            local widget = utils.BuyVigorDialog.Widget
            if widget then
                local text_vigorpill = ccui.Helper:seekNodeByName(widget, "text_vigorpill")
                local sprite = cc.Sprite:create("image/+1.png")
                local size = text_vigorpill:getContentSize()
                sprite:setPosition(size.width / 2, size.height / 2)
                sprite:setScale(20 / sprite:getContentSize().height)
                sprite:setOpacity(150)
                text_vigorpill:addChild(sprite)

                local rightHint = ccui.Helper:seekNodeByName(widget, "rightHint")
                rightHint:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.1, 1)))

                local scaleAction = cc.ScaleTo:create(1 / 6, 1.0)
                local alphaAction = cc.Sequence:create(cc.FadeIn:create(5 / 60), cc.DelayTime:create(1 / 6), cc.FadeOut:create(15 / 60))
                local moveAction = cc.EaseCubicActionInOut:create(cc.MoveBy:create(30 / 60, cc.p(0, 127)))
                moveAction = cc.Sequence:create(moveAction, cc.RemoveSelf:create())
                sprite:runAction(cc.Spawn:create(scaleAction, alphaAction, moveAction))
            end
        end

        if UILootChoose.Widget and UILootChoose.Widget:getParent() then
            UILootChoose.flushVigor()
        end
        if UIArena.Widget and UIArena.Widget:getParent() then
            UIArena.flushVigor()
        end

        if tonumber(pack.header) == StaticMsgRule.goldEnergyOrVigor then
            UIShop.getShopList(1, nil)
        end

        utils.checkPlayerVigor()
    end
end

utils.BuyVigorDialog = { }

local function showBuyVigorDialog()
    utils.BuyVigorDialog.init()
    utils.BuyVigorDialog.setup()
end

function utils.BuyVigorDialog.init()
    if utils.BuyVigorDialog.Widget then return end
    local vipNum = net.InstPlayer.int["19"]

    local ui_middle = ccui.Layout:create()
    ui_middle:setContentSize(display.size)
    ui_middle:setTouchEnabled(true)
    ui_middle:retain()

    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    ui_middle:addChild(bg_image)
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 500))
    bg_image:setPosition(display.size.width / 2, display.size.height / 2)
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.utils42)
    title:setFontName(dp.FONT)
    title:setFontSize(35)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height - 15))
    bg_image:addChild(title, 3)

    local msgLabel = ccui.Text:create()
    msgLabel:setString(Lang.utils43)
    msgLabel:setTextAreaSize(cc.size(425, 500))
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(26)
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height * 3.5))
    bg_image:addChild(msgLabel, 3)

    local node = cc.Node:create()
    local image_di = ccui.ImageView:create("ui/quality_small_blue.png")
    local image = ccui.ImageView:create("image/poster_item_small_nailidan.png")
    local description = ccui.Text:create()
    description:setName("text_vigorpill")
    description:setFontSize(20)
    description:setFontName(dp.FONT)
    description:setAnchorPoint(cc.p(0.5, 1))
    description:setTextColor(cc.c3b(255, 255, 0))
    image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
    image_di:addChild(image)
    image_di:setPosition(cc.p(0, 0))
    description:setPosition(cc.p(0, - image_di:getContentSize().height / 2 - 5))
    node:addChild(image_di)
    node:addChild(description)
    description:setString(Lang.utils44 .. DictSysConfig[tostring(StaticSysConfig.vigorPillVigor)].value)
    node:setPosition(cc.p(bgSize.width / 2, msgLabel:getPositionY() -95))
    bg_image:addChild(node, 3)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width / 2, bgSize.height - closeBtn:getContentSize().height / 2))
    bg_image:addChild(closeBtn, 3)

    closeBtn:addTouchEventListener( function(sender, eventType)
        if sender == closeBtn then
            bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.1), cc.CallFunc:create( function()
                UIManager.uiLayer:removeChild(ui_middle, true)
                cc.release(ui_middle)
                utils.BuyVigorDialog.Widget = nil
            end )))
        end
    end
    )

    local sureBtn = ccui.Button:create("ui/yh_sq_btn01.png", "ui/yh_sq_btn01.png")
    sureBtn:setName("sureBtn")
    sureBtn:setPressedActionEnabled(true)
    local withscale = ccui.RichText:create()
    withscale:setName("withscale")
    withscale:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.utils45, dp.FONT, 25))
    withscale:pushBackElement(ccui.RichElementImage:create(2, display.COLOR_WHITE, 255, "ui/jin.png"))
    withscale:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, "×10", dp.FONT, 25))
    withscale:setPosition(sureBtn:getContentSize().width / 2, sureBtn:getContentSize().height / 2)
    sureBtn:addChild(withscale)
    sureBtn:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.2))
    bg_image:addChild(sureBtn, 3)

    local leftHint = ccui.RichText:create()
    leftHint:setName("leftHint")
    leftHint:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.utils46, dp.FONT, 20))
    leftHint:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, "0", dp.FONT, 20))
    leftHint:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.utils47, dp.FONT, 20))
    leftHint:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.1))
    bg_image:addChild(leftHint, 3)

    local useBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    useBtn:setName("useBtn")
    useBtn:setTitleText(Lang.utils48)
    useBtn:setTitleFontName(dp.FONT)
    useBtn:setTitleFontSize(25)
    useBtn:setPressedActionEnabled(true)
    useBtn:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.2))
    bg_image:addChild(useBtn, 3)

    local rightHint = ccui.RichText:create()
    rightHint:setName("rightHint")
    rightHint:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.utils49, dp.FONT, 20))
    rightHint:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, "0", dp.FONT, 20))
    rightHint:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.utils50, dp.FONT, 20))
    rightHint:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.1))
    bg_image:addChild(rightHint, 3)

    UIManager.uiLayer:addChild(ui_middle, 20000)
    ActionManager.PopUpWindow_SplashAction(bg_image)
    utils.BuyVigorDialog.Widget = ui_middle
end

function utils.BuyVigorDialog.setup()
    if not utils.BuyVigorDialog.Widget then return end

    local widget = utils.BuyVigorDialog.Widget

    local number = 0
    local instThingId = nil
    if net.InstPlayerThing then
        for key, obj in pairs(net.InstPlayerThing) do
            if StaticThing.vigorPill == obj.int["3"] then
                number = obj.int["5"]
                instThingId = obj.int["1"]
            end
        end
    end

    local withscale = ccui.Helper:seekNodeByName(widget, "withscale")
    local leftHint = ccui.Helper:seekNodeByName(widget, "leftHint")
    local rightHint = ccui.Helper:seekNodeByName(widget, "rightHint")
    local sureBtn = ccui.Helper:seekNodeByName(widget, "sureBtn")
    local useBtn = ccui.Helper:seekNodeByName(widget, "useBtn")

    withscale:removeElement(2)
    withscale:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, "×" .. vigorPillPrice, dp.FONT, 25))
    leftHint:removeElement(1)
    leftHint:insertElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, tostring(math.max(0, buyVigorNum)), dp.FONT, 20), 1)
    rightHint:removeElement(1)
    rightHint:insertElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, tostring(number), dp.FONT, 20), 1)

    local function sendUseData(_instPlayerThingId)
        local sendData = {
            header = StaticMsgRule.thingUse,
            msgdata =
            {
                int =
                {
                    instPlayerThingId = _instPlayerThingId,
                    num = 1,
                }
            }
        }
        UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc)
    end
    local function sendGoldData()
        local sendData = {
            header = StaticMsgRule.goldEnergyOrVigor,
            msgdata =
            {
                int =
                {
                    type = 2,
                }
            }
        }
        UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc)
    end

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == sureBtn then
                if 0 < buyVigorNum then
                    sendGoldData()
                end
            elseif sender == useBtn then
                if number > 0 then
                    sendUseData(instThingId)
                end
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    useBtn:addTouchEventListener(btnEvent)
    if number <= 0 then
        utils.GrayWidget(useBtn, true)
        useBtn:setEnabled(false)
    else
        utils.GrayWidget(useBtn, false)
        useBtn:setEnabled(true)
    end
    if vigorPillPrice > net.InstPlayer.int["5"] or buyVigorNum <= 0 then
        utils.GrayWidget(sureBtn, true)
        sureBtn:setEnabled(false)
    else
        utils.GrayWidget(sureBtn, false)
        sureBtn:setEnabled(true)
    end
end

local function getShopFunc(pack)
    local propThing = pack.msgdata.message
    if propThing then
        for key, obj in pairs(propThing) do
            local tableFieldId = obj.int["thingId"]
            if tableFieldId == StaticThing.vigorPill then
                buyVigorNum = obj.int["canBuyNum"]
                local _todayBuyPrice = 0
                local _todayBuyNum = obj.int["todayBuyNum"] + 1
                local _extend = utils.stringSplit(DictThingExtend[tostring(tableFieldId)].extend, ";")
                for _k, _o in pairs(_extend) do
                    local _tempO = utils.stringSplit(_o, "_")
                    if _todayBuyNum >= tonumber(_tempO[1]) and _todayBuyNum <= tonumber(_tempO[2]) then
                        vigorPillPrice = math.round(tonumber(_tempO[3]) * UIShop.disCount)
                        break
                    end
                end
                break
            end
        end
    end
    showBuyVigorDialog()
end

function utils.checkPlayerVigor()
    UIManager.showLoading()
    local data = {
        header = StaticMsgRule.getStoreData,
        msgdata =
        {
            int =
            {
                type = 1,
            },
        }
    }
    netSendPackage(data, getShopFunc)
end



-- 为控件添加红点
-- flag 添加还是删除 true/false
-- item 添加红点的控件
-- tag  红点tag
-- posX,posY 红点偏移量
-- zOrder 红点zOrder
function utils.addImageHint(flag, item, tag, posX, posY, zOrder)
    if item and not tolua.isnull(item) then
        if flag then
            if not item:getChildByTag(tag) then
                local image_hint = cc.Sprite:create("ui/jiao.png")
                local contentSize = item:getContentSize()
                if not posX then
                    posX = 0
                end
                if not posY then
                    posY = 0
                end
                image_hint:setPosition(cc.p(contentSize.width - posX, contentSize.height - posY))
                image_hint:setTag(tag)
                if zOrder then
                    image_hint:setLocalZOrder(zOrder)
                end
                item:addChild(image_hint)
            end
        else
            item:removeChildByTag(tag)
        end
    end
end

function utils.decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function utils.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function utils.getEquipSuit(_equipId)
    local suitId = nil
    for key, obj in pairs(DictEquipSuitRefer) do
        if tonumber(obj.equipId) == tonumber(_equipId) then
            suitId = obj.equipSuitId
            break
        end
    end
    if not suitId then
        -- cclog("utils无此suitId : equipId.. ".._equipId )
        return nil
    end
    local dictEquipSuitred = nil
    if DictEquipSuit[tostring(suitId)] then
        if DictEquipSuit[tostring(suitId)].Redsuit0StarProp == "" and
           DictEquipSuit[tostring(suitId)].Redsuit1StarProp == "" and
           DictEquipSuit[tostring(suitId)].Redsuit2StarProp == "" and
           DictEquipSuit[tostring(suitId)].Redsuit3StarProp == "" and
           DictEquipSuit[tostring(suitId)].Redsuit4StarProp == "" and
           DictEquipSuit[tostring(suitId)].Redsuit5StarProp == "" then
            --0-5星全为空串，就表示没有红色套装属性
        else
            dictEquipSuitred = DictEquipSuit[tostring(suitId)]
        end
    end
    return DictEquipSuit[tostring(suitId)], dictEquipSuitred
end

-- 播放UI动画
function utils.playArmature(animId, name, node, offsetX, offsetY, callBack, frameCallBack, frameName, scale, notEnabledTrue)
    --    if node:getChildByName("action") then
    --        node:getChildByName("action"):removeFromParent()
    --    end
    local animation = ActionManager.getUIAnimation(animId, callBack, false, notEnabledTrue)
    animation:getAnimation():stop()
    -- animation:getAnimation():setMovementEventCallFunc(nil)
    animation:setPosition(cc.p(UIManager.screenSize.width / 2 + offsetX, UIManager.screenSize.height / 2 + offsetY))
    animation:getAnimation():play(name)
    animation:setName("action")
    if scale then
        animation:setScale(scale)
    end
    node:addChild(animation, 10000)
    if frameName then
        local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
            if evt == frameName then
                frameCallBack()
            end
        end
        animation:getAnimation():setFrameEventCallFunc(onFrameEvent)
    end
    --    cclog("执行callBack")
    --    if callBack then
    --        local function onMovementEvent(armature, movementType, movementID)
    --            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
    --                armature:getAnimation():stop()
    --                callBack()
    --                cclog("执行callBack")
    --            end
    --        end
    --        animation:getAnimation():setMovementEventCallFunc(onMovementEvent)
    --    end
end
function utils.getSoulBorderImage(qualityId, type)
    local image = ""
    if type == 0 then
        if qualityId == 1 then
            image = "ui/yh_sq_gold.png"
        elseif qualityId == 2 then
            image = "ui/yh_sq_purple.png"
        elseif qualityId == 3 then
            image = "ui/yh_sq_blue.png"
        elseif qualityId == 4 then
            image = "ui/yh_sq_green.png"
        elseif qualityId == 5 then
            image = "ui/yh_sq_white.png"
        end
    elseif type == 1 then
        if qualityId == 1 then
            image = "ui/quality_small_purple.png"
        elseif qualityId == 2 then
            image = "ui/quality_small_blue.png"
        elseif qualityId == 3 then
            image = "ui/quality_small_green.png"
        elseif qualityId == 4 then
            image = "ui/quality_small_white.png"
        elseif qualityId == 5 then
            image = "ui/qd_k.png"
        end
    end
    return image
end
-- 展示猎魂品质图片 0:圆形 1:方形
function utils.ShowFightSoulQuality(node, qualityId, type)
    if type == 0 then
        if qualityId == 0 then
            node:loadTexture("ui/yh_sq_red.png")
        elseif qualityId == 1 then
            node:loadTexture("ui/yh_sq_gold.png")
        elseif qualityId == 2 then
            node:loadTexture("ui/yh_sq_purple.png")
        elseif qualityId == 3 then
            node:loadTexture("ui/yh_sq_blue.png")
        elseif qualityId == 4 then
            node:loadTexture("ui/yh_sq_green.png")
        elseif qualityId == 5 then
            node:loadTexture("ui/yh_sq_white.png")
        end
    elseif type == 1 then
        if qualityId == 0 then
            node:loadTexture("ui/quality_small_red.png")        
        elseif qualityId == 1 then
            node:loadTexture("ui/quality_small_purple.png")
        elseif qualityId == 2 then
            node:loadTexture("ui/quality_small_blue.png")
        elseif qualityId == 3 then
            node:loadTexture("ui/quality_small_green.png")
        elseif qualityId == 4 then
            node:loadTexture("ui/quality_small_white.png")
        elseif qualityId == 5 then
            node:loadTexture("ui/qd_k.png")
        end
    end
end
-- 获得斗魂属性键、值、金钱
function utils.getSoulPro(fightSoulId, level)
    --  cclog( "fightSoulId :"..fightSoulId.."  " ..level )
    local pro = nil
    if DictFightSoul[tostring(fightSoulId)].isExpFightSoul == 1 or DictFightSoul[tostring(fightSoulId)].fightSoulQualityId == 5 then
        for key, value in pairs(DictFightSoulUpgradeProp) do
            if value.fightSoulId == fightSoulId then
                pro = value
                break
            end
        end
    else
        for key, value in pairs(DictFightSoulUpgradeProp) do
            if value.fightSoulId == fightSoulId and value.level == level then
                pro = value
                break
            end
        end
        -- pro = DictFightSoulUpgradeProp[ tostring( ( ( fightSoulId - 1 ) * 10 ) + level ) ]
    end
    --  cclog( " ------------- " ..pro.fightPropValueType.. "   " ..pro.fightPropValue .. "   "..pro.sellSilver )
    local id = pro and pro.fightPropId or 0
    local value = pro and pro.fightPropValue or 0
    return id, value, pro.sellSilver
end
-- 斗魂例子图标
function utils.addSoulParticle(node, name , qualityId )
    if node then
        for i = 1, 3 do
            if node:getChildByName("soul" .. i) then
                node:removeChildByName("soul" .. i)
            end
        end
    end
    if qualityId and tonumber(qualityId) >= 3 then
        local size = node:getContentSize()
        local image = ccui.ImageView:create( "particle/soul/white.png" )
        if qualityId == 5 then
            image = ccui.ImageView:create( "particle/soul/white.png" )
        elseif qualityId == 4 then
            image = ccui.ImageView:create( "particle/soul/green.png" )
        elseif qualityId == 3 then
            image = ccui.ImageView:create( "particle/soul/blue.png" )
        end
        image:setPosition(cc.p(size.width / 2, size.height / 2))
        image:setName("soul" .. 1)
        node:addChild(image, 1)
        return
    end
    if name then
        local names = utils.stringSplit(name, ";")
        for key, value in pairs(names) do
            local size = node:getContentSize()
 --            cclog( "------------------------>key:" .. key .. " value:" ..value )
            local particle1 = cc.ParticleSystemQuad:create("particle/soul/" .. value)
            particle1:setPositionType(cc.POSITION_TYPE_RELATIVE)
            particle1:setPosition(cc.p(size.width / 2, size.height / 2))
            particle1:setName("soul" .. key)
            node:addChild(particle1, 1)
        end
    end
end

-- 根据卡牌实例ID获取装备的异火实例数据(最多三条数据)
function utils.getEquipFireInstData(_cardInstId, _isFilter)
    local _equipFireInstData = { }
    --FIX 修复Lua语法#(取表长度的Bug),该Bug导致异火莫名其妙的无法显示.
    --FIX 不考虑_position可能重复导致统计错误的问题.
    local tableSize = 0
    if net.InstPlayerYFire then
        for key, obj in pairs(net.InstPlayerYFire) do
            local cardIds = utils.stringSplit(obj.string["8"], ";")
            for _k, _o in pairs(cardIds) do
                local _tempO = utils.stringSplit(_o, "_")
                if tonumber(_tempO[1]) == _cardInstId then
                    local _position = tonumber(_tempO[2])
                    if _isFilter then
                        local instCardData = net.InstPlayerCard[tostring(_cardInstId)]
                        -- 卡牌实例数据
                        local qualityId = instCardData.int["4"]
                        -- 品阶ID
                        local starLevelId = instCardData.int["5"]
                        -- 星级ID
                        local _gridState = 0
                        -- 0.上锁, 1.开启
                        if qualityId >= dp.FireEquipGrid[_position].qualityId then
                            if qualityId == dp.FireEquipGrid[_position].qualityId then
                                if starLevelId >= dp.FireEquipGrid[_position].starLevelId then
                                    _gridState = 1
                                end
                            else
                                _gridState = 1
                            end
                        end
                        if _gridState == 1 then
                            _equipFireInstData[_position] = obj
                            tableSize = tableSize + 1
                            _tempO = nil
                            break
                        end
                    else
                        _equipFireInstData[_position] = obj
                        tableSize = tableSize + 1
                        _tempO = nil
                        break
                    end
                end
                _tempO = nil
            end
            cardIds = nil
            if tableSize >= #dp.FireEquipGrid then
                break
            end
        end
    end
    return _equipFireInstData
end

-- 根据异火实例ID获取装备的异火状态和当前HP(0:未激活，1:旺盛，2:狂暴)
function utils.getEquipFireState(_fireInstId)
    local _fireState, _curFireHP = 0, 0
    if net.InstPlayerYFire and net.InstPlayerYFire[tostring(_fireInstId)] then
        local instPlayerYFire = net.InstPlayerYFire[tostring(_fireInstId)]
        local _curFireState = instPlayerYFire.int["4"]
        _curFireHP = instPlayerYFire.int["6"]
        local _cardList = utils.stringSplit(instPlayerYFire.string["8"], ";")
        _fireState = _curFireState
        if _curFireState == 0 then
            -- 未激活状态
        elseif _curFireState == 1 then
            -- 激活状态（旺盛）
        elseif _curFireState == 2 then
            -- 激活状态（狂暴）
            if #_cardList > 0 then
                local _times = math.floor((utils.getCurrentTime() - utils.GetTimeByDate(instPlayerYFire.string["5"])) / 60)
                if _times < 0 then
                    _times = _times * -1
                end
                local _fireHP = _times * instPlayerYFire.int["7"] * #_cardList
                _curFireHP = _curFireHP - _fireHP + 1
                -- 因时间误差+1
                if _curFireHP <= 0 then
                    -- 进入旺盛状态
                    net.InstPlayerYFire[tostring(_fireInstId)].int["4"] = 1
                    net.InstPlayerYFire[tostring(_fireInstId)].int["6"] = 0
                    _fireState = 1
                    _curFireHP = 0
                end
                if _curFireHP > DictYFire[tostring(instPlayerYFire.int["3"])].hpMax then
                    _curFireHP = DictYFire[tostring(instPlayerYFire.int["3"])].hpMax
                end
            end
        end
        _cardList = nil
    end
    return _fireState, _curFireHP
end

-- 翅膀操作 ( proPanel 属性pannel strengthen 是否需要强化后的显示 , advance 是否需要进阶后的显示 )
-- thingData 强化 , advanceData 境界 , proShow 属性
function utils.getWingInfo(wingId, level, starNum, proPanel, strengthen, advance)
    local thingData = nil
    local nextData = nil
    local count = 1
    if strengthen then
        count = 2
    end
    for key, value in pairs(DictWingStrengthen) do
        if value.wingId == wingId and value.level == level then
            thingData = value
            count = count - 1
        end
        if strengthen and value.wingId == wingId and value.level == level + 1 then
            nextData = value
            count = count - 1
        end
        if count == 0 then
            break
        end
    end
    local advanceData = nil
    local advanceData1, advanceData2, advanceData3 = nil, nil, nil
    for key, value in pairs(DictWingAdvance) do
        if value.wingId == wingId and value.starNum == starNum then
            advanceData = value
            count = count - 1
        end
        if advance and value.wingId == wingId and value.starNum == starNum + 1 then
            nextData = value
            count = count - 1
        end
        if proPanel then
            if value.wingId == wingId then
                if value.starNum == 1 then
                    advanceData1 = value
                elseif value.starNum == 2 then
                    advanceData2 = value
                elseif value.starNum == 3 then
                    advanceData3 = value
                end
            end
        end
    end

    local proShow = utils.stringSplit(advanceData.openFightPropIdList, ";")

    if proPanel then
        local textName = { }
        for i = 1, 8 do
            local text_name = proPanel:getChildByName("text_name" .. i)
            table.insert(textName, text_name)
            text_name:setVisible(false)
        end
        local fightPropName = { }
        fightPropName["2"] = { id = 2, name = Lang.utils51, oname = Lang.utils52, sname = "wAttack", smallUiId = 0, bigUiId = 0, description = "" }
        fightPropName["3"] = { id = 3, name = Lang.utils53, oname = Lang.utils54, sname = "fAttack", smallUiId = 0, bigUiId = 0, description = "" }
        fightPropName["8"] = { id = 8, name = Lang.utils55, oname = Lang.utils56, sname = "wDefense", smallUiId = 0, bigUiId = 0, description = "" }
        fightPropName["9"] = { id = 9, name = Lang.utils57, oname = Lang.utils58, sname = "fDefense", smallUiId = 0, bigUiId = 0, description = "" }
        fightPropName["17"] = { id = 17, name = Lang.utils59, oname = Lang.utils60, sname = "leiDam", smallUiId = 0, bigUiId = 0, description = "" }
        fightPropName["18"] = { id = 18, name = Lang.utils61, oname = Lang.utils62, sname = "fengDam", smallUiId = 0, bigUiId = 0, description = "" }
        fightPropName["19"] = { id = 19, name = Lang.utils63, oname = Lang.utils64, sname = "guangDam", smallUiId = 0, bigUiId = 0, description = "" }
        fightPropName["20"] = { id = 20, name = Lang.utils65, oname = Lang.utils66, sname = "anDam", smallUiId = 0, bigUiId = 0, description = "" }
        local proLevelData3 = utils.stringSplit(advanceData3.openFightPropIdList, ";")
        for key, value in pairs(proLevelData3) do
            textName[key]:setVisible(true)
            textName[key]:setString(fightPropName[tostring(value)].oname .. Lang.utils67)
        end
        local proLevelData2 = utils.stringSplit(advanceData2.openFightPropIdList, ";")
        for key, value in pairs(proLevelData2) do
            textName[key]:setString(fightPropName[tostring(value)].oname .. Lang.utils68)
        end
        local proLevelData1 = utils.stringSplit(advanceData1.openFightPropIdList, ";")
        for key, value in pairs(proLevelData1) do
            textName[key]:setString(fightPropName[tostring(value)].oname .. Lang.utils69)
        end
        local pro = utils.stringSplit(thingData.fightPropValueList, ";")
        local function getShowValue(id)
            for key, value in pairs(pro) do
                local data = utils.stringSplit(value, "_")
                if data[1] == id then
                    return data[2]
                end
            end
            return 0
        end

        if thingData then
            for key, value in pairs(proShow) do
                textName[key]:setString(fightPropName[tostring(value)].name .. "：" .. getShowValue(value))
            end
            if strengthen then
                if nextData then
                    local pro1 = utils.stringSplit(nextData.fightPropValueList, ";")
                    local function getShowValue1(id)
                        for key, value in pairs(pro1) do
                            local data = utils.stringSplit(value, "_")
                            if data[1] == id then
                                return data[2]
                            end
                        end
                        return 0
                    end

                    for i = 1, 8 do
                        local text_add = proPanel:getChildByName("text_add" .. i)
                        if i <= #proShow then
                            text_add:setVisible(true)
                            text_add:setString("+" ..(getShowValue1(proShow[i]) - getShowValue(proShow[i])))
                        else
                            text_add:setVisible(false)
                        end
                    end
                else
                    for i = 1, 8 do
                        local text_add = proPanel:getChildByName("text_add" .. i)
                        text_add:setVisible(false)
                    end
                end
            elseif advance then
                if nextData then
                    local function inShow(id)
                        for key, value in pairs(proShow) do
                            if value == id then
                                return true
                            end
                        end
                        return false
                    end
                    local pro1 = utils.stringSplit(nextData.openFightPropIdList, ";")
                    for key, value in pairs(pro1) do
                        local data = utils.stringSplit(value, "_")
                        if not inShow(data[1]) then
                            textName[key]:setTextColor(cc.c3b(18, 239, 18))
                            textName[key]:setString(fightPropName[tostring(value)].name .. "：" .. getShowValue(value))
                        else
                            textName[key]:setTextColor(cc.c3b(255, 255, 255))
                        end
                    end
                else
                    for i = 1, 8 do
                        textName[i]:setTextColor(cc.c3b(255, 255, 255))
                    end
                end
            end
        end
    end
    return thingData, advanceData, proShow
end
-- 翅膀
function utils.addArmature(node, uiAnimId, uiAnimName, positionX, positionY, zOrder, scale)
    if node:getChildByName("wing") then
        node:getChildByName("wing"):removeFromParent()
    end
    local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
    --    if uiAnimId == 55 then
    --        for i = 1 , 2 do
    --            animation:getBone("chi_01_lei"..i):addDisplay(ccs.Skin:create("image/chibang_big_lei"..i..".png"), 0)
    --            animation:getBone("chi_01_guang"..i):addDisplay(ccs.Skin:create("image/chibang_big_guang"..i..".png"), 0)
    --            animation:getBone("chi_01_feng"..i):addDisplay(ccs.Skin:create("image/chibang_big_feng"..i..".png"), 0)
    --            animation:getBone("chi_01_an"..i):addDisplay(ccs.Skin:create("image/chibang_big_an"..i..".png"), 0)
    --        end
    --    end
    animation:getAnimation():play("ui_anim" .. uiAnimId .. "_" .. uiAnimName)
    animation:setPosition(cc.p(positionX, positionY))
    animation:setName("wing")
    if scale then
        animation:setScale(scale)
    end
    node:addChild(animation, zOrder)
    return animation
end

function utils.recursionTab(t, kkk)
    for key, value in pairs(t) do
        if type(value) == "table" then
            utils.recursionTab(value, kkk .. "." .. tostring(key))
        else
            print(kkk .. "." .. tostring(key) .. "=" .. tostring(value or ""))
        end
    end
end

utils.getPlayerBaseProp = {
    __index = function() return 0 end,
    [StaticPlayerBaseProp.gold] = function()
        return net.InstPlayer.int["5"]
    end,
    [StaticPlayerBaseProp.copper] = function()
        return tonumber(net.InstPlayer.string["6"])
    end,
    [StaticPlayerBaseProp.exp] = function()
        return net.InstPlayer.int["7"]
    end,
    [StaticPlayerBaseProp.culture] = function()
        return net.InstPlayer.int["21"]
    end,
    [StaticPlayerBaseProp.prestige] = function()
        return net.InstPlayer.int["39"]
    end,
    [StaticPlayerBaseProp.level] = function()
        return net.InstPlayer.int["4"]
    end,
    [StaticPlayerBaseProp.offer] = function()
        return net.InstUnionMember.int["5"]
    end
}

function utils.getSimpleEquipmentCount(id)
    local count = 0
    if net.InstPlayerEquip then
        for key, obj in pairs(net.InstPlayerEquip) do
            if obj.int["4"] == id and obj.int["5"] == 0 and obj.int["6"] == 0 and obj.int["7"] == 0 and obj.int["8"] == 0 then
                count = count + 1
            end
        end
    end
    return count
end

function utils.getSimpleCardCount(cardId, qualityId)
    local count = 0
    if net.InstPlayerCard then
        for key, obj in pairs(net.InstPlayerCard) do
            if obj.int["3"] == cardId and obj.int["4"] == qualityId and obj.int["10"] == 0 and obj.int["15"] == 0 and obj.int["8"] == 0 and obj.int["9"] == 1 and obj.int["5"] == 1 then
                count = count + 1
            end
        end
    end
    return count
end

function utils.getCardSoulCount(cardSoulId)
    local count = 0
    if net.InstPlayerCardSoul then
        for key, obj in pairs(net.InstPlayerCardSoul) do
            if cardSoulId == obj.int["4"] then
                count = obj.int["5"]
                break
            end
        end
    end
    return count
end

function utils.getChipCount(chipId)
    local count = 0
    if net.InstPlayerChip then
        for key, obj in pairs(net.InstPlayerChip) do
            if obj.int["3"] == chipId then
                count = obj.int["4"]
                break
            end
        end
    end
    return count
end

function utils.getSimpleMagicCount(magicId)
    local count = 0
    if net.InstPlayerMagic then
        for key, obj in pairs(net.InstPlayerMagic) do
            if obj.int["3"] == magicId and obj.int["8"] == 0 and obj.int["7"] == 0 then
                count = count + 1
            end
        end
    end
    return count
end

function utils.getYFireChipCount(fireId)
    local count = 0
    if net.InstPlayerYFire then
        for key, obj in pairs(net.InstPlayerYFire) do
            if obj.int["3"] == fireId then
                count = obj.int["9"]
                break
            end
        end
    end
    return count
end

function utils.getSimpleWingCount(wingId)
    local count = 0
    if net.InstPlayerWing then
        for key, obj in pairs(net.InstPlayerWing) do
            if obj.int["3"] == wingId and obj.int["6"] == 0 and obj.int["5"] == 0 and obj.int["4"] == 0 then
                count = count + 1
            end
        end
    end
    return count
end

function utils.getSimpleFightSoulCount(fightSoulId)
    local count = 0
    if net.InstPlayerFightSoul then
        for key, obj in pairs(net.InstPlayerFightSoul) do
            if obj.int["3"] == fightSoulId and obj.int["5"] == 1 and obj.int["6"] == 0 and obj.int["7"] == 0 and obj.int["9"] == 0 then
                count = count + 1
            end
        end
    end
    return count
end
function utils.guangGao()
    local function getTaskDay()
        local _tempTime = utils.stringSplit(net.InstPlayer.registerTime, " ")
        local _registerTime = utils.GetTimeByDate(_tempTime[1] .. " 00:00:00")
        local _curTime = utils.getCurrentTime()
        local _taskDayNum = 0
        for i = 1, 7 do
            if _curTime >= _registerTime +((i - 1) * 24 * 60 * 60) then
                if i > _taskDayNum then
                    _taskDayNum = i
                end
            end
        end
        if _taskDayNum == 0 then
            _taskDayNum = 8
        end
        return _taskDayNum
    end
    local vipLevel = net.InstPlayer.int["19"]
    if getTaskDay() < 7 then
        UIManager.pushScene("ui_poster_begin")
--    elseif vipLevel == 0 then
--        UIManager.pushScene("ui_poster_recharge")
    else 
        UIManager.pushScene("ui_activity_hint")
    end
end

