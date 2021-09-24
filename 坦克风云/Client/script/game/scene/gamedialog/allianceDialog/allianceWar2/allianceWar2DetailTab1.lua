allianceWar2DetailTab1={}

function allianceWar2DetailTab1:new(id,cityData)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.isToday=nil
    self.height = 130
    self.id=cityData.id --  战场类型1和2
    self.cityData=cityData
    self.flag=false -- 是否是报名的城市，是的话取用户身上的数据，不是取0

	return nc
end

function allianceWar2DetailTab1:init(layerNum,addH)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
    -- print("++++++++++self.id",self.id)
    if self.id==nil then
        self.id=1
    end
	if addH then
		self.addH=addH
	else
		self.addH=0
	end

	self:initLayer()
    self:initTableView()
    

	return self.bgLayer
end

function allianceWar2DetailTab1:initLayer()
	local scale=1.15
	local startH=G_VisibleSizeHeight-210+self.addH
	local titleBg1=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg1:setPosition(ccp(G_VisibleSizeWidth/2,startH))
    titleBg1:setScale(scale)
    titleBg1:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(titleBg1,1)

    local fontSize=25
    local cityName=getlocal(allianceWar2Cfg.city[self.cityData.id].name)
    local titleLb1=GetTTFLabelWrap(getlocal("allianceWar2_reward1_title",{cityName}),fontSize,CCSizeMake(340,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb1:setAnchorPoint(ccp(0.5,0.5))
    titleLb1:setPosition(ccp(titleBg1:getContentSize().width/2,titleBg1:getContentSize().height/2+5))
    titleLb1:setScale(1/scale)
    titleBg1:addChild(titleLb1)

    local function helpInfo(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
            local tabStr={};
            local tabColor ={};
            local td=smallDialog:new()
            tabStr = {"\n",getlocal("allianceWar2_detail_tip3",{allianceWar2Cfg.winDonate,allianceWar2Cfg.failDonate,allianceWar2Cfg.mvpDonate,allianceWar2Cfg.maxTankDonate}),getlocal("allianceWar2_detail_tip2",{allianceWar2Cfg.winExp[self.cityData.id],allianceWar2Cfg.winExp[self.cityData.id]}),getlocal("allianceWar2_detail_tip1"),"\n"}
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,nil,nil,nil})
            sceneGame:addChild(dialog,self.layerNum+1)
        end
       
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",helpInfo,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-30,startH+6))
    self.bgLayer:addChild(menuDesc,2)

    local fadeH=160
    local fadeW=640
    local fadePosH=startH-titleBg1:getContentSize().height/2-fadeH/2
    local fadeBg=CCSprite:createWithSpriteFrameName("redFadeLine.png")
    fadeBg:setPosition(ccp(G_VisibleSizeWidth/2,fadePosH+20))
    fadeBg:setScaleY(fadeH/fadeBg:getContentSize().height)
    fadeBg:setScaleX(fadeW/fadeBg:getContentSize().width)
    fadeBg:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(fadeBg)

    local iconh=fadePosH+10
    local reward=allianceWar2Cfg["reward" .. self.id].reward
    local rewardItem=FormatItem(reward,nil,true)
    for k,v in pairs(rewardItem) do

    	local function touchPropInfo()
            local flag=false
            if v.num==0 then
                flag=true
            end
            propInfoDialog:create(sceneGame,v,self.layerNum+1,nil,nil,nil,nil,nil,nil,flag)
        end
    	local iconSp,scale=G_getItemIcon(v,100,nil,self.layerNum+1,touchPropInfo)
    	iconSp:setTouchPriority(-(self.layerNum-1)*20-3)
    	iconSp:setPosition(20+15+75+(k-1)*140,iconh)
    	self.bgLayer:addChild(iconSp)

        if v.num~=0 then
            local numLabel=GetTTFLabel("x"..v.num,22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(iconSp:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            iconSp:addChild(numLabel,1)
        end
    end

    
    local cityName=getlocal(allianceWar2Cfg.city[self.cityData.id].name)
    local titleLb2=GetTTFLabelWrap(getlocal("allianceWar2_reward2_title",{cityName}),fontSize,CCSizeMake(340,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)

    local lbSize=titleLb2:getContentSize().height+20
    local orangeH=fadePosH-fadeH/2-lbSize/2+20

    titleLb2:setAnchorPoint(ccp(0.5,0.5))
    titleLb2:setPosition(ccp(G_VisibleSizeWidth/2,orangeH))
    self.bgLayer:addChild(titleLb2,2)

    local orangeMask = CCSprite:createWithSpriteFrameName("orangeMask.png")
    orangeMask:setScaleY(lbSize/orangeMask:getContentSize().height)
    orangeMask:setPosition(G_VisibleSizeWidth/2,orangeH)
    self.bgLayer:addChild(orangeMask,1)

    self.tvBgh=orangeH-lbSize/2

    local function nilFunc()
	end
	local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
	descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvBgh-40))
	descBg:setAnchorPoint(ccp(0.5,0))
	descBg:setPosition(ccp(G_VisibleSizeWidth/2,35))
	self.bgLayer:addChild(descBg)

    local rewardDes=getlocal("allianceWar2_reward_notion",{getlocal("email_email")})
    if base.rewardcenter==1 then
        rewardDes=getlocal("allianceWar2_reward_notion",{getlocal("rewardCenterTitle")})
    end
    local rewardLb=GetTTFLabelWrap(rewardDes,25,CCSizeMake(descBg:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rewardLb:setAnchorPoint(ccp(0,0))
    rewardLb:setPosition(ccp(15,15))
    descBg:addChild(rewardLb)
    rewardLb:setColor(G_ColorRed)
    self.rewardLb=rewardLb

end

function allianceWar2DetailTab1:initTableView()
    local targetCity = allianceWar2VoApi:getTargetCity()
    if targetCity and targetCity==self.cityData.id then
        self.flag=true
        -- print("++++++4444++++++++")
    end

    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvBgh-50-self.rewardLb:getContentSize().height-25),nil)
    self.tv:setPosition(ccp(30,60+self.rewardLb:getContentSize().height))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

end


function allianceWar2DetailTab1:eventHandler(handler,fn,idx,cel)
  	if fn=="numberOfCellsInTableView" then
  		return SizeOfTable(allianceWar2Cfg.task)+1
  	elseif fn=="tableCellSizeForIndex" then
    	return  CCSizeMake(G_VisibleSizeWidth - 60,self.height)
  	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setAnchorPoint(ccp(0.5,0))
		lineSp:setPosition(ccp((G_VisibleSizeWidth - 60)/2,0))
		cell:addChild(lineSp)

        if idx==0 then
            local reward={p={{p974=1}}}
            local rewardItem=FormatItem(reward)

            local function touchPropInfo()
                propInfoDialog:create(sceneGame,rewardItem[1],self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
            end
            local iconSp,scale=G_getItemIcon(rewardItem[1],100,nil,self.layerNum+1,touchPropInfo,self.tv)
            iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
            iconSp:setAnchorPoint(ccp(0,0.5))
            iconSp:setPosition(20,self.height/2)
            cell:addChild(iconSp)

            local desLb=GetTTFLabelWrap(getlocal("allianceWar2_donate_des"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            desLb:setAnchorPoint(ccp(0,0.5))
            desLb:setPosition(ccp(140,self.height/2))
            cell:addChild(desLb)
            return cell
        end
		local tid="t" .. (idx)
		local reward=allianceWar2Cfg.taskreward[self.id][tid][1]
		local rewardItem=FormatItem(reward)

    	local iconSp,scale=G_getItemIcon(rewardItem[1],100,true,self.layerNum+1,nil,self.tv)
    	iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
    	iconSp:setAnchorPoint(ccp(0,0.5))
    	iconSp:setPosition(20,self.height/2)
    	cell:addChild(iconSp)

    	local numLabel=GetTTFLabel("x"..rewardItem[1].num,22)
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(iconSp:getContentSize().width-5, 5)
		numLabel:setScale(1/scale)
		iconSp:addChild(numLabel,1)


        
        local strSize2 = 450
        if G_getCurChoseLanguage() =="ar" then
            strSize2 =400
        end
		local desLb=""
		-- if idx==0 then
		-- 	desLb=getlocal("allianceWar2_" .. allianceWar2Cfg.task[tid][2])
		-- else
			desLb=getlocal("allianceWar2_" .. allianceWar2Cfg.task[tid][2],{allianceWar2Cfg.task[tid][1]})
		-- end
		-- print("++++++++allianceWar2Cfg.task[tid][1]",allianceWar2Cfg.task[tid][1])
		local desLb=GetTTFLabelWrap(desLb,25,CCSizeMake(strSize2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desLb:setAnchorPoint(ccp(0,0.5))
		desLb:setPosition(ccp(140,self.height/4*3))
		cell:addChild(desLb)

        local haveNum=0
        if self.flag then
            local haveTask=allianceWar2VoApi:getBattlefieldUser()["task"] or {}
            haveNum=haveTask[tid] or 0
        end
		
		local pressStr=""
		local color=G_ColorWhite
		if idx==0 then
			pressStr=getlocal("allianceWar2_haveGot",{haveNum})
		else
			local flag=false
            if haveNum>=allianceWar2Cfg.task[tid][1] then
                flag=true
            end
			if flag then
				pressStr=getlocal("activity_wanshengjiedazuozhan_complete")
				color=G_ColorGreen
			else
				pressStr=getlocal("allianceWar2_nowComplection",{haveNum})
			end
		end
		
		local progressLb=GetTTFLabelWrap(pressStr,25,CCSizeMake(strSize2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		progressLb:setAnchorPoint(ccp(0,0.5))
		progressLb:setPosition(ccp(140,self.height/4))
		progressLb:setColor(color)
		cell:addChild(progressLb)
		
		return cell
  	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
  	elseif fn=="ccTouchMoved" then
		self.isMoved=true
  	elseif fn=="ccTouchEnded"  then

  	end
end


function allianceWar2DetailTab1:refresh()
    if self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function allianceWar2DetailTab1:tick()
end

function allianceWar2DetailTab1:dispose()
end