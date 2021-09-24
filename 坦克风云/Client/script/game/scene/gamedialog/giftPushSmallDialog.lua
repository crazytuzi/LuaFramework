-- @Author hj
-- @Description 礼包推送
-- @Date 2018-07-11

giftPushSmallDialog=smallDialog:new()


function giftPushSmallDialog:new()
	local nc={
	}
	setmetatable(nc,self)
	self.__index=self

	spriteController:addTexture("public/blueFilcker.png")
	spriteController:addTexture("public/greenFlicker.png")
	spriteController:addTexture("public/purpleFlicker.png")
	spriteController:addTexture("public/yellowFlicker.png")
	spriteController:addTexture("public/redFlicker.png")
	spriteController:addPlist("public/blueFilcker.plist")
	spriteController:addPlist("public/greenFlicker.plist")
	spriteController:addPlist("public/purpleFlicker.plist")
	spriteController:addPlist("public/yellowFlicker.plist")
	spriteController:addPlist("public/redFlicker.plist")
	spriteController:addPlist("public/taskYouhua.plist")
	spriteController:addPlist("public/acThfb.plist")
	spriteController:addTexture("public/taskYouhua.png")
	spriteController:addTexture("public/acThfb.png")

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	giftPushVoApi:getCfg()
	return nc
end


function giftPushSmallDialog:showDialog(layerNum)
	local sd = giftPushSmallDialog:new()
	sd:initDialog(layerNum)
end

