secondConfirmShowSmallDialog=smallDialog:new()

function secondConfirmShowSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

--showType-》1：提升统率的二次确认
function secondConfirmShowSmallDialog:showListProp(layerNum,istouch,isuseami,titleStr,contentDes,isCheck,callback1,callback2,cancelCallback,desInfo,addStrTb,btn1,btn2,closeFlag,nocancel,showType,checkInfoStr,titleStr2)
	local sd=secondConfirmShowSmallDialog:new()
    sd:initSecondConfirm(layerNum,istouch,isuseami,titleStr,contentDes,isCheck,callback1,callback2,cancelCallback,desInfo,addStrTb,btn1,btn2,closeFlag,nocancel,showType,checkInfoStr,titleStr2)
    return sd
end

function secondConfirmShowSmallDialog:initSecondConfirm(layerNum,istouch,isuseami,titleStr,contentDes,isCheck,callback1,callback2,cancelCallback,desInfo,addStrTb,btn1,btn2,closeFlag,nocancel,showType,checkInfoStr,titleStr2)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    local nameFontSize=30


    base:removeFromNeedRefresh(self) --停止刷新

    local function close()
        if showType and showType==1 then
            if self.closeEvent then
                eventDispatcher:removeEventListener("secondConfirmShowSmallDialog.close",self.closeEvent)
                self.closeEvent=nil
            end
        end
        self:close()
    end

    if showType and showType==1 then
        local function closeEvent()
            close()
        end
        self.closeEvent=closeEvent
        eventDispatcher:addEventListener("secondConfirmShowSmallDialog.close",closeEvent) 
    end
    
    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayerColor:create(ccc4(0,0,0,255*0.7))
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local jianGeH=30
    local btnH=100
    local bgSize=CCSizeMake(560,10+jianGeH*2+btnH)

    local desFontSize,desColor,alignmentX=25,G_ColorWhite,kCCTextAlignmentLeft
    if desInfo then
        desFontSize=desInfo[1] or 25
        desColor=desInfo[2] or G_ColorWhite
        alignmentX=desInfo[3] or kCCTextAlignmentLeft
    end
    local listDesLb, listDesLbHeight
    if type(contentDes) == "table" then
        listDesLb,listDesLbHeight=G_getRichTextLabel(contentDes[1],contentDes[2],desFontSize,bgSize.width-80,alignmentX,kCCVerticalTextAlignmentTop)
    else
        listDesLb=GetTTFLabelWrap(contentDes,desFontSize,CCSizeMake(bgSize.width-80,0),alignmentX,kCCVerticalTextAlignmentTop)
        listDesLb:setColor(desColor)
        listDesLbHeight = listDesLb:getContentSize().height
    end

    local dialogBg2H=0
    bgSize.height=bgSize.height+dialogBg2H

    local addStrLbTb
    if addStrTb then
        dialogBg2H=listDesLbHeight+10
        addStrLbTb={}
        for k,strInfo in pairs(addStrTb) do
            local str=strInfo[1] or "" --文字
            local color=strInfo[2] or G_ColorWhite --颜色
            local fontSize=strInfo[3] or 25 --字号
            local alignmentX=strInfo[4] or kCCTextAlignmentLeft --水平对齐方式
            local space=strInfo[5] or 0 --与上面文字的间距
            local strLb=GetTTFLabelWrap(str,fontSize,CCSizeMake(bgSize.width-60,0),alignmentX,kCCVerticalTextAlignmentTop)
            strLb:setColor(color)
            if alignmentX==kCCTextAlignmentLeft then
                strLb:setAnchorPoint(ccp(0,0.5))
            elseif alignmentX==kCCTextAlignmentCenter then
                strLb:setAnchorPoint(ccp(0.5,0.5))
            end
            table.insert(addStrLbTb,strLb)
            dialogBg2H=dialogBg2H+strLb:getContentSize().height+space
        end
        dialogBg2H=dialogBg2H+10
    else
        dialogBg2H=listDesLbHeight+80
    end
    bgSize.height=bgSize.height+dialogBg2H

    local checkH=80
    if isCheck then
        bgSize.height=bgSize.height+checkH
    end
    if closeFlag==true then
        bgSize.height=bgSize.height+10
    end
    local titleStr2Lb
    local titleStr2FontSize = 22
    if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai" or G_getCurChoseLanguage()=="fr" then
        titleStr2FontSize = 16
    end
    if titleStr2 then
        titleStr2Lb =GetTTFLabelWrap(titleStr2,titleStr2FontSize,CCSizeMake(bgSize.width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        bgSize.height=bgSize.height+titleStr2Lb:getContentSize().height+10
    end


    -- rewardItem
    local function touchHandler()
    end
    local dialogBg
    if closeFlag==true then
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


    -- 标题
    if closeFlag==nil or closeFlag==false then
        local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
        lightSp:setAnchorPoint(ccp(0.5,0.5))
        lightSp:setScaleX(3)
        lightSp:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-50)
        self.bgLayer:addChild(lightSp)

        local nameLb=GetTTFLabelWrap(titleStr,nameFontSize,CCSizeMake(320,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
        nameLb:setAnchorPoint(ccp(0.5,0.5))
        nameLb:setColor(G_ColorYellowPro)
        nameLb:setPosition(bgSize.width/2,bgSize.height-40)
        self.bgLayer:addChild(nameLb)

        local nameLb2=GetTTFLabel(titleStr,nameFontSize)
        local realNameW=nameLb2:getContentSize().width
        if realNameW>nameLb:getContentSize().width then
            realNameW=nameLb:getContentSize().width
        end
        for i=1,2 do
            local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
            local anchorX=1
            local posX=bgSize.width/2-(realNameW/2+20)
            local pointX=-7
            if i==2 then
                anchorX=0
                posX=bgSize.width/2+(realNameW/2+20)
                pointX=15
            end
            pointSp:setAnchorPoint(ccp(anchorX,0.5))
            pointSp:setPosition(posX,nameLb:getPositionY())
            self.bgLayer:addChild(pointSp)

            local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
            pointLineSp:setAnchorPoint(ccp(0,0.5))
            pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
            pointSp:addChild(pointLineSp)
            if i==1 then
                pointLineSp:setRotation(180)
            end
        end
    end

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,dialogBg2H))
    dialogBg2:setAnchorPoint(ccp(0.5,1))
    if closeFlag==true then
        dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-70)
    else
        dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-60)
    end
    self.bgLayer:addChild(dialogBg2)

    dialogBg2:addChild(listDesLb)

    local desPosX,desPosY,anchor=20,dialogBg2:getContentSize().height/2+listDesLbHeight/2,ccp(0,1)
    if alignmentX==kCCTextAlignmentLeft then
        desPosX=20
    elseif alignmentX==kCCTextAlignmentCenter then
        desPosX=dialogBg2:getContentSize().width/2
        anchor=ccp(0.5,1)
    end

    if addStrLbTb then
        desPosY=dialogBg2:getContentSize().height-10
        local posX,posY=20,desPosY-listDesLbHeight
        for k,strLb in pairs(addStrLbTb) do
            local strInfo=addStrTb[k]
            local alignmentX=strInfo[4] or kCCTextAlignmentLeft --水平对齐方式
            local space=strInfo[5] or 0 --与上面文字的间距
            posY=posY-strLb:getContentSize().height/2-space
            if alignmentX==kCCTextAlignmentLeft then
                posX=10
            elseif alignmentX==kCCTextAlignmentCenter then
                posX=dialogBg2:getContentSize().width/2
            end
            strLb:setPosition(posX,posY)
            posY=posY-strLb:getContentSize().height/2
            dialogBg2:addChild(strLb)
        end
    end
    listDesLb:setAnchorPoint(anchor)
    listDesLb:setPosition(desPosX,desPosY)

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
            -- local flag=0
            -- if visibleFlag==true then
            --     flag=0
            -- else
            --     flag=1
            -- end
            -- if callback2 then
            --     callback2(flag)
            -- end
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

        local checkStr
        if checkInfoStr then
            checkStr = checkInfoStr
        else
            checkStr = getlocal("today_no_prompt")
        end

        local todayLb=GetTTFLabelWrap(checkStr,25,CCSizeMake(selectBg:getContentSize().width-80-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        todayLb:setPosition(80,selectBg:getContentSize().height/2)
        todayLb:setAnchorPoint(ccp(0,0.5))
        selectBg:addChild(todayLb)

        if titleStr2 then
            titleStr2Lb:setPosition(30,selectBg:getContentSize().height/2+70)
            titleStr2Lb:setAnchorPoint(ccp(0,0.5))
            titleStr2Lb:setColor(G_ColorYellowPro)
            selectBg:addChild(titleStr2Lb)
        end
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
        if showType==nil or showType~=1 then
            close()
        end
    end
    local btnStr=getlocal("confirm")
    if btn1 then
        btnStr=btn1[1]
    end

    local okMenuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchOKFunc,2,btnStr,25/scale)
    okMenuItem:setAnchorPoint(ccp(0.5,0.5))
    okMenuItem:setScale(scale)
    local okMenuBtn=CCMenu:createWithItem(okMenuItem)
    if nocancel then
        okMenuBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,60))
    else
        okMenuBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2-140,60))
    end
    okMenuBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(okMenuBtn,2)

    if not nocancel then
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
        if showType==nil or showType~=1 then
            close()
        end
    end
    btnStr=getlocal("cancel")
    if btn2 then
        btnStr=btn2[1]
    end
    local cancelBtnPic,cancelBtnDownPic = "newGrayBtn.png","newGrayBtn_Down.png"
    if showType and showType==1 then
        cancelBtnPic,cancelBtnDownPic = "newGreenBtn.png","newGreenBtn_down.png"
    end
    local cancelMenuItem=GetButtonItem(cancelBtnPic,cancelBtnDownPic,cancelBtnDownPic,touchCancelFunc,2,btnStr,25/scale)
    cancelMenuItem:setAnchorPoint(ccp(0.5,0.5))
    cancelMenuItem:setScale(scale)
    local cancelMenuBtn=CCMenu:createWithItem(cancelMenuItem)
    cancelMenuBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2+140,60))
    cancelMenuBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(cancelMenuBtn,2)
    end


    if closeFlag==nil or closeFlag==false then
        -- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        -- pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
        -- self.bgLayer:addChild(pointSp1)
        -- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
        -- pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
        -- self.bgLayer:addChild(pointSp2)
    end

    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end