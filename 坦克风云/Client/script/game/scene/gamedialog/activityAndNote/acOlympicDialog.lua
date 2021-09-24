acOlympicDialog=commonDialog:new()

function acOlympicDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.5-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end
function acOlympicDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/acNewYearsEva.plist")
   	spriteController:addTexture("public/acNewYearsEva.png")
   	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self.isTouch=nil
	self.isToday=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.freeBtn =nil
	self.freeBtnMenu=nil
	self.talkBtn1=nil
	self.talkBtn1Menu=nil
	self.talkBtn2=nil
	self.talkBtn2Menu=nil
	self.oneCostStr =nil
	self.gemIcon1 =nil
	self.tenCostStr=nil
	self.gemIcon2 =nil
	self.wholeTouchBgSp=nil
	self.tipIcon=nil
	self.bigRingsTb={}
	self.smallRingsTb={}
	self.showSmallRingsTb = {}
	self.allColors = {ccc3(0,126,202),ccc3(53,53,53),ccc3(255,18,31),ccc3(254,175,56),ccc3(0,167,82),ccc3(117,57,147)}
	self.colorNum = 1
	self.firstChangeColorRateLimit = 50
	self.colorRate = 0
	self.state =nil
	self.curReport ={}
	self.beginDelyTime =0
	self.stopOrder = {1,4,2,5,3}
	self.hadStopTb = {}
	self.bigRingsPosTb = {}
	self.smallRingsPosTb = {}
	self.isParticle = 0
	self.needContentSize =nil
	self.particleS = {}
	self.smallParticleS={}
	self.clickUseUp = 0
	self.curScoreLbTb = {}
	self.acOlympicRecordDialog = nil
	self.acOlympicGetRewardDialog = nil
	self.acOlympicAwardRuleDialog =nil
	return nc
end

function acOlympicDialog:dispose( )
	self.curScoreLbTb =nil
	self.smallParticleS=nil
	self.particleS = nil
	self.isTouch=nil
	self.isToday=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.freeBtn =nil
	self.freeBtnMenu=nil
	self.talkBtn1=nil
	self.talkBtn1Menu=nil
	self.talkBtn2=nil
	self.talkBtn2Menu=nil
	self.oneCostStr =nil
	self.gemIcon1 =nil
	self.tenCostStr=nil
	self.gemIcon2 =nil
	self.wholeTouchBgSp=nil
	self.tipIcon=nil
	self.bigRingsTb=nil
	self.smallRingsTb=nil
	self.allColors = nil
	self.curReport =nil
	self.beginDelyTime =nil
	self.stopOrder = nil
	self.hadStopTb = nil
	if self.acOlympicGetRewardDialog then
		self.acOlympicGetRewardDialog:close()
		self.acOlympicGetRewardDialog = nil
	end
	if self.acOlympicRecordDialog then
		self.acOlympicRecordDialog:close()
		self.acOlympicRecordDialog = nil
	end
	if self.acOlympicAwardRuleDialog then
		self.acOlympicAwardRuleDialog:close()
		self.acOlympicAwardRuleDialog = nil
	end
	spriteController:removePlist("public/acNewYearsEva.plist")
  	spriteController:removeTexture("public/acNewYearsEva.png")
end

