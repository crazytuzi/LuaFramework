require "luascript/script/game/scene/gamedialog/activityAndNote/activityDialog"
activityVoApi = {
    init = false, -- 是否已经初始化过数据
    newNum = 0,
    allActivity = {},
    
    callbackNum = 0,
}

function activityVoApi:requireByType(type)
    if type and type ~= "" then
        local arr = Split(type, "_")
        type = arr[1]
    end
    if type == "discount" then
        require "luascript/script/game/gamemodel/activity/acDiscountVo"
        require "luascript/script/game/gamemodel/activity/acDiscountVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDiscountDialog"
    elseif type == "moscowGambling" then
        require "luascript/script/game/gamemodel/activity/acMoscowGamblingVo"
        require "luascript/script/game/gamemodel/activity/acMoscowGamblingVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/lotteryDialog"
    elseif type == "moscowGamblingGai" then
        require "luascript/script/game/gamemodel/activity/acMoscowGamblingGaiVo"
        require "luascript/script/game/gamemodel/activity/acMoscowGamblingGaiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMoscowGamblingGaiDialog"
    elseif type == "firstRecharge" then
        require "luascript/script/game/gamemodel/activity/acFirstRechargeVo"
        require "luascript/script/game/gamemodel/activity/acFirstRechargeVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFirstRechargeDialog"
    elseif type == "fbReward" then
        require "luascript/script/game/gamemodel/activity/acFbRewardVo"
        require "luascript/script/game/gamemodel/activity/acFbRewardVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFbRewardDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFbRewardTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFbRewardTab2"
    elseif type == "dayRecharge" then
        require "luascript/script/game/gamemodel/activity/acDayRechargeVo"
        require "luascript/script/game/gamemodel/activity/acDayRechargeVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDayRechargeDialog"
    elseif type == "dayRechargeForEquip" then
        require "luascript/script/game/gamemodel/activity/acDayRechargeForEquipVo"
        require "luascript/script/game/gamemodel/activity/acDayRechargeForEquipVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDayRechargeForEquipDialog"
    elseif type == "fightRank" then
        require "luascript/script/game/gamemodel/activity/acFightRankVo"
        require "luascript/script/game/gamemodel/activity/acFightRankVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFightRankDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFightRankTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFightRankTab2"
    elseif type == "baseLeveling" then
        require "luascript/script/game/gamemodel/activity/acBaseLevelingVo"
        require "luascript/script/game/gamemodel/activity/acBaseLevelingVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBaseLevelingDialog"
    elseif type == "wheelFortune" then
        require "luascript/script/game/gamemodel/activity/acRouletteVo"
        require "luascript/script/game/gamemodel/activity/acRouletteVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRouletteDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRouletteDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRouletteDialogTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRouletteDialogTab3"
    elseif type == "allianceLevel" then
        require "luascript/script/game/gamemodel/activity/acAllianceLevelVo"
        require "luascript/script/game/gamemodel/activity/acAllianceLevelVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceLevelDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceLevelTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceLevelTab2"
    elseif type == "allianceFight" then
        require "luascript/script/game/gamemodel/activity/acAllianceFightVo"
        require "luascript/script/game/gamemodel/activity/acAllianceFightVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceFightDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceFightTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceFightTab2"
    elseif type == "personalHonor" then
        require "luascript/script/game/gamemodel/activity/acPersonalHonorVo"
        require "luascript/script/game/gamemodel/activity/acPersonalHonorVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPersonalHonorDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPersonalHonorTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPersonalHonorTab2"
    elseif type == "personalCheckPoint" then
        require "luascript/script/game/gamemodel/activity/acPersonalCheckPointVo"
        require "luascript/script/game/gamemodel/activity/acPersonalCheckPointVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPersonalCheckPointDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPersonalCheckPointTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPersonalCheckPointTab2"
    elseif type == "totalRecharge" then
        require "luascript/script/game/gamemodel/activity/acTotalRechargeVo"
        require "luascript/script/game/gamemodel/activity/acTotalRechargeVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTotalRechargeDialog"
    elseif type == "totalRecharge2" then
        require "luascript/script/game/gamemodel/activity/acTotalRecharge2Vo"
        require "luascript/script/game/gamemodel/activity/acTotalRecharge2VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTotalRecharge2Dialog"
    elseif type == "allianceHonor" then
        require "luascript/script/game/gamemodel/activity/acAllianceHonorVo"
        require "luascript/script/game/gamemodel/activity/acAllianceHonorVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceHonorDialog"
    elseif type == "crystalHarvest" then
        require "luascript/script/game/gamemodel/activity/acCrystalYieldVo"
        require "luascript/script/game/gamemodel/activity/acCrystalYieldVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCrystalYieldDialog"
    elseif type == "equipSearch" then
        require "luascript/script/game/gamemodel/activity/acEquipSearchVo"
        require "luascript/script/game/gamemodel/activity/acEquipSearchVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEquipSearchDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEquipSearchTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEquipSearchTab2"
    elseif type == "rechargeRebate" then
        require "luascript/script/game/gamemodel/activity/acRechargeRebateVo"
        require "luascript/script/game/gamemodel/activity/acRechargeRebateVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRechargeRebateDialog"
    elseif type == "customRechargeRebate" then --定制化充值返利 日本
        require "luascript/script/game/gamemodel/activity/acCustomRechargeRebateVo"
        require "luascript/script/game/gamemodel/activity/acCustomRechargeRebateVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCustomRechargeRebateDialog"
    elseif type == "monsterComeback" then
        require "luascript/script/game/gamemodel/activity/acMonsterComebackVo"
        require "luascript/script/game/gamemodel/activity/acMonsterComebackVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMonsterComebackDialog"
    elseif type == "growingPlan" then
        require "luascript/script/game/gamemodel/activity/acGrowingPlanVo"
        require "luascript/script/game/gamemodel/activity/acGrowingPlanVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGrowingPlanDialog"
    elseif type == "harvestDay" then
        require "luascript/script/game/gamemodel/activity/acHarvestDayVo"
        require "luascript/script/game/gamemodel/activity/acHarvestDayVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHarvestDayDialog"
    elseif type == "oldUserReturn" then
        require "luascript/script/game/gamemodel/activity/acReturnVo"
        require "luascript/script/game/gamemodel/activity/acReturnVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acReturnDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acReturnDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acReturnDialogTab2"
    elseif type == "accessoryEvolution" then
        require "luascript/script/game/gamemodel/activity/acAccessoryUpgradeVo"
        require "luascript/script/game/gamemodel/activity/acAccessoryUpgradeVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAccessoryUpgradeDialog"
    elseif type == "accessoryFight" then
        require "luascript/script/game/gamemodel/activity/acAccessoryFightVo"
        require "luascript/script/game/gamemodel/activity/acAccessoryFightVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAccessoryFightDialog"
    elseif type == "jsss" then
        require "luascript/script/game/gamemodel/activity/acJsysVo"
        require "luascript/script/game/gamemodel/activity/acJsysVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJsysDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJsysDialogTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJsysDialogTabTwo"
    elseif type == "allianceDonate" then
        require "luascript/script/game/gamemodel/activity/acAllianceDonateVo"
        require "luascript/script/game/gamemodel/activity/acAllianceDonateVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceDonateDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceDonateDialogTabIntro"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAllianceDonateDialogTabRank"
    elseif type == "equipSearchII" then
        require "luascript/script/game/gamemodel/activity/acEquipSearchIIVo"
        require "luascript/script/game/gamemodel/activity/acEquipSearchIIVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTreasureOfKafukaDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTreasureOfKafukaTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEquipSearchIIDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEquipSearchIITab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEquipSearchIITab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKafukabaozangDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKafukabaozangTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKafukabaozangTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoRewardTip"
    elseif type == "rechargeDouble" then
        require "luascript/script/game/gamemodel/activity/acRechargeDoubleVo"
        require "luascript/script/game/gamemodel/activity/acRechargeDoubleVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRechargeDoubleDialog"
    elseif type == "vipRight" then
        require "luascript/script/game/gamemodel/activity/acVipRightVo"
        require "luascript/script/game/gamemodel/activity/acVipRightVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acVipRightDialog"
    elseif type == "heartOfIron" then
        require "luascript/script/game/gamemodel/activity/acHeartOfIronVo"
        require "luascript/script/game/gamemodel/activity/acHeartOfIronVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHeartOfIronDialog"
    elseif type == "userFund" then
        require "luascript/script/game/gamemodel/activity/acUserFundVo"
        require "luascript/script/game/gamemodel/activity/acUserFundVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acUserFundDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acUserFundDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acUserFundDialogTab2"
    elseif type == "tendayslogin" then
        require "luascript/script/game/gamemodel/activity/acTenDaysLoginVo"
        require "luascript/script/game/gamemodel/activity/acTenDaysLoginVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTenDaysLoginDialog"
    elseif type == "vipAction" then
        require "luascript/script/game/gamemodel/activity/acVipActionVo"
        require "luascript/script/game/gamemodel/activity/acVipActionVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acVipActionDialog"
    elseif type == "investPlan" then
        require "luascript/script/game/gamemodel/activity/acInvestPlanVo"
        require "luascript/script/game/gamemodel/activity/acInvestPlanVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acInvestPlanDialog"
    elseif type == "hardGetRich" then
        require "luascript/script/game/gamemodel/activity/acHardGetRichVo"
        require "luascript/script/game/gamemodel/activity/acHardGetRichVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHardGetRichDialog"
    elseif type == "wheelFortune4" then
        require "luascript/script/game/gamemodel/activity/acRoulette4Vo"
        require "luascript/script/game/gamemodel/activity/acRoulette4VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette4Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette4DialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette4DialogTab2"
    elseif type == "openGift" then
        require "luascript/script/game/gamemodel/activity/acOpenGiftVo"
        require "luascript/script/game/gamemodel/activity/acOpenGiftVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenGiftDialog"
    elseif type == "wheelFortune2" then
        require "luascript/script/game/gamemodel/activity/acRoulette2Vo"
        require "luascript/script/game/gamemodel/activity/acRoulette2VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette2Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette2DialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette2DialogTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette2DialogTab3"
    elseif type == "wheelFortune3" then
        require "luascript/script/game/gamemodel/activity/acRoulette3Vo"
        require "luascript/script/game/gamemodel/activity/acRoulette3VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette3Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette3DialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette3DialogTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette3DialogTab3"
    elseif type == "stormrocket" then
        require "luascript/script/game/gamemodel/activity/acStormRocketVo"
        require "luascript/script/game/gamemodel/activity/acStormRocketVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acStormRocketDialog"
    elseif type == "grabRed" then
        require "luascript/script/game/gamemodel/activity/acGrabRedVo"
        require "luascript/script/game/gamemodel/activity/acGrabRedVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGrabRedDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGrabRedGrabDialog"
    elseif type == "armsRace" then -- 军备竞赛
        require "luascript/script/componet/recodeDialog"
        require "luascript/script/game/gamemodel/activity/acArmsRaceVo"
        require "luascript/script/game/gamemodel/activity/acArmsRaceVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acArmsRaceDialog"
    elseif type == "slotMachine" then -- 老虎机
        require "luascript/script/game/gamemodel/activity/acSlotMachineVo"
        require "luascript/script/game/gamemodel/activity/acSlotMachineVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSlotMachineDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSlotMachineExchangeDialog"
    elseif type == "slotMachine2" then -- 老虎机
        require "luascript/script/game/gamemodel/activity/acSlotMachine2Vo"
        require "luascript/script/game/gamemodel/activity/acSlotMachine2VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSlotMachine2Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSlotMachineExchange2Dialog"
    elseif type == "customLottery" then -- 老虎机
        require "luascript/script/game/gamemodel/activity/acCustomLotteryVo"
        require "luascript/script/game/gamemodel/activity/acCustomLotteryVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCustomLotteryDialog"
    elseif type == "customLottery1" then -- 日本平台老虎机
        require "luascript/script/game/gamemodel/activity/acCustomLotteryOneVo"
        require "luascript/script/game/gamemodel/activity/acCustomLotteryOneVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCustomLotteryOneDialog"
    elseif type == "slotMachineCommon" then -- 幸运抽奖
        require "luascript/script/game/gamemodel/activity/acSlotMachineCommonVo"
        require "luascript/script/game/gamemodel/activity/acSlotMachineCommonVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSlotMachineCommonDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSlotMachineExchangeCommonDialog"
    elseif type == "shareHappiness" then -- 有福同享
        require "luascript/script/game/gamemodel/activity/acShareHappinessVo"
        require "luascript/script/game/gamemodel/activity/acShareHappinessVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShareHappinessDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShareHappinessTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShareHappinessTab2"
    elseif type == "holdGround" then -- 坚守阵地
        require "luascript/script/game/gamemodel/activity/acHoldGroundVo"
        require "luascript/script/game/gamemodel/activity/acHoldGroundVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHoldGroundDialog"
        
    elseif type == "fundsRecruit" then --军团招募
        require "luascript/script/game/gamemodel/activity/acFundsRecruitVo"
        require "luascript/script/game/gamemodel/activity/acFundsRecruitVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFundsRecruitDialog"
    elseif type == "continueRecharge" then --连续充值领大礼
        require "luascript/script/game/gamemodel/activity/acContinueRechargeVo"
        require "luascript/script/game/gamemodel/activity/acContinueRechargeVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acContinueRechargeDialog"
    elseif type == "lxcz" then --连续充值领大礼
        require "luascript/script/game/gamemodel/activity/acContinueRechargeNewGuidVo"
        require "luascript/script/game/gamemodel/activity/acContinueRechargeNewGuidVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acContinueRechargeNewGuidDialog"
    elseif type == "rewardingBack" then --满载而归
        require "luascript/script/game/gamemodel/activity/acRewardingBackVo"
        require "luascript/script/game/gamemodel/activity/acRewardingBackVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRewardingBackDialog"
        
    elseif type == "armamentsUpdate1" or type == "armamentsUpdate2" then --军备换代
        require "luascript/script/game/gamemodel/activity/acArmamentsUpdateVo"
        require "luascript/script/game/gamemodel/activity/acArmamentsUpdateVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acArmamentsUpdateDialog"
        if type == "armamentsUpdate1" then
            require "luascript/script/game/scene/gamedialog/activityAndNote/acArmamentsUpdateDialog1"
        else
            require "luascript/script/game/scene/gamedialog/activityAndNote/acArmamentsUpdateDialog2"
        end
    elseif type == "miBao" then -- 秘宝探寻
        require "luascript/script/game/gamemodel/activity/acMiBaoVo"
        require "luascript/script/game/gamemodel/activity/acMiBaoVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMiBaoDialog"
    elseif type == "leveling" then -- 冲级三重奏
        require "luascript/script/game/gamemodel/activity/acLevelingVo"
        require "luascript/script/game/gamemodel/activity/acLevelingVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLevelingDialog"
    elseif type == "leveling2" then -- 冲级三重奏
        require "luascript/script/game/gamemodel/activity/acLeveling2Vo"
        require "luascript/script/game/gamemodel/activity/acLeveling2VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLeveling2Dialog"
    elseif type == "holdGround1" then -- 新兵军饷，坚守阵地改配置
        require "luascript/script/game/gamemodel/activity/acHoldGround1Vo"
        require "luascript/script/game/gamemodel/activity/acHoldGround1VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHoldGround1Dialog"
    elseif type == "autumnCarnival" then -- 中秋狂欢
        require "luascript/script/game/gamemodel/activity/acAutumnCarnivalVo"
        require "luascript/script/game/gamemodel/activity/acAutumnCarnivalVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAutumnCarnivalDialog"
    elseif type == "luckUp" then -- 周末狂欢
        require "luascript/script/game/gamemodel/activity/acLuckUpVo"
        require "luascript/script/game/gamemodel/activity/acLuckUpVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLuckUpDialog"
    elseif type == "republicHui" then -- 共和国之辉
        require "luascript/script/game/gamemodel/activity/acRepublicHuiVo"
        require "luascript/script/game/gamemodel/activity/acRepublicHuiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRepublicHuiDialog"
        
    elseif type == "calls" then -- 战地通讯
        require "luascript/script/game/gamemodel/activity/acCallsVo"
        require "luascript/script/game/gamemodel/activity/acCallsVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCallsDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCallsExchangeDialog"
        
    elseif type == "newTech" then -- 技术革新
        require "luascript/script/game/gamemodel/activity/acNewTechVo"
        require "luascript/script/game/gamemodel/activity/acNewTechVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewTechDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewTechTab"
    elseif type == "nationalCampaign" then -- 国庆攻势
        require "luascript/script/game/gamemodel/activity/acNationalCampaignVo"
        require "luascript/script/game/gamemodel/activity/acNationalCampaignVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNationalCampaignDialog"
    elseif type == "ghostWars" then -- 驱鬼大战
        require "luascript/script/game/gamemodel/activity/acGhostWarsVo"
        require "luascript/script/game/gamemodel/activity/acGhostWarsVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGhostWarsDialog"
    elseif type == "doorGhost" then -- 驱鬼大战
        require "luascript/script/game/gamemodel/activity/acDoorGhostVo"
        require "luascript/script/game/gamemodel/activity/acDoorGhostVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDoorGhostDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDoorGhostTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDoorGhostTab2"
    elseif type == "refitPlanT99" then -- 改装计划——T99
        require "luascript/script/game/gamemodel/activity/acRefitPlanVo"
        require "luascript/script/game/gamemodel/activity/acRefitPlanVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRefitPlanDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRefitPlanDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRefitPlanDialogTab2"
    elseif type == "preparingPeak" then -- 备战巅峰
        require "luascript/script/game/gamemodel/activity/acPreparingPeakVo"
        require "luascript/script/game/gamemodel/activity/acPreparingPeakVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPreparingPeakDialog"
    elseif type == "singles" then -- 脱光行动
        require "luascript/script/game/gamemodel/activity/acSinglesVo"
        require "luascript/script/game/gamemodel/activity/acSinglesVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSinglesDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSinglesTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSinglesTab2"
    elseif type == "cuikulaxiu" then -- 摧枯拉朽
        require "luascript/script/game/gamemodel/activity/acCuikulaxiuVo"
        require "luascript/script/game/gamemodel/activity/acCuikulaxiuVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCuikulaxiuDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCuikulaxiuTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCuikulaxiuTab2"
    elseif type == "jidongbudui" then -- "鸡"动部队
        require "luascript/script/game/gamemodel/activity/acJidongbuduiVo"
        require "luascript/script/game/gamemodel/activity/acJidongbuduiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJidongbuduiDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJidongbuduiTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJidongbuduiTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJidongbuduiRecord"
    elseif type == "baifudali" then
        require "luascript/script/game/gamemodel/activity/acBaifudaliVo"
        require "luascript/script/game/gamemodel/activity/acBaifudaliVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBaifudaliDialog"
    elseif type == "feixutansuo" then -- 改装计划——T99
        require "luascript/script/game/gamemodel/activity/acFeixutansuoVo"
        require "luascript/script/game/gamemodel/activity/acFeixutansuoVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoRewardTip"
        
    elseif type == "kuangnuzhishi" then -- 摧枯拉朽
        require "luascript/script/game/gamemodel/activity/acKuangnuzhishiVo"
        require "luascript/script/game/gamemodel/activity/acKuangnuzhishiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKuangnuzhishiDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKuangnuzhishiTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKuangnuzhishiTab2"
    elseif type == "zhenqinghuikui" then --坦克轮盘（ 飞流 ）
        require "luascript/script/game/gamemodel/activity/acRoulette5Vo"
        require "luascript/script/game/gamemodel/activity/acRoulette5VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette5Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette5Tab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRoulette5Tab2"
    elseif type == "shengdanbaozang" then
        require "luascript/script/game/gamemodel/activity/acShengdanbaozangVo"
        require "luascript/script/game/gamemodel/activity/acShengdanbaozangVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShengdanbaozangDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShengdanbaozangTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShengdanbaozangTab2"
    elseif type == "shengdankuanghuan" then
        require "luascript/script/game/gamemodel/activity/acShengdankuanghuanVo"
        require "luascript/script/game/gamemodel/activity/acShengdankuanghuanVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShengdankuanghuanDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShengdankuanghuanTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShengdankuanghuanTab2"
    elseif type == "yuandanxianli" then --元旦献礼
        require "luascript/script/game/gamemodel/activity/acYuandanxianliVo"
        require "luascript/script/game/gamemodel/activity/acYuandanxianliVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYuandanxianliDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYuandanxianliDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYuandanxianliDialogTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYuandanxianliDialogTab3"
        
    elseif type == "onlineReward" then
        require "luascript/script/game/gamemodel/activity/acOnlineRewardVo"
        require "luascript/script/game/gamemodel/activity/acOnlineRewardVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOnlineRewardDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoRewardTip"
    elseif type == "online2018" then
        require "luascript/script/game/gamemodel/activity/acOnlineRewardXVIIIVo"
        require "luascript/script/game/gamemodel/activity/acOnlineRewardXVIIIVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOnlineRewardXVIIIDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoRewardTip"
    elseif type == "tankjianianhua" then -- 坦克嘉年华
        require "luascript/script/game/gamemodel/activity/acTankjianianhuaVo"
        require "luascript/script/game/gamemodel/activity/acTankjianianhuaVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTankjianianhuaDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTankjianianhuaExplain"
    elseif type == "xuyuanlu" then -- 许愿炉
        require "luascript/script/game/gamemodel/activity/acXuyuanluVo"
        require "luascript/script/game/gamemodel/activity/acXuyuanluVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXuyuanluDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXuyuanluTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXuyuanluTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXuyuanluHistory"
    elseif type == "shuijinghuikui" then -- 水晶回馈
        require "luascript/script/game/gamemodel/activity/acShuijinghuikuiVo"
        require "luascript/script/game/gamemodel/activity/acShuijinghuikuiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acShuijinghuikuiDialog"
        
    elseif type == "xinchunhongbao" then -- 新春红包
        require "luascript/script/game/gamemodel/activity/acXinchunhongbaoVo"
        require "luascript/script/game/gamemodel/activity/acXinchunhongbaoVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXinchunhongbaoDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXinchunhongbaoSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoRewardTip"
    elseif type == "huoxianmingjiang" then -- 火线名将
        require "luascript/script/game/gamemodel/activity/acHuoxianmingjiangVo"
        require "luascript/script/game/gamemodel/activity/acHuoxianmingjiangVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangDialog"
    elseif type == "junzipaisong" then --军资派送
        require "luascript/script/game/gamemodel/activity/acJunzipaisongVo"
        require "luascript/script/game/gamemodel/activity/acJunzipaisongVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJunzipaisongDialog"
    elseif type == "chongzhiyouli" then
        require "luascript/script/game/gamemodel/activity/acChongZhiYouLiVo"
        require "luascript/script/game/gamemodel/activity/acChongZhiYouLiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChongZhiYouLiDialog"
    elseif type == "junshijiangtan" then --军事学院
        require "luascript/script/game/gamemodel/activity/acJunshijiangtanVo"
        require "luascript/script/game/gamemodel/activity/acJunshijiangtanVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJunshijiangtanDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJunshijiangtanTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJunshijiangtanTab2"
    elseif type == "songjiangling" then
        require "luascript/script/game/gamemodel/activity/acSendGeneralVo"
        require "luascript/script/game/gamemodel/activity/acSendGeneralVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSendGeneralDialog"
    elseif type == "huoxianmingjianggai" then
        require "luascript/script/game/gamemodel/activity/acMingjiangVo"
        require "luascript/script/game/gamemodel/activity/acMingjiangVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangTab2"
    elseif type == "xingyunzhuanpan" then
        require "luascript/script/game/gamemodel/activity/acMayDayVo"
        require "luascript/script/game/gamemodel/activity/acMayDayVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMayDayDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMayDayTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMayDayTab2"
    elseif type == "taibumperweek" then
        require "luascript/script/game/gamemodel/activity/acTitaniumOfharvestVo"
        require "luascript/script/game/gamemodel/activity/acTitaniumOfharvestVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTitaniumOfharvestDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTitaniumOfharvestTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTitaniumOfharvestTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTitaniumOfharvestTab3"
    elseif type == "banzhangshilian" then
        require "luascript/script/game/gamemodel/activity/acBanzhangshilianVo"
        require "luascript/script/game/gamemodel/activity/acBanzhangshilianVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBanzhangshilianDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBanzhangshilianTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBanzhangshilianTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBanzhangshilianChapterDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBanzhangshilianFullStarRankDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBanzhangshilianSetTroopsDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBanzhangshilianTroopsInfoDialog"
    elseif type == "hongchangyuebing" then
        require "luascript/script/game/gamemodel/activity/acHongchangyuebingVo"
        require "luascript/script/game/gamemodel/activity/acHongchangyuebingVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHongchangyuebingDialog"
    elseif type == "huiluzaizao" then
        require "luascript/script/game/gamemodel/activity/acRecyclingVo"
        require "luascript/script/game/gamemodel/activity/acRecyclingVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRecyclingDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRecyclingTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRecyclingTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRecyclingTab3"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoRewardTip"
    elseif type == "yunxingjianglin" then
        require "luascript/script/game/gamemodel/activity/acMeteoriteLandingVo"
        require "luascript/script/game/gamemodel/activity/acMeteoriteLandingVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMeteoriteLandingDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMeteoriteLandingTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMeteoriteLandingTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMeteoriteLandingTab3"
    elseif type == "tianjiangxiongshi" then
        require "luascript/script/game/gamemodel/activity/acTianjiangxiongshiVo"
        require "luascript/script/game/gamemodel/activity/acTianjiangxiongshiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTianjiangxiongshiDialog"
    elseif type == "kafkagift" then
        require "luascript/script/game/gamemodel/activity/acKafkaGiftVo"
        require "luascript/script/game/gamemodel/activity/acKafkaGiftVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKafkaGiftDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKafkaGiftSmallDialog"
    elseif type == "quanmintanke" then
        require "luascript/script/game/gamemodel/activity/acQuanmintankeVo"
        require "luascript/script/game/gamemodel/activity/acQuanmintankeVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQuanmintankeNewDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQuanmintankeDialog"
        
    elseif type == "alienbumperweek" then--异星资源丰收周
        require "luascript/script/game/gamemodel/activity/acAlienbumperweekVo"
        require "luascript/script/game/gamemodel/activity/acAlienbumperweekVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAlienbumperweekDialog"
    elseif type == "diancitanke" then
        require "luascript/script/game/gamemodel/activity/acDiancitankeVo"
        require "luascript/script/game/gamemodel/activity/acDiancitankeVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDiancitankeDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDiancitankeTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDiancitankeTab2"
    elseif type == "ydjl2" then
        require "luascript/script/game/gamemodel/activity/acYueduHeroTwoVo"
        require "luascript/script/game/gamemodel/activity/acYueduHeroTwoVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYueduHeroTwoDialog"
    elseif type == "yuedujiangling" then
        require "luascript/script/game/gamemodel/activity/acYueduHeroVo"
        require "luascript/script/game/gamemodel/activity/acYueduHeroVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYueduHeroDialog"
    elseif type == "twohero" then
        require "luascript/script/game/gamemodel/activity/acHeroGiftVo"
        require "luascript/script/game/gamemodel/activity/acHeroGiftVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHeroGiftDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHeroGiftTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHeroGiftTab2"
    elseif type == "sendaccessory" then -- 配件赠送
        require "luascript/script/game/gamemodel/activity/acPeijianhuzengVo"
        require "luascript/script/game/gamemodel/activity/acPeijianhuzengVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPeijianhuzengDialog"
    elseif type == "xingyunpindian" then -- 幸运拼点
        require "luascript/script/game/gamemodel/activity/acXingyunpindianVo"
        require "luascript/script/game/gamemodel/activity/acXingyunpindianVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXingyunpindianDialog"
    elseif type == "gangtieronglu" then
        require "luascript/script/game/gamemodel/activity/acGangtierongluVo"
        require "luascript/script/game/gamemodel/activity/acGangtierongluVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGangtierongluDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGangtierongluTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGangtierongluTab2"
    elseif type == "xiaofeisongli" then -- 累计消费送好礼
        require "luascript/script/game/gamemodel/activity/acXiaofeisongliVo"
        require "luascript/script/game/gamemodel/activity/acXiaofeisongliVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliSmallDialog2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
    elseif type == "haoshichengshuang" then
        require "luascript/script/game/gamemodel/activity/acHaoshichengshuangVo"
        require "luascript/script/game/gamemodel/activity/acHaoshichengshuangVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHaoshichengshuangDialog"
    elseif type == "swchallengeactive" then--能量大放送
        require "luascript/script/game/gamemodel/activity/acSwchallengeactiveVo"
        require "luascript/script/game/gamemodel/activity/acSwchallengeactiveVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSwchallengeactiveDialog"
    elseif type == "ybsc" then
        require "luascript/script/game/gamemodel/activity/acYuebingshenchaVo"
        require "luascript/script/game/gamemodel/activity/acYuebingshenchaVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYuebingshenchaDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYuebingshenchaTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYuebingshenchaTab2"
    elseif type == "chongzhisongli" then -- 累计充值送好礼
        require "luascript/script/game/gamemodel/activity/acChongzhisongliVo"
        require "luascript/script/game/gamemodel/activity/acChongzhisongliVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChongzhisongliDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliSmallDialog2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
    elseif type == "danrichongzhi" then -- 单日充值
        require "luascript/script/game/gamemodel/activity/acDanrichongzhiVo"
        require "luascript/script/game/gamemodel/activity/acDanrichongzhiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDanrichongzhiDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliSmallDialog2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
    elseif type == "mrcz" then --每日充值送好礼（新人绑定版）
        require "luascript/script/game/gamemodel/activity/acDailyRechargeByNewGuiderVo"
        require "luascript/script/game/gamemodel/activity/acDailyRechargeByNewGuiderVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDailyRechargeByNewGuiderDialog"
    elseif type == "danrixiaofei" then -- 单日消费
        require "luascript/script/game/gamemodel/activity/acDanrixiaofeiVo"
        require "luascript/script/game/gamemodel/activity/acDanrixiaofeiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDanrixiaofeiDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXiaofeisongliSmallDialog2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
    elseif type == "jiejingkaicai" then
        require "luascript/script/game/gamemodel/activity/acJiejingkaicaiVo"
        require "luascript/script/game/gamemodel/activity/acJiejingkaicaiVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJiejingkaicaiDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJiejingkaicaiSmallDialog"
    elseif type == "jffp" then -- 积分翻盘
        require "luascript/script/game/gamemodel/activity/acJffpVo"
        require "luascript/script/game/gamemodel/activity/acJffpVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJffpDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJffpTaskDialog"
    elseif type == "firstRechargenew" then -- 新的首冲送豪礼
        require "luascript/script/game/gamemodel/activity/acFirstRechargenewVo"
        require "luascript/script/game/gamemodel/activity/acFirstRechargenewVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFirstRechargenewDialog"
    elseif type == "fightRanknew" then
        require "luascript/script/game/gamemodel/activity/acFightRanknewVo"
        require "luascript/script/game/gamemodel/activity/acFightRanknewVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFightRanknewDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFightRanknewTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFightRanknewTab2"
    elseif type == "challengeranknew" then
        require "luascript/script/game/gamemodel/activity/acChallengeranknewVo"
        require "luascript/script/game/gamemodel/activity/acChallengeranknewVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChallengeranknewDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChallengeranknewTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChallengeranknewTab2"
    elseif type == "yongwangzhiqian" then
        require "luascript/script/game/gamemodel/activity/acMoveForwardVo"
        require "luascript/script/game/gamemodel/activity/acMoveForwardVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMoveForwardDialog"
    elseif type == "ywzq" then
        require "luascript/script/game/gamemodel/activity/acYwzqVo"
        require "luascript/script/game/gamemodel/activity/acYwzqVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYwzqDialog"
    elseif type == "xinfulaba" then -- 积分翻盘
        require "luascript/script/game/gamemodel/activity/acLuckyCatVo"
        require "luascript/script/game/gamemodel/activity/acLuckyCatVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLuckyCatDialog"
    elseif type == "double11new" then
        require "luascript/script/game/gamemodel/activity/acDouble11NewVo"
        require "luascript/script/game/gamemodel/activity/acDouble11NewVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11NewTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11NewTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11NewTab3"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11NewDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11NewSellDialog"
    elseif type == "double11" then
        require "luascript/script/game/gamemodel/activity/acDouble11Vo"
        require "luascript/script/game/gamemodel/activity/acDouble11VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11Tab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11Tab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11SellDialog"
    elseif type == "new112018" then
        require "luascript/script/game/gamemodel/activity/acDoubleOneVo"
        require "luascript/script/game/gamemodel/activity/acDoubleOneVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDoubleOneTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDoubleOneTabTwo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDoubleOneDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDoubleOneSellDialog"
    elseif type == "halloween" then
        require "luascript/script/game/gamemodel/activity/acSweetTroubleVo"
        require "luascript/script/game/gamemodel/activity/acSweetTroubleVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSweetTroubleDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSweetTroubleTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSweetTroubleTab2"
    elseif type == "twolduserreturn" then
        require "luascript/script/game/gamemodel/activity/acOldReturnVo"
        require "luascript/script/game/gamemodel/activity/acOldReturnVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOldReturnDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOldReturnDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOldReturnDialogTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOldReturnDialogTab3"
    elseif type == "wanshengjiedazuozhan" then -- 万圣节大作战
        require "luascript/script/game/gamemodel/activity/acWanshengjiedazuozhanVo"
        require "luascript/script/game/gamemodel/activity/acWanshengjiedazuozhanVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWanshengjiedazuozhanDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWanshengjiedazuozhanTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWanshengjiedazuozhanTab2"
    elseif type == "zhanshuyantao" then --战术研讨
        require "luascript/script/game/gamemodel/activity/acTacticalDiscussVo"
        require "luascript/script/game/gamemodel/activity/acTacticalDiscussVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTacticalDiscussDialog"
    elseif type == "yijizaitan" then -- 遗迹再探
        require "luascript/script/game/gamemodel/activity/acYijizaitanVo"
        require "luascript/script/game/gamemodel/activity/acYijizaitanVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYijizaitanDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYijizaitanTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYijizaitanTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoRewardTip"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYijizaitanLogSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYijizaitanTab1New"
    elseif type == "ganenjiehuikui" then--感恩节回馈
        require "luascript/script/game/gamemodel/activity/acThanksGivingVo"
        require "luascript/script/game/gamemodel/activity/acThanksGivingVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThanksGivingDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThanksGivingSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThanksGivingTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThanksGivingTab2"
    elseif type == "christmasfight" then--圣诞节大作战回馈
        require "luascript/script/game/gamemodel/activity/acChristmasFightVo"
        require "luascript/script/game/gamemodel/activity/acChristmasFightVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChristmasFightDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChristmasFightTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChristmasFightTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChristmasFightTab3"
    elseif type == "mingjiangzailin" then
        require "luascript/script/game/gamemodel/activity/acMingjiangzailinVo"
        require "luascript/script/game/gamemodel/activity/acMingjiangzailinVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangzailinDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangzailinRewardSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangzailinLogSmallDialog"
    elseif type == "newyeargift" then --多重好礼庆元旦
        require "luascript/script/game/gamemodel/activity/acNewYearVo"
        require "luascript/script/game/gamemodel/activity/acNewYearVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearSmallDialog"
    elseif type == "tankbattle" then
        require "luascript/script/game/gamemodel/activity/acTankBattleVo"
        require "luascript/script/game/gamemodel/activity/acTankBattleVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTankBattleDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTankBattleStartDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTankBattleEndDialog"
        
    elseif type == "shengdanqianxi" then--圣诞前夕
        require "luascript/script/game/gamemodel/activity/acChrisEveVo"
        require "luascript/script/game/gamemodel/activity/acChrisEveVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChrisEveDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChrisEveSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChrisEveTab3"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChrisEveTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChrisEveTab1"
    elseif type == "newyeareva" then --夕兽降临（除夕之夜）
        require "luascript/script/game/gamemodel/activity/acNewYearsEveVo"
        require "luascript/script/game/gamemodel/activity/acNewYearsEveVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveDialogTab3"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveDialogTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveSmallDialog"
        
    elseif type == "chunjiepansheng" then -- 春节攀升计划
        require "luascript/script/game/gamemodel/activity/acChunjiepanshengVo"
        require "luascript/script/game/gamemodel/activity/acChunjiepanshengVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengTask"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
    elseif type == "smcj" then -- 使劲冲击
        require "luascript/script/game/gamemodel/activity/acSmcjVo"
        require "luascript/script/game/gamemodel/activity/acSmcjVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSmcjDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSmcjTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSmcjTabTwo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSmcjTask"
        -- require "luascript/script/game/scene/gamedialog/activityAndNote/acSmcjSmallDialog"
    elseif type == "hljb" then -- 欢乐聚宝
        require "luascript/script/game/gamemodel/activity/acHljbVo"
        require "luascript/script/game/gamemodel/activity/acHljbVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHljbDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHljbTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHljbTabTwo"
    elseif type == "anniversary" then
        require "luascript/script/game/gamemodel/activity/acAnniversaryVo"
        require "luascript/script/game/gamemodel/activity/acAnniversaryVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryDialog"
    elseif type == "yichujifa" then --一触即发
        require "luascript/script/game/gamemodel/activity/acImminentVo"
        require "luascript/script/game/gamemodel/activity/acImminentVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acImminentDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acImminentSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acImminentTab3"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acImminentTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acImminentTab1"
    elseif type == "koulinghongbao" then
        require "luascript/script/game/gamemodel/activity/acKoulinghongbaoVo"
        require "luascript/script/game/gamemodel/activity/acKoulinghongbaoVoApi"
    elseif type == "rechargeCompetition" then --充值大比拼
        require "luascript/script/game/gamemodel/activity/acRechargeGameVo"
        require "luascript/script/game/gamemodel/activity/acRechargeGameVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRechargeGameDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRechargeGameTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRechargeGameTab2"
    elseif type == "dailyEquipPlan" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDailyEquipPlanDialog"
        require "luascript/script/game/gamemodel/activity/acDailyEquipPlanVo"
        require "luascript/script/game/gamemodel/activity/acDailyEquipPlanVoApi"
    elseif type == "stormFortress" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acStormFortressDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acStormFortressBulletsDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acStormFortressGetRewardDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acStormFortressRewardDialog"
        require "luascript/script/game/gamemodel/activity/acStormFortressVo"
        require "luascript/script/game/gamemodel/activity/acStormFortressVoApi"
    elseif type == "seikoStoneShop" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSeikoStoneShopDialog"
        require "luascript/script/game/gamemodel/activity/acSeikoStoneShopVo"
        require "luascript/script/game/gamemodel/activity/acSeikoStoneShopVoApi"
    elseif type == "anniversaryBless" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessTab2"
        require "luascript/script/game/gamemodel/activity/acAnniversaryBlessVo"
        require "luascript/script/game/gamemodel/activity/acAnniversaryBlessVoApi"
    elseif type == "blessingWheel" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBlessingWheelDialog"
        require "luascript/script/game/gamemodel/activity/acBlessingWheelVo"
        require "luascript/script/game/gamemodel/activity/acBlessingWheelVoApi"
    elseif type == "monthlysign" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMonthlySignDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMonthlySignDialogTabPay"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMonthlySignDialogTabFree"
        require "luascript/script/game/gamemodel/activity/acMonthlySignVo"
        require "luascript/script/game/gamemodel/activity/acMonthlySignVoApi"
    elseif type == "buyreward" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBuyrewardDialog"
        require "luascript/script/game/gamemodel/activity/acBuyrewardVo"
        require "luascript/script/game/gamemodel/activity/acBuyrewardVoApi"
    elseif type == "rechargebag" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRechargeBagDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRechargeBagTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRechargeBagTab2"
        require "luascript/script/game/gamemodel/activity/acRechargeBagVo"
        require "luascript/script/game/gamemodel/activity/acRechargeBagVoApi"
    elseif type == "pjjnh" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPjjnhDialog"
        require "luascript/script/game/gamemodel/activity/acPjjnhVo"
        require "luascript/script/game/gamemodel/activity/acPjjnhVoApi"
    elseif type == "luckcard" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLuckyPokerDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLuckyPokerFrameDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLuckyPokerNewDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLuckyPokerTankReformDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLuckyPokerGetRewardDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLuckyPokerRecordDialog"
        require "luascript/script/game/gamemodel/activity/acLuckyPokerVo"
        require "luascript/script/game/gamemodel/activity/acLuckyPokerVoApi"
    elseif type == "olympic" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOlympicDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOlympicGetRewardDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOlympicRecordDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOlympicAwardRuleDialog"
        require "luascript/script/game/gamemodel/activity/acOlympicVo"
        require "luascript/script/game/gamemodel/activity/acOlympicVoApi"
    elseif type == "benfuqianxian" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBenfuqianxianDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBenfuqianxianTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBenfuqianxianTab2"
        require "luascript/script/game/gamemodel/activity/acBenfuqianxianVo"
        require "luascript/script/game/gamemodel/activity/acBenfuqianxianVoApi"
    elseif type == "aoyunjizhang" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOlympicCollectDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOlympicEventDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOlympicTask"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
        require "luascript/script/game/gamemodel/activity/acOlympicCollectVo"
        require "luascript/script/game/gamemodel/activity/acOlympicCollectVoApi"
    elseif type == "battleplane" then
        require "luascript/script/game/gamemodel/activity/acAntiAirVo"
        require "luascript/script/game/gamemodel/activity/acAntiAirVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAntiAirDialog"
    elseif type == "mingjiangpeiyang" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangDialog"
        require "luascript/script/game/gamemodel/activity/acMingjiangpeiyangVo"
        require "luascript/script/game/gamemodel/activity/acMingjiangpeiyangVoApi"
    elseif type == "midautumn" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMidAutumnDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
        require "luascript/script/game/gamemodel/activity/acMidAutumnVo"
        require "luascript/script/game/gamemodel/activity/acMidAutumnVoApi"
    elseif type == "zhanyoujijie" then
        require "luascript/script/game/gamemodel/activity/acZhanyoujijieVo"
        require "luascript/script/game/gamemodel/activity/acZhanyoujijieVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZhanyoujijieDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZhanyoujijieTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZhanyoujijieTab2"
    elseif type == "threeyear" then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThreeYearDialog"
        require "luascript/script/game/gamemodel/activity/acThreeYearVo"
        require "luascript/script/game/gamemodel/activity/acThreeYearVoApi"
    elseif type == "gqkh" then
        require "luascript/script/config/gameconfig/gqkhCfg"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGqkhDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGqkhTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGqkhTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGqkhSmallDialog"
        require "luascript/script/game/gamemodel/activity/acGqkhVo"
        require "luascript/script/game/gamemodel/activity/acGqkhVoApi"
    elseif type == "wsjdzz" then
        require "luascript/script/game/gamemodel/activity/acWsjdzzVo"
        require "luascript/script/game/gamemodel/activity/acWsjdzzVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWsjdzzDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWsjdzzTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWsjdzzTab2"
    elseif type == "wsjdzz2017" then
        require "luascript/script/game/gamemodel/activity/acWsjdzzIIVo"
        require "luascript/script/game/gamemodel/activity/acWsjdzzIIVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWsjdzzIIDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWsjdzzIITabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWsjdzzIITabTwo"
    elseif type == "mineExplore" then
        require "luascript/script/config/gameconfig/mineExploreCfg"
        require "luascript/script/game/gamemodel/activity/acMineExploreVo"
        require "luascript/script/game/gamemodel/activity/acMineExploreVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreDialog"
    elseif type == "mineExploreG" then
        require "luascript/script/game/gamemodel/activity/acMineExploreGVo"
        require "luascript/script/game/gamemodel/activity/acMineExploreGVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreGDialog"
    elseif type == "gej2016" then
        require "luascript/script/game/gamemodel/activity/acGej2016Vo"
        require "luascript/script/game/gamemodel/activity/acGej2016VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGej2016Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGej2016Tab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGej2016Tab2"
    elseif type == "openyear" then
        require "luascript/script/game/gamemodel/activity/acOpenyearVo"
        require "luascript/script/game/gamemodel/activity/acOpenyearVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenyearDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenyearTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenyearTab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenyearTab3"
    elseif type == "christmas2016" then
        require "luascript/script/game/gamemodel/activity/acChristmasAttireVo"
        require "luascript/script/game/gamemodel/activity/acChristmasAttireVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acChristmasAttireDialog"
    elseif type == "djrecall" then
        require "luascript/script/game/gamemodel/activity/acGeneralRecallVo"
        require "luascript/script/game/gamemodel/activity/acGeneralRecallVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGeneralRecallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGeneralRecallSmallDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGeneralRecallTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGeneralRecallTab2"
    elseif type == "btzx" then
        require "luascript/script/game/gamemodel/activity/acBtzxVo"
        require "luascript/script/game/gamemodel/activity/acBtzxVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBtzxDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBtzxTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBtzxTab2"
    elseif type == "cjyx" then
        require "luascript/script/game/gamemodel/activity/acCjyxVo"
        require "luascript/script/game/gamemodel/activity/acCjyxVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxLottery"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxRank"
    elseif type == "nljj" then
        require "luascript/script/game/gamemodel/activity/acNljjVo"
        require "luascript/script/game/gamemodel/activity/acNljjVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNljjDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNljjTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNljjTab2"
    elseif type == "qxtw" then
        require "luascript/script/game/gamemodel/emblem/emblemVo"
        require "luascript/script/config/gameconfig/emblemListCfg"
        require "luascript/script/config/gameconfig/emblemCfg"
        
        require "luascript/script/game/gamemodel/activity/acQxtwVo"
        require "luascript/script/game/gamemodel/activity/acQxtwVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQxtwDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQxtwTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQxtwTab2"
    elseif type == "wdyo" then--无独有偶 LoversDay
        require "luascript/script/game/gamemodel/activity/acLoversDayVo"
        require "luascript/script/game/gamemodel/activity/acLoversDayVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLoversDayDialog"
    elseif type == "yswj" then
        require "luascript/script/game/gamemodel/activity/acYswjVo"
        require "luascript/script/game/gamemodel/activity/acYswjVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjLottery"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjRefinery"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjTask"
    elseif type == "zjfb"then
        require "luascript/script/game/gamemodel/activity/acArmoredStormVo"
        require "luascript/script/game/gamemodel/activity/acArmoredStormVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acArmoredStormDialog"
    elseif type == "zjjz" then
        require "luascript/script/game/gamemodel/activity/acZjjzVo"
        require "luascript/script/game/gamemodel/activity/acZjjzVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZjjzDialog"
    elseif type == "xscj" then
        require "luascript/script/game/gamemodel/activity/acXscjVo"
        require "luascript/script/game/gamemodel/activity/acXscjVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXscjDialog"
    elseif type == "xssd" then
        require "luascript/script/game/gamemodel/activity/acXssdVo"
        require "luascript/script/game/gamemodel/activity/acXssdVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXssdDialog"
    elseif type == "ljcz" then
        require "luascript/script/game/gamemodel/activity/acLjczVo"
        require "luascript/script/game/gamemodel/activity/acLjczVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLjczDialog"
    elseif type == "ljcz3" then
        require "luascript/script/game/gamemodel/activity/acSuperLjczVo"
        require "luascript/script/game/gamemodel/activity/acSuperLjczVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSuperLjczDialog"
    elseif type == "sdzs" then
        require "luascript/script/game/gamemodel/activity/acSdzsVo"
        require "luascript/script/game/gamemodel/activity/acSdzsVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSdzsDialog"
    elseif type == "wjdc" then
        require "luascript/script/game/gamemodel/activity/acWjdcVo"
        require "luascript/script/game/gamemodel/activity/acWjdcVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWjdcDialog"
    elseif type == "znkh2017" then
        require "luascript/script/game/gamemodel/activity/acZnkh2017Vo"
        require "luascript/script/game/gamemodel/activity/acZnkh2017VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh2017Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh2017Tab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh2017Tab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh2017Tab3"
    elseif type == "pjgx" then
        require "luascript/script/game/gamemodel/activity/acPjgxVo"
        require "luascript/script/game/gamemodel/activity/acPjgxVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPjgxDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPjgxTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPjgxTab2"
    elseif type == "tccx" then
        require "luascript/script/game/gamemodel/activity/acTccxVo"
        require "luascript/script/game/gamemodel/activity/acTccxVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTccxDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTccxTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTccxTab2"
    elseif type == "wmzz" then
        require "luascript/script/game/gamemodel/activity/acWmzzVo"
        require "luascript/script/game/gamemodel/activity/acWmzzVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWmzzDialog"
    elseif type == "yjtsg" then
        require "luascript/script/game/gamemodel/activity/acYjtsgVo"
        require "luascript/script/game/gamemodel/activity/acYjtsgVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYjtsgDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYjtsgTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYjtsgTab2"
    elseif type == "gzhx" then
        require "luascript/script/game/gamemodel/activity/acGzhxVo"
        require "luascript/script/game/gamemodel/activity/acGzhxVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGzhxDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGzhxDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGzhxDialogTab2"
    elseif type == "ramadan" then
        require "luascript/script/game/gamemodel/activity/acRamadanVo"
        require "luascript/script/game/gamemodel/activity/acRamadanVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRamadanDialog"
    elseif type == "phlt" then
        require "luascript/script/game/gamemodel/activity/acPhltVo"
        require "luascript/script/game/gamemodel/activity/acPhltVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPhltDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPhltLottery"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acPhltShop"
    elseif type == "hxgh" then
        require "luascript/script/game/gamemodel/activity/acHxghVo"
        require "luascript/script/game/gamemodel/activity/acHxghVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHxghDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHxghLottery"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHxghShop"
    elseif type == "cjms" then
        require "luascript/script/game/gamemodel/activity/acSuperShopVo"
        require "luascript/script/game/gamemodel/activity/acSuperShopVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSuperShopDialog"
    elseif type == "zzrs" then
        require "luascript/script/game/gamemodel/activity/acThrivingVo"
        require "luascript/script/game/gamemodel/activity/acThrivingVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
    elseif type == "kljz" then
        require "luascript/script/game/gamemodel/activity/acKljzVo"
        require "luascript/script/game/gamemodel/activity/acKljzVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKljzDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKljzTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKljzTabTwo"
    elseif type == "zjjy" then
        require "luascript/script/game/gamemodel/activity/acArmorEliteVo"
        require "luascript/script/game/gamemodel/activity/acArmorEliteVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acArmorEliteDialog"
    elseif type == "kzhd" then
        require "luascript/script/game/gamemodel/activity/acKzhdVo"
        require "luascript/script/game/gamemodel/activity/acKzhdVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKzhdDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKzhdDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKzhdDialogTab2"
    elseif type == "khzr" then
        require "luascript/script/game/gamemodel/activity/acKhzrVo"
        require "luascript/script/game/gamemodel/activity/acKhzrVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKhzrDialog"
    elseif type == "fuyunshuangshou" then
        require "luascript/script/game/gamemodel/activity/acFyssVo"
        require "luascript/script/game/gamemodel/activity/acFyssVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFyssDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFyssTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFyssTabTwo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFyssSmallDialog"
    elseif type == "znqd2017" then
        require "luascript/script/game/gamemodel/activity/acAnniversaryFourVo"
        require "luascript/script/game/gamemodel/activity/acAnniversaryFourVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryFourDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryFourTabWelfare"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryFourTabRecharge"
    elseif type == "secretshop" then
        require "luascript/script/game/gamemodel/activity/acSecretshopVo"
        require "luascript/script/game/gamemodel/activity/acSecretshopVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSecretshopDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSecretshopDialogTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSecretshopDialogTab2"
    elseif type == "znkh" then
        require "luascript/script/game/gamemodel/activity/acZnkhVo"
        require "luascript/script/game/gamemodel/activity/acZnkhVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkhDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkhTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkhTabTwo"
    elseif type == "qmcj" then
        require "luascript/script/game/gamemodel/activity/acEatChickenVo"
        require "luascript/script/game/gamemodel/activity/acEatChickenVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEatChickenDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEatChickenDialogTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acEatChickenDialogTabTwo"
    elseif type == "qmsd" then
        require "luascript/script/game/gamemodel/activity/acQmsdVo"
        require "luascript/script/game/gamemodel/activity/acQmsdVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQmsdDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQmsdTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQmsdTabTwo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acQmsdTabThree"
    elseif type == "mjzx" then
        require "luascript/script/game/gamemodel/activity/acMjzxVo"
        require "luascript/script/game/gamemodel/activity/acMjzxVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjzxDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjzxTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjzxTabTwo"
    elseif type == "yrj" then
        require "luascript/script/game/gamemodel/activity/acYrjVo"
        require "luascript/script/game/gamemodel/activity/acYrjVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYrjDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYrjTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYrjTabTwo"
    elseif type == "duanwu" then
        require "luascript/script/game/gamemodel/activity/acDuanWuVo"
        require "luascript/script/game/gamemodel/activity/acDuanWuVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDuanWuDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDuanWuTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDuanWuTabTwo"
    elseif type == "dlbz" then
        require "luascript/script/game/gamemodel/activity/acDlbzVo"
        require "luascript/script/game/gamemodel/activity/acDlbzVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acDlbzDialog"
    elseif type == "czhk" then
        require "luascript/script/game/gamemodel/activity/acCzhkVo"
        require "luascript/script/game/gamemodel/activity/acCzhkVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCzhkDialog"
    elseif type == "wpbd" then
        require "luascript/script/game/gamemodel/activity/acWpbdVo"
        require "luascript/script/game/gamemodel/activity/acWpbdVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWpbdDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWpbdTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWpbdTabTwo"
    elseif type == "cflm" then
        require "luascript/script/game/gamemodel/activity/acCflmVo"
        require "luascript/script/game/gamemodel/activity/acCflmVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCflmDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCflmDialogTabRecharge"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCflmDialogTabInvest"
    elseif type == "bhqf" then
        require "luascript/script/game/gamemodel/activity/acBhqfVo"
        require "luascript/script/game/gamemodel/activity/acBhqfVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBhqfDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBhqfLotteryDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acBhqfTaskDialog"
    elseif type == "lmqrj" then
        require "luascript/script/game/gamemodel/activity/acLmqrjVo"
        require "luascript/script/game/gamemodel/activity/acLmqrjVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLmqrjDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLmqrjTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLmqrjTabTwo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLmqrjSmallDialog"
    elseif type == "ydcz" then
        require "luascript/script/game/gamemodel/activity/acYdczVo"
        require "luascript/script/game/gamemodel/activity/acYdczVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYdczDialog"
    elseif type == "tqbj" then
        require "luascript/script/game/gamemodel/activity/acTqbjVo"
        require "luascript/script/game/gamemodel/activity/acTqbjVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acTqbjDialog"
    elseif type == "xstq" then
        require "luascript/script/game/gamemodel/activity/acXstqVo"
        require "luascript/script/game/gamemodel/activity/acXstqVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXstqDialog"
    elseif type == "smbd" then
        require "luascript/script/game/gamemodel/activity/acSmbdVoApi"
        require "luascript/script/game/gamemodel/activity/acSmbdVo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSmbdDialog"
    elseif type == "thfb" then
        require "luascript/script/game/gamemodel/activity/acThfbVoApi"
        require "luascript/script/game/gamemodel/activity/acThfbVo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThfbDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThfbGiftBagDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThfbTaskDialog"
    elseif type == "xcjh" then
        require "luascript/script/game/gamemodel/activity/acXcjhVo"
        require "luascript/script/game/gamemodel/activity/acXcjhVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXcjhDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXcjhZcjbDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXcjhDailyTaskDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXcjhRewardDialog"
    elseif type == "mjzy" then
        require "luascript/script/game/gamemodel/activity/acMjzyVoApi"
        require "luascript/script/game/gamemodel/activity/acMjzyVo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjzyDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjzyReinforceDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjzyShopDialog"
    elseif type == "xlys" then
        require "luascript/script/game/gamemodel/activity/acXlysVoApi"
        require "luascript/script/game/gamemodel/activity/acXlysVo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXlysDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXlysTrainDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXlysTaskDialog"
    elseif type == "hryx" then
        require "luascript/script/game/gamemodel/activity/acHryxVoApi"
        require "luascript/script/game/gamemodel/activity/acHryxVo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHryxDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHryxTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHryxTabTwo"
    elseif type == "wxgx" then
        require "luascript/script/game/gamemodel/activity/acWxgxVoApi"
        require "luascript/script/game/gamemodel/activity/acWxgxVo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acWxgxDialog"
    elseif type == "ryhg" then
        require "luascript/script/game/gamemodel/activity/acRyhgVoApi"
        require "luascript/script/game/gamemodel/activity/acRyhgVo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acRyhgDialog"
    elseif type == "wsj2018" then
        require "luascript/script/game/gamemodel/activity/acHalloween2018VoApi"
        require "luascript/script/game/gamemodel/activity/acHalloween2018Vo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHalloween2018Dialog"
    elseif type == "znjl" then
        require "luascript/script/game/gamemodel/activity/acZnjlVoApi"
        require "luascript/script/game/gamemodel/activity/acZnjlVo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnjlDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnsdDialog"
    elseif type == "znkh2018" then
        require "luascript/script/game/gamemodel/activity/acZnkhFiveAnniversaryVo"
        require "luascript/script/game/gamemodel/activity/acZnkhFiveAnniversaryVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkhFiveAnniversaryDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkhFiveAnniversaryTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkhFiveAnniversaryTabTwo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkhFiveAnniversaryTabThree"
    elseif type == "kfcz" then
        require "luascript/script/game/gamemodel/activity/acKfczVo"
        require "luascript/script/game/gamemodel/activity/acKfczVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKfczDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKfczTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKfczTabTwo"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acKfczTabThree"
    elseif type == "zntp" then
        require "luascript/script/game/gamemodel/activity/acZntpVo"
        require "luascript/script/game/gamemodel/activity/acZntpVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZntpDialog"
    elseif type == "jtxlh" then
        require "luascript/script/game/gamemodel/activity/acJtxlhVo"
        require "luascript/script/game/gamemodel/activity/acJtxlhVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJtxlhDialog"
    elseif type == "jblb" then
        require "luascript/script/game/gamemodel/activity/acCustomVo"
        require "luascript/script/game/gamemodel/activity/acCustomVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCustomDialog"
    elseif type == "gwkh" then
        require "luascript/script/game/gamemodel/activity/acGwkhVo"
        require "luascript/script/game/gamemodel/activity/acGwkhVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGwkhDialog"
    elseif type == "zncf" then
        require "luascript/script/game/gamemodel/activity/acZncfVo"
        require "luascript/script/game/gamemodel/activity/acZncfVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZncfDialog"
    elseif type == "xlpd" then
        require "luascript/script/game/gamemodel/activity/acXlpdVo"
        require "luascript/script/game/gamemodel/activity/acXlpdVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXlpdDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXlpdTabOne"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXlpdTabTwo"
    elseif type == "mjcs" then
        require "luascript/script/game/gamemodel/activity/acMjcsVo"
        require "luascript/script/game/gamemodel/activity/acMjcsVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjcsDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjcsTab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMjcsTab2"
    elseif type == "znkh2019" then
        require "luascript/script/game/gamemodel/activity/acZnkh19Vo"
        require "luascript/script/game/gamemodel/activity/acZnkh19VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh19Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh19LotteryTab"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh19ExchangeTab"
    elseif type == "smbx" then
        require "luascript/script/game/gamemodel/activity/acMysteryBoxVo"
        require "luascript/script/game/gamemodel/activity/acMysteryBoxVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMysteryBoxDialog"
    elseif type == "hjld" then
        require "luascript/script/game/gamemodel/activity/acMemoryServerVo"
        require "luascript/script/game/gamemodel/activity/acMemoryServerVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMemoryServerDialog"
    elseif type == "xssd2019" then
        require "luascript/script/game/gamemodel/activity/acXssd2019Vo"
        require "luascript/script/game/gamemodel/activity/acXssd2019VoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXssd2019Dialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXssd2019Tab1"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXssd2019Tab2"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXssd2019Tab3"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acXssd2019SmallDialog"
    elseif type == "xjlb" then
        require "luascript/script/game/gamemodel/activity/acCashGiftBagVo"
        require "luascript/script/game/gamemodel/activity/acCashGiftBagVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCashGiftBagDialog"
    elseif type == "jjzz" then
        require "luascript/script/game/gamemodel/activity/acJjzzVo"
        require "luascript/script/game/gamemodel/activity/acJjzzVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acJjzzDialog"
    elseif type == "nlgc" then
        require "luascript/script/game/gamemodel/activity/acNlgcVo"
        require "luascript/script/game/gamemodel/activity/acNlgcVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acNlgcDialog"
    elseif type == "xsjx2020" then
        require "luascript/script/game/gamemodel/activity/acFlashSaleVo"
        require "luascript/script/game/gamemodel/activity/acFlashSaleVoApi"
        require "luascript/script/game/scene/gamedialog/activityAndNote/acFlashSaleDialog"
    else
        return activityVo
    end
