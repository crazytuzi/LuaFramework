acQuanmintankeVoApi = {}

function acQuanmintankeVoApi:getAcVo()
	return activityVoApi:getActivityVo("quanmintanke")
end

function acQuanmintankeVoApi:getLastResultByLine(line)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.lastResult[line]
	end
	return 1
end

function acQuanmintankeVoApi:updateLastResult(result)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.lastResult = result
	end
end

function acQuanmintankeVoApi:getPicById(id)
	if id == 1 then
		return "tianjiangxiongshi_h.png"
	elseif id == 2 then
		return "tianjiangxiongshi_r.png"
	elseif id == 3 then
		return "tianjiangxiongshi_m.png"
	elseif id == 4 then
		return "tianjiangxiongshi_k.png"
	else
		return "tianjiangxiongshi_h.png"
	end
end

function acQuanmintankeVoApi:getCost(num)
	local vo = self:getAcVo()
	local cost = 99999
	if num==1 then
		cost = vo.cost1
	elseif num==2 then
		cost = vo.cost1*vo.mulc
	elseif num==3 then
		 cost = vo.cost3
	elseif num==4 then
		cost = vo.cost3*vo.mulc
	end
	if cost<1 then
		cost=1
	end
	return cost
end

function acQuanmintankeVoApi:getVipCost(num)
	local Vipdiscoun = self:getVipdiscoun()
	local vipLevel = playerVoApi:getVipLevel()
	local disCost = vipLevel*Vipdiscoun

	local vo = self:getAcVo()
	local cost = 99999
	if num==1 then
		cost = vo.cost1-disCost
	elseif num==2 then
		cost = (vo.cost1-disCost)*vo.mulc
	elseif num==3 then
		 cost = vo.cost3-disCost
	elseif num==4 then
		cost = (vo.cost3-disCost)*vo.mulc
	end
	if cost<1 then
		cost=1
	end

	return cost
end

function acQuanmintankeVoApi:getTankTb()
	
	local vo = self:getAcVo()
	if vo and vo.tankTb then
		return vo.tankTb
	end
	return {}
end

function acQuanmintankeVoApi:getRewardTank()
	
	local vo = self:getAcVo()
	if vo and vo.rewardTank then
		return vo.rewardTank
	end
	return vo.tankTb[1]
end

function acQuanmintankeVoApi:setRewardTank(tankId)
	local vo = self:getAcVo()
	vo.rewardTank=tankId
end

function acQuanmintankeVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acQuanmintankeVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime=time
end

function acQuanmintankeVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acQuanmintankeVoApi:getVipdiscoun()
	local vo = self:getAcVo()
	local Vipdiscoun=0
	if vo.Vipdiscoun then
		Vipdiscoun=vo.Vipdiscoun
	end
	return Vipdiscoun
end

-- 以下是新版需添加
-- mustMode 判断新版本还是旧版本
function acQuanmintankeVoApi:getMustMode()
	local vo = self:getAcVo()
	if vo.mustMode and tonumber(vo.mustMode)==1 then
		return true
	end
	return false
end

function acQuanmintankeVoApi:getMustReward1()
	local vo = self:getAcVo()
	if vo.mustReward1 then
		return vo.mustReward1
	end
	return {}
end

function acQuanmintankeVoApi:getMustReward2()
	local vo = self:getAcVo()
	if vo.mustReward2 then
		return vo.mustReward2
	end
	return {}
end

function acQuanmintankeVoApi:showRewardSmallDialog(isTouch,isuseami,layerNum,titleTb,bgSrc,dialogSize,bgRect,mustReward,getReward,btnStr,confirmCallback)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acQuanmintankeSmallDialog"
	local sd = acQuanmintankeSmallDialog:new()
	sd:init(isTouch,isuseami,layerNum,titleTb,bgSrc,dialogSize,bgRect,mustReward,getReward,btnStr,confirmCallback)
end
