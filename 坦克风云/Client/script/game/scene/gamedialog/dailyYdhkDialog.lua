-- @Author hj
-- @Date 2018-12-12
-- @Description 月度回馈领取世界金矿金币

dailyYdhkDialog = commonDialog:new()

function dailyYdhkDialog:new( ... )
	
	local nc = {}
	setmetatable(nc,self)
	self.__index = self
	self.cfg = dailyYdhkVoApi:getCfg()
	self.logList  = dailyYdhkVoApi:getLogList()
	self.timeInterval = base.serverTime + 2
	return nc

end

function dailyYdhkDialog:doUserHandler( ... )

	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(false)
	end
	
	local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82)
    self.bgLayer:addChild(tabLine,5)

    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    local function onLoadIcon(fn,icon)
		if self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
			icon:setAnchorPoint(ccp(0.5,1))
			icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82))
			self.bgLayer:addChild(icon,1)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("ydhk/ydhk.jpg"),onLoadIcon)

	spriteController:addPlist("public/emblem/emblemImage.plist")
	spriteController:addTexture("public/emblem/emblemImage.png")

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    --标题框
	local titleBacksprie = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
	self.bgLayer:addChild(titleBacksprie,10)
	titleBacksprie:setAnchorPoint(ccp(0.5,1))
	titleBacksprie:setContentSize(CCSizeMake(G_VisibleSizeWidth,90))
	titleBacksprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82))

	--活动时间
 	local acTimeLb=GetTTFLabel(dailyYdhkVoApi:getTimeStr(),25,true)
	acTimeLb:setPosition(ccp(titleBacksprie:getContentSize().width/2,titleBacksprie:getContentSize().height-30))
	acTimeLb:setColor(G_ColorYellowPro)
	titleBacksprie:addChild(acTimeLb)
	self.acTimeLb=acTimeLb

	-- i说明
	local function touchTip()
		local tabStr={getlocal("daily_ydhk_I1",{self.cfg.goldDayLimit}),getlocal("daily_ydhk_I2"),getlocal("daily_ydhk_I3")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(titleBacksprie,self.layerNum,ccp(titleBacksprie:getContentSize().width-40,45),{},nil,nil,28,touchTip,true)

	local strSize = 22
	if G_isAsia() == false then
		strSize = 20
	end

	local descLabel1 = GetTTFLabel(getlocal("daily_ydhk_desc1"),strSize)
	descLabel1:setAnchorPoint(ccp(0.5,1))
	descLabel1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82-80)
	descLabel1:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(descLabel1,2)

	local descLabel2 = GetTTFLabel(getlocal("daily_ydhk_desc2"),strSize)
	descLabel2:setAnchorPoint(ccp(0.5,1))
	descLabel2:setPosition(G_VisibleSizeWidth/2-40,descLabel1:getPositionY()-descLabel1:getContentSize().height-5)
	self.bgLayer:addChild(descLabel2,2)
	local costLabel = GetTTFLabel(self.cfg.monthCost,strSize)
	costLabel:setAnchorPoint(ccp(0,0.5))
	costLabel:setPosition(ccp(descLabel2:getContentSize().width+5,descLabel2:getContentSize().height/2))
	costLabel:setColor(G_ColorYellowPro)
	descLabel2:addChild(costLabel)
	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon:setAnchorPoint(ccp(0,0.5))
	goldIcon:setPosition(ccp(costLabel:getContentSize().width+5,costLabel:getContentSize().height/2))
	costLabel:addChild(goldIcon)

	local gemsFinalLimit, gemsAdded=dailyYdhkVoApi:getDailyGemsFinalLimit()
	local dailyBaseGems = gemsFinalLimit - gemsAdded
	local dailyGemsStr = ""
	if gemsAdded > 0 then
		dailyGemsStr = dailyBaseGems .. "+" .. gemsAdded
	else
		dailyGemsStr = tostring(dailyBaseGems)
	end
	local descLabel3 = GetTTFLabel(getlocal("daily_ydhk_desc3"),strSize)
	descLabel3:setAnchorPoint(ccp(0.5,1))
	descLabel3:setPosition(G_VisibleSizeWidth/2-60,descLabel2:getPositionY()-descLabel2:getContentSize().height-5)
	self.bgLayer:addChild(descLabel3,2)
	local getLabel = GetTTFLabel(getlocal("daily_ydhk_worldMine",{dailyGemsStr}),strSize)
	getLabel:setAnchorPoint(ccp(0,0.5))
	getLabel:setPosition(ccp(descLabel3:getContentSize().width+5,descLabel3:getContentSize().height/2))
	getLabel:setColor(G_ColorYellowPro)
	descLabel3:addChild(getLabel)
	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon:setAnchorPoint(ccp(0,0.5))
	goldIcon:setPosition(ccp(getLabel:getContentSize().width+5,getLabel:getContentSize().height/2))
	getLabel:addChild(goldIcon)

	local everyDaylabel = GetTTFLabel(getlocal("daily_ydhk_dailyGem"),strSize,true)
	everyDaylabel:setAnchorPoint(ccp(1,0.5))
	everyDaylabel:setPosition(ccp(470,G_VisibleSizeHeight-82-245))
	self.bgLayer:addChild(everyDaylabel,2)

	local bmGoldLabel = GetBMLabel(gemsFinalLimit,G_GoldFontSrcNew)
	bmGoldLabel:setAnchorPoint(ccp(0,0.5))
	bmGoldLabel:setPosition(ccp(490,G_VisibleSizeHeight-82-155-220))
	bmGoldLabel:setScale(0.6)
	self.bgLayer:addChild(bmGoldLabel,2)

	local adaH = 0
	if G_isAsia() == false then
		adaH = 40
	end
	local costAllLabel = GetTTFLabel(getlocal("daily_ydhk_allCost"),strSize)
	costAllLabel:setAnchorPoint(ccp(0,0.5))
	costAllLabel:setPosition(ccp(340-adaH,G_VisibleSizeHeight-82-205))
	costAllLabel:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(costAllLabel,2)

	local nowCost = dailyYdhkVoApi:getNowCost()
	local max = self.cfg.monthCost
	local color
	if nowCost < max then
		color = G_ColorRed
	else
		nowCost = max
		color = G_ColorYellowPro
	end
	local numLabel = GetTTFLabel(nowCost.."/"..max,22)
	numLabel:setColor(color)
	numLabel:setAnchorPoint(ccp(0,0.5))
	numLabel:setPosition(ccp(costAllLabel:getContentSize().width+10,costAllLabel:getContentSize().height/2))
	costAllLabel:addChild(numLabel)
	self.numLabel = numLabel

	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon:setAnchorPoint(ccp(0,0.5))
	goldIcon:setPosition(ccp(numLabel:getContentSize().width+10,numLabel:getContentSize().height/2))
	numLabel:addChild(goldIcon)

	local getAllLabel = GetTTFLabel(getlocal("daily_ydhk_dailyAllGem",{dailyYdhkVoApi:getAllReward()}),22)
	getAllLabel:setAnchorPoint(ccp(0,0.5))
	getAllLabel:setColor(G_ColorYellowPro)

	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon:setAnchorPoint(ccp(0,0.5))
	getAllLabel:addChild(goldIcon)

	 -- 等级黑条
    local levelBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
    levelBg:setOpacity(255*0.4)
    levelBg:setContentSize(CCSizeMake(getAllLabel:getContentSize().width+10+goldIcon:getContentSize().width+20,goldIcon:getContentSize().height))
    levelBg:setAnchorPoint(ccp(0.5,0.5))
    levelBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82-365))
    self.bgLayer:addChild(levelBg,2)

    getAllLabel:setPosition(ccp(10,levelBg:getContentSize().height/2))
	self.getAllLabel = getAllLabel
	goldIcon:setPosition(ccp(getAllLabel:getContentSize().width+10,costLabel:getContentSize().height/2))
	levelBg:addChild(getAllLabel)

	
	local function getCallBack()
		local function callback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData and sData.data then
					dailyYdhkVoApi:updateData(sData.data)
					self:refreshStatus()
					self:refreshAllReward()
					self.logList = dailyYdhkVoApi:getLogList()
					self:refreshNologLabel()
					self.tv:reloadData()
					local dailyGems=dailyYdhkVoApi:getDailyReward()
					playerVoApi:setGems(playerVoApi:getGems()+dailyGems)
					if sData.data.mggm then
						local gemsData={gems=sData.data.mggm[1],ts=sData.data.mggm[2]}
						goldMineVoApi:setDailyGemsData(gemsData,true)
					end
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
				end
			end
		end
   	 	socketHelper:dailyYdhkGetReward(callback)
	end

	local getBtn,getBtnMenu = G_createBotton(self.bgLayer,ccp(9999,G_VisibleSizeHeight-82-295),{getlocal("activity_ttjj_fund_now"),22},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getCallBack,0.7,-(self.layerNum-1)*20-4,2)
	self.getBtn = getBtn
	self.getBtnMenu = getBtnMenu

	local conditionLabel = GetTTFLabel(getlocal("get_prop_error1"),22)
	conditionLabel:setAnchorPoint(ccp(0.5,0.5))
	conditionLabel:setColor(G_ColorRed)
	conditionLabel:setPosition(ccp(470,G_VisibleSizeHeight-82-295))
	conditionLabel:setVisible(false)
	self.conditionLabel = conditionLabel
	self.bgLayer:addChild(conditionLabel,2)

	self:refreshStatus()

	-- 跨天加监听事件
	local function listener(event,data)
		self:refreshDay()
	end
	self.listener = listener
	if(eventDispatcher:hasEventHandler("overADay",self.listener)==false)then
		eventDispatcher:addEventListener("overADay",self.listener)
	end