function giftPushSmallDialog:initDialog(layerNum)

	base:addNeedRefresh(self)
	self.size = CCSizeMake(502,660)

	self.isUseAmi = false
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0)) 

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("xsjx_bg.png",CCRect(4, 4, 0.5, 0.5),function ()end)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    self.bgLayer1 = CCLayer:create()
    self.bgLayer:addChild(self.bgLayer1)

    local function closeCallback( ... )
    	self:close()
    end

    local closeBtn = G_createBotton(self.bgLayer,ccp(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height+15),nil,"steward_closeBtn.png","steward_closeBtn_down.png","steward_closeBtn.png",closeCallback,1,-(layerNum-1)*20-2)

	local titleKuang = LuaCCScale9Sprite:createWithSpriteFrameName("head.png",CCRect(122,14,1,1),function ()end)
	titleKuang:setContentSize(CCSizeMake(self.size.width+4,30))
	titleKuang:setAnchorPoint(ccp(0.5,1))
	titleKuang:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height+3))
	self.bgLayer:addChild(titleKuang)	

	local titleBg = CCSprite:createWithSpriteFrameName("xsjx_titleBg.png")
	titleBg:setAnchorPoint(ccp(0.5,0.5))
	titleBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
	self.bgLayer:addChild(titleBg)

	local strSize = 30
	if G_isAsia() == false then
		strSize = 22
	end
	local titleLb = GetTTFLabel(getlocal("xsjx_title"),strSize,true)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2))
	titleBg:addChild(titleLb)

	-- 火车的女朋友
	local trainGirlfriend = CCSprite:createWithSpriteFrameName("charater_beautyGirl.png")
	trainGirlfriend:setAnchorPoint(ccp(0.5,1))
	trainGirlfriend:setPosition(ccp(56,self.bgLayer:getContentSize().height+42))
	self.bgLayer:addChild(trainGirlfriend)

	local goldKuang = CCSprite:createWithSpriteFrameName("xsjx_labelBg.png")
	goldKuang:setAnchorPoint(ccp(0,1))
	goldKuang:setPosition(ccp(-20,self.bgLayer:getContentSize().height-trainGirlfriend:getContentSize().height+42))
	self.bgLayer:addChild(goldKuang)

	local descLb = GetTTFLabelWrap(getlocal("xsjx_prompt"),20,CCSizeMake(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(ccp(self.bgLayer:getContentSize().width/2-130,self.bgLayer:getContentSize().height-230))
	self.bgLayer:addChild(descLb)

	local worthLabel = GetTTFLabel(getlocal("xsjx_worth"),22,true)
	worthLabel:setAnchorPoint(ccp(0.5,0.5))
	worthLabel:setPosition(ccp(80,goldKuang:getContentSize().height/2))
	goldKuang:addChild(worthLabel)

	local goldSp = CCSprite:createWithSpriteFrameName("iconGoldNew2.png")
	goldSp:setPosition(ccp(worthLabel:getPositionX()+worthLabel:getContentSize().width/2+55,goldKuang:getContentSize().height/2))
	goldKuang:addChild(goldSp)

	local goldLabel = GetBMLabel(giftPushVoApi:getWorth(),G_GoldFontSrc) 
	goldLabel:setScale(0.8)
    goldLabel:setAnchorPoint(ccp(0.5,0.5))
    goldLabel:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width/2+80,goldKuang:getContentSize().height/2))
    goldKuang:addChild(goldLabel,2)

    local function onLoadIcon(fn,icon)
		if self and self.bgLayer1 and tolua.cast(self.bgLayer1,"CCLayer") then
			icon:setAnchorPoint(ccp(0.5,1))
			icon:setPosition(ccp(self.size.width/2,self.size.height))
			self.bgLayer1:addChild(icon)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/xsjx_head_bg.jpg"),onLoadIcon)

	local rewardTb = giftPushVoApi:getReward()
	local colorTb = giftPushVoApi:getColor()
	local specShowTb = {"g","b","p","y","r"}
	local function nilFunc( ... )
    end

	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
	backSprie:setContentSize(CCSizeMake(80*(#rewardTb)+20*(#rewardTb-1),80))
	backSprie:setAnchorPoint(ccp(0.5,0.5))
	backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,230))
	backSprie:setOpacity(0)

	for k,v in pairs(rewardTb) do
        if v then
        
			local scaleSize = 80
            local px,py=40+100*(k-1),40

            local function showNewPropInfo()
                G_showNewPropInfo(layerNum+1,true,true,nil,v)
            end
            local icon,scale
            if v.type == "se" then
                icon,scale=G_getItemIcon(v,scaleSize,true,layerNum,nil,nil,nil,nil,nil,nil,true)
            else
                icon,scale=G_getItemIcon(v,scaleSize,false,layerNum,showNewPropInfo,nil)
            end
            icon:setTouchPriority(-(layerNum-1)*20-2)
            icon:setPosition(ccp(px,py))
            G_addRectFlicker2(icon,nil,nil,colorTb[k],specShowTb[colorTb[k]],nil,nil,true)
            backSprie:addChild(icon,3)

            local numLb=GetTTFLabel("x"..FormatNumber(v.num),18)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(icon:getContentSize().width-5,5))
            icon:addChild(numLb,1)
            numLb:setScale(1/scale)
        end
    end
	self.bgLayer:addChild(backSprie,10)


    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	
	local function onLoadIcon(fn,icon)
		if self and self.bgLayer1 and tolua.cast(self.bgLayer1,"CCLayer") then
			icon:setAnchorPoint(ccp(0.5,0))
			icon:setPosition(ccp(self.size.width/2,0))
			self.bgLayer1:addChild(icon)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/xsjx_bottom_bg.jpg"),onLoadIcon)

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	
	local bottomKuang = LuaCCScale9Sprite:createWithSpriteFrameName("head_metal.png",CCRect(56, 11, 1, 1),function ()end)
	bottomKuang:setContentSize(CCSizeMake(self.size.width+4,22))
	bottomKuang:setAnchorPoint(ccp(0.5,0))
	bottomKuang:setPosition(ccp(self.bgLayer:getContentSize().width/2,0))
	self.bgLayer:addChild(bottomKuang)

	local barBg =  LuaCCScale9Sprite:createWithSpriteFrameName("greenBarBg.png",CCRect(13, 13, 1, 1),function ()end)
	barBg:setContentSize(CCSizeMake(446,26))
	barBg:setAnchorPoint(ccp(0.5,0.5))
	barBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,140))
	self.bgLayer:addChild(barBg)

	local lineSp = CCSprite:createWithSpriteFrameName("greenBar.png")
    local lineProgress = CCProgressTimer:create(lineSp)
	lineProgress:setAnchorPoint(ccp(0.5,0.5))
	lineProgress:setType(kCCProgressTimerTypeBar)
	lineProgress:setBarChangeRate(ccp(1, 0))
	lineProgress:setMidpoint(ccp(0, 0.5))
	lineProgress:setPosition(ccp(self.bgLayer:getContentSize().width/2,140))
	lineProgress:setPercentage(math.ceil(playerVoApi:getRechargeNum()/giftPushVoApi:rechargeNum()*100))
	self.bgLayer:addChild(lineProgress)

	local actualNum = playerVoApi:getRechargeNum() > giftPushVoApi:rechargeNum()  and giftPushVoApi:rechargeNum() or playerVoApi:getRechargeNum()

	local progressLabel = GetTTFLabel(getlocal("curProgressStr",{actualNum,giftPushVoApi:rechargeNum()}),22,true)
	progressLabel:setAnchorPoint(ccp(0.5,0.5))
	progressLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,140))
	self.bgLayer:addChild(progressLabel)

	local str
	local pic1,pic2 
	if  playerVoApi:getRechargeNum() < giftPushVoApi:rechargeNum() then
		str = "recharge"
		pic1="creatRoleBtn.png"
		pic2="creatRoleBtn_Down.png"
	else
		str = "daily_scene_get"
		pic1="newGreenBtn.png"
		pic2="newGreenBtn_down.png"
	end

	local timeLb = GetTTFLabel( giftPushVoApi:getTimeStr(),22)
	timeLb:setColor(G_ColorBlue)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,120))
	self.timeLb = timeLb
	self.bgLayer:addChild(timeLb)

	local clockSp = CCSprite:createWithSpriteFrameName("xsjx.clock.png")
	clockSp:setAnchorPoint(ccp(1,1))
	clockSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-timeLb:getContentSize().width/2-10,125))
	self.bgLayer:addChild(clockSp)
	local function rechargeCallback( ... )
		if  playerVoApi:getRechargeNum() < giftPushVoApi:rechargeNum() then
			local function callback(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret == true  then
					vipVoApi:showRechargeDialog(layerNum+1,nil,"xsjx")
					self:close()
				end
			end
			socketHelper:xsjxDadian(1,callback)
		else
			local function callback(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret==true then
                    playerVoApi:setXsjxPop()
					for k,v in pairs(rewardTb) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                    G_showRewardTip(rewardTb,true)
                    self:close()
                    giftPushVoApi:refreshData()    			
                end
			end
			socketHelper:xsjxGetReward(callback)
		end
	end
	buyButton = G_createBotton(self.bgLayer,ccp(self.bgLayer:getContentSize().width/2,50),{getlocal(str),25},pic1,pic2,pic1,rechargeCallback,1,-(layerNum-1)*20-2)

	--黑色遮挡层
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
end


function giftPushSmallDialog:tick( ... )
	if self.timeLb then
		self.timeLb:setString(giftPushVoApi:getTimeStr())
	end
	if playerVoApi:getRechargeNum() < giftPushVoApi:rechargeNum() and playerVoApi:isXsjxValid() == false then
        self:close()
    end
end

function giftPushSmallDialog:dispose( ... )

	spriteController:removePlist("public/xsjx.plist")
	spriteController:removeTexture("public/xsjx.png")
	spriteController:removePlist("public/blueFilcker.plist")
	spriteController:removeTexture("public/blueFilcker.png")
	spriteController:removePlist("public/greenFlicker.plist")
	spriteController:removeTexture("public/greenFlicker.png")
	spriteController:removePlist("public/purpleFlicker.plist")
	spriteController:removeTexture("public/purpleFlicker.png")
	spriteController:removePlist("public/yellowFlicker.plist")
	spriteController:removeTexture("public/yellowFlicker.png")
	spriteController:removePlist("public/taskYouhua.plist")
	spriteController:removeTexture("public/taskYouhua.png")
	spriteController:removeTexture("public/acThfb.png")
	spriteController:removePlist("public/acThfb.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
end