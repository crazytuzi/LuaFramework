allianceWar2DetailTab2={}

function allianceWar2DetailTab2:new(cityData,type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.isToday=nil
    self.height=80
    self.pageCellNum=10
    self.cityData=cityData
	self.type=type
	return nc
end

function allianceWar2DetailTab2:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer()
	self:initTableView()
	return self.bgLayer
end

function allianceWar2DetailTab2:initLayer()
	local fontSize=27
	local titleH=G_VisibleSizeHeight-200
	local titleTb={
			{str=getlocal("allianceWar2_detail_qualification"),posx=G_VisibleSizeWidth/2-200},
			{str=getlocal("allianceWar_pointRankTitle"),posx=G_VisibleSizeWidth/2},
			{str=getlocal("alliance_list_scene_alliance_name"),posx=G_VisibleSizeWidth/2+200}
		}
	local lbH=0
	for k,v in pairs(titleTb) do
		local titleLb=GetTTFLabelWrap(v.str,fontSize,CCSizeMake(170,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		titleLb:setAnchorPoint(ccp(0.5,0.5))
		titleLb:setPosition(ccp(v.posx,titleH))
		self.bgLayer:addChild(titleLb,1)
		if titleLb:getContentSize().height>lbH then
			lbH=titleLb:getContentSize().height
		end
	end

	local function nilFunc()
	end
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20,20,10,10),nilFunc)
    titleBg:setScaleX((G_VisibleSizeWidth-60)/titleBg:getContentSize().width)
    titleBg:setScaleY((lbH+30)/titleBg:getContentSize().height)
    titleBg:setAnchorPoint(ccp(0.5,0.5))
    titleBg:setPosition(ccp(G_VisibleSizeWidth/2,titleH))
    self.bgLayer:addChild(titleBg)

    self.tvH=G_VisibleSizeHeight-200-lbH/2-15
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
	descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvH-40))
	descBg:setAnchorPoint(ccp(0.5,0))
	descBg:setPosition(ccp(G_VisibleSizeWidth/2,35))
	self.bgLayer:addChild(descBg)

	
	local cityID=self.cityData.id
	local desStr=""
	-- print("allianceWar2VoApi:getStatus(cityID)",allianceWar2VoApi:getStatus(cityID))
	if allianceWar2VoApi:getStatus(cityID)<10 then
		desStr=getlocal("allianceWar2_noStart")
	elseif allianceWar2VoApi:getStatus(cityID)==12 and allianceWar2VoApi.targetCity and cityID==allianceWar2VoApi.targetCity then
        local cityCfg=allianceWar2VoApi:getCityCfgByID(cityID)
		if cityCfg and cityCfg.name then
			cityName=getlocal(cityCfg.name)
		end
		desStr=getlocal("allianceWar2_signup_end_wait",{cityName})
	elseif allianceWar2VoApi:getStatus(cityID)<20 then
		desStr=getlocal("allianceWar2_waitResult")
	else
		desStr=getlocal("allianceWar2_detail_noCorpSign")
	end

	local noCorpSignLb=GetTTFLabelWrap(desStr,30,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	noCorpSignLb:setAnchorPoint(ccp(0.5,0.5))
	noCorpSignLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.bgLayer:addChild(noCorpSignLb,1)
	noCorpSignLb:setColor(G_ColorRed)
	noCorpSignLb:setVisible(false)


	if allianceWar2VoApi:getStatus(cityID)<20 then
		noCorpSignLb:setVisible(true)
	end
	if SizeOfTable(self.cityData.bidList)==0 and allianceWar2VoApi:getStatus(cityID)>=20 then
		-- print("+++++++")
		noCorpSignLb:setVisible(true)
	end
	
end

function allianceWar2DetailTab2:initTableView()
    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvH-50),nil)
    self.tv:setPosition(ccp(30,40))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

end


function allianceWar2DetailTab2:eventHandler(handler,fn,idx,cel)
  	if fn=="numberOfCellsInTableView" then
  		local cityID=self.cityData.id
  		if allianceWar2VoApi:getStatus(cityID)<20 then
  			return 0
  		end
  		local num=(#self.cityData.bidList) or 0
        -- if(num > self.pageCellNum)then
        -- 	return self.pageCellNum
        -- else
    		return num
        -- end
  	elseif fn=="tableCellSizeForIndex" then
    	return  CCSizeMake(G_VisibleSizeWidth - 60,self.height)
  	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellData = self.cityData.bidList[idx+1]

		local midW=(G_VisibleSizeWidth - 60)/2
		local midH=self.height/2+5
		local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setAnchorPoint(ccp(0.5,0))
		lineSp:setPosition(ccp(midW,0))
		cell:addChild(lineSp)
		local desStr=""
		local color=G_ColorWhite
		if idx<2 then
			color=G_ColorYellowPro
			desStr=getlocal("allianceWar_enterBattle")
		else
			desStr=getlocal("serverWarLocal_exam")
		end
		local contentTb={
				{str=desStr,posx=midW-200},
				{str=cellData.point,posx=midW},
				{str=cellData.name,posx=midW+200}
			}
		for k,v in pairs(contentTb) do
			local titleLb=GetTTFLabelWrap(v.str,25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			titleLb:setAnchorPoint(ccp(0.5,0.5))
			titleLb:setPosition(ccp(v.posx,midH))
			cell:addChild(titleLb,1)
			titleLb:setColor(color)

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


function allianceWar2DetailTab2:refresh()
    if self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function allianceWar2DetailTab2:tick()
end

function allianceWar2DetailTab2:dispose()
end