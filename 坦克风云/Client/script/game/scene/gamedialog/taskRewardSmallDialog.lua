taskRewardSmallDialog=smallDialog:new()

function taskRewardSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.reward={}
	self.dialogHeight=510
	self.dialogWidth=550
	-- self.pageCellNum=10
	self.cellHeight=120
	return nc
end

function taskRewardSmallDialog:init(index,layerNum,callback)
	self.index=index
	self.layerNum=layerNum
	local function nilFunc()
	end
	-- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()

	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgSize=size
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
	lineSp1:setAnchorPoint(ccp(0.5,1))
	lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
	self.bgLayer:addChild(lineSp1)
	local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
	lineSp2:setAnchorPoint(ccp(0.5,0))
	lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
	self.bgLayer:addChild(lineSp2)
	lineSp2:setRotation(180)

	local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp2)

	-- local function close()
	-- 	PlayEffect(audioCfg.mouseClick)
	-- 	return self:close()
	-- end
	-- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	-- closeBtnItem:setPosition(0,0)
	-- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	-- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	-- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	-- self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	-- dialogBg:addChild(self.closeBtn)

	
	local rCfg
	local rewardLevel = taskVoApi:getRewardLevel()

	if self.index and dailyTaskCfg2 and dailyTaskCfg2.finalTask and dailyTaskCfg2.finalTask[rewardLevel] and dailyTaskCfg2.finalTask[rewardLevel]["s200"..self.index] then
		rCfg=dailyTaskCfg2.finalTask[rewardLevel]["s200"..self.index]
	end

	local lbSize2 = 30
	if G_getCurChoseLanguage() =="ko" then
		lbSize2 =25
	end
	local titleStr=""
	local pointNum
	if rCfg and rCfg.require and rCfg.require[1] then
		pointNum=rCfg.require[1]
		titleStr=getlocal("daily_task_box",{pointNum})
	end
	local titleLb=GetTTFLabelWrap(titleStr,lbSize2,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-30))
	dialogBg:addChild(titleLb,1)

	local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0))
    lightSp:setOpacity(150)
    lightSp:setPosition(self.bgLayer:getContentSize().width/2,size.height-titleLb:getContentSize().height-33)
    lightSp:setScaleX(3.5)
    lightSp:setScaleY(2)
    self.bgLayer:addChild(lightSp)

	-- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	-- lineSp:setScale((size.width-100)/lineSp:getContentSize().width)
	-- lineSp:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-50))
	-- self.bgLayer:addChild(lineSp)

	local cellWidth=self.bgLayer:getContentSize().width
	local rewardTb={}
	if rCfg and rCfg.award then
		local award=rCfg.award
		rewardTb=FormatItem(award,false,true)
	end
	local function tvCallBack(handler,fn,idx,cel)
	    if fn=="numberOfCellsInTableView" then
	        return SizeOfTable(rewardTb)
	    elseif fn=="tableCellSizeForIndex" then
	        local tmpSize=CCSizeMake(cellWidth,self.cellHeight)
	        return tmpSize
	    elseif fn=="tableCellAtIndex" then
	        local cell=CCTableViewCell:new()
	        cell:autorelease()

	        local cellHeight=self.cellHeight
	        local item=rewardTb[idx+1]
	        if item then
	            local sp,scale=G_getItemIcon(item,100)
	            sp:setPosition(ccp(105,cellHeight/2))
	            cell:addChild(sp,1)
	            local nameLb=GetTTFLabel(item.name,25)
	            nameLb:setAnchorPoint(ccp(0,0.5))
	            nameLb:setPosition(ccp(180,cellHeight/2+35))
	            cell:addChild(nameLb,1)
	            local num=FormatNumber(item.num)
	            if item and item.type=="h" and item.eType=="h" then
	            	num=1
	            end
	            local numLb=GetTTFLabel(getlocal("propInfoNum",{num}),25)
	            numLb:setAnchorPoint(ccp(0,0.5))
	            numLb:setPosition(ccp(180,cellHeight/2-35))
	            cell:addChild(numLb,1)
	        end
	        if idx + 1 ~= SizeOfTable(rewardTb) then
	        	local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
			    bottomLine:setContentSize(CCSizeMake(cellWidth - 100, bottomLine:getContentSize().height))
			    bottomLine:setPosition(ccp(cellWidth * 0.5,0))
			    cell:addChild(bottomLine)
	        end
	        return cell
	    elseif fn=="ccTouchBegan" then
	        isMoved=false
	        return true
	    elseif fn=="ccTouchMoved" then
	        isMoved=true
	    elseif fn=="ccTouchEnded"  then

	    end
	end
	local hd= LuaEventHandler:createHandler(tvCallBack)
	local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,size.height-titleLb:getContentSize().height-180-20),nil)
	tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
	tv:setPosition(ccp(35,155))
	self.bgLayer:addChild(tv,2)
	tv:setMaxDisToBottomOrTop(120)

	local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(cellWidth - 80,size.height-titleLb:getContentSize().height-160-20))
    dialogBg2:setAnchorPoint(ccp(0.5,0))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width * 0.5,145)
    self.bgLayer:addChild(dialogBg2,3)


	-- local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
	-- lineSp2:setScale((size.width-100)/lineSp2:getContentSize().width)
	-- lineSp2:setPosition(ccp(size.width/2,110))
	-- self.bgLayer:addChild(lineSp2)

    local function rewardHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local acPoint1=taskVoApi:getAcPoint()
		local isReward1=taskVoApi:acPointIsReward(self.index)
		local sid=self.index+2000
		local isDailyPoint=true
		local point=taskVoApi:getAddAlliancePoint(sid,isDailyPoint)
		if pointNum then
			if acPoint1>=pointNum and isReward1==false then
				local function rewardPointCallback(fn,data)
					local ret,sData=base:checkServerData(data)
	        		if ret==true then
	        			local isShowAddPoint=false
            			if point and point>0 and allianceVoApi:isHasAlliance()==true then
	        				if sData.data.rais and sData.data.rais==1 then
	        					taskVoApi:addAlliancePoint(sid,isDailyPoint)
	        					isShowAddPoint=true
	        				elseif sData.data.rais and sData.data.rais==-1 then
	        					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("reward_alliance_point_max"),nil,self.layerNum+1)
	        				end
	        			end

			            local awardStr,awardTab = taskVoApi:getAwardStr(sid,true,isShowAddPoint,isDailyPoint)
			            local realReward=playerVoApi:getTrueReward(awardTab)
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),awardStr,28,nil,nil,realReward)
						if realReward and SizeOfTable(realReward)>0 then
							for k,v in pairs(realReward) do
								G_addPlayerAward(v.type,v.key,v.id,v.num,true,true)
							end
						end
						if callback then
							callback()
						end
	        		end
	        	end
				local tid="s"..tostring(sid)
				socketHelper:dailytaskRewardPoint(tid,rewardPointCallback)
			end
		end

        self:close()
    end

    local str
	local rewardLevel,levelMax = taskVoApi:getRewardLevel()
	if rewardLevel < levelMax then
		str = getlocal("rewardUpdateNeedLevel",{dailyTaskCfg2.levelGroup[rewardLevel+1]})
	else
		str = getlocal("rewardUpdateMaxLevel",{dailyTaskCfg2.levelGroup[levelMax]})
	end
	local rewardLevelLabel = GetTTFLabel(str,22,true)
	rewardLevelLabel:setAnchorPoint(ccp(0.5,0.5))
	rewardLevelLabel:setPosition(ccp(size.width/2,110))
	rewardLevelLabel:setColor(G_ColorYellowPro)
	dialogBg:addChild(rewardLevelLabel,2)

	local acPoint=taskVoApi:getAcPoint()
	local isReward=taskVoApi:acPointIsReward(self.index)
	local itemStr=getlocal("ok")
	if pointNum then
		if acPoint>=pointNum and isReward==false then
			itemStr=getlocal("daily_scene_get")
		end
	end
    local rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",rewardHandler,11,itemStr,30)
    rewardItem:setScale(0.85)
    local rewardMenu=CCMenu:createWithItem(rewardItem)
    rewardMenu:setPosition(ccp(size.width/2,50))
    rewardMenu:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(rewardMenu)


	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end