end

-- -- 跨天刷新
-- function dailyYdhkDialog:overADayListener(event,data)
-- end

-- 刷新领取状态
function dailyYdhkDialog:refreshStatus( ... )

	if dailyYdhkVoApi:judgeCanReward() == 1 then
		self.conditionLabel:setVisible(true)
		self.getBtnMenu:setPosition(ccp(9999,G_VisibleSizeHeight-82-295))
	elseif dailyYdhkVoApi:judgeCanReward() == 2 then
		self.conditionLabel:setVisible(false)
		self.getBtnMenu:setPosition(ccp(470,G_VisibleSizeHeight-82-295))
		local btnLabel = tolua.cast(self.getBtn:getChildByTag(101),"CCLabelTTF")
		btnLabel:setString(getlocal("activity_hadReward"))
		self.getBtn:setEnabled(false)
	elseif dailyYdhkVoApi:judgeCanReward() == 3 then
		self.conditionLabel:setVisible(false)
		self.getBtnMenu:setPosition(ccp(470,G_VisibleSizeHeight-82-295))
		local btnLabel = tolua.cast(self.getBtn:getChildByTag(101),"CCLabelTTF")
		btnLabel:setString(getlocal("activity_ttjj_fund_now"))
		self.getBtn:setEnabled(true)
	end
