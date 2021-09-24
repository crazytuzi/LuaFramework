acNewYearSmallDialog=smallDialog:new()

function acNewYearSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self


    self.parent=nil
    self.data=nil
    self.type=0       --是配件还是碎片
    return nc
end

-- rewardList  列表信息
function acNewYearSmallDialog:init(bgSrc,size,tmpFunc,istouch,isuseami,layerNum,rewardList,title,desStr,nojilu,isCheck,isCharge,okCallBack)
    
    -- self.isTouch=istouch
    -- self.isUseAmi=isuseami
    self.rewardList=rewardList
    -- for k,v in pairs(self.rewardList) do
    --     print(k,v)
    -- end
    self.layerNum=layerNum

    local function tmpFunc()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    local titleLb=GetTTFLabel(title,25)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-35))
    dialogBg:addChild(titleLb)
    titleLb:setColor(G_ColorYellowPro)

    local desc = GetTTFLabelWrap(desStr,25,CCSizeMake(dialogBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desc:setAnchorPoint(ccp(0,1))
    desc:setPosition(20,dialogBg:getContentSize().height-75)
    dialogBg:addChild(desc)
    desc:setColor(G_ColorGreen)

    if SizeOfTable(self.rewardList)==0 then
        local noTansuoLb = GetTTFLabelWrap(nojilu,25,CCSizeMake(self.bgSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noTansuoLb:setAnchorPoint(ccp(0.5,0.5))
        noTansuoLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
        self.bgLayer:addChild(noTansuoLb)
    end
   
    --物品列表
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    if isCharge ~= nil and isCharge == true then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(size.width,size.height - 220),nil) 
        self.tv:setPosition(ccp(10,140))
    else
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(size.width,size.height - 180),nil)
        self.tv:setPosition(ccp(10,110))
    end

    self.tv:setMaxDisToBottomOrTop(100)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-5)
    self.bgLayer:addChild(self.tv,1)

    --确定按钮
    local function confirm()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        PlayEffect(audioCfg.mouseClick)
        if okCallBack ~= nil then
            okCallBack()
        end
        return self:close()
    end
    --取消按钮
    local function cancel()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end

    local sureBtn = nil
    local cancelBtn = nil
    if isCheck ~= nil and isCheck == true then
        sureBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",confirm,1,getlocal("ok"),25,11)
    elseif isCharge ~= nil and isCharge == true then
        sureBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",confirm,1,getlocal("buy"),25,11)
        cancelBtn=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancel,1,getlocal("cancel"),25,11)      

        local function touch()
            -- body
        end
        local priceBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 10, 20, 10),touch)
        priceBg:setContentSize(CCSizeMake(150,30))
        priceBg:setAnchorPoint(ccp(0.5,0))
        priceBg:setOpacity(150)
        priceBg:setPosition(ccp(sureBtn:getContentSize().width/2,sureBtn:getContentSize().height + 2))
        sureBtn:addChild(priceBg)

        local chargeGiftLabel = GetTTFLabel(acNewYearVoApi:getChargeRewardsCost(),25)
        chargeGiftLabel:setAnchorPoint(ccp(0.5,0.5))
        chargeGiftLabel:setColor(G_ColorYellow)
        chargeGiftLabel:setPosition(ccp(priceBg:getContentSize().width/2 - 15,priceBg:getContentSize().height/2))
        priceBg:addChild(chargeGiftLabel)

        local chargeGoldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        chargeGoldIcon:setAnchorPoint(ccp(0.5,0.5))
        chargeGoldIcon:setPosition(ccp(priceBg:getContentSize().width/2 + 35,priceBg:getContentSize().height/2))
        priceBg:addChild(chargeGoldIcon)

    elseif isCharge ~= nil and isCharge == false then
        sureBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",confirm,1,getlocal("daily_scene_get"),25,11)
        cancelBtn=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancel,1,getlocal("cancel"),25,11)           
    end
    if sureBtn ~= nil and cancelBtn == nil then
        local sureMenu=CCMenu:createWithItem(sureBtn);
        sureMenu:setPosition(ccp(size.width/2,sureBtn:getContentSize().height - 15))
        sureMenu:setTouchPriority(-(layerNum-1)*20-3);
        self.bgLayer:addChild(sureMenu,2)
    elseif sureBtn ~= nil and cancelBtn ~= nil then
        local sureMenu=CCMenu:createWithItem(sureBtn);
        sureMenu:setPosition(ccp(size.width/4,sureBtn:getContentSize().height - 15))
        sureMenu:setTouchPriority(-(layerNum-1)*20-3);
        self.bgLayer:addChild(sureMenu,2)

        local cancelMenu=CCMenu:createWithItem(cancelBtn);
        cancelMenu:setPosition(ccp(size.width/4*3,cancelBtn:getContentSize().height - 15))
        cancelMenu:setTouchPriority(-(layerNum-1)*20-3);
        self.bgLayer:addChild(cancelMenu,2)
    end

    -- "BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png"
    -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
    -- "BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png"

    local function forbidClick()
   
    end
    local rect2 = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.topforbidSp:setTouchPriority(-(layerNum-1)*20-5)
    self.topforbidSp:setAnchorPoint(ccp(0,0))
    self.topforbidSp:setContentSize(CCSize(self.bgSize.width, (G_VisibleSize.height-self.bgSize.height)/2+150))
    self.topforbidSp:setPosition(0,self.bgLayer:getContentSize().height-120-desc:getContentSize().height+30)


    self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-5)
    self.bottomforbidSp:setContentSize(CCSize(self.bgSize.width,30))
    self.bottomforbidSp:setAnchorPoint(ccp(0,0))
    self.bottomforbidSp:setPosition(0,0)
    dialogBg:addChild(self.topforbidSp)
    dialogBg:addChild(self.bottomforbidSp)
    self.bottomforbidSp:setVisible(false)
    self.topforbidSp:setVisible(false)

    self:show()

    local function touchDialog()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
      
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
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
    return self.dialogLayer
    
end

function acNewYearSmallDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.rewardList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        self.cellHight = 120
        tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,self.cellHight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local award = self.rewardList[idx+1]
        -- G_dayin(award)

        if award then
           local icon,iconScale = G_getItemIcon(award,100,false,self.layerNum,nil,self.tv1)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(10,self.cellHight/2)
            cell:addChild(icon)


            local name = GetTTFLabelWrap(award.name,25,CCSizeMake(self.bgLayer:getContentSize().width - 200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            name:setAnchorPoint(ccp(0,1))
            local nomePos =20
            if G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="fr" then
            nomePos =40
            end
            name:setPosition(nomePos+icon:getContentSize().width*iconScale,self.cellHight-10)

            local num = GetTTFLabel("x"..award.num,25/iconScale)
            num:setAnchorPoint(ccp(0,0))
            num:setPosition(nomePos+icon:getContentSize().width*iconScale-10,0)
            icon:addChild(num)

            cell:addChild(name)
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

function acNewYearSmallDialog:dispose()
    self.rewardList=nil
end