function acOlympicDialog:doUserHandler()
	self.activeName=acOlympicVoApi:getActiveName()
	self.isToday = acOlympicVoApi:isToday()
	-- print("self.isToday---->",self.isToday)
	local needBgAddHeight =150
	local needAddPosH = 0
	if G_isIphone5() then
	    needBgAddHeight =300
	    needAddPosH =25
	end

	local strSize3 = 23
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		strSize3 =25
	end

	local function touch2( ) 
		-- print("wholeTouchBgSp~~~~~~~~") 
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        self.state = 2
		self:clickFinishAnimation( )---------！！！！！！！！！！！！！！！
	end 
	self.wholeTouchBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch2)--拉霸动画背景
	self.wholeTouchBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth+40,G_VisibleSizeHeight+needBgAddHeight))
	self.wholeTouchBgSp:setTouchPriority(-(self.layerNum-1)*20-20)
	self.wholeTouchBgSp:setIsSallow(true)
	self.wholeTouchBgSp:setAnchorPoint(ccp(0.5,0))
	self.wholeTouchBgSp:setOpacity(0)
	self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5500))
	self.bgLayer:addChild(self.wholeTouchBgSp,30)
	self.wholeTouchBgSp:setVisible(false)

	local function bgClick() end
	local w = G_VisibleSizeWidth - 22 -- 背景框的宽度
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
	backSprie:setContentSize(CCSizeMake(w, 160))
	backSprie:setAnchorPoint(ccp(0.5,1))
	backSprie:setPosition(ccp(G_VisibleSizeWidth*0.5, G_VisibleSizeHeight - 87))
	self.bgLayer:addChild(backSprie)

	local downBg =CCSprite:create("public/superWeapon/weaponBg.jpg")
    downBg:setScaleX(backSprie:getContentSize().width/downBg:getContentSize().width)
    downBg:setScaleY((G_VisibleSizeHeight-backSprie:getContentSize().height-105)/downBg:getContentSize().height)
    downBg:setColor(ccc3(12,91,132))
    -- downBg:ignoreAnchorPointForPosition(false)
    downBg:setOpacity(250)
    downBg:setAnchorPoint(ccp(0.5,1))
    downBg:setPosition(ccp(G_VisibleSizeWidth*0.5,backSprie:getPositionY()-backSprie:getContentSize().height))
    self.bgLayer:addChild(downBg)

    local addBg = CCSprite:createWithSpriteFrameName("whiteBg.png")
    addBg:setAnchorPoint(ccp(0.5,1))
    addBg:setOpacity(30)
    addBg:setPosition(ccp(downBg:getContentSize().width*0.5,downBg:getContentSize().height))
    addBg:setScaleX((downBg:getContentSize().width-20)/addBg:getContentSize().width)
	addBg:setScaleY(downBg:getContentSize().height/addBg:getContentSize().height)
	downBg:addChild(addBg)

   	local upBoderSp = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
	upBoderSp:setAnchorPoint(ccp(0.5,1))
	upBoderSp:setPosition(ccp(G_VisibleSizeWidth*0.5,backSprie:getPositionY()-backSprie:getContentSize().height))
	self.bgLayer:addChild(upBoderSp)

    local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeInfor:setScale(2)
	spriteShapeInfor:setOpacity(200)
    spriteShapeInfor:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeInfor:setPosition(ccp(G_VisibleSizeWidth*0.6,G_VisibleSizeHeight*0.38))
    self.bgLayer:addChild(spriteShapeInfor)

    local pointTb = acOlympicVoApi:getPointTb( )
	  local function touch(tag,object)
	    PlayEffect(audioCfg.mouseClick)
	    local tabStr={};
	    local tabColor ={nil,nil,nil,nil,nil,nil,nil,nil};
	    local td=smallDialog:new()--a
	    -- local scoreTb = acOlympicVoApi:getScoreTb( )
	    local socreLimit = acOlympicVoApi:getScoreLimit( )
	    -- local topScore = scoreTb[#scoreTb]
	    tabStr = {"\n",getlocal("activity_olympic_tip_4"),"\n",getlocal("activity_olympic_tip_3",{socreLimit}),"\n",getlocal("activity_olympic_tip_2",{pointTb[1],pointTb[2],pointTb[3]}),"\n",getlocal("activity_olympic_tip_1"),"\n"}
	    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
	    sceneGame:addChild(dialog,self.layerNum+1)
	  end

	  w = w - 10 -- 按钮的x坐标
	  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
	  menuItemDesc:setAnchorPoint(ccp(1,1))
	  menuItemDesc:setScale(0.8)
	  local menuDesc=CCMenu:createWithItem(menuItemDesc)
	  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	  menuDesc:setPosition(ccp(w-10, backSprie:getContentSize().height-10))
	  backSprie:addChild(menuDesc)
	  
	  w = w - menuItemDesc:getContentSize().width

	  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
	  acLabel:setAnchorPoint(ccp(0.5,1))
	  acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)*0.5, backSprie:getContentSize().height-10))
	  backSprie:addChild(acLabel)
	  acLabel:setColor(G_ColorYellowPro)

	  local acVo = acOlympicVoApi:getAcVo()
	  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	  local messageLabel=GetTTFLabel(timeStr,25)
	  messageLabel:setAnchorPoint(ccp(0.5,1))
	  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)*0.5, backSprie:getContentSize().height-40))
	  backSprie:addChild(messageLabel)

	  local topLabel = getlocal("activity_olympic_lb_1")
	  local desTv, desLabel = G_LabelTableView(CCSizeMake(G_VisibleSizeWidth - 30, 70),topLabel,25,kCCTextAlignmentLeft)
	  backSprie:addChild(desTv)
	  desTv:setPosition(ccp(10,10))
	  desTv:setAnchorPoint(ccp(0,0))
	  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	  desTv:setMaxDisToBottomOrTop(100)

	  local oneCost,tenCost = acOlympicVoApi:getCostWithOneAndTenTimes( )
	  -- local haveCost = playerVoApi:getGems()
	  if oneCost ==nil then------------假数据！！！！！！！！
	  	oneCost =50
	  	tenCost =450
	  end
	  local function btnClick( tag,object)
	  	if G_checkClickEnable()==false  then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
		self:socBuy(tag)
	  end 
