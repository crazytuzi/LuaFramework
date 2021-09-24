acMineExploreVoApi={
	isTodayFlag=true,
	recordList=nil,
	map=nil, --整理后的地图数据，以地图块id为key
	emap=nil, --整理后的下一次可解锁的地图块数据，以地图块id为key
	requestLogFlag=false,
	rankLimit=nil, --领取每层奖励的排行限制
}

function acMineExploreVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("mineExplore")
	end
	return self.vo
end

function acMineExploreVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.activeCfg.version then
		return vo.activeCfg.version
	end
	return 1 --默认
end

function acMineExploreVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acMineExploreVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acMineExploreVoApi:canReward()
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

function acMineExploreVoApi:updateMap()
	self.map={}
	self.emap={}
	local vo=self:getAcVo()
	if vo then
		if vo.map then
			for k,v in pairs(vo.map) do
				self.map[v]=1
			end
		end
		if vo.emap then
			for k,v in pairs(vo.emap) do
				self.emap[v]=1
			end
		end
	end
end
--获取迷宫地图
function acMineExploreVoApi:getMap()
	if self.emap==nil and self.emap==nil then
		self:updateMap()
	end
	local ver=self:getVersion()
	local vo=self:getAcVo()
	local mapCfg={}
	local mapData=self.map
	local base
	local rotation=1
	if vo then
		if mineExploreCfg[ver] and vo.mid and mineExploreCfg[ver][vo.mid] then
			mapCfg=mineExploreCfg[ver][vo.mid].map
		end
		if vo.rd then
			rotation=(vo.rd-1)*90
		end
		if vo.base then
			base=vo.base
		end
	end
	return mapCfg,mapData,base,rotation
end

function acMineExploreVoApi:getCanDigCount()
	local mapCfg,mapData=self:getMap()
	local count=SizeOfTable(mapCfg)-SizeOfTable(mapData)
	if count<0 then
		count=0
	end
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.maxNum and count>vo.activeCfg.maxNum then
		count=vo.activeCfg.maxNum
	end
	return count
end

--获取下一次可以周围扩展的地图方向 v={1,{1}} v[1]:地图块id，v[2]：可能扩展的方向，方向id：1，2，3，4--》上，下，左，右
function acMineExploreVoApi:getNextDir(cellId)
	local mapCfg=self:getMap()
	if self.emap and self.emap[cellId] and self.map then
		if cellId and mapCfg[cellId] and mapCfg[cellId].adjoin then
			local dir={}
			local cell={}
			local nextTb=mapCfg[cellId].adjoin
			for k,nextId in pairs(nextTb) do
				if self.map[nextId]==nil then
					if nextId==(cellId-1) then
						table.insert(dir,3)
					elseif nextId==(cellId+1) then
						table.insert(dir,4)
					elseif nextId==(cellId-4) then
						table.insert(dir,1)
					elseif nextId==(cellId+4) then
						table.insert(dir,2)
					end
					table.insert(cell,nextId)
				end
			end
			return dir,cell
		end
	end
	return nil
end
--获取出发点
function acMineExploreVoApi:getBase()
	local vo=self:getAcVo()
	if vo and vo.base then 
		return vo.base
	end
	return nil
end
--本层通往下层的入口
function acMineExploreVoApi:getEntry()
	local vo=self:getAcVo()
	if vo and vo.entry then 
		return vo.entry
	end
	return nil
end
--是否达到终点
function acMineExploreVoApi:isReachExit()
	local entry=self:getEntry()
	if self.map and self.map[entry] then
		return true
	end
	return false
end
--获取迷宫每层宝箱的奖励
function acMineExploreVoApi:getMazeChestReward()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.reward then
		return vo.activeCfg.reward
	end
	return {}
end
--获取隐藏宝箱
function acMineExploreVoApi:getChestMaze()
	local vo=self:getAcVo()
	if vo and vo.box then
		return vo.box
	end
	return nil
end

function acMineExploreVoApi:isUnlockChest(cellId)
	local chestTb=self:getChestMaze()
	local chestR=self:getMazeChestReward()
	for k,v in pairs(chestR) do
		local cid=chestTb[k]
		if tonumber(cellId)==tonumber(cid) and self.map[cellId] then
			return true
		end
	end
	return false
end
--判断是不是所有隐藏宝箱已经领取
function acMineExploreVoApi:isChestAllGet()
	local flag=false
	local box=self:getChestMaze()
	local chestR=self:getMazeChestReward()
	local chestCount=SizeOfTable(chestR)
	if box and self.map then
		local count=0
		for i=1,chestCount do
			local cellId=box[i]
			if cellId and self.map[cellId] then
				count=count+1
			end
		end
		if count>=chestCount then
			flag=true
		end
	end
	return flag
end

function acMineExploreVoApi:isAllDiged()
	local mapCfg,mapData=self:getMap()
	if SizeOfTable(mapCfg)==SizeOfTable(mapData) then
		return true
	end
	return false
end

