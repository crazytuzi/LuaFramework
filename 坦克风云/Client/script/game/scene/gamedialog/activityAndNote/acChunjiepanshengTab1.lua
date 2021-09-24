acChunjiepanshengTab1={}

function acChunjiepanshengTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.isToday=nil
    self.height = 120
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 40
    end
	return nc
end

function acChunjiepanshengTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
    self:initBg()
	self:initLayer1()
    self:initTableView()

    -- local function addTaskPoint(event,data)
    --     self:refresh(data)
    -- end
    -- self.addTaskPointListener=addTaskPoint
    -- eventDispatcher:addEventListener("chunjiepansheng.addTaskPoint",addTaskPoint)

	return self.bgLayer
end

function acChunjiepanshengTab1:initBg()
    local acBg--=CCSprite:create("public/acWanshengjiedazuozhanBg2.jpg")
    local version = acChunjiepanshengVoApi:getVersion()
    if version and version==4 then
        acBg=CCSprite:create("public/acChunjiepanshengBg_v4.jpg")
        acBg:setAnchorPoint(ccp(0.5,1))
        acBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
        if G_isIphone5()==true then
            acBg:setScaleY(1.07)
        else
            acBg:setScaleY(0.87)
        end
    else
        if version and version==3 then
            acBg=CCSprite:create("public/acChunjiepanshengBg.jpg")
        else
            acBg=CCSprite:create("public/acWanshengjiedazuozhanBg2.jpg")
        end
        acBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-50))
        acBg:setAnchorPoint(ccp(0.5,0.5))
        acBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-110)
        acBg:setOpacity(180)
        acBg:setScale(0.96)
    end
    acBg:setAnchorPoint(ccp(0.5,0.5))
    acBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-110-self.adaH)
    acBg:setOpacity(180)
    acBg:setScale(0.96)
    self.bgLayer:addChild(acBg)

    local capInSet = CCRect(20, 20, 10, 10);
    local function nilFunc(hd,fn,idx)
    end
    local upLayer =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
    upLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,354))
    upLayer:ignoreAnchorPointForPosition(false)
    upLayer:setTouchPriority(-(self.layerNum-1)*20-3)
    upLayer:setAnchorPoint(ccp(0,1))
    upLayer:setPosition(ccp(0,G_VisibleSizeHeight))
    self.bgLayer:addChild(upLayer)
    upLayer:setVisible(false)

    local downLayer =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
    downLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,40))
    downLayer:ignoreAnchorPointForPosition(false)
    downLayer:setTouchPriority(-(self.layerNum-1)*20-3)
    downLayer:setAnchorPoint(ccp(0,0))
    downLayer:setPosition(ccp(0,0))
    self.bgLayer:addChild(downLayer)
    downLayer:setVisible(false)

end

