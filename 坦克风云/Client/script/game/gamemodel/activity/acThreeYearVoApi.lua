acThreeYearVoApi={
	shopList=nil, --商店列表
	nrtime=nil, --下一次刷新商店的时间点
	refreshFlag=false, --刷新商店的标记
}

function acThreeYearVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("threeyear")
	end
	return self.vo
end

function acThreeYearVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

function acThreeYearVoApi:getTimeStr()
	local timeStr=""
	local vo=self:getAcVo()
	if vo then
		timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	end
	return timeStr
end

function acThreeYearVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acThreeYearVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.r then
		isToday=G_isToday(vo.r)
	end
	return isToday
end

function acThreeYearVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end
	return false
end

function acThreeYearVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
	activityVoApi:updateShowState(vo)
end

function acThreeYearVoApi:getLimitLv()
	local vo=self:getAcVo()
	if vo and vo.limitLv then
		return vo.limitLv
	end
	return 1
end

function acThreeYearVoApi:isOpenHistory()
	local isOpen
	local vo=self:getAcVo()
	if vo and vo.flag then
		isOpen=vo.flag
	end
	return isOpen
end
function acThreeYearVoApi:getFootCfg()
	local vo=self:getAcVo()
	if vo and vo.footprize then
		return vo.footprize
	end
	return nil
end

function acThreeYearVoApi:getHistoryInfo()
	local vo=self:getAcVo()
	if vo and vo.historyInfo then
		return vo.historyInfo
	end
	return nil
end

function acThreeYearVoApi:getHistoryDesc(stepId)
	local str=""
	local argTb={}
	local vo=self:getAcVo()
	if vo and vo.historyInfo and vo.historyInfo[stepId] then
		local arg=vo.historyInfo[stepId]
		if stepId==1 then
			argTb[1]=G_getDataTimeStr(arg)
		elseif stepId==2 then
			if arg and arg<=0 then
				str=getlocal("activity_anniversary_target2_1")
			else
				argTb[1]=G_getDataTimeStr(arg)
				argTb[2]=""
				local alliance=allianceVoApi:getSelfAlliance()
				if alliance and alliance.name then
					argTb[2]=alliance.name
				end
			end
		elseif stepId==3 then
			if tonumber(arg)<0 then
				arg=0
			end
			argTb[1]=math.floor(tonumber(arg)/3600)
		elseif stepId==4 or stepId==5 then
			argTb[1]=tonumber(arg)
			if stepId==5 and arg and arg<=0 then
				str=getlocal("activity_anniversary_target5_1")
			end
		end
		if str=="" then
			str="☆ "..getlocal("activity_anniversary_target"..stepId,argTb)
		else
			str="☆ "..str
		end
	end
	
	return str
end

--获取每个历史足迹领取奖励的状态
--flag=1 未领取  flag=2 已领取
function acThreeYearVoApi:getHistoryRewardFlag(stepId)
	local flag=1
	local vo=self:getAcVo()
	if vo and vo.cz then
		for k,v in pairs(vo.cz) do
			if tonumber(v)==tonumber(stepId) then
				flag=2
				do break end
			end
		end
	end
	return flag
end

function acThreeYearVoApi:getRefreshNum()
	local cur=0
	local limit=0
	local vo=self:getAcVo()
	if vo and vo.limitNum then
		cur=vo.refreshNum or 0
		limit=vo.limitNum
	end
	return cur,limit
end

function acThreeYearVoApi:clearRefreshNum()
	local vo=self:getAcVo()
	if vo then
		vo.refreshNum=0
	end
end

function acThreeYearVoApi:getRefreshCost()
	local cost=0
	local refreshNum=self:getRefreshNum()
	local vo=self:getAcVo()
	if vo and vo.needMoney and vo.needMoney[refreshNum+1] then
		cost=vo.needMoney[refreshNum+1]
	end
	return cost
end

function acThreeYearVoApi:getPlayerIconCfg()
	local vo=self:getAcVo()
	if vo and vo.topPrize then
		return vo.topPrize
	end
	return nil
