acStormFortressVo = activityVo:new()

function acStormFortressVo:updateSpecialData(data)
	if data.t then
		self.lastTime =data.t
	end
	if data.t then
		self.taskRefTime =data.t
	end
	
	if data.picPrice then
		self.picPrice = data.picPrice
	end
	if data.propCost1 then
		self.needBullet=data.propCost1[2]
	end
	if data.goldCost1 then
		self.costOneInGold =data.goldCost1[2]
	end
	if data.goldCost10 then
		self.costTenInGold =data.goldCost10[2]
	end

	if data.missile then
		self.currBullet =data.missile
	end
	if self.currBullet ==nil then
		self.currBullet =0
	end

	if data.missileTask then
		self.taskAllTb= data.missileTask
	end

	if data.d and data.d.task then
		self.taskRecedTb=data.d.task
	end

	if data.reward then
		if data.reward.fortressReward then
			self.bigRewardTb = data.reward.fortressReward
		end
		if data.reward.pool then
			self.pool =data.reward.pool
		end
	end

	if data.deHp then -- 攻击掉的城堡的血量
		self.deHp = data.deHp
	end
	if self.deHp ==nil then
		self.deHp =0
	end
	if self.deHp then --活动登入 保存上次总共的掉血量
		self.lastDeHp =self.deHp
	end

	if data.hp then --碉堡总血量
		self.hp =data.hp
	end

	if data.destroyed then
		self.isDied =data.destroyed
	end
	if self.isDied==nil then
		self.isDied =0
	end

	if self.getRewardTb==nil then
		self.getRewardTb ={}
	end

	if self.isMissile ==nil then
		self.isMissile =false
	end

	if self.willDie==nil then
		self.willDie =false
	end
	if data.d and data.d.fn then
		self.fn =data.d.fn
	end
	if self.fn ==nil then
		self.fn =0
	end
end