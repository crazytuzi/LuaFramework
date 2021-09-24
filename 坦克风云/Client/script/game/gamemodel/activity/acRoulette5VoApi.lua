acRoulette5VoApi = {
	flag={0,0},
	lastListTime=0,
}

function acRoulette5VoApi:clearAll()--清空
	self.flag={0,0}
	self.lastListTime=0
end

function acRoulette5VoApi:getAcVo()
	return activityVoApi:getActivityVo("zhenqinghuikui")
end
function acRoulette5VoApi:getAcName( )
	local  vo  = self:getAcVo()
	local acName
	if vo and vo.acName then
		acName = vo.acName
	else
		acName =getlocal("activity_zhenqinghuikui_title")
	end
	return acName
end
function  acRoulette5VoApi:getGameName( )
	local vo = self:getAcVo()
	local gameName
	if vo and vo.gameName then
		gameName = vo.gameName
	else
		gameName = "坦克风云"
	end
	return gameName
end
function acRoulette5VoApi:clearRankList()--清空排名列表
	local data={awardList={}}
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
end
function acRoulette5VoApi:updateDataShow()--刷新数据，
	local vo=self:getAcVo()
	activityVoApi:updateShowState(vo)
end

function acRoulette5VoApi:getVersion( )--取version值
	local vo = self:getAcVo()
	if vo.version then
		return vo.version
	end
	return nil
end

function acRoulette5VoApi:getRouletteCfg()--拿到后端数据
	local vo=self:getAcVo()
	if vo and vo.acCfg then
		return vo.acCfg
	end
	return {}
end

function acRoulette5VoApi:getFlag(idx)
	return self.flag[idx]
end
function acRoulette5VoApi:setFlag(idx,value)
	if idx then
		if value then
			self.flag[idx]=value
		else
			self.flag[idx]=1
		end
	else
		if value then
			self.flag={value,value}----?
		else
			self.flag={1,1}
		end

	end
end

function acRoulette5VoApi:getLastListTime()--
	return self.lastListTime
end
function acRoulette5VoApi:setLastListTime(time)
	self.lastListTime=time
end


function acRoulette5VoApi:formatItemData(itemTab)
	local cfg=self:getRouletteCfg()
	local tab=FormatItem(itemTab,nil,true)
	
	local selfVer = self:getVersion() --拿到Version值
	-- for k,v in pairs(itemTab) do
	-- 	if k=="o" then
	-- 		for m,n in pairs(v) do
	-- 			--print(m,n)
	-- 		end
	-- 	end
	-- end
	for k,v in pairs(itemTab) do
		if k=="mm" and v then
			for m,n in pairs(v) do
				local item={type="mm"}
				for i,j in pairs(n) do
					if i=="index" then
						item.index=j
					else
						item.key=i
						item.num=j
						item.name=""
						item.desc=""
						local id=(tonumber(i) or tonumber(RemoveFirstChar(i)))
						if id and cfg.rewardtype and cfg.rewardtype[id] then
							item.name=cfg.rewardtype[id]
							item.desc=cfg.rewardtype[id]
							if selfVer ==1 or selfVer == nil then
								item.pic="huikui_reward"..id..".png"
							elseif selfVer ==2 or selfVer ==3 or selfVer == 5 then
								item.pic ="kuangnuTikect.png"
							elseif (selfVer ==4 or selfVer ==6) and item.key ~="m2"then
								item.pic ="jingDongCard.png"
							end
						end
						if selfVer ==6 and item.key =="m2" then
							item.pic ="kuangnuTikect.png"
						end
						if selfVer ==7 and item.key =="m1" then
							item.pic ="kuangnuTikect.png"
							item.desc=getlocal("activity_wheelFortune5_teshudes7",{self:getGameName()})
						end
					end
				end
				if item and SizeOfTable(item)>0 then
					table.insert(tab,item)
				end
			end
		end
	end
	local function sortAsc(a, b)
		if a and b and a.index and b.index then
			return tonumber(a.index) < tonumber(b.index)
		end
	end
	table.sort(tab,sortAsc)
	-- for k,v in pairs(tab) do
	-- 	print("k",k,v,v.key,v.index)
	-- end
	return tab
end

function acRoulette5VoApi:getUsedNum()  ----返回当天使用的次数
	local vo=self:getAcVo()
	local usedNum=0
	if vo and vo.hasUsedNum then
		usedNum=vo.hasUsedNum 
	end
	return usedNum
end
function acRoulette5VoApi:getLeftNum()   ---拿到剩余的总次数
	local vo=self:getAcVo()
	local leftNum=0
	if vo and activityVoApi:isStart(vo) then
		leftNum=vo.leftNum or 0
		if leftNum<0 then
			leftNum=0
		end
	else
		leftNum=0
	end
	return leftNum
end

function acRoulette5VoApi:setTenUsedNum(num)
	local vo=self:getAcVo()
	if vo then
		if vo.hasUsedNum == nil then
			vo.hasUsedNum = 0
		end
		vo.hasUsedNum=vo.hasUsedNum+num
		activityVoApi:updateShowState(vo)
	end
end

function acRoulette5VoApi:checkCanPlay()
	local vo=self:getAcVo()
	local leftNum=self:getLeftNum() or 0
	if leftNum>0 and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acRoulette5VoApi:checkCanTenPlay()
	local vo=self:getAcVo()
	local leftNum=self:getLeftNum() or 0

	if leftNum>=10 and activityVoApi:isStart(vo) then
		return true
	end
	return false
end


