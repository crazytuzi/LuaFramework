-- @Author hj
-- @Description 使命必达活动

acSmbdDialog = commonDialog:new()

function acSmbdDialog:new( ... )
	local nc={
		rewardPosTb = {ccp(G_VisibleSizeWidth/4-50,220),ccp(G_VisibleSizeWidth/2,220),ccp(G_VisibleSizeWidth/4*3+50,220)},
		rewardScale = {0.8,1.1,0.8},
		maxMoveX = 50,
		spriteArr = {2,3,4},
		rewardPackTb = {},
		timeInterval = 0.3,
		particularPos = {ccp(-115,220),ccp(G_VisibleSizeWidth+105,220)},
		curMidIdex = 3,
		curTvIdex = 1,
		taskListTb = acSmbdVoApi:getTaskList(),
		isExpand = {},
		point = acSmbdVoApi:getPoint(),
		consumePoint,
		subTaskPoint = {},
		rewardNum = 1,
		tvNum,
		taskTb = {{"ky","jz"},{"sc","gz","yx"},{"zd","pj","xm"},{"jb"}},
		logList = {},
		logCellSizeTb = {},
		ruleCellSizeTb = {},
		expandTbHeight = {},
		timeStampList = {},
		poolList = {},
		flag = true,
		nowChose = nil,
		propSize = 70,
		spaceX = 10,
		spaceY = 10,
		maxTankPage = 6,
		curTankPage = 1,
		displayTankPage = 5,
		tankSpTb = {},
		disPlayPageTb = {},
		removeNode = nil,
		switchFlag = false,
		centerPos = ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85-366-67-150)
	
	}
	setmetatable(nc,self)
	self.__index = self
	spriteController:addPlist("public/acLmqrjImage2.plist")
	spriteController:addPlist("public/juntuanCityBtns.plist")
	spriteController:addPlist("public/believer/believerMain.plist")
	spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    spriteController:addTexture("public/believer/believerMain.png")
    spriteController:addTexture("public/believer/juntuanCityBtns.png")
    spriteController:addTexture("public/acLmqrjImage2.png")
	return nc
end

function acSmbdDialog:doUserHandler( ... )
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.panelLineBg:setVisible(false)
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)

    self.touchArr = {}

	self.displayPosCfg = {
			{self.centerPos.x-240,0.8},
        	{self.centerPos.x-120,0.8},
        	{self.centerPos.x,1.2},
       	 	{self.centerPos.x+120,0.8},
        	{self.centerPos.x+240,0.8},
	}
	self.outScreenPos = ccp(10000,self.centerPos.y)
	self.leftCfg = {self.centerPos.x-360,0.8}
	self.rightCfg = {self.centerPos.x+360,0.8}
	self.panelLineBg:setVisible(false)
	self:initRewardArea()
	self:initRuleCellSize()
	self:initSubTaskPoint()
	self.logList,self.timeStampList,self.poolList = acSmbdVoApi:getLog()
end

