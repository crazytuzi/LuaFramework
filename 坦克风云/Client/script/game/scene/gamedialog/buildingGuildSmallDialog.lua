buildingGuildSmallDialog=smallDialog:new()

function buildingGuildSmallDialog:new()
    local nc={
      bgLayer=nil,             --背景sprite
    }
    setmetatable(nc,self)
    self.__index=self

    base.allShowedSmallDialog=base.allShowedSmallDialog+1
    return nc
end

function buildingGuildSmallDialog:init(bgSrc,size,bgRect,titleStr,buildData,layerNum,callback)
	self.layerNum=layerNum
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.bgSize=size
    if bgSrc==nil then
    	bgSrc="TaskHeaderBg.png"
    end
    if bgRect then
    	bgRect=CCRect(20,20,10,10)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local function nilFunc()
	end
	local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,bgRect,nilFunc)
	self.dialogLayer=CCLayerColor:create(ccc4(0,0,0,120))
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(self.bgSize)
	-- self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.bgLayer:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.dialogLayer:setTouchEnabled(true)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	self:show()

	local bgSp1=CCSprite:createWithSpriteFrameName("expedition_up.png")
	bgSp1:setAnchorPoint(ccp(0.5,1))
	bgSp1:setScaleX(size.width/bgSp1:getContentSize().width)
	bgSp1:setPosition(ccp(size.width/2,size.height))
	self.bgLayer:addChild(bgSp1,2)

	local bgSp2=CCSprite:createWithSpriteFrameName("expedition_down.png")
	bgSp2:setAnchorPoint(ccp(0.5,0))
	bgSp2:setScaleX(size.width/bgSp2:getContentSize().width)
	bgSp2:setPosition(ccp(size.width/2,0))
	self.bgLayer:addChild(bgSp2,6)


	local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
	blueBg:setAnchorPoint(ccp(0.5,0))
	blueBg:setScaleX((size.width-8)/blueBg:getContentSize().width)
	blueBg:setScaleY(size.height/blueBg:getContentSize().height)
	blueBg:setPosition(ccp(size.width/2,0))
	self.bgLayer:addChild(blueBg)

	local titleBg=CCSprite:createWithSpriteFrameName("gloryTitleBg.png")
	titleBg:setAnchorPoint(ccp(0.5,0))
	titleBg:setPosition(ccp(size.width/2,size.height))
	titleBg:setScaleX(size.width/titleBg:getContentSize().width)
	self.bgLayer:addChild(titleBg)
	-- title
	local titleLb=GetTTFLabelWrap(titleStr,30,CCSizeMake(size.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,0))
	-- titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(ccp(size.width/2,size.height))
	self.bgLayer:addChild(titleLb,1)

	local buildSp=CCSprite:createWithSpriteFrameName(buildData.pic)
	local scale=1
	local buildPosX=10
	local buildPosY=110+(size.height-110)/2-40
	if buildData.buildType>=1 and buildData.buildType<=3 then
		buildPosY=110+(size.height-110)/2-10
	elseif buildData.buildType==4 then
		buildPosY=110+(size.height-110)/2-25
	else
		buildPosY=110+(size.height-110)/2-10
	end
	if buildData.buildType==15 then
		scale=200/buildSp:getContentSize().width
		buildPosX=buildSp:getContentSize().width*scale/2-10
	else
		scale=150/buildSp:getContentSize().width
		buildPosX=10+buildSp:getContentSize().width*scale/2
	end
	buildSp:setScale(scale)
	buildSp:setPosition(ccp(buildPosX,buildPosY))
	self.bgLayer:addChild(buildSp)

	local nameBg=CCSprite:createWithSpriteFrameName("building_guild_namebg.png")
	nameBg:setAnchorPoint(ccp(0,1))
	nameBg:setPosition(ccp(170,size.height-40))
	self.bgLayer:addChild(nameBg)

	local nameLb=GetTTFLabelWrap(buildData.name,28,CCSizeMake(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setColor(G_ColorYellowPro)
	nameLb:setPosition(ccp(10,nameBg:getContentSize().height/2))
	nameBg:addChild(nameLb,1)


	local descLb=GetTTFLabelWrap(buildData.desc,25,CCSizeMake(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	local function touch(hd,fn,idx)
    end
    local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),touch)
    descBg:setContentSize(CCSizeMake(size.width-200,descLb:getContentSize().height+30))
    descBg:ignoreAnchorPointForPosition(false)
    descBg:setAnchorPoint(ccp(0,0.5))
    descBg:setIsSallow(false)
    descBg:setTouchPriority(-(self.layerNum-1)*20-2)
    descBg:setPosition(ccp(160,90+(size.height-90-nameBg:getContentSize().height)/2))
    self.bgLayer:addChild(descBg)

    descLb:setAnchorPoint(ccp(0,0.5))
	-- descLb:setColor(G_ColorYellowPro)
	descLb:setPosition(ccp(10,descBg:getContentSize().height/2))
	descBg:addChild(descLb,1)

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX(size.width/lineSp:getContentSize().width)
    lineSp:setScaleY(1.2)
    lineSp:setPosition(ccp(size.width/2,110))
    self.bgLayer:addChild(lineSp,2)

	--建造
    local function sureHandler()
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		if(callback)then
			callback()
		end
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")	
        self:realClose()
    end
    local str=getlocal("build")
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,str,25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,60))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    local function nilFunc()
	end
	
	local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(0)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(0,0)
	return self.dialogLayer
end