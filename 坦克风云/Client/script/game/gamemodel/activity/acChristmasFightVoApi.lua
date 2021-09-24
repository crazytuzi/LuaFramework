acChristmasFightVoApi={
	cRankList={},	--贡献榜
	aRankList={},	--活跃榜
	snowmanData={},	--雪人数据
	flag=1,			--数据变化刷新
	lastUpdateTime=0,--上次请求数据时间戳
	lastStatus=nil, --上次状态
	acShowType={TYPE_1=1,TYPE_2=2}
}

function acChristmasFightVoApi:getAcVo()
	return activityVoApi:getActivityVo("christmasfight")
end

function acChristmasFightVoApi:getAcShowType()
	local version = self:getVersion()
	if version==3 then
		return self.acShowType.TYPE_2
	end
	return self.acShowType.TYPE_1
end

function acChristmasFightVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acChristmasFightVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acChristmasFightVoApi:updateActiveData(action,method,callback)
	local function onRequestEnd(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
        	if sData and sData.data then
        		self:setLastUpdateTime(sData.ts)
        		if action=="rand" then
        			local costGems
        			local vo=self:getAcVo()
        			if method==2 then
        				costGems=vo.cost
        				playerVoApi:setGems(playerVoApi:getGems()-costGems)
    				elseif method==3 then
    					costGems=vo.tenCost
    					playerVoApi:setGems(playerVoApi:getGems()-costGems)
        			end
        		end
        		if sData.data.christmasfight then
		        	self:updateData(sData.data.christmasfight)
		        end
		        if action=="rank" and sData.data.ranklist then 
		        	if method==1 then
		        		self.cRankList={}
		        		self.cRankList=sData.data.ranklist
		        	else
		        		self.aRankList={}
		        		self.aRankList=sData.data.ranklist
		        	end
		        end
		        if sData.data.devil then
		        	local oldStatus=acChristmasFightVoApi:getSnowmanData()
		        	self:setSnowmanData(sData.data.devil)
		        	if action=="rand" then
			        	local status=acChristmasFightVoApi:getSnowmanData()
			        	self:checkSendChat(oldStatus,status)
			        end
		        end
		        if(sData.data.weapon)then
                    superWeaponVoApi:formatData(sData.data.weapon)
                end
                if sData.data.reward then
                	local award=FormatItem(sData.data.reward) or {}
					for k,v in pairs(award) do
						G_addPlayerAward(v.type,v.key,v.id,v.num)
						if v.type=="p" and v.key=="p894" then
							local _ketStr="activity_christmasfight_chat_3"
							if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
								_ketStr="activity_christmasfight_chat_3_1"
							end
							local message={key=_ketStr,param={playerVoApi:getPlayerName()}}
		                    chatVoApi:sendSystemMessage(message)
						end
					end
                end
                if sData.data.report then
                	local vo=self:getAcVo()
					if vo and vo.bigRewardCfg then
						local rNum=SizeOfTable(vo.bigRewardCfg)
	                	for k,v in pairs(sData.data.report) do
	                		if v and v[1] then
		                		local reward=v[1]
		                		local award=FormatItem(reward) or {}
								for m,n in pairs(award) do
									-- local isAdd=true
									for i,j in pairs(vo.bigRewardCfg) do
										if j and j.r then
											local rewardTb=FormatItem(j.r)
											if rewardTb and rewardTb[1] then
												local item=rewardTb[1]
												if item and item.type==n.type and item.key==n.key and item.num==n.num then
													local rStr=G_showRewardTip(rewardTb,false,true)
													local message={key="activity_christmasfight_chat_6",param={playerVoApi:getPlayerName(),((rNum+1)-i).."/"..(rNum+1),rStr}}
								                    chatVoApi:sendSystemMessage(message)
													-- isAdd=false
												end
											end
										end
									end
									-- if isAdd==true then
										G_addPlayerAward(n.type,n.key,n.id,n.num,nil,true)
									-- end
								end
							end
	                	end
                	end
                end
                if action=="rand" then
	                local prams={retTb=sData}
	                chatVoApi:sendUpdateMessage(28,prams)
	            end
			end
        end
        if callback then
			callback(sData)
		end
	end
	if action=="rankreward" then
		local rank=self:getRank(method)
		if rank>0 then
			socketHelper:activeChristmasfight(action,method,onRequestEnd,rank)
		end
	else
		socketHelper:activeChristmasfight(action,method,onRequestEnd)
	end
end

function acChristmasFightVoApi:checkSendChat(oldStatus,status,isSend)
	if (oldStatus and status and status~=oldStatus) or isSend==true then
        if status==0 then
        	local _keyStr="activity_christmasfight_chat_4"
			if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
				_keyStr="activity_christmasfight_chat_4_1"
			end
            local message={key=_keyStr,param={}}
            chatVoApi:sendSystemMessage(message)
        elseif status==1 then
        	local _keyStr="activity_christmasfight_chat_5"
			if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
				_keyStr="activity_christmasfight_chat_5_1"
			end
            local message={key=_keyStr,param={}}
            chatVoApi:sendSystemMessage(message)
        end
    end
end

--返回值：
-- status：1，状态  =1 是恶魔状态  0 是天使
-- point：500，剩余次数
-- time：1449562576，最近一次计算的 恶魔点数的时间 =1 不要计算
function acChristmasFightVoApi:getSnowmanData()
	local status,point,time=0,0,0
	if self.snowmanData and SizeOfTable(self.snowmanData)>0 then
		status=self.snowmanData[1] or 0
		point=self.snowmanData[2] or 0
		time=self.snowmanData[3] or 0
		if status==0 and self:acIsStop()==false then
			local diffTime=base.serverTime-time
			if diffTime<0 then
				diffTime=0
			end
			-- print("diffTime",diffTime)
			local vo=self:getAcVo()
			local addPoint=math.floor(diffTime/vo.addMin)
			point=point+addPoint
			-- print("addPoint,point",addPoint,point)
			if point>=vo.maxPoint then
				point=vo.maxPoint
				status=1
			end
		end
	end
	return status,point,time
end
function acChristmasFightVoApi:setSnowmanData(snowmanData)
	self.snowmanData=snowmanData
end

--领取贡献奖励的状态,{0,1,2},0不能领取，1可以领取，2已经领取
function acChristmasFightVoApi:getCRewardStatus()
	local statusTb={0,0,0}
	local vo=self:getAcVo()
	if vo and vo.pointRewardCfg then
		for k,v in pairs(vo.pointRewardCfg) do
			if v and v.p and v.reward then
				local point=v.p
				local reward=v.reward
				if vo.cPoint>=point then
					statusTb[k]=1
					if vo.hasPointReward then
						for m,n in pairs(vo.hasPointReward) do
							if n==k then
								statusTb[k]=2
							end
						end
					end
				end
			end
		end
	end
	return statusTb
end

function acChristmasFightVoApi:getRanklist(type)
	if type==1 then
		return self.cRankList
	elseif type==2 then
		return self.aRankList
	end
	return {}
end

function acChristmasFightVoApi:getRank(type)
	local rankList=self:getRanklist(type)
	if rankList and SizeOfTable(rankList)>0 then
		for k,v in pairs(rankList) do
			if v and v[1] and playerVoApi:getUid()==tonumber(v[1]) then
				return k
			end
		end
	end
	return 0
end

--status 0不能领奖，1可以领奖，2已领取
function acChristmasFightVoApi:getRRewardStatus(type)
	local status=0
	local vo=self:getAcVo()
	if self:acIsStop()==true and vo then
		local rank=self:getRank(type)
		if rank and rank>0 then
			status=1
			if vo.hasReward then
				for m,n in pairs(vo.hasReward) do
					if n and n==type then
						status=2
					end
				end
			end
		end
	end
	return status
end

function acChristmasFightVoApi:getFlag()
	return flag
end
function acChristmasFightVoApi:setFlag(flag)
	self.flag=flag
end
function acChristmasFightVoApi:getLastUpdateTime()
	return self.lastUpdateTime
end
function acChristmasFightVoApi:setLastUpdateTime(lastUpdateTime)
	self.lastUpdateTime=lastUpdateTime
end


function acChristmasFightVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
	return vo
end

function acChristmasFightVoApi:isFree()
	local vo=self:getAcVo()
	if vo then
		if G_isToday(vo.lastTime)==true then
			if vo.freeNum==0 then
				return true
			else
				return false
			end
		else
			return true
		end
	end
	return false
end

-- 是否是领奖时间
function acChristmasFightVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acChristmasFightVoApi:canReward()
	if (self:acIsStop()==false and self:isFree()==true) or self:getRRewardStatus(1)==1 or self:getRRewardStatus(2)==1 then
		return true
	end
	return false
end

function acChristmasFightVoApi:tick()
	if self:acIsStop()==false then
		local status=acChristmasFightVoApi:getSnowmanData()
		if self.lastStatus==nil then
			self.lastStatus=status
		end
		-- print("self.lastStatus",self.lastStatus,status)
		if self.lastStatus==0 and status==1 then
			local _keyStr="activity_christmasfight_chat_5"
			if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
				_keyStr="activity_christmasfight_chat_5_1"
			end
			local isChat=true
			local chatList=chatVoApi:getChatFromAll(1)
			for k,v in pairs(chatList) do
				if v and v.contentType==3 and v.subType==4 and v.content==getlocal(_keyStr) then
					isChat=false
				end
			end
			if isChat==true then
				local params={subType=4,contentType=3,message={key=_keyStr,param={}},ts=base.serverTime}
	            chatVoApi:addChat(1,0,"",0,"",params,base.serverTime)
			end
		end
		self.lastStatus=status
	end
end

function acChristmasFightVoApi:clearAll()
	self.cRankList={}
	self.aRankList={}
	self.snowmanData={}
	self.flag=1
	self.lastUpdateTime=0
	self.lastStatus=nil
end
