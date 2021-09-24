acTccxVoApi = {
	name=nil,
    rewardLog=nil,
}

function acTccxVoApi:setActiveName(name)
	self.name=name
end

function acTccxVoApi:getActiveName()
	return self.name or "tccx"
end

function acTccxVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acTccxVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acTccxVoApi:getTimeStr()
	local timeStr=""
	local vo=self:getAcVo()
	if vo then
		timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	end
	return timeStr
end

function acTccxVoApi:canReward(activeName)

	return false
end
function acTccxVoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acTccxVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end
function acTccxVoApi:getActiveCfg(activeName)
	local vo=self:getAcVo(activeName)
	if vo and vo.activeCfg then
		return vo.activeCfg
	end
	return {}
end


function acTccxVoApi:getPoint()
	local vo=self:getAcVo()
	if vo and vo.myPoint then
		return vo.myPoint
	end
	return 0
end

function acTccxVoApi:getRewardLog()
    return self.rewardLog
end

function acTccxVoApi:showRewardKu(title,layerNum,reward,desStr,titleColor)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenyearSmallDialog"

    local height=540
    local tvHeight=250
    local rewardTb=FormatItem(reward[1])
    if SizeOfTable(rewardTb)<5 then
    	height=height-125
    	tvHeight=125
    end
    acOpenyearSmallDialog:showOpenyearRewardDialog("TankInforPanel.png",CCSizeMake(550,height),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,layerNum+1,reward,title,desStr,tvHeight,titleColor)
end

function acTccxVoApi:socketTccx2017(refreshFunc,cmd,tid,free)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
            if sData and sData.data and sData.data[self.name] then
                if sData.data[self.name].r==nil then
                    sData.data[self.name].r={}
                end
                self:updateSpecialData(sData.data[self.name])
            end
            local pointTb={}
            local tipReward
            if sData and sData.data and sData.data.repoint then
                pointTb=sData.data.repoint
            end
			if sData and sData.data and sData.data.log then
                local logData=sData.data.log
                if cmd=="active.tuichenchuxin.getlog" then
                    self.rewardLog={}
                    local sortTb={}
                    local acCfg=self:getActiveCfg()
                    if acCfg and acCfg.showList then
                    	local tmpTb=FormatItem(acCfg.showList,nil,true)
                    	for k,v in pairs(tmpTb) do
                    		if sortTb[v.type]==nil then
                    			sortTb[v.type]={}
                    		end
                    		sortTb[v.type][v.key]={num=v.num,index=v.index}
                    	end
                    end
                    for k,v in pairs(logData) do
                        local type=v[1]
                        local reward=FormatItem(G_clone(v[2] or {}))
                        local time=v[3]
                        local point=v[4] or 0
                        local lData={type=type,reward=reward,time=time,point=point}
                        if sortTb and lData.reward then
                        	for m,item in pairs(lData.reward) do
                        		local type,key=item.type,item.key
	                        	if type and key and sortTb[type] and sortTb[type][key] and sortTb[type][key].index then
	                        		item.index=sortTb[type][key].index
	                        	end
                        	end
                        	local function sortFunc1(a,b)
                            	if a.index and b.index then
                            		return a.index<b.index
	                            end
                            end
                            table.sort(lData.reward,sortFunc1)
                        end
                        table.insert(self.rewardLog,lData)
                        -- if #self.rewardLog>0 then
                        --     local function sortFunc(a,b)
                        --     	return a.time>b.time
                        --     end
                        --     table.sort(self.rewardLog,sortFunc)
                        -- end
                    end
                else
                    local type=logData[1]
                    local reward=FormatItem(G_clone(logData[2] or {}))
                    local time=logData[3]
                    local point=0
                    tipReward=reward
                    if pointTb then
                    	for k,v in pairs(pointTb) do
                    		if v then
                    			point=point+v
                    		end
                    	end
                    end
                    if self.rewardLog then
                        local lData={type=type,reward=reward,time=time,point=point}
                        if sortTb and lData.reward then
	                        for m,item in pairs(lData.reward) do
                        		local type,key=item.type,item.key
	                        	if type and key and sortTb[type] and sortTb[type][key] and sortTb[type][key].index then
	                        		item.index=sortTb[type][key].index
	                        	end
                        	end
                        	local function sortFunc1(a,b)
                            	if a.index and b.index then
                            		return a.index<b.index
	                            end
                            end
                            table.sort(lData.reward,sortFunc1)
                        end
                        table.insert(self.rewardLog,lData)
                        if #self.rewardLog>0 then
                            local function sortFunc(a,b)
                                return a.time>b.time
                            end
                            table.sort(self.rewardLog,sortFunc)
                            if #self.rewardLog>10 then
                                table.remove(self.rewardLog,11)
                            end
                        end
                    end
                end
			end
			local rewardItem
			if sData and sData.data and sData.data.reward then
                rewardItem={}
                for k,v in pairs(sData.data.reward) do
                    local item=FormatItem(v)
                    if item[1] then
                        rewardItem[k]=item[1]
                    end
                    for m,n in pairs(item) do
                        G_addPlayerAward(n.type,n.key,n.id,n.num,nil,true)
                    end
                end
			end
			if refreshFunc then
				refreshFunc(rewardItem,pointTb,tipReward)
			end
		end
	end
	socketHelper:activityTccx(callBack,cmd,tid,free)
