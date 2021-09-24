acSweetTroubleVoApi ={}


function acSweetTroubleVoApi:getIsCrossToday()
	local vo = self:getAcVo()
	if vo.isCrossToday then
		return vo.isCrossToday 
	end
	return nil
end
function acSweetTroubleVoApi:setIsCrossToday(isCross)
	local vo = self:getAcVo()
	-- if vo.isCrossToday then
		 vo.isCrossToday =isCross
	-- end
	activityVoApi:updateShowState(vo)
end

function acSweetTroubleVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
	end
end
function acSweetTroubleVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		-- print("vo.lastTime---->",vo.lastTime)
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acSweetTroubleVoApi:getAcVo()
	return activityVoApi:getActivityVo("halloween")
end
function acSweetTroubleVoApi:afterExchange()
    local vo = self:getAcVo()

    activityVoApi:updateShowState(vo)
    vo.stateChanged = true -- 强制更新数据
end
function acSweetTroubleVoApi:canReward()
	local acVo = self:getAcVo()
	local needSnatNums = self:getAsCounts()
	local SnatedNums = self:getSnatchedCounts()
	local cropedNums = self:getCropedCounts()
	local needCropeNums = self:getCropCounts()
	local lastRwardNums = self:getCountsByTotal()
	-- print("lastRwardNums----->",lastRwardNums)

	if ( SnatedNums >= needSnatNums and self:getRecvedSnatReward() ==0 ) then
		-- print("her???????1111")
		return true
	end
	if acSweetTroubleVoApi:getCountsByDay( ) > 0 or acSweetTroubleVoApi:getCountsByTotal() > 0 then
		return true
	end
	if ( cropedNums >= needCropeNums and self:getCropedReward() == 0 ) then
		-- print("her???????111122222")
		return true
	end
    local reTimesTab = acSweetTroubleVoApi:getNeedTimesTab()
    local allRan = false
    for i=1,6 do
        if reTimesTab[i] then 
            if reTimesTab[i] >-1 then
            else
            	-- print("her???????111122222444444")
            	return true
            end
        end
    end
	return false
end

function acSweetTroubleVoApi:getAsCounts( )--抢夺次数
	local vo = self:getAcVo()
	if vo.asCounts then
		return vo.asCounts
	end
	return 999
end

function acSweetTroubleVoApi:getSnatchedCounts( )--已经 抢夺次数
	local vo = self:getAcVo()
	if vo.snatchedCounts then
		return vo.snatchedCounts
	end
	return 0
end
function acSweetTroubleVoApi:getRecvedSnatReward( )--抢夺 是否已经领奖的标识
	local vo = self:getAcVo()
	if vo.recvedSnaReward then
		return vo.recvedSnaReward
	end
	return 0
end
function acSweetTroubleVoApi:setRecvedSnatReward( )--抢夺 设置经领奖的标识
	local  vo = self:getAcVo()
	if vo.recvedSnaReward then
		vo.recvedSnaReward = 1
		activityVoApi:updateShowState(vo)
	end
end

function acSweetTroubleVoApi:getCropedReward( )--种植 是否已经领奖的标识
	local vo = self:getAcVo()
	if vo.isCroped then
		return vo.isCroped
	end
	return 0
end
function acSweetTroubleVoApi:setCropedReward( )--种植 设置经领奖的标识
	local  vo = self:getAcVo()
	if vo.isCroped then
		vo.isCroped =1
		activityVoApi:updateShowState(vo)
	end
end

function acSweetTroubleVoApi:getCropedCounts( )--已经 种植次数
	local vo = self:getAcVo()
	if vo.cropedCounts then
		return vo.cropedCounts
	end
	return 0
end
function acSweetTroubleVoApi:setCropedCounts(reCounts)
	local vo  = self:getAcVo()
	if reCounts then
		vo.cropedCounts = reCounts
		activityVoApi:updateShowState(vo)
	end
	return nil
end
function acSweetTroubleVoApi:getCropCounts( )--种植次数
	local vo = self:getAcVo()
	if vo.cropCounts then
		return vo.cropCounts
	end
	return 999
end
function acSweetTroubleVoApi:getAsReward( )--抢夺奖励
	local vo = self:getAcVo()
	if vo.asReward then
		return vo.asReward
	end
	return nil
