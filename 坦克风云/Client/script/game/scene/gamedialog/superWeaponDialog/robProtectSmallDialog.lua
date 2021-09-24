robProtectSmallDialog=smallDialog:new()

function robProtectSmallDialog:new(swId,type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.swId=swId
	nc.type=type
	nc.dialogWidth=550
	nc.dialogHeight=450
	return nc
end

function robProtectSmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function robProtectSmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	-- local titleStr=getlocal("playerInfo")
	-- local titleLb=GetTTFLabel(titleStr,30)
	-- titleLb:setAnchorPoint(ccp(0.5,0.5))
	-- titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	-- dialogBg:addChild(titleLb,1)
    
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)
end

function robProtectSmallDialog:initContent()
	local lbSize2 = 22
	local butonLbSize = 24
	local noticeLbSize = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        lbSize2 = 22
        noticeLbSize = 22
        butonLbSize = 24
    end
	local posY=self.dialogHeight-70
	-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
	local descStr=getlocal("super_weapon_rob_protect_desc",{math.floor(weaponrobCfg.gemsBuyProtectTime/3600)})
	local descLb=GetTTFLabelWrap(descStr,lbSize2,CCSizeMake(self.dialogWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0.5,0.5))
	descLb:setPosition(ccp(self.dialogWidth/2,posY))
	self.bgLayer:addChild(descLb,1)

	posY=posY-90
	local posX1=self.dialogWidth/2-120
	local posX2=self.dialogWidth/2+120
	local propTb=FormatItem(weaponrobCfg.protectCostProp)
	local item=propTb[1]
	local propIcon=CCSprite:createWithSpriteFrameName(item.pic)
	propIcon:setPosition(ccp(posX1,posY))
	self.bgLayer:addChild(propIcon,1)
	local pid=(tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
	local propNum=bagVoApi:getItemNumId(pid)
	local propNumLb=GetTTFLabel("x"..propNum,25)
	propNumLb:setAnchorPoint(ccp(1,0))
	propNumLb:setPosition(ccp(propIcon:getContentSize().width-5,5))
	propIcon:addChild(propNumLb,1)
	local goldIcon=CCSprite:createWithSpriteFrameName("resourse_normal_gem.png")
	goldIcon:setPosition(ccp(posX2,posY))
	self.bgLayer:addChild(goldIcon,1)
	local goldNum=playerVoApi:getGems()
	local goldNumLb=GetTTFLabel("x"..FormatNumber(goldNum),25)
	goldNumLb:setAnchorPoint(ccp(1,0))
	goldNumLb:setPosition(ccp(goldIcon:getContentSize().width-5,5))
	goldIcon:addChild(goldNumLb,1)

	posY=posY-80
	local costPropNum=item.num
	local numLb1=GetTTFLabel(costPropNum,25)
	numLb1:setPosition(ccp(posX1-20,posY))
	self.bgLayer:addChild(numLb1,1)

	local sp1=CCSprite:createWithSpriteFrameName("sw_10.png")
	sp1:setPosition(ccp(posX1+20,posY-3))
	self.bgLayer:addChild(sp1,1)
	sp1:setScale(0.3)
	local costGemsNum=weaponrobCfg.gemsBuyProtectCost
	local numLb2=GetTTFLabel(costGemsNum,25)
	numLb2:setPosition(ccp(posX2-20,posY))
	self.bgLayer:addChild(numLb2,1)
	local sp2=CCSprite:createWithSpriteFrameName("IconGold.png")
	sp2:setPosition(ccp(posX2+20,posY))
	self.bgLayer:addChild(sp2,1)

	posY=posY-60
    local function usePropHandler()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

		local num=bagVoApi:getItemNumId(item.id)
        if num<=0 then
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newTech_pNotEnought"),30)
            do return end
        end
        local function useProcCallback(fn,data)
        	local ret,sData=base:checkServerData(data)
			if(ret==true)then
				if(sData.data.weapon)then
					superWeaponVoApi:formatData(sData.data.weapon)
				end
	        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_protect_success"),30)
	        	self:close()
	        end
        end
        socketHelper:useProc(item.id,nil,useProcCallback)
    end
    local usePropItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",usePropHandler,2,getlocal("super_weapon_rob_prop_protect_btn"),butonLbSize/0.8,101)
    usePropItem:setScale(0.8)
    local btnLb = usePropItem:getChildByTag(101)
    if btnLb then
    	btnLb = tolua.cast(btnLb,"CCLabelTTF")
    	btnLb:setFontName("Helvetica-bold")
    end
    local usePropMenu=CCMenu:createWithItem(usePropItem)
    usePropMenu:setPosition(ccp(posX1,posY))
    usePropMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(usePropMenu,1)

    local function useGemsHandler()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        if(costGemsNum>playerVoApi:getGems())then
            GemsNotEnoughDialog(nil,nil,costGemsNum - playerVoApi:getGems(),self.layerNum+1,costGemsNum)
            do return end
        end
        local function weaponBuyProtectCallback()
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_protect_success"),30)
        	self:close()
        end
        superWeaponVoApi:weaponBuyProtect(weaponBuyProtectCallback)
    end
    local useGemsItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",useGemsHandler,2,getlocal("super_weapon_rob_gold_protect_btn"),butonLbSize/0.8,101)
    useGemsItem:setScale(0.8)
    local btnLb = useGemsItem:getChildByTag(101)
    if btnLb then
    	btnLb = tolua.cast(btnLb,"CCLabelTTF")
    	btnLb:setFontName("Helvetica-bold")
    end
    local useGemsMenu=CCMenu:createWithItem(useGemsItem)
    useGemsMenu:setPosition(ccp(posX2,posY))
    useGemsMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(useGemsMenu,1)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0.5))
	lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setScaleY(1.2)
	lineSp:setPosition(ccp(self.dialogWidth/2,90))
	self.bgLayer:addChild(lineSp,2)

	local noticeLb=GetTTFLabelWrap(getlocal("super_weapon_rob_protect_notice"),noticeLbSize,CCSizeMake(self.dialogWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	noticeLb:setAnchorPoint(ccp(0.5,0.5))
	noticeLb:setPosition(ccp(self.dialogWidth/2,55))
	self.bgLayer:addChild(noticeLb,1)
	noticeLb:setColor(G_ColorYellowPro)
end

function robProtectSmallDialog:dispose()

end