gloryUpgradeShowDialog=smallDialog:new()

function gloryUpgradeShowDialog:new(layerNum,whiDia)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.showDia = whiDia
	self.dialogLayer=nil

	return nc
end
function gloryUpgradeShowDialog:close()
	self.showDia=nil
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    base:removeFromNeedRefresh(self)
end
function gloryUpgradeShowDialog:init(callbackSure)
	self.dialogWidth=500
	self.dialogHeight=770
	self.isTouch=nil

	if  self.showDia ==3 then
		self.dialogHeight =500
	end

	local addW = 110
	local addH = 130
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	self.bgLayer:setPosition(ccp(self.bgLayer:getPositionX(),self.bgLayer:getPositionY()-50))

	if self.showDia ==3 then
		-- local titleBg = CCSprite:createWithSpriteFrameName("gloryTitleBg.png")
		-- titleBg:setAnchorPoint(ccp(0.5,0))
		-- titleBg:setPosition(ccp(self.bgLayer:getPositionX(),self.bgLayer:getPositionY()+self.dialogHeight*0.5))
		-- titleBg:setScaleX(self.dialogWidth/titleBg:getContentSize().width)
		-- self.dialogLayer:addChild(titleBg)
	end


	local function close()
		print("close()---------")
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	if self.showDia ==3 then--个人信息内显示使用
		self:showUpgrade()
	end

    local function nilFunc()
    	-- if self.showDia ==3 then
	    -- 	self:close()
	    -- end
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-2)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)


	if self.showDia ==3 then
		local function sureHandler()
	    	print("sureHandler--------")
	        if G_checkClickEnable()==false then
				do
					return
				end
			else
				base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
			end
			PlayEffect(audioCfg.mouseClick)
	        self:close()
	    end
	    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
	    local sureMenu=CCMenu:createWithItem(sureItem);
	    sureMenu:setPosition(ccp(self.dialogWidth*0.5,self.dialogWidth*0.13))
	    sureMenu:setTouchPriority(-(self.layerNum-1)*20-3);
	    self.bgLayer:addChild(sureMenu)
	end

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function gloryUpgradeShowDialog:showUpgrade( )
	--gloryUpgradeStr
	local strSize2 = 20
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =25
  	end


  	local gloryCfg = gloryVoApi:getPlayerGlory( )

	local curLevel=playerVoApi:getPlayerLevel()
    local m_gloryPic = playerVoApi:getPlayerBuildPic(curLevel)
    local buildIcon = CCSprite:createWithSpriteFrameName(m_gloryPic)
    -- buildIcon:setScaleX(self.gloryBg:getContentSize().width/buildIcon:getContentSize().width)
    -- buildIcon:setScaleY(self.gloryBg:getContentSize().width/buildIcon:getContentSize().width)
    buildIcon:setScale(1.1)
    buildIcon:setAnchorPoint(ccp(0,1))
    buildIcon:setPosition(ccp(20,self.bgLayer:getContentSize().height-70))
    self.bgLayer:addChild(buildIcon)

    local upPicTb = {"ShapeTank.png","ShapeGift.png"}
    for i=1,2 do
    	local spriteTitle = CCSprite:createWithSpriteFrameName(upPicTb[i]);
    	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
		spriteTitle:setPosition(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height+30)
		self.bgLayer:addChild(spriteTitle,i-1)
    end


	local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSP:setScaleX(self.bgLayer:getContentSize().width*0.6 /lineSP:getContentSize().width)
	lineSP:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-70))
	self.bgLayer:addChild(lineSP)

	local strTb = {getlocal("gloryUpgradeStr"),getlocal("congratulationsStr"),getlocal("gloryCityUpgradeStr",{gloryCfg.level}),getlocal("getGrowingStr")}----假数据！！！！！！
	local strPosTb ={ccp(self.dialogWidth*0.5,self.dialogHeight-25),ccp(self.dialogWidth*0.65,self.dialogHeight*0.77),ccp(self.dialogWidth*0.65,self.dialogHeight*0.76-40),ccp(self.dialogWidth*0.5,self.dialogHeight*0.55)}
	local strColorTb = {G_ColorYellowPro,nil,nil,G_ColorYellowPro}

	for i=1,4 do
		local StrLabel = GetTTFLabelWrap(strTb[i],strSize2,CCSizeMake(self.dialogWidth*0.5,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		StrLabel:setAnchorPoint(ccp(0.5,1))
		StrLabel:setPosition(strPosTb[i])
		self.bgLayer:addChild(StrLabel,2)
		if strColorTb[i] ~=nil then
			StrLabel:setColor(strColorTb[i])
		end
		if i ==1 then 
			StrLabel:setFontSize(35)
		elseif i ==4 then
			StrLabel:setFontSize(28)
			local bgSp1=CCSprite:createWithSpriteFrameName("groupSelf.png")
			bgSp1:setAnchorPoint(ccp(0.5,1))
			bgSp1:setScaleX((self.dialogWidth+20)/bgSp1:getContentSize().width)
			bgSp1:setScaleY(2)
			bgSp1:setPosition(ccp(self.dialogWidth*0.5+20,self.dialogHeight*0.55))
			self.bgLayer:addChild(bgSp1)
		end
	end
		
	local addTbStr = {"haveTroopNumsStr","baseResource"}
	local addTbNumsStr = {gloryCfg.troopsUp,gloryCfg.resource}
	for i=1,2 do
		local addStr = GetTTFLabel(getlocal(addTbStr[i])..":",25)
	    addStr:setAnchorPoint(ccp(0.5,1))
	    addStr:setPosition(ccp(self.dialogWidth*0.45,self.dialogHeight*0.5-50-(i-1)*30))
	    self.bgLayer:addChild(addStr)

	    local addNumsStr = GetTTFLabel(addTbNumsStr[i],25)
	    addNumsStr:setAnchorPoint(ccp(0,1))
	    addNumsStr:setPosition(ccp(self.dialogWidth*0.45+addStr:getContentSize().width*0.5+5,self.dialogHeight*0.5-50-(i-1)*30))
	    self.bgLayer:addChild(addNumsStr)
	end

	
end


-- function gloryUpgradeShowDialog:initTableView( ... )

-- 	local function callBack(...)
-- 	   return self:eventHandler(...)
-- 	end
-- 	local hd= LuaEventHandler:createHandler(callBack)
-- 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth ,self.dialogHeight*0.3),nil)
-- 	self.bgLayer:addChild(self.tv)
-- 	self.tv:setPosition(ccp(15,self.dialogHeight*0.15))
-- 	self.tv:setAnchorPoint(ccp(0,0))
-- 	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
-- 	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
-- 	self.tv:setMaxDisToBottomOrTop(130)
-- end

