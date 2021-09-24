addPropSmallDialog=smallDialog:new()

function addPropSmallDialog:new(swId,type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.swId=swId
	nc.type=type
	nc.dialogWidth=550
	nc.dialogHeight=440
	spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
	return nc
end

function addPropSmallDialog:init(layerNum,propMaxNum,callback,specialFlag)
	self.isTouch=nil
	self.layerNum=layerNum
	self.propMaxNum=propMaxNum
	self.callback=callback
	self.specialFlag = specialFlag
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function addPropSmallDialog:initBackground()
	local strSize2 = 26
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
		strSize2 = 30
	end
	local function nilFunc()
	end
	-- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	local dialogBg = G_getNewDialogBg(CCSizeMake(550,440),getlocal("sw_add_prop_title"),strSize2,nil,self.layerNum,nil,nil,nil)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    -- self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	-- self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	-- local function close()
	-- 	if G_checkClickEnable()==false then
	-- 		do return end
	-- 	else
	-- 		base.setWaitTime=G_getCurDeviceMillTime()
	-- 	end
	-- 	PlayEffect(audioCfg.mouseClick)
	-- 	return self:close()
	-- end
	-- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	-- closeBtnItem:setPosition(0,0)
	-- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	-- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	-- self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	-- self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	-- dialogBg:addChild(self.closeBtn)
	
	-- local titleStr=getlocal("sw_add_prop_title")
	-- local titleLb=GetTTFLabel(titleStr,strSize2)
	-- titleLb:setAnchorPoint(ccp(0.5,0.5))
	-- titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	-- dialogBg:addChild(titleLb,1)

	-- local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
 --    titleBg:setScaleX((self.dialogWidth-100)/titleBg:getContentSize().width)
 --    titleBg:setScaleY(65/titleBg:getContentSize().height)
 --    titleBg:setPosition(self.dialogWidth/2+20,self.dialogHeight-titleLb:getContentSize().height-5)
 --    dialogBg:addChild(titleBg)

 --    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	-- lineSp:setScale((self.dialogWidth-50)/lineSp:getContentSize().width)
	-- lineSp:setPosition(ccp(self.dialogWidth/2-10,self.dialogHeight-65-15))
	-- dialogBg:addChild(lineSp)
    
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)
end

