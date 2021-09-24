acTacticalDiscussDialog=commonDialog:new()

function acTacticalDiscussDialog:new(layerNum)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    self.wholeBgSp =nil
    self.tv =nil
    self.tv2=nil
    self.girSaid=nil
    self.downBg=nil
    self.cardSpTb={}
    self.cardPosSizeTb={}
    self.cardSpAwardTb={}
    self.showedAwardTb={}
    self.lastAwardTb={}
    self.lastIdx=0
    self.epLastIdx=0
    self.currCostGold=nil
    self.reSetIdx =nil
    self.isToday = nil
    self.gemIcon1 =nil
    self.goldStr1 =nil
    self.freeBtn =nil
    self.freeBtnMenu =nil
    self.talkBtn1 =nil
    self.talkBtn1Menu=nil
    self.needcardScale1 = nil
	self.needcardScale2 = nil
	self.needIphone5IconScaleX = nil
	self.needIphone5IconScaleY = nil
    return nc
end
function acTacticalDiscussDialog:dispose( )
	self.layerNum=nil
    self.wholeBgSp =nil
    self.tv =nil
    self.tv2=nil
    self.girSaid=nil
    self.cardSpTb=nil
    self.downBg=nil
    self.cardPosSizeTb=nil
    self.cardSpAwardTb=nil
    self.showedAwardTb=nil
    self.currCostGold=nil
    self.lastAwardTb=nil
    self.lastIdx=nil
    self.epLastIdx=nil
    self.reSetIdx =nil
    self.isToday =nil
    self.gemIcon1 =nil
    self.goldStr1 =nil
    self.freeBtn =nil
    self.freeBtnMenu =nil
    self.talkBtn1 =nil
    self.talkBtn1Menu=nil
    self.needcardScale1 = nil
	self.needcardScale2 = nil
	self.needIphone5IconScaleX = nil
	self.needIphone5IconScaleY = nil
	self.timeLb=nil
end

function acTacticalDiscussDialog:initTableView()
  	self.needcardScale1 = 0.8
	self.needcardScale2 = 0.9
	self.needIphone5IconScaleX = 1
	self.needIphone5IconScaleY = 1.2
	if G_isIphone5() then
		self.needcardScale1 = 1.1
		self.needcardScale2 = 1
		self.needIphone5IconScaleX =1.3
		self.needIphone5IconScaleY =1.4
	end

  self.isToday = acTacticalDiscussVoApi:isToday()
  if self.isToday ==false then
  	acTacticalDiscussVoApi:setFreeTime()
  end
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth*0.5, 5))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth ,G_VisibleSizeHeight-120),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(12,15))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acTacticalDiscussDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
		local needBgAddHeight =150
		if G_isIphone5() then
		    needBgAddHeight =-100
		end
		return  CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight+needBgAddHeight)-- -100
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       local needBgAddHeight =150
		if G_isIphone5() then
		    needBgAddHeight =-100
		end
		local function touch( )
		end 	
		self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)--拉霸动画背景
		self.wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-24,G_VisibleSizeHeight+needBgAddHeight))

		self.wholeBgSp:setAnchorPoint(ccp(0.5,0))
		self.wholeBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,0))
		cell:addChild(self.wholeBgSp,3)
		local function touch2( )
			-- print("---------wholeTouchBgSp------------")
			local tag = acTacticalDiscussVoApi:getClickTag()
		end 
		self.wholeTouchBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch2)--拉霸动画背景
		self.wholeTouchBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-24,G_VisibleSizeHeight+needBgAddHeight))
		self.wholeTouchBgSp:setTouchPriority(-(self.layerNum-1)*20-20)
		self.wholeTouchBgSp:setIsSallow(true)
		self.wholeTouchBgSp:setAnchorPoint(ccp(0.5,0))
		self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5000))
		cell:addChild(self.wholeTouchBgSp,3)
		self.wholeTouchBgSp:setVisible(false)

		self:initWholeSp(self.wholeBgSp)
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
function acTacticalDiscussDialog:openInfo()
	-- print("tip~~~~~")
	local strSize3 = 21
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		strSize3 =25
	end
	require "luascript/script/game/scene/gamedialog/activityAndNote/acTacticalDiscussSmallDialog"
	tabStr = {"\n",getlocal("activity_zhanshuyantao_tip4"),"\n",getlocal("activity_zhanshuyantao_tip3"),"\n",getlocal("activity_zhanshuyantao_tip2"),"\n",getlocal("activity_zhanshuyantao_tip1"),"\n"}
	local sd=acTacticalDiscussSmallDialog:new(self.layerNum + 1,1)
    local dialog= sd:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize3,nil,getlocal("shuoming"))
  
  	sceneGame:addChild(dialog,self.layerNum+1)
