--世界地图点击叛军弹出的叛军面板
worldRebelSmallDialog=smallDialog:new()

--param data: 数据vo,worldBaseVo
function worldRebelSmallDialog:new(data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.dialogWidth=550
	nc.dialogHeight=720
	nc.data=data
	return nc
end

function worldRebelSmallDialog:init(layerNum)
    local flag,goldMineLv=goldMineVoApi:isGoldMine(self.data.id)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("serverWar/serverWar2.plist")
	spriteController:addPlist("public/acChrisEveImage.plist")
	spriteController:addTexture("public/acChrisEveImage.png")
	spriteController:addPlist("public/boss_fuben_images.plist")
	spriteController:addTexture("public/boss_fuben_images.png")
	spriteController:addPlist("public/acAnniversary.plist")
	spriteController:addTexture("public/acAnniversary.png")
	self.isTouch=nil
	self.layerNum=layerNum
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self.bgLayer:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
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
	local closeBtnItem = GetButtonItem("newCloseBtn.png","newCloseBtn_Down.png","newCloseBtn.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn,9)

	self:initContent()

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	base:addNeedRefresh(self)
	return self.dialogLayer
end

function worldRebelSmallDialog:initContent()
	--左上角的icon
	local strSize2 = 21
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =24
    end
	local function onClickIcon()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:showIntro()
	end
	local tankBg=LuaCCSprite:createWithSpriteFrameName("alliance_boss_dissectionbg.png",onClickIcon)
	tankBg:setTouchPriority(-(self.layerNum-1)*20-2)
	tankBg:setAnchorPoint(ccp(0,1))
	tankBg:setScale(1.2)
	tankBg:setPosition(20,self.dialogHeight - 40)
	self.bgLayer:addChild(tankBg)
	local icon
	local addReward
	if self.data and self.data.pic and self.data.pic>=100 then
        local picName=rebelVoApi:getSpecialRebelPic(self.data.pic)
        if picName then
            icon=CCSprite:createWithSpriteFrameName(picName)
            --如果是中秋赏月活动的话，增加月兔叛军额外奖励
            if acMidAutumnVoApi and acMidAutumnVoApi:acIsStop()==false then
            	addReward=acMidAutumnVoApi:getRebelReward()
            end
        else
            local tankID=tonumber(RemoveFirstChar(rebelVoApi:getRebelIconTank(vv.level,vv.rebelIndex)))
            icon=G_getTankPic(tankID,nil,nil,nil,nil,false)
        end
    else
		local tankID=tonumber(RemoveFirstChar(rebelCfg.troops.tankIcon[self.data.lvIndex][self.data.rebelIndex]))
		icon=G_getTankPic(tankID,nil,nil,nil,nil,false)
	end
	if icon then
		icon:setScale(100/icon:getContentSize().height)
		icon:setPosition(getCenterPoint(tankBg))
		tankBg:addChild(icon)
	end
	local iconInfo=CCSprite:createWithSpriteFrameName("questionIcon.png")
	iconInfo:setPosition(tankBg:getContentSize().width - 25,20)
	tankBg:addChild(iconInfo)
	local iconClock=CCSprite:createWithSpriteFrameName("IconTime.png")
	iconClock:setPosition(50,self.dialogHeight - 40 - tankBg:getContentSize().height*1.2 - 10 - iconClock:getContentSize().height/2)
	self.bgLayer:addChild(iconClock)
	self.countdownLb=GetTTFLabel(GetTimeStr(self.data.ptEndTime - base.serverTime),22)
	self.countdownLb:setAnchorPoint(ccp(0,0.5))
	self.countdownLb:setPosition(50 + iconClock:getContentSize().width,iconClock:getPositionY())
	self.bgLayer:addChild(self.countdownLb)
	--名字
	local posY=self.dialogHeight - 38
	local nameLb=GetTTFLabelWrap(self.data.name,strSize2,CCSizeMake(self.dialogWidth - 320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop, "Helvetica-bold")
	nameLb:setColor(G_ColorYellowPro)
	nameLb:setAnchorPoint(ccp(0,1))
	nameLb:setPosition(240,posY)
	self.bgLayer:addChild(nameLb)
	posY=posY - 42
	local lvLb=GetTTFLabel(getlocal("world_war_level",{self.data.level}),20)
	lvLb:setAnchorPoint(ccp(0,1))
	lvLb:setPosition(240,posY)
	self.bgLayer:addChild(lvLb)
	posY=posY - 34
	local posLb=GetTTFLabel(getlocal("worldRebel_position",{getlocal("city_info_coordinate_style",{self.data.x,self.data.y})}),20)
	posLb:setAnchorPoint(ccp(0,1))
	posLb:setPosition(240,posY)
	self.bgLayer:addChild(posLb)
	posY=posY - 40
	local function onShare()
		if allianceVoApi:isHasAlliance()==true then
			--坐标发世界聊天
			local selfAlliance=allianceVoApi:getSelfAlliance()
			local channelType=selfAlliance.aid+1      
		    local sender=playerVoApi:getUid()
		    local senderName=playerVoApi:getPlayerName()
		    local level=playerVoApi:getPlayerLevel()
		    local rank=playerVoApi:getRank()
		    local allianceName
		    local allianceRole
		    if allianceVoApi:isHasAlliance() then
		        local allianceVo=allianceVoApi:getSelfAlliance()
		        allianceName=allianceVo.name
		        allianceRole=allianceVo.role
		    end
		    local message=getlocal("collect_border_name_loc",{self.data.name,self.data.x,self.data.y})
		    local params={subType=3,contentType=2,message=message,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle(),brType=13,rebelInfo={x=self.data.x,y=self.data.y}}
	        chatVoApi:sendChatMessage(channelType,sender,senderName,0,"",params)
	        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("send_rebel_info_sucess"),28)
	    else
	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("send_rebel_info_fail"),28)
	    end
	end
	local shareItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onShare)
	local shareBtn=CCMenu:createWithItem(shareItem)
	shareBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	shareBtn:setPosition(self.dialogWidth - shareItem:getContentSize().width/2 - 30,posY + shareItem:getContentSize().height/2 + 5)
	self.bgLayer:addChild(shareBtn)
	local progressBg=CCSprite:createWithSpriteFrameName("rebelProgressBg.png")
	progressBg:setAnchorPoint(ccp(0,1))
	progressBg:setPosition(240,posY)
	self.bgLayer:addChild(progressBg)
	local progress=CCSprite:createWithSpriteFrameName("rebelProgress.png")
	self.progress=CCProgressTimer:create(progress)
	self.progress:setType(kCCProgressTimerTypeBar)
	self.progress:setMidpoint(ccp(0,0))
	self.progress:setBarChangeRate(ccp(1,0))
	self.progress:setAnchorPoint(ccp(0,1))
	self.progress:setPosition(242,posY - 2)
	self.progress:setPercentage(self.data.hp/self.data.maxHp*100)
	self.bgLayer:addChild(self.progress)
	local lbHp=GetTTFLabel(G_keepNumber(self.data.hp/self.data.maxHp*100,2).."%",20)
	lbHp:setPosition(240 + progressBg:getContentSize().width/2,posY - progressBg:getContentSize().height/2)
	self.bgLayer:addChild(lbHp)

	local landType=worldBaseVoApi:getGroundType(self.data.x,self.data.y)
	local landTypeLb=GetTTFLabel(getlocal("BossBattle_ground")..": "..getlocal("world_ground_name_"..landType),20)
	landTypeLb:setAnchorPoint(ccp(1,0.5))
	landTypeLb:setPosition(nameLb:getPositionX() + progressBg:getContentSize().width - 50, self.countdownLb:getPositionY())
	self.bgLayer:addChild(landTypeLb)
	local function onShowLandType()
		self:showLandType()
	end
	local landTypeInfoItem=GetButtonItem("questionIcon.png","questionIcon.png","questionIcon.png",onShowLandType)
	landTypeInfoItem:setScale(1.2)
	local landTypeInfoBtn=CCMenu:createWithItem(landTypeInfoItem)
	local tempX = landTypeLb:getPositionX() + landTypeInfoItem:getContentSize().width/2*landTypeInfoItem:getScale() + 5
	landTypeInfoBtn:setPosition(ccp(tempX, self.countdownLb:getPositionY()))
	landTypeInfoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(landTypeInfoBtn)

	posY=landTypeLb:getPositionY() - landTypeLb:getContentSize().height/2 - 10
	if(posY>self.countdownLb:getPositionY() - self.countdownLb:getContentSize().height/2 - 5)then
		posY=self.countdownLb:getPositionY() - self.countdownLb:getContentSize().height/2 - 5
	end
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setScaleY(1.2)
	lineSp:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(lineSp)

	posY=posY - 30
	if(allianceVoApi:isHasAlliance())then
		local combo=rebelVoApi:getAttackCombo(self.data.x,self.data.y)
		if(combo>0)then
			local comboLb=GetTTFLabel(getlocal("worldRebel_attackCombo",{combo}),22)
			comboLb:setTag(101)
			comboLb:setColor(G_ColorYellowPro)
			comboLb:setPosition(self.dialogWidth/2,posY)
			self.bgLayer:addChild(comboLb)
			posY=posY - 30
			local buffLb1=GetTTFLabel(getlocal("worldRebel_comboBuff",{""}),22)
			buffLb1:setTag(102)
			buffLb1:setAnchorPoint(ccp(0,0.5))
			buffLb1:setPosition(30,posY)
			self.bgLayer:addChild(buffLb1)
			local buffLb2=GetTTFLabel((rebelCfg.attackBuff*100*combo).."%",22)
			buffLb2:setTag(103)
			buffLb2:setColor(G_ColorGreen)
			buffLb2:setAnchorPoint(ccp(1,0.5))
			buffLb2:setPosition(self.dialogWidth - 30,posY)
			self.bgLayer:addChild(buffLb2)
			posY=posY - 30
			local buffTimeLb=GetTTFLabel(getlocal("costTime1",{""}),22)
			buffTimeLb:setTag(104)
			buffTimeLb:setAnchorPoint(ccp(0,0.5))
			buffTimeLb:setPosition(30,posY)
			self.bgLayer:addChild(buffTimeLb)
			if(base.serverTime<rebelVoApi:getComboLeftTime())then
				self.buffLeftLb=GetTTFLabel(GetTimeStr(rebelVoApi:getComboLeftTime() - base.serverTime),22)
				self.buffLeftLb:setColor(G_ColorGreen)
			else
				self.buffLeftLb=GetTTFLabel("0",22)
			end
			self.buffLeftLb:setAnchorPoint(ccp(1,0.5))
			self.buffLeftLb:setPosition(self.dialogWidth - 30,posY)
			self.bgLayer:addChild(self.buffLeftLb)
		else
			posY=posY - 60
		end
		local noComboLb=GetTTFLabelWrap(getlocal("worldRebel_comboTitle"),20,CCSizeMake(self.dialogWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		noComboLb:setTag(105)
		noComboLb:setPosition(self.dialogWidth/2,posY + 30)
		self.bgLayer:addChild(noComboLb)
		if(combo>0)then
			noComboLb:setVisible(false)
		end
	else
		local allianceLb=GetTTFLabelWrap(getlocal("worldRebel_needAlliance"),20,CCSizeMake(self.dialogWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		allianceLb:setPosition(self.dialogWidth/2,posY - 30)
		self.bgLayer:addChild(allianceLb)
		posY=posY - 60
	end

	posY=posY - 30
	local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15, 15, 2, 2),onShowLandType)
	rewardBg:setContentSize(CCSizeMake(self.dialogWidth - 30,150))
	rewardBg:setAnchorPoint(ccp(0.5,1))
	rewardBg:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(rewardBg)
	local leftSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
	leftSp:setAnchorPoint(ccp(0,0.5))
	leftSp:setPosition(0,posY - 75)
	self.bgLayer:addChild(leftSp,1)
	local rightSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
	rightSp:setFlipX(true)
	rightSp:setAnchorPoint(ccp(1,0.5))
	rightSp:setPosition(self.dialogWidth,posY - 75)
	self.bgLayer:addChild(rightSp,1)
	local rewardTitle=GetTTFLabel(getlocal("award"),24,true)
	rewardTitle:setColor(G_ColorYellowPro)
	rewardTitle:setPosition(self.dialogWidth/2,posY - 25)
	self.bgLayer:addChild(rewardTitle)
	posY=posY - 45
	self.rewardTb=rebelVoApi:getRebelReward(self.data)
	if addReward then
		--添加额外奖励
		for k,v in pairs(addReward) do
			table.insert(self.rewardTb,1,v)
		end
	end
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.rewardTv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(self.dialogWidth - 60,110),nil)
	self.rewardTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.rewardTv:setPosition(ccp(30,posY - 110))
	self.rewardTv:setMaxDisToBottomOrTop(80)
	self.bgLayer:addChild(self.rewardTv)

	posY=posY - 150
	self.energyIconList={}
	self.curEnergy=rebelVoApi:getRebelEnergy()
	local maxEnergy=rebelCfg.energyMax
	local totalWidth=48*maxEnergy + 20*(maxEnergy - 1)
	local startX=(self.dialogWidth - totalWidth)/2 - 40
	local posX=startX
	for i=1,maxEnergy do
		local icon1=CCSprite:createWithSpriteFrameName("serverWarTIcon1.png")
		icon1:setAnchorPoint(ccp(0,0.5))
		icon1:setPosition(posX,posY)
		self.bgLayer:addChild(icon1,1)
		local icon2=CCSprite:createWithSpriteFrameName("serverWarTIcon2.png")
		icon2:setAnchorPoint(ccp(0,0.5))
		icon2:setPosition(posX,posY)
		self.bgLayer:addChild(icon2,1)
		if(i>self.curEnergy)then
			icon2:setVisible(false)
		end
		if(i~=maxEnergy)then
			local line1=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarProgressBg3.png",CCRect(0,2,8,4),function ( ... )end)
			line1:setContentSize(CCSizeMake(24,8))
			line1:setAnchorPoint(ccp(0,0.5))
			line1:setPosition(posX + icon1:getContentSize().width - 2,posY)
			self.bgLayer:addChild(line1)
			local line2=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarProgressBg2.png",CCRect(0,0,4,4),function ( ... )end)
			line2:setContentSize(CCSizeMake(24,6))
			line2:setAnchorPoint(ccp(0,0.5))
			line2:setPosition(posX + icon2:getContentSize().width - 2,posY)
			self.bgLayer:addChild(line2)
			if(i>=rebelVoApi:getRebelEnergy())then
				line2:setVisible(false)
			end
			self.energyIconList[i]={icon2,line2}
		else
			self.energyIconList[i]={icon2}
		end
		posX=posX + icon2:getContentSize().width + 20
	end
	posX=posX + 30
	local buyEnergyBg=CCSprite:createWithSpriteFrameName("rebelEnergyBtnBg.png")
	buyEnergyBg:setPosition(posX,posY)
	self.bgLayer:addChild(buyEnergyBg)
	local function onBuyEnergy()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(rebelVoApi:getRebelEnergy()>=rebelCfg.energyMax)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("worldRebel_energyFull"),30)
			do return end
		end
		if(allianceVoApi:isHasAlliance()==false)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("worldRebel_needAlliance"),30)
			do return end
		end
		if(rebelVoApi:checkCanBuyRebelEnergy())then
			self:showBuyEnergyDialog()
		else
			if(playerVoApi:getVipLevel()>=tonumber(playerVoApi:getMaxLvByKey("maxVip")))then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage24001"),30)
			else
				local function onConfirm()
					self:close()
					vipVoApi:showRechargeDialog(3)
				end
				smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("worldRebel_energyBuyMax"),nil,4)
			end
		end
	end
	local buyEnergyItem=GetButtonItem("rebelEnergyBtn.png","rebelEnergyBtn_down.png","rebelEnergyBtn_down.png",onBuyEnergy,2)
	local buyEnergyBtn=CCMenu:createWithItem(buyEnergyItem)
	buyEnergyBtn:setPosition(posX,posY)
	buyEnergyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(buyEnergyBtn)

	local icon=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
	icon:setPosition(60,120)
	self.bgLayer:addChild(icon)
	local scoutRes=rebelCfg.troops.scoutConsume[self.data.level] or rebelCfg.troops.scoutConsume[#rebelCfg.troops.scoutConsume]
	local lbCost1=GetTTFLabel("-"..FormatNumber(scoutRes),25)
	lbCost1:setTag(201)
	if(playerVoApi:getGold()<scoutRes)then
		lbCost1:setColor(G_ColorRed)
	end
	lbCost1:setPosition(120,120)
	self.bgLayer:addChild(lbCost1)
	local function onScout()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:scout()
	end
	local tmpBtnSize = 24
	local tmpBtnScale = 0.7
	local scoutItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onScout,2,getlocal("city_info_scout"),tmpBtnSize/tmpBtnScale)
	scoutItem:setScale(tmpBtnScale)
	local scoutBtn=CCMenu:createWithItem(scoutItem)
	scoutBtn:setPosition(100,60)
	scoutBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(scoutBtn)
	local icon=CCSprite:createWithSpriteFrameName("serverWarTIcon2.png")
	icon:setScale(40/icon:getContentSize().width)
	icon:setPosition(self.dialogWidth/2 - 25,120)
	self.bgLayer:addChild(icon)
	local costEnergy=rebelCfg.attackConsume1
	local lbCost2=GetTTFLabel("-"..costEnergy,25)
	lbCost2:setTag(202)
	if(rebelVoApi:getRebelEnergy()<costEnergy)then
		lbCost2:setColor(G_ColorRed)
	end
	lbCost2:setPosition(self.dialogWidth/2 + 15,120)
	self.bgLayer:addChild(lbCost2)
	local function onAttack()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:attack()
	end
	local attackItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onAttack,2,getlocal("worldRebel_attack"),tmpBtnSize/tmpBtnScale)
	attackItem:setScale(tmpBtnScale)
	local attackBtn=CCMenu:createWithItem(attackItem)
	attackBtn:setPosition(self.dialogWidth/2,60)
	attackBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(attackBtn)
	local icon=CCSprite:createWithSpriteFrameName("serverWarTIcon2.png")
	icon:setScale(40/icon:getContentSize().width)
	icon:setPosition(self.dialogWidth - 125,120)
	self.bgLayer:addChild(icon)
	local costEnergy=rebelCfg.attackConsume2
	local lbCost3=GetTTFLabel("-"..costEnergy,25)
	lbCost3:setTag(203)
	if(rebelVoApi:getRebelEnergy()<costEnergy)then
		lbCost3:setColor(G_ColorRed)
	end
	lbCost3:setPosition(self.dialogWidth - 85,120)
	self.bgLayer:addChild(lbCost3)
	local function onMultiAttack()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:multiAttack()
	end
	local multiItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onMultiAttack,2,getlocal("BossBattle_damagePoint").."×"..rebelCfg.highAttack,tmpBtnSize/tmpBtnScale)
	multiItem:setScale(tmpBtnScale)
	local multiBtn=CCMenu:createWithItem(multiItem)
	multiBtn:setPosition(self.dialogWidth - 100,60)
	multiBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(multiBtn)
	if(allianceVoApi:isHasAlliance()==false)then
		scoutItem:setEnabled(false)
		attackItem:setEnabled(false)
		multiItem:setEnabled(false)
	end