function acSmbdDialog:initTableView( ... )


    local tvHeight = G_VisibleSizeHeight-85-366-60-100
    local tvWidth = G_VisibleSizeWidth

    local function callBack( ... )
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.bgLayer:addChild(self.tv,3)
    self.tv:setPosition(ccp(0,100))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)

    local function ruleHandler( ... )
		if self.removeNode then
			self.removeNode:removeFromParentAndCleanup(true)
			self.removeNode = nil
		end
    	self.curTvIdex = 1
		self.tv:setViewSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-85-366-100-60))
    	self.tv:setPosition(ccp(0,100))
    	self.tv:reloadData()
    	self:updateTvDesc()


    	local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab_down.png")
    	if frame1 then
	    	self.ruleSprite:setDisplayFrame(frame1)
	    end
	    local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab.png")
	    if frame2 then
	    	self.tankSprite:setDisplayFrame(frame2)
	    end
	    local frame3 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab.png")
	    if frame3 then
	    	self.logSprite:setDisplayFrame(frame3)
	    end
    end 
    local function tankHandler( ... )
    	self.curTvIdex = 2
    	if self.removeNode then
    	else
			local removeNode = CCNode:create()
		    removeNode:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-85-366-50-100))
		    removeNode:setAnchorPoint(ccp(0.5,0))
		    self.bgLayer:addChild(removeNode)
		    removeNode:setPosition(ccp(G_VisibleSizeWidth/2,100))
		    self.removeNode = removeNode

		    local blackStencilBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function()end)
		    blackStencilBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,150))
		    blackStencilBg:setAnchorPoint(ccp(0.5,1))
		    blackStencilBg:setPosition(ccp(G_VisibleSizeWidth/2,removeNode:getContentSize().height))
		    blackStencilBg:setOpacity(0.4*255)
		    removeNode:addChild(blackStencilBg,2)

		    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
			tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-85-366-50-100-150))
			tvBg:setAnchorPoint(ccp(0.5,0))
			tvBg:setPosition(ccp(removeNode:getContentSize().width/2,0))
			removeNode:addChild(tvBg)
	    	for i=1,self.maxTankPage do
		        local function touchHandler(object,event,tag)
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
		            local offsetPage=tonumber(tag)-math.ceil(self.displayTankPage/2)
		           	self:runTankMoveAction(offsetPage)
		        end
		        local tankSp = LuaCCSprite:createWithSpriteFrameName((i+2).."_t.png",touchHandler)
		        tankSp:setPosition(self.outScreenPos)
		        tankSp:setTouchPriority(-(self.layerNum-1)*20-3)
		        tankSp:setTag(i)
		        removeNode:addChild(tankSp,1)
		        self.tankSpTb[i]=tankSp
		        local levelSp = LuaCCSprite:createWithSpriteFrameName("smbd"..(i+2)..".png",touchHandler)
		        levelSp:setAnchorPoint(ccp(1,0))
		        levelSp:setPosition(ccp(tankSp:getContentSize().width-20,20))
		        tankSp:addChild(levelSp)
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
	    		self:rightPageHandler()
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
		        self:leftPageHandler()
		    end
	    	local arrowCfg={
        		  {startPos=ccp(45,removeNode:getContentSize().height/2-40),targetPos=ccp(25,removeNode:getContentSize().height/2-40),callback=leftPageHandler,angle=0},
        		  {startPos=ccp(removeNode:getContentSize().width-45,removeNode:getContentSize().height/2-40),targetPos=ccp(removeNode:getContentSize().width-25,removeNode:getContentSize().height/2-40),callback=rightPageHandler,angle=180}
        	}
	    	for i=1,2 do
		        local cfg=arrowCfg[i]
		        local arrowBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",function () end,11,nil,nil)
		        arrowBtn:setRotation(cfg.angle)
		        local arrowMenu=CCMenu:createWithItem(arrowBtn)
		        arrowMenu:setAnchorPoint(ccp(0.5,0.5))
		        arrowMenu:setTouchPriority(-(self.layerNum-1)*20-3)
		        arrowMenu:setPosition(cfg.startPos)
		        removeNode:addChild(arrowMenu,3)

		        local arrowTouchSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5),cfg.callback)
		        arrowTouchSp:setTouchPriority(-(self.layerNum-1)*20-4)
		        arrowTouchSp:setAnchorPoint(ccp(0.5,0.5))
		        arrowTouchSp:setContentSize(CCSizeMake(100,100))
		        arrowTouchSp:setPosition(cfg.startPos)
		        arrowTouchSp:setOpacity(0)
		       	removeNode:addChild(arrowTouchSp,4)

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
        local page = self.curTankPage - 2
	    if page<1 then
	        page=page+self.maxTankPage
	    end
	    for i=1,self.displayTankPage do
	        self.disPlayPageTb[i]=page
	        local tankSp=tolua.cast(self.tankSpTb[page],"LuaCCSprite")
	        if tankSp then
	            tankSp:setPosition(self.displayPosCfg[i][1],self.centerPos.y)
	            tankSp:setScale(self.displayPosCfg[i][2])
	            tankSp:setTag(i)
	            if page == self.curTankPage then
                	self.removeNode:reorderChild(tankSp,3)
                else
                	self.removeNode:reorderChild(tankSp,1)
	            end
	        end
	        page=page+1
	        if page>self.maxTankPage then
	            page=1
	        end
	    end
		self.tv:setViewSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-85-366-100-60-150))
		self.tv:setPosition(ccp(10,105))
    	self.tv:reloadData()
    	self:updateTvDesc()

    	local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab.png")
    	if frame1 then
	    	self.ruleSprite:setDisplayFrame(frame1)
	    end

	    local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab_down.png")
	    if frame2 then
	    	self.tankSprite:setDisplayFrame(frame2)
	    end

	    local frame3 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab.png")
	    if frame3 then
	    	self.logSprite:setDisplayFrame(frame3)
	    end

    end    
    local function logHandler( ... )
    	if self.removeNode then
			self.removeNode:removeFromParentAndCleanup(true)
			self.removeNode = nil
		end
    	self.curTvIdex = 3
		self.tv:setViewSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-85-366-100-60))
    	self.tv:setPosition(ccp(0,100))
    	self.tv:reloadData()
    	self:updateTvDesc()
    	local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab.png")
    	if frame1 then
	    	self.ruleSprite:setDisplayFrame(frame1)
	    end

	    local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab.png")
	    if frame2 then
	    	self.tankSprite:setDisplayFrame(frame2)
	    end

	    local frame3 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab_down.png")
	    if frame3 then
	    	self.logSprite:setDisplayFrame(frame3)
	    end
    end
    -- 最上面的精灵切换 
    local ruleSprite = LuaCCSprite:createWithSpriteFrameName("yh_ltzdzHelp_tab_down.png",ruleHandler)
    local tankSprite = LuaCCSprite:createWithSpriteFrameName("yh_ltzdzHelp_tab.png",tankHandler)
    local logSprite = LuaCCSprite:createWithSpriteFrameName("yh_ltzdzHelp_tab.png",logHandler)
    self.ruleSprite = ruleSprite
    self.tankSprite = tankSprite
    self.logSprite = logSprite
    ruleSprite:setTouchPriority(-(self.layerNum-1)*20-4)
    tankSprite:setTouchPriority(-(self.layerNum-1)*20-4)
    logSprite:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(ruleSprite)
    self.bgLayer:addChild(tankSprite)
    self.bgLayer:addChild(logSprite)
    ruleSprite:setAnchorPoint(ccp(0,1))
    tankSprite:setAnchorPoint(ccp(0,1))
    logSprite:setAnchorPoint(ccp(0,1))
    ruleSprite:setPosition(ccp(20,G_VisibleSizeHeight-85-366))
    tankSprite:setPosition(ccp(ruleSprite:getPositionX()+ruleSprite:getContentSize().width+5,G_VisibleSizeHeight-85-366))
    logSprite:setPosition(ccp(tankSprite:getPositionX()+tankSprite:getContentSize().width+5,G_VisibleSizeHeight-85-366))
    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,ruleSprite:getPositionY()-ruleSprite:getContentSize().height)
    self.bgLayer:addChild(tabLine)

    for i=1,3 do
    	local strSize = 25
    	if G_getCurChoseLanguage() == "ja" then
    		strSize = 18
    	elseif G_isAsia() == false then
    		strSize = 20
    	end
    	local subItemlabel = GetTTFLabelWrap(getlocal("activity_smbd_subDesc"..i),strSize,CCSizeMake(ruleSprite:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	subItemlabel:setAnchorPoint(ccp(0.5,0.5))
    	subItemlabel:setPosition(ccp(20+ruleSprite:getContentSize().width/2+(i-1)*ruleSprite:getContentSize().width,G_VisibleSizeHeight-85-366-25))
    	self.bgLayer:addChild(subItemlabel)
    end
   
    -- 最下面的描述文字
	local tvDesLabel = GetTTFLabelWrap(getlocal("activity_smbd_task_desc"),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.bgLayer:addChild(tvDesLabel)
	tvDesLabel:setColor(G_ColorRed)
	tvDesLabel:setAnchorPoint(ccp(0.5,0.5))
	tvDesLabel:setPosition(ccp(G_VisibleSizeWidth/2,50))
	self.tvDesLabel = tvDesLabel

end

function acSmbdDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        return self:getTvNum()
    elseif fn=="tableCellSizeForIndex" then
        return self:getCellSize(idx)
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

function acSmbdDialog:initRewardArea( ... )

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	local rewardBg=CCSprite:create("public/smbdBg.jpg")
    rewardBg:setAnchorPoint(ccp(0.5,1)) 
    rewardBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 85))
    self.rewardBg = rewardBg
	self.bgLayer:addChild(rewardBg)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    --标题框
	local titleBacksprie = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
	rewardBg:addChild(titleBacksprie)
	titleBacksprie:setAnchorPoint(ccp(0.5,1))
	titleBacksprie:setContentSize(CCSizeMake(rewardBg:getContentSize().width,70))
	titleBacksprie:setPosition(ccp(rewardBg:getContentSize().width/2,rewardBg:getContentSize().height))
 	
 	--活动时间
 	local acTimeLb=GetTTFLabel(acSmbdVoApi:getTimeStr(),22)
	acTimeLb:setPosition(ccp(titleBacksprie:getContentSize().width/2,titleBacksprie:getContentSize().height-20))
	titleBacksprie:addChild(acTimeLb)
	self.acTimeLb=acTimeLb

	local function touchTip()
		local tabStr={getlocal("activity_smbd_tip1"),getlocal("activity_smbd_tip2"),getlocal("activity_smbd_tip3"),getlocal("activity_smbd_tip4"),getlocal("activity_smbd_tip5")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth - 35,G_VisibleSizeHeight - 120),{},nil,nil,28,touchTip,true)
	local pointStrSize =  G_isAsia() and 20 or 18
	local pointLabel = GetTTFLabel(self.point,pointStrSize,true)
	rewardBg:addChild(pointLabel)
	pointLabel:setAnchorPoint(ccp(0.5,0))
	pointLabel:setPosition(ccp(rewardBg:getContentSize().width-30-pointLabel:getContentSize().width/2,25))
	self.pointLabel = pointLabel
	
	local pointDescLabel = GetTTFLabel(getlocal("activity_smbd_point"),pointStrSize,true)
	rewardBg:addChild(pointDescLabel)
	pointDescLabel:setAnchorPoint(ccp(1,0))
	pointDescLabel:setPosition(ccp(rewardBg:getContentSize().width-30-pointLabel:getContentSize().width-10,25))

	for k,v in ipairs(self.spriteArr) do

		local function rewardDisplayCallback()
			if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

	        local function onClickEvent()
		        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
		        local rewardTb = acSmbdVoApi:getRewardPool(v-1)
		        local titleStr = getlocal("activity_smbd_boxName"..(v-1))
		        local descStr = getlocal("activity_smbd_reward_desc",{getlocal("activity_smbd_boxName"..(v-1))})
		        local needTb = {"smbd",titleStr,descStr,rewardTb,SizeOfTable(rewardTb)}
		        local rewardDialog = acThrivingSmallDialog:new(self.layerNum+1,needTb)
		        rewardDialog:init()
	    	end
	    	
	        if v ~= self.curMidIdex then
	        	for i,j in ipairs(self.spriteArr) do
	        		if v == j then
	        			-- 右移
	        			if i == 1 then
	        				self.flag = false
	        				self:runMoveAction(10,onClickEvent)
	        				return
	        			else
	        				self.falg = false
	        				self:runMoveAction(-10,onClickEvent)
	        				return
	        			end		
	        		end
	        	end
	        else
	    		onClickEvent()
	        end
		end
		local boxTb = acSmbdVoApi:getBoxTb(v-1)
		local rewardPack= LuaCCSprite:createWithSpriteFrameName(boxTb[1],rewardDisplayCallback)
		rewardPack:setTouchPriority(-(self.layerNum-1)*20-4)
		rewardBg:addChild(rewardPack)
		local rewardCap = CCSprite:createWithSpriteFrameName(boxTb[2])
		rewardPack:addChild(rewardCap)
		rewardCap:setAnchorPoint(ccp(0.5,0))
		rewardCap:setPosition(ccp(rewardPack:getContentSize().width/2+7,rewardCap:getContentSize().height-10))
		rewardPack:setPosition(self.rewardPosTb[k])
		rewardPack:setScale(self.rewardScale[k])
		table.insert(self.rewardPackTb,rewardPack)
	end

	local function nilFunc( ... )
		do return end
	end
	local namewidth = 140
	local strSize = 20
	local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5), nilFunc)
	nameBg:setContentSize(CCSizeMake(namewidth,30))
	rewardBg:addChild(nameBg)
	nameBg:setPosition(ccp(G_VisibleSizeWidth/2,200))
	self.nameBg = nameBg
	local nameLabel = GetTTFLabelWrap(getlocal("activity_smbd_boxName"..(self.spriteArr[2]-1)),strSize,CCSizeMake(namewidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	rewardBg:addChild(nameLabel)
	-- nameLabel:setPosition(ccp(G_VisibleSizeWidth/2,200))
	self.nameLabel = nameLabel

	local exchangeNumLb = GetTTFLabel("",strSize)
	rewardBg:addChild(exchangeNumLb)
	self.exchangeNumLb=exchangeNumLb

	-- 输入框
	local function nilFunc( ... )
		do return end
	end
	local editBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5), nilFunc)
	local function inputCallbcak(fn,eB,str,type)
    	-- 检测文本发生变化
    	self.numLabel:setVisible(false)
    	local rewardIdex = self.spriteArr[2]-1
    	local remainNum = acSmbdVoApi:getRemainExchangeNum(rewardIdex)
    	if type==1 then
    		if tonumber(str) == nil then
    			if str ~="" then
    				eB:setText(self.rewardNum)
    			end
    		else
    			if tonumber(str) > remainNum then
    				eB:setText(remainNum)
    				self.rewardNum = remainNum
    			elseif tonumber(str) > 0  and tonumber(str) <= remainNum then
    				eB:setText(tonumber(str))
    				self.rewardNum = tonumber(str)
    			end
    		end
    		self.numLabel:setString(self.rewardNum)
    	-- 检测文本输入结束
    	elseif type==2 then
    		if tonumber(str) == 0 then
    			if remainNum==0 then
    				self.rewardNum = 0
    			else
    				self.rewardNum = 1
    			end
    		end
    		self.numLabel:setString(self.rewardNum)
    		self.numLabel:setVisible(true)
    		self.editBox:setVisible(false)
    		self:updatePack()
    	end
    end
    local editBox=CCEditBox:createForLua(CCSize(150,50),editBoxBg,nil,nil,inputCallbcak)
    editBox:setPosition(ccp(rewardBg:getContentSize().width/2,135))
   	editBox:setVisible(false)
   	editBoxBg:setVisible(false)
   	self.editBox = editBox
    rewardBg:addChild(editBox,3)
    if G_isIOS()==true then
        editBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
    else
        editBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
    end

   	local numLabel = GetTTFLabel(self.rewardNum,25)
	numLabel:setAnchorPoint(ccp(0.5,0.5))
	numLabel:setPosition(ccp(rewardBg:getContentSize().width/2,135))
	rewardBg:addChild(numLabel,2)
	self.numLabel = numLabel

	local function clickFunc( ... )
        PlayEffect(audioCfg.mouseClick)
		self.editBox:setVisible(true)		
	end
	local editBoxRealBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5),clickFunc)
	editBoxRealBg:setAnchorPoint(ccp(0.5,0.5))
	editBoxRealBg:setContentSize(CCSizeMake(150,50))
	editBoxRealBg:setPosition(ccp(rewardBg:getContentSize().width/2,135))
	editBoxRealBg:setTouchPriority(-(self.layerNum-1)*20-4)
	rewardBg:addChild(editBoxRealBg,1)

	local function plusHandler( ... )
    	local rewardIdex = self.spriteArr[2]-1
		local remainNum = acSmbdVoApi:getRemainExchangeNum(rewardIdex)
		if self.rewardNum >= remainNum then
			do return end
		else
			self.rewardNum = self.rewardNum + 1
			self.numLabel:setString(self.rewardNum)
			self:updatePack()
		end
	end

	local function minusHandler( ... )
		if self.rewardNum == 1 then
			do return end
		else
			self.rewardNum = self.rewardNum - 1
			self.numLabel:setString(self.rewardNum)
			self:updatePack()
		end
	end 
	--加减号
	local plusSprite = LuaCCSprite:createWithSpriteFrameName("greenPlus.png",function ()end)
	local minusSprite = LuaCCSprite:createWithSpriteFrameName("greenMinus.png",function ()end)
	plusSprite:setAnchorPoint(ccp(0.5,0.5))
	minusSprite:setAnchorPoint(ccp(0.5,0.5))
	plusSprite:setPosition(ccp(G_VisibleSizeWidth/2+120,editBoxRealBg:getPositionY()))
	minusSprite:setPosition(ccp(G_VisibleSizeWidth/2-120,editBoxRealBg:getPositionY()))
	rewardBg:addChild(plusSprite)
	rewardBg:addChild(minusSprite)

    local plusTouch=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),plusHandler)
    local minusTouch=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),minusHandler)
    plusTouch:setVisible(false)
    minusTouch:setVisible(false)
    plusTouch:setContentSize(CCSizeMake(plusSprite:getContentSize().width+30,plusSprite:getContentSize().height+30))
    minusTouch:setContentSize(CCSizeMake(plusSprite:getContentSize().width+30,plusSprite:getContentSize().height+30))
   	plusTouch:setAnchorPoint(ccp(0.5,0.5))
	minusTouch:setAnchorPoint(ccp(0.5,0.5))
	plusTouch:setPosition(ccp(G_VisibleSizeWidth/2+120,editBoxRealBg:getPositionY()))
	minusTouch:setPosition(ccp(G_VisibleSizeWidth/2-120,editBoxRealBg:getPositionY()))
	plusTouch:setTouchPriority(-(self.layerNum-1)*20-4)
	minusTouch:setTouchPriority(-(self.layerNum-1)*20-4)
	rewardBg:addChild(plusTouch)
	rewardBg:addChild(minusTouch)


	-- 触摸滑动
	local touchLayer=CCLayer:create()
    self.bgLayer:addChild(touchLayer,1)
    touchLayer:setTouchEnabled(true)
 
    local function touchHandler(...)
       return self:touchEvent(...)
    end

    touchLayer:registerScriptTouchHandler(touchHandler,false,-(self.layerNum-1)*20-4,falsexww)

    local consumePointLabel = GetTTFLabel(acSmbdVoApi:getPointCost(self.spriteArr[2]-1)*self.rewardNum,25)
    consumePointLabel:setPosition(ccp(rewardBg:getContentSize().width/2,90))
    rewardBg:addChild(consumePointLabel)
    self.consumePointLabel = consumePointLabel
    self:updatePack()

    local function convertCallback( ... )
    	if self:judgeAfford()== false then
    		-- 当前积分不足
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_smbd_prompt"),30)
    	else
    		local rewardIdex = self.spriteArr[2]-1
    		local exchangeNum,exchangeLimit = acSmbdVoApi:getExchangeNum(rewardIdex),acSmbdVoApi:getExchangeLimit(rewardIdex)
    		if exchangeNum>=exchangeLimit then --已达兑换上限
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notExchangeTip"),30)
    			do return end
    		end
    		-- 展示奖励
    		local function callBack(fn,data)
    			local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.reward then
                    	acSmbdVoApi:updateSpecialData(sData.data.smbd)
                    	self:updatePoint()
                    	local rewardlist = {}
                    	for k,v in pairs(sData.data.reward) do
							local prop = FormatItem(v,nil,true)[1]
							G_addPlayerAward(prop.type,prop.key,prop.id,prop.num,nil,true)
                    		table.insert(rewardlist,prop)
                    		if  emblemListCfg.equipListCfg[prop.key] and  emblemListCfg.equipListCfg[prop.key]["color"] == 5 then
								local paramTab = {}
								paramTab.functionStr="smbd"
								paramTab.addStr="goTo_see_see"
								paramTab.colorStr="w,y,w"
						        local playerName = playerVoApi:getPlayerName() 
						        local elblemName = getlocal("emblem_name_"..prop.key)
								local message = {key="activity_smbd_getSystemMessage",param={playerName,elblemName}}
								chatVoApi:sendSystemMessage(message,paramTab)   
							end       		
                    	end

                    	local function rewardShowCallback( ... )
                    		-- body
	                        -- 飘板展示奖励
	                        local function showEndHandler( ... )
	                        	G_showRewardTip(rewardlist,true)
	                        end 
							local titleStr=getlocal("activity_wheelFortune4_reward")
		                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
		                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr,nil,nil,nil,"smbd")
		                    local function logCallback(logList,timeStampList,poolList)
	                    		self.logList = logList
	                    		self.timeStampList = timeStampList
	                    		self.poolList = poolList
	                    		self.logCellSizeTb = {}
	                    		if self.curTvIdex == 3 then
	                    			self.tv:reloadData()
	                    		end
		                    end
		                    acSmbdVoApi:getLog(logCallback)
	                	end
	                	self:runConsumeLabelAction(rewardShowCallback,self.rewardNum)
                    end
                end	
    		end
    		socketHelper:acSmbdGetReward(self.curMidIdex-1,self.rewardNum,callBack)
    	end
    end

    local convertButton = G_createBotton(rewardBg,ccp(rewardBg:getContentSize().width/2,43),{getlocal("activity_loversDay_tab2"),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",convertCallback,0.8,-(self.layerNum-1)*20-4)

    local tipLabel =  GetTTFLabel(getlocal("activity_tccx_no_record"),30)
	self.bgLayer:addChild(tipLabel,3)
	tipLabel:setAnchorPoint(ccp(0.5,1))
	tipLabel:setPosition(ccp(G_VisibleSizeWidth/2,350))
	tipLabel:setColor(G_ColorGray)
	tipLabel:setVisible(false)
	self.tipLabel = tipLabel
end

function acSmbdDialog:touchEvent(fn,x,y,touch)
	if fn == "began" then
		self.startPos = ccp(x,y)
		if self.flag == false or self:judgePos(y) == false or self.switchFlag == true then
			return 
		end
        if SizeOfTable(self.touchArr)>=1 then
            return 0
        end
        self.isMoved=false
        self.touchArr[touch]=touch
		return true
	elseif fn == "moved" then
		self.isMoved=true
		return true
	elseif fn == "ended" then
        if SizeOfTable(self.touchArr)>1 then
        	self.touchArr={}
            return 0
        end
        self.touchArr={}
		if self:judgePos(y) == false then
			return 
		elseif self:judgePos(y) == 1 then
			local endPos = ccp(x,y)
			self:endRewardPack(endPos.x-self.startPos.x)
		else
			local endPos = ccp(x,y)
			local distance = endPos.x-self.startPos.x
			if math.abs(distance) >= self.maxMoveX then
				if distance > 0 then
					distance = -1
				else
					distance = 1
				end
				self:runTankMoveAction(distance)
			else
				return
			end
		end
		return true
	else
		self.touchArr={}
	end
end

-- 移动结束时的动画
function acSmbdDialog:endRewardPack(subX)

	-- 移动超过一定的距离才做变化
	if math.abs(subX) >= self.maxMoveX then
		self.flag = false
		self:runMoveAction(subX)
	else
		return
	end

end

function acSmbdDialog:runMoveAction(subX,onClickEvent)
	self.nameLabel:setVisible(false)
	self.exchangeNumLb:setVisible(false)
	self.nameBg:setVisible(false)
	local act
	if subX < 0 then
		for i=1,3,1 do
			local acArr = CCArray:create()
			if i == 1 then
				local moveToOne = CCMoveTo:create(self.timeInterval/2,self.particularPos[1])
				local function resetPos( ... )
					self.rewardPackTb[self.spriteArr[i]-1]:setPosition(self.particularPos[2])
				end 
				local callFunc = CCCallFunc:create(resetPos)
				local moveToTwo = CCMoveTo:create(self.timeInterval/2,self.rewardPosTb[3])
				acArr:addObject(moveToOne)
				acArr:addObject(callFunc)
				acArr:addObject(moveToTwo)
				act=CCSequence:create(acArr)
			else
				local moveTo = CCMoveTo:create(self.timeInterval,self.rewardPosTb[i-1])
				local scaleTo = CCScaleTo:create(self.timeInterval,self.rewardScale[i-1])
				acArr:addObject(moveTo)
				acArr:addObject(scaleTo)
				act = CCSpawn:create(acArr)
			end
			if i == 3 then
				local function callBack()
					self:resetSprite(-10)
					self.flag = true
					self.curMidIdex = self.spriteArr[2]
					self:updatePack()
					if onClickEvent then
						onClickEvent()
					end
				end
				local resetArr = CCCallFunc:create(callBack)
				local seq = CCSequence:createWithTwoActions(act,resetArr)
				self.rewardPackTb[self.spriteArr[i]-1]:runAction(seq)
			else
				self.rewardPackTb[self.spriteArr[i]-1]:runAction(act)
			end
		end
	else
		for i=1,3 do
			local acArr = CCArray:create()
			if i == 3 then
				local moveToOne = CCMoveTo:create(self.timeInterval/2,self.particularPos[2])
				local function callBack( ... )
					self.rewardPackTb[self.spriteArr[i]-1]:setPosition(self.particularPos[1])
				end 
				local callFunc = CCCallFunc:create(callBack)
				local moveToTwo = CCMoveTo:create(self.timeInterval/2,self.rewardPosTb[1])
				acArr:addObject(moveToOne)
				acArr:addObject(callFunc)
				acArr:addObject(moveToTwo)
				act=CCSequence:create(acArr)
			else
				local moveTo = CCMoveTo:create(self.timeInterval,self.rewardPosTb[i+1])
				local scaleTo = CCScaleTo:create(self.timeInterval,self.rewardScale[i+1])
				acArr:addObject(moveTo)
				acArr:addObject(scaleTo)
				act = CCSpawn:create(acArr)
			end
			if i == 3 then
				local function callBack()
					self:resetSprite(10)
					self.flag = true
					self.curMidIdex = self.spriteArr[2]
					self:updatePack()
					if onClickEvent then
						onClickEvent()
					end
				end
				local resetArr = CCCallFunc:create(callBack)
				local seq = CCSequence:createWithTwoActions(act,resetArr)
				self.rewardPackTb[self.spriteArr[i]-1]:runAction(seq)
			else
				self.rewardPackTb[self.spriteArr[i]-1]:runAction(act)
			end
		end

	end

end

--决定移动结束后精灵的排列顺序
function acSmbdDialog:resetSprite(subX)
	
	if subX < 0 then
		if self.spriteArr[1] == 2 then
			self.spriteArr = {3,4,2}
		elseif self.spriteArr[1] == 3 then
			self.spriteArr = {4,2,3}
		else
			self.spriteArr = {2,3,4}
		end
	else
		if self.spriteArr[1] == 2 then
			self.spriteArr = {4,2,3}
		elseif self.spriteArr[1] == 3 then
			self.spriteArr = {2,3,4}
		else
			self.spriteArr = {3,4,2}
		end
	end

end

function acSmbdDialog:initRuleCellSize( ... )
	self.ruleCellSizeTb = {}	
	for k=1,4 do
		table.insert(self.ruleCellSizeTb,CCSizeMake(G_VisibleSizeWidth,70))
	end
end

--设置展开cell的数量
function acSmbdDialog:setExpandTb(idx)
	if self.ruleCellSizeTb[idx+1].height ~= 70 then
		self.ruleCellSizeTb[idx+1].height = 70
		return
	else
		self:initRuleCellSize()
		if (idx+1) == 1 then
			self.ruleCellSizeTb[idx+1].height = 70 + 50*2
		elseif(idx+1) == 2 then
			self.ruleCellSizeTb[idx+1].height = 70 + 50*18
		elseif (idx+1) == 3 then	
			self.ruleCellSizeTb[idx+1].height = 70 + 50*8
		else
			self.ruleCellSizeTb[idx+1].height = 70 + 50*1	
		end
	end
end

function acSmbdDialog:getTvNum( ... )
	if self.curTvIdex == 1 then
		self.tipLabel:setVisible(false)
		return 4
	elseif self.curTvIdex == 2 then
		self.tipLabel:setVisible(false)
		self.tankTb = acSmbdVoApi:getTankByLevel(self.curTankPage+2)
    	local tc,pertc=SizeOfTable(self.tankTb),4
    	local cellNum=tc%pertc==0 and math.floor(tc/pertc) or (math.floor(tc/pertc)+1)
    	return cellNum
	else
		if SizeOfTable(self.logList) == 0 then
			self.tipLabel:setVisible(true)
		else
			self.tipLabel:setVisible(false)
		end
		return SizeOfTable(self.logList)
	end

end


--动态获取每个cell对应的Size
function acSmbdDialog:getCellSize(idx)
	if self.curTvIdex == 1 then
		return self.ruleCellSizeTb[idx+1]
	elseif self.curTvIdex == 2 then
		return CCSizeMake(G_VisibleSizeWidth-20,150)
	else
		if SizeOfTable(self.logCellSizeTb) >= (idx+1) then
			return self.logCellSizeTb[idx+1]
		else
			local log = self.logList[idx+1]
			if (SizeOfTable(log)>7) then
				table.insert(self.logCellSizeTb,CCSizeMake(G_VisibleSizeWidth,220))
			else
				table.insert(self.logCellSizeTb,CCSizeMake(G_VisibleSizeWidth,140))
			end
			return self.logCellSizeTb[idx+1]
		end
	end

end

--初始化cell
function acSmbdDialog:initCell(idx,cell)

	local tempSize = self:getCellSize(idx)
	cell:setContentSize(tempSize)

	if self.curTvIdex == 1 then
		local function onClick( ... )
			-- self:cellClick(idx,cell)
			self:setExpandTb(idx)
			self.tv:reloadData()				
		end
		local bgImg = self.ruleCellSizeTb[idx+1].height > 70 and "newExpandCell.png" or "newCell.png"
		local greenBgSp = LuaCCScale9Sprite:createWithSpriteFrameName(bgImg,CCRect(23,23,1,1),onClick)
	    greenBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30,60))
	    greenBgSp:setAnchorPoint(ccp(0,1))
	    greenBgSp:setTouchPriority(-(self.layerNum-1)*20-2)
	    greenBgSp:setPosition(ccp(15,cell:getContentSize().height-5))
	    cell:addChild(greenBgSp)

		local arrowSprite = CCSprite:createWithSpriteFrameName("expandBtn.png")
		if self.ruleCellSizeTb[idx+1].height > 70 then
			arrowSprite:setRotation(90)
		end
		local sumPointlabel = GetTTFLabel(getlocal("activity_smbd_task_point",{self.subTaskPoint[idx+1]}),25)
		sumPointlabel:setColor(G_ColorYellowPro)
		local taskLabel = GetTTFLabel(getlocal("activity_smbd_task_"..(idx+1)),25)

		greenBgSp:addChild(arrowSprite)
		greenBgSp:addChild(sumPointlabel)
		greenBgSp:addChild(taskLabel)

		taskLabel:setAnchorPoint(ccp(0,0.5))
		sumPointlabel:setAnchorPoint(ccp(0,0.5))
		arrowSprite:setAnchorPoint(ccp(0.5,0.5))

		taskLabel:setPosition(ccp(10,30))
		sumPointlabel:setPosition(ccp(taskLabel:getContentSize().width+15,30))
		arrowSprite:setPosition(ccp(G_VisibleSizeWidth-50,30))

		if self.ruleCellSizeTb[idx+1].height > 70 then

			local extandBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
			extandBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,self.ruleCellSizeTb[idx+1].height-70))
			extandBg:setAnchorPoint(ccp(0,1))
			extandBg:setPosition(ccp(15,cell:getContentSize().height-62))
			cell:addChild(extandBg)

			local tempTask = self.taskTb[idx+1]
			local sumCount = 0
			-- 小数点等级的坦克不显示
			for k,v in pairs(tempTask) do	
				if k>1 then
					sumCount = sumCount + SizeOfTable(self.taskListTb[tempTask[k-1]])
				end
				local unIntNum = 0
				for i,vv in pairs(self.taskListTb[v]) do
					local flag = 0			
					local descNum = vv[1]
					local pointNum = vv[2]
					if (idx+1) == 1 then
						descNum = math.ceil(descNum/60)
					elseif (idx+1) == 2 or (idx+1) == 3 then
						if math.floor(descNum) ~= descNum then
							flag = 1
							unIntNum = unIntNum + 1
						end
					end
					if flag == 0 then
						local typeLabel = GetTTFLabel(getlocal("activity_smbd_task_"..v.."_desc",{descNum}),25)
						local consumeLabel = GetTTFLabel(tostring(vv[2]),25)
						cell:addChild(typeLabel)
						cell:addChild(consumeLabel)
						typeLabel:setAnchorPoint(ccp(0,0.5))
						consumeLabel:setAnchorPoint(ccp(1,0.5))
						consumeLabel:setColor(G_ColorYellowPro)
						typeLabel:setPosition(ccp(30,cell:getContentSize().height-65-50*sumCount-(i-unIntNum-1)*50-25))
						consumeLabel:setPosition(ccp(cell:getContentSize().width -30 ,cell:getContentSize().height-65-50*sumCount-(i-unIntNum-1)*50-25))
						local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function ()end)
						lineSp:setAnchorPoint(ccp(0.5,0))
						lineSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height-65-50*sumCount-(i-unIntNum-1)*50))
						lineSp:setContentSize(CCSizeMake(580,2))
						cell:addChild(lineSp)
					end
				end
			end

		end
	elseif self.curTvIdex == 2 then
		local firstPosX = 40
		local iconSize = 100
        local spaceX=(G_VisibleSizeWidth-20-2*firstPosX-4*iconSize)/3
        for i=1,4 do
            local tank=self.tankTb[idx*4+i]
            if tank then
                local tankId=tank.key
                if tankId and tankCfg[tankId] and tankCfg[tankId].icon then
                    local tankSp=CCSprite:createWithSpriteFrameName(tankCfg[tankId].icon)
                    tankSp:setAnchorPoint(ccp(0,1))
                    tankSp:setScale(iconSize/tankSp:getContentSize().width)
                    tankSp:setPosition(firstPosX+(i-1)*(iconSize+spaceX),150-10)
                    cell:addChild(tankSp,2)
                    local nameLb=GetTTFLabelWrap(getlocal(tankCfg[tankId].name),20,CCSizeMake(iconSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                    nameLb:setAnchorPoint(ccp(0.5,1))
                    nameLb:setPosition(tankSp:getPositionX()+iconSize/2,tankSp:getPositionY()-iconSize-5)
                    cell:addChild(nameLb)
                end
            end
         end
	else
		local count = SizeOfTable(self.logList[idx+1])
		local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
        cellBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,tempSize.height))
        cellBg:setAnchorPoint(ccp(0,1))
        cellBg:setPosition(ccp(10,cell:getContentSize().height))
        cell:addChild(cellBg)
        local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp1:setPosition(ccp(5,cellBg:getContentSize().height/2))
        cellBg:addChild(pointSp1)
        local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp2:setPosition(ccp(cellBg:getContentSize().width-5,cellBg:getContentSize().height/2))
        cellBg:addChild(pointSp2)

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
        lineSp:setContentSize(CCSizeMake(cellBg:getContentSize().width-20,lineSp:getContentSize().height))
        lineSp:setPosition(ccp(cellBg:getContentSize().width/2,cellBg:getContentSize().height-50))
        cellBg:addChild(lineSp)

        local strSize = G_isAsia() == true  and 25 or 23 
        local descLabel = GetTTFLabel(getlocal("activity_smbd_pack_desc",{count,getlocal("activity_smbd_boxName"..self.poolList[idx+1])}),strSize)
        descLabel:setAnchorPoint(ccp(0,0))
        descLabel:setPosition(ccp(20,cellBg:getContentSize().height-40))
        cellBg:addChild(descLabel)

        local timeLabel = GetTTFLabel(self.timeStampList[idx+1],25)
        timeLabel:setAnchorPoint(ccp(1,0))
        timeLabel:setPosition(ccp(cellBg:getContentSize().width-20,cellBg:getContentSize().height-40))
        cellBg:addChild(timeLabel)

        local function initRewards(parent)
        	local num = 7
            for k=1,count do
        		local tempList = FormatItem(self.logList[idx+1][k],nil,true)
        		local reward = tempList[1]
                local icon,scale
                local function callback( )
           			 G_showNewPropInfo(self.layerNum+1,true,nil,nil,reward,nil,nil,nil)
		        end
		        if  reward.type == "se" then
		            icon,scale=G_getItemIcon(reward,120,true,self.layerNum,nil,nil,nil,nil,nil,nil,true)
		        else
		            icon,scale=G_getItemIcon(reward,120,false,self.layerNum,callback,nil)
		        end
                if icon then
                	local firstPosX = 40
                	local firstPosY 
                	if count > 7 then
                		firstPosY = 160
                	else
                		firstPosY = 85
                	end

                    icon:setAnchorPoint(ccp(0,1))
                    icon:setPosition(firstPosX+((k-1)%num)*(self.propSize+self.spaceX),firstPosY-math.floor(((k-1)/num))*(self.propSize+self.spaceY))
                    icon:setTouchPriority(-(self.layerNum-1)*20-2)
                    icon:setIsSallow(false)
                    icon:setScale(self.propSize/icon:getContentSize().width)
                    parent:addChild(icon,1)

                    local numLb=GetTTFLabel(FormatNumber(reward.num),23)
                    numLb:setAnchorPoint(ccp(1,0))
                    numLb:setPosition(ccp(icon:getContentSize().width-5,0))
                    icon:addChild(numLb,4)

                    local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                    numBg:setAnchorPoint(ccp(1,0))
                    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                    numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                    numBg:setOpacity(150)
                    icon:addChild(numBg,3)

            	end
        	end
		end
		initRewards(cellBg)
	end