-- function gloryUpgradeShowDialog:eventHandler(handler,fn,idx,cel)
-- 	local needHeight = 200
-- 	local strSize2 = 18
--   	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
--     	strSize2 =20
--   	end
--    if fn=="numberOfCellsInTableView" then
--        return 1
--    elseif fn=="tableCellSizeForIndex" then
   		
--        return  CCSizeMake(self.dialogWidth ,self.dialogHeight*0.3)-- -100
--    elseif fn=="tableCellAtIndex" then
--        local cell=CCTableViewCell:new()
--        local needHeight2 = 240

       
--        	local function touch( ) end 
-- 		self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
-- 		self.wholeBgSp:setContentSize(CCSizeMake(self.dialogWidth ,self.dialogHeight*0.3))
-- 		self.wholeBgSp:setAnchorPoint(ccp(0,0))
-- 		self.wholeBgSp:setOpacity(0)
-- 		self.wholeBgSp:setPosition(ccp(0,0))
-- 		cell:addChild(self.wholeBgSp)

		

-- 		local directionsStr = GetTTFLabelWrap(getlocal("gloryDirection",{0}),strSize2,CCSizeMake(self.dialogWidth-110,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
-- 	  	directionsStr:setAnchorPoint(ccp(0,1))
-- 	  	directionsStr:setPosition(ccp(40,self.wholeBgSp:getContentSize().height-5))
-- 	  	self.wholeBgSp:addChild(directionsStr)

--        cell:autorelease()
--        return cell
--    elseif fn=="ccTouchBegan" then
--        self.isMoved=false
--        return true
--    elseif fn=="ccTouchMoved" then
--        self.isMoved=true
--    elseif fn=="ccTouchEnded"  then
       
--    end
-- end

-- function gloryUpgradeShowDialog:initUpDia( )
-- 	local strSize2 = 20
--   	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
--     	strSize2 =22
--   	end

--   	local function renewCall( )
--   		print("renewCall~~~~")
--   	end
--   	local renewBtn = GetButtonItem("BtnUp.png","BtnUp_Down.png","BtnUp_Down.png",renewCall,10,nil,nil)
-- 	local renewMenu = CCMenu:createWithItem(renewBtn);
-- 	renewMenu:setTouchPriority(-(self.layerNum-1)*20-3);
-- 	renewMenu:setScale(0.8)
-- 	renewBtn:setAnchorPoint(ccp(1,0.5))
-- 	renewMenu:setPosition(ccp(self.bgLayer:getContentSize().width-100,self.bgLayer:getContentSize().height-180))
-- 	self.bgLayer:addChild(renewMenu)

--   	local lineSP1=CCSprite:createWithSpriteFrameName("LineCross.png");
-- 	lineSP1:setScaleX((self.bgLayer:getContentSize().width )/lineSP1:getContentSize().width)
-- 	lineSP1:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.8))
-- 	self.bgLayer:addChild(lineSP1,1)

