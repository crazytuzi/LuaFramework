acKafkaGiftVoApi = {}

function acKafkaGiftVoApi:getAcVo()
	return activityVoApi:getActivityVo("kafkagift")
end

function acKafkaGiftVoApi:isToday( )
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		return G_isToday(vo.lastTime)
	end
	return true
end

function acKafkaGiftVoApi:getRechargedGold( )--已充值的金币数 当天的
	local  vo = self:getAcVo()
	if vo and vo.recharged then
		return vo.recharged
	end
	return 0
end
function acKafkaGiftVoApi:setRechargeGold()
	local  vo = self:getAcVo()
	if vo and vo.recharged then
		vo.recharged =0
	end
end


function acKafkaGiftVoApi:getAwardFlagList( )--领过奖的标记列表
	local  vo = self:getAcVo()
	local FlagList = {}
	if vo and vo.recAwardFlagList then
		return vo.recAwardFlagList
	end
	return {}
end
function acKafkaGiftVoApi:clearAwardFlagList( )
	local vo = self:getAcVo()
	if vo and vo.recAwardFlagList then
		for i=1,SizeOfTable(vo.recAwardFlagList) do
			vo.recAwardFlagList[i]=0
		end
	end
end

-- function acKafkaGiftVoApi:initHadAwardList( )
-- 	local vo = self:getAcVo()
-- 	local cells = self:getAwardCells()
-- 	if vo and vo.hadAwardList then

-- end
function acKafkaGiftVoApi:setHadAwardList(idx,chooseHero )
	local vo = self:getAcVo()
	if vo and vo.hadAwardList then
		vo.hadAwardList[idx]=chooseHero
	end

end
function acKafkaGiftVoApi:getHadAwardList( idx)
	local vo = self:getAcVo()
	if vo and vo.hadAwardList and vo.hadAwardList[idx]~=0 then

		return vo.hadAwardList[idx]
	end
	return nil
end

function acKafkaGiftVoApi:setAwardFlagList(idx,sxIdx )
	local vo = self:getAcVo()
	for i=1,sxIdx do
		if i ==idx then
			vo.recAwardFlagList[i]=1
		elseif vo.recAwardFlagList[i] ==nil then
			vo.recAwardFlagList[i] =0
		end
	end
end

function acKafkaGiftVoApi:getChooseFlagList( )--领过奖的标记列表
	local  vo = self:getAcVo()
	local FlagList = {}
	if vo and vo.ChooseFlagList then

		return vo.ChooseFlagList
	end

	return {}
end
function acKafkaGiftVoApi:initChooseFlagList( )
	local vo = self:getAcVo()
	local cells = self:getAwardCells()
	if vo and vo.ChooseFlagList then
		for i=1,cells do
			if vo.ChooseFlagList[i] ==nil then
				vo.ChooseFlagList[i]=0
			end
		end
	end
end
function acKafkaGiftVoApi:setChooseFlagList(idx,sxIdx )
	local vo = self:getAcVo()

	if vo and vo.ChooseFlagList then
		vo.ChooseFlagList[sxIdx]=idx
	end

end

function acKafkaGiftVoApi:getCostStandardList( )--充值等级列表
	local vo = self:getAcVo()
	if vo and vo.costStandardList then
		return vo.costStandardList
	end
	return {}

end

function acKafkaGiftVoApi:getRequireInVipList()--选择奖励所需的VIP等级列表
	local vo = self:getAcVo()
	if vo and vo.requireInVipList then
		return vo.requireInVipList
	end
	return {}
end
function acKafkaGiftVoApi:getAwardCells( )
	local list = self:getRequireInVipList()
	if list and list["r1"] then
		return SizeOfTable(list["r1"])
	end
	return nil
end

