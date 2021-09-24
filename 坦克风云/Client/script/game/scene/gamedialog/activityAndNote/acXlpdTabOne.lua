acXlpdTabOne={}
function acXlpdTabOne:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent    = parent
	nc.bgLayer   = nil
	nc.isIphone5 = G_isIphone5()
	nc.pdLevelData = {} -- 当前攀登等级 相关数据信息 通过 acXlpdVoApi:returnCurlPdLevelWithAnyData 拿到
	nc.pdLevelLbTb = {} -- 当前攀登等级 相关数据信息 显示的精灵
	nc.taskSpTb    = {}
	nc.guangSpTb   = {}
	nc.taskList    = {}
	nc.taskListNum = 0
	nc.yWater = nil
	nc.yellowCriSp = nil
	nc.yellowCriSpWidth = nil
	nc.arcBg = nil
	nc.arcBgWidth = nil
	nc.lastTime = acXlpdVoApi:isToday()
	nc.isCanSocketGetOverData = acXlpdVoApi:isCanSocketGetOverData()
	nc.isShowedUpLvl = false
	return nc
end
function acXlpdTabOne:dispose( )
	self.lastTime = nil
	self.arcBgWidth = nil
	self.yellowCriSpWidth = nil
	self.arcBg = nil
	self.yellowCriSp = nil
	self.yWater = nil
	self.taskList = nil
	self.taskListNum = nil
	self.guangSpTb   = nil
	self.taskSpTb    = nil
	self.pdLevelData = nil
	self.bgLayer     = nil
	self.parent      = nil
	self.isIphone5   = nil
end
function acXlpdTabOne:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	
	self.bottomPosy = 84 + 10
	self.topPosy    = G_VisibleSizeHeight - self.bottomPosy
	self.topHeight  = 410
	self:initTopPanel()
	self:initBottomPanel()
	if acXlpdVoApi:isCanSocketGetOverData() then
		self:showOverPanel()
	end
	return self.bgLayer
end

function acXlpdTabOne:refresh(refreshType)
	if refreshType == "gBox" then
		self:refreshPdLevelData()
	elseif refreshType == "tv" then
		self:refreshTv()
	else
		self:refreshLbColor()
		self:refreshPdLevelData()
		self:refreshTv()
	end
end

function acXlpdTabOne:refreshPdCoinData( )
	if self.curCoinBg and self.curCoinLb and self.curCoinSpWidth then
		self.curCoinLb:setString( acXlpdVoApi:getCurCoin() )
		local curCoinLbWidth = self.curCoinLb:getContentSize().width
		self.curCoinBg:setContentSize(CCSizeMake(50 + self.curCoinSpWidth + curCoinLbWidth - 4,35))
	end
end 

function acXlpdTabOne:refreshLbColor()
	if self.timeLb then
		if acXlpdVoApi:isShopOpen() then
			self.timeLb:setColor(G_ColorYellowPro)
		else
			self.timeLb:setColor(G_ColorRed)
		end
	end
end

