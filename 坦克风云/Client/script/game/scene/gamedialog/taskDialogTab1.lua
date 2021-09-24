require "luascript/script/game/gamemodel/task/taskVoApi"

taskDialogTab1={}

function taskDialogTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=nil
	self.cancelBtn=nil
    self.refreshBtn=nil
	self.resetBtn=nil
	self.resetCountLabel=nil

	self.mainBg=nil

    return nc
end

function taskDialogTab1:init(layerNum,parentDialog)
    self.layerNum=layerNum
    self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create()
    -- self:initTableView()
    self:doUserHandler()

    if newGuidMgr:isNewGuiding()==true and self.guideItem then
    	if newGuidMgr.curStep==31 then
    		newGuidMgr:setGuideStepField(32,self.guideItem)
    		newGuidMgr:setGuideStepField(34,self.guideItem)
    	end
    end
    return self.bgLayer
end

--设置对话框里的tableView
function taskDialogTab1:initTableView(height,posY)
	if self.mainBg==nil then
		local function touch()
		end
		local capInSet = CCRect(65, 25, 1, 1);--"CorpsLevel.png",capInSet
		self.mainBg=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),touch)--
		self.mainBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,185))
		self.mainBg:ignoreAnchorPointForPosition(false)
		self.mainBg:setAnchorPoint(ccp(0.5,1))
		self.mainBg:setIsSallow(true)
		self.mainBg:setTouchPriority(-(self.layerNum-1)*20-1)
		self.mainBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160))
		self.bgLayer:addChild(self.mainBg,1)
		-- print("self.mainBg",self.mainBg:getContentSize().height)

		local characterSp=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png")
		local scale=0.6
		characterSp:setScale(scale)
		-- characterSp:setAnchorPoint(ccp(0.5,0.5))
		characterSp:setPosition(ccp(characterSp:getContentSize().width/2*scale+10,characterSp:getContentSize().height/2*scale+5))
		self.mainBg:addChild(characterSp,2)


		local lbPosx=characterSp:getContentSize().width*scale+20
		local lbWidth=self.mainBg:getContentSize().width-characterSp:getContentSize().width*scale-30

		-- local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
		-- -- bgSp:setPosition(ccp(380,self.mainBg:getContentSize().height-29))
		-- bgSp:setPosition(ccp(self.mainBg:getContentSize().width/2+25,self.mainBg:getContentSize().height-29))
		-- bgSp:setScaleY(45/bgSp:getContentSize().height)
		-- bgSp:setScaleX(800/bgSp:getContentSize().width)
		-- self.mainBg:addChild(bgSp)

		local bgSp=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        -- bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setPosition(self.mainBg:getContentSize().width * 0.5,self.mainBg:getContentSize().height-29)
        self.mainBg:addChild(bgSp)

		local titleLb=GetTTFLabelWrap(getlocal("main_task_title"),24,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		-- titleLb:setPosition(lbPosx+lbWidth/2-30,self.mainBg:getContentSize().height-29)
		titleLb:setPosition(self.mainBg:getContentSize().width/2,self.mainBg:getContentSize().height-29)
		self.mainBg:addChild(titleLb,1)

		self.mtNameLb=GetTTFLabelWrap("",24,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		self.mtNameLb:setAnchorPoint(ccp(0,1))
		self.mtNameLb:setPosition(lbPosx,self.mainBg:getContentSize().height - 53-20)
		self.mtNameLb:setColor(G_ColorGreen)
		self.mainBg:addChild(self.mtNameLb,1)

		self.scheduleLb=GetTTFLabelWrap("",20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.scheduleLb:setAnchorPoint(ccp(0,0.5))
		self.scheduleLb:setPosition(lbPosx,30+20)
		-- self.scheduleLb:setColor(G_ColorGreen)
		self.mainBg:addChild(self.scheduleLb,1)


		local function touch(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            
            local mainTask=taskVoApi:getMainTask()
            if mainTask then
	            local sid=mainTask.sid
				local taskCfg = taskVoApi:getTaskFromCfg(sid)
				local awardTab = taskVoApi:getAwardBySid(sid)
				local scheduleStr=""
				if taskVoApi:isCompletedTask(sid) then
					scheduleStr=getlocal("hadCompleted")
				else
					scheduleStr=getlocal(taskCfg.schedule,{mainTask.num})
				end
	            local capInSet1 = CCRect(30, 30, 1, 1)

	            local taskDescStr=taskVoApi:getTaskInfoById(taskCfg.sid,false)--true:name,false:desc
				smallDialog:showTaskDialog("rewardPanelBg1.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),capInSet1,true,4,{getlocal("award")," ",scheduleStr," ",taskDescStr},20,awardTab,nil,nil,true)
        	end
        end
	    self.infoBtn=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,11,nil,0)
	    local menuInfo=CCMenu:createWithItem(self.infoBtn)
        menuInfo:setAnchorPoint(ccp(0,0))
        menuInfo:setPosition(ccp(427+20,40+15))
	    menuInfo:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.mainBg:addChild(menuInfo,1)


	    local function rewardHandler(tag,object)
            PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            local mainTask=taskVoApi:getMainTask()
            if mainTask then
            	local sid=mainTask.sid
				local taskNumOld=taskVoApi:getCurrentTasksNum()
				local function taskFinishHandler(fn,data)
					if base:checkServerData(data)==true then
	                    local awardStr,awardTab = taskVoApi:getAwardStr(sid)
	                    local realReward=playerVoApi:getTrueReward(awardTab)
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),awardStr,28,nil,nil,realReward)
						
						local recordPoint = self.tv:getRecordPoint()
						self:refresh()
						local taskNumNew=taskVoApi:getCurrentTasksNum()
						local diffNum=taskNumOld-taskNumNew
						if taskNumNew>5 and taskNumOld>5 then
							--if diffNum>1 then
								recordPoint.y=recordPoint.y+120*diffNum
							--end
							self.tv:recoverToRecordPoint(recordPoint)
						end
					end
	            end
				local taskid="t"..tostring(sid)
	            socketHelper:taskFinish(taskid,taskFinishHandler)
	        end
        end
	    -- self.rewardBtn=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,12,nil,0)
	    self.rewardBtn=GetButtonItem("yh_taskReward.png","yh_taskReward_down.png","yh_taskReward_down.png",rewardHandler,12,nil,0)
	    local menuReward=CCMenu:createWithItem(self.rewardBtn)
        menuReward:setAnchorPoint(ccp(0,0))
        menuReward:setPosition(ccp(513+10,40+15))
	    menuReward:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.mainBg:addChild(menuReward,1)
	    -- self:iconFlicker(self.rewardBtn)
	    G_addFlicker(self.rewardBtn,2,2)

	    local function jumpHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local mainTask=taskVoApi:getMainTask()
            if mainTask then
	            local sid=mainTask.sid
				local taskCfg = taskVoApi:getTaskFromCfg(sid)
                G_taskJumpTo(taskCfg,self.parentDialog)
            end
        end
        self.jumpBtn=GetButtonItem("yh_taskGoto.png","yh_taskGoto_down.png","yh_taskGoto_down.png",jumpHandler,13,nil,0)
	    -- self.jumpBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",jumpHandler,13,getlocal("activity_heartOfIron_goto"),25)
	    -- self.jumpBtn:setScale(0.75)
		local jumpMenu=CCMenu:createWithItem(self.jumpBtn)
        jumpMenu:setAnchorPoint(ccp(0,0))
        jumpMenu:setPosition(ccp(513+10,40+15))
	    jumpMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.mainBg:addChild(jumpMenu,1)
	end


	local tvHeight=height or 230
	local hPos=posY or 65
    local function callBack(...)
		return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)

	local mainTask=taskVoApi:getMainTask()
    if newGuidMgr:isNewGuiding()==false and mainTask then
    	local sid=mainTask.sid
		local taskCfg = taskVoApi:getTaskFromCfg(sid)
    	local isFinish=taskVoApi:isCompletedTask(sid)
    	self.mainBg:setVisible(true)
    	self.infoBtn:setEnabled(true)
    	if isFinish then
    		self.rewardBtn:setVisible(true)
    		self.rewardBtn:setEnabled(true)
    		self.jumpBtn:setVisible(false)
    		self.jumpBtn:setEnabled(false)
    	else
    		self.rewardBtn:setVisible(false)
    		self.rewardBtn:setEnabled(false)
    		self.jumpBtn:setVisible(true)
    		self.jumpBtn:setEnabled(true)
    	end

    	local nameStr=taskVoApi:getTaskInfoById(sid,true)
    	-- nameStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    	self.mtNameLb:setString(nameStr)
    	local scheduleStr=""
		if isFinish then
			scheduleStr=getlocal("hadCompleted")
		else
			scheduleStr=getlocal(taskCfg.schedule,{mainTask.num})
		end
		self.scheduleLb:setString(scheduleStr)

    	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-tvHeight-self.mainBg:getContentSize().height),nil)
    else
    	self.mainBg:setVisible(false)
    	self.infoBtn:setEnabled(false)
    	self.rewardBtn:setEnabled(false)
    	self.jumpBtn:setEnabled(false)
    	
    	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-tvHeight),nil)
    	if newGuidMgr:isNewGuiding()==false then
	    	local strSize3 = G_isAsia() and 25 or 22
	    	local mainMessionTip = GetTTFLabelWrap(getlocal("mainMissionTip"),strSize3,CCSizeMake(self.bgLayer:getContentSize().width - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	    	mainMessionTip:setPosition(getCenterPoint(self.bgLayer))
	    	mainMessionTip:setColor(G_ColorYellowPro)
	    	self.bgLayer:addChild(mainMessionTip,99)
	    end
    end

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,hPos))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function taskDialogTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return taskVoApi:getCurrentTasksNum()
	elseif fn=="tableCellSizeForIndex" then
	    local tmpSize

		local numType1 = taskVoApi:getCurrentNumByType(1)
		local numType2 = taskVoApi:getCurrentNumByType(2)
	    if idx==0 or idx==numType1 or idx==numType1+numType2 then
			tmpSize=CCSizeMake(400,141)
	    else
			tmpSize=CCSizeMake(400,99)
	    end

	    return  tmpSize
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
		
		local showTasks
		local numType1 = taskVoApi:getCurrentNumByType(1)
		local numType2 = taskVoApi:getCurrentNumByType(2)
		showTasks = taskVoApi:getCurrentTasks()

		if showTasks==nil or SizeOfTable(showTasks)==0 then
			do return cell end
		end
		
		local task = showTasks[tonumber(idx)+1]
		local taskVo = taskVoApi:getTaskFromCfg(task.sid)

		local reduceHeight=9
		local lbWidth=25*11+20
		local btnAddX,btnAddY=13,7
		
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)--"panelItemBg.png",capInSet
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("newKuang2.png",CCRect(7,7,1,1),cellClick)--

		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 96))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie,1)

        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local taskIcon
		local pic=taskVo.style
		local startIndex,endIndex=string.find(pic,"^rank(%d+).png$")
		local iconScaleX=1
		local iconScaleY=1
		if startIndex~=nil and endIndex~=nil then
			taskIcon=GetBgIcon(pic)
		else
			if taskVo and taskVo.style and taskVo.style~="" then
				taskIcon=CCSprite:createWithSpriteFrameName(taskVo.style)
			end
			if taskIcon then
				if taskIcon:getContentSize().width>100 then
					iconScaleX=0.78*100/150
					iconScaleY=0.75*100/150
				else
					iconScaleX=0.78
					iconScaleY=0.75
				end
				taskIcon:setScaleX(iconScaleX)
				taskIcon:setScaleY(iconScaleY)
			end
		end
		if taskIcon then
	        taskIcon:setAnchorPoint(ccp(0,0))
	      	taskIcon:setPosition(ccp(15,10))
	        cell:addChild(taskIcon,1)
		end

		local textSize=20
		local taskNameStr=taskVoApi:getTaskInfoById(taskVo.sid,true)--true:name,false:desc
		local strSize2,posY2 = 24,97
		local lanChos = G_getCurChoseLanguage()
		if lanChos =="ru" then
			strSize2 = 20
		elseif lanStr =="cn" or lanStr =="tw" or lanStr =="ja" or lanStr =="ko" then
			posY2 = 87
		end
		local taskName=GetTTFLabelWrap(taskNameStr,strSize2,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
        taskName:setColor(G_ColorGreen)
		taskName:setAnchorPoint(ccp(0,1))
		taskName:setPosition(100,posY2-reduceHeight)
		cell:addChild(taskName,1)
		
		--进度
		local schedule
	    if idx==0 or idx==numType1 or idx==numType1+numType2 then--"TaskHeaderBg.png",capInSet
			local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),cellClick)--
	        backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-270, 32))
	        backSprie1:ignoreAnchorPointForPosition(false)
	        backSprie1:setAnchorPoint(ccp(0,0))
	        backSprie1:setIsSallow(false)
	        backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
			backSprie1:setPosition(ccp(0,97))
			cell:addChild(backSprie1,1)
			
			-- backSprie1:setOpacity(0)
			-- local newBgSp = CCSprite:createWithSpriteFrameName("panelSubTitleBg.png")
			-- newBgSp:setScaleX(backSprie1:getContentSize().width/newBgSp:getContentSize().width)
			-- newBgSp:setScaleY(backSprie1:getContentSize().height/newBgSp:getContentSize().height)
			-- newBgSp:setPosition(getCenterPoint(backSprie1))
			-- backSprie1:addChild(newBgSp)

			local typeLabel
			if idx==0 then
				typeLabel=GetTTFLabel(getlocal("mainTask"),23,"Helvetica-bold")
			elseif idx==numType1 then
				typeLabel=GetTTFLabel(getlocal("buildTask"),23,"Helvetica-bold")
			elseif idx==numType1+numType2 then
				typeLabel=GetTTFLabel(getlocal("militaryTask"),23,"Helvetica-bold")
			end
			typeLabel:setAnchorPoint(ccp(0,0))
			typeLabel:setPosition(13,100)
			cell:addChild(typeLabel,1)
	    end
		if taskVoApi:isCompletedTask(task.sid) then
			schedule=GetTTFLabelWrap(getlocal("hadCompleted"),textSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			schedule:setAnchorPoint(ccp(0,0.5))
			schedule:setPosition(100,35-reduceHeight)
			cell:addChild(schedule,1)
			
	        local function rewardHandler(tag,object)
                PlayEffect(audioCfg.mouseClick)
	            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
					local taskNumOld=taskVoApi:getCurrentTasksNum()
					local function taskFinishHandler(fn,data)
						--local retTb=OBJDEF:decode(data)
						if base:checkServerData(data)==true then
		                    local awardStr,awardTab = taskVoApi:getAwardStr(tag)
                            if newGuidMgr:isNewGuiding() then
                                 if newGuidMgr.curStep==32 then
                                     newGuidMgr:toNextStep()
                                     newGuidMgr:toNextStep()
                                 else
                                     newGuidMgr:toNextStep()
                                 end
                            end
							--smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("award"),awardStr,true,4)
							local realReward=playerVoApi:getTrueReward(awardTab)
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),awardStr,28,nil,nil,realReward)
							
							local recordPoint = self.tv:getRecordPoint()
							self:refresh()
							local taskNumNew=taskVoApi:getCurrentTasksNum()
							local diffNum=taskNumOld-taskNumNew
							if taskNumNew>5 and taskNumOld>5 then
								--if diffNum>1 then
									recordPoint.y=recordPoint.y+120*diffNum
									--end
								self.tv:recoverToRecordPoint(recordPoint)
							end
						end
                    end
					local taskid="t"..tostring(task.sid)
                    socketHelper:taskFinish(taskid,taskFinishHandler)
	            end
	        end
		    -- local menuItemAward=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,task.sid,nil,0)
		    local menuItemAward=GetButtonItem("yh_taskReward.png","yh_taskReward_down.png","yh_taskReward_down.png",rewardHandler,task.sid,nil,0)
		    -- self:iconFlicker(menuItemAward)
		    G_addFlicker(menuItemAward,2,2)
			local menuAward=CCMenu:createWithItem(menuItemAward)
	        menuAward:setAnchorPoint(ccp(0,0))
	        menuAward:setPosition(ccp(510+btnAddX,50-10+btnAddY))
		    menuAward:setTouchPriority(-(self.layerNum-1)*20-2)
		    cell:addChild(menuAward,1)

		    if newGuidMgr:isNewGuiding()==true and newGuidMgr.curStep==31 then
		    	self.guideItem=menuItemAward
		    end
		else
			schedule=GetTTFLabelWrap(getlocal(taskVo.schedule,{task.num}),textSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			schedule:setAnchorPoint(ccp(0,0.5))
			schedule:setPosition(100,35-reduceHeight)
			cell:addChild(schedule,1)


			local function gotoHandler(tag,object)
	            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    G_taskJumpTo(taskVo,self.parentDialog)
	            end
	        end
	        local gotoItem=GetButtonItem("yh_taskGoto.png","yh_taskGoto_down.png","yh_taskGoto_down.png",gotoHandler,task.sid,nil,0)
		    -- local gotoItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",gotoHandler,task.sid,getlocal("activity_heartOfIron_goto"),25)
		    -- gotoItem:setScale(0.75)
			local gotoMenu=CCMenu:createWithItem(gotoItem)
	        gotoMenu:setAnchorPoint(ccp(0,0))
	        gotoMenu:setPosition(ccp(510+btnAddX,50-10+btnAddY))
		    gotoMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		    cell:addChild(gotoMenu,1)
		end
		
        local function touch(tag,object)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		        if newGuidMgr:isNewGuiding()==true then
		        	do return end
		        end
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
				local taskVo = taskVoApi:getTaskFromCfg(tag)
				local task = taskVoApi:getTaskBySid(tag)
				local awardTab = taskVoApi:getAwardBySid(tag)
				local scheduleStr=""
				if taskVoApi:isCompletedTask(tag) then
					scheduleStr=getlocal("hadCompleted")
				else
					scheduleStr=getlocal(taskVo.schedule,{task.num})
				end
                local capInSet1 = CCRect(30, 30, 1, 1)

                local taskDescStr=taskVoApi:getTaskInfoById(taskVo.sid,false)--true:name,false:desc
    --             local taskDescStr=getlocal(taskVo.description)
				-- if tostring(taskVo.type)=="3" then
				-- 	taskDescStr=getlocal(taskVo.description)..getlocal("schedule_hours")
				-- end
				smallDialog:showTaskDialog("rewardPanelBg1.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),capInSet1,true,4,{getlocal("award")," ",scheduleStr," ",taskDescStr},20,awardTab,nil,nil,true)
            end
        end
	    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,task.sid,nil,0)
	    local menuDesc=CCMenu:createWithItem(menuItemDesc)
        menuDesc:setAnchorPoint(ccp(0,0))
        menuDesc:setPosition(ccp(420+btnAddX*2,50-10+btnAddY))
	    menuDesc:setTouchPriority(-(self.layerNum-1)*20-2)
	    cell:addChild(menuDesc,1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
		
    elseif fn=="ccScrollEnable" then
		if newGuidMgr:isNewGuiding()==true then
		     return 0
		else
		     return 1
		end
    end
end

--用户处理特殊需求,没有可以不写此方法
function taskDialogTab1:doUserHandler()
	if self and self.tv then
		self.tv:removeFromParentAndCleanup(true)
		self.tv=nil
	end
	self:initTableView()
	
	if self.resetCountLabel then self.resetCountLabel:setVisible(false) end
	if self.cancelBtn then self.cancelBtn:setVisible(false) end
	if self.refreshBtn then self.refreshBtn:setVisible(false) end
	if self.resetBtn then self.resetBtn:setVisible(false) end

end

--刷新板子
function taskDialogTab1:refresh()
	if self==nil or self.tv==nil then
		do return end
	end
	local recordPoint = self.tv:getRecordPoint()
	-- self.tv:reloadData()
	self:doUserHandler()
	if self.tv then
		if newGuidMgr:isNewGuiding() then
		else
			self.tv:recoverToRecordPoint(recordPoint)
		end
	end
end

function taskDialogTab1:iconFlicker(icon)
	if newGuidMgr:isNewGuiding() then
		do return end
	end
	local m_iconScaleX,m_iconScaleY=1.65,0.95
	local pzFrameName="RotatingEffect1.png"
	local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
	local pzArr=CCArray:create()
	for kk=1,20 do
	    local nameStr="RotatingEffect"..kk..".png"
	    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	    pzArr:addObject(frame)
	end
	local animation=CCAnimation:createWithSpriteFrames(pzArr)
	animation:setDelayPerUnit(0.1)
	local animate=CCAnimate:create(animation)
	metalSp:setAnchorPoint(ccp(0.5,0.5))
	if m_iconScaleX~=nil then
		--metalSp:setScaleX(1/m_iconScaleX)
		metalSp:setScaleX(m_iconScaleX)
	end
	if m_iconScaleY~=nil then
		--metalSp:setScaleY(1/m_iconScaleY)
		metalSp:setScaleY(m_iconScaleY)
	end
	--metalSp:setScale(1/50)
	metalSp:setPosition(ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
	icon:addChild(metalSp,5)
	local repeatForever=CCRepeatForever:create(animate)
	metalSp:runAction(repeatForever)
end

function taskDialogTab1:dispose()
	self.layerNum=nil
	
	self.cancelBtn=nil
    self.refreshBtn=nil
	self.resetBtn=nil
	self.resetCountLabel=nil

	self.mainBg=nil

	self.guideItem=nil
end
