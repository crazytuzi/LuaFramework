acArmoredStromDialog = commonDialog:new()

function acArmoredStromDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.isToday=true
    nc.cellHight=170
    if G_getIphoneType() == G_iphoneX then
        nc.cellHight = 160
    end
    nc.cellArr={}
    local function addPlist()
    	spriteController:addPlist("public/emblemSkillBg.plist")
	    spriteController:addTexture("public/emblemSkillBg.png")
        spriteController:addPlist("public/acArmoredStorm_image.plist")
        spriteController:addTexture("public/acArmoredStorm_image.png")
        spriteController:addPlist("public/acNewYearsEva.plist")
        spriteController:addTexture("public/acNewYearsEva.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    return nc
end

function acArmoredStromDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function acArmoredStromDialog:initTableView( )
    self.taskTb1=acArmoredStormVoApi:getTaskTbByType(1)
    self.taskTb2=acArmoredStormVoApi:getTaskTbByType(2)
    -- self.taskTb=acArmoredStormVoApi:getTaskTb1()

    self.taskNum=SizeOfTable(self.taskTb1)

    local function noData( ) end
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),noData)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 420))
    tvBg:setAnchorPoint(ccp(0,0))
    -- tvBg:setOpacity(200)
    tvBg:setPosition(ccp(10,25))
    self.bgLayer:addChild(tvBg,1)

    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,1))
    goldLineSprite1:setScaleX(tvBg:getContentSize().width/goldLineSprite1:getContentSize().width)
    goldLineSprite1:setPosition(ccp(tvBg:getContentSize().width*0.5,tvBg:getContentSize().height-3))
    tvBg:addChild(goldLineSprite1,1)

	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 450),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(20,30)
	self.bgLayer:addChild(self.tv,1)
	self.tv:setMaxDisToBottomOrTop(80)

    -- print("self.cellArr nums------>",SizeOfTable(self.cellArr))
end

