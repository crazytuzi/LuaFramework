acDoubleOneTabTwo ={}
function acDoubleOneTabTwo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer        =nil
    self.layerNum       =nil
    self.tv             =nil
    self.showIdx        =nil
    self.lList          ={}
    self.List           ={}
    self.switchTab      ={}
    self.upLayer        =nil
    self.curSellTab     ={}
    self.pageFlagPosXTb ={}
    self.curPageFlag    =nil
    self.version        =1
    return nc;

end
function acDoubleOneTabTwo:init(layerNum)
    self:secondSocket()
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum
    self.version = acDoubleOneVoApi:getVersion()

    self:initMaskPanel()
    local isCanBuy,butTime = acDoubleOneVoApi:refeshBuyTime( )
    if not isCanBuy then--不能买
        self:refreshBuyShopData()
        local newIdx = acDoubleOneVoApi:getOpenShopNum()
        if newIdx == 2 then
            self:showMaskPanel(true)
        else
            self:showMaskPanel(false)
        end
    else
        self:showMaskPanel(false)    
    end

    self.switchTab,self.showIdx =acDoubleOneVoApi:getSwitchTab()   --目前是假数据     需要根据后台返回告知几个开启，具体开启是什么
    -- self:initTableView()
    -- self:initPageFlag()
    self:initAllDialog()

    return self.bgLayer
end

function acDoubleOneTabTwo:showMaskPanel(isShow)
    if self.maskPanelSp then
        self.maskPanelSp:setVisible(isShow)
        if isShow then
            self.maskPanelSp:setPosition(G_VisibleSizeWidth * 0.5,90)
        else
            self.maskPanelSp:setPosition(G_VisibleSizeWidth * 5.5,90)
        end
    else
        print "~~~~~~~~ e r r o r in showMaskPanel :self.maskPanelSp is nil"
    end
end
function acDoubleOneTabTwo:initMaskPanel(isShow)
    
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local maskPanelSp =LuaCCSprite:createWithFileName("public/superWeapon/weaponBg.jpg",function() end)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

        local bgNeedWidth = G_VisibleSizeWidth-42
        local bgNeedHeight = G_VisibleSizeHeight - 470
        local maskScaleX = bgNeedWidth/maskPanelSp:getContentSize().width
        local maskScaleY = bgNeedHeight/maskPanelSp:getContentSize().height
        maskPanelSp:setTouchPriority(-(self.layerNum-1)*20-9999)
        maskPanelSp:setIsSallow(true)
        maskPanelSp:setScaleX(maskScaleX)
        maskPanelSp:setScaleY(maskScaleY)
        maskPanelSp:setAnchorPoint(ccp(0.5,0))
        maskPanelSp:setPosition(ccp(G_VisibleSizeWidth * 0.5,90))
        self.bgLayer:addChild(maskPanelSp,10)
        self.maskPanelSp = maskPanelSp

        local upBoderLayer =CCSprite:createWithSpriteFrameName("brown_fade1.png")
        upBoderLayer:setScaleX(1/maskScaleX)
        upBoderLayer:setScaleY(1/maskScaleY)
        upBoderLayer:setScaleX((bgNeedWidth-4)/upBoderLayer:getContentSize().width)
        upBoderLayer:setScaleY(80/upBoderLayer:getContentSize().height)
        upBoderLayer:setRotation(180)
        upBoderLayer:setOpacity(150)
        upBoderLayer:setAnchorPoint(ccp(0.5,1))
        upBoderLayer:setPosition(bgNeedWidth * 0.5,maskPanelSp:getContentSize().height - 80)
        maskPanelSp:addChild(upBoderLayer)

        local addHeight2 = 5
        local goldLineSprite=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
        goldLineSprite:setScaleX(1/maskScaleX)
        goldLineSprite:setScaleY(1/maskScaleY)
        goldLineSprite:setAnchorPoint(ccp(0.5,1))
        goldLineSprite:setPosition(ccp(bgNeedWidth * 0.5,maskPanelSp:getContentSize().height))
        maskPanelSp:addChild(goldLineSprite,1)

end

