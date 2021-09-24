acDouble11VoApi={}

function acDouble11VoApi:getAcVo( )
	return activityVoApi:getActivityVo("double11")
end

function acDouble11VoApi:canReward()

	return false
end

function acDouble11VoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acDouble11VoApi:getStEdTime( )--拿到抢购时间段
	local vo = self:getAcVo()
	if vo and vo.timeShowTb then
		return vo.timeShowTb
	end
	return nil
end
function acDouble11VoApi:setLastTime(t)
	local vo = self:getAcVo()
	if vo and t then
		vo.lastTime =t
	end
end
function acDouble11VoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
	end
end
function acDouble11VoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		-- print("vo.lastTime---->",vo.lastTime)
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end


function acDouble11VoApi:getBeginGameTime( ) --拿到活动开启时间 不是抢购
	local vo = self:getAcVo()
	if vo and vo.st then
		return vo.st
	end
	return nil
end

function acDouble11VoApi:getCountdown( ) --拿到倒计时
	local zeroTime=G_getWeeTs(base.serverTime)
	local hour=math.floor((base.serverTime - zeroTime)/3600)
	local curMin=math.floor(((base.serverTime - zeroTime)%3600)/60)
	local curSec=(base.serverTime - zeroTime)%60
	-- local curTime = os.date("*t",base.serverTime)--拿到当前时间（年月日时分秒）  GetTimeStr
	-- local curMin = tonumber(curTime["min"])
	-- local curSec = tonumber(curTime["sec"])
	-- local needCurMin = nil
	curMin = 60-curMin-1
	curSec =60-curSec-1
	if curMin <0 then
		curMin =0
	end
	if curSec <0 then
		curmSec =0
	end
	return curMin,curSec
end
function acDouble11VoApi:getScratchBeginOutTime(isNext)
	local PanicTimeTb = self:getStEdTime()
	local needBeginTime =nil
	local zeroTime=G_getWeeTs(base.serverTime)
	local hour=math.floor((base.serverTime - zeroTime)/3600)
	local curMin=math.floor(((base.serverTime - zeroTime)%3600)/60)
	local curSec=(base.serverTime - zeroTime)%60

	-- local curTime = os.date("*t",base.serverTime)
	local str = nil
	if isNext then
		 needBeginTime = (PanicTimeTb[1]+1)*3600+G_getWeeTs(base.serverTime)-base.serverTime
	else
		needBeginTime = (PanicTimeTb[1])*3600+G_getWeeTs(base.serverTime)-base.serverTime
	end
	if hour== PanicTimeTb[1]-1 then
		str=GetTimeStr(needBeginTime,1)
	else
		str=GetTimeStr(needBeginTime,2)
	end
	return str
end
function acDouble11VoApi:getScratchEndOutTime(isNext)
	local PanicTimeTb = self:getStEdTime()
	local needEndTime = nil
	local str = nil
	if isNext then
		 needEndTime = (24-PanicTimeTb[2])*3600+G_getWeeTs(base.serverTime+24*3600)+(PanicTimeTb[1]+1)*3600-base.serverTime
	else
		needEndTime = (24-PanicTimeTb[2])*3600+G_getWeeTs(base.serverTime+24*3600)+PanicTimeTb[1]*3600-base.serverTime
	end
	str=GetTimeStr(needEndTime,2)
	-- end
	return str
end
function acDouble11VoApi:isInTime( )--判断 当前时间是否在抢购时间内 并且拿到当前时间
	local vo  = self:getAcVo()
	local StEdTImeTb = self:getStEdTime()
	-- local curTime = os.date("*t",base.serverTime)--拿到当前时间（年月日时分秒）
	local zeroTime=G_getWeeTs(base.serverTime)
	local hour=math.floor((base.serverTime - zeroTime)/3600)
	local curMin=math.floor(((base.serverTime - zeroTime)%3600)/60)
	local curSec=(base.serverTime - zeroTime)%60
	
	if hour>= StEdTImeTb[1] and  hour<= StEdTImeTb[2] then
		-- print("curTime--true--->",curTime["hour"])
		return true,hour,curMin
	-- elseif curTime["hour"]< StEdTImeTb[1] then
	-- 	return
	elseif hour ==8 and curMin >54 then
		return false,hour,curMin,true
	end
	-- print("curTime--false--->",curTime["hour"])
	return false,hour,curMin
