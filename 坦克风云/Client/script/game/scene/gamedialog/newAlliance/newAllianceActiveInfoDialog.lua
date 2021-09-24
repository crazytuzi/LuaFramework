-- @Author hj
-- @Date 2018-11-15
-- @Description 军团活跃积分板子

newAllianceActiveInfoDialog = {}

function newAllianceActiveInfoDialog:new(layer)
	-- body
	local nc = {
		layerNum = layer,
		switchFlag = false,
		pageList = {},
		midPos = ccp(290,160),
		timeInterval = 0.5,
		outPos = {ccp(-300,160),
				  ccp(880,160),
		},
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function newAllianceActiveInfoDialog:init( ... )
	-- body
	self.bgLayer=CCLayer:create()
	self:initUp()
	self:initDown()
	return self.bgLayer
end

function newAllianceActiveInfoDialog:initUp( ... )

    local alliance=allianceVoApi:getSelfAlliance()

    if alliance then

    	self.curIndex = alliance.alevel

    	local upSp = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png",CCRect(18,21,1,1),function ( ... ) end)
		upSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,350))
	    upSp:setAnchorPoint(ccp(0.5,1))
	    upSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
		self.bgLayer:addChild(upSp)

		local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	    titleBg:setAnchorPoint(ccp(0.5,1))
	    titleBg:setPosition(upSp:getContentSize().width/2,upSp:getContentSize().height-20)
	    upSp:addChild(titleBg)

	    -- 军团活跃等级
	    local activeLevelStr = getlocal("alliance_activie")..getlocal("fightLevel",{alliance.alevel})
	    local allianceActiveLv = GetTTFLabel(activeLevelStr,30)
	    allianceActiveLv:setColor(G_ColorYellowPro2)
	    allianceActiveLv:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)
	    titleBg:addChild(allianceActiveLv)

	    -- 进度条框
		local progressBg = CCSprite:createWithSpriteFrameName("VipIconYellowBarBg.png")
		progressBg:setAnchorPoint(ccp(0.5,0.5))
		progressBg:setPosition(ccp(upSp:getContentSize().width/2,upSp:getContentSize().height-20-titleBg:getContentSize().height-57))
		upSp:addChild(progressBg)

	    local nowPoint = alliance.apoint
	    local levelDown,levelUp,nowValue,maxValue = self:getActivePointDetail(alliance.apoint)

		local lDLabel = GetTTFLabel(getlocal("fightLevel",{levelDown}),22,true)
		lDLabel:setAnchorPoint(ccp(0,0))
		lDLabel:setPosition(ccp(2,progressBg:getContentSize().height))
		self.lDLabel = lDLabel
		progressBg:addChild(lDLabel)
		
		local str =""
		if levelUp < 999 then
			str = getlocal("fightLevel",{levelUp})
		end
		local lULabel = GetTTFLabel(str,22,true)
		lULabel:setAnchorPoint(ccp(1,0))
		lULabel:setPosition(ccp(progressBg:getContentSize().width-2,progressBg:getContentSize().height))
		self.lULabel = lULabel
		progressBg:addChild(lULabel)

	    -- 进度条
		local activeBarSp = CCSprite:createWithSpriteFrameName("VipIconYellowBar.png")
		local progressTimer = CCProgressTimer:create(activeBarSp)
		progressTimer:setAnchorPoint(ccp(0.5,0.5))
		-- kCCProgressTimerTypeBar 条形进度条
		-- kCCProgressTimerTypeRadial 扇形进度条 
		progressTimer:setType(kCCProgressTimerTypeBar)
		-- true 按照百分比隐藏  false 按照百分比显示
		progressTimer:setReverseProgress(false) 
		-- 开始的锚点
		progressTimer:setMidpoint(ccp(0,0.5))
		-- 只针对条形进度条，进度条x,y的变化率
		progressTimer:setBarChangeRate(ccp(1,0))
		-- 设置比率
		-- nowValue/maxValue*100
		progressTimer:setPercentage(nowValue/maxValue*100)
		progressTimer:setPosition(ccp(upSp:getContentSize().width/2,upSp:getContentSize().height-20-titleBg:getContentSize().height-57))
		self.progressTimer = progressTimer
		upSp:addChild(progressTimer)

		local pointStr = nowValue.."/"..maxValue
		local pointLabel = GetTTFLabel(pointStr,25,true)
		pointLabel:setAnchorPoint(ccp(0.5,0.5))
		pointLabel:setPosition(getCenterPoint(progressBg).x,getCenterPoint(progressBg).y+2)
		self.pointLabel = pointLabel
		progressTimer:addChild(pointLabel)

		local activeTip = ""
        for k,v in pairs(allianceActiveCfg.allianceAdelPoint) do
        	if k and v then
        		activeTip=activeTip..getlocal("alliance_activie_deductActive",{k,v}).."\n"
        	end
        end

		local function touchTip()
			local tabStr={getlocal("alliance_activie_tip1"),activeTip,getlocal("alliance_activie_tip2"),getlocal("alliance_activie_tip3"),getlocal("alliance_activie_tip4")}
			require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
			tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
		end
		G_addMenuInfo(upSp,self.layerNum,ccp(upSp:getContentSize().width-45,upSp:getContentSize().height-20-titleBg:getContentSize().height-57),{},nil,nil,28,touchTip,true)
		
		local removeNode=CCClippingNode:create()
		removeNode:setContentSize(CCSizeMake(upSp:getContentSize().width-40,180))
		removeNode:setAnchorPoint(ccp(0.5,1))
	    removeNode:setPosition(ccp(upSp:getContentSize().width/2,upSp:getContentSize().height-20-titleBg:getContentSize().height-20-activeBarSp:getContentSize().height-30))
	    upSp:addChild(removeNode)

		local stencil=CCDrawNode:getAPolygon(CCSizeMake(upSp:getContentSize().width-60,180),1,1)
		stencil:setPosition(ccp(10,0))
		removeNode:setStencil(stencil)

		local len = SizeOfTable(allianceActiveCfg.allianceActiveReward)
		local strSize = 25
		if G_isAsia() == false then
			strSize = 22
		end
		local descBg
		
		for i=1,len do

			local function nilFunc( ... )
				-- body
			end

			descBg = LuaCCScale9Sprite:createWithSpriteFrameName("newAlliance_desc1.png",CCRect(198,24,2,2),nilFunc)
			descBg:setContentSize(CCSizeMake(upSp:getContentSize().width-60,160))
			descBg:setAnchorPoint(ccp(0.5,1))
			removeNode:addChild(descBg)
			self.pageList[i] = descBg

			local titleLabel = GetTTFLabel(getlocal("alliance_activie_Welfare",{i}),25,true)
			titleLabel:setColor(G_ColorYellowPro2)
			titleLabel:setAnchorPoint(ccp(0.5,0))
			titleLabel:setPosition(ccp(descBg:getContentSize().width/2,descBg:getContentSize().height-18))
			descBg:addChild(titleLabel)
			
			local arowStr =""
			
	    	if alliance.alevel == i then
	    		arowStr="SlotArowRed.png"
	    	else
	    		arowStr="SlotArow.png"
	    	end
			
			-- 科技点一倍加成
			if allianceActiveCfg.ActiveDonateCount[i]==1 then
				
				local leftArrow = CCSprite:createWithSpriteFrameName(arowStr)
				leftArrow:setAnchorPoint(ccp(0.5,0.5))
	    		leftArrow:setPosition(ccp(25,descBg:getContentSize().height/2))
	    		descBg:addChild(leftArrow)
	    		leftArrow:setRotation(-90)

				local descLabel
				if allianceActiveCfg.allianceActiveReward[i]==0 then
					-- 无资源收集加成
					descLabel=GetTTFLabelWrap(getlocal("alliance_activie_noReward"),strSize,CCSizeMake(descBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				else
					-- 有资源收集加成
					descLabel=GetTTFLabelWrap(getlocal("alliance_activie_collectResource",{allianceActiveCfg.allianceActiveReward[i]*100}),strSize,CCSizeMake(descBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				end
	    		descLabel:setAnchorPoint(ccp(0,0.5))
	    		descLabel:setPosition(ccp(50,descBg:getContentSize().height/2))
	    		if i == alliance.alevel then
	    			descLabel:setColor(G_ColorYellow)
	    		end 
	    		descBg:addChild(descLabel)

			else
				-- 科技点多倍加成
				local leftArrow1 = CCSprite:createWithSpriteFrameName(arowStr)
	    		leftArrow1:setPosition(ccp(25,descBg:getContentSize().height/4*3-12))
	    		descBg:addChild(leftArrow1)
	    		leftArrow1:setRotation(-90)
	    		local desc1 = GetTTFLabelWrap(getlocal("alliance_activie_collectResource",{allianceActiveCfg.allianceActiveReward[i]*100}),strSize,CCSizeMake(descBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    		desc1:setAnchorPoint(ccp(0,0.5))
	    		desc1:setPosition(50,descBg:getContentSize().height/4*3-12)
	    		descBg:addChild(desc1)

	    		local leftArrow2 = CCSprite:createWithSpriteFrameName(arowStr)
	    		leftArrow2:setPosition(ccp(25,descBg:getContentSize().height/4+10))
	    		descBg:addChild(leftArrow2)
	    		leftArrow2:setRotation(-90)
	    		local desc2 = GetTTFLabelWrap(getlocal("alliance_activie_donate",{allianceActiveCfg.ActiveDonateCount[i]}),strSize,CCSizeMake(descBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    		desc2:setAnchorPoint(ccp(0,0.5))
	    		desc2:setPosition(50,descBg:getContentSize().height/4+10)
	    		descBg:addChild(desc2)
			end

			local descLabel = GetTTFLabelWrap("",22,CCSizeMake(upSp:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			descLabel:setAnchorPoint(ccp(0.5,1))
			descLabel:setPosition(ccp(descBg:getContentSize().width/2,descBg:getContentSize().height-5-titleLabel:getContentSize().height-5))
			descBg:addChild(descLabel)

			if i ~= alliance.alevel then
				descBg:setPosition(ccp(9999,removeNode:getContentSize().height))
			else
				descBg:setPosition(ccp(removeNode:getContentSize().width/2,removeNode:getContentSize().height-20))
			end

		end
		

		local function rightPageHandler()
			if self.switchFlag==true then
	    		do return end
			end
			if G_checkClickEnable()==false then
	    	do
	        	return
	    	end
			else
	    		base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:switchHandeler(1)
		end

		local function leftPageHandler()
	        if self.switchFlag==true then
	            do return end
	        end
	        if G_checkClickEnable()==false then
	    	do
	        	return
	    	end
			else
	    		base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:switchHandeler(-1)
		end

		local arrowCfg={
			  {startPos=ccp(20,100),targetPos=ccp(10,100),callback=leftPageHandler,angle=0},
			  {startPos=ccp(upSp:getContentSize().width-20,100),targetPos=ccp(upSp:getContentSize().width-10,100),callback=rightPageHandler,angle=180}
		}

		for i=1,2 do

	        local cfg=arrowCfg[i]
	        local arrowBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",function () end,11,nil,nil)
	        arrowBtn:setRotation(cfg.angle)
	        local arrowMenu=CCMenu:createWithItem(arrowBtn)
	        arrowMenu:setAnchorPoint(ccp(0.5,0.5))
	        arrowMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	        arrowMenu:setPosition(cfg.startPos)
	        upSp:addChild(arrowMenu,3)

	        local arrowTouchSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5),cfg.callback)
	        arrowTouchSp:setTouchPriority(-(self.layerNum-1)*20-4)
	        arrowTouchSp:setAnchorPoint(ccp(0.5,0.5))
	        arrowTouchSp:setContentSize(CCSizeMake(100,100))
	        arrowTouchSp:setPosition(cfg.startPos)
	        arrowTouchSp:setOpacity(0)
	       	upSp:addChild(arrowTouchSp,4)

	        local moveTo=CCMoveTo:create(0.5,cfg.targetPos)
	        local fadeIn=CCFadeIn:create(0.5)
	        local carray=CCArray:create()
	        carray:addObject(moveTo)
	        carray:addObject(fadeIn)
	        local spawn=CCSpawn:create(carray)

	        local moveTo2=CCMoveTo:create(0.5,cfg.startPos)
	        local fadeOut=CCFadeOut:create(0.5)
	        local carray2=CCArray:create()
	        carray2:addObject(moveTo2)
	        carray2:addObject(fadeOut)
	        local spawn2=CCSpawn:create(carray2)

	        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
	        arrowMenu:runAction(CCRepeatForever:create(seq))

		end

	end

end

function newAllianceActiveInfoDialog:initDown( ... )

	local function nilFunc( ... )
		
	end

	local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-160-350-10-20))
    downBg:setAnchorPoint(ccp(0.5,0))
    downBg:setPosition(ccp(G_VisibleSizeWidth/2,20))    
	self.bgLayer:addChild(downBg)

	local titleBg,titleLb=G_createNewTitle({getlocal("alliance_activie_toGetReward"),24},CCSizeMake(G_VisibleSizeWidth-20-140,0),nil,nil,"Helvetica-bold")
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition((G_VisibleSizeWidth-20)/2,downBg:getContentSize().height-45)
	downBg:addChild(titleBg)

	local function callBack( ... )
    	return self:eventHandler(...)
	end
	local hd = LuaEventHandler:createHandler(callBack)
	local activeTv = LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-160-350-10-20-50-10-20),nil)
	self.activeTv = activeTv
	activeTv:setPosition(ccp(5,5))
    activeTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    downBg:addChild(activeTv)
	activeTv:setMaxDisToBottomOrTop(120)

end

function newAllianceActiveInfoDialog:eventHandler(handler,fn,idx,cel)

	if fn=="numberOfCellsInTableView" then
        return #allianceActiveCfg.allianceActivePoint
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-30,120)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        self:initCell(idx,cell)
        cell:autorelease()
        return cell
    elseif fn=="ccTouchBegan" then
    	return true
    elseif fn=="ccTouchMoved" then
    elseif fn=="ccScrollEnable" then
    end

end

function newAllianceActiveInfoDialog:switchHandeler(flag)

	self.switchFlag = true
	local curIndex = self.curIndex
	local moveIndex = self:resetIndex(curIndex,flag)
	local curSp = tolua.cast(self.pageList[curIndex],"LuaCCScale9Sprite")
	local moveSp = tolua.cast(self.pageList[moveIndex],"LuaCCScale9Sprite")
	if curSp and moveSp then

		moveSp:setPosition(self.outPos[math.ceil(2^flag)])
		local moveTo=CCMoveTo:create(self.timeInterval,self.midPos)
		moveSp:runAction(moveTo)

		local moveTo=CCMoveTo:create(self.timeInterval,self.outPos[math.ceil(2^(-flag))])
		local function moveCallBack( ... )
			self.curIndex = self:resetIndex(self.curIndex,flag)
			self:refreshBar()
			self.switchFlag = false
		end
		local callback=CCCallFunc:create(moveCallBack)
		local seq=CCSequence:createWithTwoActions(moveTo,callback)
		curSp:runAction(seq)

	end	

end

function newAllianceActiveInfoDialog:initCell(idx,cell)

	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,120))
	local alliance = allianceVoApi:getSelfAlliance()
	local strSize = G_isAsia() and 25 or 22
	local function nilFunc( ... )
	end
	local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
    titleSpire:setContentSize(CCSizeMake(cell:getContentSize().width-200,32))
    titleSpire:setAnchorPoint(ccp(0,1))
    cell:addChild(titleSpire)
    titleSpire:setPosition(ccp(100,cell:getContentSize().height-10))

	local titleLabel = GetTTFLabelWrap(getlocal("newAllianceActiveTask"..(idx+1),{allianceActiveCfg.allianceActiveDonate[idx+1]}),strSize,CCSizeMake(titleSpire:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold") 
	titleLabel:setAnchorPoint(ccp(0,0.5))
	titleLabel:setPosition(ccp(15,titleSpire:getContentSize().height/2))
	titleSpire:addChild(titleLabel)
	titleLabel:setColor(G_ColorYellowPro2)

	local activeNumLb = GetTTFLabelWrap(getlocal("alliance_activie_activieNum",{"+"..allianceActiveCfg.allianceActivePoint[idx+1]}),strSize,CCSizeMake(cell:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	activeNumLb:setAnchorPoint(ccp(0,0.5))
	activeNumLb:setPosition(115,55)
	cell:addChild(activeNumLb)

	local donateNum = 0
	if alliance.ainfo and alliance.ainfo.a and  alliance.ainfo.a[idx+1] then
		donateNum=alliance.ainfo.a[idx+1]
	end
	local maxNum =allianceActiveCfg.allianceActive[idx+1]
	
	if donateNum>=maxNum then
		donateNum=maxNum
	end

	local todayLimitLb = GetTTFLabelWrap(getlocal("newAllianceActiveLimit",{donateNum,maxNum}),strSize,CCSizeMake(cell:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	todayLimitLb:setAnchorPoint(ccp(0,0.5))
	todayLimitLb:setPosition(115,20)
	cell:addChild(todayLimitLb)

	local iconStr = self:getIconStr(idx+1)
	local icon = CCSprite:createWithSpriteFrameName(iconStr)
	icon:setAnchorPoint(ccp(0.5,0.5))
	icon:setPosition(icon:getContentSize().width/2,cell:getContentSize().height/2)
	icon:setScale(0.9)
	cell:addChild(icon)

	local function jumpHandler( ... )
		self:jumpHandler(idx+1)
    end
	local jumpBtn = G_createBotton(cell,ccp(cell:getContentSize().width-50,cell:getContentSize().height/2),"","yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png","yh_nbSkillGoto.png",jumpHandler,1,-(self.layerNum-1)*20-2,10)

end

function newAllianceActiveInfoDialog:getIconStr(index)
	local iconStr
	if index == 1 then
		iconStr = "Icon_mainui_02.png"
	elseif index == 2 then
		iconStr = "icon_alliance_war.png"
	elseif index == 3 then
		iconStr = "icon_alliance_gem.png"
	else
		iconStr = "icon_help_defense.png"
	end 
	return iconStr
end

function newAllianceActiveInfoDialog:refreshBar( ... )
	
	local alliance=allianceVoApi:getSelfAlliance()

	if alliance then

		local percentage 
		local levelDown,levelUp,nowValue,maxValue = self:getActivePointDetail(alliance.apoint)

		if not (self.pointLabel and tolua.cast(self.pointLabel,"CCLabelTTF")) then
			do return end
		end

		if self.curIndex > alliance.alevel then
			percentage = 0
			tolua.cast(self.pointLabel,"CCLabelTTF"):setString("0".."/"..self:getActiveMaxValue(self.curIndex))
		elseif self.curIndex < alliance.alevel then
			percentage = 100
			tolua.cast(self.pointLabel,"CCLabelTTF"):setString(self:getActiveMaxValue(self.curIndex).."/"..self:getActiveMaxValue(self.curIndex))
		else
			percentage = nowValue/maxValue*100
			tolua.cast(self.pointLabel,"CCLabelTTF"):setString(nowValue.."/"..maxValue)
		end

		self.progressTimer:setPercentage(percentage)

		if self.lDLabel and tolua.cast(self.lDLabel,"CCLabelTTF") then
			tolua.cast(self.lDLabel,"CCLabelTTF"):setString(getlocal("fightLevel",{self.curIndex}))
		end
		if self.lULabel and tolua.cast(self.lULabel,"CCLabelTTF") then
			local str = ""
			if self.curIndex+1 <= #(allianceActiveCfg.allianceALevelPoint) then
				str = getlocal("fightLevel",{self.curIndex+1})
			end
			tolua.cast(self.lULabel,"CCLabelTTF"):setString(str)
		end

	end
	
end

function newAllianceActiveInfoDialog:jumpHandler(index)

	local function callback( ... )
		if self.activeTv and self.activeTv.reloadData then
			self.activeTv:reloadData()
			self:refreshBar()
		end
	end
	if index == 1 then
	-- 军团科技
		local td=allianceSkillDialog:new(nil,nil,nil,callback)
	  	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	elseif index == 2 then
	-- 军团副本
		local td=allianceFuDialog:new(nil,nil,callback)
	  	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_duplicate"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	elseif index == 3 then
	-- 军团商店
	 	if base.ifAllianceShopOpen==0 then
	        do
	          return
	     	end
	    end
	    allianceShopVoApi:showShopDialog(self.layerNum+1,callback)
	elseif index == 4 then
	-- 世界地图
		activityAndNoteDialog:closeAllDialog()
        mainUI:changeToWorld()
	else

	end

end

function newAllianceActiveInfoDialog:getActiveMaxValue(index)
	local maxValue
	if index < #(allianceActiveCfg.allianceALevelPoint) then
		maxValue = allianceActiveCfg.allianceALevelPoint[index+1]-allianceActiveCfg.allianceALevelPoint[index]
	else
		maxValue = allianceActiveCfg.ActiveMaxPoint-allianceActiveCfg.allianceALevelPoint[#(allianceActiveCfg.allianceALevelPoint)]
	end
	return maxValue
end

function newAllianceActiveInfoDialog:resetIndex(index,flag)
	if index+flag < 1 then
		index= #(allianceActiveCfg.allianceALevelPoint)
	elseif index+flag > #(allianceActiveCfg.allianceALevelPoint) then
		index = 1
	else
		index = index+flag
	end
	return index
end

function newAllianceActiveInfoDialog:getActivePointDetail(nowPoint)
	
	if nowPoint == 0 then
		return 1,2,nowPoint,allianceActiveCfg.allianceALevelPoint[2]-allianceActiveCfg.allianceALevelPoint[1]
	end

	for k,v in pairs(allianceActiveCfg.allianceALevelPoint) do
		if nowPoint > v then
			if allianceActiveCfg.allianceALevelPoint[k+1] then
				if nowPoint <= allianceActiveCfg.allianceALevelPoint[k+1] then
					return k,k+1,nowPoint-v,allianceActiveCfg.allianceALevelPoint[k+1]-v
				end
			else
				return k,999,nowPoint-v,allianceActiveCfg.ActiveMaxPoint-v
			end
		end
	end
end



function newAllianceActiveInfoDialog:tick( ... )
	-- body
end

function newAllianceActiveInfoDialog:dispose( ... )
	-- body
end