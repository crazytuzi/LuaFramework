serverWarTeamFlowerDialog=smallDialog:new()

function serverWarTeamFlowerDialog:new(battleData)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=550
	self.dialogHeight=830

	self.battleData=battleData
	self.betData=serverWarTeamVoApi:getBetList()[self.battleData.roundID]
	if(self.betData)then
		if(self.betData.allianceID==self.battleData.id1)then
			self.betIndex=1
		elseif(self.betData.allianceID==self.battleData.id2)then
			self.betIndex=2
		else
			self.betIndex=nil
		end
	end
	local cfgIndex=serverWarTeamCfg.betStyle4Round[self.battleData.roundID]
	self.costCfg=serverWarTeamCfg["betGem_"..cfgIndex]
	self.flowerCfg=serverWarTeamCfg["winner_"..cfgIndex]
	return nc
end

function serverWarTeamFlowerDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self.dialogLayer=CCLayer:create()
	self:initContent()
	self:show()
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function serverWarTeamFlowerDialog:initContent()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
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
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleLb=GetTTFLabel(getlocal("serverwar_bet"),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	local posY=self.dialogHeight-85
	self.countDown=serverWarTeamVoApi:getOutBattleTime(self.battleData.roundID,self.battleData.battleID) - serverWarTeamCfg.setTroopsLimit - base.serverTime
	base:addNeedRefresh(self)

	local countDownDesc=GetTTFLabel(getlocal("serverwar_betLeftTime",{""}),25)
	countDownDesc:setColor(G_ColorGreen)
	countDownDesc:setAnchorPoint(ccp(0,0.5))
	countDownDesc:setPosition(ccp(20,posY - 30))
	self.bgLayer:addChild(countDownDesc)

	posY=posY-45
	self.countDownLb=GetTTFLabel(GetTimeStr(self.countDown),25)
	self.countDownLb:setColor(G_ColorGreen)
	self.countDownLb:setAnchorPoint(ccp(0,0.5))
	self.countDownLb:setPosition(ccp(20,posY-15))
	self.bgLayer:addChild(self.countDownLb)

	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local strTb={"\n",getlocal("serverwar_betInfo1"),"\n",getlocal("serverwar_betRewardTitle"),"\n"}
		local colorTb={G_ColorWhite,G_ColorWhite,G_ColorWhite,G_ColorGreen,G_ColorWhite}
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTb,25,colorTb)
		sceneGame:addChild(dialog,self.layerNum+1)
	end

	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setScale(0.9)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setAnchorPoint(ccp(1,1))
	infoBtn:setPosition(ccp(self.dialogWidth-35,self.dialogHeight-90))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(infoBtn)

	posY=posY-30
	local function onClickCheckBox(object,name,tag)
		if((self.betData and self.betData.allianceID) or self.countDown<=0)then
			do return end
		end
		local index=math.floor(tag/10)
		local posY=self.dialogHeight-85-45-30-200
		if(tag%2==1)then
			self.betIndex=index
			for i=1,2 do
				if(i==index)then
					self.checkBoxArr[i][1]:setPositionY(999333)
					self.checkBoxArr[i][2]:setPositionY(posY)
				else
					self.checkBoxArr[i][2]:setPositionY(999333)
					self.checkBoxArr[i][1]:setPositionY(posY)
				end
			end
		else
			self.betIndex=nil
			self.checkBoxArr[index][2]:setPositionY(999333)
			self.checkBoxArr[index][1]:setPositionY(posY)
		end
    end
    local vsPic1=CCSprite:createWithSpriteFrameName("v.png")
    vsPic1:setScale(0.7)
    vsPic1:setPosition(ccp(self.dialogWidth/2-30,posY-70))
    dialogBg:addChild(vsPic1)
    local vsPic2=CCSprite:createWithSpriteFrameName("s.png")
    vsPic2:setScale(0.7)
    vsPic2:setPosition(ccp(self.dialogWidth/2+30,posY-70))
    dialogBg:addChild(vsPic2)
    self.checkBoxArr={{},{}}
	-- local function onClickHead(object,fn,tag)
	-- 	if(tag and tag~=0)then
	-- 		local index=tag - 518
	-- 		serverWarTeamVoApi:showPlayerDetailDialog(self.battleData["alliance"..index],self.layerNum+1)
	-- 	end
	-- end
	for i=1,2 do
		-- local headBorder = CCSprite:createWithSpriteFrameName("headerBgSilver.png")
		local posX
		if(i==1)then
			posX=5+(self.dialogWidth-10)/4 - 10 - 20
		else
			posX=5+(self.dialogWidth-10)*3/4 + 10 + 20
		end
		-- headBorder:setPosition(ccp(posX,posY-70))
		-- dialogBg:addChild(headBorder)

		local allianceData=self.battleData["alliance"..i]
		-- local headPic="photo"..allianceData.pic..".png"
		-- local playerPic = LuaCCSprite:createWithSpriteFrameName(headPic,onClickHead)
		-- playerPic:setTag(518+i)
		-- playerPic:setTouchPriority(-(self.layerNum-1)*20-2)
		-- playerPic:setScale(100/playerPic:getContentSize().width)
		-- playerPic:setPosition(ccp(posX,posY-70))
		-- dialogBg:addChild(playerPic,1)

		-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		-- local serverLb=GetTTFLabel(allianceData.serverName,25)
		local serverLb=GetTTFLabelWrap(allianceData.serverName,25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		-- local serverLb=GetTTFLabelWrap(str,25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		serverLb:setColor(G_ColorYellowPro)
		serverLb:setPosition(ccp(posX,posY-145+90))
		dialogBg:addChild(serverLb)

		-- local nameLb=GetTTFLabel(allianceData.name,25)
		local nameLb=GetTTFLabelWrap(allianceData.name,25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		-- local nameLb=GetTTFLabelWrap(str,25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		nameLb:setColor(G_ColorYellowPro)
		nameLb:setPosition(ccp(posX,posY-175+60))
		dialogBg:addChild(nameLb)

		self.checkBoxArr[i][1]=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",onClickCheckBox)
		self.checkBoxArr[i][1]:setTouchPriority(-(self.layerNum-1)*20-2)
		self.checkBoxArr[i][1]:setPosition(ccp(posX-60,posY-200))
		self.checkBoxArr[i][1]:setTag(i*10+1)
		self.bgLayer:addChild(self.checkBoxArr[i][1])
		self.checkBoxArr[i][2]=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",onClickCheckBox)
		self.checkBoxArr[i][2]:setTouchPriority(-(self.layerNum-1)*20-2)
		self.checkBoxArr[i][2]:setPosition(ccp(posX-60,999333))
		self.checkBoxArr[i][2]:setTag(i*10+2)
		self.bgLayer:addChild(self.checkBoxArr[i][2])

		if(self.betData and self.betData.allianceID==allianceData.id)then
			self.checkBoxArr[i][2]:setPositionY(posY-200)
			self.checkBoxArr[i][1]:setPositionY(999333)
		end

		local betDescLb=GetTTFLabel(getlocal("serverwar_bet"),25)
		betDescLb:setAnchorPoint(ccp(0,0.5))
		betDescLb:setPosition(ccp(posX-30,posY-200))
		self.bgLayer:addChild(betDescLb)
	end

	posY=posY-235
	local alreadyBetFlower=0
	if(self.betData and self.betData.times>0)then
		alreadyBetFlower=self.flowerCfg[self.betData.times]
	end
	self.flowerNumLb=GetTTFLabel(getlocal("serverwar_alreadyBet",{alreadyBetFlower}),25)
	self.flowerNumLb:setPosition(ccp(self.dialogWidth/2,posY-20))
	self.bgLayer:addChild(self.flowerNumLb)

	posY=posY-35
	local function onBet()
		self:bet()
	end
	self.betItem=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",onBet)
	local betBtn=CCMenu:createWithItem(self.betItem)
	betBtn:setPosition(ccp(self.dialogWidth/2,posY-45))
	betBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(betBtn)

	local costStr
	--超时
	if(self.betData and self.betData.times>=#self.costCfg)then
		self.betItem:setEnabled(false)
		costStr=getlocal("backstage121")
	else
		costStr=getlocal("serverwar_betNum",{self:getNextFlowerCost()})
	end

	self.betFlowerNumLb=GetTTFLabel(costStr,25)
	self.betFlowerNumLb:setPosition(ccp(self.dialogWidth/2,posY-45))
	self.bgLayer:addChild(self.betFlowerNumLb)

	posY=posY-70
	local infoTitleLb=GetTTFLabel(getlocal("serverwar_betInfoTitle",{""}),25)
	infoTitleLb:setColor(G_ColorYellowPro)
	infoTitleLb:setAnchorPoint(ccp(0,0.5))
	infoTitleLb:setPosition(ccp(20,posY-30))
	self.bgLayer:addChild(infoTitleLb)

	local infoLb=G_LabelTableView(CCSize(self.dialogWidth-40,posY-40-20),getlocal("serverwarteam_betInfo2"),25,kCCTextAlignmentLeft)
	infoLb:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	infoLb:setPosition(ccp(20,15))
	infoLb:setMaxDisToBottomOrTop(50)
	self.bgLayer:addChild(infoLb)

	self.dialogLayer:addChild(self.bgLayer,1)
end

function serverWarTeamFlowerDialog:getNextFlowerCost()
	if(self.betData and self.betData.times>0)then
		return self.flowerCfg[self.betData.times+1]-self.flowerCfg[self.betData.times]
	else
		return self.flowerCfg[1]
	end
end

function serverWarTeamFlowerDialog:getNextCoinCost()
	if(self.betData)then
		return self.costCfg[self.betData.times+1]
	else
		return self.costCfg[1]
	end
end

function serverWarTeamFlowerDialog:bet()
	--已经投注而且投的不是这一场
	if(self.betData and (self.betData.battleID~=self.battleData.battleID or self.betData.roundID~=self.battleData.roundID))then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_errorAlreadyBet"),30)
		do return end
	end
	if(self.betIndex==nil)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_errorNoTarget"),30)
		do return end
	end
	local times
	if(self.betData)then
		times=self.betData.times
	else
		times=0
	end
	if(times<#self.costCfg)then
		local coinCost=self:getNextCoinCost()
		if(playerVoApi:getGems()<coinCost)then
			GemsNotEnoughDialog(nil,nil,coinCost-playerVoApi:getGems(),self.layerNum+1,coinCost)
			do return end
		end
		local function onConfirm()
			local function callback()
				self.betData=serverWarTeamVoApi:getBetList()[self.battleData.roundID]
				local cfgIndex=serverWarTeamCfg.betStyle4Round[self.battleData.roundID]
				self.costCfg=serverWarTeamCfg["betGem_"..cfgIndex]
				self.flowerCfg=serverWarTeamCfg["winner_"..cfgIndex]

				local alreadyBetFlower=self.flowerCfg[self.betData.times]
				self.flowerNumLb:setString(getlocal("serverwar_alreadyBet",{alreadyBetFlower}))

				local costStr
				if(self.betData.times>=#self.costCfg)then
					self.betItem:setEnabled(false)
					costStr=getlocal("backstage121")
				else
					costStr=getlocal("serverwar_betNum",{self:getNextFlowerCost()})
				end
				self.betFlowerNumLb:setString(costStr)
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_betSuccessTip"),30)
			end
			serverWarTeamVoApi:bet(2,self.battleData.roundID,self.battleData.battleID,self.battleData["id"..self.betIndex],callback)
		end
		local flowerCost=self:getNextFlowerCost()
		local serverName=self.battleData["alliance"..self.betIndex].serverName
		local allianceName=self.battleData["alliance"..self.betIndex].name
		local str=getlocal("serverwar_betToPlayerDesc",{coinCost,flowerCost,serverName,allianceName})
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),str,nil,self.layerNum+1)
	end
end

function serverWarTeamFlowerDialog:tick()
	if self.countDown then
		self.countDown=self.countDown-1
		self.countDownLb:setString(GetTimeStr(self.countDown))
		if(self.countDown<=0)then
			base:removeFromNeedRefresh(self)
			self.betItem:setEnabled(false)
		end
	end
end