function acDoubleOneTabTwo:secondSocket( )
    if acDoubleOneVoApi:isInTime( ) then
      self.isbeginS=false
      local isInTime,curTime = acDoubleOneVoApi:isInTime( )
      local otherData,shop = acDoubleOneVoApi:returWhiPanicShop( ) --    根据配置 时间  自己计算 进入游戏时当前的抢购商店为第几个
      local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.new112018 then
                if sData.data.new112018.buyshop then
                     acDoubleOneVoApi:setbuyShopNums(sData.data.new112018.buyshop)
                end
            end
        end
      end
      socketHelper:doubleOnePanicBuying( getRawardCallback,"getbuyShop",nil,nil,curTime)
    end
end


function acDoubleOneTabTwo:initAllDialog( )
        local function click(hd,fn,idx)
        end
        local bigBg =CCSprite:create("public/superWeapon/weaponBg.jpg")
        bigBg:setScaleX((G_VisibleSizeWidth-42)/bigBg:getContentSize().width)
        bigBg:setScaleY((G_VisibleSizeHeight-194)/bigBg:getContentSize().height)
        bigBg:ignoreAnchorPointForPosition(false)
        bigBg:setOpacity(150)
        bigBg:setAnchorPoint(ccp(0.5,0.5))
        bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5-68))
        self.bgLayer:addChild(bigBg)

    self:initPageDialog()
    
    local maskSpHeight=self.bgLayer:getContentSize().height-133
    for k=1,3 do
        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        leftMaskSp:setAnchorPoint(ccp(0,0))
        leftMaskSp:setPosition(0,38)
        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
        self.bgLayer:addChild(leftMaskSp,6)

        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        rightMaskSp:setFlipX(true)
        rightMaskSp:setAnchorPoint(ccp(0,0))
        rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
        self.bgLayer:addChild(rightMaskSp,6)
    end

    local isCanBuy,butTime = acDoubleOneVoApi:refeshBuyTime( )
    if butTime then
        local butTimeStr = getlocal("activity_double11_countdownStr")..butTime
        if isCanBuy then
            butTimeStr = getlocal("activity_cjms_countdown",{butTime})
        end
        local refreshTime = GetTTFLabel(butTimeStr,26,"Helvetica-bold")
        if isCanBuy then
            refreshTime:setColor(G_ColorYellowPro2)
        else
            refreshTime:setColor(G_ColorRed3)
        end
        refreshTime:setPosition(G_VisibleSizeWidth * 0.5,60)
        self.bgLayer:addChild(refreshTime,10)
        self.refreshTime = refreshTime
    end

    local maskBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end);
    maskBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth,170))
    maskBg1:setPosition(ccp(G_VisibleSizeWidth * 0.5,0))
    maskBg1:setOpacity(0)
    maskBg1:setTouchPriority(-(self.layerNum-1)*20-9999)
    maskBg1:setIsSallow(true)
    self.bgLayer:addChild(maskBg1,99)
end

function acDoubleOneTabTwo:initPageDialog( )
    for i=1,self.showIdx do
        local atDialog=acDoubleOneSellDialog:new(self)
        local layer=atDialog:init(self.layerNum,i,1)
        self.bgLayer:addChild(layer,1)

        layer:setPosition(ccp(0,0))

        self.lList[i]=layer
        self.List[i]=atDialog
    end


    self.upLayer=pageDialog:new()
    local page=acDoubleOneVoApi:getFirstShowShop( ) or 1
    local isShowBg=false
    local isShowPageBtn=false
    local function onPage(topage)
        print("~~~~~topage:",topage)
        self.curSellTab=self.List[topage]
        -- self.curPageFlag:setPositionX(self.pageFlagPosXTb[topage])
    end

    local posY = G_VisibleSizeHeight*0.4
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(self.bgLayer:getContentSize().width-40,posY)
    local specialTb = {}
    specialTb[1]    =true
    specialTb[2]    =2
    specialTb[3]    ={}
    specialTb[3][1] ="new112018"
    specialTb[3][2] =self.showIdx
    specialTb[4]    = 255
    self.upLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,0),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,40),self.layerNum,page,self.lList,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,nil,nil,nil,nil,nil,specialTb)
    self.curSellTab=self.List[1]
end

