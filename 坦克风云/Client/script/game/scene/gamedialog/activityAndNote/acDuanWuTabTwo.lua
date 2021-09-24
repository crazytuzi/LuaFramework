acDuanWuTabTwo = {}

function acDuanWuTabTwo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
    nc.tv        = nil
    nc.bgLayer   = nil
    nc.isIphone5 = G_isIphone5()

    nc.timeLb       = nil
    nc.bgWidth      = 0
    nc.upPosY       = G_VisibleSizeHeight-160
    nc.upHeight     = 222
    nc.middlePosY   = nil
    nc.middleHeight = nil
    nc.cellHeight   = nil
    nc.propNums     = 0
    nc.shopList     = {}
    nc.buyedList    = {}
    nc.columnNums   = 0
    nc.adaH = G_getIphoneType() == G_iphoneX and 100 or 0
    nc.url              = G_downloadUrl("active/".."acDuanWuBg.jpg") or nil
    nc.ver              = acDuanWuVoApi:getVersion( )
    return nc    
end

function acDuanWuTabTwo:dispose( )
    -- if self.sellShowSureDialog and self.sellShowSureDialog.close then
    --     self.sellShowSureDialog:close()
    -- end
    self.url        = nil
    self.ver        = nil
    self.adaH       = nil
    self.columnNums = nil
    self.cellHeight = nil
    self.propNums   = nil
    self.shopList   = nil
    self.buyedList  = nil
    self.middlePosY   = nil
    self.middleHeight = nil
    self.upPosY       = nil
    self.upHeight     = nil
    self.timeLb       = nil
    self.bgWidth      = nil
    self.tv           = nil
    self.bgLayer      = nil
    self.layerNum     = nil
    self.isIphone5    = nil
end

function acDuanWuTabTwo:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self.bgWidth  = self.bgLayer:getContentSize().width-40
    if self.ver ~= 1 then
        self.url = G_downloadUrl("active/".."acDuanWuBg_v2.jpg") or nil
    end
    self:refresh()
    self:initUp()
    self:initShop()
    return self.bgLayer
end

function acDuanWuTabTwo:refresh( )
    self.propNums,self.shopList,self.buyedList = acDuanWuVoApi:formatShop()
    self.columnNums = self.propNums/3 + (self.propNums%3 > 0 and 1 or 0)
    self.cellHeight = self.columnNums * G_VisibleSizeHeight*0.18
    if G_getIphoneType() == G_iphone4 then
        self.cellHeight = self.columnNums * G_VisibleSizeHeight*0.22
    end
    if self.tv then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end
function acDuanWuTabTwo:initUrl( )
    local function onLoadIcon(fn,icon)
        icon:setAnchorPoint(ccp(0.5,1))
        icon:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
        self.bgLayer:addChild(icon)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end
function acDuanWuTabTwo:initUp( )
    self:initUrl()

    local strSize2 = G_isAsia() and 25 or 20
    local upBG = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    upBG:setOpacity(0)
    upBG:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.upHeight))
    upBG:setAnchorPoint(ccp(0.5,1))
    upBG:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
    self.bgLayer:addChild(upBG,1)

    local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setOpacity(255*0.6)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.upHeight)
    upBG:addChild(timeBg)

    local timeStrSize = G_isAsia() and 24 or 21
    local acLabel     = GetTTFLabel(acDuanWuVoApi:getTimer(),22,"Helvetica-bold")
    acLabel:setPosition(ccp(G_VisibleSizeWidth *0.5, self.upHeight - 25))
    upBG:addChild(acLabel,1)
    acLabel:setColor(G_ColorYellowPro2)
    self.timeLb=acLabel

    local upDesc = GetTTFLabelWrap(getlocal("activity_duanwu_upDesc2"),20,CCSizeMake(upBG:getContentSize().width-260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    upDesc:setAnchorPoint(ccp(0.5,0))
    upDesc:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.upHeight * 0.32))
    upBG:addChild(upDesc,1)

    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acDuanWuVoApi:showInfoTipTb(self.layerNum + 1)
    end
    local i1,i2 = "LotusLeafIcon1.png","LotusLeafIcon2.png"
    if self.ver ~= 1 then
        i1,i2 = "i_sq_Icon1.png","i_sq_Icon2.png"
    end
    local menuItemDesc=GetButtonItem(i1,i2,i1,touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    -- menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-10, self.upHeight - 10))
    upBG:addChild(menuDesc,2)

    local touchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 200,self.upHeight))
    touchBg:setTouchPriority(-(self.layerNum-1)*20-10)
    touchBg:setAnchorPoint(ccp(0.5,0))
    touchBg:setIsSallow(true)
    touchBg:setPosition(G_VisibleSizeWidth * 0.5 , 0)
    touchBg:setOpacity(0)
    upBG:addChild(touchBg,10)

    if self.ver ~= 1 then
        local tipPic = CCSprite:createWithSpriteFrameName("propTip1_4.png")
        tipPic:setAnchorPoint(ccp(1,0))
        tipPic:setPosition(G_VisibleSizeWidth - 15,15)
        upBG:addChild(tipPic)
    end