end


function acDouble11VoApi:getCurShowShopIndex(nextSellShow)--拿到当前需要展示的商店idx,抢购商店的开关Tab
	local inTime,curTime 		= self:isInTime() --
	local switchTab,switchNums 	= self:getSwitchTab()
	local timeShowTb 			= self:getStEdTime()
	local curShowShopIndex=nil
	local idx = 1
	if nextSellShow==true then
		idx =2
	end
	if nextSellShow ==false then
		idx =3
	end
	if inTime ==true then
		if timeShowTb[2] and timeShowTb[1] and curTime and switchNums then
			curShowShopIndex =((timeShowTb[2]-timeShowTb[1])-(timeShowTb[2]-curTime)+idx)%switchNums
			-- print("curShowShopIndex---->", curShowShopIndex)
			if curShowShopIndex ==0 then
				return switchNums,switchTab
			else
				return curShowShopIndex,switchTab
			end
		end
	end

	return idx,switchTab
end

function acDouble11VoApi:returWhiPanicShop(nextSellShow)---返回当前可以抢购的商店Tab,在商店列表里的具体第几个
	local curShowShopIndex,allSwitchTab = self:getCurShowShopIndex(nextSellShow)--当前需要展示的抢购商店idx,抢购商店的开关Tab
	local allPanicTab 					= self:getPanicShopTb()
	local inSwitchTab 					= 1
		if curShowShopIndex then
			for k,v in pairs(allSwitchTab) do
				if v ==0 then
					-- print("k-----v-------",k,v)
				elseif v ==1 and inSwitchTab ==curShowShopIndex then
					-- print("returWhiPanicShop----->k",k)
						return allPanicTab[k],k
				else
					inSwitchTab=inSwitchTab+1
				end
			end
			-- print("no find Show PanicShop")
		end
		-- print("nil~~~~~~")
	return nil
end


function acDouble11VoApi:getShowDiaAllNums(num,nextSellShow)--拿到可显示的板子数量，num 为一个板子可显示的数量,nextSellShow 第一个签使用的
	local  panicShop,panicShopIdx = self:returWhiPanicShop(nextSellShow)---tab里:i1 i2 i3 i4 i5 i6...
	local resNums = SizeOfTable(panicShop)--每个商店总道具数
	local mayShowNums = math.ceil(resNums/num)--num 为行数

	if mayShowNums then
		-- print("getShowDiaAllNums---->",resNums,mayShowNums)
		return mayShowNums,resNums,panicShop,panicShopIdx
	end
	-- print("getShowDiaAllNums--oooo-->",resNums,mayShowNums)
	return nil
end


function acDouble11VoApi:getPanicShopTbData(idx,num,nextSellShow)--idx 在板子上需要显示的id,num 为行数,nextSellShow--下一个需要展示
	local mayShowNums,resNums,panicShop = self:getShowDiaAllNums(num,nextSellShow)
	-- local showIdx = idx
	-- print("getPanicShopTbData---->",idx,num,panicShop["i"..idx])
	-- for k,v in pairs(panicShop["i"..idx]) do
	-- 	print(k,v)
	-- end
	local needResData = panicShop["i"..idx]
	local rewardTb = FormatItem(needResData["r"])
	local initRewardTb = G_clone(rewardTb)
	rewardTb[1].pic = G_getItemIcon(rewardTb[1],100,false)
	if rewardTb ==nil then
		-- print("rewardTb----->nil")
	end

	return needResData["p"],needResData["g"],needResData["bn"],rewardTb,initRewardTb--bn=buynum  p=原价   g= 抢购价
end

function acDouble11VoApi:getFuncTb( )---抢购 拿到抢购商店的对应功能信息信息
	local vo = self:getAcVo()
	if vo and vo.funcTb then
		return vo.funcTb
	end
	-- print("funcTb is nil")
	return {}
