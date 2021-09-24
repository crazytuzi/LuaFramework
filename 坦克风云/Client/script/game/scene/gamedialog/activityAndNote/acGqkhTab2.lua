acGqkhTab2 = {}

function acGqkhTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.numLb=nil
	return nc
end

function acGqkhTab2:init(layerNum)
	self.cfg=acGqkhVoApi:getVersionCfg()
	self.activeName=acGqkhVoApi:getActiveName()

	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer()
	return self.bgLayer
end

function acGqkhTab2:initLayer()
	self:addBg()
	self:addTitleLb()
	self:addTV()
end

function acGqkhTab2:addBg()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local function click(hd,fn,idx)
    end
    local rect=CCRect(0,0,612,466)
	local diBg=LuaCCScale9Sprite:create("public/acCnNewYearImage/cnNewYearBg.jpg",rect,CCRect(100, 150, 1, 1),click)
	diBg:setAnchorPoint(ccp(0.5,1))
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local rect2
	if G_getIphoneType() == G_iphoneX then
		--diBg:setScaleY((G_VisibleSizeHeight-183)/diBg:getContentSize().height)
		rect2=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-193)
	else
		rect2=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-240)

	end
	diBg:setContentSize(rect2)
	diBg:setAnchorPoint(ccp(0.5,1))
	diBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight-163))
	self.bgLayer:addChild(diBg)

	-- local bigBg =LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	-- local rect=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-186)
	-- bigBg:setContentSize(rect)

	-- CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
 --    bigBg:setOpacity(100)
 --    bigBg:setAnchorPoint(ccp(0.5,0.5))
 --    bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-186)/2))
 --    self.bgLayer:addChild(bigBg)
end

function acGqkhTab2:addTitleLb()
	local titleLb=GetTTFLabel(getlocal("activity_gqkh_leftPoint"),25)
	self.bgLayer:addChild(titleLb)
	local numLb=GetTTFLabel(acGqkhVoApi:getV(),25)
	self.bgLayer:addChild(numLb)
	local goldIcon = CCSprite:createWithSpriteFrameName("acGqkh_ vouchers.png")
	goldIcon:setScale(40/goldIcon:getContentSize().width)
	self.bgLayer:addChild(goldIcon)
	self.titleLb=titleLb
	self.numLb=numLb
	self.goldIcon=goldIcon
	self:setTitilePos()
end

function acGqkhTab2:setTitilePos()
	local width1=self.titleLb:getContentSize().width
	local width2=self.numLb:getContentSize().width
	local width3=self.goldIcon:getContentSize().width
	self.titleLb:setPosition((G_VisibleSizeWidth-width2-width3)/2,G_VisibleSizeHeight-192)
	self.numLb:setPosition((G_VisibleSizeWidth-width3)/2+width1/2,G_VisibleSizeHeight-192)
	self.goldIcon:setPosition(G_VisibleSizeWidth/2+(width1+width2)/2,G_VisibleSizeHeight-192)
end

function acGqkhTab2:addTV()
	local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
    	adaH = 60
    end
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSize.height-280-adaH),nil)-- -200
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,40))--40
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)--120
end


function acGqkhTab2:eventHandler(handler,fn,idx,cel)
	local strSize2 = 13
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =20
    end
	if fn=="numberOfCellsInTableView" then	 	
        return math.ceil(SizeOfTable(self.cfg.shop)/3)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-40,200)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local function touch(tag,object)
        	if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			        PlayEffect(audioCfg.mouseClick)

			        local sid = "i" .. tag
			        local function refreshFunc()
			        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceShop_buySuccess"),30)
			        	self:refresh()
			        	local lastNumsLb = tolua.cast(object:getChildByTag(101),"CCLabelTTF")
			        	lastNumsLb:setString(getlocal("activity_double11_lastNums",{acGqkhVoApi:getLeftNumBySid(sid)}))

			        end
			        local function callBack()
			        	acGqkhVoApi:buyShop(sid,self.activeName,refreshFunc)
			        end
			        if acGqkhVoApi:getLeftNumBySid(sid)<=0 then
			        	-- 已售罄
			        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_double11_buyEndNums"),30)
			        	return
			        end
			        local shopCfg=self.cfg.shop[sid]
			        local needCousume=shopCfg.price
			        local haveNum=acGqkhVoApi:getV()
			        if haveNum<needCousume then
			        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_gqkh_notEnough"),30)
			        	return
			        end
			        local rewardItem=FormatItem(shopCfg.reward)
			        local consumeTb={shopCfg.price,"acGqkh_ vouchers.png"}
			        acGqkhSmallDialog:showScrollDialog("TankInforPanel.png",CCRect(130, 50, 1, 1),CCSizeMake(550,380),self.layerNum+1,nil,true,rewardItem[1],consumeTb,callBack,self.bgLayer)
			    end
			end
        	
        end
        local buyLog=acGqkhVoApi:getB()
        for i=1,3 do
        	local sid="i" .. (idx*3+i)
        	local cfg=self.cfg.shop[sid]
        	if cfg then
        		local sellBtn=GetButtonItem("redCardBg_1.png","redCardBg_2.png","redCardBg_1.png",touch,idx*3+i)
				sellBtn:setAnchorPoint(ccp(0.5,0.5))
				local sellMenu=CCMenu:createWithItem(sellBtn)
				sellMenu:setPosition(ccp(143+(i-1)*180,100))
				sellMenu:setTouchPriority(-(self.layerNum-1)*20-2)
				cell:addChild(sellMenu,1)

				local rewardItem=FormatItem(cfg.reward)
				local icon,scale=G_getItemIcon(rewardItem[1],100)
				sellBtn:addChild(icon)
				icon:setPosition(sellBtn:getContentSize().width/2,sellBtn:getContentSize().height-65)

				local numLb=GetTTFLabel("x" .. rewardItem[1].num,20)
				icon:addChild(numLb)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setScale(1/scale)
				numLb:setPosition(icon:getContentSize().width*scale-5,5)


				local costLb = GetTTFLabel(cfg.price,20)
                costLb:setAnchorPoint(ccp(1,0.5))
                costLb:setPosition(ccp(sellBtn:getContentSize().width/2-costLb:getContentSize().width/2,sellBtn:getContentSize().height-130))
                sellBtn:addChild(costLb,1)

                local goldIcon = CCSprite:createWithSpriteFrameName("acGqkh_ vouchers.png")
                goldIcon:setScale(40/goldIcon:getContentSize().width)
                goldIcon:setAnchorPoint(ccp(0,0.5))
    			goldIcon:setPosition(ccp(sellBtn:getContentSize().width/2,sellBtn:getContentSize().height-130))
    			sellBtn:addChild(goldIcon,1)

				local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
				lineSp:setScaleX((sellBtn:getContentSize().width-20)/lineSp:getContentSize().width)
				sellBtn:addChild(lineSp)
				lineSp:setPosition(sellBtn:getContentSize().width/2,sellBtn:getContentSize().height-150)

				local lastNumsLb = GetTTFLabel(getlocal("activity_double11_lastNums",{acGqkhVoApi:getLeftNumBySid(sid)}),strSize2)
                lastNumsLb:setPosition(ccp(sellBtn:getContentSize().width/2,25))
                sellBtn:addChild(lastNumsLb,1)
                lastNumsLb:setTag(101)

        	end
        end

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function acGqkhTab2:refresh()
	if self.numLb then
		self.numLb:setString(acGqkhVoApi:getV())
		self:setTitilePos()
	end
end

function acGqkhTab2:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.numLb=nil
end

