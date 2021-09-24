armorMatrixDialog=commonDialog:new()

function armorMatrixDialog:new()
    local nc={
    	tankPos=1,
	    clayer=nil,            --背景sprite
		layerNum=nil,
		type = 0,
		-- nc.parentLayer=nil,
		isShowTank=nil,
		touchRect=CCRect(0,25,G_VisibleSizeWidth,250),
		iconTab={},
		posTab={},
		-- queueNumTab={},
	    touchArr={},
		multTouch=false,
		isMoved=false,
		firstOldPos=nil,
		secondOldPos=nil,
		touchedIcon=nil,
		touchedId=0,
		movedType=0, --0 原始 1 准备动  2正在动  3点在空白了
		iconLength=0,
		--移动到的
		movedIcon=nil,
		movedId=0,
		touchedScaleX=1,
		touchedScaleY=1,
		isShowTank=1,
		-- iconSize=60,
        headerBg=nil,
        bgWidth=615,
        adaptSpacey=0,
        equippedNumLb=nil,
	}
    setmetatable(nc,self)
    self.__index=self
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/armorMatrix.plist")
    spriteController:addTexture("public/armorMatrix.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/boss_fuben_images.plist")
    spriteController:addTexture("public/boss_fuben_images.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")
    spriteController:addPlist("public/armorMatrixEffect.plist")
    spriteController:addTexture("public/armorMatrixEffect.png")
    return nc
end

--设置对话框里的tableView
function armorMatrixDialog:initTableView()
    self.limitH=240
    if G_isIphone5()==true then
        self.adaptSpacey=30
        self.limitH=300
    end

	-- self.panelLineBg:setVisible(false)
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,15))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgWidth,G_VisibleSize.height-95))

    -- local clipper=CCClippingNode:create()
    -- clipper:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width,self.panelLineBg:getContentSize().height))
    -- clipper:setAnchorPoint(ccp(0,0))
    -- clipper:setPosition(ccp(0,10))
    -- local stencil=CCDrawNode:getAPolygon(CCSizeMake(self.panelLineBg:getContentSize().width,self.panelLineBg:getContentSize().height-10),1,1)
    -- clipper:setStencil(stencil) --遮罩
    -- self.panelLineBg:addChild(clipper)
    -- local gridSize=200--self.panelLineBg:getContentSize().width/3
    -- for i=1,3 do
    --     for k=1,6 do
    --         local spBg=CCSprite:createWithSpriteFrameName("amMainBg.png")
    --         spBg:setScale(gridSize/spBg:getContentSize().width)
    --         local px,py=(self.panelLineBg:getContentSize().width-(gridSize*3))/2+gridSize/2+(i-1)*gridSize,self.panelLineBg:getContentSize().height-gridSize/2-(k-1)*gridSize
    --         spBg:setPosition(ccp(px,py))
    --         clipper:addChild(spBg)
    --     end
    -- end

    local clipper=CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))
    clipper:setAnchorPoint(ccp(0,0))
    clipper:setPosition(ccp(0,0))
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height-105),1,1)
    stencil:setAnchorPoint(ccp(0,0))
    stencil:setPosition(ccp(0,25))
    clipper:setStencil(stencil) --遮罩
    self.bgLayer:addChild(clipper)
    local gridSize=201--self.panelLineBg:getContentSize().width/3
    for i=1,3 do
        for k=1,6 do
            local spBg=CCSprite:createWithSpriteFrameName("amMainBg.png")
            spBg:setScale(gridSize/spBg:getContentSize().width)
            local px,py=(self.bgLayer:getContentSize().width-(gridSize*3))/2+gridSize/2+(i-1)*gridSize,self.bgLayer:getContentSize().height-100-gridSize/2-(k-1)*gridSize
            spBg:setPosition(ccp(px,py))
            clipper:addChild(spBg)
        end
    end
    

    -- local function refreshCalback( ... )
        local function callBack(...)
           -- return self:eventHandler(...)
        end
        local hd=LuaEventHandler:createHandler(callBack)
    	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),nil)
        -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        -- self.tv:setPosition(ccp(0,25))
        -- self.bgLayer:addChild(self.tv,1)
        -- self.tv:setMaxDisToBottomOrTop(0)

        self:initHeader()
        self:initBottom()

        local function dialogListener(event,data)
            self:refreshUI()
        end
        self.dialogListener=dialogListener
        eventDispatcher:addEventListener("armorMatrix.dialog.refresh",self.dialogListener)
    -- end
    -- armorMatrixVoApi:armorGetData(refreshCalback)

    self:refresNewsTip()

    -- eventDispatcher:dispatchEvent("armor.guild.begin")
    if otherGuideMgr.isGuiding and otherGuideMgr.curStep==18 then
        otherGuideMgr:toNextStep()
    else
        if otherGuideMgr:checkGuide(18)==false and playerVoApi:getPlayerLevel()==armorCfg.openLvLimit then
            otherGuideMgr:setGuideStepDone(18)
            otherGuideMgr:showGuide(19)
        end
    end
end

