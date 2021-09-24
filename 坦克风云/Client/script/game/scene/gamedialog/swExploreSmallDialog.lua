swExploreSmallDialog=smallDialog:new()

function swExploreSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function swExploreSmallDialog:showListProp(layerNum,istouch,isuseami,titleStr,isCheck,callback1,callback2,cancelCallback,desInfo,btn1,btn2,closeFlag,spicalTb)
	local sd=swExploreSmallDialog:new()
    sd:initSecondConfirm(layerNum,istouch,isuseami,titleStr,isCheck,callback1,callback2,cancelCallback,desInfo,btn1,btn2,closeFlag,spicalTb)
    return sd
end

function swExploreSmallDialog:initSecondConfirm(layerNum,istouch,isuseami,titleStr,isCheck,callback1,callback2,cancelCallback,desInfo,btn1,btn2,closeFlag,spicalTb)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    local nameFontSize=30

    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayerColor:create(ccc4(0,0,0,180))
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local addHeihgt = 0
    if G_isAsia() == false then
        addHeihgt = 30
    end
    local jianGeH=30
    local btnH=100
    local bgSize=CCSizeMake(560,(spicalTb and spicalTb.secondTip) and (170 + addHeihgt) or 170)--(200 + addHeihgt)

    local desFontSize,desColor,alignmentX=25,G_ColorWhite,kCCTextAlignmentLeft
    if desInfo then
        desFontSize=desInfo[1] or 25
        desColor=desInfo[2] or G_ColorWhite
        alignmentX=desInfo[3] or kCCTextAlignmentLeft
    end

    local dialogBg2H= (spicalTb and spicalTb.secondTip) and (110 + addHeihgt) or 100
    bgSize.height=bgSize.height+dialogBg2H

    local checkH=80
    if isCheck then
        bgSize.height=bgSize.height+checkH
    end
    if closeFlag==true then
        bgSize.height=bgSize.height+10
    end


    -- rewardItem
    local function touchHandler()
    end
    local dialogBg
    if closeFlag==true then
        local function close()
            self:close()
        end
        dialogBg=G_getNewDialogBg(bgSize,titleStr,nameFontSize,nil,self.layerNum,true,close)
    else
        dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    end
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    local dialogBg2Width,dialogBg2Height = self.bgLayer:getContentSize().width-40,dialogBg2H + 10
    dialogBg2:setContentSize(CCSizeMake(dialogBg2Width,dialogBg2Height))
    dialogBg2:setAnchorPoint(ccp(0.5,1))
    if closeFlag==true then
        dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-75)
    else
        dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-60)
    end
    self.bgLayer:addChild(dialogBg2)

    if spicalTb and spicalTb.secondTip then
        local strSize2 = G_isAsia() and 24 or 20
        local posx = G_isAsia() and 55 or 5
        local colorTab={G_ColorWhite,G_ColorRed,G_ColorWhite}
        local expTip1=getlocal("super_weapon_expCurTip1",{2})
        local exploreLb1,exLb1Height = G_getRichTextLabel(expTip1,colorTab,strSize2,dialogBg2Width - 5,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
        exploreLb1:setAnchorPoint(ccp(0,1))
        exploreLb1:setPosition(ccp(posx,dialogBg2Height - 15))
        dialogBg2:addChild(exploreLb1)

        local colorTab={G_ColorWhite,G_ColorRed,G_ColorWhite}
        local expTip2=getlocal("super_weapon_expCurTip2",{10})
        local exploreLb2,exLb2Height = G_getRichTextLabel(expTip2,colorTab,strSize2,dialogBg2Width - 5,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
        exploreLb2:setAnchorPoint(ccp(0,1))
        exploreLb2:setPosition(ccp(posx,dialogBg2Height - 40 - exLb1Height))
        dialogBg2:addChild(exploreLb2)

        -- local expTip3 = GetTTFLabelWrap(getlocal("super_weapon_expCurTip3"),strSize2-4,CCSizeMake(dialogBg2Width + 50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- expTip3:setAnchorPoint(ccp(0.5,0.5))
        -- expTip3:setColor(G_ColorRed)
        -- expTip3:setPosition(ccp(dialogBg2:getContentSize().width * 0.5,dialogBg2Height - 65 - exLb1Height - exLb2Height))
        -- dialogBg2:addChild(expTip3)
    end

    local desPosX,desPosY,anchor=20,dialogBg2:getContentSize().height/2,ccp(0,0.5)
    if alignmentX==kCCTextAlignmentLeft then
        desPosX=20
    elseif alignmentX==kCCTextAlignmentCenter then
        desPosX=dialogBg2:getContentSize().width/2
        anchor=ccp(0.5,0.5)
    end

    local selectSp
    local unSelectSp
    if isCheck then
        local selectSpPosY=10+btnH+checkH/2-10
        local function touch()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end 
            PlayEffect(audioCfg.mouseClick)
            local visibleFlag=selectSp:isVisible()
            print("visibleFlag",visibleFlag)
            selectSp:setVisible(not visibleFlag)
        end
        local selectBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),touch)
        selectBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,checkH))
        selectBg:setPosition(self.bgLayer:getContentSize().width/2,selectSpPosY)
        self.bgLayer:addChild(selectBg)
        selectBg:setTouchPriority(-(self.layerNum-1)*20-4)
        selectBg:setOpacity(0)
        
        selectSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",function() end)
        selectBg:addChild(selectSp,2)
        selectSp:setAnchorPoint(ccp(0,0.5))
        selectSp:setPosition(20,selectBg:getContentSize().height/2)
        selectSp:setVisible(false)

        unSelectSp=CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
        selectBg:addChild(unSelectSp)
        unSelectSp:setAnchorPoint(ccp(0,0.5))
        unSelectSp:setPosition(20,selectBg:getContentSize().height/2)

        local todayLb=GetTTFLabelWrap(getlocal("today_no_prompt"),25,CCSizeMake(selectBg:getContentSize().width-80-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        todayLb:setPosition(80,selectBg:getContentSize().height/2)
        todayLb:setAnchorPoint(ccp(0,0.5))
        selectBg:addChild(todayLb)
    end


    local scale=0.8
    local function touchOKFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        PlayEffect(audioCfg.mouseClick)
        if callback1 then
            callback1()
        end
        if isCheck then
            local visibleFlag=selectSp:isVisible()
            local flag=0
            if visibleFlag==true then
                flag=1
            else
                flag=0
            end
            if callback2 then
                callback2(flag)
            end
        end
        
        self:close()
    end
    local btnStr=getlocal("confirm")
    if btn1 then
        btnStr=btn1[1]
    end
    local okMenuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchOKFunc,2,btnStr,25/scale)
    okMenuItem:setAnchorPoint(ccp(0.5,0.5))
    okMenuItem:setScale(scale)
    local okMenuBtn=CCMenu:createWithItem(okMenuItem)
    okMenuBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2-140,60))
    okMenuBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(okMenuBtn,2)

    local function touchCancelFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        PlayEffect(audioCfg.mouseClick)
        if cancelCallback then
            cancelCallback()
        end
        self:close()
    end
    btnStr=getlocal("cancel")
    if btn2 then
        btnStr=btn2[1]
    end
    local cancelMenuItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",touchCancelFunc,2,btnStr,25/scale)
    cancelMenuItem:setAnchorPoint(ccp(0.5,0.5))
    cancelMenuItem:setScale(scale)
    local cancelMenuBtn=CCMenu:createWithItem(cancelMenuItem)
    cancelMenuBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2+140,60))
    cancelMenuBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(cancelMenuBtn,2)


    if closeFlag==nil or closeFlag==false then
        local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
        self.bgLayer:addChild(pointSp1)
        local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
        self.bgLayer:addChild(pointSp2)
    end

    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end