function acRoulette5VoApi:canReward()
	local vo=self:getAcVo()
	if vo and activityVoApi:isStart(vo) then
		local leftNum=self:getLeftNum()
		if leftNum>0 then
			return true
		end
	end
	return false
end

function acRoulette5VoApi:isToday()
	local istoday = true
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		istoday = G_isToday(vo.lastTime)
	end
	return istoday

end

function acRoulette5VoApi:isRouletteToday()
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		if self:isToday()==false then	

	        vo.hasUsedNum=0

	        vo.leftNum=0
	        --vo.hasUsedFreeNum={}
	        vo.rechargeNum=0
	        vo.lastTime=G_getWeeTs(base.serverTime)

        	self:setFlag(nil,0)

        	activityVoApi:updateShowState(vo)
        	vo.stateChanged=true

        	return false
		end
	end
	return true
end

function acRoulette5VoApi:getIndexByNameAndType(name,type,num)
	local cfg=self:getRouletteCfg()
	if cfg and cfg.pool then
		local awardTab=FormatItem(cfg.pool,nil,true)
		for k,v in pairs(awardTab) do
			if v and tostring(v.type)==tostring(type) and v.name==name and tonumber(v.num)==tonumber(num) then
				return k
			end
		end
	end
	return 0
end

function acRoulette5VoApi:getTimeTab()
	local timeTab={}
	local cfg=self:getRouletteCfg()
	local function formatNum(num)
		if tonumber(num) and tonumber(num)<10 then
			return "0"..num
		end
		return num
	end
	if cfg.startTime and cfg.durationTime then
		local startTime=cfg.startTime
		local durationTime=cfg.durationTime
		for k,v in pairs(startTime) do
			local sHour,sMinute=v[1],v[2] 
			if tonumber(sHour)<10 then

			end
			local startTime=formatNum(sHour)..":"..formatNum(sMinute)
			local eHour,eMinute = durationTime[k][1],durationTime[k][2]
			local endTime = formatNum(eHour)..":"..formatNum(eMinute)
			local timeStr = startTime.."--"..endTime
			timeTab[k]=timeStr		
		end
	end
	return timeTab
end

function acRoulette5VoApi:isInFreeTime()
	local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
	local cfg=self:getRouletteCfg()
	local isInFree=false
	if cfg.startTime and cfg.durationTime then
		local startTime=cfg.startTime
		local durationTime=cfg.durationTime
		for k,v in pairs(cfg.startTime) do
			if v and v[1] and v[2] then
				local sHour,sMinute=v[1],v[2]
				local eHour,eMinute =durationTime[k][1],durationTime[k][2]
				local startPoint=sHour*3600+sMinute*60
				local endPoint=durationTime[k][1]*3600+durationTime[k][2]*60

				local vo = self:getAcVo()
				if vo  then
					if vo.freeTime == nil then
						vo.freeTime = {}
					end
				end
				if vo.freeTime[k] ==nil then
					vo.freeTime[k]=0
				end
				if dayTime>=startPoint and dayTime<=endPoint then
					if G_isToday(vo.freeTime[k])==false then
						isInFree=true
					end
				end
			end
		end
	end


	return isInFree
end
function acRoulette5VoApi:tickFreeTime(  )
		local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
	local cfg=self:getRouletteCfg()
	local isInFree=false
	if cfg.startTime and cfg.durationTime then
		local startTime=cfg.startTime
		local durationTime=cfg.durationTime
		for k,v in pairs(cfg.startTime) do
			if v and v[1] and v[2] then
				local sHour,sMinute=v[1],v[2]
				local eHour,eMinute =durationTime[k][1],durationTime[k][2]
				local startPoint=sHour*3600+sMinute*60
				local endPoint=durationTime[k][1]*3600+durationTime[k][2]*60

				local vo = self:getAcVo()
				if vo  then
					if vo.freeTime == nil then
						vo.freeTime = {}
					end

				end

				if vo.freeTime[k] ==nil then
					vo.freeTime[k]=0
				end

				if dayTime>=startPoint and dayTime<=endPoint then
					vo.freeTime[k]=base.serverTime
					
				end
			end
		end
	end


end
-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acRoulette5VoApi:addMoney(money)
	print("充钱啦")
	local acVo = self:getAcVo()
	local cfg=self:getRouletteCfg()

	if cfg and acVo then
		if acVo.rechargeNum ==nil then
			acVo.rechargeNum=0
		end

		local num=0
		acVo.rechargeNum=acVo.rechargeNum+money
		if acVo.rechargeNum>=cfg.lotteryConsume then
			num=math.floor(acVo.rechargeNum/cfg.lotteryConsume)
			acVo.rechargeNum=(acVo.rechargeNum%cfg.lotteryConsume)
		end
		acVo.leftNum=acVo.leftNum+num
		acVo.lastTime=G_getWeeTs(base.serverTime)
		self:setFlag(1,0)
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

function acRoulette5VoApi:addNum()
	local vo=self:getAcVo()
	if vo then
		vo.leftNum=vo.leftNum+1
		activityVoApi:updateShowState(vo)
		vo.stateChanged = true -- 强制更新数据
	end
end


function acRoulette5VoApi:updateLeftNum(num)
	local vo=self:getAcVo()
	if vo then
		if vo.leftNum ==nil then
			vo.leftNum = 0
		end
		if vo.leftNum>0 and vo.leftNum>=num then
			vo.leftNum = vo.leftNum - num
		end
	end
end

function acRoulette5VoApi:setlist(list)
	self.rankList = list
end

function acRoulette5VoApi:getlist( list )
	return self.rankList
end

