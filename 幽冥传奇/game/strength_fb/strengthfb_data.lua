StrenfthFbData = StrenfthFbData or BaseClass()

StrenfthFbData.SweepCountMax = 5
StrenfthFbData.ChestStageShift = 5
StrenfthFbData.PerChapStageNum = 5
STRENFTHFB_MAX_GRADE = 3
function StrenfthFbData:__init()
	if StrenfthFbData.Instance then
		ErrorLog("[StrenfthFbData] Attemp to create a singleton twice !")
	end
	
	StrenfthFbData.Instance = self
	self.fuben_page = nil 
	self.fuben_info = {}
	self.star_reward_state  = {}
	self.remain_time = 0
	self.grid_data ={}
	self.strength_fb_data, self.tollgate_cnt = StrenfthFbData.InitStrengthFbData()
	self.sweep_chapter = 0
	self.sweep_shut = 0
	self.sweep_time = 0
	self.sweep_sucess = 0
end

function StrenfthFbData:__delete()
	StrenfthFbData.Instance = nil
end

function StrenfthFbData:SetfuBenData(protocol)
	self.fuben_page = protocol.fuben_page
	self.fuben_info = protocol.fuben_info
	self.star_reward_state  = protocol.star_reward_state
	for i,v in ipairs(self.strength_fb_data) do
		if i == protocol.fuben_page then
			for i1, v1 in ipairs(v) do
				for i2, v2 in ipairs(protocol.fuben_info) do
					if i1 == i2 then
						v1.stars = v2.tongguan_star
						v1.time = v2.fight_time
					end
				end
			end
		end
	end
end

