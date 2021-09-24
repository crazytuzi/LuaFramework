allPropDialog=commonDialog:new()

function allPropDialog:new(layerNum,initShopNum,shopType,callBack1,subTabIndex,showItemId)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.layerNum=layerNum
    nc.curShopNum = initShopNum
    nc.curShopType = shopType
    nc.leftTv         = nil
    nc.rTv            = nil
    nc.shopNum        = nil
    nc.shopNameTb     = {}
    nc.unTouchBtnSpTb = {}
    nc.shopBtnSpTb    = {}
    nc.shopShowNameTb = {}
    nc.callBack1 = callBack1
    nc.subLbBgTb = {}
    nc.subLbStrTb    = {}
    nc.curSubTabLbTb = {}
    nc.tagOffset     = 518 --军团商店使用
    nc.featTagOffset = 518
    nc.countdown     = nil
    nc.countdown2    = nil
    nc.cutOver = false
    nc.diffIsToday   = true
    nc.diffCallbackNum = 0
    nc.chooseLshopBgTb = {}
    nc.needSocket = {army={false,true},drill=true,expe=true,diff=true}--切签限制后台请求，只能请求一次
    nc.sTimeTb    = {drill=0} -- 个别商店
    nc.subTabIndex = subTabIndex
    nc.showItemId = showItemId
    return nc
end
function allPropDialog:dispose()
    if self and self.callBack1 then
        self.callBack1()
    end
    self:removeListener(self.curShopType,self.useSubTabNum)
    self.tskinSaleTip   = nil
    self.layerNum       = nil
    self.curShopNum     = nil
    self.curShopType    = nil
    self.leftTv         = nil
    self.rTv            = nil
    self.shopNum        = nil
    self.shopNameTb     = nil
    self.unTouchBtnSpTb = nil
    self.shopBtnSpTb    = nil
    self.shopShowNameTb = nil
    self.subLbBgTb      = nil
    self.subLbStrTb     = nil
    self.curSubTabLbTb  = nil
    self.tagOffset      = nil
    self.featTagOffset  = nil
    self.countdown      = nil
    self.countdown2     = nil
    self.diffIsToday    = nil
    self.diffCallbackNum = nil
    self.cutOver         = nil
    self.chooseLshopBgTb = nil
    self.needSocket      = nil
    self.sTimeTb         = nil
    self.curShopItem    = nil
    self.rShoppingBg    = nil
    self.useSubTabNum   = nil
    self.loadingTipBg   = nil
    self.featLimitTb    = nil
    self.freshBtn       = nil
    self.rightUpBg      = nil
    self.sIcon          = nil
    self.rTopDes1       = nil
    self.rTopDes2       = nil
    self.featBeginTime1 = nil
    self.featBeginTime2 = nil
    self.tipBtn         = nil
    self.gotoTipBtn     = nil
    self.goToItem       = nil
    self.goToTipDesc    = nil
    self.matrShopType   = nil
    self.featBuyLbTb    = nil
    self.rBtn           = nil
    self.panelLineBg    = nil
    self.cellLeftSize   = nil
    self.noRecordLb     = nil
    self.featBuyItemTb  = nil
    self.subTabIndex    = nil
    self.showItemId    = nil
    allShopVoApi:removeAllPlist()
    if allShopSmalDiaChooseUsed then
        allShopSmalDiaChooseUsed:close()
    end
end
function allPropDialog:addListener(selectShop,curSubTab )
    if selectShop == "feat" then
        local function featRefreshListener(event,data)
            self:featRefresh(data)
        end
        self.refreshListener=featRefreshListener
        eventDispatcher:addEventListener("rpShop.refresh",featRefreshListener)
    end
end
function allPropDialog:removeListener(selectShop,curSubTab )
    if selectShop == "feat" then
        eventDispatcher:removeEventListener("rpShop.refresh",self.refreshListener)
        self.refreshListener = nil
    end
end

function allPropDialog:doUserHandler()
    -- print("new allPropDialog self.layerNum====>>>>",self.layerNum)
    -- print("in doUserHandle       curShopType=====>>>",self.curShopType)
    local otherData = nil
    otherData,self.shopNameTb = allShopVoApi:getShopNum()
    self.shopNum = SizeOfTable(self.shopNameTb)
    self.panelLineBg:setVisible(false)
    self.cellLeftSize = CCSizeMake(110,110)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight - 80)

    
    local rShoppingBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    rShoppingBg:setContentSize(CCSizeMake(512,G_VisibleSizeHeight - 110))
    rShoppingBg:setPosition(ccp(G_VisibleSizeWidth - 10,20))
    rShoppingBg:setAnchorPoint(ccp(1,0))
    self.rShoppingBg = rShoppingBg
    self.bgLayer:addChild(rShoppingBg)

    self.loadingTipBg =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ( ) end)
    self.loadingTipBg:setContentSize(CCSizeMake(512,G_VisibleSizeHeight - 110))
    self.loadingTipBg:setPosition(ccp(G_VisibleSizeWidth - 10,20))
    self.loadingTipBg:setAnchorPoint(ccp(1,0))
    self.bgLayer:addChild(self.loadingTipBg,99)

    local loadingTip = GetTTFLabelWrap(getlocal("loadingDesc"),30,CCSizeMake(self.loadingTipBg:getContentSize().width - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.loadingTipBg:addChild(loadingTip)
    loadingTip:setColor(G_ColorGray)
    loadingTip:setPosition(ccp(self.loadingTipBg:getContentSize().width*0.5,self.loadingTipBg:getContentSize().height*0.6 + 25))

    self.loadingTipBg:setVisible(false)
    self.loadingTipBg:setPositionX(self.loadingTipBg:getPositionX() + G_VisibleSizeWidth*2)

    self.leftIconNameFontSize = 17
    if G_isAsia() then
        self.leftIconNameFontSize = 23
    end
    if self.curShopType then
        self:addListener(self.curShopType)
        self:refreshShopInfo(self.curShopType)
    end
end

function allPropDialog:initTableView( )
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local subHeight = G_isIphone5() and 160 or 140
    local tvHeight = G_VisibleSizeHeight - subHeight
    self.leftTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 514,tvHeight),nil)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.leftTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    -- local hNum = G_isIphone5() and 110 * (self.shopNum+1) + 20 or 110 * self.shopNum + 35
    -- -- print("hNum=======>>>>",hNum,110 * (self.shopNum+1) + 40)
    -- local iphoneType = G_getIphoneType()
    -- if iphoneType == G_iphoneX then
    --     hNum = hNum +110
    -- elseif iphoneType==G_iphone4 then
    --     hNum = hNum - 110
    -- elseif G_isIOS() == false or G_isIphone5() then
    --     hNum = hNum -30
    -- end
    -- print("self.shopNum,largeNum====>",self.shopNum,allShopVoApi:getLargeNum())
    -- local phoneTypeH = G_VisibleSizeHeight - hNum
    -- if G_isIOS() == false then
    --     phoneTypeH = 50
    -- elseif self.shopNum ~= allShopVoApi:getLargeNum() then
    --     phoneTypeH = phoneTypeH - 110 * (allShopVoApi:getLargeNum() - self.shopNum)
    -- end
    local tvPosY = 40
    self.leftTv:setPosition(ccp(10,tvPosY))
    self.bgLayer:addChild(self.leftTv)
    self.leftTv:setMaxDisToBottomOrTop(120)

    local miny,maxy = tvHeight - self.shopNum*self.cellLeftSize.height,0
    local jumpShopIdx = allShopVoApi:getShopNum(self.curShopType)
    local recordPoint = self.leftTv:getRecordPoint()
    recordPoint.y = recordPoint.y + jumpShopIdx*self.cellLeftSize.height - tvHeight
    if recordPoint.y > maxy then
        recordPoint.y = maxy
    elseif recordPoint.y < miny then
        recordPoint.y = miny
    end
    -- print("recordPoint.y---->",recordPoint.y)
    self.leftTv:recoverToRecordPoint(recordPoint)
end

function allPropDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        -- print("self.shopNum====eventHandler=================>>>",self.shopNum)
        return self.shopNum or 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=self.cellLeftSize
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local touchBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
        touchBg:setContentSize(self.cellLeftSize)
        touchBg:setAnchorPoint(ccp(0,0))
        touchBg:setOpacity(0)
        touchBg:setPosition(ccp(0,0))
        cell:addChild(touchBg)

        local cellShopIconName = ""
        local cellShopIconIdx = idx + 1
        for k,v in pairs(self.shopNameTb) do
            if v == cellShopIconIdx then
                cellShopIconName = tostring(k)
                do break end
            end            
        end
        local function shopRefreshCall(object,name,tag)
            -- if self.leftTv:getScrollEnable()==true and self.leftTv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                self:removeListener(self.curShopType)
                local selectShop = self.curShopType or ""
                if tag ~= self.curShopNum then
                    self.curShopNum = tag
                    for k,v in pairs(self.shopBtnSpTb) do
                        if k == tag then
                            selectShop = allShopVoApi:getShopTypeByIndex(k)
                            v:setColor(ccc3(255,255,255))
                            self.shopShowNameTb[k]:setColor(G_ColorWhite)
                            if self.chooseLshopBgTb[k] then
                                self.chooseLshopBgTb[k]:setVisible(true)
                            end
                            if selectShop == "tskin" and self.tskinSaleTipSp and allShopVoApi:tankSkinIsInSale() then
                                self.tskinSaleTipSp:setVisible(true)
                            elseif self.tskinSaleTipSp then
                                -- self.tskinSaleTipSp:setVisible(false)
                            end
                        else
                            v:setColor(G_ColorGray)
                            self.shopShowNameTb[k]:setColor(G_ColorYellowPro)
                            if self.chooseLshopBgTb[k] then
                                self.chooseLshopBgTb[k]:setVisible(false)
                            end
                        end
                    end
                end
                
                self.cutOver = true
                self.curShopType = selectShop
                self:addListener(self.curShopType)
                self:refreshShopInfo(selectShop)
                
            -- end
        end
        if cellShopIconName ~= "" then
            local shopBtnPic = allShopVoApi:getShopBtnPic(cellShopIconName)
            local scale = 1
            if cellShopIconName=="preferential" or cellShopIconName=="tskin" then
                scale = 0.8
            end
            local shopBtnSp = LuaCCSprite:createWithSpriteFrameName(shopBtnPic,shopRefreshCall)
            shopBtnSp:setPosition(getCenterPoint(touchBg))
            shopBtnSp:setTouchPriority(-(self.layerNum-1)*20-2)
            shopBtnSp:setIsSallow(false)
            shopBtnSp:setScale(scale)
            shopBtnSp:setTag(cellShopIconIdx)
            touchBg:addChild(shopBtnSp,1)
            shopBtnSp:setColor(G_ColorGray)
            self.shopBtnSpTb[cellShopIconIdx] = shopBtnSp

            local shopName = GetTTFLabelWrap(getlocal(allShopVoApi:getShopShowNameTb( )[cellShopIconName]),self.leftIconNameFontSize,CCSizeMake(self.cellLeftSize.width-4,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            shopName:setPosition(ccp(shopBtnSp:getContentSize().width*0.5,10))
            shopName:setColor(G_ColorYellowPro)
            shopName:setScale(1/shopBtnSp:getScale())
            shopBtnSp:addChild(shopName,1)
            self.shopShowNameTb[cellShopIconIdx] = shopName



            if self.curShopNum == cellShopIconIdx then
                shopBtnSp:setColor(ccc3(255,255,255))
                shopName:setColor(G_ColorWhite)
            end

            if G_isAsia() then
                local chooseLshopBg = CCSprite:createWithSpriteFrameName("rankTab_Down.png")
                chooseLshopBg:setPosition(ccp(touchBg:getPositionX()-6,touchBg:getPositionY() + 5))
                chooseLshopBg:setAnchorPoint(ccp(0,0))
                chooseLshopBg:setScaleX(0.94)
                chooseLshopBg:setScaleY(1.1)
                touchBg:addChild(chooseLshopBg)
                self.chooseLshopBgTb[cellShopIconIdx] = chooseLshopBg

                if self.curShopNum == cellShopIconIdx then
                    chooseLshopBg:setVisible(true)
                else
                    chooseLshopBg:setVisible(false)
                end
            end
            if cellShopIconName == "tskin" then

                local tickSp = CCSprite:createWithSpriteFrameName("sale_ticket.png")
                tickSp:setAnchorPoint(ccp(0,1))
                tickSp:setScale(0.8)
                tickSp:setPosition(touchBg:getPositionX() - 12,touchBg:getPositionY() + 110)
                touchBg:addChild(tickSp,2)

                self.tskinSaleTipSp = tickSp

                local tickLb = GetTTFLabel("SALE",22,true)
                tickLb:setPosition(tickSp:getContentSize().width * 0.5,tickSp:getContentSize().height * 0.5 + 3)
                tickSp:addChild(tickLb)
                if not allShopVoApi:tankSkinIsInSale() then
                    self.tskinSaleTipSp:setVisible(false)
                end
            end
        end

        return cell
    end
end

function allPropDialog:shopCanGoTipInfo(selectShop,otherNeed)
    if self.rShoppingBg then
        self.rShoppingBg:setVisible(false)
    end
    if self.goToTipBg then
        self.goToTipBg:setVisible(true)
    else
        self.goToTipBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ( ) end)
        self.goToTipBg:setContentSize(CCSizeMake(512,G_VisibleSizeHeight - 110))
        self.goToTipBg:setPosition(ccp(G_VisibleSizeWidth - 10,20))
        self.goToTipBg:setAnchorPoint(ccp(1,0))
        -- self.goToTipBg:setOpacity(0)
        self.bgLayer:addChild(self.goToTipBg)
    end

    if self.goToTipDesc == nil then--loadingDesc
        self.goToTipDesc = GetTTFLabelWrap("",33,CCSizeMake(self.goToTipBg:getContentSize().width - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.goToTipBg:addChild(self.goToTipDesc)
        self.goToTipDesc:setColor(G_ColorGray)
        self.goToTipDesc:setPosition(ccp(self.goToTipBg:getContentSize().width*0.5,self.goToTipBg:getContentSize().height*0.6 + 25))
         if selectShop == "feat" then
            self.goToTipDesc:setFontSize(30)
         end
    else
        if selectShop == "feat" then
            self.goToTipDesc:setFontSize(30)
        else
            self.goToTipDesc:setFontSize(33)
        end
    end

    self.otherNeed = otherNeed

    local function goToCall( )
        local curShopType = self.curShopType or selectShop
        activityAndNoteDialog:closeAllDialog()
        allShopVoApi:removeSelfAllDia()
        if curShopType == "army" then
            if self.otherNeed then
                -- require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
                -- local td=allianceDialog:new(1,3)
                -- G_AllianceDialogTb[1]=td
                -- local tbArr={getlocal("recommendList"),getlocal("alliance_list_scene_create")}
                -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
                -- sceneGame:addChild(dialog,self.layerNum)
                allianceVoApi:showAllianceDialog(self.layerNum,nil,1)
            else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("port_scene_building_tip_6"),30)
            end
        else
            storyScene:setShow()
            local sid=checkPointVoApi:getUnlockNum()
            require "luascript/script/game/scene/gamedialog/checkPointDialog"
            local cpd = checkPointDialog:new(sid)
            storyScene.checkPointDialog[1]=cpd
            local cd = cpd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("checkPoint"),true,self.layerNum+1)
            sceneGame:addChild(cd,self.layerNum+1)
        end
    end
    if self.gotoTipBtn == nil then
        local goToItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goToCall,nil,getlocal(""),35,11)
        goToItem:setScale(0.8)
        goToItem:setAnchorPoint(ccp(0.5,1))
        self.goToItem = goToItem
        self.gotoTipBtn=CCMenu:createWithItem(goToItem);
        self.gotoTipBtn:setTouchPriority(-(self.layerNum-1)*20-2);
        self.gotoTipBtn:setPosition(ccp(self.goToTipBg:getContentSize().width*0.5,self.goToTipBg:getContentSize().height*0.6 - 25))
        self.goToTipBg:addChild(self.gotoTipBtn)
    else
        self.gotoTipBtn:setVisible(true)
    end
    local btnLb = tolua.cast(self.goToItem:getChildByTag(11),"CCLabelTTF")
    if selectShop == "army" then
        self.goToTipDesc:setString(getlocal("joinAllianceCanUse"))
        btnLb:setString(getlocal("alliance_email_title3"))
    elseif selectShop == "feat" then
        self.goToTipDesc:setString(getlocal("rpshop_openTime"))
        self.gotoTipBtn:setVisible(false)
    else
        self.goToTipDesc:setString(getlocal("joinNeedLv",{otherNeed}))
        btnLb:setString(getlocal("getExperience"))
    end
