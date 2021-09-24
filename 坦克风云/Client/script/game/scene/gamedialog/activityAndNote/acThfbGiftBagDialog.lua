-- @Author hj
-- @Description 特惠风暴礼包板子
-- @Date 2018-05-16

acThfbGiftBagDialog = {} 

function acThfbGiftBagDialog:new(layer,partent)
	local nc = {
		layerNum = layer,
		bagNum = acThfbVoApi:getGiftNum(),
		partent = partent,
		curBagNum = 0
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acThfbGiftBagDialog:init()
	self.bgLayer=CCLayer:create()
	self:doUserHandler()
	self:initTableView()
	return self.bgLayer
end

function acThfbGiftBagDialog:doUserHandler()

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	
	local function onLoadIcon(fn,icon)
		if self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
			icon:setAnchorPoint(ccp(0.5,1))
			icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-158))
			local strSize = 22
			if G_isAsia() == false then
				strSize = 20
			end
			local adaH = 35
			if G_isAsia() == false  then
				adaH = 10
			end
			local descLb = GetTTFLabelWrap(getlocal("activity_thfb_giftBag_desc"),strSize,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			descLb:setAnchorPoint(ccp(0.5,0))
			descLb:setPosition(ccp(320,adaH))
			icon:addChild(descLb)
			self.bgLayer:addChild(icon)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/acSecretshop_bg.jpg"),onLoadIcon)
	
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


	local timeLb = GetTTFLabel(acThfbVoApi:getAcTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-170))
	self.timeLb = timeLb
	self.bgLayer:addChild(timeLb)

	local function touchInfo()
        local tabStr={}
        for i=1,4 do
        	table.insert(tabStr,getlocal("activity_thfb_subTitle_tip"..i))
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
	end 

    local tipButton = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-160-30),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,0.8,-(self.layerNum-1)*20-4)

end

function acThfbGiftBagDialog:initTableView()

	local function callBack(...)
        return self:eventHandler(...)
    end
    local function nilFunc( ... )
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    self.bgLayer:addChild(tvBg)
    tvBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight-155-190-10))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(10,20))

    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(616,G_VisibleSizeHeight-155-190-10-10),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(10,25))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)


    --设置tableview的遮罩
    local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgUp:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,340))
    stencilBgUp:setAnchorPoint(ccp(0.5,1))
    stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
    stencilBgUp:setTouchPriority(-(self.layerNum-1)*20-3)
    stencilBgUp:setVisible(false)
    stencilBgUp:setIsSallow(true)
    self.bgLayer:addChild(stencilBgUp,10)
    local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgDown:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,25))
    stencilBgDown:setAnchorPoint(ccp(0.5,0))
    stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
    stencilBgDown:setTouchPriority(-(self.layerNum-1)*20-3)
    stencilBgDown:setVisible(false)
    stencilBgDown:setIsSallow(true)
    self.bgLayer:addChild(stencilBgDown,10)
end

function acThfbGiftBagDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if self.bagNum then
        	return math.ceil(self.bagNum/2)
		end
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(616,262+10)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
        cell:autorelease()
        self:initCell(cell,idx)
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function acThfbGiftBagDialog:initCell(cell,idx)

	local cellWidth = 616
	local cellHeight = 272
	local count
	if (idx+1)*2 > self.bagNum then
		count = 1
	else
		count = 2
	end
	for i=1,count,1 do
	
		local backSpirte = CCSprite:createWithSpriteFrameName("bagNewBg.png")
		backSpirte:setAnchorPoint(ccp(0.5,0.5))
		if i ==1 then
			backSpirte:setPosition(1/4*cellWidth+3,cellHeight-5-262/2)
		else
			backSpirte:setPosition(3/4*cellWidth-3,cellHeight-5-262/2)
		end
		cell:addChild(backSpirte)

		local strSize = 20
		if G_isAsia() == false then
			strSize = 15
		end

		self.curBagNum = self.curBagNum + 1
		local sale,saleRate = acThfbVoApi:getGiftDis(self.curBagNum)

		local hasSale
		if sale == 10 then
			hasSale = false
		else
			hasSale = true
		end

		local titleStr = acThfbVoApi:getGiftBagDesc(self.curBagNum)
		local bagDescLb = GetTTFLabelWrap(titleStr,strSize,CCSizeMake(backSpirte:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)

		bagDescLb:setAnchorPoint(ccp(0.5,0.5))
		bagDescLb:setColor(G_ColorYellowPro)
		bagDescLb:setPosition(ccp(backSpirte:getContentSize().width/2,backSpirte:getContentSize().height-17))
		backSpirte:addChild(bagDescLb)
		
		if acThfbVoApi:judgeLimit(self.curBagNum) == true then
			bagDescLb:setColor(G_ColorRed)
		else
			bagDescLb:setColor(G_ColorYellowPro)
		end
 
		local function jumpHandler()
			
			if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

				-- 跳转
			local index 
			if i == 1 then
				index = (idx+1)*2 - 1
			else
				index = (idx+1)*2
			end
			self.partent:tabClick(1,index)
		end

		local redTieSprite = LuaCCSprite:createWithSpriteFrameName("red_tie.png",jumpHandler)
		redTieSprite:setAnchorPoint(ccp(1,1))
		redTieSprite:setTouchPriority(-(self.layerNum-1)*20-2)
		redTieSprite:setPosition(ccp(backSpirte:getContentSize().width-5,backSpirte:getContentSize().height-45))
		backSpirte:addChild(redTieSprite)
		
		local strSize = 20
		if G_isAsia() == false then
			strSize = 15
		elseif G_getCurChoseLanguage() == "ja" then
			strSize = 18
		end	

		local dis = acThfbVoApi:getTaskDis(self.curBagNum)
		if G_isAsia() == false then
			dis = 100 - dis*10
		end
		local saleLb = GetTTFLabelWrap(getlocal("activity_thfb_sale_desc",{dis}),strSize,CCSizeMake(redTieSprite:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		saleLb:setAnchorPoint(ccp(1,0.5))
		saleLb:setPosition(ccp(redTieSprite:getContentSize().width,redTieSprite:getContentSize().height/2))
		redTieSprite:addChild(saleLb)
		
		local function giftHandeler()

			if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

			local index 
			if i == 1 then
				index = (idx+1)*2 - 1
			else
				index = (idx+1)*2
			end
			self:runClickAction(backSpirte,index,bagDescLb)
		end

		local giftSpire = LuaCCSprite:createWithSpriteFrameName(acThfbVoApi:getBagIcon(self.curBagNum),giftHandeler)
		giftSpire:setAnchorPoint(ccp(0.5,0.5))
		giftSpire:setPosition(ccp(backSpirte:getContentSize().width/2+7,115))
		giftSpire:setTouchPriority(-(self.layerNum-1)*20-2)
		backSpirte:addChild(giftSpire)

		local saleSpire = CCSprite:createWithSpriteFrameName("saleRedBg.png")
		saleSpire:setRotation(20)
		saleSpire:setScale(0.8)
		saleSpire:setPosition(ccp(70,70))
		giftSpire:addChild(saleSpire)

		local saleLabel = GetTTFLabel("-"..tostring((1-saleRate)*100).."%",20)
		saleLabel:setPosition(saleSpire:getContentSize().width/2,saleSpire:getContentSize().height/2)
		saleSpire:addChild(saleLabel)

		local goldSpire = CCSprite:createWithSpriteFrameName("IconGold.png")
		backSpirte:addChild(goldSpire)

		local costLb = GetTTFLabel(acThfbVoApi:getBuyCost(self.curBagNum),20)
		backSpirte:addChild(costLb)

		if hasSale == false then
			saleSpire:setVisible(false)
			redTieSprite:setVisible(true)

			goldSpire:setAnchorPoint(ccp(1,0.5))
			goldSpire:setPosition(ccp(backSpirte:getContentSize().width/2,23))
			
			costLb:setAnchorPoint(ccp(0,0.5))
			costLb:setPosition(ccp(backSpirte:getContentSize().width/2,goldSpire:getPositionY()))

			if acThfbVoApi:getBuyCost(self.curBagNum) > playerVoApi:getGems() then
				costLb:setColor(G_ColorRed)
			else
				costLb:setColor(G_ColorWhite)
			end

		else
			saleSpire:setVisible(true)
			redTieSprite:setVisible(false)
			redTieSprite:setTouchPriority(-1)

			goldSpire:setAnchorPoint(ccp(0.5,0.5))
			goldSpire:setPosition(ccp(50,23))
			
			costLb:setAnchorPoint(ccp(0,0.5))
			costLb:setPosition(ccp(60,goldSpire:getPositionY()))

			local redLine=CCSprite:createWithSpriteFrameName("white_line.png")
			redLine:setColor(G_ColorRed)
			redLine:setAnchorPoint(ccp(1,0.5))
			redLine:setScaleX((costLb:getContentSize().width + goldSpire:getContentSize().width + 10)/redLine:getContentSize().width)
			redLine:setPosition(costLb:getContentSize().width+costLb:getPositionX()+10,goldSpire:getPositionY())
			backSpirte:addChild(redLine)

			local goldSpireSale = CCSprite:createWithSpriteFrameName("IconGold.png")
			goldSpireSale:setAnchorPoint(ccp(0.5,0.5))
			goldSpireSale:setPosition(ccp(200,21))
			backSpirte:addChild(goldSpireSale)

			local actualCost = math.floor(acThfbVoApi:getBuyCost(self.curBagNum)*saleRate)
			local saleCostLb = GetTTFLabel(actualCost,20)
			saleCostLb:setAnchorPoint(ccp(0,0.5))
			saleCostLb:setPosition(ccp(210,goldSpireSale:getPositionY()))
			backSpirte:addChild(saleCostLb)

			if actualCost > playerVoApi:getGems() then
				saleCostLb:setColor(G_ColorRed)
			else
				saleCostLb:setColor(G_ColorWhite)
			end
		end

	end

end

function acThfbGiftBagDialog:runClickAction(spirte,giftNum,bagDescLb)
	local scaleSmall = CCScaleTo:create(0.1,0.9)
	local delay = CCDelayTime:create(0.1)
	local scaleBig = CCScaleTo:create(0.1,1)
	local acArr = CCArray:create()
	acArr:addObject(scaleSmall)
	acArr:addObject(delay)
	acArr:addObject(scaleBig)
	local seque=CCSequence:create(acArr)
	local function callBack( ... )
		self.curBagNum = 0
		require "luascript/script/game/scene/gamedialog/activityAndNote/acThfbSmallDialog" 
		acThfbSmallDialog:showBuyDialog(CCSizeMake(550,500),getlocal("activity_thfb_small_buy"),30,G_ColorWhite,self.layerNum+1,giftNum,self.tv)
	end 

	local callFunc = CCCallFunc:create(callBack)
	local seq = CCSequence:createWithTwoActions(seque,callFunc)
	spirte:runAction(seq)
end

function acThfbGiftBagDialog:refreshTv( ... )
	if self.tv then
		self.curBagNum = 0
		self.tv:reloadData()
	end
end


function acThfbGiftBagDialog:tick( ... )
	self.timeLb:setString(acThfbVoApi:getAcTimeStr())
end

function acThfbGiftBagDialog:dispose( ... )
	self.curBagNum = nil
	self.bgLayer=nil
end
