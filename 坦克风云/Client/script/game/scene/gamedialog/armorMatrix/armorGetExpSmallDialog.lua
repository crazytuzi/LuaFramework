armorGetExpSmallDialog=smallDialog:new()

function armorGetExpSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    local function addPlist()
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    end
    G_addResource8888(addPlist)
    return nc
end

function armorGetExpSmallDialog:init(layerNum,titleStr,infoTb,isuseami)
    local strSize2 = 18
    local strSize3 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
        strSize3 = 30
    end
    self.isTouch=true
    self.isUseAmi=isuseami
    local function touchHandler()
    
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    dialogBg:setTouchPriority(-(layerNum-1)*20-2)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg

    local bgWidth,bgHeight=550,115
    bgHeight=bgHeight+SizeOfTable(infoTb)*120
    self.bgSize=CCSizeMake(bgWidth,bgHeight)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()


    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    -- self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    -- title 背景
    -- local titleBgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
    -- titleBgSp:setAnchorPoint(ccp(0.5,1))
    -- titleBgSp:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-20));
    -- titleBgSp:setScaleY(60/titleBgSp:getContentSize().height)
    -- titleBgSp:setScaleX(800/titleBgSp:getContentSize().width)
    -- self.bgLayer:addChild(titleBgSp)

    -- title lb
    local titleLb=GetTTFLabelWrap(titleStr,strSize3,CCSizeMake(self.bgSize.width-160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(titleLb)
    titleLb:setPosition(self.bgSize.width/2,self.bgSize.height-50)
    titleLb:setColor(G_ColorYellowPro)

    local startH=self.bgSize.height-50-titleLb:getContentSize().height/2-10

    local function func1()
    end
    local function func2()
    end

    

    local function click(hd,fn,idx)
    end
    local totalBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),click)
    totalBg:setContentSize(CCSizeMake(self.bgSize.width-40,startH-20))
    totalBg:setAnchorPoint(ccp(0.5,1))
    totalBg:setPosition(ccp(self.bgSize.width/2,startH+5))
    self.bgLayer:addChild(totalBg)

    startH=startH-30
    
    for k,v in pairs(infoTb) do
        local function touchBSP()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self:close()
            if v.callback then
                v.callback()
            end
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchBSP)
        backSprie:setContentSize(CCSizeMake(self.bgSize.width-60, 90))
        backSprie:setTouchPriority(-(layerNum-1)*20-3)
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setPosition(self.bgSize.width/2,startH)
        self.bgLayer:addChild(backSprie,1)
        local bsSize=backSprie:getContentSize()
        -- platWarNameBg2
        local titleSp=CCSprite:createWithSpriteFrameName("platWarNameBg" .. v.picFalg .. ".png")
        backSprie:addChild(titleSp)
        titleSp:setAnchorPoint(ccp(0,0.5))
        titleSp:setPosition(0,bsSize.height)

        local subTitleLb=GetTTFLabelWrap(v.title,strSize2,CCSizeMake(titleSp:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        titleSp:addChild(subTitleLb)
        subTitleLb:setPosition(titleSp:getContentSize().width/2,titleSp:getContentSize().height/2)

        local subDesLb=GetTTFLabelWrap(v.des,strSize2,CCSizeMake(bsSize.width-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        backSprie:addChild(subDesLb)
        subDesLb:setAnchorPoint(ccp(0,0.5))
        subDesLb:setPosition(20,bsSize.height/2-5)

        local backItem=GetButtonItem("IconReturn-.png","IconReturn-_Down.png","IconReturn-.png",touchBSP,nil,nil,nil)
        local backMenu=CCMenu:createWithItem(backItem);
        backMenu:setPosition(ccp(bsSize.width-50,bsSize.height/2))
        backMenu:setTouchPriority(-(layerNum-1)*20-3);
        backSprie:addChild(backMenu)

        startH=startH-120
    end


    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
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


function armorGetExpSmallDialog:dispose()
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
end


