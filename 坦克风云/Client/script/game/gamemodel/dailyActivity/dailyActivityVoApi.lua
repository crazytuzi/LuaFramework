require "luascript/script/game/gamemodel/dailyActivity/dailyActivityVo"

dailyActivityVoApi=
{
	-- functionKeys={"rpShop","boss","dailychoice","drew1","drew2"},	--活动对应的功能key	
	functionKeys={"dnews","rpShop","dailychoice","drew1","drew2","boss","ttjj","xstz","ydhk"},	--活动对应的功能key	
	allActivity={},
	expiredTimeTb={},
	movgaBindFlag=0,	--movga特殊需求，绑定邮箱之后可以领一次奖励
}

function dailyActivityVoApi:updateFunctionKeys()
	if base.dailyAcYouhuaSwitch==1 then
		-- if base.isSignSwitch==1 and newGiftsVoApi:hasReward()==-1 then
		if base.isSignSwitch==1 then
			self.functionKeys={"dailyLottery","isSignSwitch","xstz","xstzh","ydhk","dnews","ttjj","rpShop","dailychoice","drew1","drew2","boss"}
		else
			self.functionKeys={"dailyLottery","xstz","xstzh","ydhk","dnews","ttjj","rpShop","dailychoice","drew1","drew2","boss"}
		end
	end
	if G_isGlobalServer()==true then
		for k,v in pairs(self.functionKeys) do
			if v=="dailychoice" then
				table.remove(self.functionKeys,k)
				break
			end
		end
	end
	if dailyNewsVoApi and dailyNewsVoApi.hasData and dailyNewsVoApi:hasData()==true then
	else
		for k,v in pairs(self.functionKeys) do
			if v=="dnews" then
				table.remove(self.functionKeys,k)
				break
			end
		end
	end
end
function dailyActivityVoApi:formatData(data)
	self:updateFunctionKeys()
	local sortFlag=false
	for k,fKey in pairs(self.functionKeys) do
		if(self:checkOpen(fKey))then
			local vo=self:getActivityVo(fKey)
			if(vo==nil)then
				sortFlag=true
				self:requireByType(fKey)
				vo=self:getVoByType(fKey):new(fKey)
				if fKey=="drew1" and (vo.flag==false or vo.isReceive==true or base.meirilingjiangNoon==1) then
				elseif fKey=="drew2" and (vo.flag==false or vo.isReceive==true or base.meirilingjiangNight==1) then
				elseif fKey=="dailyLottery" and FuncSwitchApi:isEnabled("luck_lottery") == false then
				else
					table.insert(self.allActivity,vo)
				end
				
			end
			if(data and data[fKey])then
				sortFlag=true
				vo:updateData(data[fKey])
			end
		end
	end
	if(dailyActivityVoApi.movgaBindFlag~=1 and dailyActivityVoApi:checkShowMovgaBind())then
		local flag=false
		for k,v in pairs(self.allActivity) do
			if(v and v.type=="movgaBind")then
				flag=true
				break
			end
		end
		if(flag==false)then
			local vo=dailyActivityVo:new("movgaBind")
			vo.showType=1
			vo.sortId=1
			table.insert(self.allActivity,vo)
		end
	end
	if(sortFlag)then
		self:sortActivity()
	end
end

function dailyActivityVoApi:formatActivityListData(data)
	self:updateFunctionKeys()
	for k,fKey in pairs(self.functionKeys) do
		if(self:checkOpen(fKey))then
			local vo=self:getActivityVo(fKey)
			if(vo==nil)then
				self:requireByType(fKey)
				vo=self:getVoByType(fKey):new(fKey)
                if fKey=="drew1" and (vo.flag==false or vo.isReceive==true or base.meirilingjiangNoon==1) then
                elseif fKey=="drew2" and (vo.flag==false or vo.isReceive==true or base.meirilingjiangNight==1) then
				elseif fKey=="dailyLottery" and FuncSwitchApi:isEnabled("luck_lottery") == false then
                else
					table.insert(self.allActivity,vo)
                end

			end
			if(data and data[fKey])then
				vo:updateData(data[fKey])
			end
		end
	end
	if base.dailyAcYouhuaSwitch==1 then
		self:sortActivity()
	end
