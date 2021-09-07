-- ---------------------------------
-- 英雄擂台枚举
-- hosr
-- ---------------------------------

PlayerkillEumn = PlayerkillEumn or {}

PlayerkillEumn.RankType = {
	World = 1, -- 世界
	Friend = 2, -- 好友
	Server = 3, -- 本服
}

PlayerkillEumn.Status = {
	None = 1, -- 空闲
	Ready = 2, -- 准备
	Running = 3, -- 进行中
}

PlayerkillEumn.StarPos = {
	[0] = {},
	[1] = {Vector3(0, 47, 0)},
	[2] = {Vector3(-30, 40, 0), Vector3(30, 40, 0)},
	[3] = {Vector3(-52, 32, 0), Vector3(0, 47, 0), Vector3(52, 32, 0)},
	[4] = {Vector3(-80, 10, 0), Vector3(-30, 40, 0), Vector3(30, 40, 0), Vector3(80, 10, 0)},
	[5] = {Vector3(-89, 0, 0), Vector3(-52, 32, 0), Vector3(0, 47, 0), Vector3(52, 32, 0), Vector3(89, 0, 0)},
}

PlayerkillEumn.RankTypeName = {
        TI18N("60~64级"),
        TI18N("65~69级"),
        TI18N("70~74级"),
        TI18N("75~79级"),
        TI18N("80~84级"),
        TI18N("85~88级"),
        TI18N("89级"),
        TI18N("90~94级"),
        TI18N("95~99级"),
        TI18N("100~突破99"),
        TI18N("突破100~104"),
        TI18N("突破105~108"),
        TI18N("突破109"),
        TI18N("突破110~119"),
        TI18N("突破120+")
    }

PlayerkillEumn.LevName = {TI18N("一阶"), TI18N("二阶"), TI18N("三阶"), TI18N("四阶"), TI18N("五阶"), TI18N("六阶")}

PlayerkillEumn.MatchStatus = {
	None = 0,
	Matching = 1, -- 匹配中
	MatchSuccess = 2, -- 匹配成功
}

function PlayerkillEumn.GetDefaultMatchRole()
	local unit = {}
	unit.rid = 0
	unit.plat = RoleManager.Instance.RoleData.platform
	unit.classes = math.random(1, 6)
	unit.sex = math.random(1, 2) - 1
	unit.name = "?????"
	unit.looks = {}
	unit.rank_lev = math.random(1, 6)
	unit.star = math.random(1, 5)
	return unit
end

-- 获取自己的所在分组
function PlayerkillEumn.GetSelfGroup()
	local role = RoleManager.Instance.RoleData
	for i,v in ipairs(DataRencounter.data_group) do
		if role.lev_break_times >= v.min_break and role.lev_break_times <= v.max_break then
			if role.lev >= v.min_lev and role.lev <= v.max_lev then
				return v.group
			end
		end
	end
	return 1
end

function PlayerkillEumn.GetRankReward(group, index)
	local myData = PlayerkillManager.Instance.myData
	if myData.rank == 0 and index == nil or index == 0 then
		return 0
	end
    if group == nil then
    	local group = PlayerkillEumn.GetSelfGroup()
    	for i,v in ipairs(DataRencounter.data_rank_reward) do
    		if v.group == group and myData.rank <= v.index then
    			return tonumber(v.rank_reward[1][2])
    		end
    	end
    	return 0
    else
        for i,v in ipairs(DataRencounter.data_rank_reward) do
            if v.group == group and index <= v.index then
                return tonumber(v.rank_reward[1][2])
            end
        end
        return 0
    end
end

-- 赛季时间是本周一到周日
function PlayerkillEumn.GetTime()
	-- local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
 --    local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
 --    local currentMinute = tonumber(os.date("%M", BaseUtils.BASE_TIME))

 --    if currentWeek == 0 then
 --    	currentWeek = 6
 --    else
 --    	currentWeek = currentWeek - 1
 --    end

 --    local startTime = BaseUtils.BASE_TIME - currentWeek * 24 * 60 * 60 - currentHour * 60 * 60
 --    local endTime = BaseUtils.BASE_TIME + (6 - currentWeek) * 24 * 60 * 60

	-- local weekday = os.date("%w", BaseUtils.BASE_TIME)
	-- local minus = 6 - weekday
	-- local plus = (tonumber(weekday) == 0) and 0 or (7 - weekday)
	-- local startTime = BaseUtils.BASE_TIME - minus * 24 * 60 * 60
	-- local endTime = BaseUtils.BASE_TIME + plus * 24 * 60 * 60
    if PlayerkillManager.Instance.timeData ~= nil and PlayerkillManager.Instance.timeData.start_time ~= 0 then
       return string.format("%s-%s", os.date("%Y.%m.%d", PlayerkillManager.Instance.timeData.start_time), os.date("%Y.%m.%d", PlayerkillManager.Instance.timeData.end_time))
    else
	   return TI18N("未开放")
    end
end

-- 赛季时间是本周一到周日
function PlayerkillEumn.GetRankTypeName(lev, lev_break_times)
    for i, v in ipairs(DataRencounter.data_group) do
        if (lev >= v.min_lev and lev_break_times >= v.min_break) and (lev <= v.max_lev and lev_break_times <= v.max_break) then
            return PlayerkillEumn.RankTypeName[v.group], v.group
        end
    end

    return PlayerkillEumn.RankTypeName[2], 2
end