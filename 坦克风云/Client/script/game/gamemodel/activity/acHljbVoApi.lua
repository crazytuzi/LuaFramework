acHljbVoApi={
	name=nil,
	exFormatTb=nil,
	willKeepNum=0,
}
function acHljbVoApi:clearAll()
	self.willKeepNum = nil
	self.exFormatTb = nil
	self.name = nil
	self.rateTb = nil
end

function acHljbVoApi:clearVo( )
	local vo = acHljbVoApi:getAcVo()
	if vo then
		vo.htb = {}
		vo.gtb = {}
		vo.gAddRate = 0
	end
end

function acHljbVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acHljbVoApi:setActiveName(name)
	self.name=name
end

function acHljbVoApi:getActiveName()
	return self.name or "hljb"
end

function acHljbVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acHljbVoApi:canReward( )

	return false
end

function acHljbVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acHljbVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acHljbVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acHljbVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acHljbVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acHljbVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acHljbVoApi:addPoint(newPoint)
	local vo = self:getAcVo()
	if vo and vo.point then
		vo.point = newPoint + vo.point
	end
end

------------------------------------------------------------------------------------------------------------------
--tip 
function acHljbVoApi:getAcTime( ) -- 聚宝倒计时
	local vo = self:getAcVo()
	local str = ""
	if vo and vo.acTime then
		local curT = vo.et - (vo.et - vo.st - vo.acTime) - base.serverTime
		local activeTime = curT > 0 and G_formatActiveDate(curT) or nil
		if not activeTime then
			str = getlocal("activity_hljb_acTimeEnd")
		else
			str = getlocal("activity_hljb_acTime")..":"..activeTime
		end
	end
	return str
end

function acHljbVoApi:getExTime()--兑换倒计时
	local vo = self:getAcVo()
	if vo and vo.acTime then
		local activeTime = G_formatActiveDate(vo.et - base.serverTime)
		if not self:isExTime() then
			activeTime = getlocal("activity_hljb_ExTimeNoOpen")
			return activeTime
		else
			return getlocal("activity_hljb_exTime")..":"..activeTime
		end
	end
	return ""
end

--是否处于兑换时间
function acHljbVoApi:isExTime()
	local vo = self:getAcVo()
	-- print("base.serverTime--->>>",base.serverTime)
	if vo then
		if base.serverTime > (vo.st + vo.acTime) and base.serverTime < vo.et then
			return true
		end
	end
	return false
end

function acHljbVoApi:getExTimeInDay()--兑换具体天数
	local vo = self:getAcVo()
	if vo and vo.acTime then
		return math.floor((vo.et - vo.st - vo.acTime) / 86400) + 1
	end
	print " ========= e r r o r in getExTimeInDay ========"
	return 0
end

function acHljbVoApi:getRateTb()
	local vo = self:getAcVo()
	local acDay = 0
	if vo and vo.acTime then
		acDay = math.floor(vo.acTime / 86400)
		-- print("acDay----->>>>",acDay)
	end
	if self.rateTb and SizeOfTable(self.rateTb) > 0 then
		return self.rateTb,acDay
	else
		self.rateTb = {}
		if acDay > 0 then
			for i=1,acDay do
				self.rateTb[i] = vo.dailyAddRate * i * 100  
				-- print("self.rateTb[i]--->>",self.rateTb[i],vo.startRate,vo.dailyAddRate * i * 100)
			end
			return self.rateTb,acDay
		end
	end
	print("self.rateTb is not into data!!!!!",self.rateTb)
	return nil
end

