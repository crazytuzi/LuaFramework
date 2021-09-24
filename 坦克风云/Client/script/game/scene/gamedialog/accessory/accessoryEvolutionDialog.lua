--配件突破的面板
accessoryEvolutionDialog=smallDialog:new()

function accessoryEvolutionDialog:new(tankID,partID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.tankID=tankID
	nc.partID=partID
	nc.data=accessoryVoApi:getAccessoryByPart(tankID,partID)
	nc.dialogWidth=580
	nc.dialogHeight=880
	return nc
end

function accessoryEvolutionDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
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
	
	local titleLb=GetTTFLabel(getlocal("accessory_evolution"),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	self.srcID = self.data.type
	self.destID = self.data:getConfigData("breach").get

	self:initUp()
	self:initDown()

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))

	local dataKey="accessoryEvolutionTips@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	local localData=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
    if localData and localData==1 then
    else
    	local subTitle=getlocal("accessory_evolution_tip_subTitle")
    	local content=getlocal("accessory_evolution_tip_desc")
    	accessoryVoApi:showEvolutionTipsDialog(self.layerNum+1,subTitle,content)
    end

	return self.dialogLayer
end

--初始化面板的上半部分，突破前后的图标和动画
function accessoryEvolutionDialog:initUp()
	local posY=self.dialogHeight - 210
	local upBg=CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
	upBg:setScale((self.dialogWidth - 10)/upBg:getContentSize().width)
	upBg:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(upBg)
	local srcBg=CCSprite:createWithSpriteFrameName("accessoryRoundBg.png")
	srcBg:setPosition(130,posY)
	self.bgLayer:addChild(srcBg)
	local function onClickSrcIcon()
		self:showAccessoryInfo(self.data)
	end
	local srcIcon=accessoryVoApi:getAccessoryIcon(self.srcID,70,100,onClickSrcIcon)
	srcIcon:setTouchPriority(-(self.layerNum-1)*20-2)
	srcIcon:setPosition(130,posY)
	self.bgLayer:addChild(srcIcon)
	local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
	local rankLb=GetTTFLabel(self.data.rank,30)
	rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
	rankTip:addChild(rankLb)
	rankTip:setScale(0.5)
	rankTip:setAnchorPoint(ccp(0,1))
	rankTip:setPosition(ccp(0,100))
	srcIcon:addChild(rankTip)
	local lvLb=GetTTFLabel(getlocal("fightLevel",{self.data.lv}),20)
	lvLb:setAnchorPoint(ccp(1,0))
	lvLb:setPosition(ccp(85,5))
	srcIcon:addChild(lvLb)
	local beforeLb=GetTTFLabel(getlocal("accessory_evolutionBefore"),25)
	beforeLb:setPosition(130,posY - 50 - 40)
	local beforeBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
	beforeBg:setContentSize(CCSizeMake(beforeLb:getContentSize().width + 120,beforeLb:getContentSize().height + 16))
	beforeBg:setPosition(130,posY - 50 - 40)
	self.bgLayer:addChild(beforeBg)
	self.bgLayer:addChild(beforeLb)


	local destBg=CCSprite:createWithSpriteFrameName("accessoryRoundBg.png")
	destBg:setPosition(self.dialogWidth - 130,posY)
	self.bgLayer:addChild(destBg)
	local function onClickDestIcon()
		local aVo=accessoryVo:new()
		aVo:initWithData({self.destID,0,0})
		if self.rankLb then
			local lbStr=self.rankLb:getString()
			if lbStr and lbStr~="" and tonumber(lbStr) then
				aVo.rank=tonumber(lbStr)
			end
		end
		self:showAccessoryInfo(aVo)
	end
	local destIcon=accessoryVoApi:getAccessoryIcon(self.destID,70,100,onClickDestIcon)
	destIcon:setTouchPriority(-(self.layerNum-1)*20-2)
	destIcon:setPosition(self.dialogWidth - 130,posY)
	self.bgLayer:addChild(destIcon)
	local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
	local rankLb=GetTTFLabel(0,30)
	rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
	rankTip:addChild(rankLb)
	self.rankLb=rankLb
	rankTip:setScale(0.5)
	rankTip:setAnchorPoint(ccp(0,1))
	rankTip:setPosition(ccp(0,100))
	destIcon:addChild(rankTip)
	local lvLb=GetTTFLabel(getlocal("fightLevel",{0}),20)
	lvLb:setAnchorPoint(ccp(1,0))
	lvLb:setPosition(ccp(85,5))
	destIcon:addChild(lvLb)
	local afterLb=GetTTFLabel(getlocal("accessory_evolutionAfter"),25)
	afterLb:setPosition(self.dialogWidth - 130,posY - 50 - 40)
	local afterBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
	afterBg:setContentSize(CCSizeMake(afterLb:getContentSize().width + 120,afterLb:getContentSize().height + 16))
	afterBg:setPosition(self.dialogWidth - 130,posY - 50 - 40)
	self.bgLayer:addChild(afterBg)
	self.bgLayer:addChild(afterLb)

	self.mvTb={}
	local startX=self.dialogWidth/2 - 42
	for i=1,3 do
		self.mvTb[i]={}
		local sp1=CCSprite:createWithSpriteFrameName("accessoryArrow1.png")
		sp1:setPosition(startX + (i - 1)*42,posY)
		self.bgLayer:addChild(sp1)
		self.mvTb[i][1]=sp1
		local sp2=CCSprite:createWithSpriteFrameName("accessoryArrow2.png")
		sp2:setOpacity(0)
		sp2:setPosition(startX + (i - 1)*42,posY)
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
	-- local descLb=GetTTFLabelWrap(getlocal("accessory_evolutionDesc"),25,CCSizeMake(self.dialogWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- descLb:setColor(G_ColorRed)
	-- descLb:setPosition(self.dialogWidth/2,posY - 200)
	-- self.bgLayer:addChild(descLb)
	-- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	-- lineSp:setScale(self.dialogWidth/lineSp:getContentSize().width)
	-- lineSp:setPosition(ccp(self.dialogWidth/2,posY - 275))
	-- self.bgLayer:addChild(lineSp)
end

--初始化面板的下半部分，材料之类
function accessoryEvolutionDialog:initDown()
	local strSize2 = 22
	local strSize3 = 22
	local strSize4 = 23
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
		strSize2 =25
		strSize3 =30
		strSize4 = 25
	elseif G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="de" then
		strSize4 =20
	end
	local posY=self.dialogHeight - 510 + 150
	local costBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ( ... )end)
	costBg:setContentSize(CCSizeMake(self.dialogWidth - 40,40))
	costBg:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(costBg)
	local costTitle=GetTTFLabel(getlocal("alien_tech_consume_material"),28)
	costTitle:setColor(G_ColorGreen)
	costTitle:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(costTitle)

	local function onTips()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local subTitle=getlocal("accessory_evolution_tip_subTitle")
    	local content=getlocal("accessory_evolution_tip_desc")
    	accessoryVoApi:showEvolutionTipsDialog(self.layerNum+1,subTitle,content)
	end
	local tipItem=GetButtonItem("noticeBtn.png","noticeBtn_down.png","noticeBtn.png",onTips,nil,nil,0)
	tipItem:setScale(1.2)
	local tipMenu=CCMenu:createWithItem(tipItem)
	tipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	tipMenu:setPosition(ccp(100,posY - 70))
	self.bgLayer:addChild(tipMenu)
	local noticeLb=GetTTFLabelWrap(getlocal("accessory_evolution_notice"),strSize2,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	noticeLb:setPosition(ccp(100,posY - 135))
	self.bgLayer:addChild(noticeLb)
	

	--突破消耗材料
	local needProps={e={}}
	if(self.data:getConfigData("breach").props)then
		for pid,num in pairs(self.data:getConfigData("breach").props) do
			needProps.e[pid]=num
		end
	end
	if(self.data:getConfigData("breach").fragment)then
		for fid,num in pairs(self.data:getConfigData("breach").fragment) do
			needProps.e[fid]=num
		end
	end
	needProps=FormatItem(needProps)
	local function sortFunc(a,b)
		if(a.type==b.type)then
			if(a.eType==b.eType)then
				local aIndex=tonumber(string.sub(a.id,2))
				local bIndex=tonumber(string.sub(b.id,2))
				return aIndex<bIndex
			else
				return a.eType<b.eType
			end
		else
			return a.type<b.type
		end
	end
	table.sort(needProps,sortFunc)
	local length=#needProps
	local unitWidth=120--(self.dialogWidth - 40)/length
	local startX=180--20
	local canCompose=true
	-- local posTb=G_getIconSequencePosx(2,unitWidth,360,length)
	for i=1,length do
		local icon=G_getItemIcon(needProps[i],100,true,self.layerNum)
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		local pox=startX + unitWidth*(i - 0.5)
		-- if posTb[i] then
		-- 	pox=posTb[i]
		-- end
		icon:setPosition(pox,posY - 80)
		self.bgLayer:addChild(icon)
		local needNum=needProps[i].num
		local hasNum
		if(needProps[i].eType=="f")then
			local fVo=accessoryVoApi:getFragmentByID(needProps[i].key)
			if(fVo)then
				hasNum=fVo.num
			else
				hasNum=0
			end
		elseif(needProps[i].eType=="p")then
			hasNum=accessoryVoApi:getPropNums()[needProps[i].key] or 0
		end
		local numLb=GetTTFLabel(hasNum.."/"..needNum,25)
		if(hasNum<needNum)then
			numLb:setColor(G_ColorRed)
			canCompose=false
		else
			numLb:setColor(G_ColorGreen)
		end
		numLb:setPosition(ccp(pox,posY - 145))
		self.bgLayer:addChild(numLb)
	end

	--突破返还材料
	local posY=posY-185
	local returnBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ( ... )end)
	returnBg:setContentSize(CCSizeMake(self.dialogWidth - 40,40))
	returnBg:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(returnBg)
	local returnTitle=GetTTFLabel(getlocal("accessory_evolution_return"),28)
	returnTitle:setColor(G_ColorGreen)
	returnTitle:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(returnTitle)

	self:resetReturnInfo(posY - 80)

	local lineSp0=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp0:setScale((G_VisibleSizeWidth-150)/lineSp0:getContentSize().width)
	lineSp0:setPosition(ccp(G_VisibleSizeWidth/2-30,165))
	self.bgLayer:addChild(lineSp0)

	local function onEvolution()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		if self.stayLvSp and self.stayLvSp:isVisible()==true then
			local costGems=accessoryVoApi:stayLvCostGems(self.data.rank) or 0
			if costGems>playerVoApi:getGems() then
				GemsNotEnoughDialog(nil,nil,costGems - playerVoApi:getGems(),self.layerNum + 1,costGems)
			else
				self:evolution()
			end
		else
			self:evolution()
		end
	end
	self.evolutionItem=GetButtonItem("LoadingBtn.png","LoadingBtn_Down.png","LoadingBtn.png",onEvolution,nil,getlocal("accessory_evolution2"),strSize3,19)
	local menuBtn=CCMenu:createWithItem(self.evolutionItem)
	menuBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	menuBtn:setPosition(ccp(self.dialogWidth/2,60))
	self.bgLayer:addChild(menuBtn)
    
	
	local lbPy=130
	local needRank=self.data:getConfigData("breach").blvl or 0
	local rankDescLb
	if(needRank>0)then
		rankDescLb=GetTTFLabelWrap(getlocal("accessory_evolutionError2",{needRank}),25,CCSizeMake(self.dialogWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		rankDescLb:setPosition(self.dialogWidth/2,lbPy)
		self.bgLayer:addChild(rankDescLb)
	end
	if(self.data.rank<needRank)then
		canCompose=false
		if(rankDescLb)then
			rankDescLb:setColor(G_ColorRed)
		end
	else
		if(rankDescLb)then
			rankDescLb:setColor(G_ColorGreen)
			rankDescLb:setVisible(false)
		end

		local quality=tonumber(self.data:getConfigData("quality"))
		if quality==4 then
			local costGems=accessoryVoApi:stayLvCostGems(self.data.rank) or 0
		    local goldSp,costLb
		    if costGems and costGems>0 then
		    	goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
			    goldSp:setPosition(ccp(40,self.evolutionItem:getContentSize().height/2))
			    self.evolutionItem:addChild(goldSp)
			    goldSp:setVisible(false)
			    costLb=GetTTFLabel(costGems,25)
			    costLb:setPosition(ccp(40+goldSp:getContentSize().width+10,self.evolutionItem:getContentSize().height/2))
			    self.evolutionItem:addChild(costLb)
			    costLb:setVisible(false)
			    
			end

			local function clickHandler1( ... )
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				PlayEffect(audioCfg.mouseClick)
				
				if self.stayLvSp then
					if self.stayLvSp:isVisible()==true then
						self.stayLvSp:setVisible(false)
						if costGems and costGems>0 and goldSp and costLb then
							goldSp:setVisible(false)
							costLb:setVisible(false)
							local lb=tolua.cast(self.evolutionItem:getChildByTag(19),"CCLabelTTF")
							if(lb)then
								lb:setPosition(getCenterPoint(self.evolutionItem))
							end
						end
						self:resetReturnInfo(posY - 80)
						if self.rankLb then
							self.rankLb:setString(0)
						end
					else
						self.stayLvSp:setVisible(true)
						if costGems and costGems>0 and goldSp and costLb then
							goldSp:setVisible(true)
							costLb:setVisible(true)
							local lb=tolua.cast(self.evolutionItem:getChildByTag(19),"CCLabelTTF")
							if(lb)then
								lb:setPosition(ccp(self.evolutionItem:getContentSize().width/2+50,lb:getPositionY()))
							end
						end
						self:resetReturnInfo(posY - 80,true)
						if self.rankLb then
							self.rankLb:setString(self.data.rank)
						end
					end
				end
			end
			local spPx=100
			local stayLvBg=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",clickHandler1)
		    stayLvBg:setTouchPriority(-(self.layerNum-1)*20-4)
		    stayLvBg:setPosition(spPx,lbPy)
		    self.bgLayer:addChild(stayLvBg,2)
		    self.stayLvSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
		    self.stayLvSp:setPosition(spPx,lbPy)
		    self.bgLayer:addChild(self.stayLvSp,3)
		    self.stayLvSp:setVisible(false)
		    local stayLvLb=GetTTFLabelWrap(getlocal("accessory_evolution_stay"),strSize4,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			stayLvLb:setAnchorPoint(ccp(0,0.5))
			stayLvLb:setPosition(ccp(spPx+stayLvBg:getContentSize().width-15,lbPy))
			self.bgLayer:addChild(stayLvLb,3)
		end
	end
	self.evolutionItem:setEnabled(canCompose)
end

function accessoryEvolutionDialog:resetReturnInfo(posy,isStay)
	if self.retTb and SizeOfTable(self.retTb)>0 then
		for k,v in pairs(self.retTb) do
			if v and v.icon then
				local icon=tolua.cast(v.icon,"LuaCCSprite")
				if icon then
					icon:removeFromParentAndCleanup(true)
				end
			end
			if v and v.lb then
				local lb=tolua.cast(v.lb,"CCLabelTTF")
				if(lb)then
					lb:removeFromParentAndCleanup(true)
				end
			end
			self.retTb[k]=nil
		end
	end
	self.retTb={}
	local propTb,resource=accessoryVoApi:getEvolutionReturn(self.data)
	local itemTb={}
	local index=0
	if isStay and isStay==true then
	else
		if propTb and SizeOfTable(propTb)>0 then
			itemTb.e={}
			local pIdx=0
			for k,v in pairs(propTb) do
				index=index+1
				pIdx=pIdx+1
				if itemTb.e[pIdx]==nil then
					itemTb.e[pIdx]={}
				end
				itemTb.e[pIdx][k]=v
				itemTb.e[pIdx].index=index
			end
		end
	end
	if resource and resource>0 then
		index=index+1
		itemTb.u={{gold=resource,index=index}}
	end
	if self.emptyLb==nil then
		self.emptyLb=GetTTFLabelWrap(getlocal("accessory_evolution_return_empty"),25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		self.emptyLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,posy))
		self.bgLayer:addChild(self.emptyLb)
	end
	if itemTb and SizeOfTable(itemTb)>0 then
		local rewardTb=FormatItem(itemTb,false,true)
		if rewardTb and SizeOfTable(rewardTb)>0 then
			local tbSize=SizeOfTable(rewardTb)
			local posTb=G_getIconSequencePosx(2,105,self.bgLayer:getContentSize().width/2,tbSize)
			for k,v in pairs(rewardTb) do
				self.retTb[k]={}
				local px,py=0,posy
				if posTb and posTb[k] then
					px=posTb[k] or 0
				end
				local icon=G_getItemIcon(v,100,true,self.layerNum)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
				icon:setPosition(ccp(px,py))
				self.bgLayer:addChild(icon)
				local numStr=v.num
				-- if v.type=="u" then
					numStr=FormatNumber(numStr)
				-- end
				local numLb=GetTTFLabel(numStr,25)
				numLb:setPosition(ccp(px,py-65))
				self.bgLayer:addChild(numLb)
				self.retTb[k].icon=icon
				self.retTb[k].lb=numLb
			end
		end
		if self.emptyLb then
			self.emptyLb:setVisible(false)
		end
	else
		if self.emptyLb then
			self.emptyLb:setVisible(true)
		end
	end
end

function accessoryEvolutionDialog:showAccessoryInfo(data,isAddLayerNum)
	local name=getlocal("accessory_quality_"..data:getConfigData("quality"),{getlocal(data:getConfigData("name"))})
	local lv=getlocal("accessory_lv",{data.lv})
	local rank=getlocal("accessory_rank",{data.rank})
	local tabStr = {rank,lv,"\n",name,"\n"}
	local tabColor = {G_ColorWhite,G_ColorWhite,G_ColorWhite,G_ColorGreen,G_ColorWhite}

	local attTb=data:getAtt()
	local attTypeTb=data:getConfigData("attType")
	local attEffectTb=accessoryCfg.attEffect
	local attStrTb={}
	for k,v in pairs(attTypeTb) do
		local effectStr
		if(attEffectTb[tonumber(v)]==1)then
			effectStr=string.format("%.2f",attTb[k]).."%%"
		else
			effectStr=attTb[k]
		end
		local attStr=getlocal("accessory_attAdd_"..v,{effectStr})
		table.insert(tabStr,1,attStr)
		table.insert(tabColor,1,G_ColorWhite)
	end
	table.insert(tabStr,1,"\n")
	table.insert(tabColor,1,nil)
	table.insert(tabStr,1,getlocal("accessory_gsAdd",{data:getGS()}))
	table.insert(tabColor,1,G_ColorGreen)
	local tankStr
	local tankID=data:getConfigData("tankID")
	if(tankID==1)then
		tankStr=getlocal("tanke")
	elseif(tankID==2)then
		tankStr=getlocal("jianjiche")
	elseif(tankID==3)then
		tankStr=getlocal("zixinghuopao")
	elseif(tankID==4)then
		tankStr=getlocal("huojianche")
	end
	local fitStr=getlocal("accessory_fit_part",{tankStr})
	table.insert(tabStr,1,fitStr)
	table.insert(tabColor,1,G_ColorWhite)
	table.insert(tabStr,1,"\n")
	table.insert(tabColor,1,nil)
	local layerNum=self.layerNum+1
	if isAddLayerNum==true then
		layerNum=layerNum+1
	end
	local td=smallDialog:new()
	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum,tabStr,25,tabColor)
	sceneGame:addChild(dialog,layerNum)
end

function accessoryEvolutionDialog:evolution()
	local stayLv
	if self.stayLvSp and self.stayLvSp:isVisible()==true then
		stayLv=1
	end
	local function callback()
		if(self.evolutionItem)then
			self.evolutionItem:setEnabled(false)
		end
		local posX,posY=130,self.dialogHeight - 210
		local oldMv=CCParticleSystemQuad:create("public/accessoryContract.plist")
		oldMv.positionType=kCCPositionTypeFree
		oldMv:setScale(2)
		oldMv:setPosition(ccp(posX,posY))
		self.bgLayer:addChild(oldMv)
		local delay1=CCDelayTime:create(0.5)
		local function onDelay1()
			local newMv=CCParticleSystemQuad:create("public/accessoryContract.plist")
			newMv.positionType=kCCPositionTypeFree
			newMv:setScale(2)
			newMv:setPosition(ccp(self.dialogWidth - posX,posY))
			self.bgLayer:addChild(newMv)
		end
		local delayFunc1=CCCallFunc:create(onDelay1)
		local delay2=CCDelayTime:create(0.5)
		local function onDelay2()
			-- local result={}
			-- local name=getlocal("accessory_quality_"..accessoryCfg.aCfg[self.destID].quality,{getlocal(accessoryCfg.aCfg[self.destID].name)})
			-- table.insert(result,getlocal("item_number",{name,1}))
			-- local prop,resource=accessoryVoApi:getEvolutionReturn(self.data)
			-- if stayLv and stayLv==1 then
			-- else
			-- 	for pid,num in pairs(prop) do
			-- 		if(num>0)then
			-- 			table.insert(result,getlocal("item_number",{getlocal(accessoryCfg.propCfg[pid].name),FormatNumber(num)}))
			-- 		end
			-- 	end
			-- end
			-- if(resource>0)then
			-- 	table.insert(result,getlocal("item_number",{getlocal("money"),FormatNumber(resource)}))
			-- end
			-- local str=getlocal("accessory_evolutionSuccess",{"\n"..table.concat(result,"\n")})
			-- smallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),str,true,self.layerNum+1,nil,true)
			-- self:close()
			self:showGetReward(self.layerNum+1)
		end
		local delayFunc2=CCCallFunc:create(onDelay2)
		local acArr=CCArray:create()
		acArr:addObject(delay1)
		acArr:addObject(delayFunc1)
		acArr:addObject(delay2)
		acArr:addObject(delayFunc2)
		local seq=CCSequence:create(acArr)
		self.bgLayer:runAction(seq)
	end
	accessoryVoApi:evolution(self.tankID,self.partID,callback,stayLv)