function acXlpdTabOne:refreshTv()
	self.taskList,self.taskListNum = acXlpdVoApi:getTaskTbData( )
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acXlpdTabOne:refreshPdLevelData( )
	self.pdLevelData = acXlpdVoApi:returnCurlPdLevelWithAnyData()
	for i=1,4 do
		if self.pdLevelLbTb[i] then
			self.pdLevelLbTb[i]:setString(self.pdLevelData[i])
		end
	end
	if self.pdLevelLbTb[5] then
		local pdExpStr = self.pdLevelData[6] and getlocal("curProgressStr",{self.pdLevelData[5],self.pdLevelData[6]}) or "MAX" 
		self.pdLevelLbTb[5]:setString(pdExpStr)
	end
	if self.pdLevelLbTb[6] then
		self.pdLevelLbTb[6]:setString(self.pdLevelData[7])
	end

	if self.yellowCriSp then
		local yellowCriSp = tolua.cast(self.yellowCriSp,"CCProgressTimer")
		-- local per = math.floor(self.pdLevelData[5] / self.pdLevelData[6] * 100)
		local per = 100 
		if self.pdLevelData[6] then
		    per = math.floor(tonumber(self.pdLevelData[5]) / tonumber(self.pdLevelData[6]) * 100)
		end

		yellowCriSp:setPercentage(per)

		if per > 0 and self.arcBg and self.arcBgHeight and self.arcBgWidth then
	    	local stPosy = 21

	    	local perRadiuos = per / 100 * 180
		    local r = 62  --半径
		  	local angleOffset = 2 * math.pi/360 --偏移角度
		  	local centerPosx,centerPosy = self.arcBgWidth * 0.5, self.arcBgHeight * 0.5
		  	local angle = angleOffset * perRadiuos
		  	local relativeX=math.sin(angle)*r       --相对于圆心的x
		    local relativeY=math.cos(angle)*r  
		    local curWidth = relativeX * 2

		    self:refreshYellowWater( self.arcBg,curWidth ,self.arcBgWidth * 0.5,stPosy + self.yellowCriSpWidth * per * 0.01 ,per)
		end
	end


	local thisPdLevel  = self.pdLevelData[7]
	local teamNum      = acXlpdVoApi:getTeamNum( )
	local per          = acXlpdVoApi:getPer(thisPdLevel)
	local taskNum,gBox = acXlpdVoApi:getgBoxNum( )
	if self.timerSpriteLv then
		local timerSpriteLv =tolua.cast(self.timerSpriteLv,"CCProgressTimer")
		timerSpriteLv:setPercentage(per)
	end
	for i=1,taskNum do
		local awardType = acXlpdVoApi:everyBoxAwardType(i,gBox[i],thisPdLevel)
		if self.taskSpTb[i] then
			if awardType > 0 then
				self.taskSpTb[i]:setOpacity(255)
			else
				self.taskSpTb[i]:setOpacity(0)
			end
		end
		if self.guangSpTb[i] then
			if awardType == 2 and self.guangSpTb[i][1] and self.guangSpTb[i][2] then
				self.guangSpTb[i][1]:setVisible(false)
				self.guangSpTb[i][2]:setVisible(false)
			elseif awardType == 1 and self.guangSpTb[i][1] and self.guangSpTb[i][2] then
				self.guangSpTb[i][1]:setVisible(true)
				self.guangSpTb[i][2]:setVisible(true)
			end
		end
	end
	self:refreshPdCoinData()
end

function acXlpdTabOne:tick( )
	if not acXlpdVoApi:isEnd() then
		if self.timeLb then
			self.timeLb:setString(acXlpdVoApi:getShopTime(true))
		end
		if self.lastTime == false or self.lastTime ~= acXlpdVoApi:isToday() then
			acXlpdVoApi:setTodayTick()
			self.lastTime = acXlpdVoApi:isToday()
			acXlpdVoApi:clearEveryDayData( )
			self:refresh("tv")
		end

		if acXlpdVoApi:getIsNewDataGet( ) then
			acXlpdVoApi:isNewDataGet(false)
			self:refresh()
		end

		if not self.isShowedUpLvl and not acXlpdVoApi:isCanSocketGetOverData() then
			self:showUpLvl()
		end

	end
end

