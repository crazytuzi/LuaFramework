acMingjiangzailinVoApi = {
	logList={}
}

function acMingjiangzailinVoApi:getAcVo()
	return activityVoApi:getActivityVo("mingjiangzailin")
end

function acMingjiangzailinVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end


function acMingjiangzailinVoApi:initLogData(data)
	local list = data or {}
	local num = SizeOfTable(list)
	for i=num,1,-1 do
		local log = G_clone(list[i][1])
		table.insert(self.logList,log)
	end
end

function acMingjiangzailinVoApi:updateLogData(log)
	local logItem = FormatItem(log)

	table.insert(self.logList,1,G_clone(log))
	if SizeOfTable(self.logList)>20 then
		table.remove(self.logList,#self.logList)
	end
end

function acMingjiangzailinVoApi:getLogList()
	return self.logList
end

function acMingjiangzailinVoApi:clearAll()
	self.logList={}
end


function acMingjiangzailinVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acMingjiangzailinVoApi:mustGetReward()
	local vo = self:getAcVo()
	if vo and vo.reward then
		return vo.reward
	end
end

function acMingjiangzailinVoApi:mustGetHero()
	local vo = self:getAcVo()
	if vo and vo.mustGetHero then
		return vo.mustGetHero
	end
end

function acMingjiangzailinVoApi:getHidandheroProductOrder()
	local mustgetHero=self:mustGetHero()
    local hid 
    local heroProductOrder
    for k,v in pairs(mustgetHero) do
       hid = Split(k,"_")[2]
       heroProductOrder = v
    end
    return hid,heroProductOrder
end

-- 得到打折
function acMingjiangzailinVoApi:getValue()
	local vo = self:getAcVo()
	if vo and vo.value then 
		return vo.value
	end
end


function acMingjiangzailinVoApi:getOneCost()
	local vo = self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
end

function acMingjiangzailinVoApi:getTenCost()
	return 10*self:getValue()*self:getOneCost()
end

function acMingjiangzailinVoApi:getStar()
	local vo = self:getAcVo()
	if vo and vo.star then 
		return vo.star
	end
end

function acMingjiangzailinVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acMingjiangzailinVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

-- mustMode 判断新版本还是旧版本
function acMingjiangzailinVoApi:getMustMode()
	local vo = self:getAcVo()
	if vo.mustMode and vo.mustMode == 1 and base.mustmodel ==1 then
		return true
	end
	return false
end