end
function acDouble11VoApi:getSwitchTab()--抢购 确定所有商店的开关,拿到开张的总商店个数
	local vo = self:getAcVo()
	local funcTb = self:getFuncTb()
	local  idx = 0
	-- print("base.ifSuperWeaponOpen---base.alien---base.heroSwitch---base.ifAccessoryOpen",base.ifSuperWeaponOpen,base.alien,base.heroSwitch,base.ifAccessoryOpen)
	for k,v in pairs(vo.switchTab) do
		if funcTb[k] ==0 then
			idx =idx+1
			vo.switchTab[k]=1			
		elseif funcTb[k] =="ec" and base.ifAccessoryOpen==1 then
			-- v=1
			idx =idx+1
			vo.switchTab[k]=1
		elseif funcTb[k]=="alien" and base.alien ==1 then
			-- v=1
			idx =idx+1
			vo.switchTab[k]=1
			-- print("k-----funcTb",k,v)
		elseif funcTb[k] =="sw" and base.ifSuperWeaponOpen ==1 then
			-- v=1
			idx =idx+1
			vo.switchTab[k]=1
			-- print("k-----funcTb",k,v)
		elseif funcTb[k] =="hero" and base.heroSwitch ==1 then
			-- v=1
			idx =idx+1
			vo.switchTab[k]=1
		elseif funcTb[k] =="he" and base.he ==1 then
			idx =idx+1
			vo.switchTab[k]=1
		end
		
	end
	return vo.switchTab,idx
end

function acDouble11VoApi:getwhiSelfShop(whiNum)--拿到当前需要初始化的商店
	local buyShopTb = self:getbuyShop()
	local swhitchTb,idxs = self:getSwitchTab()
	local inNum = 1
	for k,v in pairs(swhitchTb) do
		if v==0 then

		elseif whiNum ==inNum and v==1 then
			return buyShopTb[k],k
		else
			inNum = inNum+1
		end
	end
	-- print("nil----->getwhiSelfShop")
	return nil
end

function acDouble11VoApi:getShowSelfAllNums(num,idx)--拿到可显示的板子数量，num 页面可放置几列,idx 第几个商店
	local  selfShop = self:getwhiSelfShop(idx)---tab里:i1 i2 i3 i4 i5 i6...
	local resNums = SizeOfTable(selfShop)--每个商店总道具数
	local mayShowNums = math.ceil(resNums/num)--num 为列数

	if mayShowNums then
		-- print("getShowDiaAllNums---->",resNums,mayShowNums)
		return mayShowNums,resNums,selfShop
	end
	-- print("getShowDiaAllNums--oooo-->",resNums,mayShowNums)
	return nil
end


function acDouble11VoApi:getSelfShopTbData(idx,num,whiIdx)--idx 在板子上需要显示的id,num 为行数,
	local mayShowNums,resNums,selfShop = self:getShowSelfAllNums(num,whiIdx)
	local needResData = selfShop["i"..idx]
	local rewardTb = FormatItem(needResData["r"])
	local initRewardTb = G_clone(rewardTb)
	 rewardTb[1].pic = G_getItemIcon(rewardTb[1],100,false)
	if rewardTb ==nil then
		-- print("rewardTb----->nil")
	end

	return needResData["p"],needResData["g"],needResData["bn"],rewardTb,initRewardTb--bn=buynum  p=原价   g= 抢购价
end

function acDouble11VoApi:getbuyShop( )---拿到打折商店的信息
	local vo = self:getAcVo()
	if vo and vo.buyShopTb then
		return vo.buyShopTb
	end
	return {}
end--

function acDouble11VoApi:getPanicedShopNums( )--拿到本轮的道具抢购的次数
	local  vo  = self:getAcVo()
	if vo and vo.shopPanicedNums then
		return vo.shopPanicedNums
	end
end
function acDouble11VoApi:setPanicedShopNums(shopPanicedNums)--更新本轮的道具抢购的次数
	local  vo  = self:getAcVo()
	if vo  and shopPanicedNums then
		 vo.shopPanicedNums =shopPanicedNums
	else
		vo.shopPanicedNums ={}
	end
end

function acDouble11VoApi:getbuyShopNums( )--拿到所有商店所有物品购买的次数
	local  vo  = self:getAcVo()
	if vo and vo.buyShopNumsTb then
		return vo.buyShopNumsTb
	end
