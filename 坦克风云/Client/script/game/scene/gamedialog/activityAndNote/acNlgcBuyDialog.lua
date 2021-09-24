acNlgcBuyDialog = smallDialog:new()

function acNlgcBuyDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acNlgcBuyDialog:init(layerNum, callback, minNum, maxNum, price, diamondRatio, maxDK)
    self.layerNum = layerNum
    self.isTouch = false
    self.isUseAmi = true
    self.callback = callback
    self.dkNum = 0
    
    self.bgSize = CCSizeMake(580, 360)
    local dialogBg = G_getNewDialogBg2(self.bgSize, layerNum, nil, getlocal("buy"), 28, nil, "Helvetica-bold")
    self.dialogLayer = CCLayer:create()
    dialogBg:setTouchPriority(-(layerNum - 1) * 20 - 2)
    self.dialogLayer:setBSwallowsTouches(true);
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    
    -- 背景遮罩
    local function touchLuaSpr()
        self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1);
    sceneGame:addChild(self.dialogLayer, layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
    self.dialogLayer:addChild(self.bgLayer, 2);
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    local visibleSizeHeight = self.bgLayer:getContentSize().height - 40
    local visibleSizeWidth = self.bgLayer:getContentSize().width
    
    self.curBuyNum = minNum
    self.maxNum = maxNum
    local function sliderTouch(handler, object)
        local count = math.floor(object:getValue())
        if self and self.eLb then
            self.curBuyNum = count
            self.dkNum = math.min(maxDK, count * diamondRatio)
            self.eLb:setString(getlocal("ac_nlgc_lab7", {count, self.dkNum}))
            self.costLb:setString(getlocal("ac_nlgc_costgems", {price - self.dkNum}))
        end
    end
    local spBg = CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
    local spPr = CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
    local spPr1 = CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
    local slider = LuaCCControlSlider:create(spBg, spPr, spPr1, sliderTouch);
    slider:setTouchPriority(-(self.layerNum - 1) * 20 - 22);
    slider:setIsSallow(true);
    slider:setAnchorPoint(ccp(0.5, 0.5))
    slider:setMinimumValue(minNum);
    slider:setMaximumValue(self.maxNum);
    slider:setValue(minNum);
    slider:setPosition(ccp(self.bgSize.width * 0.5, 155))
    self.bgLayer:addChild(slider, 2)
    
    local function touchAdd()
        slider:setValue(slider:getValue() + 1);
    end
    
    local function touchMinus()
        if slider:getValue() - 1 > 0 then
            slider:setValue(slider:getValue() - 1);
        end
    end
    
    local dx = slider:getPositionX()
    local dy = slider:getPositionY()
    local dw = slider:getContentSize().width
    local dh = slider:getContentSize().height
    
    local minusSp = LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png", touchMinus)
    minusSp:setPosition(dx - dw * 0.5 - 15, dy)
    minusSp:setAnchorPoint(ccp(1, 0.5))
    self.bgLayer:addChild(minusSp)
    minusSp:setTouchPriority(-(self.layerNum - 1) * 20 - 23);
    
    local addSp = LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png", touchAdd)
    addSp:setPosition(ccp(dx + dw * 0.5 + 15, dy))
    addSp:setAnchorPoint(ccp(0, 0.5))
    self.bgLayer:addChild(addSp)
    addSp:setTouchPriority(-(self.layerNum - 1) * 20 - 23);
    
    local function sureFun()
        if self.callback then
            self.callback(self.curBuyNum, self.dkNum)
        end
        self:close()
    end
    local btnItem2 = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", sureFun, 2, getlocal("buy"), 25)
    btnItem2:setAnchorPoint(ccp(0.5, 0))
    self.sureBtn = btnItem2
    local btn2 = CCMenu:createWithItem(btnItem2);
    btn2:setTouchPriority(-(self.layerNum - 1) * 20 - 22);
    btn2:setPosition(ccp(self.bgSize.width * 0.5, 10))
    self.bgLayer:addChild(btn2)
    
    local eLb = GetTTFLabelWrap(getlocal("ac_nlgc_lab7", {minNum, minNum * diamondRatio}), G_getLS(22, 18), CCSize(500, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    eLb:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:addChild(eLb)
    eLb:setPosition(ccp(visibleSizeWidth * 0.5, 260))
    self.eLb = eLb
    
    local dkLb = GetTTFLabelWrap(getlocal("ac_nlgc_lab9", {maxDK}), G_getLS(22, 18), CCSize(500, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    dkLb:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:addChild(dkLb)
    dkLb:setPosition(ccp(visibleSizeWidth * 0.5, 210))
    dkLb:setColor(G_ColorGreen)
    
    local costLb = GetTTFLabelWrap(getlocal("ac_nlgc_costgems", {price - minNum * diamondRatio}), 22, CCSize(500, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    costLb:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:addChild(costLb)
    costLb:setPosition(ccp(visibleSizeWidth * 0.5, 100))
    self.costLb = costLb
end