end

function activityVoApi:getVoByType(type)
    if type and type ~= "" then
        local arr = Split(type, "_")
        type = arr[1]
    end
    if type == "discount" then
        return acDiscountVo
    elseif type == "moscowGambling" then
        return acMoscowGamblingVo
    elseif type == "moscowGamblingGai" then
        return acMoscowGamblingGaiVo
    elseif type == "firstRecharge" then
        return acFirstRechargeVo
    elseif type == "fbReward" then
        return acFbRewardVo
    elseif type == "dayRecharge" then
        return acDayRechargeVo
    elseif type == "dayRechargeForEquip" then
        return acDayRechargeForEquipVo
    elseif type == "fightRank" then
        return acFightRankVo
    elseif type == "baseLeveling" then
        return acBaseLevelingVo
    elseif type == "wheelFortune" then
        return acRouletteVo
    elseif type == "allianceLevel" then
        return acAllianceLevelVo
    elseif type == "allianceFight" then
        return acAllianceFightVo
    elseif type == "personalHonor" then
        return acPersonalHonorVo
    elseif type == "personalCheckPoint" then
        return acPersonalCheckPointVo
    elseif type == "totalRecharge" then
        return acTotalRechargeVo
    elseif type == "totalRecharge2" then
        return acTotalRecharge2Vo
    elseif type == "allianceHonor" then
        return acAllianceHonorVo
    elseif type == "crystalHarvest" then
        return acCrystalYieldVo
    elseif type == "equipSearch" then
        return acEquipSearchVo
    elseif type == "rechargeRebate" then
        return acRechargeRebateVo
    elseif type == "customRechargeRebate" then
        return acCustomRechargeRebateVo
    elseif type == "monsterComeback" then
        return acMonsterComebackVo
    elseif type == "growingPlan" then
        return acGrowingPlanVo
    elseif type == "harvestDay" then
        return acHarvestDayVo
    elseif type == "oldUserReturn" then
        return acReturnVo
    elseif type == "accessoryEvolution" then
        return acAccessoryUpgradeVo
    elseif type == "accessoryFight" then
        return acAccessoryFightVo
    elseif type == "jsss" then
        return acJsysVo
    elseif type == "allianceDonate" then
        return acAllianceDonateVo
    elseif type == "equipSearchII" then
        return acEquipSearchIIVo
    elseif type == "rechargeDouble" then
        return acRechargeDoubleVo
    elseif type == "vipRight" then
        return acVipRightVo
    elseif type == "heartOfIron" then
        return acHeartOfIronVo
    elseif type == "userFund" then
        return acUserFundVo
    elseif type == "tendayslogin" then
        return acTenDaysLoginVo
    elseif type == "vipAction" then
        return acVipActionVo
    elseif type == "investPlan" then
        return acInvestPlanVo
    elseif type == "hardGetRich" then
        return acHardGetRichVo
    elseif type == "wheelFortune4" then
        return acRoulette4Vo
    elseif type == "openGift" then
        return acOpenGiftVo
    elseif type == "wheelFortune2" then
        return acRoulette2Vo
    elseif type == "wheelFortune3" then
        return acRoulette3Vo
    elseif type == "stormrocket" then
        return acStormRocketVo
    elseif type == "grabRed" then
        return acGrabRedVo
    elseif type == "armsRace" then
        return acArmsRaceVo
    elseif type == "slotMachine" then
        return acSlotMachineVo
    elseif type == "slotMachine2" then
        return acSlotMachine2Vo
    elseif type == "slotMachineCommon" then
        return acSlotMachineCommonVo
    elseif type == "customLottery" then
        return acCustomLotteryVo
    elseif type == "customLottery1" then
        return acCustomLotteryOneVo
    elseif type == "shareHappiness" then
        return acShareHappinessVo
    elseif type == "holdGround" then
        return acHoldGroundVo
    elseif type == "fundsRecruit" then
        return acFundsRecruitVo
    elseif type == "continueRecharge" then
        return acContinueRechargeVo
    elseif type == "lxcz" then
        return acContinueRechargeNewGuidVo
    elseif type == "rewardingBack" then
        return acRewardingBackVo
    elseif type == "armamentsUpdate1" or type == "armamentsUpdate2" then
        return acArmamentsUpdateVo
    elseif type == "miBao" then
        return acMiBaoVo
    elseif type == "leveling" then
        return acLevelingVo
    elseif type == "leveling2" then
        return acLeveling2Vo
    elseif type == "holdGround1" then
        return acHoldGround1Vo
    elseif type == "autumnCarnival" then
        return acAutumnCarnivalVo
    elseif type == "calls" then
        return acCallsVo
    elseif type == "newTech" then
        return acNewTechVo
    elseif type == "luckUp" then
        return acLuckUpVo
    elseif type == "republicHui" then
        return acRepublicHuiVo
    elseif type == "nationalCampaign" then
        return acNationalCampaignVo
    elseif type == "ghostWars" then
        return acGhostWarsVo
    elseif type == "doorGhost" then
        return acDoorGhostVo
    elseif type == "refitPlanT99" then
        return acRefitPlanVo
    elseif type == "preparingPeak" then
        return acPreparingPeakVo
    elseif type == "singles" then
        return acSinglesVo
    elseif type == "cuikulaxiu" then
        return acCuikulaxiuVo
    elseif type == "jidongbudui" then
        return acJidongbuduiVo
    elseif type == "baifudali" then
        return acBaifudaliVo
    elseif type == "feixutansuo" then
        return acFeixutansuoVo
    elseif type == "kuangnuzhishi" then
        return acKuangnuzhishiVo
    elseif type == "zhenqinghuikui" then
        return acRoulette5Vo
    elseif type == "shengdanbaozang" then
        return acShengdanbaozangVo
    elseif type == "shengdankuanghuan" then
        return acShengdankuanghuanVo
    elseif type == "yuandanxianli" then
        return acYuandanxianliVo
    elseif type == "onlineReward" then
        return acOnlineRewardVo
    elseif type == "online2018" then
        return acOnlineRewardXVIIIVo
    elseif type == "tankjianianhua" then
        return acTankjianianhuaVo
    elseif type == "xuyuanlu" then
        return acXuyuanluVo
    elseif type == "shuijinghuikui" then
        return acShuijinghuikuiVo
    elseif type == "xinchunhongbao" then
        return acXinchunhongbaoVo
    elseif type == "huoxianmingjiang" then
        return acHuoxianmingjiangVo
    elseif type == "junzipaisong" then
        return acJunzipaisongVo
    elseif type == "chongzhiyouli" then
        return acChongZhiYouLiVo
    elseif type == "junshijiangtan" then
        return acJunshijiangtanVo
    elseif type == "songjiangling" then
        return acSendGeneralVo
    elseif type == "huoxianmingjianggai" then
        return acMingjiangVo
    elseif type == "shengdanbaozang" then
        return acShengdanbaozangVo
    elseif type == "xingyunzhuanpan" then
        return acMayDayVo
    elseif type == "taibumperweek" then
        return acTitaniumOfharvestVo
    elseif type == "banzhangshilian" then
        return acBanzhangshilianVo
    elseif type == "hongchangyuebing" then
        return acHongchangyuebingVo
    elseif type == "huiluzaizao" then
        return acRecyclingVo
    elseif type == "yunxingjianglin" then
        return acMeteoriteLandingVo
    elseif type == "tianjiangxiongshi" then
        return acTianjiangxiongshiVo
    elseif type == "kafkagift" then
        return acKafkaGiftVo
    elseif type == "quanmintanke" then
        return acQuanmintankeVo
    elseif type == "diancitanke" then
        return acDiancitankeVo
    elseif type == "alienbumperweek" then
        return acAlienbumperweekVo
    elseif type == "ydjl2" then
        return acYueduHeroTwoVo--acYueduHeroVo
    elseif type == "yuedujiangling" then
        return acYueduHeroVo
    elseif type == "twohero" then
        return acHeroGiftVo
    elseif type == "sendaccessory" then
        return acPeijianhuzengVo
    elseif type == "haoshichengshuang" then
        return acHaoshichengshuangVo
    elseif type == "gangtieronglu" then
        return acGangtierongluVo
    elseif type == "xingyunpindian" then -- 幸运拼点
        return acXingyunpindianVo
    elseif type == "swchallengeactive" then --
        return acSwchallengeactiveVo
    elseif type == "xiaofeisongli" then
        return acXiaofeisongliVo
    elseif type == "ybsc" then
        return acYuebingshenchaVo
    elseif type == "chongzhisongli" then -- 累计充值送好礼
        return acChongzhisongliVo
    elseif type == "danrichongzhi" then -- 单日充值
        return acDanrichongzhiVo
    elseif type == "mrcz" then --每日充值送好礼（新人绑定版）
        return acDailyRechargeByNewGuiderVo
    elseif type == "danrixiaofei" then -- 单日消费
        return acDanrixiaofeiVo
    elseif type == "jiejingkaicai" then
        return acJiejingkaicaiVo
    elseif type == "jffp" then -- 积分翻盘
        return acJffpVo
    elseif type == "firstRechargenew" then
        return acFirstRechargenewVo
    elseif type == "fightRanknew" then
        return acFightRanknewVo
    elseif type == "challengeranknew" then
        return acChallengeranknewVo
    elseif type == "yongwangzhiqian" then
        return acMoveForwardVo
    elseif type == "ywzq" then
        return acYwzqVo
    elseif type == "xinfulaba" then
        return acLuckyCatVo
    elseif type == "double11new" then
        return acDouble11NewVo
    elseif type == "double11" then
        return acDouble11Vo
    elseif type == "new112018" then
        return acDoubleOneVo
    elseif type == "halloween" then
        return acSweetTroubleVo
    elseif type == "twolduserreturn" then
        return acOldReturnVo
    elseif type == "wanshengjiedazuozhan" then
        return acWanshengjiedazuozhanVo
    elseif type == "zhanshuyantao" then
        return acTacticalDiscussVo
    elseif type == "yijizaitan" then
        return acYijizaitanVo
    elseif type == "ganenjiehuikui" then
        return acThanksGivingVo
    elseif type == "christmasfight" then
        return acChristmasFightVo
    elseif type == "mingjiangzailin" then
        return acMingjiangzailinVo
    elseif type == "newyeargift" then
        return acNewYearVo
    elseif type == "tankbattle" then
        return acTankBattleVo
    elseif type == "shengdanqianxi" then
        return acChrisEveVo
    elseif type == "newyeareva" then
        return acNewYearsEveVo
    elseif type == "chunjiepansheng" then
        return acChunjiepanshengVo
    elseif type == "smcj" then
        return acSmcjVo
    elseif type == "hljb" then
        return acHljbVo
    elseif type == "anniversary" then
        return acAnniversaryVo
    elseif type == "yichujifa" then
        return acImminentVo
    elseif type == "koulinghongbao" then
        return acKoulinghongbaoVo
    elseif type == "rechargeCompetition" then
        return acRechargeGameVo
    elseif type == "dailyEquipPlan" then
        return acDailyEquipPlanVo
    elseif type == "stormFortress" then
        return acStormFortressVo
    elseif type == "seikoStoneShop" then
        return acSeikoStoneShopVo
    elseif type == "anniversaryBless" then
        return acAnniversaryBlessVo
    elseif type == "blessingWheel" then
        return acBlessingWheelVo
    elseif type == "monthlysign" then
        return acMonthlySignVo
    elseif type == "buyreward" then
        return acBuyrewardVo
    elseif type == "rechargebag" then
        return acRechargeBagVo
    elseif type == "pjjnh" then
        return acPjjnhVo
    elseif type == "olympic" then
        return acOlympicVo
    elseif type == "luckcard" then
        return acLuckyPokerVo
    elseif type == "benfuqianxian" then
        return acBenfuqianxianVo
    elseif type == "aoyunjizhang" then
        return acOlympicCollectVo
    elseif type == "battleplane" then
        return acAntiAirVo
    elseif type == "mingjiangpeiyang" then
        return acMingjiangpeiyangVo
    elseif type == "midautumn" then
        return acMidAutumnVo
    elseif type == "zhanyoujijie" then
        return acZhanyoujijieVo
    elseif type == "threeyear" then
        return acThreeYearVo
    elseif type == "gqkh" then
        return acGqkhVo
    elseif type == "wsjdzz" then
        return acWsjdzzVo
    elseif type == "wsjdzz2017" then
        return acWsjdzzIIVo
    elseif type == "mineExplore" then
        return acMineExploreVo
    elseif type == "mineExploreG" then
        return acMineExploreGVo
    elseif type == "gej2016" then
        return acGej2016Vo
    elseif type == "openyear" then
        return acOpenyearVo
    elseif type == "christmas2016" then
        return acChristmasAttireVo
    elseif type == "djrecall" then
        return acGeneralRecallVo
    elseif type == "btzx" then
        return acBtzxVo
    elseif type == "cjyx" then
        return acCjyxVo
    elseif type == "nljj" then
        return acNljjVo
    elseif type == "qxtw" then
        return acQxtwVo
    elseif type == "wdyo" then
        return acLoversDayVo
    elseif type == "yswj" then
        return acYswjVo
    elseif type == "zjfb" then
        return acArmoredStormVo
    elseif type == "zjjz" then
        return acZjjzVo
    elseif type == "xscj" then
        return acXscjVo
    elseif type == "xssd" then
        return acXssdVo
    elseif type == "ljcz" then
        return acLjczVo
    elseif type == "ljcz3" then
        return acSuperLjczVo
    elseif type == "sdzs" then
        return acSdzsVo
    elseif type == "wjdc" then
        return acWjdcVo
    elseif type == "znkh2017" then
        return acZnkh2017Vo
    elseif type == "pjgx" then
        return acPjgxVo
    elseif type == "tccx" then
        return acTccxVo
    elseif type == "wmzz" then
        return acWmzzVo
    elseif type == "yjtsg" then
        return acYjtsgVo
    elseif type == "gzhx" then
        return acGzhxVo
    elseif type == "kljz" then
        return acKljzVo
    elseif type == "ramadan" then
        return acRamadanVo
    elseif type == "phlt" then
        return acPhltVo
    elseif type == "hxgh" then
        return acHxghVo
    elseif type == "cjms" then
        return acSuperShopVo
    elseif type == "zzrs" then
        return acThrivingVo
    elseif type == "zjjy" then
        return acArmorEliteVo
    elseif type == "kzhd" then
        return acKzhdVo
    elseif type == "khzr" then
        return acKhzrVo
    elseif type == "fuyunshuangshou" then
        return acFyssVo
    elseif type == "znqd2017" then
        return acAnniversaryFourVo
    elseif type == "secretshop" then
        return acSecretshopVo
    elseif type == "znkh" then
        return acZnkhVo
    elseif type == "qmcj" then
        return acEatChickenVo
    elseif type == "qmsd" then
        return acQmsdVo
    elseif type == "mjzx" then
        return acMjzxVo
    elseif type == "yrj" then
        return acYrjVo
    elseif type == "duanwu" then
        return acDuanWuVo
    elseif type == "dlbz" then
        return acDlbzVo
    elseif type == "czhk" then
        return acCzhkVo
    elseif type == "wpbd" then
        return acWpbdVo
    elseif type == "bhqf" then
        return acBhqfVo
    elseif type == "cflm" then
        return acCflmVo
    elseif type == "lmqrj" then
        return acLmqrjVo
    elseif type == "ydcz" then
        return acYdczVo
    elseif type == "tqbj" then
        return acTqbjVo
    elseif type == "xstq" then
        return acXstqVo
    elseif type == "smbd" then
        return acSmbdVo
    elseif type == "thfb" then
        return acThfbVo
    elseif type == "xcjh" then
        return acXcjhVo
    elseif type == "mjzy" then
        return acMjzyVo
    elseif type == "xlys" then
        return acXlysVo
    elseif type == "hryx" then
        return acHryxVo
    elseif type == "wxgx" then
        return acWxgxVo
    elseif type == "ryhg" then
        return acRyhgVo
    elseif type == "wsj2018" then
        return acHalloween2018Vo
    elseif type == "znjl" then
        return acZnjlVo
    elseif type == "znkh2018" then
        return acZnkhFiveAnniversaryVo
    elseif type == "kfcz" then
        return acKfczVo
    elseif type == "zntp" then
        return acZntpVo
    elseif type == "gwkh" then
        return acGwkhVo
    elseif type=="mjcs" then
        return acMjcsVo
    elseif type=="jtxlh" then
        return acJtxlhVo
    elseif type == "jblb" then
        return acCustomVo
    elseif type== "zncf" then
        return acZncfVo
    elseif type== "xlpd" then
        return acXlpdVo
    elseif type == "znkh2019" then
        return acZnkh19Vo
    elseif type == "smbx" then
        return acMysteryBoxVo
    elseif type == "hjld" then
        return acMemoryServerVo
    elseif type=="xssd2019" then
        return acXssd2019Vo
    elseif type == "xjlb" then
        return acCashGiftBagVo
    elseif type == "jjzz" then
        return acJjzzVo
    elseif type == "nlgc" then
        return acNlgcVo
    elseif type == "xsjx2020" then
        return acFlashSaleVo
    else
        return activityVo
    end
