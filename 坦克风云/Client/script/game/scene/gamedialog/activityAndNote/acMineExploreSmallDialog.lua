acMineExploreSmallDialog=smallDialog:new()

function acMineExploreSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.tv=nil
	return nc
end

--contentTb 每一项的奖励，tipStrTb 每一项奖励的提示文字
function acMineExploreSmallDialog:init(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler,addStr)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    local function touchHander()
    
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    local clayer=CCNode:create()
    clayer:setContentSize(CCSizeMake(size.width,1))
    self.bgLayer:addChild(clayer)

    local maxHeight=600
    local totalHeight=25
    local cellWidth=size.width-80
    local cellHeight=0
    local tvHeight=480
    local scrollFlag=true
    if title and title~="" then
        local titleLb=GetTTFLabelWrap(title,35,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0.5,1))
        titleLb:setPosition(ccp(size.width/2,-totalHeight))
        clayer:addChild(titleLb)
    end
    totalHeight=totalHeight+70
    if addStr and addStr~="" then
        local addStrLb=GetTTFLabelWrap(addStr,22,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        addStrLb:setAnchorPoint(ccp(0.5,1))
        addStrLb:setPosition(ccp(size.width/2,-totalHeight))
        addStrLb:setColor(G_ColorYellowPro)
        clayer:addChild(addStrLb)
        totalHeight=totalHeight+addStrLb:getContentSize().height+10
    end
    local count=SizeOfTable(contentTb)
    local propSize=100
    local spaceX,spaceY=20,20
    for k,content in pairs(contentTb) do
        local count=SizeOfTable(content)
        if count%4>0 then
            count=math.floor(count/4)+1
        else
            count=math.floor(count/4)
        end
        cellHeight=cellHeight+count*propSize+(count-1)*spaceY+70
    end
    if cellHeight<tvHeight then
        tvHeight=cellHeight
        scrollFlag=false
    end
    local tvPosY=-totalHeight-tvHeight
    totalHeight=totalHeight+tvHeight

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

            local posX=cellWidth/2
            local posY=cellHeight
            for k,content in pairs(contentTb) do
                local tipTb=tipStrTb[k]
                local tipBg,tipLb=self:addTipLb(cell,CCSizeMake(cellWidth,cellHeight),ccp(posX,posY-25),tipTb)
                posY=posY-55
                local count=SizeOfTable(content)
                local firstPosX=0
                if count<=4 then
                    firstPosX=(cellWidth-(count*propSize+(count-1)*spaceX))/2
                else
                    firstPosX=(cellWidth-(4*propSize+3*spaceX))/2
                end
                for kk,item in pairs(content) do
                    local px=firstPosX+(kk-1)%4*(spaceX+propSize)
                    local py=posY-math.floor((kk-1)/4)*(propSize+spaceY)
                    local icon,scale=G_getItemIcon(item,propSize,true,layerNum+1,nil,self.tv,nil,nil,nil,nil,true)
                    if icon then
                        icon:setTouchPriority(-(layerNum-1)*20-2)
                        icon:setAnchorPoint(ccp(0,1))
                        icon:setPosition(ccp(px,py))
                        cell:addChild(icon,1)
                        local numLb=GetTTFLabel(FormatNumber(item.num),25)
                        numLb:setAnchorPoint(ccp(1,0))
                        numLb:setScale(1/scale)
                        numLb:setPosition(ccp(icon:getContentSize().width-5,0))
                        icon:addChild(numLb,4)
                        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                        numBg:setAnchorPoint(ccp(1,0))
                        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                        numBg:setOpacity(150)
                        icon:addChild(numBg,3)
                    end
                end
                if count%4>0 then
                    count=math.floor(count/4)+1
                else
                    count=math.floor(count/4)
                end
                posY=posY-count*propSize-(count-1)*spaceY-15
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
    self.tv:setPosition(ccp(40,tvPosY))
    clayer:addChild(self.tv)
    if scrollFlag==true then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    totalHeight=totalHeight+110
    size=CCSizeMake(size.width,totalHeight)
    self.bgLayer:setContentSize(size)
    self.bgSize=size
    --确定
    local function confirmHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callBackHandler then
            callBackHandler()
        end
        self:close()
    end
    self.sureBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",confirmHandler,1,getlocal("ok"),25,11)
    local sureMenu=CCMenu:createWithItem(self.sureBtn);
    sureMenu:setPosition(ccp(size.width/2,tvPosY-55))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
    clayer:addChild(sureMenu)
    clayer:setPosition(ccp(0,size.height))

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function acMineExploreSmallDialog:addTipLb(dialogBg,size,pos,tipStrTb)
    local posX2 = 40
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        posX2 = 80
        strSize2 = 25
    end
    if tipStrTb and tipStrTb[1] then
        local tipBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
        tipBg:setScaleY(50/tipBg:getContentSize().height)
        tipBg:setScaleX(3)
        tipBg:setPosition(ccp(pos.x+20,pos.y))
        dialogBg:addChild(tipBg)
        local leftLineSP1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        leftLineSP1:setFlipX(true)
        leftLineSP1:setPosition(ccp(posX2,tipBg:getPositionY()))
        dialogBg:addChild(leftLineSP1,1)
        local rightLineSP1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        rightLineSP1:setPosition(ccp(size.width-posX2,tipBg:getPositionY()))
        dialogBg:addChild(rightLineSP1,1)
        local descLb=GetTTFLabelWrap(tipStrTb[1],strSize2,CCSizeMake(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0.5,0.5))
        descLb:setPosition(pos)
        dialogBg:addChild(descLb,1)
        local color=tipStrTb[2]
        if color then
            descLb:setColor(color)
        end
        return tipBg,descLb
    end
    return nil,nil
end

function acMineExploreSmallDialog:dispose()
	self.tv=nil
end
