ltzdzTab1 ={}
function ltzdzTab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    nc.touchEnable=true
    nc.touchArr={}
    nc.jiange=150 -- 两个战区之间的位置距离
    nc.sbScale=350/454
    if G_getIphoneType() == G_iphoneX then
    	nc.sbScale = 430/530
    end
    nc.sbOpcity=150
    nc.lastState=nil
    nc.seasonRewardState=-1 --赛季奖励的状态
    nc.seasonRewardSpTb={} --赛季任务奖励相关node
   	nc.seasonFlag=true --是否是当前赛季
    return nc
end

function ltzdzTab1:init()
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")

	local clancrossinfo=ltzdzVoApi.clancrossinfo
	self.bnum=clancrossinfo.bnum or 0 -- 刷新用

	self.centerId=ltzdzVoApi:getSegment()
	self.bgLayer=CCLayer:create()
	self:initLayer()

	-- 刷新资源
    local function refreshDialogFunc(event,data)
       self:refreshMain()
    end
    self.refreshListener=refreshDialogFunc
    eventDispatcher:addEventListener("ltzdz.mainRefresh",self.refreshListener)

	-- 刷新赛季任务奖励
    local function refreshSeasonTask(event,data)
       self:refreshSeasonTask()
    end
    self.refreshSeasonTaskListener=refreshSeasonTask
    eventDispatcher:addEventListener("ltzdz.seasonTaskRefresh",self.refreshSeasonTaskListener)

    -- ltzdzVoApi:showSeasonSettle(self.layerNum+1,true,true,nil,{},1)

    -- ltzdzVoApi:showBattleEnd(self.layerNum+1,true,true,nil,{},2)

    -- G_showNewSureSmallDialog(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ltzdz_signUp_expired"),nil)

    --如果当前是定级赛并且还没有报名，则显示报名引导
    if ltzdzVoApi:isQualifying()==true and ltzdzVoApi:getWarState()==1 then
	    if otherGuideMgr:checkGuide(43)==false then
    		otherGuideMgr:showGuide(43)
    	end
    end

	return self.bgLayer
end

function ltzdzTab1:refreshMain()
	local clancrossinfo=ltzdzVoApi.clancrossinfo
	local bnum=clancrossinfo.bnum or 0
	-- print("bnum,self.bnum",bnum,self.bnum)

	self:initUpLayer(true)
	if bnum==self.bnum then
		return
	end

	if self.bnum<1 and bnum>=1 then
		-- 上
		-- print("+++++++++++上")
		self.upBackSprie:removeFromParentAndCleanup(true)
		self.upBackSprie=nil
		self:initTop()

		-- 中
		-- print("+++++++++++中")
		self.centerId=ltzdzVoApi:getSegment()
		self.centerSprie:removeFromParentAndCleanup(true)
		self.centerSprie=nil
		self:initCenter()

		-- 下
		-- print("+++++++++++下")
		self.teamBtn:setVisible(true)
		self.singleBtn:setPosition(G_VisibleSizeWidth/2+120,self.menuPosY)
	else
		-- 上
		self.upBackSprie:removeFromParentAndCleanup(true)
		self.upBackSprie=nil
		self:initTop()

		-- 中
		self.centerId=ltzdzVoApi:getSegment()
		self:resertTheater()
	end

	self:refreshTipSp()
end

function ltzdzTab1:initLayer()
	self:initTop()
	self:initCenter()
	self:initBottom()
	self:initUpLayer()
end

function ltzdzTab1:initTop()

	local clancrossinfo=ltzdzVoApi.clancrossinfo
	local bnum=clancrossinfo.bnum or 0
	local season=clancrossinfo.season or 1

	local upbackSize=CCSizeMake(G_VisibleSizeWidth-40,200)
	local startH=G_VisibleSizeHeight-170

	if(G_isIphone5()==false)then
        upbackSize=CCSizeMake(G_VisibleSizeWidth-40,170)
        startH=G_VisibleSizeHeight-160
    end
	local function sbCallback()
    end
    local upBackSprie =LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),sbCallback)
    upBackSprie:setContentSize(upbackSize)
    self.bgLayer:addChild(upBackSprie)
    upBackSprie:setAnchorPoint(ccp(0.5,1))
    upBackSprie:setPosition(G_VisibleSizeWidth/2,startH)
    self.upBackSprie=upBackSprie

    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setScaleX(3)
    lightSp:setPosition(upBackSprie:getContentSize().width/2,upbackSize.height-40)
    upBackSprie:addChild(lightSp)

    local nameStr=getlocal("serverWarLadderSeasonTitle",{season})

    -- print("++++++++G_curPlatName()",G_curPlatName())
    if G_curPlatName()=="0" or tonumber(base.curZoneID)==997 or tonumber(base.curZoneID)==998 or tonumber(base.curZoneID)==1000 then
    	nameStr=getlocal("serverWarLadderSeasonTitle",{season}) .. clancrossinfo.rpoint
    end

    local nameFontSize=28
    local nameLb=GetTTFLabelWrap(nameStr,nameFontSize,CCSizeMake(320,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0.5,0.5))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(upbackSize.width/2,upbackSize.height-30)
    upBackSprie:addChild(nameLb)
    local nameLb2=GetTTFLabel(nameStr,nameFontSize)
    local realNameW=nameLb2:getContentSize().width
    if realNameW>nameLb:getContentSize().width then
        realNameW=nameLb:getContentSize().width
    end
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX=1
        local posX=upbackSize.width/2-(realNameW/2+20)
        local pointX=-7
        if i==2 then
            anchorX=0
            posX=upbackSize.width/2+(realNameW/2+20)
            pointX=15
        end
        pointSp:setAnchorPoint(ccp(anchorX,0.5))
        pointSp:setPosition(posX,nameLb:getPositionY())
        upBackSprie:addChild(pointSp)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
        pointSp:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end

    local function showSeasonTaskDialog()
    	ltzdzVoApi:showSeasonTaskRewardDialog(self.layerNum+1)
    end
	local pos=ccp(upBackSprie:getContentSize().width-50,(upbackSize.height-50)/2)
	local seasonRewardSp=LuaCCSprite:createWithSpriteFrameName("taskBox5.png",showSeasonTaskDialog)
	seasonRewardSp:setTouchPriority(-(self.layerNum-1)*20-4)
	seasonRewardSp:setPosition(pos)
	seasonRewardSp:setScale(0.7)
	upBackSprie:addChild(seasonRewardSp,3)
    local seasonRewardLb=GetTTFLabel(getlocal("ltzdz_season_reward"),20)
    seasonRewardLb:setAnchorPoint(ccp(0.5,0))
    seasonRewardLb:setPosition(seasonRewardSp:getPositionX(),seasonRewardSp:getPositionY()-50)
    upBackSprie:addChild(seasonRewardLb,4)
    self.seasonRewardSp=seasonRewardSp
	-- local sflag=ltzdzVoApi:isThisSeason()
	-- if sflag==false then
	-- 	ltzdzVoApi:clearSeasonTaskState()
	-- end
   	self:refreshSeasonTask()

    -- bnum=1
    if bnum<1 then
    	local qualifyLb=GetTTFLabelWrap(getlocal("ltzdz_qualify_des"),25,CCSizeMake(upbackSize.width-20-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    	upBackSprie:addChild(qualifyLb)
    	qualifyLb:setAnchorPoint(ccp(0,0.5))
    	qualifyLb:setPosition(20,(upbackSize.height-40)/2)
    else
    	local function touchSetInfo()
	    	if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			-- print("段位信息展示")
			ltzdzVoApi:showPlayerInfoDialog(self.layerNum+1)
	    end
	    local sbBackSprite =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchSetInfo)
	    sbBackSprite:setContentSize(CCSizeMake(upbackSize.width-100,upbackSize.height-50))
	    upBackSprie:addChild(sbBackSprite)
	    sbBackSprite:setAnchorPoint(ccp(0,0))
	    sbBackSprite:setPosition(0,0) 
	    sbBackSprite:setTouchPriority(-(self.layerNum-1)*20-4)
	    sbBackSprite:setOpacity(0)

	    local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
	    local setX=60
	    local function touchSeg()
	    end
	    local iconScale=0.6
	    local segIcon=ltzdzVoApi:getSegIcon(seg,smallLevel,touchSeg)
	    segIcon:setScale(iconScale)
	    sbBackSprite:addChild(segIcon)
	    segIcon:setPosition(setX+30,sbBackSprite:getContentSize().height/2+10)
	    -- ltzdz_mySegName
	    local segName=ltzdzVoApi:getSegName(seg,smallLevel)
	    local mySegName=getlocal("ltzdz_mySegName",{segName})
	    -- local segLb=GetTTFLabel(segName,25)
	    -- sbBackSprite:addChild(segLb)
	    -- segLb:setAnchorPoint(ccp(0,0.5))
	    -- segLb:setPosition(setX+60,sbBackSprite:getContentSize().height/2+20)
	    local myRankLb,lbHeight=G_getRichTextLabel(mySegName,{G_ColorWhite,G_ColorYellowPro},25,G_VisibleSizeWidth*0.4,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
        myRankLb:setAnchorPoint(ccp(0,0.5))
        myRankLb:setPosition(setX+120,sbBackSprite:getContentSize().height/2+30)
        sbBackSprite:addChild(myRankLb)

	    -- 进度条
	    local perNum,proStr=ltzdzVoApi:getNextSegInfo()
	    local percent=perNum
	    AddProgramTimer(sbBackSprite,ccp(0,0),518,nil,nil,"res_progressbg.png","resyellow_progress.png",519)
	            
	    local powerBar = tolua.cast(sbBackSprite:getChildByTag(518),"CCProgressTimer")
	    local setScaleX=250/powerBar:getContentSize().width
	    local setScaleY=30/powerBar:getContentSize().height
	    powerBar:setScaleX(setScaleX)
	    powerBar:setScaleY(setScaleY)
	    powerBar:setAnchorPoint(ccp(0,0.5))
	    powerBar:setPosition(ccp(setX+120,sbBackSprite:getContentSize().height/2-30))
	    powerBar:setPercentage(percent)

	    local powerBarBg=tolua.cast(sbBackSprite:getChildByTag(519),"CCSprite")
	    powerBarBg:setScaleX(setScaleX)
	    powerBarBg:setScaleY(setScaleY)
	    powerBarBg:setAnchorPoint(ccp(0,0.5))
	    powerBarBg:setPosition(ccp(setX+120,sbBackSprite:getContentSize().height/2-30))

	    local percentLb=GetTTFLabel(proStr,23)
	    percentLb:setAnchorPoint(ccp(0.5,0.5))
	    percentLb:setPosition(powerBar:getContentSize().width/2,powerBar:getContentSize().height/2)
	    powerBar:addChild(percentLb,4)
	    percentLb:setScaleX(1/setScaleX)
	    percentLb:setScaleY(1/setScaleY)
    end

end

function ltzdzTab1:refreshSeasonTask()
	local cur,max,state=ltzdzVoApi:getSeasonTaskState("t1")
	if state~=self.seasonRewardState then
		self.seasonRewardSp:stopAllActions()
		for k,sprite in pairs(self.seasonRewardSpTb) do
			sprite=tolua.cast(sprite,"CCNode")
			if sprite then
				sprite:removeFromParentAndCleanup(true)
			end
		end
		self.seasonRewardSpTb={}
		self.seasonRewardState=state
		if state==1 then --可以领取
	        for i=1,2 do
	          local realLight=CCSprite:createWithSpriteFrameName("equipShine.png")
	          realLight:setAnchorPoint(ccp(0.5,0.5))
	          realLight:setScale(0.9)
	          realLight:setPosition(self.seasonRewardSp:getPosition())
	          self.upBackSprie:addChild(realLight)
	          local roteSize=i==1 and 360 or -360
	          local rotate1=CCRotateBy:create(4, roteSize)
	          local repeatForever=CCRepeatForever:create(rotate1)
	          realLight:runAction(repeatForever)
	          table.insert(self.seasonRewardSpTb,realLight)
	        end

	        local time=0.1
	        local rotate1=CCRotateTo:create(time, 30)
	        local rotate2=CCRotateTo:create(time, -30)
	        local rotate3=CCRotateTo:create(time, 20)
	        local rotate4=CCRotateTo:create(time, -20)
	        local rotate5=CCRotateTo:create(time, 0)
	        local delay=CCDelayTime:create(1)
	        local acArr=CCArray:create()
	        acArr:addObject(rotate1)
	        acArr:addObject(rotate2)
	        acArr:addObject(rotate3)
	        acArr:addObject(rotate4)
	        acArr:addObject(rotate5)
	        acArr:addObject(delay)
	        local seq=CCSequence:create(acArr)
	        local repeatForever=CCRepeatForever:create(seq)
	        self.seasonRewardSp:runAction(repeatForever)
	    elseif state==2 then --已领取
			local lbBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
	        lbBg:setScaleX(100/lbBg:getContentSize().width)
	        lbBg:setScaleY(30/lbBg:getContentSize().height)
	        lbBg:setPosition(self.seasonRewardSp:getPosition())
	        self.upBackSprie:addChild(lbBg,4)
	        local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),18)
			hasRewardLb:setPosition(self.seasonRewardSp:getPosition())
			hasRewardLb:setColor(G_ColorGray)
			self.upBackSprie:addChild(hasRewardLb,5)
        	table.insert(self.seasonRewardSpTb,lbBg)
        	table.insert(self.seasonRewardSpTb,hasRewardLb)
		end
	end