function acXlpdTabOne:initTopPanel( )
	self.pdLevelData = acXlpdVoApi:returnCurlPdLevelWithAnyData( )
	local timeBgHeight   = 54
	local topPanelHeight = 356
	local topPanelWidth  = G_VisibleSizeWidth - 20
	local bgTitleHeight  = 30
	local levelBgHeight  = 210

	local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setOpacity(0)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.topPosy)
    self.bgLayer:addChild(timeBg,10)

	local vo=acXlpdVoApi:getAcVo()
	local timeStr=acXlpdVoApi:getShopTime(true)
	self.timeLb=GetTTFLabel(timeStr,G_isAsia() and 22 or 20,"Helvetica-bold")
	self.timeLb:setAnchorPoint(ccp(0.5,1))
	self.timeLb:setPosition(ccp(timeBg:getContentSize().width * 0.5,timeBg:getContentSize().height - 10))
	timeBg:addChild(self.timeLb,2)

	local function touchTip()
        acXlpdVoApi:getTip(self.layerNum + 2,"tabOne")
    end
    G_addMenuInfo(self.bgLayer, self.layerNum + 1, ccp(G_VisibleSizeWidth-30,self.topPosy - 25), {}, nil, 0.7, 28, touchTip, true)
    ------------------------------------------------------------------------------------
    local topPanel = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	topPanel:setAnchorPoint(ccp(0.5,1))
	topPanel:setContentSize(CCSizeMake(topPanelWidth, topPanelHeight))
	topPanel:setPosition(G_VisibleSizeWidth * 0.5,self.topPosy - timeBgHeight)
	self.topPanel = topPanel
	self.bgLayer:addChild(topPanel)

	local levelBg = LuaCCScale9Sprite:createWithSpriteFrameName("acXlpdTopBg.png", CCRect(41, 41, 1, 1), function()end)
	levelBg:setContentSize(CCSizeMake(topPanelWidth - 8, levelBgHeight + bgTitleHeight - 4))
	levelBg:setAnchorPoint(ccp(0.5,1))
	levelBg:setPosition(topPanelWidth * 0.5, topPanelHeight - 4)
	topPanel:addChild(levelBg)
	-- levelBgWidth, levelBgHeight = levelBg:getContentSize().width, levelBg:getContentSize().height

	local linePic = CCSprite:createWithSpriteFrameName("lightGreenPic1912.png")
	linePic:setScaleY(levelBgHeight / linePic:getContentSize().height)
	-- linePic:setRotation(90)
	linePic:setAnchorPoint(ccp(0.5,0))
	linePic:setPosition(levelBg:getContentSize().width * 0.5, 13)
	levelBg:addChild(linePic)

	local titleMiddleBg = CCSprite:createWithSpriteFrameName("lightGreenTitleBg1912.png")
	titleMiddleBg:setAnchorPoint(ccp(0.5,1))
	titleMiddleBg:setPosition(topPanelWidth * 0.5,topPanelHeight)
	topPanel:addChild(titleMiddleBg,1)

	local titleTb = {getlocal("current_level_2"), getlocal("RankScene_level"), getlocal("nextLevelStr")}
	local titlePosTb = {ccp(topPanelWidth * 0.2,topPanelHeight - 12 - 6), ccp(topPanelWidth * 0.5,topPanelHeight - 15 - 6), ccp(topPanelWidth * 0.8,topPanelHeight - 12 - 6)}
	local titleSizeTb = {20,24,20}
	local titleColorTb = {G_ColorWhite,G_ColorYellowPro2,G_ColorWhite}

	for i=1,3 do
		local titleLb = GetTTFLabel(titleTb[i],titleSizeTb[i])
		if titleLb:getContentSize().width > 180 then
			timeLb:setScale(180 / titleLb:getContentSize().width)
		end
		titleLb:setPosition(titlePosTb[i])
		titleLb:setColor(titleColorTb[i])
		topPanel:addChild(titleLb,5)
	end

	local pdStrTb = {getlocal("activity_xlpd_coinValue"), getlocal("activity_xlpd_coinValue"), getlocal("activity_xlpd_coinName"), getlocal("activity_xlpd_coinName")}
	local pdStrPosTb = { ccp(topPanelWidth * 0.2, topPanelHeight * 0.78), ccp(topPanelWidth * 0.8, topPanelHeight * 0.78), ccp(topPanelWidth * 0.2, topPanelHeight * 0.55), ccp(topPanelWidth * 0.8, topPanelHeight * 0.55),}
	for i=1,4 do
		local pdLb = GetTTFLabel(pdStrTb[i],20)
		pdLb:setColor(ccc3(0,255,198))
		pdLb:setPosition(pdStrPosTb[i])
		topPanel:addChild(pdLb)

		local usrPdLb = GetTTFLabel(self.pdLevelData[i],20)
		usrPdLb:setPosition(pdLb:getContentSize().width * 0.5, -8)
		usrPdLb:setAnchorPoint(ccp(0.5,1))
		pdLb:addChild(usrPdLb)
		self.pdLevelLbTb[i] = usrPdLb
	end

	local arcBg = CCSprite:createWithSpriteFrameName("acXlpdDiscBg.png")
	arcBg:setPosition(levelBg:getContentSize().width * 0.5,levelBgHeight * 0.55)
	levelBg:addChild(arcBg,1)
	self.arcBg = arcBg
	local arcBgWidth,arcBgHeight = arcBg:getContentSize().width,arcBg:getContentSize().height
	self.arcBgWidth = arcBgWidth
	self.arcBgHeight = arcBgHeight

	local yellowCriSpWidth = 76
	self.yellowCriSpWidth = yellowCriSpWidth
	AddProgramTimer(arcBg,getCenterPoint(arcBg),110,120,nil,"acXlpdDiscUseBg.png","acXlpdDisc.png",130,1,1,nil,ccp(0,1),nil,nil,nil,ccp(0,0))
	local per = 100 
	if self.pdLevelData[6] then
	    per = math.floor(tonumber(self.pdLevelData[5]) / tonumber(self.pdLevelData[6]) * 100)
	end
    local yellowCriSp = arcBg:getChildByTag(110)
    yellowCriSp=tolua.cast(yellowCriSp,"CCProgressTimer")
    self.yellowCriSp = yellowCriSp
    yellowCriSp:setPercentage(per)
    local yellowBg = arcBg:getChildByTag(130)
    yellowBg = tolua.cast(yellowBg,"CCSprite")
    yellowCriSp:setScaleY((yellowCriSpWidth)/yellowCriSp:getContentSize().height)
    yellowBg:setScaleY((yellowCriSpWidth)/yellowBg:getContentSize().height)
  	print("per--->>>",per)
    local perRadiuos = per / 100 * 180
    local r = 62  --半径
  	local angleOffset = 2 * math.pi/360 --偏移角度
  	local centerPosx,centerPosy = arcBgWidth * 0.5, arcBgHeight * 0.5
  	local angle = angleOffset * perRadiuos
  	local relativeX=math.sin(angle)*r       --相对于圆心的x
    local relativeY=math.cos(angle)*r  
    local curWidth = relativeX * 2
    local stPosy = 22
    
    self:refreshYellowWater( arcBg,curWidth,arcBgWidth * 0.5, stPosy + yellowCriSpWidth * per * 0.01 , per)
	
	local arcBgUpSp = CCSprite:createWithSpriteFrameName("acXlpdArcLight.png")
	arcBgUpSp:setPosition(arcBgWidth * 0.5, arcBgHeight)
	arcBgUpSp:setAnchorPoint(ccp(0.5,1))
	arcBg:addChild(arcBgUpSp,14)

	local pdExpStr = self.pdLevelData[6] and getlocal("curProgressStr",{self.pdLevelData[5],self.pdLevelData[6]}) or "MAX" 
	local pdExpLbShow = GetTTFLabel(pdExpStr,18)
	pdExpLbShow:setPosition(arcBgWidth * 0.5, 30)
	arcBg:addChild(pdExpLbShow,15)
	self.pdLevelLbTb[5] = pdExpLbShow

	local pdLevelNowLb = GetTTFLabel(self.pdLevelData[7],30,true)
	pdLevelNowLb:setPosition(getCenterPoint(arcBg))
	arcBg:addChild(pdLevelNowLb,15)
	self.pdLevelLbTb[6] = pdLevelNowLb


	local curCoinBg = LuaCCScale9Sprite:createWithSpriteFrameName("arcGreenBg.png",CCRect(20,20,1,1),function()end)
	curCoinBg:setAnchorPoint(ccp(0.5,0))
	curCoinBg:setContentSize(CCSizeMake(50,35))
	self.curCoinBg = curCoinBg
	levelBg:addChild(curCoinBg,1)
	local curCoinBgHeight = curCoinBg:getContentSize().height

	local curCoinSp = CCSprite:createWithSpriteFrameName("pdCoin.png")
	curCoinSp:setAnchorPoint(ccp(0,0.5))
	curCoinSp:setScale(0.5)
	curCoinSp:setPosition(25,curCoinBgHeight * 0.5)
	curCoinBg:addChild(curCoinSp)
	local curCoinSpWidth = curCoinSp:getContentSize().width * 0.5
	self.curCoinSpWidth = curCoinSpWidth

	local curCoinLb = GetTTFLabel(acXlpdVoApi:getCurCoin(),20)
	self.curCoinLb = curCoinLb
	local curCoinLbWidth = curCoinLb:getContentSize().width
	curCoinLb:setAnchorPoint(ccp(0,0.5))
	curCoinLb:setPosition(21 + curCoinSpWidth,curCoinBgHeight * 0.5)
	curCoinBg:addChild(curCoinLb)

	curCoinBg:setContentSize(CCSizeMake(50 + curCoinSpWidth + curCoinLbWidth - 4,35))
	curCoinBg:setPosition(levelBg:getContentSize().width * 0.5, 15)

	---------------------- 任 务 宝 箱 ----------------------
	local thisPdLevel  = self.pdLevelData[7]
	local teamNum      = acXlpdVoApi:getTeamNum( )
	local per          = acXlpdVoApi:getPer(thisPdLevel)
	local taskNum,gBox = acXlpdVoApi:getgBoxNum( )
	local barWidth     = topPanelWidth - 100
	local barPosy      = topPanelHeight * 0.18
	AddProgramTimer(topPanel,ccp(topPanelWidth * 0.5,barPosy),11,12,"","barBg1912.png","barYellow1912.png",13,1,1)
	local timerSpriteLv = topPanel:getChildByTag(11)
	timerSpriteLv       = tolua.cast(timerSpriteLv,"CCProgressTimer")
	timerSpriteLv:setPercentage(per)
	self.timerSpriteLv  = timerSpriteLv
	local timerSpriteBg = topPanel:getChildByTag(13)
    timerSpriteBg=tolua.cast(timerSpriteBg,"CCSprite")
    local scalex=barWidth/timerSpriteLv:getContentSize().width
    timerSpriteBg:setScaleX(scalex)
    timerSpriteLv:setScaleX(scalex)
    
    local spacex=( barWidth/taskNum + barWidth )/ taskNum
    for i=1,taskNum do
		local px,py= ( i - 1 ) * spacex+50,barPosy
		local guangSp1,guangSp2 = G_playShineEffect(topPanel,ccp(px,py),0.7)
		self.guangSpTb[i] = {}
		self.guangSpTb[i][1] = guangSp1
		self.guangSpTb[i][2] = guangSp2
		self.guangSpTb[i][1]:setVisible(false)
		self.guangSpTb[i][2]:setVisible(false)

		local acSp1=GraySprite:createWithSpriteFrameName("goldBox1912.png")
		acSp1:setPosition(ccp(px,py))
		topPanel:addChild(acSp1,2)
		acSp1:setScale(1)

		local function clickBoxHandler( ... )
			if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local function awardCallback()
            	self:refresh("gBox")
            end 
            -- print("i====>>>",i)
            local pdLevelData = acXlpdVoApi:returnCurlPdLevelWithAnyData( )
            local thisPdLevel = pdLevelData[7]
            local awardType = acXlpdVoApi:everyBoxAwardType(i,gBox[i],thisPdLevel)
            local taskTeamLim = gBox[i].lim
            --needTb: 3 提示， 4 领取状态 5 奖励内容 6 限制具体数值，7 宝箱idex, 8 回调
            local needTb = {"xlpdBoxAward",getlocal("levelBoxAward",{gBox[i].g}), getlocal("activity_xlpd_boxLimitTip",{taskTeamLim}), awardType, acXlpdVoApi:getgBoxIndexWithAward(i), taskTeamLim, i, awardCallback}
            G_showCustomizeSmallDialog(self.layerNum + 1,needTb)

        end
		local acSp2=LuaCCSprite:createWithSpriteFrameName("goldBox1912.png",clickBoxHandler)
		acSp2:setTouchPriority(-(self.layerNum-1)*20-5)
		acSp2:setOpacity(0)
		acSp2:setPosition(ccp(px,py))
		topPanel:addChild(acSp2,3)
		acSp2:setScale(1)
		self.taskSpTb[i] = acSp2

		local awardType = acXlpdVoApi:everyBoxAwardType(i,gBox[i],thisPdLevel)
		if awardType > 0 then
			self.taskSpTb[i]:setOpacity(255)
			if awardType == 1 then
				self.guangSpTb[i][1]:setVisible(true)
				self.guangSpTb[i][2]:setVisible(true)
			end
		end
    end

	self:refreshLbColor()
