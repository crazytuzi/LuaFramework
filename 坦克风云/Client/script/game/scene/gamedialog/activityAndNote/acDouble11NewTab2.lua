acDouble11NewTab2 ={} 
function acDouble11NewTab2:new()
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
function acDouble11NewTab2:init(layerNum)
    self:secondSocket()
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum
    self.version = acDouble11NewVoApi:getVersion()
    self.switchTab,self.showIdx =acDouble11NewVoApi:getSwitchTab()   --目前是假数据     需要根据后台返回告知几个开启，具体开启是什么
    -- self:initTableView()
    -- self:initPageFlag()
    self:initAllDialog()

    return self.bgLayer
end


function acDouble11NewTab2:secondSocket( )
    if acDouble11NewVoApi:isInTime( ) then
      local isInTime,curTime = acDouble11NewVoApi:isInTime( )
      self.isbeginS=false
      local otherData,shop = acDouble11NewVoApi:returWhiPanicShop( ) --    根据配置 时间  自己计算 进入游戏时当前的抢购商店为第几个
      local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.double11new then
                if sData.data.double11new.buyshop then
                     acDouble11NewVoApi:setbuyShopNums(sData.data.double11new.buyshop)
                end
            end
        end
      end
      socketHelper:double11NewPanicBuying( getRawardCallback,"getbuyShop",nil,nil,curTime)
    end
end


function acDouble11NewTab2:initAllDialog( )
    local function click(hd,fn,idx)
    end
    local bigBg =CCSprite:create("public/superWeapon/weaponBg.jpg")
    bigBg:setScaleX((G_VisibleSizeWidth-42)/bigBg:getContentSize().width)
    bigBg:setScaleY((G_VisibleSizeHeight-186)/bigBg:getContentSize().height)
    bigBg:ignoreAnchorPointForPosition(false)
    bigBg:setOpacity(150)
    bigBg:setAnchorPoint(ccp(0.5,0.5))
    bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5-68))
    self.bgLayer:addChild(bigBg)



    for i=1,self.showIdx do
        local atDialog=acDouble11NewSellDialog:new(self)
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
    specialTb[2] =3
    specialTb[3] ={}
    specialTb[3][1] ="double11"
    specialTb[3][2] =self.showIdx
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

end
function acDouble11NewTab2:tick( )
    if self.showIdx then
        for i=1,self.showIdx do
            if self.lList[i] then
                self.List[i]:tick()
            end
        end
    end
end
function acDouble11NewTab2:initPageFlag()
    local leftPlaceWidth = nil
    local needPosWidht = nil
    local rightPlaceWidth = nil
    leftPlaceWidth = 40
    needPosWidht = self.bgLayer:getContentSize().width*0.14
    rightPlaceWidth = self.bgLayer:getContentSize().width*0.03
    local heightPos = G_VisibleSizeHeight-190
    -- if self.version ==2 then
    --     heightPos =50
    --     local titleBg222=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
    --     titleBg222:setContentSize(CCSizeMake(G_VisibleSizeWidth-80,60))
    --     titleBg222:setAnchorPoint(ccp(0.5,0))
    --     titleBg222:setPosition(ccp(G_VisibleSizeWidth*0.5,30))
    --     self.bgLayer:addChild(titleBg222,1)
    -- end
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

function acDouble11NewTab2:dispose( )
    
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