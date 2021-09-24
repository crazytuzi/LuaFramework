acDouble11NewSellDialog={} 

function acDouble11NewSellDialog:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tv=nil
	nc.posTb=nil
	nc.sellID=1
	nc.bgLayer=nil
	nc.parent=parent
	nc.showIndx=nil
	nc.sellBtnTab ={}
	nc.whiNum=nil
    nc.sellGold=nil
    nc.version =1
    nc.oldScratchTb={}--保留旧代币数量
	return nc
end

function acDouble11NewSellDialog:init(layerNum,sellID,whiNum)
    self.version = acDouble11NewVoApi:getVersion()
	
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.sellID=sellID
	self.whiNum =whiNum
    self.showIndx = 6 -------版面固定显示为6个，在Tip2中需做修改
	self:initTableView()
	return self.bgLayer
end

function acDouble11NewSellDialog:initSellTab(whiBgLayer)
	local strSize2 = 14
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =20
    elseif G_getCurChoseLanguage() =="ru" then
        strSize2 =12
    end
    local cardUpbg = "cardUpBg.png"
    local cardDownBg = "cardDownBg.png"
    -- if self.version ==2 then
    --     cardUpbg ="redCardBg_1.png"
    --     cardDownBg ="redCardBg_2.png"
    -- end
    local btnNeedHeightPos =1.05
    local inBglayer = whiBgLayer
    if inBglayer ==nil then
    	inBglayer = self.bgLayer
    end

    local subGoldTb = acDouble11NewVoApi:getScratchTb( )
    local subGold =0
    local otherData,whiShop = acDouble11NewVoApi:getwhiSelfShop(self.sellID)
    if self.sellGold and subGoldTb and SizeOfTable(subGoldTb)>0 and subGoldTb["g"..whiShop] then
         subGold = tonumber(subGoldTb["g"..whiShop])
    end
        self.sellGold:setString(getlocal("activity_double11_sellShopGoldShow",{subGold}))
	local capInSet = CCRect(20, 20, 10, 10);
	local function nilFunc(hd,fn,idx)
	end
	local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        

        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then

	        if tag >10 and tag <30 then
				local idx = tag -10
                local costNum,halfNum,lastNums,rewardData,initRewardTb = acDouble11NewVoApi:getSelfShopTbData(idx,3,self.sellID)
                -- print("tag------>",idx,costNum,halfNum,lastNums,rewardData)        
                --action  =grab     开始抢购      shop=1  是第几个抢购的商店   sid='i1'   是那个物品
                local function panicBack( ... )
                    self:panicBack(idx,rewardData,costNum,halfNum,lastNums,subGold,initRewardTb)
                end 
                local subGoldTb = acDouble11NewVoApi:getScratchTb( )
                local subGold =nil
                local otherData,whiShop = acDouble11NewVoApi:getwhiSelfShop(self.sellID)
                if subGoldTb and SizeOfTable(subGoldTb)>0 and subGoldTb["g"..whiShop] then
                     subGold = subGoldTb["g"..whiShop]
                end
                local td=sellShowSureDialog:new()
                td:init(panicBack,nil,false,costNum,halfNum,true,subGold,sceneGame,rewardData[1],self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,true)
	        end
        end
    end
    local picStr = "Icon_BG.png"
    local picNums = 10
    local costNum = "1000"--------------假数据 用配置里的数据 
    local halfNum = "100"
    local larNums   = acDouble11NewVoApi:getShowSelfAllNums(2,self.sellID)
    local needHeight = G_VisibleSizeHeight*0.18*larNums-20
    local hangshu,resNums = acDouble11NewVoApi:getShowSelfAllNums(3,self.sellID)--拿到可显示的板子数量，num 页面可放置几列,idx 第几列
	local needSubHeight = 220
	local m = 0
    local n = 10
	for j=1,hangshu do
	    local jj = j-1
	    for i=1,3 do
	        m=m+1
	        n =n+1
            if m<= resNums then
    	        local needWidth = -15+self.bgLayer:getContentSize().width*0.22*i+self.bgLayer:getContentSize().width*0.08*(i-1)
                local rewardData = nil
                costNum,halfNum,lastNums,rewardData = acDouble11NewVoApi:getSelfShopTbData(m,3,self.sellID)
                -- print("self.sellID ==1----->",costNum,halfNum,lastNum,rewardData)

                if rewardData and SizeOfTable(rewardData)> 0 then
                    picStr =rewardData[1].pic
                    picNums =rewardData[1].num
                end
    			local sellBtn=GetButtonItem(cardUpbg,cardDownBg,cardUpbg,touch,n)--------------假数据 用配置里的数据 
                sellBtn:setAnchorPoint(ccp(0.5,0.5))
                sellBtn:setTag(10+m)

                local sellMenu=CCMenu:createWithItem(sellBtn)
                sellMenu:setPosition(ccp(needWidth,needHeight-100-needSubHeight*jj))
                sellMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                inBglayer:addChild(sellMenu,1)
                table.insert(self.sellBtnTab,sellBtn)

                pic =picStr --------------
                local picScale = 90/pic:getContentSize().width
                pic:setScale(picScale)
                pic:setAnchorPoint(ccp(0.5,0.5))
                pic:setPosition(ccp(sellMenu:getPositionX(),sellMenu:getPositionY()+36))-- +33
                inBglayer:addChild(pic,1)

                local picNumsStr = GetTTFLabel("x"..picNums,22)
                picNumsStr:setAnchorPoint(ccp(1,0))
                picNumsStr:setPosition(ccp(pic:getPositionX()+40,pic:getPositionY()-40))
                inBglayer:addChild(picNumsStr,2)

                local strBg = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
                strBg:setAnchorPoint(ccp(1,0))
                strBg:setOpacity(150)
                strBg:setScaleX((picNumsStr:getContentSize().width+5)/strBg:getContentSize().width)
                strBg:setScaleY((picNumsStr:getContentSize().height-3)/strBg:getContentSize().height)
                strBg:setPosition(ccp(pic:getPositionX()+40,pic:getPositionY()-40))
                inBglayer:addChild(strBg,1)

                local numSubWidth = 0
                local numSubWidth2 = 0
                if costNum >9999 then
                    numSubWidth =-17

                elseif costNum>999 then
                    numSubWidth =-10
                end
                if halfNum > 999 then
                    numSubWidth2 =-10
                elseif halfNum<10 and halfNum >-1 then
                    numSubWidth2 =10
                elseif (halfNum>99 and halfNum<1000) or halfNum <0 then
                    numSubWidth2 = -7
                end
                
                strHeightPos = sellMenu:getPositionY()-25 --pic:getPositionY()-pic:getContentSize().height*0.5-5

                local costStr = GetTTFLabel(costNum,20)
                costStr:setAnchorPoint(ccp(0,0.5))
                costStr:setPosition(ccp(pic:getPositionX()-40,strHeightPos+5))
                inBglayer:addChild(costStr,1)
                costStr:setColor(G_ColorRed)

                local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    			-- goldIcon:setScale(0.8)
                goldIcon:setAnchorPoint(ccp(0,1))
    			goldIcon:setPosition(ccp(costStr:getPositionX()+costStr:getContentSize().width+numSubWidth+20,strHeightPos+10))
    			inBglayer:addChild(goldIcon,1)

    			local rline = CCSprite:createWithSpriteFrameName("redline.jpg")
                rline:setScaleX(costStr:getContentSize().width / rline:getContentSize().width)
                rline:setPosition(ccp(pic:getPositionX()-40,strHeightPos+5))
                rline:setAnchorPoint(ccp(0,0.5))
                inBglayer:addChild(rline,1)

                local costStr2 = GetTTFLabel(halfNum,20)
                costStr2:setAnchorPoint(ccp(0,0.5))
                -- costStr2:setPosition(ccp(goldIcon:getPositionX()+25,strHeightPos))
                costStr2:setPosition(ccp(pic:getPositionX()-40,strHeightPos-15))
                inBglayer:addChild(costStr2,1)

       --          local goldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    			-- goldIcon2:setScale(0.8)
    			-- goldIcon2:setPosition(ccp(costStr2:getPositionX()+costStr2:getContentSize().width+numSubWidth2,strHeightPos))
    			-- inBglayer:addChild(goldIcon2,1)

    			local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    	        lineSp:setAnchorPoint(ccp(0.5,0.5))
    	        lineSp:setScaleX((sellBtn:getContentSize().width-20)/lineSp:getContentSize().width)
    	        lineSp:setPosition(ccp(pic:getPositionX(),strHeightPos-32)) -- -20
    	        inBglayer:addChild(lineSp,1)

                local buyedShopTb = acDouble11NewVoApi:getbuyShopNums()
                local otherData,whiShop = acDouble11NewVoApi:getwhiSelfShop(self.sellID)

                if buyedShopTb and SizeOfTable(buyedShopTb) >0 and buyedShopTb[whiShop]["i"..m] then
                    lastNums = lastNums-buyedShopTb[whiShop]["i"..m]
                    if lastNums <0 then
                        lastNums =0
                    end
                    -- print("lastNums-buyedShopTb[self.sellID][..m]",lastNums,buyedShopTb[self.sellID]["i"..m])
                end
    	        local lastNumsStr = GetTTFLabel(getlocal("activity_double11_lastNums",{lastNums}),strSize2)
                lastNumsStr:setPosition(ccp(pic:getPositionX(),strHeightPos-45))-- -35
                inBglayer:addChild(lastNumsStr,1)

                local saleNum = string.format("%.2f",(costNum-halfNum)/costNum)*100
                local sellIcon = CCSprite:createWithSpriteFrameName("saleRedBg.png")
                sellIcon:setPosition(ccp(sellMenu:getPositionX()+45,sellMenu:getPositionY()+81))
                sellIcon:ignoreAnchorPointForPosition(false)
                sellIcon:setAnchorPoint(ccp(0.5,0.5))
                -- sellIcon:setScale(1)
                sellIcon:setRotation(0)
                inBglayer:addChild(sellIcon,1)

                local saleNumStr = GetTTFLabel("-"..saleNum.."%",18)
                saleNumStr:setAnchorPoint(ccp(0.5,0.5))
                saleNumStr:setPosition(getCenterPoint(sellIcon))
                saleNumStr:setRotation(10)
                sellIcon:addChild(saleNumStr)

            end
		end
	end	
