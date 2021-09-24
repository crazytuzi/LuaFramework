alienMinesTargetSmallDialog=smallDialog:new()

--param type: 面板类型, 1是自己占领, 2是友军占领, 3是敌军占领,4是空地
--param data: 数据, 坐标 ID等
function alienMinesTargetSmallDialog:new(type,data,isScout,num,name)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=560
	self.dialogHeight=725

	if type==3 then
		self.isScout=isScout
		self.num=num
		self.name=name
	end
	
	self.type=type
	self.data=data
	return nc
end

function alienMinesTargetSmallDialog:setLayerSize()
	self.dialogWidth=560
	if self.type==1 then
		self.dialogHeight=725
	elseif self.type==2 then
		self.dialogHeight=520
	elseif self.type==3 then
		-- self.dialogHeight=520
		-- if self.isScout then
			self.dialogHeight=725
		-- end
	elseif self.type==4 then
		self.dialogHeight=440
	end

end

function alienMinesTargetSmallDialog:init(layerNum,spWorldPos)
	self.isTouch=nil
	self.layerNum=layerNum
	self.spWorldPos=spWorldPos

	-- 设置Layer大小
	self:setLayerSize()

	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleStr=getlocal("city_info_targetInfo")
	local titleLb=GetTTFLabel(titleStr,30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)
    
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	local posY=self.dialogHeight-110

	-- 矿名
	local nameStr=getlocal("alien_tech_res_name_"..(self.data.type))..getlocal("city_info_level",{self.data.level})
    local StrWidth=dialogBg:getContentSize().width-20
    local minesLb=GetTTFLabelWrap(nameStr,28,CCSizeMake(StrWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	minesLb:setAnchorPoint(ccp(0,0.5))
	minesLb:setPosition(ccp(20,posY))
	minesLb:setColor(G_ColorYellowPro)
	dialogBg:addChild(minesLb)

	posY=posY-minesLb:getContentSize().height+5
	-- 坐标和采集速度背景
	local function touchBS()
	end
	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchBS)
	backSprie:setContentSize(CCSizeMake(self.dialogWidth-30, 120))
	backSprie:ignoreAnchorPointForPosition(false);
	backSprie:setAnchorPoint(ccp(0.5,1));
	backSprie:setIsSallow(false)
	backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	backSprie:setPosition(self.dialogWidth/2, posY)
	dialogBg:addChild(backSprie,2)

	-- 光亮线
	local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp1:setAnchorPoint(ccp(0.5,0.5))
	lineSp1:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)
	lineSp1:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp1:getContentSize().width)
	backSprie:addChild(lineSp1)

	-- 坐标lb
	local coordinateStr = getlocal("city_info_coordinate") .. ":" .. self.data.x .. "," .. self.data.y
	local coordinateLb = GetTTFLabelWrap(coordinateStr,25,CCSizeMake(StrWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	coordinateLb:setAnchorPoint(ccp(0,0.5))
	coordinateLb:setPosition(ccp(10,backSprie:getContentSize().height/4*3))
	backSprie:addChild(coordinateLb)

	local speedTai=tonumber(math.ceil(tonumber(mapCfg[4][self.data.level].resource)))
	local speedAlien=math.floor(speedTai*alienMineCfg.collect[self.data.type].rate)

	-- 采集速度
	local collectionStr=getlocal("alienMines_collection_speed",{speedTai,speedAlien,getlocal("alien_tech_res_name_"..(self.data.type))})
	local desTv,desLabel = G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-20, backSprie:getContentSize().height/2-10),collectionStr,25,kCCTextAlignmentLeft)
 	backSprie:addChild(desTv)
    desTv:setPosition(ccp(10,0))
    desTv:setAnchorPoint(ccp(0.5,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)

    posY=posY-backSprie:getContentSize().height-10
    -- 驻守者
    local garrisonStr=getlocal("alienMines_garrison")
    local garrisonLb=GetTTFLabelWrap(garrisonStr,28,CCSizeMake(StrWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	garrisonLb:setAnchorPoint(ccp(0,1))
	garrisonLb:setPosition(ccp(20,posY))
	garrisonLb:setColor(G_ColorYellowPro)
	dialogBg:addChild(garrisonLb)

	posY=posY-35
	-- 驻守者背景
	local bsSizeY
	if self.type==4 then
		bsSizeY=120
	else
		bsSizeY=200
	end
	local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchBS)
	backSprie1:setContentSize(CCSizeMake(self.dialogWidth-30, bsSizeY))
	backSprie1:ignoreAnchorPointForPosition(false);
	backSprie1:setAnchorPoint(ccp(0.5,1));
	backSprie1:setIsSallow(false)
	backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
	backSprie1:setPosition(self.dialogWidth/2, posY)
	dialogBg:addChild(backSprie1,2)


	if self.type==4 then
		local desTb={
			{lbName=getlocal("alienMines_unkown"),pos=ccp(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height/4*3-10)},
			{lbName=getlocal("alienMines_after_scout"),pos=ccp(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height/4+10)},
			}

			for i=1,SizeOfTable(desTb) do
				local infoLb = GetTTFLabelWrap(desTb[i].lbName,25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				infoLb:setColor(G_ColorYellowPro)
				infoLb:setPosition(desTb[i].pos)
				backSprie1:addChild(infoLb)
			end
	else
		-- local personPhotoName="photo"..playerVoApi:getPic()..".png"
		local personPhotoName=playerVoApi:getPersonPhotoName(playerVoApi:getPic())

		if self.type==1 then
			-- personPhotoName="photo"..playerVoApi:getPic()..".png"
			personPhotoName=playerVoApi:getPersonPhotoName(playerVoApi:getPic())

		else
			local info = alienMinesEnemyInfoVoApi:getEnemyInfoVoByXYAndOid(self.data.x,self.data.y,self.data.oid)
			-- personPhotoName="photo".. info.pic ..".png"
			personPhotoName=playerVoApi:getPersonPhotoName(info.pic)

		end
		-- local photoSp = GetBgIcon(personPhotoName);
		local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName);
		
		photoSp:setScale(1.7)
		photoSp:setAnchorPoint(ccp(0,0.5))
		photoSp:setPosition(ccp(15,backSprie1:getContentSize().height/2))
		backSprie1:addChild(photoSp,2)

		local nameStr
		local levelStr
		local powerStr
		local allianceStr

		if self.type==1 then
			nameStr=getlocal("buffName",{playerVoApi:getPlayerName()})
			levelStr=getlocal("buffLv",{playerVoApi:getPlayerLevel()})
			powerStr=getlocal("alliance_info_power") .. FormatNumber(playerVoApi:getPlayerPower())
			local alliance =  allianceVoApi:getSelfAlliance()
			local allianceName=""
			if alliance and alliance.name then
				allianceName= alliance.name
			end
			allianceStr=getlocal("alliance_list_scene_name") .. ":" .. allianceName
		else
			local info = alienMinesEnemyInfoVoApi:getEnemyInfoVoByXYAndOid(self.data.x,self.data.y,self.data.oid)
			nameStr=getlocal("buffName",{self.data.name})
			levelStr=getlocal("buffLv",{info.level})
			powerStr=getlocal("alliance_info_power") .. FormatNumber(info.power)
			allianceStr=getlocal("alliance_list_scene_name") .. ":" .. (info.alienceName or "")
		-- else
		-- 	nameStr=getlocal("buffName",{self.data.name})
		-- 	levelStr=getlocal("buffLv",{self.data.level})
		-- 	powerStr=getlocal("alliance_info_power") .. FormatNumber(self.data.power)
		-- 	allianceStr=getlocal("alliance_list_scene_name") .. ":" .. self.data.allianceName
		end

		-- 名称  等级  战力 军团
		local garrisonTb={
		{lbStr=nameStr,pos=ccp(200,backSprie1:getContentSize().height/2+40)},
		{lbStr=levelStr,pos=ccp(200,backSprie1:getContentSize().height/2+5)},
		{lbStr=powerStr,pos=ccp(200,backSprie1:getContentSize().height/2-30)},
		{lbStr=allianceStr,pos=ccp(200,backSprie1:getContentSize().height/2-65)},
		}
		for i=1,SizeOfTable(garrisonTb) do
			local infoLb = GetTTFLabel(garrisonTb[i].lbStr,25)
			infoLb:setAnchorPoint(ccp(0,0))
			infoLb:setPosition(garrisonTb[i].pos)
			backSprie1:addChild(infoLb,2)
		end

		posY=posY-backSprie1:getContentSize().height-10
		-- 采集资源
		if self.type==1 or self.type == 3 then
			local acquisitionResourcesStr=getlocal("alienMines_acquisition_resources")
			if self.isScout==true then
				acquisitionResourcesStr=acquisitionResourcesStr .. "(" ..  getlocal("alienMines_latest_cout") .. ")"
			end
			
			local resLb = GetTTFLabelWrap(acquisitionResourcesStr,28,CCSizeMake(StrWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			resLb:setAnchorPoint(ccp(0,1))
			resLb:setPosition(ccp(20,posY))
			resLb:setColor(G_ColorYellowPro)
			dialogBg:addChild(resLb)

			posY=posY-38
			local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchBS)
			backSprie1:setContentSize(CCSizeMake(self.dialogWidth-30, 150))
			backSprie1:ignoreAnchorPointForPosition(false);
			backSprie1:setAnchorPoint(ccp(0.5,1));
			backSprie1:setIsSallow(false)
			backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
			backSprie1:setPosition(self.dialogWidth/2, posY)
			dialogBg:addChild(backSprie1,2)

			if self.isScout==true or self.type==1 then

				local resTaiSp = CCSprite:createWithSpriteFrameName("resourse_normal_uranium.png")
				resTaiSp:setAnchorPoint(ccp(0,0.5))
				resTaiSp:setPosition(10, backSprie1:getContentSize().height/2)
				backSprie1:addChild(resTaiSp)
				
				local pic="alien_mines" .. self.data.type .. ".png"
				local resAlienSp = CCSprite:createWithSpriteFrameName(pic)
				resAlienSp:setAnchorPoint(ccp(0,0.5))
				resAlienSp:setPosition(backSprie1:getContentSize().width/2-20, backSprie1:getContentSize().height/2)
				backSprie1:addChild(resAlienSp)

				local lbW=resTaiSp:getContentSize().width+resTaiSp:getPositionX()+20
				local lbH=backSprie1:getContentSize().height/2
				local lbW2=resAlienSp:getPositionX()+resAlienSp:getContentSize().width
				local changeH=15

				local lbName1
				local lbName2
				if self.type==1 then
					local slotId=attackTankSoltVoApi:getSlotIdBytargetid(self.data.x,self.data.y)
					local nowRes,maxRes,alienNowRes,alienMaxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(slotId)
					lbName1=FormatNumber(nowRes)
					lbName2=FormatNumber(alienNowRes)
				else
					lbName1=FormatNumber(self.num)
					lbName2=FormatNumber(self.num*alienMineCfg.collect[self.data.type].rate)
				end
				local resTb={
				{lbName=getlocal("uranium"),pos=ccp(lbW,lbH+changeH)},
				{lbName=lbName1,pos=ccp(lbW,lbH-25-changeH)},
				{lbName=getlocal("alien_tech_res_name_"..(self.data.type)),pos=ccp(lbW2,lbH+changeH)},
				{lbName=lbName2,pos=ccp(lbW2,lbH-25-changeH)},
				}

				for i=1,SizeOfTable(resTb) do
					local infoLb = GetTTFLabelWrap(resTb[i].lbName,25,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					infoLb:setAnchorPoint(ccp(0,0))
					infoLb:setPosition(resTb[i].pos)
					backSprie1:addChild(infoLb)
				end
			else
				local desTb={
					{lbName=getlocal("alienMines_unkown"),pos=ccp(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height/4*3-10)},
					{lbName=getlocal("alienMines_after_scout"),pos=ccp(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height/4+10)},
					}

				for i=1,SizeOfTable(desTb) do
					local infoLb = GetTTFLabelWrap(desTb[i].lbName,25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					infoLb:setColor(G_ColorYellowPro)
					infoLb:setPosition(desTb[i].pos)
					backSprie1:addChild(infoLb)
				end
			end

		end
	end

	

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end




