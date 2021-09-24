acLoversDayVoApi={
	recordList=nil,
	requestLogFlag = false,
}

function acLoversDayVoApi:addActivieIcon()
	spriteController:addPlist("public/acLoversDay.plist")
	spriteController:addTexture("public/acLoversDay.png")
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acLoversDayVoApi:removeActivieIcon()
	spriteController:removePlist("public/acLoversDay.plist")
	spriteController:removeTexture("public/acLoversDay.png")
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acLoversDayVoApi:clearAll()
	self.recordList=nil
	self.requestLogFlag = false
	self.vo=nil
end
function acLoversDayVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("wdyo")
	end
	return self.vo
end

function acLoversDayVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

function acLoversDayVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acLoversDayVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acLoversDayVoApi:canReward()
	if self:isToday() == false then
		print(" is free day?????????")
		return true
	end
	return false
end

function acLoversDayVoApi:getShopCfg()--2
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.shop then
		return vo.activeCfg.shop
	end
	return {}
end

function acLoversDayVoApi:getBuyData(saleId)--2
	local cur=0 --已购次数
	local vo=self:getAcVo()
	if vo and vo.shop then
		cur=vo.shop[saleId] or 0
	end
	return cur
end

function acLoversDayVoApi:getShopIndexTb()--2
	local vo=self:getAcVo()
	local shopIndexTb={}
	local oldShopIndexTb={}
	if vo and vo.activeCfg and vo.activeCfg.shop then
		local shop=vo.activeCfg.shop
		local num=SizeOfTable(shop)
		for i=1,num do
			local index=i
			local saleId="i" .. i
			if shop[saleId].limit then
				local limit=shop[saleId].limit
				local nowNum=self:getBuyData(saleId)
				if nowNum>=limit then
					index=index+1000
				end
			end
			table.insert(shopIndexTb,{index=index,saleId=saleId})
			table.insert(oldShopIndexTb,{index=i,saleId=saleId})
		end
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(shopIndexTb,sortFunc)
	return shopIndexTb,oldShopIndexTb
end

--自己当前的任务点(同心结)
function acLoversDayVoApi:getMyPoint()
	local vo=self:getAcVo()
	if vo and vo.score then
		return vo.score
	end
	return 0
end


--item商店兑换的宝箱
function acLoversDayVoApi:sendRewardNotice(rtype,item)--2
    local playerName=playerVoApi:getPlayerName()
    local activityName=getlocal("activity_loversDay_title")
    local message
    if rtype==1 then
    	message={key="activity_mineExploreG_notice2",param={playerName,activityName}}
	elseif rtype==2 then
		if item and item.name then
    		message={key="activity_mineExploreG_notice2",param={playerName,activityName,item.name}}
		end
    end
    if message then
    	local paramTab={}
    	paramTab.functionStr="loversDay"
        paramTab.addStr="goTo_see_see"
    	chatVoApi:sendSystemMessage(message,paramTab)
    end
end

function acLoversDayVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end


function acLoversDayVoApi:isShowTip( )
	local vo = self:getAcVo()
	local shopIndexTb,oldShopIndexTb=self:getShopIndexTb()
	local shopCfg=acLoversDayVoApi:getShopCfg() or {}
	local ownNum=acLoversDayVoApi:getMyPoint()
	for i=1,3 do
		local indexCfg=oldShopIndexTb[i]
		local saleId=indexCfg.saleId
		local cur = self:getBuyData(saleId)
		local saleCfg=shopCfg[saleId]
		local price=saleCfg.g
		if cur < saleCfg.limit and ownNum >= price then
			-- print("cur---saleCfg.limit----ownNum------price----->",cur,saleCfg.limit,ownNum,price)
			return true
		end
	end
	
end


--------------------------------------------------------------------------------

function acLoversDayVoApi:getAwardPic( )
	local vo = self:getAcVo()
	if vo.activeCfg and vo.activeCfg.picture then
		return vo.activeCfg.picture
	end
	print(" get non pic~~~~!!!!!!")
	return {}
