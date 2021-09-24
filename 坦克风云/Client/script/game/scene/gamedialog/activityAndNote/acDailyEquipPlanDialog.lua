acDailyEquipPlanDialog = commonDialog:new()

function acDailyEquipPlanDialog:new(parent,layerNum)
	local nc = {}
	setmetatable(nc,self)
	self.__index = self

	nc.parent = parent
	nc.layerNum = layerNum
    nc.stateCfg=acDailyEquipPlanVoApi:getTaskStateCfg()
    acDailyEquipPlanVoApi:initTaskData()
    nc.tasksData=acDailyEquipPlanVoApi:getTaskData()
    nc.isToday=acDailyEquipPlanVoApi:isToday()
    nc.tvHeight=0
	return nc
end

function acDailyEquipPlanDialog:initTableView() 
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" then
      strSize2 =28
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")

    self.panelLineBg:setAnchorPoint(ccp(0.5,1))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSize.width-20,G_VisibleSize.height-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height-85))

    local titleBgHeight=160
    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
    titleBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,titleBgHeight))
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setTouchPriority(-(self.layerNum-1)*20-2)
    titleBg:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height - 85))
    self.bgLayer:addChild(titleBg,1)
    
    local buildIcon = CCSprite:createWithSpriteFrameName("equipBtn.png")
    buildIcon:setAnchorPoint(ccp(0.5,0.5))
    buildIcon:setScale(1.3)
    buildIcon:setPosition(ccp(60,titleBg:getContentSize().height/2))
    titleBg:addChild(buildIcon)

    local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),25)
    timeTitle:setAnchorPoint(ccp(0.5,1))
    timeTitle:setColor(G_ColorGreen)
    timeTitle:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height-10))
    titleBg:addChild(timeTitle)

    local timeStr = acDailyEquipPlanVoApi:getTimeStr()
    local timeStrLabel = GetTTFLabel(timeStr,25)
    timeStrLabel:setAnchorPoint(ccp(0.5,1))
    timeStrLabel:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height-60))
    titleBg:addChild(timeStrLabel)
    self.timeLb=timeStrLabel
    self:updateAcTime()

    local contentLabel = GetTTFLabelWrap(getlocal("activity_dailyequip_content"),strSize2,CCSizeMake(G_VisibleSizeWidth*0.7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    contentLabel:setAnchorPoint(ccp(0.5,0))
    contentLabel:setPosition(ccp(titleBg:getContentSize().width/2,15))
    contentLabel:setColor(G_ColorYellow)
    titleBg:addChild(contentLabel)

    local function onTouchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:showAcInfo()
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",onTouchInfo,11,nil,nil)
    infoItem:setScale(0.8) 
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(titleBg:getContentSize().width - infoItem:getContentSize().width/2 - 10,titleBg:getContentSize().height/2))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:addChild(infoBtn)

    local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function () end)
    tipBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,60))
    tipBg:setAnchorPoint(ccp(0.5,0))
    tipBg:setPosition(ccp(G_VisibleSizeWidth/2,25))
    self.bgLayer:addChild(tipBg)

    local tipLabel = GetTTFLabelWrap(getlocal("activity_dailyequip_tip"),25,CCSizeMake(G_VisibleSizeWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tipLabel:setAnchorPoint(ccp(0.5,0.5))
    tipLabel:setPosition(ccp(tipBg:getContentSize().width/2,tipBg:getContentSize().height/2))
    tipLabel:setColor(G_ColorRed)
    tipBg:addChild(tipLabel)

    local function callBack(...)
        return self:taskEventHandler(...)
    end
    self.tvHeight=G_VisibleSize.height-85-titleBgHeight-25-65
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.tvHeight),nil)
    self.tv:setPosition(ccp(10,85))
    self.tv:setMaxDisToBottomOrTop(100)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv)


    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acDailyEquipPlanDialog:taskEventHandler(handler,fn,idx,cel)
    local tasksData = self.tasksData
    if SizeOfTable(tasksData)<=0 then
        return
    end
    local cellHight=200
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(tasksData)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.bgLayer:getContentSize().width-20,cellHight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        if tasksData[idx+1]==nil then
            return
        end
        local function cellclick()
        end
        local task = tasksData[idx+1]

        local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellclick)
        backSprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,cellHight-10))
        backSprite:setAnchorPoint(ccp(0,0))
        backSprite:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprite:setPosition(ccp(10,0))
        cell:addChild(backSprite,1)

        local bgWidth=backSprite:getContentSize().width
        local bgHeight=backSprite:getContentSize().height

        local descBg = CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
        descBg:setAnchorPoint(ccp(0.5,1))
        descBg:setPosition(ccp(bgWidth/2,bgHeight))
        backSprite:addChild(descBg)

        local descLabel = GetTTFLabelWrap(task.desc,25,CCSizeMake(G_VisibleSizeWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        descLabel:setAnchorPoint(ccp(0.5,0.5))
        descLabel:setPosition(ccp(descBg:getContentSize().width/2,descBg:getContentSize().height/2))
        descLabel:setColor(G_ColorYellowPro)
        descBg:addChild(descLabel)

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp:setScale(self.dialogWidth/lineSp:getContentSize().width)
        lineSp:setAnchorPoint(ccp(0.5,1))
        lineSp:setPosition(ccp(bgWidth/2,bgHeight-descBg:getContentSize().height))
        backSprite:addChild(lineSp)

        local posX = 30
        local posY = 20
        local rewardList=FormatItem(task.rewardCfg,nil,true)
        for k,v in pairs(rewardList) do
            local icon,scale = G_getItemIcon(v,80,true,self.layerNum+1)
            icon:setAnchorPoint(ccp(0,0))
            icon:setPosition(ccp(posX,posY))
            icon:setTouchPriority(-(self.layerNum-1)*20-3)
            icon:setScale(scale)
            backSprite:addChild(icon,1)
            local iconWidth = icon:getContentSize().width*icon:getScaleX()
            local numLabel = GetTTFLabel("x"..v.num,25)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(ccp(iconWidth+10,5))
            icon:addChild(numLabel,1)
            posX=posX+iconWidth+10
        end

        local function onTouchGoBtn()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            self:onTouchGoBtn(task)
        end
        local function onGetReward()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            self:onGetReward(task)
        end
        local function nilFunc()
        end
        local btnItem
        if task.state==self.stateCfg.UNFINISH then
            btnItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnGraySmall_Down.png",onTouchGoBtn,nil,getlocal("activity_heartOfIron_goto"),30)
        elseif task.state==self.stateCfg.FINISHED then
            btnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnGraySmall_Down.png",onGetReward,nil,getlocal("daily_scene_get"),30)
        elseif task.state==self.stateCfg.HAS_REWARD then
            btnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnGraySmall_Down.png",nilFunc,nil,getlocal("activity_hadReward"),30)
            btnItem:setEnabled(false)
        end
        if btnItem then
            btnItem:setScale(0.8)
            local btnMenu = CCMenu:createWithItem(btnItem)
            btnMenu:setPosition(ccp(backSprite:getContentSize().width-90,50))
            btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
            backSprite:addChild(btnMenu,1)

            local progressLabel = GetTTFLabel(task.curTimes.."/"..task.maxTimes,25)
            progressLabel:setAnchorPoint(ccp(0.5,0))
            progressLabel:setScale(1/btnItem:getScale())
            progressLabel:setPosition(ccp(btnItem:getContentSize().width/2,btnItem:getContentSize().height))
            btnItem:addChild(progressLabel)
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

function acDailyEquipPlanDialog:onTouchGoBtn(task)
    if task==nil or type(task)~="table" then
        return
    end
    if task.tid=="t1" then
        G_goToDialog("hy",self.layerNum,true)
    elseif task.tid=="t2" or task.tid=="t3" then
        G_goToDialog("ht",self.layerNum,true)
    else
        G_goToDialog("hu",self.layerNum,true)
    end
end

function acDailyEquipPlanDialog:onGetReward(task)
    if task==nil or type(task)~="table" then
        return
    end
    local function getRewardsCallBack(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data then
                if sData.data.dailyEquipPlan then
                    acDailyEquipPlanVoApi:updateData(sData.data.dailyEquipPlan)
                    self.tv:reloadData()
                    local rewardList=FormatItem(task.rewardCfg,nil,true)
                    --本地添加奖励
                    for index,item in pairs(rewardList) do
                        G_dayin(item)
                        G_addPlayerAward(item.type,item.key,item.id,item.num,false,true)   
                    end
                    --奖励飘窗
                    G_showRewardTip(rewardList,true)
                end
            end        
        end
    end
    socketHelper:dailyEquipPlanGetRewards(task.tid,getRewardsCallBack)
end

function acDailyEquipPlanDialog:showAcInfo()
    local limitLv
    if(base.heroEquipOpenLv)then
        limitLv=base.heroEquipOpenLv
    else
        limitLv=30
    end
    local tabStr = {getlocal("activity_dailyequip_rule4"),"\n",getlocal("activity_dailyequip_rule3",{limitLv}),"\n",getlocal("activity_dailyequip_rule2"),"\n",getlocal("activity_dailyequip_rule1"),"\n"}
    local tabColor ={G_ColorRed,nil,nil,nil}
    local td=smallDialog:new()
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    sceneGame:addChild(dialog,self.layerNum+1)
end

function acDailyEquipPlanDialog:resetTab()

end
  
function acDailyEquipPlanDialog:tick()
    if acDailyEquipPlanVoApi:isEnd()==true then
        self:close()
        do return end
    end

    local flag=acDailyEquipPlanVoApi:isToday()
    if flag~=self.isToday and flag==false then
        -- print("===========重置任务===========")
        acDailyEquipPlanVoApi:resetTaskData()
        acDailyEquipPlanVoApi:initTaskData()
        self.tasksData=acDailyEquipPlanVoApi:getTaskData()
        self.isToday=false
        if self.tv then
            -- print("=============刷新任务列表==============")
            self.tv:reloadData()
        end
    end
    self.isToday=flag
    self:updateAcTime()
end

function acDailyEquipPlanDialog:updateAcTime()
    local acVo=acDailyEquipPlanVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

--活动页面关闭时的资源释放处理
function acDailyEquipPlanDialog:dispose()
    self.parent=nil
    self.layerNum=nil
    self.stateCfg=nil
    self.tasksData=nil
    self.isToday=false
    self.tvHeight=0

    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
end