end
function acSweetTroubleVoApi:getCropReward( )--种植奖励
	local vo = self:getAcVo()
	if vo.cropReward then
		return vo.cropReward
	end
	return nil
end
function acSweetTroubleVoApi:setTgSeedTab( seedTab )
	local vo = self:getAcVo()
	if vo.tgSeedTab then
		for i=1,4 do
			if seedTab["t"..5-i] then
				vo.tgSeedTab["t"..5-i]=seedTab["t"..5-i]
			end
		end
		activityVoApi:updateShowState(vo)
	end
end
function acSweetTroubleVoApi:getTgSeedTab( )--糖果TAB（4种糖果的数量）糖果就是种子
	local vo = self:getAcVo()
	if vo.tgSeedTab then
		for i=1,4 do
			if vo.tgSeedTab["t"..5-i]==nil then
				vo.tgSeedTab["t"..5-i]=0
			end
		end
		return vo.tgSeedTab
	end
	return {}
end
function acSweetTroubleVoApi:subTgSeedTab(whiSweNum)--糖果TAB（4种糖果的数量）糖果就是种子
	local vo = self:getAcVo()
	if vo.tgSeedTab then
			if vo.tgSeedTab["t"..5-whiSweNum]==nil then
				vo.tgSeedTab["t"..5-whiSweNum]=0
			elseif vo.tgSeedTab["t"..5-whiSweNum] >0 then
				vo.tgSeedTab["t"..5-whiSweNum] =vo.tgSeedTab["t"..5-whiSweNum]-1
			end
		return vo.tgSeedTab
	end
	return {}
end


function acSweetTroubleVoApi:getNeedtimeTab( )--4个种子所有种植需要的小时数 tab表
	local vo = self:getAcVo()
	if vo.needTime then
		return vo.needTime
	end
	return nil
end

function acSweetTroubleVoApi:getDayreward( )--每天的充值奖励
	local vo = self:getAcVo()
	if vo.dayReward then
		return vo.dayReward
	end
	return nil
end
function acSweetTroubleVoApi:getNeedCost( )
	local vo = self:getAcVo()
	if vo.cost then
		return vo.cost
	end
	return 9999
end
function acSweetTroubleVoApi:getTotalReward( )--每到cost领一次
	local vo = self:getAcVo()
	if vo.totalReward then
		return vo.totalReward
	end
	return nil
end
function acSweetTroubleVoApi:getSeedNeedReward( )
	local vo = self:getAcVo()
	if vo.seeReward then
		return vo.seeReward 
	end
end

function acSweetTroubleVoApi:getTotalRewardShowTab(idx)
	local totalTab = self:getTotalReward()
	local firstTab = self:getDayreward()
	local dj = nil 
	if idx ==2 then
		dj =FormatItem(totalTab[1],nil,true)
	elseif idx== 1 then
		dj =FormatItem(firstTab[1],nil,true)
	end
	if dj then
		return dj
	end
	return nil
end
function acSweetTroubleVoApi:getFirstAllCounts( )
	local vo = self:getAcVo()
	if vo.firCounts then
		return vo.firCounts
	end
	return 0
end
function acSweetTroubleVoApi:setFirstAllCounts(num)
	local vo = self:getAcVo()
	if vo.firCounts then
		vo.firCounts =num
		activityVoApi:updateShowState(vo)
	end
	-- return 0
end
function acSweetTroubleVoApi:getFirstRecvedCounts( )
	local vo = self:getAcVo()
	if vo.firRecedCounts then
		return vo.firRecedCounts
	end
	return 0
end
function acSweetTroubleVoApi:setFirstRecvedCounts( num)
	local vo = self:getAcVo()
	if vo.firRecedCounts then
		 vo.firRecedCounts = num
		 activityVoApi:updateShowState(vo)
	end
	-- return 0
end
function acSweetTroubleVoApi:getCountsByDay( )--首充剩余领奖次数
	local firCounts = self:getFirstAllCounts()
	local firRecedCounts = self:getFirstRecvedCounts()
	if firCounts and firRecedCounts then
		return firCounts - firRecedCounts
	end
	return 0
end