end

function ltzdzTab1:initCenter()

	local clancrossinfo=ltzdzVoApi.clancrossinfo
	local bnum=clancrossinfo.bnum or 0
	-- bnum=0

	local centerStratH=self.upBackSprie:getPositionY()-self.upBackSprie:getContentSize().height-10
	local centerSize=CCSizeMake(G_VisibleSizeWidth,centerStratH-120-60-40)
	if(G_isIphone5()==false)then
        centerSize=CCSizeMake(G_VisibleSizeWidth,centerStratH-120-60-30)
    end
	local function sbCallback()
    end
    local centerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),sbCallback)
    centerSprie:setContentSize(centerSize)
    self.bgLayer:addChild(centerSprie)
    centerSprie:setAnchorPoint(ccp(0.5,1))
    centerSprie:setPosition(G_VisibleSizeWidth/2,centerStratH)
    self.centerSprie=centerSprie

    self.upLimitY=centerSprie:getPositionY()
    self.downLimitY=self.upLimitY-centerSize.height


    local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp1:setPosition(centerSize.width/2,centerSize.height)
    centerSprie:addChild(lineSp1,5)
    lineSp1:setScaleX(centerSize.width/lineSp1:getContentSize().width)

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setPosition(centerSize.width/2,0)
    centerSprie:addChild(lineSp2,5)
    lineSp2:setScaleX(centerSize.width/lineSp2:getContentSize().width)

    local fragScale=1
    -- 激活坦克背景
    local leftPosx=20
    local rightPosx=centerSprie:getContentSize().width-leftPosx
    local leftFrameBg2=CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    leftFrameBg2:setAnchorPoint(ccp(0,0.5))
    leftFrameBg2:setPosition(ccp(leftPosx,centerSprie:getContentSize().height/2))
    centerSprie:addChild(leftFrameBg2,1)

    if(G_isIphone5()==false)then
        fragScale=centerSprie:getContentSize().height/leftFrameBg2:getContentSize().height
    end
    leftFrameBg2:setScale(fragScale)

    local rightFrameBg2=CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    rightFrameBg2:setFlipX(true)
    rightFrameBg2:setFlipY(true)
    rightFrameBg2:setAnchorPoint(ccp(1,0.5))
    rightFrameBg2:setPosition(ccp(rightPosx,centerSprie:getContentSize().height/2))
    centerSprie:addChild(rightFrameBg2,1)
    rightFrameBg2:setScale(fragScale)

    local leftFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0,0.5))
    leftFrameBg1:setPosition(ccp(leftPosx,centerSprie:getContentSize().height/2))
    centerSprie:addChild(leftFrameBg1,1)
    leftFrameBg1:setScale(fragScale)

    local rightFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1,0.5))
    rightFrameBg1:setPosition(ccp(rightPosx,centerSprie:getContentSize().height/2))
    centerSprie:addChild(rightFrameBg1,1)
    rightFrameBg1:setScale(fragScale)


    local troopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("st_background.png",CCRect(5, 5, 1, 1),function ()end)
    centerSprie:addChild(troopsBg)
    -- troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-55,rightFrameBg1:getContentSize().height))
    troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,centerSprie:getContentSize().height))
    troopsBg:setPosition(getCenterPoint(centerSprie))

    centerSprie:setOpacity(0)

    -- print("bnumbnumbnumbnum",bnum)
    if bnum<1 then
    	local function touchDialogBg()
		end
		local adaptSize = CCSizeMake(454,302)
		local descLocation = 15
		if G_getIphoneType() == G_iphoneX then
			adaptSize = CCSizeMake(530,350)
			descLocation = 20
		end
		local dialogBg=G_getNewDialogBg3(adaptSize,getlocal("ltzdz_qualify_title"),25,touchDialogBg,self.layerNum,nil,nil,G_ColorBlue)
		dialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
		centerSprie:addChild(dialogBg,3)
		dialogBg:setPosition(centerSprie:getContentSize().width/2,centerSprie:getContentSize().height/2)
		local dialogSize=dialogBg:getContentSize()

		local jpgBg=CCSprite:createWithSpriteFrameName("ltzdz_segbg_0.jpg")
		dialogBg:addChild(jpgBg)
		jpgBg:setAnchorPoint(ccp(0.5,1))
		jpgBg:setPosition(dialogSize.width/2,dialogSize.height-40)

		if G_getIphoneType() == G_iphoneX then
			jpgBg:setScaleX(530/454)
			jpgBg:setScaleY((350-40-descLocation)/(302-40-descLocation))
		end

		local desStr=getlocal("ltzdz_qualify_des")
		local desLb=GetTTFLabelWrap(desStr,22,CCSizeMake(dialogSize.width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		desLb:setAnchorPoint(ccp(0.5,0))
		-- desLb:setColor(G_ColorYellowPro)
		dialogBg:addChild(desLb)
		desLb:setPosition(dialogSize.width/2,descLocation)


		local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
		mLine:setPosition(ccp(dialogBg:getContentSize().width/2,20))
		mLine:setContentSize(CCSizeMake(dialogBg:getContentSize().width-10,mLine:getContentSize().height))
		dialogBg:addChild(mLine)
	    if ltzdzVoApi:isQualifying()==true and ltzdzVoApi:getWarState()==1 then
		    if otherGuideMgr:checkGuide(43)==false then
		    	otherGuideMgr:setGuideStepField(43,nil,nil,{dialogBg,1})
		    end
		end
    else

    	--下面的滑动区域

	    local nodeSize=CCSizeMake(centerSize.width,centerSize.height-10)
		local clipperNode=CCClippingNode:create()

		local stencil=CCDrawNode:getAPolygon(nodeSize,1,1)
		stencil:setPosition(0,0)
		clipperNode:setStencil(stencil)

		clipperNode:setAnchorPoint(ccp(0.5,1))
		clipperNode:setContentSize(nodeSize)
		self.bgLayer:addChild(clipperNode)
		clipperNode:setPosition(ccp(G_VisibleSizeWidth/2,centerStratH-5))



		self.clipperNode=clipperNode

		self.theaterTb={}
		for i=1,6 do
			local function touchDialogBg()
				-- print("touchDialogBg")
			end
			local adaptSize = CCSizeMake(454,302)
			local descLocation = 15
			if G_getIphoneType() == G_iphoneX then
				adaptSize = CCSizeMake(530,350)
				descLocation = 20
			end
			local dialogBg=G_getNewDialogBg3(adaptSize,getlocal("ltzdz_theater" .. i),25,touchDialogBg,self.layerNum,nil,nil,G_ColorBlue)
			dialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
			clipperNode:addChild(dialogBg)
			-- dialogBg:setPosition(clipperNode:getContentSize().width/2,clipperNode:getContentSize().height/2)
			self.theaterTb[i]=dialogBg
			local dialogSize=dialogBg:getContentSize()

			local jpgBg=CCSprite:createWithSpriteFrameName("ltzdz_segbg_" .. i .. ".jpg")
			dialogBg:addChild(jpgBg)
			jpgBg:setAnchorPoint(ccp(0.5,1))
			jpgBg:setPosition(dialogSize.width/2,dialogSize.height-40)
			if G_getIphoneType() == G_iphoneX then
			 	jpgBg:setScaleX(530/454)
			 	jpgBg:setScaleY((350-40-descLocation)/(302-40-descLocation))
			end

			local childSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
			childSp:setContentSize(dialogBg:getContentSize())
			childSp:setOpacity(180)
			childSp:setPosition(getCenterPoint(dialogBg))

			dialogBg:addChild(childSp,10)
			childSp:setTag(110)

			local desStr=ltzdzVoApi:getTheaterDes(i)
			local desLb=GetTTFLabelWrap(desStr,22,CCSizeMake(dialogSize.width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
			desLb:setAnchorPoint(ccp(0.5,0))
			-- desLb:setColor(G_ColorYellowPro)
			desLb:setTag(112)
			dialogBg:addChild(desLb)
			desLb:setPosition(dialogSize.width/2,descLocation)
			if self.centerId>i then --已解锁
				desLb:setColor(G_ColorGray)
			elseif self.centerId<i then --未解锁
				desLb:setColor(G_ColorRed)
				local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png") --锁
				lockSp:setPosition(dialogSize.width/2,80)
				lockSp:setTag(116)
				dialogBg:addChild(lockSp,2)
				local shadeSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end) --黑色遮罩
				shadeSp:setContentSize(jpgBg:getContentSize())
				shadeSp:setAnchorPoint(ccp(0.5,1))
				if G_getIphoneType() == G_iphoneX then
					shadeSp:setScaleX(530/454)
			 		shadeSp:setScaleY((350-40-descLocation)/(302-40-descLocation))
				end
				-- shadeSp:setOpacity(180)
				shadeSp:setPosition(jpgBg:getPosition())
				shadeSp:setTag(118)
				dialogBg:addChild(shadeSp,1)
			end
			local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
			mLine:setPosition(ccp(dialogBg:getContentSize().width/2,20))
			mLine:setContentSize(CCSizeMake(dialogBg:getContentSize().width-10,mLine:getContentSize().height))
			dialogBg:addChild(mLine)
		end
		self:resertTheater()

		-- 触摸滑动
		local touchLayer=CCLayer:create()
	    self.bgLayer:addChild(touchLayer,1)
	    touchLayer:setTouchEnabled(true)
	    touchLayer:setBSwallowsTouches(false)
	    
	    local function tmpHandler(...)
	       return self:touchEvent(...)
	    end
	    touchLayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-3,true)
	    touchLayer:setTouchPriority(-(self.layerNum-1)*20-3)
    end

    

end

function ltzdzTab1:touchEvent(fn,x,y,touch)
	if fn=="began" then
		if self.touchEnable==false then
			return false
		end
		if y>self.upLimitY or y<self.downLimitY then
			return false
		end
		table.insert(self.touchArr,touch)
		if SizeOfTable(self.touchArr)>1 then
			self.touchArr={}
			return false
		end
		self.startPos=ccp(x,y)
		-- print("++++++++began",x,y)
		return true
	elseif fn=="moved" then
		self.lastMovePosY=self.nowMovePosY or self.startPos.y
		self.nowMovePosY=y
		if math.abs(self.nowMovePosY-self.startPos.y)>=self.jiange then
			self.nowMovePosY=self.lastMovePosY
		end

		local subY=self.nowMovePosY-self.lastMovePosY
		self:moveTheater(subY)
	elseif fn=="ended" then
		-- print("fn,x,y,touch end",fn,x,y,touch)
		self.touchArr={}
		self.lastMovePosY=nil
		self.nowMovePosY=nil

		if self.startPos.y==y then
			self.touchEnable=true
			-- print("++++++++没移动")
			return 
		elseif math.abs(self.startPos.y-y)<75 then
			self.touchEnable=false
			-- 复原（缓动）记得缓动之后重置（self.touchEnable=true）
			-- print("++++++++<50")
			self:endTheater(1)
		else
			self.touchEnable=false
			-- 切换（缓动）记得缓动之后重置（self.touchEnable=true）
			if y-self.startPos.y>0 then
				self:endTheater(2)
				-- print("2222222")
			else
				-- print("333333333")
				self:endTheater(3)
			end
		end
	else
		self.touchArr={}
		self.lastMovePosY=nil
		self.nowMovePosY=nil
	end
end

function ltzdzTab1:updateId()
	self.downId=self:getNeedId(self.centerId-1)
	self.upId=self:getNeedId(self.centerId+1)

	-- 刷新按钮
	self:refreshBtn()
	
end


function ltzdzTab1:getNeedId(inialId)
	if inialId<1 then
		return 6
	end
	if inialId>6 then
		return 1
	end
	return inialId
end

function ltzdzTab1:getDisplayPos()
	local centerPos=ccp(self.clipperNode:getContentSize().width/2,self.clipperNode:getContentSize().height/2)
	local upPos=ccp(centerPos.x,centerPos.y+self.jiange)
	local downPos=ccp(centerPos.x,centerPos.y-self.jiange)
	-- print("centerPos,upPos,downPos",centerPos.y,upPos.y,downPos.y)
	return centerPos,upPos,downPos
end


function ltzdzTab1:resertTheater()
	local mySeg=ltzdzVoApi:getSegment()
	local centerPos,upPos,downPos=self:getDisplayPos()

	self.downId=self:getNeedId(self.centerId+1)
	self.upId=self:getNeedId(self.centerId-1)
	
	for k,v in pairs(self.theaterTb) do
		local child=tolua.cast(v:getChildByTag(110),"LuaCCScale9Sprite")
		if k==self.centerId then
			v:setPosition(centerPos)
			v:setScale(1)
			self.clipperNode:reorderChild(v,3)
			if child then
				child:setOpacity(0)
			end
		elseif k==self.downId then
			v:setPosition(downPos)
			v:setScale(self.sbScale)
			self.clipperNode:reorderChild(v,1)
			if child then
				child:setOpacity(self.sbOpcity)
			end
		elseif k==self.upId then
			v:setPosition(upPos)
			v:setScale(self.sbScale)
			self.clipperNode:reorderChild(v,1)
			if child then
				child:setOpacity(self.sbOpcity)
			end
		else
			v:setPosition(upPos.x,upPos.y+100000)
		end
		local desLb=tolua.cast(v:getChildByTag(112),"CCLabelTTF")
		local lockSp=tolua.cast(v:getChildByTag(116),"CCSprite")
		local shadeSp=tolua.cast(v:getChildByTag(118),"LuaCCScale9Sprite")
		if desLb then
			local desColor=G_ColorWhite
			if mySeg>k then --已解锁
				desColor=G_ColorGray
			elseif mySeg<k then --未解锁
				desColor=G_ColorRed
			end
			desLb:setColor(desColor)
			if mySeg>=k then
				if lockSp then
					lockSp:removeFromParentAndCleanup(true)
					lockSp=nil
				end
				if shadeSp then
					shadeSp:removeFromParentAndCleanup(true)
					shadeSp=nil
				end
			end
		end
	end
end

function ltzdzTab1:moveTheater(subY)
	local centerPos,upPos,downPos=self:getDisplayPos()

	-- 位置
	local posY1=self.theaterTb[self.centerId]:getPositionY()
	self.theaterTb[self.centerId]:setPositionY(posY1+subY)
	local posY2=self.theaterTb[self.downId]:getPositionY()
	self.theaterTb[self.downId]:setPositionY(posY2+subY)
	local posY3=self.theaterTb[self.upId]:getPositionY()
	self.theaterTb[self.upId]:setPositionY(posY3+subY)

	local disY1=posY1+subY-centerPos.y
	local disY2=posY2+subY-downPos.y
	local disY3=posY3+subY-upPos.y

	-- 缩放
	local xishu1=math.abs(disY1)/self.jiange*(1-self.sbScale)
	self.theaterTb[self.centerId]:setScale(1-xishu1)

	local xishu2=disY2/self.jiange*(1-self.sbScale)
	self.theaterTb[self.downId]:setScale(self.sbScale+xishu2)

	local xishu3=disY3/self.jiange*(1-self.sbScale)
	self.theaterTb[self.upId]:setScale(self.sbScale-xishu3)

	-- 透明度
	local chidSp1=self.theaterTb[self.centerId]:getChildByTag(110)
	if chidSp1 and chidSp1.setOpacity then
		local opcity1=math.abs(disY1)/self.jiange*self.sbOpcity
		chidSp1:setOpacity(opcity1)
	end
	
	local chidSp2=self.theaterTb[self.downId]:getChildByTag(110)
	if chidSp2 and chidSp2.setOpacity then
		local opcity2=disY2/self.jiange*self.sbOpcity
		chidSp2:setOpacity(self.sbOpcity-opcity2)
	end
	
	local chidSp3=self.theaterTb[self.upId]:getChildByTag(110)
	if chidSp3 and chidSp3.setOpacity then
		local opcity3=disY3/self.jiange*self.sbOpcity
		chidSp3:setOpacity(self.sbOpcity-opcity3)
	end

	if math.abs(disY1)>self.jiange/2 then
		if disY1>0 then
			self.clipperNode:reorderChild(self.theaterTb[self.centerId],2)
			self.clipperNode:reorderChild(self.theaterTb[self.downId],3)
			self.clipperNode:reorderChild(self.theaterTb[self.upId],1)
		else
			self.clipperNode:reorderChild(self.theaterTb[self.centerId],2)
			self.clipperNode:reorderChild(self.theaterTb[self.downId],1)
			self.clipperNode:reorderChild(self.theaterTb[self.upId],3)
		end
	else
		self.clipperNode:reorderChild(self.theaterTb[self.centerId],3)
		self.clipperNode:reorderChild(self.theaterTb[self.downId],1)
		self.clipperNode:reorderChild(self.theaterTb[self.upId],1)
	end

end

-- flag 1:归位 2：向上移动 3：向下移动
function ltzdzTab1:endTheater(flag)
	local centerPos,upPos,downPos=self:getDisplayPos()

	local targetPosY1,targetPosY2,targetPosY3
	if flag==1 then
		targetPosY1,targetPosY2,targetPosY3=centerPos.y,upPos.y,downPos.y
	elseif flag==2 then
		targetPosY1=centerPos.y+self.jiange
		targetPosY2=upPos.y+self.jiange
		targetPosY3=downPos.y+self.jiange
	elseif flag==3 then
		targetPosY1=centerPos.y-self.jiange
		targetPosY2=upPos.y-self.jiange
		targetPosY3=downPos.y-self.jiange
	end
	local nowPosY1,nowPosY2,nowPosY3
	nowPosY1=self.theaterTb[self.centerId]:getPositionY()
	nowPosY2=self.theaterTb[self.upId]:getPositionY()
	nowPosY3=self.theaterTb[self.downId]:getPositionY()


	local speed=1000 --速度
	local time1=math.abs((targetPosY1-nowPosY1)/speed)
	local time2=math.abs((targetPosY2-nowPosY2)/speed)
	local time3=math.abs((targetPosY3-nowPosY3)/speed)

	local moveTo1=CCMoveTo:create(time1,CCPointMake(self.theaterTb[self.centerId]:getPositionX(),targetPosY1))
	local moveTo2=CCMoveTo:create(time2,CCPointMake(self.theaterTb[self.upId]:getPositionX(),targetPosY2))
	local moveTo3=CCMoveTo:create(time3,CCPointMake(self.theaterTb[self.downId]:getPositionX(),targetPosY3))

	local function updeteFunc()
		self.theaterTb[self.centerId]:stopAllActions()
		self.theaterTb[self.upId]:stopAllActions()
		self.theaterTb[self.downId]:stopAllActions()

		if flag==2 then
			self.centerId=self:getNeedId(self.centerId+1)
		elseif flag==3 then
			self.centerId=self:getNeedId(self.centerId-1)
		end
		self:updateId()
		self:resertTheater()
		self.touchEnable=true
	end
	local refreshFunc=CCCallFunc:create(updeteFunc)
	local acArr=CCArray:create()
	acArr:addObject(moveTo1)
	acArr:addObject(refreshFunc)
	local seq=CCSequence:create(acArr)


	self.theaterTb[self.centerId]:runAction(seq)
	self.theaterTb[self.upId]:runAction(moveTo2)
	self.theaterTb[self.downId]:runAction(moveTo3)


end



function ltzdzTab1:initBottom()

	local menuPosY=70
	self.menuPosY=menuPosY
	local btnScale=1
	local btnlbSize=25
	local function touchTeamFunc()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		if ltzdzVoApi:todayBattleIsOver() then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_only_one_battle",{1}),30)
			return
		end

		if ltzdzVoApi:getWarState()==1 then
			local flag,curDuan=ltzdzVoApi:canSignTime()
			-- flag=1
			if flag==0 then
				local openTime=ltzdzVoApi.openTime
			    local openStr = string.format("%02d:%02d",openTime[1][1],openTime[1][2])
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_signUp_expired",{openStr}),30)
				return
			end
			ltzdzVoApi:showCampaign(self.layerNum+1,1)

			local tipSp=tolua.cast(self.teamItem:getChildByTag(101),"CCSprite")
			if tipSp then
				tipSp:setVisible(false)
			end

		end
		
	end
	local teamItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchTeamFunc,nil,getlocal("ltzdz_team_limitTips",{ltzdzVoApi:getTeamNum()}),btnlbSize/btnScale)
	local tipSp = CCSprite:createWithSpriteFrameName("NumBg.png")
	teamItem:addChild(tipSp)
	tipSp:setPosition(teamItem:getContentSize().width-tipSp:getContentSize().width/2-5,teamItem:getContentSize().height-tipSp:getContentSize().height/2)
	tipSp:setScale(1/btnScale)
	tipSp:setTag(101)

	

    local teamBtn=CCMenu:createWithItem(teamItem)
    teamBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    teamItem:setScale(btnScale)
    teamBtn:setPosition(G_VisibleSizeWidth/2-120,menuPosY)
    self.bgLayer:addChild(teamBtn)
    self.teamItem=teamItem
    self.teamBtn=teamBtn

    self:refreshTipSp()

    local function touchSingleFunc()
    	if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
        if otherGuideMgr.isGuiding and otherGuideMgr.curStep==43 then
            otherGuideMgr:toNextStep()
        end
		-- print("ltzdzVoApi:getWarState()",ltzdzVoApi:getWarState(),ltzdzVoApi:stepState())
		if ltzdzVoApi:todayBattleIsOver() then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_only_one_battle",{1}),30)
			return
		end
		if ltzdzVoApi:getWarState()==1 then
			local flag,curDuan=ltzdzVoApi:canSignTime()
			-- flag=1
			if flag==0 then
				    local openTime=ltzdzVoApi.openTime
				    local openStr = string.format("%02d:%02d",openTime[1][1],openTime[1][2])
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_signUp_expired",{openStr}),30)
				return
			end
			local function directBattle()
				ltzdzVoApi:showCampaign(self.layerNum+1,2)
			end

			if ltzdzVoApi:stepState()==2 then
				local clancrossinfo=ltzdzVoApi.clancrossinfo
				local invite=clancrossinfo.invite
				local invitelist=clancrossinfo.invitelist
				local proptStr=getlocal("ltzdz_invite_war_attention1")
				if (invite and invite.uid) or (invitelist and SizeOfTable(invitelist)~=0) then
					proptStr=getlocal("ltzdz_invite_war_attention2")
				end
				G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),proptStr,false,directBattle,nil,nil)
			else
				directBattle()
			end
		end
		
	end
	local singleItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchSingleFunc,nil,getlocal("ltzdz_campaign"),btnlbSize/btnScale)
    local singleBtn=CCMenu:createWithItem(singleItem)
    singleBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    singleItem:setScale(btnScale)
    singleBtn:setPosition(G_VisibleSizeWidth/2+120,menuPosY)
    self.bgLayer:addChild(singleBtn)
    self.singleItem=singleItem
    self.singleBtn=singleBtn

    local function touchBattleFunc()
    	if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		if ltzdzVoApi:todayBattleIsOver() then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_only_one_battle",{1}),30)
			return
		end
		-- 进入战场
		require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
		ltzdzFightApi:showMap(self.layerNum+1)
	end
	local battleItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchBattleFunc,nil,getlocal("returnWarField"),btnlbSize/btnScale)
    local battleBtn=CCMenu:createWithItem(battleItem)
    battleBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    battleItem:setScale(btnScale)
    battleBtn:setPosition(G_VisibleSizeWidth/2,menuPosY)
    self.bgLayer:addChild(battleBtn)
    self.battleItem=battleItem

    
    self:refreshBtn()

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth/2,menuPosY+60))
    mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)

    local clancrossinfo=ltzdzVoApi.clancrossinfo
	local bnum=clancrossinfo.bnum or 0
	if bnum<1 then
		self.teamBtn:setVisible(false)
		self.singleBtn:setPosition(G_VisibleSizeWidth/2,menuPosY)
	end

    -- 倒计时
    local countDY=menuPosY+40+30
    local countDownLb1=GetTTFLabelWrap("",25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	countDownLb1:setAnchorPoint(ccp(0.5,0.5))
	countDownLb1:setPosition(self.bgLayer:getContentSize().width/2,countDY)
	self.bgLayer:addChild(countDownLb1)
	countDownLb1:setColor(G_ColorGreen)
	self.countDownLb1=countDownLb1

	self.countDownLb2Posy=countDY+40
	-- local countDownLb2=GetTTFLabelWrap("",25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- countDownLb2:setAnchorPoint(ccp(0.5,0.5))
	-- countDownLb2:setPosition(self.bgLayer:getContentSize().width/2,countDY+40)
	-- self.bgLayer:addChild(countDownLb2)
	-- -- countDownLb2:setColor(G_ColorGreen)
	-- self.countDownLb2=countDownLb2

	-- local myRankLb,lbHeight=G_getRichTextLabel(mySegName,{G_ColorWhite,G_ColorYellowPro},25,G_VisibleSizeWidth*0.4,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
 --        myRankLb:setAnchorPoint(ccp(0,0.5))
 --        myRankLb:setPosition(setX+60,sbBackSprite:getContentSize().height/2+30)
 --        sbBackSprite:addChild(myRankLb)

 	self.lastState=-1 -- 默认，先刷新一次
 	local state=ltzdzVoApi:getWarState()
	self:refreshDownLb(state)
	self.lastState=state


    local function touchTip()
       	ltzdzVoApi:showHelpDialog(self.layerNum+1)
    end

    local pos=ccp(self.bgLayer:getContentSize().width-70,countDY+20)
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,nil,nil,1,nil,touchTip,true)

    if ltzdzVoApi:isQualifying()==true and ltzdzVoApi:getWarState()==1 then
	    if otherGuideMgr:checkGuide(43)==false then
	    	otherGuideMgr:setGuideStepField(43,singleItem)
	    end
	end
end

function ltzdzTab1:refreshBtn()
	-- print("ltzdzVoApi:stepState()",ltzdzVoApi:stepState(),ltzdzVoApi:getWarState())

	if ltzdzVoApi:getWarState()~=1 then
		self.battleItem:setVisible(true)
		self.battleItem:setEnabled(true)

		self.singleItem:setVisible(false)
		self.singleItem:setEnabled(false)
		self.teamItem:setVisible(false)
		self.teamItem:setEnabled(false)
	else
		self.battleItem:setVisible(false)
		self.battleItem:setEnabled(false)

		self.singleItem:setVisible(true)
		self.singleItem:setEnabled(true)
		if ltzdzVoApi:getTeamNum() > 0 then
			self.teamItem:setVisible(true)
			self.teamItem:setEnabled(true)
		else
			-- self.teamItem:setVisible(false)
			self.teamItem:setEnabled(false)
		end
	end

	if self.centerId and self.centerId~=ltzdzVoApi:getSegment() then
		self.battleItem:setEnabled(false)
		self.singleItem:setEnabled(false)
		self.teamItem:setEnabled(false)
	end
end


function ltzdzTab1:addTV()
	local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function ltzdzTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then	 	
        return 0
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-40,200)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function ltzdzTab1:removeCountDownLb2()
	if self.countDownLb2 then
		self.countDownLb2:removeFromParentAndCleanup(true)
		self.countDownLb2=nil
	end
end
function ltzdzTab1:addCountDownLb2(lbStr,colorTb)
	self.countDownLb2=G_getRichTextLabel(lbStr,colorTb,25,500,kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,0)
	self.countDownLb2:setAnchorPoint(ccp(0.5,0.5))
	self.countDownLb2:setPosition(self.bgLayer:getContentSize().width/2,self.countDownLb2Posy)
	self.bgLayer:addChild(self.countDownLb2)
end

function ltzdzTab1:refreshDownLb(state)

	local updateFlag=false
	if self.lastState and self.lastState~=state then
		updateFlag=true
	end

	if updateFlag then
		self:removeCountDownLb2()
	end
	
	-- print("statestatestatestate",state)
	-- 倒计时
	if state==1 then
		if ltzdzVoApi:todayBattleIsOver() then
			if not self.todayOverFlag then
				self.countDownLb1:setString("")
				self:removeCountDownLb2()
				local colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
				local lbStr=getlocal("ltzdz_only_one_battle",{"<rayimg>1/1<rayimg>"})
				self:addCountDownLb2(lbStr,colorTb)
				self.todayOverFlag=true
			end
			
			return
		end

		if ltzdzVoApi:isAtEndDay() == true then
			local joinFlag, flag = ltzdzVoApi:isJoinFinalBattleAtToday()
			if joinFlag == false and flag == 2 then
				self.countDownLb1:setString("")
				self:removeCountDownLb2()
				do return end
			end
		end
		self.todayOverFlag=false

		local flag,curDuan,curEndTime,lastTime=ltzdzVoApi:canSignTime()

		local timeTb=ltzdzVoApi.openTime[curDuan]
		if curDuan==0 then
			timeTb=ltzdzVoApi.openTime[1]
		end
		-- print("+++++flag,curDuan",flag,curDuan)

		local time=timeTb[1] * 3600 + timeTb[2] * 60+G_getWeeTs(base.serverTime)
		local time=time-base.serverTime
		if curDuan==0 then
			time=time+3600*24
		end

		local timeFlag
		if time<0 then
			timeFlag=false
		else
			timeFlag=true
		end

		-- print("self.signUpFlag,flag,self.timeFlag,timeFlag",self.signUpFlag,flag,self.timeFlag,timeFlag)

		if updateFlag or self.signUpFlag==nil or self.signUpFlag~=flag or self.timeFlag==nil or self.timeFlag~=timeFlag then
			self.signUpFlag=flag
			self.timeFlag=timeFlag
			self:removeCountDownLb2()

			local time1 = string.format("%02d:%02d",timeTb[1],timeTb[2])
			local lbStr
			local colorTb
			-- print("timetimetimetime",time)
			if time<0 then
				colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite,G_ColorYellowPro,G_ColorWhite}

				lbStr=getlocal("ltzdz_battle_start_des2",{time1})
			else
				colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
				lbStr=getlocal("ltzdz_battle_start_des1",{time1})
			end
			self:addCountDownLb2(lbStr,colorTb)

		end

		if time<=0 then
			self.countDownLb1:setString(GetTimeForItemStrState(time+lastTime))
		else
			self.countDownLb1:setString(GetTimeForItemStrState(time))
		end
		
	elseif state==2 then
		if updateFlag then
			local lbStr=getlocal("ltzdz_battle_start_des3")
			local colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
			self:addCountDownLb2(lbStr,colorTb)
		end
		
		local time=ltzdzVoApi.clancrossinfo.st-base.serverTime
		if time<0 then
			time=0
		end
		self.countDownLb1:setString(GetTimeForItemStrState(time))
	elseif state==3 then
		if updateFlag then
			local lbStr=getlocal("ltzdz_battle_start_des4")
			local colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
			self:addCountDownLb2(lbStr,colorTb)
		end
		local warCfg=ltzdzVoApi:getWarCfg()
		local time=ltzdzVoApi.clancrossinfo.st+warCfg.warTime-base.serverTime
		if time<0 then
			time=0
		end
		self.countDownLb1:setString(GetTimeForItemStrState(time))
	end