-- 	local gloryCfg = playerVoApi:getPlayerGlory( )

-- 	local curLevel=playerVoApi:getPlayerLevel()
--     local m_gloryPic = playerVoApi:getPlayerBuildPic(curLevel)
--     local buildIcon = CCSprite:createWithSpriteFrameName(m_gloryPic)
--     -- buildIcon:setScaleX(self.gloryBg:getContentSize().width/buildIcon:getContentSize().width)
--     -- buildIcon:setScaleY(self.gloryBg:getContentSize().width/buildIcon:getContentSize().width)
--     buildIcon:setScale(1.7)
--     buildIcon:setAnchorPoint(ccp(0,0))
--     buildIcon:setPosition(ccp(-10,self.dialogHeight*0.8+5))
--     self.bgLayer:addChild(buildIcon)

--     local stateStr = GetTTFLabel(getlocal("state")..":",25)
--     stateStr:setAnchorPoint(ccp(0,1))
--     stateStr:setPosition(ccp(self.dialogWidth*0.43,self.dialogHeight-50))
--     self.bgLayer:addChild(stateStr)

--     local curState = "gloryStr"--假数据 需要取相关信息确定
--     local curStateStr = GetTTFLabel(getlocal(curState),25)
--     curStateStr:setAnchorPoint(ccp(0,1))
--     curStateStr:setPosition(ccp(stateStr:getContentSize().width+5+self.dialogWidth*0.43,self.dialogHeight-50))
--     self.bgLayer:addChild(curStateStr)

--     local gloryDegreeStr = GetTTFLabel(getlocal("gloryDegreeStr")..":",25)
--     gloryDegreeStr:setAnchorPoint(ccp(0,1))
--     gloryDegreeStr:setPosition(ccp(self.dialogWidth*0.43,self.dialogHeight-90))
--     self.bgLayer:addChild(gloryDegreeStr)

--     local gloryDgreeWithCurAndUp = GetTTFLabel(getlocal("scheduleChapter",{0,0}),25)--假数据 需要取相关信息确定
--     gloryDgreeWithCurAndUp:setAnchorPoint(ccp(0,1))
--     gloryDgreeWithCurAndUp:setPosition(ccp(gloryDegreeStr:getContentSize().width+5+self.dialogWidth*0.43,self.dialogHeight-90))
--     self.bgLayer:addChild(gloryDgreeWithCurAndUp)