function acHljbVoApi:getTabOneTipTb()
	local vo = self:getAcVo()
	local exDay = self:getExTimeInDay()
	local rateTb = self:getRateTb()
	local lbTb = {}
	for i=1,9 do
		if i == 1 then
			lbTb[i] = getlocal("activity_hljb_tab1_tip1",{exDay})
		elseif i == 4 then
			lbTb[i] = getlocal("activity_hljb_tab1_tip4",{rateTb[1],rateTb[2],rateTb[3],rateTb[4],rateTb[5]})
		elseif i == 8 then
			local num = self:getNumToPoint()
			local point = vo.usePointNum <= 1 and 1 or vo.usePointNum
			local itemName = getlocal(vo.acName)
			lbTb[i] = getlocal("activity_hljb_tab1_tip8",{num,itemName,point})
		elseif i == 3 then
			local acName = getlocal(vo.acName)
			local dailyChargeAddLimit=vo.dailyChargeAddLimit
			lbTb[i] = getlocal("activity_hljb_tab1_tip3",{dailyChargeAddLimit,acName})
		elseif i ==9 then
			if vo.activeCfg.version == 1 then
				lbTb[i] = getlocal("activity_hljb_tab1_tip"..i)
			end
		else
			lbTb[i] = getlocal("activity_hljb_tab1_tip"..i)
		end
	end
	return lbTb
end

function acHljbVoApi:getNumToPoint()---单个物品可获得积分
	local vo = self:getAcVo()
	if vo and vo.usePointNum then
		if vo.usePointNum >= 1 then
			return 1
		end
		local num = 1 / vo.usePointNum

		if math.floor(num) < num then
			for i=1,5 do
				if math.floor(num) < num then
					num = num * 10
				else
					do break end
				end
			end
			if math.floor(num) < num then
				num = math.floor(num)
			end
		end
		-- print("num---->>>",num)
		return num
	end
end

function acHljbVoApi:getTabTwoTipTb( )
	local exDay = self:getExTimeInDay()
	local lbTb = {}
	for i=1,3 do
		if i == 1 then
			lbTb[i] = getlocal("activity_hljb_tab2_tip1",{exDay})
		else
			lbTb[i] = getlocal("activity_hljb_tab2_tip"..i)
		end
	end
	return lbTb
end

function acHljbVoApi:showInfoTipTb(layerNum,lbTb,textFormatTb,newTitleStr)
    local titleStr=newTitleStr or getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,lbTb,nil,22,textFormatTb)
end

------------------------------------------------------------------------------------------------------------------
--t a b  O n e

