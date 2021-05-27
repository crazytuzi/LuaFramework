KnightData = KnightData or BaseClass()

function KnightData:__init()
	if KnightData.Instance then
		ErrorLog("[KnightData] attempt to create singleton twice!")
		return
	end
	KnightData.Instance = self
	self.knight_cfg = {}
	self:InitCfgList()
end

function KnightData:__delete()

end

function KnightData:GetRoleCreat()
	local role_creat_day = OtherData.Instance:GetRoleCreatDay()
	local knight_open = KnightErrantCfg.createRoleLimitDay
	local left_day = knight_open - role_creat_day 
	return left_day
end

function KnightData:InitCfgList()
	self.max_chapter = #KnightErrantCfg.clientShow
	self.knight_cfg = {}
	for k,v in ipairs(KnightErrantCfg.chaptersAwards) do
		v.is_open = false --self:LockOpen(v.createRoleOpenDay)
		v.content = KnightErrantCfg.clientShow[k].content
		v.need_remind = false
		v.state = 0
		table.insert(self.knight_cfg, v)
	end
end

function KnightData:UpdateChapterOpenState()
	for k, v in pairs(self.knight_cfg) do
		local data = KnightErrantCfg.chaptersAwards[k]
		if data then
			v.is_open = self:LockOpen(data.createRoleOpenDay)
		end
	end
end

function KnightData:LockOpen(day)
	local role_creat_day = OtherData.Instance:GetRoleCreatDay()
	if role_creat_day > KnightErrantCfg.createRoleLimitDay then
		return false
	end

	return day <= role_creat_day
end

function KnightData:GetKnightChapterCfg()
	for k, v in pairs(self.knight_cfg) do
		v.finish_num = v.finish_num or 0
		v.state = v.state or 0
		v.need_remind = self:IsCurChapNeedRemind(v.content, v.state, v.is_open)
	end
	return self.knight_cfg
end

function KnightData:GetMinRemindDataIndex()
	for k,v in pairs(self.knight_cfg) do
		if v.need_remind then
			return k
		end
	end
end

function KnightData:GetMaxChpater()
	return self.max_chapter
end

function KnightData:KnightProtocolInfo(protocol)
	self.jindu_value = protocol.jindu_value
	for k,v in pairs(protocol.chapeter_list) do
		if self.knight_cfg[v.chaper] then
			local data = self.knight_cfg[v.chaper]
			data.finish_num = v.chaper_jindu 
			data.state = v.state
			data.need_remind = self:IsCurChapNeedRemind(data.content, data.state, data.is_open)
		end
	end
	
end

function KnightData:GetProgressData()
	return self.jindu_value or 0
end

function KnightData:SortListData(data)
	local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
		return function(c, d)
			local achieve_finish_c = AchieveData.Instance:GetAwardState(c.achieveId)
			local achieve_finish_d = AchieveData.Instance:GetAwardState(d.achieveId)
			if achieve_finish_c.reward ~= achieve_finish_d.reward then
				return achieve_finish_c.reward < achieve_finish_d.reward
			elseif achieve_finish_c.reward == 0 then
				if achieve_finish_c.finish ~= achieve_finish_d.finish then
					return achieve_finish_c.finish > achieve_finish_d.finish
				end
			end
			return c.achieveId > d.achieveId
		end
	end
	table.sort(data.content, sort_list()) 
end
function KnightData:IsCurChapNeedRemind(data, state, is_open)
	local need_remind = false
	if is_open == false then
		return need_remind
	end
	for k, v in pairs(data) do
		local achieve_finish = AchieveData.Instance:GetAwardState(v.achieveId)
		if achieve_finish.finish == 1 and achieve_finish.reward == 0 then
			need_remind = true
			break
		end
	end
	need_remind = need_remind and need_remind or state == 1
	return need_remind

end

function KnightData:GetKnightRemindNum()
	local remind_num = 0
	for k, v in pairs(self.knight_cfg) do
		if v.need_remind then
			remind_num = 1
			break
		end
	end

	return remind_num
end

function KnightData:OpenKnight()
	return OtherData.Instance:GetRoleCreatDay() <= KnightErrantCfg.createRoleLimitDay
end

function KnightData:RemindRight(cur_chap)
	local remind_right = nil
	for i=cur_chap,self.max_chapter do
		local data = self.knight_cfg[i]
		if data and data.need_remind then
			remind_right = i
		end
	end
	return remind_right
end


function KnightData:RemindLeft(cur_chap)
	local remind_left = nil
	for i=1,cur_chap do
		local data  = self.knight_cfg[i]
		if data and data.need_remind  then 
			remind_left = i
		end
	end
	return remind_left
end





