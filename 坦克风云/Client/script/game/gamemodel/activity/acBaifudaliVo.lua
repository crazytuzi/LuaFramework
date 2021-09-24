acBaifudaliVo = activityVo:new()

function acBaifudaliVo:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acBaifudaliVo:updateSpecialData( data )
	
	if self.version==nil then 
		self.version = data.version
	end

	if data.goldcondition then
		self.goldAction = data.goldcondition--充值返利的条件3000
	end

	if data.goldreward then
		self.goldReward = data.goldreward--充值返利奖励
	end

	if  data.daily then
		self.daily = data.daily--每日奖励
	end

	if  data.repairVate then
		self.repairVate = data.repairVate--修理坦克减少的金币或者晶石消耗 减少50%
	end

	if self.levelLimit == nil then  --每日领取奖励的等级限制
		self.levelLimit = data.levellimit
	end

	if data.m then 
		self.isRecGold=data.m  --是否领取金币奖励(1:领取)
	end

	if data.v then
		self.addGold = data.v --充值的金币记录
	end

	if data.t  then  --每日领取奖励时间标识
		self.time = data.t
	end


end