end

function acSmbdDialog:runTankMoveAction(offset)

	if offset == 0 then
	 	do return end	
	else
		if self.switchFlag == false then
			self.switchFlag = true
			local unDisplayPage = self.curTankPage + math.ceil(self.displayTankPage/2)
			if unDisplayPage > self.maxTankPage then
				unDisplayPage = unDisplayPage - self.maxTankPage 
			end

			-- 向右移动
			if offset < 0 then
				offset = offset + 1
				self.tankSpTb[unDisplayPage]:setPosition(ccp(self.leftCfg[1],self.centerPos.y))
				self.tankSpTb[unDisplayPage]:setScale(self.leftCfg[2])
	    		table.insert(self.disPlayPageTb,1,unDisplayPage)
	    		for i=1,self.displayTankPage+1 do
		    		local tankSp = self.tankSpTb[self.disPlayPageTb[i]]
		    		tankSp:setTag(i)
		    		if i == (self.displayTankPage+1) then
		            	targetPos,targetScale=ccp(self.rightCfg[1],self.centerPos.y),self.rightCfg[2]
		        	else
		            	targetPos,targetScale=ccp(self.displayPosCfg[i][1],self.centerPos.y),self.displayPosCfg[i][2]
		        	end
		        	local acArr=CCArray:create()
			        local moveTo=CCMoveTo:create(self.timeInterval,targetPos)
			        local scaleTo=CCScaleTo:create(self.timeInterval,targetScale)
			        acArr:addObject(moveTo)
			        acArr:addObject(scaleTo)
			        local swpanAc=CCSpawn:create(acArr)
			        local function moveCallBack()
			            if i==(self.displayTankPage+1) then
			                self.curTankPage=self.curTankPage-1
			                if self.curTankPage<1 then
			                    self.curTankPage=self.maxTankPage
			                end
			                self:resetDisplayPage()
			                tankSp:setPosition(self.outScreenPos)
			                -- segmentSp:setScale(self.scaleCfg[page])
			                if offset and offset~=0 then
			                    self.switchFlag = false
			                    self:runTankMoveAction(offset)
			                else
			                    self.switchFlag=false
			                    self.tv:reloadData()
			                end
		           		end
			        end
			        local callback=CCCallFunc:create(moveCallBack)
			        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
			        tankSp:runAction(seq)
	    		end
			-- 向左移动
			elseif offset > 0 then
				offset = offset -1
				self.tankSpTb[unDisplayPage]:setPosition(ccp(self.rightCfg[1],self.centerPos.y))
				self.tankSpTb[unDisplayPage]:setScale(self.rightCfg[2])
	    		table.insert(self.disPlayPageTb,unDisplayPage)
	    		for i=1,self.displayTankPage+1 do
		    		local tankSp = self.tankSpTb[self.disPlayPageTb[i]]
		    		if i==1 then
		            	targetPos,targetScale=ccp(self.leftCfg[1],self.centerPos.y),self.leftCfg[2]
		            	tankSp:setTag(self.displayTankPage+1)
		        	else
		            	targetPos,targetScale=ccp(self.displayPosCfg[i-1][1],self.centerPos.y),self.displayPosCfg[i-1][2]
		            	tankSp:setTag(i-1)
		        	end
			        local acArr=CCArray:create()
			        local moveTo=CCMoveTo:create(self.timeInterval,targetPos)
			        local scaleTo=CCScaleTo:create(self.timeInterval,targetScale)
			        acArr:addObject(moveTo)
			        acArr:addObject(scaleTo)
			        local swpanAc=CCSpawn:create(acArr)
			        local function moveCallBack()
			            if i==1 then
			                self.curTankPage=self.curTankPage+1
			                if self.curTankPage > self.maxTankPage then
			                    self.curTankPage=1
			                end
			                self:resetDisplayPage()
			                tankSp:setPosition(self.outScreenPos)
			                if offset and offset~= 0 then
			                    self.switchFlag=false
			                    self:runTankMoveAction(offset)
			                else
			                    self.switchFlag=false
			                    self.tv:reloadData()
			                end
			            end
			        end
			        local callback=CCCallFunc:create(moveCallBack)
			        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
			        tankSp:runAction(seq)
	    		end
			end
		end
	end
