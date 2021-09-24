--技能升级面板
planeSkillUpgradeDialog=commonDialog:new()

function planeSkillUpgradeDialog:new(sid,planeVo,pos,activeFlag)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.equipBgWidth = 295
	self.equipBgHeight = 530
	nc.sid=sid
	nc.skillCfg=nil
	nc.planeVo=planeVo
	nc.pos=pos
	nc.activeFlag=activeFlag
	return nc
end

function planeSkillUpgradeDialog:resetTab()
	self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 93))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
end

-- 添加一条装备信息
function planeSkillUpgradeDialog:doUserHandler()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/emblem/emblemImage.plist")
    spriteController:addTexture("public/emblem/emblemImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444) 
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
	spriteController:addTexture("public/allianceWar2/allianceWar2.png")


	local scfg,gcfg=planeVoApi:getSkillCfgById(self.sid)
	self.skillCfg=gcfg
	local function nilFunc()
	end
	local centerX=G_VisibleSizeWidth/2
	local centerY=G_VisibleSizeHeight - 100 - self.equipBgHeight/2
	
	-- 文字大小
	self.fontSize = 20
	if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
		self.fontSize = 18
	end

	local txtWidth = 255
	self.targetSid=self.skillCfg.lvTo
	if self.targetSid==nil then
		self:close()
	end
	local scfg2,gcfg2=planeVoApi:getSkillCfgById(self.targetSid)
	local showCfg={{self.sid,self.skillCfg},{self.targetSid,gcfg2}}

	self.skillHeight = 0
	self.attUpHeight = 0

	self.skillHeight = self.skillHeight + 10 + 50 --  10 是文字最下面间隔高度，50是“装备技能”文字总高度
	self.attUpHeight = self.attUpHeight + 10 + 50

	for k=1,2 do
		local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("emblemUpBg.png",CCRect(40,60,46,6),nilFunc)
		iconBg:setContentSize(CCSizeMake(self.equipBgWidth,self.equipBgHeight))
		iconBg:setAnchorPoint(ccp(0.5,0.5))

		-- 装备的icon
		local sid=showCfg[k][1]
		local skillCfg=showCfg[k][2]
		local nameStr,descStr=planeVoApi:getSkillInfoById(sid,nil,true)
		local icon=planeVoApi:getSkillIcon(sid,100)
		icon:setAnchorPoint(ccp(0.5,1))
		icon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height-40))
		iconBg:addChild(icon)
		local color=planeVoApi:getColorByQuality(skillCfg.color)
		local nameLb=GetTTFLabel(nameStr,25)
		nameLb:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height - 170)
		nameLb:setColor(color)
		iconBg:addChild(nameLb)

		local line1 = CCSprite:createWithSpriteFrameName("LineCross.png")
		line1:setScaleX((iconBg:getContentSize().width - 20)/line1:getContentSize().width)
		line1:setAnchorPoint(ccp(0.5,0.5))
		line1:setPosition(ccp(iconBg:getContentSize().width/2, iconBg:getContentSize().height-200))
		iconBg:addChild(line1)

		local colorTb={G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorGreen,G_ColorWhite}
		local descWidth,descFontSize=iconBg:getContentSize().width-20,25
		local descHeight,maxDescHeight=0,iconBg:getContentSize().height/2-70        
        local descLb=GetTTFLabelWrap(descStr,descFontSize,CCSize(descWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,nil,true)
        descHeight=descLb:getContentSize().height
        if descHeight>maxDescHeight then
			local descTb={
            	{descStr,colorTb,descFontSize,true}
		    }
        	local descTv,cellHeight=G_LabelTableViewNew(CCSizeMake(descWidth,maxDescHeight),descTb,descFontSize,kCCTextAlignmentLeft)
        	descTv:setAnchorPoint(ccp(0,0))
	        descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	        descTv:setMaxDisToBottomOrTop(100)
	        descTv:setPosition(10,10)
	        iconBg:addChild(descTv,2)
        else
        	local descLb,lbHeight=G_getRichTextLabel(descStr,colorTb,descFontSize,descWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			descLb:setAnchorPoint(ccp(0,1))
			descLb:setPosition(ccp(10,maxDescHeight+10))
			iconBg:addChild(descLb,2)
        end        

		if k==1 then
			iconBg:setPosition(ccp(iconBg:getContentSize().width/2+15,centerY))
			self.bgLayer:addChild(iconBg)
		else
			iconBg:setPosition(ccp(self.bgLayer:getContentSize().width-iconBg:getContentSize().width/2-15,centerY))
			self.bgLayer:addChild(iconBg)
		end
		
	end

	self.mvTb={}
	local startX=centerX - 30
	for i=1,3 do
		self.mvTb[i]={}
		local sp1=CCSprite:createWithSpriteFrameName("accessoryArrow1.png")
		sp1:setPosition(startX + (i - 1)*30,centerY)
		self.bgLayer:addChild(sp1)
		self.mvTb[i][1]=sp1
		local sp2=CCSprite:createWithSpriteFrameName("accessoryArrow2.png")
		sp2:setOpacity(0)
		sp2:setPosition(startX + (i - 1)*30,centerY)
		self.bgLayer:addChild(sp2)
		self.mvTb[i][2]=sp2
	end
	self.actionSp=0
	local function onActionEnd()
		self.actionSp=self.actionSp + 1
		if(self.actionSp>3)then
			self.actionSp=1
		end
		local fadeOut=CCFadeOut:create(0.5)
		local delay=CCDelayTime:create(0.5)
		local callFunc=CCCallFunc:create(onActionEnd)
		local fadeIn=CCFadeIn:create(0.5)
		local acArr2=CCArray:create()
		acArr2:addObject(fadeIn)
		acArr2:addObject(delay)
		acArr2:addObject(fadeOut)
		local seq2=CCSequence:create(acArr2)
		self.mvTb[self.actionSp][2]:runAction(seq2)
		local acArr=CCArray:create()
		acArr:addObject(fadeOut)
		acArr:addObject(delay)
		acArr:addObject(callFunc)
		acArr:addObject(fadeIn)
		local seq=CCSequence:create(acArr)
		self.mvTb[self.actionSp][1]:runAction(seq)
	end
	onActionEnd()

	local costY = centerY - self.equipBgHeight/2 - 10
	local costBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(30,30,40,40),function ( ... )end)
	costBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,200))
	costBg:setAnchorPoint(ccp(0.5,1))
	costBg:setPosition(G_VisibleSizeWidth/2,costY)
	self.bgLayer:addChild(costBg)
	local titleBg = CCSprite:createWithSpriteFrameName("HelpHeaderBg.png")
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition(self.bgLayer:getContentSize().width/2,costY - 5)
	self.bgLayer:addChild(titleBg)
	-- 升级所需材料提示文字
	local upgradeNeedLb = GetTTFLabel(getlocal("emblem_upgrade_need"),25)
	upgradeNeedLb:setAnchorPoint(ccp(0.5,0.5))
	upgradeNeedLb:setPosition(getCenterPoint(titleBg))
	titleBg:addChild(upgradeNeedLb,1)

	costY = costY - titleBg:getContentSize().height

	local upCost = {p=self.skillCfg.upCost}
	local costReward = FormatItem(upCost)
	local index = 1
	local px
	local iconSpace = 130
	local isSuccessUpdate = true--是否材料足够升级
	local useGems = 0
	local startX=(G_VisibleSizeWidth - iconSpace*(#costReward))/2 + iconSpace/2
	for k,v in pairs(costReward) do
		local icon = G_getItemIcon(v,100,true,self.layerNum)
		px = startX + (k - 1)*iconSpace
		icon:setPosition(ccp(px,costY - 65))
		self.bgLayer:addChild(icon)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		local str=bagVoApi:getItemNumId(v.id).."/"..v.num
		local strLb=GetTTFLabel(str,22)
		strLb:setPosition(ccp(icon:getContentSize().width/2,-15))
		icon:addChild(strLb)
		local havePropNum = bagVoApi:getItemNumId(v.id)
		if havePropNum<v.num then
			strLb:setColor(G_ColorRed)
			isSuccessUpdate=false
			useGems = useGems + (v.num-havePropNum)*propCfg[v.key].gemCost
		end
		index = index + 1
	end
	costY = costY - 150 - 20

	-- 升级
	local function onClickUpgrade()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local function onConfirm()
			if self.skillCfg.lvTo == nil then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_maxLv"),30)
				do return end
			end
			local function upgradeCallBack()
				self:showGetSkill(self.sid,self.targetSid,self.layerNum+1)
			end
	
			if isSuccessUpdate==false then
				local function upgradeByGemsFunc()
					local useGems=planeVoApi:getSkillUpgradeCost(self.sid)
					if playerVoApi:getGems() >= useGems then
						planeVoApi:upgrade(self.sid,true,upgradeCallBack,self.planeVo,self.pos,self.activeFlag)
					else
						GemsNotEnoughDialog(nil,nil,useGems - playerVoApi:getGems(),self.layerNum+1,useGems)
					end
				end
				smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),upgradeByGemsFunc,getlocal("dialog_title_prompt"),getlocal("emblem_upgrade_no_prop",{useGems}),nil,self.layerNum+1)
			else
				planeVoApi:upgrade(self.sid,false,upgradeCallBack,self.planeVo,self.pos,self.activeFlag)
			end
		end
		if(self.skillCfg.color<5)then
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("skill_upgradeConfirm"),nil,self.layerNum+1)
		else
			onConfirm()
		end
	end
	local scale=0.8
	local upgradeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onClickUpgrade,2,getlocal("upgradeBuild"),25/scale)
	upgradeItem:setScale(scale)
	local upgradeBtn=CCMenu:createWithItem(upgradeItem)
	upgradeBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,costY/2 + 10))
	upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(upgradeBtn)
