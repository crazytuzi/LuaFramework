--百花齐放
--author: ym
acBhqfTaskDialog={}

function acBhqfTaskDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acBhqfTaskDialog:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initTask()
	return self.bgLayer
end

function acBhqfTaskDialog:initTask()
	local function touchLuaSpr( ... )
	end
	local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touchLuaSpr)
    bgSp:setAnchorPoint(ccp(0,0))
    bgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-203))
    bgSp:setPosition(ccp(15,35))
    self.bgLayer:addChild(bgSp,1)

	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 213),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(20,40)
	self.bgLayer:addChild(self.tv,1)
	self.tv:setMaxDisToBottomOrTop(80)
end

function acBhqfTaskDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local acVo=acBhqfVoApi:getAcVo()
		if acVo and acVo.activeCfg and acVo.activeCfg.collectReward then
			return #acVo.activeCfg.collectReward
		end
		return 0
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 60,150)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cellSize=CCSizeMake(G_VisibleSizeWidth - 60,150)
		local acVo=acBhqfVoApi:getAcVo()
		if not acVo then
			do return cell end
		end
		
		-- local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("acZnqd2017Bg2.png",CCRect(40,15,10,10),function ( ... )end)
		-- cellBg:setContentSize(cellSize)
		-- cellBg:setPosition(cellSize.width/2,cellSize.height/2)
		-- cell:addChild(cellBg)
		-- local rewardIndex=#self.rechargeCfg - idx
		-- local rechargeCfg=self.rechargeCfg[rewardIndex]
		-- local titleLb=GetTTFLabel(getlocal("daily_award_tip_3",{rechargeCfg[1]}),25,true)

		
		local tid = idx + 1
		local tType,str,cond = acBhqfVoApi:getTask(tid)
		local descParm = {}
		if tType == 1 then
			local wnum = SizeOfTable(acVo.words or {})
			if tonumber(str) and wnum > tonumber(str) then
				descParm = {str,str}
			else
				descParm = {wnum,str}
			end
		else
			descParm = {str}
		end
		local titleLb=GetTTFLabel(getlocal("activity_bhqf_task"..tType,descParm),21,true)
		titleLb:setColor(G_ColorYellowPro)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(15,cellSize.height - 20)
		cell:addChild(titleLb,1)
		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),function()end)
		titleBg:setContentSize(CCSizeMake(cellSize.width - 100,33))
		titleBg:setAnchorPoint(ccp(0,0.5))
		titleBg:setPosition(0,cellSize.height - 20)
		cell:addChild(titleBg)
		local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake(cellSize.width-10,2))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5,0.5))
        lineSp:setPosition(cellSize.width/2,5)
        cell:addChild(lineSp)

        local iconpy=60
		local rewardTaskCfg=acVo.activeCfg.collectReward[tid][2]
		local rewardTb=FormatItem(rewardTaskCfg,true,true)
		local rewardNum=#rewardTb
		for i=1,rewardNum do
			local reward=rewardTb[i]
			local function showNewReward()
				G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
				return false
			end
			local icon,scale=G_getItemIcon(reward,80,true,self.layerNum,showNewReward)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(20 + 90*(i - 1),iconpy)
			cell:addChild(icon)
			local numLb=GetTTFLabel("×"..FormatNumber(reward.num),22)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width - 5,5)
			icon:addChild(numLb)
			numLb:setScale(0.9/scale)
			-- -- if(colorTb and (colorTb[i] or colorTb[tostring(i)]))then
			-- -- 	local colorStr=colorTb[i] or colorTb[tostring(i)]
			-- -- 	local flickerIdxTb={y=3,b=1,p=2,g=4}
			-- -- 	local color=flickerIdxTb[colorStr]
			-- 	local flickerIdxTb={"y","b","p","g"}
			-- 	local color=(idx%4)+1
			-- 	local colorStr=flickerIdxTb[(idx%4)+1]
			-- 	G_addRectFlicker2(icon,1.15,1.15,color,colorStr)
			-- -- end
		end

		local function onGetReward(tag,object)
			if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

			if tag then
				self:getReward(tag)
			end
		end
		local status = acBhqfVoApi:getTaskState(tid)
		if(status==0)then
			local lb=GetTTFLabel(getlocal("noReached"),25)
			lb:setAnchorPoint(ccp(0.5,0.5))
			lb:setPosition(cellSize.width - 70,iconpy)
			cell:addChild(lb)
		elseif(status==1)then
			local rewardItem=GetButtonItem("yh_taskReward.png","yh_taskReward_down.png","yh_taskReward_down.png",onGetReward,tid,nil,0)
			rewardItem:setAnchorPoint(ccp(0.5,0.5))
			rewardItem:setScale(1.1)
			local rewardMenu=CCMenu:createWithItem(rewardItem)
			rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
			rewardMenu:setPosition(cellSize.width - 70,iconpy)
			cell:addChild(rewardMenu)
		else
			local lb=GetTTFLabel(getlocal("activity_hadReward"),25)
			lb:setColor(G_ColorGray)
			lb:setAnchorPoint(ccp(0.5,0.5))
			lb:setPosition(cellSize.width - 70,iconpy)
			cell:addChild(lb)
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function acBhqfTaskDialog:getReward(tid)
	local function taskCallback(fn,data)
	    local ret,sData=base:checkServerData(data)
	    if ret==true then
	    	local acVo=acBhqfVoApi:getAcVo()
	        local rewardTaskCfg=acVo.activeCfg.collectReward[tid][2]
			local reward=FormatItem(rewardTaskCfg)
			for k,v in pairs(reward) do
                G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
            end
            G_showRewardTip(reward,true)

	        if sData and sData.data then
	        	if sData.data.bhqf then
	        		acBhqfVoApi:updateData(sData.data.bhqf)
	        	end
	        end
	        self:refreshUI()

	        --聊天公告
	        local tType=acVo.activeCfg.collectTask[tid][1]
	        if tType==3 then
                -- local message={key="activity_bhqf_chat",param={playerVoApi:getPlayerName(),getlocal("activity_bhqf_title"),rewardStr}}
                -- chatVoApi:sendSystemMessage(message)
                local rewardStr=G_showRewardTip(reward,false,true)
                local sysMsg
                if acBhqfVoApi and acBhqfVoApi:getVersion()==2 then
                	sysMsg = {key="activity_bhqf_chat_v2",param={playerVoApi:getPlayerName(),getlocal("activity_bhqf_title"),rewardStr}}
                else
                	sysMsg = {key="activity_bhqf_chat",param={playerVoApi:getPlayerName(),getlocal("activity_bhqf_title"),rewardStr}}
                end
                local paramTab={}
                paramTab.functionStr="bhqf"
                paramTab.addStr="goTo_see_see"
                chatVoApi:sendSystemMessage(sysMsg,paramTab)
            end
		end
	end
	local status = acBhqfVoApi:getTaskState(tid)
	if status == 1 then
		socketHelper:activeBhqfTask(tid,taskCallback)
	end
end

function acBhqfTaskDialog:refreshUI()
	if self and self.tv and tolua.cast(self.tv,"CCTableView") then
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acBhqfTaskDialog:dispose()
	self.tv=nil
end