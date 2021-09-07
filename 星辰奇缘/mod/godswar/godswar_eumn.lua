-- --------------------------
-- 诸神之战枚举
-- hosr
-- --------------------------
GodsWarEumn = GodsWarEumn or {}

-- -define(cross_warlord_quality_create, 0). %% 组件未报名
-- -define(cross_warlord_quality_sign, 1). %% 已报名
-- -define(cross_warlord_quality_256, 2). %%  小组赛
-- -define(cross_warlord_quality_64, 3). %% 淘汰赛64强
-- -define(cross_warlord_quality_32, 4). %% 淘汰赛32强
-- -define(cross_warlord_quality_16, 5). %% 淘汰赛16强
-- -define(cross_warlord_quality_8, 6). %% 淘汰赛8强
-- -define(cross_warlord_quality_4, 7). %% 淘汰赛4强
-- -define(cross_warlord_quality_third_place, 8). %% 亚军争夺
-- -define(cross_warlord_quality_fourth, 9). %% 第四名
-- -define(cross_warlord_quality_third, 10). %% 季军
-- -define(cross_warlord_quality_champion_place, 11). %% 决赛资格
-- -define(cross_warlord_quality_second, 12). %% 亚军
-- -define(cross_warlord_quality_champion, 13). %% 冠军
-- 战队资格
GodsWarEumn.Quality = {
	Create = 0,
	Sign = 1,
	Q256 = 2,
	Q64 = 3,
	Q32 = 4,
	Q16 = 5,
	Q8 = 6,
	Q4 = 7,
	ThirdPlace = 8,
	Fourth = 9,
	Third = 10,
	ChampionPlace = 11,
	Second = 12,
	Champion = 13,
}

-- {"准备阶段", 1}
-- ,{"报名阶段", 2}
-- ,{"公示阶段", 3}
-- ,{"海选场1空闲", 4}
-- ,{"海选场1", 5}
-- ,{"海选场2空闲", 6}
-- ,{"海选场2", 7}
-- ,{"海选场3空闲", 8}
-- ,{"海选场3", 9}
-- ,{"海选场4空闲", 10}
-- ,{"海选场4", 11}
-- ,{"海选场5空闲", 12}
-- ,{"海选场5", 13}
-- ,{"海选场6空闲", 14}
-- ,{"海选场6", 15}
-- ,{"海选场7空闲", 16}
-- ,{"海选场7", 17}
-- ,{"32强赛空闲", 18}
-- ,{"32强赛", 19}
-- ,{"16强赛空闲", 20}
-- ,{"16强赛", 21}
-- ,{"8强赛空闲", 22}
-- ,{"8强赛", 23}
-- ,{"4强赛空闲", 24}
-- ,{"4强赛", 25}
-- ,{"半决赛空闲", 26}
-- ,{"半决赛", 27}
-- ,{"季军赛空闲", 28}
-- ,{"季军赛", 29}
-- ,{"决赛空闲", 30}
-- ,{"决赛", 31}
-- ,{"赛季后", 32}
-- 活动阶段
GodsWarEumn.Step = {
	None = 0,
	Prepare = 1, -- 准备阶段
	Sign = 2, --报名阶段
	Publicity = 3, --公示阶段
	Audition1Idel = 4, --海选场1
	Audition1 = 5, --海选场1
	Audition2Idel = 6, --海选场2
	Audition2 = 7, --海选场2
	Audition3Idel = 8, --海选场3
	Audition3 = 9, --海选场3
	Audition4Idel = 10, --海选场4
	Audition4 = 11, --海选场4
	Audition5Idel = 12, --海选场5
	Audition5 = 13, --海选场5
	Audition6Idel = 14, --海选场6
	Audition6 = 15, --海选场6
	Audition7Idel = 16, --海选场7
	Audition7 = 17, --海选场7
	Elimination32Idel = 18, --32强赛
	Elimination32 = 19, --32强赛
	Elimination16Idel = 20, --16强赛
	Elimination16 = 21, --16强赛
	Elimination8Idel = 22, --8强赛
	Elimination8 = 23, --8强赛
	Elimination4Idel = 24, --4强赛
	Elimination4 = 25, --4强赛
	SemifinalIdel = 26, -- 半决赛
	Semifinal = 27, -- 半决赛
	ThirdfinalIdel = 28, -- 季军赛
	Thirdfinal = 29, -- 季军赛
	FinalIdel = 30, -- 决赛
	Final = 31, -- 决赛
	FinalOff = 32, -- 赛季后
    ChallengeIdel = 33, --诸神挑战空闲
    Challenge = 34, --诸神挑战

}

