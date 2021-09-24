useOrBuyPropSmallDialog=smallDialog:new()

function useOrBuyPropSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function useOrBuyPropSmallDialog:init(bgSrc,size,fullRect,inRect,isuseami,layerNum,isBuy,pid,callback,btnStr,limitNum,truePrice,costTb,isNotProp,shopItem,onePrice,isIntegral)
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/acRadar_images.plist")
    spriteController:addTexture("public/acRadar_images.png")

    self.isTouch=nil
    self.isUseAmi=isuseami

    local function touchHandler()
    end
    local dialogBg,lineSp1,lineSp2=G_getNewDialogBg2(size,layerNum,touchHandler)
    -- local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local nameFontSize,priceFontSize=22,20
    local lnode=CCNode:create()
    lnode:setContentSize(CCSizeMake(self.bgSize.width,1))
    lnode:setAnchorPoint(ccp(0.5,1))
    dialogBg:addChild(lnode)
    local confirmMenu
    local height=0
    local maxNum=0
    local price=0
    if isNotProp or (pid and propCfg[pid]) then
        local id=tonumber(pid) or tonumber(RemoveFirstChar(pid))
        if isBuy==true then
            local prop=propCfg[pid]
            if costTb then
                local tmpMaxNum    
                for k,v in pairs(costTb) do
                    local num=0
                    if v.type=="u" then
                        num=playerVo[v.key]
                    elseif v.type=="p" then
                        num=bagVoApi:getItemNumId(v.id)
                    elseif v.type=="e" then
                        local propNum=accessoryVoApi:getShopPropNum()
                        num = tonumber(propNum[v.key])
                    end
                    local canBuyNum=math.floor(num/v.num)
                    if tmpMaxNum==nil then
                        tmpMaxNum=canBuyNum
                    elseif tmpMaxNum>canBuyNum then
                        tmpMaxNum=canBuyNum
                    end
                end
                maxNum=tmpMaxNum or 0
            else
                if prop and prop.spCost then --特惠商品价格会根据购买次数发生变化
                    maxNum = allShopVoApi:getSpecialShopItemMaxBuyNum(pid)
                else
                    price=truePrice or prop.gemCost  
                    local gemsCount=playerVoApi:getGems()
                    local num=math.floor(gemsCount/price)
                    maxNum=num
                    if maxNum == 0 then
                        maxNum = 1
                    end
                end
            end
            local sbLimitNum=limitNum or 100
            if not isNotProp and  maxNum>prop.maxCount then
                maxNum=prop.maxCount
            end
            if maxNum>sbLimitNum then
                maxNum=sbLimitNum
            end
        else
            maxNum=bagVoApi:getItemNumId(id)
        end
        if isIntegral then
            maxNum = limitNum or 1
        end
        local item 
        if not isNotProp then
            local itemData={p={}}
            itemData.p[pid]=maxNum
            local itemTb=FormatItem(itemData,false)
            item=itemTb[1]
        else
            item = shopItem
        end
        
        if item then
            -- local iconSp=bagVoApi:getItemIcon(pid)
            local iconSp,scale=G_getItemIcon(item,100,false)
            if iconSp then
                iconSp:setAnchorPoint(ccp(0,1))
                iconSp:setPosition(25,0)
                lnode:addChild(iconSp,2)
            end

            local nameLb=GetTTFLabelWrap(item.name,nameFontSize,CCSize(self.bgSize.width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            nameLb:setAnchorPoint(ccp(0,1))
            nameLb:setPosition(ccp(iconSp:getPositionX()+iconSp:getContentSize().width*scale+10,iconSp:getPositionY()))
            lnode:addChild(nameLb,1)
            nameLb:setColor(G_ColorGreen)
            
            local descLb=GetTTFLabelWrap(getlocal(item.desc),priceFontSize,CCSize(self.bgSize.width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(nameLb:getPositionX(),nameLb:getPositionY()-nameLb:getContentSize().height-20))
            lnode:addChild(descLb,1)

            height=nameLb:getContentSize().height+descLb:getContentSize().height+20
            if height<iconSp:getContentSize().height then
                height=iconSp:getContentSize().height
            end
            height=height+30

            -- if isBuy==true then
            --     local priceTip=GetTTFLabel(getlocal("per_price").."：",25)
            --     priceTip:setAnchorPoint(ccp(0,0.5))
            --     priceTip:setPosition(self.bgSize.width-220,-height)
            --     lnode:addChild(priceTip)
            --     local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
            --     goldSp:setAnchorPoint(ccp(0,0.5))
            --     goldSp:setPosition(ccp(priceTip:getPositionX()+priceTip:getContentSize().width,-height))
            --     lnode:addChild(goldSp)
            --     local priceLb=GetTTFLabel(price,25)
            --     priceLb:setAnchorPoint(ccp(0,0.5))
            --     priceLb:setPosition(goldSp:getPositionX()+goldSp:getContentSize().width,-height)
            --     lnode:addChild(priceLb)
            --     if priceTip:getContentSize().height>goldSp:getContentSize().height then
            --         height=height+priceTip:getContentSize().height
            --     else
            --         height=height+goldSp:getContentSize().height
            --     end
            -- end
            if isIntegral == nil and item.type =="p" and propCfg[pid].spCost then
                local usePreferentialNum = allShopVoApi:getSpecialShopBuyNum(pid)
                local maxPreferentialNum = SizeOfTable(propCfg[pid].spCost) - 1
                local lbColorTb = {}
                if usePreferentialNum >= maxPreferentialNum then
                    usePreferentialNum = maxPreferentialNum
                    lbColorTb = { nil, G_ColorRed, nil }
                end
                local lbStr = getlocal("shop_preferentialNumText", { "<rayimg>" ..  usePreferentialNum .. "<rayimg>/" .. maxPreferentialNum})
                local numTipsLb, lbHeight = G_getRichTextLabel(lbStr, lbColorTb, priceFontSize, self.bgSize.width - 60, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                numTipsLb:setAnchorPoint(ccp(0.5, 1))
                numTipsLb:setPosition(self.bgSize.width / 2, -height + lbHeight)
                lnode:addChild(numTipsLb)
            end
         
            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
            lineSp:setAnchorPoint(ccp(0.5,1))
            lineSp:setContentSize(CCSizeMake(self.bgSize.width-60,2))
            lineSp:setPosition(ccp(self.bgSize.width/2,-height))
            lnode:addChild(lineSp)
            height=height+40

            local numTip=GetTTFLabel(getlocal("amountStr").."：",priceFontSize)
            numTip:setAnchorPoint(ccp(0,0.5))
            local numLb=GetTTFLabel(maxNum,25)
            numLb:setAnchorPoint(ccp(0,0.5))
            numLb:setColor(G_ColorGreen)

            local numNode
            if isBuy==false or isBuy==nil then
                numNode=CCNode:create()
                numNode:setContentSize(CCSizeMake(numTip:getContentSize().width+numLb:getContentSize().width,numTip:getContentSize().height))
                numNode:setAnchorPoint(ccp(0.5,0.5))
                lnode:addChild(numNode)
                numNode:addChild(numTip)
                numNode:addChild(numLb)
                numTip:setPosition(ccp(0,numNode:getContentSize().height/2))
                numLb:setPosition(ccp(numTip:getPositionX()+numTip:getContentSize().width,numNode:getContentSize().height/2))
                numNode:setPosition(ccp(self.bgSize.width/2,-height))
            else
                lnode:addChild(numTip)
                lnode:addChild(numLb,2)
                numTip:setPosition(140,-height+15)
                if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
                    numTip:setPosition(140,-height)
                end
                numLb:setPosition(numTip:getPositionX()+numTip:getContentSize().width,numTip:getPositionY())
            end
            local tpriceLb
            if isBuy==true then
                local tpriceTip=GetTTFLabel(getlocal("total_price").."：",priceFontSize)
                tpriceTip:setAnchorPoint(ccp(0,0.5))

                tpriceTip:setPosition(140,-height-20)
                if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
                    tpriceTip:setPosition(self.bgSize.width-260,-height)
                end
                lnode:addChild(tpriceTip)
                if costTb then
                    self.costLbTb={}
                    local iconSize,startY=40,tpriceTip:getPositionY()
                    for k,v in pairs(costTb) do
                        local iconSp
                        if v.type=="u" then
                            local pic=G_getResourceIcon(v.key)
                            if pic then
                                iconSp=CCSprite:createWithSpriteFrameName(pic)
                            end
                        elseif v.type=="p" then
                            iconSp=G_getItemIcon(v,100)
                            iconSp:setScale(iconSize/iconSp:getContentSize().width)
                        elseif v.type=="e" and v.eType=="p" then
                            --配件的晶体图片不要背景图
                            if(v.key=="p8" or v.key=="p9" or v.key=="p10") then
                                if (v.key=="p8") then
                                    iconName="accessoryP8_1.png"
                                elseif(v.key=="p9") then
                                    iconName="accessoryP9_1.png"
                                elseif(v.key=="p10") then
                                    iconName="accessoryP10_1.png"
                                end
                                iconSp=CCSprite:createWithSpriteFrameName(iconName)
                            else
                                iconSp=G_getItemIcon(v,100)
                            end
                            iconSp:setScale(iconSize/iconSp:getContentSize().width)
                        end
                        if iconSp then
                            iconSp:setPosition(tpriceTip:getPositionX()+tpriceTip:getContentSize().width+16,startY)
                            lnode:addChild(iconSp)
                            costLb=GetTTFLabel("",priceFontSize)
                            costLb:setAnchorPoint(ccp(0,0.5))
                            costLb:setPosition(iconSp:getPositionX()+25,iconSp:getPositionY())
                            lnode:addChild(costLb)
                            self.costLbTb[k]=costLb
                        end
                        startY=startY-40
                    end
                    height=height+(SizeOfTable(costTb)-1)*40
                else
                    local tgemPic, tgemScale
                    if type(isIntegral) == "table" then
                        tgemPic = isIntegral[1]
                        tgemScale = isIntegral[2] or 1
                    else
                        tgemPic = (isIntegral == true and "acRadar_integralIcon.png" or "IconGold.png")
                        tgemScale = 1
                    end
                    local tgemSp=CCSprite:createWithSpriteFrameName(tgemPic)
                    tgemSp:setAnchorPoint(ccp(0,0.5))
                    tgemSp:setScale(tgemScale)
                    tgemSp:setPosition(ccp(tpriceTip:getPositionX()+tpriceTip:getContentSize().width,tpriceTip:getPositionY()))
                    lnode:addChild(tgemSp)
                    tpriceLb=GetTTFLabel("",priceFontSize)
                    tpriceLb:setAnchorPoint(ccp(0,0.5))
                    tpriceLb:setPosition(tgemSp:getPositionX()+tgemSp:getContentSize().width*tgemScale,tpriceTip:getPositionY())
                    lnode:addChild(tpriceLb)
                end
            end

            height=height+numTip:getContentSize().height+40

            local function sliderTouch(handler,object)
                local count=math.ceil(object:getValue())
                if count>0 then
                    if isBuy==true then
                        numLb:setString(count)
                        if costTb then
                            if self.costLbTb then
                                for k,v in pairs(costTb) do
                                    local costLb=self.costLbTb[k]
                                    if costLb then
                                        costLb:setString(FormatNumber(count*v.num))
                                    end
                                end
                            end
                        else
                            if type(onePrice) == "number" then
                                if tpriceLb then
                                    tpriceLb:setString(count * onePrice)
                                end
                            else
                                if propCfg[pid] and propCfg[pid].spCost then
                                    if tpriceLb then
                                        local costNum = allShopVoApi:getSpecialShopItemCost(pid,count)
                                        tpriceLb:setString(costNum)
                                    end
                                else
                                    if tpriceLb and price then
                                        tpriceLb:setString(count*price)
                                    end
                                end
                            end
                        end
                    else
                        numLb:setString(count.."/"..maxNum)
                        if numNode then
                            numNode:setContentSize(CCSizeMake(numTip:getContentSize().width+numLb:getContentSize().width,numTip:getContentSize().height))
                        end
                    end
                end
            end
            local spBg=CCSprite:createWithSpriteFrameName("proBar_n2.png")
            local spPr=CCSprite:createWithSpriteFrameName("proBar_n1.png")
            local spPr1=CCSprite:createWithSpriteFrameName("grayBarBtn.png")
            local slider=LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch)
            slider:setTouchPriority(-(layerNum-1)*20-5)
            slider:setIsSallow(true)
            slider:setMinimumValue(1)
            slider:setMaximumValue(maxNum)
            slider:setValue(1)
            slider:setPosition(ccp(self.bgSize.width/2,-height))
            slider:setTag(99)
            lnode:addChild(slider,2)
            if isBuy==true then
                numLb:setString(math.ceil(slider:getValue()))
            else
                numLb:setString(math.ceil(slider:getValue()).."/"..maxNum)
            end
            self.slider=slider

            local function touchHander()
            end
            local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("buyBarBg.png",CCRect(10,10,10,10),touchHander)
            bgSp:setContentSize(CCSizeMake(490,45))
            bgSp:setOpacity(0)
            bgSp:setPosition(self.bgSize.width/2,-height)
            lnode:addChild(bgSp,1)
            
            local function touchAdd()
                self.slider:setValue(self.slider:getValue()+1)
            end
            
            local function touchMinus()
                if self.slider:getValue()-1>0 then
                    self.slider:setValue(self.slider:getValue()-1)
                end
            end

            local addSp=CCSprite:createWithSpriteFrameName("greenPlus.png")
            addSp:setAnchorPoint(ccp(1,0.5))
            addSp:setPosition(ccp(bgSp:getContentSize().width-10,bgSp:getContentSize().height/2))
            bgSp:addChild(addSp,1)

            local rect=CCSizeMake(50,45)
            local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchAdd)
            addTouchBg:setTouchPriority(-(layerNum-1)*20-5)
            addTouchBg:setContentSize(rect)
            addTouchBg:setAnchorPoint(ccp(1,0.5))
            addTouchBg:setOpacity(0)
            addTouchBg:setPosition(ccp(bgSp:getContentSize().width,bgSp:getContentSize().height/2))
            bgSp:addChild(addTouchBg,1)
           
            local minusSp=CCSprite:createWithSpriteFrameName("greenMinus.png")
            minusSp:setAnchorPoint(ccp(0,0.5))
            minusSp:setPosition(ccp(10,bgSp:getContentSize().height/2))
            bgSp:addChild(minusSp,1)

            local minusTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchMinus)
            minusTouchBg:setTouchPriority(-(layerNum-1)*20-5)
            minusTouchBg:setContentSize(rect)
            minusTouchBg:setAnchorPoint(ccp(0,0.5))
            minusTouchBg:setOpacity(0)
            minusTouchBg:setPosition(ccp(0,bgSp:getContentSize().height/2))
            bgSp:addChild(minusTouchBg,1)

            height=height+slider:getContentSize().height

            local function confirmHandler(tag,object)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if callback then
                    local num=self.slider:getValue()
                    num=math.ceil(num)
                    if num and num>0 then
                        callback(num)
                    end
                end
                self:close()
            end
            local itemStr
            if isBuy==true then
                if btnStr and btnStr~="" then
                    itemStr=btnStr
                else
                    itemStr=getlocal("buy")
                end
            else
                itemStr=getlocal("use")
            end
            local confirmItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",confirmHandler,2,itemStr,34)
            confirmItem:setScale(0.8)
            confirmMenu=CCMenu:createWithItem(confirmItem)
            confirmMenu:setPosition(ccp(size.width/2+120,-height-confirmItem:getContentSize().height/2))
            confirmMenu:setTouchPriority(-(layerNum-1)*20-2)
            lnode:addChild(confirmMenu,1)

            height=height+confirmItem:getContentSize().height+30
        end
    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    self.bgLayer:setContentSize(CCSizeMake(size.width,height+50))
    lnode:setPosition(ccp(self.bgSize.width/2,height))
    lineSp1:setPositionY(self.bgLayer:getContentSize().height)
    lineSp2:setPositionY(lineSp2:getContentSize().height)

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn.png",close,nil,getlocal("cancel"),34)
    cancelItem:setScale(0.8)
    local cancelBtn=CCMenu:createWithItem(cancelItem)
    cancelBtn:setTouchPriority(-(layerNum-1)*20-4)
    if confirmMenu then
        cancelBtn:setPosition(ccp(self.bgSize.width/2-120,confirmMenu:getPositionY()))
        lnode:addChild(cancelBtn,1)
    else
        cancelBtn:setPosition(ccp(self.bgSize.width/2,80))
        self.bgLayer:addChild(cancelBtn,2)
    end
 
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))

    return self.dialogLayer