end


function accessoryEvolutionDialog:showGetReward(layerNum)
	local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =28
    end
	if self.rewardLayer == nil then
		self.rewardLayer = CCLayer:create()
		sceneGame:addChild(self.rewardLayer,layerNum)

		local function callback()
		 
		end
		local sceneSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,6,6),function ()end)
		sceneSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
		sceneSp:setAnchorPoint(ccp(0,0))
		sceneSp:setPosition(ccp(0,0))
		sceneSp:setTouchPriority(-(layerNum-1)*20-1)
		self.rewardLayer:addChild(sceneSp)
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		local bigBg=LuaCCSprite:createWithFileName("public/emblem/emblemBlackBg.jpg",callback)
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		bigBg:setAnchorPoint(ccp(0.5,0.5))
		bigBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
		self.rewardLayer:addChild(bigBg)
		local fadeTo = CCFadeTo:create(1.5, 100)
		local fadeBack = CCFadeTo:create(1.5, 255)
		local acArr = CCArray:create()
		acArr:addObject(fadeTo)
		acArr:addObject(fadeBack)
		local seq = CCSequence:create(acArr)
		bigBg:runAction(CCRepeatForever:create(seq))
		
		
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGetBg.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 200))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.rewardLayer:addChild(particleS)
	end
	self:clearChildLayer()
	self.childLayer = CCLayer:create()
	self.rewardLayer:addChild(self.childLayer)
	self.addParticleTb = {}

	local function callback1()
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup1.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.rewardLayer:addChild(particleS,10)
		table.insert(self.addParticleTb,particleS)
		local particleS2 = CCParticleSystemQuad:create("public/emblem/emblemGlowup2.plist")
		particleS2:setPositionType(kCCPositionTypeFree)
		particleS2:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
		particleS2:setAutoRemoveOnFinish(true) -- 自动移除
		self.rewardLayer:addChild(particleS2,11)
		table.insert(self.addParticleTb,particleS2)
	end

	local function callback2()
		local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup3.plist")
		particleS:setPositionType(kCCPositionTypeFree)
		particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
		particleS:setAutoRemoveOnFinish(true) -- 自动移除
		self.rewardLayer:addChild(particleS,12)
		table.insert(self.addParticleTb,particleS)
	end

	-- 抽奖的亮晶晶特效
	local function showBgParticle(parent,pos,quality,order)
		if parent then
			-- local equipCfg = emblemVoApi:getEquipCfgById(equipID)
			local color = quality+1--equipCfg.color
			local particleName = "public/emblem/emblemGet"..color..".plist"
			local starParticleS = CCParticleSystemQuad:create(particleName)
			if starParticleS then
				starParticleS:setPosition(pos)
				parent:addChild(starParticleS,order)
				table.insert(self.addParticleTb,starParticleS)
			end
		end
	end
	
	
	local callFunc1=CCCallFunc:create(callback1)
	local callFunc2=CCCallFunc:create(callback2)
	

	local acArr=CCArray:create()
	local function callback3()
		local titleBg = CCSprite:createWithSpriteFrameName("awTitleBg.png")
		titleBg:setScale(1.2)
		titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 80 - 80)
		self.childLayer:addChild(titleBg)
	
		local titleLb=GetTTFLabel(getlocal("accessory_evolution_success"),strSize2)
		titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 73 - 80)
		self.childLayer:addChild(titleLb)

		local function callback31()
			local function ok( ... )
				-- self:disposeRewardLayer()
				self:close()
			end

			local btnName,btnNameDown
			-- if(self.lastGetType==1)then
			-- 	btnName="BtnCancleSmall.png"
			-- 	btnNameDown="BtnCancleSmall_Down.png"
			-- else
				btnName="BtnOkSmall.png"
				btnNameDown="BtnOkSmall_Down.png"
			-- end
			local okItem=GetButtonItem(btnName,btnNameDown,btnNameDown,ok,nil,getlocal("confirm"),25)
			local okBtn=CCMenu:createWithItem(okItem)
			okBtn:setTouchPriority(-(layerNum-1)*20-2)
			okBtn:setAnchorPoint(ccp(1,0.5))
			okBtn:setPosition(ccp(G_VisibleSizeWidth/2,100))
			self.childLayer:addChild(okBtn,11)


			local accNameLb=GetTTFLabel(getlocal(accessoryCfg.aCfg[self.destID].name),28)
			accNameLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-55))
			self.childLayer:addChild(accNameLb)

			local propTb,resource=accessoryVoApi:getEvolutionReturn(self.data)
			local itemTb={}
			local index=0
			if self.stayLvSp and self.stayLvSp:isVisible()==true then
			else
				if propTb and SizeOfTable(propTb)>0 then
					itemTb.e={}
					local pIdx=0
					for k,v in pairs(propTb) do
						index=index+1
						pIdx=pIdx+1
						if itemTb.e[pIdx]==nil then
							itemTb.e[pIdx]={}
						end
						itemTb.e[pIdx][k]=v
						itemTb.e[pIdx].index=index
					end
				end
			end
			if resource and resource>0 then
				index=index+1
				itemTb.u={{gold=resource,index=index}}
			end
			if itemTb and SizeOfTable(itemTb)>0 then
				-- local returnBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ( ... )end)
				-- returnBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,40))
				-- returnBg:setPosition(ccp(G_VisibleSizeWidth/2,posY))
				-- self.childLayer:addChild(returnBg)
				local returnTitle=GetTTFLabel(getlocal("accessory_evolution_return"),28)
				returnTitle:setColor(G_ColorGreen)
				returnTitle:setPosition(ccp(G_VisibleSizeWidth/2,360))
				self.childLayer:addChild(returnTitle)
				local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
				lineSp1:setScale(G_VisibleSizeWidth/lineSp1:getContentSize().width)
				lineSp1:setPosition(ccp(G_VisibleSizeWidth/2,360+returnTitle:getContentSize().height/2+5))
				self.childLayer:addChild(lineSp1)
				local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
				lineSp2:setScale(G_VisibleSizeWidth/lineSp2:getContentSize().width)
				lineSp2:setPosition(ccp(G_VisibleSizeWidth/2,360-returnTitle:getContentSize().height/2-5))
				self.childLayer:addChild(lineSp2)
			
				local rewardTb=FormatItem(itemTb,false,true)
				if rewardTb and SizeOfTable(rewardTb)>0 then
					local tbSize=SizeOfTable(rewardTb)
					local posTb=G_getIconSequencePosx(2,105,self.childLayer:getContentSize().width/2,tbSize)
					for k,v in pairs(rewardTb) do
						local px,py=0,260
						if posTb and posTb[k] then
							px=posTb[k] or 0
						end
						local icon=G_getItemIcon(v,100,true,self.layerNum+1)
						icon:setTouchPriority(-(self.layerNum-1)*20-6)
						icon:setPosition(ccp(px,py))
						self.childLayer:addChild(icon)
						local numStr=v.num
						-- if v.type=="u" then
							numStr=FormatNumber(numStr)
						-- end
						local numLb=GetTTFLabel(numStr,25)
						numLb:setPosition(ccp(px,py-65))
						self.childLayer:addChild(numLb)
					end
				end
				local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")
				lineSp3:setScale(G_VisibleSizeWidth/lineSp3:getContentSize().width)
				lineSp3:setPosition(ccp(G_VisibleSizeWidth/2,160))
				self.childLayer:addChild(lineSp3)
			end
		end
		local posCfg,iconSc
		-- if SizeOfTable(item)==1 and item[1].num==1 then
			posCfg = {{G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+50}}
			iconSc= 1.2
		-- else
		-- 	posCfg = {
		-- 	{G_VisibleSizeWidth/2 - 200,G_VisibleSizeHeight/2 + 100 + 30},
		-- 	{G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+250 + 30},
		-- 	{G_VisibleSizeWidth/2 + 200,G_VisibleSizeHeight/2+100 + 30},
		-- 	{G_VisibleSizeWidth/2-130,G_VisibleSizeHeight/2-120 + 30},
		-- 	{G_VisibleSizeWidth/2+130,G_VisibleSizeHeight/2-120 + 30}
		-- 	}
		-- 	iconSc= 1.2
		-- end

		local index = 1
		local equipIdTb = {}

		local accRank=0
		if self.rankLb then
			local lbStr=self.rankLb:getString()
			if lbStr and lbStr~="" and tonumber(lbStr) then
				accRank=tonumber(lbStr)
			end
		end
		local function showItemInfo(tag)
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			-- local eVo=emblemVoApi:getEquipVoByID(equipIdTb[tag])
			-- if(eVo)then
			-- 	emblemVoApi:showInfoDialog(eVo,layerNum + 1)
			-- end
			local aVo=accessoryVo:new()
			aVo:initWithData({self.destID,0,0})
			aVo.rank=accRank
			self:showAccessoryInfo(aVo,true)
		end
		-- for k,v in pairs(item) do
		-- 	for i=1,v.num do
				local mIcon=accessoryVoApi:getAccessoryIcon(self.destID,70,100,showItemInfo)
				-- if v.type == "se" then
				-- 	mIcon=emblemVoApi:getEquipIconNoBg(v.key,strSize2,nil,showItemInfo)
					mIcon:setTouchPriority(-(layerNum-1)*20-5)
				-- 	table.insert(equipIdTb,v.key)
				-- end
				mIcon:setTag(index)
				if mIcon then
					local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
					local rankLb=GetTTFLabel(accRank,30)
					rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
					rankTip:addChild(rankLb)
					rankTip:setScale(0.5)
					rankTip:setAnchorPoint(ccp(0,1))
					rankTip:setPosition(ccp(0,100))
					mIcon:addChild(rankTip)
					local lvLb=GetTTFLabel(getlocal("fightLevel",{0}),20)
					lvLb:setAnchorPoint(ccp(1,0))
					lvLb:setPosition(ccp(85,5))
					mIcon:addChild(lvLb)

					mIcon:setScale(0)
					mIcon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
					self.childLayer:addChild(mIcon,20+index)
					local ccMoveTo = CCMoveTo:create(0.2,CCPointMake(posCfg[index][1],posCfg[index][2]))
					local ccScaleTo = CCScaleTo:create(0.2,iconSc)
					local callFunc3=CCCallFuncN:create(callback31)
					local moveAndScaleArr=CCArray:create()
					moveAndScaleArr:addObject(ccMoveTo)
					moveAndScaleArr:addObject(ccScaleTo)
					local moveAndScaleSpawn=CCSpawn:create(moveAndScaleArr)
					local function addParticle(icon)
						local tag = icon:getTag()
						local aVo3=accessoryVo:new()
						aVo3:initWithData({self.destID,0,0})
						local quality=tonumber(aVo3:getConfigData("quality"))
						showBgParticle(self.childLayer,ccp(icon:getPosition()),quality,10+tag)
					end
					local callFunParticle = CCCallFuncN:create(addParticle)
					local iconAcArr=CCArray:create()
					iconAcArr:addObject(moveAndScaleSpawn)
					iconAcArr:addObject(callFunParticle)
					index = index + 1
					if index > SizeOfTable(posCfg) then
						index = 1
						iconAcArr:addObject(callFunc3)
					end  
					local seq=CCSequence:create(iconAcArr)
					mIcon:runAction(seq)
				end
		-- 	end
		-- end
		
	end
	local callFunc3=CCCallFunc:create(callback3)
	local delay = CCDelayTime:create(0.5)
	acArr:addObject(callFunc1)
	acArr:addObject(delay)
	acArr:addObject(callFunc2)
	acArr:addObject(callFunc3)
	local seq=CCSequence:create(acArr)
	self.rewardLayer:runAction(seq)

