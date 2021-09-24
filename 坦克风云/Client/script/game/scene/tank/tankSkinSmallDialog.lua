tankSkinSmallDialog = smallDialog:new()

function tankSkinSmallDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    return nc
end

function tankSkinSmallDialog:showSkinAttributeOverviewDialog(skinId, layerNum)
    local sd = tankSkinSmallDialog:new()
    sd:initSkinAttributeOverviewDialog(skinId, layerNum)
end

function tankSkinSmallDialog:initSkinAttributeOverviewDialog(skinId, layerNum)
    self.isUseAmi = true
    self.layerNum = layerNum
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
    
    local cfg = tankSkinCfg.skinCfg[skinId]
    local skinVo = tankSkinVoApi:getSkinById(skinId)
    local skinLv = skinVo and skinVo.lv or 0
    local maxLv = cfg.lvMax
    local attriTb = tankSkinVoApi:getAttributeBySkinId(skinId, skinLv)
    local attriNum = SizeOfTable(attriTb)
    
    local starWidth = 50
    local height = 90
    height = height + attriNum * (math.ceil(maxLv / 5) * starWidth + (math.ceil(maxLv / 5) - 1) * 10) + attriNum * 70
    
    local function closeCallBack(...)
        self:close()
    end
    
    local titleStr = getlocal("decorateSmallTitle")
    local titleSize = 30
    
    --采用新式小板子
    local dialogBg = G_getNewDialogBg(CCSizeMake(550, height), titleStr, titleSize, nil, self.layerNum, true, closeCallBack)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(CCSizeMake(550, height))
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    local attriFontSize, attriFontWidth, smallFontSize = 22, 320, 20
    local leftPosX, rightPosX, lbposY = 60, self.bgLayer:getContentSize().width - 100, height - 65
    local leftStarPosX = 80
    local starOffx, starOffy = (self.bgLayer:getContentSize().width - 2 * leftStarPosX - 5 * starWidth) / 4, 10
    local attriKeys = G_clone(cfg.attType)
    if cfg.restrain and cfg.restrain > 0 then --有克制关系
        table.insert(attriKeys, "restrain")
    end
    
    local posY = lbposY
    for k, v in pairs(attriKeys) do
        posY = posY - 10
        local attriNameStr = ""
        if v == "restrain" then
            attriNameStr = tankSkinVoApi:getAttributeNameStr(v, cfg.restrain)
        else
            attriNameStr = tankSkinVoApi:getAttributeNameStr(v)
        end
        local attriLb = GetTTFLabelWrap(attriNameStr, attriFontSize, CCSizeMake(attriFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        attriLb:setAnchorPoint(ccp(0, 0.5))
        attriLb:setPosition(leftPosX, posY - attriLb:getContentSize().height / 2)
        attriLb:setColor(G_ColorGreen)
        self.bgLayer:addChild(attriLb)
        
        local valueSuffix = ""
        if v ~= "first" and v ~= "antifirst" then
            valueSuffix = "%"
        end
        local attstr = "+" .. (attriTb[v] or 0) .. valueSuffix
        local valueLabel = GetTTFLabelWrap(attstr, attriFontSize, CCSizeMake(70, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        valueLabel:setAnchorPoint(ccp(0, 0.5))
        valueLabel:setPosition(rightPosX, attriLb:getPositionY())
        valueLabel:setColor(G_ColorGreen)
        self.bgLayer:addChild(valueLabel)
        
        posY = posY - attriLb:getContentSize().height - 10
        
        for k = 1, maxLv do
            local starSp
            if k <= skinLv then
                starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
            else
                starSp = CCSprite:createWithSpriteFrameName("starIconEmpty.png")
                local attriTb = tankSkinVoApi:getAttributeBySkinId(skinId, k)
                local valueStr = attriTb[v] or 0
                valueStr = "+"..valueStr..valueSuffix
                local attrLabel = GetTTFLabel(valueStr, smallFontSize, true)
                attrLabel:setAnchorPoint(ccp(0.5, 0.5))
                attrLabel:setScale(0.6)
                attrLabel:setPosition(getCenterPoint(starSp))
                starSp:addChild(attrLabel)
            end
            starSp:setScale(starWidth / starSp:getContentSize().width)
            starSp:setAnchorPoint(ccp(0, 0.5))
            local starPosX = leftStarPosX + math.floor((k - 1) % 5) * (starWidth + starOffx)
            local starPosY = posY - starWidth / 2 - math.floor((k - 1) / 5) * (starWidth + starOffy)
            starSp:setPosition(starPosX, starPosY)
            self.bgLayer:addChild(starSp)
        end
        
        posY = posY - math.ceil(maxLv / 5) * starWidth - (math.ceil(maxLv / 5) - 1) * starOffy - 10
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
        lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 36, 2))
        lineSp:setPosition(ccp(self.bgLayer:getContentSize().width / 2, posY))
        self.bgLayer:addChild(lineSp)
        
        posY = posY - 2
    end
end