end

-- 判断滑动事件所在的不同区域
function acSmbdDialog:judgePos(y)
	if y < G_VisibleSizeHeight - 85 - 60 and y > G_VisibleSizeHeight - 85 - 60 - 150 then
		return 1
	elseif y < G_VisibleSizeHeight - 85 - 366 - 60 and y > G_VisibleSizeHeight - 85 -366- 60 - 120 and self.curTvIdex == 2 then
		return 2
	else
		return false
	end
end

function acSmbdDialog:updatePack( ... )
	self.nameLabel:setVisible(true)
	self.exchangeNumLb:setVisible(true)
	self.nameBg:setVisible(true)
	local nameStr = getlocal("activity_smbd_boxName"..(self.spriteArr[2]-1))
	self.nameLabel:setString(nameStr)
	local rewardIdex = self.spriteArr[2]-1
	local exchangeNum,exchangeLimit = acSmbdVoApi:getExchangeNum(rewardIdex),acSmbdVoApi:getExchangeLimit(rewardIdex)
	self.exchangeNumLb:setString("("..exchangeNum.."/"..exchangeLimit..")")

	local nameLb=GetTTFLabel(nameStr,20)
	local realWidth = nameLb:getContentSize().width
	if realWidth>=self.nameLabel:getContentSize().width then
		realWidth=self.nameLabel:getContentSize().width
	end
	local lbWidth = realWidth+self.exchangeNumLb:getContentSize().width
	self.exchangeNumLb:setVisible(true)
	local posArx = G_getCurChoseLanguage() == "ar" and 10 or 0
	self.nameLabel:setPosition((G_VisibleSizeWidth-lbWidth)/2+realWidth/2,200)
	self.exchangeNumLb:setPosition(self.nameLabel:getPositionX()+realWidth/2+self.exchangeNumLb:getContentSize().width/2 + posArx,200)

	if exchangeNum>=exchangeLimit then
		self.exchangeNumLb:setColor(G_ColorRed)
	else
		self.exchangeNumLb:setColor(G_ColorGreen)
	end

	local rewardIdex = self.spriteArr[2]-1
	if self.numLabel then
		local remainNum = acSmbdVoApi:getRemainExchangeNum(rewardIdex)
		if remainNum == 0 then
			self.rewardNum = 1
		elseif self.rewardNum>remainNum then
			self.rewardNum = remainNum
		end
		self.numLabel:setString(self.rewardNum)
		self.editBox:setText(self.rewardNum)
	end
	self.consumePoint = acSmbdVoApi:getPointCost(rewardIdex)
	if self.point < self.consumePoint*self.rewardNum then
		self.consumePointLabel:setColor(G_ColorRed)
	else
		self.consumePointLabel:setColor(G_ColorYellowPro)
	end
	self.consumePointLabel:setString(self.consumePoint*self.rewardNum)