end

function dailyYdhkDialog:refreshAllReward( ... )
	self.getAllLabel:setString(getlocal("daily_ydhk_dailyAllGem",{dailyYdhkVoApi:getAllReward()}))
end

function dailyYdhkDialog:refreshNologLabel( ... )
	if #self.logList == 0 then
		self.noLogLabel:setVisible(true)
	else
		self.noLogLabel:setVisible(false)
	end
end

function dailyYdhkDialog:initTableView( ... )

	local downSpire = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	downSpire:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-82-390-20-30))
	downSpire:setAnchorPoint(ccp(0.5,0))
	downSpire:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.bgLayer:addChild(downSpire)

	local noLogLabel = GetTTFLabel(getlocal("activity_tccx_no_record"),25,true)
	noLogLabel:setAnchorPoint(ccp(0.5,0.5))
	noLogLabel:setPosition(getCenterPoint(downSpire))
	noLogLabel:setColor(G_ColorGray)
	self.noLogLabel = noLogLabel
	downSpire:addChild(noLogLabel,5)
	self:refreshNologLabel()

	
	local tvHeight = G_VisibleSizeHeight-82-390-20-30-10
    local tvWidth = G_VisibleSizeWidth-40

    local function callBack( ... )
    	return self:eventHandler(...)
    end

    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
	self.tv:setPosition(ccp(20,35))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.tv:setMaxDisToBottomOrTop(120)

	self.bgLayer:addChild(self.tv)

end

function dailyYdhkDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        return #self.logList
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-40,60)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        self:initCell(cell,idx)
        return cell
    elseif fn=="ccTouchBegan" then
    	return true
    elseif fn=="ccTouchMoved" then
    elseif fn=="ccScrollEnable" then
    end
end

function dailyYdhkDialog:refreshTime( ... )
	if tolua.cast(self.acTimeLb,"CCLabelTTF") then
    	self.acTimeLb:setString(dailyYdhkVoApi:getTimeStr())
    end
end

-- -- 跨月刷新
-- function dailyYdhkDialog:refreshMonth( ... )
-- 	if dailyYdhkVoApi:getCts()-base.serverTime <= 0 and  dailyYdhkVoApi:getFreshFlag() == false then
-- 		dailyYdhkVoApi:setFreshFlag()
-- 	end
-- end

-- function dailyYdhkDialog:refreshData( ... )
-- 	if dailyYdhkVoApi:getFreshFlag() == true then

-- 	end
-- end

