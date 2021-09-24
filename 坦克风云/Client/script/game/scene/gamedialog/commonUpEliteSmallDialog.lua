commonUpEliteSmallDialog=smallDialog:new()

function commonUpEliteSmallDialog:new(data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.data=data or {}
	return nc
end

function commonUpEliteSmallDialog:init(layerNum,callBack)

	self.isUseAmi=true

	local data={}
	for k,v in pairs(self.data) do
		local tankId = tonumber(k) or tonumber(RemoveFirstChar(k))
		tankId=G_pickedList(tankId)
		local num = v
		table.insert(data,{tankId,num})
	end

	local function sortFunc(a,b)
		return tonumber(tankCfg[a[1]].sortId)<tonumber(tankCfg[b[1]].sortId)
	end

	table.sort(data,sortFunc)

	local num = SizeOfTable(self.data)
	local Size = CCSizeMake(550,220+num*90)
	-- 添加层
	self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))

    
    -- 添加屏蔽
	local function touchLuaSpr()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local flag=checkPointVoApi:getRefreshFlag()
        if flag==0 and G_WeakTb.checkPoint then
            G_WeakTb.checkPoint:refresh()
        end
        
		self:close()
		if callBack then
			callBack()
		end
		
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1)


	local function touchDialog()    
    end

    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    dialogBg:setContentSize(Size)
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    self:show()

    local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.bgLayer:addChild(spriteTitle,2)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.bgLayer:addChild(spriteTitle1,2)

	local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.bgLayer:addChild(spriteShapeAperture,1)

	local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png")
	self.bgLayer:addChild(lineSP)
	lineSP:setPosition(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height-130)

	local titleLb = GetTTFLabel(getlocal("tankUpgrade"),30)
	self.bgLayer:addChild(titleLb,3)
	titleLb:setPosition(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height-110)
	titleLb:setColor(G_ColorYellowPro)

	for i=1,#data do
		local function touchClick()
		end
		local arrowSp1 =LuaCCScale9Sprite:createWithSpriteFrameName("heroArrowRight.png",CCRect(9, 6, 1, 1),touchClick)
		arrowSp1:setContentSize(CCSizeMake(200, 16))
		arrowSp1:setAnchorPoint(ccp(0.5,0.5))
		arrowSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220-(i-1)*90))
		arrowSp1:setIsSallow(false)
		arrowSp1:setTouchPriority(-(layerNum-1)*20-1)
		self.bgLayer:addChild(arrowSp1,1)

		local numLb=GetTTFLabel(getlocal("numtank",{data[i][2]}),22)
		numLb:setAnchorPoint(ccp(0.5,0))
		numLb:setPosition(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-180-(i-1)*90)
		self.bgLayer:addChild(numLb,1)

		local desLb = GetTTFLabel(getlocal("promotion"),22)
		desLb:setAnchorPoint(ccp(0.5,0))
		desLb:setPosition(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-210-(i-1)*90)
		self.bgLayer:addChild(desLb,1)


		local orderId=GetTankOrderByTankId(data[i][1])
	    local sId = ( tankSkinVoApi and tankSkinVoApi:getEquipSkinByTankId(orderId) ) and tankSkinVoApi:getEquipSkinByTankId(orderId).."_" or ""
		local tankStr    = sId.."t"..orderId.."_1.png"
		local tankBarrel = sId.."t"..orderId.."_1_1.png"  --炮管 第6层
		for j=1,2 do
			local tankSp = CCSprite:createWithSpriteFrameName(tankStr)
			self.bgLayer:addChild(tankSp)
			tankSp:setScale(100/tankSp:getContentSize().width)

			local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
            if tankBarrelSP then
                tankBarrelSP:setPosition(ccp(tankSp:getContentSize().width*0.5,tankSp:getContentSize().height*0.5))
                tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
                tankSp:addChild(tankBarrelSP)
            end

			if j==1 then
				tankSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-170, self.bgLayer:getContentSize().height-220-(i-1)*90))
			else
				tankSp:setPosition(ccp(self.bgLayer:getContentSize().width/2+170, self.bgLayer:getContentSize().height-220-(i-1)*90))
				local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
				tankSp:addChild(pickedIcon)
				pickedIcon:setPosition(tankSp:getContentSize().width*0.7,tankSp:getContentSize().height*0.5-20)
				pickedIcon:setScale(tankSp:getContentSize().width/100)
			end
			

		end
	end
	


end