end

function worldRebelSmallDialog:showIntro()
	if(self.infoLayer)then
		do return end
	end
	local layerNum=self.layerNum + 1
	local tv
	local function onClose()
		if(tv and tv:getIsScrolled())then
			do return end
		end
		if(self.infoLayer)then
			self.infoLayer:removeFromParentAndCleanup(true)
			self.infoLayer=nil
		end
	end
	self.infoLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onClose)
	self.infoLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.infoLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.infoLayer:setOpacity(120)
	self.infoLayer:setAnchorPoint(ccp(0,0))
	self.infoLayer:setPosition(ccp(0,0))
	self.dialogLayer:addChild(self.infoLayer,5)
	local height=500
	local strSize2 = 25
	if G_getCurChoseLanguage() ~="cn" then
		height =600
		strSize2 = 23
	end
	local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),onClose)
	dialogBg:setContentSize(CCSizeMake(530,height))
	dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.infoLayer:addChild(dialogBg)
	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return 1
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(470,height + 50)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local posX,posY=0,height +35
			local lb=GetTTFLabel(getlocal("shuoming"),28)
			lb:setColor(G_ColorYellowPro)
			lb:setAnchorPoint(ccp(0.5,1))
			lb:setPosition(470/2,posY)
			cell:addChild(lb)
			posY=posY - lb:getContentSize().height - 10
			local lb=GetTTFLabelWrap(getlocal("worldRebel_info1"),strSize2,CCSizeMake(470,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lb:setAnchorPoint(ccp(0,1))
			lb:setPosition(0,posY)
			cell:addChild(lb)
			posY=posY - lb:getContentSize().height - 10
			local lb=GetTTFLabelWrap(getlocal("worldRebel_info2"),strSize2,CCSizeMake(470,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lb:setAnchorPoint(ccp(0,1))
			lb:setPosition(0,posY)
			cell:addChild(lb)
			posY=posY - lb:getContentSize().height - 10
			local lb=GetTTFLabelWrap(getlocal("worldRebel_info3"),strSize2,CCSizeMake(470,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lb:setAnchorPoint(ccp(0,1))
			lb:setPosition(0,posY)
			cell:addChild(lb)
			posY=posY - lb:getContentSize().height - 10
			local lb=GetTTFLabelWrap(getlocal("worldRebel_info4"),strSize2,CCSizeMake(470,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lb:setAnchorPoint(ccp(0,1))
			lb:setPosition(0,posY)
			cell:addChild(lb)
			posY=posY - lb:getContentSize().height - 10
			local lb,height=G_getRichTextLabel(getlocal("worldRebel_info5",{(rebelCfg.startDamage*100).."%%"}),{G_ColorWhite,G_ColorGreen,G_ColorWhite},strSize2,470,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lb:setAnchorPoint(ccp(0,1))
			lb:setPosition(0,posY)
			cell:addChild(lb)
			posY=posY - height - 10
			local lb,height=G_getRichTextLabel(getlocal("worldRebel_info6",{(rebelCfg.damageRatio*100).."%%"}),{G_ColorWhite,G_ColorRed,G_ColorWhite},strSize2,470,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lb:setAnchorPoint(ccp(0,1))
			lb:setPosition(0,posY)
			cell:addChild(lb)
			posY=posY - height - 10
			local lb,height=G_getRichTextLabel(getlocal("worldRebel_info7"),{G_ColorWhite,G_ColorRed,G_ColorWhite},strSize2,470,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lb:setAnchorPoint(ccp(0,1))
			lb:setPosition(0,posY)
			cell:addChild(lb)
			posY=posY - height - 10
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(470,height - 30),nil)
	tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
	tv:setPosition(ccp(30,15))
	tv:setMaxDisToBottomOrTop(180)
	dialogBg:addChild(tv)
end

function worldRebelSmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.rewardTb
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(90,90)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local rewardIcon=G_getItemIcon(self.rewardTb[idx + 1],80,true,self.layerNum + 1,nil,self.rewardTv)
		rewardIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		rewardIcon:setPosition(45,45)
		cell:addChild(rewardIcon)
		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded"  then
	end
end

function worldRebelSmallDialog:showBuyEnergyDialog()
	if(self.energyLayer)then
		do return end
	end
	local layerNum=self.layerNum + 1
	local function onClose()
		if(self.energyLayer)then
			self.energyLayer:removeFromParentAndCleanup(true)
			self.energyLayer=nil
			self.energyCountDown=nil
		end
	end
	self.energyLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ( ... )end)
	self.energyLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.energyLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.energyLayer:setOpacity(120)
	self.energyLayer:setAnchorPoint(ccp(0,0))
	self.energyLayer:setPosition(ccp(0,0))
	self.dialogLayer:addChild(self.energyLayer,5)
	local recoverLeft=rebelVoApi:getEnergyRecoverTs() - base.serverTime
	local recoverEnergy=rebelVoApi:getEnergyBuyMax()
	local recoverCost1=rebelVoApi:getBuyRebelEneryCost(1)
	local recoverCost2=rebelVoApi:getBuyRebelEneryCost(2)
	self.energyCountDown=GetTTFLabel(getlocal("worldRebel_buyEnergyConfirm1",{GetTimeStr(recoverLeft)}),25)
	local height=self.energyCountDown:getContentSize().height
	local buyLimitLb,descLb1,descLb2,height1,height2
	local buyLimitLb=GetTTFLabelWrap(getlocal("worldRebel_buyEnergyNum",{rebelVoApi:getBuyEnergy(),rebelCfg.vipBuyLimit[playerVoApi:getVipLevel() + 1]}),25,CCSizeMake(470,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	height=height + buyLimitLb:getContentSize().height
	descLb1,height1=G_getRichTextLabel(getlocal("worldRebel_buyEnergyConfirm2"),{G_ColorWhite},25,470,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	height=height + height1
	descLb2,height2=G_getRichTextLabel(getlocal("worldRebel_buyEnergyConfirm3"),{G_ColorWhite,G_ColorYellowPro,G_ColorWhite},25,470,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	height=height + height2 + 230
	local dialogBg=G_getNewDialogBg(CCSizeMake(530,height),getlocal("dialog_title_prompt"),28,nil,layerNum,true,onClose)
	dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.energyLayer:addChild(dialogBg)
	self.energyCountDown:setAnchorPoint(ccp(0,1))
	self.energyCountDown:setPosition(30,height - 90)
	dialogBg:addChild(self.energyCountDown)
	buyLimitLb:setAnchorPoint(ccp(0,1))
	buyLimitLb:setPosition(30,height - 90 - self.energyCountDown:getContentSize().height)
	dialogBg:addChild(buyLimitLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
    lineSp:setContentSize(CCSizeMake(dialogBg:getContentSize().width-60,2))
	lineSp:setPosition(265,height - 95 - self.energyCountDown:getContentSize().height - buyLimitLb:getContentSize().height)
	dialogBg:addChild(lineSp)
	descLb1:setAnchorPoint(ccp(0,1))
	descLb1:setPosition(30,height - 100 - self.energyCountDown:getContentSize().height - buyLimitLb:getContentSize().height)
	dialogBg:addChild(descLb1)
	descLb2:setAnchorPoint(ccp(0,1))
	descLb2:setPosition(30,height - 100 - self.energyCountDown:getContentSize().height - buyLimitLb:getContentSize().height - height1)
	dialogBg:addChild(descLb2)
	local costIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	costIcon:setPosition(ccp(80,110))
	dialogBg:addChild(costIcon)
	local costLb=GetTTFLabel("-"..recoverCost1,23)
	if(recoverCost1>playerVoApi:getGems())then
		costLb:setColor(G_ColorRed)
	end
	costLb:setPosition(ccp(120,110))
	dialogBg:addChild(costLb)
	local function onBuy1()
		if recoverCost1>playerVoApi:getGems() then
			GemsNotEnoughDialog(nil,nil,recoverCost1 - playerVoApi:getGems(),layerNum+1,recoverCost1)
			do return end
		else
			local function callback()
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
				onClose()
				self:tick()
			end
			rebelVoApi:buyRebelEnergy(1,callback)
		end
	end
	local buyItem1=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onBuy1,2,getlocal("worldRebel_buyEnergyBtn",{1}),24/0.8)
	buyItem1:setScale(0.8)
	local buyBtn=CCMenu:createWithItem(buyItem1)
	buyBtn:setTouchPriority(-(layerNum-1)*20-3)
	buyBtn:setPosition(ccp(120,50))
	dialogBg:addChild(buyBtn)
	local costIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	costIcon:setPosition(ccp(530 - 120 - 40,110))
	dialogBg:addChild(costIcon)
	local costLb=GetTTFLabel("-"..recoverCost2,23)
	if(recoverCost2>playerVoApi:getGems())then
		costLb:setColor(G_ColorRed)
	end
	costLb:setPosition(ccp(530 - 120,110))
	dialogBg:addChild(costLb)
	local function onBuy2()
		if recoverCost2>playerVoApi:getGems() then
			GemsNotEnoughDialog(nil,nil,recoverCost2 - playerVoApi:getGems(),layerNum+1,recoverCost2)
			do return end
		else
			local function callback()
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
				onClose()
				self:tick()
			end
			rebelVoApi:buyRebelEnergy(recoverEnergy,callback)
		end
	end
	local buyItem2=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onBuy2,2,getlocal("worldRebel_buyEnergyBtn",{recoverEnergy}),24/0.8)
	buyItem2:setScale(0.8)
	local buyBtn2=CCMenu:createWithItem(buyItem2)
	buyBtn2:setTouchPriority(-(layerNum-1)*20-3)
	buyBtn2:setPosition(ccp(530 - 120,50))
	dialogBg:addChild(buyBtn2)
end

function worldRebelSmallDialog:scout()
	if self.data.ptEndTime<=base.serverTime then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("worldRebel_expire"),true,self.layerNum)
		self:close()
		do return end
	end
	local scoutRes=rebelCfg.troops.scoutConsume[self.data.level] or rebelCfg.troops.scoutConsume[#rebelCfg.troops.scoutConsume]
	local function callBack()
		if playerVoApi:getGold()>=scoutRes then
			-- 验证码
			local function realMapScout()
				local function callback(eid)
					self:realClose()
					if eid then
                        require "luascript/script/game/scene/gamedialog/emailDetailDialog"
						local layerNum=self.layerNum + 1
						local td=emailDetailDialog:new(layerNum,2,eid)
						local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("scout_content_scout_title"),false,layerNum)
						sceneGame:addChild(dialog,layerNum)
					end
				end
				rebelVoApi:rebelScout(self.data.x,self.data.y,callback)
			end
			local function checkcodeHandler()
				if base.isCheckCode==1 then
					local function checkcodeSuccess(fn,data)
			        	local ret,sData = base:checkServerData(data)
						if ret==true then
							-- print("++++++++领取奖励成功++++++++")
                            --领取验证码奖励成功后再更新lastCheckcodeNum			
			                local checkcodeNum=CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
                            CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(),checkcodeNum)
                    		CCUserDefault:sharedUserDefault():flush()
							if sData and sData.data and sData.data.reward then
								local reward = FormatItem(sData.data.reward)
								local rewardStr=getlocal("daily_lotto_tip_10")
								if reward then
									for k,v in pairs(reward) do
										if k==SizeOfTable(reward) then
									        rewardStr = rewardStr .. v.name .. " x" .. v.num
									    else
									        rewardStr = rewardStr .. v.name .. " x" .. v.num .. ","
									    end
									end
									smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr ,30)
								end
							end
						elseif sData.ret==-6010 then
							-- print("++++++++领取奖励失败++++++++")
                            CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(),G_maxCheckCount)
                            CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(),G_maxCheckCount)
                    		CCUserDefault:sharedUserDefault():flush()
						end
			        	realMapScout()
			        end
			        socketHelper:checkcodereward(checkcodeSuccess)
			    end
			end
			
			if G_isCheckCode()==true then
				self:realClose()
				smallDialog:initCheckCodeDialog(self.layerNum+1,checkcodeHandler)
			else
				realMapScout()
			end
		else
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("reputation_scene_money_require"),true,4)
		end
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("rebel_info_scout_tip",{scoutRes}),nil,4)
end

--进攻
function worldRebelSmallDialog:attack()
	if self.data.ptEndTime<=base.serverTime then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("worldRebel_expire"),true,self.layerNum)
		self:close()
		do return end
	end
	--判断是否有能量
	if rebelVoApi:getRebelEnergy()<rebelCfg.attackConsume1 then
		if(rebelVoApi:checkCanBuyRebelEnergy())then
			self:showBuyEnergyDialog()
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_event_title7"),30)
		end
		do return end
	end
	self:realClose()
    require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
	local td=tankAttackDialog:new(self.data.type,self.data,4,1)
	local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
	sceneGame:addChild(dialog,4)
end

--高级进攻
function worldRebelSmallDialog:multiAttack()
	if self.data.ptEndTime<=base.serverTime then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("worldRebel_expire"),true,self.layerNum)
		self:close()
		do return end
	end
	--判断是否有能量
	if rebelVoApi:getRebelEnergy()<rebelCfg.attackConsume2 then
		if(rebelVoApi:checkCanBuyRebelEnergy())then
			self:showBuyEnergyDialog()
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_event_title7"),30)
		end
		do return end
	end
	self:realClose()
    require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
	local td=tankAttackDialog:new(self.data.type,self.data,4,2)
	local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
	sceneGame:addChild(dialog,4)
end

function worldRebelSmallDialog:showLandType()
	if(self.landTypeLayer)then
		do return end
	end
	local layerNum=self.layerNum + 1
	local function onClose()
		if(self.landTypeLayer)then
			self.landTypeLayer:removeFromParentAndCleanup(true)
			self.landTypeLayer=nil
		end
	end
	self.landTypeLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onClose)
	self.landTypeLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.landTypeLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.landTypeLayer:setOpacity(120)
	self.landTypeLayer:setAnchorPoint(ccp(0,0))
	self.landTypeLayer:setPosition(ccp(0,0))
	self.dialogLayer:addChild(self.landTypeLayer,5)
	local bgHeight,tmpLb
	tmpLb=GetTTFLabelWrap(getlocal("world_ground_buff_title"),25,CCSizeMake(410,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	if(tmpLb:getContentSize().height>40)then
		bgHeight=400
	else
		bgHeight=375
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),onClose)
	dialogBg:setContentSize(CCSizeMake(450,bgHeight))
	dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.landTypeLayer:addChild(dialogBg)
	local function getPositionByIndex(index)
		local groundX,groundY
		if(index==1)then
			groundX=self.data.x-1
			groundY=self.data.y-1
		elseif(index==2)then
			groundX=self.data.x
			groundY=self.data.y-1
		elseif(index==3)then
			groundX=self.data.x+1
			groundY=self.data.y-1
		elseif(index==4)then
			groundX=self.data.x-1
			groundY=self.data.y
		elseif(index==5)then
			groundX=self.data.x
			groundY=self.data.y
		elseif(index==6)then
			groundX=self.data.x+1
			groundY=self.data.y
		elseif(index==7)then
			groundX=self.data.x-1
			groundY=self.data.y+1
		elseif(index==8)then
			groundX=self.data.x
			groundY=self.data.y+1
		elseif(index==9)then
			groundX=self.data.x+1
			groundY=self.data.y+1
		end
		return groundX,groundY
	end
	local groundList={}
	for i=1,9 do
		local groundX,groundY=getPositionByIndex(i)
		local gType=worldBaseVoApi:getGroundType(groundX,groundY)
		local function showGroundDetail()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			if(gType)then
				local tabStr={}
				local tabColor={}
				local td=smallDialog:new()
				local attackCfg=worldGroundCfg[gType]
				for k,v in pairs(attackCfg.attType) do
					local valueStr
					if(attackCfg.attValue[k]>0)then
						valueStr="+"..attackCfg.attValue[k]
						table.insert(tabColor,1,G_ColorGreen)
					else
						valueStr=attackCfg.attValue[k]
						table.insert(tabColor,1,G_ColorRed)
					end
					table.insert(tabColor,1,G_ColorWhite)
					table.insert(tabStr,1,getlocal("world_ground_effect_"..v).." "..valueStr.."%")
					table.insert(tabStr,1,"\n")
				end
				local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,tabStr,25,tabColor,getlocal("world_ground_name_"..gType).." ("..groundX..","..groundY..")")
				sceneGame:addChild(dialog,layerNum+1)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_ground_no_ground"),30)
			end
		end
		local groundBg
		if(i==5)then
			groundBg=LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",CCRect(20,20,10,10),showGroundDetail)
		else
			groundBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(20,20,10,10),showGroundDetail)
		end
		groundBg:setTouchPriority(-(layerNum-1)*20-2)
		groundBg:setContentSize(CCSizeMake(120,65))
		local tmpX=(i - 1)%3*125 + 95
		local tmpY=bgHeight - 70 - math.floor((i - 1)/3)*70
		groundBg:setPosition(ccp(tmpX,tmpY))

		local groundIcon
		if(gType==nil)then
			groundIcon=CCSprite:createWithSpriteFrameName("world_ground_0.png")
		else
			groundIcon=CCSprite:createWithSpriteFrameName("world_ground_"..gType..".png")
		end
		groundIcon:setPosition(ccp(groundBg:getContentSize().width/2,groundBg:getContentSize().height/2-5))
		groundBg:addChild(groundIcon)
		dialogBg:addChild(groundBg)
		groundList[i]=groundBg
	end
	local direction=worldBaseVoApi:getAttackDirection(self.data.x,self.data.y,playerVoApi:getMapX(),playerVoApi:getMapY())
	if(direction==nil)then
		do return end
	end
	local arrowSP=CCSprite:createWithSpriteFrameName("arrow_direction_"..direction..".png")
	if(arrowSP==nil)then
		local nameIndex=10 - direction
		arrowSP=CCSprite:createWithSpriteFrameName("arrow_direction_"..nameIndex..".png")
		arrowSP:setRotation(180)
	end
	local bgPosX,bgPosY=groundList[direction]:getPosition()
	local bgSize=groundList[direction]:getContentSize()
	local posX,posY
	if(direction==1)then
		posX=bgPosX + bgSize.width/2
		posY=bgPosY - bgSize.height/2
	elseif(direction==2)then
		posX=bgPosX
		posY=bgPosY - bgSize.height/2
	elseif(direction==3)then
		posX=bgPosX - bgSize.width/2
		posY=bgPosY - bgSize.height/2
	elseif(direction==4)then
		posX=bgPosX + bgSize.width/2
		posY=bgPosY
	elseif(direction==5)then
		posX=bgPosX
		posY=bgPosY
	elseif(direction==6)then
		posX=bgPosX - bgSize.width/2
		posY=bgPosY
	elseif(direction==7)then
		posX=bgPosX + bgSize.width/2
		posY=bgPosY + bgSize.height/2
	elseif(direction==8)then
		posX=bgPosX
		posY=bgPosY + bgSize.height/2
	elseif(direction==9)then
		posX=bgPosX - bgSize.width/2
		posY=bgPosY + bgSize.height/2
	end
	arrowSP:setPosition(ccp(posX,posY))
	dialogBg:addChild(arrowSP)
	local buffDescLb=GetTTFLabelWrap(getlocal("world_ground_buff_title"),25,CCSizeMake(410,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	buffDescLb:setAnchorPoint(ccp(0,1))
	buffDescLb:setPosition(ccp(20,bgHeight - 250))
	dialogBg:addChild(buffDescLb)
	local posY=bgHeight - 250 - buffDescLb:getContentSize().height
	local attackCfg=worldBaseVoApi:getAttackGroundCfg(self.data.x,self.data.y)
	for k,v in pairs(attackCfg.attType) do
		local buffLb=GetTTFLabel(getlocal("world_ground_effect_"..v),23)
		buffLb:setAnchorPoint(ccp(0,1))
		buffLb:setPosition(ccp(20,posY))
		dialogBg:addChild(buffLb)

		local buffValue=attackCfg.attValue[k].."%"
		if(attackCfg.attValue[k]>=0)then
			buffValue="+"..buffValue
		end
		local buffValueLb=GetTTFLabel(buffValue,25)
		if(attackCfg.attValue[k]>0)then
			buffValueLb:setColor(G_ColorGreen)
		elseif(attackCfg.attValue[k]<0)then
			buffValueLb:setColor(G_ColorRed)
		end
		buffValueLb:setAnchorPoint(ccp(0,1))
		buffValueLb:setPosition(ccp(35 + buffLb:getContentSize().width,posY))
		dialogBg:addChild(buffValueLb)
		posY=posY-30
	end
end

function worldRebelSmallDialog:tick()
	if(self.data.ptEndTime<=base.serverTime)then
		self:close()
		do return end
	end
	local combo=rebelVoApi:getAttackCombo(self.data.x,self.data.y)
	if(combo<=0)then
		local comboLb=tolua.cast(self.bgLayer:getChildByTag(101),"CCLabelTTF")
		if(comboLb)then
			comboLb:removeFromParentAndCleanup(true)
		end
		local buffLb1=tolua.cast(self.bgLayer:getChildByTag(102),"CCLabelTTF")
		if(buffLb1)then
			buffLb1:removeFromParentAndCleanup(true)
		end
		local buffLb2=tolua.cast(self.bgLayer:getChildByTag(103),"CCLabelTTF")
		if(buffLb2)then
			buffLb2:removeFromParentAndCleanup(true)
		end
		local buffTimeLb=tolua.cast(self.bgLayer:getChildByTag(104),"CCLabelTTF")
		if(buffTimeLb)then
			buffTimeLb:removeFromParentAndCleanup(true)
		end
		local noComboLb=tolua.cast(self.bgLayer:getChildByTag(105),"CCLabelTTF")
		if(noComboLb and noComboLb:isVisible()==false)then
			noComboLb:setVisible(true)
		end
		if(self.buffLeftLb)then
			self.buffLeftLb:removeFromParentAndCleanup(true)
			self.buffLeftLb=nil
		end
	end
	if(self.buffLeftLb)then
		self.buffLeftLb:setString(GetTimeStr(rebelVoApi:getComboLeftTime() - base.serverTime))
	end
	local curEnergy=rebelVoApi:getRebelEnergy()
	if(curEnergy~=self.curEnergy)then
		local maxEnergy=rebelCfg.energyMax
		for i=1,maxEnergy do
			if(i<=curEnergy)then
				self.energyIconList[i][1]:setVisible(true)
			else
				self.energyIconList[i][1]:setVisible(false)
			end
			if(self.energyIconList[i][2])then
				if(i<curEnergy)then
					self.energyIconList[i][2]:setVisible(true)
				else
					self.energyIconList[i][2]:setVisible(false)
				end
			end
		end
		self.curEnergy=curEnergy
	end
	if(self.countdownLb)then
		self.countdownLb:setString(GetTimeStr(self.data.ptEndTime - base.serverTime))
	end
	local lbCost1=tolua.cast(self.bgLayer:getChildByTag(201),"CCLabelTTF")
	if(lbCost1)then
		local scoutRes=rebelCfg.troops.scoutConsume[self.data.level] or rebelCfg.troops.scoutConsume[#rebelCfg.troops.scoutConsume]
		if(playerVoApi:getGold()>=scoutRes)then
			lbCost1:setColor(G_ColorWhite)
		else
			lbCost1:setColor(G_ColorRed)
		end
	end
	local lbCost2=tolua.cast(self.bgLayer:getChildByTag(202),"CCLabelTTF")
	if(lbCost2)then
		local costEnergy1=rebelCfg.attackConsume1
		if(rebelVoApi:getRebelEnergy()>=costEnergy1)then
			lbCost2:setColor(G_ColorWhite)
		else
			lbCost2:setColor(G_ColorRed)
		end
	end
	local lbCost3=tolua.cast(self.bgLayer:getChildByTag(203),"CCLabelTTF")
	if(lbCost3)then
		local costEnergy2=rebelCfg.attackConsume2
		if(rebelVoApi:getRebelEnergy()>=costEnergy2)then
			lbCost3:setColor(G_ColorWhite)
		else
			lbCost3:setColor(G_ColorRed)
		end
	end
	if(self.energyCountDown and self.energyCountDown.setString)then
		local recoverLeft=rebelVoApi:getEnergyRecoverTs() - base.serverTime
		if(recoverLeft==0)then
			if(rebelVoApi:getRebelEnergy()>=rebelCfg.energyMax)then
				if(self.energyLayer)then
					self.energyLayer:removeFromParentAndCleanup(true)
					self.energyLayer=nil
					self.energyCountDown=nil
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("worldRebel_energyFull"),30)
				end
			else
				if(self.energyLayer)then
					self.energyLayer:removeFromParentAndCleanup(true)
					self.energyLayer=nil
					self.energyCountDown=nil
					self:showBuyEnergyDialog()
				end
			end
		else
			self.energyCountDown:setString(getlocal("worldRebel_buyEnergyConfirm1",{GetTimeStr(recoverLeft)}))
		end
	end
end

function worldRebelSmallDialog:dispose()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("serverWar/serverWar2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("serverWar/serverWar2.png")
	spriteController:removePlist("public/acChrisEveImage.plist")
	spriteController:removeTexture("public/acChrisEveImage.png")
	spriteController:removePlist("public/boss_fuben_images.plist")
	spriteController:removeTexture("public/boss_fuben_images.png")
	spriteController:removePlist("public/acAnniversary.plist")
	spriteController:removeTexture("public/acAnniversary.png")
end