end

function useOrBuyPropSmallDialog:showBatchBuyProp(layerNum, callback, titleStr, onePrice, limitNum)
    local sd = useOrBuyPropSmallDialog:new()
    sd:initBatchBuyProp(layerNum, callback, titleStr, onePrice, limitNum)
end

function useOrBuyPropSmallDialog:initBatchBuyProp(layerNum, callback, titleStr, onePrice, limitNum)
    self.isTouch = nil
    self.isUseAmi = true

    local size = CCSizeMake(550, 330)
    local dialogBg,lineSp1,lineSp2=G_getNewDialogBg2(size,layerNum,function()end)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()end);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local titleLb = GetTTFLabelWrap(titleStr, 25, CCSizeMake(self.bgSize.width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    titleLb:setAnchorPoint(ccp(0.5, 1))
    titleLb:setColor(G_ColorGreen)
    titleLb:setPosition(self.bgSize.width / 2, self.bgSize.height - 25)
    self.bgLayer:addChild(titleLb)


    local priceFontSize = 20
    local lbPosY = titleLb:getPositionY() - titleLb:getContentSize().height - 50
    local numTipLb = GetTTFLabel(getlocal("amountStr") .. "：", priceFontSize)
    local numLb = GetTTFLabel("", 24)
    numTipLb:setAnchorPoint(ccp(0, 0.5))
    numLb:setAnchorPoint(ccp(0, 0.5))
    numLb:setColor(G_ColorGreen)
    numTipLb:setPosition(140, lbPosY)
    self.bgLayer:addChild(numTipLb)
    numLb:setPosition(numTipLb:getPositionX() + numTipLb:getContentSize().width, lbPosY)
    self.bgLayer:addChild(numLb)
    local priceTipLb = GetTTFLabel(getlocal("total_price") .. "：", priceFontSize)
    local priceSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    local priceLb = GetTTFLabel("", priceFontSize)
    priceTipLb:setAnchorPoint(ccp(0, 0.5))
    priceSp:setAnchorPoint(ccp(0, 0.5))
    priceLb:setAnchorPoint(ccp(0, 0.5))
    -- priceTipLb:setPosition(140, lbPosY)
    -- if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        priceTipLb:setPosition(self.bgSize.width - 260, lbPosY)
    -- end
    priceSp:setPosition(priceTipLb:getPositionX() + priceTipLb:getContentSize().width, lbPosY)
    priceLb:setPosition(priceSp:getPositionX() + priceSp:getContentSize().width, lbPosY)
    self.bgLayer:addChild(priceTipLb)
    self.bgLayer:addChild(priceSp)
    self.bgLayer:addChild(priceLb)

    local maxNum = math.floor(playerVoApi:getGems() / onePrice)
    if maxNum > limitNum then
        maxNum = limitNum
    end

    local function sliderTouch(handler, object)
        local count=math.ceil(object:getValue())
        if count>0 then
            numLb:setString(count)
            priceLb:setString(onePrice * count)
        end
    end
    local spBg=CCSprite:createWithSpriteFrameName("proBar_n2.png")
    local spPr=CCSprite:createWithSpriteFrameName("proBar_n1.png")
    local spPr1=CCSprite:createWithSpriteFrameName("grayBarBtn.png")
    local slider=LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch)
    slider:setTouchPriority(-(layerNum-1)*20-5)
    slider:setIsSallow(true)
    slider:setMinimumValue(1)
    slider:setMaximumValue(maxNum)
    slider:setValue(1)
    slider:setPosition(self.bgSize.width / 2, 150)
    self.bgLayer:addChild(slider)
    numLb:setString(math.ceil(slider:getValue()))
    priceLb:setString(onePrice * math.ceil(slider:getValue()))

    local function touchAdd()
        slider:setValue(slider:getValue() + 1)
    end
    
    local function touchMinus()
        if slider:getValue() - 1 > 0 then
            slider:setValue(slider:getValue() - 1)
        end
    end

    local addSp = CCSprite:createWithSpriteFrameName("greenPlus.png")
    addSp:setAnchorPoint(ccp(0, 0.5))
    addSp:setPosition(slider:getPositionX() + slider:getContentSize().width / 2 + 30, slider:getPositionY())
    self.bgLayer:addChild(addSp)

    local rect=CCSizeMake(50,45)
    local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchAdd)
    addTouchBg:setTouchPriority(-(layerNum-1)*20-5)
    addTouchBg:setContentSize(rect)
    addTouchBg:setAnchorPoint(ccp(0,0.5))
    addTouchBg:setOpacity(0)
    addTouchBg:setPosition(addSp:getPosition())
    self.bgLayer:addChild(addTouchBg)
   
    local minusSp = LuaCCSprite:createWithSpriteFrameName("greenMinus.png", touchMinus)
    minusSp:setAnchorPoint(ccp(1, 0.5))
    minusSp:setPosition(slider:getPositionX() - slider:getContentSize().width / 2 - 30, slider:getPositionY())
    minusSp:setTouchPriority(-(layerNum-1)*20-5)
    self.bgLayer:addChild(minusSp)

    local minusTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchMinus)
    minusTouchBg:setTouchPriority(-(layerNum-1)*20-5)
    minusTouchBg:setContentSize(rect)
    minusTouchBg:setAnchorPoint(ccp(1,0.5))
    minusTouchBg:setOpacity(0)
    minusTouchBg:setPosition(minusSp:getPosition())
    self.bgLayer:addChild(minusTouchBg)

    local function onClickHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
            if callback then
                local num = math.ceil(slider:getValue())
                if num and num > 0 then
                    callback(num)
                end
            end
            self:close()
        elseif tag == 11 then
            self:close()
        end
    end
    local btnScale, btnFontSize = 0.7, 24
    local sureBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickHandler, 10, getlocal("buy"), btnFontSize / btnScale)
    local cancelBtn = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", onClickHandler, 11, getlocal("cancel"), btnFontSize / btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(sureBtn)
    menuArr:addObject(cancelBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    self.bgLayer:addChild(btnMenu)
    sureBtn:setScale(btnScale)
    cancelBtn:setScale(btnScale)
    cancelBtn:setPosition(self.bgSize.width / 2 - 45 - cancelBtn:getContentSize().width * btnScale / 2, 25 + cancelBtn:getContentSize().height * btnScale / 2)
    sureBtn:setPosition(self.bgSize.width / 2 + 45 + sureBtn:getContentSize().width * btnScale / 2, 25 + sureBtn:getContentSize().height * btnScale / 2)

    self:show()
    sceneGame:addChild(self.dialogLayer,layerNum)
end

function useOrBuyPropSmallDialog:dispose()
    self = nil
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/acRadar_images.plist")
    spriteController:removeTexture("public/acRadar_images.png")
end