end
function acTacticalDiscussDialog:initWholeSp(bgDia)
	local strSize2 = 21
	local strSize3 = 20
	local strSize6 = 22
	local posStr = 25
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		strSize2 =23
		strSize3 =24
		posStr =10
		strSize6 =26
	end
	local needIphone5Height_1 = 0
	local needIphone5Height_2 = 0
	local needIphone5Height_3 = 0
	local needcardScale1 = 0.8
	local needcardScale2 = 0.9
	local needIphone5PosHeight_1 = 60
	local needIphone5PosBeiShu = 1.66
	local needIphone5IconScaleX = 1
	local needIphone5IconScaleY = 1.2
	if G_isIphone5() then
		needIphone5Height_1 =20
		needIphone5Height_2 =15
		needIphone5Height_3 =180
		needcardScale1 = 1.1
		needcardScale2 = 1
		needIphone5PosHeight_1 =120
		needIphone5PosBeiShu = 1.72
		needIphone5IconScaleX =1.3
		needIphone5IconScaleY =1.4
	end
	local function touch(tag,object)
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end

		PlayEffect(audioCfg.mouseClick)
		if tag == 1 then
		  self:openInfo()
		end
	end

	local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    headBg:setContentSize(CCSizeMake(bgDia:getContentSize().width-4,bgDia:getContentSize().height*0.16+needIphone5Height_1))
    headBg:setAnchorPoint(ccp(0.5,1))
    headBg:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height))
    bgDia:addChild(headBg) 

    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),strSize2+2)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp(headBg:getContentSize().width*0.5, headBg:getContentSize().height-5))
	acLabel:setColor(G_ColorYellowPro)
	headBg:addChild(acLabel,1)

	local acVo = acTacticalDiscussVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,28)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp(headBg:getContentSize().width*0.5, acLabel:getPositionY()-25))
	headBg:addChild(messageLabel,3)
	self.timeLb=messageLabel
	self:updateAcTime()

    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,1,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,1))
	menuItemDesc:setScale(0.7)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(headBg:getContentSize().width-10,headBg:getContentSize().height-10))
	headBg:addChild(menuDesc,2)

    local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale(headBg:getContentSize().height*0.7/girlImg:getContentSize().height)
	girlImg:setAnchorPoint(ccp(0,0))
	girlImg:setPosition(ccp(5,2))
	headBg:addChild(girlImg,1)

    local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	middleBg:setContentSize(CCSizeMake(headBg:getContentSize().width*0.8,headBg:getContentSize().height*0.6))
	middleBg:setAnchorPoint(ccp(0.5,0))
	middleBg:setPosition(ccp(headBg:getContentSize().width*0.5+35,5))
	headBg:addChild(middleBg)
	---------
	self.girSaid = GetTTFLabelWrap(getlocal("activity_zhanshuyantao_girlStr1"),strSize2,CCSizeMake(middleBg:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.girSaid:setAnchorPoint(ccp(0,0.5))
    self.girSaid:setPosition(ccp(30,middleBg:getContentSize().height*0.8-posStr))
    middleBg:addChild(self.girSaid,1)
    
    self.downBg= LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),function () do return end end)
	self.downBg:setContentSize(CCSizeMake(bgDia:getContentSize().width*0.98,bgDia:getContentSize().height*0.35+needIphone5Height_3))
	self.downBg:setAnchorPoint(ccp(0.5,1))
	self.downBg:setPosition(ccp(bgDia:getContentSize().width*0.5,headBg:getPositionY()-headBg:getContentSize().height-10+needIphone5Height_2))
	bgDia:addChild(self.downBg,1)

	self.str1  = GetTTFLabelWrap(getlocal("activity_zhanshuyantao_currAwardShowTitle"),strSize3,CCSizeMake(bgDia:getContentSize().width*0.5+80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.str1:setAnchorPoint(ccp(0.5,0.5))
	self.str1:setPosition(ccp(bgDia:getContentSize().width*0.5,self.downBg:getPositionY()-self.downBg:getContentSize().height-10))
	bgDia:addChild(self.str1,3)

    self.lastAwardTb =acTacticalDiscussVoApi:getLastAwardTb()
	local needHeightPos2 = 85
	local needSubBoxHeight = 50
	local awardIdx = 0
	local m = 0
    local n = 10
    if self.lastAwardTb and SizeOfTable(self.lastAwardTb)>0 then
    	for j=1,2 do
	        local jj = j-1
	        for i=1,3 do
	            m=m+1
	            n =n+1
	            local needWidth6 = 40+self.downBg:getContentSize().width*0.18*i+self.downBg:getContentSize().width*0.08*(i-1)
	            local cardSp = CCSprite:createWithSpriteFrameName("rewardCard2.png")
	            cardSp:setScale(needcardScale1)
	            cardSp:setScaleX(needcardScale2)
	            cardSp:setPosition(ccp(needWidth6,self.downBg:getPositionY()-self.downBg:getContentSize().height*needIphone5PosBeiShu-(cardSp:getContentSize().height*0.5+needIphone5PosHeight_1)*jj+needIphone5Height_3*2.5))
	            cardSp:setAnchorPoint(ccp(0.5,0.5))
	            -- goldSp:setOpacity(70)
	            self.downBg:addChild(cardSp,1)
	            if self.lastAwardTb[m] =="sp" then
	            	awardIdx =awardIdx+1
                	icon =CCSprite:createWithSpriteFrameName("serverWarTopMedal1.png")
                	icon:setPosition(ccp(cardSp:getContentSize().width/2,100))
                    cardSp:addChild(icon,2)
                    icon:setScaleY(needIphone5IconScaleY)
                    icon:setScaleX(needIphone5IconScaleX)
                    -- icon:setFlipX(true)

                    G_addRectFlicker(cardSp,2,2.4)
                else
                	local idx = tonumber(RemoveFirstChar(self.lastAwardTb[m]))
                	nameLb=GetTTFLabelWrap(getlocal("activity_zhanshuyantao_ljAward"..idx),strSize6,CCSizeMake(cardSp:getContentSize().width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                	nameLb:setAnchorPoint(ccp(0.5,0.5))
                	nameLb:setPosition(ccp(cardSp:getContentSize().width/2,100))
                    cardSp:addChild(nameLb,2)
                    -- nameLb:setFlipX(true)
                end
	            local cardPos = {x=cardSp:getPositionX(),y=cardSp:getPositionY()}
	            table.insert(self.cardPosSizeTb,cardPos)
	            table.insert(self.cardSpAwardTb,cardSp)
	            table.insert(self.cardSpTb,nil)

	        end
		end
		local needReward = acTacticalDiscussVoApi:formatNeedReward(self.layerNum)
		self.showedAwardTb=needReward[awardIdx+1]

		local idx = 0
	    for k,v in pairs(self.lastAwardTb) do
			if v =="sp" then
				idx= idx+1
			end
		end
		acTacticalDiscussVoApi:setCurrBigAwardIdx(idx)
	    local bigAwardIdx = acTacticalDiscussVoApi:getCurrBigAwardIdx()
	    if bigAwardIdx ==4 then
	    	self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr3"))
	    elseif bigAwardIdx ==5 then
	    	self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr4"))
	    elseif bigAwardIdx ==6 then
	    	self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr5"))
	    else 
	    	self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr2"))
	    end
    else
    	self.str1:setString(getlocal("activity_zhanshuyantao_awardShowTitle"))
	    for j=1,2 do
	        local jj = j-1
	        for i=1,3 do
	            m=m+1
	            n =n+1
	            local needWidth6 = 40+self.downBg:getContentSize().width*0.18*i+self.downBg:getContentSize().width*0.08*(i-1)

	            local cardSp = CCSprite:createWithSpriteFrameName("rewardCard1.png")
	            -- cardSp:setScale(0.8)
	            -- cardSp:setScaleX(0.9)
	            cardSp:setScale(needcardScale1)
	            cardSp:setScaleX(needcardScale2)
	            cardSp:setPosition(ccp(needWidth6,self.downBg:getPositionY()-self.downBg:getContentSize().height*needIphone5PosBeiShu-(cardSp:getContentSize().height*0.5+needIphone5PosHeight_1)*jj+needIphone5Height_3*2.5))
	            cardSp:setAnchorPoint(ccp(0.5,0.5))
	            -- goldSp:setOpacity(70)
	            self.downBg:addChild(cardSp,1)
	            local cardPos = {x=cardSp:getPositionX(),y=cardSp:getPositionY()}
	            table.insert(self.cardPosSizeTb,cardPos)
	            table.insert(self.cardSpAwardTb,nil)
	            table.insert(self.cardSpTb,cardSp)

	        end
		end
	end
	if awardIdx > 0 then
		self.lastIdx = awardIdx
	end
	local function callBack2(...)
        return self:eventHandler2(...)
    end
    local hd= LuaEventHandler:createHandler(callBack2)
    local height=0;
    self.tv2=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeWidth*0.18),nil)
    self.tv2:setAnchorPoint(ccp(0,0))
    -- self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv2:setPosition(ccp(10,self.str1:getPositionY()-bgDia:getContentSize().height*0.12-needIphone5Height_2))
    self.tv2:setMaxDisToBottomOrTop(120)
    bgDia:addChild(self.tv2)

    self.gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon1:setAnchorPoint(ccp(1,0.5))
	self.gemIcon1:setPosition(ccp(bgDia:getContentSize().width*0.3-33, self.tv2:getPositionY()-20-needIphone5Height_2))
	bgDia:addChild(self.gemIcon1,1)

	local gemIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
	gemIcon2:setAnchorPoint(ccp(1,0.5))
	gemIcon2:setPosition(ccp(bgDia:getContentSize().width*0.8-33, self.tv2:getPositionY()-20-needIphone5Height_2))
	bgDia:addChild(gemIcon2,1)

	-----
	local gold1 = acTacticalDiscussVoApi:getGoldCost1()
	local gold2 = acTacticalDiscussVoApi:getGoldCost2()
	self.goldStr1  = GetTTFLabel(gold1,24)
	self.goldStr1:setAnchorPoint(ccp(0,0.5))
	self.goldStr1:setPosition(ccp(bgDia:getContentSize().width*0.3-30, self.tv2:getPositionY()-20-needIphone5Height_2))
	bgDia:addChild(self.goldStr1,1)

	local goldStr2  = GetTTFLabel(gold2,24)
	goldStr2:setAnchorPoint(ccp(0,0.5))
	goldStr2:setPosition(ccp(bgDia:getContentSize().width*0.8-30, self.tv2:getPositionY()-20-needIphone5Height_2))
	bgDia:addChild(goldStr2,1)


	local function btnClick( tag,object)
		
		acTacticalDiscussVoApi:setClickTag(tag)
		local needCost = nil
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 33 then
        	
        elseif tag ==31 and tonumber(acTacticalDiscussVoApi:getGoldCost1()) > tonumber(playerVoApi:getGems()) then
        	--出板子 让玩家充值
        	needCost =tonumber(acTacticalDiscussVoApi:getGoldCost1())
        	acTacticalDiscussVoApi:setNeedCostNow(needCost)
        	acTacticalDiscussDialog:needMoneyDia(needCost,playerVoApi:getGems(),self.wholeTouchBgSp)
        	
        	do return end
        elseif tag ==32 and tonumber(acTacticalDiscussVoApi:getGoldCost2()) > tonumber(playerVoApi:getGems()) then
        	--出板子 让玩家充值
        	needCost =tonumber(acTacticalDiscussVoApi:getGoldCost2())
        	acTacticalDiscussVoApi:setNeedCostNow(needCost)
        	acTacticalDiscussDialog:needMoneyDia(needCost,playerVoApi:getGems(),self.wholeTouchBgSp)
        	
        	do return end
        elseif tag ==34  then
        	local currRestartTime,currRestartTimeNext = acTacticalDiscussVoApi:getCurrRestartTime()
		    local upRestartTime = acTacticalDiscussVoApi:getUpTimes()
		    local reStartGoldCostTb = acTacticalDiscussVoApi:getReStartGoldCostTb()
		    local bigAwardIdx = acTacticalDiscussVoApi:getCurrBigAwardIdx( )
		    
        	if tonumber(currRestartTimeNext) > tonumber(upRestartTime) then --activity_zhanshuyantao_kywx
        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanshuyantao_kywx"),30)
        		do return end
        	elseif bigAwardIdx >=6 then
        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanshuyantao_zyfa"),30)
        		do return end
        	elseif tonumber(reStartGoldCostTb[currRestartTimeNext]) >tonumber(playerVoApi:getGems()) then
		    	needCost =tonumber(reStartGoldCostTb[currRestartTimeNext])
		    	acTacticalDiscussVoApi:setNeedCostNow(needCost)
		    	acTacticalDiscussDialog:needMoneyDia(needCost,playerVoApi:getGems(),self.wholeTouchBgSp)
        		do return end
        	end
        end
        local acIdx =nil
        local tid =nil
        local free = nil
        if tag >29 then
	        acIdx = tag -30
	        tid = nil
	        if acIdx <3 then --普通抽奖，高级抽奖
	        	tid = acIdx
	        	acIdx =1
	        elseif acIdx ==4 then--抗议
	        	acIdx =acIdx-2
	        end
	    else
	    	acIdx =1
	    	free =true
	    end

        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
	        local function callback(fn,data)
	        	local ret,sData = base:checkServerData(data)
		        if ret==true then
		        	self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,0))
		        	local needCost = acTacticalDiscussVoApi:getNeedCostNow( )
		        	-- print("tag------>",tag)
		        		if tag ==34 then
		        			if sData.data and sData.data.zhanshuyantao and sData.data.zhanshuyantao.n then
			        			acTacticalDiscussVoApi:setCurrRestartTime(sData.data.zhanshuyantao.n)
			        			local currRestartTime,currRestartTimeNext = acTacticalDiscussVoApi:getCurrRestartTime()
			        			local upRestartTime = acTacticalDiscussVoApi:getUpTimes()
			        			local reStartGoldCostTb = acTacticalDiscussVoApi:getReStartGoldCostTb()
							    local currChangeNeedGold = nil
							    if currRestartTime==nil or currRestartTime <=0 then
							    	currChangeNeedGold =reStartGoldCostTb[1]
							    elseif  currRestartTimeNext <SizeOfTable(reStartGoldCostTb)+1 then
							    	currChangeNeedGold = reStartGoldCostTb[currRestartTimeNext]
							    elseif currRestartTimeNext >SizeOfTable(reStartGoldCostTb) then
							    	local highTime = SizeOfTable(reStartGoldCostTb)
							    	currChangeNeedGold =reStartGoldCostTb[highTime]
							    end
			        			self.currCostGold:setString(currChangeNeedGold)
			        			self.currCostedTime:setString(getlocal("super_weapon_challenge_troops_schedule",{currRestartTime,upRestartTime}))
			        			if tonumber(currRestartTimeNext) > tonumber(upRestartTime) then
			        				local menu = tolua.cast(self.touchDialogBg:getChildByTag(34),"CCMenu")
			        				local btn = tolua.cast(menu:getChildByTag(34),"CCMenuItemSprite")
			        				btn:setEnabled(false)
			        				self.gemIcon3:setVisible(false)
									self.currCostGold:setVisible(false)
			        			end
			        		end
		        			if sData.data and sData.data.zhanshuyantao and sData.data.zhanshuyantao.m then
			        			acTacticalDiscussVoApi:setLastAward(sData.data.zhanshuyantao.m)
			        			
			        			self:btnClick(tag)
			        		end

			        	elseif tag < 33 then
			        		if sData.data and sData.data.zhanshuyantao and sData.data.zhanshuyantao.m then
			        			acTacticalDiscussVoApi:setLastAward(sData.data.zhanshuyantao.m)
			        			local awardTb =sData.data.zhanshuyantao.m

				                if self.touchDialogBg then
				                	-- print("here?-",tag)
				                	acTacticalDiscussVoApi:setLastAward(awardTb)
				                	local moveby=CCMoveTo:create(1,ccp(bgDia:getContentSize().width*0.5,1))
									self.touchDialogBg:runAction(moveby)
								end
								self:btnClick(tag)
							end
							if sData.data and sData.data.zhanshuyantao and sData.data.zhanshuyantao.t and sData.data.zhanshuyantao.f then
								acTacticalDiscussVoApi:updateLastTime(sData.data.zhanshuyantao.t)--当免费 使用后 需要把时间戳置为当前0点时间戳
								acTacticalDiscussVoApi:setFreeTime(sData.data.zhanshuyantao.f)
								self:refresh( )
							end
			            elseif tag ==33 then
			            	if self.touchDialogBg then
			            		-- print("here??--",tag)
			            		local moveby=CCMoveTo:create(1,ccp(bgDia:getContentSize().width*0.5,1-self.tv2:getPositionY()+1))
								self.touchDialogBg:runAction(moveby)
							end
							self:btnClick(tag)
			            end
		        end
	        end 
        	socketHelper:zhanshuyantao(acIdx,callback,tid,free)
        end
    end 
