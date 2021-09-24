acArmorEliteVoApi = {
	name=nil,
    rewardLog=nil,
    report={},
}

function acArmorEliteVoApi:refreshClear()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.useFree=0
end

function acArmorEliteVoApi:clearAll()
	self.name=nil
    self.rewardLog=nil
    self.report={}
end

function acArmorEliteVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acArmorEliteVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acArmorEliteVoApi:setActiveName(name)
	self.name=name
end

function acArmorEliteVoApi:getActiveName()
	return self.name or "zjjy"
end

function acArmorEliteVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acArmorEliteVoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acArmorEliteVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acArmorEliteVoApi:getCostByType(costType)
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		if costType==1 then
			return acVo.activeCfg.moneyCost2
		else
			return acVo.activeCfg.moneyCost2*acVo.activeCfg.discount*10
		end
	end
	return 9999
end

function acArmorEliteVoApi:isToday(activeName)
	local isToday=false
	local vo = self:getAcVo(activeName)
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acArmorEliteVoApi:getNextBigRewardNum()
	local bn=0
	local acVo = self:getAcVo()
	if acVo and acVo.bn then
		bn=acVo.bn
	end

	local maxNum=10
	if acVo and acVo.activeCfg then
		maxNum=acVo.activeCfg.maxNum
	end
	local remainder=maxNum-bn%maxNum
	-- if remainder==0 then
	-- 	remainder=maxNum
	-- end
	return remainder
end


function acArmorEliteVoApi:socketElite(action,num,free,refreshFunc)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			local rewardP={}
			if sData and sData.data and sData.data.reward then
				for k,v in pairs(sData.data.reward) do
					local rewardItem=FormatItem(v)
					G_addPlayerAward(rewardItem[1].type,rewardItem[1].key,rewardItem[1].id,rewardItem[1].num)
					table.insert(rewardP,rewardItem[1])


					if rewardItem[1].type=="p" then
						local useGetArmor=propCfg[rewardItem[1].key].useGetArmor
		                if useGetArmor then
		                    local aKey
		                    for k,v in pairs(useGetArmor) do
		                        aKey=k
		                    end
		                    local cfg=armorMatrixVoApi:getCfgByMid(aKey)

		                    if cfg.quality>=4 then
		                        local paramTab={}
								paramTab.functionStr=self:getActiveName()
								paramTab.addStr="i_also_want"
								local message={key="activity_nljj_chatSystemMessage",param={playerVoApi:getPlayerName(),getlocal("activity_zjjy_title"),rewardItem[1].name .. "*" .. rewardItem[1].num}}
								chatVoApi:sendSystemMessage(message,paramTab)
		                    end
		                end
					end
				end

			end
			local ishexie,rewardItem=self:isHexie()
			if ishexie then
				G_addPlayerAward(rewardItem[1].type,rewardItem[1].key,rewardItem[1].id,rewardItem[1].num*num)
			end


			if sData and sData.data and sData.data.log then
				if self.report[self.name] and self.report[self.name]==1 then
					for k,v in pairs(sData.data.log) do
						self:setLog(v)
					end
				end
			end

			if refreshFunc then
				refreshFunc(rewardP)
			end
		end
	end
	socketHelper:activeArmorElite(action,num,free,callBack)
	
end

function acArmorEliteVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	return G_formatActiveDate(vo.et - base.serverTime)
end

function acArmorEliteVoApi:isHexie()
	local flag=false
	if base.hexieMode==1 then
		local acVo=self:getAcVo()
		if acVo and acVo.activeCfg then
			local hxcfg=acVo.activeCfg.hxcfg
			if hxcfg then
				flag=true
				local rewardItem=FormatItem(hxcfg.reward)
				return flag,rewardItem
			end
		end

	end
	return flag
end

function acArmorEliteVoApi:setLog(report)
	local acVo = self:getAcVo()
	if acVo.log==nil then
		acVo.log={}
	end
	table.insert(acVo.log,1,report)
	for i=#acVo.log,11,-1 do
		table.remove(acVo.log,i)
	end
end

function acArmorEliteVoApi:getLog(refreshFunc)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.log then
				self:updateSpecialData(sData.data)
			end
			self.report[self.name]=1
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	if self.report[self.name]==nil then
		socketHelper:activeArmorElite(2,nil,nil,callback)
	else
		if refreshFunc then
			refreshFunc()
		end
	end
end

function acArmorEliteVoApi:showLogRecord(layerNum)
	local acVo = self:getAcVo()
	if acVo.log==nil or SizeOfTable(acVo.log)==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        do return end
	end

	local logList={}
	local ishexie,rewardItem=self:isHexie()
    for k,v in pairs(acVo.log) do
    	local sType=v[1] 
    	local time=v[3]

    	local reward={}
    	local mustReward=G_clone(rewardItem)
    	if ishexie then
    		if sType==2 then
    			mustReward[1].num=mustReward[1].num*10
    		end
    		table.insert(reward,mustReward[1])
    	end
    	for kk,vv in pairs(v[2]) do
    		local subReward=FormatItem(vv)
    		table.insert(reward,subReward[1])
    	end


        local title
        if sType==1 then
        	title={getlocal("activity_zjjy_buyLogDes",{1})}
        else
        	title={getlocal("activity_zjjy_buyLogDes",{10})}
        end

        local content={{reward}}
        local log={title=title,content=content,ts=time}
        table.insert(logList,log)
    end
    local logNum=SizeOfTable(logList)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
    acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,layerNum,nil,true,10,false,true)

end

function acArmorEliteVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.version then
		return vo.activeCfg.version
	end
	return 1
end

function acArmorEliteVoApi:canReward(activeName)
	local isfree=true
	if self:isToday(activeName)==true then
		isfree=false
	end
	return isfree
end