function armorMatrixDialog:initHeader()
	local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local headerBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
	headerBg:setContentSize(CCSizeMake(self.bgWidth,555+self.adaptSpacey*4))
    headerBg:ignoreAnchorPointForPosition(false)
    headerBg:setAnchorPoint(ccp(0.5,1))
    headerBg:setIsSallow(false)
    headerBg:setTouchPriority(-(self.layerNum-1)*20-1)
	headerBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-90))
    self.bgLayer:addChild(headerBg,1)
    headerBg:setOpacity(0)
    self.headerBg=headerBg

    local amChangeBg1=CCSprite:createWithSpriteFrameName("amChangeBg.png")
    amChangeBg1:setScaleX(headerBg:getContentSize().width/amChangeBg1:getContentSize().width)
    amChangeBg1:setScaleY(headerBg:getContentSize().height/2/amChangeBg1:getContentSize().height)
    amChangeBg1:setAnchorPoint(ccp(0.5,1))
    amChangeBg1:setPosition(ccp(headerBg:getContentSize().width/2,headerBg:getContentSize().height))
    headerBg:addChild(amChangeBg1)
    local amChangeBg2=CCSprite:createWithSpriteFrameName("amChangeBg.png")
    amChangeBg2:setRotation(180)
    amChangeBg2:setScaleX(headerBg:getContentSize().width/amChangeBg2:getContentSize().width)
    amChangeBg2:setScaleY(headerBg:getContentSize().height/2/amChangeBg2:getContentSize().height)
    amChangeBg2:setAnchorPoint(ccp(0.5,1))
    amChangeBg2:setPosition(ccp(headerBg:getContentSize().width/2,0))
    headerBg:addChild(amChangeBg2)

    local subTitleSp=CCSprite:createWithSpriteFrameName("amTitleBg.png")
    subTitleSp:setAnchorPoint(ccp(0.5,1))
    subTitleSp:setPosition(ccp(headerBg:getContentSize().width/2,headerBg:getContentSize().height+4))
    headerBg:addChild(subTitleSp,1)
    local space=2
    for i=1,5 do
        local subTitleLb=GetTTFLabel(getlocal("armorMatrix_lineup"),28,true)
        local px,py=subTitleSp:getContentSize().width/2,subTitleSp:getContentSize().height/2+7
        if i==1 then
            px,py=px-space,py
        elseif i==2 then
            px,py=px,py-space
        elseif i==3 then
            px,py=px+space,py
        elseif i==4 then
            px,py=px,py+space
        end
        if i==5 then
        else
            subTitleLb:setColor(ccc3(42, 126, 80))
        end
        subTitleLb:setPosition(ccp(px,py))
        subTitleSp:addChild(subTitleLb,1)
        -- subTitleLb:setColor(G_ColorYellow)
    end
    
    local poy=headerBg:getContentSize().height-120-20-self.adaptSpacey
    local tankBg=CCSprite:createWithSpriteFrameName("alliance_boss_dissectionbg.png")
    tankBg:setAnchorPoint(ccp(0.5,0.5))
    tankBg:setPosition(ccp(headerBg:getContentSize().width/2,poy))
    tankBg:setScale(1.6)
    headerBg:addChild(tankBg)
    local tankSp=CCSprite:createWithSpriteFrameName("amMainTank.png")
    tankSp:setPosition(ccp(tankBg:getPositionX()-8,tankBg:getPositionY()-3))
    tankSp:setScale(1.1)
    headerBg:addChild(tankSp)

    local strSize2 = 13
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =22
    end
    local subPosX = 0
    if G_getCurChoseLanguage() =="ar" then
        subPosX = 15
    end

    for i=1,6 do
    	local function clickHandler( ... )
    		if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

	        --是否装备
            local mid,id,lv=armorMatrixVoApi:getEquipedData(self.tankPos,i)
	        if mid and id and id~=0 then
	        	--信息小面板
	        	armorMatrixVoApi:showInfoSmallDialog(id,self.layerNum+1,true)
                if otherGuideMgr.isGuiding and otherGuideMgr.curStep==28 then
                    otherGuideMgr:toNextStep()
                end
	        else
		        armorMatrixVoApi:showSelectDialog(self.tankPos,i,self.layerNum+1)
		    end
    	end
        local spScale=0.8
        local tag=2100+i
    	local px,py=55+(headerBg:getContentSize().width-55*2)*((i-1)%2),poy+40-math.floor((i-1)/2)*95
    	local graySp=LuaCCSprite:createWithSpriteFrameName("armorMatrix_0.png",clickHandler)
    	graySp:setTouchPriority(-(self.layerNum-1)*20-4)
	    graySp:setPosition(ccp(px,py))
        graySp:setTag(tag)
	    headerBg:addChild(graySp,1)
        graySp:setScale(spScale)
        -- 加号
        -- local addSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
        local addSp = CCSprite:createWithSpriteFrameName("ProduceTankIconMore.png")
        addSp:setScale(1.8)
        addSp:setPosition(getCenterPoint(graySp))
        graySp:addChild(addSp)
        -- 忽隐忽现
        local fade1 = CCFadeTo:create(0.8,55)
        local fade2 = CCFadeTo:create(0.8,255)
        local seq = CCSequence:createWithTwoActions(fade1,fade2)
        local repeatEver = CCRepeatForever:create(seq)
        addSp:runAction(repeatEver)
        local newsTip=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),function ()end)
        newsTip:setScale(0.5)
        newsTip:setPosition(ccp(graySp:getContentSize().width-15,graySp:getContentSize().height-15))
        newsTip:setTag(3100)
        graySp:addChild(newsTip,9)
        newsTip:setVisible(false)
        
        local function onClick( ... )
        end
        local mid,id,lv=armorMatrixVoApi:getEquipedData(self.tankPos,i)
        -- print("mid,id,lv~~~~~~~",mid,id,lv)
        if mid and id and id~=0 then
            local amIcon=armorMatrixVoApi:getArmorMatrixIcon(mid,90,100,onClick,lv)
            -- amIcon:setScale(90/amIcon:getContentSize().width)
            amIcon:setPosition(getCenterPoint(graySp))
            amIcon:setTag(tag)
            graySp:addChild(amIcon,1)
            armorMatrixVoApi:addLightEffect(amIcon, mid)
        end

        -- local lineIndex=math.ceil(i/2)
        local lineIndex=i
        -- if i>=4 then
        --     if i==4 then
        --         lineIndex=3
        --     else
        --         lineIndex=i-1
        --     end
        -- end
        local tankLineSp=CCSprite:createWithSpriteFrameName("amLine"..lineIndex..".png")
        local anchorX,anchorY=0,0
        local posx,posy=px-graySp:getContentSize().width/2*spScale+2,py+25
        local lbx,kAlignment=px-graySp:getContentSize().width/2*spScale-5,kCCTextAlignmentLeft
        local pointx,pointy=0,0
        -- if i==4 then
        --     tankLineSp:setFlipX(true)
        -- end
        if math.ceil(i/2)==1 then
            anchorY=1
            posy=py+30
        else
            pointy=tankLineSp:getContentSize().height
        end
        if i%2==0 then
            anchorX=1
            -- tankLineSp:setFlipX(true)
            kAlignment=kCCTextAlignmentRight
        else
            posx=px+graySp:getContentSize().width/2*spScale-2
            lbx=px+graySp:getContentSize().width/2*spScale+5
            pointx=tankLineSp:getContentSize().width
        end
        tankLineSp:setAnchorPoint(ccp(anchorX,anchorY))
        tankLineSp:setPosition(ccp(posx,posy))
        headerBg:addChild(tankLineSp,1)
        local acPointSp=CCSprite:createWithSpriteFrameName("amPointCircle.png")
        acPointSp:setPosition(ccp(pointx,pointy))
        tankLineSp:addChild(acPointSp,1)

        local attrLbFontSize = 24
        -- if G_getCurChoseLanguage()=="de" then
        --     attrLbFontSize = 12
        -- elseif G_getCurChoseLanguage()=="it" then
        --     attrLbFontSize = 14
        -- elseif G_getCurChoseLanguage()=="fr" then
        --     attrLbFontSize = 16
        -- elseif G_getCurChoseLanguage()=="in" then
        --     attrLbFontSize = 15
        -- end
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
            attrLbFontSize = 24
        else
            attrLbFontSize = 12
        end
        local attrStr=armorMatrixVoApi:getAttrByType(i)
        local attrLb=GetTTFLabelWrap(attrStr,attrLbFontSize,CCSizeMake(75,0),kAlignment,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        attrLb:setAnchorPoint(ccp(anchorX,0.5))
        attrLb:setPosition(ccp(lbx,py))
        if i % 2 ~= 0 then
            attrLb:setPosition(ccp(lbx - subPosX , py))
        end
        headerBg:addChild(attrLb,1)

	    self:resetAttribute(i)

        if i==3 and otherGuideMgr.isGuiding then
            otherGuideMgr:setGuideStepField(28,graySp,true)
        end
	end

    poy=poy-140
    local function onSuit(object,fn,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.buffBg then
            local function callBack4()
                armorMatrixVoApi:showSuitDialog(self.layerNum+1,self.tankPos)
            end
            local callFunc=CCCallFunc:create(callBack4)

            local scaleTo1=CCScaleTo:create(0.1,0.9,0.9)
            local scaleTo2=CCScaleTo:create(0.1,1,1)

            local acArr=CCArray:create()
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)
            acArr:addObject(callFunc)

            local seq=CCSequence:create(acArr)
            self.buffBg:runAction(seq)
        end
    end
    local buffBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),onSuit)
    buffBg:setContentSize(CCSizeMake(tankBg:getContentSize().width*1.6,110-15))
    buffBg:setPosition(ccp(headerBg:getContentSize().width/2,poy))
    buffBg:setTouchPriority(-(self.layerNum-1)*20-4)
    headerBg:addChild(buffBg,1)
    self.buffBg=buffBg
    local buffLb=GetTTFLabel(getlocal("armorMatrix_set_effect"),20,CCSizeMake(buffBg:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    buffLb:setPosition(ccp(buffBg:getContentSize().width/2,buffBg:getContentSize().height-20))
    buffBg:addChild(buffLb,1)
    buffLb:setColor(G_ColorYellowPro)
    self:initSuit()

    poy=poy-115-self.adaptSpacey
    local function cellClick( ... )
    end
    local attrBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),cellClick)
    attrBg:setContentSize(CCSizeMake(580,120))
    attrBg:setPosition(ccp(headerBg:getContentSize().width/2,poy))
    headerBg:addChild(attrBg)

	local itemScale=130/205
    local itemPy=55+self.adaptSpacey
    local btnCenter=headerBg:getContentSize().width/2
    local btnW=20
    --招募
    local function onRecruit()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        armorMatrixVoApi:showRecruitDialog(self.layerNum+1)
	end
    local recruitFontSize=24
    if G_getCurChoseLanguage()=="de" then
        recruitFontSize=20
    end
	local recruitItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onRecruit,nil,getlocal("recruit"),recruitFontSize/itemScale,101)
	recruitItem:setScale(itemScale)
    local btnLb=recruitItem:getChildByTag(101)
    if btnLb then
        btnLb=tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
	local recruitMenu=CCMenu:createWithItem(recruitItem)
	recruitMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	recruitMenu:setAnchorPoint(ccp(0.5,0.5))
	recruitMenu:setPosition(ccp(btnCenter-btnW/2-65-btnW-130,itemPy))
	headerBg:addChild(recruitMenu,1)

    -- 数字小图标
    local newsIcon =CCSprite:createWithSpriteFrameName("NumBg.png")
    newsIcon:setAnchorPoint(CCPointMake(1,0.5))
    newsIcon:setPosition(ccp(recruitItem:getContentSize().width,recruitItem:getContentSize().height-15))
    newsIcon:setVisible(false)
    recruitItem:addChild(newsIcon)
    self.newsIcon=newsIcon
    
    local newsNumLabel = GetTTFLabel("0",25)
    newsNumLabel:setPosition(ccp(newsIcon:getContentSize().width/2,newsIcon:getContentSize().height/2))
    newsNumLabel:setTag(11)
    newsIcon:addChild(newsNumLabel,1)
    self:refresNewsIcon()

    -- 商店
    local function goShop()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        armorMatrixVoApi:showShopDialog(self.layerNum+1)
    end
    local shopItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goShop,nil,getlocal("market"),24/itemScale,101)
    shopItem:setScale(itemScale)
    local btnLb=shopItem:getChildByTag(101)
    if btnLb then
        btnLb=tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local shopMenu=CCMenu:createWithItem(shopItem)
    shopMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    shopMenu:setAnchorPoint(ccp(0.5,0.5))
    shopMenu:setPosition(ccp(btnCenter-btnW/2-65,itemPy))
    headerBg:addChild(shopMenu,1)

    local shopTipSp = CCSprite:createWithSpriteFrameName("IconTip.png");
    shopTipSp:setAnchorPoint(CCPointMake(1,0.5))
    shopTipSp:setPosition(ccp(shopItem:getContentSize().width,shopItem:getContentSize().height-15));
    shopTipSp:setVisible(false)
    shopItem:addChild(shopTipSp)
    self.shopTipSp=shopTipSp
    self:refreshTipIcon()

    --仓库
	local function goBag()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        armorMatrixVoApi:showBagDialog(self.layerNum+1)
	end
    local bagFontSize=24
    if G_getCurChoseLanguage()=="de" then
        bagFontSize=23
    end
	local bagItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goBag,nil,getlocal("sample_build_name_10"),bagFontSize/itemScale,101)
	bagItem:setScale(itemScale)
    local btnLb=bagItem:getChildByTag(101)
    if btnLb then
        btnLb=tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
	local bagMenu=CCMenu:createWithItem(bagItem)
	bagMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	bagMenu:setAnchorPoint(ccp(0.5,0.5))
	bagMenu:setPosition(ccp(btnCenter+btnW/2+65,itemPy))
	headerBg:addChild(bagMenu,1)

    --一键装备
	local function onEquip()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function refreshCalback(data)
            self:refreshUI()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_use_success"),30)
        end
	    local line,line2=self.tankPos,nil
        local armors,isEmpty,isSame=armorMatrixVoApi:getBestArmor(self.tankPos)
        if isEmpty==false then
            if isSame==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_equip_same"),30)
            else
                armorMatrixVoApi:armorAssembly(line,line2,armors,refreshCalback)
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_empty"),30)
        end
        if (otherGuideMgr.isGuiding and otherGuideMgr.curStep==27) then
            otherGuideMgr:toNextStep()
        end
	end
	local equipItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onEquip,nil,getlocal("armorMatrix_equip"),24/itemScale,101)
	equipItem:setScale(itemScale)
    local btnLb=equipItem:getChildByTag(101)
    if btnLb then
        btnLb=tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
	local equipMenu=CCMenu:createWithItem(equipItem)
	equipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	equipMenu:setAnchorPoint(ccp(0.5,0.5))
	equipMenu:setPosition(ccp(btnCenter+btnW/2+65+btnW+130,itemPy))
	headerBg:addChild(equipMenu,1)


    local bottomLineSp=CCSprite:createWithSpriteFrameName("amBottomLine.png")
    bottomLineSp:setPosition(ccp(headerBg:getContentSize().width/2,12))
    headerBg:addChild(bottomLineSp,1)

    if otherGuideMgr.isGuiding==true then
        otherGuideMgr:setGuideStepField(20,recruitItem,true)
        otherGuideMgr:setGuideStepField(27,equipItem,true)
    end