end

function allPropDialog:refreshShopInfo(selectShop)
    local isShopOpen,otherNeed = allShopVoApi:isCanGo(selectShop)
    if isShopOpen == false then
        self:shopCanGoTipInfo(selectShop,otherNeed)
        do return end
    elseif self.rShoppingBg then
        if self.goToTipBg then
            self.goToTipBg:setVisible(false)
        end
        self.rShoppingBg:setVisible(true)
    end
    if selectShop ~= "" then
        if self.rightUpBg == nil then
            self.rightUpBg=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function ( ) end)
            self.rightUpBg:setContentSize(CCSizeMake(self.rShoppingBg:getContentSize().width - 8,128))
            self.rightUpBg:setPosition(ccp(self.rShoppingBg:getContentSize().width*0.5,self.rShoppingBg:getContentSize().height - 8 - self.rightUpBg:getContentSize().height*0.5))
            self.rShoppingBg:addChild(self.rightUpBg)
        end
        if self.sIcon then
            local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(allShopVoApi:getCurIconSpName(selectShop))
            if frame then
                tolua.cast(self.sIcon,"CCSprite"):setDisplayFrame(frame)
            end
        elseif self.sIcon == nil then
            self.sIcon = CCSprite:createWithSpriteFrameName(allShopVoApi:getCurIconSpName(selectShop))--小签上面的对应商店图标
            self.sIcon:setAnchorPoint(ccp(0,0.5))
            self.rightUpBg:addChild(self.sIcon)
        end
        
        if selectShop == "gems" or selectShop == "tskin" or selectShop == "preferential" then
            self.sIcon:setScale(1)
            self.sIcon:setPosition(ccp(30,self.rightUpBg:getContentSize().height*0.5))
            if selectShop == "tskin" then
                if self.goToBagBtn then
                    self.goToBagBtn:setVisible(false)
                    self.goToBagBtn:setEnabled(false)
                end
                if self.goToTankHouseBtn == nil then
                    self:initGoToTankHouse(self.rightUpBg)
                else
                    self.goToTankHouseBtn:setVisible(true)
                    self.goToTankHouseBtn:setEnabled(true)
                end
            else
                if self.goToTankHouseBtn then
                    self.goToTankHouseBtn:setVisible(false)
                    self.goToTankHouseBtn:setEnabled(false)
                end

                if self.goToBagBtn == nil then
                    self:initGoToBagBtn(self.rightUpBg)
                else
                    self.goToBagBtn:setVisible(true)
                    self.goToBagBtn:setEnabled(true)
                end
            end
        else
            self.sIcon:setScale(0.6)
            self.sIcon:setPosition(ccp(30,self.rightUpBg:getContentSize().height*0.7))
            if self.goToBagBtn then
                self.goToBagBtn:setVisible(false)
                self.goToBagBtn:setEnabled(false)
            end
            if self.goToTankHouseBtn then
                self.goToTankHouseBtn:setVisible(false)
                self.goToTankHouseBtn:setEnabled(false)
            end
        end

        local lb1,lb2 = allShopVoApi:getNeedrLb(selectShop)
        if self.rTopDes1 then
            self.rTopDes1:setString(lb1)
        else
            self.rTopDes1 = GetTTFLabel(lb1,24,"Helvetica-bold")
            self.rTopDes1:setAnchorPoint(ccp(0,0.5))            
            self.rightUpBg:addChild(self.rTopDes1)
        end
        if selectShop == "army" or selectShop == "diff" then
            self.sIcon:setVisible(false)
            self.rTopDes1:setPosition(ccp(self.sIcon:getPositionX(),self.sIcon:getPositionY()))
        else
            self.sIcon:setVisible(true)
            local sNum = (selectShop == "gems" or selectShop == "tskin" or selectShop == "preferential") and 1 or 0.6
            self.rTopDes1:setPosition(ccp(self.sIcon:getPositionX() + self.sIcon:getContentSize().width * sNum,self.sIcon:getPositionY()))
        end
        
        if selectShop == "tskin" and allShopVoApi:tankSkinIsInSale() then -- 有限时售卖
            self.tskinIsInTime = true
            if self.tskinSaleTip then
                self.tskinSaleTip:setVisible(true)
            else
                self:initTankSkinTipAndTime(self.rightUpBg)
            end
        elseif self.tskinSaleTip then
            self.tskinSaleTip:setVisible(false)
        end

        if lb2 then
            if self.rTopDes2 then
                self.rTopDes2:setString(lb2)
            else
                self.rTopDes2 = GetTTFLabelWrap(lb2,21,CCSizeMake(self.rightUpBg:getContentSize().width*0.9,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                self.rTopDes2:setAnchorPoint(ccp(0,0.5))
                self.rTopDes2:setColor(G_ColorYellowPro)
                self.rightUpBg:addChild(self.rTopDes2)
            end
            if self.curShopType == "seiko" and G_isAsia() == false then
                self.rTopDes2:setFontSize(18)
            else
                self.rTopDes2:setFontSize(21)
            end
            self.rTopDes2:setPosition(ccp(self.sIcon:getPositionX(),self.rightUpBg:getContentSize().height*0.3))
        elseif self.rTopDes2 then
            self.rTopDes2:removeFromParentAndCleanup(true)
            self.rTopDes2 = nil
        end
        if selectShop == "feat" then
            if self.featBeginTime1 and self.featBeginTime2 then
                self.featBeginTime1:setVisible(true)
                self.featBeginTime2:setVisible(true)
            else
                self:addFeatBeginTime()
            end
        else
            if self.featBeginTime1 and self.featBeginTime2 then
                self.featBeginTime1:setVisible(false)
                self.featBeginTime2:setVisible(false)
            end
        end
        if self.rBtn == nil then
                local function goToNewDiaCall()
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    -- print("self.curShopType,self.layerNum + 1====>>>",self.curShopType,self.layerNum + 1)
                    allShopVoApi:goToNewDia(self.curShopType,self.layerNum)
                end
                local rMenuItem=GetButtonItem("sYellowAddBtn.png","sYellowAddBtnDown.png","sYellowAddBtn.png",goToNewDiaCall)
                rMenuItem:setScale(0.7)
                rMenuItem:setAnchorPoint(ccp(0,0.5))
                self.rBtn=CCMenu:createWithItem(rMenuItem);
                self.rBtn:setTouchPriority(-(self.layerNum-1)*20-2);
                self.rBtn:setPosition(ccp(self.rTopDes1:getPositionX() + self.rTopDes1:getContentSize().width + 10,self.rTopDes1:getPositionY()))
                self.rightUpBg:addChild(self.rBtn)
        else
            self.rBtn:setPosition(ccp(self.rTopDes1:getPositionX() + self.rTopDes1:getContentSize().width + 10,self.rTopDes1:getPositionY()))
        end

        if self.tipBtn == nil then
            local function showTipDiaCall()
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                allShopVoApi:showTipDia(self.curShopType or "",self.useSubTabNum or 1,self.layerNum + 1)
            end
            local tipItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showTipDiaCall)
            tipItem:setScale(0.75)
            tipItem:setAnchorPoint(ccp(1,0.5))
            self.tipBtn=CCMenu:createWithItem(tipItem);
            self.tipBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            self.tipBtn:setPosition(ccp(self.rightUpBg:getContentSize().width - 20,self.rightUpBg:getContentSize().height*0.7))
            self.rightUpBg:addChild(self.tipBtn)
            if allShopVoApi:tipIsNotShow(selectShop) then
                self.tipBtn:setVisible(false)
            end
        else
            if allShopVoApi:tipIsNotShow(selectShop) then
                self.tipBtn:setVisible(false)
            else
                self.tipBtn:setVisible(true)
            end
        end

    end

    self:useTickDataCall(selectShop)--各商店 在tick里需要的数据初始化
    if self.rTv then
        self.loadingTipBg:setPositionX(self.loadingTipBg:getPositionX() - G_VisibleSizeWidth*2)
        self.loadingTipBg:setVisible(true)

        self.useSubTabNum = 1
        local function calSelfSubInfo(selectShop)
            self.loadingTipBg:setVisible(false)
            self.loadingTipBg:setPositionX(self.loadingTipBg:getPositionX() + G_VisibleSizeWidth*2)
            self:curSubTabInfo(selectShop,1)
        end
        -- print("self.needSocket[self.curShopType][2]====>>>>>>>>>",self.needSocket[self.curShopType],self.curShopType)
        if type(self.needSocket[self.curShopType]) ~= "table" and self.needSocket[self.curShopType] == true then
            self.needSocket[self.curShopType] = false
            allShopVoApi:SocketNewData(self.curShopType,self.useSubTabNum,calSelfSubInfo,nil,true)
        else
            allShopVoApi:SocketNewData(self.curShopType,self.useSubTabNum,calSelfSubInfo)
        end
    else
        self:initRightTableView(selectShop)
    end
end
function allPropDialog:curSubTabInfo(selectShop,chooseSuTabNum)
    if self:isClosed()==true then
        do return end
    end
    if self.useSubTabNum then--
        self:useTickDataCall(selectShop)
    end
    self.curSubTabLbTb = allShopVoApi:getCursubLbStrTb(selectShop)
    self.AllSubTabNums = SizeOfTable(self.curSubTabLbTb)

    local lb1,lb2 = allShopVoApi:getNeedrLb(selectShop,(chooseSuTabNum and chooseSuTabNum > 1) and chooseSuTabNum or nil)
    if lb1 and self.rTopDes1 then
        self.rTopDes1:setString(lb1)
        self.rBtn:setPosition(ccp(self.rTopDes1:getPositionX() + self.rTopDes1:getContentSize().width + 10,self.rTopDes1:getPositionY()))
    end
    if lb2 and self.rTopDes2 then
        self.rTopDes2:setString(lb2)
    end
    self:addRefreshBtn()

    local function selectSubTabCall(object,name,tag)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.useSubTabNum ~= tag - 100 and self.AllSubTabNums >= tag - 100 then
            self.useSubTabNum = tag - 100
            self.cutOver = true
            -- print("self.useSubTabNum======>>>>",self.useSubTabNum)
            local function calSelfSubInfo(selectShop,chooseSuTabNum)
                self:curSubTabInfo(selectShop,chooseSuTabNum)
            end
            if self.curShopType =="army" and self.useSubTabNum == 2 then
                local canSoc = self.needSocket[self.curShopType][2]
                if canSoc == true then
                    self.needSocket[self.curShopType][2] = false
                end
                allShopVoApi:SocketNewData(self.curShopType,self.useSubTabNum,calSelfSubInfo,nil,canSoc)
            else
                allShopVoApi:SocketNewData(self.curShopType,self.useSubTabNum,calSelfSubInfo)
            end
        end
    end

    for i=1,self.AllSubTabNums do
        if self.subLbStrTb[i] then
            self.subLbStrTb[i]:setString(self.curSubTabLbTb[i])
            self.subLbBgTb[i]:setVisible(true)
            self.subLbStrTb[i]:setVisible(true)
        else

            local subTabBg = LuaCCSprite:createWithSpriteFrameName("tabBtnSp4.png",selectSubTabCall)
            if not self.rTvHeight then
                if self.rShoppingBg and self.rightUpBg then
                    self.rTvHeight = self.rShoppingBg:getContentSize().height - 8 - self.rightUpBg:getContentSize().height - 56
                else
                    self.rTvHeight = 834
                end
            end
            subTabBg:setPosition(ccp(subTabBg:getContentSize().width*0.5 * i + 4 + (i - 1) * 4 + (i -1) * subTabBg:getContentSize().width * 0.5,subTabBg:getContentSize().height*0.5 + self.rTvHeight + 2))
            subTabBg:setTag(100 + i)
            subTabBg:setTouchPriority(-(self.layerNum-1)*20-3)
            self.subLbBgTb[i] = subTabBg
            self.rShoppingBg:addChild(subTabBg)
            local strSzie = 23
            if G_getCurChoseLanguage() == "de" and (selectShop == "gems" or selectShop == "preferential") then
                strSzie = 20
            end
            local subTabStr = GetTTFLabelWrap(self.curSubTabLbTb[i],strSzie,CCSizeMake(subTabBg:getContentSize().width -4,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            subTabStr:setPosition(ccp(subTabBg:getPositionX(),subTabBg:getPositionY()))
            self.subLbStrTb[i] = subTabStr
            self.rShoppingBg:addChild(subTabStr,2)

        end
    end

    if self.AllSubTabNums < 4 then
        for i=self.AllSubTabNums+1,4 do
            if self.subLbBgTb[i] then
                self.subLbBgTb[i]:setVisible(false)
                self.subLbStrTb[i]:setVisible(false)
            end
        end
    end

    if self.subTabBgDown == nil then
        self.subTabBgDown = CCSprite:createWithSpriteFrameName("tabBtnSp4_down.png")
        self.rShoppingBg:addChild(self.subTabBgDown,1)
        self.subTabBgDown:setPosition(ccp(self.subLbBgTb[1]:getPositionX(),self.subLbBgTb[1]:getPositionY()))--容错
    end
    if self.subLbBgTb[chooseSuTabNum] then
        self.subTabBgDown:setPosition(ccp(self.subLbBgTb[chooseSuTabNum]:getPositionX(),self.subLbBgTb[chooseSuTabNum]:getPositionY()))
    end

    self.curShopItem = allShopVoApi:getCurShopItem(selectShop,chooseSuTabNum)
    if self.rTv and self.curShopItem then
        if self.cutOver then
            self.cutOver = false
            self.rTv:reloadData()
        else
            if self.curShopType =="matr" then
                if self.matrShopType==1 then
                    self.rTv:reloadData()
                else
                    if self.lastMatrShopType==1 and self.matrShopType==2 then
                        self.rTv:reloadData()
                    else
                        local recordPoint=self.rTv:getRecordPoint()
                        self.rTv:reloadData()
                        self.rTv:recoverToRecordPoint(recordPoint)
                    end
                end
            else
                local recordPoint = self.rTv:getRecordPoint()
                self.rTv:reloadData()
                self.rTv:recoverToRecordPoint(recordPoint)
            end
        end
    elseif self.curShopItem == nil and self.rTv then
        print("error in reload tableView ~~~~~~~~selectShop-----self.useSubTabNum----->>>>",selectShop,self.useSubTabNum)
        self.rTv:removeFromParentAndCleanup(true)----容错机制，未测试
        self.rTv = nil
    end
end

function allPropDialog:initRightTableView(selectShop)
    self.rTvHeight = self.rShoppingBg:getContentSize().height - 8 - self.rightUpBg:getContentSize().height - 56 --60 小签的高度 + 空隙的高度
    self.rTvWidth = self.rShoppingBg:getContentSize().width - 4
    self.cellHeight = 120

    if self.tvUpLineSp == nil then
        local tvUpLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine4.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
        tvUpLineSp:setContentSize(CCSizeMake(self.rTvWidth,tvUpLineSp:getContentSize().height))
        tvUpLineSp:setPosition(ccp(self.rTvWidth*0.5 + 2,self.rTvHeight + 2))
        self.rShoppingBg:addChild(tvUpLineSp)
        self.tvUpLineSp = tvUpLineSp
    end

    self.useSubTabNum = 1
    -- self:curSubTabInfo(selectShop,1)
    local function calSelfSubInfo(selectShop)
        if selectShop=="gems" and self.subTabIndex then
            self:curSubTabInfo(selectShop,self.subTabIndex)
            self.subTabIndex = nil
        else
            self:curSubTabInfo(selectShop,1)
        end

        if self.curShopItem == nil then
            print("error in init tableView ~~~~~~~~selectShop-----self.useSubTabNum----->>>>",selectShop,self.useSubTabNum)
            do return end
        end

        local function callBack(...)
           return self:rEventHandler(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        self.rTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.rTvWidth,self.rTvHeight),nil)
        self.rTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.rTv:setPosition(ccp(2,2))
        self.rShoppingBg:addChild(self.rTv)
        self.rTv:setMaxDisToBottomOrTop(120)

        if selectShop=="gems" and self.showItemId then
            local cellIndex = nil
            for k, v in pairs(self.curShopItem) do
                if self.showItemId==v.sid then
                    cellIndex = k-1
                    break
                end
            end
            if cellIndex then
                local tvPoint = self.rTv:getRecordPoint()
                if tvPoint.y < 0 then
                    local itemSize=SizeOfTable(self.curShopItem)
                    local tvSize = self.rTv:getViewSize()
                    tvPoint.y=tvSize.height-self.cellHeight*(itemSize-cellIndex)
                    if tvPoint.y>0 then
                        tvPoint.y=0
                    end
                    self.rTv:recoverToRecordPoint(tvPoint)
                end
            end
            self.showItemId = nil
        end
    end
    -- allShopVoApi:SocketNewData(selectShop,1,calSelfSubInfo)
    if type(self.needSocket[self.curShopType]) ~= "table" and self.needSocket[self.curShopType] == true then
        self.needSocket[self.curShopType] = false
        allShopVoApi:SocketNewData(selectShop,1,calSelfSubInfo,nil,true)
    else
        allShopVoApi:SocketNewData(selectShop,1,calSelfSubInfo)
    end

end

function allPropDialog:rEventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local useNums = self.matrShopNum or 0
        return self.curShopType == "matr" and useNums or SizeOfTable(self.curShopItem)
    elseif fn=="tableCellSizeForIndex" then
        if  idx + 1 == 1 and self.curShopType == "diff" and self.useSubTabNum == 2 then
            return  CCSizeMake(self.rTvWidth,self.cellHeight + 40)
        else
            return  CCSizeMake(self.rTvWidth,self.cellHeight)
        end
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
        cellBg:setContentSize(CCSizeMake(self.rTvWidth,self.cellHeight))
        cellBg:setOpacity(0)
        cellBg:setPosition(ccp(0,0))
        cellBg:setAnchorPoint(ccp(0,0))
        cell:addChild(cellBg)

        local cellLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
        cellLine:setContentSize(CCSizeMake(self.rTvWidth,cellLine:getContentSize().height))
        cellLine:setPosition(ccp(self.rTvWidth*0.5,1))
        cellBg:addChild(cellLine)

        if self.curShopType == "gems" then
            self:initGemsShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "army" then
            self:initArmyShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "drill" then
            self:initDrillShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "expe" then
            self:initExpeShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "diff" then
            self:initDiffShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "seiko" then
            self:initSeikoShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "matr" then
            self:initMatrShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "feat" then
            self:initFeatShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "tskin" then
            self:initTankSkinShopInCell(idx + 1,cellBg)
        elseif self.curShopType == "preferential" then --优惠商店
            self:initSpecialShopInCell(idx + 1,cellBg)
        end
        return cell
    end
end

------------------------军功商店-------------------------
function allPropDialog:initFeatShopInCell(idx,cellBg)
        local lbNameFontSize,nameSubPosY,desSize2 = 22,30,18
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 20,20,16
        end

        local cellData,strPosx = self.curShopItem[idx],95
        local nameStrTb={}
        for k,v in pairs(cellData.rewardTb) do
            table.insert(nameStrTb,v.name.." x"..FormatNumber(v.num))
        end
        local nameLb=GetTTFLabel(table.concat(nameStrTb, ", "),lbNameFontSize-2)
        nameLb:setAnchorPoint(ccp(0,1))
        nameLb:setColor(G_ColorGreen)
        nameLb:setPosition(ccp(10,self.cellHeight - 5))
        cellBg:addChild(nameLb)

        local limitLb=GetTTFLabel("("..cellData.curTime.."/"..cellData.maxTime..")",lbNameFontSize-2)
        limitLb:setAnchorPoint(ccp(0,1))
        limitLb:setPosition(ccp(10+nameLb:getContentSize().width+5,nameLb:getPositionY()))
        cellBg:addChild(limitLb)
        self.featLimitTb[cellData.id]=limitLb

        local award=cellData.rewardTb[1]
        local icon
        local iconSize=100
        if(award.type and award.type=="e")then
            if(award.eType)then
                if(award.eType=="a")then
                    icon=accessoryVoApi:getAccessoryIcon(award.key,80,iconSize)
                elseif(award.eType=="f")then
                    icon=accessoryVoApi:getFragmentIcon(award.key,80,iconSize)
                elseif(award.pic and award.pic~="")then
                    icon=GetBgIcon(award.pic,nil,nil,80,iconSize)
                end
            end
        elseif(award.equipId)then
            local eType=string.sub(award.equipId,1,1)
            if(eType=="a")then
                icon=accessoryVoApi:getAccessoryIcon(award.equipId,80,iconSize)
            elseif(eType=="f")then
                icon=accessoryVoApi:getFragmentIcon(award.equipId,80,iconSize)
            elseif(eType=="p")then
                icon=GetBgIcon(accessoryCfg.propCfg[award.equipId].icon,nil,nil,80,iconSize)
            end
        elseif(award.pic and award.pic~="")then
            icon=GetBgIcon(award.pic,nil,nil,80,iconSize)
        end
        if(icon)then
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(ccp(10,self.cellHeight*0.5 - 10))
            cellBg:addChild(icon)
            icon:setScale(80/icon:getContentSize().width)
        end

        local descLb=GetTTFLabelWrap(getlocal(cellData.rewardTb[1].desc),desSize2,CCSizeMake(self.rTvWidth - 230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(ccp(strPosx,self.cellHeight*0.44))
        cellBg:addChild(descLb)
        if descLb:getContentSize().height > self.cellHeight*0.75 then
            descLb:setFontSize(desSize2 - 2)
            if descLb:getContentSize().height > self.cellHeight*0.85 then
                descLb:setFontSize(desSize2 - 4)
            end
        end

        canBuyLb=GetTTFLabel(getlocal("activity_vipRight_can_buy",{math.max(rpShopVoApi:getPersonalMaxBuy(cellData.id) - rpShopVoApi:getPersonalBuy(cellData.id),0)}),lbNameFontSize)
        canBuyLb:setAnchorPoint(ccp(0.5,1))
        cellBg:addChild(canBuyLb)
        self.featBuyLbTb[cellData.id]=canBuyLb

        -- 修改逻辑（增加可能消耗金币）
        local coinPrice=cellData.price or 0
        local gemPrice=cellData.gemprice or 0

        -- 军功币
        local coinIconScale = 0.2
        local coinIcon=CCSprite:createWithSpriteFrameName("rpCoin.png")
        cellBg:addChild(coinIcon)
        coinIcon:setScale(coinIconScale)
        local coinLb=GetTTFLabel(FormatNumber(coinPrice),lbNameFontSize)
        if(playerVoApi:getRpCoin()<coinPrice)then
            coinLb:setColor(G_ColorRed)
        else
            coinLb:setColor(G_ColorYellowPro)
        end
        coinLb:setAnchorPoint(ccp(0,0.5))
        cellBg:addChild(coinLb)

        local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
        cellBg:addChild(gemIcon)
        local gemLb=GetTTFLabel(FormatNumber(gemPrice),lbNameFontSize)
        if(playerVoApi:getGems()<gemPrice)then
            gemLb:setColor(G_ColorRed)
        else
            gemLb:setColor(G_ColorYellowPro)
        end
        gemLb:setAnchorPoint(ccp(0,0.5))
        cellBg:addChild(gemLb)

        local function onClick(tag,object)
            if(playerVoApi:getRpCoin()<cellData.price)then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage14005"),30)
                do return end
            end
            if(playerVoApi:getGems()<cellData.gemprice)then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30)
                do return end
            end
            if(tag)then
                self:featBuyItem(tag-self.featTagOffset)
            end
        end
        local btnStr
        if(cellData.curTime>=cellData.maxTime)then
            btnStr=getlocal("soldOut")
        else
            btnStr=getlocal("code_gift")
        end
        local buyItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onClick,nil,btnStr,34,518)
        buyItem:setTag(self.featTagOffset+idx)
        buyItem:setScale(0.6)
        if(cellData.curTime>=cellData.maxTime or rpShopVoApi:getPersonalBuy(cellData.id)>=rpShopVoApi:getPersonalMaxBuy(cellData.id)) then
            buyItem:setEnabled(false)
        end
        self.featBuyItemTb[cellData.id]=buyItem
        local buyBtn = CCMenu:createWithItem(buyItem)
        buyBtn:setPosition(ccp(self.rTvWidth - buyItem:getContentSize().width*0.5*0.65 - 5,30))
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        cellBg:addChild(buyBtn)

        if canBuyLb:getContentSize().width > buyItem:getContentSize().width * 0.6 then
            canBuyLb:setAnchorPoint(ccp(1,1))
            canBuyLb:setPosition(ccp(self.rTvWidth - 5,self.cellHeight - 5))
        else
            canBuyLb:setPosition(ccp(buyBtn:getPositionX(),self.cellHeight - 5 ))
        end
        if gemPrice==0 then
            coinIcon:setPosition(ccp(buyBtn:getPositionX() -25,self.cellHeight*0.6))
            coinLb:setPosition(ccp(buyBtn:getPositionX() -5,self.cellHeight*0.6))
            gemIcon:setVisible(false)
            gemLb:setVisible(false)
        elseif coinPrice==0 then
            gemIcon:setPosition(ccp(buyBtn:getPositionX() -25,self.cellHeight*0.6))
            gemLb:setPosition(ccp(buyBtn:getPositionX() -5,self.cellHeight*0.6))
            coinIcon:setVisible(false)
            coinLb:setVisible(false)
        else
            local rPosx = buyBtn:getPositionX() + buyItem:getContentSize().width*0.6*0.5
            coinLb:setAnchorPoint(ccp(1,0.5))
            coinIcon:setAnchorPoint(ccp(1,0.5))
            gemLb:setAnchorPoint(ccp(1,0.5))
            gemIcon:setAnchorPoint(ccp(1,0.5))

            coinLb:setPosition(ccp(rPosx,self.cellHeight*0.6))
            coinIcon:setPosition(ccp(rPosx - coinLb:getContentSize().width ,self.cellHeight*0.6))
            gemLb:setPosition(ccp(coinIcon:getPositionX() - 5 - coinIcon:getContentSize().width * coinIconScale ,self.cellHeight*0.6))
            gemIcon:setPosition(ccp(gemLb:getPositionX() - gemLb:getContentSize().width + 5,self.cellHeight*0.6))
            
        end

        local selfRank=playerVoApi:getRank()
        if(selfRank<cellData.rank)then
            local mask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
            mask:setContentSize(CCSizeMake(self.rTvWidth,self.cellHeight))
            mask:setOpacity(200)
            mask:setPosition(ccp(self.rTvWidth * 0.5,self.cellHeight * 0.5))
            mask:setTouchPriority(-(self.layerNum-1)*20-2)
            cellBg:addChild(mask,2)

            local unlockIcon=CCSprite:createWithSpriteFrameName(playerVoApi:getRankIconName(cellData.rank))
            unlockIcon:setPosition(ccp(120,self.cellHeight * 0.5))
            cellBg:addChild(unlockIcon,3)

            local unlockDesc=GetTTFLabelWrap(getlocal("rpshop_rankLimit",{getlocal("military_rank_"..cellData.rank)}),28,CCSizeMake(self.rTvWidth - 150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            unlockDesc:setColor(G_ColorRed)
            unlockDesc:setAnchorPoint(ccp(0,0.5))
            unlockDesc:setPosition(ccp(unlockIcon:getPositionX() + 30,unlockIcon:getPositionY()))
            cellBg:addChild(unlockDesc,3)

            local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
            titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,unlockDesc:getContentSize().height+10))
            titleBg:setScaleX((self.rTvWidth-60)/titleBg:getContentSize().width)
            titleBg:setPosition(ccp((self.rTvWidth-60)* 0.5,self.cellHeight* 0.5))
            cellBg:addChild(titleBg,2)
        end
end
------------------------矩阵商店-------------------------
function allPropDialog:initMatrShopInCell(idx,cellBg)
    local lbNameFontSize,nameSubPosY,desSize2,strPosx= 22,30,18,95
    if G_isAsia() == false then
        lbNameFontSize,nameSubPosY,desSize2= 20,20,16
    end
    local preshoplist=self.curShopItem
    local id=self.matrShopInfo[idx].id
    local index=self.matrShopInfo[idx].index
    local infoTb=preshoplist[id]
    local rewardTb=FormatItem(infoTb.reward)

    local armorMatrixInfo,exinfo,s,buyNum = nil,{},{},0
    if self.matrShopType == 2 then
        armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
        exinfo=armorMatrixInfo.exinfo or {}
        s=exinfo.s or {}
        buyNum=(s[2] or {})[id] or 0
    end

    if(rewardTb and rewardTb[1])then
        local reward=rewardTb[1]
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
            return false
        end
        local icon,scale=G_getItemIcon(reward,80,false,self.layerNum)
        icon:setAnchorPoint(ccp(0,0))
        icon:setPosition(10,5)
        icon:setTouchPriority(-(self.layerNum-1)*20-2)
        cellBg:addChild(icon)
        local iconHeight = icon:getContentSize().height*0.8 + 5
        if infoTb.flicker then
            local indexTb={y=3,b=1,p=2,g=4}
            G_addRectFlicker2(icon,1.2,1.2,indexTb[infoTb.flicker],infoTb.flicker,nil,3)
        end

        local numLb=GetTTFLabel("x"..FormatNumber(reward.num),22)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(icon:getContentSize().width-5,5)
        icon:addChild(numLb)

        if self.matrShopType == 1 then
            local nameLb=GetTTFLabelWrap(reward.name,lbNameFontSize-2,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
            nameLb:setAnchorPoint(ccp(0,0))
            cellBg:addChild(nameLb)
            nameLb:setPosition(ccp(10,iconHeight + 3))
            nameLb:setColor(G_ColorGreen)

            local conditionLb=GetTTFLabelWrap(getlocal("armor_buy_conditions"),lbNameFontSize+2,CCSizeMake(self.rTvWidth - 230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
            conditionLb:setAnchorPoint(ccp(0,1))
            conditionLb:setPosition(strPosx,iconHeight+5)
            cellBg:addChild(conditionLb)

        else
            local limittimes=infoTb.limittimes
            local colorTab={G_ColorYellowPro,G_ColorWhite}

            local StitchingStr="(" .. buyNum .. "/" .. limittimes .. ")"
            local nameStr=reward.name .. "<rayimg>" .. StitchingStr .. "<rayimg>"
            local nameLb=G_getRichTextLabel(nameStr,colorTab,lbNameFontSize-2,self.rTvWidth-100,kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom,0,true)
            nameLb:setAnchorPoint(ccp(0,0))
            cellBg:addChild(nameLb)
            nameLb:setPosition(ccp(10,iconHeight + 3))
            if G_isShowRichLabel() then
                nameLb:setPosition(ccp(10,iconHeight + 26))
            end

            local desLb=GetTTFLabelWrap(getlocal(reward.desc),desSize2,CCSizeMake(self.rTvWidth - 240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            desLb:setAnchorPoint(ccp(0,0.5))
            desLb:setPosition(105,self.cellHeight*0.5 - 15)
            cellBg:addChild(desLb)
            if desLb:getContentSize().height > self.cellHeight*0.65 then
                desLb:setFontSize(desSize2 - 2)
            end
        end

        local needquality,haveNum,needNum,needStr,colorTab,price = nil,nil,nil,nil,{},nil
        local armorMatrixInfo,exp = nil,0--price共用，上面已经定义了，
        if self.matrShopType == 1 then
            needQuality=infoTb.needquality
            haveNum=armorMatrixVoApi:getUsedQualityNum(needQuality)
            needNum=infoTb.needNum
            needStr=getlocal("armor_buy_need1",{haveNum .. "/" .. needNum,getlocal("armorMatrix_color_" .. needQuality)})
            if haveNum>=needNum then
                colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorPurple}
            else
                colorTab={G_ColorWhite,G_ColorRed,G_ColorWhite,G_ColorPurple}
            end
            local needLb,lbHeight=G_getRichTextLabel(needStr,colorTab,lbNameFontSize,self.rTvWidth - 230,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
            needLb:setAnchorPoint(ccp(0,0))
            cellBg:addChild(needLb)
            needLb:setPosition(strPosx,50)

            if G_isShowRichLabel() == false then
                needLb:setPositionY(needLb:getPositionY() - lbHeight)
            end

            price=infoTb.price

        else
            price=infoTb.aExpcost
            armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
            exp=armorMatrixInfo.exp or 0
        end
        
        local function buyFunc()
            if self.rTv:getScrollEnable()==true and self.rTv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                if self.matrShopType == 1 then
                    if haveNum<needNum then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armor_buy_des1"),30)
                        do return end
                    else
                        local gems=playerVoApi:getGems() or 0
                        if gems<price then
                            GemsNotEnoughDialog(nil,nil,price-gems,self.layerNum+1,price)
                            do return end
                        else
                            local function refreshFunc()
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
                                playerVoApi:setGems(playerVoApi:getGems() - price)
                                self:curSubTabInfo("matr",1)
                            end
                            armorMatrixVoApi:shopExchange(refreshFunc,1,id)
                        end
                    end
                else
                    if exp<price then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armor_no_enough_exp"),30)
                        do return end
                    else
                        local function refreshFunc()
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_change_sucess"),30)
                            G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true,nil)
                            self:curSubTabInfo("matr",1)
                        end
                        armorMatrixVoApi:shopExchange(refreshFunc,2,id)
                    end
                end
            end
        end
        local lbStr2= self.matrShopType == 1 and getlocal("buy") or getlocal("activity_loversDay_tab2")
        local buyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",buyFunc,nil,lbStr2,33,11)
        buyItem:setScale(0.6)
        local btnLb = buyItem:getChildByTag(11)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        if self.matrShopType == 2 and index>10000 then
            buyItem:setEnabled(false)
        end
        local buyBtn=CCMenu:createWithItem(buyItem);
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-2);
        buyBtn:setPosition(ccp(self.rTvWidth - buyItem:getContentSize().width*0.5*0.65 - 5,35))
        cellBg:addChild(buyBtn)

        local iconName= self.matrShopType == 1 and "IconGold.png" or "armorMatrixExp.png"
        local expIcon1=CCSprite:createWithSpriteFrameName(iconName)
        if self.matrShopType == 2 then
            expIcon1:setScale(0.4)
        end
        cellBg:addChild(expIcon1)
        local iconLb1=GetTTFLabel(price,lbNameFontSize)
        iconLb1:setAnchorPoint(ccp(0,0.5))
        cellBg:addChild(iconLb1)

        expIcon1:setPosition(ccp(buyBtn:getPositionX() -25,self.cellHeight*0.65));
        iconLb1:setPosition(ccp(buyBtn:getPositionX() -5,self.cellHeight*0.65))

        if self.matrShopType == 1 and playerVoApi:getGems() < price then
            iconLb1:setColor(G_ColorRed)
        end
    end     
end
------------------------精工商店-------------------------
function allPropDialog:initSeikoShopInCell(idx,cellBg)
        local lbNameFontSize,nameSubPosY,desSize2 = 22,30,18
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 20,20,16
        end

        local tId,strPosx = "i" .. idx,95
        local reward = self.curShopItem[tId].reward
        local price = self.curShopItem[tId].price
        local item = FormatItem(reward)
        local propIcon,namestr,desStr,propSp,hid="","","","",""

        namestr=item[1].name
        descStr=getlocal(item[1].desc)
        propSp=G_getItemIcon(item[1],80,nil,self.layerNum+1)
        propSp:setAnchorPoint(ccp(0,0.5))
        propSp:setPosition(ccp(10,self.cellHeight*0.5))
        cellBg:addChild(propSp,1)

        local lbName=GetTTFLabelWrap(namestr,lbNameFontSize,CCSizeMake(self.rTvWidth*0.7,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbName:setPosition(strPosx,self.cellHeight-nameSubPosY)
        lbName:setAnchorPoint(ccp(0,0.5));
        cellBg:addChild(lbName,2)
        lbName:setColor(G_ColorYellowPro)
        
        local lbDescription=GetTTFLabelWrap(descStr,desSize2,CCSize(self.rTvWidth - 220,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbDescription:setPosition(strPosx,(self.cellHeight-25)*0.5)
        lbDescription:setAnchorPoint(ccp(0,0.5));
        cellBg:addChild(lbDescription,2)
        if lbDescription:getContentSize().height > self.cellHeight*0.65 then
            lbDescription:setFontSize(desSize2 - 2)
        end

        local pointSp = CCSprite:createWithSpriteFrameName("icon_awaken_fragment.png")
        pointSp:setScale(0.4)
        cellBg:addChild(pointSp,6)

        local num = price
        local numLb = GetTTFLabel(num,21)
        numLb:setAnchorPoint(ccp(0,0.5))
        cellBg:addChild(numLb)

        local propKey = heroEquipAwakeShopCfg.buyitem
        local useId   = tonumber(propKey) or tonumber(RemoveFirstChar(propKey))
        local useName = getItem(propKey,"p")
        local useNum  = bagVoApi:getItemNumId(useId)

        local function exchange()
            if self.rTv:getScrollEnable()==true and self.rTv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                local propKey = heroEquipAwakeShopCfg.buyitem
                local useId   = tonumber(propKey) or tonumber(RemoveFirstChar(propKey))
                local useName = getItem(propKey,"p")
                local useNum  = bagVoApi:getItemNumId(useId)
                if useNum < price then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("sample_prop_name_933")..getlocal("notEnoughNow"),30)
                    do return end
                end
                local function buycallback()
                    local function callback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{namestr}),30)

                            self:curSubTabInfo("seiko",1)
                        end
                    end
                    socketHelper:awakeShopBuy(tId,callback)
                end

                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycallback,getlocal("dialog_title_prompt"),getlocal("equip_shopBuy",{num  .. useName,namestr}),nil,self.layerNum+1)
            end
        end
        local exchangeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",exchange,nil,getlocal("code_gift"),34)
        exchangeItem:setScale(0.6)
        if useNum < price then
            numLb:setColor(G_ColorRed)
        end
        local exchangeBtn=CCMenu:createWithItem(exchangeItem)
        exchangeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        exchangeBtn:setPosition(ccp(self.rTvWidth - exchangeItem:getContentSize().width*0.5*0.6 - 5,35))
        cellBg:addChild(exchangeBtn,1)

        numLb:setPosition(ccp(exchangeBtn:getPositionX() -5,self.cellHeight*0.65))
        pointSp:setPosition(ccp(exchangeBtn:getPositionX() -20,self.cellHeight*0.65))
end
------------------------异元商店-------------------------
function allPropDialog:initDiffShopInCell(idx,cellBg )
        local lbNameFontSize,nameSubPosY,desSize2 = 22,30,18
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 19,16,16
        end
        if self.useSubTabNum == 1 then
            local shopVo,strPosx=self.curShopItem[idx],95
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
            local nameLb=GetTTFLabel(table.concat(nameStrTb, ", "),lbNameFontSize)
            nameLb:setAnchorPoint(ccp(0,0.5))
            nameLb:setColor(G_ColorGreen)
            nameLb:setPosition(ccp(strPosx,self.cellHeight-nameSubPosY))
            cellBg:addChild(nameLb)

            local limitLb=GetTTFLabel("("..num.."/"..maxNum..")",lbNameFontSize)
            limitLb:setAnchorPoint(ccp(0,0.5))
            limitLb:setPosition(ccp(2+nameLb:getContentSize().width+5 + nameLb:getPositionX(),nameLb:getPositionY()))
            cellBg:addChild(limitLb)

            local award=rewardTb[1]
            local iconSize=80
            local icon=G_getItemIcon(award,iconSize,false,self.layerNum)
            if icon then
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(ccp(10,self.cellHeight*0.5))
                cellBg:addChild(icon)
            end

            local descLb=GetTTFLabelWrap(getlocal(rewardTb[1].desc),desSize2,CCSizeMake(self.rTvWidth - 230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0,0.5))
            descLb:setPosition(ccp(strPosx,(self.cellHeight-25)*0.5))
            cellBg:addChild(descLb)
            if descLb:getContentSize().height > self.cellHeight*0.65 then
                descLb:setFontSize(desSize2 - 2)
            end

            local priceDescLb=GetTTFLabel(getlocal("serverwar_point"),lbNameFontSize)
            cellBg:addChild(priceDescLb)

            local priceLb=GetTTFLabel(price,lbNameFontSize)
            if(dimensionalWarVoApi:getPoint()<price)then
                priceLb:setColor(G_ColorRed)
            else
                priceLb:setColor(G_ColorYellowPro)
            end
            cellBg:addChild(priceLb)

            local function onClick(tag,object)
                if self and self.rTv and self.rTv:getScrollEnable()==true and self.rTv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    local showList=dimensionalWarVoApi:getShopList()
                    local shopVo=self.curShopItem[idx]
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
                    self:diffBuyItem(shopVo)
                end
            end
            local buyItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onClick,nil,getlocal("code_gift"),34)
            buyItem:setTag(idx)
            buyItem:setScale(0.6)
            if num>=maxNum then
                buyItem:setEnabled(false)
            end
            local buyBtn = CCMenu:createWithItem(buyItem)
            buyBtn:setPosition(ccp(self.rTvWidth - buyItem:getContentSize().width*0.5*0.65 - 5,30))
            buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
            cellBg:addChild(buyBtn)

            priceDescLb:setPosition(ccp(buyBtn:getPositionX(),self.cellHeight*0.75))
            priceLb:setPosition(ccp(buyBtn:getPositionX(),self.cellHeight*0.55))
        else
            local width=(self.rTvWidth - 10) * 0.65
            local height=self.cellHeight
            local color=G_ColorWhite
            local time,round,message=0,0,""
            local type,index
            local index=idx

            local vo=self.curShopItem[index]
            if vo==nil then
                do return end
            end
            message=vo.message
            color=vo.color
            time=vo.time
            type=vo.type
            round=vo.round

            local timeStr=""
            if type==1 then
                timeStr=G_getDataTimeStr(time)
            else
                timeStr=G_getDataTimeStr(time,nil,true).." "..getlocal("dimensionalWar_round",{round})
            end
            local timeLabel=GetTTFLabel(timeStr,lbNameFontSize)
            timeLabel:setAnchorPoint(ccp(0,0.5))
            timeLabel:setPosition(ccp(10,height*0.5))
            cellBg:addChild(timeLabel,1)

            local textLabel=GetTTFLabelWrap(message,lbNameFontSize,CCSizeMake(width,height),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            textLabel:setAnchorPoint(ccp(0,0.5))
            textLabel:setPosition(ccp(self.rTvWidth*0.35,height*0.5))
            cellBg:addChild(textLabel,1)

            timeLabel:setColor(color)
            textLabel:setColor(color)

            if idx == 1 then
                local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function() end)
                headSprie:setContentSize(CCSizeMake(self.rTvWidth, 38))
                headSprie:ignoreAnchorPointForPosition(false)
                headSprie:setAnchorPoint(ccp(0.5,0))
                headSprie:setIsSallow(false)
                headSprie:setTouchPriority(-(self.layerNum-1)*20-2)
                headSprie:setPosition(ccp(self.rTvWidth*0.5,self.cellHeight + 2))
                cellBg:addChild(headSprie,1)

                local timeLb=GetTTFLabel(getlocal("alliance_event_time"),lbNameFontSize)
                timeLb:setPosition(self.rTvWidth*0.15,headSprie:getContentSize().height*0.5)
                timeLb:setAnchorPoint(ccp(0.5,0.5))
                headSprie:addChild(timeLb,2)
                timeLb:setColor(G_ColorGreen2)

                local recordLb=GetTTFLabel(getlocal("serverwar_point_record"),lbNameFontSize)
                recordLb:setPosition(self.rTvWidth*0.65,headSprie:getContentSize().height*0.5)
                recordLb:setAnchorPoint(ccp(0.5,0.5))
                headSprie:addChild(recordLb,2)
                recordLb:setColor(G_ColorGreen2)
            end
        end
end
------------------------远征商店-------------------------
function allPropDialog:initExpeShopInCell(idx,cellBg )
        local lbNameFontSize,nameSubPosY,desSize2 = 22,30,18
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 20,20,16
        end

        local itemType,strPosx = Split(self.curShopItem[idx][1],"_")[1],95
        local propIcon=""
        local namestr=""
        local descStr=""
        local propSp=""
        local hid=""
        if itemType=="props" then
            local pid = Split(self.curShopItem[idx][1],"_")[2]
            propIcon=propCfg[pid].icon
            namestr=getlocal(propCfg[pid].name).."×"..self.curShopItem[idx][2]
            descStr=getlocal(propCfg[pid].description)
            local num = self.curShopItem[idx][2]
            local name,pic,desc,id,index,eType,equipId,bgname=getItem(pid,"p")
            local item = {name=name,num=num,pic=pic,desc=desc,id=id,type="p",index=index,key=pid,eType=eType,equipId=equipId,bgname=bgname}
            propSp=G_getItemIcon(item,100,nil,self.layerNum+1)
            propSp:setScale(0.8)
            -- print("----dmj----pid:"..pid)
        elseif itemType=="hero" then
            local sid = Split(self.curShopItem[idx][1],"_")[2]
            hid = heroVoApi:getSoulHid(sid)
            propSp=heroVoApi:getHeroIcon(hid)
            propSp:setScale(0.55)

            namestr=heroVoApi:getHeroSoulName(hid).."×"..self.curShopItem[idx][2]
            descStr=heroVoApi:getHeroDes(hid)
        elseif itemType=="equip" then
            local eid = Split(self.curShopItem[idx][1],"_")[2]
            local num = self.curShopItem[idx][2]

            local name,pic,desc,id,index,eType,equipId,bgname=getItem(eid,"f")
            local item = {name=name,num=num,pic=pic,desc=desc,id=id,type="f",index=index,key=eid,eType=eType,equipId=equipId,bgname=bgname}
            propSp=G_getItemIcon(item,100,nil,self.layerNum+1)
            namestr=name .. "×"..num
            descStr=getlocal(desc)
            propSp:setScale(0.8)
        end
        propSp:setAnchorPoint(ccp(0,0.5))
        propSp:setPosition(ccp(10,self.cellHeight*0.5))
        cellBg:addChild(propSp,1)

        local lbName=GetTTFLabelWrap(namestr,lbNameFontSize,CCSizeMake(self.rTvWidth*0.7,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbName:setPosition(strPosx,self.cellHeight-nameSubPosY)
        lbName:setAnchorPoint(ccp(0,0.5));
        cellBg:addChild(lbName,2)
        lbName:setColor(G_ColorYellowPro)
        
        local lbDescription=GetTTFLabelWrap(descStr,desSize2,CCSize(self.rTvWidth - 230,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbDescription:setPosition(strPosx,(self.cellHeight-25)*0.5)
        lbDescription:setAnchorPoint(ccp(0,0.5));
        cellBg:addChild(lbDescription,2)
        if lbDescription:getContentSize().height > self.cellHeight*0.65 then
            lbDescription:setFontSize(desSize2 - 2)
        end

        local useNum = self.curShopItem[idx][3]
        local numLb = GetTTFLabel(useNum,21)
        numLb:setAnchorPoint(ccp(0,0.5))
        cellBg:addChild(numLb)

        local pointSp = CCSprite:createWithSpriteFrameName("expeditionPoint.png")
        pointSp:setScale(0.4)
        cellBg:addChild(pointSp)

        local function exchange()
          if self.rTv:getIsScrolled()==true then
            do return end
          end
          if expeditionVoApi:getPoint() < useNum then--serverwar_point_not_enough
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_point_not_enough",{namestr}),30)
                do return end
          end
          local function buycallback()
              local function callback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if itemType=="hero" then
                            local sid = Split(self.curShopItem[idx][1],"_")[2]
                            local snum=self.curShopItem[idx][2]
                            local hData={h={}}
                            hData.h[sid]=snum
                            local heroTb=FormatItem(hData)
                            if heroTb and heroTb[1] then
                                 local hero=heroVoApi:getHeroByHid(hid)
                                local heroIsExist = true
                                if hero==nil then
                                    heroIsExist = false
                                 end
                                G_recruitShowHero(2,heroTb[1],self.layerNum+1,heroIsExist,snum)
                                heroVoApi:addSoul(sid,snum)
                            end
                        elseif itemType=="equip" then
                            local eid = Split(self.curShopItem[idx][1],"_")[2]
                            G_addPlayerAward("f",eid,nil,self.curShopItem[idx][2])
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{namestr}),30)
                        else
                            local pid = Split(self.curShopItem[idx][1],"_")[2]
                            bagVoApi:addBag(tonumber(RemoveFirstChar(pid)),self.curShopItem[idx][2])

                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{namestr}),30)
                        end

                        expeditionVoApi:addBuy(idx)
                        local point=expeditionVoApi:getPoint()-self.curShopItem[idx][3]
                        expeditionVoApi:setPoint(point)

                        self:curSubTabInfo("expe",1)
                    end
                end
                socketHelper:expeditionBuy(idx,self.curShopItem[idx][1],self.curShopItem[idx][2],callback)
          end

          smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycallback,getlocal("dialog_title_prompt"),getlocal("expeditionBuy",{useNum,namestr}),nil,self.layerNum+1)
        end
        local exchangeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",exchange,nil,getlocal("code_gift"),33,101)
        exchangeItem:setScale(0.6)
        if expeditionVoApi:getPoint() < useNum then
            numLb:setColor(G_ColorRed)
        end
        local btnLb = exchangeItem:getChildByTag(101)
        if btnLb then
          btnLb = tolua.cast(btnLb,"CCLabelTTF")
          btnLb:setFontName("Helvetica-bold")
        end
        local exchangeBtn=CCMenu:createWithItem(exchangeItem)
        exchangeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        exchangeBtn:setPosition(ccp(self.rTvWidth - exchangeItem:getContentSize().width*0.5*0.6 - 5,35))
        cellBg:addChild(exchangeBtn,1)
        numLb:setPosition(ccp(exchangeBtn:getPositionX() -5,self.cellHeight*0.65))
        pointSp:setPosition(ccp(exchangeBtn:getPositionX() -20,self.cellHeight*0.65))

        if expeditionVoApi:isSoldOut(idx)==true then
           exchangeItem:setEnabled(false)
           local function touchLuaSpr( ... )
             
           end
           local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",  CCRect(10, 10, 1, 1),touchLuaSpr)
            touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
            local rect=CCSizeMake(cellBg:getContentSize().width,cellBg:getContentSize().height)
            touchDialogBg:setContentSize(rect)
            touchDialogBg:setOpacity(200)
            touchDialogBg:setPosition(getCenterPoint(cellBg))
            cellBg:addChild(touchDialogBg,3)
        
            local unlockDesc=GetTTFLabelWrap(getlocal("soldOut"),28,CCSizeMake(self.rTvWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            unlockDesc:setColor(G_ColorRed)
            unlockDesc:setPosition(ccp((self.rTvWidth-60)*0.5,self.cellHeight*0.5))
            cellBg:addChild(unlockDesc,5)

            local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20  , 20, 10, 10),function ()end)
            titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,  unlockDesc:getContentSize().height+10))
            titleBg:setScaleX((self.rTvWidth-60)/titleBg:getContentSize().width)
            titleBg:setPosition(ccp((self.rTvWidth-60)*0.5,self.cellHeight*0.5))
            cellBg:addChild(titleBg,4)
        end
end
------------------------军演商店-------------------------
function allPropDialog:initDrillShopInCell(idx,cellBg)
    local lbNameFontSize,nameSubPosY,desSize2 = 22,30,18
    if G_isAsia() == false then
        lbNameFontSize,nameSubPosY,desSize2= 20,20,16
    end

    local arr = Split(self.curShopItem[idx][1],"_")
    local itemType,itemKey,strPosx = arr[1],arr[2],95

    local propIcon=""
    local namestr=""
    local descStr=""
    local propSp=""
    local hid=""
    if itemType=="props" then
        local pid = Split(self.curShopItem[idx][1],"_")[2]
        propIcon=propCfg[pid].icon
        namestr=getlocal(propCfg[pid].name).."×"..self.curShopItem[idx][2]
        descStr=getlocal(propCfg[pid].description)
        local num = self.curShopItem[idx][2]
        local name,pic,desc,id,index,eType,equipId,bgname=getItem(pid,"p")
        local item = {name=name,num=num,pic=pic,desc=desc,id=id,type="p",index=index,key=pid,eType=eType,equipId=equipId,bgname=bgname}
        -- propSp=CCSprite:createWithSpriteFrameName(pic)
        propSp=G_getItemIcon(item,100,nil,self.layerNum+1)
        propSp:setScale(0.8)
    elseif itemType=="hero" then
        local sid = Split(self.curShopItem[idx][1],"_")[2]
        hid = heroVoApi:getSoulHid(sid)
        propSp=heroVoApi:getHeroIcon(hid)
        propSp:setScale(0.55)

        namestr=heroVoApi:getHeroSoulName(hid).."×"..self.curShopItem[idx][2]
        descStr=heroVoApi:getHeroDes(hid)
    elseif itemType=="equip" then
        local eid = Split(self.curShopItem[idx][1],"_")[2]
        local num = self.curShopItem[idx][2]

        local name,pic,desc,id,index,eType,equipId,bgname=getItem(eid,"f")
        local item = {name=name,num=num,pic=pic,desc=desc,id=id,type="f",index=index,key=eid,eType=eType,equipId=equipId,bgname=bgname}
        -- propSp=CCSprite:createWithSpriteFrameName(pic)
        propSp=G_getItemIcon(item,100,nil,self.layerNum+1)
        propSp:setScale(0.8)
        namestr=name .. "×"..num
        descStr=getlocal(desc)
    else
        local rtype = G_rewardType(itemType)
        local reward = {}
        local num = self.curShopItem[idx][2]
        reward[rtype]={[itemKey]=num}
        local item = FormatItem(reward)[1]
        propSp=G_getItemIcon(item,100,nil,self.layerNum+1)
        propSp:setScale(80/propSp:getContentSize().width)
        namestr = item.name.."x"..item.num
        descStr=getlocal(item.desc)
    end
    -- propSp:setScale(0.8)
    propSp:setAnchorPoint(ccp(0,0.5))
    propSp:setPosition(ccp(10,self.cellHeight*0.5))
    cellBg:addChild(propSp,1)

    local lbName=GetTTFLabelWrap(namestr,lbNameFontSize,CCSizeMake(self.rTvWidth*0.7,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbName:setPosition(strPosx,self.cellHeight-nameSubPosY)
    lbName:setAnchorPoint(ccp(0,0.5));
    cellBg:addChild(lbName,2)
    lbName:setColor(G_ColorYellowPro)
    
    local lbDescription=GetTTFLabelWrap(descStr,desSize2,CCSize(self.rTvWidth - 230,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbDescription:setPosition(strPosx,(self.cellHeight-25)*0.5)
    lbDescription:setAnchorPoint(ccp(0,0.5));
    cellBg:addChild(lbDescription,2)
    if lbDescription:getContentSize().height > self.cellHeight*0.65 then
        lbDescription:setFontSize(desSize2 - 2)
    end

    local useNum = self.curShopItem[idx][3]
    local numLb = GetTTFLabel(useNum,21)
    numLb:setAnchorPoint(ccp(0,0.5))
    cellBg:addChild(numLb)

    local pointSp = CCSprite:createWithSpriteFrameName("icon_medal_sports.png")
    pointSp:setScale(0.4)
    cellBg:addChild(pointSp)

    local function exchange()
      if self.rTv:getIsScrolled()==true then
        do return end
      end
      if arenaVoApi:getPoint() < useNum then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_point_not_enough",{namestr}),30)
            do return end
      end
      local function buycallback()
          local function callback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if itemType=="hero" then
                        local sid = Split(self.curShopItem[idx][1],"_")[2]
                        local snum=self.curShopItem[idx][2]
                        local hData={h={}}
                        hData.h[sid]=snum
                        local heroTb=FormatItem(hData)
                        if heroTb and heroTb[1] then
                             local hero=heroVoApi:getHeroByHid(hid)
                            local heroIsExist = true
                            if hero==nil then
                                heroIsExist = false
                             end
                            G_recruitShowHero(2,heroTb[1],self.layerNum+1,heroIsExist,snum)
                            heroVoApi:addSoul(sid,snum)
                        end
                    elseif itemType=="equip" then
                        local eid = Split(self.curShopItem[idx][1],"_")[2]
                        G_addPlayerAward("f",eid,nil,self.curShopItem[idx][2])
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{namestr}),30)
                    else
                        local pid = Split(self.curShopItem[idx][1],"_")[2]
                        bagVoApi:addBag(tonumber(RemoveFirstChar(pid)),self.curShopItem[idx][2])

                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{namestr}),30)
                    end

                    arenaVoApi:addBuy(idx)
                    local point=arenaVoApi:getPoint()-self.curShopItem[idx][3]
                    arenaVoApi:setPoint(point)
                    -- self:refresh()
                    self:curSubTabInfo("drill",1)
                end
            end
            socketHelper:shamBattleBuy(idx,self.curShopItem[idx][1],self.curShopItem[idx][2],callback)
      end

      smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycallback,getlocal("dialog_title_prompt"),getlocal("expeditionBuy",{useNum,namestr}),nil,self.layerNum+1)
      
    
    end
    local exchangeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",exchange,nil,getlocal("code_gift"),34)
    exchangeItem:setScale(0.6)
    -- print("arenaVoApi:getPoint() < useNum=====>>>>",arenaVoApi:getPoint() , useNum)
    local selfPoint =  arenaVoApi:getPoint() or 0
    if selfPoint < useNum then
        numLb:setColor(G_ColorRed)
    end
    local exchangeBtn=CCMenu:createWithItem(exchangeItem)
    exchangeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
    exchangeBtn:setPosition(ccp(self.rTvWidth - exchangeItem:getContentSize().width*0.5*0.6 - 5,35))
    cellBg:addChild(exchangeBtn,1)
    numLb:setPosition(ccp(exchangeBtn:getPositionX() -5,self.cellHeight*0.65))
    pointSp:setPosition(ccp(exchangeBtn:getPositionX() -20,self.cellHeight*0.65))


    if arenaVoApi:isSoldOut(idx)==true then
       exchangeItem:setEnabled(false)
       local function touchLuaSpr( ... )
         
       end
       local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",  CCRect(10, 10, 1, 1),touchLuaSpr)
        touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
        local rect=CCSizeMake(cellBg:getContentSize().width,cellBg:getContentSize().height)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(200)
        touchDialogBg:setPosition(getCenterPoint(cellBg))
        cellBg:addChild(touchDialogBg,3)
    
        local unlockDesc=GetTTFLabelWrap(getlocal("soldOut"),28,CCSizeMake(self.rTvWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        unlockDesc:setColor(G_ColorRed)
        unlockDesc:setPosition(ccp((self.rTvWidth-60)*0.5,self.cellHeight*0.5))
        cellBg:addChild(unlockDesc,5)

        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20  , 20, 10, 10),function ()end)
        titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,  unlockDesc:getContentSize().height+10))
        titleBg:setScaleX((self.rTvWidth-60)/titleBg:getContentSize().width)
        titleBg:setPosition(ccp((self.rTvWidth-60)*0.5,self.cellHeight*0.5))
        cellBg:addChild(titleBg,4)
    end