end

function activityVoApi:getVoApiByType(type)
    if type and type ~= "" then
        local arr = Split(type, "_")
        type = arr[1]
    end
    if type == "discount" then
        return acDiscountVoApi
    elseif type == "moscowGambling" then
        return acMoscowGamblingVoApi
    elseif type == "moscowGamblingGai" then
        return acMoscowGamblingGaiVoApi
    elseif type == "firstRecharge" then
        return acFirstRechargeVoApi
    elseif type == "fbReward" then
        return acFbRewardVoApi
    elseif type == "dayRecharge" then
        return acDayRechargeVoApi
    elseif type == "dayRechargeForEquip" then
        return acDayRechargeForEquipVoApi
    elseif type == "fightRank" then
        return acFightRankVoApi
    elseif type == "baseLeveling" then
        return acBaseLevelingVoApi
    elseif type == "wheelFortune" then
        return acRouletteVoApi
    elseif type == "allianceLevel" then
        return acAllianceLevelVoApi
    elseif type == "allianceFight" then
        return acAllianceFightVoApi
    elseif type == "personalHonor" then
        return acPersonalHonorVoApi
    elseif type == "personalCheckPoint" then
        return acPersonalCheckPointVoApi
    elseif type == "totalRecharge" then
        return acTotalRechargeVoApi
    elseif type == "totalRecharge2" then
        return acTotalRecharge2VoApi
    elseif type == "allianceHonor" then
        return acAllianceHonorVoApi
    elseif type == "crystalHarvest" then
        return acCrystalYieldVoApi
    elseif type == "equipSearch" then
        return acEquipSearchVoApi
    elseif type == "rechargeRebate" then
        return acRechargeRebateVoApi
    elseif type == "customRechargeRebate" then
        return acCustomRechargeRebateVoApi
    elseif type == "monsterComeback" then
        return acMonsterComebackVoApi
    elseif type == "growingPlan" then
        return acGrowingPlanVoApi
    elseif type == "harvestDay" then
        return acHarvestDayVoApi
    elseif type == "oldUserReturn" then
        return acReturnVoApi
    elseif type == "accessoryEvolution" then
        return acAccessoryUpgradeVoApi
    elseif type == "accessoryFight" then
        return acAccessoryFightVoApi
    elseif type == "jsss" then
        return acJsysVoApi
    elseif type == "allianceDonate" then
        return acAllianceDonateVoApi
    elseif type == "equipSearchII" then
        return acEquipSearchIIVoApi
    elseif type == "rechargeDouble" then
        return acRechargeDoubleVoApi
    elseif type == "vipRight" then
        return acVipRightVoApi
    elseif type == "heartOfIron" then
        return acHeartOfIronVoApi
    elseif type == "userFund" then
        return acUserFundVoApi
    elseif type == "tendayslogin" then
        return acTenDaysLoginVoApi
    elseif type == "vipAction" then
        return acVipActionVoApi
    elseif type == "investPlan" then
        return acInvestPlanVoApi
    elseif type == "hardGetRich" then
        return acHardGetRichVoApi
    elseif type == "wheelFortune4" then
        return acRoulette4VoApi
    elseif type == "openGift" then
        return acOpenGiftVoApi
    elseif type == "wheelFortune2" then
        return acRoulette2VoApi
    elseif type == "wheelFortune3" then
        return acRoulette3VoApi
    elseif type == "stormrocket" then
        return acStormRocketVoApi
    elseif type == "grabRed" then
        return acGrabRedVoApi
    elseif type == "armsRace" then
        return acArmsRaceVoApi
    elseif type == "slotMachine" then
        return acSlotMachineVoApi
    elseif type == "slotMachine2" then
        return acSlotMachine2VoApi
    elseif type == "slotMachineCommon" then
        return acSlotMachineCommonVoApi
    elseif type == "customLottery" then
        return acCustomLotteryVoApi
    elseif type == "customLottery1" then
        return acCustomLotteryOneVoApi
    elseif type == "shareHappiness" then
        return acShareHappinessVoApi
    elseif type == "holdGround" then
        return acHoldGroundVoApi
    elseif type == "fundsRecruit" then
        return acFundsRecruitVoApi
    elseif type == "continueRecharge" then
        return acContinueRechargeVoApi
    elseif type == "lxcz" then
        return acContinueRechargeNewGuidVoApi
    elseif type == "rewardingBack" then
        return acRewardingBackVoApi
    elseif type == "armamentsUpdate1" or type == "armamentsUpdate2" then
        return acArmamentsUpdateVoApi
    elseif type == "miBao" then
        return acMiBaoVoApi
    elseif type == "leveling" then
        return acLevelingVoApi
    elseif type == "leveling2" then
        return acLeveling2VoApi
    elseif type == "holdGround1" then
        return acHoldGround1VoApi
    elseif type == "autumnCarnival" then
        return acAutumnCarnivalVoApi
    elseif type == "calls" then
        return acCallsVoApi
    elseif type == "newTech" then
        return acNewTechVoApi
    elseif type == "luckUp" then
        return acLuckUpVoApi
    elseif type == "republicHui" then
        return acRepublicHuiVoApi
    elseif type == "nationalCampaign" then
        return acNationalCampaignVoApi
    elseif type == "ghostWars" then
        return acGhostWarsVoApi
    elseif type == "doorGhost" then
        return acDoorGhostVoApi
    elseif type == "refitPlanT99" then
        return acRefitPlanVoApi
    elseif type == "preparingPeak" then
        return acPreparingPeakVoApi
    elseif type == "singles" then
        return acSinglesVoApi
    elseif type == "cuikulaxiu" then
        return acCuikulaxiuVoApi
    elseif type == "jidongbudui" then
        return acJidongbuduiVoApi
    elseif type == "baifudali" then
        return acBaifudaliVoApi
    elseif type == "feixutansuo" then
        return acFeixutansuoVoApi
    elseif type == "kuangnuzhishi" then
        return acKuangnuzhishiVoApi
    elseif type == "zhenqinghuikui" then
        return acRoulette5VoApi
    elseif type == "shengdanbaozang" then
        return acShengdanbaozangVoApi
    elseif type == "shengdankuanghuan" then
        return acShengdankuanghuanVoApi
    elseif type == "yuandanxianli" then
        return acYuandanxianliVoApi
    elseif type == "onlineReward" then
        return acOnlineRewardVoApi
    elseif type == "online2018" then
        return acOnlineRewardXVIIIVoApi
    elseif type == "tankjianianhua" then
        return acTankjianianhuaVoApi
    elseif type == "xuyuanlu" then
        return acXuyuanluVoApi
    elseif type == "shuijinghuikui" then
        return acShuijinghuikuiVoApi
    elseif type == "xinchunhongbao" then
        return acXinchunhongbaoVoApi
    elseif type == "huoxianmingjiang" then
        return acHuoxianmingjiangVoApi
    elseif type == "junzipaisong" then
        return acJunzipaisongVoApi
    elseif type == "chongzhiyouli" then
        return acChongZhiYouLiVoApi
    elseif type == "junshijiangtan" then
        return acJunshijiangtanVoApi
    elseif type == "songjiangling" then
        return acSendGeneralVoApi
    elseif type == "huoxianmingjianggai" then
        return acMingjiangVoApi
    elseif type == "shengdanbaozang" then
        return acShengdanbaozangVoApi
    elseif type == "xingyunzhuanpan" then
        return acMayDayVoApi
    elseif type == "taibumperweek" then
        return acTitaniumOfharvestVoApi
    elseif type == "banzhangshilian" then
        return acBanzhangshilianVoApi
    elseif type == "hongchangyuebing" then
        return acHongchangyuebingVoApi
    elseif type == "huiluzaizao" then
        return acRecyclingVoApi
    elseif type == "yunxingjianglin" then
        return acMeteoriteLandingVoApi
    elseif type == "tianjiangxiongshi" then
        return acTianjiangxiongshiVoApi
    elseif type == "kafkagift" then
        return acKafkaGiftVoApi
    elseif type == "quanmintanke" then
        return acQuanmintankeVoApi
    elseif type == "diancitanke" then
        return acDiancitankeVoApi
    elseif type == "alienbumperweek" then
        return acAlienbumperweekVoApi
    elseif type == "ydjl2" then
        return acYueduHeroTwoVoApi
    elseif type == "yuedujiangling" then
        return acYueduHeroVoApi
    elseif type == "twohero" then
        return acHeroGiftVoApi
    elseif type == "sendaccessory" then
        return acPeijianhuzengVoApi
    elseif type == "haoshichengshuang" then
        return acHaoshichengshuangVoApi
    elseif type == "gangtieronglu" then
        return acGangtierongluVoApi
    elseif type == "xingyunpindian" then -- 幸运拼点
        return acXingyunpindianVoApi
    elseif type == "swchallengeactive" then --
        return acSwchallengeactiveVoApi
    elseif type == "xiaofeisongli" then
        return acXiaofeisongliVoApi
    elseif type == "ybsc" then
        return acYuebingshenchaVoApi
    elseif type == "chongzhisongli" then -- 累计充值送好礼
        return acChongzhisongliVoApi
    elseif type == "danrichongzhi" then -- 单日充值
        return acDanrichongzhiVoApi
    elseif type == "mrcz" then --每日充值送好礼（新手绑定版）
        return acDailyRechargeByNewGuiderVoApi
    elseif type == "danrixiaofei" then -- 单日消费
        return acDanrixiaofeiVoApi
    elseif type == "jiejingkaicai" then
        return acJiejingkaicaiVoApi
    elseif type == "jffp" then -- 单日消费
        return acJffpVoApi
    elseif type == "firstRechargenew" then -- 新的首冲送豪礼
        return acFirstRechargenewVoApi
    elseif type == "fightRanknew" then
        return acFightRanknewVoApi
    elseif type == "challengeranknew" then
        return acChallengeranknewVoApi
    elseif type == "yongwangzhiqian" then
        return acMoveForwardVoApi
    elseif type == "ywzq" then
        return acYwzqVoApi
    elseif type == "xinfulaba" then
        return acLuckyCatVoApi
    elseif type == "double11new" then
        return acDouble11NewVoApi
    elseif type == "double11" then
        return acDouble11VoApi
    elseif type == "new112018" then
        return acDoubleOneVoApi
    elseif type == "halloween" then
        return acSweetTroubleVoApi
    elseif type == "twolduserreturn" then
        return acOldReturnVoApi
    elseif type == "wanshengjiedazuozhan" then
        return acWanshengjiedazuozhanVoApi
    elseif type == "zhanshuyantao" then
        return acTacticalDiscussVoApi
    elseif type == "yijizaitan" then
        return acYijizaitanVoApi
    elseif type == "ganenjiehuikui" then
        return acThanksGivingVoApi
    elseif type == "christmasfight" then
        return acChristmasFightVoApi
    elseif type == "mingjiangzailin" then
        return acMingjiangzailinVoApi
    elseif type == "newyeargift" then
        return acNewYearVoApi
    elseif type == "tankbattle" then
        return acTankBattleVoApi
    elseif type == "shengdanqianxi" then
        return acChrisEveVoApi
    elseif type == "newyeareva" then
        return acNewYearsEveVoApi
    elseif type == "chunjiepansheng" then
        return acChunjiepanshengVoApi
    elseif type == "smcj" then
        return acSmcjVoApi
    elseif type == "hljb" then
        return acHljbVoApi
    elseif type == "anniversary" then
        return acAnniversaryVoApi
    elseif type == "yichujifa" then
        return acImminentVoApi
    elseif type == "koulinghongbao" then
        return acKoulinghongbaoVoApi
    elseif type == "rechargeCompetition" then
        return acRechargeGameVoApi
    elseif type == "dailyEquipPlan" then
        return acDailyEquipPlanVoApi
    elseif type == "stormFortress" then
        return acStormFortressVoApi
    elseif type == "seikoStoneShop" then
        return acSeikoStoneShopVoApi
    elseif type == "anniversaryBless" then
        return acAnniversaryBlessVoApi
    elseif type == "blessingWheel" then
        return acBlessingWheelVoApi
    elseif type == "monthlysign" then
        return acMonthlySignVoApi
    elseif type == "buyreward" then
        return acBuyrewardVoApi
    elseif type == "rechargebag" then
        return acRechargeBagVoApi
    elseif type == "pjjnh" then
        return acPjjnhVoApi
    elseif type == "olympic" then
        return acOlympicVoApi
    elseif type == "luckcard" then
        return acLuckyPokerVoApi
    elseif type == "benfuqianxian" then
        return acBenfuqianxianVoApi
    elseif type == "aoyunjizhang" then
        return acOlympicCollectVoApi
    elseif type == "battleplane" then
        return acAntiAirVoApi
    elseif type == "mingjiangpeiyang" then
        return acMingjiangpeiyangVoApi
    elseif type == "midautumn" then
        return acMidAutumnVoApi
    elseif type == "zhanyoujijie" then
        return acZhanyoujijieVoApi
    elseif type == "threeyear" then
        return acThreeYearVoApi
    elseif type == "gqkh" then
        return acGqkhVoApi
    elseif type == "wsjdzz" then
        return acWsjdzzVoApi
    elseif type == "wsjdzz2017" then
        return acWsjdzzIIVoApi
    elseif type == "mineExplore" then
        return acMineExploreVoApi
    elseif type == "mineExploreG" then
        return acMineExploreGVoApi
    elseif type == "gej2016" then
        return acGej2016VoApi
    elseif type == "openyear" then
        return acOpenyearVoApi
    elseif type == "christmas2016" then
        return acChristmasAttireVoApi
    elseif type == "djrecall" then
        return acGeneralRecallVoApi
    elseif type == "btzx" then
        return acBtzxVoApi
    elseif type == "cjyx" then
        return acCjyxVoApi
    elseif type == "nljj" then
        return acNljjVoApi
    elseif type == "qxtw" then
        return acQxtwVoApi
    elseif type == "wdyo" then
        return acLoversDayVoApi
    elseif type == "yswj" then
        return acYswjVoApi
    elseif type == "zjfb" then
        return acArmoredStormVoApi
    elseif type == "zjjz" then
        return acZjjzVoApi
    elseif type == "xscj" then
        return acXscjVoApi
    elseif type == "xssd" then
        return acXssdVoApi
    elseif type == "ljcz" then
        return acLjczVoApi
    elseif type == "ljcz3" then
        return acSuperLjczVoApi
    elseif type == "sdzs" then
        return acSdzsVoApi
    elseif type == "wjdc" then
        return acWjdcVoApi
    elseif type == "znkh2017" then
        return acZnkh2017VoApi
    elseif type == "pjgx" then
        return acPjgxVoApi
    elseif type == "tccx" then
        return acTccxVoApi
    elseif type == "wmzz" then
        return acWmzzVoApi
    elseif type == "yjtsg" then
        return acYjtsgVoApi
    elseif type == "gzhx" then
        return acGzhxVoApi
    elseif type == "kljz" then
        return acKljzVoApi
    elseif type == "ramadan" then
        return acRamadanVoApi
    elseif type == "phlt" then
        return acPhltVoApi
    elseif type == "hxgh" then
        return acHxghVoApi
    elseif type == "cjms" then
        return acSuperShopVoApi
    elseif type == "zzrs" then
        return acThrivingVoApi
    elseif type == "zjjy" then
        return acArmorEliteVoApi
    elseif type == "kzhd" then
        return acKzhdVoApi
    elseif type == "khzr" then
        return acKhzrVoApi
    elseif type == "fuyunshuangshou" then
        return acFyssVoApi
    elseif type == "znqd2017" then
        return acAnniversaryFourVoApi
    elseif type == "secretshop" then
        return acSecretshopVoApi
    elseif type == "znkh" then
        return acZnkhVoApi
    elseif type == "qmcj" then
        return acEatChickenVoApi
    elseif type == "qmsd" then
        return acQmsdVoApi
    elseif type == "mjzx" then
        return acMjzxVoApi
    elseif type == "yrj" then
        return acYrjVoApi
    elseif type == "duanwu" then
        return acDuanWuVoApi
    elseif type == "dlbz" then
        return acDlbzVoApi
    elseif type == "czhk" then
        return acCzhkVoApi
    elseif type == "wpbd" then
        return acWpbdVoApi
    elseif type == "bhqf" then
        return acBhqfVoApi
    elseif type == "cflm" then
        return acCflmVoApi
    elseif type == "lmqrj" then
        return acLmqrjVoApi
    elseif type == "ydcz" then
        return acYdczVoApi
    elseif type == "tqbj" then
        return acTqbjVoApi
    elseif type == "xstq" then
        return acXstqVoApi
    elseif type == "smbd" then
        return acSmbdVoApi
    elseif type == "thfb" then
        return acThfbVoApi
    elseif type == "xcjh" then
        return acXcjhVoApi
    elseif type == "mjzy" then
        return acMjzyVoApi
    elseif type == "xlys" then
        return acXlysVoApi
    elseif type == "hryx" then
        return acHryxVoApi
    elseif type == "wxgx" then
        return acWxgxVoApi
    elseif type == "ryhg" then
        return acRyhgVoApi
    elseif type == "wsj2018" then
        return acHalloween2018VoApi
    elseif type == "znjl" then
        return acZnjlVoApi
    elseif type == "znkh2018" then
        return acZnkhFiveAnniversaryVoApi
    elseif type == "kfcz" then
        return acKfczVoApi
    elseif type == "zntp" then
        return acZntpVoApi
    elseif type == "gwkh" then
        return acGwkhVoApi
    elseif type=="mjcs" then
        return acMjcsVoApi
    elseif type=="jtxlh" then
        return acJtxlhVoApi
    elseif type == "jblb" then
        return acCustomVoApi
    elseif type=="zncf" then
        return acZncfVoApi
    elseif type=="xlpd" then
        return acXlpdVoApi
    elseif type == "znkh2019" then
        return acZnkh19VoApi
    elseif type == "smbx" then
        return acMysteryBoxVoApi
    elseif type == "hjld" then
        return acMemoryServerVoApi
    elseif type=="xssd2019" then
        return acXssd2019VoApi
    elseif type == "xjlb" then
        return acCashGiftBagVoApi
    elseif type == "jjzz" then
        return acJjzzVoApi
    elseif type == "nlgc" then
        return acNlgcVoApi
    elseif type == "xsjx2020" then
        return acFlashSaleVoApi
    else
        return activityVoApi
    end
