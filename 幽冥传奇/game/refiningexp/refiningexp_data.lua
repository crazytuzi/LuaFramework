RefiningExpData = RefiningExpData or BaseClass()

RefiningExpData.REFINING_EXP_MSG_CHANGE = "refining_exp_msg_change"

function RefiningExpData:__init()
	if RefiningExpData.Instance then
		ErrorLog("[RefiningExpData] Attemp to create a singleton twice !")
	end

	RefiningExpData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	
end

function RefiningExpData:__delete()
	RefiningExpData.Instance = nil
end


function RefiningExpData:SetRefiningExpMsg(protocol)
	self.refining_exp_msg_list = {}
	self.refining_exp_msg_list.refining_exp_count = protocol.refining_exp_count
	self.refining_exp_msg_list.can_to_level = protocol.can_to_level
	self.refining_exp_msg_list.is_get_award = protocol.is_get_award
	self.refining_exp_msg_list.exp_gold = protocol.exp_gold
	self.refining_exp_msg_list.record_list = protocol.record_list
	self.refining_exp_msg_list.award_gold = protocol.award_gold

	self:DispatchEvent(RefiningExpData.REFINING_EXP_MSG_CHANGE)
end

-- 获取升到多少级
function RefiningExpData:GetCanToLevel()
	return self.refining_exp_msg_list and self.refining_exp_msg_list.can_to_level or RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
end

-- 获取升到多少级
function RefiningExpData:GetCanGetAward()
	return self.refining_exp_msg_list and self.refining_exp_msg_list.is_get_award or 0
end

-- 获取升到多少级
function RefiningExpData:GetExpGold()
	return self.refining_exp_msg_list and self.refining_exp_msg_list.exp_gold or 0
end

-- 获取升到多少级
function RefiningExpData:GetAwardGold()
	return self.refining_exp_msg_list and self.refining_exp_msg_list.award_gold or 0
end

-- 获取目前炼制次数能提升的等级
function RefiningExpData:GetExpTime()
	return self.refining_exp_msg_list and ExpRefiningConfig.ExpRefining[1][self.refining_exp_msg_list.refining_exp_count+1].upLevel or 0
end



-- 获取配置信息
function RefiningExpData:GetCfgData()
	local cfg = ExpRefiningConfig and ExpRefiningConfig.ExpRefining
	if nil == cfg then return end
	local now_day = self:GetNowDay()
	now_day = now_day >= #cfg and #cfg - 1 or now_day
	now_day = now_day < 0 and 0 or now_day

	local exp_cfg = cfg[now_day + 1]
	if nil == exp_cfg then return end

	local count = self.refining_exp_msg_list and self.refining_exp_msg_list.refining_exp_count

	if nil == count or count >= #exp_cfg then
		return {addExp = 0, consume = {type = 15,id = 0,count = 0},}
	end
	count = count < 0 and 0 or count

	return exp_cfg[count + 1]
end

-- 获取最大炼制次数
function RefiningExpData:GetMaxCountDay()
	local cfg = ExpRefiningConfig
	if nil == cfg then return 0 end
	return cfg.maxCountDay
end

-- 获取今天剩下的炼制次数
function RefiningExpData:GetNowCount()
	local count = self.refining_exp_msg_list and self.refining_exp_msg_list.refining_exp_count
	if nil == count then return 0 end
	return self.GetMaxCountDay() - count >= 0 and self.GetMaxCountDay() - count or 0
end

-- 获取开启天数
function RefiningExpData:GetActOpenDay()
	local cfg = ExpRefiningConfig and ExpRefiningConfig.ExpRefining
	if cfg == nil then return 3 end
	return #cfg
end

function RefiningExpData:GetRefiningExpRemainTime()
	local cfg = ExpRefiningConfig
	local open_s_t = TimeUtil.Format2TableDHM(OtherData.Instance.open_server_time)
	local open_server_time = self:GetTimeByYear(nil, nil, open_s_t.day)
	if nil == open_server_time then return end
	
	local hour_shift = tonumber(os.date("%H", open_server_time))
	hour_shift = hour_shift or 0
	
	local shift_day = self:GetActOpenDay()

	-- 北京时区+8h
	-- local remain_time_s = (open_server_time + shift_day * 24 * 60 * 60) - (TimeCtrl.Instance:GetServerTime() + hour_shift * 60 * 60)
	local remain_time_s = (OtherData.Instance.open_server_time + shift_day * 24 * 60 * 60) - TimeCtrl.Instance:GetServerTime()
	if remain_time_s < 0 then remain_time_s = 0 end

	return remain_time_s
end



-- 获取时间(秒)(从1970年1月1日算起)
function RefiningExpData:GetTimeByYear(year, shift_time, shift_day)
	year = year or 1970
	if year < 1970 then return end

	shift_time = shift_time or 0
	shift_day = shift_day or 0

	local day = 0
	for i=year - 1, 1970, -1 do
		if i % 4 == 0 then
			day = day + 366
		else
			day = day + 365
		end
	end

	return day * 24 * 60 * 60 + shift_time + (shift_day * 24 * 60 * 60)
end

function RefiningExpData:GetNowDay()
	local day_max = self:GetActOpenDay()
	local open_server_time = self:GetTimeByYear(nil, nil, TimeUtil.Format2TableDHM(OtherData.Instance.open_server_time).day)
	local hour_shift = tonumber(os.date("%H", open_server_time))
	hour_shift = hour_shift or 0
	local now_time_t = TimeUtil.Format2TableDHMS((TimeCtrl.Instance:GetServerTime() + hour_shift * 60 * 60) - open_server_time)
	
	local now_day = now_time_t.day
	now_day = now_day >= day_max and day_max - 1 or now_day
	now_day = now_day < 0 and 0 or now_day

	return now_day
end

function RefiningExpData:GetExpRecordList()
	local exp_list = {}
	local str = self.refining_exp_msg_list and self.refining_exp_msg_list.record_list
	local tag_t = Split(str, ";")
	for i= #tag_t, 1, -1 do
		local str2 =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str2[1]
		vo.money = str2[2]
		table.insert(exp_list, vo)
	end
	return exp_list
end

-- 功能开启
function RefiningExpData:GetIconIsOpen()
	local remain_time_s = self:GetRefiningExpRemainTime()
	if (remain_time_s and remain_time_s <= 0) or self:GetNowCount() <= 0 then return false end
	return true
end