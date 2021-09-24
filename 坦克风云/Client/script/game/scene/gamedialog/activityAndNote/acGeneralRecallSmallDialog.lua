acGeneralRecallSmallDialog=smallDialog:new()

function acGeneralRecallSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.cellHight=120
    self.whiTypeDia =0
    self.choosePage = 0
    self.allSubTabs ={}
    self.selectedSubTabIndex =0
    self.showGiftBgTb={nil,nil,nil}
    self.upRect =nil
    self.chooseSid =0
    self.slider ={}
    self.cellNum=0
    self.cellWidth=0
    self.cellHightTb=nil
    self.sellTitleTb={}
    self.sellIconTb ={}
    self.sellNumTb ={}
    self.sliderNumTb={}
    self.checkBtn=nil
    self.checkPosTb={}
    self.pageData =nil
    self.confirmCallback =nil
    self.costPropSize=70
    self.sendLb=nil
    self.selectPropIcon=nil
    self.nameLb=nil
    self.touchItem=nil
    spriteController:addPlist("public/acNewYearsEva.plist")--acDouble11New_addImage
    spriteController:addTexture("public/acNewYearsEva.png")
    return nc
end

-- isXiushi:是否有顶部的修饰
function acGeneralRecallSmallDialog:init(dialogType,confirmCallback,cancleCallBack,layerNum,titleStr,btnStr,bgSrc,dialogSize,bgRect,needData)
    local strHeight2 = 25
    local strSize2 =21
    self.confirmCallback = confirmCallback
    local titleStr2 = 25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strHeight2 =30
        strSize2 =24
        titleStr2 =33
    end
    self.whiTypeDia =dialogType
    self.layerNum=layerNum
    self.needData=needData or {}

    self.dialogWidth=550
    self.dialogHeight=750
    if bgSrc==nil then
        bgSrc="TankInforPanel.png"
    end
    if dialogSize==nil then
        dialogSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
    end
    if bgRect==nil then
        bgRect=CCRect(130, 50, 1, 1)
    end
    local function nilFunc()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,bgRect,nilFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=dialogSize
    self.bgLayer:setContentSize(self.bgSize)
    -- self:show()
    self.dialogLayer:addChild(self.bgLayer,1)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    self:initTitleBg(strHeight2)

    

    -- title
    local titleLb=GetTTFLabelWrap(titleStr,titleStr2,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,1))
    titleLb:setColor(G_ColorYellowPro)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-strHeight2))
    self.bgLayer:addChild(titleLb,1)

    local descBgHeightScaleY = {0.25,0.8,0.5,0.6}
    local descBgPosY={0.8,0.83,0.8,0.83}
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
    self.upRect = CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height*descBgHeightScaleY[self.whiTypeDia])
    descBg:setContentSize(self.upRect)
    descBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*descBgPosY[self.whiTypeDia]))
    descBg:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(descBg)


    local tvWidth,tvHeight,tvPos,zorder
    if self.whiTypeDia ==1 then
        self:initChooseGiftTab(descBg:getPositionY())
        self:resetTab()
    elseif self.whiTypeDia==4 or self.whiTypeDia==2 then --4:绑定战友记录 2:选择战友板子
        if self.whiTypeDia==4 then
            spriteController:addPlist("public/vipFinal.plist")--newTipImage
            spriteController:addTexture("public/vipFinal.png")
        end
        tvWidth=descBg:getContentSize().width-20
        self.cellWidth=tvWidth
        tvHeight=descBg:getContentSize().height-20
        tvPos=ccp(20,self.bgSize.height-140-tvHeight)
        zorder=0
        local titleH=38
        local rect=CCRect(0,0,50,50)
        local capInSet=CCRect(60,20,1,1)
        local function touch(hd,fn,idx)
        end
        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",capInSet,touch)
        titleBg:setContentSize(CCSizeMake(tvWidth,titleH))
        titleBg:ignoreAnchorPointForPosition(false)
        titleBg:setAnchorPoint(ccp(0.5,0))
        titleBg:setIsSallow(false)
        titleBg:setTouchPriority(-(self.layerNum-1)*20-2)
        titleBg:setPosition(ccp(self.bgSize.width/2,tvPos.y+tvHeight+10))
        self.bgLayer:addChild(titleBg,zorder+1)

        local w=(self.bgSize.width-80)/3
        local function getX(index)
            -- return 20+w*index+w/2-35
            return -5+w*index+w/2
        end
        local lbSize=22
        local color=G_ColorGreen
        local nameLb=GetTTFLabel(getlocal("alliance_scene_button_info_name"),lbSize)
        nameLb:setPosition(getX(0),titleBg:getContentSize().height/2)
        nameLb:setColor(color)
        titleBg:addChild(nameLb,1)
      
        local vipLb=GetTTFLabel(getlocal("vipLevelStr"),lbSize)
        vipLb:setPosition(getX(1),titleBg:getContentSize().height/2)
        vipLb:setColor(color)
        titleBg:addChild(vipLb,1)
        

        local valueStr=""
        if self.whiTypeDia==2 then
            valueStr=getlocal("state")
            if self.needData then
                bindCount=SizeOfTable(self.needData)
            end
            if bindCount==0 then
                local noBindLb=GetTTFLabelWrap(getlocal("noBindFriendStr"),28,CCSizeMake(self.bgSize.width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                noBindLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2+30))
                noBindLb:setColor(G_ColorGray)
                self.bgLayer:addChild(noBindLb)
            end
        elseif self.whiTypeDia==4 then
            valueStr=getlocal("vipLevelUpStr")
            local bindCount=0
            if self.needData then
                bindCount=SizeOfTable(self.needData)
            end
            local bindCountStr=GetTTFLabelWrap(getlocal("bindFriendNumStr",{bindCount}),25,CCSizeMake(self.bgSize.width*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
            bindCountStr:setAnchorPoint(ccp(0,1))
            bindCountStr:setPosition(ccp(20,160))
            bindCountStr:setColor(G_ColorRed)
            self.bgLayer:addChild(bindCountStr)
            if bindCount==0 then
                local noBindLb=GetTTFLabelWrap(getlocal("noBindFriendStr"),25,CCSizeMake(self.bgSize.width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                noBindLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2+30))
                noBindLb:setColor(G_ColorGray)
                self.bgLayer:addChild(noBindLb)
            end
        end
        local valueLb=GetTTFLabel(valueStr,lbSize)
        valueLb:setPosition(getX(2),titleBg:getContentSize().height/2)
        valueLb:setColor(color)
        titleBg:addChild(valueLb,1)

        zorder=zorder+2
    elseif self.whiTypeDia == 3 then
        self:initFixDialog(descBg)
    end
    if tvWidth and tvHeight and tvPos then
        local function eventHandler(...)
            return self:eventHandler(...)
        end
        local hd=LuaEventHandler:createHandler(eventHandler)
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil) 
        self.tv:setPosition(tvPos)
        self.tv:setMaxDisToBottomOrTop(100)
        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(self.tv,zorder)
    end
    --------------------------------\\\\小板子界面的 按钮////--------------------------------
    --取消----------------
    local function cancleHandler()
        -- print(" cancleHandler")
         --清空 SID 数量 金币相关
         if self.whiTypeDia ==1 then
             self:cleanAllData()
         end
         PlayEffect(audioCfg.mouseClick)
         if cancleCallBack~=nil then
            cancleCallBack()
         end
         if self.whiTypeDia==2 then
            acGeneralRecallVoApi:setMyFriend(nil)
         end
         self:close()
    end
    local cancleItem =GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",cancleHandler,2)

    local cancleMenu=CCMenu:createWithItem(cancleItem);
    cancleItem:setAnchorPoint(ccp(1,1))
    cancleItem:setScale(0.9)
    cancleMenu:setPosition(ccp(dialogBg:getContentSize().width-5,dialogBg:getContentSize().height-10))
    cancleMenu:setTouchPriority(-(self.layerNum-1)*20-5);
    dialogBg:addChild(cancleMenu,1)

     --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        local payProp,needPayPropNum,selfPropNum = acGeneralRecallVoApi:getNeedCurPayProp( )
        if self.whiTypeDia==4 then
        else
            local curSid = acGeneralRecallVoApi:getCurSid( )--要送的礼物
            local giftNum = acGeneralRecallVoApi:getCurGiftNum()
            local payGems = acGeneralRecallVoApi:getCurPayGems( )
            local payType = acGeneralRecallVoApi:getIsNeedGem( )
            -- local payProp,needPayPropNum,selfPropNum = acGeneralRecallVoApi:getNeedCurPayProp( )
            if  curSid ==0 then-- 未选SID
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noChooseGift"),28) 
                do return end
            elseif giftNum ==0 then-- 未选数量
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noChooseNum"),28) 
                do return end
            elseif payType == 0 then--未选择支付方式
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noChoosePay"),28) 
                do return end
            elseif payType ==2 and needPayPropNum*giftNum > selfPropNum then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noPayProp"),28) 
                do return end
            elseif payType ==1 and payGems*giftNum > playerVoApi:getGems() then
                GemsNotEnoughDialog(nil,nil,payGems*giftNum-playerVoApi:getGems(),self.layerNum+1,payGems*giftNum)
                do return end
            end
        end
        if self.whiTypeDia ==1 then
            local curSid = acGeneralRecallVoApi:getCurSid( )--要送的礼物
            local giftNum = acGeneralRecallVoApi:getCurGiftNum()
            local payGems = acGeneralRecallVoApi:getCurPayGems( )
            local payType = acGeneralRecallVoApi:getIsNeedGem( )
            -- local payProp,needPayPropNum,selfPropNum = acGeneralRecallVoApi:getNeedCurPayProp( )
            if  curSid ==0 then-- 未选SID
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noChooseGift"),28) 
                do return end
            elseif giftNum ==0 then-- 未选数量
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noChooseNum"),28) 
                do return end
            elseif payType == 0 then--未选择支付方式
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noChoosePay"),28) 
                do return end
            elseif payType ==2 and needPayPropNum*giftNum > selfPropNum then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noPayProp"),28) 
                do return end
            elseif payType ==1 and payGems*giftNum > playerVoApi:getGems() then
                GemsNotEnoughDialog(nil,nil,payGems*giftNum-playerVoApi:getGems(),self.layerNum+1,payGems*giftNum)
                do return end
            end
            acGeneralRecallVoApi:setFixGiftType(true)

        elseif self.whiTypeDia == 3 then
           local sendParams=acGeneralRecallVoApi:getLastToSend()
            local costGems=sendParams[5] or 0
            if costGems>playerVoApi:getGems() then
                GemsNotEnoughDialog(nil,nil,costGems-playerVoApi:getGems(),self.layerNum+1,costGems)
                do return end
            end
           local uid=acGeneralRecallVoApi:getMyFriend()
           sendParams[3]=uid
           acGeneralRecallVoApi:setLastToSend(sendParams)
            acGeneralRecallVoApi:SureToSendNow(payProp)    
        end
        PlayEffect(audioCfg.mouseClick)
        if(confirmCallback)then
            confirmCallback()
        end
        
        self:close()
    end
    local str
    if btnStr then
        str=btnStr
    else
        str=getlocal("confirm")
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,str,25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,65))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-5);
    dialogBg:addChild(sureMenu)
    --------------------------------////小板子界面的 按钮\\\\--------------------------------
    
    if self.whiTypeDia ==1 then
        local smalTipStr = GetTTFLabelWrap(getlocal("activity_generalRecall_noPropPayByGems"),strSize2,CCSizeMake(self.bgLayer:getContentSize().width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
        smalTipStr:setAnchorPoint(ccp(0.5,0))
        smalTipStr:setPosition(ccp(sureItem:getContentSize().width*0.5,sureItem:getContentSize().height+10))
        sureItem:addChild(smalTipStr)
        smalTipStr:setColor(G_ColorRed)
    elseif self.whiTypeDia ==2 then
        sureMenu:setVisible(false)
    end
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-4)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg)

    self:show()
    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end

function acGeneralRecallSmallDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.whiTypeDia==4 or self.whiTypeDia==2 then
            return 1
        end
        return 0 ----------假数据
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.whiTypeDia==4 or self.whiTypeDia==2 then
            local height=self:getCellHeight(idx+1)
            tmpSize=CCSizeMake(self.cellWidth,height)
        else
            tmpSize=CCSizeMake(300,200) ------------假数据
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        if self.whiTypeDia==4 or self.whiTypeDia==2 then
            self:addBindOrSelectPlayers(cell,CCSizeMake(self.cellWidth,self.cellHightTb[idx+1]))
        end
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acGeneralRecallSmallDialog:initTitleBg(strHeight2)
    local titleBgWidth,titleBgHeight,needPosX = self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height,5
    local titleHeight = 50
    local titleDownBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    local scalex,scaley=titleBgWidth*0.8/titleDownBg:getContentSize().width,titleHeight/titleDownBg:getContentSize().height
    titleDownBg:setAnchorPoint(ccp(0.5,1))
    titleDownBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5+needPosX,self.bgLayer:getContentSize().height-strHeight2+5))
    titleDownBg:setScaleX(scalex)
    titleDownBg:setScaleY(scaley)
    self.bgLayer:addChild(titleDownBg,1)

    local upSideBar=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    upSideBar:setAnchorPoint(ccp(0.5,1))
    upSideBar:setScaleX(0.96)
    upSideBar:setPosition(ccp(titleBgWidth*0.5,titleDownBg:getPositionY()-titleHeight+5))
    self.bgLayer:addChild(upSideBar)

