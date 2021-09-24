acYswjVoApi={
	taskList=nil,
	logList=nil,
	requestLogFlag=false,
}

function acYswjVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("yswj")
	end
	return self.vo
end

function acYswjVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.version then
		return vo.activeCfg.version
	end
	return 1 --默认
end

function acYswjVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acYswjVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acYswjVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acYswjVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acYswjVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acYswjVoApi:canReward()
	local vo=self:getAcVo()
	local flag=self:canTaskReward()
	return flag
end

function acYswjVoApi:canTaskReward()
	local tasklist=self:getTaskList()
	for k,v in pairs(tasklist) do
		local state=self:getTaskState(v)
		if state==1 then
			return true
		end
	end
	return false
end

function acYswjVoApi:showSmallDialog(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
	local sd=acChunjiepanshengSmallDialog:new()
	sd:init(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
end

function acYswjVoApi:checkInit(callback)
	local vo=self:getAcVo()
	if(vo and vo.stoneList)then
		self:checkStoneInfo()
		if(callback)then
			callback()
		end
	else
		local function onRequestEnd()
			if(callback)then
				callback()
			end
		end
		self:yswjRequest("active.yunshiwajue.getalien",{},onRequestEnd)
	end
end

function acYswjVoApi:getStoneList()
	local vo=self:getAcVo()
	if vo and vo.stoneList then
		return vo.stoneList
	end
	return {}
end

--获取已经抽到的奖励列表
function acYswjVoApi:getRewardFlagTb()
	local vo=self:getAcVo()
	if vo.rewardFlagTb then
		return vo.rewardFlagTb
	end
	return {}
end

function acYswjVoApi:clearRewardFlagTb()
	local vo=self:getAcVo()
	if vo.rewardFlagTb then
		vo.rewardFlagTb={}
	end
end

function acYswjVoApi:getRewardPool()
	local content={}
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.showList then
		for k,v in pairs(vo.activeCfg.showList) do
			local item={}
			item.rewardlist=FormatItem(v,nil,true)
			local subStr=""
			local count=SizeOfTable(item.rewardlist)
			if k<=3 then
				if count>1 then
					subStr=getlocal("yswj_rpool_anyelse")
				else
					subStr=getlocal("bookmarksAll")
				end
			else
				subStr=getlocal("bookmarksAll")
			end
			local titleStr=getlocal("yswj_rpool_title"..k)
			item.title={titleStr}
			item.subTitle={getlocal("yswj_rpool_pro",{titleStr,subStr})}
			table.insert(content,1,item)
		end
	end
	return content
end
--是否是免费挖掘
function acYswjVoApi:isFreeGather()
	local flag=1
	local vo=self:getAcVo()
	if vo then
		if vo.free and vo.free>=1 then
			flag=0
		end
	end

	return flag
end
--重置免费挖掘次数
function acYswjVoApi:resetFreeGather()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end

--挖掘消耗
function acYswjVoApi:getGatherCost()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.cost1,vo.activeCfg.cost2
	end
	return nil,nil
end

function acYswjVoApi:getPlayNum()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.playNum then
		return vo.activeCfg.playNum
	end
	return 4
end
--是否可以重置的陨石列表
function acYswjVoApi:isReset()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.playNum then
		local playNum=vo.activeCfg.playNum
		local gatherNum=vo.gatherNum or 0
		if gatherNum>=playNum then
			return true,2
		elseif gatherNum>=1 then
			return true,1
		end
	end
	return false
end

function acYswjVoApi:getResource(id)
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.resource then
		return vo.activeCfg.resource[id]
	end
	return nil
end

function acYswjVoApi:getGetNameAndPic(id)
	local resource=self:getResource(id)
	local getItem=FormatItem(resource.get)
	return getItem[1].name,getItem[1].pic,getItem[1].key,getItem[1].desc,getItem[1].num
end

function acYswjVoApi:getCostItem(id)
	local resource=self:getResource(id)
	local costItem=FormatItem(resource.cost)
	return costItem
end

function acYswjVoApi:getGetItem(id)
	local resource=self:getResource(id)
	local getItem=FormatItem(resource.get)
	return getItem
end

function acYswjVoApi:getMaxNum(costItem)
	local num1=costItem[1].num
	local num2=tonumber(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(costItem[1].key))))
	local num3=costItem[2].num
	local num4=alienTechVoApi:getAlienResByType(costItem[2].key)
	local maxnum1=num2/num1
	local maxnum2=num4/num3
	local maxNum=maxnum2
	if maxnum1<maxnum2 then
		maxNum=maxnum1
	end
	return maxNum
end

function acYswjVoApi:getTaskList()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.task then
		if self.taskList==nil then
			self.taskList={}
			for k,v in pairs(vo.activeCfg.task) do
				v.tid=k
				table.insert(self.taskList,v)
			end
		end
		for k,task in pairs(self.taskList) do
			local state=self:getTaskState(task)
			task.weight=state*100+task.index
		end
		local function sortFunc(a,b)
			if a and b and a.weight and b.weight then
				return a.weight<b.weight
			end
			return false
		end
		table.sort(self.taskList,sortFunc)
		return self.taskList
	end
	return {}
