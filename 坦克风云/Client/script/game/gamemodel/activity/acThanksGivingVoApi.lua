acThanksGivingVoApi ={}

function  acThanksGivingVoApi:getAcVo( )
	return activityVoApi:getActivityVo("ganenjiehuikui")
end
function acThanksGivingVoApi:canReward()
	if self:upData() ==1 then
		return true
	end
	return false
end

function acThanksGivingVoApi:upData( )
	local isRec = 0
	if self:getAcVo() ==nil then
		 do return isRec end
	end
	for i=1,3 do
        local taskedNum = 0
        local awardList ={}
        local factorValue = 0 --拿到的条件限制
        local whiKey = nil
         --领奖颜色标示
        if i ==1 then
             whiKey = "jg"
             taskedNum = math.floor(self:getMerit( ))
        elseif i ==2 then
             whiKey = "res"
             taskedNum = math.floor(self:getCargo( ))
        elseif i ==3 then
             whiKey = "challenge"
             taskedNum = math.floor(self:getGameLevel( ))
        end
        local needIdxInAward,isOver,showAwardIdx,AwardedIdx = self:getNeedIdxInAward(i) --
        awardList,factorValue= self:getUpDiaAward(needIdxInAward,whiKey)
        if tonumber(factorValue) <= tonumber(taskedNum) and isOver ==false then
            isRec=1
        end
    end
   
    if isRec ==0 then
    	local rechargedGold = self:getRechargedGold( )--已充值的金币数
	    for i=1,3 do
	 		local needRecharge = self:getNeedRechargeNum(i)
	        local sjNum= self:getRechargedInAwardSS()
	        local rechargeAwardTb = self:getRechargedLogTb()
	        -- print("--------->",tonumber(rechargedGold),tonumber(needRecharge) , rechargeAwardTb[i])
	        if needRecharge and tonumber(rechargedGold)>=tonumber(needRecharge) and ((rechargeAwardTb[i]and rechargeAwardTb[i]~=1) or rechargeAwardTb[i] ==nil)  then
	            isRec =1
	        end
	    end
	end
	if isRec ==0 then
		local currEnergyNum = self:getCurrEnergy()
		local rewardNum = tonumber(self:getNeedIdxInAwardSS())
		local collectTbGrade = self:getCollectEnergyTbNums()
	    for i=1,collectTbGrade do
	        -- print("rewardNum------i------>",rewardNum,i)
	        local awardTb,collectEnergyNum = self:getSingleDataOfEnergy(i)
	        if tonumber(currEnergyNum) >= tonumber(collectEnergyNum) then
	        		isRec =1
	            if rewardNum >=i then
	                isRec=0
	            end
	        end
	    end
	end
	return isRec
end

function acThanksGivingVoApi:setCurrType( currType)
	local vo = self:getAcVo()
	if vo and isCurr then
		vo.isCurr =isCurr
	end
end
function acThanksGivingVoApi:getCurrType()
	local acVo = self:getAcVo()
	if acVo and acVo.isCurr then
		return acVo.isCurr
	end
	return nil
end
function acThanksGivingVoApi:setCurrTime( currTime)
	local vo = self:getAcVo()
	if vo and currTime then
		vo.currTime =currTime
	end
end
function acThanksGivingVoApi:getCurrTime()
	local acVo = self:getAcVo()
	if acVo and acVo.currTime then
		return acVo.currTime
	end
	return nil
end
function acThanksGivingVoApi:isRefreshAllServerData( )
	local currTime = acThanksGivingVoApi:getCurrTime()
	local isCurr = acThanksGivingVoApi:getCurrType()
	if isCurr ==false then
		if currTime+300 >base.serverTime then
			acThanksGivingVoApi:setCurrType( true)
			return true
		else
			return false
		end
	end
end

function acThanksGivingVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
	end
end
function acThanksGivingVoApi:setUpLastTime(newTime)
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = newTime
	end
end
function acThanksGivingVoApi:getUpLastTime()
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		return vo.lastTime 
	end
	return nil
