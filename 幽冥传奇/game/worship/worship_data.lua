--支持类型
WORSHIP_SUPPORT_TYPE = {
	DESPISE = 1,		--鄙视
	WORSHIP = 2,		--膜拜
}

--消耗金钱类型
WORSHIP_MONEY_TYPE = {
	BIND_GOLD = 1,			--绑金
	INGOT = 2,				--元宝
}

--膜拜参数枚举
WORSHIP_ENUM = {
	CHENGZHU_NAME = 1,		-- 城主名字
	ACT_TIME = 2,			-- 活动时间
	CHENGZHU_GUILD = 3,		-- 城主行会
	MULTI_RATE = 4,			-- 
	DESPISE_PROGRESS = 5,	-- 拥护率
	WORSHIP_PROGRESS = 6,	-- 反对率
	LEFT_TIMES = 7,			-- 剩余次数
	DAY_GLOD_BENEFIT = 8,	-- 元宝收益
	CHENGZHU_ID = 9,		-- 城主ID
	CHENGZHU_ASSIST_ID = 10,	-- 副城主ID
	IS_RECEIVE = 11,		-- 是否已领取
	
	THIS_TIME_EXP = 100,	-- 本次经验
	TOTAL_EXP = 101,		-- 总经验
}

WorshipData = WorshipData or BaseClass(BseData)

function WorshipData:__init()
	if WorshipData.Instance then
		ErrorLog("[WorshipData] Attemp to create a singleton twice !")
	end
	
	WorshipData.Instance = self
end

function WorshipData:__delete()
	WorshipData.Instance = nil
end


--获取膜拜鄙视奖励
function WorshipData.GetWorshipDespiseAwardCfg()
	return StdActivityCfg[DAILY_ACTIVITY_TYPE.MO_BAI].psmbAward
end

--获取领取奖励时间
function WorshipData.GetWorshipMasterYbTimesCfg()
	return StdActivityCfg[DAILY_ACTIVITY_TYPE.MO_BAI].getMasterYbTimes
end


function WorshipData:GetConsumeCfg()
	return StdActivityCfg[DAILY_ACTIVITY_TYPE.MO_BAI].bindcoinRefresh
end