--------
	self.freeBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen.png",btnClick,29,getlocal("daily_lotto_tip_2"),25)
    self.freeBtn:setAnchorPoint(ccp(0.5,0.5))
    self.freeBtnMenu=CCMenu:createWithItem(self.freeBtn)
    self.freeBtnMenu:setPosition(ccp(bgDia:getContentSize().width*0.25,self.gemIcon1:getPositionY()-50-needIphone5Height_2))
    self.freeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    bgDia:addChild(self.freeBtnMenu)  
--------
    self.talkBtn1 =GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge.png",btnClick,31,getlocal("activity_zhanshuyantao_talk1"),25)
    self.talkBtn1:setAnchorPoint(ccp(0.5,0.5))
    self.talkBtn1Menu=CCMenu:createWithItem(self.talkBtn1)
    self.talkBtn1Menu:setPosition(ccp(bgDia:getContentSize().width*0.25,self.gemIcon1:getPositionY()-50-needIphone5Height_2))
    self.talkBtn1Menu:setTouchPriority(-(self.layerNum-1)*20-2)
    bgDia:addChild(self.talkBtn1Menu)  

    -- if self.isToday ==false then
    -- 	self.freeBtn:setVisible(true)
    -- 	self.talkBtn1:setVisible(false)
    -- 	self.goldStr1:setVisible(false)
    -- 	self.gemIcon1:setVisible(false)
    -- end
    if acTacticalDiscussVoApi:getFreeTime( ) ==false then
    	self.freeBtn:setVisible(true)
    	self.talkBtn1:setVisible(false)
    	self.goldStr1:setVisible(false)
    	self.gemIcon1:setVisible(false)   	
    end
    local talkBtn2 =GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge.png",btnClick,32,getlocal("activity_zhanshuyantao_talk2"),25);
    talkBtn2:setAnchorPoint(ccp(0.5,0.5))
    local talkBtn2Menu=CCMenu:createWithItem(talkBtn2)
    talkBtn2Menu:setPosition(ccp(bgDia:getContentSize().width*0.75,self.gemIcon1:getPositionY()-50-needIphone5Height_2))
    talkBtn2Menu:setTouchPriority(-(self.layerNum-1)*20-2)
    bgDia:addChild(talkBtn2Menu)  

	local function touchDialog()
	end
	self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-5)
	local rect=CCSizeMake(bgDia:getContentSize().width-4,self.tv2:getPositionY()-2)
	self.touchDialogBg:setContentSize(rect)
	self.touchDialogBg:setAnchorPoint(ccp(0.5,0))
	self.touchDialogBg:setOpacity(255)
	-- self.touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*0.5,1))
	self.touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*0.5,1-self.tv2:getPositionY()+1))
	bgDia:addChild(self.touchDialogBg,1)

	touchDialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	touchDialogBg2:setTouchPriority(-(self.layerNum-1)*20-5)
	local rect=CCSizeMake(bgDia:getContentSize().width-4,self.tv2:getPositionY()-2)
	touchDialogBg2:setContentSize(rect)
	touchDialogBg2:setAnchorPoint(ccp(0.5,0))
	touchDialogBg2:setOpacity(255)
	-- self.touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*0.5,1))
	touchDialogBg2:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.5,0))
	self.touchDialogBg:addChild(touchDialogBg2,1)

	touchDialogBg3 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	touchDialogBg3:setTouchPriority(-(self.layerNum-1)*20-5)
	local rect=CCSizeMake(bgDia:getContentSize().width-4,self.tv2:getPositionY()-2)
	touchDialogBg3:setContentSize(rect)
	touchDialogBg3:setAnchorPoint(ccp(0.5,0))
	touchDialogBg3:setOpacity(255)
	-- self.touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*0.5,1))
	touchDialogBg3:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.5,0))
	self.touchDialogBg:addChild(touchDialogBg3,1)

	if self.lastAwardTb and SizeOfTable(self.lastAwardTb)>0 then
		self.touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*0.5,1))
	end

    local talkBtn3 =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen.png",btnClick,33,getlocal("activity_zhanshuyantao_talk3"),25)
    talkBtn3:setAnchorPoint(ccp(0.5,0.5))
    local talkBtn3Menu=CCMenu:createWithItem(talkBtn3)
    talkBtn3Menu:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.25,self.touchDialogBg:getContentSize().height-70))
    talkBtn3Menu:setTouchPriority(-(self.layerNum-1)*20-6)
    self.touchDialogBg:addChild(talkBtn3Menu,1)  

    local talkBtn4 =GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge.png",btnClick,34,getlocal("activity_zhanshuyantao_talk4"),25);
    talkBtn4:setAnchorPoint(ccp(0.5,0.5))
    talkBtn4:setTag(34)
    local talkBtn4Menu=CCMenu:createWithItem(talkBtn4)
    talkBtn4Menu:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.75,self.touchDialogBg:getContentSize().height-70))
    talkBtn4Menu:setTouchPriority(-(self.layerNum-1)*20-6)
    talkBtn4Menu:setTag(34)
    self.touchDialogBg:addChild(talkBtn4Menu,1) 
    
    self.gemIcon3 = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon3:setAnchorPoint(ccp(1,0.5))
	self.gemIcon3:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.7-25,self.touchDialogBg:getContentSize().height-20))
	self.touchDialogBg:addChild(self.gemIcon3,1)

    local currRestartTime,currRestartTimeNext = acTacticalDiscussVoApi:getCurrRestartTime()
    local upRestartTime = acTacticalDiscussVoApi:getUpTimes()
    local reStartGoldCostTb = acTacticalDiscussVoApi:getReStartGoldCostTb()
    local currChangeNeedGold = nil
    if currRestartTime==nil or currRestartTime <=0 then
    	currChangeNeedGold =reStartGoldCostTb[1]
    elseif  currRestartTimeNext <SizeOfTable(reStartGoldCostTb)+1 then
    	currChangeNeedGold = reStartGoldCostTb[currRestartTimeNext]
    elseif currRestartTimeNext >SizeOfTable(reStartGoldCostTb) then
    	local highTime = SizeOfTable(reStartGoldCostTb)
    	currChangeNeedGold =reStartGoldCostTb[highTime]
    end

    self.currCostGold = GetTTFLabel(currChangeNeedGold,24)
	self.currCostGold:setAnchorPoint(ccp(0,0.5))
	self.currCostGold:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.7-22,self.touchDialogBg:getContentSize().height-20))
	self.touchDialogBg:addChild(self.currCostGold,1)

	self.currCostedTime = GetTTFLabel(getlocal("super_weapon_challenge_troops_schedule",{currRestartTime,upRestartTime}),24)
	self.currCostedTime:setAnchorPoint(ccp(0,0.5))
	self.currCostedTime:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.75,self.touchDialogBg:getContentSize().height-20))
	self.touchDialogBg:addChild(self.currCostedTime,1)


    if tonumber(currRestartTimeNext) > tonumber(upRestartTime) then
		talkBtn4:setEnabled(false)
		self.gemIcon3:setVisible(false)
		self.currCostGold:setVisible(false)
	end
