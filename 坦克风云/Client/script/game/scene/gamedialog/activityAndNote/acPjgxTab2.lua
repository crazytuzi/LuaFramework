acPjgxTab2={

}

function acPjgxTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    nc.buyDialog=nil
    nc.showPropDialog=nil

    return nc;
end

function acPjgxTab2:init(layerNum,parent)
    self.activeName=acPjgxVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initUp()
    self:initBottom()
    -- self:initTableView()
    return self.bgLayer
end

function acPjgxTab2:initUp()
    local startH=self.bgLayer:getContentSize().height-185
    local titleLb=GetTTFLabel(getlocal("activity_pjgx_special_bag"),28)
    -- titleLb:setColor(G_ColorYellowPro)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(G_VisibleSizeWidth/2,startH))
    self.bgLayer:addChild(titleLb,1)

    local cfg=acPjgxVoApi:getActiveCfg()
    local buyLimit=cfg.gift.buyLimit
    local boxReward=cfg.gift.boxReward

    local function nilFunc()
    end
    local  titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),nilFunc)
    self.bgLayer:addChild(titleBg1)
    titleBg1:setPosition(G_VisibleSizeWidth/2,startH)
    titleBg1:setContentSize(CCSizeMake(titleLb:getContentSize().width+150,math.max(titleLb:getContentSize().height,50)))

    local buyItemSizeH=370
    if(G_isIphone5())then
        buyItemSizeH=450
    end

    local butItemBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
    butItemBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,buyItemSizeH))
    butItemBg:setPosition(ccp(G_VisibleSizeWidth/2,startH-titleBg1:getContentSize().height/2))
    butItemBg:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(butItemBg)
    self.butItemBg=butItemBg

    local bn=acPjgxVoApi:getBn()
    local buyNumLb=GetTTFLabel(getlocal("activity_pjgx_buyNum",{bn .. "/" .. buyLimit}),25)
    butItemBg:addChild(buyNumLb)
    buyNumLb:setPosition(butItemBg:getContentSize().width/2,butItemBg:getContentSize().height-30)
    self.buyNumLb=buyNumLb
    if bn>=buyLimit then
        buyNumLb:setColor(G_ColorRed)
    else
        buyNumLb:setColor(G_ColorYellowPro)
    end
    

    local buyStartH=butItemBg:getContentSize().height-60
    local sbH=(buyItemSizeH-90)/2
    local posX1=butItemBg:getContentSize().width/4
    local posX2=butItemBg:getContentSize().width/4*3
    local posY1=buyStartH
    local posY2=buyStartH-sbH-10
    local buyTb={ccp(posX1,posY1),ccp(posX2,posY1),ccp(posX1,posY2),ccp(posX2,posY2)}

    
    for k,v in pairs(buyTb) do
        local sbBg =LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
        sbBg:setContentSize(CCSizeMake(
        butItemBg:getContentSize().width/2-40,sbH))
        sbBg:ignoreAnchorPointForPosition(false)
        sbBg:setAnchorPoint(ccp(0.5,1))
        sbBg:setPosition(v)
        butItemBg:addChild(sbBg)

        local sbSize=sbBg:getContentSize()

        local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp1:setPosition(ccp(5,sbBg:getContentSize().height/2))
        sbBg:addChild(pointSp1)
        local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp2:setPosition(ccp(sbBg:getContentSize().width-5,sbBg:getContentSize().height/2))
        sbBg:addChild(pointSp2)

        local propItem=FormatItem(boxReward[k][3])[1]
        local count=boxReward[k][2]
        local disCount=math.floor(boxReward[k][2]*boxReward[k][1])

        local function onClickGift()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local pid="p"..propItem.id
            local bn=acPjgxVoApi:getBn()

            local function touch1()
                self.showPropDialog=nil
                if bn>=buyLimit then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tankbattle_attackLimit"),30)
                    return
                end
                local gems=playerVoApi:getGems() or 0
                if disCount>gems then
                    local function onSure()
                        activityAndNoteDialog:closeAllDialog()
                    end
                    GemsNotEnoughDialog(nil,nil,disCount-gems,self.layerNum+1,disCount,onSure)
                    return
                end

                local function refreshFunc(num)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{propItem.name}),30)
                    playerVoApi:setGems(playerVoApi:getGems() - disCount*num)
                    local sbReward = G_rewardFromPropCfg(pid)
                    for k,v in pairs(sbReward) do
                        v.num=v.num*num
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                    G_showRewardTip(sbReward,true)
                    self:refresh()
                end
                

                local function touchBuy(num)
                    local action=3
                    local tid=k
                    self.buyDialog=nil
                    acPjgxVoApi:socketPjgx2017(refreshFunc,action,tid,nil,num)
                end
                local limiNum=buyLimit-bn
                local truePrice=disCount
                self.buyDialog=shopVoApi:showBatchBuyPropSmallDialog(pid,self.layerNum+1,touchBuy,nil,limiNum,truePrice)

            end

            local btnTb={}
            -- if bn>=buyLimit then
            -- else
                table.insert(btnTb,{name=getlocal("buy"),tag=propItem.id,callback=touch1})
            -- end
            
            
            local sbReward = G_rewardFromPropCfg(pid)
            local desStr
            local random = propCfg[pid].isRandom
            -- if random and random==1 then
                desStr=getlocal("database_des4")
            -- else
            --     desStr=getlocal("database_des2")
            -- end
            -- if propCfg[pid].useGetOne then
            --     desStr=getlocal("database_des3")
            -- end
            local titleStr=getlocal(propCfg[pid].name)

            self.showPropDialog=bagVoApi:showPropDisplaySmallDialog(self.layerNum+1,sbReward,titleStr,desStr,btnTb,CCSizeMake(550,550))
            -- shopVoApi:showBatchBuyPropSmallDialog(pid,self.layerNum+1,touchBuy)

        end
        local giftSp=LuaCCSprite:createWithSpriteFrameName(propItem.pic,onClickGift)
        giftSp:setTouchPriority(-(self.layerNum-1)*20-3)
        giftSp:setAnchorPoint(ccp(0,0.5))
        sbBg:addChild(giftSp)
        giftSp:setPosition(10,sbBg:getContentSize().height/2)

        
        local function onConfirmSell()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            
            local bn=acPjgxVoApi:getBn()
            if bn>=buyLimit then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tankbattle_attackLimit"),30)
                return
            end
            local gems=playerVoApi:getGems() or 0
            if disCount>gems then
                local function onSure()
                    activityAndNoteDialog:closeAllDialog()
                end
                GemsNotEnoughDialog(nil,nil,disCount-gems,self.layerNum+1,disCount,onSure)
                return
            end

            local pid="p"..propItem.id

            local function refreshFunc(num)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{propItem.name}),30)
                playerVoApi:setGems(playerVoApi:getGems() - disCount*num)
                local sbReward = G_rewardFromPropCfg(pid)
                for k,v in pairs(sbReward) do
                    v.num=v.num*num
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end
                G_showRewardTip(sbReward,true)
                self:refresh()
            end
            

            local function touchBuy(num)
                local action=3
                local tid=k
                self.buyDialog=nil
                acPjgxVoApi:socketPjgx2017(refreshFunc,action,tid,nil,num)
            end
            local limiNum=buyLimit-bn
            local truePrice=disCount
            self.buyDialog=shopVoApi:showBatchBuyPropSmallDialog(pid,self.layerNum+1,touchBuy,nil,limiNum,truePrice)

        end
        local buyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onConfirmSell,nil,getlocal("buy"),25,11)
        buyItem:setScale(0.6)
        local lb=tolua.cast(buyItem:getChildByTag(11),"CCLabelTTF")
        lb:setScale(1/0.6)
        local buyBtn=CCMenu:createWithItem(buyItem)
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-3)
        buyBtn:setAnchorPoint(ccp(1,0.5))
        buyBtn:setPosition(ccp(sbSize.width-70,sbSize.height/2-30))
        sbBg:addChild(buyBtn)

        local countTb={{count,sbSize.height/2+40},{disCount,sbSize.height/2+10}}
        for k,v in pairs(countTb) do
            local countLb=GetTTFLabel(v[1],25)
            countLb:setPositionY(v[2])
            sbBg:addChild(countLb)

            if k==2 then
                countLb:setColor(G_ColorYellowPro)
            end

            local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
            goldIcon:setPositionY(v[2])
            sbBg:addChild(goldIcon)


            G_setchildPosX(sbBg,countLb,goldIcon)
            countLb:setPositionX(countLb:getPositionX()+sbSize.width-70-sbSize.width/2)
            goldIcon:setPositionX(countLb:getPositionX()+sbSize.width-70-sbSize.width/2)

            if k==1 then
                local line = CCSprite:createWithSpriteFrameName("redline.jpg")
                line:setScaleX((countLb:getContentSize().width + goldIcon:getContentSize().width  + 10) / line:getContentSize().width)
                --line:setAnchorPoint(ccp(0, 0))
                line:setPosition(sbSize.width-70,v[2])
                sbBg:addChild(line)
            end
        end



        local clipper=CCClippingNode:create()
        -- clipper:setAnchorPoint(ccp(0.5,1))
        -- clipper:setContentSize(sbSize)
        clipper:setPosition(v.x-sbSize.width/2,v.y-sbSize.height)
        butItemBg:addChild(clipper,1)
        -- clipper:setInverted(true)

        local stencil=CCDrawNode:getAPolygon(CCSizeMake(sbSize.width,sbSize.height),1,1)
        clipper:setStencil(stencil)

        local redTiltBg = CCSprite:createWithSpriteFrameName("redTiltBg.png")
        -- icon:addChild(redTiltBg)
        redTiltBg:setPosition(35,sbSize.height-20)
        redTiltBg:setRotation(-15)
        redTiltBg:setScale(0.8)
        clipper:addChild(redTiltBg)

        local disLb=GetTTFLabel(-(100-boxReward[k][1]*100) .. "%",22)
        redTiltBg:addChild(disLb)
        disLb:setScale(1/0.8)
        disLb:setPosition(redTiltBg:getContentSize().width/2-5,redTiltBg:getContentSize().height/2)
        disLb:setRotation(-30)
    end