end
function acThanksGivingVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		-- print("vo.lastTime---->",vo.lastTime)
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acThanksGivingVoApi:getTaskList( )
	local acVo = self:getAcVo()
	if acVo and acVo.taskList then
		return acVo.taskList
	end
	return nil
end

function acThanksGivingVoApi:getRechargedLogTb( )--rechargedLogTb
	local acVo = self:getAcVo()
	if acVo and acVo.rechargedLogTb then
		return acVo.rechargedLogTb
	end
	return nil
end
function acThanksGivingVoApi:setRechargedLogTb( rechargedLogTb )
	local acVo = self:getAcVo()
	if acVo and rechargedLogTb then
		 acVo.rechargedLogTb = rechargedLogTb
	end
end
function acThanksGivingVoApi:getRechargedInAwardSS( )--
	local recAwardTb = self:getRechargedLogTb()
	local num =0
	
	if recAwardTb and SizeOfTable(recAwardTb) then
		for k,v in pairs(recAwardTb) do
			if num <k and v == 1 then
				num = k
			end
		end
	end
	return num
end

function acThanksGivingVoApi:getUpDiaAward(idx,whiKey)--whiKey 纵向1，2，3行，idx 第几轮 1，2，3
	local acVo = self:getAcVo()
	local taskList = self:getTaskList()
	local taskListForTb = {}
	local awardTb = {}
	local factorValue = 0
	if taskList and SizeOfTable(taskList)>0 and taskList[whiKey] and taskList[whiKey][idx] and taskList[whiKey][idx]["reward"] then
		taskListForTb = taskList[whiKey][idx]["reward"]
		if taskList[whiKey][idx]["conditions"] then
			local factorTb = taskList[whiKey][idx]["conditions"]
			factorValue =factorTb.num
		end
	end
	awardTb = FormatItem(taskListForTb,nil,true)
	return awardTb,factorValue
end

function acThanksGivingVoApi:getRechargeAward( )
	local vo = self:getAcVo()
	if vo and vo.rechargeAward then
		return vo.rechargeAward,SizeOfTable(vo.rechargeAward)
	end
	return nil
end

function acThanksGivingVoApi:getFormatRechargeAward( )
	local rechAwardTb = self:getRechargeAward()
	local lotChooseTb = nil
	local singleChooseTb = nil
	local allLotAwardTb = {}
	local allSinAwardTb = {}
	if rechAwardTb and SizeOfTable(rechAwardTb) then
		lotChooseTb =rechAwardTb["r1"]
		singleChooseTb =rechAwardTb["r2"]
	end
	local lotChooseAwardTb = {}

	if lotChooseTb and SizeOfTable(lotChooseTb) then
		for k,v in pairs(lotChooseTb) do
			for i,j in pairs(v) do
				local awardTb =FormatItem(j,nil,false)---假数据  换真数据的时候需要把 false 改成 true
				table.insert(lotChooseAwardTb,awardTb[1])
			end
			table.insert(allLotAwardTb,lotChooseAwardTb)
			lotChooseAwardTb = {}
		end
	end
	local singleChooseAwardTb= nil
	if singleChooseTb and SizeOfTable(singleChooseTb) then
		for k,v in pairs(singleChooseTb) do
			local awardTb =FormatItem(v,nil,true)---假数据  换真数据的时候需要把 false 改成 true
			table.insert(allSinAwardTb,awardTb)
		end
	end

	return allLotAwardTb,allSinAwardTb
end



function acThanksGivingVoApi:setNewData(data)
	local vo = self:getAcVo()
	if vo and vo.changeData then
		vo.changeData =data
	end
end

function acThanksGivingVoApi:getNewData( )
	local vo = self:getAcVo()
	if vo and vo.changeData and SizeOfTable(vo.changeData)>0 then
		return vo.changeData 
	end
	return nil
end

function acThanksGivingVoApi:setRechargeAwardTb(rechargeAwardTb)
	local vo = self:getAcVo()
	if vo and vo.rechargeAwardTb then
		vo.rechargeAwardTb =rechargeAwardTb
	end