end

function acTacticalDiscussDialog:btnClick(tag,costGold)
	local strSize6 = 22
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		strSize6 =26
	end
  local awardTb = acTacticalDiscussVoApi:getLastAwardTb()
  -- print("here???????",tag)
  self.reSetIdx = 0
    for k=1,6 do----需要其他信息 确定翻盘数量
        local cardSp1=self.cardSpTb[k] --tolua.cast(self.bgLayer:getChildByTag(100+k),"LuaCCSprite")
        local cardSp2 = self.cardSpAwardTb[k]

        if cardSp1 then
        	-- print("in cardSp1~~~~~~")
        	self.reSetIdx = self.reSetIdx+1
        	print("in cardSp1~~~~~~",reSetIdx)
            local function onFlipHandler()
                if cardSp1 then
                    cardSp1:removeFromParentAndCleanup(true)
                    self.cardSpTb[k]=nil
                end

                    local cardSp2=nil 
                    if self.cardSpAwardTb[k] ==nil then
                        cardSp2 = CCSprite:createWithSpriteFrameName("rewardCard2.png")
                        self.cardSpAwardTb[k]=cardSp2
                    else
                    	cardSp2 =self.cardSpAwardTb[k]
                    end
                    local card2Xx,card2yy = self.cardPosSizeTb[k]["x"],self.cardPosSizeTb[k]["y"]
                    cardSp2:setPosition(ccp(card2Xx,card2yy))
                    cardSp2:setScale(self.needcardScale1)
		            cardSp2:setScaleX(self.needcardScale2)
                    self.downBg:addChild(cardSp2,2)
                    cardSp2:setFlipX(true)
                    

                    local icon,name,num,nameLb
                    if awardTb[k] =="sp" then
                    	icon =CCSprite:createWithSpriteFrameName("serverWarTopMedal1.png")
                    	icon:setPosition(ccp(cardSp2:getContentSize().width/2,100))
                        cardSp2:addChild(icon,2)
                        icon:setScaleY(self.needIphone5IconScaleY)
                        icon:setScaleX(self.needIphone5IconScaleX)
                        icon:setFlipX(true)

                        G_addRectFlicker(cardSp2,2,2.4)
                    else
                    	local idx = tonumber(RemoveFirstChar(awardTb[k]))
                    	nameLb=GetTTFLabelWrap(getlocal("activity_zhanshuyantao_ljAward"..idx),strSize6,CCSizeMake(cardSp2:getContentSize().width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    	nameLb:setAnchorPoint(ccp(0.5,0.5))
                    	nameLb:setPosition(ccp(cardSp2:getContentSize().width/2,100))
                        cardSp2:addChild(nameLb,2)
                        nameLb:setFlipX(true)
                    end

                    local function onFlipHandler2()
                    	self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+5000))
                        -- print("self.lastIdx--- 6-self.lastIdx----reSetIdx->",self.lastIdx,6-self.lastIdx,self.reSetIdx)
                        if k ==6 or self.reSetIdx == 6-self.lastIdx then
                        	self:stopAction(tag,k)
                        end
                    end
                    local callFunc=CCCallFunc:create(onFlipHandler2)
                    local orbitCamera=CCOrbitCamera:create(0.5,1,0,90,90,0,0)
                    -- self.cardSpAwardRotTb[k] =90
                    local acArr=CCArray:create()
                    acArr:addObject(orbitCamera)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    cardSp2:runAction(seq)
                -- end
            end
            if cardSp1  then
            	-- print("in cardSp1~~~~~")
                local callFunc=CCCallFunc:create(onFlipHandler)
                local delay=CCDelayTime:create(2)
                --旋转的时间，起始半径，半径差，起始z角，旋转z角差，起始x角，旋转x角差
                local angleDiff=12
                local angleDiffZ=90
                if k==1 then
                    angleDiffZ=angleDiffZ-angleDiff
                elseif k==2 then
                elseif k==3 then
                    angleDiffZ=angleDiffZ+angleDiff
                end
                local orbitCamera=CCOrbitCamera:create(0.5,1,0,0,angleDiffZ,0,0)
                local acArr=CCArray:create()
                acArr:addObject(orbitCamera)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                cardSp1:runAction(seq)
            end
        elseif cardSp2 and tag > 32 then
        	local function onFlipHandler21()
                if cardSp2 then
                    cardSp2:removeFromParentAndCleanup(true)
                    self.cardSpAwardTb[k]=nil
                end
                	local cardSp1 =nil
                	if self.cardSpTb[k] ==nil then
                        cardSp1=CCSprite:createWithSpriteFrameName("rewardCard1.png")
                        self.cardSpTb[k] = cardSp1
                    else
                    	cardSp1 = self.cardSpTb[k]
                    end
                    local card2Xx,card2yy = self.cardPosSizeTb[k]["x"],self.cardPosSizeTb[k]["y"]
                    cardSp1:setPosition(ccp(card2Xx,card2yy))
                    cardSp1:setScale(self.needcardScale1)
		            cardSp1:setScaleX(self.needcardScale2)
                    self.downBg:addChild(cardSp1,2)		                            


                    local function onFlipHandler222()
                    	if tag ==34 then
                    		self:btnClick(tag,costGold)
                    		-- self:stopAction(tag)
                    	elseif tag ==33 then
                        	self:stopAction(tag,k)
                        	-- self.tv2:reloadData()
                    	else
                    		self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+5000))
                    	end
                    end
                    local callFunc=CCCallFunc:create(onFlipHandler222)
                    local angleDiff=12
                    local angleDiffZ=90
                    if k==1 then
                        angleDiffZ=angleDiffZ-angleDiff
                    elseif k==2 then
                    elseif k==3 then
                        angleDiffZ=angleDiffZ+angleDiff
                    end
                    local orbitCamera2=CCOrbitCamera:create(0.5,1,0,0,angleDiffZ,0,0)
                    
                    local orbitCameraReverse2 = orbitCamera2:reverse()
                    local acArr=CCArray:create()
                    acArr:addObject(orbitCameraReverse2)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    cardSp1:runAction(seq)
                -- end
            end
            if cardSp2 and (self.lastAwardTb[k] ~="sp" or tag ==33 )then
            	-- print("in cardSp2~~~~~")
                local callFunc=CCCallFunc:create(onFlipHandler21)
                local delay=CCDelayTime:create(2)
                --旋转的时间，起始半径，半径差，起始z角，旋转z角差，起始x角，旋转x角差
                local orbitCamera2=CCOrbitCamera:create(0.5,1,0,90,90,0,0)
                local orbitCameraReverse2 = orbitCamera2:reverse()
                local acArr=CCArray:create()
                acArr:addObject(orbitCameraReverse2)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                cardSp2:runAction(seq)
            end
        end
        	            
    end
    self.lastAwardTb = awardTb
