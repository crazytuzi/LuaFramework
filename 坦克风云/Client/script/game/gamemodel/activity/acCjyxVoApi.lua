acCjyxVoApi={
	rankList=nil,
	logList=nil,
	myRank="0",
	requestLogFlag=false,
	acShowType = {TYPE_1=1,TYPE_2=2}
}

function acCjyxVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("cjyx")
	end
	return self.vo
end

function acCjyxVoApi:getAcShowType()
	local version = self:getVersion()
	if version==2 then
		return self.acShowType.TYPE_2
	end
	return acCjyxVoApi.acShowType.TYPE_1
end

function acCjyxVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.version then
		return vo.activeCfg.version
	end
	return 1 --默认
end

function acCjyxVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
		str=getlocal("activity_timeLabel").."\n"..timeStr
	end

	return str
end

function acCjyxVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local rewardTimeStr=activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
		str=getlocal("recRewardTime").."\n"..rewardTimeStr
	end
	return str
end

function acCjyxVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acCjyxVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acCjyxVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end
	return false
end

--韩国绿色版开关
function acCjyxVoApi:getMustMode()
	local vo=self:getAcVo()
	if vo.activeCfg and vo.activeCfg.mustMode and vo.activeCfg.mustMode==1 and base.mustmodel==1 then
		return true
	end
	return false
end

--获取单抽和连抽的必给奖励
function acCjyxVoApi:getMustReward()
	local vo=self:getAcVo()
	if vo.activeCfg then
		local reward1=vo.activeCfg.mustReward1
		local reward2=vo.activeCfg.mustReward2
		if reward1 and reward1.reward then
			reward1=FormatItem(reward1.reward,nil,true)
		end
		if reward2 and reward2.reward then
			reward2=FormatItem(reward2.reward,nil,true)
		end
		return {reward1[1],reward2[1]}
	end
	return nil
end

-- 自己当前的任务点
function acCjyxVoApi:getMyPoint()
	local vo=self:getAcVo()
	if vo and vo.score then
		return vo.score
	end
	return 0
end

function acCjyxVoApi:getLotteryCost()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.cost1,vo.activeCfg.cost2
	end
	return nil,nil
end

function acCjyxVoApi:getLotteryPool()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.reward then
		return vo.activeCfg.reward
	end
	return {}
end

--ltype：抽到的四种鞭炮的类型
function acCjyxVoApi:getLotteryReward(ltype)
	local rewardlist={}
	local pool=self:getLotteryPool()
	if pool[ltype] then
		rewardlist=FormatItem(pool[ltype],nil,true)
	end
	return rewardlist
end

function acCjyxVoApi:isFreeLottery()
	local flag=1
	local vo=self:getAcVo()
	if vo then
		if vo.free and vo.free>=1 then
			flag=0
		end
	end
	return flag
end

function acCjyxVoApi:resetFreeLottery()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end