-- 活动阶段名称
GodsWarEumn.StepName = {
    [1] = "准备阶段",
    [2] = "报名阶段",
    [3] = "公示阶段",
    [4] = "第一轮",
    [5] = "第一轮",
    [6] = "第二轮",
    [7] = "第二轮",
    [8] = "第三轮",
    [9] = "第三轮",
    [10] = "第四轮",
    [11] = "第四轮",
    [12] = "第五轮",
    [13] = "第五轮",
    [14] = "第六轮",
    [15] = "第六轮",
    [16] = "第七轮",
    [17] = "第七轮",
    [18] = "64进32",
    [19] = "64进32",
    [20] = "32进16",
    [21] = "32进16",
    [22] = "16进8",
    [23] = "16进8",
    [24] = "8进4",
    [25] = "8进4",
    [26] = "半决赛",
    [27] = "半决赛",
    [28] = "季军赛",
    [29] = "季军赛",
    [30] = "决赛",
    [31] = "决赛",
    [32] = "赛季后",
    [33] = "诸神挑战",
    [34] = "诸神挑战",

}

-- 成员身份
GodsWarEumn.Position = {
	Applyer = 0, -- 申请人
	Captin = 1,  -- 队长
	Member = 2,  -- 成员
	Standby = 3, -- 替补
}

-- GodsWarEumn.GroupName = {
-- 	TI18N("半神组(80-89级)"),
-- 	TI18N("真神组(90-突破99)"),
-- 	TI18N("主神组(突破100+)"),
-- }

-- GodsWarEumn.GroupNameSample = {
-- 	TI18N("半神组"),
-- 	TI18N("真神组"),
-- 	TI18N("主神组"),
-- }

-- function GodsWarEumn.GroupName(group_id)
-- 	for key, value in pairs(DataGodsDuel.data_gruop) do
-- 		if group_id == value.group_id then
-- 			return value.name
-- 		end
-- 	end
-- 	return ""
-- end

function GodsWarEumn.GroupName(index)
	for key, value in pairs(DataGodsDuel.data_gruop) do
		if index == value.index then
			return value.name
		end
	end
	return ""
end

function GodsWarEumn.GroupNameSample(index)
	for key, value in pairs(DataGodsDuel.data_gruop) do
		if index == value.index then
			return value.name_sample
		end
	end
	return ""
end

function GodsWarEumn.GroupNum()
	local maxIndex = 0
	for key, value in pairs(DataGodsDuel.data_gruop) do
		if maxIndex < value.index then
			maxIndex = value.index
		end
	end
	return maxIndex
end

function GodsWarEumn.GetGruopLev(group_id)
	local name = ""
	local max_lev = 0
	local max_break = 0
	local min_lev = 999999
	local min_break = 999999
	for key, value in pairs(DataGodsDuel.data_gruop) do
		if group_id == value.group_id then
			name = value.name
			if max_lev <= value.lev_max and max_break <= value.break_times then
				max_lev = value.lev_max
				max_break = value.break_times
			end
			if min_lev >= value.lev_min and min_break >= value.break_times then
				min_lev = value.lev_min
				min_break = value.break_times
			end
		end
	end

	return { name = name, max_lev = max_lev, max_break = max_break, min_lev = min_lev, min_break = min_break }
end

function GodsWarEumn.Group(lev, break_times)
	local group = 1
	for key, value in pairs(DataGodsDuel.data_gruop) do
		if lev >= value.lev_min and lev <= value.lev_max and break_times == value.break_times then
			group = value.group_id
		end
	end
	return group
end

-- function GodsWarEumn.Group(lev, break_times)
-- 	local group = 1
-- 	break_times = break_times or 0
-- 	if break_times == 0 and lev >= 80 and lev <= 89 then
-- 		group = 1
-- 	elseif break_times == 0 and lev >= 90 and lev <= 100 then
-- 		group = 2
-- 	elseif break_times == 1 and lev >= 90 and lev <= 99 then
-- 		group = 2
-- 	elseif break_times == 1 and lev >= 100 then
-- 		group = 3
-- 	end
-- 	return group
-- end

