propListShowSmallDialog=smallDialog:new()

function propListShowSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function propListShowSmallDialog:showListProp(layerNum,istouch,isuseami,callBack,titleStr,listDes,propList)
	local sd=propListShowSmallDialog:new()
    sd:initPropList(layerNum,istouch,isuseami,callBack,titleStr,listDes,propList)
    return sd
end

function propListShowSmallDialog:initPropList(layerNum,istouch,isuseami,pCallBack,titleStr,listDes,propList)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    local nameFontSize=30


    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
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
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                touchHandler()
            end
        else
            touchHandler()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local cellHeight=120
    local jianGeH=30
    local bgSize=CCSizeMake(560,30+jianGeH*2)
    local listDesLb
    if listDes then
        listDesLb=GetTTFLabelWrap(listDes,22,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        listDesLb:setAnchorPoint(ccp(0,1))
        bgSize.height=bgSize.height+listDesLb:getContentSize().height+10
    end

    local num=#propList
    local showNum=0
    if num<4 then
        showNum=num
    else
        showNum=4
    end
    local tvHeight=showNum*cellHeight
    bgSize.height=bgSize.height+tvHeight+10

    -- rewardItem
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)


    -- 标题
    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setScaleX(3)
    lightSp:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-50)
    self.bgLayer:addChild(lightSp)

    local nameLb=GetTTFLabelWrap(titleStr,nameFontSize,CCSizeMake(320,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    nameLb:setAnchorPoint(ccp(0.5,0.5))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(bgSize.width/2,bgSize.height-40)
    self.bgLayer:addChild(nameLb)

    if listDesLb then
        listDesLb:setPosition(20,bgSize.height-65)
        self.bgLayer:addChild(listDesLb)
    end

   
    -- -- 内容
    local cellWidth=self.bgLayer:getContentSize().width-70
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(19,19,2,2),function ()end)
    dialogBg2:setContentSize(CCSizeMake(cellWidth,tvHeight+10))
    dialogBg2:setAnchorPoint(ccp(0.5,0))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,25)
    self.bgLayer:addChild(dialogBg2)

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return #propList
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local award=propList[idx+1]
            local function showNewPropInfo()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,award)
                return false
            end
            local icon=G_getItemIcon(award,100,true,self.layerNum,showNewPropInfo)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            icon:setPosition(70,cellHeight/2)
            cell:addChild(icon,1)

            local nameLb=GetTTFLabelWrap(award.name,25,CCSizeMake(cellWidth-100-40-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            cell:addChild(nameLb)
            nameLb:setAnchorPoint(ccp(0,0.5))
            nameLb:setPosition(130,cellHeight/2+25)

            local numLb = GetTTFLabel("x"..award.num,25)
            numLb:setAnchorPoint(ccp(0,0.5))
            numLb:setPosition(130,cellHeight/2-25)
            numLb:setAnchorPoint(ccp(0,0.5))
            cell:addChild(numLb)

            if idx+1~=#propList then
                local newLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
                newLineSp:setContentSize(CCSizeMake(cellWidth - 26,newLineSp:getContentSize().height))
                newLineSp:setPosition(ccp(cellWidth/2,0))
                cell:addChild(newLineSp)
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
    self.tv:setPosition(ccp(0,5))
    dialogBg2:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    -- 添加屏蔽层
    local function touchForbid()
        if pCallBack then
            pCallBack()
        end
        return self:close()
    end
    local topforbid=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),touchForbid)
    topforbid:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight/2))
    topforbid:setAnchorPoint(ccp(0.5,0))
    dialogBg2:addChild(topforbid)
    topforbid:setTouchPriority(-(self.layerNum-1)*20-3)
    topforbid:setPosition(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height)
    topforbid:setVisible(false)

    local bottomforbid=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),touchForbid)
    bottomforbid:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight/2))
    bottomforbid:setAnchorPoint(ccp(0.5,1))
    dialogBg2:addChild(bottomforbid)
    bottomforbid:setTouchPriority(-(self.layerNum-1)*20-3)
    bottomforbid:setPosition(dialogBg2:getContentSize().width/2,0)
    bottomforbid:setVisible(false)
   

	-- 下面的点击屏幕继续
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