function acDoubleOneTabTwo:removePageDialog( )
    for i=1,self.showIdx do
        if self.List[i].sellShowSureDialog then
            self.List[i].sellShowSureDialog:close()
            self.List[i].sellShowSureDialog = nil
        end
        self.lList[i]:removeFromParentAndCleanup(true)
        self.List[i] = nil
        -- self.List[i]:dispose()
    end
    self.lList = {}
    self.List = {}

    self.upLayer:dispose()
    self.upLayer = nil
    self.curSellTab = {}
end

function acDoubleOneTabTwo:tick( )
    if self.showIdx then
        for i=1,self.showIdx do
            if self.lList[i] then
                self.List[i]:tick()
            end
        end
    end

    if self.refreshTime then
        local isCanBuy,butTime,isShowShop,isShowShop2 = acDoubleOneVoApi:refeshBuyTime( )--isShowShop :只用于晚上9：00 - 9：05
        if butTime then
            local butTimeStr = getlocal("activity_double11_countdownStr")..butTime
            if isCanBuy then
                butTimeStr = getlocal("activity_cjms_countdown",{butTime})
            end
            if isShowShop2 then
                self.refreshTime:setVisible(false)
            else
                self.refreshTime:setVisible(true)
                self.refreshTime:setString(butTimeStr)
            end
            if isCanBuy then
                self.refreshTime:setColor(G_ColorYellowPro2)
                self:showMaskPanel(false)
            else
                self.refreshTime:setColor(G_ColorRed3)

                local newIdx = acDoubleOneVoApi:getOpenShopNum()

                if newIdx == 2 and isShowShop then
                    self:showMaskPanel(false)    
                end
                if isShowShop2 then
                   self:showMaskPanel(true) 

                    if self.showIdx and self.List then
                        for i=1,self.showIdx do
                            if self.List[i] and self.List[i].sellShowSureDialog then
                                self.List[i].sellShowSureDialog:close()
                                self.List[i].sellShowSureDialog = nil
                            end
                        end
                    end
                end
                if self.upLayer.openIdx and self.upLayer.openIdx ~= newIdx then
                    self.upLayer.openIdx = nil

                    if newIdx == 2 then
                        self:showMaskPanel(true)
                    elseif isShowShop2 == nil then
                        self:showMaskPanel(false)    
                    end

                    self:refreshBuyShopData()

                    if newIdx == 2 then
                        self:removePageDialog()
                        self:initPageDialog()
                    else
                        local function getNewRefShopCall()
                            self:removePageDialog()
                            self:initPageDialog()    
                        end 
                        acDoubleOneVoApi:getRefShopTbSocket(getNewRefShopCall)
                    end
                end
            end
        end
    end
end

function acDoubleOneTabTwo:refreshBuyShopData( )
    acDoubleOneVoApi:setbuyShopNums()
    acDoubleOneVoApi:setBuyedTb()
end

function acDoubleOneTabTwo:initPageFlag()
    local leftPlaceWidth  = nil
    local needPosWidht    = nil
    local rightPlaceWidth = nil
    leftPlaceWidth        = 40
    needPosWidht    = self.bgLayer:getContentSize().width*0.14
    rightPlaceWidth = self.bgLayer:getContentSize().width*0.03
    local heightPos = G_VisibleSizeHeight-190

    for i=1,self.showIdx do
        local needWidth = 120 + (G_VisibleSizeWidth - 240)/(self.showIdx+1)*i--需要调整 30 + (G_VisibleSizeWidth - 60)/(total+1)*i
        table.insert(self.pageFlagPosXTb,needWidth)


        local pageFlag=CCSprite:createWithSpriteFrameName("circlenormal.png")
        pageFlag:setPosition(ccp(self.pageFlagPosXTb[i],heightPos))
        self.bgLayer:addChild(pageFlag,1)
    end
    self.curPageFlag=CCSprite:createWithSpriteFrameName("circleSelect.png")
    self.curPageFlag:setPosition(ccp(self.pageFlagPosXTb[1],heightPos))
    self.bgLayer:addChild(self.curPageFlag,2)
end

function acDoubleOneTabTwo:dispose( )
    
    self.bgLayer        =nil
    self.layerNum       =nil
    self.tv             =nil
    self.showIdx        =nil
    self.lList          ={}
    self.List           ={}
    self.switchTab      ={}
    self.upLayer        =nil
    self.curSellTab     ={}
    self.pageFlagPosXTb ={}
    self.curPageFlag    =nil
    self.version        =nil
end