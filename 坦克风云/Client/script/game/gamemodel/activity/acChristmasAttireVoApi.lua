acChristmasAttireVoApi={
	rankList=nil,
	myRank="0",
	isTodayFlag=true,
	materialPicCfg=nil,
	recordList=nil,
	requestLogFlag=false,
}

function acChristmasAttireVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("christmas2016")
	end
	return self.vo
end

function acChristmasAttireVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

function acChristmasAttireVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
		if G_isIphone5() then
			str=getlocal("activity_timeLabel").."\n"..timeStr
		else
			str=getlocal("activity_timeLabel")..":"..timeStr
		end
	end

	return str
end

function acChristmasAttireVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local rewardTimeStr=activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
		if G_isIphone5() then
			str=getlocal("recRewardTime").."\n"..rewardTimeStr
		else
			str=getlocal("recRewardTime")..":"..rewardTimeStr
		end
	end
	return str
end

function acChristmasAttireVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acChristmasAttireVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acChristmasAttireVoApi:canReward()
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

-- 自己当前的任务点
function acChristmasAttireVoApi:getMyPoint()
	local vo=self:getAcVo()
	if vo and vo.score then
		return vo.score
	end
	return 0
end

--是否是免费装扮
function acChristmasAttireVoApi:isFreeAttire()
	local flag=1
	local vo=self:getAcVo()
	if vo then
		if vo.free and vo.free>=1 then
			flag=0
		end
	end
	return flag
end

function acChristmasAttireVoApi:resetFreeAttire()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end

function acChristmasAttireVoApi:getAttireCost()
	local vo=self:getAcVo()
	if vo and vo.cost1 and vo.cost2 then
		return vo.cost1,vo.cost2
	end
	return nil,nil
end

function acChristmasAttireVoApi:getRewardList()
	local vo=self:getAcVo()
	if vo and vo.rewardList then
		return vo.rewardList
	end
	return {}
end

function acChristmasAttireVoApi:getMaterialNumCfg()
	local vo=self:getAcVo()
	if vo and vo.materialNum then
		return vo.materialNum
	end
	return nil
end

function acChristmasAttireVoApi:getMaterials()
	local vo=self:getAcVo()
	if vo and vo.materials then
		return vo.materials
	end
	return {}
end

--fidx：层数   midx：材料所在位置
function acChristmasAttireVoApi:getMaterialPic(fidx,midx)
	if self.materialPicCfg==nil then
		self.materialPicCfg={{"attire_material1.png","attire_material2.png","attire_material3.png","worldBtnSearch.png"},{"Dice5.png","sweet_2.png","attire_material4.png"},{"sweet_3.png","flowerBtn.png","iconGoldNew3.png"},{"loveBagPic.png","sweet_4.png"},{"bellPic.png"},{"attire_material5.png"}}
	end
	if self.materialPicCfg[fidx] and self.materialPicCfg[fidx][midx] then
		return self.materialPicCfg[fidx][midx]
	end
	return ""
end

--礼包兑换所需的每种材料的个数
function acChristmasAttireVoApi:getExchangeNeed(fidx)
	local num=10000
	local vo=self:getAcVo()
	local rewardlist=self:getRewardList()
	if vo then
		if vo.exchanges and vo.exchanges[fidx] then
			local exchanged=vo.exchanges[fidx] --已经兑换的次数
			local nextNeed=exchanged+1
			if rewardlist[fidx] and rewardlist[fidx].need then
				local needCfg=rewardlist[fidx].need
				local size=SizeOfTable(needCfg)
				if nextNeed>=size then --每次兑换所需材料数量，随着兑换次数不断增加，超过上限则取上限值
					num=needCfg[size]
				else
					num=needCfg[nextNeed]
				end
			end
		else
			--默认取第一次兑换数据
			if rewardlist[fidx] and rewardlist[fidx].need then
				num=rewardlist[fidx].need[1]
			end
		end
	end
	return num
end

--礼包是否可以兑换
function acChristmasAttireVoApi:isCanExchange(fidx)
	local flag=false
	local needNum=self:getExchangeNeed(fidx)
	local materials=self:getMaterials()
	local materialCfg=self:getMaterialNumCfg()
	if materialCfg and materialCfg[fidx] and materials and materials[fidx] then
		local count=0
		for i=1,materialCfg[fidx] do
			local num=materials[fidx][i]
			if num and num>=needNum then
				count=count+1
			else
				do break end
			end
		end
		if count==materialCfg[fidx] then
			flag=true
		end
	end
	return flag