end

--state: 1->可领取，2->未完成，3->已领取
function acYswjVoApi:getTaskState(task)
	local state=2
	local cur=0
	if task then
		local tid="t"..task.tid
		local vo=self:getAcVo()
		if vo.task and vo.task[tid] then
			local cur=tonumber(vo.task[tid])
			if vo.tr and vo.tr[task.tid] and vo.tr[task.tid]==1 then
				state=3
			elseif cur>=tonumber(task.needNum) then
				state=1
			end
			return state,cur,task.needNum
		end
		return state,cur,task.needNum
	end
	return state,cur,0
end

function acYswjVoApi:isAllTaskRewarded()
	local vo=self:getAcVo()
	if vo.tr then
		local count=SizeOfTable(vo.tr)
		local tasklist=self:getTaskList()
		local taskCount=SizeOfTable(tasklist)
		if count==taskCount then
			return true
		end
	end
	return false
end

function acYswjVoApi:getTaskDesc(mtype,num)
	local desCfg={
		{"activity_yswj_tdesc1","alien_tech_res_name_1"},
		{"activity_yswj_tdesc1","alien_tech_res_name_2"},
		{"activity_yswj_tdesc1","alien_tech_res_name_3"},
		{"activity_yswj_tdesc2","alien_tech_res_name_2"},
		{"activity_yswj_tdesc2","alien_tech_res_name_3"},
		{"activity_yswj_tdesc3"},
	}
	local cfg=desCfg[mtype]
	if cfg then
		if cfg[2]==nil then
			return getlocal(cfg[1],{num})
		end
		return getlocal(cfg[1],{num..getlocal(cfg[2])})
	end
	return ""
end