end
------------------------军团商店-------------------------
function allPropDialog:initArmyShopInCell(idx,cellBg)
        local lbNameFontSize,nameSubPosY,desSize2 = 22,30,18
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 20,16,16
        end
        local cellData,strPosx=self.curShopItem[idx],95
        local nameStrTb={}
        for k,v in pairs(cellData.rewardTb) do
            table.insert(nameStrTb,v.name.." x"..FormatNumber(v.num))
        end
        local nameLb=GetTTFLabel(table.concat(nameStrTb, ", "),lbNameFontSize)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setColor(G_ColorGreen)
        nameLb:setPosition(ccp(strPosx,self.cellHeight-nameSubPosY))
        cellBg:addChild(nameLb)

        local limitLb=GetTTFLabel("("..cellData.curTime.."/"..cellData.maxTime..")",lbNameFontSize)
        limitLb:setAnchorPoint(ccp(0,0.5))
        limitLb:setPosition(ccp(2+nameLb:getContentSize().width+5 + nameLb:getPositionX(),nameLb:getPositionY()))
        cellBg:addChild(limitLb)

        local award=cellData.rewardTb[1]
        local icon
        local iconSize=100
        if(award.type and award.type=="e")then
            if(award.eType)then
                if(award.eType=="a")then
                    icon=accessoryVoApi:getAccessoryIcon(award.key,80,iconSize)
                elseif(award.eType=="f")then
                    icon=accessoryVoApi:getFragmentIcon(award.key,80,iconSize)
                elseif(award.pic and award.pic~="")then
                    icon=GetBgIcon(award.pic,nil,nil,80,iconSize)
                end
            end
        elseif(award.equipId)then
            local eType=string.sub(award.equipId,1,1)
            if(eType=="a")then
                icon=accessoryVoApi:getAccessoryIcon(award.equipId,80,iconSize)
            elseif(eType=="f")then
                icon=accessoryVoApi:getFragmentIcon(award.equipId,80,iconSize)
            elseif(eType=="p")then
                icon=GetBgIcon(accessoryCfg.propCfg[award.equipId].icon,nil,nil,80,iconSize)
            end
        elseif(award.pic and award.pic~="")then
            icon=GetBgIcon(award.pic,nil,nil,80,iconSize)
        end
        if(icon)then
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(ccp(10,self.cellHeight*0.5))
            cellBg:addChild(icon)
            icon:setScale(80/icon:getContentSize().width)
        end

        local descLb=GetTTFLabelWrap(getlocal(cellData.rewardTb[1].desc),desSize2,CCSizeMake(self.rTvWidth - 230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(ccp(strPosx,(self.cellHeight-25)*0.5))
        cellBg:addChild(descLb)
        if descLb:getContentSize().height > self.cellHeight*0.65 then
            descLb:setFontSize(desSize2 - 2)
        end

        local priceDescLb=GetTTFLabel(getlocal("alliance_contribution"),lbNameFontSize)
        cellBg:addChild(priceDescLb)

        local costPrice = cellData.price
        local priceLb=GetTTFLabel(costPrice,lbNameFontSize)
        if(allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid())<costPrice)then
            priceLb:setColor(G_ColorRed)
        else
            priceLb:setColor(G_ColorYellowPro)
        end
        cellBg:addChild(priceLb)

        local function onClick(tag,object)
                           -- body
            if(allianceVoApi:getJoinTime()>=base.serverTime-allianceShopCfg.cdTime)then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceShop_errorNewmemberCD",{allianceShopCfg.cdTime/3600}),30)
                do return end
            end
            if self.useSubTabNum == 2 and (cellData.userBuy>=cellData.maxPTime)then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceShop_errorHasBuy"),30)
                do return end
            end
            if(allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid())<cellData.price)then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceShop_donateNotEnough"),30)
                do return end
            end
            
            local function confirmHandler( ... )
                if(tag)then
                    if self.useSubTabNum == 2 then
                        self:buyItem2(tag-self.tagOffset)
                    else    
                        self:buyItem(tag-self.tagOffset)
                    end
                end
            end
            local keyName = "alliance_shop_buy"
            local function secondTipFunc(sbFlag)
                local sValue=base.serverTime .. "_" .. sbFlag
                G_changePopFlag(keyName,sValue)
            end
            if G_isPopBoard(keyName) then
               G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des3",{cellData.price}),true,confirmHandler,secondTipFunc)
            else
                confirmHandler()
            end
        end


        local buyItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onClick,nil,getlocal("code_gift"),34)
        buyItem:setTag(self.tagOffset+idx)
        buyItem:setScale(0.6)
        if cellData.curTime>=cellData.maxTime then
            buyItem:setEnabled(false)
        end
        local buyBtn = CCMenu:createWithItem(buyItem)
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        cellBg:addChild(buyBtn)

        buyBtn:setPosition(ccp(self.rTvWidth - buyItem:getContentSize().width*0.5*0.65 - 5,30))
        priceDescLb:setPosition(ccp(buyBtn:getPositionX(),self.cellHeight*0.75))
        priceLb:setPosition(ccp(buyBtn:getPositionX(),self.cellHeight*0.55))

        if self.useSubTabNum ~= 2 then
            local selfLv=allianceVoApi:getSelfAlliance().level
            if(selfLv<cellData.lv)then
                local mask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
                mask:setContentSize(CCSizeMake(self.rTvWidth + 4,self.cellHeight + 4))
                mask:setOpacity(200)
                mask:setPosition(getCenterPoint(cellBg))
                mask:setTouchPriority(-(self.layerNum-1)*20-2)
                cellBg:addChild(mask,2)
                local unlockDesc=GetTTFLabelWrap(getlocal("alliance_skillUnlockLv",{cellData.lv}),28,CCSizeMake(self.rTvWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                unlockDesc:setColor(G_ColorRed)
                unlockDesc:setPosition(ccp((self.rTvWidth-60)*0.5,self.cellHeight*0.5))
                cellBg:addChild(unlockDesc,3)
                local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
                titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,unlockDesc:getContentSize().height+10))
                titleBg:setScaleX((self.rTvWidth-100)/titleBg:getContentSize().width)
                titleBg:setPosition(ccp((self.rTvWidth-60)*0.5,self.cellHeight*0.5))
                cellBg:addChild(titleBg,2)
            end
        end
