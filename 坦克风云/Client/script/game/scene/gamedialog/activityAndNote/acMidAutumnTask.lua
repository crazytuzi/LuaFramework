acMidAutumnTask={}

function acMidAutumnTask:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.bgLayer=nil
	nc.parent=nil
	nc.infoHeight=165
	nc.fixedTaskList=nil
	nc.changedTaskList=nil
    nc.isTodayFlag=true
    nc.isEnd=false
    nc.cellHeight=nil

    spriteController:addPlist("public/armorMatrixEffect.plist")
    spriteController:addTexture("public/armorMatrixEffect.png")

	return nc
end

function acMidAutumnTask:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self.version=acMidAutumnVoApi:getVersion()
	self.fixedTaskList=acMidAutumnVoApi:getFixedTaskList()
	self.changedTaskList=acMidAutumnVoApi:getChangedTaskList()
	self.fixedTaskNum=SizeOfTable(self.fixedTaskList)
	self.changedTaskNum=SizeOfTable(self.changedTaskList)
    self.isEnd=acMidAutumnVoApi:acIsStop()

	self:initTableView()
	base:addNeedRefresh(self)

	return self.bgLayer
end

function acMidAutumnTask:initTableView()
    local tvH=G_VisibleSizeHeight-160-self.infoHeight-30
	local function eventHandler( ... )
		return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(eventHandler)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,tvH),nil)
    self.tv:setPosition(ccp(25,30))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acMidAutumnTask:getCellHeight(idx)
	if self.cellHeight==nil then
		self.cellHeight={}
	end
	if self.cellHeight[idx]==nil then
		local height=0
		if idx==3 then
			height=110
		elseif idx == 2 then
			height=290
		else
			height=160
		end
		self.cellHeight[idx]=height
	end
	return self.cellHeight[idx]
end