--------
	self.freeBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnClick,31,getlocal("daily_lotto_tip_2"),25)
    self.freeBtn:setAnchorPoint(ccp(0.5,0.5))
    self.freeBtnMenu=CCMenu:createWithItem(self.freeBtn)
    self.freeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width*0.25,self.freeBtn:getContentSize().height*0.5+25+needAddPosH))
    self.freeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.freeBtnMenu,2)  
--------
    self.talkBtn1 =GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnClick,32,getlocal("activity_olympic_btnLb_1"),25)
    self.talkBtn1:setAnchorPoint(ccp(0.5,0.5))
    self.talkBtn1Menu=CCMenu:createWithItem(self.talkBtn1)
    self.talkBtn1Menu:setPosition(ccp(self.bgLayer:getContentSize().width*0.25,self.talkBtn1:getContentSize().height*0.5+25+needAddPosH))
    self.talkBtn1Menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.talkBtn1Menu)  

    self.oneCostStr = GetTTFLabel(oneCost,25)
    self.oneCostStr:setAnchorPoint(ccp(1,0))
    self.talkBtn1:addChild(self.oneCostStr)
    self.oneCostStr:setColor(G_ColorYellowPro)

    self.gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon1:setAnchorPoint(ccp(0,0))
	self.talkBtn1:addChild(self.gemIcon1,1)

    self.talkBtn2 =GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnClick,33,getlocal("activity_olympic_btnLb_2"),strSize3);
    self.talkBtn2:setAnchorPoint(ccp(0.5,0.5))
    self.talkBtn2Menu=CCMenu:createWithItem(self.talkBtn2)
    self.talkBtn2Menu:setPosition(ccp(self.bgLayer:getContentSize().width*0.75,self.talkBtn2:getContentSize().height*0.5+25+needAddPosH))
    self.talkBtn2Menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.talkBtn2Menu)

    self.tenCostStr = GetTTFLabel(tenCost,25)
    self.tenCostStr:setAnchorPoint(ccp(1,0))
    self.talkBtn2:addChild(self.tenCostStr)
    self.tenCostStr:setColor(G_ColorYellowPro)

    self.gemIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon2:setAnchorPoint(ccp(0,0))
	self.talkBtn2:addChild(self.gemIcon2,1)

    self:refreshVisible2()

    local addWidth = 25
    local olyLogoPic = CCSprite:createWithSpriteFrameName("olympicPic.png")
    olyLogoPic:setAnchorPoint(ccp(0,1))
    olyLogoPic:setPosition(ccp(addWidth,backSprie:getPositionY()-backSprie:getContentSize().height-30))
    self.bgLayer:addChild(olyLogoPic)

    local smallRingSpLeftPosBeginX = olyLogoPic:getPositionX()
	local smallRingSpLeftPosBeginY = olyLogoPic:getPositionY()-olyLogoPic:getContentSize().height-10
	self.smallScaleNum = 0.3
	for i=1,5 do
		local ringSp = CCSprite:createWithSpriteFrameName("ring_"..i..".png")
		ringSp:setAnchorPoint(ccp(0,1))
		
		ringSp:setScale(self.smallScaleNum)
		ringSp:setColor(self.allColors[i])
		local aHeight = math.floor((i-1)/3)
		local awidth = i%3
		local ringWidth = ringSp:getContentSize().width*self.smallScaleNum
		local ringHeight = (ringSp:getContentSize().height-20)*self.smallScaleNum
		local needWidth = 0
		if awidth==0 then
			awidth=3
		end
		if i > 3 then
			needWidth =  ringWidth*0.5
		end
		self.smallRingsPosTb[i] = ccp(smallRingSpLeftPosBeginX+ringWidth*(awidth-1)+needWidth,smallRingSpLeftPosBeginY-ringHeight*aHeight)
		ringSp:setPosition(self.smallRingsPosTb[i])
		self.bgLayer:addChild(ringSp,2)
		table.insert(self.smallRingsTb,ringSp)
	end

    local middWidth = backSprie:getContentSize().width- olyLogoPic:getContentSize().width-50
    local middHeight = olyLogoPic:getContentSize().height
    local function noData( ) end
    local middleBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
    middleBg:setAnchorPoint(ccp(1,1))
    middleBg:setContentSize(CCSizeMake(middWidth,middHeight))
    middleBg:setPosition(ccp(backSprie:getContentSize().width,backSprie:getPositionY()-backSprie:getContentSize().height-50))
    self.bgLayer:addChild(middleBg)
    middleBg:setOpacity(0)

    local middLb = getlocal("activity_olympic_lb_2")
	local desTv2, desLabel2 = G_LabelTableView(CCSizeMake(middWidth - 10, middHeight),middLb,22,kCCTextAlignmentLeft)
	middleBg:addChild(desTv2)
	desTv2:setPosition(ccp(0,0))
	desTv2:setAnchorPoint(ccp(0,0))
	desTv2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv2:setMaxDisToBottomOrTop(100)

	local ringSubPosH = 80
	if G_isIphone5() then
		ringSubPosH = 140
	end
	local fiveRingsBg = CCSprite:createWithSpriteFrameName("fiveRingsBg.png")
	fiveRingsBg:setAnchorPoint(ccp(0,1))
	fiveRingsBg:setPosition(ccp(middleBg:getPositionX()-middleBg:getContentSize().width-40,middleBg:getPositionY()-middleBg:getContentSize().height-ringSubPosH))
	self.bgLayer:addChild(fiveRingsBg)

	local ringSpLeftPosBeginX = fiveRingsBg:getPositionX()+30
	local ringSpLeftPosBeginY = fiveRingsBg:getPositionY()+30
	for i=1,5 do
		local ringSp = CCSprite:createWithSpriteFrameName("ring_"..i..".png")
		ringSp:setAnchorPoint(ccp(0,1))
		ringSp:setColor(self.allColors[i])
		local aHeight = math.floor((i-1)/3)
		local awidth = i%3
		local ringWidth = ringSp:getContentSize().width
		local ringHeight = ringSp:getContentSize().height-20
		local needWidth = 0
		if awidth==0 then
			awidth=3
		end
		if i > 3 then
			needWidth =  ringWidth*0.5
		end
		if self.needContentSize ==nil then
			self.needContentSize = CCSizeMake(ringSp:getContentSize().width,ringSp:getContentSize().height)
		end
		self.bigRingsPosTb[i] = ccp(ringSpLeftPosBeginX+ringWidth*(awidth-1)+needWidth,ringSpLeftPosBeginY-ringHeight*aHeight)
		ringSp:setPosition(self.bigRingsPosTb[i])
		self.bgLayer:addChild(ringSp,2)
		table.insert(self.bigRingsTb,ringSp)
	end

	local strSize2 = 26
   	if G_getCurChoseLanguage() =="ru" then
   		strSize2 =22
    elseif G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
    	strSize2 =30
    end

	local function showRewardsInfo(tag,object)------获奖记录
		print("in showRewardsInfo----->tag",tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if tag == 11 then
        	self.acOlympicAwardRuleDialog=acOlympicAwardRuleDialog:new(self.layerNum + 1)
		  	local dialog= self.acOlympicAwardRuleDialog:init(nil)
        elseif tag == 12 then
	        local function callback(fn,data)
	        	local ret,sData = base:checkServerData(data)
		        if ret==true then
		        	acOlympicVoApi:setIsSeeRecord(true)
		        	self:refreshVisibleWithRecord()
		        	if sData and sData.data then
		        		local data  = sData.data
		        		if data.log then
		        			acOlympicVoApi:setAwardAllTbRecord( data.log )
		        		end
		        		self:openRecordDia()
		        	end
		        end
	        end 
	        socketHelper:acOlympicSoc(4,self.activeName,callback)
	    end
    end

    local awardRuleItem = GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",showRewardsInfo,11,nil,nil)
    awardRuleItem:setScale(0.8)
    local awardRuleBtn = CCMenu:createWithItem(awardRuleItem)
    awardRuleItem:setAnchorPoint(ccp(0.5,0))
    local ruleLb = GetTTFLabelWrap(getlocal("awardRuleLb"),strSize2,CCSizeMake(awardRuleItem:getContentSize().width*2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    ruleLb:setPosition(ccp(awardRuleItem:getContentSize().width*0.5,-5))
    awardRuleItem:addChild(ruleLb)
    ruleLb:setAnchorPoint(ccp(0.5,1))

    

    local rewardInfoItem = GetButtonItem("bless_record.png","bless_record.png","bless_record.png",showRewardsInfo,12,getlocal("serverwar_point_record"),strSize2,12)--serverwar_point_record
    rewardInfoItem:setScale(0.8)
    local rewardInfoBtn = CCMenu:createWithItem(rewardInfoItem)
    rewardInfoItem:setRotation(10)
    rewardInfoItem:setAnchorPoint(ccp(0.5,0))
    local recordLb =tolua.cast(rewardInfoItem:getChildByTag(12),"CCLabelTTF")
    recordLb:setPosition(ccp(rewardInfoItem:getContentSize().width*0.5,-10))
    recordLb:setRotation(-10)
    recordLb:setAnchorPoint(ccp(0.5,1))

    local bookNeedPosH = 110
    local bookNeedPosH2 = 240
    if G_isIphone5() ==true then
    	bookNeedPosH =140
    	bookNeedPosH2 =280
    end
    rewardInfoBtn:setPosition(ccp(olyLogoPic:getContentSize().width*0.5+addWidth,self.talkBtn2:getContentSize().height+bookNeedPosH))
    rewardInfoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rewardInfoBtn)

    awardRuleBtn:setPosition(ccp(olyLogoPic:getContentSize().width*0.5+addWidth,self.talkBtn2:getContentSize().height+bookNeedPosH2))
    awardRuleBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(awardRuleBtn)

    self.tipIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
    self.tipIcon:setAnchorPoint(ccp(0.5,0.5))
    self.tipIcon:setPosition(ccp(rewardInfoItem:getContentSize().width-20,rewardInfoItem:getContentSize().height-15))
    rewardInfoItem:addChild(self.tipIcon,10)

    self:refreshVisibleWithRecord()

end

function acOlympicDialog:fastTick( )
	
	if self.state ==nil then
		self:xiaBiBianSe()
	elseif self.state ==1 then
		self:showResult()
	elseif self.state ==2 and self.clickUseUp >100 then
		self.state =3
		self:getAllAwardToShowWithDialog()
	end

	if self.state ==2 and self.clickUseUp then
		self.clickUseUp = self.clickUseUp +1
	end
end

function acOlympicDialog:showResult( )
	local addRate = 1
	local isCurSHow	 = 1
	for i=1,5 do
		local stopOrderNum = self.stopOrder[i]
		if self.hadStopTb[stopOrderNum] and i+1 < 6 then
			isCurSHow = self.stopOrder[i]
			break
		end
	end

	if self.colorRate < self.firstChangeColorRateLimit then
		self.colorRate = self.colorRate +4
	else
		if self.bigRingsTb and #self.bigRingsTb >4 then
			for i=1,5 do
				if self.colorNum +1 <7 then
					self.colorNum = self.colorNum +1
				else
					self.colorNum = 1
				end
				local stopOrderNum = self.stopOrder[i]
				if self.beginDelyTime < 60+(i-1)*self.firstChangeColorRateLimit and (isCurSHow ~= stopOrderNum or self.isChange ==true)  then
					self.isChange =false
					self.bigRingsTb[stopOrderNum]:setColor(self.allColors[self.colorNum])
				end
				
				if self.beginDelyTime > 60+(i-1)*self.firstChangeColorRateLimit then
					local curColorNum = self.curReport[stopOrderNum]
					self.hadStopTb[stopOrderNum] = 1
					local isColor = 0
					if curColorNum == stopOrderNum then
						isColor =1
					elseif curColorNum <6 then
						isColor =2
					end
					self.bigRingsTb[stopOrderNum]:setColor(self.allColors[curColorNum])
					if self.particleS[stopOrderNum] ==nil then
						self:playParticles(stopOrderNum,isColor,curColorNum)
					end
					if i == 5 and self.beginDelyTime > 40+i*self.firstChangeColorRateLimit then
						self.state = 3 
						self:getAllAwardToShowWithDialog()
					end
				end
				self.beginDelyTime = self.beginDelyTime +1
			end
			self.isChange =true
		end
		self.colorRate = 1
		
	end
end
function acOlympicDialog:clickFinishAnimation( )
	for i=1,5 do
		local stopOrderNum = self.stopOrder[i]
		local curColorNum = self.curReport[stopOrderNum]
		self.bigRingsTb[stopOrderNum]:setColor(self.allColors[curColorNum])
		local isColor = 0
		if curColorNum == stopOrderNum then
			isColor =1
		elseif curColorNum <6 then
			isColor =2
		end
		if self.particleS[stopOrderNum] ==nil then
			self:playParticles(stopOrderNum,isColor,curColorNum)
		end
	end
	-- self:getAllAwardToShowWithDialog()
end
function acOlympicDialog:playParticles(showIdx,isColor,curColorNum)
    --粒子效果
    local PointTb  = acOlympicVoApi:getPointTb( )
	if isColor >0 and self.isParticle ~= showIdx then

		self.isParticle = showIdx
		local needParticle
		if isColor >1 then
			needParticle = "public/olympicImage/silverRingParticl.plist"
		else
			needParticle = "public/olympicImage/goldRingParticl.plist"
		end
		local p = CCParticleSystemQuad:create(needParticle)
		p.positionType = kCCPositionTypeFree
		p:setAnchorPoint(ccp(0,1))
		p:setScale(0.58)
		p:setPosition(ccp(self.bigRingsPosTb[showIdx].x+self.needContentSize.width*0.5,self.bigRingsPosTb[showIdx].y-self.needContentSize.height*0.5))
		self.bgLayer:addChild(p,3)
		self.particleS[showIdx] = p

		self:smallRingShowEffect(showIdx,isColor,curColorNum)
	end
	local curGetScoresTb = acOlympicVoApi:getCurGetSocresTb(curSocresTb )
	local curSocreLb = nil
	if self.curScoreLbTb[showIdx] ==nil then
		curSocreLb = GetTTFLabel("+"..curGetScoresTb[showIdx],25)
		curSocreLb:setAnchorPoint(ccp(0.5,0.5))
		curSocreLb:setPosition(ccp(self.bigRingsPosTb[showIdx].x+self.needContentSize.width*0.5,self.bigRingsPosTb[showIdx].y-self.needContentSize.height*0.5))
		self.bgLayer:addChild(curSocreLb,2)
		self.curScoreLbTb[showIdx] = curSocreLb

	else
		tolua.cast(self.curScoreLbTb[showIdx],"CCLabelTTF"):setString("+"..curGetScoresTb[showIdx])
		self.curScoreLbTb[showIdx]:setVisible(true)
	end
	if curGetScoresTb[showIdx] ==PointTb[1] then
		tolua.cast(self.curScoreLbTb[showIdx],"CCLabelTTF"):setColor(ccc3(255,250,116))
		tolua.cast(self.curScoreLbTb[showIdx],"CCLabelTTF"):setFontSize(29)
	elseif curGetScoresTb[showIdx] ==PointTb[3] then
		tolua.cast(self.curScoreLbTb[showIdx],"CCLabelTTF"):setColor(ccc3(255,147,82))
	end
	
end

function acOlympicDialog:smallRingShowEffect( showIdx,isColor,curColorNum )
	print("curColorNum---->>>",curColorNum)
	if isColor >0 then
		local needParticle
		if isColor >1 then
			needParticle = "public/olympicImage/silverRingParticl.plist"
		else
			needParticle = "public/olympicImage/goldRingParticl.plist"
		end
		local p = CCParticleSystemQuad:create(needParticle)
		p.positionType = kCCPositionTypeFree
		p:setAnchorPoint(ccp(0,1))
		p:setScale((self.smallScaleNum+0.08)*0.5)
		p:setPosition(ccp(self.smallRingsPosTb[curColorNum].x+self.needContentSize.width*0.5*self.smallScaleNum,self.smallRingsPosTb[curColorNum].y-self.needContentSize.height*0.5*self.smallScaleNum))
		self.bgLayer:addChild(p,1)
		self.smallParticleS[curColorNum] = p

	end
end
function acOlympicDialog:removeParticles()
	if self.particleS ~= nil then
	  for k,v in pairs(self.particleS) do
	    v:removeFromParentAndCleanup(true)
	  end
	end
	if self.curScoreLbTb ~=nil then
		for k,v in pairs(self.curScoreLbTb) do
			v:setVisible(false)
			v:setColor(G_ColorWhite)
			v:setFontSize(25)
			-- tolua.cast(v,"CCLabelTTF"):setVisible(false)
		end
	end
	if self.smallParticleS ~=nil then
		for k,v in pairs(self.smallParticleS) do
			v:removeFromParentAndCleanup(true)
		end
	end
  self.particleS = {}
  self.smallParticleS = {}
  
end

function acOlympicDialog:refreshState( )
	self.beginDelyTime = 1
	self.state  = nil
	self.hadStopTb = {}
	self:removeParticles()
	self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5000))
