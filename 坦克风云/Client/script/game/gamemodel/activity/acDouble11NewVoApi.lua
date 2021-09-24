acDouble11NewVoApi={}

function acDouble11NewVoApi:getAcVo( )
	return activityVoApi:getActivityVo("double11new")
end

function acDouble11NewVoApi:canReward()

	return false
end

function acDouble11NewVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acDouble11NewVoApi:getStEdTime( )--拿到抢购时间段
	local vo = self:getAcVo()
	if vo and vo.timeShowTb then
		return vo.timeShowTb
	end
	return nil
end
function acDouble11NewVoApi:setLastTime(t)
	local vo = self:getAcVo()
	if vo and t then
		vo.lastTime =t
	end
end
function acDouble11NewVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
	end
end
function acDouble11NewVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		-- print("vo.lastTime---->",vo.lastTime)
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end


function acDouble11NewVoApi:getBeginGameTime( ) --拿到活动开启时间 不是抢购
	local vo = self:getAcVo()
	if vo and vo.st then
		return vo.st
	end
	return nil
end

function acDouble11NewVoApi:getCountdown( ) --拿到倒计时
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
function acDouble11NewVoApi:getScratchBeginOutTime(isNext)
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
function acDouble11NewVoApi:getScratchEndOutTime(isNext)
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
function acDouble11NewVoApi:isInTime( )--判断 当前时间是否在抢购时间内 并且拿到当前时间
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


function acDouble11NewVoApi:getCurShowShopIndex(nextSellShow)--拿到当前需要展示的商店idx,抢购商店的开关Tab
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

function acDouble11NewVoApi:returWhiPanicShop(nextSellShow)---返回当前可以抢购的商店Tab,在商店列表里的具体第几个
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


function acDouble11NewVoApi:getShowDiaAllNums(num,nextSellShow)--拿到可显示的板子数量，num 为一个板子可显示的数量,nextSellShow 第一个签使用的
	local  panicShop = self:returWhiPanicShop(nextSellShow)---tab里:i1 i2 i3 i4 i5 i6...
	local resNums = SizeOfTable(panicShop)--每个商店总道具数
	local mayShowNums = math.ceil(resNums/num)--num 为行数

	if mayShowNums then
		-- print("getShowDiaAllNums---->",resNums,mayShowNums)
		return mayShowNums,resNums,panicShop
	end
	-- print("getShowDiaAllNums--oooo-->",resNums,mayShowNums)
	return nil
end


function acDouble11NewVoApi:getPanicShopTbData(idx,num,nextSellShow)--idx 在板子上需要显示的id,num 为行数,nextSellShow--下一个需要展示
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

function acDouble11NewVoApi:getFuncTb( )---抢购 拿到抢购商店的对应功能信息信息
	local vo = self:getAcVo()
	if vo and vo.funcTb then
		return vo.funcTb
	end
	-- print("funcTb is nil")
	return {}
end
function acDouble11NewVoApi:getSwitchTab()--抢购 确定所有商店的开关,拿到开张的总商店个数
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

function acDouble11NewVoApi:getwhiSelfShop(whiNum)--拿到当前需要初始化的商店
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

function acDouble11NewVoApi:getShowSelfAllNums(num,idx)--拿到可显示的板子数量，num 页面可放置几列,idx 第几个商店
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


function acDouble11NewVoApi:getSelfShopTbData(idx,num,whiIdx)--idx 在板子上需要显示的id,num 为行数,
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

function acDouble11NewVoApi:getbuyShop( )---拿到打折商店的信息
	local vo = self:getAcVo()
	if vo and vo.buyShopTb then
		return vo.buyShopTb
	end
	return {}
end--

function acDouble11NewVoApi:getPanicedShopNums( )--拿到本轮的道具抢购的次数
	local  vo  = self:getAcVo()
	if vo and vo.shopPanicedNums then
		return vo.shopPanicedNums
	end