end

--领取三周年专属头像的状态 1：未领取 2：已领取 3：未达到领取条件
function acThreeYearVoApi:getVipIconState()
	local state=3
	local myVip=playerVoApi:getVipLevel()
	local iconCfg=self:getPlayerIconCfg()
	local vo=self:getAcVo()
	if myVip and iconCfg and iconCfg.viplimit and vo then
		if tonumber(myVip)<tonumber(iconCfg.viplimit) then
			state=3
		elseif vo.vip and vo.vip==1 then
			state=2
		else
			state=1
		end
	end
	return state
end

function acThreeYearVoApi:getBuffAddedCfg()
	local vo=self:getAcVo()
	if vo and vo.buff then
		return vo.buff
	end
	return nil
end

function acThreeYearVoApi:getBuffAdded(buffId)
	local added=0
	local vo=self:getAcVo()
	if  activityVoApi:isStart(vo)==true then
		local buffCfg=self:getBuffAddedCfg()
		if buffCfg and buffCfg[buffId] then
			added=buffCfg[buffId]
		end
	end
	return added
end

function acThreeYearVoApi:getBuffInfo(buffId)
	local buffCfg=acThreeYearVoApi:getBuffAddedCfg()
	local added=100*buffCfg[buffId].."%%"
	local titleStr=getlocal("activity_threeyear_buff"..buffId)
	local desc=getlocal("activity_threeyear_buffdesc"..buffId,{added},{added})
	local btnName
	local iconName
	local scale=1
	if buffId==1 then --攻打关卡奖励和几率掉落提升
		btnName=getlocal("go_to_attack")
		iconName="tech_fight_exp_up.png"
	elseif buffId==2 then --坦克生产和改造速度提升
		btnName=getlocal("go_produce")
		iconName="TankLv1.png"
		scale=0.65
	elseif buffId==3 then --所有资源生产产量提升
		btnName=getlocal("goTo_see_see")
		iconName="item_buff_all_up.png"
	elseif buffId==4 then --配件强化成功率提升
		btnName=getlocal("go_strength")
		iconName="icon_build.png"
	elseif buffId==5 then --世界行军速度提升
		btnName=getlocal("go_to_world")
		iconName="icon_buff9.png"
	elseif buffId==6 then --建筑建造或升级速度提升
		btnName=getlocal("go_build")
		iconName="tech_build_speed_upnew.png"
	elseif buffId==7 then --科技研究速度提升
		btnName=getlocal("go_study")
		iconName="Icon_ke_yan_zhong_xin.png"
	end
	return titleStr,desc,btnName,iconName,scale
end

function acThreeYearVoApi:goBuffAddedDialog(buffId,layerNum)
	if buffId==1 then
		G_goToDialog("cn",layerNum,true)
	elseif buffId==2 then
		G_goToDialog("tankfactory",layerNum,true)
	elseif buffId==3 then
		G_goToDialog("warehouse",layerNum,true)
	elseif buffId==4 then
		G_goToDialog("au",layerNum,true)
	elseif buffId==5 then
		G_goToDialog("pe",layerNum,true)
	elseif buffId==6 then
		G_goToDialog("build",layerNum,true)
	elseif buffId==7 then
		G_goToDialog("study",layerNum,true)
	end
end

function acThreeYearVoApi:getShopList()
	return self.shopList
end

--获取商店购买数据
function acThreeYearVoApi:getShopData(stype,id)
	local cur=0
	local vo=self:getAcVo()
	if vo and vo.shopData then
		local shop=vo.shopData[stype]
		if shop then
			for k,v in pairs(shop) do
				if k=="i"..id then
					cur=tonumber(v)
				end
			end
		end
	end
	return cur
end