function GodsWarEumn.Round(status)
	local round = 1
	if status <= GodsWarEumn.Step.Audition1 then
		round = 1
	elseif status <= GodsWarEumn.Step.Audition2 then
		round = 2
	elseif status <= GodsWarEumn.Step.Audition3 then
		round = 3
	elseif status <= GodsWarEumn.Step.Audition4 then
		round = 4
	elseif status <= GodsWarEumn.Step.Audition5 then
		round = 5
	elseif status <= GodsWarEumn.Step.Audition6 then
		round = 6
	elseif status <= GodsWarEumn.Step.Audition7 then
		round = 7
	elseif status <= GodsWarEumn.Step.Elimination32 then
		round = 1
	elseif status <= GodsWarEumn.Step.Elimination16 then
		round = 2
	elseif status <= GodsWarEumn.Step.Elimination8 then
		round = 3
	elseif status <= GodsWarEumn.Step.Elimination4 then
		round = 4
	else
		round = 0
	end
	return round
end

function GodsWarEumn.MatchName(status)
	if status >= GodsWarEumn.Step.ChallengeIdel then
		return TI18N("诸神挑战")
	elseif status >= GodsWarEumn.Step.FinalIdel then
		return TI18N("决赛")
	elseif status >= GodsWarEumn.Step.ThirdfinalIdel then
		return TI18N("季军赛")
	elseif status >= GodsWarEumn.Step.SemifinalIdel then
		return TI18N("半决赛")
	elseif status > GodsWarEumn.Step.Audition7 then
		return TI18N("淘汰赛")
	else
		return TI18N("小组赛")
	end
end

function GodsWarEumn.ShowStr()
	local round = GodsWarEumn.Round(GodsWarManager.Instance.status)
	if round == 0 then
		return string.format(TI18N("<color='#ffff00'>%s</color>"), GodsWarEumn.MatchName(GodsWarManager.Instance.status))
	else
		return string.format(TI18N("<color='#ffff00'>%s</color>第<color='#ffff00'>%s</color>轮"), GodsWarEumn.MatchName(GodsWarManager.Instance.status), round)
	end
end

function GodsWarEumn.MatchTime(status)
	local s = math.max(status, 4)
	if s % 2 == 0 then
		s = s + 1
	end
	local str = ""
	for i,v in ipairs(GodsWarManager.Instance.godwarTimeData) do
		if v.state_code == s then
			local start_y = tonumber(os.date("%Y", v.start_time))
        	local start_m = tonumber(os.date("%m", v.start_time))
        	local start_d = tonumber(os.date("%d", v.start_time))
       	 	local start_h = tonumber(os.date("%H",v.start_time))
        	local start_mini = tonumber(os.date("%M",v.start_time))
        	local start_s = tonumber(os.date("%S",v.start_time))

        	local end_y = tonumber(os.date("%Y", v.end_time))
        	local end_m = tonumber(os.date("%m", v.end_time))
        	local end_d = tonumber(os.date("%d", v.end_time))
       	 	local end_h = tonumber(os.date("%H",v.end_time))
        	local end_mini = tonumber(os.date("%M",v.end_time))
        	local end_s = tonumber(os.date("%S",v.end_time))


			str = string.format("%s月%s日 %s:%s-%s:%s", GodsWarEumn.Format(start_m), GodsWarEumn.Format(start_d), GodsWarEumn.Format(start_h), GodsWarEumn.Format(start_mini), GodsWarEumn.Format(end_h), GodsWarEumn.Format(end_mini))
		end
	end
	return str
end

function GodsWarEumn.Format(val)
	val = tonumber(val)
	if val < 10 then
		return "0" .. val
	end
	return val
end

GodsWarEumn.EliminationName = {
	TI18N("疾风战区"),
	TI18N("秘林战区"),
	TI18N("奥火战区"),
	TI18N("群山战区"),
	TI18N("真水战区"),
	TI18N("后土战区"),
	TI18N("锐金战区"),
	TI18N("雷霆战区"),
}

GodsWarEumn.ZoneName = {"A区", "B区", "C区", "D区"}

-- 是否完成本轮比赛
function GodsWarEumn.IsCompleteRount()
	-- local data = GodsWarManager.Instance.myData
	-- if data == nil then
	-- 	return true
	-- end

	-- local status = GodsWarManager.Instance.status
	-- local count = data.win_times + data.loss_times
	-- if status == GodsWarEumn.Step.Audition1 and count == 1 then
	-- 	return true
	-- elseif status == GodsWarEumn.Step.Audition2 and count == 2 then
	-- 	return true
	-- elseif status == GodsWarEumn.Step.Audition3 and count == 3 then
	-- 	return true
	-- elseif status == GodsWarEumn.Step.Audition4 and count == 4 then
	-- 	return true
	-- elseif status == GodsWarEumn.Step.Audition5 and count == 5 then
	-- 	return true
	-- elseif status == GodsWarEumn.Step.Audition6 and count == 6 then
	-- 	return true
	-- elseif status == GodsWarEumn.Step.Audition7 and count == 7 then
	-- 	return true
	-- end
	local data = GodsWarManager.Instance.readyData
	if data ~= nil and data.status == 2 then
		return true
	end
	return false
