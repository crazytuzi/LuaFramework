--[[
    文件名: ActivityConfig.lua
	描述: 精彩活动、限时活动、节日活动、通用活动等的配置信息
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

-- 活动配置中单个条目包含如下信息
--[[
	{
		name = TR("单笔充值"),  	-- 活动的默认名称
		navImg = "xshd_1.png",	-- 活动的默认图片标识
		moduleFile = "activity.ActivityChargeSingle", -- 实现该活动的字页面文件名
	}
]]

require("Config.EnumsConfig")

ActivityConfig = {}

-- 所有精彩活动信息
ActivityConfig[ModuleSub.eExtraActivity] = {
    -- 开工红包
    [ModuleSub.eStartworkReward] = {
        name = TR(""),  -- 活动的默认名称
        navImg = "tb_82.png",    -- 活动的默认图片标识
        moduleFile = "activity.ActivityStartworkRewardLayer", -- 实现该活动的字页面文件名
    },

	-- "成长计划页面"
    [ModuleSub.eExtraActivityGrowPlan] = {
    	name = TR(""),
		navImg = "tb_85.png",
		moduleFile = "activity.ActivityGrowPlanLayer",
    },

    -- "VIP福利页面"
    [ModuleSub.eExtraActivityVIPWelfare] = {
    	name = TR(""),
		navImg = "tb_88.png",
		moduleFile = "activity.ActivityVIPWelfareLayer",
    },

    -- "每日分享页面(又叫礼包兑换)"
    [ModuleSub.eExtraActivityDailyShare] = {
    	name = TR(""),
		navImg = "tb_83.png",
		moduleFile = "activity.ActivityDailyShareLayer",
    },

    -- "至尊盛宴"
    [ModuleSub.eExtraActivityDinner] = {
    	name = TR(""),
		navImg = "tb_89.png",
		moduleFile = "activity.ActivityDinnerLayer",
    },

    -- "月卡"
    [ModuleSub.eExtraActivityMonthCard] = {
    	name = TR(""),
		navImg = "tb_90.png",
		moduleFile = "activity.ActivityMonthCardLayer",
    },

    -- "摇钱树"
    [ModuleSub.eLuckySymbol] = {
    	name = TR(""),
		navImg = "tb_84.png",
		moduleFile = "activity.ActivityLuckySymbolLayer",
    },

    -- "月签到"
    [ModuleSub.eMonthSign] = {
    	name = TR(""),
		navImg = "tb_86.png",
		moduleFile = "activity.ActivityMonthSignLayer",
    },
    -- "十万元宝"
    [ModuleSub.eShiWanYuanBao] = {
        name = TR(""),
        navImg = "tb_79.png",
        moduleFile = "activity.ActivityRewardLoginDaysLayer",
    },
    -- "QQ分享"
    [ModuleSub.ePrivilege] = {
        name = TR(""),
        navImg = "qq_10.png",
        moduleFile = "activity.QQShareLayer",
    },

  --   -- "天天基金"
  --   [ModuleSub.eExtraActivityDayDayFund] = {
  --    name = TR("天天基金"),
        -- navImg = "tb_146.png",
        -- moduleFile = "activity.ActivityDayDayFundLayer",
  --   },

  --   -- "好友邀请页面"
  --   [ModuleSub.eExtraActivityInviteFriend] = {
  --    name = TR("好友邀请"),
        -- navImg = "",
        -- moduleFile = "activity.ActivityInviteFriendLayer",
  --   },

  --   -- "微信关注"
  --   [ModuleSub.eExtraActivityWeChat] = {
  --   	name = TR(""),
		-- navImg = "",
		-- moduleFile = "activity.ActivityWeChatLayer",
  --   },

    -- "限时招摹页面"
  --   [ModuleSub.eExtraActivityLimitTime] = {
  --       name = TR(""),
  --       navImg = "",
  --       moduleFile = "",
  --   },

  --   -- "每日分享页面_微信"
  --   [ModuleSub.eDailyShareWX] = {
  --   	name = TR(""),
		-- navImg = "",
		-- moduleFile = "",
  --   },

  --   -- "每日分享页面_微博"
  --   [ModuleSub.eDailyShareWB] = {
  --   	name = TR(""),
		-- navImg = "",
		-- moduleFile = "",
  --   },

}

-- 所有限时活动信息
ActivityConfig[ModuleSub.eTimedActivity] = {
	-- "限时-单笔充值"
	[ModuleSub.eTimedChargeSingle] = {
		name = TR("单笔充值"),  -- 活动的默认名称
		navImg = "tb_93.png",	-- 活动的默认图片标识
		moduleFile = "activity.ActivityChargeSingleLayer",-- 实现该活动的字页面文件名
	},

	-- "限时-累计充值"
    [ModuleSub.eTimedChargeTotal] = {
    	name = TR("累计充值"),
		navImg = "tb_96.png",
		moduleFile = "activity.ActivityChargeTotalLayer",
    },

    -- "限时-累积消费"
    [ModuleSub.eTimedUseTotal] = {
    	name = TR("累积消费"),
		navImg = "tb_98.png",
		moduleFile = "activity.ActivityUseTotalLayer",
    },

    -- "限时-招募"
    [ModuleSub.eTimedRecruit] = {
    	name = TR("限时招募"),
		navImg = "tb_172.png",
		moduleFile = "activity.ActivityRecruitLayer",
    },

    -- "限时-累计充值天数"
    [ModuleSub.eChargeDays] = {
    	name = TR("累充天数"),
		navImg = "tb_99.png",
		moduleFile = "activity.ActivityChargeDaysLayer",
    },

    -- "限时-兑换"
    [ModuleSub.eTimedExchange] = {
    	name = TR("礼包兑换"),
		navImg = "tb_92.png",
		moduleFile = "activity.ActivityExchangeLayer",
    },

    -- "许愿树"
  --   [ModuleSub.eTimedWishingTree] = {
  --   	name = TR(""),
		-- navImg = "",
		-- moduleFile = "activity.ActivityWishingTreeLayer",
  --   },

    -- "限时-招财树"
    [ModuleSub.eTimedMoneyTree] = {
        name = TR("招财树"),
        navImg = "tb_102.png",
        moduleFile = "activity.ActivityMoneyTreeLayer",
    },

    -- "限时-砸金蛋活动"
    [ModuleSub.eTimedSmashingEggs] = {
        name = TR("砸金蛋"),
        navImg = "tb_101.png",
        moduleFile = "activity.ActivitySmashingLayer",
    },

    -- "限时-累计登录"
    [ModuleSub.eTimedAcumulateLogin] = {
        name = TR("累计登录"),
        navImg = "tb_97.png",
        moduleFile = "activity.ActivityAcumulateLoginLayer",
    },

    -- "限时-积分商城"
    [ModuleSub.eTimedPointsMall] = {
        name = TR("积分商城"),
        navImg = "tb_95.png",
        moduleFile = "activity.ActivityPointsMallLayer",
    },

    -- "限时-新累计充值"
    [ModuleSub.eTimedAcumulateCharge] = {
        name = TR(""),
        navImg = "",
        moduleFile = "activity.ActivityAcumulateChargeLayer",
    },

    -- "宝库抽奖"
    [ModuleSub.eTimedLuckDraw] = {
    	name = TR("宝库抽奖"),
		navImg = "tb_91.png",
		moduleFile = "activity.ActivityLuckDrawLayer",
    },

    -- "福利多多-天道榜"
    [ModuleSub.eTimedWelfareMaxJJC] = {
    	name = TR(""),
		navImg = "tb_94.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-传承之战"
    [ModuleSub.eTimedWelfareMaxDWDH] = {
    	name = TR(""),
		navImg = "tb_94.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-丹神古墓"
    [ModuleSub.eTimedWelfareMaxYCJK] = {
    	name = TR(""),
		navImg = "tb_94.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-装备召唤打折"
    [ModuleSub.eTimedWelfareMaxEquip] = {
    	name = TR(""),
		navImg = "tb_94.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-人物召唤打折"
    [ModuleSub.eTimedWelfareMaxHero] = {
    	name = TR(""),
		navImg = "tb_94.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-装备合成暴击"
    [ModuleSub.eTimedWelfareEquipCompareCrid]= {
    	name = TR(""),
		navImg = "tb_94.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-装备召唤暴击"
    [ModuleSub.eTimedWelfareEquipCallCrid] = {
    	name = TR(""),
		navImg = "tb_94.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-装备中心战功翻倍"
    [ModuleSub.eTimedWelfareMaxBDD] = {
    	name = TR(""),
		navImg = "tb_94.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-BOSS战特殊掉落"
    [ModuleSub.eTimedBossDrop] = {
    	name = TR(""),
		navImg = "jrhd_33.png",
		moduleFile = "activity.ActivityBossDropLayer",
    },

    -- "福利多多-光明顶翻倍"
    [ModuleSub.eTimedSalesRebornCoin] = {
        name = TR(""),
        navImg = "tb_134.png",
        moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "福利多多-地宫翻倍"
    [ModuleSub.eTimedSalesSectPalace] = {
        name = TR(""),
        navImg = "tb_134.png",
        moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "限时-团购"
    [ModuleSub.eTimedGroupBuy] = {
        name = TR("团购活动"),
        navImg = "tb_197.png",
        moduleFile = "activity.ActivityGroupBuy",
    },

    -- "限时-每日挑战"
    [ModuleSub.eTimedDailyChallenge] = {
        name = TR("每日挑战"),
        navImg = "tb_197.png",
        moduleFile = "activity.ActivityDailyTaskLayer",
    },

    -- "双倍元宝"
    [ModuleSub.eTimeDoubleDiamond] = {
        name = TR(""),
        navImg = "",
        moduleFile = "",
    },
    -- "限时-充值夺宝"
    [ModuleSub.eTimedRechargeTheTreasure] = {
        name = TR("充值夺宝"),
        navImg = "tb_225.png",
        moduleFile = "activity.ActivityRechargeTheTreasureLayer",
    },

    -- "限时秒杀"
    -- [ModuleSub.eTimedMiaoSha] = {
    --     name = TR("限时秒杀"),
    --     navImg = "tb_176.png",
    --     moduleFile = "activity.ActivityTimeSeckill",
    -- },
}

-- 所有通用活动信息
ActivityConfig[ModuleSub.eCommonHoliday] = {
	-- "通用活动-累计充值"
    [ModuleSub.eCommonHoliday1] = {
    	name = TR("累计充值"),
		navImg = "tb_150.png",
		moduleFile = "activity.ActivityChargeTotalLayer",
    },

    -- "通用活动-单笔充值"
    [ModuleSub.eCommonHoliday2] = {
    	name = TR("单笔充值"),
		navImg = "tb_141.png",
		moduleFile = "activity.ActivityChargeSingleLayer",
    },

    -- "通用活动-礼包兑换"
    [ModuleSub.eCommonHoliday3] = {
    	name = TR("礼包兑换"),
		navImg = "tb_143.png",
		moduleFile = "activity.ActivityExchangeLayer",
    },

    -- "通用活动-宝库抽奖"
    [ModuleSub.eCommonHoliday4] = {
    	name = TR("宝库抽奖"),
		navImg = "tb_176.png",
		moduleFile = "activity.ActivityLuckDrawLayer",
    },

    -- "通用节日-灵玉矿"
    [ModuleSub.eCommonHoliday5] = {
    	name = TR(""),
		navImg = "",
		moduleFile = "",
    },

    -- "通用节日-砸金蛋"
    [ModuleSub.eCommonHoliday6] = {
    	name = TR("砸金蛋"),
		navImg = "tb_152.png",
		moduleFile = "activity.ActivitySmashingLayer",
    },
}

-- 所有节日活动信息
ActivityConfig[ModuleSub.eChristmasActivity] = {
	-- "圣诞活动-累计充值"
	[ModuleSub.eChristmasActivity1] = {
    	name = TR("累计充值"),
		navImg = "tb_96.png",
		moduleFile = "activity.ActivityChargeTotalLayer",
    },

	-- "圣诞活动-单笔充值"
    [ModuleSub.eChristmasActivity2] = {
    	name = TR("单笔充值"),
		navImg = "tb_93.png",
		moduleFile = "activity.ActivityChargeSingleLayer",
    },

    -- "圣诞活动-礼包兑换"
    [ModuleSub.eChristmasActivity3] = {
    	name = TR("礼包兑换"),
		navImg = "tb_143.png",
		moduleFile = "activity.ActivityExchangeLayer",
    },

    -- "圣诞活动-宝库抽奖"
    [ModuleSub.eChristmasActivity4] = {
    	name = TR("宝库抽奖"),
		navImg = "tb_176.png",
		moduleFile = "activity.ActivityLuckDrawLayer",
    },

    -- "圣诞活动-招财树"
    [ModuleSub.eChristmasActivity5] = {
    	name = TR("招财树"),
		navImg = "tb_151.png",
		moduleFile = "activity.ActivityMoneyTreeLayer",
    },

    -- "圣诞活动-砸金蛋"
    [ModuleSub.eChristmasActivity6] = {
    	name = TR("砸金蛋"),
		navImg = "tb_152.png",
		moduleFile = "activity.ActivitySmashingLayer",
    },

    -- "节日活动-累计登录"
    [ModuleSub.eChristmasActivity8] = {
    	name = TR("累计登录"),
		navImg = "tb_179.png",
		moduleFile = "activity.ActivityAcumulateLoginLayer",
    },

    -- "节日活动-累积消费"
    [ModuleSub.eChristmasActivity9] = {
    	name = TR("累积消费"),
		navImg = "tb_153.png",
		moduleFile = "activity.ActivityUseTotalLayer",
    },

    -- "节日活动-BOSS掉落"
    [ModuleSub.eChristmasActivity10] = {
    	name = TR(""),
		navImg = "tb_158.png",
		moduleFile = "activity.ActivityWelfareLayer",
    },

    -- "节日活动-积分商城"
    [ModuleSub.eChristmasActivity11] = {
    	name = TR("积分商城"),
		navImg = "tb_182.png",
		moduleFile = "activity.ActivityPointsMallLayer",
    },

    -- "节日活动-新累计充值"
    [ModuleSub.eChristmasActivity12] = {
    	name = TR(""),
		navImg = "",
		moduleFile = "activity.ActivityAcumulateChargeLayer",
    },

    -- "节日活动-全民铸剑开启"
    [ModuleSub.eChristmasActivity14] = {
        name = TR("铸倚天"),
        navImg = "jrhd_32.png",
        moduleFile = "festival.NationalZYTLayer",
    },

    -- "节日活动-全民铸剑奖励"
    [ModuleSub.eTimedHolidayDrop] = {
        name = TR("限时掉落"),
        navImg = "jrhd_31.png",
        moduleFile = "festival.NationalTimeDropLayer",
    },

    -- "节日活动-全民铸剑绝学展示"
    [ModuleSub.eChristmasActivity16] = {
        name = TR("限时绝学"),
        navImg = "jrhd_28.png",
        moduleFile = "festival.NationalFashionLayer",
    },

    --"节日活动-元旦祈福"
    [ModuleSub.eChristmasActivity17] = {
        name = TR("元旦祈福"),
        navImg = "tb_230.png",
        moduleFile = "festival.ThanksGivingLayer",
    },
}

-- 相同类型的活动需要在同一个页面显示的活动类型列表
ActivityConfig.ShareLayerActivity = {
	[ModuleSub.eChargeDays] = true, -- "限时-累计充值天数"
	-- ...
}

-- 福利多多 活动类型
ActivityConfig.Welfare = {
    -- "福利多多-天道榜"
    [ModuleSub.eTimedWelfareMaxJJC] = true,
    -- "福利多多-传承之战"
    [ModuleSub.eTimedWelfareMaxDWDH] = true,
    -- "福利多多-丹神古墓"
    [ModuleSub.eTimedWelfareMaxYCJK] = true,
    -- "福利多多-装备召唤打折"
    [ModuleSub.eTimedWelfareMaxEquip] = true,
    -- "福利多多-人物召唤打折"
    [ModuleSub.eTimedWelfareMaxHero] = true,
    -- "福利多多-装备合成暴击"
    [ModuleSub.eTimedWelfareEquipCompareCrid] = true,
    -- "福利多多-装备召唤暴击"
    [ModuleSub.eTimedWelfareEquipCallCrid] = true,
    -- "福利多多-装备中心战功翻倍"
    [ModuleSub.eTimedWelfareMaxBDD] = true,
    -- "福利多多-BOSS战特殊掉落"
    -- [ModuleSub.eTimedBossDrop] = true,
    -- "福利多多-光明顶翻倍"
    [ModuleSub.eTimedSalesRebornCoin] = true,
    -- "福利多多-门派地宫产出翻倍"
    [ModuleSub.eTimedSalesSectPalace] = true,
}

-- 活动主模块Id
ActivityConfig.MainActivity = {
    ModuleSub.eExtraActivity,   -- 精彩活动
    ModuleSub.eTimedActivity,   -- 限时活动
    ModuleSub.eCommonHoliday,   -- 通用活动
    ModuleSub.eChristmasActivity,-- 节日活动
}

-- 获取活动所属的主模块Id
--[[
-- 参数
    moduleSub: 子模块Id
-- 返回值
    如果该模块Id所属活动的某模块，则返回其主模块Id，否则为nil
]]
function ActivityConfig.getMainModuleSub(moduleSub)
    for mainModuleId, configItem in pairs(ActivityConfig.MainActivity) do
        local hadFound = false
        if moduleSub == mainModuleId then
            return mainModuleId
        end

        for key, item in pairs(ActivityConfig[configItem]) do
            if key == moduleSub then
                hadFound = true
                break
            end
        end
        if hadFound then
            return mainModuleId
        end
    end

    return nil
end