end

function acXlpdTabOne:initBottomPanel( )
	self.taskList,self.taskListNum = acXlpdVoApi:getTaskTbData( )

	local bottomPanelWidth  = G_VisibleSizeWidth - 20
	self.bottomPanelWidth = bottomPanelWidth
	local bottomPanelHeight = G_VisibleSizeHeight - self.topHeight - 168 - 75
	local bottomPanel = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	bottomPanel:setAnchorPoint(ccp(0.5,0))
	bottomPanel:setContentSize(CCSizeMake(bottomPanelWidth, bottomPanelHeight))
	bottomPanel:setPosition(G_VisibleSizeWidth * 0.5,self.bottomPosy)
	self.bgLayer:addChild(bottomPanel)

	local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.taskListNum
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(self.bottomPanelWidth, 100)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local taskTb = self.taskList[idx + 1]
            local stPosx = 10
            local iconBg = CCSprite:createWithSpriteFrameName("Icon_BG.png")
            iconBg:setPosition(stPosx + 40,50)
            cell:addChild(iconBg)
            local pdExpIcon = CCSprite:createWithSpriteFrameName("pdExpIcon.png")
            pdExpIcon:setPosition(getCenterPoint(iconBg))
            iconBg:addChild(pdExpIcon)
            pdExpIcon:setScale(0.75)
            iconBg:setScale(0.9)

            local expNum = taskTb.exp
            local numLb = GetTTFLabel("x" .. FormatNumber(expNum),20)
            numLb:setAnchorPoint(ccp(1,0))
            iconBg:addChild(numLb,4)
            numLb:setPosition(iconBg:getContentSize().width-5, 5)
            numLb:setScale(1/0.9)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(iconBg:getContentSize().width-5,5))
            numBg:setOpacity(150)
            iconBg:addChild(numBg,3)

			local limit        = taskTb.max
			local curTaskNum   = acXlpdVoApi:getTaskedTbFinshTime(idx + 1)
			local lbRich       = {nil, curTaskNum >= limit and G_ColorGreen or G_ColorRed, nil, G_ColorGreen}
			local taskNumGetLb = getlocal("activity_xlpd_taskedStr",{curTaskNum, limit})
		    local tip2Lb, lbHeight = G_getRichTextLabel(taskNumGetLb, lbRich, G_isAsia() and 19 or 17, self.bottomPanelWidth - 150, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		    tip2Lb:setAnchorPoint(ccp(0, 1))
		    tip2Lb:setPosition(ccp(90, 40))
		    cell:addChild(tip2Lb, 1)

		    local useTaskNum = acXlpdVoApi:getTaskedOneTime(idx + 1)
		    local isFull = false
		    if curTaskNum >= limit then
				useTaskNum = taskTb.num
				isFull     = true
		    end
		    -- local useTaskNum = curTaskNum >= limit and taskTb.num or acXlpdVoApi:getTaskedOneTime(idx + 1)
		    -- local isFull = curTaskNum >= limit and true or false
		    local taskTitleStr = G_getTaskWithDescLb(taskTb.tsk,useTaskNum,taskTb.num,isFull)
		    local titleLb = GetTTFLabelWrap(taskTitleStr,G_isAsia() and 20 or 18,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	        titleLb:setColor(G_ColorYellowPro)
			titleLb:setAnchorPoint(ccp(0,1))
			titleLb:setPosition(90,80)
			cell:addChild(titleLb,1)

			--"gotoBtn.png","gotoBtn_down.png","gotoBtn_down.png"
			local function gotoHandle( )
				if curTaskNum >= limit then
					G_showTipsDialog(getlocal("upperTen"))
					do return end
				end
				G_goToDialog2NeedSecondTurn(taskTb.tsk)
			end 
			local gotoBtnItem, gotoMenu = G_createBotton(cell, ccp(self.bottomPanelWidth - 60, 50), nil, "gotoBtn.png","gotoBtn_down.png","gotoBtn_down.png", gotoHandle, 0.8, -(self.layerNum - 1) * 20 - 3, 3,nil,ccp(0.5,0.5))
			if acXlpdVoApi:isShopOpen() then
				gotoBtnItem:setEnabled(false)
			end
            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(self.bottomPanelWidth - 20,bottomLine:getContentSize().height + 1))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(self.bottomPanelWidth * 0.5, 0))
            cell:addChild(bottomLine,1)
            return cell
        end
    end
	local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bottomPanelWidth, bottomPanelHeight - 4),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(0,2))
    bottomPanel:addChild(tableView,1)
    tableView:setMaxDisToBottomOrTop(100)
    self.tv = tableView

    local titleBg = G_createNewTitle({getlocal("activity_xcjh_subTitle2"), 24}, CCSizeMake(300, 0), nil, nil, "Helvetica-bold")
    titleBg:setPosition(bottomPanelWidth * 0.5, bottomPanelHeight + 5)
    bottomPanel:addChild(titleBg,1)