end

function acTacticalDiscussDialog:eventHandler2(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1

   elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth*0.9,G_VisibleSizeWidth*0.18)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()

       local function touch( )
			print("22222")
		end 
		self.awardShowCell=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)--拉霸动画背景
		self.awardShowCell:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.95-15,G_VisibleSizeWidth*0.18))
		self.awardShowCell:setOpacity(200)
		self.awardShowCell:setAnchorPoint(ccp(0,0))
		self.awardShowCell:setPosition(ccp(0,0))
		cell:addChild(self.awardShowCell,3)
		self:awardShowCellF(self.awardShowCell)
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end
function acTacticalDiscussDialog:awardShowCellF( showCellBg)
	local needAward = acTacticalDiscussVoApi:formatNeedReward(self.layerNum)
	if self.showedAwardTb and SizeOfTable(self.showedAwardTb)>0 then
		-- print("SizeOfTable--->self.showedAwardTb---->",SizeOfTable(self.showedAwardTb))
		for k,v in pairs(self.showedAwardTb) do
			local awardPic = G_getItemIcon(v,65,true,self.layerNum)
			awardPic:setTouchPriority(-(self.layerNum-1)*20-6)
	        awardPic:setPosition(ccp(-10+ (G_VisibleSizeWidth -20)/5*k,showCellBg:getContentSize().height*0.5))
	        showCellBg:addChild(awardPic,1)
			awardPic:setScale(0.8)
	        local iconNum = v.num
	        local iconLabel = GetTTFLabel("x"..iconNum,25)
            iconLabel:setAnchorPoint(ccp(1,0))
            iconLabel:setPosition(ccp(awardPic:getContentSize().width-4,4))
            awardPic:addChild(iconLabel,1)
		end
	else
		
		for k,v in pairs(needAward[7]) do
			local awardPic = G_getItemIcon(v,65,true,self.layerNum)
			awardPic:setTouchPriority(-(self.layerNum-1)*20-6)
								----需要调整 30 + (G_VisibleSizeWidth - 60)/(total+1)*i
	        awardPic:setPosition(ccp(-10+ (G_VisibleSizeWidth -20)/(SizeOfTable(needAward[7])+1)*k,showCellBg:getContentSize().height*0.5))
	        showCellBg:addChild(awardPic,1)
			awardPic:setScale(0.8)
	        local iconNum = v.num
	        local iconLabel = GetTTFLabel("x"..iconNum,25)
            iconLabel:setAnchorPoint(ccp(1,0))
            iconLabel:setPosition(ccp(awardPic:getContentSize().width-4,4))
            awardPic:addChild(iconLabel,1)
		end
	end

