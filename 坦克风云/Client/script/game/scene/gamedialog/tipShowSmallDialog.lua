tipShowSmallDialog = smallDialog:new()

function tipShowSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function tipShowSmallDialog:showStrInfo(layerNum, istouch, isuseami, callBack, titleStr, textTab, textColorTab, textSize, textFormatTb, specialMark, speciaTb)
    local sd = tipShowSmallDialog:new()
    sd:initStrInfo(layerNum, istouch, isuseami, callBack, titleStr, textTab, textColorTab, textSize, textFormatTb, specialMark, speciaTb)
    return sd
end

function tipShowSmallDialog:initStrInfo(layerNum, istouch, isuseami, pCallBack, titleStr, textTab, textColorTab, textSize, textFormatTb, specialMark, speciaTb)
    self.isTouch = istouch
    self.isUseAmi = isuseami
    self.layerNum = layerNum
    local nameFontSize = 30
    
    if G_getCurChoseLanguage() == "ar" and specialMark == "ydcz" then
        nameFontSize = 20
    end
    
    base:removeFromNeedRefresh(self) --停止刷新
    
    local function tmpFunc()
    end
    local rrect = CCRect(0, 50, 1, 1)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        local function touchHandler()
            if pCallBack then
                pCallBack()
            end
            return self:close()
        end
        if self.tv then
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                touchHandler()
            end
        else
            touchHandler()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.7)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    local everyCellH = 170
    local jianGeH = 30
    local bgSize = CCSizeMake(560, 30 + jianGeH * 2)
    local textLbTb = {}
    local height = 10
    local subH = 10
    if titleStr == nil or titleStr == "" then
        bgSize.height = bgSize.height - 30
    end
    local textWidth = bgSize.width - 60
    local textHeightTb = {}
    for k, v in pairs(textTab) do
        local alignment, richFlag, colorTb, fontSize, ws, isBold, color = kCCTextAlignmentLeft, false, {}, (textSize or 25), nil, false
        if textFormatTb and textFormatTb[k] then
            alignment = textFormatTb[k].alignment or kCCTextAlignmentLeft
            richFlag = textFormatTb[k].richFlag or false
            colorTb = textFormatTb[k].richColor or {}
            if textFormatTb[k].fontSize then
                fontSize = textFormatTb[k].fontSize
            end
            ws = textFormatTb[k].ws
            isBold = textFormatTb[k].bold or false
            color = textFormatTb[k].color
        end
        local textlb
        -- print("richFlag----->",richFlag)
        if richFlag == true then
            textlb, textHeightTb[k] = G_getRichTextLabel(v, colorTb, fontSize, textWidth, alignment, kCCVerticalTextAlignmentTop)
        else
            local fontType = (isBold == true) and "Helvetica-bold" or nil
            textlb = GetTTFLabelWrap(v, fontSize, CCSize(textWidth, 0), alignment, kCCVerticalTextAlignmentTop, fontType)
            textHeightTb[k] = textlb:getContentSize().height
        end
        if textColorTab and richFlag == false then
            if textColorTab[k] ~= nil then
                textlb:setColor(textColorTab[k])
            else
                textlb:setColor(G_ColorWhite)
            end
        end
        if color then
            textlb:setColor(color)
        end
        textlb:setAnchorPoint(ccp(0, 1))
        if ws ~= nil then --行间距
            height = height + textHeightTb[k] + ws
        else
            height = height + textHeightTb[k] + subH
        end
        textLbTb[k] = textlb
    end
    local dialogHeight = height + 20
    local textTotalHeight = dialogHeight
    local maxHeight = 620
    if G_isIphone5() == true then
        maxHeight = 720
    end
    if dialogHeight > maxHeight then
        scrollFlag = true
        dialogHeight = maxHeight
    end
    bgSize.height = bgSize.height + dialogHeight
    -- rewardItem
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png", CCRect(30, 30, 1, 1), touchHandler)
    self.bgLayer = dialogBg
    -- self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    if specialMark == "xlpdOverShow" then
        self:showOverType(speciaTb.overType)
    elseif specialMark == "xlpd_upLvlStr" then
        self:showPdLvl()
    end
    -- 内容
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function ()end)
    dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 40, dialogHeight))
    dialogBg2:setAnchorPoint(ccp(0.5, 0))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width / 2, 30)
    self.bgLayer:addChild(dialogBg2)
    
    if textTotalHeight > dialogHeight then
        local cellHeight = height - 10
        local isMoved = false
        local function tvCallBack(handler, fn, idx, cel)
            if fn == "numberOfCellsInTableView" then
                return 1
            elseif fn == "tableCellSizeForIndex" then
                local tmpSize = CCSizeMake(textWidth, cellHeight)
                return tmpSize
            elseif fn == "tableCellAtIndex" then
                local cell = CCTableViewCell:new()
                cell:autorelease()
                
                local posY = cellHeight
                for k, v in pairs(textLbTb) do
                    local alignment, richFlag, ws = kCCTextAlignmentLeft, false
                    if textFormatTb and textFormatTb[k] then
                        alignment = textFormatTb[k].alignment or kCCTextAlignmentLeft
                        richFlag = textFormatTb[k].richFlag or false
                        ws = textFormatTb[k].ws
                    end
                    -- print("textHeightTb[k]---?",textHeightTb[k])
                    cell:addChild(v)
                    if alignment == kCCTextAlignmentCenter then
                        v:setPosition((dialogBg2:getContentSize().width - textWidth) / 2, posY)
                    else
                        v:setPosition(0, posY)
                    end
                    if ws ~= nil then
                        posY = posY - textHeightTb[k] - ws
                    else
                        posY = posY - textHeightTb[k] - subH
                    end
                end
                
                return cell
            elseif fn == "ccTouchBegan" then
                isMoved = false
                return true
            elseif fn == "ccTouchMoved" then
                isMoved = true
            elseif fn == "ccTouchEnded" then
                
            end
        end
        local hd = LuaEventHandler:createHandler(tvCallBack)
        self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(textWidth, dialogHeight - 20), nil)
        self.tv:setTableViewTouchPriority(-(layerNum - 1) * 20 - 3)
        self.tv:setPosition(ccp(10, 10))
        dialogBg2:addChild(self.tv, 2)
        self.tv:setMaxDisToBottomOrTop(120)
    else
        local startH = 20
        for k, v in pairs(textLbTb) do
            dialogBg2:addChild(v)
            local alignment, richFlag, ws = kCCTextAlignmentLeft, false
            if textFormatTb and textFormatTb[k] then
                alignment = textFormatTb[k].alignment or kCCTextAlignmentLeft
                richFlag = textFormatTb[k].richFlag or false
                ws = textFormatTb[k].ws
            end
            -- print("textHeightTb[k]---?",textHeightTb[k])
            if alignment == kCCTextAlignmentCenter then
                if SizeOfTable(textLbTb) == 1 then
                    v:setPosition((dialogBg2:getContentSize().width - textWidth) / 2, dialogBg2:getContentSize().height * 0.5 + textHeightTb[k] * 0.5)
                else
                    v:setPosition((dialogBg2:getContentSize().width - textWidth) / 2, dialogBg2:getContentSize().height - startH)
                end
            else
                v:setPosition(10, dialogBg2:getContentSize().height - startH)
            end
            if ws ~= nil then
                startH = startH + textHeightTb[k] + ws
            else
                startH = startH + textHeightTb[k] + subH
            end
        end
    end
    local lineSp1 = CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5, 1))
    lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(lineSp1)
    local lineSp2 = CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5, 0))
    lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width / 2, lineSp2:getContentSize().height))
    self.bgLayer:addChild(lineSp2)
    lineSp2:setRotation(180)
    
    -- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    -- self.bgLayer:addChild(pointSp1)
    -- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    -- self.bgLayer:addChild(pointSp2)
    -- 标题
    
    if titleStr and titleStr ~= "" then
        local lightSp = CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
        lightSp:setAnchorPoint(ccp(0.5, 0.5))
        lightSp:setPosition(self.bgLayer:getContentSize().width / 2, bgSize.height - 45)
        lightSp:setScaleX(3)
        self.bgLayer:addChild(lightSp)
        
        local nameLb = GetTTFLabelWrap(titleStr, nameFontSize, CCSizeMake(320, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom, "Helvetica-bold")
        nameLb:setAnchorPoint(ccp(0.5, 0.5))
        nameLb:setPosition(bgSize.width / 2, bgSize.height - 35)
        nameLb:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(nameLb)
        local nameLb2 = GetTTFLabel(titleStr, nameFontSize)
        local realNameW = nameLb2:getContentSize().width
        if realNameW > nameLb:getContentSize().width then
            realNameW = nameLb:getContentSize().width
        end
        for i = 1, 2 do
            local pointSp = CCSprite:createWithSpriteFrameName("newPointRect.png")
            local anchorX = 1
            local posX = bgSize.width / 2 - (realNameW / 2 + 20)
            local pointX = -7
            if i == 2 then
                anchorX = 0
                posX = bgSize.width / 2 + (realNameW / 2 + 20)
                pointX = 15
            end
            pointSp:setAnchorPoint(ccp(anchorX, 0.5))
            pointSp:setPosition(posX, nameLb:getPositionY())
            self.bgLayer:addChild(pointSp)
            local pointLineSp = CCSprite:createWithSpriteFrameName("newPointLine.png")
            pointLineSp:setAnchorPoint(ccp(0, 0.5))
            pointLineSp:setPosition(pointX, pointSp:getContentSize().height / 2)
            pointSp:addChild(pointLineSp)
            if i == 1 then
                pointLineSp:setRotation(180)
            end
        end
    end
    -- 下面的点击屏幕继续
    local clickLbPosy = -80
    local tmpLb = GetTTFLabel(getlocal("click_screen_continue"), 25)
    local clickLb = GetTTFLabelWrap(getlocal("click_screen_continue"), 25, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1, arrowPosx2
    local realWidth, maxWidth = tmpLb:getContentSize().width, clickLb:getContentSize().width
    if realWidth > maxWidth then
        arrowPosx1 = self.bgLayer:getContentSize().width / 2 - maxWidth / 2
        arrowPosx2 = self.bgLayer:getContentSize().width / 2 + maxWidth / 2
    else
        arrowPosx1 = self.bgLayer:getContentSize().width / 2 - realWidth / 2
        arrowPosx2 = self.bgLayer:getContentSize().width / 2 + realWidth / 2
    end
    local smallArrowSp1 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1 - 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1 - 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2 + 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2 + 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)
    
    local space = 20
    smallArrowSp1:runAction(G_actionArrow(1, space))
    smallArrowSp2:runAction(G_actionArrow(1, space))
    smallArrowSp3:runAction(G_actionArrow(-1, space))
    smallArrowSp4:runAction(G_actionArrow(-1, space))
    
    sceneGame:addChild(self.dialogLayer, layerNum)
    return self.dialogLayer
    
end

function tipShowSmallDialog:showPdLvl()
    local topPicStr = "rewardPanelSuccessBg.png"
    local topPicStr2 = "rewardPanelSuccessLight.png"
    local titleStr = getlocal("upgradeBuild")
    local G_ColorType = G_ColorYellowPro
    
    local titlePos = self.bgLayer:getContentSize().height + 40
    local tmpBg = CCSprite:createWithSpriteFrameName(topPicStr)
    
    local titleLb = GetTTFLabel(titleStr, 35)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, titlePos + 20))
    self.bgLayer:addChild(titleLb, 1)
    titleLb:setColor(G_ColorType)
    
    local titleBgWidth = titleLb:getContentSize().width + 260
    local originalWidth = tmpBg:getContentSize().width
    
    local rewardTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName(topPicStr, CCRect(originalWidth / 2, 20, 1, 1), function ()end)
    rewardTitleBg:setContentSize(CCSizeMake(titleBgWidth, tmpBg:getContentSize().height))
    rewardTitleBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, titlePos))
    self.bgLayer:addChild(rewardTitleBg)
    
    local rewardTitleLineSp = CCSprite:createWithSpriteFrameName(topPicStr2)
    rewardTitleLineSp:setPosition(ccp(self.bgLayer:getContentSize().width / 2, titlePos))
    self.bgLayer:addChild(rewardTitleLineSp)