function StrenfthFbData.InitStrengthFbData()
	local strength_fb_data = {}
	local tollgate_cnt = (AllDayCfg[1] and AllDayCfg[1].Checkpoint) and #AllDayCfg[1].Checkpoint or 5
	for i, v in ipairs(AllDayCfg) do
		strength_fb_data[i] = {}
		for i1, v1 in ipairs(v.Checkpoint) do
			strength_fb_data[i][i1] = {}
			strength_fb_data[i][i1] = {
				page = i,
				index = i1,
				min_level = v.level,
				name = v1.name, 
				consumeid = v1.consume and v1.consume[1] and v1.consume[1].id or 2,
				consume_num = v1.consume and v1.consume[1] and v1.consume[1].count or 0,
				stars = 0,
				my_time = v1.Count,
				time = 0,
				awrad = v1.ShowAward and v1.ShowAward[1],
				monster = v1.Monsters[#v1.Monsters] and v1.Monsters[#v1.Monsters].monsterId,
				limit_level = v1.Level,
				icon = v1.Icon,
			}
		end
	end
	return strength_fb_data, tollgate_cnt
end

function StrenfthFbData:SetFubenEndData(protocol)
	for i, v in ipairs(self.strength_fb_data) do
		if i == protocol.fuben_page then
			for i1, v1 in ipairs(v) do
				if i1 == protocol.fuben_pos then
					v1.stars = protocol.tongguan_star
					v1.time = v1.time + 1
				end
			end
		end
	end
end

-- 扫荡副本
function StrenfthFbData:SetSweepFuben(protocol)
	self.sweep_chapter = protocol.sweep_chapter			-- 第几章
	self.sweep_shut = protocol.sweep_shut				-- 第几关
	self.sweep_time = protocol.sweep_time				-- 几次
	self.sweep_sucess = protocol.sweep_sucess			-- 1成功 0失败
	for i, v in ipairs(self.strength_fb_data) do
		if i == protocol.sweep_chapter then
			for i1, v1 in ipairs(v) do
				if i1 == protocol.sweep_shut then
					v1.time = v1.time + protocol.sweep_time
				end
			end
		end
	end
end

function StrenfthFbData:GetTotalData()
	return self.strength_fb_data
end

function StrenfthFbData:GetSweepSucess()
	return self.sweep_sucess
end

--得到该章的次数
function StrenfthFbData:GetAllStarNum()
	local star = 0 
	for i, v in ipairs(self.fuben_info) do
		star = star + v.tongguan_star
	end
	return star
end

--得到是否满足条件
function StrenfthFbData:GetBoolShowEffect(cur_page)
	local star = StrenfthFbData.Instance:GetAllStarNum()
	local data = {}
	local cur_cfg = AllDayCfg[cur_page] and AllDayCfg[cur_page].AwardCfg
	if cur_cfg then
		for i = 1, #cur_cfg do
			if star >= cur_cfg[i].myStar then
				data[i] = 1
			else
				data[i] = 0
			end
		end
	end
	return data
end

function StrenfthFbData:GetReward(fuben_page, fuben_pos)
	local reward_data = {}
	for i,v in ipairs(AllDayCfg) do
		if i == fuben_page then
			for i1, v1 in ipairs(v.Checkpoint) do
				if i1 == fuben_pos then
					reward_data = v1.ShowAward and v1.ShowAward[1] or {}
				end
			end
		end
	end
	return reward_data
end

function StrenfthFbData:GetSuccessReward(fuben_page, fuben_pos, star)
	local reward_data = {}
	local cfg = (AllDayCfg[fuben_page] and AllDayCfg[fuben_page].Checkpoint and AllDayCfg[fuben_page].Checkpoint[fuben_pos] and 
		AllDayCfg[fuben_page].Checkpoint[fuben_pos].Awards) and AllDayCfg[fuben_page].Checkpoint[fuben_pos].Awards[star]
	if cfg then
		reward_data = cfg.Award or {}
	end
	return reward_data
end

function StrenfthFbData:GetDoubleLinQuConsume(fuben_page, fuben_pos)
	return (AllDayCfg[fuben_page] and AllDayCfg[fuben_page].Checkpoint and 
		AllDayCfg[fuben_page].Checkpoint[fuben_pos] and AllDayCfg[fuben_page].Checkpoint[fuben_pos].timesconsume) and 
		AllDayCfg[fuben_page].Checkpoint[fuben_pos].timesconsume[1].count or 0
end

function StrenfthFbData:GetConsumeLevel(fuben_page)
	local level = 0
	local circel_level = 0 
	local cfg = AllDayCfg[fuben_page] and AllDayCfg[fuben_page].level
	if cfg then
		level = cfg[2]
		circel_level = cfg[1]
	end
	return level, circel_level
end

function StrenfthFbData:GetGiftState()
	return self.star_reward_state
end

function StrenfthFbData:GetCurPage()
	return self.fuben_page
end

function StrenfthFbData:GetTimeCfg(page)
	return (AllDayCfg[page] and AllDayCfg[page].Star) and AllDayCfg[page].Star[1] or 300
end

function StrenfthFbData:GetStarNum(page, time)
	local n = 0
	local cfg = AllDayCfg[page] and AllDayCfg[page].Star
	if cfg then
		local use_time = cfg[1] - time
		if use_time < cfg[3] then
			n = 3
		elseif use_time >= cfg[3] and use_time < cfg[2] then
			n = 2
		elseif use_time >= cfg[2] and use_time < cfg[1] then
			n = 1 
		end
	end
	return n
end

function StrenfthFbData:ReturnId()
	local id = AllDayCfg[1] and AllDayCfg[1].Checkpoint[1].consume[1].id
	return id
end

function StrenfthFbData:GetClearanceIndex(page)
	local data = self.strength_fb_data[page]
	for i = 1, self.tollgate_cnt do
		if data[i-1] and data[i-1].stars > 0 and data[i] and data[i].stars == 0 then
			return i
		elseif data[1] and data[1].stars == 0 then
			return 1
		end
	end
end

function StrenfthFbData:GetShowEffect(page)
	local data_1 = self.strength_fb_data[page -1] 
	local data_2 = self.strength_fb_data[page]
	local m = 0 
	local n = 0
	if data_1 == nil then
		return true
	else
		for i,v in ipairs(data_1) do
			if v.stars > 0 then
				m = m + 1
			end
		end
		for i,v in ipairs(data_2) do
			if v.stars > 0 then
				n = n + 1
			end
		end
	end
	if m == 6 and n < 6 then
		return true
	else
		return false
	end
end

function StrenfthFbData:GetClearCurPage()
	for i = 1, #self.strength_fb_data do
		local data_1 = self.strength_fb_data[i]
		local data_2 = self.strength_fb_data[i + 1]
		local m = 0
		local n = 0
		for i,v in ipairs(data_1) do
			if v.stars > 0 then
				m = m + 1
			end
		end
		if data_2 ~= nil then
			for i,v in ipairs(data_2) do
				if v.stars > 0 then
					n = n + 1
				end
			end
			if m == 6 and n < 6 then
				return i + 1
			elseif m < 6 and n < 6 then
				return  i
			end
		else
			return #self.strength_fb_data
		end
	end
end

function StrenfthFbData:GetRewardByStar(page, stage)
	local reward_data = {}
	local achieve_num = 0
	local cur_cfg = AllDayCfg[page] and AllDayCfg[page].AwardCfg and AllDayCfg[page].AwardCfg[stage]
	if cur_cfg then
		achieve_num = cur_cfg.myStar
		reward_data = ItemData.AwardsToItems(cur_cfg.Award)
	end
	return reward_data, achieve_num
end

function StrenfthFbData:GetStarPercent(page)
	local data = AllDayCfg[page] and AllDayCfg[page].Star
	local percent_1 =  0
	local percent_2 =  (data[1] -  data[2])/ (data[1] or 1) or 0.6
	local percent_3 =  (data[1] -  data[3])/ (data[1] or 1) or 0.7
	return {percent_1, percent_2, percent_3}
end
