acImminentTab2 ={}
function acImminentTab2:new(layerNum)
        local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.layerNum=layerNum
    self.tv = nil
    self.needIphone5Height_1 = 0
    self.headScale = 0.35
    if G_isIphone5() then
        self.needIphone5Height_1 =20
        self.headScale =0.3
    end
    self.adaH = 0
    return nc;

end
function acImminentTab2:dispose( )
    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil
    self.needIphone5Height_1 = nil
end

function acImminentTab2:init(layerNum)
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    local function cellClick(hd,fn,index)
    end
    local w = G_VisibleSizeWidth - 60 -- 背景框的宽度
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-44, G_VisibleSizeHeight-185))
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setOpacity(0)
    backSprie:setPosition(ccp(G_VisibleSizeWidth*0.5,25))
    self.bgLayer:addChild(backSprie)

    local bgWidht = backSprie:getContentSize().width
    local bgHeight = backSprie:getContentSize().height 

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local headBg = CCSprite:create("public/acImminentImage/imminentBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    headBg:setPosition(ccp(0,bgHeight))
    headBg:setAnchorPoint(ccp(0,1))
    local headbgScaleX = bgWidht/headBg:getContentSize().width
    local headbgScaleY = bgHeight*self.headScale/headBg:getContentSize().height  
    headBg:setScaleX(headbgScaleX)
    headBg:setScaleY(headbgScaleY)
    if G_getIphoneType() == G_iphoneX then
        headBg:setScaleY(1)
    end
    backSprie:addChild(headBg)

    local girlScl = 0.3
    -- if G_isIphone5() then
    --     girlScl =0.3
    -- end
    local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png")
    girlImg:setAnchorPoint(ccp(0,0))
    girlImg:setPosition(ccp(0,1))
    girlImg:setScaleX(1/headbgScaleX)
    girlImg:setScaleY(1/headbgScaleY)
    girlImg:setScaleX(headBg:getContentSize().width*girlScl/girlImg:getContentSize().width)
    girlImg:setScaleY(headBg:getContentSize().height*0.7/girlImg:getContentSize().height)
    if G_getIphoneType() == G_iphoneX then
        girlImg:setScale(0.85)
    end
    headBg:addChild(girlImg,2)
    local function noData( )
    end 
    touchDialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 5, 10, 2),noData)
    touchDialogBg2:setTouchPriority(-(self.layerNum-1)*20-2)
    touchDialogBg2:setScaleX(1/headbgScaleX)
    touchDialogBg2:setScaleY(1/headbgScaleY)
    touchDialogBg2:setOpacity(150)
    touchDialogBg2:setContentSize(CCSizeMake(bgWidht*(1-self.headScale),bgHeight*0.15))
    touchDialogBg2:setAnchorPoint(ccp(0,0))
    touchDialogBg2:setPosition(ccp(bgWidht*self.headScale,5))
    headBg:addChild(touchDialogBg2,1)

    local descTv1=G_LabelTableView(CCSize(bgWidht*(1-self.headScale),bgHeight*0.15),getlocal("activity_yichujifa_tab2_desc"),strSize2,kCCTextAlignmentLeft)
    descTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv1:setAnchorPoint(ccp(0,0))
    if G_getIphoneType() == G_iphoneX then
        descTv1:setScaleX(1)
        descTv1:setScaleY(1)
        descTv1:setPosition(ccp(bgWidht*self.headScale+15,-15))
    else
        descTv1:setScaleX(1/headbgScaleX)
        descTv1:setScaleY(1/headbgScaleY)
        descTv1:setPosition(ccp(bgWidht*self.headScale,5))
    end
    
    headBg:addChild(descTv1,5)
    descTv1:setMaxDisToBottomOrTop(100)

    local needScale = 1-self.headScale-0.1
    local desScale = 0.2
    if G_isIphone5() then
        -- needScale =1-self.headScale-0.1
        desScale =0.18
    end
    local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    downBg:setContentSize(CCSizeMake(bgWidht-2, bgHeight*needScale))
    downBg:setAnchorPoint(ccp(0,1))
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 60
    end
    downBg:setPosition(ccp(1,bgHeight*(1-self.headScale)+self.adaH))
    backSprie:addChild(downBg)

    local scaleTb = {1,0.7,0.38}
    if G_isIphone5() then
        scaleTb ={1,0.65,0.35}
    end
    local everDataTb = {0,acImminentVoApi:getUpperLimit(),acImminentVoApi:getIncreasePick()}
    for i=1,3 do
        local orangeMask = CCSprite:createWithSpriteFrameName("orangeMask.png")
        orangeMask:setAnchorPoint(ccp(0.5,1))
        orangeMask:setScaleX(1.1)
        orangeMask:setPosition(ccp(downBg:getContentSize().width*0.5,downBg:getContentSize().height*scaleTb[i]-4))
        downBg:addChild(orangeMask)

        local orderStr  = GetTTFLabelWrap(getlocal("activity_yichujifa_order",{i}),25,CCSizeMake(downBg:getContentSize().width*0.5,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        orderStr:setAnchorPoint(ccp(0.5,0.5))
        orderStr:setScaleX(1/1.1)
        orderStr:setPosition(ccp(orangeMask:getContentSize().width*0.5,orangeMask:getContentSize().height*0.5))
        orangeMask:addChild(orderStr)

        local orderDesc  = GetTTFLabelWrap(getlocal("activity_yichujifa_order_des"..i,{everDataTb[i]}),strSize2,CCSizeMake(downBg:getContentSize().width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        orderDesc:setAnchorPoint(ccp(0,0.5))
        orderDesc:setPosition(ccp(8,downBg:getContentSize().height*(scaleTb[i]-desScale)))
        downBg:addChild(orderDesc)
    end

    local function btnClick( ... )
        mainUI.m_menuToggle:setSelectedIndex(2)
        activityAndNoteDialog:closeAllDialog()
        worldScene:setShow()
    end 
    self.goToBtn =GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",btnClick,11,getlocal("activity_heartOfIron_goto"),25)
    self.goToBtn:setAnchorPoint(ccp(0.5,0))
    self.goToBtnMenu=CCMenu:createWithItem(self.goToBtn)
    self.goToBtnMenu:setPosition(ccp(bgWidht*0.5,2+self.adaH/2))
    self.goToBtnMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:addChild(self.goToBtnMenu) 


    return self.bgLayer
end