function acMidAutumnTask:eventHandler(handler,fn,idx,cel)
  	if fn=="numberOfCellsInTableView" then
  		 return self.changedTaskNum+self.fixedTaskNum
  	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local height=self:getCellHeight(idx+1)
		tmpSize=CCSizeMake(G_VisibleSizeWidth-50,height)
		return  tmpSize
  	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cellWidth=G_VisibleSizeWidth-50
		local cellHeight=self.cellHeight[idx+1] - 10
		local function cellClick()
		end
		local taskTab = nil
		local taskType --任务类型
		local reward={} --任务完成奖励
		local level=1 --任务的品阶
		local state,cur,max --当前任务状态
		local backSprite
		local taskId=1
		local isReachTop
		if idx==0 then
			local task=self.fixedTaskList[idx+1]
			taskType=task.key --任务类型
			reward=FormatItem(task.reward,false,true) --任务完成奖励
			level=1 --任务的品阶
			taskId=idx+1
			state,cur,max=acMidAutumnVoApi:getFixedTaskState(taskType) --当前任务状态
		elseif idx == 1 then
			taskTab = {}
			for i=1,2 do
				local task=self.fixedTaskList[idx+i]
				taskType=task.key --任务类型
				reward=FormatItem(task.reward,false,true) --任务完成奖励
				level=1 --任务的品阶
				taskId=idx+1
				state,cur,max=acMidAutumnVoApi:getFixedTaskState(taskType, i+1) --当前任务状态

				taskTab[i] = {taskType=taskType,taskId=taskId,cur=cur,max=max,level=level,reward=reward,state=state,isReachTop=isReachTop}
			end
		elseif idx==2 then
			local orangeMask=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
		    orangeMask:setPosition(ccp(cellWidth/2,35))
		    cell:addChild(orangeMask)

		    local titleUseStr = self.version ==3 and getlocal("midautumn_dailytask_v2_title") or getlocal("midautumn_dailytask_title")
			local titleLb=GetTTFLabelWrap(titleUseStr,30,CCSizeMake(cellWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			titleLb:setColor(G_ColorYellowPro)
			titleLb:setPosition(ccp(cellWidth/2,orangeMask:getPositionY()))
			cell:addChild(titleLb)
		    --刷新任务列表
		    local function refreshHandler()
				if G_checkClickEnable()==false then
				    do
				        return
				    end
				else
				    base.setWaitTime=G_getCurDeviceMillTime()
				end

				local function refreshTask()
					local function callback()
						self:refresh()
						local cost=acMidAutumnVoApi:getRefreshCost()
						playerVoApi:setGems(playerVoApi:getGems()-cost)
					end
					acMidAutumnVoApi:midAutumnRequest(1,1,callback)
				end
				--刷新之前先判断当前任务有没有未领取的奖励
		        local title=getlocal("dialog_title_prompt")
		        local content=getlocal("midautumn_refresh_tip2")
				local flag=acMidAutumnVoApi:hasReward()
				if flag==true then
			        content=getlocal("midautumn_refresh_tip") -- midautumn_RefreshTips1
				end

				local refreshNum = acMidAutumnVoApi:getReValue()
				local content2 = getlocal("midautumn_refresh_num_tips1", {refreshNum .. "/" .. acMidAutumnVoApi:getChangeTaskLimit()})
				content = content .. "\n \n" .. content2

				if refreshNum >= acMidAutumnVoApi:getChangeTaskLimit() then
					-- 刷新次数到上限
		        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("midautumn_refresh_num_tips2"),30)
		        	return
		        end

				do -- 检测金币
					local cost=acMidAutumnVoApi:getRefreshCost()
					if playerVoApi:getGems() < cost then
			            GemsNotEnoughDialog(nil, nil, cost - playerVoApi:getGems(), self.layerNum + 1, cost)
			            return
			        end
				end

		        local tipDialog=smallDialog:new()
		        tipDialog:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0,0,400,350),CCRect(168,86,10,10),refreshTask,title,content,nil,self.layerNum+1)
		    end
			local refreshItem=GetButtonItem("yh_hero_switch1.png","yh_hero_switch2.png","yh_hero_switch1.png",refreshHandler,nil,"",25)
			local refreshBtn=CCMenu:createWithItem(refreshItem)
			refreshBtn:setTouchPriority(-(self.layerNum-1)*20-3)
			refreshBtn:setPosition(ccp(cellWidth-40,orangeMask:getPositionY()))
			cell:addChild(refreshBtn)
			if self.isEnd==true then
				refreshItem:setEnabled(false)
			end
		    local gemSp=CCSprite:createWithSpriteFrameName("IconGold.png")
		    gemSp:setAnchorPoint(ccp(0,0.5))
		    gemSp:setPosition(ccp(refreshBtn:getPositionX()+5,cellHeight/2+35))
		    cell:addChild(gemSp)
		    local cost=acMidAutumnVoApi:getRefreshCost()
		    local costLb=GetTTFLabel(tostring(cost),25)
		    costLb:setAnchorPoint(ccp(1,0.5))
		    costLb:setPosition(ccp(gemSp:getPositionX(),gemSp:getPositionY()))
		    cell:addChild(costLb)
		else
			local task=self.changedTaskList[idx-2]
			taskType=task[1] --任务类型
			taskId=idx-2
			state,cur,max,level,isReachTop=acMidAutumnVoApi:getChangedTaskState(idx-2) --当前任务状态
			if state and cur and max then
				local changedTaskCfg=acMidAutumnVoApi:getChangedTaskCfg()
				for k,v in pairs(changedTaskCfg) do
					if v.key==taskType then
						--遍历获取任务的品级，以及对应品级的奖励
						reward=FormatItem(v.reward[level],false,true)
						do break end
					end
				end
			end
		end

		if idx~=2 then
			local backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("nbSkillBorder.png",CCRect(116, 58, 1, 1),cellClick)
			backSprite:setContentSize(CCSizeMake(cellWidth,cellHeight))
			backSprite:ignoreAnchorPointForPosition(false)
			backSprite:setIsSallow(false)
			backSprite:setTouchPriority(-(self.layerNum-1)*20-1)
			backSprite:setPosition(ccp(cellWidth/2,cellHeight/2))
			cell:addChild(backSprite,1)

			if level and idx>=3 then
				for i=1,level do
					local starSize=25
				    local starSp=CCSprite:createWithSpriteFrameName("stars_n1.png")
		            starSp:setAnchorPoint(ccp(1,0.5))
		            starSp:setScale(starSize/starSp:getContentSize().width)
		            starSp:setPosition(ccp(backSprite:getContentSize().width-20-(i-1)*28,backSprite:getContentSize().height-25))
		            backSprite:addChild(starSp)
				end
			end

			if taskTab and next(taskTab) and idx==1 then
				-- 这里是2个cell显示2组奖励
				self:cellNotIdx1(backSprite, taskTab)
			elseif taskType and level and reward and state and cur and max and taskId then
				task={taskType=taskType,taskId=taskId,cur=cur,max=max,level=level,reward=reward,state=state,isReachTop=isReachTop}
				if idx==0 then
					self:cellIdx0(backSprite,task)
				else
					self:cellNotIdx0(backSprite,task)
				end
			end
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