end

function acDouble11NewSellDialog:initTableView( )
    local posWidht2 = 0
    local posHeight2 = 0
    local sellStr2 = 24
    if G_getCurChoseLanguage() =="it" or G_getCurChoseLanguage() =="fr" then
        posWidht2 =60
        posHeight2 =-40
        sellStr2 =20
    end
    local iphon5SizeH = 0
    if G_getIphoneType() == G_iphone5 then
        iphon5SizeH = 170
    end
    if G_getIphoneType() == G_iphoneX then
        iphon5SizeH = 290 
    end
    local function click(hd,fn,idx)
    end
    local cnNewYearBg =nil
    -- if self.version ==2 then--元旦版背景图-- 
    --     local rect=CCRect(0,0,612,466)
    --     CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    --     CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    --     cnNewYearBg= LuaCCScale9Sprite:create("public/acCnNewYearImage/cnNewYearBg.jpg",rect,CCRect(100, 150, 1, 1),click);
    --     CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    --     CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    --     local rect2=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-240)
    --     cnNewYearBg:setContentSize(rect2)
    --     cnNewYearBg:setAnchorPoint(ccp(0.5,1))
    --     cnNewYearBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight-163))
    --     self.bgLayer:addChild(cnNewYearBg)
    -- end


    local bigBg =CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")--LuaCCScale9Sprite:createWithSpriteFrameName("halloweenBg.jpg",CCRect(20, 20, 10, 10),clickk)
    -- bigBg:setContentSize(CCSizeMake(G_VisibleSizeWidth ,G_VisibleSizeHeight))
    bigBg:setScaleX((G_VisibleSizeWidth-42)/bigBg:getContentSize().width)
    bigBg:setScaleY((G_VisibleSizeHeight-186)/bigBg:getContentSize().height)
    bigBg:ignoreAnchorPointForPosition(false)
    bigBg:setOpacity(0)
    bigBg:setAnchorPoint(ccp(0.5,1))
    bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight-163))
    self.bgLayer:addChild(bigBg)