end

----------------------------\\\\\确认支付//////----------------------------

function acGeneralRecallSmallDialog:initFixDialog(descBg)
    local lastToSend = {}
    descBg:setPositionY(descBg:getPositionY()+60)
    local curSid = acGeneralRecallVoApi:getCurSid()
    local gData,gFormatTb = acGeneralRecallVoApi:getLast(curSid)
    local count = acGeneralRecallVoApi:getCurGiftNum()
    --sendGift
    lastToSend[1] = curSid
    lastToSend[2] = count
    lastToSend[3] = ""--被赠送人uid

    local useTitle=GetTTFLabelWrap(getlocal("sendGift",{""}),25,CCSizeMake(descBg:getContentSize().width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    useTitle:setAnchorPoint(ccp(0.5,1))
    useTitle:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height-15))
    descBg:addChild(useTitle)

    local giftSp = G_getItemIcon(gFormatTb,100,true,self.layerNum)
    giftSp:setAnchorPoint(ccp(0.5,1))
    giftSp:setPosition(ccp(descBg:getContentSize().width*0.35,useTitle:getPositionY()-50))
    descBg:addChild(giftSp)

    local giftName = GetTTFLabelWrap(gFormatTb.name,24,CCSizeMake(descBg:getContentSize().width*0.6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    giftName:setAnchorPoint(ccp(0,1))
    giftName:setPosition(ccp(giftSp:getPositionX()+70,giftSp:getPositionY()-5))
    descBg:addChild(giftName)

    local giftCount = GetTTFLabelWrap(getlocal("activity_openyear_fd_opened",{count}),24,CCSizeMake(descBg:getContentSize().width*0.5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    giftCount:setAnchorPoint(ccp(0,0))
    giftCount:setPosition(ccp(giftSp:getPositionX()+70,giftSp:getPositionY()-100))
    descBg:addChild(giftCount)

    local lineSp = CCSprite:createWithSpriteFrameName("openyear_line.png")
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setPosition(ccp(descBg:getContentSize().width*0.5,giftSp:getPositionY()-120))
    lineSp:setScaleX((descBg:getContentSize().width*0.8)/lineSp:getContentSize().width)
    descBg:addChild(lineSp,1)


    local isNeedGem = acGeneralRecallVoApi:getIsNeedGem()
    local sellTbStr = { getlocal("expendProp",{""}),getlocal("expendGems",{""})}

    if isNeedGem ==2 then --道具
        lastToSend[4] = 0
        local useProp = FormatItem(gData[curSid].need,true,true)[1]
        --expendProp
        useTitle =  GetTTFLabelWrap(sellTbStr[1],25,CCSizeMake(descBg:getContentSize().width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        useTitle:setAnchorPoint(ccp(0.5,1))
        useTitle:setPosition(ccp(descBg:getContentSize().width*0.5,lineSp:getPositionY()-10))
        descBg:addChild(useTitle)

        local expendIcon = G_getItemIcon(useProp,80,true,self.layerNum)
        expendIcon:setAnchorPoint(ccp(0.5,1))
        expendIcon:setPosition(ccp(descBg:getContentSize().width*0.35,useTitle:getPositionY()-50))
        descBg:addChild(expendIcon)

        local expendName = GetTTFLabelWrap(useProp.name,24,CCSizeMake(descBg:getContentSize().width*0.6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        expendName:setAnchorPoint(ccp(0,1))
        expendName:setPosition(ccp(expendIcon:getPositionX()+70,expendIcon:getPositionY()-5))
        descBg:addChild(expendName)

        local expendCount = GetTTFLabelWrap(getlocal("activity_openyear_fd_opened",{useProp.num*count}),24,CCSizeMake(descBg:getContentSize().width*0.5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        expendCount:setAnchorPoint(ccp(0,0))
        expendCount:setPosition(ccp(expendIcon:getPositionX()+70,expendIcon:getPositionY()-80))
        descBg:addChild(expendCount)
    elseif isNeedGem ==1 then--金币
        lastToSend[4] =1

        --buyGemsTiTle
        useTitle =  GetTTFLabelWrap(sellTbStr[2],25,CCSizeMake(descBg:getContentSize().width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        useTitle:setAnchorPoint(ccp(0.5,1))
        useTitle:setPosition(ccp(descBg:getContentSize().width*0.5,lineSp:getPositionY()-10))
        descBg:addChild(useTitle)

        local gemIcon = CCSprite:createWithSpriteFrameName("resourse_normal_gem.png")
        gemIcon:setAnchorPoint(ccp(0.5,1))
        gemIcon:setPosition(ccp(descBg:getContentSize().width*0.35,useTitle:getPositionY()-50))
        descBg:addChild(gemIcon)

        local gemName = GetTTFLabelWrap("",24,CCSizeMake(descBg:getContentSize().width*0.6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        gemName:setAnchorPoint(ccp(0,1))
        gemName:setPosition(ccp(gemIcon:getPositionX()+70,gemIcon:getPositionY()-5))
        descBg:addChild(gemName)

        local gemCount = GetTTFLabel(getlocal("activity_openyear_fd_opened",{gData[curSid].gems*count}),24)
        gemCount:setAnchorPoint(ccp(0,0))
        gemCount:setColor(G_ColorYellowPro)
        gemCount:setPosition(ccp(gemIcon:getPositionX()+70,gemIcon:getPositionY()-80))
        descBg:addChild(gemCount)

        local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        gemIcon:setAnchorPoint(ccp(0,0))
        gemIcon:setPosition(gemCount:getPositionX()+gemCount:getContentSize().width+5,gemCount:getPositionY())
        descBg:addChild(gemIcon,1)
    end

    local expendGemsStrTb = {getlocal("emailGems"),getlocal("allExpendGems")}
    local nilData,beSenderNameStr = acGeneralRecallVoApi:getMyFriend( )
    local downLbTb = {getlocal("beSenderName",{beSenderNameStr}),getlocal("getScoreAtThisTime",{gData[curSid].getdonate*count})}
    local emailGems = gData[curSid].extra*(count ==0 and 1 or count)
    local allExpendGems = emailGems + (isNeedGem ==1 and gData[curSid].gems*count or 0)
    -- print("allExpendGems----->",allExpendGems)
    -- acGeneralRecallVoApi:setCurPayGems(allExpendGems)
    lastToSend[5] = allExpendGems
    for i=1,2 do
        local gemName = GetTTFLabel(expendGemsStrTb[i],26)
        gemName:setAnchorPoint(ccp(0,1))
        gemName:setPosition(ccp(50,-45*(i-1)-5))
        descBg:addChild(gemName)

        local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        gemIcon:setAnchorPoint(ccp(1,1))
        gemIcon:setPosition(ccp(descBg:getContentSize().width-50,-45*(i-1)-5))
        descBg:addChild(gemIcon,1)

        local gemCount = GetTTFLabel(i==1 and emailGems or allExpendGems,24)
        gemCount:setAnchorPoint(ccp(1,1))
        gemCount:setColor(G_ColorYellowPro)
        gemCount:setPosition(ccp(gemIcon:getPositionX()-gemIcon:getContentSize().width-5,-45*(i-1)-5))
        descBg:addChild(gemCount)
        if i ==1 then
            local lineSp = CCSprite:createWithSpriteFrameName("openyear_line.png")
            lineSp:setAnchorPoint(ccp(0.5,0.5))
            lineSp:setPosition(ccp(descBg:getContentSize().width*0.5,gemName:getPositionY()-40))
            lineSp:setScaleX((descBg:getContentSize().width*0.8)/lineSp:getContentSize().width)
            descBg:addChild(lineSp,1)
        end

        local downStr= GetTTFLabelWrap(downLbTb[i],25,CCSizeMake(descBg:getContentSize().width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        downStr:setAnchorPoint(ccp(0.5,1))
        downStr:setPosition(ccp(descBg:getContentSize().width*0.5,gemName:getPositionY()-80))
        descBg:addChild(downStr)
        if i ==1 then
            downStr:setColor(G_ColorYellowPro)
        end
    end


    acGeneralRecallVoApi:setLastToSend(lastToSend)
end

----------------------------\\\\\选择礼物//////----------------------------

function acGeneralRecallSmallDialog:initChooseGiftTab(descBgPosY)
    local strSize2 = 24
  if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 =30
  end
   local subTabTb = {getlocal("accessory"),getlocal("tanke"),getlocal("heroTitle")}
   local subTabIndex=0
   local tabBtn=CCMenu:create()
   for k,v in pairs(subTabTb) do
       local tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
       tabBtnItem:setAnchorPoint(CCPointMake(0.5,0))
       local function tabSubClick(idx)
           return self:tabSubClick(idx)
       end
       tabBtnItem:registerScriptTapHandler(tabSubClick)
       local lb=GetTTFLabelWrap(v,strSize2,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
       lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
       tabBtnItem:addChild(lb)
       self.allSubTabs[k]=tabBtnItem
       tabBtn:addChild(tabBtnItem)
       tabBtnItem:setTag(subTabIndex+20)
       subTabIndex=subTabIndex+1
   end
   tabBtn:setPosition(ccp(0,descBgPosY-5))
   self.bgLayer:addChild(tabBtn,5)
   self:tabSubClick(20)

   -- LegionCheckBtnUn.png
   local function checkCallBack(hd,fn,tag)
        print("check tag---->",tag,acGeneralRecallVoApi:getCurSid( ))
        if acGeneralRecallVoApi:getCurSid( )==0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_noChooseGift"),28) 
            do return end
        end
        local idx=1
        if tag==51 or tag==501 then
            acGeneralRecallVoApi:setIsNeedGem(2)
            if self.touchItemTb and self.touchItemTb[1] and self.touchItemTb[2] then
                self.touchItemTb[1]:setOpacity(255)
                self.touchItemTb[2]:setOpacity(0)
            end
            idx=1
        elseif tag==52 or tag==502 then
            acGeneralRecallVoApi:setIsNeedGem(1)
            if self.touchItemTb and self.touchItemTb[1] and self.touchItemTb[2] then
                self.touchItemTb[1]:setOpacity(0)
                self.touchItemTb[2]:setOpacity(255)
            end
            idx=2
        end
        self.checkBtn:setPosition(self.checkPosTb[idx])
        self.checkBtn:setVisible(true)

   end 
    local costLb=GetTTFLabelWrap(getlocal("selectGiftCostStr"),24,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    costLb:setAnchorPoint(ccp(0,0.5))
    costLb:setPosition(ccp(20,self.bgLayer:getContentSize().height*0.3))
    self.bgLayer:addChild(costLb)
    self.touchItemTb={}
    local cPosY = {0.358,0.238}
    for i=1,2 do
        local checkUnSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",checkCallBack)
        checkUnSp:setAnchorPoint(ccp(0.5,0.5))
        self.checkPosTb[i]=ccp(165,self.bgLayer:getContentSize().height*cPosY[i]) 
        checkUnSp:setPosition(self.checkPosTb[i])
        checkUnSp:setTag(50+i)
        checkUnSp:setTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(checkUnSp)

        local touchBg=LuaCCSprite:createWithSpriteFrameName("groupSelf.png",checkCallBack)
        touchBg:setAnchorPoint(ccp(0.5,0.5))
        touchBg:setTouchPriority(-(self.layerNum-1)*20-5)
        touchBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.65,checkUnSp:getPositionY()))
        touchBg:setScaleX(500/touchBg:getContentSize().width)
        touchBg:setScaleY(self.costPropSize/touchBg:getContentSize().height)
        touchBg:setTag(500+i)
        touchBg:setOpacity(0)
        self.bgLayer:addChild(touchBg)
        self.touchItemTb[i]=touchBg
    end


   self.checkBtn = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
   self.checkBtn:setVisible(false)
   self.bgLayer:addChild(self.checkBtn)

end
function acGeneralRecallSmallDialog:tabSubClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allSubTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedSubTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
    self:refreshSelectProp(true)
    if idx ==20 then
        if self.showGiftBgTb[1] then
                self.showGiftBgTb[1]:setVisible(true)
                self.showGiftBgTb[1]:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.8))
        else
            self:initShowGiftBg(1)
        end
        if self.showGiftBgTb[2] then
            self.showGiftBgTb[2]:setVisible(false)
            self.showGiftBgTb[2]:setPosition(ccp(999999,0))
        end
        if self.showGiftBgTb[3] then
            self.showGiftBgTb[3]:setVisible(false)
            self.showGiftBgTb[3]:setPosition(ccp(999999,0))
        end
        self.choosePage = 1
    elseif idx ==21 then
        if self.showGiftBgTb[2] then
                self.showGiftBgTb[2]:setVisible(true)
                self.showGiftBgTb[2]:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.8))
        else
            self:initShowGiftBg(2)
        end
        if self.showGiftBgTb[1] then
            self.showGiftBgTb[1]:setVisible(false)
            self.showGiftBgTb[1]:setPosition(ccp(999999,0))
        end
        if self.showGiftBgTb[3] then
            self.showGiftBgTb[3]:setVisible(false)
            self.showGiftBgTb[3]:setPosition(ccp(999999,0))
        end
        self.choosePage =2
    elseif idx ==22 then
        if self.showGiftBgTb[3] then
                
                self.showGiftBgTb[3]:setVisible(true)
                self.showGiftBgTb[3]:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.8))
        else
            self:initShowGiftBg(3)
        end
        if self.showGiftBgTb[2] then
            self.showGiftBgTb[2]:setVisible(false)
            self.showGiftBgTb[2]:setPosition(ccp(999999,0))
        end
        if self.showGiftBgTb[1] then
            self.showGiftBgTb[1]:setVisible(false)
            self.showGiftBgTb[1]:setPosition(ccp(999999,0))
        end
        self.choosePage =3
    end
    self.chooseSid =0
    self:cleanAllData(true)

end

function acGeneralRecallSmallDialog:getCellHeight(idx)
    if self.cellHightTb==nil then
        self.cellHightTb={}
    end
    if self.cellHightTb[idx]==nil then
        local height=0
        if self.whiTypeDia==4 then
            if self.needData then
                local w=self.cellWidth/3
                for k,player in pairs(self.needData) do
                    local name=player[4] or ""
                    local vip=tonumber(player[7]) or 0
                    local nameLb=GetTTFLabelWrap(name,25,CCSizeMake(w,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    height=height+nameLb:getContentSize().height+41
                end
            end
        elseif self.whiTypeDia==2 then
            if self.needData then
                local fcount=SizeOfTable(self.needData)
                height=fcount*91
            end
        end
        self.cellHightTb[idx]=height
    end
    return self.cellHightTb[idx]
end

--添加绑定或者选择战友
function acGeneralRecallSmallDialog:addBindOrSelectPlayers(parent,size)
    if parent==nil or size==nil or self.needData==nil then
        do return end
    end
    local lbSize=25
    local w=size.width/3
    local function getX(index)
        return -5+w*index+w/2
    end
    local posY=size.height
    for k,player in pairs(self.needData) do
        local uid=player[1]
        local name=player[4] or ""
        local vip=tonumber(player[7]) or 0
        local lastVip=tonumber(player[3]) or 0
        local nameLb=GetTTFLabelWrap(name,lbSize,CCSizeMake(w,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local cellH=0
        local namePosY=0
        if self.whiTypeDia==4 then
            cellH=nameLb:getContentSize().height+41
            namePosY=posY-nameLb:getContentSize().height/2-15
        else
            cellH=80
            namePosY=posY-40
        end
        nameLb:setPosition(getX(0),namePosY)
        parent:addChild(nameLb,1)        
        local vipLb=GetTTFLabel(getlocal("VIPStr1",{vip}),lbSize)
        vipLb:setPosition(ccp(getX(1),namePosY))
        parent:addChild(vipLb,1)

        if self.whiTypeDia==4 then
            local addSp
            local addValue=vip-lastVip
            if addValue>0 then  --vip上升
                addSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
            else
                addSp=CCSprite:createWithSpriteFrameName("vipNoChange.png")
            end
            local changeLb=GetTTFLabel(tostring(addValue),lbSize)
            changeLb:setPosition(getX(2),namePosY)
            parent:addChild(changeLb,1)
            if addSp then
                addSp:setAnchorPoint(ccp(0,0.5))
                addSp:setPosition(ccp(changeLb:getPositionX()+30,namePosY))
                parent:addChild(addSp)
            end
        elseif self.whiTypeDia==2 then
            local flag=acGeneralRecallVoApi:isGifted(uid) --是否已经赠送的标记
            if flag==true then
                local sendLb=GetTTFLabelWrap(getlocal("alien_tech_alreadySend"),lbSize,CCSizeMake(w,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                sendLb:setPosition(getX(2),namePosY)
                parent:addChild(sendLb,1)
            else
                local function selectCallBack() --选择战友的处理
                    acGeneralRecallVoApi:setMyFriend(uid,name)
                    if self.confirmCallback then
                        self.confirmCallback()
                    end
                    self:close()
                end
                local selectItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",selectCallBack,2,getlocal("dailyAnswer_tab1_btn"),25)
                local selectBtn=CCMenu:createWithItem(selectItem)
                selectItem:setScale(0.8)
                selectBtn:setPosition(ccp(getX(2),namePosY))
                selectBtn:setTouchPriority(-(self.layerNum-1)*20-5)
                parent:addChild(selectBtn,1)
            end
        end
        if self.whiTypeDia==4 then
            posY=posY-nameLb:getContentSize().height-41
        elseif self.whiTypeDia==2 then
            posY=posY-91
        end
        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(ccp(size.width/2,posY))
        parent:addChild(lineSp)
    end
end

function acGeneralRecallSmallDialog:resetTab()

    local indexSub=0
    for k,v in pairs(self.allSubTabs) do
         local  tabBtnItem=v

         if indexSub==0 then
            tabBtnItem:setPosition(100,0)
         elseif indexSub==1 then
            tabBtnItem:setPosition(240,0)
         elseif indexSub==2 then
            tabBtnItem:setPosition(380,0)
         end
         if indexSub==self.selectedSubTabIndex then
             tabBtnItem:setEnabled(false)
         end
         indexSub=indexSub+1
    end
    self.selectedSubTabIndex=10
end

function acGeneralRecallSmallDialog:initShowGiftBg(idx)
    local choosePage = idx
    self.choosePage =choosePage

    local function nilFunc( ) end
    local blackBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    blackBg:setTouchPriority(-(self.layerNum-1)*20-4)
    blackBg:setContentSize(self.upRect)
    blackBg:setAnchorPoint(ccp(0.5,1))
    blackBg:setTag(1)
    blackBg:setOpacity(0)
    blackBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.8))
    self.bgLayer:addChild(blackBg,1)
    self.showGiftBgTb[idx] = blackBg
    local iconStartPosY = blackBg:getContentSize().height-10
    if self.flickSp ==nil then
        self.flickSp = G_addRectFlicker(blackBg,1,1)
        self.flickSp:setAnchorPoint(ccp(0,1))
        self.flickSp:setVisible(false)
    end

    local pageData,curGiftTb = acGeneralRecallVoApi:getDonateReward(choosePage)

    local function clickCallBack(object,fn,idx )
        
        self.chooseSid = "i"..acGeneralRecallVoApi:getClickCurSid(idx-10,choosePage)--"i"..idx-10+(choosePage-1)*3
        print("chooseSid",self.chooseSid)

        -- print("in clickCallBack---->self.chooseSid",self.chooseSid,choosePage)
        acGeneralRecallVoApi:setCurSid(self.chooseSid)
        acGeneralRecallVoApi:setSingleNum()
        acGeneralRecallVoApi:setIsNeedGem()
        if self.checkBtn then
            self.checkBtn:setVisible(false)
        end
        for k,v in pairs(pageData[self.chooseSid].need) do
            print("k-------->",k)
            acGeneralRecallVoApi:setPayPropKey(k)
        end
        local payProp = FormatItem(pageData[self.chooseSid].need,true,true)[1]
        local needPropIcon = acGeneralRecallVoApi:setNeedCurPayProp(payProp,self.layerNum,self.costPropSize)
        acGeneralRecallVoApi:setCurPayGems(pageData[self.chooseSid].gems)
        local propItem=curGiftTb[idx-10]
        if propItem then
            self:refreshSelectProp(false,propItem)
        end
        self.sellIconTb[1]:setVisible(false)
        needPropIcon:setPosition(self.sellIconTb[1]:getPositionX(),self.sellIconTb[1]:getPositionY())
        needPropIcon:setTouchPriority(-(self.layerNum-1)*20-5)
        needPropIcon:setAnchorPoint(ccp(0,1))
        blackBg:addChild(needPropIcon)
        self.sellIconTb[1]:removeFromParentAndCleanup(true)
        self.sellIconTb[1] = needPropIcon
        self.sellTitleTb[1]:setString(payProp.name)

        local nilData,needPropNum,curPropnum = acGeneralRecallVoApi:getNeedCurPayProp()
        self.sellNumTb[1]:setString(getlocal("serverwar_shop_tab1").."："..getlocal("scheduleChapter",{curPropnum,needPropNum}))
        -- print("needPropNum----curPropnum---->",needPropNum,curPropnum)
        if needPropNum > curPropnum then
            self.sellNumTb[1]:setColor(G_ColorRed)
        end
        self.sellNumTb[2]:setString(getlocal("dimensionalWar_cost_gold",{pageData[self.chooseSid].gems}))
        if playerVoApi:getGems() < pageData[self.chooseSid].gems then
            self.sellNumTb[2]:setColor(G_ColorRed)
        end
        for i=1,2 do
            self.sellNumTb[i]:setVisible(true)
        end

        if self.slider[choosePage] then
            acGeneralRecallVoApi:setCurGiftNum()
            -- self.slider[choosePage]:setMaximumValue(0.0)
            local donateId=self.chooseSid
            local max=acGeneralRecallVoApi:getCurMaxDonate(choosePage,self.chooseSid)
            -- self.slider[choosePage]:setMaximumValue(G_keepNumber(pageData[self.chooseSid].maxNum,1))
            if max==0 then
                self.slider[choosePage]:setMinimumValue(0)
            else
                self.slider[choosePage]:setMinimumValue(1.0)
            end
            self.slider[choosePage]:setMaximumValue(max)
            self.slider[choosePage]:setValue(1)
            -- if G_keepNumber(pageData[self.chooseSid].maxNum,1) ==1 then
            --     self.slider[choosePage]:setMaximumValue(1.0)
            -- end
        end

        local icon = tolua.cast(blackBg:getChildByTag(idx),"CCSprite")
        local flickSpPosX = icon:getPositionX()
        local flickSpPosY = icon:getPositionY()

        self.flickSp:setPosition(ccp(flickSpPosX,flickSpPosY))
        self.flickSp:setVisible(true)
    end

    local vv = curGiftTb[1]
    local sindex=1
    local count=0
    for k,v in pairs(curGiftTb) do
        local sid="i"..acGeneralRecallVoApi:getClickCurSid(k,choosePage)
        local max=acGeneralRecallVoApi:getCurMaxDonate(choosePage,sid)
        -- print("sid,max------>",sid,max)
        if max>0 then
            local icon,iiScale=G_getItemIcon(v,80,false,self.layerNum,clickCallBack)
            icon:ignoreAnchorPointForPosition(false)
            icon:setAnchorPoint(ccp(0,1))
            icon:setIsSallow(false)
            icon:setTag(k+10)
            icon:setTouchPriority(-(self.layerNum-1)*20-5)
            local xX = sindex<7 and sindex or sindex-6
            icon:setPosition(ccp(5+85*(xX-1),sindex >6 and iconStartPosY-90 or iconStartPosY ))
            blackBg:addChild(icon,1)
            sindex=sindex+1
            count=count+1
        end
    end
    if count==0 then
        local noSendLb=GetTTFLabelWrap(getlocal("noPropDonateStr"),25,CCSizeMake(self.bgLayer:getContentSize().width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noSendLb:setAnchorPoint(ccp(0.5,0.5))
        noSendLb:setPosition(ccp(blackBg:getContentSize().width*0.5,blackBg:getContentSize().height*0.5))
        noSendLb:setColor(G_ColorGray)
        blackBg:addChild(noSendLb,3)
    end
    ------------------slider
    local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
    bgSp:setAnchorPoint(ccp(0,0.5));
    bgSp:setPosition(225,-70);
    bgSp:setScaleX(0.5)
    bgSp:setScaleY(0.8)
    blackBg:addChild(bgSp,1);

    local m_numLb=GetTTFLabel(" ",25)
    m_numLb:setPosition(self.bgLayer:getContentSize().width*0.47,-70);
    blackBg:addChild(m_numLb,2);
    self.sliderNumTb[self.choosePage]= m_numLb
    if self.sendLb==nil then
        local sendLb=GetTTFLabelWrap(getlocal("donateGiftStr"),24,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        sendLb:setAnchorPoint(ccp(0,0.5))
        sendLb:setPosition(ccp(20,self.bgLayer:getContentSize().height*0.48))
        self.bgLayer:addChild(sendLb)
        self.sendLb=sendLb
    end

    if self.selectPropIcon==nil then
        local selectPropIcon=CCSprite:createWithSpriteFrameName("Icon_BG.png")
        selectPropIcon:setAnchorPoint(ccp(0,0.5))
        selectPropIcon:setScale(90/selectPropIcon:getContentSize().width)
        selectPropIcon:setPosition(ccp(self.bgLayer:getContentSize().width*0.25,self.bgLayer:getContentSize().height*0.485))
        self.bgLayer:addChild(selectPropIcon)
        self.selectPropIcon=selectPropIcon
        local iconSp=CCSprite:createWithSpriteFrameName("questionMark.png")
        iconSp:setPosition(getCenterPoint(selectPropIcon))
        selectPropIcon:addChild(iconSp)
    end
    if self.nameLb==nil then
        local nameLb=GetTTFLabelWrap("",24,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(self.selectPropIcon:getPositionX()+90,self.bgLayer:getContentSize().height*0.53))
        nameLb:setVisible(false)
        self.bgLayer:addChild(nameLb)
        self.nameLb=nameLb
    end
    local function sliderTouch(handler,object)
      local count = math.floor(object:getValue())
      
        self:refreshSlider(count,pageData)
        m_numLb:setString(count)
        acGeneralRecallVoApi:setCurGiftNum(count)
    end

    local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
    local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
    local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    slider:setScaleX(130/slider:getContentSize().width)
    slider:setTouchPriority(-(self.layerNum-1)*20-5);
    slider:setIsSallow(true);
    self.slider[choosePage] = slider
    slider:setMinimumValue(0.0);
    slider:setMaximumValue(0.0);
    -- print("slider:getMinimumValue(),slider:getMaximumValue()",slider:getMinimumValue(),slider:getMaximumValue())
    spPr1:setScaleY(0.8)

    slider:setValue(0);
    slider:setPosition(ccp(self.bgLayer:getContentSize().width*0.73,-70))
    slider:setTag(99)
    blackBg:addChild(slider,2)
    m_numLb:setString(math.floor(slider:getValue()))

    local function touchAdd()
        -- print("slider:getValue()+1,slider:getMaximumValue()",slider:getValue()+1,slider:getMaximumValue())
        if slider:getValue()+1<=slider:getMaximumValue() then
            slider:setValue(slider:getValue()+1)
        end
    end
  
    local function touchMinus()
      if slider:getValue()-1>0 then
          slider:setValue(slider:getValue()-1);
      end
    end
  
    local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
    addSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.9,-70))
    blackBg:addChild(addSp,1)
    addSp:setTouchPriority(-(self.layerNum-1)*20-5);

    local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
    minusSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.56,-70))
    blackBg:addChild(minusSp,1)
    minusSp:setTouchPriority(-(self.layerNum-1)*20-5);

    local lineSp = CCSprite:createWithSpriteFrameName("openyear_line.png")
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setPosition(ccp(blackBg:getContentSize().width*0.5,slider:getPositionY()-30))
    lineSp:setScaleX((blackBg:getContentSize().width*0.8)/lineSp:getContentSize().width)
    blackBg:addChild(lineSp,1)


    local rect=CCSizeMake(50,45)
    local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchAdd)
    addTouchBg:setTouchPriority(-(self.layerNum-1)*20-5)
    addTouchBg:setContentSize(rect)
    addTouchBg:setAnchorPoint(ccp(0.5,0.5))
    addTouchBg:setOpacity(0)
    addTouchBg:setPosition(getCenterPoint(addSp))
    addSp:addChild(addTouchBg,1)


    local minusTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchMinus)
    minusTouchBg:setTouchPriority(-(self.layerNum-1)*20-5)
    minusTouchBg:setContentSize(rect)
    minusTouchBg:setAnchorPoint(ccp(0.5,0.5))
    minusTouchBg:setOpacity(0)
    minusTouchBg:setPosition(getCenterPoint(minusSp))
    minusSp:addChild(minusTouchBg,1)



    -------------------

    self:defaultSellDataShow(blackBg,lineSp)
    -------------------兑换  购买
    --boxIcon = GetBgIcon(pic,showInfoHandler,nil,nil,iconSize)
    

end

function acGeneralRecallSmallDialog:refreshSelectProp(cleanFlag,prop)
    if self.selectPropIcon and self.nameLb then
        local posX=self.selectPropIcon:getPositionX()
        local posY=self.selectPropIcon:getPositionY()
        self.selectPropIcon:removeFromParentAndCleanup(true)
        self.selectPropIcon=nil
        if cleanFlag==true then
            local selectPropIcon=CCSprite:createWithSpriteFrameName("Icon_BG.png")
            selectPropIcon:setAnchorPoint(ccp(0,0.5))
            selectPropIcon:setScale(90/selectPropIcon:getContentSize().width)
            selectPropIcon:setPosition(ccp(posX,posY))
            self.bgLayer:addChild(selectPropIcon)
            self.selectPropIcon=selectPropIcon
            local iconSp=CCSprite:createWithSpriteFrameName("questionMark.png")
            iconSp:setPosition(getCenterPoint(selectPropIcon))
            selectPropIcon:addChild(iconSp)
            self.nameLb:setVisible(false)
        else
            if prop then
                local icon,scale=G_getItemIcon(prop,90,true,self.layerNum+1)
                icon:setTouchPriority(-(self.layerNum-1)*20-5)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(ccp(posX,posY))
                self.bgLayer:addChild(icon)
                self.selectPropIcon=icon
                self.nameLb:setVisible(true)
                self.nameLb:setString(prop.name)
            end
        end
    end
end

function acGeneralRecallSmallDialog:refreshSlider(count,pageData )
        local countNum = tonumber(count)
        acGeneralRecallVoApi:setSingleNum(countNum)
        countNum = countNum > 0 and countNum or 1
        local nilData,needPropNum,curPropnum = acGeneralRecallVoApi:getNeedCurPayProp()
        if self.chooseSid and tonumber(RemoveFirstChar(self.chooseSid)) then
          if self.sellNumTb[1] then
                self.sellNumTb[1]:setString(getlocal("serverwar_shop_tab1").."："..getlocal("scheduleChapter",{curPropnum,needPropNum*countNum}))
                if curPropnum < needPropNum*countNum then
                    self.sellNumTb[1]:setColor(G_ColorRed)
                else
                    self.sellNumTb[1]:setColor(G_ColorWhite)
                end
          end
          if self.sellNumTb[2] and pageData[self.chooseSid] then
                self.sellNumTb[2]:setString(getlocal("dimensionalWar_cost_gold",{pageData[self.chooseSid].gems*countNum}))
                if playerVoApi:getGems() < pageData[self.chooseSid].gems*countNum then
                    self.sellNumTb[2]:setColor(G_ColorRed)
                else
                    self.sellNumTb[2]:setColor(G_ColorWhite)
                end
          end
        end
end

function acGeneralRecallSmallDialog:defaultSellDataShow(blackBg,lineSp)
    local sellTbStr = { getlocal("allianceShop_tab1"),getlocal("gem")}
    local sellTbIcon ={ "questionMark.png","resourse_normal_gem.png"}
    local sellTbNum = { getlocal("activity_xuyuanlu_costGolds",{0}),getlocal("activity_xuyuanlu_costGolds",{0})}
    if SizeOfTable(self.sellIconTb) == 0 then
        for i=1,2 do
            local sellIcon
            if i==1 then
                sellIcon=GetBgIcon(sellTbIcon[i],nil,nil,nil,80)
            else
                sellIcon=CCSprite:createWithSpriteFrameName(sellTbIcon[i])
                sellIcon:setScale(self.costPropSize/sellIcon:getContentSize().width)
            end
            sellIcon:setPosition(ccp(200,lineSp:getPositionY()-10-(i-1)*(self.costPropSize+20)))
            blackBg:addChild(sellIcon)
            sellIcon:setAnchorPoint(ccp(0,1))
            self.sellIconTb[i]=sellIcon

            local sellTitle=GetTTFLabel(sellTbStr[i],22)
            sellTitle:setAnchorPoint(ccp(0,1))
            sellTitle:setPosition(ccp(sellIcon:getPositionX()+self.costPropSize,sellIcon:getPositionY()))
            blackBg:addChild(sellTitle)
            self.sellTitleTb[i]=sellTitle
            local sellNum=GetTTFLabel(sellTbNum[i],22)
            sellNum:setAnchorPoint(ccp(0,0))
            sellNum:setPosition(ccp(sellIcon:getPositionX()+self.costPropSize,sellIcon:getPositionY()-self.costPropSize))
            self.sellNumTb[i] =sellNum
        end
    else

        for i=1,2 do
            local sellTitle = GetTTFLabel(sellTbStr[i],22)
            sellTitle:setAnchorPoint(ccp(0,1))
            sellTitle:setPosition(ccp(self.sellTitleTb[i]:getPositionX(),self.sellTitleTb[i]:getPositionY()))
            blackBg:addChild(sellTitle)
            self.sellTitleTb[i]:removeFromParentAndCleanup(true)
            self.sellTitleTb[i] = sellTitle
            local sellIcon
            if i==1 then
                sellIcon = GetBgIcon(sellTbIcon[i],nil,nil,nil,self.costPropSize)
            else
                sellIcon = CCSprite:createWithSpriteFrameName(sellTbIcon[i])
                sellIcon:setScale(self.costPropSize/sellIcon:getContentSize().width)
            end
            self.sellIconTb[i]:setVisible(false)
            sellIcon:setPosition(self.sellIconTb[i]:getPositionX(),self.sellIconTb[i]:getPositionY())
            sellIcon:setAnchorPoint(ccp(0,1))
            blackBg:addChild(sellIcon)
            self.sellIconTb[i]:removeFromParentAndCleanup(true)
            self.sellIconTb[i] = sellIcon

            local sellNum = GetTTFLabel(sellTbNum[i],22)
            sellNum:setAnchorPoint(ccp(0,0))
            sellNum:setPosition(ccp(self.sellNumTb[i]:getPositionX(),self.sellNumTb[i]:getPositionY()))
            blackBg:addChild(sellNum)
            self.sellNumTb[i]:removeFromParentAndCleanup(true)
            self.sellNumTb[i] = sellNum

        end
        if self.flickSp then
            self.flickSp:removeFromParentAndCleanup(true)
            self.flickSp = G_addRectFlicker(blackBg,1,1)
            self.flickSp:setAnchorPoint(ccp(0,1))
            self.flickSp:setVisible(false)
        end

    end
end

function acGeneralRecallSmallDialog:cleanAllData(noClean)
    acGeneralRecallVoApi:setPayPropKey()
    acGeneralRecallVoApi:setCurSid()
    acGeneralRecallVoApi:setCurGiftNum()
    acGeneralRecallVoApi:setIsNeedGem()
    acGeneralRecallVoApi:setNeedCurPayProp()
    acGeneralRecallVoApi:setSingleNum()
    acGeneralRecallVoApi:setCurPayGems()
    if self.checkBtn then
        self.checkBtn:setVisible(false)
    end

    if self.slider[self.choosePage] then
        self.slider[self.choosePage]:setMinimumValue(0.0)
        self.slider[self.choosePage]:setMaximumValue(0.0)
        self.slider[self.choosePage]:setValue(0)
    end
    if self.sliderNumTb[self.choosePage] then
        self.sliderNumTb[self.choosePage]:setString(0)
    end
    if noClean then
        local blackBg = tolua.cast(self.bgLayer:getChildByTag(1),"CCSprite")
        self:defaultSellDataShow(self.showGiftBgTb[self.choosePage])
    end
end

-- function acGeneralRecallSmallDialog:initGiftData( )
--  acGeneralRecallVoApi:setFixGiftType()
--  acGeneralRecallVoApi:setCurSid()
--  acGeneralRecallVoApi:setCurGiftNum()
--  acGeneralRecallVoApi:setIsNeedGem()
--  acGeneralRecallVoApi:setNeedCurPayProp()
--  acGeneralRecallVoApi:setSingleNum()
--  acGeneralRecallVoApi:setCurPayGems()
-- end

function acGeneralRecallSmallDialog:dispose()
    -- print("dispose in recallSmallDialog~~~~~~~")
    if self.whiTypeDia==4 then
        spriteController:removePlist("public/vipFinal.plist")
        spriteController:removeTexture("public/vipFinal.png")
    end
    self.id = nil
    self.checkSp = nil
    self.item = nil
    self.whiTypeDia =nil
    self.choosePage =nil
    self.needData =nil
    self.allSubTabs=nil
    self.selectedSubTabIndex=nil
    self.showGiftBgTb=nil
    self.upRect =nil
    self.chooseSid =nil
    self.slider =nil
    self.cellNum=0
    self.cellWidth=0
    self.cellHightTb=nil
    self.sellTitleTb=nil
    self.sellIconTb =nil
    self.sellNumTb =nil
    self.sliderNumTb=nil
    self.checkLeftPosTb=nil
    self.checkRightPosTb=nil
    self.checkBtn=nil
    self.checkPosTb=nil
    self.confirmCallback =nil
    self.sendLb=nil
    self.selectPropIcon=nil
    self.nameLb=nil
    self.touchItem=nil
    spriteController:removePlist("public/acNewYearsEva.plist")--
    spriteController:removeTexture("public/acNewYearsEva.png")
end