end

function ltzdzTab1:tick()
	if ltzdzVoApi:getWarState()==1 then
		self:refreshTipSp()
	end
	local isDelay,time=ltzdzVoApi:isDelaySettlement()
	if isDelay==true then
		if time==nil or time<=0 then
			time=0
			ltzdzVoApi:crossInit(nil,self.layerNum+1)
			
		end
		if self.settleDownLb then
			self.settleDownLb:setString(GetTimeStr(time))
		end
	end
	-- local sflag=ltzdzVoApi:isThisSeason()
	-- if sflag~=self.seasonFlag and sflag==false then
	-- 	self.seasonFlag=sflag
	-- 	ltzdzVoApi:clearSeasonTaskState()
	-- 	self:refreshSeasonTask()
	-- end
	if self.countDownLb1 and self.countDownLb2 then
		local state=ltzdzVoApi:getWarState()
		self:refreshDownLb(state)
		if self.lastState and self.lastState~=state then
			self.lastState=state
			self:refreshBtn()
		end
		do return end
	end
	
	
	
end

function ltzdzTab1:refreshEnable(flag)
	self.touchEnable=flag
end

function ltzdzTab1:refreshTipSp()
	if self.teamItem then
		local tipSp=tolua.cast(self.teamItem:getChildByTag(101),"CCSprite")
		if tipSp then
			local clancrossinfo=ltzdzVoApi.clancrossinfo
			-- print("111111111111")
			if clancrossinfo.invite and clancrossinfo.invite.uid then
				tipSp:setVisible(true)
				return
			end
			-- print("222222222222")
			if clancrossinfo and clancrossinfo.invitelist and SizeOfTable(clancrossinfo.invitelist)~=0 then
				tipSp:setVisible(true)
				return
			end
			tipSp:setVisible(false)
		end
	end
	