end

function acChristmasAttireVoApi:getRankList()
	return self.rankList
end

function acChristmasAttireVoApi:setRankList(rank)
	if rank then
		if self.rankList==nil then
			self.rankList={}
		end
		self.rankList=rank
	end
end

function acChristmasAttireVoApi:getRankReward()
	local reward={}
	local vo=self:getAcVo()
	if vo and vo.rankReward then
		reward=vo.rankReward
	end
	return reward
end

function acChristmasAttireVoApi:getRankLimit()
	local rankLimit=100
	local vo=self:getAcVo()
	if vo and vo.rankLimit then
		rankLimit=vo.rankLimit
	end
	return rankLimit
end

function acChristmasAttireVoApi:canRankReward()
	if self and self:acIsStop()==true then
		local rankList=self:getRankList()
		if rankList and SizeOfTable(rankList)>0 then
			for k,v in pairs(rankList) do
				if v and v[1] and tonumber(v[1])==playerVoApi:getUid() then
					local vo=self:getAcVo()
					if vo and vo.rankRewardFlag then
						return false,2
					end
					return true,0,k
				end
			end
		end
	end
	return false,1
end

function acChristmasAttireVoApi:getFlick()
	local vo=self:getAcVo()
	if vo and vo.flickReward then
		return vo.flickReward
	end
	return {}
end

function acChristmasAttireVoApi:setRecord(record)
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

function acChristmasAttireVoApi:getRecordList()
	return self.recordList or {}
end

function acChristmasAttireVoApi:getRequestLogFlag()
	return self.requestLogFlag
end