end

function armorMatrixDialog:initSuit()
    if self.buffBg then
        if self.buffIcon==nil then
            self.buffIcon={}
        end
        for k,v in pairs(self.buffIcon) do
            if v and v.removeFromParentAndCleanup then
                self.buffIcon[k]:removeFromParentAndCleanup(true)
                self.buffIcon[k]=nil
            end
        end
        local suitTb=armorMatrixVoApi:getMatrixSuit(self.tankPos)
        if suitTb then
            for k,v in pairs(suitTb) do
                if v and v.quality and v.num then
                    local quality,num,value=v.quality,v.num,v.value or 0
                    local function onSuit( ... )
                    end
                    local posTb=G_getIconSequencePosx(1,82,50+8,3)
                    local isGray=false
                    if value and value>0 then
                    else
                        isGray=true
                    end
                    local icon=armorMatrixVoApi:getSuitIcon(quality,num,55,onSuit,isGray)
                    -- icon:setTouchPriority(-(self.layerNum-1)*20-4)
                    icon:setPosition(ccp(posTb[k],self.buffBg:getContentSize().height/2-15))
                    self.buffIcon[k]=icon
                    self.buffBg:addChild(icon,1)
                end
            end
        end
    end
end

--attType:1.攻击，2.血量，3.精准，4.闪避，5.暴击，6.坚韧
function armorMatrixDialog:resetAttribute(attType)
    local subPosX = 0
    if G_getCurChoseLanguage() =="ar" then
        subPosX = 15
    end
    if self.headerBg then
        local parent=self.headerBg
    	local labelSize,labelWidth,iconSize=20,140,45
    	-- local value=valueTb[attType]
    	local value=0
    	local attrStr,pic=armorMatrixVoApi:getAttrByType(attType)
        local attrTb=armorMatrixVoApi:getEquipedAttr(self.tankPos)
        if attrTb and attrTb[attType] then
            value=attrTb[attType]
        end
    	attrStr=attrStr..":+"..value.."%"
    	local tag=1010+attType
    	if parent and parent:getChildByTag(tag) then
    		local lb1=tolua.cast(parent:getChildByTag(tag),"CCLabelTTF")
    		lb1:setString(attrStr)
    	else
            local px,py=55+math.floor((attType-1)/2)*190,185-0-((attType-1)%2)*50+self.adaptSpacey*2
            local pos=ccp(px,py)
    		local sp=CCSprite:createWithSpriteFrameName(pic)
    		local iconScale=iconSize/sp:getContentSize().width
    	    sp:setAnchorPoint(ccp(0.5,0.5))
    	    sp:setPosition(pos)
    	    parent:addChild(sp,1)
    	    sp:setScale(iconScale)
    	    local lb=GetTTFLabelWrap(attrStr,labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    		lb:setAnchorPoint(ccp(0,0.5))
    	    lb:setPosition(ccp(pos.x+iconSize/2+5-subPosX,pos.y))
    	    lb:setTag(tag)
    	    parent:addChild(lb,1)
    	    lb:setColor(G_ColorYellowPro)
    	end
    end
end

function armorMatrixDialog:initBottom()
    local bgHeight = 290
    local bgTank = 116
    local spacey=5+self.adaptSpacey
	local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    --iphonex适配
    if G_getIphoneType() == G_iphoneX then
        bgHeight = 400
        bgTank = 170
    end
    local bottomBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
	bottomBg:setContentSize(CCSizeMake(self.bgWidth,bgHeight+self.adaptSpacey*2))
    bottomBg:ignoreAnchorPointForPosition(false)
    bottomBg:setAnchorPoint(ccp(0.5,0))
    bottomBg:setIsSallow(false)
    bottomBg:setTouchPriority(-(self.layerNum-1)*20-1)
	bottomBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,25))
    self.bgLayer:addChild(bottomBg,1)
    bottomBg:setOpacity(0)

    local amChangeBg1=CCSprite:createWithSpriteFrameName("amChangeBg.png")
    amChangeBg1:setScaleX(bottomBg:getContentSize().width/amChangeBg1:getContentSize().width)
    amChangeBg1:setScaleY(bottomBg:getContentSize().height/2/amChangeBg1:getContentSize().height)
    amChangeBg1:setAnchorPoint(ccp(0.5,1))
    amChangeBg1:setPosition(ccp(bottomBg:getContentSize().width/2,bottomBg:getContentSize().height))
    bottomBg:addChild(amChangeBg1)
    local amChangeBg2=CCSprite:createWithSpriteFrameName("amChangeBg.png")
    amChangeBg2:setRotation(180)
    amChangeBg2:setScaleX(bottomBg:getContentSize().width/amChangeBg2:getContentSize().width)
    amChangeBg2:setScaleY(bottomBg:getContentSize().height/2/amChangeBg2:getContentSize().height)
    amChangeBg2:setAnchorPoint(ccp(0.5,1))
    amChangeBg2:setPosition(ccp(bottomBg:getContentSize().width/2,0))
    bottomBg:addChild(amChangeBg2)

    local subTitleSp=CCSprite:createWithSpriteFrameName("amTitleBg.png")
    subTitleSp:setAnchorPoint(ccp(0.5,1))
    subTitleSp:setPosition(ccp(bottomBg:getContentSize().width/2,bottomBg:getContentSize().height))
    bottomBg:addChild(subTitleSp,1)

    local function showInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        armorMatrixVoApi:showDescSmallDialog(self.layerNum+1)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
    -- infoItem:setScale(0.9)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(50,bottomBg:getContentSize().height-subTitleSp:getContentSize().height-30))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    bottomBg:addChild(infoBtn,1)


    local space=2
    self.equippedNumLb={}
    for i=1,5 do
        local equipedNum,equipedMaxNum=armorMatrixVoApi:getEquipedNum()
        local equippedNumLb=GetTTFLabel(getlocal("armorMatrix_has_equipped",{equipedNum,equipedMaxNum}),28,true)
        local px,py=subTitleSp:getContentSize().width/2,subTitleSp:getContentSize().height/2+7
        if i==1 then
            px,py=px-space,py
        elseif i==2 then
            px,py=px,py-space
        elseif i==3 then
            px,py=px+space,py
        elseif i==4 then
            px,py=px,py+space
        end
        if i==5 then
        else
            equippedNumLb:setColor(ccc3(42, 126, 80))
        end
        equippedNumLb:setPosition(ccp(px,py))
        subTitleSp:addChild(equippedNumLb,1)
        -- equippedNumLb:setColor(G_ColorYellowPro)
        self.equippedNumLb[i]=equippedNumLb
    end
    
    local amTankPosBg=CCSprite:createWithSpriteFrameName("amTankPosBg.png")
    amTankPosBg:setPosition(ccp(bottomBg:getContentSize().width/2,bgTank+spacey))
    bottomBg:addChild(amTankPosBg)
    -- amTankPosBg:setOpacity(100)

    local bottomLineSp=CCSprite:createWithSpriteFrameName("amBottomLine.png")
    bottomLineSp:setPosition(ccp(bottomBg:getContentSize().width/2,10))
    bottomBg:addChild(bottomLineSp,1)

    for i=1,6 do
    	local posSp=CCSprite:createWithSpriteFrameName("amTankPosBtn.png")
        local posSp2=CCSprite:createWithSpriteFrameName("amTankPosBtn_Down.png")
    	local firstX,firstY,secX,secY,spaceX,spaceY=215,185+spacey,140,95+spacey,145,0
    	local px,py
         --iphonex适配
        if G_getIphoneType() == G_iphoneX then
            firstY = firstX + 57
            secY = secY + 57
        end
    	if i==1 then
    		px,py=firstX,firstY
    	elseif i==2 then
    		px,py=firstX+spaceX,firstY-spaceY
    	elseif i==3 then
    		px,py=firstX+spaceX*2,firstY-spaceY*2
    	elseif i==4 then
    		px,py=secX,secY
    	elseif i==5 then
    		px,py=secX+spaceX*1,secY-spaceY*1
    	else
    		px,py=secX+spaceX*2,secY-spaceY*2
    	end
    	posSp:setPosition(ccp(px,py))
        posSp2:setPosition(getCenterPoint(posSp))
        posSp2:setTag(101)
        posSp:addChild(posSp2,1)
        local orderNum=7-i
    	self.bgLayer:addChild(posSp,orderNum)
        local tankSp1=CCSprite:createWithSpriteFrameName("amTank.png")
        tankSp1:setPosition(getCenterPoint(posSp))
        tankSp1:setScale(1)
        tankSp1:setTag(102)
        posSp:addChild(tankSp1,2)
        local tankSp2=CCSprite:createWithSpriteFrameName("amMainTank.png")
        tankSp2:setPosition(getCenterPoint(posSp))
        tankSp2:setTag(103)
        posSp:addChild(tankSp2,3)
        tankSp2:setScale(0.45)
        -- local indexSp=CCSprite:createWithSpriteFrameName("amYellow"..i..".png")
        -- indexSp:setPosition(getCenterPoint(posSp))
        -- indexSp:setTag(104)
        -- posSp:addChild(indexSp,4)
        local nameStr=armorMatrixVoApi:getNameByAttr(i)
        local nameLb=GetTTFLabel(nameStr,22)
        nameLb:setAnchorPoint(ccp(0.5,0.5))
        nameLb:setPosition(ccp(posSp:getContentSize().width/2,25))
        nameLb:setTag(105)
        posSp:addChild(nameLb,6)
        nameLb:setColor(G_ColorYellowPro)
        local nameBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
        nameBg:setAnchorPoint(ccp(0.5,0.5))
        nameBg:setPosition(ccp(posSp:getContentSize().width/2,25))
        posSp:addChild(nameBg,5)
        nameBg:setTag(106)
        nameBg:setScaleX((posSp:getContentSize().width-20)/nameBg:getContentSize().width)
        nameBg:setScaleY((nameLb:getContentSize().height+10)/nameBg:getContentSize().height)
        if nameStr and nameStr~="" then
        else
            nameBg:setVisible(false)
        end

        if self.tankPos==i then
            tankSp1:setVisible(false)
        else
            posSp2:setVisible(false)
            tankSp2:setVisible(false)
        end

    	self.posTab[i]=ccp(px,py)
    	self.iconTab[i] = posSp

        local numPx,numPy=px-75,py+48
        if math.ceil(i/3)==2 then
           numPx,numPy=px+75,py-48
        end
        local numSp=CCSprite:createWithSpriteFrameName("amNum"..i..".png")
        numSp:setPosition(ccp(numPx,numPy))
        self.bgLayer:addChild(numSp,1)
    end

    self.clayer=CCLayer:create()
	self.bgLayer:addChild(self.clayer)
    local function tmpHandler(...)
        return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-2,true)
    self.clayer:setTouchPriority(-(self.layerNum-1)*20-2)
    self.clayer:setTouchEnabled(true)