end

function acLoversDayVoApi:getScoreCfg()
	local vo = self:getAcVo()
	if vo and vo.activeCfg.getScore then
		return vo.activeCfg.getScore
	end
	print("error in getScoreCfg--------!!!!!")
	return {}
end

function acLoversDayVoApi:getRecordList()
	return self.recordList or {}
end

function acLoversDayVoApi:getCostWithOneAndTenTimes( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.cost1,vo.activeCfg.cost2
	end
	-- print("error in getCostWithOneAndTenTimes--------!!!!!")
	return nil
end

function acLoversDayVoApi:setRecord(record)
	if self.recordList==nil then
		self.recordList={}
	end
	self.recordList = record
end

function acLoversDayVoApi:getAwardList( )
	local vo = self:getAcVo()
	local awardForTb = {}
	if vo and vo.activeCfg and vo.activeCfg.reward then
		 awardForTb = FormatItem(vo.activeCfg.reward,nil,true)
	end
	-- print("awardForTb nums-------->",SizeOfTable(awardForTb))
	return awardForTb
end

function acLoversDayVoApi:getRequestLogFlag()
	return self.requestLogFlag
end

--------------------------------------------------------------------------------
function acLoversDayVoApi:setCurReward( curReward )
	local vo = self:getAcVo()
	if vo and curReward then
		vo.curReward = curReward
	elseif curReward == nil then
		vo.curReward = {}
	end
end
function acLoversDayVoApi:getCurReward( )
	local vo = self:getAcVo()
	if vo and vo.curReward then
		return vo.curReward
	end
	return {}
end

function acLoversDayVoApi:setCurAwardPoint( point)
	local vo = self:getAcVo()
	if vo and point then
		vo.curPoint = point
	elseif point ==nil then
		vo.curPoint = 0 
	end
end
function acLoversDayVoApi:getCurAwardPoint( )
	local vo = self:getAcVo()
	if vo and vo.curPoint then
		local mateCfg = self:getScoreCfg()
		local curOldAwardTb = self:getOldAwardIdTb()
		local isSame = 0
		local curPoint = vo.curPoint
		if curPoint == mateCfg[1]*10 then
			for k,v in pairs(curOldAwardTb[1]) do
				for m,n in pairs(curOldAwardTb[2]) do
					if v == n then
						isSame = isSame +1
					end
				end
			end
			if isSame == 0 then
				curPoint =  curPoint/10
			end
		elseif curPoint > mateCfg[#mateCfg] then
			curPoint = curPoint/10
		end
		-- print("isSame = ----->",isSame)

		for k,v in pairs(mateCfg) do
			-- print("v----curPoint-->",v,curPoint)
			if v == curPoint then
				-- print("kkkkk------>",k)
				return vo.curPoint,k,curPoint
			end
		end
		
	end
	return 0
end
function acLoversDayVoApi:getOldAwardIdTb( )
	local vo = self:getAcVo()
	if vo and vo.curOldAwardTb then
		return vo.curOldAwardTb
	end
	return {}
end
function acLoversDayVoApi:setCurAwardIdTb(report )
	local vo = self:getAcVo()
	if vo and report then
		if #vo.curAwardTb > 0 then
			vo.curAwardTb = {}
		end
		for k,v in pairs(report) do
			for m,n in pairs(v) do
				table.insert(vo.curAwardTb,n)
			end
		end
		vo.curOldAwardTb = report
		-- vo.curAwardTb = report
	elseif report == nil then
		vo.curAwardTb = {}
		vo.curOldAwardTb = {}
	end
end
function acLoversDayVoApi:getCurAwardIdTb( )
	local vo = self:getAcVo()
	if vo and vo.curAwardTb then
		return vo.curAwardTb
	end
	return {}
end

--活动所有请求数据处理
function acLoversDayVoApi:loversDayRequest(action,varArg,callback,isShowTip)--2
	if action=="active.wuduyouou.rand" then 
		local function digCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.wdyo then
	            		self:updateData(sData.data.wdyo)
	            	end
	            	if varArg[1] and varArg[1] > 1 then
	            		playerVoApi:setGems(playerVoApi:getGems()-varArg[2])
	            	end
            		if sData.data.reward then
            			local rewardList = FormatItem(sData.data.reward)
            			self:setCurReward(rewardList)
            			for k,v in pairs(rewardList) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
            		end

            		if sData.data.report then
            			self:setCurAwardIdTb(sData.data.report)
            		end
            		if sData.data.point then
            			self:setCurAwardPoint(sData.data.point)
            		end

            		if callback then
	                	callback()
	                end
				end
	        end
	    end
		socketHelper:loversDayRequest(action,varArg[1],nil,digCallBack)
	elseif action=="active.wuduyouou.buy" then--商店购买
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.wdyo then
	            	self:updateData(sData.data.wdyo)
	            end
	            local rewardlist
	            local saleId=varArg[1]
	            if saleId then
           			local shopCfg=self:getShopCfg()[saleId]
	            	if shopCfg and shopCfg.reward then
	            		rewardlist=FormatItem(shopCfg.reward)
	            	end
	            end
	            if rewardlist then
					for k,v in pairs(rewardlist) do
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
					G_showRewardTip(rewardlist)
	            end
  			   	if callback then
                	callback()
                end
	        end
	    end
	    -- print("buy----------varArg[1]----->",varArg[1])
		socketHelper:loversDayRequest(action,nil,varArg[1],rewardCallback)
	elseif action=="active.wuduyouou.getlog" then --获取抽奖日志
		local function logHandler(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.wdyo then
	            	self:updateData(sData.data.wdyo)
	            end

	            -- self.requestLogFlag=true
	      		if sData and sData.data and sData.data.log then
				  	if sData.data.log then
				  		local logData = sData.data.log
				  		local allTimes = SizeOfTable(logData)
				  		local logList = {}
				  		local  mateCfg = self:getScoreCfg()
				  		for i=1,allTimes do

		            		local rewards={}--其他奖励
		            		local contentAll = {}
		            		local num=logData[i][3]--代币
		            		local numc = num > mateCfg[#mateCfg] and (num/10) or num

		            		local sucessMateNum = 0
		            		local item1 = {}

	            			if logData[i][2] then--配对奖励
		            			local reward=FormatItem(logData[i][2])
		            			for k,v in pairs(reward) do
		            				table.insert(rewards,v)
		            			end
		            		end
		            		
		            		for k,v in pairs(mateCfg) do
		            			if v == numc then
		            				sucessMateNum = k-1 
		            			end
		            		end
		            		if num == mateCfg[1]*10 and logData[i][1] == 10 then -- 本次抽奖 10倍 num == 最低值 那么 配对为 0 
		            			sucessMateNum = 0
		            		end
	        				if num and num>0 then
	            				local key="p3348"
	            				local type="p"
	            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
								table.insert(rewards,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num})
	            			end
	            			if SizeOfTable(rewards) > 0 then
		            			item1[1] = rewards
								table.insert(contentAll,item1)
							end

							local ts=logData[i][4]--时间
	            			local digNum=logData[i][1] or 1--抽奖次数
	            			-- local beishuStr = 1
	                		local colorCur=G_ColorWhite
	                		local bShu = getlocal("merge_precent_name3")
	                		if digNum and digNum > 1 then--merge_precent_name3
	                			colorCur = G_ColorYellowPro
	                			bShu = "10"..getlocal("activity_refitPlanT99_bigRewardRateAdd")
	                			-- beishuStr = 10
	                		end
	                		local desc=getlocal("activity_loversDay_mateSucess",{sucessMateNum,bShu})

							table.insert(logList,{title={desc,colorCur},ts=ts,content=contentAll})
							
				  		end
				  		self:setRecord(logList)
	            	end

				   	if callback then
                		callback(true)
                	end
                else
                	if callback then
                		callback(false)
                	end
	      		end  
	        end
	    end
		socketHelper:loversDayRequest(action,nil,nil,logHandler)
	end
end