end
function acTacticalDiscussDialog:stopAction( tag,idx )
			local currAward = acTacticalDiscussVoApi:getLastAwardTb()
			local currIdx = 0
			if currAward and SizeOfTable(currAward)>0 then
				for k,v in pairs(currAward) do
						if v =="sp" then
							currIdx= currIdx+1
						end
				end
				if currIdx ==0 then
					currIdx =1
				end
			end
	 local needReward=nil
	 local awardTb = nil
    if tag ==33 then
		-- print("stop --->tag",tag)
		awardTb = currAward
		local Awardidx = 0
		for k,v in pairs(awardTb) do
			if v =="sp" then
				Awardidx= Awardidx+1
			end
		end
		G_showRewardTip(self.showedAwardTb,true)
		local strs = nil
		if tag ==33 and Awardidx+1 >6 then
			strs = G_showRewardTip(self.showedAwardTb,false,true)
			local paramTab={}
			paramTab.functionStr="zhanshuyantao"
			paramTab.addStr="i_also_want"
			local message={key="chatSystemMessage13",param={playerVoApi:getPlayerName(),getlocal("activity_zhanshuyantao_title"),strs,""}}
			chatVoApi:sendSystemMessage(message,paramTab)
		end
		acTacticalDiscussVoApi:setCurrRestartTime(0)
		self.lastAwardTb ={}
		local upRestartTime = acTacticalDiscussVoApi:getUpTimes()
		local reStartGoldCostTb = acTacticalDiscussVoApi:getReStartGoldCostTb()
	    local currChangeNeedGold = reStartGoldCostTb[1]
		self.currCostGold:setString(currChangeNeedGold)
		self.currCostedTime:setString(getlocal("super_weapon_challenge_troops_schedule",{0,upRestartTime}))
		acTacticalDiscussVoApi:setCurrBigAwardIdx(0)
		self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr1"))
		self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+5000))
		local menu = tolua.cast(self.touchDialogBg:getChildByTag(34),"CCMenu")
		menu:setEnabled(true)
		acTacticalDiscussVoApi:setLastAward()
		self.showedAwardTb={}
		local menu = tolua.cast(self.touchDialogBg:getChildByTag(34),"CCMenu")
		local btn = tolua.cast(menu:getChildByTag(34),"CCMenuItemSprite")
		btn:setEnabled(true)
		self.gemIcon3:setVisible(true)
		self.currCostGold:setVisible(true)
		self.str1:setString(getlocal("activity_zhanshuyantao_awardShowTitle"))
		self.lastIdx =0

		self.tv2:reloadData()
	elseif 6-self.lastIdx == self.reSetIdx and currAward and SizeOfTable(currAward) then
		
		awardTb = currAward--acTacticalDiscussVoApi:getLastAwardTb()
		local Awardidx = 0
		for k,v in pairs(awardTb) do
			if v =="sp" then
				Awardidx= Awardidx+1
			end
		end
		
		acTacticalDiscussVoApi:setCurrBigAwardIdx(Awardidx)
		local bigAwardIdx = acTacticalDiscussVoApi:getCurrBigAwardIdx()
		-- print("here???????????self.lastIdx >= Awardidx----",self.lastIdx ,Awardidx)
		if self.lastIdx >= Awardidx then
			local randomIdx = math.random(3)
			self.girSaid:setString(getlocal("activity_zhanshuyantao_currAwardShowSame_"..randomIdx))
		else
			self.lastIdx =Awardidx

			if bigAwardIdx ==4 then
		    	self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr3"))
		    elseif bigAwardIdx ==5 then
		    	self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr4"))
		    elseif bigAwardIdx ==6 then
		    	self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr5"))
		    else 
		    	self.girSaid:setString(getlocal("activity_zhanshuyantao_girlStr2"))
		    end
		end
	    
		needReward = acTacticalDiscussVoApi:formatNeedReward(self.layerNum)
		self.showedAwardTb=needReward[Awardidx+1]

		self.str1:setString(getlocal("activity_zhanshuyantao_currAwardShowTitle"))
		self.tv2:reloadData()
	end