end

function armorMatrixDialog:touchEvent(fn,x,y,touch)
    -- print("touchEvent",fn,x,y,touch)
    if fn=="began" then
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=1 or self.touchRect:containsPoint(ccp(x,y))==false then
            return 0
        end

        -- if self.bgLayer:isVisible()==false then
        --     return 0
        -- end

        local tIcon,tId,isTouchedSoldier = self:isHasIconWithPos(x,y)
        print("touch event",self.type,tId,isTouchedSoldier)
        if tIcon==nil or tId==0 then
            return 0
        end

        self.touchedIcon=tIcon
        self.touchedId=tId

        -- if isTouchedSoldier==true then
            local function startMove()
                self:beginSwitch()
            end
            local callFuncS = CCCallFunc:create(startMove)
            local delayAction=CCDelayTime:create(1.0)
            local seq=CCSequence:createWithTwoActions(delayAction,callFuncS)
            self.touchedIcon:runAction(seq)
            self.movedType=1

        -- else
        --     self.movedType=3

        -- end

        self.isMoved=false
        self.touchArr[touch]=touch
        local touchIndex=0
        for k,v in pairs(self.touchArr) do
            local temTouch= tolua.cast(v,"CCTouch")
            if self and temTouch then
                if touchIndex==0 then
                     self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                else
                     self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                end
            end
            touchIndex=touchIndex+1
        end
        if touchIndex==1 then
            self.secondOldPos=nil
            self.lastTouchDownPoint=self.firstOldPos
        end
        if SizeOfTable(self.touchArr)>1 then
            self.multTouch=true
        else
            self.multTouch=false
        end

        if self.multTouch==false then
            if tIcon~=nil and tId~=0 and tId~=self.tankPos then
                self.tankPos=tId
                self:refreshUI()
            end
        end

        return 1
    elseif fn=="moved" then
        if self.touchEnable==false then
             do
                return
             end
        end

        -- if self.movedType==3 then
        --      do
        --         return
        --      end
        -- end

        self.isMoved=true
        if self.multTouch==true then --双点触摸

        else --单点触摸

            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            if curPos.y>self.limitH then
                curPos.y=self.limitH
            elseif curPos.y<100 then
                curPos.y=100
            end
            if curPos.x>G_VisibleSizeWidth-100 then
                curPos.x=G_VisibleSizeWidth-100
            elseif curPos.x<100 then
                curPos.x=100
            end 
            local moveDisPos=ccpSub(curPos,self.firstOldPos)
            -- 部分安卓设备可能存在灵敏度问题
            local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
            if G_isIOS()==false then
                if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<13 then
                    self.isMoved=false
                    do return end
                end
            else
                if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<30 then
                    self.isMoved=false
                    do return end
                end
            end
            if self.movedType==1 then
                self.touchedIcon:stopAllActions()
                self.movedType=2
                self:setIconScale(self.touchedIcon,true)
                self.bgLayer:reorderChild(self.touchedIcon,8)
            end

            if self.movedType==2 then
                self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,(curPos.y-self.firstOldPos.y)*3)
                local tmpPos=ccpAdd(ccp(self.touchedIcon:getPosition()),ccp(moveDisPos.x,moveDisPos.y))
                self.touchedIcon:setPosition(tmpPos)
                self.firstOldPos=curPos
                self.isMoving=true

                -- -- 移动到的
                -- local tIcon,tId  = self:isHasIconWithPos(self.touchedIcon:getPositionX(),self.touchedIcon:getPositionY(),true)
                -- if tId~=self.movedId and self.movedIcon then

                --     local tempSp = nil
                --     if self.movedIcon and self.movedIcon:getChildByTag(2) then
                --         tempSp = tolua.cast(self.movedIcon:getChildByTag(2):getChildByTag(12),"CCSprite")
                --     end
                --     if tempSp then
                --         tempSp:setOpacity(255)
                --     end
                --     self.movedIcon=nil
                --     self.movedId=0
                    
                -- end

                -- if tIcon~=nil and tId~=0 and tId~=self.movedId and tId~=self.touchedId then
                --     self.movedIcon=tIcon
                --     local tempSp = nil
                --     if tIcon:getChildByTag(2) then
                --         tempSp = tolua.cast(tIcon:getChildByTag(2):getChildByTag(12),"CCSprite")
                --     end
                --     if tempSp then
                --         tempSp:setOpacity(100)
                --     end
                --     self.movedId=tId
                -- end
            end
        end
    elseif fn=="ended" then
        if self.touchEnable==false then
            do
                return
            end
        end
        if self.touchArr[touch]~=nil then
           	self.touchArr[touch]=nil
           	local touchIndex=0
            for k,v in pairs(self.touchArr) do
                if touchIndex==0 then
                    self.firstOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                else
                    self.secondOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                end
                touchIndex=touchIndex+1
            end
            if touchIndex==1 then
                self.secondOldPos=nil
            end
            if SizeOfTable(self.touchArr)>1 then
                self.multTouch=true
            else
                self.multTouch=false
            end
        end
        if self.isMoving==true then
            self.isMoving=false

            -- local tmpToPos=ccp(self.touchedIcon:getPosition())

            -- local positionY = G_VisibleSizeHeight/2-10-32+5

            -- local positionX=120+(self.touchedId-1)*200

            -- local XL = 0

            -- --优化拖动
            -- if (x-positionX > 30 and x-positionX <100) then
            --     XL=100
            -- end
            -- if (x-positionX > -100 and x-positionX < -30) then
            --     XL=-100
            -- end

            -- local tIcon,tId = self:isHasIconWithPos(x+XL,y,true)
            local tIcon,tId = self:isHasIconWithPos(self.touchedIcon:getPositionX(),self.touchedIcon:getPositionY(),true)

            local iconPos = nil

            local function endMove()
                -- self.touchedIcon:setScale(self.touchedScaleX)
                -- self.touchedIcon:setScale(self.touchedScaleY)
                -- self.touchedIcon:setOpacity(0)
                self:setIconScale(self.touchedIcon)
                self.bgLayer:reorderChild(self.touchedIcon,5)

                self.touchedIcon=nil
                self.touchedId=0
                self.movedType=0

                -- if self.movedIcon and self.movedIcon:getChildByTag(2) and self.movedIcon:getChildByTag(2):getChildByTag(12) then
                --     local tempSp = tolua.cast(self.movedIcon:getChildByTag(2):getChildByTag(12),"CCSprite")
                --     if tempSp then
                --         tempSp:setOpacity(255)
                --     end
                    
                --     self.movedIcon=nil
                --     self.movedId=0
                -- end

            end

            if tIcon~=nil and tId~=0 and tId~=self.touchedId then
                -- local allArmorMatrix=armorMatrixVoApi:getAllArmorMatrix()
                -- if allArmorMatrix and SizeOfTable(allArmorMatrix)>0 then
                    local function refreshCalback( ... )
                        self.tankPos=tId

                        tIcon:setPosition(self.posTab[self.touchedId])
                        self:setIconScale(tIcon)
                        self.iconTab[self.touchedId]=tIcon
                        self.iconTab[tId]=self.touchedIcon

                        tIcon:setTag(self.touchedId)
                        self.touchedIcon:setTag(tId)

                        iconPos=self.posTab[tId]

                        -- if self.isShowTank==1 then
                        --     tankVoApi:exchangeTanksByType(self.type,self.touchedId,tId)
                        -- else
                        --     heroVoApi:exchangeHerosByType(self.type,self.touchedId,tId)
                        -- end
                        
                        -- self:checkButtomName(self.touchedId)
                        -- self:checkButtomName(tId)

                        self.touchedIcon:setPosition(iconPos)
                        self:setIconScale(self.touchedIcon)
                        endMove()
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_change_success"),30)
                    end
                    local line,line2,armors=self.tankPos,tId
                    local isEmpty1=armorMatrixVoApi:isEmptyByPos(line)
                    local isEmpty2=armorMatrixVoApi:isEmptyByPos(line2)
                    -- print("isEmpty1,isEmpty2",isEmpty1,isEmpty2)
                    if isEmpty1==true and isEmpty2==true then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_change_empty"),30)
                    else
                        armorMatrixVoApi:armorAssembly(line,line2,armors,refreshCalback)
                    end
                -- else
                --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_empty"),30)
                -- end
                self.touchedIcon:setPosition(self.posTab[self.touchedId])
                self:setIconScale(self.touchedIcon)
            else
                self.touchedIcon:setPosition(self.posTab[self.touchedId])
                endMove()
            end

            -- -- if iconPos then
            -- --     self.touchedIcon:setPosition(iconPos)
            -- --     self:setIconScale(self.touchedIcon)
            -- -- else 
            --     self.touchedIcon:setPosition(self.posTab[self.touchedId])
            -- -- end

            -- endMove()

            -- self:resetQueueNum()
        else

            if self.touchedIcon~=nil and self.touchedId~=0 and (self.movedType==1)then
                -- local tankPos=self.touchedId
                -- self.tankPos=tankPos
                -- self:refreshUI()
                -- -- self:touchConfig(self.touchedId)
            elseif self.touchedIcon~=nil and self.touchedId~=0 and self.movedType==2 then
                -- self.touchedIcon:setOpacity(0)
                self:setIconScale(self.touchedIcon)
                self.bgLayer:reorderChild(self.touchedIcon,5)
            end
            self.touchedIcon:stopAllActions()
            self.movedType=0
        end
    else

        if self.touchedIcon then
            self.touchedIcon:setPosition(self.posTab[self.touchedId])
            -- self.touchedIcon:setOpacity(0)
            self:setIconScale(self.touchedIcon)
            self.bgLayer:reorderChild(self.touchedIcon,5)
        end

        self.touchedIcon=nil
        self.touchedId=0
        self.movedType=0

        -- if self.movedIcon then
        --     local tempSp = tolua.cast(self.movedIcon:getChildByTag(2):getChildByTag(12),"CCSprite")
        --      if tempSp then
        --         tempSp:setOpacity(255)
        --     end
        --     self.movedIcon=nil
        --     self.movedId=0
        -- end
        self.touchArr=nil
        self.touchArr={}
    end
