-- @Author hj
-- @Description 多项目的奖励展示板子
-- @Date 2018-07-02

-- warning!单个奖励多于6个不适合采用本板子，需要自己另加tableview滑动

rewardMultiShowSmallDialog=smallDialog:new()

function rewardMultiShowSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function rewardMultiShowSmallDialog:showNewReward(layerNum,istouch,isuseami,content,callBack,titleStr)
	local sd=rewardMultiShowSmallDialog:new()
    sd:initNewReward(layerNum,istouch,isuseami,content,callBack,titleStr)
    return sd
end

function rewardMultiShowSmallDialog:initNewReward(layerNum,istouch,isuseami,content,pCallBack,titleStr)
	
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.rewardItem = rewardItem
    self.addStrTb2 = addStrTb2
    self.addStrTb = addStrTb
    self.content=content
    self.cellHeightTb={}
   
    base:removeFromNeedRefresh(self) 
    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

  	local function touchLuaSpr()
         if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if pCallBack then
        	pCallBack()
        end
        return self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
	
	local dialogBgWidth,dialogBgHeight = 560,60
    local maxTvHeight = 600
    self.iconWidth,self.nameFontSize,self.titleFontSize,self.titleWidth,self.nameWidth = 100,18,22,500,140
    self.tvWidth,self.tvHeight=dialogBgWidth-30,maxTvHeight
    self.cellNum=SizeOfTable(self.content)
    if G_isAsia() == false then
        self.titleFontSize = 18
    end
    local tvContentHeight = 0
	for k=1,self.cellNum do
        tvContentHeight=tvContentHeight+self:getCellHeight(k)
    end
    if tvContentHeight<self.tvHeight then
        self.tvHeight=tvContentHeight
    end
    dialogBgHeight=dialogBgHeight+self.tvHeight

    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setContentSize(CCSizeMake(dialogBgWidth,dialogBgHeight))
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
    self.bgLayer:addChild(lineSp2)
    lineSp2:setRotation(180)

    -- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    -- self.bgLayer:addChild(pointSp1)
    -- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    -- self.bgLayer:addChild(pointSp2)

    -- 标题
    local titlePos=self.bgLayer:getContentSize().height+40
    local titleLb = GetTTFLabel(titleStr,35)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos+20))
    self.bgLayer:addChild(titleLb,1)
    titleLb:setColor(G_ColorYellow)
    local tmpBg=CCSprite:createWithSpriteFrameName("rewardPanelSuccessBg.png")
    local originalWidth=tmpBg:getContentSize().width
    local titleBgWidth=titleLb:getContentSize().width+260
    if titleBgWidth<originalWidth then
        titleBgWidth=originalWidth
    end
    if titleBgWidth>(G_VisibleSizeWidth) then
        titleBgWidth=G_VisibleSizeWidth
    end
	local rewardTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelSuccessBg.png",CCRect(originalWidth/2, 20, 1, 1),function ()end)
	rewardTitleBg:setContentSize(CCSizeMake(titleBgWidth,tmpBg:getContentSize().height))
	rewardTitleBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos))
	self.bgLayer:addChild(rewardTitleBg)
	local rewardTitleLineSp=CCSprite:createWithSpriteFrameName("rewardPanelSuccessLight.png")
	rewardTitleLineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos))
	self.bgLayer:addChild(rewardTitleLineSp)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp((dialogBgWidth-self.tvWidth)/2,30))
    self.bgLayer:addChild(self.tv,3)
    if tvContentHeight>self.tvHeight then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end

	local clickLbPosy=-80
    local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
    local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1,arrowPosx2
    local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
    if realWidth>maxWidth then
        arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
    else
        arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
    end
    local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)

    local space=20
    smallArrowSp1:runAction(G_actionArrow(1,space))
    smallArrowSp2:runAction(G_actionArrow(1,space))
    smallArrowSp3:runAction(G_actionArrow(-1,space))
    smallArrowSp4:runAction(G_actionArrow(-1,space))

    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function rewardMultiShowSmallDialog:getCellHeight(idx)
    if self.cellHeightTb[idx]==nil then
        local height = 0
        local item=self.content[idx]
        if item.title then
            local subtitleLb = GetTTFLabelWrap(item.title,self.titleFontSize,CCSizeMake(self.titleWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            height=height+subtitleLb:getContentSize().height+10
            height=height+20
            local row = math.ceil(SizeOfTable(item.reward)/3)
            for k=1,row do
                local rh = 0
                for m=1,3 do
                    local ridx = (k-1)*3+m
                    local reward = item.reward[ridx]
                    if reward then
                        local nameLb=GetTTFLabelWrap(reward.name,self.nameFontSize,CCSizeMake(self.nameWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                        local tempH=nameLb:getContentSize().height+5
                        if reward.pointDesc then
                            local extraLb = GetTTFLabelWrap(reward.pointDesc,self.nameFontSize-1,CCSizeMake(self.nameWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                            tempH=tempH+extraLb:getContentSize().height+5
                        end
                        if tempH>rh then
                            rh=tempH
                        end
                    end
                end
                height=height+rh+self.iconWidth + 10
            end
        end
        self.cellHeightTb[idx]=height
    end
    return self.cellHeightTb[idx]
end

function rewardMultiShowSmallDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.tvWidth,self:getCellHeight(idx+1))
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth,cellHeight = self.tvWidth,self:getCellHeight(idx+1)
        local rewardBgHeight = cellHeight
        local posY = cellHeight
        local item = self.content[idx+1]
        if item.title then
            local subtitleLb = GetTTFLabelWrap(item.title,self.titleFontSize,CCSizeMake(self.titleWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            subtitleLb:setAnchorPoint(ccp(0,1))
            subtitleLb:setPosition(ccp(20,posY-5))
            cell:addChild(subtitleLb)
            rewardBgHeight = rewardBgHeight - subtitleLb:getContentSize().height - 10
            posY=subtitleLb:getPositionY()-subtitleLb:getContentSize().height - 5
        end

        local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
        rewardBg:setAnchorPoint(ccp(0.5,1))
        rewardBg:setContentSize(CCSizeMake(cellWidth,rewardBgHeight))
        rewardBg:setPosition(ccp(cellWidth/2,posY))
        cell:addChild(rewardBg)

        posY = posY - 10

        local rc=SizeOfTable(item.reward)
        local pading = 60
        local leftPosX = (cellWidth-3*self.iconWidth-2*pading)/2
        local row = math.ceil(SizeOfTable(item.reward)/3)
        for k=1,row do
            local rh = 0
            for m=1,3 do
                local ridx = (k-1)*3+m
                local reward = item.reward[ridx]
                if reward then
                    local function showNewPropInfo()
                        G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
                    end
                    local icon
                    if item.type == "se" then
                        icon=G_getItemIcon(reward,100,true,self.layerNum,nil,nil,nil,nil,nil,nil,true)
                    else
                        icon=G_getItemIcon(reward,100,false,self.layerNum,showNewPropInfo,nil)
                    end
                    icon:setTouchPriority(-(self.layerNum-1)*20-3)
                    icon:setScale(self.iconWidth/icon:getContentSize().width)
                    cell:addChild(icon)
                    if rc == 2 then
                        icon:setPosition(ccp(cellWidth/2+85*(-1)^m,posY-self.iconWidth/2))
                    elseif rc == 1 then
                        icon:setPosition(ccp(cellWidth/2,posY-self.iconWidth/2))
                    else
                        icon:setPosition(leftPosX+(2*m-1)*self.iconWidth/2+pading*(m-1),posY-self.iconWidth/2)
                    end

                    local nameLb=GetTTFLabelWrap(reward.name,self.nameFontSize,CCSizeMake(self.nameWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                    nameLb:setAnchorPoint(ccp(0.5,1))
                    nameLb:setPosition(icon:getPositionX(),icon:getPositionY()-self.iconWidth/2-5)
                    cell:addChild(nameLb)

                    local tempH = nameLb:getContentSize().height+5

                    local numLb=GetTTFLabel(FormatNumber(reward.num),20)
                    numLb:setAnchorPoint(ccp(1,0))
                    numLb:setPosition(ccp(icon:getPositionX()+self.iconWidth/2-5,icon:getPositionY()-self.iconWidth/2+5))
                    cell:addChild(numLb,2)

                    local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                    numBg:setAnchorPoint(ccp(1,0))
                    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                    numBg:setPosition(numLb:getPosition())
                    numBg:setOpacity(150)
                    cell:addChild(numBg)

                    if reward.pointDesc then
                        local extraLb = GetTTFLabelWrap(reward.pointDesc,self.nameFontSize-1,CCSizeMake(self.nameWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                        extraLb:setColor(G_ColorYellow)
                        extraLb:setAnchorPoint(ccp(0.5,1))
                        extraLb:setPosition(nameLb:getPositionX(),nameLb:getPositionY()-nameLb:getContentSize().height-5)
                        cell:addChild(extraLb)
                        tempH = tempH+extraLb:getContentSize().height+5
                    end
                    if tempH>rh then
                        rh=tempH
                    end
                end
            end
            posY=posY-self.iconWidth-rh-20
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

function rewardMultiShowSmallDialog:dispose()
    self.content=nil
    self.iconWidth,self.nameFontSize,self.titleFontSize,self.titleWidth,self.nameWidth = nil,nil,nil,nil,nil
    self.tvWidth,self.tvHeight=nil,nil
    self.cellNum=nil
end