end

function ltzdzTab1:initUpLayer(popflag)
	local isDelay,time=ltzdzVoApi:isDelaySettlement()
	-- isDelay=true
	if isDelay==true then
		local centerStratH=self.upBackSprie:getPositionY()-self.upBackSprie:getContentSize().height-10
		if self.settleBg~=nil then
			self.settleBg:removeFromParentAndCleanup(true)
			self.settleBg=nil
			self.settleDownLb=nil
		end
		if self.settleBg==nil then
			local function touchSettleBg()
			end
			self.settleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),touchSettleBg)
		end
		self.settleBg:setAnchorPoint(ccp(0,0))
		self.settleBg:setTouchPriority(-(self.layerNum-1)*20-10)
		local rect=CCSizeMake(640,centerStratH)
		self.settleBg:setContentSize(rect)
		self.settleBg:setOpacity(255*0.8)
		self.settleBg:setPosition(0,0)
		self.bgLayer:addChild(self.settleBg,10)

		local function closeFunc()
	    end
	    local countDownBg=G_getNewDialogBg2(CCSizeMake(580,250),self.layerNum,nil,getlocal("serverWarLocal_status_6"),25,G_ColorWhite)
	    countDownBg:setTouchPriority(-(self.layerNum-1)*20-10)
	    self.settleBg:addChild(countDownBg,2)
	    countDownBg:setPosition(getCenterPoint(self.settleBg))

		local lbBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
		lbBg:setContentSize(CCSizeMake(countDownBg:getContentSize().width-40,countDownBg:getContentSize().height-60))
		lbBg:setAnchorPoint(ccp(0.5,0))
		lbBg:setPosition(countDownBg:getContentSize().width/2,20)
		countDownBg:addChild(lbBg)

		if time==nil or time<=0 then
			time=0
		end

		local startH=lbBg:getContentSize().height-25
		local downDesLb1=GetTTFLabelWrap(getlocal("ltzdz_count_down_des"),25,CCSizeMake(lbBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		lbBg:addChild(downDesLb1)
		downDesLb1:setAnchorPoint(ccp(0,1))
		downDesLb1:setPosition(30,startH)

		startH=startH-downDesLb1:getContentSize().height-30
		local downDesLb2=GetTTFLabelWrap(getlocal("ltzdz_count_down_des3"),25,CCSizeMake(lbBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		lbBg:addChild(downDesLb2)
		downDesLb2:setAnchorPoint(ccp(0.5,1))
		downDesLb2:setPosition(downDesLb2:getContentSize().width/2,startH)

		startH=startH-downDesLb2:getContentSize().height
		local settleDownLb=GetTTFLabelWrap(GetTimeStr(time),25,CCSizeMake(lbBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		settleDownLb:setAnchorPoint(ccp(0.5,1))
		lbBg:addChild(settleDownLb)
		settleDownLb:setPosition(downDesLb2:getContentSize().width/2,startH)
		settleDownLb:setColor(G_ColorYellowPro)
		self.settleDownLb=settleDownLb

		-- popflag=true
		if popflag then
			ltzdzVoApi:showCountDownSettleDialog(self.layerNum+1,true,true,nil,getlocal("serverWarLocal_status_6"))
		end
	else
		if self.settleBg~=nil then
			self.settleBg:removeFromParentAndCleanup(true)
			self.settleBg=nil
		end
		self.settleDownLb=nil
	end
end

function ltzdzTab1:dispose()
	if self.refreshListener then
        eventDispatcher:removeEventListener("ltzdz.mainRefresh",self.refreshListener)
        self.refreshListener=nil
    end
	if self.refreshSeasonTaskListener then
        eventDispatcher:removeEventListener("ltzdz.seasonTaskRefresh",self.refreshSeasonTaskListener)
        self.refreshSeasonTaskListener=nil
    end
    self.layerNum=nil
    if self.bgLayer then
	    self.bgLayer:removeFromParentAndCleanup(true)
	end
    self.bgLayer=nil
    self.lastState=nil
	self.seasonRewardSpTb={}
	self.seasonRewardSp=nil
	self.seasonRewardState=-1
	self.seasonFlag=true
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end