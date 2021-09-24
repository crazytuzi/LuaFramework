acDailyEquipPlanVo = activityVo:new()

function acDailyEquipPlanVo:new()
	local nc = {}

	nc.version=0 --当前版本
	nc.tasklistCfg={}
	nc.taskData={}

	setmetatable(nc,self)
	self.__index = self

	return nc
end

--解析来自服务器的活动配置数据
function acDailyEquipPlanVo:updateSpecialData(data)
	if data then
		if data.version then
			self.version = data.version
		end
		if data.tasklist then
			self.tasklistCfg=data.tasklist
		end
		if data.task then
			self.taskData=data.task
		end
		-- if data.t then
		-- 	print("最后一次触发任务的时间：",G_getDataTimeStr(data.t))
		-- end
	end
end