end

function acOlympicDialog:xiaBiBianSe( )
	if self.colorRate < self.firstChangeColorRateLimit then
		self.colorRate = self.colorRate +1
	else
		if self.bigRingsTb and #self.bigRingsTb >4 then
			for i=1,5 do
				if self.colorNum +1 <7 then
					self.colorNum = self.colorNum +1
				else
					self.colorNum = 1
				end
				self.bigRingsTb[i]:setColor(self.allColors[self.colorNum])
			end
		end
		self.colorRate = 1
	end
end



function acOlympicDialog:needMoneyDia(cost,playerGems,wholeTouchBgSp)
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

function acOlympicDialog:refreshVisible2()

    local goldNum1,goldNum2=acOlympicVoApi:getCostWithOneAndTenTimes()
	local haveCost = playerVoApi:getGems()

    if acOlympicVoApi:canReward()==true then
        self.freeBtn:setVisible(true)
    	self.talkBtn1:setEnabled(false)
    	self.talkBtn2:setEnabled(false)
    	self.oneCostStr:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5-5,self.talkBtn1:getContentSize().height*0.5-250))
    	self.gemIcon1:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5-250))
    	self.tenCostStr:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5-5,self.talkBtn2:getContentSize().height*0.5-250))
    	self.gemIcon2:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5-250))
    else
        self.freeBtn:setVisible(false)
    	self.talkBtn1:setEnabled(true)
    	self.talkBtn2:setEnabled(true)
    	self.oneCostStr:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5+35))
    	self.gemIcon1:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5+35))
    	self.tenCostStr:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5+35))
    	self.gemIcon2:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5+35))

    	if haveCost<goldNum1 then
	    	self.oneCostStr:setColor(G_ColorRed)
	    else
	    	self.oneCostStr:setColor(G_ColorYellowPro)
	    end
	    if haveCost<goldNum2 then
	    	self.tenCostStr:setColor(G_ColorRed)
	    else
	    	self.tenCostStr:setColor(G_ColorYellowPro)
	    end
    end