end

function accessoryEvolutionDialog:clearChildLayer()
	if self.addParticleTb then
		for k,v in pairs(self.addParticleTb) do
			if v and v.parent then
				v:removeFromParentAndCleanup(true)
				v = nil
			end	
		end
		self.addParticleTb = nil
	end
	
	if self.childLayer then
		self.childLayer:removeAllChildrenWithCleanup(true)
		self.childLayer:removeFromParentAndCleanup(true)
		self.childLayer = nil
	end
end

function accessoryEvolutionDialog:disposeRewardLayer()
	if self.addParticleTb then
		for k,v in pairs(self.addParticleTb) do
			if v and v.parent then
				v:removeFromParentAndCleanup(true)
				v = nil
			end	
		end
		self.addParticleTb = nil
	end
	if self.childLayer then
		self.childLayer:removeAllChildrenWithCleanup(true)
		self.childLayer:removeFromParentAndCleanup(true)
		self.childLayer = nil
	end
	if self.rewardLayer then
		self.rewardLayer:removeAllChildrenWithCleanup(true)				   
		self.rewardLayer:removeFromParentAndCleanup(true)
		self.rewardLayer = nil
	end
	self.getTimeTick = nil
end

function accessoryEvolutionDialog:dispose()
	self:disposeRewardLayer()
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/hero/heroequip/equipBigBg.jpg")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBlackBg.jpg")
	self.mvTb=nil
	self.retTb=nil
end