function acCjyxVoApi:showSmallDialog(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
	local sd=acChunjiepanshengSmallDialog:new()
	sd:init(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
end

function acCjyxVoApi:getRankList()
	return self.rankList
end

function acCjyxVoApi:setRankList(rank)
	if rank then
		if self.rankList==nil then
			self.rankList={}
		end
		self.rankList=rank
	end
end

function acCjyxVoApi:getRankReward()
	local reward={}
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.rankReward then
		reward=vo.activeCfg.rankReward
	end
	return reward
end

function acCjyxVoApi:getRankLimit()
	local rankLimit=100
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.rankLimit then
		rankLimit=vo.activeCfg.rankLimit
	end
	return rankLimit
end

function acCjyxVoApi:canRankReward()
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

function acCjyxVoApi:addLog(log)
	if self.logList==nil then
		self.logList={}
	end
	local rcount=SizeOfTable(self.logList)
	if rcount>=15 then
		for i=15,rcount do
			table.remove(self.logList,i)
		end
	end
	table.insert(self.logList,1,log)
end

function acCjyxVoApi:getLogLimit()
	return 15
end

function acCjyxVoApi:getLogList()
	return self.logList or {}
end

function acCjyxVoApi:getRequestLogFlag()
	return self.requestLogFlag
end

function acCjyxVoApi:getFirecrackersName(fid)
	local name=getlocal("cjyx_firecrackers"..fid)
	return name
end

function acCjyxVoApi:formatLog(log)
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
		local desc=""
		local pointStr=getlocal("cjyx_point_str").."："..score
		local color=G_ColorWhite
		if num and tonumber(num)>1 then
			color=G_ColorGreen
		end
		--韩国绿色版固定奖励特殊处理
		if self:getMustMode()==true then
	       	local mustRewardCfg=acCjyxVoApi:getMustReward()
	        local mustReward
	        if num==1 then
	            mustReward=mustRewardCfg[1]
	        else
	            mustReward=mustRewardCfg[2]
	        end
        	local item={}
			item[1]={mustReward}
			item[2]=getlocal("cjyx_rpool_fixReward")
			item[3]=G_ColorWhite
			table.insert(content,1,item)

			desc=mustReward.name.."x"..FormatNumber(mustReward.num)
		else
			desc=getlocal("cjyx_multilottery",{num})
		end
		local logItem={title={desc,color},append={pointStr},ts=ts,content=content}
		return logItem
	end
	return {}
end

--活动所有请求数据处理
--taskType:领取任务奖励的任务key（对于那些玩家已经升到顶级无法完成的任务，需要给后台传任务key）
function acCjyxVoApi:cjyxAcRequest(cmd,params,callback)
	local requestHandler=nil
	if cmd=="active.cjyx" or cmd=="active.cjyx.rankreward" then --抽奖和领取排行榜奖励
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.cjyx then
		            	self:updateData(sData.data.cjyx)
	            	end
	            	local rewardlist={}
        	       	if sData.data.reward then
       		     		rewardlist=FormatItem(sData.data.reward,nil,true)
	            	end
	            	if rewardlist then
	            		for k,v in pairs(rewardlist) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
	            		end
	            		if self:getMustMode()==true then --韩国绿色活动固定奖励添加
        			       	local mustRewardCfg=acCjyxVoApi:getMustReward()
					        local reward
					        if params.num==1 then
					            reward=mustRewardCfg[1]
					        else
					            reward=mustRewardCfg[2]
					        end
					        if reward then
								G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
					        end
	            		end
	            	end
	            	if cmd=="active.cjyx" then
		            	local noticeR --用于礼花炮广播的奖励
		            	if params.num==1 and sData.data.detail and sData.data.detail[2] then --单抽时，如果抽到的二踢脚和挂鞭炮时特殊处理
		            		rewardlist={}
		            		local detail=sData.data.detail[2]
		            		if detail then
								for k,v in pairs(detail) do
			            			local reward=FormatItem(v,nil,true)[1]
			            			table.insert(rewardlist,reward)
			            		end
		            		end
		            	end
		            	local lottery={} --key是抽到的奖励个数，value是爆炸次数
		            	local detailStr=getlocal("cjyx_point_str")..sData.data.score
		            	if sData.data.log then
			  		  		if sData.data.log.r then
	        		  			local str=""
	        		  			for k,r in pairs(sData.data.log.r) do
	        		  				local rtype=r[1]
	        		  				lottery[1]=rtype
	        		  				lottery[2]=r[3] or 1
									local times=r[4] or 0
	        		  				local fireName=self:getFirecrackersName(rtype)
	        		  				str=fireName.."x"..times..","..str
	        		  				if tonumber(rtype)==4 then
										noticeR=FormatItem(r[2],nil,true)
	        		  				end
	        		  			end
	        		  			detailStr=str..detailStr
		            		end
		            		if self.requestLogFlag==true then
								local log=self:formatLog(sData.data.log)
								self:addLog(log)
		            		end
		            	end
		            	if params.num==10 then
		            		lottery[1]=5
		            		lottery[2]=1
		            	end
            			callback(true,rewardlist,detailStr,noticeR,lottery,sData.data.score)	
	            	elseif cmd=="active.cjyx.rankreward" then
        				callback(true,rewardlist)
        				G_showRewardTip(rewardlist)
	            	end
	            end
            else
            	if callback then
            		callback(false)
            	end	
	        end
	    end
	    requestHandler=rewardCallback
	elseif cmd=="active.cjyx.report" then --获取抽奖日志
		local function logHandler(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.cjyx then
		            	self:updateData(sData.data.cjyx)
	            	end
	            	self.requestLogFlag=true
	            	local hasLog=false
	            	if sData.data.log then
	            		for k,log in pairs(sData.data.log) do
	            			local log=self:formatLog(log)
	            			self:addLog(log)
	            			hasLog=true
	            		end
	            		if self.logList then
	            			local function sort(a,b)
	            				if a and b and a.ts and b.ts then
	            					return tonumber(a.ts)>tonumber(b.ts)
	            				end
	            				return false
	            			end
	            			table.sort(self.logList,sort)
	            		end
	            	end
	            end
	        end
	        if callback then
	        	callback()
	        end
	    end
	    requestHandler=logHandler
	elseif cmd=="active.cjyx.rank" then --获取排行榜数据
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
       	requestHandler=listCallback
	end
	-- print("cmd,params,requestHandler------->",cmd,params,requestHandler)
	socketHelper:cjyxAcRequest(cmd,params,requestHandler)
end

function acCjyxVoApi:getNeedRank()
	return 10
end

function acCjyxVoApi:getSelfRank()
	-- return self.selfRank
	return self.myRank
end

function acCjyxVoApi:showFireworksEffectDialog(params)
	local uid=params.uid
	local myUid=playerVoApi:getUid()
	-- print("uid,myUid------>",uid,myUid)
	if uid and myUid and tostring(myUid)~=tostring(uid) then
		if(newGuidMgr and newGuidMgr.isGuiding==true) or (otherGuideMgr and otherGuideMgr.isGuiding==true)then
			do return end
		end
		local sceneIdx=sceneController:getNextIndex()-1
		if mainUI:isVisible()==true and (sceneIdx==0 or sceneIdx==1 or sceneIdx==2) and base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 then
	        require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
			acCjyxSmallDialog:showFireworksEffectDialog()
		end
	end
end
function acCjyxVoApi:sendCjyxNotice(notice)
	local function getRewardStr(rewardlist)
		local rewardStr=""
		for k,v in pairs(rewardlist) do
		    if k==SizeOfTable(rewardlist) then
		        rewardStr=rewardStr.."【"..v.name.."】"
		    else
		        rewardStr=rewardStr.."【"..v.name.."】".. ","
		    end
		end
		return rewardStr
	end
    local playerName=playerVoApi:getPlayerName()
    local acName=getlocal("activity_cjyx_title")
	local message={}
	local paramTab={}
	paramTab.functionStr="cjyx"
    paramTab.addStr="goTo_see_see"
	if notice then
		if notice.ntype==1 then --抽到礼花弹
			local ltype=notice.ltype
			local lname=self:getFirecrackersName(ltype)
			local rewardlist=notice.rewardlist
            local rewardStr=getRewardStr(rewardlist)
            if self:getMustMode()==true then
		       	local mustRewardCfg=acCjyxVoApi:getMustReward()
		        local mustReward
		        if notice.num==1 then
		            mustReward=mustRewardCfg[1]
		        else
		            mustReward=mustRewardCfg[2]
		        end
				message={key="cjyx_lottery_notice2",param={playerName,acName,mustReward.name,lname,rewardStr}}
		    else
				message={key="cjyx_lottery_notice",param={playerName,acName,lname,rewardStr}}
            end			
			local myUid=playerVoApi:getUid()
            chatVoApi:sendUpdateMessage(43,{uid=myUid})
		elseif notice.ntype==2 then --排名奖励
			local rewardStr=""
			local myRank=notice.rank
			if myRank and myRank>0 then
			    local rewards=acCjyxVoApi:getRankReward()
			    for k,v in pairs(rewards) do
			        local rank=v[1]
			        if myRank>=rank[1] and myRank<=rank[2] then
			            local rewardlist=FormatItem(v[2],false,true)
			            rewardStr=getRewardStr(rewardlist)
			        end
			    end
			end
			message={key="activity_christmas2016_notice2",param={playerName,acName,myRank,rewardStr}}
		end
	end
    if message then
    	chatVoApi:sendSystemMessage(message,paramTab)
    end
end

function acCjyxVoApi:getFlick()
	local vo=self:getAcVo()
	if vo and vo.flick then
		return vo.flick
	end
	return {}
end

function acCjyxVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acCjyxVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acCjyxVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acCjyxVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acCjyxVoApi:clearAll()
	self.rankList=nil
	self.logList=nil
	self.myRank="0"
	self.requestLogFlag=false
	self.vo=nil
end