--获取商店下次刷新倒计时
function acThreeYearVoApi:checkRefreshShop(callback)
	local time
	local vo=self:getAcVo()
	if vo and vo.v and vo.time then
		local timeCfg=vo.time
		local last=vo.v
		-- print("last======",last)
		local tc=SizeOfTable(timeCfg)
		local flag=false
		if self.nrtime==nil then
			if (last>timeCfg[tc] and last<24) or (last>=0 and last<timeCfg[1]) then
				vo.v=-1
				last=vo.v
			end
			for k,moment in pairs(timeCfg) do
				local timestamp=G_getWeeTs(base.serverTime)+moment*3600
				if moment>last and base.serverTime<=timestamp then
					self.nrtime=timestamp
					flag=true
					-- print("next=======",moment)
				end
			end
			if flag==false then
				self.nrtime=24*3600+G_getWeeTs(base.serverTime)+timeCfg[1]*3600
				-- print("next=======",timeCfg[1])
			end
		end
		if self.nrtime then
			-- print("self.nrtime====",self.nrtime)
			time=self.nrtime-base.serverTime
			if time and time==0 and self.refreshFlag==false then
				self.refreshFlag=true
				local function getHandler()
					self.refreshFlag=false
					self.nrtime=nil
					if callback then
						callback()
					end
				end
	            acThreeYearVoApi:threeYearRequest("getshop",nil,nil,getHandler)
			end
		end
	end
	return time
end

--活动所有请求数据处理
function acThreeYearVoApi:threeYearRequest(action,varArg1,varArg2,callback)
	if action=="getshop" or action=="refshop" then --获取和刷新商店列表
		local function shopHandler(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.threeyear then
	            		self:updateData(sData.data.threeyear)
	            	end
	            	local shopData=sData.data.shop
	            	if shopData then
	            		self.shopList={}
	            		for k,v in pairs(shopData) do
	            			local stype=k
	            			for kk,goods in pairs(v) do
	            				local reward=FormatItem(goods.reward[1])[1]
		            			local shop={stype=stype,id=goods.id,reward=reward,price=goods.price,discount=goods.discount,max=goods.bn}
		           				table.insert(self.shopList,shop)
	            			end
	            		end
	            	end
	                if callback then
	                	callback()
	                end
	            end
	        end
	    end
	    if action=="getshop" then
	    	socketHelper:activityThreeYear(action,nil,nil,nil,nil,shopHandler)
	    else
		    socketHelper:activityThreeYear(action,nil,nil,nil,varArg1,shopHandler)
	    end
	elseif action=="buy" then --购买商店物品
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.threeyear then
	            		self:updateData(sData.data.threeyear)
	            	end
	            	if sData.data.reward then
			       		local rewardlist=FormatItem(sData.data.reward) or {}
	            		for k,v in pairs(rewardlist) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)	
	            		end
        				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)
						G_showRewardTip(rewardlist,true)
	            	end
	            end

	            if callback then
                	callback()
                end
	        end
	    end
	    socketHelper:activityThreeYear(action,nil,varArg1,varArg2,nil,rewardCallback)
	elseif action=="reward" then --领取vip头像和历史足迹奖励
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.threeyear then
	            	self:updateData(sData.data.threeyear)
	            end
	            if varArg1=="vip" then
        		    local iconCfg=self:getPlayerIconCfg()
				    if iconCfg then
			    		local item=FormatItem(iconCfg.reward[1])[1]
			    		if item then
							G_addPlayerAward(item.type,item.key,item.id,item.num,nil,true)
			    		end
				    end
	            end
        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)
	            if callback then
                	callback()
                end
	        end
	    end
	    socketHelper:activityThreeYear(action,varArg1,nil,nil,nil,rewardCallback)
	elseif action=="login" then --在线玩家活动开启初始化数据
		local function dataCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.threeyear then
	            	self:updateData(sData.data.threeyear)
	            end
	            if callback then
                	callback()
                end
	        end
	    end
	    socketHelper:activityThreeYear(action,nil,nil,nil,nil,dataCallBack)
	end
end

function acThreeYearVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acThreeYearVoApi:clearAll()
	self.shopList=nil
	self.nrtime=nil
	self.refreshFlag=false
	self.vo=nil
end