end

function dailyActivityVoApi:checkOpen(type)
	if(base[type] and base[type]==1 or (base.dailyAcYouhuaSwitch==1 and type=="dailyLottery"))then
		return true;
	end
	return false
end

function dailyActivityVoApi:getActivityVo(key)
	for k,vo in pairs(self.allActivity) do
		if(vo and vo.type==key)then
			return vo
		end
	end
	return nil
end

function dailyActivityVoApi:deleteActivityVo(key)
	local num=nil
	for k,vo in pairs(self.allActivity) do
		if(vo and vo.type==key)then
			num=k
			break
		end
	end
	if num~=nil then
		table.remove(self.allActivity,num)
	end
end

function dailyActivityVoApi:requireByType(type)
	if type == "rpShop" then
		require "luascript/script/game/gamemodel/rpshop/rpShopVoApi"
		require "luascript/script/game/gamemodel/rpshop/rpShopVo"
    elseif type == "boss" then
		require "luascript/script/game/gamemodel/Boss/BossBattleVoApi"
		require "luascript/script/game/gamemodel/Boss/BossBattleVo"
	end
	if type == "dailychoice" then
		require "luascript/script/game/gamemodel/dailyAnswer/dailyAnswerVo"
		require "luascript/script/game/gamemodel/dailyAnswer/dailyAnswerVoApi"
	end
	if type == "drew1" then
		require "luascript/script/game/gamemodel/receiveReward/receivereward1VoApi"
		require "luascript/script/game/gamemodel/receiveReward/receivereward1Vo"
	end

	if type == "drew2" then
		require "luascript/script/game/gamemodel/receiveReward/receivereward2VoApi"
		require "luascript/script/game/gamemodel/receiveReward/receivereward2Vo"
	end

	if type == "ttjj" then
		require "luascript/script/game/gamemodel/Ttjj/dailyTtjjVo"
		require "luascript/script/game/gamemodel/Ttjj/dailyTtjjVoApi"
	end

	if type == "xstz" or type == "xstzh" then
		require "luascript/script/game/gamemodel/limitChallenge/limitChallengeVo"
	    require "luascript/script/game/gamemodel/limitChallenge/limitChallengeVoApi"
	end

	if type == "ydhk" then
		require "luascript/script/game/gamemodel/ydhk/dailyYdhkVo"
	    require "luascript/script/game/gamemodel/ydhk/dailyYdhkVoApi"
	end
end

function dailyActivityVoApi:getExpiredTimeTb()
	return self.expiredTimeTb