end

function activityVoApi:clear()
    local needClearVoApi = {}
    if self.allActivity then
        for k, v in pairs(self.allActivity) do
            local voApi = self:getVoApiByType(v.type)
            if voApi ~= nil and voApi.clearAll ~= nil then
                voApi:clearAll()
            end
            self.allActivity[k] = nil
        end
    end
    self.allActivity = {}
    self.init = false
    self.newNum = 0
    
    self.callbackNum = 0
end

function activityVoApi:formatData(data)
    if data ~= nil and data[1] then
        for k, v in pairs(data[1]) do
            local vo = self:getActivityVo(k)
            if vo == nil then
                self:requireByType(k)
                vo = self:getVoByType(k):new()
                vo:init(k)
                table.insert(self.allActivity, vo)
            end
            vo:updateData(v)
        end
        -- self.newNum = tonumber(data[2] or 0)
    end
    self:sortById()
end

function activityVoApi:formatDetailData(data)
    -- data["zhanyoujijie"] = {t=0,c=0,type=1,v=0} -- 测试数据
    for k, v in pairs(data) do
        local vo = self:getActivityVo(k)
        if vo == nil then
            self:requireByType(k)
            vo = self:getVoByType(k):new()
            vo:init(k)
            table.insert(self.allActivity, vo)
        end
        vo:updateData(v)
        vo.hasData = true
        self:updateShowState(vo)
    end
    self:sortById()
    self:initUserDefault()
    
    self.newNum = self:newAcNum()
    print("初始化新活动个数：", self.newNum)
