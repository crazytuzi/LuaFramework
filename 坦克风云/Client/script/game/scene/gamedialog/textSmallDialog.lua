textSmallDialog=smallDialog:new()

function textSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function textSmallDialog:showTextDialog(bgSrc,size,inRect,title,textlist,isuseami,isTouch,layerNum,callBackHandler)
    local sd=textSmallDialog:new()
    sd:initTextDialog(bgSrc,size,inRect,title,textlist,isuseami,isTouch,layerNum,callBackHandler)
end

function textSmallDialog:initTextDialog(bgSrc,size,inRect,title,textlist,isuseami,isTouch,layerNum,callBackHandler)
    self.isTouch=isTouch
    self.isUseAmi=isuseami
    local function tmpFunc()
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self:show()

    -- local txtLayer=CCNode:create()
    -- txtLayer:setContentSize(CCSizeMake(size.width,1))
    -- self.bgLayer:addChild(txtLayer)

    local totalHeight=30
    local titleLb
    if title then
        local titleStr=title[1]
        local color=title[2] or G_ColorWhite
        local tsize=title[3] or 28
        if titleStr then
            titleLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            titleLb:setAnchorPoint(ccp(0.5,1))
            titleLb:setColor(color)
            self.bgLayer:addChild(titleLb)
            totalHeight=totalHeight+titleLb:getContentSize().height+20
        end
    end

    local cellWidth=size.width-40
    local cellHeight=0
    for k,text in pairs(textlist) do
        local str=text[1]
        local tsize=text[3] or 25
        local alignment=text[4] or kCCTextAlignmentLeft
        local space=text[5] or 0
        if str then
            local txtLb=GetTTFLabelWrap(str,tsize,CCSizeMake(cellWidth,0),alignment,kCCVerticalTextAlignmentCenter)
            local txtHeight=txtLb:getContentSize().height
            cellHeight=cellHeight+txtHeight
        end
        cellHeight=cellHeight+space
    end
    local scrollFlag=false
    local tvHeight=cellHeight
    local maxTvH=620
    if G_isIphone5()==true then
        maxTvH=720
    end
    if tvHeight>maxTvH then
        tvHeight=maxTvH
        scrollFlag=true
    end
    totalHeight=totalHeight+tvHeight+30
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local posY=cellHeight
            for k,text in pairs(textlist) do
                local str=text[1]
                local color=text[2] or G_ColorWhite
                local tsize=text[3] or 25
                local alignment=text[4] or kCCTextAlignmentLeft
                local space=text[5] or 0
                if str then
                    local txtLb=GetTTFLabelWrap(str,tsize,CCSizeMake(cellWidth,0),alignment,kCCVerticalTextAlignmentCenter)
                    txtLb:setAnchorPoint(ccp(0,1))
                    txtLb:setPosition(ccp(0,posY-space))
                    txtLb:setColor(color)
                    cell:addChild(txtLb)
                    local txtHeight=txtLb:getContentSize().height
                    posY=posY-txtHeight-space
                end
            end
            
            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,30))
    self.bgLayer:addChild(self.tv,2)
    if scrollFlag==true then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    size=CCSizeMake(size.width,totalHeight)
    self.bgLayer:setContentSize(size)
    if titleLb then
        titleLb:setPosition(ccp(size.width/2,totalHeight-30))
    end

    local function touchDialog()
        if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if self.isTouch~=nil then
                self:close()
            end
        end
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    sceneGame:addChild(self.dialogLayer,layerNum)

    return self.dialogLayer
end