function acSweetTroubleVoApi:getCountsByTotal( )--充值满足情况下的剩余领奖次数
	local golds = self:getAllgolds()
	local countsG = self:getRecvedGoldsCounts()
	local needGolds = self:getNeedCost()
	if golds and countsG and needGolds then
		return math.floor(golds/needGolds)-countsG
	end
	return 0
end
function acSweetTroubleVoApi:getAllgolds( )		-- 累计充值的金币数
	local vo = self:getAcVo()
	if vo.allRechaGolds then
		return vo.allRechaGolds
	end
	return 0
end
function acSweetTroubleVoApi:setAllgolds( gems )		-- 累计充值的金币数
	local vo = self:getAcVo()
	if vo.allRechaGolds then
		 vo.allRechaGolds =gems
		 activityVoApi:updateShowState(vo)
	end
end

function acSweetTroubleVoApi:getRecvedGoldsCounts() -- 已领取累计充值到n金币的次数
	local vo = self:getAcVo()
	if vo.countsByGolds then
		return vo.countsByGolds
	end
	return nil
end
function acSweetTroubleVoApi:setRecvedGoldsCounts(idx) -- 已领取累计充值到n金币的次数
	local vo = self:getAcVo()
	if vo.countsByGolds  then
		 vo.countsByGolds =idx
		 activityVoApi:updateShowState(vo)
	end
end
-- function acSweetTroubleVoApi:ChangeAlreadyCost(addMoney)
-- 	local vo = self:getAcVo()
-- 	if vo.allRechaGolds then
-- 		vo.allRechaGolds = v.allRechaGolds + addMoney
-- 		if vo.allRechaGolds > self:getNeedCost() then
-- 			vo.allRechaGolds =self:getNeedCost()
-- 		end
-- 	end
-- 	self:setChanData(1,true)
-- end
function acSweetTroubleVoApi:setAddOrRecTab(idx,num)
	local vo = self:getAcVo()
	if vo.addOrRecTab then
		vo.addOrRecTab[idx]=num
		activityVoApi:updateShowState(vo)
	end
end

function acSweetTroubleVoApi:getAddOrRecTab( )
	local vo = self:getAcVo()
	if vo.addOrRecTab then
		return vo.addOrRecTab
	end
	return nil
end


function acSweetTroubleVoApi:setWhiPos(posNum,SweNum )--放置第几个盒子里
	local vo = 	self:getAcVo()
	if vo.whiPosNum then
		vo.whiPosNum =posNum
		activityVoApi:updateShowState(vo)
	end
end
function acSweetTroubleVoApi:getWhiPos( )
	local vo = self:getAcVo()
	if vo.whiPosNum then
		return vo.whiPosNum
	end
	return nil
end
function acSweetTroubleVoApi:setWhiSweet( SweNum )--拿取第几种糖果
	local vo = 	self:getAcVo()
	if vo.whiSweNum then
		vo.whiSweNum = SweNum
		activityVoApi:updateShowState(vo)
	end
end
function acSweetTroubleVoApi:getWhiSwe( )
	local vo = self:getAcVo()
	if vo.whiSweNum then
		return vo.whiSweNum
	end
	return nil
end

function acSweetTroubleVoApi:getWhiSweTimes(SweNum,posNum) --在开始倒计时之前 拿到某一个种子的倒计时时间 用于改变str
	local vo = self:getAcVo()
	local seedGrowTimesTab  = self:getGrowTimesTab( )
	local reStr = GetTimeStr(seedGrowTimesTab["p"..posNum][2]-base.serverTime)
	if reStr then
		return reStr
	end
	return nil
end

function acSweetTroubleVoApi:getGrowTimesTab( )
	local vo = self:getAcVo()
	if vo.seedGrowTimesTab then
		return vo.seedGrowTimesTab
	end
	return nil
		
end
function acSweetTroubleVoApi:setAllGrowTimesTab( needTimesNowTab)
	local vo = self:getAcVo()
	-- if vo.seedGrowTimesTab then
		-- for i=1,6 do
			if vo.seedGrowTimesTab and needTimesNowTab then
				vo.seedGrowTimesTab = G_clone(needTimesNowTab)
				activityVoApi:updateShowState(vo)
			end
		-- end
	-- end