end
function armorMatrixDialog:isHasIconWithPos(x,y,isMoveEnd)
    local tIcon = nil
    local idx = 0


    -- if isMoveEnd==true then
        for i=1,6 do


            local tempIcon = self.iconTab[i]

            local tPos = self.posTab[i]
            local tRect = CCRect(tPos.x-tempIcon:getContentSize().width/2,tPos.y-tempIcon:getContentSize().height/2,tempIcon:getContentSize().width,tempIcon:getContentSize().height)

            if tRect:containsPoint(ccp(x,y))==true then

                -- local isTouchedSoldier = false
                -- if tempIcon then
                --     isTouchedSoldier=true
                -- end

                return tempIcon,i--,isTouchedSoldier


            end
        end
    -- else
    --     for i=1,6 do

    --         local tempIcon = self.iconTab[i]

    --         local tPos = self.posTab[i]        
    --         local tRect = CCRect(tPos.x-tempIcon:getContentSize().width/2,tPos.y-tempIcon:getContentSize().height/2,tempIcon:getContentSize().width,tempIcon:getContentSize().height)

    --         -- print("touch pos",tPos.x,tPos.y,tPos.x-tempIcon:getContentSize().width/2,tPos.y-tempIcon:getContentSize().height/2,tempIcon:getContentSize().width,tempIcon:getContentSize().height)

    --         if tRect:containsPoint(ccp(x,y))==true then

    --             local isTouchedSoldier = false
    --             if tempIcon:getChildByTag(2) then
    --                 isTouchedSoldier=true
    --             end

    --             return tempIcon,i,isTouchedSoldier
    --         end
    --     end
    -- end

    return tIcon,idx