end
function acDouble11NewVoApi:setPanicedShopNums(shopPanicedNums)--更新本轮的道具抢购的次数
	local  vo  = self:getAcVo()
	if vo  and shopPanicedNums then
		 vo.shopPanicedNums =shopPanicedNums
	else
		vo.shopPanicedNums ={}
	end
end

function acDouble11NewVoApi:getbuyShopNums( )--拿到所有商店所有物品购买的次数
	local  vo  = self:getAcVo()
	if vo and vo.buyShopNumsTb then
		return vo.buyShopNumsTb
	end
end
function acDouble11NewVoApi:setbuyShopNums(buyShopNumsTb)--更新所有商店所有物品购买的次数
	local  vo  = self:getAcVo()
	if vo and buyShopNumsTb then
		 vo.buyShopNumsTb =buyShopNumsTb
	else
		vo.buyShopTb={}
	end
end

function acDouble11NewVoApi:getPanicShopTb( ) ---拿到抢购商店的信息
	local vo = self:getAcVo()
	if vo and vo.shopItemTb then
		return vo.shopItemTb
	end
	return {}
end

function acDouble11NewVoApi:setPanicedTab(panicedTab )--设置本轮已抢购的tab
	local vo = self:getAcVo()
	if vo and panicedTab and SizeOfTable(panicedTab) then
		vo.panicedTab=G_clone(panicedTab)
	else
		vo.panicedTab={}
	end
end
function acDouble11NewVoApi:getPanicedTab( )--拿到本轮已抢购的tab
	local vo = self:getAcVo()
	if vo and vo.panicedTab then
		return vo.panicedTab
	end
	return nil
end

function acDouble11NewVoApi:setEndts(endts )
	local vo = self:getAcVo()
	if vo and endts then
		vo.endts =endts
		-- local curTimeTb = G_getDate(base.serverTime)
		for k,v in pairs(vo.endts) do
			local tab = G_getDate(v)
			-- if curTimeTb.day > tab.day and curTimeTb.month == tab.month then
			-- 	vo.ents[k] = getlocal("day_num",{curTimeTb.day-tab.day})
			-- elseif curTimeTb.hour > tab.hour and curTimeTb.day == tab.day then
			-- 	vo.ents[k] =getlocal("muchHours",{curTimeTb.hour-tab.hour})
			if tab.min >1 then
				vo.endts[k] = getlocal("activity_fundsRecruit_time",{tab.min-1})
			elseif tab.sec >0 then
				vo.endts[k] = getlocal("second_num",{tab.sec})
			else
				vo.endts[k] = getlocal("second_num",{1})
			end
		end
	end
end
function acDouble11NewVoApi:getEndts(whiI)--拿到本轮抢购商品的抢光时间戳，转化成分钟或是秒 返回
	local vo = self:getAcVo()
	if vo and vo.endts[whiI] then
		return vo.endts[whiI]
	end
	return nil
end

function acDouble11NewVoApi:getScratchTimeTb( )
	local vo = self:getAcVo()
	if vo and vo.scratchTimeTb then
		return vo.scratchTimeTb
	end
	return nil
end

function acDouble11NewVoApi:setScratchTimeTb(scratchTimeTb)
	local vo = self:getAcVo()
	if vo and scratchTimeTb then
		 vo.scratchTimeTb =scratchTimeTb
	else
		vo.scratchTimeTb = {}
	end
end

function acDouble11NewVoApi:getScratchTb( )--拿到刮刮奖 奖池的金币数量
	local vo =self:getAcVo()
	if vo and vo.scratchTb then
		return vo.scratchTb
	end
end
function acDouble11NewVoApi:setScratchTb(scratchTb)--更新刮刮奖 奖池的金币数量
	local vo =self:getAcVo()
	if vo  then
		 vo.scratchTb = scratchTb
	end
end

function acDouble11NewVoApi:getLastScratchGold( )--拿到当前一次刮奖的金币数量
	local vo =self:getAcVo()
	if vo and vo.lastScratchGold then
		return vo.lastScratchGold
	end
end