end
function acSweetTroubleVoApi:setNeedimesTab( idx)
	local vo = self:getAcVo()
	-- local seedGrowTimesTab = self:getGrowTimesTab()
	if idx then
		vo.needTimesTab[idx] = -1
		vo.seedGrowTimesTab["p"..idx][2] =-1
	else
		if vo.seedGrowTimesTab and vo.needTimesTab then
			for i=1,6 do
				if vo.seedGrowTimesTab["p"..i] and vo.seedGrowTimesTab["p"..i][2] then
						if vo.seedGrowTimesTab["p"..i][2]-base.serverTime >0  then
							vo.needTimesTab[i] = vo.seedGrowTimesTab["p"..i][2]-base.serverTime
						else
							vo.needTimesTab[i] = -1
						end
				end
			end
		end
	end
	activityVoApi:updateShowState(vo)
end
function acSweetTroubleVoApi:setNeedimesTabIdxNil(idx)
	local vo = self:getAcVo()
	-- local seedGrowTimesTab = self:getGrowTimesTab()
	if  vo.needTimesTab and vo.needTimesTab[idx]then
		vo.needTimesTab[idx]=nil
		activityVoApi:updateShowState(vo)
	end
	if vo.seedGrowTimesTab and vo.seedGrowTimesTab["p"..idx][2] then
		vo.seedGrowTimesTab["p"..idx][2] = nil 
		activityVoApi:updateShowState(vo)
	end
end


function acSweetTroubleVoApi:setWhiSweTimesInWhiPos(SweNum,posNum)--设置某种糖果的倒计时 放入某一个位置
	-- local needTimeTab = self:getNeedtimeTab()
	local seedGrowTimesTab = self:getGrowTimesTab( )
	local vo = self:getAcVo()
	if vo.needTimesTab then
		vo.needTimesTab[posNum] = seedGrowTimesTab["p"..posNum][2]-base.serverTime
		activityVoApi:updateShowState(vo)

	end

end
function acSweetTroubleVoApi:setSubTimes( )
	local vo = self:getAcVo()
	if vo.needTimesTab then
		for i=1,6 do
			if vo.needTimesTab[i] and vo.needTimesTab[i] >-1 then
				vo.needTimesTab[i] = vo.seedGrowTimesTab["p"..i][2]-base.serverTime
			end
		end
		activityVoApi:updateShowState(vo)
	end
	return nil
end
function acSweetTroubleVoApi:getGemsSecond(idx)
	local vo = self:getAcVo()
	if vo.gemsecond and vo.needTimesTab[idx] >0 then
		return math.ceil(vo.needTimesTab[idx] /vo.gemsecond)
	end
	return nil
end


function acSweetTroubleVoApi:getNeedTimesTab( )
	local vo = self:getAcVo()
	if vo.needTimesTab then
		return vo.needTimesTab
	end
	return nil
end
function acSweetTroubleVoApi:isChanData( num )
	local vo = self:getAcVo()
	if num==1 and vo.tab1Data then
		return vo.tab1Data
	elseif num ==2 and vo.tab2Data then
		return vo.tab2Data
	end
	return nil
end
function acSweetTroubleVoApi:setChanData( num,bool )
	local vo = self:getAcVo()
	if num ==1 then
		vo.tab1Data = bool
	elseif num ==2 then
		vo.tab2Data = bool
	end
	activityVoApi:updateShowState(vo)
	return nil
end




function acSweetTroubleVoApi:showRewardTip(award,isShow,sweetStr)
    if isShow==nil then
        isShow=true
    end
    local str = ""
    if award and SizeOfTable(award)>0 then
            str = getlocal("activity_sweettrouble_plantRec",{getlocal(sweetStr)})
        for k,v in pairs(award) do
            local nameStr=v.name
            if v.type=="c" then
                nameStr=getlocal(v.name,{v.num})
            end
            if k==SizeOfTable(award) then
                if v.type=="e" and v.eType=="a" then
                    str = str .. nameStr
                else
                    str = str .. nameStr .. " x" .. v.num
                end
            else
                if v.type=="e" and v.eType=="a" then
                    str = str .. nameStr .. ","
                else
                    str = str .. nameStr .. " x" .. v.num .. ","
                end
            end
        end
    end
    if isShow and str and str~="" then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
    end
    return str
end