end
function armorMatrixDialog:beginSwitch()
    if self.isMoved==false and self.movedType==1 then
        if self.touchedIcon~=nil then
            print("beginSwitch")
            self.movedType=2
            self:setIconScale(self.touchedIcon,true)
            self.bgLayer:reorderChild(self.touchedIcon,8)
        end
    end
end
function armorMatrixDialog:setIconScale(icon,isBig)
	if icon then
		if isBig==true then
			icon:setScale(1.2)
		else
			icon:setScale(1)
		end
	end
end

function armorMatrixDialog:refreshUI()
    -- local armors=armorMatrixVoApi:hasBetterTb(self.tankPos)
    for i=1,6 do
        local tag=2100+i
        local graySp=self.headerBg:getChildByTag(tag)
        if graySp then
            local function onClick( ... )
            end
            local amIcon=graySp:getChildByTag(tag)
            if amIcon then
                amIcon:removeFromParentAndCleanup(true)
                amIcon=nil
            end
            local mid,id,lv=armorMatrixVoApi:getEquipedData(self.tankPos,i)
            if mid and id and id~=0 then
                amIcon=armorMatrixVoApi:getArmorMatrixIcon(mid,90,100,onClick,lv)
                -- amIcon:setScale(90/amIcon:getContentSize().width)
                amIcon:setPosition(getCenterPoint(graySp))
                amIcon:setTag(tag)
                graySp:addChild(amIcon,1)
                armorMatrixVoApi:addLightEffect(amIcon, mid)
            end
            -- local newsTip=graySp:getChildByTag(3100)
            -- if newsTip then
            --     if armors and armors[i]==1 then
            --         newsTip:setVisible(true)
            --     else
            --         newsTip:setVisible(false)
            --     end
            -- end
        end

        self:resetAttribute(i)

        if self.iconTab and self.iconTab[i] then
            local sp=tolua.cast(self.iconTab[i],"CCSprite")
            if sp then
                local posSp2=tolua.cast(sp:getChildByTag(101),"CCSprite")
                local tankSp1=tolua.cast(sp:getChildByTag(102),"CCSprite")
                local tankSp2=tolua.cast(sp:getChildByTag(103),"CCSprite")
                local nameLb=tolua.cast(sp:getChildByTag(105),"CCLabelTTF")
                local nameBg=tolua.cast(sp:getChildByTag(106),"CCSprite")
                if nameLb then
                    local nameStr=armorMatrixVoApi:getNameByAttr(i)
                    nameLb:setString(nameStr)
                    if nameBg then
                        if nameStr and nameStr~="" then
                            nameBg:setVisible(true)
                            nameBg:setScaleX((sp:getContentSize().width-20)/nameBg:getContentSize().width)
                            nameBg:setScaleY((nameLb:getContentSize().height+10)/nameBg:getContentSize().height)
                        else
                            nameBg:setVisible(false)
                        end
                    end
                end
                if self.tankPos==i then
                    if posSp2 then
                        posSp2:setVisible(true)
                    end
                    if tankSp1 then
                        tankSp1:setVisible(false)
                    end
                    if tankSp2 then
                        tankSp2:setVisible(true)
                    end
                else
                    if posSp2 then
                        posSp2:setVisible(false)
                    end
                    if tankSp1 then
                        tankSp1:setVisible(true)
                    end
                    if tankSp2 then
                        tankSp2:setVisible(false)
                    end
                end
            end
        end
    end
    self:initSuit()
    if self.equippedNumLb then
        for k,v in pairs(self.equippedNumLb) do
            if v then
                local lb=tolua.cast(v,"CCLabelTTF")
                if lb then
                    local equipedNum,equipedMaxNum=armorMatrixVoApi:getEquipedNum()
                    lb:setString(getlocal("armorMatrix_has_equipped",{equipedNum,equipedMaxNum}))
                end
            end
        end
    end
    self:refresNewsTip()