function acDouble11NewVoApi:setLastScratchGold(gold)
	local vo =self:getAcVo()
	if vo and gold then
		 vo.lastScratchGold = gold
    else
    	vo.lastScratchGold =nil
	end
end

function acDouble11NewVoApi:getNearScratchGold()
	local vo =self:getAcVo()
	if vo and vo.nearScratchGold then
		return vo.nearScratchGold
	end
end
function acDouble11NewVoApi:setNearScratchGold(nearScratchGoldTb )--最近一次挂奖钱数
	local vo = self:getAcVo()
	if vo  and nearScratchGoldTb then
		vo.nearScratchGold = nearScratchGoldTb
	else
		vo.nearScratchGold =nil
	end
end

function acDouble11NewVoApi:isLastTim( )
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

function acDouble11NewVoApi:getChatSillValue( )
	local vo = self:getAcVo()
	if vo.chatSillValue then
		return vo.chatSillValue
	end
	return 0
end
function acDouble11NewVoApi:setChatSillValue(chatSillValue)
	local vo = self:getAcVo()
	if chatSillValue then
		vo.chatSillValue = chatSillValue
	end
end

--------------------------------红包

-- function acDouble11NewVoApi:setSingleIntoScratchTb(dgemstype,dgems)--更新单一某一类型的代币数量
-- 	print("setSingleIntoScratchTb~~~~~~~~~")
-- 	local vo =self:getAcVo()
-- 	if vo  then
-- 		if vo.scratchTb["g"..dgemstype] ==nil then
-- 			vo.scratchTb["g"..dgemstype] = dgems
-- 			print("dgems=====>",dgems)
-- 		else
-- 			print("vo.scratchTb[g..dgemstype] + dgems===>",vo.scratchTb["g"..dgemstype],dgems)
-- 			vo.scratchTb["g"..dgemstype] = vo.scratchTb["g"..dgemstype] + dgems
-- 		end
-- 	end
-- end

function acDouble11NewVoApi:getCurFlag()
	local vo = self:getAcVo()
	if vo and vo.curFlag then
		return vo.curFlag
	end
	return 0
end

function acDouble11NewVoApi:setCurFlag(curFlag)
	local vo = self:getAcVo()
	if vo and curFlag then
		vo.curFlag = curFlag
	end
end

function acDouble11NewVoApi:getPickNumTb( )
	local vo = self:getAcVo()
	if vo and vo.pickNumTb then
		return vo.pickNumTb
	end
	return nil
end

function acDouble11NewVoApi:getPickMoneyTb( )
	local vo = self:getAcVo()
	if vo and vo.pickMoneyTb then
		return vo.pickMoneyTb
	end
	return nil
end

function acDouble11NewVoApi:getDiscount( )
	local vo = self:getAcVo()
	if vo and vo.discount then
		return vo.discount
	end
	return 1
end

function acDouble11NewVoApi:getLvLimit( )
	local vo = self:getAcVo()
	if vo and vo.sendCorpRedBagLvLimit then
		return vo.sendCorpRedBagLvLimit
	end
	return 30
end

function acDouble11NewVoApi:getNumLimit( )
	local vo = self:getAcVo()
	if vo and vo.numLimit then
		return vo.numLimit
	end
	return 10
end

function acDouble11NewVoApi:setUsePickNum(pickNum)
	local vo = self:getAcVo()
	if vo and pickNum then
		vo.usePickNum =pickNum
	elseif pickNum ==nil then
		vo.usePickNum =nil 
	end
end
function acDouble11NewVoApi:setUsePickMoney(picMoney )
	local vo = self:getAcVo()
	if vo and picMoney then
		vo.usePickMoney =picMoney
	elseif picMoney ==nil then
		vo.usePickMoney =nil 
	end
end

function acDouble11NewVoApi:getUsePickNum( )
	local vo = self:getAcVo()
	if vo and vo.usePickNum then
		return vo.usePickNum
	end
	return nil
end

