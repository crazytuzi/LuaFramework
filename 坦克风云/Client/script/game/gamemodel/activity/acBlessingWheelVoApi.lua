acBlessingWheelVoApi={
	itemList=nil
}

function acBlessingWheelVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("blessingWheel")
	end
	return self.vo
end

--判断是否有任务奖励领取
function acBlessingWheelVoApi:canReward()
	return false
end

function acBlessingWheelVoApi:getCost1()
	local vo=self:getAcVo()
	if vo then
		return vo.cost1
	end
	return 0
end

function acBlessingWheelVoApi:getCost10()
	local vo=self:getAcVo()
	if vo then
		return vo.cost10
	end
	return 0
end

function acBlessingWheelVoApi:getRewardListCfg()
	local vo=self:getAcVo()
	if vo and vo.rewardlist then
		return vo.rewardlist
	end
	return {}
end

function acBlessingWheelVoApi:FormatItem()
	local formatData={}	
	local num=0
	local name=""
	local pic=""
	local desc=""
    local id=0
	local index=0
    local eType=""
    local equipId
    local noUseIdx=0 --无用的index 只是占位
    local data = self:getRewardListCfg()
	if data then
		for k,v in pairs(data) do
			if v then
				for m,n in pairs(v) do
					if m~=nil and n~=nil then
						local key,type1,num=m,k,n
						if type(n)=="table" then
							for i,j in pairs(n) do
								if i=="index" then
									index=j
								else
									key=i
									num=j
								end
							end
						end
						name,pic,desc,id,noUseIdx,eType,equipId,bgname=getItem(key,type1)
						if name and name~="" then
							table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId,bgname=bgname})
						end
					end
				end
			end
		end
	end
	if formatData and SizeOfTable(formatData)>0 then
		local function sortAsc(a, b)
			if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
				return a.index < b.index
			end
	    end
		table.sort(formatData,sortAsc)
	end
	return formatData
end

function acBlessingWheelVoApi:getItemByIndex(index)
	local itemList = self:getItemList()
	for k,v in pairs(itemList) do
		if v then
			if v.index and v.index==index then
				return v
			end
		end
	end
	return {}
end

function acBlessingWheelVoApi:getItemList()
	if self.itemList==nil then
		self.itemList=self:FormatItem()
	end
	return self.itemList
end

function acBlessingWheelVoApi:isFree()
	local acVo = self:getAcVo()
	if acVo then
		if self:isToday()==false then
			self:resetAc()
		end
		if acVo.free==nil or acVo.free==0 then
			return true
		end
	end
	return false
end

function acBlessingWheelVoApi:isToday()
	local flag = false
	local vo=self:getAcVo()
	if vo then
		flag=G_isToday(vo.t)
	end
	return flag
end

function acBlessingWheelVoApi:updateData(data)
	local acVo = self:getAcVo()
	if acVo then
		acVo:updateSpecialData(data)
	end
end

--玩家等级在22级及以上才能参加活动
function acBlessingWheelVoApi:isCanJoinActivity()
	local curLevel = playerVoApi:getPlayerLevel()
	if tonumber(curLevel) >= 30 then
		return true,30
	end
	return false,30
end

function acBlessingWheelVoApi:isGemsEnough(cost)
	local isEnough = false
	if playerVoApi then
		local curGems = playerVoApi:getGems()
		if curGems >= tonumber(cost) then
			isEnough = true
		end
	end
	return isEnough
end

function acBlessingWheelVoApi:getTimeStr()
	local str = ""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
		str=getlocal("activity_timeLabel")..":"..timeStr
	end

	return str
end

function acBlessingWheelVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acBlessingWheelVoApi:resetAc()
	local vo=self:getAcVo()
	if vo then
		vo.free=nil
	end
end

function acBlessingWheelVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acBlessingWheelVoApi:clearAll()
	self.itemList=nil
	self.vo=nil
end