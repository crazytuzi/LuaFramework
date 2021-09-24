acJiejingkaicaiVoApi={}

function acJiejingkaicaiVoApi:getAcVo()
	return activityVoApi:getActivityVo("jiejingkaicai")
end

function acJiejingkaicaiVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acJiejingkaicaiVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acJiejingkaicaiVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acJiejingkaicaiVoApi:getCost()
	local vo = self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 1000
end

function acJiejingkaicaiVoApi:getMulCost()
	local vo = self:getAcVo()
	if vo and vo.mulCost then
		return vo.mulCost
	end
	return 10000
end

function acJiejingkaicaiVoApi:getLastTime()
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		return vo.lastTime
	end
	return 0
end

function acJiejingkaicaiVoApi:getRewardList()
	local vo = self:getAcVo()
	if vo and vo.rewardlist then
		local rewardList1 = FormatItem(vo.rewardlist[1])
		local rewardList2 = FormatItem(vo.rewardlist[2])
		return rewardList1,rewardList2
	end
	return {}
end

function acJiejingkaicaiVoApi:getDajiang()
	local vo = self:getAcVo()
	if vo and vo.dajiang then
		for k,v in pairs(vo.dajiang) do
			local keyTb = Split(k,"_")
			local name,pic,desc,id,index,eType,equipId,bgname=getItem(keyTb[2],"w")
			local item = {name=name,pic=pic,id=id,index=index,eType=eType,num=v,key=keyTb[2],desc=desc,type="w"}
			return item
		end
	end
	return nil
end

function acJiejingkaicaiVoApi:setDajiang()
	local vo = self:getAcVo()
	if vo and vo.dajiang then
		vo.dajiang=nil
	end
end

function acJiejingkaicaiVoApi:updataData(data)
	local  vo = self:getAcVo()
	vo:updateSpecialData(data)
end

function acJiejingkaicaiVoApi:showSmallDialogL(layerNum,callback)
	local sd=acJiejingkaicaiSmallDialog:new(layerNum)
	local dialog= sd:init(callback)
end