function acDouble11NewVoApi:getUsePickMoney( )
	local vo = self:getAcVo()
	if vo and vo.usePickMoney then
		return vo.usePickMoney
	end
	return nil
end


-------------------------------------------------------- 军团红包 新加处理 --------------------------------------------------------

function acDouble11NewVoApi:socketAllianceAllRedBagLog(initNewTab)
	
	local function getLogCallBack(fn,data )
		local ret,sData = base:checkServerData(data)
		if ret ==true and sData.data then


			if initNewTab then
				initNewTab()
			end
		end
	end
	socketHelper:double11NewAllianceAllLog(getLogCallBack)
end
--------------------------------------------------------   e   n   d   --------------------------------------------------------


function acDouble11NewVoApi:getCurNeedMoney( )--返回：1 消费的金币，2 赠送的代币
	local discount = self:getDiscount()
	local usePickNum = self:getUsePickNum()
	local usePickMoney = self:getUsePickMoney()
	local vo = self:getAcVo()
	if usePickNum ==nil or usePickMoney ==nil then
		return nil
	else
		return G_keepNumber(discount*vo.pickNumTb[usePickNum]*vo.pickMoneyTb[usePickMoney],0),G_keepNumber(vo.pickNumTb[usePickNum]*vo.pickMoneyTb[usePickMoney],0)
	end
end


function acDouble11NewVoApi:chatCorpRedBag( redid,redtype,redcount,redmethod,redbuyedTs)--后台返回后 直接军团广播，
	local paramTab={}
    paramTab.functionStr="double11NewWithRedBag"
    paramTab.addStr="activity_double11New_clickToGetRedBag"
    paramTab.redBagTb={redid =redid,redtype =redtype,sender=playerVoApi:getPlayerName(),redcount = redcount, redmethod = redmethod,redbuyedTs = redbuyedTs}
    local chatKey1="activity_double11New_CorpChat"
    local message={key=chatKey1,param={playerVoApi:getPlayerName()}}
    chatVoApi:sendSystemMessage(message,paramTab,nil,3,playerVoApi:getPlayerAid()+1)
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_double11New_sendSuccess"),30)
end

function acDouble11NewVoApi:formatNewAllainceRedBagTb(newTb)
	local formatedTb = {}
	local vo = self:getAcVo()
	local newTbUseNum = SizeOfTable(newTb)
	if newTbUseNum > 0 then
		newTbUseNum = newTbUseNum + 1
	end
	for k,v in pairs(newTb) do
		formatedTb[newTbUseNum - k] = {redid =v[1],sender=v[2],redbuyedTs = v[3],redtype = 2, redmethod = v[4], redcount = v[5]}
		if not v[6] then
			acDouble11NewVoApi:setRedBagTagbaseIdx(newTbUseNum - k,true)
			formatedTb[newTbUseNum - k].tag = acDouble11NewVoApi:getRedBagTagbaseIdx() + 1019
		else
			formatedTb[newTbUseNum - k].tag = nil
		end
	end
	vo.receivedCorpRedBagTb = G_clone(formatedTb)
end


function acDouble11NewVoApi:showSendRedBagPointDialog(redid,layerNum,redtype,dgemstype,dgems)--自己发出的红包记录--仅用于世界频道的红包！！不需要使用socket!!!redtype（红包类型）=1，世界；2，军团
	 local strSize2 = 20
	 if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
	 	strSize2 =23
	 end

	 local swhitchTb,idxs = self:getSwitchTab()
	 local inNum = 1
	 local shopName = nil
	 for k,v in pairs(swhitchTb) do
		 if v==0 then
		 elseif dgemstype ==inNum and v==1 then
			 shopName =getlocal("activity_double11_shopName_"..k)
			 do break end
		 else
			 inNum = inNum+1
		 end
	 end

	 local vo = self:getAcVo()
	 if vo.sendRedidTb[redid] and vo.sendRedidTb[redid] ==redid then
	 	print("error~~~!!!!~~~~~~~????",vo.sendRedidTb[redid],redid)
	 end
	 if vo and redid then
	 	vo.sendRedidTb[redid] = redid
	 end
	 local function tochat()
        local paramTab={}
        paramTab.functionStr="double11NewWithRedBag"
        paramTab.addStr="activity_double11New_clickToGetRedBag"
        paramTab.redBagTb={redid =redid,redtype =redtype,sender=playerVoApi:getPlayerName()}
        local chatKey1="activity_double11New_WorldChat"
        local message={key=chatKey1,param={playerVoApi:getPlayerName()}}
        chatVoApi:sendSystemMessage(message,paramTab)
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_double11New_sendSuccess"),30)
     end
	 local smallD=smallDialog:new()
	 smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tochat,getlocal("dialog_title_prompt"),getlocal("activity_double11New_SendTip",{shopName,dgems}),nil,layerNum+1,nil,nil,nil,getlocal("alliance_send_channel_1"),nil,nil,nil,nil,nil,strSize2,true)