end

-- 是否是对战进行中
function GodsWarEumn.IsFighting()
	local status = GodsWarManager.Instance.status
	if status == GodsWarEumn.Step.Audition1 then
		return true
	elseif status == GodsWarEumn.Step.Audition2 then
		return true
	elseif status == GodsWarEumn.Step.Audition3 then
		return true
	elseif status == GodsWarEumn.Step.Audition4 then
		return true
	elseif status == GodsWarEumn.Step.Audition5 then
		return true
	elseif status == GodsWarEumn.Step.Audition6 then
		return true
	elseif status == GodsWarEumn.Step.Audition7 then
		return true
	elseif status == GodsWarEumn.Step.Elimination32 then
		return true
	elseif status == GodsWarEumn.Step.Elimination16 then
		return true
	elseif status == GodsWarEumn.Step.Elimination8 then
		return true
	elseif status == GodsWarEumn.Step.Elimination4 then
		return true
	elseif status == GodsWarEumn.Step.Semifinal then
		return true
	elseif status == GodsWarEumn.Step.Thirdfinal then
		return true
	elseif status == GodsWarEumn.Step.Final then
		return true
	else
		return false
	end
end

GodsWarEumn.PositionIndex = {
	{1, 37, 17, 53, 9, 45, 25, 61},
	{5, 41, 21, 57, 13, 49, 29, 33},
	{3, 39, 19, 35, 11, 47, 27, 63},
	{7, 43, 23, 59, 15, 51, 31, 55},
	{2, 38, 18, 54, 10, 46, 26, 62},
	{6, 42, 22, 58, 14, 50, 30, 34},
	{4, 40, 20, 56, 12, 48, 28, 64},
	{8, 44, 24, 60, 16, 52, 32, 36},
}

function GodsWarEumn.PosDataIndex(group)
	return GodsWarEumn.PositionIndex[group]
end

function GodsWarEumn.GroupIndex(team_group_64)
	if team_group_64 == 1 or team_group_64 == 37 or team_group_64 == 17 or team_group_64 == 53 or team_group_64 == 9 or team_group_64 == 45 or team_group_64 == 25 or team_group_64 == 61 then
		return 1
	elseif team_group_64 == 5 or team_group_64 == 41 or team_group_64 == 21 or team_group_64 == 57 or team_group_64 == 13 or team_group_64 == 49 or team_group_64 == 29 or team_group_64 == 33 then
		return 2
	elseif team_group_64 == 3 or team_group_64 == 39 or team_group_64 == 19 or team_group_64 == 35 or team_group_64 == 11 or team_group_64 == 47 or team_group_64 == 27 or team_group_64 == 63 then
		return 3
	elseif team_group_64 == 7 or team_group_64 == 43 or team_group_64 == 23 or team_group_64 == 59 or team_group_64 == 15 or team_group_64 == 51 or team_group_64 == 31 or team_group_64 == 55 then
		return 4
	elseif team_group_64 == 2 or team_group_64 == 38 or team_group_64 == 18 or team_group_64 == 54 or team_group_64 == 10 or team_group_64 == 46 or team_group_64 == 26 or team_group_64 == 62 then
		return 5
	elseif team_group_64 == 6 or team_group_64 == 42 or team_group_64 == 22 or team_group_64 == 58 or team_group_64 == 14 or team_group_64 == 50 or team_group_64 == 30 or team_group_64 == 34 then
		return 6
	elseif team_group_64 == 4 or team_group_64 == 40 or team_group_64 == 20 or team_group_64 == 56 or team_group_64 == 12 or team_group_64 == 48 or team_group_64 == 28 or team_group_64 == 64 then
		return 7
	elseif team_group_64 == 8 or team_group_64 == 44 or team_group_64 == 24 or team_group_64 == 60 or team_group_64 == 16 or team_group_64 == 52 or team_group_64 == 32 or team_group_64 == 36 then
		return 8
	end
