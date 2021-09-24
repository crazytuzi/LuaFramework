acHuoxianmingjiangVoApi = {
	rewardList=nil,
	logTimeList={},
	logItemList={},
	logItemNumList={},
}

function acHuoxianmingjiangVoApi:getAcVo()
	return activityVoApi:getActivityVo("huoxianmingjiang")
end

function acHuoxianmingjiangVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

function acHuoxianmingjiangVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acHuoxianmingjiangVoApi:getLogList()
	return self.logTimeList,self.logItemList,self.logItemNumList
end

function acHuoxianmingjiangVoApi:analyzeItem(item)
	for k,v in pairs(item) do
		
		if SizeOfTable(v)==1 then	
			table.insert(self.logItemList,v)
		end
	end

end

function acHuoxianmingjiangVoApi:initLogData(data)
	for k,v in pairs(data) do
    	local tb = {}
    	tb.time=v[2]
    	self:analyzeItem(v[1])
    	table.insert(self.logTimeList,v[2])
    end

    local tb = {}
    for k,v in pairs(self.logItemList) do
    	for p,q in pairs(v) do
    		table.insert(tb,p)
    		table.insert(self.logItemNumList,q)
    	end
    end
    self.logItemList = tb
end

function acHuoxianmingjiangVoApi:clear()
	self:clearLogData()
end

function acHuoxianmingjiangVoApi:clearLogData()
	self.logTimeList={}
	self.logItemList={}
	self.logItemNumList={}
end


function acHuoxianmingjiangVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acHuoxianmingjiangVoApi:mustGetHero()
	local vo = self:getAcVo()
	if vo and vo.mustGetHero then
		return vo.mustGetHero
	end
end

-- 得到打折
function acHuoxianmingjiangVoApi:getValue()
	local vo = self:getAcVo()
	if vo and vo.value then 
		return vo.value
	end
end


function acHuoxianmingjiangVoApi:getOneCost()
	local vo = self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
end

function acHuoxianmingjiangVoApi:getTenCost()
	return 10*self:getValue()*self:getOneCost()
end

function acHuoxianmingjiangVoApi:getStar()
	local vo = self:getAcVo()
	if vo and vo.star then 
		return vo.star
	end
end

function acHuoxianmingjiangVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acHuoxianmingjiangVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end