-- 跨天刷新
function dailyYdhkDialog:refreshDay( ... )

	local function callback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				dailyYdhkVoApi:updateData(sData.data)
				self:refreshStatus()
				self:refreshTime()
				self:refreshAllReward()
				self:refreshCost()
				self.logList = dailyYdhkVoApi:getLogList()
				self:refreshNologLabel()
			end
		end
	end
    socketHelper:dailyYdhkGetData(callback)

end


function dailyYdhkDialog:initCell(cell,idx)

	local log = self.logList[idx+1]
	if log then

		cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,60))
		local timeStr = G_getDataTimeStr(log[2])
		local num = log[1]

		local color = G_ColorWhite
		local descStr

		local timeLabel = GetTTFLabel(timeStr,22)
		timeLabel:setAnchorPoint(ccp(0,0.5))
		timeLabel:setPosition(ccp(20,cell:getContentSize().height/2))
		cell:addChild(timeLabel)

		if num == 0 then
			descStr = getlocal("daily_ydhk_logNoGem")
		elseif num < self.cfg.goldDayLimit then
			descStr = getlocal("daily_ydhk_gemReachLimit")
		else
			descStr = getlocal("daily_ydhk_logDesc")
			color = G_ColorYellowPro
		end
		local descLabel
		local strSize = 22
		if G_isAsia() == false then
			strSize = 18
			descLabel = GetTTFLabelWrap(descStr,20,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		else
			descLabel = GetTTFLabel(descStr,strSize)
		end

		descLabel:setAnchorPoint(ccp(0,0.5))
		descLabel:setColor(G_ColorYellowPro)
		descLabel:setPosition(ccp(20+timeLabel:getContentSize().width+10,cell:getContentSize().height/2))
		cell:addChild(descLabel)

		if color then

			timeLabel:setColor(color)
			descLabel:setColor(color)

			local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
			goldIcon:setAnchorPoint(ccp(1,0.5))
			goldIcon:setPosition(ccp(cell:getContentSize().width-20,cell:getContentSize().height/2))
			cell:addChild(goldIcon)

			local numLabel = GetTTFLabel("+"..num,22,true)
			numLabel:setAnchorPoint(ccp(1,0.5))
			numLabel:setColor(color)
			numLabel:setPosition(ccp(cell:getContentSize().width-20-goldIcon:getContentSize().width-5,cell:getContentSize().height/2))
			cell:addChild(numLabel)
		end

		local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png",CCRect(4, 0, 2, 2),function ()end)--modifiersLine2
        lineSp:setContentSize(CCSizeMake(cell:getContentSize().width-40,2))
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(ccp(cell:getContentSize().width/2,1))
        cell:addChild(lineSp)
	end
end

function dailyYdhkDialog:flashStar( ... )
	if self.timeInterval <= base.serverTime then
		self:runStarAction()
		self.timeInterval = base.serverTime + math.random(3,10)
	end
end

function dailyYdhkDialog:runStarAction(flag)
	
	local posX = math.random(65,150)
	local posY = math.random(200,270)
	posY = G_VisibleSizeHeight-82-posY

	local blingSp=CCSprite:createWithSpriteFrameName("emblemBling.png")
	
	blingSp:setPosition(posX,posY)
	self.bgLayer:addChild(blingSp,5)
	blingSp:setOpacity(0)

	local fadeIn=CCFadeIn:create(0.5)
	local delay=CCDelayTime:create(2)
	local fadeOut=CCFadeOut:create(0.5)
	local arr1=CCArray:create()
	arr1:addObject(fadeIn)
	arr1:addObject(delay)
	arr1:addObject(fadeOut)
	local seque=CCSequence:create(arr1)
	
	local arr2=CCArray:create()
	local rotate=CCRotateBy:create(3,360)
	arr2:addObject(seque)
	arr2:addObject(rotate)
	local spawn=CCSpawn:create(arr2)

	local function callBack( ... )
		blingSp:removeFromParentAndCleanup(true)
		blingSp = nil
	end 
	local callFunc = CCCallFunc:create(callBack)

	local seq = CCSequence:createWithTwoActions(spawn,callFunc)

	blingSp:runAction(seq)
end


function dailyYdhkDialog:refreshCost( ... )
	local nowCost = dailyYdhkVoApi:getNowCost()
	local max = self.cfg.monthCost
	local color
	if nowCost < max then
		color = G_ColorRed
	else
		nowCost = max
		color = G_ColorYellowPro
	end
	self.numLabel:setColor(color)
	self.numLabel:setString(nowCost.."/"..max)
end

function dailyYdhkDialog:dispose( ... )
	eventDispatcher:removeEventListener("overADay",self.listener)
	self.listener = nil
end

function dailyYdhkDialog:tick( ... )
	self:refreshTime()
	self:flashStar()
end