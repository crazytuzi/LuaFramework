
acJidongbuduiVoApi = {
	serverLeftTankNum=0,
	lastSt = 0,
	recordList={},
	updateListTime =0
}

function acJidongbuduiVoApi:getAcVo()
	return activityVoApi:getActivityVo("jidongbudui")
end
function acJidongbuduiVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acJidongbuduiVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acJidongbuduiVoApi:getCircleListCfg()
	local vo = self:getAcVo()
	if vo and vo.circleList then
		return vo.circleList
	end
	return {}
end

function acJidongbuduiVoApi:getLotteryOnceCost()
	local vo = self:getAcVo()
	if vo and vo.cost then
		return tonumber(vo.cost)
	end
	return 0 
end

function acJidongbuduiVoApi:getTurkeyNum()
	local vo = self:getAcVo()
	if vo and vo.turkey then
		return tonumber(vo.turkey)
	end
	return 0 
end
function acJidongbuduiVoApi:updateSelfTurkey(num)
	local vo = self:getAcVo()
	if vo then
		if vo.turkey == nil then
			vo.turkey = 0 
		end
		vo.turkey = vo.turkey+num
	end
end

function acJidongbuduiVoApi:getOtherRewardCfg( ... )
	local vo = self:getAcVo()
	if vo and vo.otherReward then
		return vo.otherReward
	end
	return {}
end
function acJidongbuduiVoApi:getNeedTurkeyByID(id)
	local cfg = self:getOtherRewardCfg()
	-- otherReward={
 --                    p={{p20=30,num=20,index=1},{p19=5,num=30,index=2},{p13=10,num=50,index=3},},
 --                },
	if cfg then
		for k,v in pairs(cfg) do
			if v and type(v)=="table" then
				for m,n in pairs(v) do
					if n.index and n.index == id and n.num then
						return tonumber(n.num)
					end
				end
			end
		end
	end
	return 0

end

function acJidongbuduiVoApi:getExchangeRewardByID(id)
	local cfg = self:getOtherRewardCfg()
	-- otherReward={
 --                    p={{p20=30,num=20,index=1},{p19=5,num=30,index=2},{p13=10,num=50,index=3},},
 --                },
	if cfg then
		for k,v in pairs(cfg) do
			if v and type(v)=="table" then
				for m,n in pairs(v) do
					if n.index and n.index == id then
						local key,num,index
						for i,j in pairs(n) do
							for i,j in pairs(n) do
								if i=="index" then
									index=j
								elseif i=="num" then

								else
									key=i
									num=j
								end
							end
						end
						local name,pic,desc,id,noUseIdx,eType,equipId=getItem(key,k)
          				local award = {name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId}
          				return award
					end
				end
			end
		end
	end
	return {}

end

function acJidongbuduiVoApi:getTankCfg(  )
	local vo = self:getAcVo()
	if vo and vo.tankCfg then
		return vo.tankCfg
	end
	return {}
end
function acJidongbuduiVoApi:getExchangeTankNeedParts()
	local cfg = self:getTankCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if k and v  and k == "needPartNum" then
				return tonumber(v)
			end
		end
	end
	return 0 
end
function acJidongbuduiVoApi:getTankIdAndNum()
	local cfg = self:getTankCfg()
	local tankAid,tankID,tankNum
	if cfg then
		for k,v in pairs(cfg) do
			if k and v  and k == "gettank" and type(v)=="table" then
				for m,n in pairs(v) do
					print(m,n)
					if m and n then
						tankAid = m
						tankNum = n
					end
				end
			end
		end
	end
	if tankAid then
		local arr = Split(tankAid,"a")
		tankID = tonumber(arr[2])
	end
	return tankAid,tankID,tankNum
end

function acJidongbuduiVoApi:getExChangeTankNum()
	local vo = self:getAcVo()
	if vo and vo.exchangeTankNum then
		return tonumber(vo.exchangeTankNum)
	end
	return 0 
end
function acJidongbuduiVoApi:updateExChangeTankNum(num)
	local vo = self:getAcVo()
	if vo then
		if vo.exchangeTankNum ==nil then
			vo.exchangeTankNum = 0
		end
		vo.exchangeTankNum= vo.exchangeTankNum+num
	end
	return 0 
end

function acJidongbuduiVoApi:getServerLeftTankNum()
	return self.serverLeftTankNum
end

function acJidongbuduiVoApi:setServerLeftTankNum(num)
	self.serverLeftTankNum = num
end

function acJidongbuduiVoApi:getServerTankShowMax()
	local vo = self:getAcVo()
	if vo and vo.showNums then
		return vo.showNums
	end
	return 0
end

function acJidongbuduiVoApi:getSelfTankMax()
	local vo = self:getAcVo()
	if vo and vo.limitNums then
		return vo.limitNums
	end
	return 0
end


function acJidongbuduiVoApi:getRecordList()
	return self.recordList
end
function acJidongbuduiVoApi:setRecordList(list)

	self.recordList = list

	-- for k,v in pairs(list) do
	-- 	--local tb =  G_Json.decode(G_Json.decode(tostring(v)))
	-- 	table.insert(self.recordList,tb)
	-- end
end
function acJidongbuduiVoApi:addRecordList(tb)
	local posx = tb[1]
	local posy = tb[2]
	local canAdd = true
	for k,v in pairs(self.recordList) do
		if v then
			if v[1]==posx and v[2]==posy then
				canAdd = false
			end
		end
	end
	if canAdd == true then
		self:setUpdateListTime()
		table.insert(self.recordList,1,tb)
	end
end
function acJidongbuduiVoApi:delRecordList(tb)
	local posx = tb[1]
	local posy = tb[2]
	-- body
	if self.recordList then
		for k,v in pairs(self.recordList) do
			if v then
				if v[1]==posx and v[2]==posy then
					self:setUpdateListTime()
					table.remove(self.recordList,k)
				end
			end
		end
	end
	
end
function acJidongbuduiVoApi:setUpdateListTime()
	self.updateListTime=base.serverTime
end
function acJidongbuduiVoApi:getUpdateListTime()
	return self.updateListTime
end
function acJidongbuduiVoApi:setLastSt()
	self.lastSt = base.serverTime
end


function acJidongbuduiVoApi:getTurkeyCfgForShow()
	return {name="activity_jidongbudui_turkey",icon="Turkey.png",des="activity_jidongbudui_turkeyDesc"}
end
function acJidongbuduiVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acJidongbuduiVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acJidongbuduiVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end