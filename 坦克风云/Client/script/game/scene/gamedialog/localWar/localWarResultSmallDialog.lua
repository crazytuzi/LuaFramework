--区域战结算小面板
localWarResultSmallDialog=smallDialog:new()

--param allianceID: 获胜军团的ID
--param endTs: 战斗结束的时间
function localWarResultSmallDialog:new(allianceID,endTs)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.winnerID=allianceID
	nc.endTs=endTs
	nc.dialogWidth=600
	nc.dialogHeight=600
	return nc
end

function localWarResultSmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function localWarResultSmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)
end

function localWarResultSmallDialog:initContent()
	local headerSp
	if(self.winnerID==playerVoApi:getPlayerAid())then
		headerSp = CCSprite:createWithSpriteFrameName("SuccessHeader.png")
		headerSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight))
		self.bgLayer:addChild(headerSp,2)
	else
		headerSp = CCSprite:createWithSpriteFrameName("LoseHeader.png")
		headerSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight))
		self.bgLayer:addChild(headerSp,2)
	end
	local nameBg=CCSprite:createWithSpriteFrameName("TeamHeaderBg.png")
	nameBg:setScale(1.1)
	nameBg:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 115))
	self.bgLayer:addChild(nameBg)
	local winnerName
	if(localWarFightVoApi:getDefenderAlliance() and self.winnerID==localWarFightVoApi:getDefenderAlliance().id)then
		winnerName=localWarFightVoApi:getDefenderAlliance().name
	else
		for k,v in pairs(localWarFightVoApi:getAllianceList()) do
			if(v.id==self.winnerID)then
				winnerName=v.name
				break
			end
		end
	end
	local nameLb
	if(winnerName)then
		nameLb=GetTTFLabel(getlocal("local_war_winner",{"【"..winnerName.."】"}),25)
	else
		nameLb=GetTTFLabel(getlocal("alliance_info_content"),25)
	end
	nameLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 105))
	self.bgLayer:addChild(nameLb)
	local capitalCity=CCSprite:createWithSpriteFrameName("localWar_capital.png")
	capitalCity:setScale(180/capitalCity:getContentSize().width)
	capitalCity:setPosition(ccp(130,self.dialogHeight - 220))
	self.bgLayer:addChild(capitalCity)
	local occupyLb
	if(winnerName)then
		occupyLb=GetTTFLabel(getlocal("local_war_occupied_time")..": "..G_getDataTimeStr(self.endTs,true,true),25)
	else
		occupyLb=GetTTFLabel(getlocal("local_war_occupied_time")..": "..getlocal("alliance_info_content"),25)
	end
	occupyLb:setAnchorPoint(ccp(0,0.5))
	occupyLb:setPosition(ccp(220,self.dialogHeight - 200))
	self.bgLayer:addChild(occupyLb)
	local timeLb=GetTTFLabel(getlocal("local_war_costTime",{GetTimeStr(self.endTs - localWarFightVoApi.startTime)}),25)
	timeLb:setAnchorPoint(ccp(0,0.5))
	timeLb:setPosition(ccp(220,self.dialogHeight - 230))
	self.bgLayer:addChild(timeLb)
	local function nilFunc( ... )
	end
	local cityBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	cityBg:setContentSize(CCSizeMake(self.dialogWidth - 20,190))
	cityBg:setPosition(ccp(self.dialogWidth/2,210))
	self.bgLayer:addChild(cityBg)
	local baseIcon=CCSprite:createWithSpriteFrameName("localWar_baseUp.png")
	baseIcon:setScale(170/baseIcon:getContentSize().width)
	baseIcon:setPosition(ccp(130,230))
	self.bgLayer:addChild(baseIcon)
	local cityInIcon=CCSprite:createWithSpriteFrameName("localWar_cityIn.png")
	cityInIcon:setScale(130/cityInIcon:getContentSize().width)
	cityInIcon:setPosition(ccp(self.dialogWidth/2,230))
	self.bgLayer:addChild(cityInIcon)
	local cityOutIcon=CCSprite:createWithSpriteFrameName("localWar_cityOut.png")
	cityOutIcon:setScale(130/cityOutIcon:getContentSize().width)
	cityOutIcon:setPosition(ccp(self.dialogWidth - 130,230))
	self.bgLayer:addChild(cityOutIcon)
	local baseNum,cityInNum,cityOutNum=0,0,0
	if(winnerName)then
		for cityID,cityVo in pairs(localWarFightVoApi:getCityList()) do
			if(cityVo.allianceID==self.winnerID)then
				if(cityVo.cfg.type==1)then
					baseNum=baseNum + 1
				elseif(cityVo.cfg.icon=="localWar_cityIn.png")then
					cityInNum=cityInNum + 1
				elseif(cityVo.cfg.icon=="localWar_cityOut.png")then
					cityOutNum=cityOutNum + 1
				end
			end
		end
	end
	local baseLb=GetTTFLabel("x"..baseNum,25)
	baseLb:setPosition(ccp(130,135))
	self.bgLayer:addChild(baseLb)
	local cityInLb=GetTTFLabel("x"..cityInNum,25)
	cityInLb:setPosition(ccp(self.dialogWidth/2,135))
	self.bgLayer:addChild(cityInLb)
	local cityOutLb=GetTTFLabel("x"..cityOutNum,25)
	cityOutLb:setPosition(ccp(self.dialogWidth - 130,135))
	self.bgLayer:addChild(cityOutLb)
	local function onReport()
		localWarVoApi:showReportDialog(self.layerNum + 1)
		self:close()
	end
	local reportItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onReport,1,getlocal("serverwarteam_record"),25)
	local reportBtn=CCMenu:createWithItem(reportItem)
	reportBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	reportBtn:setPosition(ccp(150,60))
	self.bgLayer:addChild(reportBtn)
	local function onConfirm()
		self:close()
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,1,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	okBtn:setPosition(ccp(self.dialogWidth - 150,60))
	self.bgLayer:addChild(okBtn)
end

function localWarResultSmallDialog:dispose()
	if(localWarMapScene and localWarMapScene.isShow)then
		localWarMapScene:close()
	end
	localWarFightVoApi:clear()
end