acSecretshopChangeSmallDialog=smallDialog:new()

function acSecretshopChangeSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    nc.allTabs={}
	return nc
end

function acSecretshopChangeSmallDialog:showChange(layerNum,istouch,isuseami,callBack,titleStr,tabInfo1,tabInfo2,flag)
	local sd=acSecretshopChangeSmallDialog:new()
    sd:initChange(layerNum,istouch,isuseami,callBack,titleStr,tabInfo1,tabInfo2,flag)
    return sd
end

function acSecretshopChangeSmallDialog:initChange(layerNum,istouch,isuseami,pCallBack,titleStr,tabInfo1,tabInfo2,flag)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.tabInfo1=tabInfo1
    self.tabInfo2=tabInfo2
    self.flag=flag

    local nameFontSize=30



    -- base:removeFromNeedRefresh(self) --停止刷新
    base:addNeedRefresh(self)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dgSize=CCSizeMake(600,660)
    self.dgSize=dgSize

    local function closeFunc()
        self:close()
    end
    local dialogBg=G_getNewDialogBg(dgSize,titleStr,30,nil,self.layerNum+1,true,closeFunc)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    self:show()

    local function touchItem(idx)
        self:tabClickColor(idx)
    end
    local menuItem1 = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
    menuItem1:setTag(1)
    menuItem1:registerScriptTapHandler(touchItem)
    -- menuItem1:setEnabled(false)
    self.allTabs[1]=menuItem1
    local menu1=CCMenu:createWithItem(menuItem1)
    menu1:setPosition(ccp(30+menuItem1:getContentSize().width/2-10,self.bgLayer:getContentSize().height-95))
    menu1:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(menu1,2)
    -- serverwar_shop_tab1

    local menuLb1=GetTTFLabelWrap(getlocal("serverwar_shop_tab1"),24,CCSizeMake(menuItem1:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    menuLb1:setPosition(ccp(menuItem1:getContentSize().width/2,menuItem1:getContentSize().height/2))
    menuItem1:addChild(menuLb1,6)

    local menuItem2=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
    menuItem2:setTag(2)
    menuItem2:registerScriptTapHandler(touchItem)
    self.allTabs[2]=menuItem2
    local menu2=CCMenu:createWithItem(menuItem2)
    menu2:setPosition(ccp(30+menuItem2:getContentSize().width/2*3-5,self.bgLayer:getContentSize().height-95))
    menu2:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(menu2,2)
    -- sample_general_exp

    local menuLb2=GetTTFLabelWrap(getlocal("sample_general_exp"),24,CCSizeMake(menuItem2:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    menuLb2:setPosition(ccp(menuItem2:getContentSize().width/2,menuItem2:getContentSize().height/2))
    menuItem2:addChild(menuLb2,6)


    self.dialogWidth2=dgSize.width-40
    self.dialogBg2H=dgSize.height-195

    touchItem(self.flag)


    local picStr1
    local picStr2
    picStr1="newGreenBtn.png"
    picStr2="newGreenBtn_down.png"

    local function touchRefreshFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self.selectInfo==nil then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_secretshop_select_des"),30)
            do return end
        end
        if pCallBack then
            pCallBack(self.selectInfo)
        end
        self:close()
    end
    local scale=160/207
    local refreshMenuItem=GetButtonItem(picStr1,picStr2,picStr2,touchRefreshFunc,1,getlocal("dailyAnswer_tab1_btn"),24/scale)
    refreshMenuItem:setScale(scale)
    local refreshBtn = CCMenu:createWithItem(refreshMenuItem)
    dialogBg:addChild(refreshBtn,1)
    refreshBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    refreshBtn:setBSwallowsTouches(true)
    refreshBtn:setPosition(dialogBg:getContentSize().width/2,50)

    local desLb=GetTTFLabelWrap(getlocal("activity_secretshop_click_des"),22,CCSizeMake(dialogBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    dialogBg:addChild(desLb)
    desLb:setPosition(dialogBg:getContentSize().width/2,50+30+20)
    desLb:setColor(G_ColorRed)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function acSecretshopChangeSmallDialog:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end

    print("self.selectedTabIndex",self.selectedTabIndex)

    if self.selectedTabIndex==1 then
        if self.rewardBg1==nil then
            self.rewardBg1=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
            self.rewardBg1:setContentSize(CCSizeMake(self.dialogWidth2,self.dialogBg2H))
            self.rewardBg1:setAnchorPoint(ccp(0.5,1))
            self.rewardBg1:setPosition(self.bgLayer:getContentSize().width/2,self.dgSize.height-120)
            self.bgLayer:addChild(self.rewardBg1)
            self:initReward(self.rewardBg1)

        else
            self.rewardBg1:setPosition(self.bgLayer:getContentSize().width/2,self.dgSize.height-120)
            self.rewardBg1:setVisible(true)
        end
        if self.rewardBg2 then
            self.rewardBg2:setPosition(ccp(999333,0))
            self.rewardBg2:setVisible(false)
        end

    else
        if self.rewardBg2==nil then
            self.rewardBg2=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
            self.rewardBg2:setContentSize(CCSizeMake(self.dialogWidth2,self.dialogBg2H))
            self.rewardBg2:setAnchorPoint(ccp(0.5,1))
            self.rewardBg2:setPosition(self.bgLayer:getContentSize().width/2,self.dgSize.height-120)
            self.bgLayer:addChild(self.rewardBg2)
            self:initReward(self.rewardBg2)
        else
            self.rewardBg2:setPosition(self.bgLayer:getContentSize().width/2,self.dgSize.height-120)
            self.rewardBg2:setVisible(true)
        end
        if self.rewardBg1 then
            self.rewardBg1:setPosition(ccp(999333,0))
            self.rewardBg1:setVisible(false)
        end

    end
    self.selectInfo=nil
    if self.selectSp then
        self.selectSp:removeFromParentAndCleanup(true)
        self.selectSp=nil
    end
end

function acSecretshopChangeSmallDialog:initReward(rewardBg)
    local tabInfo
    if self.selectedTabIndex==1 then
        tabInfo=self.tabInfo1
    else
        tabInfo=self.tabInfo2
    end
    local startW=90
    local startH=rewardBg:getContentSize().height-60
    for k,v in pairs(tabInfo) do
        local value=v.value
        local rewardItem=FormatItem(value.r)[1]

        local ys=k%4
        if ys==0 then
            ys=4
        end
        local shang=math.ceil(k/4)

        local posX=startW+(ys-1)*130
        local posY=startH-(shang-1)*140

        local changeNum=acSecretshopVoApi:getChangeNum(v.key)

        local function showNewPropInfo()
            if changeNum>=value.maxtimes and value.maxtimes~=0 then
                return false
            end
            if self.selectInfo==nil then
                self.selectInfo=v
                self.selectSp=CCSprite:createWithSpriteFrameName("TeamTankSelected.png")
                rewardBg:addChild(self.selectSp,2)
                self.selectSp:setPosition(posX,posY)
                self.selectSp:setScale(110/self.selectSp:getContentSize().width)
            else
                if self.selectInfo.key==v.key then
                    G_showNewPropInfo(self.layerNum+1,true,true,nil,rewardItem)
                else
                    self.selectInfo=v
                    if self.selectSp then
                        self.selectSp:setPosition(posX,posY)
                    else
                        self.selectSp=CCSprite:createWithSpriteFrameName("TeamTankSelected.png")
                        rewardBg:addChild(self.selectSp)
                        self.selectSp:setPosition(posX,posY)
                    end
                end
            end
            return false
        end
        
        local rewardSp=G_getItemIcon(rewardItem,100,true,self.layerNum + 1,showNewPropInfo)
        rewardBg:addChild(rewardSp)
        rewardSp:setPosition(posX,posY)
        rewardSp:setTouchPriority(-(self.layerNum-1)*20-4)

        local pointBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),function ( ... )end)
        pointBg:setContentSize(CCSizeMake(95,30))
        rewardSp:addChild(pointBg)
        pointBg:setScale(1/rewardSp:getScale())
        pointBg:setPosition(rewardSp:getContentSize().width/2,15)
        pointBg:setOpacity(120)

        local pointLb=GetTTFLabel("+" .. value.needp,22)
        rewardSp:addChild(pointLb)
        pointLb:setAnchorPoint(ccp(0.5,0))
        pointLb:setScale(1/rewardSp:getScale())
        pointLb:setPosition(rewardSp:getContentSize().width/2,5)
        pointLb:setColor(G_ColorGreen)

        local numLb
        if value.maxtimes~=0 then
            numLb=GetTTFLabel(changeNum .. "/" .. value.maxtimes,22)
            rewardBg:addChild(numLb)
            numLb:setPosition(posX,posY-65)
        end

        if changeNum>=value.maxtimes and value.maxtimes~=0 then
            local blackBg = CCSprite:createWithSpriteFrameName("acSecretshop_gray.png")
            rewardBg:addChild(blackBg)
            blackBg:setPosition(posX,posY)
            blackBg:setOpacity(120)

            if numLb then
                numLb:setColor(G_ColorGray)
            end
        end


    end
end



function acSecretshopChangeSmallDialog:tick()
end


function acSecretshopChangeSmallDialog:dispose()
    self.parent=nil
    self.costNum=nil
    self.allTabs=nil
    self.tabInfo1=nil
    self.tabInfo2=nil
    self.flag=nil
    self.rewardBg1=nil
    self.rewardBg2=nil
    self.selectInfo=nil
end