end

function acDouble11NewVoApi:setNewGetRecord(redBagTb)--点击某一红包，获取红包相关信息
	local vo =self:getAcVo()
	if vo and redBagTb then
		vo.redBagRecordTb =redBagTb
		vo.corpRedBagRecordTb =nil
	end
end

function acDouble11NewVoApi:setNewGetRecordInCorp(corpRedBagTb)--点击某一军团红包，获取红包相关信息
	local vo =self:getAcVo()
	if vo and corpRedBagTb then
		vo.corpRedBagRecordTb =corpRedBagTb
		vo.redBagRecordTb =nil
	end
end

function acDouble11NewVoApi:getRedBag()--抢红包的接口
	
	local vo =self:getAcVo()
	local function getCallBack(fn,data )
		local ret,sData = base:checkServerData(data)
		if ret ==true and sData.data then
			if sData.data.double11new.dg then
                acDouble11NewVoApi:setScratchTb(sData.data.double11new.dg)--更新刮刮奖 奖池的金币数量
            end
			if sData.data.dgems and sData.data.dgemstype then
				self:showGetRedBagAnimation(sData.data.dgems , sData.data.dgemstype)
			elseif sData.data.grablog then
				local corpLimit = nil
				if vo.corpRedBagRecordTb then
					corpLimit = vo.pickNumTb[tonumber(vo.corpRedBagRecordTb.redcount)]
				end
				self:setCurFlag(sData.data.flag)
				self:showBlogDialog(sData.data.grablog,corpLimit)
			elseif sData.data.flag == 4 or sData.data.flag == 2 then
				self:setCurFlag(sData.data.flag)
				self:getRedBagBlogSocket()
			end
		end
	end 
	if vo.redBagRecordTb then
		socketHelper:double11NewPanicBuying(getCallBack,"getredbag",nil,nil,nil,tonumber(vo.redBagRecordTb.redid),tonumber(vo.redBagRecordTb.redtype))
	elseif vo.corpRedBagRecordTb then
		socketHelper:double11NewPanicBuying(getCallBack,"getredbag",nil,nil,nil,tonumber(vo.corpRedBagRecordTb.redid),tonumber(vo.corpRedBagRecordTb.redtype),tonumber(vo.corpRedBagRecordTb.redcount),tonumber(vo.corpRedBagRecordTb.redmethod))
	end
end

function acDouble11NewVoApi:getRedBagBlogSocket( )
	local vo =self:getAcVo()
	local function getCallBack(fn,data )
		local ret,sData = base:checkServerData(data)
		if ret ==true and sData.data then
			local corpLimit = nil
			if vo.corpRedBagRecordTb then
				corpLimit = vo.pickNumTb[tonumber(vo.corpRedBagRecordTb.redcount)]
			end

			self:showBlogDialog(sData.data.grablog,corpLimit)
		end
	end
	if vo.redBagRecordTb then
		socketHelper:double11NewPanicBuying(getCallBack,"redbaglog",nil,nil,nil,tonumber(vo.redBagRecordTb.redid),tonumber(vo.redBagRecordTb.redtype))
	elseif vo.corpRedBagRecordTb then
		socketHelper:double11NewPanicBuying(getCallBack,"redbaglog",nil,nil,nil,tonumber(vo.corpRedBagRecordTb.redid),tonumber(vo.corpRedBagRecordTb.redtype),tonumber(vo.corpRedBagRecordTb.redcount),tonumber(vo.corpRedBagRecordTb.redmethod))
	end