end

function acPjgxTab2:initBottom()
    local startH=self.bgLayer:getContentSize().height-185-15
    local bottomSH=startH-self.butItemBg:getContentSize().height-40

    local titleLb=GetTTFLabel(getlocal("activity_pjgx_accessory_welfare"),28)
    -- titleLb:setColor(G_ColorYellowPro)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(G_VisibleSizeWidth/2,bottomSH))
    self.bgLayer:addChild(titleLb,1)

    local function nilFunc()
    end
    local  titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),nilFunc)
    self.bgLayer:addChild(titleBg1)
    titleBg1:setPosition(G_VisibleSizeWidth/2,bottomSH)
    titleBg1:setContentSize(CCSizeMake(titleLb:getContentSize().width+150,math.max(titleLb:getContentSize().height,50)))

    bottomSH=bottomSH-20
    local rewardBgH=150
    if(G_isIphone5())then
        rewardBgH=190
    end
    local rewardBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("titlesDesBg.png",CCRect(50, 20, 1, 1),nilFunc)
    rewardBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, rewardBgH))
    rewardBg1:setAnchorPoint(ccp(0.5,1))
    rewardBg1:setPosition(ccp(G_VisibleSizeWidth/2, bottomSH))
    self.bgLayer:addChild(rewardBg1)

    -- accessory_stronger
    local rewardDes1Lb = GetTTFLabel(getlocal("accessory_stronger"),26)
    rewardDes1Lb:setAnchorPoint(ccp(0,1))
    rewardDes1Lb:setPosition(ccp(10,rewardBg1:getContentSize().height-8))
    rewardBg1:addChild(rewardDes1Lb,1)
    rewardDes1Lb:setColor(G_ColorYellowPro)

    local strSize4 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize4 = 25
    end

    local desBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("titlesBG.png",CCRect(35, 0, 1, 33),nilFunc)
    desBg1:setContentSize(CCSizeMake(rewardDes1Lb:getContentSize().width+35,rewardDes1Lb:getContentSize().height+8))
    desBg1:setAnchorPoint(ccp(0,1))
    desBg1:setPosition(ccp(8,rewardBg1:getContentSize().height-5))
    rewardBg1:addChild(desBg1)

    local function onConfirmSell()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        G_goToDialog2("ge",4,true)
    end
    local goItem1=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onConfirmSell,nil,getlocal("activity_heartOfIron_goto"),25,11)
    -- goItem1:setScale(0.6)
    -- local lb=tolua.cast(goItem1:getChildByTag(11),"CCLabelTTF")
    -- lb:setScale(1/0.6)
    local goBtn1=CCMenu:createWithItem(goItem1)
    goBtn1:setTouchPriority(-(self.layerNum-1)*20-3)
    goBtn1:setAnchorPoint(ccp(1,0.5))
    goBtn1:setPosition(ccp(rewardBg1:getContentSize().width-120,rewardBg1:getContentSize().height/2))
    rewardBg1:addChild(goBtn1)

    local cfg=acPjgxVoApi:getActiveCfg()
    local value1=cfg.value1
    local returnDes1=GetTTFLabelWrap(getlocal("activity_pjgx_returnDes1",{value1*100 .. "%%"}),strSize4,CCSizeMake(rewardBg1:getContentSize().width-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rewardBg1:addChild(returnDes1)
    returnDes1:setAnchorPoint(ccp(0,0.5))
    returnDes1:setPosition(25,rewardBg1:getContentSize().height/2-15)

    local subH=0
    if(G_isIphone5())then
        subH=15
    end

    local rewardBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("titlesDesBg.png",CCRect(50, 20, 1, 1),nilFunc)
    rewardBg2:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, rewardBgH))
    rewardBg2:setAnchorPoint(ccp(0.5,1))
    rewardBg2:setPosition(ccp(G_VisibleSizeWidth/2, bottomSH-rewardBg1:getContentSize().height-subH))
    self.bgLayer:addChild(rewardBg2)

    local rewardDes2Lb = GetTTFLabel(getlocal("accessory_change"),26)
    rewardDes2Lb:setAnchorPoint(ccp(0,1))
    rewardDes2Lb:setPosition(ccp(10,rewardBg2:getContentSize().height-8))
    rewardBg2:addChild(rewardDes2Lb,1)
    rewardDes2Lb:setColor(G_ColorYellowPro)

    local desBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("titlesBG.png",CCRect(35, 0, 1, 33),nilFunc)
    desBg2:setContentSize(CCSizeMake(rewardDes2Lb:getContentSize().width+35,rewardDes2Lb:getContentSize().height+8))
    desBg2:setAnchorPoint(ccp(0,1))
    desBg2:setPosition(ccp(8,rewardBg2:getContentSize().height-5))
    rewardBg2:addChild(desBg2)

    local function onConfirmSell()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        G_goToDialog2("ge",4,true)
    end
    local goItem2=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onConfirmSell,nil,getlocal("activity_heartOfIron_goto"),25,11)
    -- goItem2:setScale(0.6)
    -- local lb=tolua.cast(goItem2:getChildByTag(11),"CCLabelTTF")
    -- lb:setScale(1/0.6)
    local goBtn2=CCMenu:createWithItem(goItem2)
    goBtn2:setTouchPriority(-(self.layerNum-1)*20-3)
    goBtn2:setAnchorPoint(ccp(1,0.5))
    goBtn2:setPosition(ccp(rewardBg2:getContentSize().width-120,rewardBg2:getContentSize().height/2))
    rewardBg2:addChild(goBtn2)

    local value2=cfg.value2
    local returnDes2=GetTTFLabelWrap(getlocal("activity_pjgx_returnDes2",{value2[1]*100 .. "%%",value2[2]*100 .. "%%"}),strSize4,CCSizeMake(rewardBg2:getContentSize().width-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rewardBg2:addChild(returnDes2)
    returnDes2:setAnchorPoint(ccp(0,0.5))
    returnDes2:setPosition(25,rewardBg2:getContentSize().height/2-15)

end

function acPjgxTab2:refresh()
    local bn=acPjgxVoApi:getBn()
    local cfg=acPjgxVoApi:getActiveCfg()
    local buyLimit=cfg.gift.buyLimit

    self.buyNumLb:setString(getlocal("activity_pjgx_buyNum",{bn .. "/" .. buyLimit}))
    if bn>=buyLimit then
        self.buyNumLb:setColor(G_ColorRed)
    else
        self.buyNumLb:setColor(G_ColorYellowPro)
    end
end

function acPjgxTab2:dispose()
    if self.buyDialog and self.buyDialog.close then
        self.buyDialog:close()
    end
    if self.showPropDialog and self.showPropDialog.close then
        self.showPropDialog:close()
    end
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
end