end

function activityVoApi:formatActivityListData(data)
    for k, v in pairs(data) do
        local vo = self:getActivityVo(k)
        if vo == nil then
            self:requireByType(k)
            vo = self:getVoByType(k):new()
            vo:init(k)
            table.insert(self.allActivity, vo)
        end
        vo:updateData(v)
        vo.initCfg = true
        self:updateShowState(vo)
        
        if k == "tzzk" and not G_tzzkSaleData then--G_tzzkSaleData 全局使用,只给商店涂装折扣使用
            G_tzzkSaleData = v
        end
    end
    self:sortById()
    self.init = true
    self:updateUserDefault()
    self.newNum = self:newAcNum()
    print("初始化列表时更新新活动个数：", self.newNum)
end

function activityVoApi:sortById()
    for k, v in pairs(self.allActivity) do
        if v.type == "ydcz" and acYdczVoApi and acYdczVoApi:isCanUpgrade() == true then
            v.showType = 1
        end
    end
    local function sortAsc(a, b)
        if (a.showType or 0) ~= (b.showType or 0) then
            return (a.showType or 0) < (b.showType or 0)
        elseif tonumber(a.sortId) ~= tonumber(b.sortId) then
            return tonumber(a.sortId) < tonumber(b.sortId)
        end
        return a.st < b.st
    end
    table.sort(self.allActivity, sortAsc)
