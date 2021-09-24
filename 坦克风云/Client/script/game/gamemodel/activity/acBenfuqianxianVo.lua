acBenfuqianxianVo = activityVo:new()

function acBenfuqianxianVo:new()
	local nc={}

	nc.version=0 --当前版本
	nc.reward={} --对应积分的奖励
	nc.flickReward={} --贵重物品
	nc.need={} --对应积分额度
	nc.task={} 	--任务配置 --第一个字段：任务类型 t1:攻打玩家，t2:攻打野外资源点，t3:协防次数，t4:获得军功点数，t5:充值金币
				--第二个字段：任务上限
				--第三个字段为X，代表每做一次任务，所获得任务点数
	nc.needNotice={} --需要发公告的配置
	nc.integral=0 --当前积分
	nc.taskData={} --任务数据
	nc.hasRewardTb={} --已经领取的奖励

	setmetatable(nc,self)
	self.__index=self

	return nc
end

--解析来自服务器的活动配置数据
function acBenfuqianxianVo:updateSpecialData(data)
	if data then
		if data.version then
			self.version=data.version
		end
		if data.reward then
			self.reward=data.reward
		end
		if data.flickReward then
			self.flickReward=data.flickReward
		end
		if data.need then
			self.need=data.need
		end
		if data.task then
			self.task=data.task
		end
		if data.needNotice then
			self.needNotice=data.needNotice
		end
		if data.point then
			self.integral=data.point
		end
		if data.d then
			self.taskData=data.d
		end
		if data.r then
			self.hasRewardTb=data.r
		end
	end
end