--活动所有请求数据处理
function acChristmasAttireVoApi:christmasRequest(action,varArg,callback,isShowTip)
	if action=="active.christmas2016" then --装扮
		local function attireCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	local lastScore=self:getMyPoint()
	            	if sData.data.christmas2016 then
	            		self:updateData(sData.data.christmas2016)
	            	end
	            	local score=self:getMyPoint()
	            	local rewardlist
	            	local crit=0
	            	if sData.data.log then
	            		if self.requestLogFlag==true then
	            			self:setRecord(sData.data.log)
	            		end
	            		if sData.data.log.r then
	            			rewardlist=FormatItem(sData.data.log.r)
	            		end
	            		crit=tonumber(sData.data.log.c) or 0
	            		for k,v in pairs(rewardlist) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
	            		end
	            	end
	                if callback then
	                	local addScore=score-lastScore
	                	if addScore<0 then
	                		addScore=0
	                	end
	                	local materialTb=sData.data.material or {}
	                	-- materialTb={{1,1},{1,3},{2,2},{2,3},{3,1},{3,3},{4,1},{4,2},{5,1},{6,1}}
	                	callback(true,rewardlist,materialTb,addScore,crit)
	                end
	            end
	        else
	        	if callback then
	        		callback(false)
	        	end
	        end
	    end
		socketHelper:christmasRequest(action,varArg[1],varArg[2],nil,nil,attireCallBack)
	elseif action=="active.christmas2016.reward" or action=="active.christmas2016.rankreward" then--兑换和领取排行榜奖励
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
            	local lastNeed=0
            	local nextNeed=0
            	if action=="active.christmas2016.reward" then
            		lastNeed=acChristmasAttireVoApi:getExchangeNeed(varArg[1])
            	end
            	acChristmasAttireVoApi:getExchangeNeed(varArg[1])

	            if sData and sData.data and sData.data.christmas2016 then
	            	self:updateData(sData.data.christmas2016)
	            end
	            local rewardlist
	            if action=="active.christmas2016.reward" then
            		rewardlist=self:getRewardList()
			    	if rewardlist and rewardlist[varArg[1]] and rewardlist[varArg[1]].reward then
			    		rewardlist=FormatItem(rewardlist[varArg[1]].reward,false,true)
			    	end
	            elseif action=="active.christmas2016.rankreward" then
	            	if sData and sData.data and sData.data.reward then
			       		rewardlist=FormatItem(sData.data.reward) or {}
	            	end
	            end
	            if rewardlist then
					for k,v in pairs(rewardlist) do
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
					G_showRewardTip(rewardlist)
	            end

	      		if action=="active.christmas2016.reward" then
            		nextNeed=acChristmasAttireVoApi:getExchangeNeed(varArg[1])
        			if callback then
						if nextNeed-lastNeed>0 then
	            			callback(true)
            			else
	            			callback(false)	
	            		end
        			end
            	else
        		    if callback then
	                	callback()
	                end
            	end
	        end
	    end
	    if action=="active.christmas2016.rankreward" then
			socketHelper:christmasRequest(action,nil,nil,nil,varArg[1],rewardCallback)
	    elseif action=="active.christmas2016.reward" then
			socketHelper:christmasRequest(action,nil,nil,varArg[1],nil,rewardCallback)
	    end
	elseif action=="active.christmas2016.report" then --获取抽奖日志
		local function logHandler(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	        	self.requestLogFlag=true
	            if sData and sData.data and sData.data.christmas2016 then
	            	self:updateData(sData.data.christmas2016)
	            end
	      		if sData and sData.data and sData.data.log then
	      			for k,v in pairs(sData.data.log) do
	      				self:setRecord(v)
	      			end
			        local function sortFunc(a,b)
			            if a and b and a.t and b.t then
			                return tonumber(a.t)>tonumber(b.t)
			            end
			        end
			        if self.recordList then
			        	table.sort(self.recordList,sortFunc)
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
		socketHelper:christmasRequest(action,nil,nil,nil,nil,logHandler)
	elseif action=="active.christmas2016.rank" then --获取排行榜数据
		local function listCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.ranklist then
	            	local ranklist=sData.data.ranklist
	            	self:setRankList(ranklist)
	            	local inRank=false
	            	local uid=playerVoApi:getUid()
	             	for k,v in pairs(ranklist) do
	            		if uid==tonumber(v[1]) then
	            			self.myRank=k
	            			inRank=true
	            			do break end
	            		end
	            	end
	            	if inRank==false then
	            		local myPoint=self:getMyPoint()
         				local rankLimit=self:getRankLimit()
         				if tonumber(myPoint)<tonumber(rankLimit) then
         					self.myRank=getlocal("dimensionalWar_out_of_rank")
         				else
	            			self.myRank=self:getNeedRank().."+"
         				end
	            	end
	                if callback then
	                	callback()
	                end
	            end
	        end
	    end
		socketHelper:christmasRequest(action,nil,nil,nil,nil,listCallback)
	end
end

function acChristmasAttireVoApi:getNeedRank()
	return 10
end

function acChristmasAttireVoApi:getSelfRank()
	return self.myRank
end

function acChristmasAttireVoApi:sendRewardNotice(rtype,myRank)
	local rewardStr=""
    local rewardlist
    if rtype==1 then
    	rewardlist=self:getRewardList()
    	if rewardlist and rewardlist[6] and rewardlist[6].reward then
    		rewardlist=FormatItem(rewardlist[6].reward,false,true)
    	end
    elseif rtype==2 and myRank then
    	rewardlist=acChristmasAttireVoApi:getRankReward()
	    for k,v in pairs(rewardlist) do
	        local rank=v[1]
	        if myRank>=rank[1] and myRank<=rank[2] then
	            rewardlist=FormatItem(v[2],false,true)
	        end
	    end
    end
    if rewardlist then
	    for k,v in pairs(rewardlist) do
	        if k==SizeOfTable(rewardlist) then
	            rewardStr=rewardStr.."【"..v.name.."】"
	        else
	            rewardStr=rewardStr.."【"..v.name.."】".. ","
	        end
	    end
    end
    local playerName=playerVoApi:getPlayerName()
    local activityName=getlocal("activity_christmas2016_title")
    local message
    if rtype==1 then
    	message={key="activity_christmas2016_notice1",param={playerName,activityName,rewardStr}}
	elseif rtype==2 then
    	message={key="activity_christmas2016_notice2",param={playerName,activityName,myRank,rewardStr}}
    end
    if message then
    	local paramTab={}
    	paramTab.functionStr="christmas2016"
        paramTab.addStr="goTo_see_see"
    	chatVoApi:sendSystemMessage(message,paramTab)
    end
end

function acChristmasAttireVoApi:tick()

end

function acChristmasAttireVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acChristmasAttireVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acChristmasAttireVoApi:clearAll()
	self.rankList=nil
	self.myRank="0"
	self.isTodayFlag=true
	self.materialPicCfg=nil
	self.recordList=nil
	self.requestLogFlag=false
	self.vo=nil
end