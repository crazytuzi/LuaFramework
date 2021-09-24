acNewYearsEveVo = activityVo:new()


function acNewYearsEveVo:new()
	local nc = {}
	nc.version = 0 --当前版本
	nc.evaLevel = 0 --当前夕的等级
	nc.cost = nil --三种爆竹打击消耗的金币数
	nc.freeAttackNum = 0 --免费攻击的次数
	nc.attackedCount = 0 --带部队已经攻击的次数
	nc.buyCost = nil --购买带部队攻击次数消耗的金币配置
	nc.saluteAttackedCount = nil --礼炮打击已经攻击的次数
	nc.saluteLimit = nil --礼炮攻击的vip限制
	nc.buff = nil
	nc.rankCount = 0 --伤害排行榜的人数
	nc.perDamageRewards = nil --单次伤害排行榜的奖励配置
	nc.totalDamageRewards = nil --累计伤害排行榜的奖励配置
	nc.totalReviveTime = 0 --夕的总的复活时间
	nc.reviveTime = 0 --当前剩余的复活时间
	nc.attckedHp = 0 --当前已经攻击的血量
	nc.maxHp = 0 --夕总的血量
	nc.oldHp = 0 --之前的血量
	nc.lastAttackTime = 0 --上一次攻击的时间
	nc.lastKillTime = 0 --最后一次击杀的时间，用于计算复活倒计时时间
	nc.bestDamage = 0 --最高伤害值
	nc.customRewards = nil
	nc.specialRewards = nil
	nc.killreward = nil
	nc.paotou = nil
	nc.hasRewardTb = nil
	nc.landform = nil --战斗地形
	nc.rewardPool = nil--奖励库
	setmetatable(nc,self)
	self.__index = self

	return nc
end

--解析来自服务器的活动配置数据
function acNewYearsEveVo:updateSpecialData(data)
	self.acEt=self.et
	if data then
		if data.version then
			self.version = data.version
		end
		if data.cost then
			self.cost = data.cost
		end
		if data.ac then
			self.freeAttackNum = data.ac
		end
		if data.accost then
			self.buyCost = data.accost
		end
		if data.cost3vipLimit then
			self.saluteLimit = data.cost3vipLimit
		end
		if data.buff then
			self.buff = data.buff
		end
		if data.rank then
			self.rankCount = data.rank
		end
		if data.rankReward1 then
			self.perDamageRewards = data.rankReward1
		end
		if data.rankReward2 then
			self.totalDamageRewards = data.rankReward2
		end
		if data.revivetime then
			self.totalReviveTime = data.revivetime
		end
		if data.newyeareva then
			local infoTb = data.newyeareva
			if infoTb.f then
				self.saluteAttackedCount = infoTb.f
			end
			if infoTb.t then
				self.lastAttackTime = infoTb.t
			end
			if infoTb.ac then
				self.attackedCount = infoTb.ac
			end
			if infoTb.h then
				self.bestDamage = infoTb.h
			end
		end
		if data.eva then
			if data.eva[1] then
				self.evaLevel = data.eva[1]
			end
			if data.eva[2] then
				self.maxHp = data.eva[2]
			end
			if data.eva[3] then
				self.attckedHp = data.eva[3]
			end
			if data.eva[4] then
				self.landform = data.eva[4]
			end
			if data.eva[5] then
				self.lastKillTime = data.eva[5]
			end
			if data.eva[6] then
				self.oldHp = data.eva[6]
			end	
		end
		if data.attackHpreward then
			if data.attackHpreward[1] then
				self.customRewards = data.attackHpreward[1]
			end
			if data.attackHpreward[2] then
				self.specialRewards = data.attackHpreward[2]
			end
		end
		if data.paotou then
			self.paotou = data.paotou
		end
		if data.r then
			self.hasRewardTb = data.r
		end
		if data.killreward then
			self.killreward = data.killreward
		end
		if data.allReward then
			self.rewardPool = data.allReward
		end
	end
end

function acNewYearsEveVo:resetAcData()
	self.attackedCount = 0
	if self.saluteAttackedCount ~= nil then
		self.saluteAttackedCount = 0
	end
end