acStormFortressVoApi={}

function acStormFortressVoApi:getAcVo()
	return activityVoApi:getActivityVo("stormFortress")
end
function acStormFortressVoApi:canReward()
	local isfree=false							--是否是第一次免费
	if acStormFortressVoApi:isToday()==false then
		isfree =true
	end
	if isfree ==false then
		local taskRecTb = acStormFortressVoApi:getTaskRecedTb( )
		for k,v in pairs(taskRecTb) do
			if v >0 then
				isfree =true
				do break end
			end
		end
	end
	return isfree
end

function acStormFortressVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acStormFortressVoApi:getTurkeyCfgForShow()
	return {name="millieName",icon="dartIcon.png",des="millieDesc"}
end

function acStormFortressVoApi:updateLastTime(newTime)
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = newTime
	end
end

function acStormFortressVoApi:updateTaskRefTime(newTime)
	local vo = self:getAcVo()
	if vo then
		vo.taskRefTime = newTime
	end
end
function acStormFortressVoApi:isTaskRefTimeToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.taskRefTime then
		isToday=G_isToday(vo.taskRefTime)
	end
	return isToday
end


function acStormFortressVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acStormFortressVoApi:getFN()
	local vo = self:getAcVo()
	if vo and vo.fn then
		return vo.fn
	end
	return 0
end

function acStormFortressVoApi:setFN(fnValue)
	local vo = self:getAcVo()
	if vo then
		 vo.fn=fnValue
	end
end


--------------------------------------------------------------------------getRewardTb
function acStormFortressVoApi:getNowRewardTb()
	local vo = self:getAcVo()
	if vo and vo.getRewardTb then
		local formatReward = G_clone(vo.getRewardTb)
		for k,v in pairs(vo.getRewardTb) do
			G_addPlayerAward(v.type,v.key,v.id,v.num,false,true)
			-- print("v.type,v.key,v.id,v.num--->",v.type,v.key,v.id,v.num)
		end

		return formatReward
	end
	print("数据有问题~~~~~~~~~")
	return  {}
end

function acStormFortressVoApi:setNowRewardTb(getRewardTb)
	local vo = self:getAcVo()
	local bigReward = self:getBigReward()
	local poolReward = self:getPoolReward()
	--
	if SizeOfTable(vo.getRewardTb)>0 then
		vo.getRewardTb ={}
	end
	for k,v in pairs(getRewardTb) do
		for m,n in pairs(v) do
			for i,j in pairs(n) do
				for r,t in pairs(bigReward) do
					if t.key ==i then
						table.insert(vo.getRewardTb,t)
						do break end
					end
				end
				local ii =0
				for mm,nn in pairs(poolReward) do
					if nn.key ==i then
						table.insert(vo.getRewardTb,nn)
						-- print("ii--->",ii)
						-- ii = ii+1
						do break end
					end
				end
			end
		end
	end
end


function acStormFortressVoApi:getIsDied()
	local vo = self:getAcVo()
	if vo and vo.isDied then
		return vo.isDied
	end
	return 0
end

function acStormFortressVoApi:setIsDied(isDied)
	local vo = self:getAcVo()
	if vo then
		 vo.isDied=isDied
	end
end

function acStormFortressVoApi:getWillDied()
	local vo = self:getAcVo()
	if vo and vo.willDie then
		return vo.willDie
	end
	return false
end

function acStormFortressVoApi:setWillDied(willDie)
	local vo = self:getAcVo()
	if vo then
		 vo.willDie=willDie
	end
end


function acStormFortressVoApi:getStormFortressHP( )
	local vo = self:getAcVo()
	if vo and vo.hp then
		return vo.hp
	end
	return 999
end

function acStormFortressVoApi:getFortressHp( )-- 攻击掉的城堡的血量
	local vo = self:getAcVo()
	if vo and vo.deHp then
		return vo.deHp
	end
	return 0
end

function acStormFortressVoApi:getStormFortressLastHp()
	local vo = self:getAcVo()
	if vo and vo.lastDeHp then
		return vo.lastDeHp
	end
	return 0
end

function acStormFortressVoApi:setFortressHp(new_deHp)
	local vo = self:getAcVo()
	if vo then
		 vo.lastDeHp=vo.deHp
		 vo.deHp = new_deHp
	end
end

function acStormFortressVoApi:getBigReward()----击破的大奖
	local vo = self:getAcVo()
	if vo and vo.bigRewardTb then
		local formatReward = FormatItem(vo.bigRewardTb,nil,true)
		return formatReward
	end
	return {}
end

function acStormFortressVoApi:getPoolReward( )----普通奖项
	local vo = self:getAcVo()
	if vo and vo.pool then
		local formatReward = FormatItem(vo.pool,nil,true)
		return formatReward
	end
	return {}
end

function acStormFortressVoApi:getTaskRecedTb( )
	local vo = self:getAcVo()
	if vo and vo.taskRecedTb then
		return vo.taskRecedTb
	end
	return {}
end
function acStormFortressVoApi:setTaskRecedTb(newTaskRecedTb)
	local vo = self:getAcVo()
	if vo then
		if newTaskRecedTb ~=nil then
		 	vo.taskRecedTb = newTaskRecedTb
		 else 
		 	vo.taskRecedTb ={}
		 end
		 self:updateShow()
	end	
end

function acStormFortressVoApi:getTaskAllTb( )
	local vo = self:getAcVo()
	if vo and vo.taskAllTb then
		return vo.taskAllTb
	end
	return {}
end

function acStormFortressVoApi:getNeedBullet( )
	local vo = self:getAcVo()
	if vo and vo.needBullet then
		return vo.needBullet
	end
	return 999
end

function acStormFortressVoApi:getOneCostNeedGold( )
	local vo = self:getAcVo()
	if vo and vo.costOneInGold then
		return vo.costOneInGold
	end
	return 999
end

function acStormFortressVoApi:getTenCostNeedGold( )
	local vo = self:getAcVo()
	if vo and vo.costTenInGold then
		return vo.costTenInGold
	end
	return 999
end

function acStormFortressVoApi:getPicPrice( )
	local vo = self:getAcVo()
	if vo and vo.picPrice then
		return vo.picPrice
	end
	return 999
end

function acStormFortressVoApi:getCurrentBullet( )
	local vo = self:getAcVo()
	if vo and vo.currBullet then
		return vo.currBullet
	end
	return 0
end

function acStormFortressVoApi:getIsMissile( )
	local vo = self:getAcVo()
	if vo and vo.isMissile then
		return vo.isMissile
	end
	return false
end
function acStormFortressVoApi:updateMissile(isfalse,t)
	local vo  = self:getAcVo()
	if vo and vo.isMissile then
		vo.isMissile =true
		if isfalse ==false then
			vo.isMissile =false
		end
	end
	self:updateTaskRefTime(t)-------------------------
end
function acStormFortressVoApi:setCurrentBullet(newCurrBullet)
	local vo = self:getAcVo()
	if vo and newCurrBullet then
		 vo.currBullet = newCurrBullet
	end
end