-- 仿照全线突围活动 acQxtwVoApi:getCurrentTaskState()
function acArmoredStromDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.taskNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 40,self.cellHight)
	elseif fn=="tableCellAtIndex" then
        local strSize3,strSize4,strSize5 = 22,22,25
        if G_getCurChoseLanguage() =="ru" then
            strSize3,strSize4,strSize5 = 18,20,22
        end
		local cell=CCTableViewCell:new()
        self.cellArr[idx+1] = cell
		cell:autorelease()
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
		background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,self.cellHight-10))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(0,5))
		cell:addChild(background)

        local trueIndex=self.taskTb[idx+1].trueIndex
        local index=self.taskTb[idx+1].index
        local haveNum=self.taskTb[idx+1].haveNum

        local taskInfo
        -- print("self.trueNbTag---->",self.trueNbTag)
        if self.trueNbTag==1 then
            taskInfo=self.taskTb1["t" .. trueIndex]
        else
            taskInfo=self.taskTb2["t" .. trueIndex]
        end


        local taskDes=""
        if self.trueNbTag==1 then
            taskDes=getlocal("activity_zjfb_taskType1",{haveNum .. "/" .. taskInfo[2]})
        else
            taskDes=getlocal("activity_zjfb_taskType2",{haveNum .. "/" .. taskInfo[2]})
        end

        local taskDesLb=GetTTFLabelWrap(taskDes,strSize4,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        taskDesLb:setAnchorPoint(ccp(0,0.5))
        -- taskDesLb:setColor(G_ColorYellowPro)
        taskDesLb:setPosition(ccp(30,self.cellHight-35))
        background:addChild(taskDesLb)

		local leftLineSP =CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        leftLineSP:setAnchorPoint(ccp(0,0.5))
        -- leftLineSP:setPosition(ccp(15,background:getContentSize().height-20-titleLb:getContentSize().height))
        leftLineSP:setPosition(ccp(15,background:getContentSize().height-20-30))
        background:addChild(leftLineSP,1)

        -- local desH=(self.cellHight - titleLb:getContentSize().height-20)/2
        local desH=(self.cellHight - 20 -20-20)/2
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),strSize3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(30,desH))
        background:addChild(desLb)

        local reward=taskInfo[3]
        local rewardItem=FormatItem(reward,nil,true)
        local starW=150
        for k,v in pairs(rewardItem) do
            -- print("v.name--->",v.name,v.pic)
            local icon=G_getItemIcon(v,100,true,self.layerNum)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            icon:setPosition(ccp(starW+(k-1)*80,desH))
            background:addChild(icon)
            icon:setScale(80/icon:getContentSize().width)

            if acArmoredStormVoApi:isFlick(v.type,v.key,v.num) then
                G_addRectFlicker2(icon,1.2,1.2,2,"p")
            end

            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-10,3)
            icon:addChild(numLabel,1)
            numLabel:setScale(1/icon:getScale())
        end

        if index>10000 then -- 已完成(已领取)
            local desLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            desLb:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(desLb)
            desLb:setColor(G_ColorGray)
        elseif index>1000 then -- 未完成
            local expiredStr = GetTTFLabelWrap(getlocal("noReached"),strSize5,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--activity_hadReward
            expiredStr:setAnchorPoint(ccp(0.5,0.5))
            expiredStr:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(expiredStr)

        else -- 可领取
            local function rewardTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    local function refreshFunc(rewardlist)
                        -- print("in callback       self.trueNbTag---->",self.trueNbTag)
                        self:changTask(self.trueNbTag,true)

                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)

                        for k,v in pairs(rewardItem) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end

                        G_showRewardTip(rewardItem,true)
                    end
                    acArmoredStormVoApi:socketReward(self.trueNbTag,trueIndex,refreshFunc)
                
                end
            end
            local rewardItem=GetButtonItem("taskReward.png","taskReward_down.png","taskReward_down.png",rewardTiantang,nil)
            -- rewardItem:setScale(0.8)
            local rewardBtn=CCMenu:createWithItem(rewardItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(rewardBtn)

            G_addFlicker(rewardItem,2,2)
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

function acArmoredStromDialog:doUserHandler()
    local function touch2( ) 
        print("wholeTouchBgSp~~~~~~~~") 
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
    end 
    self.wholeTouchBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch2)--拉霸动画背景
    self.wholeTouchBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth+40,G_VisibleSizeHeight+500))
    self.wholeTouchBgSp:setTouchPriority(-(self.layerNum-1)*20-20)
    self.wholeTouchBgSp:setIsSallow(true)
    self.wholeTouchBgSp:setAnchorPoint(ccp(0.5,0))
    self.wholeTouchBgSp:setOpacity(0)
    self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5500))
    self.bgLayer:addChild(self.wholeTouchBgSp,30)
    self.wholeTouchBgSp:setVisible(false)



    local function onLoadIcon(fn,icon)
        if self and self.bgLayer and icon then
            self.bgLayer:addChild(icon)
            icon:setScaleX(self.bgLayer:getContentSize().width/icon:getContentSize().width)
            icon:setScaleY((self.bgLayer:getContentSize().height-80)/icon:getContentSize().height)
            icon:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40)
            icon:setOpacity(180)
        end
    end
    local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("active/buyreward/acBuyrewardjpg4.jpg"),onLoadIcon)


	local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
    headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,300))
    headerSprie:setOpacity(0)
    headerSprie:setAnchorPoint(ccp(0.5,1))
    headerSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    headerSprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95))
    self.bgLayer:addChild(headerSprie,1)
    self.headerSprie = headerSprie

    local hs=headerSprie:getContentSize().height
    local ws=headerSprie:getContentSize().width
    hs=hs-10

	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),27)
	actTime:setAnchorPoint(ccp(0.5,1))
	actTime:setPosition(ccp(ws/2,hs))
	headerSprie:addChild(actTime)
	actTime:setColor(G_ColorGreen)

	hs=hs-actTime:getContentSize().height-5

	local tabStr={" ",getlocal("activity_zjfb_tip2"),getlocal("activity_zjfb_tip1")," "}
	G_addMenuInfo(headerSprie,self.layerNum,ccp(ws-50,hs),tabStr,nil,0.9,28,nil,true)
    
    local acVo=acArmoredStormVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,24)
    timeLabel:setAnchorPoint(ccp(0.5,1))
    timeLabel:setPosition(ccp(ws/2, hs))
    headerSprie:addChild(timeLabel,1)
    self.timeLb=timeLabel
    self:updateAcTime()

    hs=hs-timeLabel:getContentSize().height-5
    local strSize2 = 16
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 = 24
    end
    local acDesLb=GetTTFLabelWrap(getlocal("activity_zjfb_des"),strSize2,CCSizeMake(ws-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    acDesLb:setAnchorPoint(ccp(0.5,1))
    headerSprie:addChild(acDesLb)
    acDesLb:setPosition(headerSprie:getContentSize().width*0.5,hs)

    self.nbTag=1
    self.trueNbTag = 1
    local function touchArmorSp1()
  --       print("touchArmorSp1111~~~~~~",self.nbTag)
  --   	if G_checkClickEnable()==false then
		--     do
		--         return
		--     end
		-- else
		--     base.setWaitTime=G_getCurDeviceMillTime()
		-- end
		-- if self.nbTag==1 then return end

  --       if self.yellowBtn and self.greenBtn then

  --           local posX1 = self.yellowBtn:getPositionX()
  --           local posY1 = self.yellowBtn:getPositionY()
  --           local posX2 = self.greenBtn:getPositionX()
  --           local posY2 = self.greenBtn:getPositionY()
  --           self.yellowBtn:setPosition(ccp(posX2,posY2))
  --           self.greenBtn:setPosition(ccp(posX1,posY1))
            
  --           self.headerSprie:reorderChild(self.embleDiSp1,2)
  --           self.headerSprie:reorderChild(self.embleDiSp2,1)
  --       end
		-- PlayEffect(audioCfg.mouseClick)
        -----------
        -- self.nbTag=1
		-- self.shineSp2:setVisible(false)
		-- self.shineSp1:setVisible(true)
		-- self:changeColor(1)
  --       self:changTask(1)
    end

    local embleDiSp1=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
    headerSprie:addChild(embleDiSp1,2)
    self.embleDiSp1 = embleDiSp1
    embleDiSp1:setAnchorPoint(ccp(0.5,0.5))
    embleDiSp1:setOpacity(0)
    embleDiSp1:setContentSize(CCSizeMake(headerSprie:getContentSize().width*0.55,headerSprie:getContentSize().height*0.35))
    embleDiSp1:setPosition(ccp(headerSprie:getContentSize().width*0.3,headerSprie:getContentSize().height*0.43))

    local shineSp1=CCSprite:createWithSpriteFrameName("equipShine.png")
    embleDiSp1:addChild(shineSp1,1)
    shineSp1:setPosition(embleDiSp1:getContentSize().width*0.25,embleDiSp1:getContentSize().height*0.5)
    shineSp1:setScale(embleDiSp1:getContentSize().height/shineSp1:getContentSize().width)
    self.shineSp1=shineSp1

    local armorSp1=CCSprite:createWithSpriteFrameName("armorMatrix_1.png")
    embleDiSp1:addChild(armorSp1,2)
    armorSp1:setPosition(embleDiSp1:getContentSize().width*0.25,embleDiSp1:getContentSize().height*0.5)
    armorSp1:setScale(embleDiSp1:getContentSize().height/armorSp1:getContentSize().width)

    local embleLb1=GetTTFLabelWrap(getlocal("activity_zjfb_collect"),24,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    embleLb1:setAnchorPoint(ccp(0.5,0.5))
    embleDiSp1:addChild(embleLb1,2)
    embleLb1:setPosition(ccp(embleDiSp1:getContentSize().width*0.65,embleDiSp1:getContentSize().height*0.5))
    embleLb1:setColor(G_ColorYellowPro)
    self.embleLb1 = embleLb1

    local lbBg = LuaCCScale9Sprite:createWithSpriteFrameName("redLineLight.png",CCRect(43,12,1,1),function () end)
    lbBg:setScaleX(embleLb1:getContentSize().width/lbBg:getContentSize().width)
    lbBg:setScaleY(embleLb1:getContentSize().height*1.4/lbBg:getContentSize().height)
    lbBg:setPosition(ccp(embleLb1:getPositionX(),embleLb1:getPositionY()))
    embleDiSp1:addChild(lbBg,1)
    self.lbBg1 = lbBg

    local coverSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function () end)
    coverSp1:setContentSize(CCSizeMake(embleDiSp1:getContentSize().width,embleDiSp1:getContentSize().height))
    coverSp1:setOpacity(100)
    coverSp1:setPosition(getCenterPoint(embleDiSp1))
    coverSp1:setVisible(false)
    embleDiSp1:addChild(coverSp1,5)
    self.coverSp1 = coverSp1

------------------====-----=====-----------------
    local embleDiSp2=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
    headerSprie:addChild(embleDiSp2,1)
    self.embleDiSp2 = embleDiSp2
    embleDiSp2:setAnchorPoint(ccp(0.5,0.5))
    embleDiSp2:setOpacity(0)
    embleDiSp2:setContentSize(CCSizeMake(headerSprie:getContentSize().width*0.55,headerSprie:getContentSize().height*0.35))
    embleDiSp2:setScale(0.9)
    embleDiSp2:setPosition(ccp(headerSprie:getContentSize().width*0.44,headerSprie:getContentSize().height*0.18))

    local shineSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
    embleDiSp2:addChild(shineSp2,1)
    shineSp2:setPosition(embleDiSp2:getContentSize().width*0.25,embleDiSp2:getContentSize().height*0.5)
    shineSp2:setScale(embleDiSp2:getContentSize().height/shineSp2:getContentSize().width)
    self.shineSp2=shineSp2

    local armorSp2=CCSprite:createWithSpriteFrameName("armorMatrix_2.png")
    embleDiSp2:addChild(armorSp2,2)
    armorSp2:setPosition(embleDiSp2:getContentSize().width*0.25,embleDiSp2:getContentSize().height*0.5)
    armorSp2:setScale(embleDiSp2:getContentSize().height/armorSp2:getContentSize().width)

    local embleLb2=GetTTFLabelWrap(getlocal("activity_zjfb_strengthen"),24,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    embleLb2:setAnchorPoint(ccp(0.5,0.5))
    embleDiSp2:addChild(embleLb2,2)
    embleLb2:setPosition(ccp(embleDiSp2:getContentSize().width*0.65,embleDiSp2:getContentSize().height*0.5))
    self.embleLb2 = embleLb2
    -- embleLb2:setColor(G_ColorYellowPro)

    local lbBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("redLineLight.png",CCRect(43,12,1,1),function () end)
    lbBg2:setPosition(ccp(embleLb2:getPositionX(),embleLb2:getPositionY()))
    lbBg2:setScaleX(embleLb2:getContentSize().width/lbBg:getContentSize().width)
    lbBg2:setScaleY(embleLb2:getContentSize().height*1.4/lbBg2:getContentSize().height)
    lbBg2:setVisible(false)
    embleDiSp2:addChild(lbBg2,1)
    self.lbBg2 = lbBg2

    local coverSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function () end)
    coverSp2:setContentSize(CCSizeMake(embleDiSp2:getContentSize().width,embleDiSp2:getContentSize().height))
    coverSp2:setOpacity(100)
    coverSp2:setPosition(getCenterPoint(embleDiSp2))
    embleDiSp2:addChild(coverSp2,5)
    self.coverSp2 = coverSp2
---===================================================================================================================

    local function touchArmorSp2()
        -- print("touchArmorSp2222~~~~~~",self.nbTag)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.nbTag==2 then return end

        PlayEffect(audioCfg.mouseClick)
        -- self.nbTag=2
        if self.yellowBtn and self.greenBtn then

            local posX1 = self.yellowBtn:getPositionX()
            local posY1 = self.yellowBtn:getPositionY()
            local posX2 = self.greenBtn:getPositionX()
            local posY2 = self.greenBtn:getPositionY()
            self.yellowBtn:setPosition(ccp(posX2,posY2))
            self.greenBtn:setPosition(ccp(posX1,posY1))
            if self.embleDiSp1:getZOrder() == 2 then
                self.headerSprie:reorderChild(self.embleDiSp1,1)
                self.headerSprie:reorderChild(self.yellowBtn,1)
                self.headerSprie:reorderChild(self.embleDiSp2,2)
                self.embleLb1:setColor(G_ColorWhite)
                self.embleLb2:setColor(G_ColorYellowPro)
                self.embleDiSp1:setScale(0.9)
                self.embleDiSp2:setScale(1)

                self.shineSp1:setVisible(false)
                self.lbBg1:setVisible(false)
                self.coverSp2:setVisible(false)

                self.shineSp2:setVisible(true)
                self.lbBg2:setVisible(true)
                self.coverSp1:setVisible(true)

                self:changTask(2)
            else
                self.headerSprie:reorderChild(self.embleDiSp1,2)
                self.headerSprie:reorderChild(self.embleDiSp2,1)
                self.headerSprie:reorderChild(self.yellowBtn,1)
                self.embleLb2:setColor(G_ColorWhite)
                self.embleLb1:setColor(G_ColorYellowPro)
                self.embleDiSp1:setScale(1)
                self.embleDiSp2:setScale(0.9)

                self.shineSp2:setVisible(false)
                self.lbBg2:setVisible(false)
                self.coverSp1:setVisible(false)

                self.shineSp1:setVisible(true)
                self.lbBg1:setVisible(true)
                self.coverSp2:setVisible(true)

                self:changTask(1)
            end
        end
    end


    local yellowBg = GetButtonItem("asOreigeBg.png","asOreigeBg_Down.png","asOreigeBg.png",touchArmorSp1,nil)
    yellowBg:setScaleX(embleDiSp1:getContentSize().width/yellowBg:getContentSize().width)
    yellowBg:setScaleY(embleDiSp1:getContentSize().height/yellowBg:getContentSize().height)
    local yellowBtn = CCMenu:createWithItem(yellowBg)
    yellowBtn:setTouchPriority(-(self.layerNum-1)*20-5);
    yellowBtn:setBSwallowsTouches(true)
    yellowBtn:setPosition(ccp(embleDiSp1:getPositionX(),embleDiSp1:getPositionY()))
    headerSprie:addChild(yellowBtn,1)
    self.yellowBtn = yellowBtn

    local posTb = {ccp(3,yellowBg:getContentSize().height*0.71),ccp(yellowBg:getContentSize().width*0.5,3),ccp(yellowBg:getContentSize().width-4,yellowBg:getContentSize().height*0.31)}
    local rotationTb = {90,0,90}

    for i=1,3 do
        local yellowLineLight = CCSprite:createWithSpriteFrameName("yellowLineLight.png")
        yellowLineLight:setPosition(posTb[i])
        yellowLineLight:setRotation(rotationTb[i])
        yellowBg:addChild(yellowLineLight)
        if i == 2 then
            yellowLineLight:setScaleX(2.4)
        end
    end



    local greenBg = GetButtonItem("asGreenBg.png","asGreenBg_Down.png","asGreenBg.png",touchArmorSp2,nil)
    greenBg:setScaleX(embleDiSp2:getContentSize().width*0.9/greenBg:getContentSize().width)
    greenBg:setScaleY(embleDiSp2:getContentSize().height*0.9/greenBg:getContentSize().height)
    local greenBtn = CCMenu:createWithItem(greenBg)
    greenBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    greenBtn:setBSwallowsTouches(true)
    greenBtn:setPosition(ccp(embleDiSp2:getPositionX(),embleDiSp2:getPositionY()))
    headerSprie:addChild(greenBtn,0)
    self.greenBtn = greenBtn

    local function goDialog()
        -- print("here????in goDialog~~~~~")
         -- if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                activityAndNoteDialog:closeAllDialog()
                if self.trueNbTag==1 then
                    -- print("11111")
                    if armorMatrixVoApi:canOpenArmorMatrixDialog(true) then
                        local function showCallback()
                            armorMatrixVoApi:showArmorMatrixDialog(4)
                            armorMatrixVoApi:showRecruitDialog(5)
                        end
                        armorMatrixVoApi:armorGetData(showCallback)
                        return
                    end
                else
                    G_goToDialog2("armor",4,false)
                end
            -- end
    end
    local rewardItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",goDialog,nil,getlocal("activity_heartOfIron_goto"),25)
    rewardItem:setScale(0.8)
    local rewardBtn=CCMenu:createWithItem(rewardItem);
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    rewardBtn:setPosition(ccp(headerSprie:getContentSize().width-90,60))
    headerSprie:addChild(rewardBtn)


    self.shineSp2:setVisible(false)
    self:changeColor(1)

    local taskTb1=acArmoredStormVoApi:getTaskTb1()
    for k,v in pairs(taskTb1) do
        if v.index<1000 then
            self.taskTb=taskTb1
            return
        end
    end

    local taskTb2=acArmoredStormVoApi:getTaskTb2()
    for k,v in pairs(taskTb2) do
        if v.index<1000 then
            local posX1 = self.yellowBtn:getPositionX()
            local posY1 = self.yellowBtn:getPositionY()
            local posX2 = self.greenBtn:getPositionX()
            local posY2 = self.greenBtn:getPositionY()
            self.yellowBtn:setPosition(ccp(posX2,posY2))
            self.greenBtn:setPosition(ccp(posX1,posY1))
            
            self.taskTb=taskTb2
            self.trueNbTag = 2
            -- self.nbTag=2
            self.headerSprie:reorderChild(self.embleDiSp1,1)
            self.headerSprie:reorderChild(self.yellowBtn,1)
            self.headerSprie:reorderChild(self.embleDiSp2,2)
            self.embleLb1:setColor(G_ColorWhite)
            self.embleLb2:setColor(G_ColorYellowPro)
            self.embleDiSp1:setScale(0.9)
            self.embleDiSp2:setScale(1)

            self.shineSp1:setVisible(false)
            self.lbBg1:setVisible(false)
            self.coverSp2:setVisible(false)

            self.shineSp2:setVisible(true)
            self.lbBg2:setVisible(true)
            self.coverSp1:setVisible(true)

            -- self:changTask(2)
            return
        end
    end
    self.taskTb=taskTb1

end

function acArmoredStromDialog:changeColor(flag)

end

function acArmoredStromDialog:changTask(flag,isgetAward)
    self.trueNbTag = flag or 1
        if self.trueNbTag==1 then
            self.taskTb=acArmoredStormVoApi:getTaskTb1()
            self.taskNum=SizeOfTable(self.taskTb1)
        else
            self.taskTb=acArmoredStormVoApi:getTaskTb2()
            self.taskNum=SizeOfTable(self.taskTb2)
        end
    if isgetAward then
        self:refreshTv()
    else
        self:refreshTv(flag)
    end
end

function acArmoredStromDialog:moveDown( )
    local cellNums = SizeOfTable(self.cellArr)
    -- print("in moveDown------====---=-=-=-=-=-=-=",cellNums)
    for i=1,cellNums do
        self.cellArr[i]:setPositionY(self.cellHight*(cellNums+2))
        local posX = self.cellArr[1]:getPositionX()
        local moveDown2 = CCMoveTo:create(0.2,ccp(posX,self.cellOldPosYTb[i]))--moveUp:reverse()
        local acArr = CCArray:create()
        acArr:addObject(moveDown2)
        if i == cellNums then
                local function reloadCell2( )
                    self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+500))
                    self.wholeTouchBgSp:setVisible(false)
                end 
                local acCallBack = CCCallFuncN:create(reloadCell2)
                acArr:addObject(acCallBack)
            end
        local seq=CCSequence:create(acArr)
        self.cellArr[i]:runAction(seq)
    end
    
    -- local recordPoint=self.tv:getRecordPoint()
    -- self.cellArr = {}
    -- self.tv:reloadData()
    -- self.tv:recoverToRecordPoint(recordPoint)