end

function acTccxVoApi:showRewardDialog(rewardlist,layerNum,fqNum)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,{award=v})                        
	end
	local rewardPromptStr=nil
	if fqNum and fqNum~=0 then
		rewardPromptStr=getlocal("activity_openyear_fetFQNum_des",{fqNum})
	end
	local function callBack()
		G_showRewardTip(rewardlist)
	end
	acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,nil,content,false,layerNum+1,nil,getlocal("confirm"),callBack,nil,nil,nil,true,false,nil,true)
end

function acTccxVoApi:getBn()
	local vo=self:getAcVo()
	if vo and vo.bn then
		return vo.bn
	end
	return 0
end

function acTccxVoApi:refreshClear()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.useFree=0
end

function acTccxVoApi:addBuffScuess(activeName)
	local acVo = self:getAcVo(activeName)
	if activityVoApi:isStart(acVo)==true then
		return acVo.activeCfg.value1
	end
	return 0
end

function acTccxVoApi:getShop(activeName)
	local vo=self:getAcVo(activeName)
	if vo and vo.activeCfg then
		return vo.activeCfg.shop
	end
	return {}
end

function acTccxVoApi:getSortShop(activeName)
	local vo=self:getAcVo(activeName)
	local shop=vo.activeCfg.shop
	local buyLog=vo.b or {}
	local myPoint=self:getPoint()
	local trueShop={}
	-- RemoveFirstChar(prop.key)
	for k,v in pairs(shop) do
		local index=tonumber(RemoveFirstChar(k))
		local limit=v.limit
		local buyNum=buyLog[k] or 0
		if buyNum>=limit then
			index=index+10000
		elseif myPoint<v.needPt then
			index=index+1000
		end
		local subTb={index=index,id=k}
		table.insert(trueShop,subTb)
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(trueShop,sortFunc)


	return trueShop
end

function acTccxVoApi:getCount()
	local count=0
	local acVo=self:getAcVo()
	if acVo then
		local openR=acVo.openR or {}
	    count=SizeOfTable(openR)
	end
	return count
end

function acTccxVoApi:getAllCost()
    local acCfg=self:getActiveCfg()
    if acCfg==nil then
        do return 0 end
    end
    local costGems=acCfg.cost1
    local discount=acCfg.cost2 or {}
    local count=self:getCount() or 0
    local totalCount=SizeOfTable(discount)
    local leftCount=totalCount-count
    local allCostGems=0
    if count<totalCount then
        allCostGems=math.ceil(costGems*discount[leftCount]*leftCount)
    end
    return allCostGems
end

function acTccxVoApi:getShowReward()
	local tb={}
	local count=0
	local acVo=self:getAcVo()
	if acVo then
		local rewardTb=acVo.rd or {}
		if rewardTb then
			for k,v in pairs(rewardTb) do
				tb[k]=0
			end
		end
		local openR=acVo.openR or {}
		if openR then
			for k,v in pairs(openR) do
				if v and rewardTb[v] then
					local itemTb=FormatItem(rewardTb[v])
					if itemTb and itemTb[1] then
						tb[v]=itemTb[1]
					end
				end
			end
		end
	end
	return tb
end

function acTccxVoApi:getBigReward()
	local acCfg=self:getActiveCfg()
	local acVo=self:getAcVo()
	if acVo and acCfg and acCfg.color then
		local brTb=acVo.br or {}
		local bigTb=G_clone(acCfg.color) or {}
		local bigReward=FormatItem(bigTb,nil,true) or {}
		if bigReward then
			for k,v in pairs(bigReward) do
                v.num=0
				if brTb and brTb["c"..k] then
					v.num=tonumber(brTb["c"..k])
				end
			end
		end
		return bigReward
	end
	return {}
end

function acTccxVoApi:getIsFree()
    local free=false
    local lastTime=0
    local acVo=self:getAcVo()
    if acVo and acVo.lastTime then
        lastTime=acVo.lastTime
    end
    if G_isToday(lastTime)==true then
    	if acVo.useFree and acVo.useFree>0 then
    	else
    		free=true
    	end
    else
        free=true
    end
    return free
end

function acTccxVoApi:checkTab2Tip()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		local myPoint=acVo.myPoint or 0
		local buyLog=acVo.b or {}
		if myPoint>0 then
			for k,v in pairs(acVo.activeCfg.shop) do
				if v.needTell then
					local buyNum=buyLog[k] or 0
					if buyNum>=v.limit then
						return false
					end
					if v.needTell and myPoint>=v.needPt then
						return true
					end
				end
			end
		end
	end
	return false
end


function acTccxVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acTccxVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end


function acTccxVoApi:clearAll()
	self.name=nil
    self.rewardLog=nil
end