-----------
    local groupPosY = G_VisibleSizeHeight-260
    local needLength2 = 20
    local groupSelf = CCSprite:createWithSpriteFrameName("groupSelf.png")
    groupSelf:setScaleY(50/groupSelf:getContentSize().height)
    groupSelf:setScaleX(4.5)
    groupSelf:setPosition(ccp(G_VisibleSizeWidth*0.5+needLength2,groupPosY))
    groupSelf:ignoreAnchorPointForPosition(false)
    groupSelf:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(groupSelf)

    local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp1:setAnchorPoint(ccp(0.5,0.5))
    lineSp1:setScaleX(G_VisibleSizeWidth*0.5/lineSp1:getContentSize().width)
    lineSp1:setPosition(ccp(G_VisibleSizeWidth*0.5,groupPosY-2))
    self.bgLayer:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setAnchorPoint(ccp(0.5,0.5))
    lineSp2:setScaleX(G_VisibleSizeWidth*0.5/lineSp2:getContentSize().width)
    lineSp2:setPosition(ccp(G_VisibleSizeWidth*0.5,groupPosY+2-groupSelf:getContentSize().height*(50/groupSelf:getContentSize().height)))
    self.bgLayer:addChild(lineSp2)

    local otherData,whiShop = acDouble11NewVoApi:getwhiSelfShop(self.sellID)
    local groupStr = GetTTFLabel(getlocal("activity_double11_shopName_"..whiShop),28)
    groupStr:setAnchorPoint(ccp(0.5,0.5))
    groupStr:setPosition(ccp(groupSelf:getPositionX()-needLength2,groupSelf:getPositionY()-25))
    groupStr:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(groupStr)

    -- local sellIcon = CCSprite:createWithSpriteFrameName("sellIcon.png")
    -- sellIcon:setPosition(ccp(groupSelf:getPositionX()+150+posWidht2,groupSelf:getPositionY()-30+posHeight2))
    -- sellIcon:ignoreAnchorPointForPosition(false)
    -- sellIcon:setAnchorPoint(ccp(0.5,0.5))
    -- self.bgLayer:addChild(sellIcon)
 -------   
    local subGoldTb = acDouble11NewVoApi:getScratchTb( )
    local subGold =0
    local otherData,whiShop = acDouble11NewVoApi:getwhiSelfShop(self.sellID)
    if subGoldTb and SizeOfTable(subGoldTb)>0 and subGoldTb["g"..whiShop] then
        if self.oldScratchTb["g"..whiShop]==nil or self.oldScratchTb["g"..whiShop] ~= tonumber(subGoldTb["g"..whiShop]) then
            self.oldScratchTb["g"..whiShop] = tonumber(subGoldTb["g"..whiShop])
        end
        subGold = tonumber(subGoldTb["g"..whiShop])
    end
    local sizeWidth = 300
    local strSizehj = sellStr2
    if G_isAsia() == false then
        sizeWidth = 500
        strSizehj = 18
    end
    self.sellGold=GetTTFLabelWrap(getlocal("activity_double11_sellShopGoldShow",{subGold}),strSizehj,CCSizeMake(sizeWidth,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.sellGold:setPosition(ccp(G_VisibleSizeWidth*0.5,groupSelf:getPositionY()-90))
    self.sellGold:setAnchorPoint(ccp(0.5,0.5));
    self.bgLayer:addChild(self.sellGold,2)

    local tvHeightNeedSub =430
    -- if self.version ==2 then
    --     groupSelf:setVisible(false)
    --     groupStr:setPosition(ccp(groupSelf:getPositionX(),groupSelf:getPositionY()+30))
    --     groupStr:setColor(G_ColorYellowPro)
    --     -- sellIcon:setAnchorPoint(ccp(0,0.5))
    --     -- sellIcon:setPosition(ccp(30,groupSelf:getPositionY()))
    --     self.sellGold:setPosition(ccp(G_VisibleSizeWidth*0.5,groupSelf:getPositionY()-20))

    --     -- tvHeightNeedSub =350
    -- end

    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    -- goldIcon:setScale(0.8)
    goldIcon:setPosition(ccp(self.sellGold:getPositionX()+self.sellGold:getContentSize().width*0.5,self.sellGold:getPositionY()))
    self.bgLayer:addChild(goldIcon,1)
    local function touchDialog( )  end 
    local maskBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    maskBg1:setTouchPriority(-(self.layerNum-1)*20-6)
    local rect=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-300-tvHeightNeedSub-iphon5SizeH)
    maskBg1:setContentSize(rect)
    maskBg1:setOpacity(0)
    maskBg1:setAnchorPoint(ccp(0,0))
    maskBg1:setIsSallow(true) -- 点击事件透下去
    maskBg1:setPosition(ccp(22,G_VisibleSize.height-tvHeightNeedSub+40))
    self.bgLayer:addChild(maskBg1,10)
    maskBg1:setVisible(true)

    local maskBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    maskBg2:setTouchPriority(-(self.layerNum-1)*20-6)
    local rect2=CCSizeMake(G_VisibleSizeWidth-120,80)
    maskBg2:setContentSize(rect2)
    maskBg2:setOpacity(0)
    maskBg2:setAnchorPoint(ccp(0,1))
    maskBg2:setIsSallow(true) -- 点击事件透下去
    maskBg2:setPosition(ccp(22,G_VisibleSize.height))
    self.bgLayer:addChild(maskBg2,10)
    maskBg2:setVisible(true)

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,G_VisibleSize.height-tvHeightNeedSub),nil)-- -200
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(0,40))
    -- if self.version ==2 then
    --     self.tv:setPosition(ccp(0,80))--40
    -- else
    --     self.tv:setPosition(ccp(0,40))--40
    -- end
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)--120
end

