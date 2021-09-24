armorMatrixSuitSmallDialog=smallDialog:new()

function armorMatrixSuitSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.btnScale1=160/205
    return nc
end

function armorMatrixSuitSmallDialog:init(layerNum,tankPos)
    self.layerNum=layerNum
    self.tankPos=tankPos
    local suitTb=armorMatrixVoApi:getMatrixSuit(tankPos)

    -- local cfg=armorMatrixVoApi:getCfgByMid(mid)
    -- if tankPos==nil or index==nil then
    --     isShowBtn=false
    -- end

    local function touchHandler()
    
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg

    local bgWidth,bgHeight=550,700
    self.bgSize=CCSizeMake(bgWidth,bgHeight)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()


    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    -- local function close()
    --     PlayEffect(audioCfg.mouseClick)
    --     return self:close()
    -- end
    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    -- closeBtnItem:setPosition(ccp(0,0))
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    -- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    -- self.bgLayer:addChild(self.closeBtn,2)


    local posy=self.bgLayer:getContentSize().height-50
    local titleLb = GetTTFLabel(getlocal("armorMatrix_suit_active"),30)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,posy))
    self.bgLayer:addChild(titleLb,1)
    local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    titleBg:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,posy-0))
    titleBg:setScaleY((titleLb:getContentSize().height+20)/titleBg:getContentSize().height)
    titleBg:setScaleX(self.bgSize.width/titleBg:getContentSize().width)
    self.bgLayer:addChild(titleBg)

    local function cellClick(hd,fn,idx)
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local isShowSuitBg=false
    if suitTb and suitTb[2] and suitTb[2].quality and suitTb[2].num and suitTb[2].value and suitTb[2].value>0 then
        isShowSuitBg=true
        local suitBg2=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        suitBg2:setContentSize(CCSizeMake(310+30,200))
        suitBg2:ignoreAnchorPointForPosition(false)
        suitBg2:setAnchorPoint(ccp(0.5,1))
        suitBg2:setIsSallow(false)
        suitBg2:setTouchPriority(-(self.layerNum-1)*20-1)
        suitBg2:setPosition(ccp(190,self.bgLayer:getContentSize().height-80))
        self.bgLayer:addChild(suitBg2,1)
        local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setRotation(90)
        lineSp:setPosition(ccp(suitBg2:getContentSize().width/2,suitBg2:getContentSize().height/2))
        lineSp:setScaleX((suitBg2:getContentSize().height-40)/lineSp:getContentSize().width)
        suitBg2:addChild(lineSp,1)
    end
    local xtb=G_getIconSequencePosx(2,170,self.bgLayer:getContentSize().width/2,3)
    for i=1,3 do
        local suitBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        suitBg:setContentSize(CCSizeMake(140,200))
        suitBg:ignoreAnchorPointForPosition(false)
        suitBg:setAnchorPoint(ccp(0.5,1))
        suitBg:setIsSallow(false)
        suitBg:setTouchPriority(-(self.layerNum-1)*20-1)
        suitBg:setPosition(ccp(xtb[i],self.bgLayer:getContentSize().height-80))
        self.bgLayer:addChild(suitBg,1)
        if suitTb and suitTb[i] and suitTb[i].quality and suitTb[i].num then
            local quality,num,value=suitTb[i].quality,suitTb[i].num,suitTb[i].value or 0
            local isGray=false
            if value and value>0 then
            else
                isGray=true
            end
            local function onClick( ... )
            end
            local suitIcon=armorMatrixVoApi:getSuitIcon(quality,num,80,onClick,isGray)
            suitIcon:setPosition(ccp(suitBg:getContentSize().width/2,suitBg:getContentSize().height-60))
            suitBg:addChild(suitIcon,1)
            local lbpy=40
            if value and value>0 then
                local allAttrLb=GetTTFLabelWrap(getlocal("armorMatrix_suit_all_attr"),22,CCSizeMake(suitBg:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                allAttrLb:setAnchorPoint(ccp(0.5,0))
                allAttrLb:setPosition(ccp(suitBg:getContentSize().width/2,lbpy+0))
                suitBg:addChild(allAttrLb,1)
                local attrLb=GetTTFLabel(getlocal("armorMatrix_suit_add_attr",{value*100}),22)
                attrLb:setAnchorPoint(ccp(0.5,1))
                attrLb:setPosition(ccp(suitBg:getContentSize().width/2,lbpy-0))        
                suitBg:addChild(attrLb,1)
                attrLb:setColor(G_ColorGreen)
            else
                local unActiceLb=GetTTFLabelWrap(getlocal("not_activated"),22,CCSizeMake(suitBg:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                unActiceLb:setAnchorPoint(ccp(0.5,0.5))
                unActiceLb:setPosition(ccp(suitBg:getContentSize().width/2,lbpy))
                suitBg:addChild(unActiceLb,1)
                unActiceLb:setColor(G_ColorGray)
            end
        end
        if isShowSuitBg==true and (i==1 or i==2) then
            suitBg:setOpacity(0)
        end
    end
    

    posy=posy-290+50
    local function cellClick1( ... )
    end
    local attrBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),cellClick1)
    attrBg:setAnchorPoint(ccp(0.5,1))
    attrBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,300))
    attrBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,posy))
    self.bgLayer:addChild(attrBg,1)
    
    if self.refreshData==nil then
        self.refreshData={}
    end
    local spacey=15
    local cellWidth,cellHeight=attrBg:getContentSize().width,0
    local descLb=GetTTFLabelWrap(getlocal("armorMatrix_suit_desc"),25,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    cellHeight=spacey+descLb:getContentSize().height+spacey*2
    local armorCfg=armorMatrixVoApi:getArmorCfg()
    for k,v in pairs(armorCfg.matrixSuit) do
        local quality=k
        if v then
            for kk,vv in pairs(v) do
                if vv then
                    local num,value=kk,vv
                    local vStr=nil
                    if type(value)=="table" then
                        vStr=getlocal("firstValue").."+"..value[2]
                        value=value[1]
                    end
                    local valueStr=getlocal("armorMatrix_suit_value",{getlocal("armorMatrix_color_"..quality),num,value*100})
                    if vStr then
                        valueStr=valueStr..",["..vStr.."]"
                    end
                    local color=armorMatrixVoApi:getColorByQuality(quality)
                    local colorTab={nil,color,nil}
                    local suitLb,lbHeight=G_getRichTextLabel(valueStr,colorTab,22,370,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
                    cellHeight=cellHeight+lbHeight+spacey
                end
            end
        end
    end

    local function tvCallBack(handler,fn,idx,cel)
        local strSize2 = 15
        local subPosX = 0
        if G_isAsia() == true then
            strSize2 = 18
        elseif G_getCurChoseLanguage() == "ar" then
            subPosX = 35
        else
            subPosX = 20
        end
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local lby=cellHeight-spacey
            local descLb=GetTTFLabelWrap(getlocal("armorMatrix_suit_desc"),25,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(20,lby))
            cell:addChild(descLb,1)

            lby=lby-descLb:getContentSize().height-spacey
            local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSprite:setPosition(ccp(cellWidth/2+10,lby))
            cell:addChild(lineSprite,1)
            lineSprite:setScaleX(cellWidth/lineSprite:getContentSize().width)

            lby=lby-spacey
            local effectLb=GetTTFLabelWrap(getlocal("armorMatrix_effect_list"),25,CCSizeMake(130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            effectLb:setAnchorPoint(ccp(0,1))
            effectLb:setPosition(ccp(20,lby))
            cell:addChild(effectLb,1) 
            local lbx=20+effectLb:getContentSize().width+10
            local armorCfg=armorMatrixVoApi:getArmorCfg()
            -- local attrLbHeight=0
            for k,v in pairs(armorCfg.matrixSuit) do
                local quality=k
                if v then
                    for kk,vv in pairs(v) do
                        if vv then
                            local num,value=kk,vv
                            local vStr=nil
                            if type(value)=="table" then
                                vStr=getlocal("firstValue").."+"..value[2]
                                value=value[1]
                            end
                            local valueStr=getlocal("armorMatrix_suit_value",{getlocal("armorMatrix_color_"..quality),num,value*100})
                            if vStr then
                                valueStr=valueStr..",["..vStr.."]"
                            end
                            local color=armorMatrixVoApi:getColorByQuality(quality)
                            local colorTab={nil,color,nil}
                            local suitLb,lbHeight=G_getRichTextLabel(valueStr,colorTab,strSize2,370,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
                            suitLb:setAnchorPoint(ccp(0,1))
                            suitLb:setPosition(ccp(lbx-subPosX,lby))
                            cell:addChild(suitLb,1)
                            lby=lby-lbHeight-spacey
                        end
                    end
                end
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,attrBg:getContentSize().height-10),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(20,posy-attrBg:getContentSize().height+5))
    self.bgLayer:addChild(self.refreshData.tableView,1)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)

    self:addForbidSp(self.bgLayer,self.bgSize,layerNum,true)


    local function onConfim()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        self:close()
    end
    local confimItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfim,nil,getlocal("ok"),24/self.btnScale1)
    confimItem:setScale(self.btnScale1)
    local confimMenu=CCMenu:createWithItem(confimItem)
    confimMenu:setTouchPriority(-(layerNum-1)*20-4)
    confimMenu:setAnchorPoint(ccp(0.5,0.5))
    confimMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,60))
    self.bgLayer:addChild(confimMenu,1)


    local function touchLuaSpr()
        -- PlayEffect(audioCfg.mouseClick)
        -- self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
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