end

function acArmoredStromDialog:refreshTv(flag)
    -- print(":refreshTv(flag)------>",flag)
    
    if flag then
        self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,0))
        self.wholeTouchBgSp:setVisible(true)
        self.cellOldPosYTb = {}
        local cellNums = SizeOfTable(self.cellArr)
        local posX = self.cellArr[1]:getPositionX()
        for i=1,cellNums do
            self.cellOldPosYTb[i] = self.cellArr[i]:getPositionY()
            local moveUp = CCMoveTo:create(0.05*(cellNums-i),ccp(posX,self.cellHight*(cellNums+1)))
            local moveDis = CCDelayTime:create(0.08*(cellNums-i))
            local acArr = CCArray:create()
            acArr:addObject(moveUp)
            -- acArr:addObject(moveDis)
            if i == 1 then
                local function reloadCell( )
                    local recordPoint=self.tv:getRecordPoint()
                    self.cellArr = {}
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)
                    local cellNums = SizeOfTable(self.cellArr)
                    for i=1,SizeOfTable(self.cellArr) do
                        self.cellArr[i]:setPosition(ccp(posX,self.cellHight*(cellNums+1)))
                    end
                    self:moveDown()
                end 
                local acCallBack = CCCallFuncN:create(reloadCell)
                acArr:addObject(acCallBack)
            end
            

            local seq=CCSequence:create(acArr)
            self.cellArr[i]:runAction(seq)
        end

        return
    end

    local recordPoint=self.tv:getRecordPoint()
    self.cellArr = {}
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
end

function acArmoredStromDialog:tick()
    local acVo = acArmoredStormVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==false then
        self:close()
        do return end
    end
    self:updateAcTime()
end

function acArmoredStromDialog:updateAcTime()
    local acVo=acArmoredStormVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acArmoredStromDialog:dispose()
    self.cellArr=nil
	spriteController:removePlist("public/emblemSkillBg.plist")
    spriteController:removeTexture("public/emblemSkillBg.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
    spriteController:removePlist("public/acArmoredStorm_image.plist")
    spriteController:removeTexture("public/acArmoredStorm_image.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end