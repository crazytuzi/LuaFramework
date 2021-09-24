acKhzrSmallDialog=smallDialog:new()

function acKhzrSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acKhzrSmallDialog:showGiftBuy(layerNum,istouch,isuseami,callBack,giftId,shopInfo,parent)
	local sd=acKhzrSmallDialog:new()
    sd:initGiftBuy(layerNum,istouch,isuseami,callBack,giftId,shopInfo,parent)
    return sd
end

function acKhzrSmallDialog:initGiftBuy(layerNum,istouch,isuseami,pCallBack,giftId,shopInfo,parent)
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.giftId=giftId
    self.parent=parent
    self.shopInfo,parent=shopInfo
    local nameFontSize=30

    local ng,curStalls = acKhzrVoApi:getNgAndStalls()--后台给，curStalls：当前第几档

    -- base:removeFromNeedRefresh(self) --停止刷新
    base:addNeedRefresh(self)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        -- PlayEffect(audioCfg.mouseClick)
        -- if pCallBack then
        --     pCallBack()
        -- end
        -- self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dgSize
    local canBuyTimesTb = acKhzrVoApi:getCanBuyTimesTb( )
    local buyedTiems = canBuyTimesTb["i"..self.giftId] or 0
    local shopCfg=self.shopInfo["i" .. self.giftId]
    local curSpendGold = shopCfg.g[curStalls]
    local r=shopCfg.r
    -- r={p={{p4603=1,index=1},{p4204=1,index=4}}}
    local rewardItem=FormatItem(r,nil,true)
    local rewardNum=SizeOfTable(rewardItem)

    if rewardNum>4 then
        dgSize=CCSizeMake(600,580)
    else
        dgSize=CCSizeMake(600,460)
    end
    local function closeFunc()
        self:close()
    end
    local dialogBg=G_getNewDialogBg(dgSize,getlocal("packs_name_" .. self.giftId),30,nil,self.layerNum+1,true,closeFunc)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    self:show()

    local desH=dgSize.height-90
    local desLb1=GetTTFLabelWrap(getlocal("activity_openyear_allreward_des"),22,CCSizeMake(dgSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb1:setAnchorPoint(ccp(0,0.5))
    desLb1:setPosition(30,desH)
    dialogBg:addChild(desLb1)

    local upM_Line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
    upM_Line:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,upM_Line:getContentSize().height))
    upM_Line:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,desH-30))
    upM_Line:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(upM_Line,2)

    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(5,175))
    mLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,mLine:getContentSize().height))
    mLine:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(mLine)


    local rewardH=desH-90-30
    local startW
    local subW
    if rewardNum==1 then
        subW=0
        startW=dgSize.width/2
    elseif rewardNum==2 then
        subW=300
        startW=dgSize.width/2-subW/2       
    elseif rewardNum==3 then
        subW=200
        startW=dgSize.width/2-subW        
    else
        subW=130
        startW=dgSize.width/2-subW-subW/2
    end

    local flicker=shopCfg.flicker or {}

    for i=1,rewardNum do
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,rewardItem[i])
            return false
        end

        local icon,scale=G_getItemIcon(rewardItem[i],100,true,self.layerNum + 1,showNewPropInfo,nil,nil,nil,nil,nil,true)
        if i>4 then
            icon:setPosition(startW+(i-5)*subW,rewardH-120)
        else
            icon:setPosition(startW+(i-1)*subW,rewardH)
        end
        dialogBg:addChild(icon)
        icon:setTouchPriority(-(self.layerNum-1)*20-4)

        local numLb=GetTTFLabel("x"..FormatNumber(rewardItem[i].num),22)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(95,5))
        icon:addChild(numLb)
        if scale then
            numLb:setScale(1/scale)
        end

        local index=rewardItem[i].index
        if index and flicker[index] then
            local flickerIdxTb = {y=3,b=1,p=2,g=4}
            local colorType=flicker[index]
            G_addRectFlicker2(icon,1.15/scale,1.15/scale,flickerIdxTb[colorType],colorType)
        end
    end

    local oPrice=shopCfg.p
    local cPrice=curSpendGold

    local priceH=135

    local strSize2,strSize3 = 18,22
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2,strSize3 = 24,25
    end
    local oLb=GetTTFLabel(getlocal("activity_kzhd_original_price"),strSize2)
    dialogBg:addChild(oLb)
    oLb:setAnchorPoint(ccp(0,0.5))
    oLb:setPosition(60,priceH)

    local oPricelb=GetTTFLabel(oPrice,strSize2)
    oLb:addChild(oPricelb)
    oPricelb:setAnchorPoint(ccp(0,0.5))
    oPricelb:setPosition(oLb:getContentSize().width,oLb:getContentSize().height/2)

    local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
    iconGold:setAnchorPoint(ccp(0,0.5))
    iconGold:setPosition(oPricelb:getContentSize().width,oPricelb:getContentSize().height/2)
    oPricelb:addChild(iconGold)

    local lineWhite=CCSprite:createWithSpriteFrameName("white_line.png")
    lineWhite:setAnchorPoint(ccp(0,0.5))
    lineWhite:setColor(G_ColorRed)
    lineWhite:setScaleX((oPricelb:getContentSize().width+iconGold:getContentSize().width)/lineWhite:getContentSize().width)
    lineWhite:setPosition(0,oPricelb:getContentSize().height/2-3)
    oPricelb:addChild(lineWhite)

    
    local cLb=GetTTFLabel(getlocal("activity_kzhd_current_price"),strSize2)
    dialogBg:addChild(cLb)
    cLb:setAnchorPoint(ccp(0,0.5))
    cLb:setPosition(G_VisibleSizeWidth/2+60,priceH)
    cLb:setColor(G_ColorYellowPro)

    local cPriceStr=cPrice
    local strSize23 = 24
    if cPrice==0 then
        cPriceStr=getlocal("daily_lotto_tip_2")
        strSize23 = 18
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
            strSize23 = 24
        end
    end
    local cPricelb=GetTTFLabel(cPriceStr,strSize23)
    cLb:addChild(cPricelb)
    cPricelb:setAnchorPoint(ccp(0,0.5))
    cPricelb:setPosition(cLb:getContentSize().width,cLb:getContentSize().height*0.5)
    cPricelb:setColor(G_ColorYellowPro)

    local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
    iconGold:setAnchorPoint(ccp(0,0.5))
    iconGold:setPosition(cPricelb:getContentSize().width,cPricelb:getContentSize().height*0.5)
    cPricelb:addChild(iconGold)


        local function buyFunc()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local gems=playerVoApi:getGems() or 0
            if cPrice>gems then
                local function onSure()
                    self:close()
                    activityAndNoteDialog:closeAllDialog()
                end
                GemsNotEnoughDialog(nil,nil,cPrice-gems,self.layerNum+1,cPrice,onSure)
                return
            end

            local function refreshFunc()
                if self.giftId and self.giftId>=4 then
                    local paramTab={}
                    paramTab.functionStr=acKhzrVoApi:getActiveName()
                    paramTab.addStr="i_also_want"
                    local message={key="activity_kzhd_chatSystemMessage",param={playerVoApi:getPlayerName(),getlocal("activity_khzr_title"),getlocal("packs_name_" .. self.giftId)}}
                    chatVoApi:sendSystemMessage(message,paramTab)
                end
                playerVoApi:setGems(playerVoApi:getGems() - cPrice)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
                G_showRewardTip(rewardItem,true)

                for k,v in pairs(rewardItem) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end
                

                if self.parent and self.parent.refresh then
                    self.parent:refresh()
                end
                self:close()
            end
            local function sureClick()
                -- print("self.giftId=====>>>>>",self.giftId)
                if self.buyMenuItem then
                    self.buyMenuItem:setEnabled(false)
                end
                acKhzrVoApi:socketBuy(1,self.giftId,refreshFunc)
            end
            local function secondTipFunc(sbFlag)
                local keyName=acKhzrVoApi:getActiveName()
                local sValue=base.serverTime .. "_" .. sbFlag
                G_changePopFlag(keyName,sValue)
            end
            

            if cPrice and cPrice>0 then
                local keyName=acKhzrVoApi:getActiveName()

                if G_isPopBoard(keyName) then--
                    self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("packsBuyTip",{cPrice,getlocal("packs_name_" .. self.giftId)}),true,sureClick,secondTipFunc,nil,{strSize3})
                else
                    sureClick()
                end
            -- else
            --     sureClick()
            end
        end
        local scale=140/205
        local buyMenuItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",buyFunc,1,getlocal("buy"),24/scale)
        buyMenuItem:setScale(scale)
        self.buyMenuItem = buyMenuItem
        local buyBtn = CCMenu:createWithItem(buyMenuItem)
        dialogBg:addChild(buyBtn,1)
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        buyBtn:setBSwallowsTouches(true)
        buyBtn:setPosition(dialogBg:getContentSize().width/2,40)
        
        if shopCfg.t <= buyedTiems then
            buyMenuItem:setEnabled(false)
            buyBtn:setEnabled(false)
        end
        --activity_khzr_buyDesc
        local strSize4 = (G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="fr") and 16 or 20
        if curStalls < #ng then
            local SpendGold = acKhzrVoApi:getSelfSpendGold( )
            local stallsGold = ng[curStalls + 1]
            local needGold = stallsGold - SpendGold
            local giftName = getlocal("packs_name_" .. self.giftId)
            local curSpendGold = shopCfg.g[curStalls + 1]
            local discount= math.ceil((shopCfg.p - curSpendGold)/shopCfg.p*100)

            local lastBuyDesc = GetTTFLabel(getlocal("activity_khzr_buyDesc",{needGold,giftName,discount}),strSize4)
            lastBuyDesc:setPosition(ccp(dialogBg:getContentSize().width*0.5,90))
            lastBuyDesc:setColor(G_ColorRed)
            dialogBg:addChild(lastBuyDesc)

        else
            buyBtn:setPosition(dialogBg:getContentSize().width/2,60)
        end

    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end



function acKhzrSmallDialog:tick()
end


function acKhzrSmallDialog:dispose()
    self.giftId=nil
    self.parent=nil
    self.shopInfo,parent=nil

    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end

