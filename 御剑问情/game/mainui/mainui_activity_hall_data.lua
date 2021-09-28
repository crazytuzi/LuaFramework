MainuiActivityHallData = MainuiActivityHallData or BaseClass()

function MainuiActivityHallData:__init()
	if MainuiActivityHallData.Instance ~= nil then
		ErrorLog("[MainuiActivityHallData] Attemp to create a singleton twice !")
	end

	MainuiActivityHallData.Instance = self
	self.flag_shouw = {}
	self.act_times = {}
end

function MainuiActivityHallData:__delete()
	MainuiActivityHallData.Instance = nil
end

-- 设置活动特效出现次数
function MainuiActivityHallData:SetShowOnceEff(act_type,flag_shouw)
	self.flag_shouw[act_type] = flag_shouw
end

function MainuiActivityHallData:GetShowOnceEff(act_type)
	if nil ~= self.flag_shouw[act_type] then
		return self.flag_shouw[act_type]
	end
	return true
end

-- 随机活动倒计时
function MainuiActivityHallData:SetActTime(act_type,act_time)
	self.act_times[act_type] = act_time
end

function MainuiActivityHallData:GetActTime(act_type)
	if nil ~= self.act_times[act_type] then
		return self.act_times[act_type]
	end
	return 0
end

function MainuiActivityHallData:FlushActRedPoint()
	local data_list = ActivityData.Instance:GetActivityHallDatalist()
	for k,v in pairs(data_list) do
		if v.type == ACTIVITY_TYPE.RAND_JINYINTA then
			-- 金银塔
			JinYinTaData.Instance:FlushHallRedPoindRemind()
		elseif v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT then

		end
	end
end