end

-- 活动数据发生改变，更新活动数据
function activityVoApi:updateVoByType(data)
    for k, v in pairs(data) do
        if type(v) == "table" then
            local vo = self:getActivityVo(k)
            if vo == nil then
                vo = activityVoApi:getVoByType(k):new(k)
            end
            vo:updateData(v)
            self:updateShowState(vo)
        end
    end
end

function activityVoApi:shareHappinessAddGiftList(data)
    local shareHappinessVo = self:getActivityVo("shareHappiness")
    if shareHappinessVo ~= nil and self:isStart(shareHappinessVo) == true then
        acShareHappinessVoApi:addGift(data)
    end
end

function activityVoApi:afterPushCallsData(data)
    local callVo = self:getActivityVo("calls")
    if callVo ~= nil and self:isStart(callVo) == true then
        acCallsVoApi:afterPushStatus(data, true)
    end
end

-- 获得所有正在进行中的活动
function activityVoApi:getAllActivity(needInitCfg)
    local all = {}
    if(G_isHexie())then
        return all
    end
    local heroOpenLv = base.heroOpenLv or 20
    local heroEquipOpenLv = base.heroEquipOpenLv or 30
    local expeditionOpenLv = base.expeditionOpenLv or 25
    local superWeaponOpenLv = base.superWeaponOpenLv or 25
    local alienTechOpenLv = base.alienTechOpenLv or 22
    local armorOpenLv = base.armor == 1 and 3 or nil
    for k, v in pairs(self.allActivity) do
        if v and self:isStart(v) == true and v.over == false and v.hasData == true and (((needInitCfg == nil or needInitCfg == true) and v.initCfg == true) or needInitCfg == false) and v.isShow ~= 0 then
            local acKeyTb = Split(v.type, "_")
            if v.type == "growingPlan" then
                local growingPlanCfg = playerCfg.growingPlan
                if playerVoApi:getGrowingPlanRewarded() < growingPlanCfg.playerLevelAndRewards[SizeOfTable(growingPlanCfg.playerLevelAndRewards)]["lv"] then
                    table.insert(all, v)
                end
            elseif v.type == "xinfulaba" then
                if playerVoApi:getPlayerLevel() > 4 then
                    table.insert(all, v)
                end
            elseif v.type == "ganenjiehuikui" then
                if playerVoApi:getPlayerLevel() >= 20 then
                    table.insert(all, v)
                end
            elseif v.type == "swchallengeactive" or v.type == "halloween" then
                if playerVoApi:getPlayerLevel() >= superWeaponOpenLv then
                    table.insert(all, v)
                end
            elseif(v.type == "dailyEquipPlan" or v.type == "seikoStoneShop")then
                if playerVoApi:getPlayerLevel() >= heroEquipOpenLv then
                    table.insert(all, v)
                end
            elseif(v.type == "tankbattle" or v.type == "huoxianmingjiang" or v.type == "huoxianmingjianggai" or v.type == "yuedujiangling"or v.type == "ydjl2" or v.type == "twohero" or v.type == "junshijiangtan" or v.type == "songjiangling" or v.type == "zhanshuyantao" or v.type == "mingjiangzailin" or v.type == "mingjiangpeiyang")then
                if playerVoApi:getPlayerLevel() >= heroOpenLv then
                    table.insert(all, v)
                end
            elseif(v.type == "yunxingjianglin" or v.type == "alienbumperweek" or v.type == "yichujifa" or v.type == "yswj")then
                if playerVoApi:getPlayerLevel() >= alienTechOpenLv then
                    table.insert(all, v)
                end
            elseif (v.type == "ljcz3") then
                if armorOpenLv and tonumber(armorOpenLv) and playerVoApi:getPlayerLevel() >= armorOpenLv then
                    table.insert(all, v)
                end
            elseif (v.type == "tzzk") then--不需要显示出来
            elseif acKeyTb[1] == "jblb" then
                if acCustomVoApi and acCustomVoApi:isCanEnter(v) then
                    table.insert(all, 1, v) --置顶显示
                end
            elseif (v.type=="mjcs") then
                if acMjcsVoApi and acMjcsVoApi:isCanEnter() then
                    table.insert(all,v)
                end
            elseif (v.type=="xssd2019") then
                if acXssd2019VoApi and acXssd2019VoApi:isCanEnter() then
                    table.insert(all,v)
                end
            elseif (v.type == "smbx" or v.type == "xsjx2020") then --不需要显示出来
            elseif (v.type == "xjlb") then
                if acCashGiftBagVoApi and acCashGiftBagVoApi:isCanEnter(false) then
                    table.insert(all, v)
                end
            else
                table.insert(all, v)
            end
        end
    end
    -- table.sort(all, function(a, b) return Split(a.type or "", "_")[1] == "jblb" end) --置顶显示
    return all
