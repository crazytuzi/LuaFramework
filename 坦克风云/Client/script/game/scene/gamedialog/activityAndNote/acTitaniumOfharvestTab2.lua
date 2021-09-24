acTitaniumOfharvestTab2={

}

function acTitaniumOfharvestTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.isToday=true

    return nc
end

function acTitaniumOfharvestTab2:init(layerNum)
 	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	-- 活动info
	local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),25)
    timeTitle:setAnchorPoint(ccp(0.5,1))
	timeTitle:setPosition(ccp(G_VisibleSize.width/2, G_VisibleSize.height-175))
	self.bgLayer:addChild(timeTitle)
	timeTitle:setColor(G_ColorGreen)

	local timeLabel = GetTTFLabelWrap(acTitaniumOfharvestVoApi:getTimeStr(),25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLabel:setAnchorPoint(ccp(0.5,1))
	timeLabel:setPosition(ccp(G_VisibleSize.width/2, G_VisibleSize.height-210))
	self.bgLayer:addChild(timeLabel)
	self.timeLb=timeLabel
	self:updateAcTime()

	local function touchDesItem()
    	PlayEffect(audioCfg.mouseClick)
	    local tabStr={}
	    local td=smallDialog:new()
	    tabStr = {"\n",getlocal("activity_TitaniumOfharvest_tab2_des3"),"\n",getlocal("activity_TitaniumOfharvest_tab2_des2"),"\n",getlocal("activity_TitaniumOfharvest_tab2_des1"),"\n"}
	    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
	    sceneGame:addChild(dialog,self.layerNum+1)
    end
    local desItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchDesItem,nil,nil,0)
	desItem:setAnchorPoint(ccp(1,1))
	desItem:setScale(0.8)
	local desMenu=CCMenu:createWithItem(desItem)
	desMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	desMenu:setPosition(ccp(G_VisibleSize.width-40, G_VisibleSize.height-170))
	self.bgLayer:addChild(desMenu)

	local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    descBg:setContentSize(CCSizeMake(430,180))
    descBg:setAnchorPoint(ccp(0,0))
    descBg:setPosition(ccp(180,self.bgLayer:getContentSize().height- 510))
    self.bgLayer:addChild(descBg)

    local characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(20,self.bgLayer:getContentSize().height - 510))
    self.bgLayer:addChild(characterSp)

    local desTv,desLabel = G_LabelTableView(CCSizeMake(descBg:getContentSize().width-100, descBg:getContentSize().height-20),getlocal("activity_TitaniumOfharvest_tab2_des"),25,kCCTextAlignmentLeft)
 	descBg:addChild(desTv)
    desTv:setPosition(ccp(90,10))
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    desTv:setMaxDisToBottomOrTop(100) 

    local lineSprie =CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 3))
	lineSprie:ignoreAnchorPointForPosition(false);
	lineSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-515))
	self.bgLayer:addChild(lineSprie)

    -- tableView 信息
    self:initTableView()

    -- 注意
    local tipLb = GetTTFLabelWrap(getlocal("activity_TitaniumOfharvest_tab2_tip"),25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(tipLb)
    tipLb:setAnchorPoint(ccp(0,0))
    tipLb:setColor(G_ColorRed)
    tipLb:setPosition(ccp(30,50))

	return self.bgLayer
end

function acTitaniumOfharvestTab2:initTableView()
	local task = acTitaniumOfharvestVoApi:getTask()
	self.strTb={
		getlocal("activity_TitaniumOfharvest_tab2_mission1"),
		getlocal("activity_TitaniumOfharvest_tab2_mission2",{FormatNumber(task["t"][1][1])}),
		getlocal("activity_TitaniumOfharvest_tab2_mission3",{FormatNumber(task["r"][1][1])}),
		getlocal("activity_TitaniumOfharvest_tab2_mission3",{FormatNumber(task["r"][2][1])}),
	}

	self.numStrTb={
		FormatNumber(task["l"][1][2]),
		FormatNumber(task["t"][1][2]),
		FormatNumber(task["r"][1][2]),
		FormatNumber(task["r"][2][2]),
	}

	-- 0 前往  1 领取  2 已领取
	self.flagTb=acTitaniumOfharvestVoApi:getMissionFlag()

    local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-630),nil)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(10,100))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(80)
	self.bgLayer:addChild(self.tv)
end

function acTitaniumOfharvestTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 4
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		if G_getCurChoseLanguage() =="de" then
			tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,200)
		else
			tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,150)
		end
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end
		local hei
		if G_getCurChoseLanguage() =="de" then
			 hei=200-4
		else
			 hei=150-4
		end
	   
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, hei))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(20,2))
		cell:addChild(backSprie)

		local strSize = 25
		if G_getCurChoseLanguage() =="en" then
			strSize =23
		end

		local missionLb =  GetTTFLabelWrap(self.strTb[idx+1],strSize,CCSizeMake(backSprie:getContentSize().width-210,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		missionLb:setAnchorPoint(ccp(0,1))
		missionLb:setPosition(ccp(30,backSprie:getContentSize().height-20))
		missionLb:setColor(G_ColorYellowPro)
		backSprie:addChild(missionLb)

		local taiSp = CCSprite:createWithSpriteFrameName("IconUranium.png")
	    taiSp:setPosition(ccp(30,20))
	    taiSp:setAnchorPoint(ccp(0,0))
	    backSprie:addChild(taiSp)

	    local xLb = GetTTFLabel("x" .. self.numStrTb[idx+1],25)
	    xLb:setAnchorPoint(ccp(0,0.5))
	    xLb:setPosition(ccp(taiSp:getContentSize().width+10,taiSp:getContentSize().height/2))
	    taiSp:addChild(xLb)

	    local function touchBtnItem()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
					do
						return
					end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
		    	PlayEffect(audioCfg.mouseClick)

		    	-- 登陆
		    	if idx==0 and self.flagTb[idx+1]==1 then
		    		-- 发送请求（登陆领取） 改变状态
		    		local function callBack(fn,data)
				        local ret,sData = base:checkServerData(data)
			            if ret==true then 
			            	acTitaniumOfharvestVoApi:setlFlag(2)
			            	self.flagTb=acTitaniumOfharvestVoApi:getMissionFlag()
			         		self.tv:reloadData()

			         		local task = acTitaniumOfharvestVoApi:getTask()
			         		local name,pic,desc,id,index,eType,equipId=getItem("r4","u")
			            	G_addPlayerAward("u","r4",id,task["l"][1][2],false,true)
			            	
			            	local str = getlocal("daily_lotto_tip_10") .. name .. self.numStrTb[idx+1]
			            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
			            end                
					end
		    		socketHelper:TitaniumOfharvestGetReward(nil,1,nil,nil,callBack)
		    	end

		    	-- 前往坦克工厂 cell2
		    	if idx==1 and self.flagTb[idx+1]==0 then
		    		self:goTankFactory()
	    		elseif idx==1 and self.flagTb[idx+1]==1 then
		    		-- 发送请求（建造tank） 改变状态
		    		local function callBack(fn,data)
				        local ret,sData = base:checkServerData(data)
			            if ret==true then 
			            	acTitaniumOfharvestVoApi:setTankFlag(2)
			            	self.flagTb=acTitaniumOfharvestVoApi:getMissionFlag()
			         		self.tv:reloadData()

			         		local task = acTitaniumOfharvestVoApi:getTask()
			         		local name,pic,desc,id,index,eType,equipId=getItem("r4","u")
			            	G_addPlayerAward("u","r4",id,task["t"][1][2],false,true)

			            	local str = getlocal("daily_lotto_tip_10") .. name .. self.numStrTb[idx+1]
			            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
			            end                
					end
		    		socketHelper:TitaniumOfharvestGetReward(nil,nil,1,nil,callBack)
		    	end

		    	-- 世界地图 cell3 or cell4
		    	if (idx==2 and self.flagTb[idx+1]==0) or (idx==3 and self.flagTb[idx+1]==0) then
					self:goWorld()
				elseif idx==2 and self.flagTb[idx+1]==1 then
					local function callBack(fn,data)
				        local ret,sData = base:checkServerData(data)
			            if ret==true then 
			            	acTitaniumOfharvestVoApi:setrFlag1(2)
			            	self.flagTb=acTitaniumOfharvestVoApi:getMissionFlag()
			         		self.tv:reloadData()

			         		local task = acTitaniumOfharvestVoApi:getTask()
			         		local name,pic,desc,id,index,eType,equipId=getItem("r4","u")
			            	G_addPlayerAward("u","r4",id,task["r"][1][2],false,true)

			            	local str = getlocal("daily_lotto_tip_10") .. name .. self.numStrTb[idx+1]
			            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
			            end                
					end
		    		socketHelper:TitaniumOfharvestGetReward(nil,nil,nil,1,callBack)
				elseif idx==3 and self.flagTb[idx+1]==1 then
					local function callBack(fn,data)
				        local ret,sData = base:checkServerData(data)
			            if ret==true then 
			            	acTitaniumOfharvestVoApi:setrFlag2(2)
			            	self.flagTb=acTitaniumOfharvestVoApi:getMissionFlag()
			         		self.tv:reloadData()

			         		local task = acTitaniumOfharvestVoApi:getTask()
			         		local name,pic,desc,id,index,eType,equipId=getItem("r4","u")
			            	G_addPlayerAward("u","r4",id,task["r"][2][2],false,true)

			            	local str = getlocal("daily_lotto_tip_10") .. name .. self.numStrTb[idx+1]
			            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
			            end                
					end
		    		socketHelper:TitaniumOfharvestGetReward(nil,nil,nil,2,callBack)
		    	end
		    end
	    	
		end

		local btnStr = getlocal("activity_heartOfIron_goto")
	    if self.flagTb[idx+1]==1 then
	    	btnStr=getlocal("daily_scene_get")
    	elseif self.flagTb[idx+1]==2 then
    		btnStr=getlocal("activity_hadReward")
	    end

	    local btnItem
	    if self.flagTb[idx+1]==0 then
	    	btnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchBtnItem,nil,btnStr,25)
    	elseif self.flagTb[idx+1]==1 then
    		btnItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchBtnItem,nil,btnStr,25)
		elseif self.flagTb[idx+1]==2 then
			btnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchBtnItem,nil,btnStr,25)
	    end

	   btnItem:setAnchorPoint(ccp(0.5,0.5))
       local btnMenu=CCMenu:createWithItem(btnItem)
       btnMenu:setTouchPriority(-(self.layerNum-1)*20-2);
       btnMenu:setPosition(ccp(backSprie:getContentSize().width-btnItem:getContentSize().width/2-20,backSprie:getContentSize().height/2))
       backSprie:addChild(btnMenu)

		local alreadyLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		alreadyLb:setAnchorPoint(ccp(0.5,0.5))
		alreadyLb:setPosition(ccp(backSprie:getContentSize().width-btnItem:getContentSize().width/2-20,backSprie:getContentSize().height/2))
		backSprie:addChild(alreadyLb)
		alreadyLb:setColor(G_ColorGreen)
		alreadyLb:setVisible(false)

       if self.flagTb[idx+1]==2 then
       		btnItem:setEnabled(false)
       		btnItem:setVisible(false)
       		alreadyLb:setVisible(true)
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

