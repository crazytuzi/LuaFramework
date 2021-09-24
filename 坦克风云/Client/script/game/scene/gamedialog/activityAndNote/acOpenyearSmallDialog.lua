acOpenyearSmallDialog=smallDialog:new()

function acOpenyearSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- 新奖励提示（不再是简单的飘字）
function acOpenyearSmallDialog:showOpenyearRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,reward,title,desStr,tvHeight,titleColor,useNewUI)
	local sd=acOpenyearSmallDialog:new()
    sd:initOpenyearRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,reward,title,desStr,tvHeight,titleColor,useNewUI)
end

-- isXiushi:是否有顶部的修饰
function acOpenyearSmallDialog:initOpenyearRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,reward,title,desStr,tvHeight,titleColor,useNewUI)
	self.isTouch=nil
    self.isUseAmi=isuseami
    self.useNewUI=useNewUI
    local function touchHandler()
    
    end
    local dialogBg,newUseTitleBg,newUseTitle
    if useNewUI==true then
        local titleStr1,color1,tsize1 = title,titleColor,titleSize or 35
        dialogBg,newUseTitleBg,newUseTitle = G_getNewDialogBg(size,titleStr1,tsize1,touchHander,layerNum,nil,nil,color1)
    else
        dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    end
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local titleLb = newUseTitle
    if useNewUI then
    else
        titleLb = GetTTFLabelWrap(title,35,CCSize(self.bgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-50))
        self.bgLayer:addChild(titleLb)
        if titleColor then
            titleLb:setColor(titleColor)
        end
    end

    
    if not useNewUI then
        local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setScaleX((size.width-50)/lineSp:getContentSize().width)
        lineSp:setScaleY(1.2)
        lineSp:setPosition(ccp(size.width * 0.5,size.height-80))
        self.bgLayer:addChild(lineSp,2)
    end

    local strSize2 = 25
    local needPos = 20
    local tvWidth=size.width-60
    -- tvHeight=250
    local fy=0
    for i=1,SizeOfTable(reward) do
        local px,py=20,size.height-150-320*(i-1)
        local descLb=GetTTFLabel(desStr,strSize2)

        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(ccp(px+10+needPos,py+8+30))
        self.bgLayer:addChild(descLb,1)
        if useNewUI then
            descLb:setFontSize(28)
            descLb:setPositionY(descLb:getPositionY() + 5)
        end

        local tvBg
        if useNewUI then
            tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
        else
            tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),function ()end)
        end
        tvBg:setTouchPriority(-(layerNum-1)*20-1)
        tvBg:setContentSize(CCSizeMake(tvWidth+10,tvHeight+10))
        tvBg:ignoreAnchorPointForPosition(false)
        tvBg:setAnchorPoint(ccp(0,1))
        tvBg:setPosition(ccp(px,py))
        self.bgLayer:addChild(tvBg,1)
        if useNewUI then
            local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
            pointSp1:setPosition(ccp(2,tvBg:getContentSize().height * 0.5))
            tvBg:addChild(pointSp1)
            local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
            pointSp2:setPosition(ccp(tvBg:getContentSize().width-2,tvBg:getContentSize().height * 0.5))
            tvBg:addChild(pointSp2)
        end
        local awardTb
        if reward and reward[i] then
            awardTb=FormatItem(reward[i],nil,true)
        end
        local num=math.ceil(SizeOfTable(awardTb)/4)
        if awardTb and SizeOfTable(awardTb)>0 then
            local function tvCallBack(handler,fn,idx,cel)
                if fn=="numberOfCellsInTableView" then
                    return 1
                elseif fn=="tableCellSizeForIndex" then
                    local tmpSize=CCSizeMake(tvWidth,num*125)
                    return tmpSize
                elseif fn=="tableCellAtIndex" then
                    local cell=CCTableViewCell:new()
                    cell:autorelease()

                    local cellHeight=num*125
                    for k,v in pairs(awardTb) do
                        local posx,posy=60+120*((k-1)%4),cellHeight-65-120*math.floor((k-1)/4)
                        local function showNewPropInfo()
                            G_showNewPropInfo(layerNum+1,true,true,nil,v,nil,nil,nil,nil,true)
                            return false
                        end
                        local sp,scale=G_getItemIcon(v,100,true,layerNum,showNewPropInfo,self["acTv"..i])
                        sp:setPosition(ccp(posx,posy))
                        sp:setTouchPriority(-(layerNum-1)*20-2)
                        cell:addChild(sp)
                        if v and v.type=="h" and v.eType=="h" then
                        else
                            local lb=GetTTFLabel("x"..FormatNumber(v.num),25)
                            lb:setAnchorPoint(ccp(1,0))
                            lb:setPosition(ccp(sp:getContentSize().width-5,5))
                            sp:addChild(lb)
                            lb:setScale(1/scale)
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
            local cellWidth=self.bgLayer:getContentSize().width-40
            local hd= LuaEventHandler:createHandler(tvCallBack)
            self["acTv"..i]=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
            self["acTv"..i]:setTableViewTouchPriority(-(layerNum-1)*20-3)
            self["acTv"..i]:setPosition(ccp(5,5))
            tvBg:addChild(self["acTv"..i],2)
            self["acTv"..i]:setMaxDisToBottomOrTop(120)
        end

        local function sureHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
        local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,getlocal("ok"),33)
        sureItem:setScale(0.8)
        local sureMenu=CCMenu:createWithItem(sureItem)
        sureMenu:setPosition(ccp(size.width/2,70))
        sureMenu:setTouchPriority(-(layerNum-1)*20-5)
        self.bgLayer:addChild(sureMenu)

        local function forbidClick()
        end
        local rect2 = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        if i==1 then
            local topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
            topforbidSp:setTouchPriority(-(layerNum-1)*20-4)
            topforbidSp:setContentSize(CCSize(size.width,size.height-py))
            topforbidSp:setAnchorPoint(ccp(0,0))
            topforbidSp:setPosition(ccp(0,py))
            self.bgLayer:addChild(topforbidSp)
            topforbidSp:setVisible(false)

            fy=py
        elseif i==2 then
            local middleforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
            middleforbidSp:setTouchPriority(-(layerNum-1)*20-4)
            middleforbidSp:setContentSize(CCSize(size.width,fy-py-tvBg:getContentSize().height))
            middleforbidSp:setAnchorPoint(ccp(0,0))
            middleforbidSp:setPosition(ccp(0,py))
            self.bgLayer:addChild(middleforbidSp)
            middleforbidSp:setVisible(false)

            local bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
            bottomforbidSp:setTouchPriority(-(layerNum-1)*20-4)
            bottomforbidSp:setContentSize(CCSize(size.width,py-tvBg:getContentSize().height))
            bottomforbidSp:setAnchorPoint(ccp(0,0))
            bottomforbidSp:setPosition(ccp(0,0))
            self.bgLayer:addChild(bottomforbidSp)
            bottomforbidSp:setVisible(false)
        end
    end

    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end