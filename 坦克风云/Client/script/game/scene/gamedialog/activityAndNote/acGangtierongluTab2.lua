acGangtierongluTab2 = {}

function acGangtierongluTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellHeight=310
	return nc
end


function acGangtierongluTab2:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:setTargetList()
	self:initLayer()
	self:initTableView()
	return self.bgLayer
end

function acGangtierongluTab2:setTargetList()

	self.targetList={}
	local alreadyTb,readyTb,noReadyTb=acGangtierongluVoApi:getThreeTb()

	for i=1,#readyTb do
		table.insert(self.targetList,readyTb[i])
	end

	for i=1,#noReadyTb do
		table.insert(self.targetList,noReadyTb[i])
	end

	for i=1,#alreadyTb do
		table.insert(self.targetList,alreadyTb[i])
	end

end



function acGangtierongluTab2:initLayer()
	local h = G_VisibleSizeHeight-200
	local function touchInfo()
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local tabStr = {"\n",getlocal("activity_gangtieronglu_tab2_tip2"), getlocal("activity_gangtieronglu_tab2_tip1"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
		sceneGame:addChild(dialog,self.layerNum+1)

	end
	local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touchInfo,1,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-35, h))
	self.bgLayer:addChild(menuDesc,2)
end

function acGangtierongluTab2:initTableView()
	local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-280),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(80)
    
end

function acGangtierongluTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=SizeOfTable(self.targetList)
	    return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
		cell:autorelease()

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function nilFunc(hd,fn,idx)
		end
		local hei =self.cellHeight-4

		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)


		local titileStr = getlocal("activity_gangtieronglu_targetT" .. self.targetList[idx+1].index)
		local titleLb = GetTTFLabelWrap(titileStr,25,CCSizeMake(440,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		backSprie:addChild(titleLb)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(10, backSprie:getContentSize().height-40)

		local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSp:setAnchorPoint(ccp(0.5,0.5));
		lineSp:setPosition(backSprie:getContentSize().width/2,80)
		lineSp:setScaleX((backSprie:getContentSize().width-60)/lineSp:getContentSize().width)
		backSprie:addChild(lineSp)

		local lineSp1 = CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSp1:setAnchorPoint(ccp(0.5,0.5));
		lineSp1:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height-80)
		lineSp1:setScaleX((backSprie:getContentSize().width-60)/lineSp1:getContentSize().width)
		backSprie:addChild(lineSp1)

		local reward=FormatItem(self.targetList[idx+1].reward,nil,true) or {}
		for i=1,#reward do
			local item = reward[i]
			local function callback()
				propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
			end
			local icon,scale=G_getItemIcon(item,100,false,self.layerNum,callback,self.tv)
			backSprie:addChild(icon)
			icon:setAnchorPoint(ccp(0.5,1))
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setPosition(100+(i-1)*130, backSprie:getContentSize().height-103)

			local numLb = GetTTFLabel("x" .. item.num,24)
			numLb:setAnchorPoint(ccp(1,0))
			icon:addChild(numLb)
			numLb:setPosition(icon:getContentSize().width-10, 5)
			numLb:setScale(1/scale)
		end

		local str=""
		local conditions = self.targetList[idx+1].conditions
		local myType = conditions.type
		local num = FormatNumber(conditions.num)
		local num1 = conditions.num -- 需要完成任务数量
		local num2 = 0  -- 已完成任务数量
		if myType=="a" then
			local myNum = FormatNumber(acGangtierongluVoApi:getA())
			num2=acGangtierongluVoApi:getA()
			str=getlocal("activity_gangtieronglu_target1",{num,myNum})
		elseif myType=="r" then
			local name = getItem(conditions.name,"o")
			local myNum = FormatNumber(acGangtierongluVoApi:getRById(conditions.name))
			num2=acGangtierongluVoApi:getRById(conditions.name)
			str=getlocal("activity_gangtieronglu_target2",{name,num,myNum})
		elseif myType=="h" then
			local myNum = FormatNumber(acGangtierongluVoApi:getH())
			num2=acGangtierongluVoApi:getH()
			str=getlocal("activity_gangtieronglu_target3",{num,myNum})
		else
			local name = getItem(conditions.name,"o")
			local myNum = FormatNumber(acGangtierongluVoApi:getGById(conditions.name))
			num2=acGangtierongluVoApi:getGById(conditions.name)
			str=getlocal("activity_gangtieronglu_target4",{name,num,myNum})
		end
		local descLbSiz = 20
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
			descLbSiz =25
		end
		local descLb=GetTTFLabelWrap(str,descLbSiz,CCSizeMake(420,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		backSprie:addChild(descLb)
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(10, 40)

		

		local function touchItem()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
			    PlayEffect(audioCfg.mouseClick)
			    local function callback(fn,data)
			    	local ret,sData = base:checkServerData(data)
			    	if ret==true then
			    		if sData and sData.data and sData.data.gangtieronglu then
                            acGangtierongluVoApi:updateSpecialData(sData.data.gangtieronglu)
                        end
                        G_showRewardTip(reward,true)
                        for k,v in pairs(reward) do
                        	if v.type and v.type=="u" then
                        	else
                        		G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true,false)
                        	end
                            
                        end
                        self:refresh()
			    	end
			    end
			   	socketHelper:acGangtierongluTotal(3,nil,nil,self.targetList[idx+1].key,callback)
			end
			
		end
		local lingquItem1=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touchItem,2,getlocal("daily_scene_get"),25)
		lingquItem1:setAnchorPoint(ccp(0.5,0.5))
		lingquItem1:setScale(0.8)
		if G_getCurChoseLanguage() == "ko" then
			lingquItem1:setScale(0.6)
		end
		local lingquBtn1=CCMenu:createWithItem(lingquItem1);
		lingquBtn1:setTouchPriority(-(self.layerNum-1)*20-2);
		lingquBtn1:setPosition(ccp(500,40))
		backSprie:addChild(lingquBtn1)

		local aLingquLb1 = GetTTFLabel(getlocal("activity_hadReward"),25)
		backSprie:addChild(aLingquLb1)
		aLingquLb1:setPosition(ccp(500,40))
		aLingquLb1:setColor(G_ColorGreen)

		if num1>num2 then
			descLb:setColor(G_ColorRed)
			lingquItem1:setEnabled(false)
		else
			descLb:setColor(G_ColorGreen)
			lingquItem1:setEnabled(true)
		end
		

		local flagTb=acGangtierongluVoApi:getFlagTb()
		local key = self.targetList[idx+1].key
		if flagTb[key] then
			aLingquLb1:setVisible(true)
			lingquItem1:setEnabled(false)
			lingquItem1:setVisible(false)
		else
			aLingquLb1:setVisible(false)
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

function acGangtierongluTab2:refresh()
	self:setTargetList()
	local recordPoint=self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)
end




function acGangtierongluTab2:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeight=nil
    self.targetList=nil
end