function acMidAutumnTask:cellIdx0(backSprie,task)
	local strSize2=22
	local subWidth=360
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
        strSize2=22
        subWidth=340
    end
	local desH=backSprie:getContentSize().height/2
	local desW=130
	local titleStr
	local limitNum = acMidAutumnVoApi:getGuValue()
	local limitStr = "(" .. limitNum .. "/" .. acMidAutumnVoApi:getGiftLimit() .. ")"
	local titleuse1 = self.version == 3 and getlocal("midautumn_gu_v2_title") or getlocal("midautumn_gu_title")
	titleStr=titleuse1 .. limitStr
	local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(G_VisibleSizeWidth-340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0,1))
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(ccp(desW,backSprie:getContentSize().height-10))
	backSprie:addChild(titleLb)

	local taskDesc=self.version == 3 and getlocal("midautumn_gu_v2_desc") or getlocal("midautumn_gu_desc")
	local colorTab={}
	local descLb,lbHeight=G_getRichTextLabel(taskDesc,colorTab,strSize2,G_VisibleSizeWidth-subWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
    descLb:setAnchorPoint(ccp(0,1))
	descLb:setPosition(ccp(desW,titleLb:getPositionY()-titleLb:getContentSize().height-10))
	backSprie:addChild(descLb)
	local function touchReward()
		if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end

			local trueReward={}
			for i,v in ipairs(task.reward) do
	            table.insert(trueReward,v)
	        end
	        G_showPropList(self.layerNum+1,true,true,nil,titleuse1,nil,trueReward)
		end
	end
	local rewardSp=LuaCCSprite:createWithSpriteFrameName("friendBtn.png",touchReward)
	rewardSp:setTouchPriority(-(self.layerNum-1)*20-3)
	rewardSp:setAnchorPoint(ccp(0,0.5))
	rewardSp:setPosition(15,desH)
	backSprie:addChild(rewardSp)

	local cost=task.max
	local taskType=task.taskType
	local state=task.state
	if state==1 or state==2 then
		local function purLibao()
			if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
				    do
				        return
				    end
				else
				    base.setWaitTime=G_getCurDeviceMillTime()
				end

				if playerVoApi:getGems()<cost then
		            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
		            return
		        end

		        if acMidAutumnVoApi:getGuValue() >= acMidAutumnVoApi:getGiftLimit() then
		        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("midautumn_reward_box_tips1"),30)
		        	return
		        end

				local function callback()
					local rewardItem=task.reward
					local rewardlist = {}
					for k,v in pairs(rewardItem) do
						table.insert(rewardlist,v)
					end
					require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                    local titleStr=getlocal("EarnRewardStr")
                    local titleStr2 = ""
                    local function showEndHandler()
                    end
                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr,titleStr2,nil,nil,"")
					playerVoApi:setGems(playerVoApi:getGems()-cost)

					self:refresh()
				end


				local saveLocalKey = "keyAcMidAutumnTask"
                local function onSureBuyItem()
					acMidAutumnVoApi:midAutumnRequest(2,1,callback,false)
                end
                local function secondTipFunc(sbFlag)
                    local sValue=base.serverTime .. "_" .. sbFlag
                    G_changePopFlag(saveLocalKey,sValue)
                end
                if G_isPopBoard(saveLocalKey) then
                    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,onSureBuyItem,secondTipFunc)
                else
                    onSureBuyItem()
                end
			end
		end
		local purItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",purLibao,nil,getlocal("buy"),25/0.7)
		purItem:setAnchorPoint(ccp(0.5,0.5))
		purItem:setScale(0.7)
		local purBtn=CCMenu:createWithItem(purItem)
		purBtn:setTouchPriority(-(self.layerNum-1)*20-3)
		purBtn:setPosition(ccp(backSprie:getContentSize().width-90,desH-20))
		backSprie:addChild(purBtn)
		if self.isEnd==true then
			purItem:setEnabled(false)
		end

		local costLabel=GetTTFLabel(tostring(cost),25)
		costLabel:setAnchorPoint(ccp(0,0))
		costLabel:setPosition(purItem:getContentSize().width/2-25,purItem:getContentSize().height+5)
		costLabel:setColor(G_ColorYellowPro)
		purItem:addChild(costLabel)
		costLabel:setScale(1/purItem:getScale())

		local tenGem=CCSprite:createWithSpriteFrameName("IconGold.png")
		tenGem:setAnchorPoint(ccp(0,0.5))
		tenGem:setPosition(costLabel:getContentSize().width,costLabel:getContentSize().height/2)
		costLabel:addChild(tenGem)
	elseif state==3 then
		local alreadyLb=GetTTFLabelWrap(getlocal("hasBuy"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		alreadyLb:setAnchorPoint(ccp(0.5,0.5))
		alreadyLb:setColor(G_ColorGreen)
		alreadyLb:setPosition(ccp(backSprie:getContentSize().width-90,desH))
		backSprie:addChild(alreadyLb)
	end
end

function acMidAutumnTask:cellNotIdx0(backSprie,task)
	local strSize2=21
	local strWidthSize2=20
	local lbWidth,lbWidth2=180,120
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
        strSize2=22
        strWidthSize2=90
    end
	local taskType=task.taskType
	local cur=task.cur
	local max=task.max
	local titleStr1
	if cur>max then
		cur=max
	end
	local offsetH=0
	local colorTab={}
	local isRichLabel=G_isShowRichLabel()
	if taskType=="gb" then
		colorTab={nil,G_ColorYellowPro}
		if isRichLabel==true then
			titleStr1=getlocal("activity_chunjiepansheng_gb_title2",{"<rayimg>"..cur.."/"..max.."<rayimg>"})
		else
			titleStr1=getlocal("activity_chunjiepansheng_gb_title2",{cur.."/"..max})
		end
	else
		-- 在api写一个方法，知道完成多少次了
		if isRichLabel==true then
			titleStr1=getlocal("activity_chunjiepansheng_" .. taskType .. "_title",{"<rayimg>"..cur,max.."<rayimg>"})
		else
			titleStr1=getlocal("activity_chunjiepansheng_" .. taskType .. "_title",{cur,max})
		end
		colorTab={nil,G_ColorYellowPro,nil}
	end
	local lbStarWidth=15
	local realTextW
	if isRichLabel==true then
		if taskType=="gb" then
			titleStr1=titleStr1.."<rayimg>IconGold.png<rayimg>"
		end
	else
		local titleLb=GetTTFLabel(titleStr1,strSize2)
		realTextW=titleLb:getContentSize().width
	end
    local titleLb,lbHeight=G_getRichTextLabel(titleStr1,colorTab,strSize2,backSprie:getContentSize().width-lbWidth2-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
    titleLb:setAnchorPoint(ccp(0,1))
	titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-10-offsetH))
	backSprie:addChild(titleLb)
	if taskType=="gb" then
		if realTextW then
			local titleW=titleLb:getContentSize().width
			if realTextW>titleW then
				realTextW=titleW
			end
			local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
			goldSp:setAnchorPoint(ccp(0,0))
			goldSp:setPosition(titleLb:getPositionX()+realTextW,titleLb:getPositionY()-lbHeight-3)
			backSprie:addChild(goldSp)
		end
	end

	local rewardItemTitle = "" -- getlocal("activity_rechargeDouble_get")
	local desH=backSprie:getContentSize().height-lbHeight-20+2*offsetH
	local getLb=GetTTFLabel(rewardItemTitle,strSize2-3)
	local desLb=GetTTFLabelWrap(rewardItemTitle,strSize2-3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
	desLb:setPosition(ccp(lbStarWidth,desH/2))
	backSprie:addChild(desLb)
	local realDesLbW=getLb:getContentSize().width
	if realDesLbW>desLb:getContentSize().width then
		realDesLbW=desLb:getContentSize().width
	end
	local startX=desLb:getPositionX()+realDesLbW-20
	for k,v in pairs(task.reward) do
		local icon,scale=G_getItemIcon(v,80,true,self.layerNum+1,nil,self.tv)
		icon:setTouchPriority(-(self.layerNum-1)*20-3)
		backSprie:addChild(icon)
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(startX+(k-1)*80+20,desH/2)

		local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(icon:getContentSize().width-5,5)
		numLabel:setScale(1/scale)
		icon:addChild(numLabel,1)
	end
	local state=task.state
	if state==1 then
		local function goTiantang()
			if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
				    do
				        return
				    end
				else
				    base.setWaitTime=G_getCurDeviceMillTime()
				end

				G_goToDialog(taskType,4,true)
			end
		end
		local goItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),25/0.7)
		goItem:setScale(0.7)
		local goBtn=CCMenu:createWithItem(goItem)
		goBtn:setTouchPriority(-(self.layerNum-1)*20-3)
		goBtn:setPosition(ccp(backSprie:getContentSize().width-90,desH/2))
		backSprie:addChild(goBtn)
		if self.isEnd==true then
			goItem:setEnabled(false)
		end
	elseif state==2 then
		local function rewardHandler()
			if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
				    do
				        return
				    end
				else
				    base.setWaitTime=G_getCurDeviceMillTime()
				end

				local action=2
				if taskType=="gb" then
					action=2
				else
					action=3
				end
				local function callback()
					self:refresh()
				end
				if task.isReachTop and task.isReachTop==true and (taskType=="au" or taskType=="wp" or taskType=="hu" or taskType=="rc") then
					acMidAutumnVoApi:midAutumnRequest(action,task.taskId,callback,nil,taskType)
				else
					acMidAutumnVoApi:midAutumnRequest(action,task.taskId,callback)
				end
			end
		end
		local rewardItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rewardHandler,nil,getlocal("daily_scene_get"),25/0.7)
		rewardItem:setScale(0.7)
		local rewardBtn=CCMenu:createWithItem(rewardItem)
		rewardBtn:setTouchPriority(-(self.layerNum-1)*20-3)
		rewardBtn:setPosition(ccp(backSprie:getContentSize().width-90,desH/2))
		backSprie:addChild(rewardBtn)
		if self.isEnd==true then
			rewardItem:setEnabled(false)
		end
	elseif state==3 then
		local alreadyLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		alreadyLb:setAnchorPoint(ccp(0.5,0.5))
		alreadyLb:setColor(G_ColorGreen)
		alreadyLb:setPosition(ccp(backSprie:getContentSize().width-90,desH/2))
		backSprie:addChild(alreadyLb)
	end