function acKafkaGiftVoApi:getAwardList( )--奖励列表
	local vo = self:getAcVo()
	if vo and vo.awardList then

		return vo.awardList
	end
	return {}
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acKafkaGiftVoApi:addTotalMoney(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.recharged = acVo.recharged + money
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

function acKafkaGiftVoApi:getNeedGoldById( id ) --根据ID 取到相应等级的金币数
	local costList =self:getCostStandardList()
	if costList and SizeOfTable(costList) >0 then
		return tonumber(costList[id])
	end
	return nil
end

function acKafkaGiftVoApi:checkIfHadAwardById(id ) --根据ID 判断相应等级的奖励是否已经领取过
	local hadAwardInList = self:getAwardFlagList()
	if hadAwardInList and SizeOfTable(hadAwardInList)>0 then
		for k,v in pairs(hadAwardInList) do
			if k==id and v>0 then
				return true
			end
		end
	end
	return false
end

function acKafkaGiftVoApi:checkIfCanRewardById(id ) --根据ID 判断是否可以领取相应奖励
	local needGold = self:getNeedGoldById(id)
	local gold = self:getRechargedGold()
	if needGold and gold >= needGold then
		return true
	end
	return false
end

function acKafkaGiftVoApi:canReward( )
	local list = self:getRequireInVipList()
	if list and list["r1"] then
		local len = SizeOfTable(list["r1"])
		if len and len>0 then
			for i=1,len do
				if self:checkIfCanRewardById(i) ==true and self:checkIfHadAwardById(i) ==false then
					return true
				end
			end
		end
	end
	return false
end
function acKafkaGiftVoApi:getCurrentCanReward( )---返回所有可以领取的奖励
	local list = self:getRequireInVipList()
	if list and list["r1"] then
		local len = SizeOfTable(list["r1"])
		if len and len>0 then
			for i=1,len do
				if self:checkIfCanRewardById(i) ==true and self:checkIfHadAwardById(i) ==false then
					return self:getRewardR1ById(i),i
				end
			end
		end
	end
	return nil
end

function acKafkaGiftVoApi:getRewardR1ById(id)---根据ID 返回相应的奖励信息 (table)
	local awardList = self:getAwardList()
	local reward = awardList["r2"][id]
	if awardList ~= nil and reward ~= nil then
		return reward
	end
	return nil
end
function acKafkaGiftVoApi:getRewardR2ById(id)---根据ID 返回相应的奖励信息 (table)
	local awardList = self:getAwardList()
	local reward = awardList["r1"][id]
	local rr = {}
	local chose={}
	local tt = {}
	for k,v in pairs(reward) do
		for m,n in pairs(v) do
				local hh = {}
				local nn = G_clone(n)
				nn["index"]=k
				local index = k
				if rr[m] ==nil then
					rr[m] ={}
				end
				for i,j in pairs(n) do
					table.insert(tt,j)
				end
				table.insert(rr[m],nn)
				chose =rr[m]
		end
	end
	-- if chose and SizeOfTable(chose)>0 then
	-- 	print("~~~~~",SizeOfTable(chose))
	-- 	local function sortAsc(a, b)
	-- 			if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
	-- 				print("~~~~~",a.index , b.index)
	-- 				return a.index < b.index
	-- 			end
	--     end
	-- 	table.sort(chose,sortAsc)
	-- end
	return rr,tt
end



function acKafkaGiftVoApi:setBigAwardCellIdx( idx ) --设置特殊奖励的选择Cellidx（）
	local vo = self:getAcVo()
	if vo then
		vo.bigAwardCellIdx =idx
	else
		vo.bigAwardCellIdx =nil
	end
end
function acKafkaGiftVoApi:getBigAwardCellIdx(  )--拿到特殊奖励的选择Cellidx（）
	local vo = self:getAcVo()
	if vo and vo.bigAwardCellIdx then
		return vo.bigAwardCellIdx
	end
	return nil
end

function acKafkaGiftVoApi:setBigAwardInIdx( idx) --设置特殊奖励的选择idx（）
	local vo = self:getAcVo()
	if vo then
		vo.bigAwardInIdx = idx
	else
		vo.bigAwardInIdx =nil
	end
end

function acKafkaGiftVoApi:getBigAwardInIdx(  )--拿到特殊奖励的选择idx（）
	local vo  = self:getAcVo()
	if vo and vo.bigAwardInIdx then
		return vo.bigAwardInIdx
	end
	return nil
end
function acKafkaGiftVoApi:setSureToAward( SF)
	local  vo = self:getAcVo()
	if vo  then
		vo.SureAward =SF
	end
end
function acKafkaGiftVoApi:getSureToAward( )
	local vo  = self:getAcVo()
	if vo and vo.SureAward then
		return vo.SureAward
	end
	return nil
end


function acKafkaGiftVoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.c = acVo.c + 1
	end
	activityVoApi:updateShowState(acVo)
	acVo.stateChanged = true
end

function acKafkaGiftVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.time = G_getWeeTs(base.serverTime)
	end
end
function acKafkaGiftVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.time then
		isToday=G_isToday(vo.time)
	end
	return isToday
end

function acKafkaGiftVoApi:takeHeroOrder( id )
	if id  then
		local heroId = heroCfg.soul2hero[id]
		if heroId then
			local orderId = heroListCfg[heroId]["fusion"]["p"]
			return heroId,orderId
		end
		
	end
	return nil
end

-- item 格式整理之后的奖励对象  size 图片的大小，如100  isShowInfo 是否显示详细信息面板（true or false）layerNum 图标要放置的面板的layerNum, callback回调 
function acKafkaGiftVoApi:getItemIcon(item,size,isShowInfo,layerNum,callback)
    if item then
        local iconSize=100
        if size then
            iconSize=size
        end

        local function showInfoHandler(hd,fn,idx)

            callback(hd,fn,idx)
        end

        local icon
        if item.type=="h" then
            if item.eType=="h" then
                local productOrder=item.num
                icon = heroVoApi:getHeroIcon(item.key,productOrder,true,showInfoHandler,nil,nil,nil,{adjutants={}})
                item.num=1
            else
                icon = heroVoApi:getHeroIcon(item.key,1,false,showInfoHandler)
            end
        elseif item.type and item.type=="e" then
            if item.eType then
                if item.eType=="a" then
                    icon = accessoryVoApi:getAccessoryIcon(item.key,iconSize/100*80,iconSize,showInfoHandler)
                elseif item.eType=="f" then
                    icon = accessoryVoApi:getFragmentIcon(item.key,iconSize/100*80,iconSize,showInfoHandler)
                elseif item.pic and item.pic~="" then
                    icon = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
                end
            end
        elseif item.equipId then
            local eType=string.sub(item.equipId,1,1)
            if eType=="a" then
                icon = accessoryVoApi:getAccessoryIcon(item.equipId,iconSize/100*80,iconSize,showInfoHandler)
            elseif eType=="f" then
                icon = accessoryVoApi:getFragmentIcon(item.equipId,iconSize/100*80,iconSize,showInfoHandler)
            elseif eType=="p" then
                icon = LuaCCSprite:createWithSpriteFrameName(accessoryCfg.propCfg[award.equipId].icon,showInfoHandler)
            end
        elseif item.pic and item.pic~="" then
            if item.key == "energy" then
                icon = GetBgIcon(item.pic,showInfoHandler)
            else
                icon = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
            end
        end
        if icon then
            local scale=iconSize/icon:getContentSize().width
            icon:setScale(scale)
            return icon, scale
        end
        return nil
    end
    return nil
end

function acKafkaGiftVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo.version then
		return acVo.version
	end
	return nil
end