function addPropSmallDialog:initContent()
	local strSize2 = 21
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
		strSize2 = 25
	end

	local posY=self.dialogHeight-110
	local descStr
	if self.specialFlag then
		descStr=getlocal("sw_protect_prop_desc")
	else
		descStr=getlocal("sw_add_prop_desc")
	end

	local descLb=GetTTFLabelWrap(descStr,strSize2,CCSizeMake(self.dialogWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0.5,0.5))
	descLb:setPosition(ccp(self.dialogWidth/2,posY))
	self.bgLayer:addChild(descLb,1)

	posY=posY-80
	-- local propTb=FormatItem(weaponrobCfg.addEnergyCostProp)
	-- local item=propTb[1]
	if self.specialFlag then

		local item=superWeaponVoApi:getProtetPropData()
		local propNum=0
		if item and item.num then
			propNum=item.num or 0
		end
		local function clickIconHandler( ... )
			local reward={w={{c201=item.num,index=1}}}
			local rewardTb = FormatItem(reward,true,true)[1]
			G_showNewPropInfo(self.layerNum+1,true,true,nil,rewardTb)
	    end
		local propIcon=item:getIconSp(clickIconHandler)
		propIcon:setPosition(ccp(80,posY-30))
		self.bgLayer:addChild(propIcon,1)
		propIcon:setTouchPriority(-(self.layerNum-1)*20-3)
		local propNameLb=GetTTFLabel(item:getLocalName(),25)
		propNameLb:setAnchorPoint(ccp(0,0.5))
		propNameLb:setPosition(ccp(150,posY))
		self.bgLayer:addChild(propNameLb,1)
		propNameLb:setColor(G_ColorPurple)
		local propNumLb=GetTTFLabel(getlocal("propOwned")..propNum,25)
		propNumLb:setAnchorPoint(ccp(0,0.5))
		propNumLb:setPosition(ccp(150,posY-60))
		self.bgLayer:addChild(propNumLb,1)


		posY = posY-100
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScale((self.dialogWidth-100)/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(self.dialogWidth/2,posY))
		self.bgLayer:addChild(lineSp)

		posY=posY-70
		local posX1=self.dialogWidth/2-120
		local posX2=self.dialogWidth/2+120
	    local function sureHandler()
	    	if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)

	        if self.callback then
	        	if self.specialFlag == 0 then
	        	--装配 
					if item and item.num and item.num >=1 then
	        			self.callback(1)
	        		end
	        	else
	        	-- 卸载
	        		self.callback(0)
        		end
	        end
	        self:close()
	    end
	    local str = ""
	    if self.specialFlag == 0 then
	    	str = "alien_tech_wear"
	    else
	    	str = "superWeapon_newCrystal_uninstall"
	    end
	    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",sureHandler,2,getlocal(str),25)
	    sureItem:setScale(0.8)
	    local sureMenu=CCMenu:createWithItem(sureItem)
	    sureMenu:setPosition(ccp(posX1,posY))
	    sureMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.bgLayer:addChild(sureMenu,1)

	    local function cancelHandler()
	    	if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)
	        self:close()
	    end
	    local cancelItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",cancelHandler,2,getlocal("cancel"),25)
	    cancelItem:setScale(0.8)
	    local cancelMenu=CCMenu:createWithItem(cancelItem)
	    cancelMenu:setPosition(ccp(posX2,posY))
	    cancelMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.bgLayer:addChild(cancelMenu,1)

	else	
		local item=superWeaponVoApi:getAddPerPropData()
		local propNum=0
		if item and item.num then
			propNum=item.num or 0
		end
		local function clickIconHandler( ... )
			local sbItem={}
			sbItem.type="p"
			sbItem.key="p12"
			sbItem.num=item.num
			sbItem.bgname="purpleBg.png"
			sbItem.pic=item:getIcon()
			sbItem.name=item:getLocalName()
			sbItem.desc=getlocal(item:getCfg().desc,{item:getCfg().att*100 .. "%%"})
			sbItem.noLocal=true
			sbItem.id=12
			local addDesc=getlocal("add_crystal11_description")
			propInfoDialog:create(sceneGame,sbItem,self.layerNum+1,nil,nil,addDesc,nil,nil,nil,false)
	    end
		local propIcon=item:getIconSp(clickIconHandler)
		propIcon:setPosition(ccp(80,posY))
		self.bgLayer:addChild(propIcon,1)
		propIcon:setTouchPriority(-(self.layerNum-1)*20-3)
		local propNameLb=GetTTFLabel(item:getLocalName(),25)
		propNameLb:setAnchorPoint(ccp(0,0.5))
		propNameLb:setPosition(ccp(150,posY+30))
		self.bgLayer:addChild(propNameLb,1)
		propNameLb:setColor(G_ColorPurple)
		local propNumLb=GetTTFLabel(getlocal("propOwned")..propNum,25)
		propNumLb:setAnchorPoint(ccp(0,0.5))
		propNumLb:setPosition(ccp(150,posY-30))
		self.bgLayer:addChild(propNumLb,1)

		posY=posY-90
		local spcaex=25
		local m_numLb=GetTTFLabel(" ",strSize2)
		m_numLb:setPosition(70,posY)
		self.bgLayer:addChild(m_numLb,2)
		local maxNum=propNum
		if maxNum>self.propMaxNum then
			maxNum=self.propMaxNum
		end
		local function sliderTouch(handler,object)
			local count = math.floor(object:getValue())
			m_numLb:setString(count.."/"..maxNum)
			-- if count>0 then
			-- 	lbTime:setString(GetTimeStr(timeConsume*count))
			-- 	for k,v in pairs(countTb) do
			-- 		v:setString(FormatNumber(tb[k].num2*count))
			-- 	end

			-- end
		end

		local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png")
		local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png")
		local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png")
		local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch)
		slider:setTouchPriority(-(self.layerNum-1)*20-2)
		slider:setIsSallow(true)

		slider:setMinimumValue(0.0)
		
		slider:setMaximumValue(maxNum)
		slider:setValue(maxNum)
		slider:setPosition(ccp(355-spcaex,posY))
		slider:setTag(99)
		self.bgLayer:addChild(slider,2)
		slider:setScaleX(0.8)
		self.slider = slider
		m_numLb:setString(math.floor(slider:getValue()).."/"..maxNum)


		local function touchAdd()
			slider:setValue(slider:getValue()+1);
		end

		local function touchMinus()
			if slider:getValue()-1>0 then
				slider:setValue(slider:getValue()-1);
			end
		end

		local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
		addSp:setPosition(ccp(549-spcaex-30,posY))
		self.bgLayer:addChild(addSp,1)
		addSp:setTouchPriority(-(self.layerNum-1)*20-3)

		local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
		minusSp:setPosition(ccp(157-spcaex+30,posY))
		self.bgLayer:addChild(minusSp,1)
		minusSp:setTouchPriority(-(self.layerNum-1)*20-3)

		-- local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png")
	 --    bgSp:setAnchorPoint(ccp(0.5,0.5))
	 --    bgSp:setPosition(self.bgLayer:getContentSize().width/2,posY)
	 --    self.bgLayer:addChild(bgSp)
	 --    bgSp:setScale(0.8)

	    local function touchHander()
	    end
	    local bgSp1=LuaCCScale9Sprite:createWithSpriteFrameName("buyBarBg.png",CCRect(10,10,10,10),touchHander)
	    bgSp1:setContentSize(CCSizeMake(400,45))
	    bgSp1:setPosition((addSp:getPositionX()+minusSp:getPositionX())/2,posY)
	    self.bgLayer:addChild(bgSp1)
	    local bgSp2=LuaCCScale9Sprite:createWithSpriteFrameName("buyBarBg.png",CCRect(10,10,10,10),touchHander)
	    bgSp2:setContentSize(CCSizeMake(100,45))
	    bgSp2:setPosition(70,posY)
	    self.bgLayer:addChild(bgSp2)

		posY=posY-40
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScale((self.dialogWidth-100)/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(self.dialogWidth/2,posY))
		self.bgLayer:addChild(lineSp)

		posY=posY-50
		local posX1=self.dialogWidth/2-120
		local posX2=self.dialogWidth/2+120
	    local function sureHandler()
	    	if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)

	        if self.callback then
	        	self.callback(math.floor(self.slider:getValue()))
	        end
	        self:close()
	    end
	    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",sureHandler,2,getlocal("ok"),25)
	    sureItem:setScale(0.8)
	    local sureMenu=CCMenu:createWithItem(sureItem)
	    sureMenu:setPosition(ccp(posX1,posY))
	    sureMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.bgLayer:addChild(sureMenu,1)

	    local function cancelHandler()
	    	if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)
	        self:close()
	    end
	    local cancelItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",cancelHandler,2,getlocal("cancel"),25)
	    cancelItem:setScale(0.8)
	    local cancelMenu=CCMenu:createWithItem(cancelItem)
	    cancelMenu:setPosition(ccp(posX2,posY))
	    cancelMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.bgLayer:addChild(cancelMenu,1)
	end

	
end

function addPropSmallDialog:dispose()
	spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end