end
function acDouble11VoApi:setbuyShopNums(buyShopNumsTb)--更新所有商店所有物品购买的次数
	local  vo  = self:getAcVo()
	if vo and buyShopNumsTb then
		 vo.buyShopNumsTb =buyShopNumsTb
	else
		vo.buyShopTb={}
	end
end

function acDouble11VoApi:getPanicShopTb( ) ---拿到抢购商店的信息
	local vo = self:getAcVo()
	if vo and vo.shopItemTb then
		return vo.shopItemTb
	end
	return {}
end

function acDouble11VoApi:setgDouble11rTb( )
	local pShopItem = acDouble11VoApi:getPanicShopTb( )
	for k,v in pairs(pShopItem) do
		local vNum = SizeOfTable(v)
		gDouble11rTb[k] = {}

		local useTb = {}
		for i=1,vNum do
			useTb[i] = i
		end
		for i=1,vNum do
			local useNum = math.random(1,SizeOfTable(useTb))
			gDouble11rTb[k][i] = useTb[useNum]
			table.remove(useTb,useNum)
		end
	end
end


function acDouble11VoApi:setPanicedTab(panicedTab )--设置本轮已抢购的tab
	local vo = self:getAcVo()
	if vo and panicedTab and SizeOfTable(panicedTab) then
		vo.panicedTab=G_clone(panicedTab)
	else
		vo.panicedTab={}
	end
end
function acDouble11VoApi:getPanicedTab( )--拿到本轮已抢购的tab
	local vo = self:getAcVo()
	if vo and vo.panicedTab then
		return vo.panicedTab
	end
	return nil
end

function acDouble11VoApi:getScratchTimeTb( )
	local vo = self:getAcVo()
	if vo and vo.scratchTimeTb then
		return vo.scratchTimeTb
	end
	return nil
end

function acDouble11VoApi:setScratchTimeTb(scratchTimeTb)
	local vo = self:getAcVo()
	if vo and scratchTimeTb then
		 vo.scratchTimeTb =scratchTimeTb
	else
		vo.scratchTimeTb = {}
	end
end

function acDouble11VoApi:getScratchTb( )--拿到刮刮奖 奖池的金币数量
	local vo =self:getAcVo()
	if vo and vo.scratchTb then
		return vo.scratchTb
	end
end
function acDouble11VoApi:setScratchTb(scratchTb)--更新刮刮奖 奖池的金币数量
	local vo =self:getAcVo()
	if vo  then
		 vo.scratchTb = scratchTb
	end
end

function acDouble11VoApi:getLastScratchGold( )--拿到当前一次刮奖的金币数量
	local vo =self:getAcVo()
	if vo and vo.lastScratchGold then
		return vo.lastScratchGold
	end
end

function acDouble11VoApi:setLastScratchGold(gold)
	local vo =self:getAcVo()
	if vo and gold then
		 vo.lastScratchGold = gold
    else
    	vo.lastScratchGold =nil
	end
end

function acDouble11VoApi:getNearScratchGold()
	local vo =self:getAcVo()
	if vo and vo.nearScratchGold then
		return vo.nearScratchGold
	end
end
function acDouble11VoApi:setNearScratchGold(nearScratchGoldTb )--最近一次挂奖钱数
	local vo = self:getAcVo()
	if vo  and nearScratchGoldTb then
		vo.nearScratchGold = nearScratchGoldTb
	else
		vo.nearScratchGold =nil
	end
end

function acDouble11VoApi:isLastTim( )
	local vo = self:getAcVo()
	local stEdTime = self:getStEdTime()
	local lastDay=vo.et-24*3600
	if vo  and vo.et then
		if base.serverTime > lastDay then
			if base.serverTime> lastDay+(stEdTime[2]-1)*3600 then
				return true
			end
		end
	end
	return false
end

function acDouble11VoApi:getChatSillValue( )
	local vo = self:getAcVo()
	if vo.chatSillValue then
		return vo.chatSillValue
	end
	return 0
end
function acDouble11VoApi:setChatSillValue(chatSillValue)
	local vo = self:getAcVo()
	if chatSillValue then
		vo.chatSillValue = chatSillValue
	end
end