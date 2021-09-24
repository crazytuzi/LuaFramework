acTqbjVoApi={
	name=nil,
}
function acTqbjVoApi:clearAll()
	self.name = nil
end
function acTqbjVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acTqbjVoApi:setActiveName(name)
	self.name=name
end

function acTqbjVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acTqbjVoApi:getActiveName()
	return self.name or "tqbj"
end

function acTqbjVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acTqbjVoApi:canReward( )
	local vo = self:getAcVo()
	if self:isToday() and vo.curData and SizeOfTable(vo.curData) > 0 then
		for k,v in pairs(vo.curData) do--v[1] 充值次数  v[2] 领取次数
			if v and v[1] and v[2] and v[1] > v[2] then
				return true
			end
		end
	end
	return false
end

function acTqbjVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acTqbjVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acTqbjVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acTqbjVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acTqbjVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acTqbjVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acTqbjVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acTqbjVoApi:showInfoTipTb(layerNum)
	local tabStr = {}
	for i=1,5 do
        table.insert(tabStr,getlocal("activity_tqbj_tip"..i))
    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,26)
end

-------------------------------------------------------

function acTqbjVoApi:getLevelGroup( )
	local vo = self:getAcVo()
	if vo and vo.levelGroup then
		return vo.levelGroup
	end
	return {}
end

function acTqbjVoApi:getCellNum( )
	local vo = self:getAcVo()
	if vo and vo.rewardTb and vo.rewardTb[1] then
		return SizeOfTable(vo.rewardTb[1])
	end
	return 1
end

function acTqbjVoApi:getUseLevel( playerLevel )
	local vo  = self:getAcVo()
	local num = SizeOfTable(vo.levelGroup)
	local idx = 0
	for i=1, num do
		if tonumber(vo.levelGroup[i][2]) >= playerLevel and tonumber(vo.levelGroup[i][1]) <= playerLevel then
			idx = i
		end
	end
	return idx
end

function acTqbjVoApi:getCurRecharge(rechargeType)
	local moneyName = G_getCurMoneyName()
	local storeCfg=G_getPlatStoreCfg()
	local mType=storeCfg["moneyType"][moneyName]
	local realId = rechargeType
	local indexSortCfg=playerCfg.recharge.indexSort
	
	indexSortCfg=storeCfg.indexSort or indexSortCfg
	for k,v in pairs(indexSortCfg) do
		if tostring(v) == tostring(rechargeType) then
			realId = k
			do break end
		end
	end
	-- print("rechargeType=====realId=======>>>",rechargeType,realId)
	local mPrice=tonumber(storeCfg["money"][moneyName][tonumber(realId)])
	-- print("mPrice===>>>",mPrice)
	mPrice = G_getCurChoseLanguage() == "tw" and mPrice.."美" or mPrice
	-- mPrice = math.floor(mPrice) < mPrice and mPrice or math.floor(mPrice)
	return mPrice
end

function acTqbjVoApi:getCurCellAwardAndRechargeNum(idx,playerLevel)
	-- print("idx===playerLevel===>>>",idx,playerLevel)
	local useLevel           = self:getUseLevel(playerLevel)
	local vo                 = self:getAcVo()
	local thisAwardTb        = vo.rewardTb[useLevel][idx].reward
	local curCellAward       =FormatItem(thisAwardTb,true,true)
	local curCellTopAwardNum = vo.rewardTb[useLevel][idx].bn
	local curCellRecharge    = acTqbjVoApi:getCurRecharge(vo.rewardTb[useLevel][idx].recharge)
	-- print("curCellTopAwardNum,curCellRecharge,curCellAward,SizeOfTable(curCellAward)====>>>>",curCellTopAwardNum,curCellRecharge,curCellAward,SizeOfTable(curCellAward))
	-- print("useLevel=====>>>>",useLevel)
	return curCellTopAwardNum,curCellRecharge,curCellAward,SizeOfTable(curCellAward)
end

function acTqbjVoApi:getCurCellAllLevelAward(idx)
	local vo = self:getAcVo()
	local showAwardTb = {}
	local rechanrgeNum = 0
	for k,v in pairs(vo.rewardTb) do
		for mm,nn in pairs(v) do
			if mm == idx then
				rechanrgeNum = nn.recharge
				local awardTb = FormatItem(nn.reward,true,true)
				showAwardTb[k] = awardTb
			end
		end
	end
	print("SizeOfTable(showAwardTb)==>>>>>",SizeOfTable(showAwardTb))
	return showAwardTb
end

function acTqbjVoApi:getCurCellInfo(idx )
	local vo = self:getAcVo()
	if self:isToday() and vo.curData and SizeOfTable(vo.curData) > 0 then
		for k,v in pairs(vo.curData) do--v[1] 充值次数  v[2] 领取次数
			-- print("k----",k,v[1],v[2])
			if "t"..idx == k and v then
				local isCan = v[1] > v[2] and true or false
				local recNum = v[2]
				return isCan,recNum
			end
		end
	end
	
	return false,0
end

function acTqbjVoApi:removeCurData( )
	local vo = self:getAcVo()
	if vo and vo.curData then
		vo.curData = {}
	end
end

function acTqbjVoApi:recSocket(tid,EndCall)
	local function socketCall(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret == true then
            if sData and sData.data then
	        	if sData.data.tqbj then
	        		self:updateSpecialData(sData.data.tqbj)

	        		if sData.data.reward then
	        			local reward = FormatItem(sData.data.reward)
	        			for k,v in pairs(reward) do
			                G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
			            end
			            G_showRewardTip(reward,true)
			        end
			        if EndCall then
			        	EndCall()
			        end
	        	end
	        end
	        
		end
	end
	socketHelper:activeTqbj(socketCall,tid)
end




