end
------------------------金币商店-------------------------
function allPropDialog:initGemsShopInCell(idx,cellBg)
        local lbNameFontSize,nameSubPosY,desSize2 = 22,30,18
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 20,20,16
        end
        local tabItem,strPosx = self.curShopItem,95
        local lbName=GetTTFLabelWrap(getlocal(tabItem[idx].name),lbNameFontSize,CCSizeMake(self.rTvWidth - 190,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
        lbName:setColor(G_ColorGreen)
        lbName:setPosition(strPosx,self.cellHeight-nameSubPosY)
        lbName:setAnchorPoint(ccp(0,0.5));
        cellBg:addChild(lbName,2)

        local pid="p"..tabItem[idx].sid
       -- local sprite = CCSprite:createWithSpriteFrameName(tabItem[idx].icon);
        local sprite
        if pid=="p56" then
            sprite = GetBgIcon(tabItem[idx].icon,nil,nil,70,100)
        elseif pid=="p57" then
            sprite = GetBgIcon(tabItem[idx].icon,nil,nil,80,100)
        elseif pid=="p866" then
            sprite = CCSprite:createWithSpriteFrameName("item_prop_866.png")
        elseif propCfg[pid].useGetHero then
            local heroData={h=G_clone(propCfg[pid].useGetHero)}
            local itemTb=FormatItem(heroData)
            local item=itemTb[1]
            if item and item.type=="h" then
                if item.eType=="h" then
                    local productOrder=item.num
                    sprite = heroVoApi:getHeroIcon(item.key,productOrder,true,touch,nil,nil,nil,{adjutants={}})
                else
                    sprite = heroVoApi:getHeroIcon(item.key,1,false,touch)
                end
            end
        else
            local propData={p={}}
            propData.p[pid]=0
            local itemTb = FormatItem(propData)
            local item = itemTb[1]
            if item then
                sprite = G_getItemIcon(item,100)
            end
        end
        sprite:setAnchorPoint(ccp(0,0.5));
        sprite:setPosition(ccp(10,self.cellHeight*0.5))
        if sprite and sprite:getContentSize().width>80 then
            sprite:setScale(80/sprite:getContentSize().width)
        end
        cellBg:addChild(sprite,2)
       
        local lbDescription=GetTTFLabelWrap(getlocal(tabItem[idx].description),desSize2,CCSizeMake(self.rTvWidth - 230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        lbDescription:setPosition(strPosx,(self.cellHeight-25)*0.5)
        lbDescription:setAnchorPoint(ccp(0,0.5));
        cellBg:addChild(lbDescription,2)
        if lbDescription:getContentSize().height > self.cellHeight*0.65 then
            lbDescription:setFontSize(desSize2 - 2)
        end
       
        local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
        cellBg:addChild(gemIcon,2)
        local costNum = tabItem[idx].gemCost
        local lbPrice=GetTTFLabel(costNum,24)
        
        lbPrice:setAnchorPoint(ccp(0,0.5));
        cellBg:addChild(lbPrice,2)
       
        
        local function touch1(tag,object)
            if self.rTv:getIsScrolled()==true then
                do return end
            end
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
      
            local function touchBuy(num)
                local function callbackBuyprop(fn,data)
                    if base:checkServerData(data)==true then
                        --统计购买物品
                        statisticsHelper:buyItem("p"..tabItem[idx].sid,tabItem[idx].gemCost,1,tabItem[idx].gemCost)
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{getlocal(tabItem[idx].name)}),28)
                        -- self.shoptabItemBag=bagVoApi:getShopItemByType(2)
                        -- self.shoptabItemBagType1=bagVoApi:getShopItemByType(1)
                        -- self.shoptabItemBagType2=bagVoApi:getShopItemByType(3)
                        -- self.shoptabItemBagType3=bagVoApi:getShopItemByType(4)
                        -- print("here???~#@#!~@~@~!@!~@~!@~@!~@!~")
                        local lb1 = allShopVoApi:getNeedrLb("gems")
                        if self.rTopDes1 then
                            self.rTopDes1:setString(lb1)
                            self.rBtn:setPosition(ccp(self.rTopDes1:getPositionX() + self.rTopDes1:getContentSize().width + 10,self.rTopDes1:getPositionY()))
                        end
                    end

                end
                socketHelper:buyProc(tag,callbackBuyprop,num)
            end
             
            local function showBuyDialog()
              shopVoApi:showBatchBuyPropSmallDialog(pid,self.layerNum+1,touchBuy)
            end
            local function buyGems()
            if G_checkClickEnable()==false then
                do return end
            end
                vipVoApi:showRechargeDialog(self.layerNum+1)
            end

            if playerVo.gems<tonumber(tabItem[idx].gemCost) then
                local num=tonumber(tabItem[idx].gemCost)-playerVo.gems
                local smallD=smallDialog:new()
                     smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(tabItem[idx].gemCost),playerVo.gems,num}),nil,self.layerNum+1)
            else
                local smallD=smallDialog:new()
                showBuyDialog()
            end   
        end
        
        local menuItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touch1,tabItem[idx].sid,getlocal("buy"),35,100)
        menuItem:setScale(0.6)

        menuItem:setEnabled(true);
        if playerVo.gems < costNum then
            lbPrice:setColor(G_ColorRed)
        end
        local menu3=CCMenu:createWithItem(menuItem);
        menu3:setPosition(ccp(self.rTvWidth - menuItem:getContentSize().width*0.5*0.65 - 5,35))
        gemIcon:setPosition(ccp(menu3:getPositionX() -20,self.cellHeight*0.65));
        lbPrice:setPosition(ccp(menu3:getPositionX() -5,self.cellHeight*0.65))

        menu3:setTouchPriority(-(self.layerNum-1)*20-2);
        cellBg:addChild(menu3,6)

        local btnTb={}
        table.insert(btnTb,{name=getlocal("buy"),tag=tabItem[idx].sid,callback=touch1})
        local isShow=propCfg[pid].isShow
        if isShow and isShow==1 then
          local function  showDisplayDialog()
            if self.rTv:getIsScrolled()==true then
                do return end
            end
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local sbReward = G_rewardFromPropCfg(pid)
            local titleStr=getlocal(propCfg[pid].name)
            local desStr
            local random = propCfg[pid].isRandom
            if random and random==1 then
              desStr=getlocal("database_des1")
            else
              desStr=getlocal("database_des2")
            end
            bagVoApi:showPropDisplaySmallDialog(self.layerNum+1,sbReward,titleStr,desStr,btnTb)
           end
           local touchSp=LuaCCSprite:createWithSpriteFrameName("datebaseShow1.png",showDisplayDialog)
           touchSp:setTouchPriority(-(self.layerNum-1)*20-2);
           touchSp:setScale(80/touchSp:getContentSize().width)
           touchSp:setIsSallow(false)
           touchSp:setAnchorPoint(ccp(0,0.5));
           touchSp:setPosition(10,self.cellHeight/2)
           -- touchSp:setOpacity(0)
           cellBg:addChild(touchSp,2)

           local fangdajinSp=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
           fangdajinSp:setAnchorPoint(ccp(1,0))
           fangdajinSp:setPosition(touchSp:getContentSize().width-5,5)
           -- touchSp:setOpacity(0)
           touchSp:addChild(fangdajinSp,2)
        end
