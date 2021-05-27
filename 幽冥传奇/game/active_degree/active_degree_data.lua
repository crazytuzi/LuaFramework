-- 活跃度
ActiveDegreeData = ActiveDegreeData or BaseClass()

function ActiveDegreeData:__init()
	if ActiveDegreeData.Instance then
		ErrorLog("[ActiveDegreeData]:Attempt to create singleton twice!")
	end
	ActiveDegreeData.Instance = self
	self.daily_data =  {}
	self.daily_cound = 0
end

function ActiveDegreeData:__delete()
	--ActiveDegreeData.Instance = nil
end

function ActiveDegreeData.GetAddActiveDegreeCountList()
	data = LivenessActivityCfg.clientShow or {}
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)		-- 人物转生等级
	for k,v in pairs(LivenessActivityCfg and LivenessActivityCfg.clientShow or {}) do
		if circle_level >= v.levelLimit[1] and role_level >= v.levelLimit[2] then
			v.is_lev = 1
		else
			v.is_lev = 0
		end
	end
	return data 
end



function ActiveDegreeData:SetVitalityAcitivityInfromation(protocol)
	self.daily_cound = protocol.activedegree
	self.daily_data = protocol.complete_info_t
end

function ActiveDegreeData:GetDailyCound()
	return self.daily_cound
end

function ActiveDegreeData:GetDailyData()
	return self.daily_data
end

function ActiveDegreeData:GetActiveIconRemindNum()
	local n = 0 
	for k, v in pairs(self.daily_data) do
		if v.state_get == 1 then 
			n =  n + 1
		end
	end
	return  n > 0 and 1 or 0
end

function ActiveDegreeData:GetOneAchieveCfgByAchiID(achieveId)
	return AchieveData.GetAchieveConfig(achieveId) and AchieveData.GetAchieveConfig(achieveId)[1]
end

function ActiveDegreeData:IsDisplay()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if level < 60 then
		return false
	else
		return true
	end
end

function ActiveDegreeData:GetActiveDegreeNum(activedegree)
	local reward_data, reward_num = {}, 0
	local open_days =  OtherData.Instance:GetOpenServerDays()
	for k,v in pairs(LivenessActivityCfg.dailyActivityAwards) do		
		if k == activedegree then
			reward_num = v.ActivityNum
			for i1, v2 in ipairs(v.awards) do
				if open_days >= v2.cond[1] and open_days <= v2.cond[2] then
					for k3,v3 in pairs(v2.dailyAwards) do
						reward_data[k3] = {item_id = v3.id, num = v3.count, is_bind = v3.bind}
					end
				end
			end	
		end
	end
	return reward_data, reward_num
end
