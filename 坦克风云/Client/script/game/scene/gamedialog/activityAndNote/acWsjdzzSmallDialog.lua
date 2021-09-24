acWsjdzzSmallDialog=smallDialog:new()

function acWsjdzzSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- 新奖励提示（不再是简单的飘字）
function acWsjdzzSmallDialog:showWsjdzzRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,showType,reward,title,titleSize)
	local sd=acWsjdzzSmallDialog:new()
    sd:initWsjdzzRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,showType,reward,title,titleSize)
end

-- isXiushi:是否有顶部的修饰
function acWsjdzzSmallDialog:initWsjdzzRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,showType,reward,title,titleSize)
	self.isTouch=nil
    self.isUseAmi=isuseami
    local titleSizeIn = 35
    if titleSize then
        titleSizeIn = titleSize
    end
    local function touchHandler()
    
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local titleLb=GetTTFLabelWrap(title,titleSizeIn,CCSize(self.bgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-50))
    self.bgLayer:addChild(titleLb)

    local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX(size.width/lineSp:getContentSize().width)
    lineSp:setScaleY(1.2)
    lineSp:setPosition(ccp(size.width/2,size.height-80))
    self.bgLayer:addChild(lineSp,2)

    local strSize2 = 22
    local needPos = 5
    if G_getCurChoseLanguage() =="cn" and G_getCurChoseLanguage() =="ja" and G_getCurChoseLanguage() =="ko" and G_getCurChoseLanguage() =="tw" then
      strSize2 =25
      needPos = 20
    end 
    local tvWidth=size.width-60
    local tvHeight=250
    local fy=0
    for i=1,SizeOfTable(reward) do
        local px,py=20,size.height-150-320*(i-1)
        local tabItemSp=CCSprite:createWithSpriteFrameName("RankBtnTab_Down.png")
        local lbStr=getlocal("activity_wanshengjiedazuozhan_tab"..i)
        local lb=GetTTFLabelWrap(lbStr,20,CCSizeMake(tabItemSp:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setPosition(getCenterPoint(tabItemSp))
        tabItemSp:addChild(lb)
        tabItemSp:setAnchorPoint(ccp(0,0))
        tabItemSp:setPosition(ccp(px+10,py))
        self.bgLayer:addChild(tabItemSp,1)

        local descLb=GetTTFLabelWrap(getlocal("activity_wanshengjiedazuozhan_reward_desc"),strSize2,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
        descLb:setAnchorPoint(ccp(0,0))
        descLb:setPosition(ccp(px+10+tabItemSp:getContentSize().width+needPos,py+8))
        self.bgLayer:addChild(descLb,1)

        local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
        tvBg:setTouchPriority(-(layerNum-1)*20-1)
        tvBg:setContentSize(CCSizeMake(tvWidth+10,tvHeight+10))
        tvBg:ignoreAnchorPointForPosition(false)
        tvBg:setAnchorPoint(ccp(0,1))
        tvBg:setPosition(ccp(px,py))
        -- tvBg:setIsSallow(true)
        self.bgLayer:addChild(tvBg,1)

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
                        local sp,scale=G_getItemIcon(v,100,true,layerNum,nil,self["acTv"..i])
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
        local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
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