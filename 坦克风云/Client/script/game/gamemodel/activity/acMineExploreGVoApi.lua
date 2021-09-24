acMineExploreGVoApi={
	isTodayFlag=true,
	recordList=nil,
	map=nil, --整理后的地图数据，以地图块id为key
	emap=nil, --整理后的下一次可解锁的地图块数据，以地图块id为key
	requestLogFlag=false,
	rankLimit=nil, --领取每层奖励的排行限制
}

function acMineExploreGVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("mineExploreG")
	end
	return self.vo
end

function acMineExploreGVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.version then
		return vo.activeCfg.version
	end
	return 1 --默认
end

function acMineExploreGVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acMineExploreGVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acMineExploreGVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end
	local canReward=self:canRankReward()
	if canReward==true then
		return true
	end
	return false
end

function acMineExploreGVoApi:getScoreRage( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.getScore then
		return vo.activeCfg.getScore[1],vo.activeCfg.getScore[2]
	end
	return nil
end


function acMineExploreGVoApi:getCanDigCount()
	-- local vo=self:getAcVo()
	-- if vo and vo.activeCfg and vo.activeCfg.maxNum and count>vo.activeCfg.maxNum then
	-- 	count=vo.activeCfg.maxNum
	-- end
	--配置没有显示连抽的字数 maxNum =nil 默认为5
	return 5
end


--获取迷宫每层宝箱的奖励
function acMineExploreGVoApi:getMazeChestReward()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.reward then
		return vo.activeCfg.reward
	end
	return {}
end


function acMineExploreGVoApi:showSmallDialog(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
	local sd=acChunjiepanshengSmallDialog:new()
	sd:init(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
end

--自己当前的任务点
function acMineExploreGVoApi:getMyPoint()--2
	local vo=self:getAcVo()
	if vo and vo.score then
		return vo.score
	end
	return 0
end

--是否是免费挖掘
function acMineExploreGVoApi:isFreeDig()
	local flag=1
	local vo=self:getAcVo()
	if vo then
		if vo.free and vo.free>=1 then
			print("vo.free======",vo.free)
			flag=0
		end
	end
	print("flag======",flag)

	return flag
end
--重置免费挖掘次数
function acMineExploreGVoApi:resetFreeDig()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end

--挖掘消耗
function acMineExploreGVoApi:getDigCost()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.cost1 then
		local digCount=self:getCanDigCount()
		return vo.activeCfg.cost1,vo.activeCfg.cost2
	end
	return nil,nil
end

function acMineExploreGVoApi:getShopCfg()--2
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.shop then
		return vo.activeCfg.shop
	end
	return {}
end

function acMineExploreGVoApi:getBuyData(saleId)--2
	local cur=0 --已购次数
	local vo=self:getAcVo()
	if vo and vo.shop then
		cur=vo.shop[saleId] or 0
	end
	return cur
end

function acMineExploreGVoApi:getShopIndexTb()--2
	local vo=self:getAcVo()
	local shopIndexTb={}
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
		end
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(shopIndexTb,sortFunc)
	return shopIndexTb
end

function acMineExploreGVoApi:canRankReward()
	return false,1
end

function acMineExploreGVoApi:setRecord(record)
	if self.recordList==nil then
		self.recordList={}
	end
	local rcount=SizeOfTable(self.recordList)
	if rcount>=10 then
		for i=10,rcount do
			table.remove(self.recordList,i)
		end
	end
	table.insert(self.recordList,1,record)
end

function acMineExploreGVoApi:getRecordList()
	return self.recordList or {}
end

function acMineExploreGVoApi:showRewardSmallDialog(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreSmallDialog"    
    local dialog=acMineExploreSmallDialog:new()
    dialog:init(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler)
    return dialog
end

--活动所有请求数据处理
function acMineExploreGVoApi:mineExploreGRequest(action,varArg,callback,isShowTip)--2
	if action=="active.mineexploreg" then --挖掘
		local function digCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.mineExploreG then
	            		self:updateData(sData.data.mineExploreG)
	            	end
	            	--log字段下的r是所有奖励（包括宝箱奖励） ，s是奇异宝石的奖励
	            	--log字段作为记录显示
	            	local storeRewards = {}--购买的宝石
            		local rewards={}--其他奖励
            		local contentAll = {}
				  	if sData.data.log then
				  		local item1 = {}
				  		local num=sData.data.log.s--购买的宝石
        				if num and num>0 then
            				local key="p3338"
            				local type="p"
            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
							table.insert(storeRewards,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num})

							item1[1] = storeRewards
							item1[2] = getlocal("activity_mineexploreG_storeReward")
							item1[3] = G_ColorWhite
							table.insert(contentAll,item1)
            			end
            			
            			local item2 = {}
	            		if sData.data.log.r then
	            			local reward=FormatItem(sData.data.log.r)
	            			for k,v in pairs(reward) do
	            				table.insert(rewards,v)
	            			end
	            		end

	            		local num2 = sData.data.log.s1
	            		if num2 and num2 > 0 then
	            			local key="p3338"
            				local type="p"
            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
							table.insert(rewards,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num2})
	            		end
	            		if SizeOfTable(rewards) > 0 then
	            			item2[1] = rewards
	            			item2[2] = getlocal("activity_mineExploreG_otherReward")
	            			item2[3] = G_ColorWhite
	            			table.insert(contentAll,item2)
						end
	            	end
					if self.requestLogFlag==true then
           				local ts=sData.data.log.ts
            			local digNum=sData.data.log.n
						local desc=getlocal("multi_excavate",{digNum})
                		local colorCur= G_ColorWhite
                		local hasChest=sData.data.log.k
                		if digNum and digNum > 1 then
                			colorCur = G_ColorYellowPro
                		end
						-- local record={award=rewards,time=ts,desc=desc,colorTb=colorTb}
						local logItem={title={desc,colorCur},ts=ts,content=contentAll}
						self:setRecord(logItem)
            		end
            		--log字段中 r：普通地块奖励，r1：宝箱地块奖励，s：普通地块奇异宝石数量，s1：宝箱地块奇异宝石数量
            		--showLog字段最为前台奖励显示
        		   	local rewardlist={}
	            	local tipStrTb={}
	            	if sData.data.showLog then
	            		local rewardLog=sData.data.showLog
            			local rTb={}
    					local rTb1={}
            			local tipTb={}
						local tipTb1={}
						for k,v in pairs(rewardLog) do

							if v.s and v.s>0 then
								if rTb[1] then
									rTb[1].num = rTb[1].num + v.s--rewardLog[k].s
								else									
		            				local key="p3338"
		            				local type="p"
		            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
									rTb[1] = {type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=v.s}
									if tipTb[1]==nil then
										tipTb[1]=getlocal("activity_mineexploreG_storeReward")
		            					table.insert(tipStrTb,tipTb)
									end
								end
	            			end
			            	if v.r then
			            		-- rTb={}
	    						local r=FormatItem(v.r)
								for k,v in pairs(r) do
	    							table.insert(rTb1,v)
									G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
									if tipTb1[1]==nil then
										tipTb1[1]=getlocal("activity_mineExploreG_otherReward")
		            					table.insert(tipStrTb,tipTb1)
									end
	    						end
			            	end
			            	if v.r1 then
			            		-- rTb1={}
	    						local r1=FormatItem(v.r1)
								for k,v in pairs(r1) do
	    							table.insert(rTb1,v)
									G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
									if tipTb1[1]==nil then
										tipTb1[1]=getlocal("activity_mineExploreG_otherReward")
		            					table.insert(tipStrTb,tipTb1)
									end
	    						end
			            	end
							
	    					if v.s1 and v.s1>0 then
	            				local key="p3338"
	            				local type="p"
	            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
								table.insert(rTb1,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=v.s1})
								if tipTb1[1]==nil then
									tipTb1[1]=getlocal("activity_mineExploreG_otherReward")
	            					table.insert(tipStrTb,tipTb1)
								end
	            			end
						end
						
						if SizeOfTable(rTb)>0 then
							table.insert(rewardlist,rTb)
						end
						if SizeOfTable(rTb1)>0 then
							table.insert(rewardlist,rTb1)
						end
	            	end
			
	                if callback then
	                	local digTb=sData.data.newMap or {}
	                	callback(true,self.map,digTb,rewardlist,tipStrTb,rewards)
	                end
	            end
	        else
	        	if callback then
	        		callback(false)
	        	end
	        end
	    end
		socketHelper:mineExploreGRequest(action,varArg[1],varArg[2],nil,digCallBack)
	elseif action=="active.mineexploreg.shop" then--商店购买
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.mineExploreG then
	            	self:updateData(sData.data.mineExploreG)
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
		socketHelper:mineExploreGRequest(action,nil,nil,varArg[1],rewardCallback)
	elseif action=="active.mineexploreg.report" then --获取抽奖日志
		local function logHandler(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.mineExploreG then
	            	self:updateData(sData.data.mineExploreG)
	            end

	            self.requestLogFlag=true
	      		if sData and sData.data and sData.data.log then
				  	if sData.data.log then
				  		local logData = sData.data.log
				  		local allTimes = SizeOfTable(logData)
				  		for i=allTimes,1,-1 do
				  			local storeRewards = {}--购买的宝石
		            		local rewards={}--其他奖励
		            		local contentAll = {}
		            		local num=logData[i].s
		            		local item1 = {}
	        				if num and num>0 then
	            				local key="p3338"
	            				local type="p"
	            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
								table.insert(storeRewards,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num})

								item1[1] = storeRewards
								item1[2] = getlocal("activity_mineexploreG_storeReward")
								item1[3] = G_ColorWhite
								table.insert(contentAll,item1)
	            			end

	            			if logData[i].r then
		            			local reward=FormatItem(logData[i].r)
		            			for k,v in pairs(reward) do
		            				table.insert(rewards,v)
		            			end
		            		end

	            			local num2=logData[i].s1
	            			local item2 = {}
	        				if num2 and num2>0 then
	            				local key="p3338"
	            				local type="p"
	            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
								table.insert(rewards,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num2})
	            			end

	            			if SizeOfTable(rewards) > 0 then
		            			item2[1] = rewards
		            			item2[2] = getlocal("activity_mineExploreG_otherReward")
		            			item2[3] = G_ColorWhite
		            			table.insert(contentAll,item2)
							end

							local ts=logData[i].ts
	            			local digNum=logData[i].n or 1
							local desc=getlocal("multi_excavate",{digNum})
	                		local colorCur=G_ColorWhite
	                		local hasChest=logData[i].k
	                		if digNum and digNum > 1 then
	                			colorCur = G_ColorYellowPro
	                		end

							local logItem={title={desc,colorCur},ts=ts,content=contentAll}
							self:setRecord(logItem)
				  		end
	            	end
			        -- local function sortFunc(a,b)
			        --     if a and b and a.time and b.time then
			        --         return tonumber(a.time)>tonumber(b.time)
			        --     end
			        -- end
			        -- if self.recordList then
				       --  table.sort(self.recordList,sortFunc)
			        -- end
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
		socketHelper:mineExploreGRequest(action,nil,nil,nil,logHandler)
	end