function acHljbVoApi:getActiveData()
	local vo = self:getAcVo()
	local acName = ""
	if vo and vo.acName then
		acName = getlocal(vo.acName)
	end
	local getUsePer = vo.startRate + vo.dailyAddRate * 5 + vo.dailyChargeAddRate * 5 + vo.activeCfg.FirstAddRate

	--=x*5*(1+dailyAddRate*5+FirstAddRate+dailyChargeAddRate*5）
	local recNum = (vo.dailyLimit + vo.dailyChargeAddLimit) * 5 * getUsePer  
	-- print("getUsePer--->>>", vo.startRate , vo.dailyAddRate * 5,vo.dailyLimit,vo.dailyChargeAddLimit)
	return acName,vo.dailyLimit + vo.dailyChargeAddLimit,recNum
end
function acHljbVoApi:getDayRate( )
	local vo = self:getAcVo()
	if vo and vo.dailyAddRate and vo.dailyChargeAddRate then
		return vo.dailyAddRate * 100 , (vo.dailyAddRate * 5 + vo.dailyChargeAddRate * 5 + vo.activeCfg.FirstAddRate) * 100
	end
	return 0,0
end

function acHljbVoApi:getLogSocket(callBack)
	local function getLogSuccCall( fn,data )
		local ret,sData = base:checkServerData(data)
		if ret then
			if sData and sData.data and sData.data.log then
				self:updateSpecialData(sData.data)
				if callBack then
					callBack()
				end
			end
		end
	end
	socketHelper:acHljbSocket(getLogSuccCall,"getlog")
end

function acHljbVoApi:getLog()
	local vo = self:getAcVo()
	return vo.log
end

function acHljbVoApi:getKeepItemAllDays( )--存放了几天的东西，（每天都有存放，并且最后一天没有取出）
	local vo = self:getAcVo()
	local stayDay = 0
	if vo and SizeOfTable(vo.htb) > 0 then
		local tag = 1
		local rateTb,acDays = self:getRateTb()
		for i=1,acDays do
			if vo.htb["d"..i] == 1 then
				stayDay = stayDay + tag
			elseif vo.htb["d"..i] == 2 then
				stayDay = 0
			end
		end
	end
	return stayDay
end

function acHljbVoApi:getCurRecRate( )--当前返利比 基础 + 充值
	local vo = self:getAcVo()

	local rateTb,acDays = self:getRateTb()
	--天数增加比率
    local dAddRate = 0
	local largeBaseRate = 0
	local gAddRate = vo.gAddRate * 100 --gAddRate：FirstAddRate+dailyChargeAddRate*满足充值金币天数
	if vo then
		local function getRate(day)
			local rate = 0
	        local start = false
	        for i=1,day do
	            local ackey = "d"..i  
	            if vo.htb[ackey] or (vo.keepTb[ackey] and vo.keepTb[ackey] == vo.dailyChargeAddLimit) then --该天有存入或者取出操作，或者充值累计达到 dailyChargeAddLimit 时
	                if vo.htb[ackey] then --该天有存入或者取出操作
	                    if vo.htb[ackey] == 1 then --表示该天存入了物品，则返利比增加 dailyAddRate
	                        rate = rate + vo.dailyAddRate
	                        start = true
	                    else --表示该天取出了物品（则返利全部从取出当天开始重新计算）
	                        rate = 0
	                        start = false
	                        if vo.keepTb[ackey] == vo.dailyChargeAddLimit then
	                            start = true
	                            rate = rate + vo.dailyAddRate --当天累计充值达到 dailyChargeAddLimit 则相当于存入了物品，则返利比初始化为 dailyAddRate
	                        end
	                    end
	                elseif vo.keepTb[ackey] == vo.dailyChargeAddLimit then --没有操作时如果玩家充值累计达到 dailyChargeAddLimit 则相当于存入了物品，则返利比累加 dailyAddRate
	                    start = true
	                    rate = rate + vo.dailyAddRate
	                end
	            else --该天没有任何的操作，也没有充值到 dailyChargeAddLimit 时
	                if start then --如果前一天有存入操作（充值达到累计金额也算存入）则返利比根据存入天数累加 dailyAddRate
	                    rate = rate + vo.dailyAddRate
	                end
	            end
	        end
	        if start == false then --如果玩家还没有开始进行任何的存入操作，则默认显示 dailyAddRate 的返利比
                rate = vo.dailyAddRate    	
	        end
	        rate = rate * 100
	        return rate
		end
		local currDay = self:getCurDay()
		dAddRate = getRate(currDay)
		largeBaseRate = getRate(acDays)
	end
	return dAddRate + gAddRate,dAddRate,gAddRate,largeBaseRate + gAddRate
end

function acHljbVoApi:getHtbNum( )
	local vo = self:getAcVo() 
	if vo and vo.htb then
		return SizeOfTable(vo.htb)
	end
	return 0 
end

function acHljbVoApi:getRateTip( )
	local allRate,baseRate,gAddRate,noData,startRate = self:getCurRecRate()
	local dayAdd,dayAdd2 = self:getDayRate()
	local curRateLb2 = getlocal("totolKeep",{acHljbVoApi:getAllKeepNums()}) .."\n"..getlocal("curRateStr2",{baseRate,gAddRate, baseRate + gAddRate}).."\n"..getlocal("activity_hljb_upTip2", {dayAdd,dayAdd2})

	
	-- local curRateLb3 = getlocal("activity_hljb_upTip2", {dayAdd,dayAdd2})
	return {curRateLb2}
end

function acHljbVoApi:getCurDay( )
	local vo = self:getAcVo()
	if vo then
		local curDay = 0
		if base.serverTime >= (vo.st + vo.acTime) then
			curDay = math.floor(vo.acTime / 86400)
			return curDay
		end
		for i=1,5 do
			if base.serverTime - vo.st <= 86400 * i then
				curDay = i
				do break end
			end
		end
		-- print("curDay----->>>>",curDay)
		return curDay
	end
	return 0
end

function acHljbVoApi:getCurRechargeGoldAndEnough()--当前这天充值的金币数，和是否满足充值要求
	local vo = self:getAcVo()
	local curDay = self:getCurDay()
	if vo and vo.gtb and vo.gtb["d"..curDay] and vo.dailyRecharge then
		return vo.gtb["d"..curDay], vo.gtb["d"..curDay] >= vo.dailyRecharge
	end
	return 0,false
end

function acHljbVoApi:getCurDayKeepLimit()--当前这天的存入上限
	local vo = self:getAcVo()
	local gold,isEnough = self:getCurRechargeGoldAndEnough()
	if vo and vo.dailyLimit and vo.dailyChargeAddLimit then
		if isEnough then
			return vo.dailyLimit + vo.dailyChargeAddLimit,vo.dailyLimit
		else
			return vo.dailyLimit,vo.dailyLimit
		end
	end
	print "======== e r r o r in getCurDayKeepLimit ========"
	return 0
end

function acHljbVoApi:getCurDayKeepItem( )--当前这天存入的数量
	local vo = self:getAcVo()
	local curDay = self:getCurDay()
	if vo and vo.keepTb and type(vo.keepTb)=="table" then

		if vo and vo.keepTb and vo.keepTb["d"..curDay] then
			return vo.keepTb["d"..curDay]

		-- liuning修改: 优化当天充值后且当天取出金币，今日已存为显示为0情况
		-- elseif next(vo.keepTb) == nil and vo.gtb then
		-- 	for k,v in pairs(vo.gtb) do
	 --        	local strCurday = "d"..curDay
	 --        	if k == strCurday then
	 --        	  return vo.dailyChargeAddLimit
	 --        	end
	 --        end
		end
	end
	
	return 0
end

function acHljbVoApi:getCurCanKeepItemNum( )
	local keepedNum               = self:getCurDayKeepItem()
	local keepLimit,keepBaseLimit = self:getCurDayKeepLimit()
	local rechargeNum,isEnough    = self:getCurRechargeGoldAndEnough()
	local vo = self:getAcVo()
	if not isEnough then
		return keepLimit,keepLimit-- 可存下限，可存上限
	elseif keepedNum == 0 then
		return keepBaseLimit,keepLimit
	else
		return 1,keepLimit - keepedNum
	end
end

function acHljbVoApi:getCurDayDoingType()
	local vo = self:getAcVo()
	local curDay = self:getCurDay()
	if vo then
		if vo and vo.htb and vo.htb["d"..curDay] then
			return vo.htb["d"..curDay]
		end
	end
	return nil
end

function acHljbVoApi:getCurDayDoingTip(onlyTake)
	local vo              = self:getAcVo()
	local curkeepNum      = self:getCurDayKeepItem()
	local curKeepLimitNum = self:getCurDayKeepLimit()
	local curDoingType    = self:getCurDayDoingType()
	if onlyTake then
		if curDoingType then
			return getlocal("doingOverStr")
		elseif vo.keepTb == 0 or SizeOfTable(vo.keepTb) == 0 then
			return getlocal("notTakeTip")
		end
	elseif curDoingType and curDoingType == 2 then
		return getlocal("doingOverStr")
	elseif curKeepLimitNum <= curkeepNum then
		return getlocal("keepOverStr")
	end
	return nil
end
----------------------------------------------------------更换配置需要修改这里
function acHljbVoApi:getCurHasItem( )
	local vo = self:getAcVo()
	if vo and vo.acName then
		if vo.acName == "gem" then--金币
			local useIcon = GetBgIcon("resourse_normal_gem.png")
			return playerVoApi:getGems() or 0,useIcon,getlocal(vo.acName)
		elseif vo.acName == "armorMatrix_name_exp" then
			local useIcon = GetBgIcon("armorMatrixExp.png",nil,"equipBg_blue.png")
			local armorExp = (armorMatrixVoApi and armorMatrixVoApi.armorMatrixInfo) and armorMatrixVoApi.armorMatrixInfo.exp or 0
			return armorExp , useIcon ,getlocal(vo.acName)
		end
	end
	return nil
end

function acHljbVoApi:setLastHasItem(subNum,addNum) -- 存入后剩余的数量
	local vo = self:getAcVo()
	if vo and vo.acName then
		if subNum then
				if vo.acName == "gem" then
					playerVoApi:setGems(playerVoApi:getGems() - subNum)
				elseif vo.acName == "armorMatrix_name_exp" then
					if armorMatrixVoApi and armorMatrixVoApi.armorMatrixInfo and armorMatrixVoApi.armorMatrixInfo.exp then
						armorMatrixVoApi.armorMatrixInfo.exp = armorMatrixVoApi.armorMatrixInfo.exp - subNum
					end
				end
		elseif addNum then
			if vo.acName == "gem" then
				playerVoApi:setGems(playerVoApi:getGems() + addNum)
			elseif vo.acName == "armorMatrix_name_exp" then
				if armorMatrixVoApi and armorMatrixVoApi.armorMatrixInfo and armorMatrixVoApi.armorMatrixInfo.exp then
					armorMatrixVoApi.armorMatrixInfo.exp = armorMatrixVoApi.armorMatrixInfo.exp + addNum
				end
			end
		end
	end
end

function acHljbVoApi:getAllKeepNums( )
	local vo = self:getAcVo()
	if vo and vo.keepTb and type(vo.keepTb)=="table"  then
		local n = 0
		for k,v in pairs(vo.keepTb) do
			n = v + n
		end
		return n
	end
	return 0
end

function acHljbVoApi:getCanTakeItems( )--当前可取出的所有数量 可给予的积分
	local vo = self:getAcVo()
	local curRate, baseRate, gAddRate, largeRate = acHljbVoApi:getCurRecRate()
	local canTakeNums = self:getAllKeepNums()
	-- print("canTakeNums--->>>",canTakeNums,curRate,largeRate)
	local curCanTakeNums = math.floor(canTakeNums * curRate / 100) + canTakeNums--当前可领取的物品数量
	local larCanTakeNums     = math.floor(canTakeNums * largeRate  / 100) + canTakeNums--最大领取物品数量
	local curCanGetPoints    = math.floor(vo.usePointNum * curCanTakeNums)--当前可获得积分
	local larCanGetPoints    = math.floor(vo.usePointNum * larCanTakeNums)--最大积分数量
	local useIcon,useIcon2 = "", ""

	if vo.acName == "gem" then--金币
		useIcon = GetBgIcon("resourse_normal_gem.png")
		useIcon2 = GetBgIcon("resourse_normal_gem.png")
	elseif vo.acName == "armorMatrix_name_exp" then
		useIcon = GetBgIcon("armorMatrixExp.png",nil,"equipBg_blue.png")
		useIcon2 = GetBgIcon("armorMatrixExp.png",nil,"equipBg_blue.png")
	end
	return useIcon, curRate, curCanTakeNums, curCanGetPoints, useIcon2, largeRate, larCanTakeNums, larCanGetPoints
end
----------------------------------------------------------

function acHljbVoApi:takeSocket(callBack, addNum)
	local function takeSuccCall( fn,data )
		local ret,sData = base:checkServerData(data)
		if ret then
			if sData and sData.data and sData.data.hljb then
				self:updateSpecialData(sData.data.hljb)
				self:setLastHasItem(nil,addNum)
				-- self:willKeepItemNum()
				if callBack then
					callBack()
				end
			end
		end
	end
	socketHelper:acHljbSocket(takeSuccCall,"get")
end

function acHljbVoApi:willKeepItemNum(newNum)
	if newNum then
		self.willKeepNum = newNum
	else
		self.willKeepNum = 0
	end
end
function acHljbVoApi:getKeepItemNum( )
	return self.willKeepNum
end

function acHljbVoApi:keepSocket(callBack,keepNum)
	local function keepSuccCall( fn,data )
		local ret,sData = base:checkServerData(data)
		if ret then
			if sData and sData.data and sData.data.hljb then
				self:updateSpecialData(sData.data.hljb)
				self:setLastHasItem(keepNum)
				self:willKeepItemNum()
				if callBack then
					callBack()
				end
			end
		end
	end
	socketHelper:acHljbSocket(keepSuccCall,"set",nil,keepNum)
end

function acHljbVoApi:getRechageTipData( )
	local vo = self:getAcVo()
	local curGold,isEnough = self:getCurRechargeGoldAndEnough()
	return vo.dailyRecharge ,curGold,isEnough
end
function acHljbVoApi:getRechagedKeepNumAndRate( )
	local vo = self:getAcVo()
	--liuning修改
	local curDay = self:getCurDay()
	if vo.gtb then
		if SizeOfTable(vo.gtb) == 0 then 
           return vo.dailyChargeAddLimit,(vo.dailyChargeAddRate + vo.activeCfg.FirstAddRate) * 100
        end

        if SizeOfTable(vo.gtb) == 1 then
        	for k,v in pairs(vo.gtb) do
        	   local strCurday="d"..curDay

        	   if k == strCurday then
        	   	return vo.dailyChargeAddLimit,(vo.dailyChargeAddRate + vo.activeCfg.FirstAddRate) * 100

        	   end
            end
        end 
    end
	return vo.dailyChargeAddLimit,vo.dailyChargeAddRate * 100
end



function acHljbVoApi:showbtnTip(str)
	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
end
------------------------------------------------------------------------------------------------------------------
--t a b  T w o
function acHljbVoApi:getCurPoint( )--当前的积分
	local vo = self:getAcVo()
	if vo and vo.point then
		return vo.point
	end
	return 0
end

function acHljbVoApi:getExChangeAward(idx)
	local vo = self:getAcVo()
	if vo and vo.exchangeList then
		if not self.exchangeList then
			self.exFormatTb = {}
			for k,v in pairs(vo.exchangeList) do
				local reward = FormatItem(v.reward,nil)[1]
				-- print("reward---->>>",reward.name,reward.id,reward.iconImage)
				self.exFormatTb[v.order] = {}
				self.exFormatTb[v.order].order = v.order
				self.exFormatTb[v.order].price = v.price
				self.exFormatTb[v.order].limit = v.limit
				self.exFormatTb[v.order].reward = reward
				-- print("v.order---->>>",v.order)

			end
		end
		if idx and self.exFormatTb[idx] then
			return self.exFormatTb[idx]
		end
		return self.exFormatTb
	end
	return nil
end

function acHljbVoApi:getShowExChangeAward()
	local vo = self:getAcVo()

	if not self.exFormatTb then
		self:getExChangeAward()
	end
	-- print("self.exFormatTb---size-->>",SizeOfTable(self.exFormatTb))
	if vo and SizeOfTable(vo.hadExTb) > 0 then
		local newTb = {}
		local endTb = {}
		for k,v in pairs(self.exFormatTb) do
			if vo.hadExTb["i"..k] and v.limit <= vo.hadExTb["i"..k] then
				v.endEx = true
				v.hadExNum = vo.hadExTb["i"..k]
				table.insert(endTb,v)
			else
				v.hadExNum = vo.hadExTb["i"..k]
				table.insert(newTb,v)
			end
		end
		for k,v in pairs(endTb) do
			table.insert(newTb,v)
		end
		-- print("newTb---size--->>",SizeOfTable(newTb))
		return newTb
	elseif SizeOfTable(vo.hadExTb) == 0 then
		return self.exFormatTb
	else
		return {}
	end

	return nil
end


function acHljbVoApi:exchangeSocket(id,num,callBack)
	local function exchangeSuccCall(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret then
			if sData and sData.data and sData.data.hljb then
				self:updateSpecialData(sData.data.hljb)
				if callBack then
					callBack()
				end
			end
		end
	end
	socketHelper:acHljbSocket(exchangeSuccCall,"changeItem","i"..id,num)
end