function acYswjVoApi:showRewardSmallDialog(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreSmallDialog"    
    local dialog=acMineExploreSmallDialog:new()
    dialog:init(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler)
    return dialog
end

function acYswjVoApi:getLogLimit()
	return 10
end

function acYswjVoApi:formatLog(log)
	if log then
		local num=log[1]
		local rewardlist={}
		for ptype,ptb in pairs(log[2]) do
			local list={}
			for key,num in pairs(ptb) do
				local index=self:getSortIndex(key)
				local reward={}
				reward[key]=num
				reward.index=index
				table.insert(list,reward)
			end
			rewardlist[ptype]=list
		end

		local reward=FormatItem(rewardlist,nil,true)
		local time=log[3]
		local colorTb={G_ColorWhite}
		local desc=""
		if num==1 then
			desc=getlocal("yswj_record_pro",{getlocal("yswj_gather")})
		else
			desc=getlocal("yswj_record_pro",{getlocal("yswj_allgather")})
			colorTb={G_ColorGreen}
		end
		return {award=reward,time=time,desc=desc,colorTb=colorTb}
	end
	return {}
end

function acYswjVoApi:getSortIndex(key)
	local vo=self:getAcVo()
	if vo then
		if vo.activeCfg.showList and vo.activeCfg.showList[3] then
			for ptype,ptb in pairs(vo.activeCfg.showList[3]) do
				for kk,reward in pairs(ptb) do
					if reward[key] then
						return reward.index
					end
				end
			end
		end
	end
	return 1
end

function acYswjVoApi:addLog(log,selfAdd)
	if self.logList==nil then
		self.logList={}
	end
	local rcount=SizeOfTable(self.logList)
	local limit=self:getLogLimit()
	if rcount>=limit then
		for i=limit,rcount do
			table.remove(self.logList,i)
		end
	end
	if selfAdd and selfAdd==true then
		table.insert(self.logList,1,log)
	else
		table.insert(self.logList,log)
	end
end

function acYswjVoApi:getLogList()
	return self.logList or {}
end

function acYswjVoApi:clearLog()
	self.logList={}
end

function acYswjVoApi:checkStoneInfo()
    local stoneKey="yswj@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	local stoneStr=CCUserDefault:sharedUserDefault():getStringForKey(stoneKey)
	if stoneStr=="" then
		self:setStoneInfo()
	end
end

function acYswjVoApi:setStoneInfo()
   	local ptype={1,2} --陨石图片类型
    local angle={0,60,120,180,240,300} --陨石旋转角度
    local stoneKey="yswj@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
    local stoneList=self:getStoneList()
    local count=#stoneList
    local stoneStr=""
    for k,v in pairs(stoneList) do
    	local idx=math.random(1,#ptype)
    	local str=ptype[idx]
    	idx=math.random(1,#angle)
    	str=str.."-"..angle[idx]
    	if k~=count then
    		str=str.."|"
    	end
    	stoneStr=stoneStr..str
    end
    --本地保存每一个陨石的图片类型和旋转角度
	CCUserDefault:sharedUserDefault():setStringForKey(stoneKey,stoneStr)
    CCUserDefault:sharedUserDefault():flush()
end

function acYswjVoApi:getStoneInfo()
    local stoneKey="yswj@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	local stoneStr=CCUserDefault:sharedUserDefault():getStringForKey(stoneKey)
	local info={}
  	local strArr=Split(stoneStr,"|")
  	for k,str in pairs(strArr) do
  		local arr=Split(str,"-")
  		table.insert(info,arr)
  	end
  	return info
end

--活动所有请求数据处理
function acYswjVoApi:yswjRequest(cmd,params,callback)
	local requestHandler=nil
	if cmd=="active.yunshiwajue.getalien" then --初始化陨石列表
		local function stoneListCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.yswj then
		            	self:updateData(sData.data.yswj)
	            	end
	            end
	    		self:setStoneInfo()
	            if callback then
	            	callback()
	            end
	        end
		end
		requestHandler=stoneListCallBack
	elseif cmd=="active.yunshiwajue.rand" then --挖掘采集
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	local rewardlist={}
        	       	if sData.data.reward then
       		     		rewardlist=FormatItem(sData.data.reward,nil,true)
	            	end
	            	if rewardlist then
	            		for k,v in pairs(rewardlist) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
	            		end
	            	end
	            	local lid
	            	local detailStr=""
	            	local numTb={}
	            	local stoneList=self:getStoneList()
	            	if sData.data.report then
	            		for k,v in pairs(sData.data.report) do
	            			lid=v[2]
	            			local idx=v[2]
	            			local stype=stoneList[idx]
	            			if stype then
	            				if numTb[stype]==nil then
	            					numTb[stype]=0
	            				end
	            				numTb[stype]=numTb[stype]+1
	            			end
	            		end
	            	end
	            	if self.requestLogFlag==true then
            			if sData.data.log then
	            			local log=self:formatLog(sData.data.log)
	            			self:addLog(log,true)
	            		end
	            	end
	            
	            	local count=SizeOfTable(numTb)
	            	local idx=1
	            	for k,v in pairs(numTb) do
	            		if v>0 then
            				detailStr=detailStr..getlocal("yswj_rpool_title"..k).."x"..v
	            			if idx<count then
	            				detailStr=detailStr.."，"
	            			end
	            			idx=idx+1
	            		end
	            	end
	            	if params.rand==3 then
	            		lid=1001
	            	end
					--先处理本次抽取的奖励，然后重新同步当前数据
	            	if sData.data.yswj then
		            	self:updateData(sData.data.yswj)
	            	end
	            	if callback then
	            		callback(true,lid,rewardlist,detailStr)
	            	end
					eventDispatcher:dispatchEvent("yswj.refreshTip",{})
	            end
            else
            	if callback then
            		callback(false)
            	end	
	        end
	    end
	    requestHandler=rewardCallback
	elseif cmd=="active.yunshiwajue.getlog" then --获取抽奖日志
		local function logHandler(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.yswj then
		            	self:updateData(sData.data.yswj)
	            	end
	            	self.requestLogFlag=true
	            	if sData.data.log then
	            		self:clearLog()  --初始化log列表前，先清空log列表
	            		for k,v in pairs(sData.data.log) do
	            			local log=self:formatLog(v)
	            			self:addLog(log)
	            		end
	            	end
	            end
	        end
	        if callback then
	        	callback()
	        end
	    end
	    requestHandler=logHandler
    elseif cmd=="active.yunshiwajue.taskreward" then --领取任务奖励
    	local function rewardHandler(fn,data)
    		local ret,sData=base:checkServerData(data)
	        if ret==true then
	        	if sData and sData.data then
	        		if sData.data.yswj then
	        			self:updateData(sData.data.yswj)
	        		end
	        		if sData.data.reward then
	        			local rewardlist=FormatItem(sData.data.reward,nil,true)
	        			G_showRewardTip(rewardlist)
	        			for k,v in pairs(rewardlist) do
	                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
	        			end
	        		end
	        	end
	        	if callback then
	        		callback()
	        	end
				eventDispatcher:dispatchEvent("yswj.refreshTip",{})
	        end
    	end
    	requestHandler=rewardHandler
	elseif cmd=="active.yunshiwajue.change" then
		local function refineryHandler(fn,data) --改造
			local ret,sData=base:checkServerData(data)
			if ret==true then
                acYswjVoApi:updateData(sData.data.yswj)
				if callback then
					callback(fn,data)
				end
				eventDispatcher:dispatchEvent("yswj.refreshTip",{})
			end
		end
		requestHandler=refineryHandler
	end
	-- print("cmd,params,requestHandler------->",cmd,params,requestHandler)
	socketHelper:yswjAcRequest(cmd,params,requestHandler)
end

--item商店兑换的宝箱
function acYswjVoApi:sendRewardNotice()
    local playerName=playerVoApi:getPlayerName()
    local activityName=getlocal("activity_yswj_title")
    local message={key="activity_yswj_notice",param={playerName,activityName}}
    if message then
    	local paramTab={}
    	paramTab.functionStr="yswj"
        paramTab.addStr="goTo_see_see"
    	chatVoApi:sendSystemMessage(message,paramTab)
    end
end

function acYswjVoApi:getRequestLogFlag()
	return self.requestLogFlag
end

function acYswjVoApi:tick()

end

function acYswjVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acYswjVoApi:clearAll()
	self.taskList=nil
	self.logList=nil
	self.requestLogFlag=false
	self.vo=nil
end