end
function dailyActivityVoApi:updateExpiredTimeTb()
	self.expiredTimeTb={}
	if self.allActivity then
		for idx,acVo in pairs(self.allActivity) do
			-- local cdTime=0
			if acVo.type=="boss" then
				local st = bossCfg.opentime[1][1]*60*60+bossCfg.opentime[1][2]*60
			    local et = bossCfg.opentime[2][1]*60*60+bossCfg.opentime[2][2]*60
			    local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
			    if dayTime then
			    	if dayTime<st then
			    		-- cdTime=st-dayTime
			    		self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+st
					else
						-- cdTime=st+86400-dayTime
						self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+86400+st
			    	end
			    end
			elseif acVo.type=="dailychoice" then
				local st = meiridatiCfg.openTime[1][1]*60*60+meiridatiCfg.openTime[1][2]*60
			    local et = meiridatiCfg.openTime[2][1]*60*60+meiridatiCfg.openTime[2][2]*60
			    local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
			    if dayTime then
			    	if dayTime<st then
			    		-- cdTime=st-dayTime
			    		self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+st
					else
						-- cdTime=st+86400-dayTime
						self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+86400+st
			    	end
			    end
			elseif acVo.type=="drew1" then
				local st = getEnergyNoonCfg.opentime[1][1]*60*60+getEnergyNoonCfg.opentime[1][2]*60
			    local et = getEnergyNoonCfg.opentime[2][1]*60*60+getEnergyNoonCfg.opentime[2][2]*60
			    local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
			    if dayTime then
			    	if dayTime<st then
			    		-- cdTime=st-dayTime
			    		self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+st
					else
						-- cdTime=st+86400-dayTime
						self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+86400+st
			    	end
			    end
			elseif acVo.type=="drew2" then
				local st = getEnergyNightCfg.opentime[1][1]*60*60+getEnergyNightCfg.opentime[1][2]*60
			    local et = getEnergyNightCfg.opentime[2][1]*60*60+getEnergyNightCfg.opentime[2][2]*60
			    local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
			    if dayTime then
			    	if dayTime<st then
			    		-- cdTime=st-dayTime
			    		self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+st
					else
						-- cdTime=st+86400-dayTime
						self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+86400+st
			    	end
			    end
			-- elseif acVo.type=="rpShop" then
			-- 	local weekDay=G_getFormatWeekDay(base.serverTime)
			-- 	if weekDay>=1 and weekDay<=5 then
			-- 		local saturdayZeroTs=G_getWeeTs(base.serverTime)+(6-weekDay)*86400
			-- 		-- cdTime=saturdayZeroTs-base.serverTime
			-- 		self.expiredTimeTb[acVo.type]=saturdayZeroTs
			-- 	else
			-- 		local saturdayZeroTs=G_getWeeTs(base.serverTime)-(weekDay-6)*86400+7*86400
			-- 		-- cdTime=saturdayZeroTs-base.serverTime
			-- 		self.expiredTimeTb[acVo.type]=saturdayZeroTs
			-- 	end
			-- elseif acVo.type=="dailyLottery" then
			-- 	self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+86400
			-- elseif acVo.type=="isSignSwitch" then
			-- 	self.expiredTimeTb[acVo.type]=G_getWeeTs(base.serverTime)+86400
			end
		end
	end
end

--对所有活动进行排序, 激活的活动排在未激活的前面, 状态相同的按照functionKeys的先后顺序排
function dailyActivityVoApi:sortActivity()
	if base.dailyAcYouhuaSwitch==1 then
		self:updateExpiredTimeTb()
		local maxTime=0
		for acType,ts in pairs(self.expiredTimeTb) do
			cdTime=ts-base.serverTime
    		if cdTime<0 then
    			cdTime=0
    		end
    		if cdTime>maxTime then
    			maxTime=cdTime
    		end
		end
		for k,v in pairs(self.functionKeys) do
			for idx,acVo in pairs(self.allActivity) do
				if acVo and acVo.type==v then
			        local cdTime=0
			        local time=self.expiredTimeTb[acVo.type]
			        if time then
				        cdTime=time-base.serverTime
		        		if cdTime<0 then
		        			cdTime=0
		        		end
		        	end
			        local showType=0
					if acVo.type=="dailyLottery" then
						if dailyVoApi and dailyVoApi:isFree()==true then
							showType=1
						end
						cdTime=maxTime+1
					elseif acVo.type=="isSignSwitch" then
						if signVoApi and signVoApi:isTodaySign()==false then
							showType=1
						end
						cdTime=maxTime+2
					else
						if (acVo.canReward and acVo:canReward()==true) or (acVo.checkActive and acVo:checkActive()==true) then
							showType=1
						end
						if acVo.type=="rpShop" then
							cdTime=maxTime+3
						end
			        end
			        self.allActivity[idx].showType=showType
			        self.allActivity[idx].cdTime=cdTime
			        self.allActivity[idx].sortId=k
				end
			end
		end
		local function sortFunc(a,b)
			if a.showType==1 and b.showType==1 then
				return a.sortId<b.sortId
			elseif a.showType==0 and b.showType==0 then
				if a.cdTime~=b.cdTime and a.cdTime>0 and b.cdTime>0 then
					return a.cdTime<b.cdTime
				else
					return a.sortId<b.sortId
				end
			else
				return a.showType>b.showType
			end
		end
		table.sort(self.allActivity,sortFunc)
	else
		local function sortFunc(a,b)
			local activeA=a:checkActive()
			local activeB=b:checkActive()
			if(a==true and b==false)then
				return true
			elseif(a==false and b==true)then
				return false
			else
				local length=#(self.functionKeys)
				for i=1,length do
					if(self.functionKeys[i]==a.type)then
						return true
					elseif(self.functionKeys[i]==b.type)then
						return false
					end
				end
			end
		end
		table.sort(self.allActivity,sortFunc)
	end