end

function acMidAutumnTask:cellNotIdx1(backSprie, taskTab)
	local middleLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
	middleLine:setContentSize(CCSizeMake(backSprie:getContentSize().width-20,middleLine:getContentSize().height))
	middleLine:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2))
	middleLine:setAnchorPoint(ccp(0.5,0.5))
	backSprie:addChild(middleLine,2)

	for i,v in ipairs(taskTab) do
		local showY = backSprie:getContentSize().height - (backSprie:getContentSize().height/2 - 5) * (i - 1)
		local task = v
		local strSize2=21
		local strWidthSize2=20
		local lbWidth,lbWidth2=180,120
	    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
	        strSize2=22
	        strWidthSize2=90
	    end
		local taskType=task.taskType
		local cur=task.cur
		local max=task.max
		local titleStr1
		if cur>max then
			cur=max
		end
		local offsetH=0
		local colorTab={}
		local isRichLabel=G_isShowRichLabel()
		colorTab={nil,G_ColorYellowPro}
		if isRichLabel==true then
			titleStr1=getlocal("activity_chunjiepansheng_gb_title2",{"<rayimg>"..cur.."/"..max.."<rayimg>"})
		else
			titleStr1=getlocal("activity_chunjiepansheng_gb_title2",{cur.."/"..max})
		end
		local lbStarWidth=15
		local realTextW
		if isRichLabel==true then
			titleStr1=titleStr1.."<rayimg>IconGold.png<rayimg>"
		else
			local titleLb=GetTTFLabel(titleStr1,strSize2)
			realTextW=titleLb:getContentSize().width
		end
	    local titleLb,lbHeight=G_getRichTextLabel(titleStr1,colorTab,strSize2,backSprie:getContentSize().width-lbWidth2-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
	    titleLb:setAnchorPoint(ccp(0,1))
		titleLb:setPosition(ccp(lbStarWidth,showY-10-offsetH))
		backSprie:addChild(titleLb)
		if realTextW then
			local titleW=titleLb:getContentSize().width
			if realTextW>titleW then
				realTextW=titleW
			end
			local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
			goldSp:setAnchorPoint(ccp(0,0))
			goldSp:setPosition(titleLb:getPositionX()+realTextW,titleLb:getPositionY()-lbHeight-3)
			backSprie:addChild(goldSp)
		end

		local rewardItemTitle = "" -- getlocal("activity_rechargeDouble_get")
		local desH=backSprie:getContentSize().height-lbHeight-20+2*offsetH
		local getLb=GetTTFLabel(rewardItemTitle,strSize2-3)
		local desLb=GetTTFLabelWrap(rewardItemTitle,strSize2-3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    desLb:setAnchorPoint(ccp(0,0.5))
		desLb:setPosition(ccp(lbStarWidth,showY - 90))
		backSprie:addChild(desLb)
		local realDesLbW=getLb:getContentSize().width
		if realDesLbW>desLb:getContentSize().width then
			realDesLbW=desLb:getContentSize().width
		end
		local startX=desLb:getPositionX()+realDesLbW-20
		for k,v in pairs(task.reward) do
			local icon,scale=G_getItemIcon(v,80,true,self.layerNum+1,nil,self.tv)
			icon:setTouchPriority(-(self.layerNum-1)*20-3)
			backSprie:addChild(icon)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(startX+(k-1)*80+20,desLb:getPositionY())

			local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
			numLabel:setAnchorPoint(ccp(1,0))
			numLabel:setPosition(icon:getContentSize().width-5,5)
			numLabel:setScale(1/scale)
			icon:addChild(numLabel,1)

			if v.type=="p" and propCfg[v.key] and propCfg[v.key].useGetArmor then
				armorMatrixVoApi:addLightEffect(icon, propCfg[v.key].Mid)
			end
		end
		local state=task.state
		if state==1 then
			local function goTiantang()
				if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
					    do
					        return
					    end
					else
					    base.setWaitTime=G_getCurDeviceMillTime()
					end

					G_goToDialog(taskType,4,true)
				end
			end
			local goItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),25/0.7)
			goItem:setScale(0.7)
			local goBtn=CCMenu:createWithItem(goItem)
			goBtn:setTouchPriority(-(self.layerNum-1)*20-3)
			goBtn:setPosition(ccp(backSprie:getContentSize().width-90,desLb:getPositionY() + 15))
			backSprie:addChild(goBtn)
			if self.isEnd==true then
				goItem:setEnabled(false)
			end
		elseif state==2 then
			local function rewardHandler()
				if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
					    do
					        return
					    end
					else
					    base.setWaitTime=G_getCurDeviceMillTime()
					end

					local action= 2
					local function callback()
						self:refresh()
					end
					if task.isReachTop and task.isReachTop==true and (taskType=="au" or taskType=="wp" or taskType=="hu" or taskType=="rc") then
						acMidAutumnVoApi:midAutumnRequest(action,task.taskId,callback,nil,taskType,i+1)
					else
						acMidAutumnVoApi:midAutumnRequest(action,task.taskId,callback,nil,nil,i+1)
					end
				end
			end
			local rewardItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rewardHandler,nil,getlocal("daily_scene_get"),25/0.7)
			rewardItem:setScale(0.7)
			local rewardBtn=CCMenu:createWithItem(rewardItem)
			rewardBtn:setTouchPriority(-(self.layerNum-1)*20-3)
			rewardBtn:setPosition(ccp(backSprie:getContentSize().width-90,desLb:getPositionY() + 15))
			backSprie:addChild(rewardBtn)
			if self.isEnd==true then
				rewardItem:setEnabled(false)
			end
		elseif state==3 then
			local alreadyLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			alreadyLb:setAnchorPoint(ccp(0.5,0.5))
			alreadyLb:setColor(G_ColorGreen)
			alreadyLb:setPosition(ccp(backSprie:getContentSize().width-90,desLb:getPositionY() + 15))
			backSprie:addChild(alreadyLb)
		end
	end
end

--领奖时刷新
function acMidAutumnTask:refreshTvAndProgress()
	self:refresh()
end

function acMidAutumnTask:refresh()
	if self.tv then
		self.changedTaskList=acMidAutumnVoApi:getChangedTaskList()
		self.changedTaskNum=SizeOfTable(self.changedTaskList)
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acMidAutumnTask:tick()
    local isEnd=acMidAutumnVoApi:acIsStop()
    if isEnd~=self.isEnd and isEnd==true then
    	self.isEnd=isEnd
    	self:refresh()
    end
    --跨天刷新任务
    local refreshFlag=acMidAutumnVoApi:isRefreshTask()
    if refreshFlag==true then
        self:refresh()
        acMidAutumnVoApi:setRefreshTaskFlag(false)
    end
end

function acMidAutumnTask:dispose()
	base:removeFromNeedRefresh(self)
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.parent=nil
	self.infoHeight=150
	self.fixedTaskList=nil
	self.changedTaskList=nil
    self.isTodayFlag=true
    self.isEnd=false
    self.cellHeight=nil

    spriteController:removePlist("public/armorMatrixEffect.plist")
    spriteController:removeTexture("public/armorMatrixEffect.png")
end