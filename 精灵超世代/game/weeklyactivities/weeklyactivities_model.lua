-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
WeeklyActivitiesModel = WeeklyActivitiesModel or BaseClass()

function WeeklyActivitiesModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function WeeklyActivitiesModel:config()
	self.weekly_activity_data = {}
	self.weekly_exchange_data = {}
	self.weekly_task_data = {}
end

function WeeklyActivitiesModel:setWeeklyActivityData( data )
	self.weekly_activity_data = data
end

--判断周活动是否开启
function WeeklyActivitiesModel:checkActivityOpen()
	if not self.weekly_activity_data then return false end
	local time = self.weekly_activity_data.end_time-GameNet:getInstance():getTime()
	if time > 0 then
		return true
	end
	return false
end

--获得日常任务活跃度奖励道具
function WeeklyActivitiesModel:getDailyAwards(activity)
	if not self.weekly_activity_data then return {} end
	local id = self.weekly_activity_data.activity_id
	local data = Config.WeekActData.data_weekly_reward_info[id]
	local items ={}
	local limitlv = data[activity] and data[activity].limitlv
	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo.lev < limitlv then
		return {}
	end
	items = data[activity] and data[activity].day_reward
	return items
end

function WeeklyActivitiesModel:setWeeklyTaskData( data )
	self.weekly_task_data = data
end

--获取当前活动id 1地宫 2灵泉 3石室
function WeeklyActivitiesModel:getWeeklyActivityId()
	return self.weekly_activity_data.activity_id
end

function WeeklyActivitiesModel:setCultivateCount( num )
	self.weekly_activity_data.cultivate_count = num
end

function WeeklyActivitiesModel:getCultivateCount(  )
	return self.weekly_activity_data.cultivate_count or 0
end

function WeeklyActivitiesModel:setExchangeData( data )
	if data and data.activity_id then
		for i,v in pairs(self.weekly_exchange_data) do
			if v.activity_id ==  data.activity_id then
				self.weekly_exchange_data[i] = data
				return
			end
		end
		table.insert(self.weekly_exchange_data, data)
	end
end

function WeeklyActivitiesModel:getExchangeData()
	return self.weekly_exchange_data
end

function WeeklyActivitiesModel:getWeeklyActivityData( )
	 return	self.weekly_activity_data
end

function WeeklyActivitiesModel:getWeeklyTaskData( )
	 return	self.weekly_task_data
end

function WelfareModel:__delete()
end