end
------------------------坦克涂装商店----------------------
function allPropDialog:initTankSkinShopInCell(idx,cellBg)
    local nameFontSize,nameSubPosY,desSize,strPosx = 22,30,20,95
    if G_isAsia() == false then
        nameFontSize,nameSubPosY,desSize= 20,20,18
    end
    local shopItem = self.curShopItem[idx]
    local saleId = shopItem.id
    local saleItem = allShopVoApi:getTankSkinSaleData( )[saleId] or nil
    local saleP = saleItem and saleItem.dis or 1
    -- print("saleP--->>>",saleP,saleId)
    if shopItem==nil then
        do return end
    end
    local iconWidth = 80
    local reward = shopItem.reward
    local price = shopItem.price
    local ticketId, discount = tankSkinVoApi:getBestDiscountTicket(reward.key) --涂装折扣券折扣  
    saleP = tonumber(string.format("%.2f",saleP * (discount or 1)))
    local rewardSp=G_getItemIcon(reward,100,nil,self.layerNum+1)
    rewardSp:setScale(iconWidth/rewardSp:getContentSize().width)
    rewardSp:setAnchorPoint(ccp(0,0))
    rewardSp:setPosition(10,5)--ccp(10,self.cellHeight*0.5))
    cellBg:addChild(rewardSp,1)

    local iconHeight = iconWidth + 5
    local maxNameWidth = self.rTvWidth*0.65
    local nameLb = GetTTFLabel(reward.name,nameFontSize)
    local lbWidth = nameLb:getContentSize().width
    local nameLbWidth = lbWidth
    if lbWidth > maxNameWidth then
        isSc = maxNameWidth / lbWidth
        nameLb:setScale(isSc)
        nameLbWidth = lbWidth*isSc
    end
    nameLb:setAnchorPoint(ccp(0,0))
    nameLb:setPosition(10,iconHeight + 3)--strPosx,self.cellHeight-nameSubPosY)
    nameLb:setColor(G_ColorYellowPro)
    cellBg:addChild(nameLb,2)
    local numLb
    local isTop = (shopItem.num == shopItem.bn and shopItem.bn > 0) and true or false
    if shopItem.stype~=1 then --如果是道具没有限购次数
        local posx = G_getCurChoseLanguage() =="ar" and nameLbWidth + 13 or nameLb:getPositionX() + nameLbWidth + 3
        numLb = GetTTFLabel("("..shopItem.num.."/"..shopItem.bn..")",nameFontSize)
        numLb:setAnchorPoint(ccp(0,0))
        numLb:setPosition(posx,nameLb:getPositionY())
        cellBg:addChild(numLb,2)
    end

    local descStr,descColor = "",G_ColorWhite
    if shopItem.status==1 then --不可购买，敬请期待
        descStr,descColor = getlocal("alliance_notOpen"),G_ColorRed
    else
        if shopItem.stype==2 then --部队涂装
            descStr = getlocal("tankSkin_desc_tip")..getlocal(shopItem.desc)
        else
            descStr = getlocal(shopItem.desc)
        end
    end

    local descLb=GetTTFLabelWrap(descStr,desSize,CCSize(self.rTvWidth - 230,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb:setPosition(strPosx,(self.cellHeight-25)*0.5)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setColor(descColor)
    cellBg:addChild(descLb,2)
    if descLb:getContentSize().height > self.cellHeight*0.65 then
        descLb:setFontSize(desSize - 2)
    end

    if shopItem.status~=1 then --暂未开放的涂装不显示购买
        local function buyHandler()
            -- print("self.rTv:getScrollEnable(),self.rTv:getIsScrolled()",self.rTv:getScrollEnable(),self.rTv:getIsScrolled())
            if self.rTv:getScrollEnable() == true and self.rTv:getIsScrolled() == false then
                if shopItem.stype ~= 1 and shopItem.num >= shopItem.bn then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage1987"),30)
                    do return end
                end
                if shopItem.stype==2 then
                    local ownFlag,tankId = tankSkinVoApi:isTankOwnedBySkinId(reward.key)
                    if ownFlag==false then --如果涂装对应的坦克数量为0，则给提示
                        if tankId then
                            local tankNameStr = getlocal(tankCfg[tankId].name)
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("tankSkin_buy_disable",{tankNameStr}),30)
                        end
                        do return end
                    end
                end
                local gems = playerVoApi:getGems()
                local newPrice = math.floor(saleP * price)
                if gems<newPrice then
                    GemsNotEnoughDialog(nil,nil,newPrice-gems,self.layerNum+1,newPrice)
                    do return end
                end
                if shopItem.stype==1 then --如果是道具的话，支持批量购买操作
                    local pId,rId = reward.key,reward.id
                    local function touchBuy(num)
                        local function callbackBuyprop(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if base:checkServerData(data)==true then
                                --统计购买物品
                                statisticsHelper:buyItem(pId,newPrice,num,newPrice)
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
                                if sData.data and sData.data.tankskin then
                                    tankSkinVoApi:formatData(sData.data.tankskin)
                                end
                                local costGems = num*newPrice
                                -- playerVoApi:setGems(playerVoApi:getGems()-costGems)
                                self:curSubTabInfo("tskin",1)
                            end
                        end
                        socketHelper:buyProc(rId,callbackBuyprop,num)
                    end

                    self.tskinShowPanel = shopVoApi:showBatchBuyPropSmallDialog(pId,self.layerNum+1,touchBuy)
                else
                    local ticketId, discount = tankSkinVoApi:getBestDiscountTicket(reward.key) --折扣券
                    local function buyCallBack()
                        local function callback(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                if sData.data and sData.data.tankskin then
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
                                    playerVoApi:setGems(playerVoApi:getGems()-newPrice)
                                    if ticketId then --需要消耗折扣券则扣除折扣券
                                        bagVoApi:useItemNumId(tonumber(RemoveFirstChar(ticketId)), 1)
                                    end
                                    tankSkinVoApi:formatData(sData.data.tankskin)
                                    self:curSubTabInfo("tskin",1)
                                end
                            end
                        end
                        socketHelper:buyTankSkin(shopItem.id,callback)
                    end
                    -- local popKey = "tskinShop"
                    -- local function secondTipFunc(sbFlag)
                    --     local sValue=base.serverTime .. "_" .. sbFlag
                    --     G_changePopFlag(popKey,sValue)
                    -- end
                    local tipStr = ""
                    if ticketId then --有折扣券
                        tipStr = {getlocal("tksin_discount_buytip",{1, getlocal(propCfg[ticketId].name), newPrice}),{nil,G_ColorGreen,nil,G_ColorGreen,nil}}
                    else
                        tipStr = getlocal("second_tip_des",{newPrice})
                    end
                    -- if G_isPopBoard(popKey) then
                        self.tskinShowPanel = G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),tipStr,false,buyCallBack,secondTipFunc)
                    -- else
                        -- buyCallBack()
                    -- end
                end
            end
        end
        local btnScale = 0.6
        local buyBtn,buyMenu=G_createBotton(cellBg,ccp(self.rTvWidth - 205*0.5*btnScale - 5,35),{getlocal("buy")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",buyHandler,btnScale,-(self.layerNum-1)*20-2)
        local btnStr = buyBtn:getChildByTag(101)
        btnStr:setFontSize(34)
        if shopItem.status==1 then
            buyBtn:setEnabled(false)
        else
            buyBtn:setEnabled(true)
        end
        if isTop then
            btnStr:setString(getlocal("hasBuy"))
            buyMenu:setPositionY(cellBg:getContentSize().height / 2)
        else
            local realPrice = math.floor(price * saleP)
            local gemIconSp=CCSprite:createWithSpriteFrameName("IconGold.png")
            cellBg:addChild(gemIconSp,2)
            local priceLb=GetTTFLabel(realPrice,24)
            priceLb:setAnchorPoint(ccp(0,0.5))
            cellBg:addChild(priceLb,2)
            if playerVoApi:getGems() < realPrice then
                priceLb:setColor(G_ColorRed)
            else
                priceLb:setColor(G_ColorWhite)
            end

            gemIconSp:setPosition(ccp(buyMenu:getPositionX() -20,self.cellHeight*0.65 - 5))
            priceLb:setPosition(ccp(buyMenu:getPositionX() -5,self.cellHeight*0.65 - 5 ))

            if saleP > 0 and saleP < 1 then
                local discountSp = CCSprite:createWithSpriteFrameName("disticket.png")
                discountSp:setPosition(ccp(rewardSp:getContentSize().width - discountSp:getContentSize().width / 2,rewardSp:getContentSize().height - discountSp:getContentSize().height / 2 + 20))
                rewardSp:addChild(discountSp)

                -- 折扣券文字
                local saleLabel = GetTTFLabel((saleP * 100).."%", 24, true)
                -- saleLabel:setAnchorPoint(ccp(0, 0.5))
                saleLabel:setPosition(ccp(44, discountSp:getContentSize().height - 42))
                discountSp:addChild(saleLabel)

                local gemIconSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
                cellBg:addChild(gemIconSp2,2)
                local priceLb2=GetTTFLabel(price,24)
                priceLb2:setAnchorPoint(ccp(0,0.5))
                cellBg:addChild(priceLb2,2)

                local line = CCSprite:createWithSpriteFrameName("redline.jpg")
                line:setScaleX((priceLb2:getContentSize().width  + 30) / 4)
                line:setPosition(getCenterPoint(priceLb2))
                priceLb2:addChild(line)

                gemIconSp2:setPosition(ccp(buyMenu:getPositionX() -20,self.cellHeight*0.85))
                priceLb2:setPosition(ccp(buyMenu:getPositionX() -5,self.cellHeight*0.85 ))
            end
        end
    end
end

------------------------军功商店 请求或刷新数据使用-------------------------------------------------
function allPropDialog:featBuyItem(index)
    local cellData=self.curShopItem[index]
    if(cellData.curTime<cellData.maxTime and rpShopVoApi:getPersonalBuy(cellData.id)<rpShopVoApi:getPersonalMaxBuy(cellData.id))then
        local function callback()
            local canBuyLb=tolua.cast(self.featBuyLbTb[cellData.id],"CCLabelTTF")
            canBuyLb:setString(getlocal("activity_vipRight_can_buy",{rpShopVoApi:getPersonalMaxBuy(cellData.id) - rpShopVoApi:getPersonalBuy(cellData.id)}))
            -- self.parent.rpOwnLb:setString(getlocal("propOwned").." "..FormatNumber(playerVoApi:getRpCoin()))
            self:featRefresh()
        end
        rpShopVoApi:buyItem(cellData.id,callback)
    end
end
------------------------军团商店 请求或刷新数据使用-------------------------------------------------
function allPropDialog:buyItem(index)--只用于军团商店 第一个页签
    local cellData=self.curShopItem[index]
    if(cellData.curTime<cellData.maxTime)then
        local function callback()
            local function calSelfSubInfo(selectShop)
                self:curSubTabInfo(selectShop,1)
            end
            allShopVoApi:SocketNewData("army",1,calSelfSubInfo)
        end
        allianceShopVoApi:buyItem(1,cellData.id,nil,callback)
    end
end
function allPropDialog:buyItem2(index)--只用于军团商店 第2个页签
    local cellData=self.curShopItem[index]
    if(cellData.curTime<cellData.maxTime)then
        local function callback()
            local function calSelfSubInfo(selectShop)
                self:curSubTabInfo(selectShop,2)
            end
            allShopVoApi:SocketNewData("army",2,calSelfSubInfo)
        end
        allianceShopVoApi:buyItem(2,cellData.id,cellData.index,callback)
    end
end
------------------------异元商店 请求或刷新数据使用-------------------------------------------------
function allPropDialog:diffBuyItem(shopVo)--只用于 第一个页签
    local id=shopVo.id
    local num=shopVo.num
    local shopItems=dimensionalWarVoApi:getShopItems()
    local cfg=shopItems[id]
    local rewardTb=FormatItem(cfg.reward)
    local price=cfg.price
    local maxNum=cfg.buynum

    if (num<maxNum) and (dimensionalWarVoApi:getPoint()>=price) then
        local function callback()
            self:curSubTabInfo("diff",1)
            self:tick()
            dimensionalWarVoApi:setPointDetailFlag(-1)
            local lastBuyTime=dimensionalWarVoApi:getLastBuyTime()
            self.diffIsToday=G_isToday(lastBuyTime)
        end
        dimensionalWarVoApi:buyItem(id,callback)
    end
end
------------------------军功商店 请求或刷新数据使用-------------------------------------------------
function allPropDialog:featRefresh(featItemVo)
    if(featItemVo and self.curShopItem)then
        if(featItemVo.type=="i")then
            for k,v in pairs(self.curShopItem) do
                if(v.id==featItemVo.id)then
                    v.curTime=featItemVo.buyNum
                    if(self.featLimitTb and v.id and self.featLimitTb[v.id] and tolua.cast(self.featLimitTb[v.id],"CCLabelTTF"))then
                        self.featLimitTb[v.id]:setString("("..v.curTime.."/"..v.maxTime..")")
                        if(v.curTime>=v.maxTime)then
                            local buyItem=self.featBuyItemTb[v.id]
                            if(buyItem and buyItem.getChildByTag)then
                                local lb=tolua.cast(buyItem:getChildByTag(518),"CCLabelTTF")
                                if(lb)then
                                    lb:setString(getlocal("soldOut"))
                                    buyItem:setEnabled(false)
                                end
                            end
                        end
                    end
                    break
                end
            end
        elseif(featItemVo.type=="a")then
            for k,v in pairs(self.curShopItem) do
                if(v.id==featItemVo.id)then
                    v.curTime=featItemVo.buyNum
                    if(self.featLimitTb and v.id and self.featLimitTb[v.id] and tolua.cast(self.featLimitTb[v.id],"CCLabelTTF"))then
                        self.featLimitTb[v.id]:setString("("..v.curTime.."/"..v.maxTime..")")
                        if(v.curTime>=v.maxTime)then
                            local buyItem=self.featBuyItemTb[v.id]
                            if(buyItem and buyItem.getChildByTag)then
                                local lb=tolua.cast(buyItem:getChildByTag(518),"CCLabelTTF")
                                if(lb)then
                                    lb:setString(getlocal("soldOut"))
                                    buyItem:setEnabled(false)
                                end
                            end
                        end
                    end
                    break
                end
            end
        end
    else
        local function calSelfSubInfo(selectShop,subTabNum)
            self:curSubTabInfo(selectShop,subTabNum)
        end
        allShopVoApi:SocketNewData("feat",self.useSubTabNum,calSelfSubInfo,true)
    end
end

-------------------------金币商店 跳转背包--------------------------------------------------------
function allPropDialog:initGoToBagBtn(bgSp)--金币商店 跳转背包
    local function goToBagCall( )
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        activityAndNoteDialog:closeAllDialog()
        local td=shopVoApi:showPropDialog(3,true)
    end 
    local BagItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goToBagCall,nil,getlocal("bundle"),34,11)
    BagItem:setScale(0.6)
    local BagBtn=CCMenu:createWithItem(BagItem);
    BagBtn:setTouchPriority(-(self.layerNum-1)*20-2);
    BagBtn:setPosition(ccp(bgSp:getContentSize().width*0.85,self.sIcon:getPositionY()))
    self.goToBagBtn = BagBtn
    bgSp:addChild(BagBtn)
end

-------------------------涂装商店 跳转--------------------------------------------------------
function allPropDialog:initGoToTankHouse(bgSp)
    local function goToTankHouse()
        local buildVo=buildingVoApi:getBuildiingVoByBId(15)
        if buildVo==nil then
            do return end
        end
        if buildVo.status==-1 then --地库未开启
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("port_scene_building_tip_14"),nil,self.layerNum+1)
            do return end
        end
        activityAndNoteDialog:closeAllDialog()
        if FuncSwitchApi:isEnabled("diku_repair") == false then
            tankWarehouseScene:setShow()
        else
            tankVoApi:showTankWarehouseDialog(3,2)
        end
    end
    self.goToTankHouseBtn=G_createBotton(bgSp,ccp(bgSp:getContentSize().width*0.85,self.sIcon:getPositionY()),{getlocal("sample_build_name_17")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goToTankHouse,0.6,-(self.layerNum-1)*20-2)
    local goStr = self.goToTankHouseBtn:getChildByTag(101)
    goStr:setFontSize(34)
end

-------------------------军功商店 添加时间告示-----------------------------------------------------
function allPropDialog:addFeatBeginTime()
    local strSize2 = G_isAsia() and 21 or 20
    if G_getCurChoseLanguage() == "ru" then
        strSize2 = 15
    end
    local openLb1=GetTTFLabel(getlocal("serverwar_opentime",{""}),strSize2)
    openLb1:setColor(G_ColorGreen)
    openLb1:setAnchorPoint(ccp(0,0.5))
    openLb1:setPosition(ccp(self.sIcon:getPositionX(),self.rightUpBg:getContentSize().height*0.3))
    self.rightUpBg:addChild(openLb1)
    self.featBeginTime1 = openLb1
    local openLb2=GetTTFLabel(getlocal("rpshop_openTime"),strSize2)
    openLb2:setAnchorPoint(ccp(0,0.5))
    openLb2:setPosition(ccp(openLb1:getPositionX() + openLb1:getContentSize().width + 5,openLb1:getPositionY()))
    self.rightUpBg:addChild(openLb2)
    self.featBeginTime2 = openLb2
end
------------------------------------------------------------------------------------------------
function allPropDialog:addRefreshBtn()--某些商店的刷新使用
    local function touchRefreshBtn()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.curShopType == "drill" then------军演商店刷新使用
            print("refrsh in drill~~~~~~~~")
            local cost = arenaVoApi:getRefreshCost()
            if playerVoApi:getGems()<cost then
                GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
                return
            end
            local function callback()
                local function reShop(fn,data)
                  local ret,sData=base:checkServerData(data)
                  if ret==true then
                       playerVoApi:setGems(playerVoApi:getGems() - cost)
                       local function calSelfSubInfo(selectShop)
                            arenaVoApi:setBuy()
                            self:curSubTabInfo(selectShop,1)
                       end
                       allShopVoApi:SocketNewData("drill",1,calSelfSubInfo,nil,true)
                  end
                end
                socketHelper:shamBattleRefshop(reShop)
            end
            if cost==0 then
                callback()
            else
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callback,getlocal("dialog_title_prompt"),getlocal("expendition_refreshDesc",{cost}),nil,self.layerNum+1)
            end
        elseif self.curShopType =="expe" then
              local cost = expeditionVoApi:getRefreshCost()
              if playerVoApi:getGems()<cost then
                  GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
                  return
              end
              local function callback()
                local function reShop(fn,data)
                      local ret,sData=base:checkServerData(data)
                      if ret==true then
                          playerVoApi:setGems(playerVoApi:getGems() - cost)
                          local function calSelfSubInfo(selectShop)
                                expeditionVoApi:setBuy()
                                self:curSubTabInfo(selectShop,1)
                          end
                          allShopVoApi:SocketNewData("expe",1,calSelfSubInfo,nil,true)
                      end
                end
                socketHelper:expeditionRefshop(reShop)
              end
              if cost==0 then
                  callback()
              else
                  smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callback,getlocal("dialog_title_prompt"),getlocal("expendition_refreshDesc",{cost}),nil,self.layerNum+1)
              end
        end
    end--freshIcon.png
    
    if self.curShopType == "drill" or self.curShopType == "expe" then
        if self.freshBtn then
            self.freshBtn:setVisible(true)
        else

            local refreshItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchRefreshBtn,nil,getlocal("dailyTaskFlush"),34,101)
            refreshItem:setScale(0.6)
            self.freshBtn = CCMenu:createWithItem(refreshItem)--LuaCCSprite:createWithSpriteFrameName("freshIcon.png",touchRefreshBtn)
            self.freshBtn:setTouchPriority(-(self.layerNum-1)*20-3)
            self.freshBtn:setAnchorPoint(ccp(1,1))
            
            if G_isAsia() then
                self.freshBtn:setPosition(ccp(self.rightUpBg:getContentSize().width*0.85,self.rightUpBg:getContentSize().height*0.3))
            else
                self.freshBtn:setPosition(ccp(self.rightUpBg:getContentSize().width*0.85, -5 - refreshItem:getContentSize().height*0.5*0.6 ))
            end
            self.rightUpBg:addChild(self.freshBtn)
        end
    else
        if self.freshBtn then
            self.freshBtn:setVisible(false)
        end
    end
