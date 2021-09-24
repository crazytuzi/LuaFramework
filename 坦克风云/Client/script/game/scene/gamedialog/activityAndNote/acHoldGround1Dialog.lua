
acHoldGround1Dialog=commonDialog:new()

function acHoldGround1Dialog:new()
    local nc=commonDialog:new()
    setmetatable(nc,self)
    self.__index=self
	-- self.loginDay=1
	self.isToday=true
	self.tvHeight1=125*0.8
	return nc
end

--设置对话框里的tableView
function acHoldGround1Dialog:initTableView()
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))

	local acVo=acHoldGround1VoApi:getAcVo()

	local timeLabel=GetTTFLabel(activityVoApi:getActivityTimeStr(acVo.st,acVo.et),25)
	timeLabel:setAnchorPoint(ccp(0.5,0.5))
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-115))
    self.bgLayer:addChild(timeLabel)
	timeLabel:setColor(G_ColorYellowPro)

	-- local descLabel=GetTTFLabelWrap(getlocal("activity_holdGround1_desc"),25,CCSizeMake(self.bgLayer:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	-- descLabel:setAnchorPoint(ccp(0,0.5))
 --    descLabel:setPosition(ccp(20,self.bgLayer:getContentSize().height-190))
 --    self.bgLayer:addChild(descLabel)
	-- descLabel:setColor(G_ColorYellowPro)

	local function callBack1(...)
        return self:eventHandler1(...)
    end
    local hd= LuaEventHandler:createHandler(callBack1)
    self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,self.tvHeight1),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv1:setPosition(ccp(0,self.bgLayer:getContentSize().height-255))
    self.bgLayer:addChild(self.tv1,2)
    self.tv1:setMaxDisToBottomOrTop(50)


	local function tipTouch()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local sd=smallDialog:new()
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,{" ",getlocal("activity_holdGround_tip_3")," ",getlocal("activity_holdGround_tip_2")," ",getlocal("activity_holdGround_tip_1")," "},25,{nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil})
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,12,nil,nil)
    local spScale=1
    tipItem:setScale(spScale)
    local tipMenu = CCMenu:createWithItem(tipItem)
    tipMenu:setPosition(ccp(G_VisibleSizeWidth-tipItem:getContentSize().width/2*spScale-20,self.bgLayer:getContentSize().height-175))
    tipMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(tipMenu,1)

	local function rewardHandler(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		PlayEffect(audioCfg.mouseClick)

		local acVo=acHoldGround1VoApi:getAcVo()
        local num=acVo.rewardNum+1

		local function rewardCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data then
                    acHoldGround1VoApi:afterGetReward(sData.ts)

                    local acCfg=acHoldGround1VoApi:getAcCfg()
			        local awardCfg
			    	if acCfg and acCfg.awardCfg then
			    		awardCfg=acCfg.awardCfg
			    		local award=awardCfg[num] or {}
			    		for k,v in pairs(award) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
						G_showRewardTip(award,true)	
			    	end

					if self then
						if self.tv then
							local recordPoint = self.tv:getRecordPoint()
							self.tv:reloadData()
							self.tv:recoverToRecordPoint(recordPoint)
						end
						if self.rewardBtn then
							self.rewardBtn:setEnabled(false)
							local lb=tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF")
							lb:setString(getlocal("activity_hadReward"))
						end
					end
                end
            end
        end
		socketHelper:activeHoldground1(num,rewardCallback)
	end
	self.rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",rewardHandler,nil,getlocal("daily_scene_get"),25,11);
	-- self.rewardBtn:setPosition(0,0)
	-- self.rewardBtn:setAnchorPoint(CCPointMake(0,0))
		 
	local rewardMenu = CCMenu:createWithItem(self.rewardBtn)
	rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,self.rewardBtn:getContentSize().height/2+20))
	self.bgLayer:addChild(rewardMenu,3)

	if acHoldGround1VoApi:checkCanReward() then
		self.rewardBtn:setEnabled(true)
		local lb=tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF")
		lb:setString(getlocal("daily_scene_get"))
	else
		self.rewardBtn:setEnabled(false)
		local lb=tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF")
		lb:setString(getlocal("activity_hadReward"))
	end

	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-180-80-100),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(19,20+80))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(140)

end