end

function dailyActivityVoApi:getVoByType(type)
	if(type=="rpShop")then
		return rpShopVo
    elseif(type=="boss")then
		return BossBattleVo
	elseif (type=="dailychoice") then		
		return dailyAnswerVo
	elseif (type == "drew1") then
		return receivereward1Vo
	elseif (type == "drew2") then
		return receivereward2Vo
	elseif (type == "ttjj") then
		return dailyTtjjVo
	elseif (type == "xstz") or (type == "xstzh") then
		return limitChallengeVo
	elseif (type == "ydhk") then
		return dailyYdhkVo
	end
	return dailyActivityVo
end

function dailyActivityVoApi:getVoApiByType(type)
	if type=="ydhk" then
		return dailyYdhkVoApi
	end
end

function dailyActivityVoApi:getActivityNum()
	if(G_isHexie())then
		return 0
	end
	return #(self.allActivity)
end

function dailyActivityVoApi:getAllActivity()
    if(G_isHexie())then
        return {}
    end
	return self.allActivity
end

function dailyActivityVoApi:showDialog(index,layerNum,callback,isDelay)
	local vo=self.allActivity[index]
	if(vo.type=="rpShop")then
		rpShopVoApi:showShop(layerNum)
    elseif(vo.type=="boss")then
		BossBattleVoApi:showShop(layerNum)
	elseif vo.type=="dnews" then
		dailyNewsVoApi:showDailyNewsDialog(layerNum)
	elseif(vo.type=="dailychoice")then
		dailyAnswerVoApi:showShop(layerNum)
	elseif vo.type=="drew1" then
		receivereward1VoApi:showShop(layerNum)
	elseif vo.type=="drew2" then
		receivereward2VoApi:showShop(layerNum)
	elseif vo.type=="dailyLottery" then
		dailyVoApi:showDailyDialog(layerNum)
	elseif vo.type=="isSignSwitch" then
		if base.newSign == 1 then
			newSignInVoApi:showSignDialog(layerNum)
		else
			signVoApi:showSignDialog(layerNum)
		end
	elseif vo.type=="ttjj" then
		dailyTtjjVoApi:showDialog(layerNum)
	elseif vo.type == "xstz" then
		limitChallengeVoApi:showDialog(1,layerNum)
	elseif vo.type == "xstzh" then
		limitChallengeVoApi:showDialog(2,layerNum)
	elseif vo.type == "ydhk" then
		dailyYdhkVoApi:showDialog(layerNum)
	elseif vo.type=="movgaBind" then
		require "luascript/script/game/scene/gamedialog/activityAndNote/acMovgaBindEmailSmallDialog"
		local sd = acMovgaBindEmailSmallDialog:new()
		sd:init(layerNum)
	end
	if callback then
		callback(vo.type)
	end
end

function dailyActivityVoApi:oneCanReward()
	local voTb=self:getAllActivity()
	for k,v in pairs(voTb) do
        self:updateShowState(v)
		if v.canRewardFlag == true then
			return true
		end
	end
	return false
end

-- 执行一些可能改变用户领奖状态的操作后调用刷新当前状态
function dailyActivityVoApi:updateShowState(vo)
	if vo == nil then
		do
		  return
		end
	end

	local canReward = vo:canReward()
	if canReward ~= vo.canRewardFlag then
	   vo.canRewardFlag = canReward
       vo.stateChanged = true
	end
end