function acDouble11NewSellDialog:tick( )
    local subGoldTb = acDouble11NewVoApi:getScratchTb( )
    local subGold =0
    local otherData,whiShop = acDouble11NewVoApi:getwhiSelfShop(self.sellID)
    if subGoldTb and SizeOfTable(subGoldTb)>0 and subGoldTb["g"..whiShop] then
        if self.oldScratchTb["g"..whiShop]==nil or self.oldScratchTb["g"..whiShop] ~= tonumber(subGoldTb["g"..whiShop]) then
            self.oldScratchTb["g"..whiShop] = tonumber(subGoldTb["g"..whiShop])
            subGold = tonumber(subGoldTb["g"..whiShop])
            self.sellGold:setString(getlocal("activity_double11_sellShopGoldShow",{subGold}))
        end
    end
end

function acDouble11NewSellDialog:eventHandler( handler,fn,idx,cel)

  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local larNums   = acDouble11NewVoApi:getShowSelfAllNums(2,self.sellID)
    local needHeight = G_VisibleSizeHeight*0.18*larNums
    -- local needBgAddHeight =150
    -- if G_isIphone5() then
    --     needBgAddHeight =-100
    -- end
    return  CCSizeMake(G_VisibleSizeWidth-42,needHeight)-- -100
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()


    self:initSellTab(cell)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end