end

function acDuanWuTabTwo:initShop( )
    self.middlePosY = self.upPosY - self.upHeight
    self.middleHeight = self.middlePosY - G_VisibleSizeHeight * 0.01

    local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    middleBg:setContentSize(CCSizeMake(self.bgWidth,self.middleHeight))
    middleBg:setAnchorPoint(ccp(0.5,1))
    middleBg:setPosition(G_VisibleSizeWidth * 0.5,self.middlePosY)
    self.bgLayer:addChild(middleBg)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgWidth,self.middleHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(0,0)
    middleBg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(150)
end

function acDuanWuTabTwo:socketBuy(buyId,needGems,sParent,rewardData,layerNum)
    local function refreshSelf( )
        self:refresh()
    end 
    acDuanWuVoApi:socketBuy(refreshSelf,buyId,needGems,sParent,rewardData,layerNum)
end
function acDuanWuTabTwo:tick( )
    if self.timeLb then
        self.timeLb:setString(acDuanWuVoApi:getTimer())
    end
end
function acDuanWuTabTwo:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.bgWidth,self.cellHeight + 10)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local shop = self.shopList

        local jiangeW = 200
        local jiangeH = 210
        local listStartH = self.cellHeight + 10
        local listCenterW = self.bgWidth * 0.5

        for i=1,self.columnNums do
            for j=1,3 do
                local tag=(i-1)*3 + j
                local shopCfg=shop[tag]
                local oldIdx = shopCfg.oldIdx
                local buyedTiems = (oldIdx and self.buyedList["i"..oldIdx]) and self.buyedList["i"..oldIdx] or 0

                local function touchListItem(curTag,object)
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    local giftId=tag
                    PlayEffect(audioCfg.mouseClick)
                    if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        print("tag---curTag---->>>>>>",tag,curTag)
                        local costNum, halfNum = shop[curTag].price, math.floor(shop[curTag].price * shop[curTag].dis)
                        local oldIdx = shop[tag].oldIdx
                        -- print("shop[tag].oldIdx===>>>",shop[tag].oldIdx)
                        local rewardData = FormatItem(shop[curTag].reward)[1]
                        local function sureBuyCall(sParent)
                            self:socketBuy(oldIdx,halfNum,sParent,rewardData,self.layerNum+1)
                        end
                        local td=sellShowSureDialog:new()
                        td:init(sureBuyCall,nil,false,costNum,halfNum,"duanwu",0,sceneGame,rewardData,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,true)

                        -- self.sellShowSureDialog = td
                        -- print("self.sellShowSureDialog and self.sellShowSureDialog.isSpe ===>>>",self.sellShowSureDialog , self.sellShowSureDialog.isSpe )
                        -- if self.sellShowSureDialog and self.sellShowSureDialog.isSpe and self.sellShowSureDialog.isSpe =="duanwu" then
                        --     print " is close????"
                        --     if self.sellShowSureDialog.close then
                        --         print " real close@@@@#######"
                        --         self.sellShowSureDialog:close()
                        --     end
                        -- end
                    end
                end
                local menuSpName="superShopBg1.png"
                local menuSp1=CCSprite:createWithSpriteFrameName(menuSpName)
                local menuSp2=CCSprite:createWithSpriteFrameName(menuSpName)
                local menuSp3=GraySprite:createWithSpriteFrameName(menuSpName)
                local upSp=CCSprite:createWithSpriteFrameName("superShopBg_down.png")
                menuSp2:addChild(upSp)
                upSp:setPosition(getCenterPoint(menuSp2))
                local listItem=CCMenuItemSprite:create(menuSp1,menuSp2,menuSp3)
                listItem:registerScriptTapHandler(touchListItem)
                listItem:setTag(tag)
                listItem:setAnchorPoint(ccp(0.5,1))
                -- self.listItemTb[tag]=listItem
                local listMenu = CCMenu:createWithItem(listItem)
                listMenu:setTouchPriority(-(self.layerNum-1)*20-3)
                -- listMenu:setIsSallow(false)
                listMenu:setPosition(listCenterW+(j-2)*jiangeW,listStartH-(i-1)*jiangeH-self.adaH)
                cell:addChild(listMenu)

                local r=shopCfg.reward
                local rewardItem=FormatItem(r)[1]
                
                local icon,scale=G_getItemIcon(rewardItem,80,false,self.layerNum,nil)
                icon:setPosition(listItem:getContentSize().width/2,138)
                listItem:addChild(icon)

                local bgName = self.ver == 1 and "LotusLeafTag.png" or "saleRedBg.png"
                local redBg=CCSprite:createWithSpriteFrameName(bgName)
                redBg:setPosition(listItem:getContentSize().width-25,listItem:getContentSize().height-30)
                -- redBg:setRotation(20)
                listItem:addChild(redBg)

                local discount= (1 - shopCfg.dis) * 100
                local discountLb=GetTTFLabel("-"..discount.."%",22,"Helvetica-bold")
                discountLb:setRotation(20)
                discountLb:setColor(G_ColorYellow)
                discountLb:setPosition(redBg:getContentSize().width/2-1,redBg:getContentSize().height/2+1)
                redBg:addChild(discountLb)

                local strSize3 = 20
                if G_isAsia() then
                    strSize3 = 22
                elseif G_getCurChoseLanguage() =="fr" then
                    strSize3 = 17
                end

                local useBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                useBg:setContentSize(CCSizeMake(listItem:getContentSize().width - 20,24))
                listItem:addChild(useBg)
                useBg:setPosition(listItem:getContentSize().width * 0.5,20)

                local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
                iconGold:setAnchorPoint(ccp(0,0.5))
                iconGold:setPosition(10,20)
                listItem:addChild(iconGold)
                local originPriceLb=GetTTFLabel(shopCfg.price,22)
                originPriceLb:setColor(G_ColorRed)
                originPriceLb:setAnchorPoint(ccp(0,0.5))
                originPriceLb:setPosition(15 + iconGold:getContentSize().width,20)
                listItem:addChild(originPriceLb)
                local lineWhite=CCSprite:createWithSpriteFrameName("white_line.png")
                lineWhite:setColor(G_ColorRed)
                lineWhite:setScaleX((originPriceLb:getContentSize().width + 10)/lineWhite:getContentSize().width)
                lineWhite:setPosition(originPriceLb:getPositionX() + originPriceLb:getContentSize().width/2,17)
                listItem:addChild(lineWhite)

                local colorP=G_ColorWhite
                local priceSteSize = 22

                local priceLb=GetTTFLabel(math.floor(shopCfg.price * shopCfg.dis),priceSteSize)
                priceLb:setAnchorPoint(ccp(1,0.5))
                priceLb:setPosition(listItem:getContentSize().width - 10,20)
                listItem:addChild(priceLb)
                priceLb:setColor(colorP)

                local showBugTimes = buyedTiems.."/"..shopCfg.maxLimit
                local wordShow = GetTTFLabel(getlocal("canBuy").." "..showBugTimes,19)
                wordShow:setPosition(listItem:getContentSize().width/2,63)
                wordShow:setColor(G_ColorYellowPro2)
                if buyedTiems == shopCfg.maxLimit then
                    wordShow:setColor(G_ColorRed)

                    local function showTip()
                    end
                    blackBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),showTip)
                    blackBg:setTouchPriority(-(self.layerNum-1)*20-3)
                    blackBg:setContentSize(listItem:getContentSize())
                    blackBg:setAnchorPoint(ccp(0,0))
                    blackBg:setPosition(0,0)
                    blackBg:setOpacity(100)
                    listItem:addChild(blackBg,2)

                    buyLb=GetTTFLabelWrap(getlocal("hasBuy"),22,CCSizeMake(listItem:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    listItem:addChild(buyLb,4)
                    buyLb:setPosition(listItem:getContentSize().width/2,138)
                    buyLb:setColor(G_ColorRed)

                    lbBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
                    listItem:addChild(lbBg,3)
                    lbBg:setPosition(listItem:getContentSize().width/2,138)
                end
                listItem:addChild(wordShow,5)
            end
        end
        
        return cell
    end
end