end

function allPropDialog:useTickDataCall(selectShop)

    if selectShop ~= "diff" then
        if self.noRecordLb then
            self.noRecordLb:removeFromParentAndCleanup(true)
            self.noRecordLb = nil
        end
    end

    if selectShop =="army" then
        if self.useSubTabNum ==nil or self.useSubTabNum == 1 then
            self.countdown=allianceShopVoApi:getNextRefreshTime(1)-base.serverTime
        elseif self.useSubTabNum == 2 and self.countdown2 == nil then
            self.countdown2=allianceShopVoApi:getNextRefreshTime(2)-base.serverTime
        end
    elseif selectShop =="diff" then
        if self.useSubTabNum == 2 then
            local pointDetail=dimensionalWarVoApi:getPointDetail()
            local num=SizeOfTable(pointDetail)
            if self.noRecordLb then
                if num == nil or num == 0 then
                    self.noRecordLb:setString(getlocal("serverwar_point_no_record"))
                    self.noRecordLb:setVisible(true)
                else
                    self.noRecordLb:setVisible(false)
                end
            else
                if num == nil or num == 0 then
                    self.noRecordLb=GetTTFLabelWrap(getlocal("serverwar_point_no_record"),30,CCSizeMake(self.rTvWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    self.noRecordLb:setPosition(getCenterPoint(self.rShoppingBg))
                    self.rShoppingBg:addChild(self.noRecordLb,1)
                    self.noRecordLb:setColor(G_ColorYellowPro)
                end
            end
            
        else
            if self.noRecordLb then
                self.noRecordLb:setVisible(false)
            end
        end
    elseif selectShop == "matr" then
        self.lastMatrShopType = self.matrShopType
        self.matrShopType,self.matrShopInfo,self.matrShopNum=armorMatrixVoApi:getShopInfo()
    elseif selectShop == "feat" then
        self.featLimitTb={}
        self.featBuyItemTb={}
        self.featBuyLbTb={}
    end
end
function allPropDialog:tick( )
    if self.curShopType == "army" then
        if self.useSubTabNum == nil or self.useSubTabNum == 1 then
            if(self.countdown)then
                self.countdown=self.countdown-1
                if(self.countdown<=0)then
                        local function calSelfSubInfo(selectShop)
                            self:curSubTabInfo(selectShop,1)
                            -- self:useTickDataCall(selectShop)
                        end
                        allShopVoApi:SocketNewData("army",1,calSelfSubInfo,nil,true)
                end
            end
        elseif self.useSubTabNum == 2 then
            if(self.countdown2)then
                self.countdown2=self.countdown2-1
                if(self.countdown2<=0)then
                        local function calSelfSubInfo(selectShop)
                            self:curSubTabInfo(selectShop,2)
                            -- self:useTickDataCall(selectShop)
                        end
                        allShopVoApi:SocketNewData("army",2,calSelfSubInfo,nil,true)
                end
            end
        end
    elseif self.curShopType == "drill" then
        local isToday = arenaVoApi:isShopToday()
        if isToday==false and self.rTv then
                local function calSelfSubInfo(selectShop)
                    self:curSubTabInfo(selectShop,1)
                end
                allShopVoApi:SocketNewData("drill",1,calSelfSubInfo,nil,true)
        end

        if self and self.rTopDes2 then
            local timeStr=arenaVoApi:getRefreshTimeStr()
            self.rTopDes2:setString(getlocal("expeditionRefreshTime",{timeStr}))
        end
    elseif self.curShopType == "expe" then
        if base.ea==1 then
            local isToday = expeditionVoApi:isToday()
            if isToday==false and self.rTv then
                local function calSelfSubInfo(selectShop)
                    self:curSubTabInfo(selectShop,1)
                end
                allShopVoApi:SocketNewData("expe",1,calSelfSubInfo,nil,true)
            end
        end

        if self and self.rTopDes2 then
            local timeStr=expeditionVoApi:getRefreshTimeStr()
            self.rTopDes2:setString(getlocal("expeditionRefreshTime",{timeStr}))
        end
    elseif self.curShopType == "diff" then
        if self.useSubTabNum ==nil or self.useSubTabNum == 1 then
            local lb1,lb2 = allShopVoApi:getNeedrLb("diff",1)
            if lb1 and self.rTopDes1 then
                self.rTopDes1:setString(lb1)
                self.rBtn:setPosition(ccp(self.rTopDes1:getPositionX() + self.rTopDes1:getContentSize().width + 10,self.rTopDes1:getPositionY()))
            end
            local lastBuyTime=dimensionalWarVoApi:getLastBuyTime()
            local isBuyToday=G_isToday(lastBuyTime)
            if self.diffIsToday~=isBuyToday and isBuyToday==false then
                dimensionalWarVoApi:resetBuyNum()
                self.diffIsToday=isBuyToday
                self:curSubTabInfo("diff",1)
            end
        elseif self.useSubTabNum == 2 then
            local flag=dimensionalWarVoApi:getPointDetailFlag()
            if self.diffCallbackNum<3 and flag==-1 then
                local function callback()
                    self:curSubTabInfo("diff",2)
                    dimensionalWarVoApi:setPointDetailFlag(1)
                    self.diffCallbackNum=0
                end
                dimensionalWarVoApi:formatPointDetail(callback)
                self.diffCallbackNum=self.diffCallbackNum+1
            elseif flag==0 then
                self:curSubTabInfo("diff",2)
                dimensionalWarVoApi:setPointDetailFlag(1)
            end
        end
    elseif self.curShopType == "matr" then
        if self.matrShopType and self.matrShopType==2 then
            local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
            local exinfo=armorMatrixInfo.exinfo or {}
            local s=exinfo.s or {}
            local ts=s[1] or 0
            if G_isToday(ts)==false then
                self:curSubTabInfo("matr",1)
            end
        end
    elseif self.curShopType == "feat" then
        if(base.serverTime>=rpShopVoApi.dataExpireTime)and rpShopVoApi and rpShopVoApi:checkShopOpen() then
            local function callback()
                self:featRefresh()
            end
            rpShopVoApi:refresh(callback)
        end
    elseif self.curShopType =="tskin" then
        if not allShopVoApi:tankSkinIsInSale() and G_tzzkSaleData and self.tskinIsInTime then
            self.tskinIsInTime = nil
            G_tzzkSaleData = nil
            self:curSubTabInfo("tskin",1)

            if self.tskinShowPanel and self.tskinShowPanel.close then
                self.tskinShowPanel:close()
            end
            if self.tskinSaleTip then
                self.tskinSaleTip:setVisible(false)
            end
            if self.tskinSaleTipSp then
                self.tskinSaleTipSp:setVisible(false)
            end
        elseif allShopVoApi:tankSkinIsInSale() and G_tzzkSaleData then
            self:initTankSkinTipAndTime(self.rightUpBg)
            local saleP = allShopVoApi:getTankSkinSaleDis()
            self.tskinSaleTip:setString(getlocal("newTankSkinTime",{saleP*10,G_formatActiveDate(G_tzzkSaleData.et - base.serverTime)}))
            if self.tskinSaleTipSp then
                self.tskinSaleTipSp:setVisible(true)
            end
            if self.tskinIsInTime == nil then
                self.tskinIsInTime = true
                self:curSubTabInfo("tskin",1)
            end
        end
    end
end

------坦克皮肤 倒计时初始化显示 -------
function allPropDialog:initTankSkinTipAndTime(rightUpBg)
    if not self.tskinSaleTip then
        local saleP = allShopVoApi:getTankSkinSaleDis()    
        self.tskinSaleTip = GetTTFLabelWrap(getlocal("newTankSkinTime",{saleP*10,G_formatActiveDate(G_tzzkSaleData.et - base.serverTime)}),23,CCSizeMake(rightUpBg:getContentSize().width * 0.76,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter) 
        self.tskinSaleTip:setAnchorPoint(ccp(0,0.5))
        self.tskinSaleTip:setPosition(rightUpBg:getContentSize().width *0.26, - 30)
        self.tskinSaleTip:setColor(G_ColorYellowPro3)
        rightUpBg:addChild(self.tskinSaleTip)
    else
        self.tskinSaleTip:setVisible(true)
    end
end

------------------------优惠商店-------------------------
function allPropDialog:initSpecialShopInCell(idx,cellBg)
    local lbNameFontSize,nameSubPosY,desSize2 = 22,30,18
    if G_isAsia() == false then
        lbNameFontSize,nameSubPosY,desSize2 = 20,20,16
    end
    local itemList,strPosx = self.curShopItem,95
    local pid = itemList[idx]
    local pcfg = propCfg[pid]
    local propData={p={}}
    propData.p[pid]=0
    local itemTb = FormatItem(propData)
    local item = itemTb[1]
    local sprite = G_getItemIcon(item,100)
    sprite:setAnchorPoint(ccp(0,0.5))
    sprite:setPosition(ccp(10,self.cellHeight*0.5))
    if sprite and sprite:getContentSize().width>80 then
        sprite:setScale(80/sprite:getContentSize().width)
    end
    cellBg:addChild(sprite,2)

    local tabItem,strPosx = self.curShopItem,95
    local lbName=GetTTFLabelWrap(getlocal(pcfg.name),lbNameFontSize,CCSizeMake(self.rTvWidth - 190,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    lbName:setColor(G_ColorGreen)
    lbName:setPosition(strPosx,self.cellHeight-nameSubPosY)
    lbName:setAnchorPoint(ccp(0,0.5));
    cellBg:addChild(lbName,2)
    local tmpNameLb = GetTTFLabel(getlocal(pcfg.name),lbNameFontSize)
    if tmpNameLb:getContentSize().height<lbName:getContentSize().height then --文字换行了，则需要缩放一下
        lbName:setScale(0.8)
    end
    if G_getCurChoseLanguage() == "ar" then
        lbName:setPositionX(lbName:getPositionX() - 55)
    end
   
    local lbDescription=GetTTFLabelWrap(getlocal(pcfg.description),desSize2,CCSizeMake(self.rTvWidth - 230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    lbDescription:setPosition(strPosx,(self.cellHeight-25)*0.5)
    lbDescription:setAnchorPoint(ccp(0,0.5));
    cellBg:addChild(lbDescription,2)
    if lbDescription:getContentSize().height > self.cellHeight*0.65 then
        lbDescription:setFontSize(desSize2 - 2)
    end
   
    local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
    cellBg:addChild(gemIcon,2)
    local oldCostNum = 0 --原价
    local costNum = 0 --消耗的金币数
    if pcfg.spCost then
        costNum = allShopVoApi:getSpecialShopItemCost(pid)
        oldCostNum = pcfg.spCost[SizeOfTable(pcfg.spCost)]
    else
        costNum = pcfg.gemCost
        oldCostNum = pcfg.gemCost
    end

    local lbPrice=GetTTFLabel(costNum,24)
    
    lbPrice:setAnchorPoint(ccp(0,0.5));
    cellBg:addChild(lbPrice,2)

    local function touch1(tag,object)
        if self.rTv:getIsScrolled()==true then
            do return end
        end
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local price = allShopVoApi:getSpecialShopItemCost(pid) --因优惠商店价格是变化的，则金币购买统计的单价记为购买之前的最低价格
        local function touchBuy(num)
            local totalCost = allShopVoApi:getSpecialShopItemCost(pid,num) --本次购买花费的总金币数
            local function callbackBuyprop(fn,data)
                if base:checkServerData(data)==true then
                    --统计购买物品，因优惠商店价格是变化的，则金币购买统计的单价记为购买之前的最低价格也就是price
                    statisticsHelper:buyItem(pid,price,num,totalCost)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{getlocal(pcfg.name)}),28)
                    self:curSubTabInfo("preferential",1)
                    local lb1 = allShopVoApi:getNeedrLb("preferential")
                    if self.rTopDes1 then
                        self.rTopDes1:setString(lb1)
                        self.rBtn:setPosition(ccp(self.rTopDes1:getPositionX() + self.rTopDes1:getContentSize().width + 10,self.rTopDes1:getPositionY()))
                    end
                end

            end
            socketHelper:buyProc(tag,callbackBuyprop,num)
        end
         
        local function showBuyDialog()
            local limitNum
            if propCfg[pid].spCost then
                local usePreferentialNum = allShopVoApi:getSpecialShopBuyNum(pid)
                local maxPreferentialNum = SizeOfTable(propCfg[pid].spCost) - 1
                if usePreferentialNum < maxPreferentialNum then
                    limitNum = maxPreferentialNum - usePreferentialNum
                end
            end
            shopVoApi:showBatchBuyPropSmallDialog(pid,self.layerNum+1,touchBuy,nil,limitNum)
        end
        local function buyGems()
            if G_checkClickEnable()==false then
                do return end
            end
            vipVoApi:showRechargeDialog(self.layerNum+1)
        end

        if playerVo.gems<tonumber(costNum) then
            local num=tonumber(costNum)-playerVo.gems
            local smallD=smallDialog:new()
            smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{costNum,playerVo.gems,num}),nil,self.layerNum+1)
        else
            showBuyDialog()
        end   
    end
    local btnTag = tonumber(RemoveFirstChar(pid))
    local menuItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touch1,btnTag,getlocal("buy"),35,100)
    menuItem:setScale(0.6)

    menuItem:setEnabled(true);
    if playerVo.gems < costNum then
        lbPrice:setColor(G_ColorRed)
    end
    local menu3=CCMenu:createWithItem(menuItem);
    menu3:setPosition(ccp(self.rTvWidth - menuItem:getContentSize().width*0.5*0.65 - 5,35))
    gemIcon:setPosition(ccp(menu3:getPositionX() -20,self.cellHeight*0.65));
    lbPrice:setPosition(ccp(menu3:getPositionX() -5,self.cellHeight*0.65))

    --原价
    if propCfg[pid].spCost then
        local usePreferentialNum = allShopVoApi:getSpecialShopBuyNum(pid)
        local maxPreferentialNum = SizeOfTable(propCfg[pid].spCost) - 1
        if usePreferentialNum < maxPreferentialNum then
            local oldGemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
            cellBg:addChild(oldGemIcon, 2)
            local oldLbPrice = GetTTFLabel(oldCostNum, 24)
            -- oldLbPrice:setColor(G_ColorRed)
            oldLbPrice:setAnchorPoint(ccp(0, 0.5))
            cellBg:addChild(oldLbPrice, 2)
            local lineLb = GetTTFLabel("-", 24)
            lineLb:setScaleX((oldLbPrice:getContentSize().width + 10) / lineLb:getContentSize().width)
            lineLb:setColor(G_ColorRed)
            lineLb:setAnchorPoint(ccp(0.5, 0.5))
            cellBg:addChild(lineLb)
            menu3:setPositionY(33)
            gemIcon:setPositionY(self.cellHeight*0.58)
            lbPrice:setPositionY(self.cellHeight*0.58)
            oldGemIcon:setPosition(gemIcon:getPositionX(), gemIcon:getPositionY() + gemIcon:getContentSize().height)
            oldLbPrice:setPosition(lbPrice:getPositionX(), oldGemIcon:getPositionY())
            lineLb:setPosition(oldLbPrice:getPositionX() + oldLbPrice:getContentSize().width / 2, oldLbPrice:getPositionY())
        end
    end

    menu3:setTouchPriority(-(self.layerNum-1)*20-2);
    cellBg:addChild(menu3,6)

    local btnTb={}
    table.insert(btnTb,{name=getlocal("buy"),tag=btnTag,callback=touch1})
    local isShow=propCfg[pid].isShow
    if isShow and isShow==1 then
      local function  showDisplayDialog()
        if self.rTv:getIsScrolled()==true then
            do return end
        end
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local sbReward = G_rewardFromPropCfg(pid)
        local titleStr=getlocal(propCfg[pid].name)
        local desStr
        local random = propCfg[pid].isRandom
        if random and random==1 then
          desStr=getlocal("database_des1")
        else
          desStr=getlocal("database_des2")
        end
        bagVoApi:showPropDisplaySmallDialog(self.layerNum+1,sbReward,titleStr,desStr,btnTb)
       end
       local touchSp=LuaCCSprite:createWithSpriteFrameName("datebaseShow1.png",showDisplayDialog)
       touchSp:setTouchPriority(-(self.layerNum-1)*20-2);
       touchSp:setScale(80/touchSp:getContentSize().width)
       touchSp:setIsSallow(false)
       touchSp:setAnchorPoint(ccp(0,0.5));
       touchSp:setPosition(10,self.cellHeight/2)
       -- touchSp:setOpacity(0)
       cellBg:addChild(touchSp,2)

       local fangdajinSp=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
       fangdajinSp:setAnchorPoint(ccp(1,0))
       fangdajinSp:setPosition(touchSp:getContentSize().width-5,5)
       -- touchSp:setOpacity(0)
       touchSp:addChild(fangdajinSp,2)
    end
end