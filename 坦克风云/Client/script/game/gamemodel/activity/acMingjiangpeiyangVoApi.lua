acMingjiangpeiyangVoApi = {

}

function acMingjiangpeiyangVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("mingjiangpeiyang")
	end
	return self.vo
end

function acMingjiangpeiyangVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

function acMingjiangpeiyangVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acMingjiangpeiyangVoApi:clear()

end

function acMingjiangpeiyangVoApi:canReward()
	return self:isFree()
end

function acMingjiangpeiyangVoApi:mustGetHero()
	local vo=self:getAcVo()
	if vo and vo.mustGetHero then
		return vo.mustGetHero
	end
	return nil
end

function acMingjiangpeiyangVoApi:getHidandheroProductOrder(mustgetHero)
    local hid 
    local heroProductOrder
    for k,v in pairs(mustgetHero) do
        hid=Split(k,"_")[2]
        heroProductOrder=v
    end
    return hid,heroProductOrder
end

function acMingjiangpeiyangVoApi:getOneCost()
	local onceCost=0
	local vo=self:getAcVo()
	if vo and vo.onceCost then
		onceCost=vo.onceCost
	end
	return tonumber(onceCost)
end

function acMingjiangpeiyangVoApi:getTenCost()
	local tenCost=0
	local vo=self:getAcVo()
	if vo and vo.tenCost then
		tenCost=vo.tenCost
	end
	return tonumber(tenCost)
end

function acMingjiangpeiyangVoApi:getRewardRecords()
	local records={}
	return records
end

function acMingjiangpeiyangVoApi:getMaxPoint()
	local maxPoint=0
	local vo=self:getAcVo()
	if vo and vo.maxPoint then
		maxPoint=vo.maxPoint
	end
	return maxPoint
end

function acMingjiangpeiyangVoApi:getPointTimes()
	local pointTimes=0
	local vo=self:getAcVo()
	if vo and vo.pointTimes then
		pointTimes=vo.pointTimes
	end
	return pointTimes
end

function acMingjiangpeiyangVoApi:getPointData()
	local vo=self:getAcVo()
	if vo and vo.pointTb then
		return vo.pointTb
	end
	return nil
end

function acMingjiangpeiyangVoApi:setTrainPoint(index,addPoint)
	local vo=self:getAcVo()
	if vo and vo.pointTb and vo.pointTb[index] and vo.maxPoint then
		vo.pointTb[index]=vo.pointTb[index]+tonumber(addPoint)
		if vo.pointTb[index]>vo.maxPoint then
			vo.pointTb[index]=vo.maxPoint
		end
	end
end

function acMingjiangpeiyangVoApi:getTrainItem(index)
	local pic,name
	pic="acmjpy_trainitem"..index..".png"
	name=getlocal("activity_mjpy_trainItem"..index)
	return pic,name
end

function acMingjiangpeiyangVoApi:getClientReward()
	local reward={}
	local vo=self:getAcVo()
	if vo then
		reward=vo.clientReward
	end
	return reward
end

function acMingjiangpeiyangVoApi:isFree()
	local freeFlag=false --是否是免费
	local vo=self:getAcVo()
	if self:isToday()==false then
		self:resetFreeNum()
		freeFlag=true
	else
		if vo and vo.freeNum and vo.usedFree then
			if tonumber(vo.freeNum)>tonumber(vo.usedFree) or self:isToday()==false then
				freeFlag=true
			end
		end
	end
	return freeFlag
end

function acMingjiangpeiyangVoApi:isAllTrainCompleted()
	local flag=true
	local pointTb=self:getPointData()
	local maxPoint=self:getMaxPoint()
	for i=1,4 do
		local point=pointTb[i] or 0
		if tonumber(point)<tonumber(maxPoint) and tonumber(maxPoint)>0 then
			flag=false
		end
	end
	return flag
end

function acMingjiangpeiyangVoApi:isTrainCompleted(index)
	local flag=false
	local pointTb=self:getPointData()
	local maxPoint=self:getMaxPoint()
	if pointTb and pointTb[index] and maxPoint then
		if tonumber(pointTb[index])>=tonumber(maxPoint) then
			flag=true
		end
	end
	return flag
end

function acMingjiangpeiyangVoApi:isMultiplier()
	local flag=false
	local vo=self:getAcVo()
	if vo and vo.multiplierFlag then
		if tonumber(vo.multiplierFlag)==1 then
			flag=true
		end
	end
	return flag
end

function acMingjiangpeiyangVoApi:multiplierDone()
	local vo=self:getAcVo()
	if vo and vo.multiplierFlag then
		vo.multiplierFlag=0
	end
end

function acMingjiangpeiyangVoApi:getHeroDescStr()
	local desStr=""
	local ver=self:getVersion()
    if ver==1 then 
        desStr=getlocal("hero_info_Introduction1")
    elseif ver==2 then
        desStr=getlocal("hero_info_Introduction2")
    elseif ver==3 then
        desStr=getlocal("active_mingjiang_hero_des")
    elseif ver==4 then
    	desStr=getlocal("active_mingjiang_hero_des4")
	elseif ver==5 then
    	desStr=getlocal("active_mingjiang_hero_des5")
	elseif ver==6 then
    	desStr=getlocal("active_mingjiang_hero_des6")
	elseif ver==7 then
    	desStr=getlocal("active_mingjiang_hero_des7")
	elseif ver==8 then
    	desStr=getlocal("active_mingjiang_hero_des8")
    end
    return desStr
end

function acMingjiangpeiyangVoApi:resetFreeNum()
	local vo=self:getAcVo()
	if vo then
		vo.usedFree=0
	end
end

function acMingjiangpeiyangVoApi:getFreeNum()
	local vo=self:getAcVo()
	if vo and vo.freeNum then
		return vo.freeNum
	end
	return 0
end

function acMingjiangpeiyangVoApi:clearAc()
	local vo=self:getAcVo()
	if vo then
		vo.pointTb={0,0,0,0}
	end
end

function acMingjiangpeiyangVoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acMingjiangpeiyangVoApi:clearAll()
	self.vo=nil
end