end

function acXlpdTabOne:refreshYellowWater( parent,useWidth,posx,posy , per)
	if per == 0 or per == 100 then
		if self.yWater then
			self.yWater:setVisible(false)
		end
		do return end
	end
	local stPosy = 23
	if self.yWater then
		local scaleV = useWidth / self.yWater:getContentSize().width
		self.yWater:setScale(( scaleV * 76 + 46) / self.yWater:getContentSize().width)
		self.yWater:setPositionY(posy)
		self.yWater:setVisible(true)
	else
		local yWater = CCSprite:createWithSpriteFrameName("yellowWater1.png")
		yWater:setPosition(posx,posy)
		local scaleV = useWidth / yWater:getContentSize().width
		yWater:setScale( ( scaleV * 76 + 46) / yWater:getContentSize().width)
		parent:addChild(yWater,2)
		self.yWater = yWater
		local pzArr=CCArray:create()
	    for kk=1,20 do
	        local nameStr="yellowWater"..kk..".png"
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	        pzArr:addObject(frame)
	    end
	    local animation=CCAnimation:createWithSpriteFrames(pzArr)
	    animation:setDelayPerUnit(0.05)
	    local animate=CCAnimate:create(animation)
	    local repeatForever=CCRepeatForever:create(animate)
	    yWater:runAction(repeatForever)
	end