function acChunjiepanshengTab1:initLayer1()
    local version = acChunjiepanshengVoApi:getVersion()

  	local function bgClick()
  	end
    
    local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
    local h = G_VisibleSizeHeight - 165
    if version and version==4 then
        w = G_VisibleSizeWidth - 30 -- 背景框的宽度
    end
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
    backSprie:setContentSize(CCSizeMake(w, 130))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setOpacity(0)
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2, h))
    self.bgLayer:addChild(backSprie)
  
    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
            if version and version==4 then
                local tabStr = {
                    getlocal("activity_chunjiepansheng_tip1"),
                    getlocal("activity_chunjiepansheng_tip2"),
                    getlocal("activity_chunjiepansheng_tip3"),
                    getlocal("activity_chunjiepansheng_tip4"),
                    getlocal("activity_chunjiepansheng_tip5")
                }
                local tabColor = {
                    nil, nil, nil, nil, G_ColorRed
                }
                local titleStr=getlocal("activity_baseLeveling_ruleTitle")
                require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
                tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,tabColor,25)
            else
                local tabStr={};
                local tabColor ={};
                local td=smallDialog:new()
                tabStr = {"\n",getlocal("activity_chunjiepansheng_tip5"),getlocal("activity_chunjiepansheng_tip4"),getlocal("activity_chunjiepansheng_tip3"),getlocal("activity_chunjiepansheng_tip2"),getlocal("activity_chunjiepansheng_tip1"),"\n"}
                local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil,nil,nil})
                sceneGame:addChild(dialog,self.layerNum+1)
            end
        end
       
    end

    w = w - 10 -- 按钮的x坐标
    local menuItemDesc, menuItemScale
    if version and version==4 then
        menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,nil,nil,0)
        menuItemScale=1
    else
        menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
        menuItemScale=0.8
    end
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(menuItemScale)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(w-10, backSprie:getContentSize().height-10))
    if version and version==4 then
        menuDesc:setPositionX(w)
    end
    backSprie:addChild(menuDesc)

    local bsH = backSprie:getContentSize().height-10
    local messageLabel
    if version and version==4 then
        messageLabel=GetTTFLabel(acChunjiepanshengVoApi:getTimeStr(),24)
        messageLabel:setAnchorPoint(ccp(0.5,1))
        messageLabel:setPosition(ccp((G_VisibleSizeWidth - 75)/2, bsH))
    else    
        local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
        acLabel:setAnchorPoint(ccp(0.5,1))
        acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, bsH))
        backSprie:addChild(acLabel)
        acLabel:setColor(G_ColorGreen)

        bsH = bsH - acLabel:getContentSize().height-5
        local acVo = acChunjiepanshengVoApi:getAcVo()
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        messageLabel=GetTTFLabel(timeStr,25)
        messageLabel:setAnchorPoint(ccp(0.5,1))
        messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, bsH))
    end
    backSprie:addChild(messageLabel)
    self.timeLb=messageLabel
    self:updateAcTime()


    bsH = bsH - messageLabel:getContentSize().height-10
    local upLb--=getlocal("activity_chunjiepansheng_taskDesc")
    local version = acChunjiepanshengVoApi:getVersion()
    if version and version==3 then
        upLb=getlocal("activity_chunjiepansheng_taskDesc_ver"..version)
    else
        upLb=getlocal("activity_chunjiepansheng_taskDesc")
    end
    if version and version==4 then
        local desLabel=GetTTFLabelWrap(upLb,24,CCSizeMake(w-75,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        desLabel:setAnchorPoint(ccp(0,1))
        desLabel:setPosition(15,bsH)
        desLabel:setColor(G_ColorYellowPro)
        backSprie:addChild(desLabel)
    else
        local desTv, desLabel = G_LabelTableView(CCSizeMake(w-10, bsH),upLb,25)
        backSprie:addChild(desTv)
        desTv:setPosition(ccp(15,8-self.adaH))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
        desTv:setMaxDisToBottomOrTop(120)
        desLabel:setColor(G_ColorOrange)
    end

    local myPoint=acChunjiepanshengVoApi:getMyPoint()
    local myTaskPointStr=getlocal("activity_chunjiepansheng_myTaskPoint") .. ":" .. myPoint
    local pointLbFontSize,pointLbW=25,400
    if version and version==4 then
        pointLbFontSize,pointLbW=30,280
    end
    local myTaskPointLb=GetTTFLabelWrap(myTaskPointStr,pointLbFontSize,CCSizeMake(pointLbW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    myTaskPointLb:setAnchorPoint(ccp(0.5,0.5))
    myTaskPointLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-345+7+25-self.adaH))
    self.bgLayer:addChild(myTaskPointLb,1)
    self.myTaskPointLb=myTaskPointLb

    if version and version==4 then
        myTaskPointLb:setPosition(G_VisibleSizeWidth/2+55,G_VisibleSizeHeight-285)
        myTaskPointLb:setColor(G_ColorYellowPro)
        local pointBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_caidai_v4.png",CCRect(43,34,2,2),bgClick)
        pointBg:setContentSize(CCSizeMake(300,pointBg:getContentSize().height))
        pointBg:setPosition(G_VisibleSizeWidth/2+55,G_VisibleSizeHeight-285)
        self.bgLayer:addChild(pointBg)
    else
        local picStr="acChunjiepansheng_caidai.png"
        local version = acChunjiepanshengVoApi:getVersion()
        if version and version==3 then
            picStr="acChunjiepansheng_caidai3.png"
        end
        local pointBg=LuaCCScale9Sprite:createWithSpriteFrameName(picStr,CCRect(85,26,2,2),bgClick)
        pointBg:setContentSize(CCSizeMake(400,60))
        pointBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-345+25-self.adaH))
        self.bgLayer:addChild(pointBg)
    end