end

function acThanksGivingVoApi:getRechargeAwardTb( )
	local vo = self:getAcVo()
	if vo and vo.rechargeAwardTb and SizeOfTable(vo.rechargeAwardTb)>0 then
		return vo.rechargeAwardTb 
	end
	return nil
end

function acThanksGivingVoApi:setAllDataRefresh( )--更新第一个面板所有的数据，如果没有 去推送里找
	local newData = self:getNewData()
	self:setUpLastTime(newData.t)
	local vo = self:getAcVo()
	if vo and newData then
		if newData.t then
			vo.lastRewardTime = newData.t
		end
		if newData.j then
			vo.merit = newData.j
		end
		if newData.r then
			vo.cargo = newData.r 
		end
		if newData.c then
			vo.gameLevel = newData.c
		end
		if newData.m then
			vo.rechargeAwardTb =newData.m
		end
		if newData.f then
			vo.recAward = newData.f
		end
		if newData.f2 then
			self:setRechargedLogTb(newData.f2)
		end
	end
end

function acThanksGivingVoApi:setAllDataRefresh_0( )--更新第一个面板所有的数据，如果没有 去推送里找
	local newData = self:getNewData()
	local vo = self:getAcVo()
	if vo  then
			vo.lastRewardTime = 0
			vo.merit = 0
			vo.cargo = 0
			vo.gameLevel = 0
			vo.recAward ={}
			vo.rechargedLogTb ={}
			vo.rechargedGold =0
			vo.rechargeAwardTb ={}
	end
end

function acThanksGivingVoApi:isRefresh( )
	local vo = self:getAcVo()
	if vo and vo.isRefreshTab2 then
		return vo.isRefreshTab2 
	end
	return false
end
function acThanksGivingVoApi:setRefresh(isRefresh)
	local vo = self:getAcVo()
	if vo  then
		 vo.isRefreshTab2 = isRefresh
	end

end

function acThanksGivingVoApi:zeroRushInTask(whiKey,needIdxInAward)
	if whiKey then
		if tonumber(RemoveFirstChar(needIdxInAward)) <3 then
			if whiKey =="jg" then
				self:setMerit_0()
			elseif whiKey =="res" then
				self:setCargo_0()
			elseif whiKey =="challenge" then
				self:setGameLevel_0()
			end
		end
	end
end

function acThanksGivingVoApi:getMerit( ) --自己的得到军功数量
	local vo = self:getAcVo()
	if vo and vo.merit then
		return vo.merit
	end
	return 0
end
function acThanksGivingVoApi:setMerit_0( )--置零
	local vo = self:getAcVo()
	if vo and vo.merit then
		vo.merit =0
	end
end
function acThanksGivingVoApi:getCargo( ) --自己的得到资源数量
	local vo = self:getAcVo()
	if vo and vo.cargo then
		return vo.cargo
	end
	return 0
end
function acThanksGivingVoApi:setCargo_0( )--置零
	local vo = self:getAcVo()
	if vo and vo.cargo then
		vo.cargo =0
	end
end
function acThanksGivingVoApi:getGameLevel( ) --自己的通过的关卡数量
	local vo = self:getAcVo()
	if vo and vo.gameLevel then
		return vo.gameLevel
	end
	return 0
end
function acThanksGivingVoApi:setGameLevel_0( )--置零
	local vo = self:getAcVo()
	if vo and vo.gameLevel then
		vo.gameLevel =0
	end
end
function acThanksGivingVoApi:getRecAwardTbq( ) --已经领取的奖励 Tb  全服 F3
	local vo = self:getAcVo()
	if vo and vo.recAwardq then
		return vo.recAwardq
	end
	return nil
end
function acThanksGivingVoApi:setRecAwardTbq(recAwardq) --已经领取的奖励 Tb全服 F3
	local vo = self:getAcVo()
	if vo then
		 vo.recAwardq = recAwardq
	end