end

function acXlpdTabOne:showUpLvl( )
	self.isShowedUpLvl = true
	-- print("acXlpdVoApi:changeSaveOldPdLevel()====>>>",acXlpdVoApi:changeSaveOldPdLevel())
	if acXlpdVoApi:changeSaveOldPdLevel() then
		-- print("self.arcBg====>>>",self.arcBg)
		if not self.arcBg then do return end end
		local function showUpAction()
				local scale = 2

				local yBall	= CCSprite:createWithSpriteFrameName("yellowBall_1.png")
				yBall:setScale(scale)
				yBall:setPosition(getCenterPoint(self.arcBg))
				self.arcBg:addChild(yBall,20)
				local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
				blendFunc.src=GL_ONE
				blendFunc.dst=GL_ONE
				yBall:setBlendFunc(blendFunc)

				local pzArr=CCArray:create()
				for kk=1,13 do
				  local nameStr="yellowBall_"..kk..".png"
				  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				  pzArr:addObject(frame)
				end
				local animation=CCAnimation:createWithSpriteFrames(pzArr)
				animation:setDelayPerUnit(0.07)
				local animate=CCAnimate:create(animation)

				local function callBack()
					yBall:removeFromParentAndCleanup(true)
				end
				local callFunc = CCCallFunc:create(callBack)
				local acArr=CCArray:create()
				acArr:addObject(animate)
				acArr:addObject(callFunc)
				local seq=CCSequence:create(acArr)
				yBall:runAction(seq)

				local g1Sp = CCSprite:createWithSpriteFrameName("xlpd_g1.png")
				g1Sp:setOpacity(0)
				g1Sp:setScale(scale)
				g1Sp:setPosition(getCenterPoint(self.arcBg))
				self.arcBg:addChild(g1Sp,20)

				local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
				blendFunc.src=GL_ONE
				blendFunc.dst=GL_ONE
				g1Sp:setBlendFunc(blendFunc)

				local fade1 = CCFadeIn:create(0)
				local delayFade1 =CCDelayTime:create(0.33)
				local fade2 = CCFadeOut:create(1.33)
				local function g1SpCallBack()
					g1Sp:removeFromParentAndCleanup(true)
				end
				local g1SpCall = CCCallFunc:create(g1SpCallBack)
				local g1Arr=CCArray:create()
				g1Arr:addObject(fade1)
				g1Arr:addObject(delayFade1)
				g1Arr:addObject(fade2)
				g1Arr:addObject(g1SpCall)
				local g1Seq=CCSequence:create(g1Arr)
				g1Sp:runAction(g1Seq)

				local g2Sp = CCSprite:createWithSpriteFrameName("xlpd_g2.png")
				g2Sp:setOpacity(0)
				g2Sp:setScale(scale)
				g2Sp:setPosition(getCenterPoint(self.arcBg))
				self.arcBg:addChild(g2Sp,20)

				local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
				blendFunc.src=GL_ONE
				blendFunc.dst=GL_ONE
				g2Sp:setBlendFunc(blendFunc)

				local fade11 = CCFadeIn:create(0)
				local delayFade11 =CCDelayTime:create(0.33)
				local fade22 = CCFadeOut:create(1.33)
				local function g2SpCallBack()
					g2Sp:removeFromParentAndCleanup(true)
				end
				local g2SpCall = CCCallFunc:create(g2SpCallBack)
				local g2Arr=CCArray:create()
				g2Arr:addObject(fade11)
				g2Arr:addObject(delayFade11)
				g2Arr:addObject(fade22)
				g2Arr:addObject(g2SpCall)
				local g2Seq=CCSequence:create(g2Arr)
				g2Sp:runAction(g2Seq)

				local glowSp = CCSprite:createWithSpriteFrameName("xlpd_glow.png")
				glowSp:setScale(scale)
				glowSp:setPosition(getCenterPoint(self.arcBg))
				self.arcBg:addChild(glowSp,20)

				local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
				blendFunc.src=GL_ONE
				blendFunc.dst=GL_ONE
				glowSp:setBlendFunc(blendFunc)

				local scaleTo1 = CCScaleTo:create(0,1.18)
				local scaleTo2 = CCScaleTo:create(0.06,3.4)
				local scaleTo3 = CCScaleTo:create(0.13,2)
				local scaleTo4 = CCScaleTo:create(0.26,0)
				local function glowCallBack()
					glowSp:removeFromParentAndCleanup(true)
				end
				local glowFun = CCCallFunc:create(glowCallBack)
				local glowArr = CCArray:create()
				glowArr:addObject(scaleTo1)
				glowArr:addObject(scaleTo2)
				glowArr:addObject(scaleTo3)
				glowArr:addObject(scaleTo4)
				glowArr:addObject(glowFun)
				local glowSeq = CCSequence:create(glowArr)
				glowSp:runAction(glowSeq)

				local greenPointSp = CCSprite:createWithSpriteFrameName("xlpd_greenPoint.png")
				greenPointSp:setOpacity(0)
				greenPointSp:setScale(scale)
				greenPointSp:setPosition(getCenterPoint(self.arcBg))
				greenPointSp:setPositionY(greenPointSp:getPositionY() + 20)
				self.arcBg:addChild(greenPointSp,20)

				local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
				blendFunc.src=GL_ONE
				blendFunc.dst=GL_ONE
				greenPointSp:setBlendFunc(blendFunc)

				local greenFade1 = CCFadeIn:create(0)
				local greenDelay = CCDelayTime:create(0.9)
				local greenFade2 = CCFadeOut:create(0.6)
				local function showUpLvlPanel()
					greenPointSp:removeFromParentAndCleanup(true)

					local curLvl, allGetCoin = acXlpdVoApi:getUpLevelData()
					-- print("curLvl, allGetCoin====>>",curLvl, allGetCoin)
					acXlpdVoApi:showPdLvlPanel(self.layerNum + 10, curLvl, allGetCoin)
				end
				local showUpFun = CCCallFunc:create(showUpLvlPanel)
				local grpointArr = CCArray:create()
				grpointArr:addObject(greenFade1)
				grpointArr:addObject(greenDelay)
				grpointArr:addObject(greenFade2)
				grpointArr:addObject(showUpFun)
				local grpointSeq = CCSequence:create(grpointArr)
				greenPointSp:runAction(grpointSeq)

				local haloSp = CCSprite:createWithSpriteFrameName("xlpd_halo.png")
				haloSp:setOpacity(0)
				haloSp:setScale(scale)
				haloSp:setPosition(getCenterPoint(self.arcBg))
				self.arcBg:addChild(haloSp,20)

				local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
				blendFunc.src=GL_ONE
				blendFunc.dst=GL_ONE
				haloSp:setBlendFunc(blendFunc)

				local haloFadeIn1 = CCFadeIn:create(0.03)
				local haloScale1 = CCScaleTo:create(0.03,3)
				local sArr1 = CCArray:create()
				sArr1:addObject(haloFadeIn1)
				sArr1:addObject(haloScale1)
				local halospawn1 = CCSpawn:create(sArr1)

				local haloFadeIn2 = CCFadeIn:create(0.2)
				local haloScale2 = CCScaleTo:create(0.2,4.33)
				local sArr2 = CCArray:create()
				sArr2:addObject(haloFadeIn2)
				sArr2:addObject(haloScale2)
				local halospawn2 = CCSpawn:create(sArr2)

				local haloFadeIn3 = CCFadeOut:create(0.25)
				local haloScale3 = CCScaleTo:create(0.25,6)
				local sArr3 = CCArray:create()
				sArr3:addObject(haloFadeIn3)
				sArr3:addObject(haloScale3)
				local halospawn3 = CCSpawn:create(sArr3)

				local function endHandle()
					haloSp:removeFromParentAndCleanup(true)
				end
				local endFun = CCCallFunc:create(endHandle)
				local haloArr = CCArray:create()
				haloArr:addObject(halospawn1)
				haloArr:addObject(halospawn2)
				haloArr:addObject(halospawn3)
				haloArr:addObject(endFun)
				local haloSeq = CCSequence:create(haloArr)
				haloSp:runAction(haloSeq)
		end
		local deT = CCDelayTime:create(0.5)
		local ccFun = CCCallFunc:create(showUpAction)
		local arr = CCArray:create()
		arr:addObject(deT)
		arr:addObject(ccFun)
		local seq = CCSequence:create(arr)
		self.arcBg:runAction(seq)

	end
end

function acXlpdTabOne:showOverPanel( )
	local function showOverPanel( )
		local function showUpLvl( )
			self:showUpLvl()
			self:refresh("gBox")
		end
		print "~~~  showOverPanel ~~~"
		local overData, overType = acXlpdVoApi:getOverNow()
		acXlpdVoApi:showOverPanel(self.layerNum + 10, showUpLvl, overData, overType)
	end
	acXlpdVoApi:socketOverData(showOverPanel)
end