function acHoldGround1Dialog:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.cellHeight==nil then
        	local descLabel=GetTTFLabelWrap(getlocal("activity_holdGround1_desc"),25,CCSizeMake(self.bgLayer:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            self.cellHeight=descLabel:getContentSize().height
            if self.cellHeight<self.tvHeight1 then
            	self.cellHeight=self.tvHeight1
            end
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-140,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local descLabel=GetTTFLabelWrap(getlocal("activity_holdGround1_desc"),25,CCSizeMake(self.bgLayer:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        if self.cellHeight==nil then
            self.cellHeight=descLabel:getContentSize().height
            if self.cellHeight<self.tvHeight1 then
            	self.cellHeight=self.tvHeight1
            end
        end
        if descLabel:getContentSize().height<=self.tvHeight1 then
        	descLabel=GetTTFLabelWrap(getlocal("activity_holdGround1_desc"),25,CCSizeMake(self.bgLayer:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        	descLabel:setAnchorPoint(ccp(0,0.5))
		    descLabel:setPosition(ccp(20,self.cellHeight/2))
		else
			descLabel=GetTTFLabelWrap(getlocal("activity_holdGround1_desc"),25,CCSizeMake(self.bgLayer:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        	descLabel:setAnchorPoint(ccp(0,1))
		    descLabel:setPosition(ccp(20,self.cellHeight-10))
        end
		
	    cell:addChild(descLabel)
		descLabel:setColor(G_ColorYellowPro)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acHoldGround1Dialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
    	local acCfg=acHoldGround1VoApi:getAcCfg()
    	if acCfg and acCfg.awardCfg then
    		local awardCfg=acCfg.awardCfg
    		if awardCfg then
    			return SizeOfTable(awardCfg)
    		end
    	end
        return 0
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,150)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local acCfg=acHoldGround1VoApi:getAcCfg()
        local awardCfg
    	if acCfg and acCfg.awardCfg then
    		awardCfg=acCfg.awardCfg
    		
    	end
    	if acCfg==nil or awardCfg==nil or SizeOfTable(awardCfg)==0 then
			do return end
		end

		award=awardCfg[idx+1]
		local flickCfg=acCfg.flick or {}
		local acVo=acHoldGround1VoApi:getAcVo()
		
		local sprieBg=CCSprite:createWithSpriteFrameName("7daysBg.png")
		sprieBg:setAnchorPoint(ccp(0,0))
        sprieBg:setPosition(ccp(0,10))
        cell:addChild(sprieBg)

		local numLabel=GetTTFLabel(getlocal("signDayNum",{idx+1}),30)
		numLabel:setAnchorPoint(ccp(0.5,0.5))
        -- numLabel:setPosition(ccp(15,sprieBg:getContentSize().height-25))
        numLabel:setPosition(ccp(75-10,sprieBg:getContentSize().height/2))
        sprieBg:addChild(numLabel,1)
		numLabel:setColor(G_ColorGreen)

		local function isShowInfo()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				return true
			else
				return false
			end
		end
		local size=85
		for k,v in pairs(award) do
			local icon
			-- icon,iconScale=G_getItemIcon(v,size,true,self.layerNum+1,isShowInfo)
			icon,iconScale=G_getItemIcon(v,size,false,self.layerNum+1,isShowInfo)


			icon:ignoreAnchorPointForPosition(false)
	       --  icon:setAnchorPoint(ccp(0,0))
	      	-- icon:setPosition(ccp(10+(k-1)*85,12))
	      	icon:setAnchorPoint(ccp(0.5,0.5))
	      	icon:setPosition(ccp((k-1)*(size+10)+size/2+150-20,sprieBg:getContentSize().height/2))
			icon:setIsSallow(false)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			sprieBg:addChild(icon,1)
			icon:setTag(k)

			for m,n in pairs(flickCfg) do
				if n.type==v.type and n.key==v.key and n.num==v.num then
					G_addRectFlicker(icon,1.4,1.4)
				end
			end
		
			if tostring(v.name)~=getlocal("honor") then
				local numLabel=GetTTFLabel("x"..v.num,25)
		        --numLabel:setColor(G_ColorGreen)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(icon:getContentSize().width-5,5)
				icon:addChild(numLabel,1)
				numLabel:setScale(1/iconScale*0.8)
			end
		end
		
		local canReward=acHoldGround1VoApi:canRewardById(idx+1)
		if canReward==true then
		    local lightSp = CCSprite:createWithSpriteFrameName("7daysLight.png")
	        lightSp:setPosition(getCenterPoint(sprieBg))
	        sprieBg:addChild(lightSp)
		end

		if acVo.rewardNum>=idx+1 then
			local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
			rightIcon:setAnchorPoint(ccp(0.5,0.5))
			rightIcon:setPosition(ccp(self.bgLayer:getContentSize().width-120+30,sprieBg:getContentSize().height/2))
			sprieBg:addChild(rightIcon,1)
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

function acHoldGround1Dialog:tick()
	local vo=acHoldGround1VoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    local acVo=acHoldGround1VoApi:getAcVo()
	if self and acVo and acVo.lastTime then
		local lastTime=acVo.lastTime or 0
		if self.isToday~=G_isToday(lastTime) then
			if self.tv then
				local recordPoint = self.tv:getRecordPoint()
				self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)
			end
			self.isToday=G_isToday(lastTime)
		end
	end

	if self and self.rewardBtn then
		if acHoldGround1VoApi:checkCanReward() then
			self.rewardBtn:setEnabled(true)
			local lb=tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF")
			lb:setString(getlocal("daily_scene_get"))
		else
			self.rewardBtn:setEnabled(false)
			local lb=tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF")
			lb:setString(getlocal("activity_hadReward"))
		end
	end

end

--用户处理特殊需求,没有可以不写此方法
function acHoldGround1Dialog:doUserHandler()

end

function acHoldGround1Dialog:dispose()
	-- self.loginDay=nil
	self.isToday=nil
end