end
function acThanksGivingVoApi:getRecAwardTb( ) --已经领取的奖励 Tb
	local vo = self:getAcVo()
	if vo and vo.recAward then
		return vo.recAward
	end
	return nil
end
function acThanksGivingVoApi:setRecAwardTb(recAward ) --已经领取的奖励 Tb
	local vo = self:getAcVo()
	if vo then
		 vo.recAward = recAward
	end
end
-- rechargedGold
function acThanksGivingVoApi:getRechargedGold( ) --已经充值的金币
	local vo = self:getAcVo()
	if vo and vo.rechargedGold then
		return vo.rechargedGold
	end
	return nil
end
function acThanksGivingVoApi:getNeedIdxInAward(idx )
	local recAwardTb = self:getRecAwardTb()
	local mark = false
	local awardKey = nil
	if idx ==1 then
		awardKey ="j"
	elseif idx ==2 then
		awardKey ="r" 
	elseif idx ==3 then
		awardKey ="c"
	elseif idx ==4 then
		awardKey ="g"
	end
	local num =0
	local num2 = 0
	if SizeOfTable(recAwardTb) then
		for k,v in pairs(recAwardTb) do
			if string.sub(k,1,1)==awardKey and num <tonumber(RemoveFirstChar(k)) then
				num = tonumber(RemoveFirstChar(k))
			end
		end
	end
	num2 =num
	if num ==3 then--轮回的最大次数 死值，如果轮回的次数需要随着配置变化，需要传一个值告知
		mark =true
	elseif num >=0 and num <3 then---
		num= num+1
		mark =false
	end
	return awardKey..num,mark,num,num2
end
function acThanksGivingVoApi:getNeedIdxInAwardSS(allNums )--
	local recAwardTb = self:getRecAwardTbq()
	local num =0
	-- print("in-----getNeedIdxInAwardSS--->",SizeOfTable(recAwardTb))
	if recAwardTb and SizeOfTable(recAwardTb) then
		for k,v in pairs(recAwardTb) do
			-- print("string.sub(k,1,1)---->",string.sub(k,1,1))
			if string.sub(k,1,1)=="s" and num <tonumber(RemoveFirstChar(k)) then
				num = tonumber(RemoveFirstChar(k))
			end
		end
	end
	return num
end
function acThanksGivingVoApi:getNeedRechargeNum(idx)
	local vo = self:getAcVo()
	if vo and vo.rechargeTb and SizeOfTable(vo.rechargeTb)>0 and vo.rechargeTb[idx]then
		return vo.rechargeTb[idx]
	end
	return nil
end

function acThanksGivingVoApi:setSureAward(cellId,idx)
	local vo = self:getAcVo()
	if vo and cellId and idx then
		vo.sureIdTb[cellId]=idx
	end
end
function acThanksGivingVoApi:getSureAward()
	local vo = self:getAcVo()
	if vo and vo.sureIdTb then
		return vo.sureIdTb
	end
	return nil
end

function acThanksGivingVoApi:getCollectEnergyTbNums( )
	local vo = self:getAcVo()
	if vo  and vo.collectEnergyTb then
		return SizeOfTable(vo.collectEnergyTb)
	end
	return nil
end

function acThanksGivingVoApi:getCollectEnergyTb( )
	local vo = self:getAcVo()
	if vo and vo.collectEnergyTb then
		return vo.collectEnergyTb
	end
	return nil
end
function acThanksGivingVoApi:getSingleDataOfEnergy(idx)
	local collectEnergyTb =self:getCollectEnergyTb()
	local awardTb = FormatItem(collectEnergyTb["s"..idx]["reward"])
	local collectEnergyNum = collectEnergyTb["s"..idx]["conditions"]["num"]
	if awardTb and collectEnergyNum then
		return awardTb,collectEnergyNum
	end
	print("sigleData is nil")
	return nil
end


function acThanksGivingVoApi:getCurrEnergy(  )
	local vo = self:getAcVo()
	if vo and vo.energyNum then
		return vo.energyNum
	end
	return 0