function acTitaniumOfharvestTab2:goTankFactory()
	if buildingVoApi:getBuildiingVoByBId(11).status<1 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("tankFactory_not_build"),30)
	else
		activityAndNoteDialog:closeAllDialog()
		local bid=11;
		local tankSlot1=tankSlotVoApi:getSoltByBid(11)
		local tankSlot2=tankSlotVoApi:getSoltByBid(12)
		if SizeOfTable(tankSlot1)==0 and SizeOfTable(tankSlot2)==0 then
		bid=11;
		elseif SizeOfTable(tankSlot1)==0 and SizeOfTable(tankSlot2)>0 then
		bid=11;
		elseif SizeOfTable(tankSlot1)>0 and SizeOfTable(tankSlot2)==0 then
		bid=12;
		elseif SizeOfTable(tankSlot1)>0 and SizeOfTable(tankSlot2)>0 then
		bid=11;
		end

		local buildingVo=buildingVoApi:getBuildiingVoByBId(bid)
		if buildingVo.level==0 then
		bid=11;
		buildingVo=nil
		buildingVo=buildingVoApi:getBuildiingVoByBId(bid)
		end
        require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
		local td=tankFactoryDialog:new(bid,3)
		local bName=getlocal(buildingCfg[6].buildName)

		local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildingVo.level..")",true,3)
		td:tabClick(1)
		sceneGame:addChild(dialog,3)
	end
	
end

function acTitaniumOfharvestTab2:goWorld()
	if playerVoApi:getPlayerLevel()<3 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("worldMap_limit"),30)
	else
		activityAndNoteDialog:closeAllDialog()
		mainUI:changeToWorld()
	end
end

function acTitaniumOfharvestTab2:tick()

	if G_isToday(playerVoApi:getLogindate())~=acTitaniumOfharvestVoApi:getEnterGameFlag() then
		acTitaniumOfharvestVoApi:setEnterGameFlag(G_isToday(playerVoApi:getLogindate()))
		-- if acTitaniumOfharvestVo then
			acTitaniumOfharvestVo:updateMySpecialData()
		-- end
		acTitaniumOfharvestVoApi:clear()
		if self.tv then
			self.flagTb=acTitaniumOfharvestVoApi:getMissionFlag(true)
			self.tv:reloadData()
		end
	
	end

	local count = 0
	local flagTb=acTitaniumOfharvestVoApi:getMissionFlag()
	for k,v in pairs(flagTb) do
		if self.flagTb[k]==v then
			count=count+1
		end
	end
	if count~=SizeOfTable(flagTb) then
		self.flagTb=acTitaniumOfharvestVoApi:getMissionFlag()
		self.tv:reloadData()
	end

	
	self:updateAcTime()
end

function acTitaniumOfharvestTab2:updateAcTime()
  local acVo=acTitaniumOfharvestVoApi:getAcVo()
  if acVo and self.timeLb then
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acTitaniumOfharvestTab2:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.tv=nil
	self.timeLb=nil
end