end



function acDouble11NewVoApi:showBlogDialog(grablog,corpLimit)
	local vo =self:getAcVo()
	require "luascript/script/game/scene/gamedialog/activityAndNote/acDouble11NewShowBlogDialog"
	local sender = vo.redBagRecordTb and vo.redBagRecordTb.sender or vo.corpRedBagRecordTb.sender
    local sd=acDouble11NewShowBlogDialog:new(grablog,sender,corpLimit)
    sd:init(10)
end

function acDouble11NewVoApi:showGetRedBagAnimation(dgems,dgemstype)--
	-- spriteController:addPlist("public/acBlessWords.plist")
	local swhitchTb,idxs = self:getSwitchTab()
	local inNum = 1
	local shopName = nil
	for k,v in pairs(swhitchTb) do
		if v==0 then
		elseif dgemstype ==inNum and v==1 then
			shopName =getlocal("activity_double11_shopName_"..k)
			do break end
		else
			inNum = inNum+1
		end
	end
	
	local function bgCallBack( ) end 
	local getRedBagBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),bgCallBack)
    getRedBagBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    getRedBagBg:setPosition(getCenterPoint(sceneGame))
    getRedBagBg:setTouchPriority(-(10-1)*20-10)
    getRedBagBg:setOpacity(200)
    sceneGame:addChild(getRedBagBg,10);

    local function sureHandler()
         getRedBagBg:removeFromParentAndCleanup(true)
         -- spriteController:removePlist("public/acBlessWords.plist")
         if shopName ==nil then
         	shopName =getlocal("congratulation")
         end
         local function nodataCall( ) end
         smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_double11New_getRedBagNow",{shopName,dgems}),nil,12,nil,nodataCall)
    end


    local smallGetRedBagBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),sureHandler)
    smallGetRedBagBg:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.24,G_VisibleSizeHeight*0.2))
    smallGetRedBagBg:setPosition(getCenterPoint(sceneGame))
    smallGetRedBagBg:setTouchPriority(-(10-1)*20-11)
    smallGetRedBagBg:setOpacity(0)
    getRedBagBg:addChild(smallGetRedBagBg,10);


    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(G_VisibleSizeWidth*0.5,80))
    sureMenu:setTouchPriority(-(10-1)*20-11);
    getRedBagBg:addChild(sureMenu)

    local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp:setPosition(getCenterPoint(getRedBagBg))
    guangSp:setScale(2.5)
    getRedBagBg:addChild(guangSp,1)

    local iconFuzi = "friendBtn.png"
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
    	iconFuzi = "bless_getword.png"
    end
    local fuzi = CCSprite:createWithSpriteFrameName(iconFuzi)
    fuzi:setPosition(getCenterPoint(getRedBagBg))
    fuzi:setScale(2.2)
    getRedBagBg:addChild(fuzi,2)
    local time = 0.07
    local rotate1=CCRotateTo:create(time, 30)
    local rotate2=CCRotateTo:create(time, -30)
    local rotate3=CCRotateTo:create(time, 20)
    local rotate4=CCRotateTo:create(time, -20)
    local rotate5=CCRotateTo:create(time, 0)

    local delay=CCDelayTime:create(1)
    local acArr=CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq=CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
    fuzi:runAction(repeatForever)
end