end

function acThanksGivingVoApi:setCurrEnergy(currEnergyNum )
	local vo = self:getAcVo()
	if vo and currEnergyNum then
		vo.energyNum = currEnergyNum
	else
		vo.energyNum = 0
	end
end


function acThanksGivingVoApi:getPercentage()--acChongzhisongliVoApi
	local collectEnergyTb = acThanksGivingVoApi:getCollectEnergyTb( )
	local alreadyCost = acThanksGivingVoApi:getCurrEnergy(  )
	local numDuan = SizeOfTable(collectEnergyTb)
	local cost = {}
	for i=1,SizeOfTable(collectEnergyTb) do
		table.insert(cost,collectEnergyTb["s"..i]["conditions"]["num"])
	end
	-- alreadyCost = 10000
	local per = 0
	if numDuan==0 then
		numDuan=5
	end
	local everyPer = 100/numDuan

	local per = 0

	local diDuan=0 
	for i=1,numDuan do
		if alreadyCost<=cost[i] then
			diDuan=i
			break
		end
	end

	if alreadyCost>=cost[numDuan] then
		per=100
	elseif diDuan==1 then
		per=alreadyCost/cost[1]/numDuan*100
	else
		per = (diDuan-1)*everyPer+(alreadyCost-cost[diDuan-1])/(cost[diDuan]-cost[diDuan-1])/numDuan*100
	end

	return per
end