-- 	local upLb = GetTTFLabelWrap(getlocal("current_level_2")..":",strSize2+1,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
--   	upLb:setAnchorPoint(ccp(0,1))
--   	upLb:setColor(G_ColorGreen)
--   	upLb:setPosition(ccp(10,self.bgLayer:getContentSize().height*0.8-20))
--   	self.bgLayer:addChild(upLb)

--   	local gloryValueStr = GetTTFLabel(getlocal("gloryValueStr",{gloryCfg.level}),strSize2);
-- 	gloryValueStr:setAnchorPoint(ccp(0,1));
-- 	gloryValueStr:setPosition(ccp(110,upLb:getPositionY()-25));
-- 	self.bgLayer:addChild(gloryValueStr,2);

--   	local gloryDegree = GetTTFLabel("("..gloryCfg.gloryDegree..")",strSize2);
-- 	gloryDegree:setAnchorPoint(ccp(0,1));
-- 	gloryDegree:setPosition(ccp(115+gloryValueStr:getContentSize().width,upLb:getPositionY()-25));
-- 	self.bgLayer:addChild(gloryDegree,2);

--   	local leadership = GetTTFLabel(getlocal("leadership"),strSize2)
--   	leadership:setAnchorPoint(ccp(0,1))
--   	leadership:setPosition(ccp(110,gloryValueStr:getPositionY()-25))
--   	self.bgLayer:addChild(leadership)

--   	local troopNums = GetTTFLabel("+"..gloryCfg.troopNums,strSize2);
-- 	troopNums:setAnchorPoint(ccp(0,1));
-- 	troopNums:setPosition(ccp(115+leadership:getContentSize().width,leadership:getPositionY()));
-- 	self.bgLayer:addChild(troopNums,2);

--   	local baseResource = GetTTFLabel(getlocal("baseResource"),strSize2)
--   	baseResource:setAnchorPoint(ccp(0,1))
--   	baseResource:setPosition(ccp(110,leadership:getPositionY()-25))
--   	self.bgLayer:addChild(baseResource)

--   	local baseResourceNums = GetTTFLabel("+"..gloryCfg.resource,strSize2);
-- 	baseResourceNums:setAnchorPoint(ccp(0,1));
-- 	baseResourceNums:setPosition(ccp(115+baseResource:getContentSize().width,baseResource:getPositionY()));
-- 	self.bgLayer:addChild(baseResourceNums,2);
-- --------------
--   	local middLb = GetTTFLabelWrap(getlocal("upgradeEffectStr")..":",strSize2+1,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
--   	middLb:setAnchorPoint(ccp(0,1))
--   	middLb:setColor(G_ColorGreen)
--   	middLb:setPosition(ccp(10,baseResource:getPositionY()-25))
--   	self.bgLayer:addChild(middLb)
--   	--gloryValueStr
--   	local nextGloryValueStr = GetTTFLabel(getlocal("gloryValueStr",{gloryCfg.level}),strSize2);
-- 	nextGloryValueStr:setAnchorPoint(ccp(0,1));
-- 	nextGloryValueStr:setPosition(ccp(110,middLb:getPositionY()-25));
-- 	self.bgLayer:addChild(nextGloryValueStr,2);

--   	local nextGloryDegree = GetTTFLabel("("..gloryCfg.gloryDegree..")",strSize2);
-- 	nextGloryDegree:setAnchorPoint(ccp(0,1));
-- 	nextGloryDegree:setColor(G_ColorRed)
-- 	nextGloryDegree:setPosition(ccp(115+nextGloryValueStr:getContentSize().width,nextGloryValueStr:getPositionY()));
-- 	self.bgLayer:addChild(nextGloryDegree,2);

--   	local nextLeadership = GetTTFLabel(getlocal("leadership"),strSize2)
--   	nextLeadership:setAnchorPoint(ccp(0,1))
--   	nextLeadership:setPosition(ccp(110,nextGloryValueStr:getPositionY()-25))
--   	self.bgLayer:addChild(nextLeadership)

--   	local nextTroopNums = GetTTFLabel("+"..gloryCfg.troopNums,strSize2);
-- 	nextTroopNums:setAnchorPoint(ccp(0,1));
-- 	nextTroopNums:setColor(G_ColorGreen)
-- 	nextTroopNums:setPosition(ccp(115+nextLeadership:getContentSize().width,nextLeadership:getPositionY()));
-- 	self.bgLayer:addChild(nextTroopNums,2);

--   	local nextBaseResource = GetTTFLabel(getlocal("baseResource"),strSize2)
--   	nextBaseResource:setAnchorPoint(ccp(0,1))
--   	nextBaseResource:setPosition(ccp(110,nextLeadership:getPositionY()-25))
--   	self.bgLayer:addChild(nextBaseResource)

--   	local nextBaseResourceNums = GetTTFLabel("+"..gloryCfg.resource,strSize2);
-- 	nextBaseResourceNums:setAnchorPoint(ccp(0,1));
-- 	nextBaseResourceNums:setColor(G_ColorGreen)
-- 	nextBaseResourceNums:setPosition(ccp(115+nextBaseResource:getContentSize().width,nextBaseResource:getPositionY()));
-- 	self.bgLayer:addChild(nextBaseResourceNums,2);

-- 	local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png");
-- 	lineSP:setScaleX((self.bgLayer:getContentSize().width )/lineSP:getContentSize().width)
-- 	lineSP:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.5))
-- 	self.bgLayer:addChild(lineSP,1)