end

function tipShowSmallDialog:showOverType(overType)
    local topPicStr = "rewardPanelSuccessBg.png"
    local topPicStr2 = "rewardPanelSuccessLight.png"
    local titleStr = getlocal("drawStr")
    local G_ColorType = G_ColorWhite
    
    if overType == 1 then
        titleStr = getlocal("fight_content_result_win")
        G_ColorType = G_ColorYellowPro
    elseif overType == 2 then
        topPicStr = "rewardPanelFailBg.png"
        topPicStr2 = "rewardPanelFailLight.png"
        titleStr = getlocal("fight_content_result_defeat")
        G_ColorType = G_ColorGray
    end
    
    local titlePos = self.bgLayer:getContentSize().height + 40
    local tmpBg = CCSprite:createWithSpriteFrameName(topPicStr)
    
    local titleLb = GetTTFLabel(titleStr, 35)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, titlePos + 20))
    self.bgLayer:addChild(titleLb, 1)
    titleLb:setColor(G_ColorType)
    
    local titleBgWidth = titleLb:getContentSize().width + 260
    local originalWidth = tmpBg:getContentSize().width
    
    local rewardTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName(topPicStr, CCRect(originalWidth / 2, 20, 1, 1), function ()end)
    rewardTitleBg:setContentSize(CCSizeMake(titleBgWidth, tmpBg:getContentSize().height))
    rewardTitleBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, titlePos))
    self.bgLayer:addChild(rewardTitleBg)
    
    local rewardTitleLineSp = CCSprite:createWithSpriteFrameName(topPicStr2)
    rewardTitleLineSp:setPosition(ccp(self.bgLayer:getContentSize().width / 2, titlePos))
    self.bgLayer:addChild(rewardTitleLineSp)