--显示时间00:00~23:59
function dailyActivityVoApi:getTimeStr(isWeekend,st,et)
    local startTime=0
    local endTime=86400-1
    local timeStr = G_getTimeStr(startTime,2).."~"..G_getTimeStr(endTime,2)
    if st and et then
        if type(st)=="number" and type(et)=="number" then
            startTime=st-G_getWeeTs(st)
            endTime=et-G_getWeeTs(et)
            timeStr = G_getTimeStr(startTime,2).."~"..G_getTimeStr(endTime,2)
        elseif type(st)=="table" and type(et)=="table" then
            local time1 = string.format("%02d:%02d",st[1],st[2])
            local time2 = string.format("%02d:%02d",et[1],et[2])
            timeStr = string.format("%s~%s",time1,time2)
        end 
    end
	if isWeekend==true then
        timeStr=timeStr..getlocal("dailyActivity_weekend_time")
    end
    return timeStr
end



function dailyActivityVoApi:canRewardNum()
	local num=0
	if base.dailyAcYouhuaSwitch==1 then
		local voTb=self:getAllActivity()
		if voTb then
			for k,v in pairs(voTb) do
				if v and v.type=="dailyLottery" then
					if dailyVoApi and dailyVoApi:isFree()==true then
						num=num+1
					end
				elseif v and v.type=="isSignSwitch" then
					if base.newSign == 1 then
						if newSignInVoApi and newSignInVoApi:isToday()==false then
							num=num+1
						end
					else
						if signVoApi and signVoApi:isTodaySign()==false then
							num=num+1
						end
					end
				elseif v and ((v.canReward and v:canReward()==true) or (v.checkActive and v:checkActive()==true)) then
					num=num+1
		        end
			end
		end
	end
	return num	
end

-- flag 1:add 2 remove
function dailyActivityVoApi:addOrRemvoeIcon(flag)
    if not self.allActivity then
        return
    end
    for k,v in pairs(self.allActivity) do
        if v and (v.type=="dnews") then
	        if flag==1 then
	            spriteController:addPlist("public/activeCommonImage1.plist")
			    spriteController:addTexture("public/activeCommonImage1.png")
	        else
	            spriteController:removePlist("public/activeCommonImage1.plist")
			    spriteController:removeTexture("public/activeCommonImage1.png")
	        end
	    end
	    if v and (v.type=="xstz") then
	    	if flag == 1 then
	    		spriteController:addPlist("public/activeCommonImage2.plist")
			    spriteController:addTexture("public/activeCommonImage2.png")
      		else
    			spriteController:removePlist("public/activeCommonImage2.plist")
			    spriteController:removeTexture("public/activeCommonImage2.png")
    		end
	    end
	    local voApi=dailyActivityVoApi:getVoApiByType(v.type)
	    if voApi then
	    	if flag==1 then
	    		if voApi.addActivieIcon then
	    			voApi:addActivieIcon()
	    		end
	    	else
				if voApi.removeActivieIcon then
	    			voApi:removeActivieIcon()
	    		end
	    	end
	    end
    end
end

--是否显示movga绑定邮箱的相关功能
function dailyActivityVoApi:checkShowMovgaBind()
	if((G_curPlatName()=="11" and G_Version>=13) or (G_curPlatName()=="androidsevenga" and G_Version>=20) or G_curPlatName()=="0")then
		return true
	else
		return false
	end
end

--领过奖，移除movga的活动
function dailyActivityVoApi:removeMovgaBind()
	dailyActivityVoApi.movgaBindFlag=1
	for k,v in pairs(self.allActivity) do
		if(v.type=="movgaBind")then
			table.remove(self.allActivity,k)
			eventDispatcher:dispatchEvent("activity.dialog.refresh",{type="movgaBind"})
			break
		end
	end
end

function dailyActivityVoApi:clear()
	for index,vo in pairs(self.allActivity) do
		if(vo and vo.dispose)then
			vo:dispose()
			self.allActivity[index]=nil
		end
	end
	if receivereward1Vo then
		receivereward1Vo:dispose()
	end
	if receivereward2Vo then
		receivereward2Vo:dispose()
	end
	self.functionKeys={"dnews","rpShop","dailychoice","drew1","drew2","boss"}
	self.allActivity={}
	self.expiredTimeTb={}
	self.movgaBindFlag=0
end