end

function activityVoApi:hadActivity()
    local num = SizeOfTable(self:getAllActivity(false))
    if num > 0 then
        return true
    end
    return false
end

function activityVoApi:initUserDefault()
    local zoneId = tostring(base.curZoneID)
    local gameUid = tostring(playerVoApi:getUid())
    local settingsKey = "activity@"..gameUid.."@"..zoneId
    local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
    local valueT
    if settingsValue ~= nil and settingsValue ~= "" then
        valueT = Split(settingsValue, ",")
    end
    local newSettingsValue
    local allActivity = self:getAllActivity()
    local acValue
    local acType
    local acSt
    local acEt
    local acIsRead
    local had = false
    
    for k, v in pairs(allActivity) do
        if v ~= nil then
            had = false
            if valueT ~= nil and type(valueT) == "table" then
                for k1, v1 in pairs(valueT) do
                    if v1 ~= nil then
                        acValue = Split(v1, "@")
                        if acValue ~= nil and type(acValue) == "table" and SizeOfTable(acValue) == 4 then
                            acType = tostring(acValue[1])
                            acSt = tonumber(acValue[2])
                            acEt = tonumber(acValue[3])
                            acIsRead = tonumber(acValue[4])
                            if v.type == acType and v.st == acSt and v.et == acEt then
                                had = true
                                if newSettingsValue == nil then
                                    newSettingsValue = v1
                                else
                                    newSettingsValue = newSettingsValue..","..v1
                                end
                            end
                        end
                    end
                end
            end
            if had == false then
                local value = v.type.."@"..v.st.."@"..v.et.."@"..0
                if newSettingsValue == nil then
                    newSettingsValue = value
                else
                    newSettingsValue = newSettingsValue..","..value
                end
            end
        end
    end
    if newSettingsValue ~= nil and newSettingsValue ~= settingsValue then
        CCUserDefault:sharedUserDefault():setStringForKey(settingsKey, newSettingsValue)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function activityVoApi:updateUserDefault()
    
    local zoneId = tostring(base.curZoneID)
    local gameUid = tostring(playerVoApi:getUid())
    local settingsKey = "activity@"..gameUid.."@"..zoneId
    local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
    -- if settingsValue == "" then
    --  do
    --    return
    --  end
    -- end
    
    local newSettingsValue
    local allActivity = self:getAllActivity()
    local had = false
    
    for k, v in pairs(allActivity) do
        if v ~= nil then
            if string.find(settingsValue, v.type.."@"..v.st.."@"..v.et) ~= nil then
                had = true
            else
                had = false
            end
            if had == false then
                local value = v.type.."@"..v.st.."@"..v.et.."@"..0
                if newSettingsValue == nil then
                    newSettingsValue = settingsValue..","..value
                else
                    newSettingsValue = newSettingsValue..","..value
                end
            end
        end
    end
    if newSettingsValue ~= nil then
        CCUserDefault:sharedUserDefault():setStringForKey(settingsKey, newSettingsValue)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function activityVoApi:updateUserDefaultAfterRead(type)
    local newSettingsValue
    local vo = self:getActivityVo(type)
    if vo ~= nil and self:isStart(vo) == true then
        local zoneId = tostring(base.curZoneID)
        local gameUid = tostring(playerVoApi:getUid())
        local settingsKey = "activity@"..gameUid.."@"..zoneId
        local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
        newSettingsValue = string.gsub(settingsValue, vo.type.."@"..vo.st.."@"..vo.et.."@"..0, vo.type.."@"..vo.st.."@"..vo.et.."@"..1)
        if newSettingsValue ~= nil and newSettingsValue ~= settingsValue then
            CCUserDefault:sharedUserDefault():setStringForKey(settingsKey, newSettingsValue)
            CCUserDefault:sharedUserDefault():flush()
            settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
        end
    end
    self.newNum = self:newAcNum()
    print("阅读后更新新活动个数：", self.newNum)
end

-- 新活动个数
function activityVoApi:newAcNum()
    local num = 0
    local allActivity = self:getAllActivity(false)
    for k, v in pairs(allActivity) do
        if v ~= nil and self:checkIfIsNew(v.type) == true then
            num = num + 1
        end
    end
    
    return num
end

-- 是否有新活动
function activityVoApi:hadNewActivity()
    if self.newNum > 0 then
        return true
    end
    return false
end

-- 根据type判断是否是新活动
function activityVoApi:checkIfIsNew(acT)
    local vo = self:getActivityVo(acT)
    if vo ~= nil and self:isStart(vo) == true then
        local zoneId = tostring(base.curZoneID)
        local gameUid = tostring(playerVoApi:getUid())
        local settingsKey = "activity@"..gameUid.."@"..zoneId
        local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
        local valueT
        if settingsValue ~= nil and settingsValue ~= "" then
            valueT = Split(settingsValue, ",")
        end
        if valueT ~= nil and type(valueT) == "table" then
            local acValue
            local acType
            local acSt
            local acEt
            local acIsRead
            for k, v in pairs(valueT) do
                if v ~= nil then
                    acValue = Split(v, "@")
                    if acValue ~= nil and type(acValue) == "table" and SizeOfTable(acValue) == 4 then
                        acType = tostring(acValue[1])
                        acSt = tonumber(acValue[2])
                        acEt = tonumber(acValue[3])
                        acIsRead = tonumber(acValue[4])
                        if acType == acT and vo.st == acSt and vo.et == acEt then
                            if acIsRead == 0 then
                                return true
                            else
                                return false
                            end
                        end
                    end
                end
            end
        end
        return true
    end
    return false
end

-- 根据type获得活动vo
function activityVoApi:getActivityVo(type)
    for k, v in pairs(self.allActivity) do
        if v and v.type ~= nil and tostring(v.type) == tostring(type) then
            return v
        end
    end
    return nil
end

-- 执行一些可能改变用户领奖状态的操作后调用刷新当前状态
function activityVoApi:updateShowState(vo)
    if vo == nil then
        do
            return
        end
    end
    local voApi = self:getVoApiByType(vo.type)
    local canReward = voApi:canReward(vo.type)
    if canReward ~= vo.canRewardFlag then
        vo.canRewardFlag = canReward
        vo.stateChanged = true
    end
end
--
function activityVoApi:updateAllShowState()
    for k, v in pairs(self.allActivity) do
        if v then
            self:updateShowState(v)
        end
    end
end

-- main.ui里tick时通过调用该方法来判断是否有可以领取但还未领取的奖励，来显示按钮动画
function activityVoApi:oneCanReward()
    local voTb = self:getAllActivity()
    for k, v in pairs(voTb) do
        self:updateShowState(v)
        if v.canRewardFlag == true then
            return true
        end
    end
    return false
end

function activityVoApi:afterShowState(vo)
    vo.stateChanged = false
end

-- 有一个或多个活动改变了显示状态
function activityVoApi:getOneChangeState()
    local voTb = self:getAllActivity()
    for k, v in pairs(voTb) do
        if v and v.stateChanged == true then
            return true
        end
    end
    return false
end

-- 活动是否正在进行中
function activityVoApi:isStart(vo)
    if vo and tonumber(vo.st) <= tonumber(base.serverTime) and tonumber(base.serverTime) < tonumber(vo.et) then
        return true
    end
    return false
end

function activityVoApi:getAcListShowTime(acVo)
    local timeStr = ""
    if acVo then
        if acVo.type == "firstRecharge" then
            timeStr = getlocal("getRewardAnyRecharge")
        elseif acVo.type == "growingPlan" then
            timeStr = getlocal("growingPlanTime")
        elseif acVo.type == "junshijiangtan" or acVo.type == "huoxianmingjianggai" or acVo.type == "shengdanqianxi" or acVo.type == "nljj" or acVo.type == "newyeareva" or acVo.type == "jsss" or acVo.type == "zzrs" or acVo.type == "fuyunshuangshou" or acVo.type == "cflm" then
            timeStr = activityVoApi:getActivityTimeStr(acVo.st, acVo.acEt - 86400, acVo.et, true)
        else
            timeStr = activityVoApi:getActivityTimeStr(acVo.st, acVo.acEt, acVo.et, true)
        end
    end
    return timeStr
end

--isShowCd 是否显示倒计时，混服活动列表和部分活动修改
--et 活动结束时间，不带领奖时间
--finalEt 活动关闭时间，包括领奖时间
--isShowText 是否显示"距离结束：{1}"文字
function activityVoApi:getActivityTimeStr(st, et, finalEt, isShowText, isShowCd)
    --[[local acSt=os.date("*t",st)
  local acEt = os.date("*t",et)
  --获得time时间table，有year,month,day,hour,min,sec等元素。
  local function format(num)
    if num<10 then
      return "0" .. num
    else
      return num
    end
  end
  local sDay = getlocal("day_time",{format(acSt.month),format(acSt.day),format(acSt.hour),format(acSt.min)})
  local eDay = getlocal("day_time",{format(acEt.month),format(acEt.day),format(acEt.hour),format(acEt.min)})--]]
    isShowCd = isShowCd or true
    local day
    if isShowCd == true and G_isGlobalServer() == true then
        local countDown, isReward = 0, false
        if base.serverTime < et then
            countDown = et - base.serverTime
        elseif finalEt and base.serverTime < finalEt then
            countDown = finalEt - base.serverTime
            isReward = true
        end
        if countDown < 0 then
            countDown = 0
        end
        if isShowText == true then
            if isReward == true then
                day = getlocal("rewardEndCountDown", {G_formatActiveDate(countDown)})
            else
                day = getlocal("endCountDown", {G_formatActiveDate(countDown)})
            end
        else
            if isReward == true then
                day = getlocal("serverwarteam_all_end")
            else
                -- day = GetTimeStr(G_formatActiveDate(countDown),true)
                day = G_formatActiveDate(countDown)
            end
        end
    else
        day = getlocal("activity_time", {G_getDataTimeStr(st), G_getDataTimeStr(et)})
    end
    return day
end

function activityVoApi:getActivityRewardTimeStr(et, numSt, numEn, isShowCd)
    local day
    isShowCd = isShowCd or true
    if isShowCd == true and G_isGlobalServer() == true then
        local countDown = 0
        if base.serverTime < (et + numSt) then
            day = getlocal("active_reward_left")
        elseif base.serverTime < (et + numEn) then
            countDown = et + numEn - base.serverTime
            if countDown < 0 then
                countDown = 0
            end
            day = G_formatActiveDate(countDown)
        else
            day = getlocal("serverwarteam_all_end")
        end
    else
        day = getlocal("activity_time", {G_getRewardTime(et, numSt), G_getRewardTime(et, numEn)})
    end
    return day
end

