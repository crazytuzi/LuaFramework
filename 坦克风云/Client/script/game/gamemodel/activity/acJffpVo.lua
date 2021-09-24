acJffpVo=activityVo:new()
function acJffpVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end
--i:排序，t:每日可完成次数，s:每次完成获得分数
 -- l登录,ab攻打关卡,a攻打一次玩家，eb攻打一次补给线,su精炼一次配件
 -- qe 强化配件，ge 改造配件，bs 进攻海德拉,ar 军事演习，aw 军团战占领一次据点
 -- ex 远征 ，al 赠送一次异星资源 wp 抢一次碎片
function acJffpVo:updateSpecialData(data)
	if data.version ~= nil then
		self.version = data.version
	end
	if data.consume ~= nil then--活动配置
		self.consume = data.consume
	end
	if data.cost ~= nil then--每次抽奖消耗多少
		self.cost = data.cost
	end
	if data.version ~= nil then
		self.version = data.version
	end
	if data.n ~= nil then
		self.n = data.n
	end
	if data.reward ~= nil then
		self.reward = data.reward
	end
	-- 最多可以抽取几次
	if data.count ~= nil then
		self.count = data.count
	end
end
