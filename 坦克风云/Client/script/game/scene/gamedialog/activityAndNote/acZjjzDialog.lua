acZjjzDialog = commonDialog:new()

function acZjjzDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.isToday=true
    nc.cellHight=170
    local function addPlist()
    	spriteController:addPlist("public/emblemSkillBg.plist")
	    spriteController:addTexture("public/emblemSkillBg.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    return nc
end

function acZjjzDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function acZjjzDialog:initTableView( )
    self.taskTb1=acZjjzVoApi:getTaskTbByType(1)
    self.taskTb2=acZjjzVoApi:getTaskTbByType(2)
    -- self.taskTb=acZjjzVoApi:getTaskTb1()

    self.taskNum=SizeOfTable(self.taskTb1)
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 300-100-30),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(20,30)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end

-- 仿照全线突围活动 acQxtwVoApi:getCurrentTaskState()
function acZjjzDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.taskNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 40,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
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
        if self.nbTag==1 then
            taskInfo=self.taskTb1["t" .. trueIndex]
        else
            taskInfo=self.taskTb2["t" .. trueIndex]
        end


        local taskDes=""
        if self.nbTag==1 then
            taskDes=getlocal("activity_zjjz_taskType1",{haveNum .. "/" .. taskInfo[2][1],getlocal("armorMatrix_color_" .. taskInfo[2][2])})
        else
            taskDes=getlocal("activity_zjjz_taskType2",{haveNum .. "/" .. taskInfo[2]})
        end

        local taskDesLb=GetTTFLabelWrap(taskDes,22,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
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
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),22,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(30,desH))
        background:addChild(desLb)

        local reward=taskInfo[3]
        local rewardItem=FormatItem(reward,nil,true)
        local starW=150
        for k,v in pairs(rewardItem) do
            local icon=G_getItemIcon(v,100,true,self.layerNum)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            icon:setPosition(ccp(starW+(k-1)*80,desH))
            background:addChild(icon)
            icon:setScale(80/icon:getContentSize().width)

            if acZjjzVoApi:isFlick(v.type,v.key,v.num) then
                G_addRectFlicker2(icon,1.3,1.3,2,"p")
                -- G_addRectFlicker(icon,1,1,ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
            end

            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-10,3)
            icon:addChild(numLabel,1)
            numLabel:setScale(1/icon:getScale())
        end

        if index>10000 then -- 已完成(已领取)
            local desLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            -- desLb:setColor(G_ColorYellowPro)
            desLb:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(desLb)
            desLb:setColor(G_ColorGreen)
            -- titleLb:setColor(G_ColorWhite)
        elseif index>1000 then -- 未完成
        	local function goDialog()
        		if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				    if G_checkClickEnable()==false then
				        do
				            return
				        end
				    else
				        base.setWaitTime=G_getCurDeviceMillTime()
				    end
				    PlayEffect(audioCfg.mouseClick)
				    activityAndNoteDialog:closeAllDialog()
                    if self.nbTag==1 then
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
				end
        	end
            local rewardItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",goDialog,nil,getlocal("activity_heartOfIron_goto"),25)
            -- rewardItem:setScale(0.8)
            local rewardBtn=CCMenu:createWithItem(rewardItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(rewardBtn)

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
                        self:changTask()

                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)

                        for k,v in pairs(rewardItem) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end

                        G_showRewardTip(rewardItem,true)
                    end
                    acZjjzVoApi:socketReward(self.nbTag,trueIndex,refreshFunc)
                
                end
            end
            local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardTiantang,nil,getlocal("daily_scene_get"),25)
            -- rewardItem:setScale(0.8)
            local rewardBtn=CCMenu:createWithItem(rewardItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(background:getContentSize().width-90,background:getContentSize().height/2))
            background:addChild(rewardBtn)
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