end

function acOlympicDialog:socBuy(tag )
		local oneCost,tenCost = acOlympicVoApi:getCostWithOneAndTenTimes( )
	  -- local haveCost = playerVoApi:getGems()
	  if oneCost ==nil then------------假数据！！！！！！！！
	  	oneCost =50
	  	tenCost =450
	  end
	print("in btnClick----->tag",tag)
		local haveCost = playerVoApi:getGems()
        
        PlayEffect(audioCfg.mouseClick)
        local free = false --acLuckyPokerVoApi:isToday()
        local needSubCost =0
        if tag == 31 then
        	free =true
        elseif tag ==32 then 
        	if tonumber(oneCost) > haveCost then
	        	self:needMoneyDia(oneCost,haveCost,self.wholeTouchBgSp)--出板子 让玩家充值
	        	do return end
	        else
	        	needSubCost =oneCost
	        end
        elseif tag ==33 then
        	if  tonumber(tenCost) > haveCost then
	        	self:needMoneyDia(tenCost,haveCost,self.wholeTouchBgSp)--出板子 让玩家充值
	        	do return end
			else
	        	needSubCost =tenCost
	        end
        end
        local acIdx =tag-30
        if needSubCost > 0 then
        	acOlympicVoApi:setBuyTagAndGems(acIdx,needSubCost)
        elseif needSubCost == 0 then
        	acOlympicVoApi:setBuyTagAndGems(acIdx,oneCost)
        end
        local function callback(fn,data)
        	local ret,sData = base:checkServerData(data)
	        if ret==true then
	        	acOlympicVoApi:setIsSeeRecord(false)
	        	self:refreshVisibleWithRecord()
	        	
	        	self.wholeTouchBgSp:setVisible(true)
	        	playerVoApi:setGems(playerVoApi:getGems()-needSubCost)
	        	if sData and sData.data then
	        		self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,0))
	        		local data = sData.data
	        		if data[self.activeName] then
	        			acOlympicVoApi:updateLastTime(data[self.activeName].t)
	        		end
	        		if data.report then
	        			acOlympicVoApi:setCurAllScores( data.report )--用于奖励板子使用
	        			self.curReport = data.report
	        		end
	        		if data.reward then
	        			acOlympicVoApi:setCurAwardTb(data.reward)
	        		end
	        		--activity_olympic_beginLb
	        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_olympic_beginLb"),28)
	        		self.state = 1
	        	end
		    	self:refreshVisible2()
	        end
        end
        socketHelper:acOlympicSoc(acIdx,self.activeName,callback)