end

function acTacticalDiscussDialog:needMoneyDia(cost,playerGems,wholeTouchBgSp)
	local function buyGems()
      if G_checkClickEnable()==false then
          do
              return
          end
      end

	  activityAndNoteDialog:closeAllDialog()
      vipVoApi:showRechargeDialog(self.layerNum+1)
  	end
  	local function cancleCallBack( )
  		if wholeTouchBgSp then
  			wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+5000))
  		end
  	end 
	local num=tonumber(cost)-playerGems
	local smallD=smallDialog:new()
	smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(cost),playerGems,num}),nil,self.layerNum+1,nil,nil,cancleCallBack)
end

function acTacticalDiscussDialog:refresh( )
	local vo=acTacticalDiscussVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
		if acTacticalDiscussVoApi:getFreeTime() ==false then
			-- self.freeBtnMenu:setVisible(true)
			acTacticalDiscussVoApi:setFreeTime()
			self.freeBtn:setVisible(true)
			self.talkBtn1:setVisible(false)
			self.goldStr1:setVisible(false)
			self.gemIcon1:setVisible(false)
		else
			-- self.freeBtnMenu:setVisible(false)
			self.freeBtn:setVisible(false)
			self.talkBtn1:setVisible(true)
			self.goldStr1:setVisible(true)
			self.gemIcon1:setVisible(true)
		end
end

function acTacticalDiscussDialog:tick()
	local istoday = acTacticalDiscussVoApi:isToday()
	if istoday ~= self.isToday then
	    self.isToday = istoday
	    print("acTacticalDiscussVoApi:getFreeTime()==true and istoday == false then----->",acTacticalDiscussVoApi:getFreeTime(),istoday)
	    if acTacticalDiscussVoApi:getFreeTime()==true and istoday == false then
	    	acTacticalDiscussVoApi:setFreeTime()
	    	self:refresh()
	    end
	end
	self:updateAcTime()
end

function acTacticalDiscussDialog:updateAcTime()
	local acVo=acTacticalDiscussVoApi:getAcVo()
	if acVo and self.timeLb then
		G_updateActiveTime(acVo,self.timeLb)
	end
end