function acMineExploreVoApi:getRemainDoubleLayer()
	local remain=0
	local layer=self:getLayer()
	local doubleLayer=self:getDoubleLayer()
	if doubleLayer>0 then
		if layer%doubleLayer==0 then
			remain=0
		else
			remain=doubleLayer-layer%doubleLayer
		end
	end
	return remain
end

function acMineExploreVoApi:getDoubleLayer()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.doubleLayer then
		return tonumber(vo.activeCfg.doubleLayer)
	end
	return 1
end
function acMineExploreVoApi:getLayer()
	local vo=self:getAcVo()
	if vo and vo.l then
		return vo.l
	end
	return 0
end


function acMineExploreVoApi:isShowLayerRank()
	local layerNum=self:getLayer()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.layerLimit then
		if tonumber(vo.activeCfg.layerLimit)<=tonumber(layerNum) then
			return true
		end
	end
	return false
end

function acMineExploreVoApi:showSmallDialog(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
	local sd=acChunjiepanshengSmallDialog:new()
	sd:init(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
end

--自己当前的任务点
function acMineExploreVoApi:getMyPoint()
	local vo=self:getAcVo()
	if vo and vo.score then
		return vo.score
	end
	return 0
end

--是否是免费挖掘
function acMineExploreVoApi:isFreeDig()
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
function acMineExploreVoApi:resetFreeDig()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end

--挖掘消耗
function acMineExploreVoApi:getDigCost()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.cost1 then
		local digCount=self:getCanDigCount()
		return vo.activeCfg.cost1,digCount*vo.activeCfg.cost1
	end
	return nil,nil
end

function acMineExploreVoApi:getShopCfg()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.shop then
		return vo.activeCfg.shop
	end
	return {}
end

function acMineExploreVoApi:getBuyData(saleId)
	local cur=0 --已购次数
	local vo=self:getAcVo()
	if vo and vo.shop then
		cur=vo.shop[saleId] or 0
	end
	return cur
end

function acMineExploreVoApi:getShopIndexTb()
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

--每层获得积分的名次限制
function acMineExploreVoApi:getRankLimit()
	if self.rankLimit==nil then
		local vo=self:getAcVo()
		if vo and vo.activeCfg and vo.activeCfg.rank then
			local rank=vo.activeCfg.rank
			local max=SizeOfTable(rank)
			if rank[max] and rank[max]["1"] and rank[max]["1"][2] then
				self.rankLimit=rank[max]["1"][2]
			end
		end
	end
	return self.rankLimit or 0
end

function acMineExploreVoApi:canRankReward()
	return false,1
end

function acMineExploreVoApi:setRecord(record)
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

function acMineExploreVoApi:getRecordList()
	return self.recordList or {}
end

function acMineExploreVoApi:showRewardSmallDialog(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreSmallDialog"    
    local dialog=acMineExploreSmallDialog:new()
    dialog:init(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler)
    return dialog
end

--活动所有请求数据处理
function acMineExploreVoApi:mineExploreRequest(action,varArg,callback,isShowTip)
	if action=="active.mineexplore" then --挖掘
		local function digCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if sData.data.mineExplore then
	            		self:updateData(sData.data.mineExplore)
	            	end
	            	self:updateMap()
	            	--log字段下的r是所有奖励（包括宝箱奖励） ，s是奇异宝石的奖励
	            	--log字段作为记录显示
            		local rewards={}
				  	if sData.data.log then
	            		if sData.data.log.r then
	            			local reward=FormatItem(sData.data.log.r)
	            			for k,v in pairs(reward) do
	            				table.insert(rewards,v)
	            			end
	            		end
	            		local num=sData.data.log.s
        				if num and num>0 then
            				local key="p3338"
            				local type="p"
            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
							table.insert(rewards,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num})
            			end
	            	end
					if self.requestLogFlag==true then
           				local ts=sData.data.log.ts
            			local digNum=sData.data.log.n
						local desc=getlocal("multi_excavate",{digNum})
                		local colorTb={G_ColorWhite}
                		local hasChest=sData.data.log.k
                		if hasChest and tonumber(hasChest)==1 then
			                desc=desc.."（"..getlocal("hide_chest").."）"
                			colorTb={G_ColorYellowPro}
                		end
						local record={award=rewards,time=ts,desc=desc,colorTb=colorTb}
						self:setRecord(record)
            		end
            		--showLog字段中 r：普通地块奖励，r1：宝箱地块奖励，s：普通地块奇异宝石数量，s1：宝箱地块奇异宝石数量
            		--showLog字段最为前台奖励显示
        		   	local rewardlist={}
	            	local tipStrTb={}
	            	if sData.data.showLog then
	            		local rewardLog=sData.data.showLog
            			local rTb
    					local rTb1
            			local tipTb={}
						local tipTb1={}
		            	if rewardLog.r then
		            		rTb={}
    						local r=FormatItem(rewardLog.r)
							for k,v in pairs(r) do
    							table.insert(rTb,v)
								G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
								if tipTb[1]==nil then
									tipTb[1]=getlocal("custom_maze_reward")
	            					table.insert(tipStrTb,tipTb)
								end
    						end
		            	end
		            	if rewardLog.r1 then
		            		rTb1={}
    						local r1=FormatItem(rewardLog.r1)
							for k,v in pairs(r1) do
    							table.insert(rTb1,v)
								G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
								if tipTb1[1]==nil then
									tipTb1[1]=getlocal("chest_maze_reward")
	            					table.insert(tipStrTb,tipTb1)
								end
    						end
		            	end
						if rewardLog.s and rewardLog.s>0 then
            				local key="p3338"
            				local type="p"
            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
							table.insert(rTb,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=rewardLog.s})
							if tipTb[1]==nil then
								tipTb[1]=getlocal("custom_maze_reward")
            					table.insert(tipStrTb,tipTb)
							end
            			end
    					if rewardLog.s1 and rewardLog.s1>0 then
            				local key="p3338"
            				local type="p"
            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
							table.insert(rTb1,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=rewardLog.s1})
							if tipTb1[1]==nil then
								tipTb1[1]=getlocal("chest_maze_reward")
            					table.insert(tipStrTb,tipTb1)
							end
            			end
						if rTb and SizeOfTable(rTb)>0 then
							table.insert(rewardlist,rTb)
						end
						if rTb1 and SizeOfTable(rTb1)>0 then
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
		socketHelper:mineExploreRequest(action,varArg[1],varArg[2],nil,digCallBack)
	elseif action=="active.mineexplore.shop" then--商店购买
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.mineExplore then
	            	self:updateData(sData.data.mineExplore)
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
		socketHelper:mineExploreRequest(action,nil,nil,varArg[1],rewardCallback)
	elseif action=="active.mineexplore.report" then --获取抽奖日志
		local function logHandler(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.mineExplore then
	            	self:updateData(sData.data.mineExplore)
	            end
	            self.requestLogFlag=true
	      		if sData and sData.data and sData.data.log then
				  	if sData.data.log then
				  		for k,v in pairs(sData.data.log) do
		            		local rewards={}
		            		if v.r then
		            			local reward=FormatItem(v.r)
		            			for k,v in pairs(reward) do
		            				table.insert(rewards,v)
		            			end
		            		end
		            		local num=v.s
		            		local ts=v.ts
	        				if num and num>0 then
	            				local key="p3338"
	            				local type="p"
	            				local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
								table.insert(rewards,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num})
	            			end
	            			local digNum=v.n or 1
							local desc=getlocal("multi_excavate",{digNum})
	                		local colorTb={G_ColorWhite}
	                		local hasChest=v.k
	                		if hasChest and tonumber(hasChest)==1 then
				                desc=desc.."（"..getlocal("hide_chest").."）"
	                			colorTb={G_ColorYellowPro}
	                		end
							local record={award=rewards,time=ts,desc=desc,colorTb=colorTb}
							self:setRecord(record)
				  		end
	            	end
			        local function sortFunc(a,b)
			            if a and b and a.time and b.time then
			                return tonumber(a.time)>tonumber(b.time)
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
		socketHelper:mineExploreRequest(action,nil,nil,nil,logHandler)
	elseif action=="active.mineexplore.next" then --获取下一张地图的数据
		local function nextCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	        	local lastScore=self:getMyPoint()
	          	if sData and sData.data and sData.data.mineExplore then
	            	self:updateData(sData.data.mineExplore)
	            end
	            local score=self:getMyPoint()
	            local addScore=tonumber(score)-tonumber(lastScore)
	    		self:updateMap()
	    		local rewards={}
	    		if sData.data.s then
					local key="p3338"
					local type="p"
					local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
					table.insert(rewards,{type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=sData.data.s})
	    		end
	    		if callback then
	    			callback(self.map,nil,addScore,rewards)
	    		end
	        end
	    end
		socketHelper:mineExploreRequest(action,nil,nil,nil,nextCallBack)
	end
end

function acMineExploreVoApi:getSelfRank()
	local vo=self:getAcVo()
	if vo and vo.rank then
		return vo.rank
	end
	return 0
end

--item商店兑换的宝箱
function acMineExploreVoApi:sendRewardNotice(rtype,item)
    local playerName=playerVoApi:getPlayerName()
    local activityName=getlocal("activity_mineExplore_title")
    local message
    if rtype==1 then
    	message={key="activity_mineExplore_notice1",param={playerName,activityName}}
	elseif rtype==2 then
		if item and item.name then
    		message={key="activity_mineExplore_notice2",param={playerName,activityName,item.name}}
		end
    end
    if message then
    	local paramTab={}
    	paramTab.functionStr="mineExplore"
        paramTab.addStr="goTo_see_see"
    	chatVoApi:sendSystemMessage(message,paramTab)
    end
end

function acMineExploreVoApi:getRequestLogFlag()
	return self.requestLogFlag
end

function acMineExploreVoApi:tick()

end

function acMineExploreVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acMineExploreVoApi:clearAll()
	self.isTodayFlag=true
	self.recordList=nil
	self.map=nil
	self.emap=nil
	self.requestLogFlag=false
	self.rankLimit=nil
	self.vo=nil
end