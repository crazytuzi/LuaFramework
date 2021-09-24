acDouble11Tab2 ={}
function acDouble11Tab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil
    self.showIdx =nil
    self.lList={}
    self.List={}
    self.switchTab={}
    self.upLayer=nil
    self.curSellTab={}
    self.pageFlagPosXTb={}
    self.curPageFlag=nil
    self.version =1
    return nc;

end
function acDouble11Tab2:init(layerNum)
    self:secondSocket()
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum
    self.version = acDouble11VoApi:getVersion()
    self.switchTab,self.showIdx =acDouble11VoApi:getSwitchTab()   --目前是假数据     需要根据后台返回告知几个开启，具体开启是什么
    -- self:initTableView()
    -- self:initPageFlag()
    self:initAllDialog()

    return self.bgLayer
end


function acDouble11Tab2:secondSocket( )
    if acDouble11VoApi:isInTime( ) then
      self.isbeginS=false
      local isInTime,curTime = acDouble11VoApi:isInTime( )
      local otherData,shop = acDouble11VoApi:returWhiPanicShop( ) --    根据配置 时间  自己计算 进入游戏时当前的抢购商店为第几个
      local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.double11 then
                if sData.data.double11.buyshop then
                     acDouble11VoApi:setbuyShopNums(sData.data.double11.buyshop)
                end
            end
        end
      end
      socketHelper:double11PanicBuying( getRawardCallback,"getbuyShop",nil,nil,curTime)
    end
end