function acZjjzDialog:doUserHandler()
	local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
    headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,300))
    headerSprie:setAnchorPoint(ccp(0.5,1))
    headerSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    headerSprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95))
    self.bgLayer:addChild(headerSprie)

    local hs=headerSprie:getContentSize().height
    local ws=headerSprie:getContentSize().width
    hs=hs-10

	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),28)
	actTime:setAnchorPoint(ccp(0.5,1))
	actTime:setPosition(ccp(ws/2,hs))
	headerSprie:addChild(actTime)
	actTime:setColor(G_ColorGreen)

	hs=hs-actTime:getContentSize().height-5

	local tabStr={" ",getlocal("activity_zjjz_tip2"),getlocal("activity_zjjz_tip1")," "}
	G_addMenuInfo(headerSprie,self.layerNum,ccp(ws-50,hs),tabStr,nil,0.9,28)
    
    local acVo=acZjjzVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setAnchorPoint(ccp(0.5,1))
    timeLabel:setPosition(ccp(ws/2, hs))
    headerSprie:addChild(timeLabel,1)
    self.timeLb=timeLabel
    G_updateActiveTime(acVo,self.timeLb)

    hs=hs-timeLabel:getContentSize().height-5
    local strSize2 = 18
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 = 25
    end
    local acDesLb=GetTTFLabelWrap(getlocal("activity_zjjz_des"),strSize2,CCSizeMake(ws-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    acDesLb:setAnchorPoint(ccp(0,1))
    headerSprie:addChild(acDesLb)
    acDesLb:setPosition(20,hs)

    hs=hs-acDesLb:getContentSize().height-5

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    headerSprie:addChild(lineSp)
    lineSp:setPosition(ws/2, hs)

    hs=hs-lineSp:getContentSize().height/2-5

    local pos1=ccp(80,(headerSprie:getContentSize().height-hs)/2)
    local pos2=ccp(ws-80,(headerSprie:getContentSize().height-hs)/2)

    self.cgTb1={}
    self.cgTb2={}

    local shineSp1=CCSprite:createWithSpriteFrameName("equipShine.png")
    headerSprie:addChild(shineSp1,1)
    shineSp1:setPosition(pos1)
    self.shineSp1=shineSp1

    self.nbTag=1

    local function touchArmorSp1()
    	if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		if self.nbTag==1 then
			return
		end

		PlayEffect(audioCfg.mouseClick)
        self.nbTag=1
		self.shineSp2:setVisible(false)
		self.shineSp1:setVisible(true)
		self:changeColor(1)
        self:changTask(1)
    end
    local armorSp1=LuaCCSprite:createWithSpriteFrameName("armorMatrix_1.png",touchArmorSp1)
    headerSprie:addChild(armorSp1,2)
    armorSp1:setPosition(pos1)
    armorSp1:setScale(1.4)
    table.insert(self.cgTb1,armorSp1)
    armorSp1:setTouchPriority(-(self.layerNum-1)*20-4)

    -- emblemSkillGreen
    local embleDiSp1=LuaCCSprite:createWithSpriteFrameName("emblemSkillGreen.png",touchArmorSp1)
    headerSprie:addChild(embleDiSp1)
    embleDiSp1:setAnchorPoint(ccp(0.5,0.5))
    local emblePos1=ccp(60+embleDiSp1:getContentSize().width/2,15+embleDiSp1:getContentSize().height/2)
    embleDiSp1:setPosition(emblePos1)
    table.insert(self.cgTb1,embleDiSp1)
    embleDiSp1:setTouchPriority(-(self.layerNum-1)*20-4)

    local embleLb1=GetTTFLabelWrap(getlocal("activity_zjjz_collect"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    embleLb1:setAnchorPoint(ccp(0.5,0.5))
    headerSprie:addChild(embleLb1)
    embleLb1:setPosition(emblePos1)
    embleLb1:setColor(G_ColorYellowPro)
    table.insert(self.cgTb1,embleLb1)

    local shineSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
    headerSprie:addChild(shineSp2,1)
    shineSp2:setPosition(pos2)
    self.shineSp2=shineSp2

    

    local function touchArmorSp2()
    	if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		if self.nbTag==2 then
			return
		end

		PlayEffect(audioCfg.mouseClick)
        self.nbTag=2
		self.shineSp2:setVisible(true)
		self.shineSp1:setVisible(false)
		self:changeColor(2)
        self:changTask(1)
    end
    local armorSp2=LuaCCSprite:createWithSpriteFrameName("armorMatrix_2.png",touchArmorSp2)
    headerSprie:addChild(armorSp2,2)
    armorSp2:setPosition(pos2)
    armorSp2:setScale(1.3)
    table.insert(self.cgTb2,armorSp2)
    armorSp2:setTouchPriority(-(self.layerNum-1)*20-4)

    local arrowSp=CCSprite:createWithSpriteFrameName("dwArrow1.png")
    armorSp2:addChild(arrowSp)
    arrowSp:setAnchorPoint(ccp(0.5,0))
    arrowSp:setPosition(armorSp2:getContentSize().width/2+25,0)

    local embleDiSp2=LuaCCSprite:createWithSpriteFrameName("emblemSkillGreen.png",touchArmorSp2)
    headerSprie:addChild(embleDiSp2)
    embleDiSp2:setAnchorPoint(ccp(0.5,0.5))
    local emblePos2=ccp(ws-60-embleDiSp2:getContentSize().width/2,hs-embleDiSp2:getContentSize().height/2)
    embleDiSp2:setPosition(emblePos2)
    table.insert(self.cgTb2,embleDiSp2)
    embleDiSp2:setTouchPriority(-(self.layerNum-1)*20-4)

    local embleLb2=GetTTFLabelWrap(getlocal("activity_zjjz_strengthen"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    embleLb2:setAnchorPoint(ccp(0.5,0.5))
    headerSprie:addChild(embleLb2)
    embleLb2:setPosition(emblePos2)
    embleLb2:setColor(G_ColorYellowPro)
    table.insert(self.cgTb2,embleLb2)
    table.insert(self.cgTb2,arrowSp)

    self.shineSp2:setVisible(false)
    self:changeColor(1)


    local taskTb1=acZjjzVoApi:getTaskTb1()
    for k,v in pairs(taskTb1) do
        if v.index<1000 then
            self.taskTb=taskTb1
            return
        end
    end

    local taskTb2=acZjjzVoApi:getTaskTb2()
    for k,v in pairs(taskTb2) do
        if v.index<1000 then
            self.taskTb=taskTb2
            self.nbTag=2
            self.shineSp2:setVisible(true)
            self.shineSp1:setVisible(false)
            self:changeColor(2)
            return
        end
    end
    self.taskTb=taskTb1

end

function acZjjzDialog:changeColor(flag)
	if flag==1 then
		for k,v in pairs(self.cgTb1) do
			v:setColor(G_ColorWhite)
		end
		self.cgTb1[3]:setColor(G_ColorYellowPro)
		for k,v in pairs(self.cgTb2) do
			v:setColor(G_ColorGray)
		end
	else
		for k,v in pairs(self.cgTb1) do
			v:setColor(G_ColorGray)
		end
		for k,v in pairs(self.cgTb2) do
			v:setColor(G_ColorWhite)
		end
		self.cgTb2[3]:setColor(G_ColorYellowPro)
	end
end

function acZjjzDialog:changTask(flag)
    if self.nbTag==1 then
        self.taskTb=acZjjzVoApi:getTaskTb1()
        self.taskNum=SizeOfTable(self.taskTb1)
    else
        self.taskTb=acZjjzVoApi:getTaskTb2()
        self.taskNum=SizeOfTable(self.taskTb2)
    end
    self:refreshTv(flag)
end

function acZjjzDialog:refreshTv(flag)
    if flag then
        self.tv:reloadData()
        return
    end
    local recordPoint=self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
end

function acZjjzDialog:tick()
    local acVo = acZjjzVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==false then
        self:close()
        do return end
    end
    if self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acZjjzDialog:dispose()
    self.timeLb=nil
	spriteController:removePlist("public/emblemSkillBg.plist")
    spriteController:removeTexture("public/emblemSkillBg.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
end