function acThanksGivingVoApi:G_getItemIcon(item,size,isShowInfo,layerNum,callback,container,addDesc,isHuoxianmingjianggai)
    if item then
        local iconSize=100
        if size then
            iconSize=size
        end
        local id = (tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
        local function showInfoHandler(hd,fn,idx)
            
            if container and container:getIsScrolled()==true then
                do return end
            end

            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            local isShow=true
            if callback then
                isShow=callback()
                if isShow==nil then
                    isShow=true
                end
            end
            if isShowInfo and layerNum and isShow==true then
                PlayEffect(audioCfg.mouseClick)
                if item.type=="e" then
                    if item.eType=="a" or item.eType=="f" then
                        local isAccOrFrag=true
                        propInfoDialog:create(sceneGame,item,layerNum+1,nil,nil,addDesc,nil,nil,isAccOrFrag)
                    else
                        propInfoDialog:create(sceneGame,item,layerNum+1,nil,nil,addDesc)
                    end
                elseif item.name then
                    if item.key == "energy" then
                        propInfoDialog:create(sceneGame,item,layerNum+1,nil, true,nil,addDesc)
                    else
                        if isHuoxianmingjianggai==true then
                            propInfoDialog:create(sceneGame,item,layerNum+1,nil,nil,addDesc,nil,nil,nil,nil,nil,true)                            
                        elseif  (item.type=="p" and id>=2001 and id<=2128) or item.key=="p903" or item.key=="p904" then
                             propInfoDialog:create(sceneGame,item,layerNum+1,nil,true,addDesc)
                        else
                          propInfoDialog:create(sceneGame,item,layerNum+1,nil,nil,addDesc)
                        end
                    end
                end
            end
            callback(hd,fn,idx)
        end
        local icon
        if item.type=="t" then 
            local bgname = "equipBg_green.png"                  --糖果
            for i=1,4 do
                if item.key =="t1" then
                    local pic ="sweet_1.png"
                    bgname="equipBg_green.png"
                elseif item.key =="t2" then
                    local pic ="sweet_2.png"
                    bgname="equipBg_blue.png"
                elseif item.key =="t3" then
                    local pic ="sweet_3.png"
                    bgname="equipBg_purple.png"
                elseif item.key =="t4" then
                    local pic ="sweet_4.png"
                    bgname="equipBg_orange.png"
                end
                icon = GetBgIcon(item.pic,nil,bgname)
            end
        elseif item.type=="w" and item.eType and item.eType=="f" then
            icon = superWeaponVoApi:getFragmentIcon(item.key,showInfoHandler)
        elseif item.type=="w" and item.eType and item.eType=="c" then
            icon = superWeaponVoApi:getCrystalIcon(item.key,showInfoHandler)            
        elseif item.type=="p" and propCfg[item.key] and propCfg[item.key].useGetHero then
            local heroData={h=G_clone(propCfg[item.key].useGetHero)}
            local hItmeTb=FormatItem(heroData)
            local hItme=hItmeTb[1]
            if hItme and hItme.type=="h" then
                if hItme.eType=="h" then
                    local productOrder=hItme.num
                    icon = heroVoApi:getHeroIcon(hItme.key,productOrder,true,showInfoHandler,nil,nil,nil,{adjutants={}})
                else
                    icon = heroVoApi:getHeroIcon(hItme.key,1,false,showInfoHandler)
                end
            end
        elseif item.type=="h" then
            if item.eType=="h" then
                local productOrder=item.num
                icon = heroVoApi:getHeroIcon(item.key,productOrder,true,showInfoHandler,nil,nil,nil,{adjutants={}})
                item.num=1
            else
                icon = heroVoApi:getHeroIcon(item.key,1,false,showInfoHandler)
            end
        elseif (item.type=="p" and id>=2001 and id<=2128) or item.key=="p903" or item.key=="p904" then
            icon = GetBgIcon(item.pic,showInfoHandler,nil,80,100)
            
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
        elseif item.type and item.type=="p" and item.bgname and item.bgname~="" then
            icon = GetBgIcon(item.pic,showInfoHandler,item.bgname,iconSize/100*90,iconSize)
            local pid="p"..item.id
            local prop=propCfg[pid]
            if prop and prop.addNum and prop.addNum>0 then
                    local addNumPic = "addnum_"..prop.addNum..".png"
                    local addNumBgPic = ""
                    if item.bgname=="equipBg_green.png" then
                        addNumBgPic="addnum_green.png"
                    elseif item.bgname=="equipBg_blue.png" then
                        addNumBgPic="addnum_blue.png"
                    elseif item.bgname=="equipBg_purple.png" then
                        addNumBgPic="addnum_purple.png"
                    elseif item.bgname=="equipBg_orange.png" then
                        addNumBgPic="addnum_orange.png"
                    end                    
                    -- print("----dmj----addNumPic:"..addNumPic.."---addNumBgPic:"..addNumBgPic.."---prop.addNum:"..prop.addNum)
                    local addNumBgSp=CCSprite:createWithSpriteFrameName(addNumBgPic)
                    addNumBgSp:setPosition(ccp(addNumBgSp:getContentSize().width/2+5,iconSize-addNumBgSp:getContentSize().height/2-8))
                    icon:addChild(addNumBgSp)
                    local addNumSp=CCSprite:createWithSpriteFrameName(addNumPic)
                    addNumSp:setPosition(getCenterPoint(addNumBgSp))
                    addNumBgSp:addChild(addNumSp)
            end
        elseif item.type and item.type=="f" then
            if equipCfg and equipCfg.quality then
                local bgname = "equipBg_green.png"
                if equipCfg.quality[1] and item.num and item.num<equipCfg.quality[1] then
                    bgname="equipBg_green.png"
                elseif equipCfg.quality[2] and item.num and item.num<equipCfg.quality[2] then
                    bgname="equipBg_blue.png"
                elseif equipCfg.quality[3] and item.num and item.num<equipCfg.quality[3] then
                    bgname="equipBg_purple.png"
                elseif equipCfg.quality[3] and item.num and item.num>=equipCfg.quality[3] then
                    bgname="equipBg_orange.png"
                end
                icon = GetBgIcon(item.pic,showInfoHandler,bgname,iconSize/100*90,iconSize)
            else
                icon = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
            end
        elseif item.type and (item.type=="m" or item.type=="n") or item.bgname and item.bgname~="" then
            icon = GetBgIcon(item.pic,showInfoHandler,item.bgname,iconSize/100*90,iconSize)
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


