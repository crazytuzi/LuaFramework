-- 显示属性的小板子
attributeStarSmallDialog=smallDialog:new()

function attributeStarSmallDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	return nc
end	

function attributeStarSmallDialog:init(detailTb,addStr)

	self.isUseAmi = false
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0)) 

    local height = 120
    height = #detailTb*140

    if addStr then
    	height = height + 70
    end

    local function closeCallBack( ... )
    	self:close()
    end

    local titleStr = getlocal("decorateSmallTitle")
    local titleSize = 30

    --采用新式小板子
	local dialogBg = G_getNewDialogBg(CCSizeMake(550,height),titleStr,titleSize,nil,self.layerNum,true,closeCallBack)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(CCSizeMake(550,height))
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

     --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    for k,v in pairs(detailTb) do
    	local adaW = 0
    	if G_getCurChoseLanguage() == "ar" then
    		adaW = 80
 		end
    	if v.nowLevel ~= 0 then
			local valueStr = v.value[v.nowLevel] < 1 and tostring(v.value[v.nowLevel]*100).."%" or v.value[v.nowLevel]
			local adaWidth = 0
			if v.type == 5 then
				valueStr = math.floor(valueStr/60)
				adaWidth = 100
			end
			local attstr = "+"..valueStr
			if v.type == 9 then --受到戏谑攻击 
				attstr = getlocal("text_zerobattleDamage")
			end
			if type(v.experienceTimer) == "number" and v.experienceTimer > 0 then --体验皮肤
				attstr = "+0"
			end
			local attrLabel = GetTTFLabelWrap(getlocal("decorateAttr"..v.type),20,CCSizeMake(220+adaWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			local valueLabel = GetTTFLabelWrap(attstr,20,CCSizeMake(70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			attrLabel:setAnchorPoint(ccp(0.5,0.5))
			valueLabel:setAnchorPoint(ccp(0,0.5))
			attrLabel:addChild(valueLabel)
			valueLabel:setPosition(ccp(attrLabel:getContentSize().width,attrLabel:getContentSize().height/2))
			self.bgLayer:addChild(attrLabel)
			attrLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2-adaW,self.bgLayer:getContentSize().height-80-100*(k-1)))
			attrLabel:setColor(G_ColorGreen)
			valueLabel:setColor(G_ColorGreen)
			if v.type == 9 and G_isGermany() == true then --德国不显示戏谑技能
				attrLabel:setVisible(false)
				valueLabel:setVisible(false)
			end
		else
			local adaWidth = 0
			if v.type == 5 then
				adaWidth = 100
			end
			local tipLabel = GetTTFLabelWrap(getlocal("decorateAttr"..v.type),20,CCSizeMake(220+adaWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			tipLabel:setColor(G_ColorGreen)
			self.bgLayer:addChild(tipLabel)
			tipLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2-adaW,self.bgLayer:getContentSize().height-80-100*(k-1)))	
		end

    	local backSpire = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
		backSpire:setContentSize(CCSizeMake(60*v.lvMax,40))
		backSpire:setAnchorPoint(ccp(0.5,1))
		backSpire:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-100-100*(k-1)))
		backSpire:setOpacity(0)
		self.bgLayer:addChild(backSpire)
		for i=1,v.lvMax do
			local starSp
			if i <= v.nowLevel then
				starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
			else
				starSp = CCSprite:createWithSpriteFrameName("starIconEmpty.png")
				local valueStr = v.value[i] < 1 and tostring(v.value[i]*100).."%" or v.value[i]
				if v.type == 5 then
					valueStr = math.floor(valueStr/60)
				end
				valueStr = "+"..valueStr
				local attrLabel = GetTTFLabel(valueStr,20,true)
				attrLabel:setAnchorPoint(ccp(0.5,0.5))
				attrLabel:setPosition(ccp(18,18))
				attrLabel:setScale(0.6)
				starSp:addChild(attrLabel)
			end
			starSp:setAnchorPoint(ccp(0,0.5))
			starSp:setPosition(ccp(2+60*(i-1),20))
			starSp:setScale(1.4)
			backSpire:addChild(starSp)
		end
		local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
	    lineSp:setAnchorPoint(ccp(0.5,0))
	    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-60-100*k))
	    lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,2))
	    self.bgLayer:addChild(lineSp)
    end

    if addStr then
    	local strSize = 20
    	local descLb 

    	if G_isAsia() == false or G_getCurChoseLanguage() == "ko" then
    		strSize = 17
    		descLb = GetTTFLabelWrap(addStr,strSize,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    	else
    		descLb = GetTTFLabel(addStr,strSize,true)
    	end

    	descLb:setAnchorPoint(ccp(0.5,0.5))
    	descLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-100*#detailTb-95))
    	self.bgLayer:addChild(descLb)
    end

end