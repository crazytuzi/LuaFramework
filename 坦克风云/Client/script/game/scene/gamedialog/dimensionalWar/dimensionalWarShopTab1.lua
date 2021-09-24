dimensionalWarShopTab1={}

function dimensionalWarShopTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=layerNum

    self.cellHeght=230

    if G_getIphoneType() == G_iphoneX then
        self.cellHeght = 176
    end

    self.hSpace=10
    self.maskSp=nil
    self.myFeatLb=nil
    self.isToday=true

    return nc
end

function dimensionalWarShopTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initLayer()
    return self.bgLayer
end

function dimensionalWarShopTab1:initLayer()
    self:initTableView()
end

function dimensionalWarShopTab1:initTableView()
    -- self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))
    -- self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,G_VisibleSize.height-105))

    self:initDesc()

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,self.bgLayer:getContentSize().height-290-self.hSpace-35-60),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,30+60))
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)

    self:tick()
end

function dimensionalWarShopTab1:initDesc()
    local myFeatDescLb=GetTTFLabel(getlocal("serverwar_my_point"),28)
    myFeatDescLb:setColor(G_ColorGreen)
    myFeatDescLb:setAnchorPoint(ccp(0,0.5))
    myFeatDescLb:setPosition(ccp(30,G_VisibleSizeHeight-180-self.hSpace))
    self.bgLayer:addChild(myFeatDescLb)
    self.myFeatLb=GetTTFLabel(dimensionalWarVoApi:getPoint(),28)
    self.myFeatLb:setAnchorPoint(ccp(0,0.5))
    self.myFeatLb:setPosition(ccp(40+myFeatDescLb:getContentSize().width,G_VisibleSizeHeight-180-self.hSpace))
    self.bgLayer:addChild(self.myFeatLb)

    local str=getlocal("dimensionalWar_shop_desc")
    -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local descLb=GetTTFLabelWrap(str,25,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(ccp(30,G_VisibleSizeHeight-225-self.hSpace-20))
    -- descLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(descLb)

    local function showInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local tabStr={"\n",getlocal("dimensionalWar_point_shop_desc3"),"\n",getlocal("dimensionalWar_point_shop_desc2"),"\n",getlocal("dimensionalWar_point_shop_desc1"),"\n"};
        local tabColor={nil,G_ColorRed,nil,G_ColorYellow,nil,G_ColorYellow,nil}
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-210-self.hSpace-30))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(infoBtn)

    local resetStr=getlocal("dimensionalWar_shop_reset")
    -- resetStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local resetLb=GetTTFLabelWrap(resetStr,25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    resetLb:setAnchorPoint(ccp(0,0.5))
    resetLb:setPosition(ccp(30,55))
    resetLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(resetLb)
end

function dimensionalWarShopTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local shopList=dimensionalWarVoApi:getShopList()
        local num=SizeOfTable(shopList)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(G_VisibleSizeWidth-60,self.cellHeght)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-65,self.cellHeght))
        backSprie:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.cellHeght/2))
        backSprie:setTouchPriority(-(self.layerNum-1)*20-1)

        local showList=dimensionalWarVoApi:getShopList()
        local shopVo=showList[idx+1]
        local id=shopVo.id
        local num=shopVo.num or 0
        
        local shopItems=dimensionalWarVoApi:getShopItems()
        local cfg=shopItems[id]
        local rewardTb=FormatItem(cfg.reward)
        local price=cfg.price
        local maxNum=cfg.buynum

        local nameStrTb={}
        for k,v in pairs(rewardTb) do
            table.insert(nameStrTb,v.name.." x"..FormatNumber(v.num))
        end
        local nameLb=GetTTFLabel(table.concat(nameStrTb, ", "),25)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setColor(G_ColorGreen)
        nameLb:setPosition(ccp(10,(self.cellHeght/2+50+self.cellHeght)/2))
        backSprie:addChild(nameLb)

        local limitLb=GetTTFLabel("("..num.."/"..maxNum..")",25)
        limitLb:setAnchorPoint(ccp(0,0.5))
        limitLb:setPosition(ccp(10+nameLb:getContentSize().width+5,(self.cellHeght/2+50+self.cellHeght)/2))
        backSprie:addChild(limitLb)

        local award=rewardTb[1]
        local iconSize=100
        local icon=G_getItemIcon(award,iconSize,false,self.layerNum)
        if icon then
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(ccp(10,self.cellHeght/2-10))
            backSprie:addChild(icon)
        end

        local descLb=GetTTFLabelWrap(getlocal(rewardTb[1].desc),22,CCSizeMake(G_VisibleSizeWidth-335,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,1))
        descLb:setPosition(ccp(130,self.cellHeght/2+40))
        backSprie:addChild(descLb)

        local priceDescLb=GetTTFLabel(getlocal("serverwar_point"),25)
        priceDescLb:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght*3/4))
        backSprie:addChild(priceDescLb)

        local priceLb=GetTTFLabel(price,25)
        priceLb:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght/2+10))
        if(dimensionalWarVoApi:getPoint()<price)then
            priceLb:setColor(G_ColorRed)
        else
            priceLb:setColor(G_ColorYellowPro)
        end
        backSprie:addChild(priceLb)

        local function onClick(tag,object)
            if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                local showList=dimensionalWarVoApi:getShopList()
                local shopVo=showList[idx+1]
                local id=shopVo.id
                local num=shopVo.num or 0
                if(num>=maxNum)then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_buy_num_full"),30)
                    do return end
                end
                if(dimensionalWarVoApi:getPoint()<price)then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_point_not_enough"),30)
                    do return end
                end
                self:buyItem(shopVo)
            end
        end
        local buyItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onClick,nil,getlocal("code_gift"),25)
        buyItem:setTag(idx+1)
        buyItem:setScale(0.8)
        if(num>=maxNum)then
            buyItem:setEnabled(false)
        end
        local buyBtn = CCMenu:createWithItem(buyItem)
        buyBtn:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght/4))
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:addChild(buyBtn)

        cell:addChild(backSprie,1)
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function dimensionalWarShopTab1:buyItem(shopVo)
    local id=shopVo.id
    local num=shopVo.num
    local shopItems=dimensionalWarVoApi:getShopItems()
    local cfg=shopItems[id]
    local rewardTb=FormatItem(cfg.reward)
    local price=cfg.price
    local maxNum=cfg.buynum

    if (num<maxNum) and (dimensionalWarVoApi:getPoint()>=price) then
        local function callback()
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
            self:tick()
            dimensionalWarVoApi:setPointDetailFlag(-1)
            local lastBuyTime=dimensionalWarVoApi:getLastBuyTime()
            self.isToday=G_isToday(lastBuyTime)
        end
        dimensionalWarVoApi:buyItem(id,callback)
    end
end

function dimensionalWarShopTab1:doUserHandler()

end

function dimensionalWarShopTab1:tick()
    if self and self.myFeatLb then
        self.myFeatLb:setString(dimensionalWarVoApi:getPoint())
    end
    local lastBuyTime=dimensionalWarVoApi:getLastBuyTime()
    local isBuyToday=G_isToday(lastBuyTime)
    if self.isToday~=isBuyToday and isBuyToday==false then
        dimensionalWarVoApi:resetBuyNum()
        self.isToday=isBuyToday
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function dimensionalWarShopTab1:refresh()

end

function dimensionalWarShopTab1:dispose()
    self.isToday=true
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeght=nil
    self.hSpace=nil
    self.maskSp=nil
    self.descLb=nil
    self.myFeatLb=nil
end