end

function acSmbdDialog:updatePoint( ... )
	self.point = acSmbdVoApi:getPoint()
	self.pointLabel:setString(self.point)
end

function acSmbdDialog:leftPageHandler( ... )
	self:runTankMoveAction(-1)
end

function acSmbdDialog:rightPageHandler( ... )
	self:runTankMoveAction(1)
end
function acSmbdDialog:tick( ... )
	self:updatePoint()
    self.acTimeLb:setString(acSmbdVoApi:getTimeStr())
end

function acSmbdDialog:initSubTaskPoint()
	for i=1,4 do
		if i == 1 then
			self.subTaskPoint[i] = acSmbdVoApi:getTaskPoint("ky") + acSmbdVoApi:getTaskPoint("jz")
		elseif i == 2 then
			self.subTaskPoint[i] = acSmbdVoApi:getTaskPoint("sc") + acSmbdVoApi:getTaskPoint("gz") + acSmbdVoApi:getTaskPoint("yx")
		elseif i == 3 then
			self.subTaskPoint[i] = acSmbdVoApi:getTaskPoint("zd") + acSmbdVoApi:getTaskPoint("xm") + acSmbdVoApi:getTaskPoint("pj")
		else
			self.subTaskPoint[i] = acSmbdVoApi:getTaskPoint("jb")
		end
	end
