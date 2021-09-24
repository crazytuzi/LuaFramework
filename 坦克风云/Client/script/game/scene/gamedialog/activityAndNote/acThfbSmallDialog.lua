-- @Author hj
-- @Description 特惠风暴活动小板子
-- @Date 2018-05-16

acThfbSmallDialog=smallDialog:new()

function acThfbSmallDialog:new()
    local nc={
        totalNum = 0,
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end

-- id 为礼包id
function acThfbSmallDialog:showBuyDialog(size,titleStr,titleSize,titleColor,layerNum,id,partentTv)
    local sd = acThfbSmallDialog:new()
    sd:initBuyDialog(size,titleStr,titleSize,titleColor,layerNum,id,partentTv)
end

function acThfbSmallDialog:initBuyDialog(size,titleStr,titleSize,titleColor,layerNum,id,partentTv)
    
    self.partentTv = partentTv
    self.isUseAmi = false
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0)) 

    local sale,saleRate = acThfbVoApi:getGiftDis(id)
        
    local hasSale
    if sale == 10 then
        hasSale = false
    else
        hasSale = true
    end

    local function closeCallBack( ... )
        self:close()
    end

    --采用新式小板子
    local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,titleColor)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local function giftHandeler()
    end

    local giftSpire = LuaCCSprite:createWithSpriteFrameName(acThfbVoApi:getBagIcon(id),giftHandeler)
    giftSpire:setAnchorPoint(ccp(0,1))
    giftSpire:setPosition(ccp(40,self.bgLayer:getContentSize().height-66-30))
    giftSpire:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:addChild(giftSpire,2)

    local saleSpire = CCSprite:createWithSpriteFrameName("saleRedBg.png")
    saleSpire:setRotation(20)
    saleSpire:setScale(0.8)
    saleSpire:setPosition(ccp(70,70))
    giftSpire:addChild(saleSpire)

    if hasSale == true then
        local saleLabel = GetTTFLabel("-"..tostring((1-saleRate)*100).."%",20)
        saleLabel:setPosition(saleSpire:getContentSize().width/2,saleSpire:getContentSize().height/2)
        saleSpire:addChild(saleLabel)
    else
        saleSpire:setVisible(false)
    end
   
    local strSize = 25
    if G_isAsia() == false then
        strSize = 20
    end
    local titleStr,descStr = acThfbVoApi:getGiftBagDesc(id)

    local bagDescLb = GetTTFLabelWrap(titleStr,strSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    bagDescLb:setAnchorPoint(ccp(0,1))
    bagDescLb:setColor(G_ColorYellowPro)
    bagDescLb:setPosition(ccp(giftSpire:getPositionX()+giftSpire:getContentSize().width+20,giftSpire:getPositionY()))
    self.bgLayer:addChild(bagDescLb)

    if acThfbVoApi:judgeLimit(id) == true then
        bagDescLb:setColor(G_ColorRed)
    else
        bagDescLb:setColor(G_ColorYellowPro)
    end

    local descLabel = GetTTFLabelWrap(descStr,20,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLabel:setAnchorPoint(ccp(0,1))
    descLabel:setPosition(ccp(bagDescLb:getPositionX(),giftSpire:getPositionY()- 60))
    self.bgLayer:addChild(descLabel)

    local strSize1 = 20
    if G_isAsia() == false then
        strSize1 = 18
    end

    -- 获取礼券的提示
    local tipLabel 
    if hasSale == false then
        tipLabel = GetTTFLabelWrap(acThfbVoApi:getTaskDesc(id),strSize1,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    else
        tipLabel = GetTTFLabelWrap(getlocal("activity_thfb_dis_limit"),strSize1,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    end
    tipLabel:setAnchorPoint(ccp(0.5,0.5))
    tipLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    tipLabel:setColor(G_ColorRed)
    self.bgLayer:addChild(tipLabel)
    
    local function nilfunc( ... )
    end
    -- 分割线
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(26,0,2,6),nilfunc)
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70,lineSp:getContentSize().height))
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40))
    self.bgLayer:addChild(lineSp)

    -- 数量
    local orginNumLb = GetTTFLabel(getlocal("amountStr"),22)
    orginNumLb:setAnchorPoint(ccp(1,0.5))
    orginNumLb:setPosition(self.bgLayer:getContentSize().width/4,180)
    self.bgLayer:addChild(orginNumLb)

    local m_numLb=GetTTFLabel("",22)
    m_numLb:setAnchorPoint(ccp(0,0.5))
    m_numLb:setPosition(self.bgLayer:getContentSize().width/4+15,180)
    m_numLb:setColor(G_ColorGreen)
    self.bgLayer:addChild(m_numLb)

    local maxNum= acThfbVoApi:getBuyLimit(id)-acThfbVoApi:getBuyCount(id)
    local actualCost = math.floor(acThfbVoApi:getBuyCost(id)*saleRate)
    local canBuyNum 

    if math.floor(playerVoApi:getGems()/actualCost)>=maxNum then
        canBuyNum = maxNum
    elseif math.floor(playerVoApi:getGems()/actualCost) == 0 then
        canBuyNum = 1
    else
        canBuyNum = math.floor(playerVoApi:getGems()/actualCost)
    end


    local allGoldLabel = GetTTFLabel(getlocal("total_price"),22)
    allGoldLabel:setAnchorPoint(ccp(1,0.5))
    allGoldLabel:setPosition(ccp(self.bgLayer:getContentSize().width/4*3-40,180))
    self.bgLayer:addChild(allGoldLabel)

    -- 总花费
    local goldBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilfunc)
    self.bgLayer:addChild(goldBg)
    goldBg:setContentSize(CCSizeMake(150,30))
    goldBg:setPosition(ccp(self.bgLayer:getContentSize().width/4*3,180))
    goldBg:setOpacity(0)

    local goldSpire = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSpire:setAnchorPoint(ccp(1,0.5))
    goldSpire:setPosition(ccp(75,15))
    goldBg:addChild(goldSpire)

    local goldLabel = GetTTFLabel("",22,true)
    goldLabel:setAnchorPoint(ccp(0,0.5))
    goldLabel:setPosition(ccp(75,15))
    goldBg:addChild(goldLabel)


    local function sliderTouch(handler,object)
        local count = math.floor(object:getValue())
        m_numLb:setString(count)
        goldLabel:setString(actualCost*count)
        self.totalNum = count
        if playerVoApi:getGems() < actualCost*count then
            goldLabel:setColor(G_ColorRed)
        else
            goldLabel:setColor(G_ColorYellowPro)
        end
    end

    local spBg=CCSprite:createWithSpriteFrameName("proBar_n2.png")
    local spPr=CCSprite:createWithSpriteFrameName("proBar_n1.png")
    local spPr1=CCSprite:createWithSpriteFrameName("grayBarBtn.png")
    local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch)
    slider:setTouchPriority(-(layerNum-1)*20-2)
    slider:setIsSallow(true)
    
    if maxNum > 0 then
        slider:setMinimumValue(1.0)
    else
        slider:setMinimumValue(0.0)
    end
    
    slider:setMaximumValue(maxNum)
    slider:setValue(canBuyNum)
    slider:setPosition(ccp(self.bgLayer:getContentSize().width/2,130))
    slider:setTag(99)
    self.bgLayer:addChild(slider,2)
    slider:setScaleX(0.8)
    self.slider = slider
    m_numLb:setString(math.floor(slider:getValue()))
    goldLabel:setString(actualCost*math.floor(slider:getValue()))
    
    if playerVoApi:getGems() < actualCost*math.floor(slider:getValue()) then
        goldLabel:setColor(G_ColorRed)
    else
        goldLabel:setColor(G_ColorYellowPro)
    end

    self.totalNum = math.floor(slider:getValue())

    local function touchAdd()
        slider:setValue(slider:getValue()+1);
    end

    local function touchMinus()
        if slider:getValue()-1>0 then
            slider:setValue(slider:getValue()-1);
        end
    end

    local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
    addSp:setPosition(ccp(self.bgLayer:getContentSize().width/2+self.slider:getContentSize().width/2+10,130))
    self.bgLayer:addChild(addSp,1)
    addSp:setTouchPriority(-(layerNum-1)*20-3)

    local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
    minusSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-self.slider:getContentSize().width/2-10,130))
    self.bgLayer:addChild(minusSp,1)
    minusSp:setTouchPriority(-(layerNum-1)*20-3)

    local function touchHander()
    end
    local bgSp1=LuaCCScale9Sprite:createWithSpriteFrameName("buyBarBg.png",CCRect(10,10,10,10),touchHander)
    bgSp1:setContentSize(CCSizeMake(self.slider:getContentSize().width+100,45))
    bgSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,130))
    self.bgLayer:addChild(bgSp1)


    local function buyCallback( ... )
        if acThfbVoApi:getBuyCount(id) < acThfbVoApi:getBuyLimit(id) then
            if playerVoApi:getGems() < self.totalNum * math.floor(acThfbVoApi:getBuyCost(id)*saleRate) then
                GemsNotEnoughDialog(nil,nil,self.totalNum * math.floor(acThfbVoApi:getBuyCost(id)*saleRate)-playerVoApi:getGems(),layerNum+1,self.totalNum * math.floor(acThfbVoApi:getBuyCost(id)*saleRate))
            else
                local function confirmHandler( ... )
                    self:close()
                    local function callback(fn,data)
                        local ret,sData = base:checkServerData(data)
                        if ret==true then
                            if sData.data and sData.data.thfb then
                                acThfbVoApi:updateSpecialData(sData.data.thfb)
                                playerVoApi:setGems(playerVoApi:getGems()- self.totalNum*math.floor(acThfbVoApi:getBuyCost(id)*saleRate))
                                if self.partentTv then
                                    local recordPoint=self.partentTv:getRecordPoint()
                                    self.partentTv:reloadData()
                                    self.partentTv:recoverToRecordPoint(recordPoint)
                                end
                            end
                            if sData.data and sData.data.report then

                                local rewardTb = FormatItem(sData.data.report,nil,true)
                                for k,v in pairs(rewardTb) do
                                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                end
                                local function showEndHandler( ... )
                                    G_showRewardTip(rewardTb,true)
                                end 
                                local titleStr=getlocal("activity_wheelFortune4_reward")
                                require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                                rewardShowSmallDialog:showNewReward(layerNum+1,true,true,rewardTb,showEndHandler,titleStr,nil,nil,nil,"smbd")
                                
                                if id == 8 then
                                    local paramTab = {}
                                    paramTab.functionStr="thfb"
                                    paramTab.addStr="goTo_see_see"
                                    paramTab.colorStr="w,y,w"
                                    local playerName = playerVoApi:getPlayerName()
                                    local message = {}
                                    if acThfbVoApi:getVersion()==1 then
                                        message = {key="activity_thfb_sysMessage",param={playerName}}
                                    else
                                        local nameStr = acThfbVoApi:getThfbAcNameStr()
                                        local giftNameStr = acThfbVoApi:getBagNameStr(id)
                                        message = {key="activity_thfb_v2_sysMessage",param={playerName,nameStr,giftNameStr}}
                                    end
                                    chatVoApi:sendSystemMessage(message,paramTab) 
                                end
                            end 
                        end
                    end
                    local actualId  
                    if id == 7 then
                        actualId = 8
                    elseif id == 8 then
                        actualId = 7
                    else
                        actualId = id
                    end                            
                    socketHelper:acThfbGetReward(actualId,self.totalNum,callback)
                end
                local function secondTipFunc(sbFlag)
                    local keyName = "thfb"
                    local sValue=base.serverTime .. "_" .. sbFlag
                    G_changePopFlag(keyName,sValue)
                end
                local keyName = "thfb"
                if G_isPopBoard(keyName) then
                   G_showSecondConfirm(layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{self.totalNum * math.floor(acThfbVoApi:getBuyCost(id)*saleRate)}),true,confirmHandler,secondTipFunc)
                else
                    confirmHandler()
                end
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_thfb_buy_limit"),30)
        end
    end 


    local buyButton 
    if acThfbVoApi:getBuyCount(id) < acThfbVoApi:getBuyLimit(id) then
        buyButton = G_createBotton(self.bgLayer,ccp(self.bgLayer:getContentSize().width/2,60),{getlocal("activity_thfb_small_buy"),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",buyCallback,0.8,-(layerNum-1)*20-2)
    else
        buyButton = G_createBotton(self.bgLayer,ccp(self.bgLayer:getContentSize().width/2,60),{getlocal("hasBuy"),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",buyCallback,0.8,-(layerNum-1)*20-2)
        buyButton:setEnabled(false)
    end

    --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

end