end

function planeSkillUpgradeDialog:showGetSkill(sid,targetSid,layerNum)
	self:close()

	local layer = CCLayer:create()
	layer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	sceneGame:addChild(layer,layerNum)

	local equipIconPos = ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 250)

	-- 文字大小
	local fontSize = 20
	if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
		fontSize = 18
	end

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2, 2, 2, 2),function ()end)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setContentSize(CCSizeMake(640,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(200)
	touchDialogBg:setPosition(ccp(0,0))
	layer:addChild(touchDialogBg)
	
	local lightSp1=CCSprite:createWithSpriteFrameName("emblemLight.png")
	lightSp1:setScale(5)
	lightSp1:setOpacity(153)
	lightSp1:setPosition(equipIconPos)
	layer:addChild(lightSp1,1)
	local rotate=CCRotateBy:create(10,360)
	local repeatAc=CCRepeatForever:create(rotate)
	lightSp1:runAction(repeatAc)
	local lightSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
	lightSp2:setScale(2.5)
	lightSp2:setPosition(equipIconPos)
	layer:addChild(lightSp2,2)
	local rotate=CCRotateBy:create(10,-360)
	local repeatAc=CCRepeatForever:create(rotate)
	lightSp2:runAction(repeatAc)

	local titleBg = CCSprite:createWithSpriteFrameName("awTitleBg.png")
	titleBg:setPosition(layer:getContentSize().width/2,layer:getContentSize().height - 80)
	layer:addChild(titleBg,1)

	local lb=GetTTFLabel(getlocal("emblem_upgrade_success"),28)
	lb:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2 + 7)
	lb:setColor(G_ColorYellowPro)
	titleBg:addChild(lb,8)

	local function callback31()
		local strSize2 = 21
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" then
			strSize2 = 25
		elseif G_getCurChoseLanguage() =="ru" then
			strSize2 = 19
		end
		local function nilFunc( ... )
			-- body
		end
		local txtWidth=200
		local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
		local targetSid=gcfg.lvTo
		local scfg2,gcfg2=planeVoApi:getSkillCfgById(targetSid)
		local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("VipIconYellow.png",CCRect(60,24,90,40),nilFunc)
		titleBg:setContentSize(CCSizeMake(400,74))
		local contentW=G_VisibleSizeWidth
		local contentH=0
		local descW=(contentW-100)/2
		local showCfg={{sid,gcfg},{targetSid,gcfg2}}
		local descLbTb={}
		for i=1,2 do
			-- 技能名称
			local sid=showCfg[i][1]
			local cfg=showCfg[i][2]
			local nameStr,descStr=planeVoApi:getSkillInfoById(sid,nil,true)
			local colorTb={G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorGreen,G_ColorWhite}
	        local descLb,lbHeight=G_getRichTextLabel(descStr,colorTb,strSize2,descW,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			descLb:setAnchorPoint(ccp(0,0.5))
			if lbHeight>contentH then
				contentH=lbHeight
			end
			descLbTb[i]={descLb,lbHeight}
		end
		contentH=contentH+100
		if contentH<300 then
			contentH=300
		end
		local contentBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(213,20,1,7),nilFunc)
		contentBg:setContentSize(CCSizeMake(contentW,contentH))
		contentBg:setAnchorPoint(ccp(0.5,1))
		contentBg:setPosition(layer:getContentSize().width/2,layer:getContentSize().height - 430)
		layer:addChild(contentBg,10)

		titleBg:setPosition(contentBg:getContentSize().width/2,contentBg:getContentSize().height)
		contentBg:addChild(titleBg,9)

		local nameStr,descStr=planeVoApi:getSkillInfoById(targetSid)
		local nameLb=GetTTFLabelWrap(nameStr,26,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		nameLb:setAnchorPoint(ccp(0.5,0))
		nameLb:setPosition(ccp(titleBg:getContentSize().width/2,20))
		titleBg:addChild(nameLb)

		for i=1,2 do
			local descLb=descLbTb[i][1]
			local height=descLbTb[i][2]
			descLb:setPosition(20+(i-1)*(contentW/2+25),contentBg:getContentSize().height/2+height/2)
			contentBg:addChild(descLb)
		end

		local mvTb={}
		local startX=contentBg:getContentSize().width/2 - 30
		for i=1,3 do
			mvTb[i]={}
			local sp1=CCSprite:createWithSpriteFrameName("accessoryArrow1.png")
			sp1:setPosition(startX + (i - 1)*30,contentBg:getContentSize().height/2)
			sp1:setScale(0.8)
			contentBg:addChild(sp1,1)
			mvTb[i][1]=sp1
			local sp2=CCSprite:createWithSpriteFrameName("accessoryArrow2.png")
			sp2:setOpacity(0)
			sp2:setScale(0.8)
			sp2:setPosition(startX + (i - 1)*30,contentBg:getContentSize().height/2)
			contentBg:addChild(sp2,1)
			mvTb[i][2]=sp2
		end
		local actionSp=0
		local function onActionEnd()
			actionSp=actionSp + 1
			if(actionSp>3)then
				actionSp=1
			end
			local fadeOut=CCFadeOut:create(0.5)
			local delay=CCDelayTime:create(0.5)
			local callFunc=CCCallFunc:create(onActionEnd)
			local fadeIn=CCFadeIn:create(0.5)
			local acArr2=CCArray:create()
			acArr2:addObject(fadeIn)
			acArr2:addObject(delay)
			acArr2:addObject(fadeOut)
			local seq2=CCSequence:create(acArr2)
			mvTb[actionSp][2]:runAction(seq2)
			local acArr=CCArray:create()
			acArr:addObject(fadeOut)
			acArr:addObject(delay)
			acArr:addObject(callFunc)
			acArr:addObject(fadeIn)
			local seq=CCSequence:create(acArr)
			mvTb[actionSp][1]:runAction(seq)
		end
		onActionEnd()

		
		local startX = 0
		local attStartX = 0
		local posY

		local function onClose( ... )
			for k,v in pairs(mvTb) do
				if(v and v.stopAllActions)then
					v:stopAllActions()
				end
			end
			layer:removeAllChildrenWithCleanup(true)				   
			layer:removeFromParentAndCleanup(true)
		end
		local scale=0.8
		local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onClose,nil,getlocal("fight_close"),25/scale)
		okItem:setScale(scale)
		local okBtn=CCMenu:createWithItem(okItem)
		okBtn:setTouchPriority(-(layerNum)*20-2)
		okBtn:setAnchorPoint(ccp(1,0.5))
		okBtn:setPosition(ccp(G_VisibleSizeWidth/2,60))
		layer:addChild(okBtn,11)
	end
	
	-- 装备的icon
	local mIcon = planeVoApi:getSkillIcon(targetSid,100)
	if mIcon then
		mIcon:setScale(0)
		mIcon:setPosition(equipIconPos)
		layer:addChild(mIcon,12)
		local ccScaleTo = CCScaleTo:create(0.6,1.4)
		local callFunc3=CCCallFuncN:create(callback31)
		local iconAcArr=CCArray:create()
		iconAcArr:addObject(ccScaleTo)
		iconAcArr:addObject(callFunc3)
		local seq=CCSequence:create(iconAcArr)
		mIcon:runAction(seq)
	end
end

function planeSkillUpgradeDialog:dispose()
	if(self.mvTb)then
		for k,v in pairs(self.mvTb) do
			if(v and v.stopAllActions)then
				v:stopAllActions()
			end
		end
	end
	spriteController:removePlist("public/emblem/emblemImage.plist")
	spriteController:removeTexture("public/emblem/emblemImage.png")
	spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
	spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
end