end	

function acSmbdDialog:judgeAfford( ... )
	if self.consumePoint * self.rewardNum > self.point then
		return false
	else
		return true
	end
end

function acSmbdDialog:resetDisplayPage( ... )

    self.disPlayPageTb = {}
    local page=self.curTankPage-2
    if page<1 then
        page=page+self.maxTankPage
    end
    for i=1,5 do
        self.disPlayPageTb[i]=page
        local tankSp=self.tankSpTb[page]
        if tankSp then
            if page==self.curTankPage then
                self.removeNode:reorderChild(tankSp,3)
            else
                self.removeNode:reorderChild(tankSp,1)
            end
        end
        page=page+1
        if page>self.maxTankPage then
            page=1
        end
    end
end

--积分消费动画 
function acSmbdDialog:runConsumeLabelAction(rewardShowCallback,rewardNum)

	local acArr=CCArray:create()
    local scaleBigTo=CCScaleTo:create(self.timeInterval,1.5)
    local scaleSmallTo=CCScaleTo:create(self.timeInterval,1)
    acArr:addObject(scaleBigTo)
    acArr:addObject(scaleSmallTo)
    local numScale=CCSequence:create(acArr)

    local function actionLast( ... )
    	local numActLabel = GetTTFLabel("-"..tonumber(rewardNum*self.consumePoint),25,true)
    	numActLabel:setColor(G_ColorRed)
    	numActLabel:setAnchorPoint(ccp(0.5,0.5))
    	numActLabel:setPosition(ccp(self.pointLabel:getPositionX(),10+self.pointLabel:getContentSize().height+20))
    	self.rewardBg:addChild(numActLabel)

		local arr1=CCArray:create()
	    local fadeIn=CCFadeIn:create(0.3)
		local delay=CCDelayTime:create(0.4)
		local fadeOut=CCFadeOut:create(0.3)
		arr1:addObject(fadeIn)
		arr1:addObject(delay)
		arr1:addObject(fadeOut)
		local seque1=CCSequence:create(arr1)

		local arr2=CCArray:create()
		local scaleTo1 = CCScaleTo:create(0.5,2)
	    local scaleTo2 = CCScaleTo:create(0.5,1)
	    arr2:addObject(scaleTo1)
	    arr2:addObject(scaleTo2)
		local seque2=CCSequence:create(arr1)

		local arrAll=CCArray:create()
		local moveBy = CCMoveBy:create(1,CCPointMake(0,50))
		arrAll:addObject(seque1)
		arrAll:addObject(seque2)
		arrAll:addObject(moveBy)
		local sequeAll = CCSpawn:create(arrAll)

	   	local function callBack1( ... )
	   		if rewardShowCallback then
	   			rewardShowCallback()
			end
			numActLabel:removeFromParentAndCleanup(true)
			numActLabel = nil
		end 
		local callFunc = CCCallFunc:create(callBack1)
		local seq2 = CCSequence:createWithTwoActions(sequeAll,callFunc)
		numActLabel:runAction(seq2)
	end

 	local callFunc1=CCCallFunc:create(actionLast)
    local seq1= CCSequence:createWithTwoActions(numScale,callFunc1)
    self:updatePack()
    self.pointLabel:runAction(seq1)

end

function acSmbdDialog:updateTvDesc( ... )
	if self.curTvIdex == 1 then
		self.tvDesLabel:setString(getlocal("activity_smbd_task_desc"))
		self.tvDesLabel:setColor(G_ColorRed)
	elseif self.curTvIdex == 2 then
		self.tvDesLabel:setString(getlocal("activity_smbd_tank_desc"))
		self.tvDesLabel:setColor(G_ColorRed)
	else
		self.tvDesLabel:setString(getlocal("activity_smbd_log_desc"))
		self.tvDesLabel:setColor(G_ColorRed)
	end
end

function acSmbdDialog:dispose( ... )
	spriteController:removePlist("public/acLmqrjImage2.plist")
	spriteController:removePlist("public/juntuanCityBtns.plist")
	spriteController:removePlist("public/believer/believerMain.plist")
	spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
	spriteController:removeTexture("public/acLmqrjImage2.png")
	spriteController:removeTexture("public/juntuanCityBtns.png")
	spriteController:removeTexture("public/believer/believerMain.png")
	self.touchArr={}	
end