end

--多页签的文本显示
function tipShowSmallDialog:showMultiTabInfo(titleInfo, tabTb, textFormatTb, unified, layerNum)
    local sd = tipShowSmallDialog:new()
    sd:initMultiTabInfo(titleInfo, tabTb, textFormatTb, unified, layerNum)
end

function tipShowSmallDialog:initMultiTabInfo(titleInfo, tabTb, textFormatTb, unified, layerNum)
    self.isTouch, self.isUseAmi, self.layerNum = false, true, layerNum
    self.textFormatTb = textFormatTb --存储文本信息
    self.unified = {ft = 22, spacing = 5, align = kCCTextAlignmentLeft} --统一的文字显示标准 ft：字体大小，spacing：文字间距，align：对齐方式
    if unified then
        self.unified.ft = unified.ft or self.unified.ft
        self.unified.spacing = unified.spacing or self.unified.spacing
    end
    
    local function close()
        self.textFormatTb = {}
        self.textFormatTb = nil
        self.tvCellHeightTb = {}
        self.tvCellHeightTb = nil
        return self:close()
    end
    
    local dialogLayer = CCLayer:create()
    dialogLayer:setBSwallowsTouches(true)
    dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer = dialogLayer
    
    local size = CCSizeMake(600, 750)
    self.bgLayer = G_getNewDialogBg(size, titleInfo.text or "", titleInfo.ft or 25, function () end, self.layerNum, true, close, titleInfo.color or G_ColorYellowPro)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 1)
    self:show()
    
    self.tabIdx = 1
    
    self.tvCellNum = 0
    self.tvCellHeightTb = {}
    
    local function refresh()
        if self and self.tv and tolua.cast(self.tv, "LuaCCTableView") then
            self.tv:reloadData()
        end
    end
    local function tabClick(idx)
        self.tabIdx = idx
        refresh()
    end
    
    local multiTab = G_createMultiTabbed(tabTb, tabClick, "yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", nil, nil, 10)
    multiTab:setTabTouchPriority(-(self.layerNum - 1) * 20 - 4)
    multiTab:setTabPosition(16, size.height - 96 - 50)
    multiTab:setParent(self.bgLayer, 2)
    self.multiTab = multiTab
    
    self.multiTab:tabClick(self.tabIdx)
    
    local textWidth = size.width - 50
    
    local function getLb(idx, widx)
        local textTb = self.textFormatTb[idx] or {}
        local txtInfo = textTb[widx]
        if txtInfo == nil then
            return nil, nil
        end
        local alignment = txtInfo.align or self.unified.align
        local textLb, lbHeight
        if txtInfo.r == true then --是否使用富文本形式
            textLb, lbHeight = G_getRichTextLabel(txtInfo.text, txtInfo.color or {}, txtInfo.ft or self.unified.ft, textWidth, alignment, kCCVerticalTextAlignmentTop)
        else
            textLb = GetTTFLabelWrap(txtInfo.text, txtInfo.ft or self.unified.ft, CCSize(textWidth, 0), alignment, kCCVerticalTextAlignmentTop)
            textLb:setColor(txtInfo.color or G_ColorWhite)
            lbHeight = textLb:getContentSize().height
        end
        if alignment == kCCTextAlignmentLeft then
            textLb:setAnchorPoint(ccp(0, 1))
        else
            textLb:setAnchorPoint(ccp(0.5, 1))
        end
        return textLb, lbHeight
    end
    
    local function getHeight(idx)
        if self.tvCellHeightTb[idx] == nil then
            local height = 0
            local textLb, lbHeight = nil, 0
            local textTb = self.textFormatTb[idx] or {}
            for k, v in pairs(textTb) do
                textLb, lbHeight = getLb(idx, k)
                if textLb and lbHeight then
                    height = height + lbHeight + (k == 1 and 5 or (v.spacing or self.unified.spacing))
                end
            end
            self.tvCellHeightTb[idx] = height
        end
        return self.tvCellHeightTb[idx]
    end
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(size.width - 30, size.height - 96 - 50 - 20))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(ccp(size.width / 2, 20))
    self.bgLayer:addChild(tvBg, 1)
    
    local tvWidth, tvHeight = tvBg:getContentSize().width, tvBg:getContentSize().height - 6
    self.tv = G_createTableView(CCSizeMake(tvWidth, tvHeight), 1, function ()
        return CCSizeMake(tvBg:getContentSize().width, getHeight(self.tabIdx))
    end, function (cell, cellSize, idx, cellNum) --初始化文字
        local posX, posY = 10, getHeight(self.tabIdx)
        local textTb = self.textFormatTb[self.tabIdx] or {}
        for k, v in pairs(textTb) do
            local textLb, lbHeight = getLb(self.tabIdx, k)
            if textLb and lbHeight then
                local spacing = (k == 1 and 5 or (v.spacing or self.unified.spacing))
                local alignment = v.align or self.unified.align
                if alignment == kCCTextAlignmentLeft then
                    textLb:setPosition(posX, posY - spacing)
                else
                    textLb:setPosition(tvWidth / 2, posY - spacing)
                end
                cell:addChild(textLb)
                posY = posY - lbHeight - spacing
            end
        end
    end)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((size.width - tvWidth) / 2, tvBg:getPositionY() + 5))
    self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv, 2)
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(640, G_VisibleSizeHeight))
    touchDialogBg:setOpacity(255 * 0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)
    
    sceneGame:addChild(self.dialogLayer, layerNum)
    return self.dialogLayer
end