function acDouble11Tab2:initAllDialog( )
    if  self.version ~=4 then
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
    end

    local function click(hd,fn,idx)
    end
    local cnNewYearBg =nil
    if self.version ==2 then--元旦版背景图-- 
        local rect=CCRect(0,0,612,466)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        cnNewYearBg= LuaCCScale9Sprite:create("public/acCnNewYearImage/cnNewYearBg.jpg",rect,CCRect(100, 150, 1, 1),click);
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        local rect2=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-200)
        cnNewYearBg:setContentSize(rect2)
        cnNewYearBg:setAnchorPoint(ccp(0.5,1))
        cnNewYearBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight-162))
        self.bgLayer:addChild(cnNewYearBg)
    end

    for i=1,self.showIdx do
        local atDialog=acDouble11SellDialog:new(self)
        local layer=atDialog:init(self.layerNum,i,1)
        self.bgLayer:addChild(layer,1)

        layer:setPosition(ccp(0,0))

        self.lList[i]=layer
        self.List[i]=atDialog
    end

    self.upLayer=pageDialog:new()
    local page=1
    local isShowBg=false
    local isShowPageBtn=false
    local function onPage(topage)
        print("~~~~~topage:",topage)
        self.curSellTab=self.List[topage]
        -- self.curPageFlag:setPositionX(self.pageFlagPosXTb[topage])
    end
    -- local posY=(G_VisibleSizeHeight-155-((G_VisibleSizeHeight-160)/3+40))/2+(G_VisibleSizeHeight-160)/3+40
    -- local posY = G_VisibleSizeHeight*0.5-50
    local posY = G_VisibleSizeHeight*0.4
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(self.bgLayer:getContentSize().width-40,posY)
    local specialTb = {}
    specialTb[1] =true
    specialTb[2] =2
    specialTb[3] ={}
    specialTb[3][1] ="double11"
    specialTb[3][2] =self.showIdx
    specialTb[4] = self.version == 2 and 300 or 255
    self.upLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,0),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,40),self.layerNum,page,self.lList,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,nil,nil,nil,nil,nil,specialTb)--iconStr = "double11_pic_"..k
    self.curSellTab=self.List[1]

    local maskSpHeight=self.bgLayer:getContentSize().height-133
    for k=1,3 do
        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        leftMaskSp:setAnchorPoint(ccp(0,0))
        -- leftMaskSp:setPosition(0,pos.y+25)
        leftMaskSp:setPosition(0,38)
        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
        self.bgLayer:addChild(leftMaskSp,6)

        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        -- rightMaskSp:setRotation(180)
        rightMaskSp:setFlipX(true)
        rightMaskSp:setAnchorPoint(ccp(0,0))
        -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
        rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
        self.bgLayer:addChild(rightMaskSp,6)
    end
    if (self.version ==4 or self.version >= 5) then
        local subHeightMask = 160
        local sideHeight = G_VisibleSizeHeight-186
        if self.version == 4 then
            local topSide = LuaCCScale9Sprite:createWithSpriteFrameName("goldenSide1.png",CCRect(40, 5, 1, 1),function() end);
            topSide:setContentSize(CCSizeMake(G_VisibleSizeWidth - 44,10))
            topSide:setPosition(ccp(G_VisibleSizeWidth*0.5,self.bgLayer:getContentSize().height - subHeightMask))
            self.bgLayer:addChild(topSide)

            local sidePic = LuaCCScale9Sprite:createWithSpriteFrameName("goldenSide2.png",CCRect(8, 3, 1, 1),function() end);
            sidePic:setContentSize(CCSizeMake(sideHeight,7))
            sidePic:setRotation(90)
            sidePic:setAnchorPoint(ccp(0,1))
            sidePic:setPosition(ccp(topSide:getPositionX() - topSide:getContentSize().width*0.5+6,self.bgLayer:getContentSize().height - subHeightMask+4))
            self.bgLayer:addChild(sidePic)

            local sidePic2 = LuaCCScale9Sprite:createWithSpriteFrameName("goldenSide2.png",CCRect(8, 3, 1, 1),function() end);
            sidePic2:setContentSize(CCSizeMake(sideHeight,7))
            sidePic2:setRotation(-90)
            sidePic2:setAnchorPoint(ccp(1,1))
            sidePic2:setPosition(ccp(topSide:getPositionX() + topSide:getContentSize().width*0.5-6,self.bgLayer:getContentSize().height - subHeightMask+4))
            self.bgLayer:addChild(sidePic2)

            local subWidht =42-- G_isIphone5() and 44 or 44
            local addHeight =8-- G_isIphone5() and 0 or 10
            local topSide2 = LuaCCScale9Sprite:createWithSpriteFrameName("goldenSide1.png",CCRect(40, 5, 1, 1),function() end);
            topSide2:setRotation(180)
            topSide2:setContentSize(CCSizeMake(G_VisibleSizeWidth - subWidht,10))
            topSide2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.bgLayer:getContentSize().height - subHeightMask - sideHeight + addHeight))
            self.bgLayer:addChild(topSide2)
        elseif self.version >= 5 then
            local borderSide1 = LuaCCScale9Sprite:createWithSpriteFrameName("greenBorder_2.png",CCRect(8, 8, 1, 1),function() end);
            borderSide1:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,sideHeight))
            borderSide1:setAnchorPoint(ccp(0.5,1))
            borderSide1:setPosition(ccp(G_VisibleSizeWidth*0.5,self.bgLayer:getContentSize().height - subHeightMask + 5))
            self.bgLayer:addChild(borderSide1,90)
        end
    end
end
function acDouble11Tab2:tick( )
    if self.showIdx then
        for i=1,self.showIdx do
            if self.lList[i] then
                self.List[i]:tick()
            end
        end
    end
end
function acDouble11Tab2:initPageFlag()
    local leftPlaceWidth = nil
    local needPosWidht = nil
    local rightPlaceWidth = nil
    leftPlaceWidth = 40
    needPosWidht = self.bgLayer:getContentSize().width*0.14
    rightPlaceWidth = self.bgLayer:getContentSize().width*0.03
    local heightPos = G_VisibleSizeHeight-190
    if self.version ==2 then
        heightPos =50
        local titleBg222=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
        titleBg222:setContentSize(CCSizeMake(G_VisibleSizeWidth-80,60))
        titleBg222:setAnchorPoint(ccp(0.5,0))
        titleBg222:setPosition(ccp(G_VisibleSizeWidth*0.5,30))
        self.bgLayer:addChild(titleBg222,1)
    end
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

function acDouble11Tab2:dispose( )
    
    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil
    self.showIdx =nil
    self.lList={}
    self.List={}
    self.switchTab={}
    self.upLayer=nil
    self.curSellTab={}
    self.pageFlagPosXTb={}
    self.curPageFlag=nil
    self.version =nil
end