function acDouble11NewSellDialog:panicBack(idx,rewardData,costNum,halfNum,lastNums,subGold,initRewardTb)
    subGold =tonumber(subGold)
    local halfNumOne=halfNum
    if subGold and subGold >0 then
        if halfNum-subGold >= math.floor(halfNum/2) then
            halfNumOne =halfNum-subGold
        else
            halfNumOne =halfNum -math.floor(halfNum/2)
        end
    end
    -- print("playerVo.gems<halfNumOne",playerVo.gems,halfNumOne)
    if playerVo.gems<halfNumOne then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem",{getlocal("notEnoughGem")}),30)
        do return end
    end
    local buyedShopTb = acDouble11NewVoApi:getbuyShopNums()
    local otherData,whiShop = acDouble11NewVoApi:getwhiSelfShop(self.sellID)
    if buyedShopTb and SizeOfTable(buyedShopTb)>0 and  buyedShopTb[whiShop]["i"..idx]  and buyedShopTb[whiShop]["i"..idx] >=lastNums then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_double11_buyEndNums",{getlocal("activity_double11_buyEndNums")}),30)
        self.tv:reloadData()
        do return end
    end
    local isInTime,curTime = acDouble11NewVoApi:isInTime( )
    local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)--acDouble11VoApi:getbuyShopNums( )
        if ret==true then
            -- print("yes~~~~~")
            subGold =tonumber(subGold)
            if subGold and subGold >0 then
                if halfNum-subGold >= math.floor(halfNum/2) then
                    halfNum =halfNum-subGold
                else
                    halfNum =halfNum - math.floor(halfNum/2)
                end
            end
            local gems = playerVoApi:getGems()
            playerVoApi:setGems(gems-halfNum)
            if sData and sData.data and sData.data.double11new then
                for k,v in pairs(rewardData) do
                    if v.type =="p" and v.key == "p601" then
                    else
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                end
                G_showRewardTip(initRewardTb,true)
                if sData.data.double11new.qg then
                    acDouble11NewVoApi:setPanicedTab(sData.data.double11new.qg )--设置本轮已抢购的tab
                end
                if sData.data.double11new.dgem then
                    acDouble11NewVoApi:setNearScratchGold(sData.data.double11new.dgem )--最近一次挂奖钱数
                end
                if sData.data.double11new.shop then
                    acDouble11NewVoApi:setPanicedShopNums(sData.data.double11new.shop)
                end
                if sData.data.double11new.dg then
                    acDouble11NewVoApi:setScratchTb(sData.data.double11new.dg)--更新刮刮奖 奖池的金币数量
                end
                if sData.data.double11new.endts then--
                    acDouble11NewVoApi:setEndts(sData.data.double11new.endts)--当前时间内最终抢光的时间戳
                end
                if sData.data.double11new.buyshop then
                    acDouble11NewVoApi:setbuyShopNums(sData.data.double11new.buyshop)
                end
                if sData.data.redid then--记录自己的可发送的红包ID的记录，弹出窗口提示玩家是否世界广播发送
                    acDouble11NewVoApi:showSendRedBagPointDialog(sData.data.redid,self.layerNum,sData.data.redtype,sData.data.dgemstype,sData.data.dgems)
                end
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)

                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success",{getlocal("vip_tequanlibao_goumai_success")}),30)
            end
        else
            -- print("no~~~~~")
            subGold =tonumber(subGold)
            if subGold and subGold >0 then
                if halfNum-subGold >= math.floor(halfNum/2) then
                    halfNum =halfNum-subGold
                else
                    halfNum =halfNum - math.floor(halfNum/2)
                end
            end
            local gems = playerVoApi:getGems()
            playerVoApi:setGems(gems-halfNum)
            if sData and sData.data and sData.data.double11new then
                if sData.data.double11new.qg then
                    acDouble11NewVoApi:setPanicedTab(sData.data.double11new.qg )--设置本轮已抢购的tab
                end
                if sData.data.double11new.dgem then
                    acDouble11NewVoApi:setNearScratchGold(sData.data.double11new.dgem )--最近一次挂奖钱数
                end
                if sData.data.double11new.shop then
                    acDouble11NewVoApi:setPanicedShopNums(sData.data.double11new.shop)
                end
                if sData.data.double11new.dg then
                    acDouble11NewVoApi:setScratchTb(sData.data.double11new.dg)--更新刮刮奖 奖池的金币数量
                end
                if sData.data.double11new.endts then--
                    acDouble11NewVoApi:setEndts(sData.data.double11new.endts)--当前时间内最终抢光的时间戳
                end
                if sData.data.double11new.buyshop then
                    acDouble11NewVoApi:setbuyShopNums(sData.data.double11new.buyshop)
                end
                
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success",{getlocal("vip_tequanlibao_goumai_success")}),30)
            end
        end
    end
    socketHelper:double11NewPanicBuying( getRawardCallback,"buy",whiShop,'i'..idx,curTime)
 end 


function acDouble11NewSellDialog:dispose()
	self.tv=nil
	self.posTb=nil
	self.sellID=nil
	self.bgLayer=nil
	self.parent=nil
	self.showIndx=nil
	self.sellBtnTab ={}
	self.whiNum=nil
    self.sellGold=nil
    self.version =nil
end