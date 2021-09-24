acMoveForwardVoApi={}

function acMoveForwardVoApi:canReward()
	local acVo=self:getAcVo()
	if(acVo)then
		if(acVo.progressTotal and acVo.totalCfg)then
			for k,v in pairs(acVo.progressTotal) do
				if(v.f~=1)then
					for kk,vv in pairs(acVo.totalCfg) do
						if(k==vv.id)then
							if(v.n>=vv.num)then
								return true
							end
						end
					end
				end
			end
		end
		if(acVo.progressDaily and acVo.dailyCfg)then
			for k,v in pairs(acVo.dailyCfg) do
				if((acVo.progressDaily.f==nil or acVo.progressDaily.f[v.id]~=1) and acVo.progressDaily.n and acVo.progressDaily.n>=v.num)then
					return true
				end
			end
		end
		return false
	else
		return false
	end
end

function acMoveForwardVoApi:getAcVo()
	local acVo=activityVoApi:getActivityVo("yongwangzhiqian")
	if(acVo.lastBattleTs==nil or acVo.lastBattleTs<G_getWeeTs(base.serverTime))then
		if(acVo.progressDaily)then
			acVo.progressDaily.n=0
			acVo.progressDaily.f={}
		end
	end
	return acVo
end

--param type: 1 领取关卡通过奖励 2 领取每日任务奖励
--param sid: s1，s2  领取第几关的奖励
function acMoveForwardVoApi:getReward(type,sid,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local acVo=self:getAcVo()
			if(acVo)then
				local awardTab
				if(type==1)then
					if(acVo.progressTotal[sid])then
						acVo.progressTotal[sid].f=1
					else
						acVo.progressTotal[sid]={f=1}
					end
					local index
					for k,v in pairs(acVo.totalCfg) do
						if(v.id==sid)then
							index=k
							break
						end
					end
					awardTab=FormatItem(acVo.totalCfg[index].reward,true)
				else
					if(acVo.progressDaily.f)then
						acVo.progressDaily.f[sid]=1
					else
						acVo.progressDaily.f={}
						acVo.progressDaily.f[sid]=1
					end
					local index
					for k,v in pairs(acVo.dailyCfg) do
						if(v.id==sid)then
							index=k
							break
						end
					end
					awardTab=FormatItem(acVo.dailyCfg[index].reward,true)
				end				
				G_showRewardTip(awardTab)
				activityVoApi:updateShowState(acVo)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:activityMoveForwardReward(type,sid,onRequestEnd)
end