-- 	local shuoming = GetTTFLabel(getlocal("shuoming")..":",strSize2)
-- 	shuoming:setAnchorPoint(ccp(0,1))
-- 	shuoming:setColor(G_ColorGreen)
-- 	shuoming:setPosition(ccp(5,lineSP:getPositionY()-10))
-- 	self.bgLayer:addChild(shuoming)

-- end



-- function gloryUpgradeShowDialog:initShowInPlayerInfo( )
-- 	local strSize2 = 20
-- 	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
--     	strSize2 =25
--   	end

-- 	local upTitleTb = {"help3_t3_t2","RankScene_level","amountStr"}
-- 	local leftTitleTb = {getlocal("purifying_common"),"+",getlocal("become_strong_commander"),"+",getlocal("help2_t1_t3"),"+",getlocal("gloryStr")}
-- 	local downTitleTb = {"nextLevelStr","upgradeClaimStr","upgradeEffectStr"}
-- 	local upCurShowTb = {getlocal("scheduleChapter",{playerVoApi:getPlayerCurGlory( ),playerVoApi:getPlayerGlory( ).gloryDegree}),}

-- 	for i=1,3 do
-- 		local upTitleTbStr = GetTTFLabelWrap(getlocal(upTitleTb[i]),strSize2,CCSizeMake(self.dialogWidth*0.3,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
-- 		upTitleTbStr:setAnchorPoint(ccp(0,1))
-- 		upTitleTbStr:setPosition(ccp(self.dialogWidth*((i-1)*0.38)+20,self.dialogHeight-30))
-- 		self.bgLayer:addChild(upTitleTbStr)
-- 	end


-- 	for i=1,7 do
-- 		local needWidht2 = 0
-- 		local leftTitleStr = GetTTFLabelWrap(leftTitleTb[i],strSize2,CCSizeMake(self.dialogWidth*0.25,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
-- 		leftTitleStr:setAnchorPoint(ccp(0,1))
-- 		if i%2 ==0 then 
-- 			needWidht2 =15
-- 			leftTitleStr:setColor(G_ColorYellowPro)
-- 		end
-- 		leftTitleStr:setPosition(ccp(20+needWidht2,self.dialogHeight-(i-1)*40-80))
-- 		self.bgLayer:addChild(leftTitleStr)
-- 	end

-- 	local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png");
-- 	lineSP:setScaleX((self.bgLayer:getContentSize().width )/lineSP:getContentSize().width)
-- 	lineSP:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.22))
-- 	self.bgLayer:addChild(lineSP,1)


-- 	-- for i=1,3 do
-- 	-- 	local leftDownTitleStr = GetTTFLabelWrap(getlocal(downTitleTb[i])..":",strSize2,CCSizeMake(self.dialogWidth*0.32,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
-- 	-- 	leftDownTitleStr:setAnchorPoint(ccp(0,0.5))
-- 	-- 	leftDownTitleStr:setPosition(ccp(35,self.dialogHeight*0.45-(i-1)*50-10))
-- 	-- 	self.bgLayer:addChild(leftDownTitleStr)
-- 	-- end
-- end



function gloryUpgradeShowDialog:dispose()
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.dialogLayer=nil
end