end

function acOlympicDialog:getAllAwardToShowWithDialog(isClick)
	self.clickUseUp = 0
	local function closeSure( )
		print("in closeSure~~~~~acOlympicGetRewardDialog~~~")
		self:refreshState()
		if acOlympicVoApi:getAgainBug( ) ==3 then
			local acIdx = acOlympicVoApi:getBuyTagAndGems( )
			if acIdx == 1 then --从免费 变成付费
				acIdx = acIdx +1
			end
			if acOlympicVoApi:isToday() == false  then --免费
				print("免费~~~~~~~~~")
				acIdx = 1
			end
			self:socBuy(acIdx+30)------
		end
	end
	self.acOlympicGetRewardDialog=acOlympicGetRewardDialog:new(self.layerNum + 1)
  	local dialog= self.acOlympicGetRewardDialog:init(closeSure)
  	self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5000))
end

function acOlympicDialog:openRecordDia()--获奖记录
	local recordTb = acOlympicVoApi:getAwardAllTbRecord( )
	if recordTb ==nil or #recordTb ==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
	else
		self.acOlympicRecordDialog =acOlympicRecordDialog:new(self.layerNum + 1)
	  	local dialog= self.acOlympicRecordDialog:init(nil)
   end
end
function acOlympicDialog:refreshVisibleWithRecord()
	if acOlympicVoApi:getIsSeeRecord() ==true then
		self.tipIcon:setVisible(false)
	else
		self.tipIcon:setVisible(true)
	end
end

function acOlympicDialog:tick()
	local acVo = acOlympicVoApi:getAcVo()
	if acVo ~= nil then
		if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
			if self ~= nil then
				self:close()
			end
		end
	end
	if acOlympicVoApi:isToday()==false and self.isToday==true then
		self.isToday=false
		self:refreshVisible2()
	end
end