end

function armorMatrixDialog:refresNewsTip()
    local armors=armorMatrixVoApi:hasBetterTb(self.tankPos)
    for i=1,6 do
        local tag=2100+i
        local graySp=self.headerBg:getChildByTag(tag)
        if graySp then
            local newsTip=graySp:getChildByTag(3100)
            if newsTip then
                if armors and armors[i]==1 then
                    newsTip:setVisible(true)
                else
                    newsTip:setVisible(false)
                end
            end
        end
    end
end

function armorMatrixDialog:refresNewsIcon()
    if self.newsIcon then
        local _,_,num1=armorMatrixVoApi:getRecruitCost(1,1)
        local _,_,num2=armorMatrixVoApi:getRecruitCost(2,1)
        if num1+num2>0 then
            self.newsIcon:setVisible(true)
            local lbNum=tolua.cast(self.newsIcon:getChildByTag(11),"CCLabelTTF")
            if lbNum then
                lbNum:setString(num1+num2)
            end

        else
            self.newsIcon:setVisible(false)
        end
    end
   

end

function armorMatrixDialog:refreshTipIcon()
    if self.shopTipSp then
        if armorMatrixVoApi:isAddShopTip() then
            self.shopTipSp:setVisible(true)
        else
            self.shopTipSp:setVisible(false)
        end
    end
end

function armorMatrixDialog:tick()
    self:refresNewsIcon()
    self:refreshTipIcon()
end

function armorMatrixDialog:dispose()
	self.tankPos=nil
    self.headerBg=nil
	self.clayer=nil
    self.shopTipSp=nil
    spriteController:removePlist("public/armorMatrix.plist")
    spriteController:removeTexture("public/armorMatrix.png")
    spriteController:removePlist("public/boss_fuben_images.plist")
    spriteController:removeTexture("public/boss_fuben_images.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/heroRecruitImage.plist")
    eventDispatcher:removeEventListener("armorMatrix.dialog.refresh",self.dialogListener)
    spriteController:removePlist("public/armorMatrixEffect.plist")
    spriteController:removeTexture("public/armorMatrixEffect.png")
end