-- 根据条件来更改活动数据（一般没法手动执行，如时间到等）
function activityVoApi:tick()
    
    for k, v in pairs(self.allActivity) do
        if v ~= nil and v.type and (v.type == "leveling" or v.type == "leveling2" or v.type == "cjms") then
            local voApi = self:getVoApiByType(v.type)
            if(voApi and voApi.tick)then
                self:getVoApiByType(v.type):tick()
            end
        end
        
        if v ~= nil and self:isStart(v) == true and v.needRefresh == true and v.refresh == false and tonumber(base.serverTime) >= tonumber(v.refreshTs) then
            self:getVoApiByType(v.type):refresh()
        end
        if allianceVoApi:isHasAlliance() == true and v ~= nil and self:isStart(v) == true and v.type and v.type == "fundsRecruit" then
            if v.ls == nil or (v.ls ~= nil and (G_getWeeTs(base.serverTime) > v.ls["lg"][3])) then
                local function updateCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        acFundsRecruitVoApi:updateData(sData.data)
                    end
                end
                socketHelper:activeFundsRecruit("updateTime", updateCallback)
            end
        end
        if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
            if v and v.type and v.type == "wheelFortune4" and self:isStart(v) and acRoulette4VoApi then
                -- print("self.callbackNum",self.callbackNum)
                if self.callbackNum < 5 then
                    local isInFreeTime = acRoulette4VoApi:isInFreeTime()
                    -- print("isInFreeTime",isInFreeTime)
                    if isInFreeTime == true then
                        local function activeWheelfortuneCallback(fn, data)
                            local ret, sData = base:checkServerData(data)
                            if ret == true then
                                if sData and sData.data and sData.data.wheelFortune4 and sData.data.wheelFortune4.active then
                                    local updateData = sData.data.wheelFortune4.active
                                    acRoulette4VoApi:updateData(updateData)
                                    acRoulette4VoApi:setFlag(1, 0)
                                end
                            end
                        end
                        socketHelper:activeWheelfortune4(2, nil, activeWheelfortuneCallback)
                        self.callbackNum = self.callbackNum + 1
                    end
                end
            end
        end
        if v and v.type and v.type == "zhenqinghuikui" and self:isStart(v) and acRoulette5VoApi then
            local isInFreeTime = acRoulette5VoApi:isInFreeTime()
            if isInFreeTime == true then
                local function activeZhenqinghuikuiRefreshTime(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData and sData.data and sData.data.zhenqinghuikui then
                            acRoulette5VoApi:addNum()
                            acRoulette5VoApi:tickFreeTime()
                            acRoulette5VoApi:updateDataShow()
                            acRoulette5VoApi:setFlag(1, 0)
                        end
                    end
                end
                socketHelper:activeZhenqinghuikuiRefreshTime("refresh", activeZhenqinghuikuiRefreshTime)
            end
        end
        if v and v.type and v.type == "alienbumperweek" and self:isStart(v) and acAlienbumperweekVoApi then
            -- 判断充值是否跨天
            local lastRechargeWeeTs = acAlienbumperweekVoApi:getLastRechargeWeeTs()
            if lastRechargeWeeTs and G_getWeeTs(lastRechargeWeeTs) ~= G_getWeeTs(base.serverTime) then
                acAlienbumperweekVoApi:changeDayUpdateData()
            end
        end
        if v and v.type and v.type == "ydjl2" and self:isStart(v) and acYueduHeroTwoVoApi then
            -- 判断是否跨天
            local istoday = acYueduHeroTwoVoApi:isToday()
            if istoday then
            else
                acYueduHeroTwoVoApi:kuaTianRefresh()
            end
            
        end
        if v and v.type and v.type == "yuedujiangling" and self:isStart(v) and acYueduHeroVoApi then
            -- 判断是否跨天
            local istoday = acYueduHeroVoApi:isToday()
            if istoday then
            else
                acYueduHeroVoApi:kuaTianRefresh()
            end
            
        end
        if v and v.type and v.type == "christmasfight" and self:isStart(v) and acChristmasFightVoApi and acChristmasFightVoApi.tick then
            acChristmasFightVoApi:tick()
        end
        if v and v.type and v.type == "newyeareva" and self:isStart(v) and acNewYearsEveVoApi and acNewYearsEveVoApi.tick then
            acNewYearsEveVoApi:tick()
        end
        if v and v.type and v.type == "midautumn" and self:isStart(v) and acMidAutumnVoApi and acMidAutumnVoApi.tick then
            acMidAutumnVoApi:tick()
        end
    end
end

-- 数据发生改变，手动重新获取活动数据或更改活动ui
function activityVoApi:updateAc(type)
    local vo = self:getActivityVo(type)
    if vo ~= nil and self:isStart(vo) == true then
        local voApi = self:getVoApiByType(type)
        if voApi ~= nil and voApi.update ~= nil then
            voApi:update()
        end
    end
end

-- 下面两个方法是旧版activityVoApi给newyear用的
function activityVoApi:updateIsReward(data)
    if data == nil then
        if self.allActivity and self.allActivity["newyear"] then
            self.allActivity["newyear"].rewardTs = 0
        end
    else
        for k, v in pairs(data) do
            if v and self.allActivity and self.allActivity[k] then
                self.allActivity[k].rewardTs = tonumber(v)
            end
        end
    end
end

function activityVoApi:canReward(type)
    local voTb = self:getAllActivity()
    if voTb then
        for k, v in pairs(voTb) do
            if v and k == "newyear" and tostring(v.type) == tostring(type) then
                if v.enable == "Y" and v.st < base.serverTime and base.serverTime < v.et and (v.rewardTs == nil or v.rewardTs == 0) then
                    return true
                end
            end
        end
    end
    return false
end

-- 玩家充值成功后，更改相关活动
function activityVoApi:updateByRecharge(addMoney)
    
    local vo = self:getActivityVo("dayRecharge")
    if vo ~= nil and self:isStart(vo) == true then
        acDayRechargeVoApi:addTodayMoney(addMoney)
    end
    
    local voMrcz = self:getActivityVo("mrcz")
    if voMrcz and self:isStart(voMrcz) == true then
        acDailyRechargeByNewGuiderVoApi:addTodayMoney(addMoney)
    end
    
    local vo6 = self:getActivityVo("totalRecharge")
    if vo6 ~= nil and self:isStart(vo6) == true then
        acTotalRechargeVoApi:addTotalMoney(addMoney)
    end
    
    local totalRecharge2 = self:getActivityVo("totalRecharge2")
    if totalRecharge2 ~= nil and self:isStart(totalRecharge2) == true then
        acTotalRecharge2VoApi:addTotalMoney(addMoney)
    end
    
    local totalRecharge3 = self:getActivityVo("kafkagift")
    if totalRecharge3 ~= nil and self:isStart(totalRecharge3) == true then
        acKafkaGiftVoApi:addTotalMoney(addMoney)
    end
    
    local vo1 = self:getActivityVo("dayRechargeForEquip")
    if vo1 ~= nil and self:isStart(vo1) == true then
        acDayRechargeForEquipVoApi:addTodayMoney(addMoney)
    end
    
    local vo2 = self:getActivityVo("rechargeRebate")
    if vo2 ~= nil and self:isStart(vo2) == true then
        acRechargeRebateVoApi:updateRechargeNum(addMoney)
    end
    local vo3 = self:getActivityVo("rechargeDouble")
    if vo3 ~= nil and vo3.over == false and self:isStart(vo3) == true then
        vo3:onRechargeSuccess(addMoney)
    end
    
    local vo4 = self:getActivityVo("userFund")
    if vo4 ~= nil and self:isStart(vo4) == true then
        acUserFundVoApi:addMoney(addMoney)
    end
    
    local vipActionVo = self:getActivityVo("vipAction")
    if vipActionVo ~= nil and self:isStart(vipActionVo) == true then
        acVipActionVoApi:addTodayMoney(addMoney)
    end
    
    local vo5 = self:getActivityVo("investPlan")
    if vo5 ~= nil and self:isStart(vo5) == true then
        acInvestPlanVoApi:addMoney(addMoney)
    end
    
    local vo7 = self:getActivityVo("wheelFortune4")
    if vo7 ~= nil and self:isStart(vo7) == true then
        acRoulette4VoApi:addMoney(addMoney)
    end
    
    local zqhk = self:getActivityVo("zhenqinghuikui")
    
    if zqhk ~= nil and self:isStart(zqhk) == true then
        acRoulette5VoApi:addMoney(addMoney)
    end
    
    local shareHappinessVo = self:getActivityVo("shareHappiness")
    if shareHappinessVo ~= nil and self:isStart(shareHappinessVo) == true then
        acShareHappinessVoApi:addGiftAfterRecharge(addMoney)
    end
    
    local rewardingbackVo = self:getActivityVo("rewardingBack")
    if rewardingbackVo ~= nil and self:isStart(rewardingbackVo) == true then
        acRewardingBackVoApi:updateRechargeGolds(addMoney)
    end
    
    local continueRechargeVo = self:getActivityVo("continueRecharge")
    if continueRechargeVo ~= nil and self:isStart(continueRechargeVo) == true then
        acContinueRechargeVoApi:updateAfterRecharge(addMoney)
    end
    local continueRechargeNewGuidVo = self:getActivityVo("lxcz")
    if continueRechargeNewGuidVo and self:isStart(continueRechargeNewGuidVo) == true then
        acContinueRechargeNewGuidVoApi:updateAfterRecharge(addMoney)
    end
    
    local callsVo = self:getActivityVo("calls")
    if callsVo ~= nil and self:isStart(callsVo) == true then
        self:updateShowState(callsVo)
        callsVo.stateChanged = true -- 强制更新数据
    end
    
    local baifudaliVo = self:getActivityVo("baifudali")
    if baifudaliVo ~= nil and self:isStart(baifudaliVo) == true then
        acBaifudaliVoApi:updateAddGold(addMoney)
        self:updateShowState(baifudaliVo)
        baifudaliVo.stateChanged = true -- 强制更新数据
    end
    
    local shengdankuanghuanVo = self:getActivityVo("shengdankuanghuan")
    if shengdankuanghuanVo ~= nil and self:isStart(shengdankuanghuanVo) == true then
        acShengdankuanghuanVoApi:updateAddGold(addMoney)
        acShengdankuanghuanVoApi:updateShow()
        shengdankuanghuanVo.stateChanged = true -- 强制更新数据
    end
    
    local zhenqinghuikuiVo = self:getActivityVo("zhenqinghuikui")
    if ZhenqinghuikuiVo ~= nil and self:isStart(zhenqinghuikuiVo) == true then
        --强制更新数据
        zhenqinghuikuiVo.stateChanged = true --强制更新数据
    end
    
    local YuanDanXianLiVo = self:getActivityVo("yuandanxianli")
    if YuanDanXianLiVo ~= nil and self:isStart(YuanDanXianLiVo) == true then
        acYuandanxianliVoApi:reFreAllday()
        --强制更新数据
        YuanDanXianLiVo.stateChanged = true --强制更新数据
    end
    
    local shuijinghuikuiVo = self:getActivityVo("shuijinghuikui")
    if shuijinghuikuiVo ~= nil and self:isStart(shuijinghuikuiVo) == true then
        acShuijinghuikuiVoApi:updateRecharge(addMoney)
        --强制更新数据
        shuijinghuikuiVo.stateChanged = true --强制更新数据
    end
    
    local chongzhiyouliVo = self:getActivityVo("chongzhiyouli")
    if chongzhiyouliVo ~= nil and self:isStart(chongzhiyouliVo) == true then
        acChongZhiYouLiVoApi:updateRecharge(addMoney)
        chongzhiyouliVo.stateChanged = true --强制更新数据
    end
    
    local sendGeneralVo = self:getActivityVo("songjiangling")
    if sendGeneralVo ~= nil and self:isStart(sendGeneralVo) == true then
        acSendGeneralVoApi:reFreAllday()
        sendGeneralVo.stateChanged = true
    end
    
    local mayDayVo = self:getActivityVo("xingyunzhuanpan")
    if mayDayVo ~= nil and self:isStart(mayDayVo) == true then
        activityAndNoteDialog:closeAllDialog()
        --acMayDayVoApi:reFreMoneyShow()
        mayDayVo.stateChanged = true
    end
    
    local alienbumperweekVo = self:getActivityVo("alienbumperweek")
    if alienbumperweekVo ~= nil and self:isStart(alienbumperweekVo) == true then
        acAlienbumperweekVoApi:addTotalMoney(addMoney)
    end
    
    local acYueduHeroTwoVo = self:getActivityVo("ydjl2")
    if acYueduHeroTwoVo ~= nil and self:isStart(acYueduHeroTwoVo) == true then
        acYueduHeroTwoVoApi:addGold(addMoney)
    end
    
    local acYueduHeroVo = self:getActivityVo("yuedujiangling")
    if acYueduHeroVo ~= nil and self:isStart(acYueduHeroVo) == true then
        acYueduHeroVoApi:addGold(addMoney)
    end
    local sendAccessoryVo = self:getActivityVo("sendaccessory")
    if sendAccessoryVo ~= nil and self:isStart(sendAccessoryVo) == true then
        
        acPeijianhuzengVoApi:addGold(addMoney)
    end
    local acXingyunpindianVo = self:getActivityVo("xingyunpindian")
    if acXingyunpindianVo ~= nil and self:isStart(acXingyunpindianVo) == true then
        acXingyunpindianVoApi:ChangeAlreadyCost(addMoney)
    end
    local acNewYearVo = self:getActivityVo("newyeargift")
    if acNewYearVo ~= nil and self:isStart(acNewYearVo) == true then
        acNewYearVoApi:onChargeGoldChanged(addMoney)
    end
    local acYijizaitanVo = self:getActivityVo("yijizaitan")
    if acYijizaitanVo ~= nil and self:isStart(acYijizaitanVo) == true then
        eventDispatcher:dispatchEvent("acYijizaitan.recharge", {})
    end
    local acQuanmintankeVo = self:getActivityVo("quanmintanke")
    if acQuanmintankeVo ~= nil and self:isStart(acQuanmintankeVo) == true then
        eventDispatcher:dispatchEvent("acQuanmintanke.recharge", {})
    end
    local acFeixutansuoVo = self:getActivityVo("feixutansuo")
    if acFeixutansuoVo ~= nil and self:isStart(acFeixutansuoVo) == true then
        eventDispatcher:dispatchEvent("acFeixutansuo.recharge", {})
    end
    local acZhanyoujijieVo = self:getActivityVo("zhanyoujijie")
    if acZhanyoujijieVo ~= nil and self:isStart(acZhanyoujijieVo) == true then
        acZhanyoujijieVoApi:addBuyGems(addMoney)
    end
    local acOpenyearVo = self:getActivityVo("openyear")
    if acOpenyearVo ~= nil and self:isStart(acOpenyearVo) == true then
        acOpenyearVoApi:setV(addMoney)
    end
    
    local acLjczVo = self:getActivityVo("ljcz")
    if acLjczVo ~= nil and self:isStart(acLjczVo) == true then
        acLjczVoApi:addTotalMoney(addMoney)
    end
    local acSuperLjczVo = self:getActivityVo("ljcz3")
    if acSuperLjczVo ~= nil and self:isStart(acSuperLjczVo) == true then
        acSuperLjczVoApi:addTotalMoney(addMoney)
    end
    local acYdczVo = self:getActivityVo("ydcz") --月度充值添加充值金币处理
    if acYdczVo ~= nil and self:isStart(acYdczVo) == true then
        acYdczVoApi:addRecharge(addMoney)
    end

    local znjlVo = self:getActivityVo("znjl") --周年锦鲤充值金币后更新状态
    if acZnjlVoApi and znjlVo ~= nil and self:isStart(znjlVo) == true and acZnjlVoApi:isRewardTime() == false then
        --充值后就有了进入锦鲤名单的资格
        acZnjlVoApi:setQualification()
    end
    eventDispatcher:dispatchEvent("activity.recharge", {})
    --[[local customRechargeRebateVo = self:getActivityVo("customRechargeRebate")
    if customRechargeRebateVo ~= nil and self:isStart(customRechargeRebateVo) == true then
        self:updateShowState(customRechargeRebateVo)
        callsVo.stateChanged = true -- 强制更新数据
    end--]]
    
end

-- 主基地升级成功后，更改相关活动
function activityVoApi:updateByBaseUpgradeSuccess()
    local vo = self:getActivityVo("baseLeveling")
    if vo ~= nil and self:isStart(vo) == true and base.serverTime < vo.acEt then
        acBaseLevelingVoApi:UpgradeSuccess()
    end
    
    local levelingVo = self:getActivityVo("leveling")
    if levelingVo ~= nil and self:isStart(levelingVo) == true then
        activityVoApi:updateShowState(levelingVo)
        levelingVo.stateChanged = true
    end
    
    local leveling2Vo = self:getActivityVo("leveling2")
    if leveling2Vo ~= nil and self:isStart(leveling2Vo) == true then
        activityVoApi:updateShowState(leveling2Vo)
        leveling2Vo.stateChanged = true
    end
end

--根据活动名称判断某个活动是否生效
--param actName: 活动的名称
function activityVoApi:checkActivityEffective(actName)
    local vo = activityVoApi:getActivityVo(actName)
    if(vo == nil)then
        return false
    end
    if tonumber(vo.st) <= tonumber(base.serverTime) and tonumber(base.serverTime) < tonumber(vo.acEt) then
        return true
    else
        return false
    end
end

--判断抽奖活动是否使用道具 返回true使用道具 false直接使用金币  updateTime为更新时间戳
function activityVoApi:getLotteryIsUseProp(vo)
    local isUserProp = false
    local updateTime = 1409500800
    if platCfg.platLotteryVersion[G_curPlatName()] and platCfg.platLotteryVersion[G_curPlatName()] == 2 and vo and vo.st > updateTime then
        isUserProp = true
    end
    return isUserProp
end

-- flag 1:add 2 remove
function activityVoApi:addOrRemvoeIcon(flag)
    if not self.allActivity then
        return
    end
    for k, v in pairs(self.allActivity) do
        local voApi = self:getVoApiByType(v.type)
        if flag == 1 then
            if voApi and voApi.addActivieIcon then
                voApi:addActivieIcon()
            end
        else
            if voApi and voApi.removeActivieIcon then
                voApi:removeActivieIcon()
            end
        end
    end
end

--获取活动名称，活动名字不是固定格式的，需要自己特殊处理
function activityVoApi:getActivityName(ackey)
    if ackey then
        return getlocal("activity_"..ackey.."_title")
    end
    return ""
end