function acDouble11NewVoApi:setRecBagTbTagNil(tag,idx)--idx: 通过军团红包板子清理图标tag tag:通过点击抢红包清理图标tag
	local vo = self:getAcVo()
	if vo and vo.receivedCorpRedBagTb and SizeOfTable(vo.receivedCorpRedBagTb) > 0 and idx then
		-- print("tag------vo.receivedCorpRedBagTb[idx].tag-->>",tag,vo.receivedCorpRedBagTb[idx].tag)
		vo.receivedCorpRedBagTb[idx].tag =nil
	elseif vo and vo.receivedCorpRedBagTb and SizeOfTable(vo.receivedCorpRedBagTb) > 0 and tag then
			for k,v in pairs(vo.receivedCorpRedBagTb) do
				if v.tag == tag then
					vo.receivedCorpRedBagTb[k].tag =nil
				end
			end
	end
end

function acDouble11NewVoApi:isHasTag(tag)
	local vo = self:getAcVo()
	for k,v in pairs(vo.receivedCorpRedBagTb) do
		if v.tag == tag then
			-- print("yes~~~~~~~tag---->>>>>",tag)
			return true
		end
	end
	return false
end

function acDouble11NewVoApi:setReceivedCorpRedbagTb(corpRedBagTb )--corpRedBagTb 是单体  vo.receivedCorpRedBagTb 最多接收15个单体
	local vo = self:getAcVo()
	if vo and corpRedBagTb then
		if SizeOfTable(vo.receivedCorpRedBagTb) <15 then
			table.insert(vo.receivedCorpRedBagTb,corpRedBagTb)
		else
			local refreshTb = {}
			for i=2,15 do
				table.insert(refreshTb,vo.receivedCorpRedBagTb[i])
			end
			table.insert(refreshTb,corpRedBagTb)
			vo.receivedCorpRedBagTb = G_clone(refreshTb)
		end
		self:setIsNewCorpTbReceived(1)
	end
end

function acDouble11NewVoApi:getReceivedCorpRedbagTb( )
	local vo = self:getAcVo()
	if vo and vo.receivedCorpRedBagTb then
		return vo.receivedCorpRedBagTb
	end
	return {}
end

function acDouble11NewVoApi:getIsNewCorpTbReceived( )
	local vo = self:getAcVo()
	if vo and vo.isNewCorpTbReceived then
		return vo.isNewCorpTbReceived
	end
	return 0
end
function acDouble11NewVoApi:setIsNewCorpTbReceived(isNew)--设置是否有新的红包数据， 
	local vo = self:getAcVo()
	if vo and isNew then
		vo.isNewCorpTbReceived =isNew
	end
end

function acDouble11NewVoApi:setRedBagTagbaseIdx(idx,only)
	local vo = self:getAcVo()

	if vo and idx then
		if only then
			vo.redBagTagbaseIdx = idx
		else
			vo.redBagTagbaseIdx = vo.redBagTagbaseIdx +idx
		end
	end
end

function acDouble11NewVoApi:getRedBagTagbaseIdx()
	local vo = self:getAcVo()
	if vo and vo.redBagTagbaseIdx then
		return vo.redBagTagbaseIdx
	end
	return nil
end

function acDouble11NewVoApi:showActionTip( parent,tag,ccPos)
    -- print("in showActionTip~~~~~~")
    local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp:setPosition(ccPos)
    guangSp:setScale(0.48)
    guangSp:setTag(tag)
    parent:addChild(guangSp,3)

    local iconFuzi = "friendBtn.png"
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
    	iconFuzi = "bless_getword.png"
    end
    local fuzi = CCSprite:createWithSpriteFrameName(iconFuzi)
    fuzi:setPosition(ccPos)
    fuzi:setScale(0.45)
    fuzi:setTag(tag+1000)
    parent:addChild(fuzi,3)
    local time = 0.07
    local rotate1=CCRotateTo:create(time, 30)
    local rotate2=CCRotateTo:create(time, -30)
    local rotate3=CCRotateTo:create(time, 20)
    local rotate4=CCRotateTo:create(time, -20)
    local rotate5=CCRotateTo:create(time, 0)

    local delay=CCDelayTime:create(1)
    local acArr=CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq=CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
    fuzi:runAction(repeatForever)

    return guangSp,fuzi
end