end

function GodsWarEumn.GroupIndex2(team_group_64)
	if team_group_64 == 1 or team_group_64 == 37 or team_group_64 == 17 or team_group_64 == 53 or team_group_64 == 9 or team_group_64 == 45 or team_group_64 == 25 or team_group_64 == 61 then
		return 1
	elseif team_group_64 == 5 or team_group_64 == 41 or team_group_64 == 21 or team_group_64 == 57 or team_group_64 == 13 or team_group_64 == 49 or team_group_64 == 29 or team_group_64 == 33 then
		return 1
	elseif team_group_64 == 3 or team_group_64 == 39 or team_group_64 == 19 or team_group_64 == 35 or team_group_64 == 11 or team_group_64 == 47 or team_group_64 == 27 or team_group_64 == 63 then
		return 2
	elseif team_group_64 == 7 or team_group_64 == 43 or team_group_64 == 23 or team_group_64 == 59 or team_group_64 == 15 or team_group_64 == 51 or team_group_64 == 31 or team_group_64 == 55 then
		return 2
	elseif team_group_64 == 2 or team_group_64 == 38 or team_group_64 == 18 or team_group_64 == 54 or team_group_64 == 10 or team_group_64 == 46 or team_group_64 == 26 or team_group_64 == 62 then
		return 3
	elseif team_group_64 == 6 or team_group_64 == 42 or team_group_64 == 22 or team_group_64 == 58 or team_group_64 == 14 or team_group_64 == 50 or team_group_64 == 30 or team_group_64 == 34 then
		return 3
	elseif team_group_64 == 4 or team_group_64 == 40 or team_group_64 == 20 or team_group_64 == 56 or team_group_64 == 12 or team_group_64 == 48 or team_group_64 == 28 or team_group_64 == 64 then
		return 4
	elseif team_group_64 == 8 or team_group_64 == 44 or team_group_64 == 24 or team_group_64 == 60 or team_group_64 == 16 or team_group_64 == 52 or team_group_64 == 32 or team_group_64 == 36 then
		return 4
	end
end

function GodsWarEumn.GroupIndex3(team_group_64)
	if team_group_64 == 1 or team_group_64 == 37 or team_group_64 == 17 or team_group_64 == 53 or team_group_64 == 9 or team_group_64 == 45 or team_group_64 == 25 or team_group_64 == 61 then
		return 1
	elseif team_group_64 == 5 or team_group_64 == 41 or team_group_64 == 21 or team_group_64 == 57 or team_group_64 == 13 or team_group_64 == 49 or team_group_64 == 29 or team_group_64 == 33 then
		return 1
	elseif team_group_64 == 3 or team_group_64 == 39 or team_group_64 == 19 or team_group_64 == 35 or team_group_64 == 11 or team_group_64 == 47 or team_group_64 == 27 or team_group_64 == 63 then
		return 1
	elseif team_group_64 == 7 or team_group_64 == 43 or team_group_64 == 23 or team_group_64 == 59 or team_group_64 == 15 or team_group_64 == 51 or team_group_64 == 31 or team_group_64 == 55 then
		return 1
	elseif team_group_64 == 2 or team_group_64 == 38 or team_group_64 == 18 or team_group_64 == 54 or team_group_64 == 10 or team_group_64 == 46 or team_group_64 == 26 or team_group_64 == 62 then
		return 2
	elseif team_group_64 == 6 or team_group_64 == 42 or team_group_64 == 22 or team_group_64 == 58 or team_group_64 == 14 or team_group_64 == 50 or team_group_64 == 30 or team_group_64 == 34 then
		return 2
	elseif team_group_64 == 4 or team_group_64 == 40 or team_group_64 == 20 or team_group_64 == 56 or team_group_64 == 12 or team_group_64 == 48 or team_group_64 == 28 or team_group_64 == 64 then
		return 2
	elseif team_group_64 == 8 or team_group_64 == 44 or team_group_64 == 24 or team_group_64 == 60 or team_group_64 == 16 or team_group_64 == 52 or team_group_64 == 32 or team_group_64 == 36 then
		return 2
	end
end

function GodsWarEumn.ExceptStep(type)
    return type == 4
    	or type == 6
    	or type == 8
    	or type == 10
    	or type == 12
    	or type == 14
    	or type == 16
    	or type == 18
    	or type == 20
    	or type == 22
    	or type == 24
    	or type == 26
    	or type == 28
    	or type == 30
    	or type == 32
end