end

function acChunjiepanshengTab1:initTableView()
    local version = acChunjiepanshengVoApi:getVersion()
    self.taskPoint=acChunjiepanshengVoApi:getTaskPoint()
    self.numberCell = SizeOfTable(self.taskPoint)

    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callback)
    if version and version==4 then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight-175),nil)
        self.tv:setPosition(ccp(30,15))
        -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.bgLayer:addChild(self.tv,1)
    else
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight-400),nil)
        self.tv:setPosition(ccp(30,40-self.adaH))
        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.bgLayer:addChild(self.tv,1)
        self.tv:setMaxDisToBottomOrTop(120)
    end

    -- local recordPoint = self.tv:getRecordPoint()
    -- recordPoint.y = 0
    -- self.tv:recoverToRecordPoint(recordPoint)
end


function acChunjiepanshengTab1:eventHandler(handler,fn,idx,cel)
    local strSize2 = 15
    local strSize3 = 18
    local version = acChunjiepanshengVoApi:getVersion()
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =22
        strSize3 =25
    end
  	if fn=="numberOfCellsInTableView" then
  		return 1
  	elseif fn=="tableCellSizeForIndex" then
        if version and version==4 then
           return  CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight-175)
       else
    	   return  CCSizeMake(G_VisibleSizeWidth - 60,self.height*self.numberCell+self.height)
        end
  	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
        local totalH = self.height*self.numberCell
        local addH=0
        -- if (G_isIphone5()) then
        --     addH=0
        -- else
            addH=30
        -- end
        if version and version==4 then
            totalH=G_VisibleSizeHeight-175
            -- addH=-20
        end
        for i=1,self.numberCell do
            local _posY=0
            if version and version==4 then
                _posY = (totalH-200-90)/self.numberCell*i+68+5
            end

            local capInSet = CCRect(20, 20, 10, 10)
            local function cellClick()
            end
            local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-280, 80))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0.5))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
            backSprie:setPosition(220,0+i*self.height+addH)
            cell:addChild(backSprie,1)
            backSprie:setOpacity(0)
            if version and version==4 then
                if G_isIphone5()==false and i~=self.numberCell then
                    backSprie:setPositionY(_posY-25-15)
                else
                    backSprie:setPositionY(_posY-15)
                end
            end

            local bgdiSp = CCSprite:createWithSpriteFrameName("acLabelbg.png")
            backSprie:addChild(bgdiSp)
            bgdiSp:setScaleX(backSprie:getContentSize().width/bgdiSp:getContentSize().width)
            bgdiSp:setScaleY(backSprie:getContentSize().height/bgdiSp:getContentSize().height)
            bgdiSp:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)

            -- 礼包
            local function touchReward()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                

                    local flag = acChunjiepanshengVoApi:taskPointState(i,self.taskPoint)
                    local reward = acChunjiepanshengVoApi:getTaskPointReward(i)
                    local rewardItem=FormatItem(reward,nil,true)

                    if flag==2 then
                        local function callback()
                            acChunjiepanshengVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_chunjiepansheng_getReward"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem,true)
                            for k,v in pairs(rewardItem) do
                                if v.type~="p" then
                                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                end
                            end

                            G_showRewardTip(rewardItem,nil,nil,false)

                            local recordPoint=self.tv:getRecordPoint()
                            self.tv:reloadData()
                            self.tv:recoverToRecordPoint(recordPoint)
                        end
                        local action=1
                        local tid=i
                        acChunjiepanshengVoApi:getSocketReward(action,nil,tid,callback)
                        return
                    end
                    local desStr2=getlocal("activity_chunjiepansheng_taskReward" .. i)
                    acChunjiepanshengVoApi:showSmallDialog(true,true,self.layerNum+1,desStr2,"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem)
                   
                end
            end
            local rewardPic = "friendBtn.png"
            if version and version==4 then
                rewardPic = "packs"..(i+1)..".png"
            end
            local scale=0.9
            local scale2=1.2
            if i==self.numberCell then
                if version and version==4 then
                    rewardPic = "packs6.png"
                else
                    rewardPic = "mainBtnGift.png"
                end
                if version and version==4 then
                    scale=1.1
                    scale2=1.3
                else
                    scale=1.3
                    scale2=1.5
                end

                local guangSp1 = CCSprite:createWithSpriteFrameName("equipShine.png")
                guangSp1:setPosition(-60,backSprie:getContentSize().height/2)
                backSprie:addChild(guangSp1)

                local guangSp2 = CCSprite:createWithSpriteFrameName("equipShine.png")
                guangSp2:setPosition(-60,backSprie:getContentSize().height/2)
                backSprie:addChild(guangSp2)

                local rotateBy = CCRotateBy:create(4,360)
                local reverseBy = rotateBy:reverse()
                guangSp1:runAction(CCRepeatForever:create(rotateBy))
                guangSp2:runAction(CCRepeatForever:create(reverseBy))
            end
            local rewardSp = LuaCCSprite:createWithSpriteFrameName(rewardPic,touchReward)
            rewardSp:setTouchPriority(-(self.layerNum-1)*20-2)
            rewardSp:setPosition(170,i*self.height+addH)
            cell:addChild(rewardSp,3)
            rewardSp:setScale(scale)
            if version and version==4 then
                if G_isIphone5()==false and i~=self.numberCell then
                    rewardSp:setPositionY(_posY-25)
                else
                    rewardSp:setPositionY(_posY)
                end
            end
            

            local flag = acChunjiepanshengVoApi:taskPointState(i,self.taskPoint)
            local libaoStr=""
            local color=G_ColorWhite
            if flag==3 then
                libaoStr=getlocal("activity_chunjiepansheng_click_kan")
                color=G_ColorWhite
            elseif flag==2 then
                rewardSp:runAction(self:canRewardAction(scale,scale2))
                self:particleAction(rewardSp)

                libaoStr=getlocal("canReward")
                color=G_ColorGreen
            elseif flag==1 then
                libaoStr=getlocal("activity_hadReward")
                color=G_ColorWhite
            end

            local libaoLb=GetTTFLabelWrap(libaoStr,strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            libaoLb:setAnchorPoint(ccp(0.5,0.5))
            libaoLb:setColor(color)
            libaoLb:setPosition(ccp(rewardSp:getContentSize().width/2,0))
            rewardSp:addChild(libaoLb,2)
            libaoLb:setScale(1/scale)

            local titleBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
            titleBg:setScaleX(120/titleBg:getContentSize().width*1/scale)
            titleBg:setScaleY(1/scale)
            titleBg:setPosition(ccp(rewardSp:getContentSize().width/2,0))
            titleBg:setOpacity(160)
            rewardSp:addChild(titleBg)

            -- 描述
            local desStr1=getlocal("activity_chunjiepansheng_taskPoint",{self.taskPoint[i]})
            local desLb1=GetTTFLabelWrap(desStr1,25,CCSizeMake(G_VisibleSizeWidth-300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            desLb1:setAnchorPoint(ccp(0.5,0.5))
            desLb1:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/4*3))
            backSprie:addChild(desLb1)

            local desStr2=getlocal("activity_chunjiepansheng_taskReward" .. i)
            local canGet=getlocal("activity_vipAction_get")
            local desLb2=GetTTFLabelWrap(canGet .. desStr2,strSize3,CCSizeMake(G_VisibleSizeWidth-300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            desLb2:setAnchorPoint(ccp(0.5,0.5))
            desLb2:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/4*1))
            backSprie:addChild(desLb2)
            desLb2:setColor(G_ColorGreen)

            if i==self.numberCell then
                desLb2:setColor(G_ColorYellowPro)
            end

            -- 渐变线条
            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
            backSprie:addChild(lineSp)
            lineSp:setScaleX(0.5)
            lineSp:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)
            lineSp:setVisible(false)

            -- 刻度线
            local keduSp
            if version and version==3 then
                keduSp = CCSprite:createWithSpriteFrameName("acChunjiepansheng_fengexian3.png")
            else
                keduSp = CCSprite:createWithSpriteFrameName("acChunjiepansheng_fengexian.png")
            end
            keduSp:setPosition(44,i*self.height+addH)
            cell:addChild(keduSp,3)
            if version and version==4 then
                keduSp:setVisible(false)
            end

            -- local per=self.taskPoint[i]/self.taskPoint[self.numberCell]
            -- keduSp:setPosition(44,self.numberCell*self.height*per+addH)

            -- 数字背景
            if i~=self.numberCell then
                local numBgSp
                if version and version==4 then
                    numBgSp = CCSprite:createWithSpriteFrameName("acChunjiepansheng_numBg_v4.png")
                elseif version and version==3 then
                    numBgSp = CCSprite:createWithSpriteFrameName("acChunjiepansheng_numBg3.png")
                else
                    numBgSp = CCSprite:createWithSpriteFrameName("acChunjiepansheng_numBg.png")
                end
                numBgSp:setAnchorPoint(ccp(0,0.5))
                numBgSp:setPosition(53,i*self.height+addH)
                cell:addChild(numBgSp,3)
                -- numBgSp:setPosition(53,self.numberCell*self.height*per+addH)

                if version and version==4 then
                    numBgSp:setPositionX(28)

                    -- TODO TEST
                    -- numBgSp:setPositionY( (totalH-200-90)*(self.taskPoint[i]/self.taskPoint[self.numberCell])+68+5 )
                    -- numBgSp:setPositionY( (totalH-200-90)/self.numberCell*i+68+5 )
                    numBgSp:setPositionY(_posY)

                    local numLb=GetTTFLabel(self.taskPoint[i],18)
                    numLb:setAnchorPoint(ccp(1,0.5))
                    numLb:setPosition(numBgSp:getContentSize().width-10,numBgSp:getContentSize().height/2)
                    numBgSp:addChild(numLb)
                else
                    local numLb=GetTTFLabel(self.taskPoint[i],22)
                    numLb:setPosition(numBgSp:getContentSize().width/2,numBgSp:getContentSize().height/2)
                    numBgSp:addChild(numLb)
                end
            end
            


        end

        local barWidth = totalH
        local function click(hd,fn,idx)
        end
        local barSprieStr
        local barSprieRect=CCRect(42,42,2,2)
        if version and version==4 then
            barSprieStr="acChunjiepansheng_progressBg_v4.png"
            barSprieRect=CCRect(40,103,2,1)
        elseif version and version==3 then
            barSprieStr="acChunjiepansheng_progressBg3.png"
        else
            barSprieStr="acChunjiepansheng_progressBg.png"
        end
        local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName(barSprieStr, barSprieRect,click)
        -- barSprie:setContentSize(CCSizeMake(barWidth, 86))
        if version and version==4 then
            barSprie:setContentSize(CCSizeMake(barSprie:getContentSize().width, totalH-200))
            barSprie:setPosition(ccp(44,barSprie:getContentSize().height/2+5))
        else
            barSprie:setContentSize(CCSizeMake(86, barWidth+25))
            barSprie:setPosition(ccp(44,barWidth/2+addH))
        end
        cell:addChild(barSprie,1)

        local dingSp
        if version and version==4 then
            dingSp=CCSprite:createWithSpriteFrameName("acChunjiepansheng_limit_v4.png")
        elseif version and version==3 then
            dingSp=CCSprite:createWithSpriteFrameName("acChunjiepansheng_limit3.png")
        else
            dingSp=CCSprite:createWithSpriteFrameName("acChunjiepansheng_limit.png")
        end
        dingSp:setAnchorPoint(ccp(0.5,0))
        dingSp:setPosition(barSprie:getContentSize().width/2,barSprie:getContentSize().height-10)
        barSprie:addChild(dingSp)

        local numLb=GetTTFLabel(self.taskPoint[self.numberCell],22)
        numLb:setPosition(dingSp:getContentSize().width/2,dingSp:getContentSize().height/2+3)
        dingSp:addChild(numLb)

        if version and version==4 then
            numLb:setPosition(dingSp:getContentSize().width/2,40)
            numLb:setColor(G_ColorYellowPro)

            local per = acChunjiepanshengVoApi:getPercentage()
            local progressBar=CCSprite:createWithSpriteFrameName("acChunjiepansheng_porgressBar_v4.png")
            progressBar:setAnchorPoint(ccp(0.5,0))
            progressBar:setPosition(barSprie:getContentSize().width/2+3,68)
            progressBar:setScaleY((barSprie:getContentSize().height-90)*(per/100)/progressBar:getContentSize().height)
            barSprie:addChild(progressBar)
        else
            local barSpStr,barBgStr
            local version = acChunjiepanshengVoApi:getVersion()
            if version and version==3 then
                barSpStr,barBgStr="acChunjiepansheng_progress13.png","acChunjiepansheng_progress23.png"
            else
                barSpStr,barBgStr="acChunjiepansheng_progress1.png","acChunjiepansheng_progress2.png"
            end
            AddProgramTimer(cell,ccp(44,barWidth/2+addH),11,12,nil,barBgStr,barSpStr,13,1,1,nil,ccp(0,1))
            local per = acChunjiepanshengVoApi:getPercentage()
            local timerSpriteLv = cell:getChildByTag(11)
            timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
            timerSpriteLv:setPercentage(per)
            timerSpriteLv:setScaleY((barWidth)/timerSpriteLv:getContentSize().height)
            timerSpriteLv:setRotation(180)
            local bg = cell:getChildByTag(13)
            bg:setScaleY((barWidth)/bg:getContentSize().height)
            bg:setScaleX(1.2)
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

-- scale1:初始大小
function acChunjiepanshengTab1:canRewardAction(scale1,scale2)
    local scaleTo1=CCScaleTo:create(0.3,scale2)
    local scaleTo2=CCScaleTo:create(0.3,scale1)
    local array=CCArray:create()
    array:addObject(scaleTo1)
    array:addObject(scaleTo2)
    local seq=CCSequence:create(array)
    local everAction=CCRepeatForever:create(seq)
    return everAction
end

function acChunjiepanshengTab1:particleAction(rewardSp)
    local p = CCParticleSystemQuad:create("public/xingxing.plist")
    p.positionType = kCCPositionTypeFree
    p:setPosition(ccp(rewardSp:getContentSize().width/2,rewardSp:getContentSize().height/2))
    rewardSp:addChild(p,3)
    p:setScale(0.7)

end

function acChunjiepanshengTab1:refresh()
    if self.myTaskPointLb then
        local myPoint=acChunjiepanshengVoApi:getMyPoint()
        local myTaskPointStr=getlocal("activity_chunjiepansheng_myTaskPoint") .. ":" .. myPoint
        self.myTaskPointLb:setString(myTaskPointStr)
    end
    
    if self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acChunjiepanshengTab1:tick()
    self:updateAcTime()
end

function acChunjiepanshengTab1:updateAcTime()
    local version=acChunjiepanshengVoApi:getVersion()
    if version and version==4 then
        if self and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
            self.timeLb:setString(acChunjiepanshengVoApi:getTimeStr())
        end
    else
        local acVo=acChunjiepanshengVoApi:getAcVo()
        if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
            G_updateActiveTime(acVo,self.timeLb)
        end
    end
end

function acChunjiepanshengTab1:dispose()
    -- eventDispatcher:removeEventListener("chunjiepansheng.addTaskPoint",self.addTaskPointListener)
end