end

function acMineExploreGVoApi:formatLog(log)
	if log then
		local content={}	
		if log.r then
			for k,r in pairs(log.r) do
				local item={}
				local rtype=r[1]
				local times=r[4] or 0
				local fireName=self:getFirecrackersName(rtype)
				item[1]=FormatItem(r[2],nil,true)
				item[2]=fireName.."x"..times
				item[3]=G_ColorWhite
				if tonumber(rtype)==4 then
					item[3]=G_ColorYellowPro
				end
				table.insert(content,item)
			end
		end
		local ts=log.ts or base.serverTime
		local num=log.n or 1
		local score=log.s or 0
		local desc=getlocal("cjyx_multilottery",{num})--标题
		local pointStr=getlocal("cjyx_point_str").."："..score
		local color=G_ColorWhite
		if num and tonumber(num)>1 then
			color=G_ColorGreen
		end
		local logItem={title={desc,color},append={pointStr},ts=ts,content=content}
		return logItem
	end
	return {}
end

function acMineExploreGVoApi:getSelfRank()
	local vo=self:getAcVo()
	if vo and vo.rank then
		return vo.rank
	end
	return 0
end

--item商店兑换的宝箱
function acMineExploreGVoApi:sendRewardNotice(rtype,item)--2
    local playerName=playerVoApi:getPlayerName()
    local activityName=getlocal("activity_mineExploreG_title")
    local message
    if rtype==1 then
    	message={key="activity_mineExploreG_notice1",param={playerName,activityName}}
	elseif rtype==2 then
		if item and item.name then
    		message={key="activity_mineExploreG_notice2",param={playerName,activityName,item.name}}
		end
    end
    if message then
    	local paramTab={}
    	paramTab.functionStr="mineExploreG"
        paramTab.addStr="goTo_see_see"
    	chatVoApi:sendSystemMessage(message,paramTab)
    end
end

function acMineExploreGVoApi:getRequestLogFlag()
	return self.requestLogFlag
end

function acMineExploreGVoApi:tick()

end

function acMineExploreGVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acMineExploreGVoApi:clearAll()
	self.isTodayFlag=true
	self.recordList=nil
	self.map=nil
	self.emap=nil
	self.requestLogFlag=false
	self.rankLimit=nil
	self.vo=nil
end