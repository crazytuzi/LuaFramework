--2017四周年周年庆典活动, 福利页签
--author: Liang Qi
acAnniversaryFourTabWelfare={}

function acAnniversaryFourTabWelfare:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.bgLayer=nil
	return nc
end

function acAnniversaryFourTabWelfare:init(acVo,layerNum)
	self.acVo=acVo
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initBackground()
	self:initPage()
	self:initAchievements()
	return self.bgLayer
end

function acAnniversaryFourTabWelfare:initBackground()
	local bg1=CCSprite:createWithSpriteFrameName("openyear_fire.png")
	bg1:setFlipX(true)
	bg1:setAnchorPoint(ccp(0.5,1))
	bg1:setPosition(20 + bg1:getContentSize().width/2,G_VisibleSizeHeight - 180)
	self.bgLayer:addChild(bg1)
	local bg2=CCSprite:createWithSpriteFrameName("openyear_fire.png")
	bg2:setAnchorPoint(ccp(0.5,1))
	bg2:setPosition(G_VisibleSizeWidth - 20 - bg2:getContentSize().width/2,G_VisibleSizeHeight - 180)
	self.bgLayer:addChild(bg2)
	self.timeLb=GetTTFLabel(getlocal("activityCountdown")..": "..G_formatActiveDate(self.acVo.et - base.serverTime),23)
	self.timeLb:setColor(G_ColorYellowPro)
	self.timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 200))
	self.bgLayer:addChild(self.timeLb)
	self:updateAcTime()
	local descLb=GetTTFLabelWrap(getlocal("activity_znqd2017_desc"),23,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0.5,1))
	descLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 220)
	self.bgLayer:addChild(descLb)
	local function touchTip()
		local tabStr={getlocal("activity_znqd2017_info1",{self.acVo.limitLv}),getlocal("activity_znqd2017_info2"),getlocal("activity_znqd2017_info3"),getlocal("activity_znqd2017_info4")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 195),{},nil,nil,28,touchTip,true)
end

function acAnniversaryFourTabWelfare:updateAcTime()
	if self.acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
		self.timeLb:setString(getlocal("activityCountdown")..": "..G_formatActiveDate(self.acVo.et - base.serverTime))
	end
end

function acAnniversaryFourTabWelfare:initPage()
	self.pageLayer=CCLayer:create()
	self.pageTouchArr={}
	local function onSlidePage( ... )
		if(self.pageAction~=true)then
			return self:slidePage(...)
		end
	end
	self.pageLayer:registerScriptTouchHandler(onSlidePage,false,-(self.layerNum-1)*20-3,false)
	self.pageLayer:setTouchEnabled(true)
	self.pageLayer:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(self.pageLayer)
	local pageSize
	if(G_isIphone5())then
		pageSize=CCSizeMake(G_VisibleSizeWidth - 40,400)
	else
		pageSize=CCSizeMake(G_VisibleSizeWidth - 40,350)
	end
	local pageBg=LuaCCScale9Sprite:createWithSpriteFrameName("acZnqd2017Border.png",CCRect(3,3,1,1),function ( ... )end)
	pageBg:setTag(1)
	pageBg:setContentSize(pageSize)
	pageBg:setAnchorPoint(ccp(0.5,1))
	pageBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 280)
	self.pageLayer:addChild(pageBg)
	local function onLoadImage(fn,image)
		if(self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") and pageBg)then
			image:setPosition(pageSize.width/2,pageSize.height/2)
			pageBg:addChild(image)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/znqd2017/anniversary2017Bg3.png"),onLoadImage)
	if(playerVoApi:getPlayerLevel()<self.acVo.limitLv)then
		local image=CCSprite:createWithSpriteFrameName("threeyear_icon.png")
		if(G_isIphone5())then
			image:setScale(0.9)
		else
			image:setScale(0.8)
		end
		image:setAnchorPoint(ccp(0.5,1))
		image:setPosition(pageSize.width/2,pageSize.height - 20)
		pageBg:addChild(image)
		local descLb=GetTTFLabelWrap(getlocal("activity_ganenjiehuikui_level",{self.acVo.limitLv}),25,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		descLb:setColor(G_ColorYellowPro)
		descLb:setAnchorPoint(ccp(0.5,0))
		descLb:setPosition(pageSize.width/2,80)
		pageBg:addChild(descLb,1)
		local function callback()
			PlayEffect(audioCfg.mouseClick)
			activityAndNoteDialog:closeAllDialog()
			playerVoApi:showPlayerDialog(3,3)
		end
		local becomeStrongItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callback,nil,getlocal("activity_zhanyoujijie_level_up"),24)
		becomeStrongItem:setScale(0.8)
		local becomeStrongMenu=CCMenu:createWithItem(becomeStrongItem)
		becomeStrongMenu:setPosition(pageSize.width/2,45)
		becomeStrongMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		pageBg:addChild(becomeStrongMenu,1)
		G_addRectFlicker(becomeStrongItem,3)
		do return end
	end
	self.experienceList=acAnniversaryFourVoApi:getAllExperience()
	self.pageBtnTb={}
	self.pageBtnCfgTb={}
	for k,v in pairs(self.experienceList) do
		if(acAnniversaryFourVoApi:checkCanGetExperienceReward(v))then
			self.curExperiencePage=k
			break
		end
	end
	if(self.curExperiencePage==nil)then
		self.curExperiencePage=#self.experienceList
	end
	local pageNum=#self.experienceList
	local angleOffset=2*math.pi/pageNum		--偏移角度
	local centerPos
	if(G_isIphone5())then
		centerPos=ccp(pageSize.width/2,300)
	else
		centerPos=ccp(pageSize.width/2,260)
	end
	local btnRound=CCSprite:createWithSpriteFrameName("acZnqd2017Sp2.png")
	btnRound:setPosition(centerPos)
	pageBg:addChild(btnRound,1)
	local r=btnRound:getContentSize().width/2 - 30 	--半径
	local minScale=0.4
	local minColor=80
	local offsetIndex=self.curExperiencePage
	for i=1,pageNum do
		local angle=angleOffset*(i - 1)
		local relativeX=math.sin(angle)*r 		--相对于圆心的x
		local relativeY=-math.cos(angle)*r 		--相对于圆心的y
		local distance=r + relativeY			--翻倒后距离屏幕的距离
		relativeY=relativeY*0.2 				--由于圆是压扁的，所以y坐标做了一个压缩
		local absolutePos=ccp(centerPos.x + relativeX,centerPos.y + relativeY)
		local scale=1 - (1 - minScale)*(distance/r/2)
		local color=255 - (255 - minColor)*(distance/r/2)
		self.pageBtnCfgTb[i]={absolutePos,scale,color}
		local realIndex=self.experienceList[offsetIndex]
		local btn=CCSprite:createWithSpriteFrameName("acZnqd2017Sp1.png")
		btn:setAnchorPoint(ccp(0.5,0))
		btn:setScale(scale)
		btn:setColor(ccc3(color,color,color))
		btn:setPosition(absolutePos)
		pageBg:addChild(btn,1)
		self.pageBtnTb[i]=btn
		local icon1=CCSprite:createWithSpriteFrameName("acZnqd2017Func"..realIndex.."0.png")
		icon1:setTag(1)
		icon1:setPosition(btn:getContentSize().width/2,60)
		btn:addChild(icon1)
		local icon2=CCSprite:createWithSpriteFrameName("acZnqd2017Func"..realIndex.."1.png")
		icon2:setTag(2)
		icon2:setPosition(btn:getContentSize().width/2,60)
		btn:addChild(icon2)
		if(offsetIndex==self.curExperiencePage)then
			icon2:setVisible(false)
		else
			icon1:setVisible(false)
			icon2:setColor(ccc3(color,color,color))
		end
		offsetIndex=offsetIndex + 1
		if(offsetIndex>pageNum)then
			offsetIndex=1
		end
	end
	local function onSwithPage(object,fn,tag)
		if(self.pageAction~=true)then
			if(tag==10)then
				self:switchPage(-1)
			elseif(tag==11)then
				self:switchPage(1)
			end
		end
	end
	local leftBtn=LuaCCSprite:createWithSpriteFrameName("ArrowYellow.png",onSwithPage)
	leftBtn:setTag(10)
	leftBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	leftBtn:setFlipX(true)
	leftBtn:setPosition(30,pageSize.height/2)
	pageBg:addChild(leftBtn)
	local mvTo=CCMoveTo:create(0.5,ccp(30,pageSize.height/2))
	local fadeIn=CCFadeTo:create(0.5,255)
	local carray=CCArray:create()
	carray:addObject(mvTo)
	carray:addObject(fadeIn)
	local spawn=CCSpawn:create(carray)
	local mvTo2=CCMoveTo:create(0.5,ccp(50,pageSize.height/2))
	local fadeOut=CCFadeTo:create(0.5,150)
	local carray2=CCArray:create()
	carray2:addObject(mvTo2)
	carray2:addObject(fadeOut)
	local spawn2=CCSpawn:create(carray2)
	local seq=CCSequence:createWithTwoActions(spawn2,spawn)
	leftBtn:runAction(CCRepeatForever:create(seq))
	local rightBtn=LuaCCSprite:createWithSpriteFrameName("ArrowYellow.png",onSwithPage)
	rightBtn:setTag(11)
	rightBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	rightBtn:setPosition(pageSize.width - 30,pageSize.height/2)
	pageBg:addChild(rightBtn)
	local mvTo=CCMoveTo:create(0.5,ccp(pageSize.width - 30,pageSize.height/2))
	local fadeIn=CCFadeTo:create(0.5,255)
	local carray=CCArray:create()
	carray:addObject(mvTo)
	carray:addObject(fadeIn)
	local spawn=CCSpawn:create(carray)
	local mvTo2=CCMoveTo:create(0.5,ccp(pageSize.width - 50,pageSize.height/2))
	local fadeOut=CCFadeTo:create(0.5,150)
	local carray2=CCArray:create()
	carray2:addObject(mvTo2)
	carray2:addObject(fadeOut)
	local spawn2=CCSpawn:create(carray2)
	local seq=CCSequence:createWithTwoActions(spawn2,spawn)
	rightBtn:runAction(CCRepeatForever:create(seq))
	self:refreshPageContent()
end

function acAnniversaryFourTabWelfare:slidePage(fn,x,y,touch)
	if fn=="began" then
		if(self.pageLayer==nil or tolua.cast(self.pageLayer,"CCLayer")==nil)then
			return 0
		end
		local pageBg=tolua.cast(self.pageLayer:getChildByTag(1),"CCScale9Sprite")
		local minX,minY,maxX,maxY=pageBg:getPositionX() - pageBg:getContentSize().width/2,pageBg:getPositionY() - pageBg:getContentSize().height,pageBg:getPositionX() + pageBg:getContentSize().width/2,pageBg:getPositionY()
		if touch then
			local curTouchPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
			if curTouchPos.x<minX or curTouchPos.x>maxX or curTouchPos.y<minY or curTouchPos.y>maxY then
				return 0
			end
		end
		self.pageTouchArr[touch]=touch
		local touchIndex=0
		for k,v in pairs(self.pageTouchArr) do
			local temTouch= tolua.cast(v,"CCTouch")
			if self and temTouch then
				if touchIndex==0 then
					self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
				else
					self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
				end
			end
			touchIndex=touchIndex+1
		end
		if touchIndex==1 then
			self.secondOldPos=nil
			self.lastTouchDownPoint=self.firstOldPos
		end
		if SizeOfTable(self.pageTouchArr)>1 then
			self.multTouch=true
		else
			self.multTouch=false
		end
		return 1
	elseif fn=="moved" then
	elseif fn=="ended" then
		if(self.pageLayer==nil or tolua.cast(self.pageLayer,"CCLayer")==nil)then
			return 0
		end
		if self.pageTouchArr[touch]~=nil then
			self.pageTouchArr[touch]=nil
			local touchIndex=0
			for k,v in pairs(self.pageTouchArr) do
				local temTouch= tolua.cast(v,"CCTouch")
				if self and temTouch then
					if touchIndex==0 then
						self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
					else
						self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
					end
				end
				touchIndex=touchIndex+1
			end
			if touchIndex==1 then
				self.secondOldPos=nil
			end
			if SizeOfTable(self.pageTouchArr)>1 then
				self.multTouch=true
			else
				self.multTouch=false
			end
		end
		if self.multTouch==true then --双点触摸
		else --单点触摸
			local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
			local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
			if moveDisTmp.x>50 then
				self:switchPage(-1)
			elseif moveDisTmp.x<-50 then
				self:switchPage(1)
			end
		end
	else
		self.pageTouchArr=nil
		self.pageTouchArr={}
	end
end

function acAnniversaryFourTabWelfare:switchPage(space)
	if(self.pageLayer==nil or tolua.cast(self.pageLayer,"CCLayer")==nil or self.pageBtnTb==nil)then
		do return end
	end
	self.pageAction=true
	local totalPage=#self.pageBtnTb
	for k,v in pairs(self.pageBtnTb) do
		v:stopAllActions()
	end
	for i=1,totalPage do
		local btn=self.pageBtnTb[i]
		local pos,scale,color=self.pageBtnCfgTb[i][1],self.pageBtnCfgTb[i][2],self.pageBtnCfgTb[i][3]
		btn:setPosition(pos)
		btn:setScale(scale)
		btn:setColor(ccc3(color,color,color))
		local icon1=tolua.cast(btn:getChildByTag(1),"CCSprite")
		local icon2=tolua.cast(btn:getChildByTag(2),"CCSprite")
		icon2:setColor(ccc3(color,color,color))
		if(i==1)then
			icon1:setVisible(true)
			icon2:setVisible(false)
		else
			icon1:setVisible(false)
			icon2:setVisible(true)
		end
	end
	local actionIndex=0
	local iOffset
	if(space>0)then
		iOffset=-1
	else
		iOffset=1
	end
	for k,v in pairs(self.pageBtnTb) do
		local endIndex=k - space
		if(endIndex>totalPage)then
			endIndex=1
		elseif(endIndex<1)then
			endIndex=totalPage
		end
		local pos,scale,color=self.pageBtnCfgTb[endIndex][1],self.pageBtnCfgTb[endIndex][2],self.pageBtnCfgTb[endIndex][3]
		local icon1=tolua.cast(v:getChildByTag(1),"CCSprite")
		local icon2=tolua.cast(v:getChildByTag(2),"CCSprite")
		local actionArr=CCArray:create()
		for i=0,space,-iOffset do
			if(i==space)then
				break
			end
			local j=k + iOffset
			if(j>totalPage)then
				j=1
			elseif(j<1)then
				j=totalPage
			end
			local targetPos,targetScale,targetColor=self.pageBtnCfgTb[j][1],self.pageBtnCfgTb[j][2],self.pageBtnCfgTb[j][3]
			local moveTo=CCMoveTo:create(0.3,targetPos)
			local scaleTo=CCScaleTo:create(0.3,targetScale)
			local tintTo=CCTintTo:create(0.3,targetColor,targetColor,targetColor)
			local actionArr1=CCArray:create()
			actionArr1:addObject(moveTo)
			actionArr1:addObject(scaleTo)
			actionArr1:addObject(tintTo)
			local spawn=CCSpawn:create(actionArr1)
			actionArr:addObject(spawn)
		end
		local function onActionEnd()
			icon2:setColor(ccc3(color,color,color))
			if(endIndex==1)then
				icon1:setVisible(true)
				icon2:setVisible(false)
			else
				icon1:setVisible(false)
				icon2:setVisible(true)
			end
			actionIndex=actionIndex + 1
			if(actionIndex>=totalPage)then
				if(space>0)then
					for i=1,space do
						table.insert(self.pageBtnTb,self.pageBtnTb[1])
						table.remove(self.pageBtnTb,1)
					end
				else
					for i=-1,space,-1 do
						local lastBtn=self.pageBtnTb[totalPage]
						table.insert(self.pageBtnTb,1,lastBtn)
						table.remove(self.pageBtnTb,totalPage + 1)
					end
				end
				self.pageAction=false
				self.curExperiencePage=self.curExperiencePage + space
				if(self.curExperiencePage<1)then
					self.curExperiencePage=totalPage
				elseif(self.curExperiencePage>totalPage)then
					self.curExperiencePage=1
				end
				self:refreshPageContent()
			end
		end
		local callFunc=CCCallFunc:create(onActionEnd)
		actionArr:addObject(callFunc)
		local seq=CCSequence:create(actionArr)
		v:runAction(seq)
	end
end

function acAnniversaryFourTabWelfare:refreshPageContent()
	if(self.pageLayer==nil or tolua.cast(self.pageLayer,"CCLayer")==nil)then
		do return end
	end
	local pageBg=tolua.cast(self.pageLayer:getChildByTag(1),"CCScale9Sprite")
	if(pageBg==nil)then
		do return end
	end
	pageBg:removeChildByTag(1,true)
	local tmpBg=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
	tmpBg:setTag(1)
	tmpBg:setAnchorPoint(ccp(0,0))
	tmpBg:setPosition(0,0)
	tmpBg:setOpacity(0)
	pageBg:addChild(tmpBg,1)
	local pageSize=pageBg:getContentSize()
	local bgPosY=pageSize.height/2
	local rewardIndex=self.experienceList[self.curExperiencePage]
	local rewardData
	local rewardCfg=acAnniversaryFourVoApi:getExperienceRewardCfg(rewardIndex)
	local function callback(percent,strength)
		if(self.bgLayer==nil or self.pageLayer==nil or tolua.cast(self.pageLayer,"CCLayer")==nil or tolua.cast(tmpBg,"CCSprite")==nil)then
			return
		end
		local cfg=FormatItem(rewardCfg)
		local count=#cfg
		local space=(pageSize.width - 130)/5
		local startX=pageSize.width/2 - space*(count - 1)/2
		for k,v in pairs(cfg) do
			local function showNewReward()
				G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
				return false
			end
			local icon=G_getItemIcon(v,80,true,self.layerNum,showNewReward)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setPosition(startX + space*(k - 1),bgPosY)
			tmpBg:addChild(icon)
			local numLb=GetTTFLabel("×"..v.num,22)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width - 5,5)
			icon:addChild(numLb)
		end
		local rewardItem
		local function onGetReward()
			PlayEffect(audioCfg.mouseClick)
			local function callback()
				if(rewardItem and tolua.cast(rewardItem,"CCMenuItemSprite"))then
					rewardItem:setEnabled(false)
					local lb=tolua.cast(rewardItem:getChildByTag(101),"CCLabelTTF")
					if(lb)then
						lb:setString(getlocal("activity_hadReward"))
					end
				end
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)
			end
			acAnniversaryFourVoApi:getReward(1,rewardIndex,callback)
		end
		local enabled,btnStr
		if(acAnniversaryFourVoApi:checkCanGetExperienceReward(rewardIndex)==false)then
			enabled=false
			btnStr=getlocal("activity_hadReward")
		else
			enabled=true
			btnStr=getlocal("daily_scene_get")
		end
		rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onGetReward,nil,btnStr,32,101)
		rewardItem:setScale(0.6)
		rewardItem:setEnabled(enabled)
		local rewardMenu=CCMenu:createWithItem(rewardItem)
		rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		rewardMenu:setPosition(pageSize.width/2,bgPosY - 80)
		tmpBg:addChild(rewardMenu)

		local strSize3 = 20
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
			strSize3 = 23
		end

		local desc=acAnniversaryFourVoApi:getExperienceStr(rewardIndex,strength,percent)
		local descLb=GetTTFLabelWrap(desc,strSize3,CCSizeMake(G_VisibleSizeWidth - 130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0.5,1))
		descLb:setPosition(pageSize.width/2 - 30,bgPosY - 110)
		tmpBg:addChild(descLb)
		local function onSendChat()
			if(self.lastChat==nil or base.serverTime>=self.lastChat + 5)then
				self.lastChat=base.serverTime
				local params={subType=1,contentType=2,message=acAnniversaryFourVoApi:getChatMessage(rewardIndex,strength,percent),level=playerVoApi:getPlayerLevel(),rank=playerVoApi:getRank(),power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=G_getCurChoseLanguage(),st=base.serverTime,title=playerVoApi:getTitle(),brType=10}
				chatVoApi:sendChatMessage(1,playerVoApi:getUid(),playerVoApi:getPlayerName(),0,"",params)
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_anniversary_sendChat"),30)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("time_limit_prompt",{self.lastChat + 5 - base.serverTime}),30)
			end
		end
		local sendChatItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onSendChat)
		sendChatItem:setScale(1.2)
		local sendChatBtn=CCMenu:createWithItem(sendChatItem)
		sendChatBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		sendChatBtn:setPosition(pageSize.width - 30,bgPosY - 130)
		tmpBg:addChild(sendChatBtn)
	end
	rewardData=acAnniversaryFourVoApi:checkGetExperienceData(rewardIndex,callback)
end

function acAnniversaryFourTabWelfare:initAchievements()
	local achieveSize
	if(G_isIphone5())then
		achieveSize=CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 700)
	else
		achieveSize=CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 650)
	end
	local achiveBg=LuaCCScale9Sprite:createWithSpriteFrameName("acZnqd2017Border.png",CCRect(3,3,1,1),function ( ... )end)
	achiveBg:setContentSize(achieveSize)
	achiveBg:setAnchorPoint(ccp(0,0))
	achiveBg:setPosition(20,10)
	self.bgLayer:addChild(achiveBg)
	local function onLoadImage(fn,image)
		if(self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") and achiveBg)then
			if(G_isIphone5())then
				image:setPosition(achieveSize.width/2,achieveSize.height/2 + 50)
			else
				image:setPosition(achieveSize.width/2,achieveSize.height/2)
			end
			achiveBg:addChild(image)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/znqd2017/anniversary2017Bg3.png"),onLoadImage)
	local titleBg=CCSprite:createWithSpriteFrameName("orangeMask.png")
	titleBg:setScaleY(1.1)
	titleBg:setPosition(achieveSize.width/2,achieveSize.height - 25)
	achiveBg:addChild(titleBg,1)
	local titleLb=GetTTFLabel(getlocal("google_achievement"),28,true)
	titleLb:setPosition(achieveSize.width/2,achieveSize.height - 25)
	achiveBg:addChild(titleLb,1)
	self.achievementList=acAnniversaryFourVoApi:getAllAchievements()
	local count=#self.achievementList
	local space=achieveSize.width/count
	local function onClickBox(object,fn,tag)
		if(tag)then
			local rewardCfg=acAnniversaryFourVoApi:getAchievementRewardCfg(tag)
			local formatCfg=FormatItem(rewardCfg)
			if(#formatCfg>1)then
				require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
				local sd = acChunjiepanshengSmallDialog:new()
				local desStr=getlocal("award")
				sd:init(true,true,self.layerNum+1,desStr,"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),formatCfg)
			else
				G_showNewPropInfo(self.layerNum+1,true,true,nil,formatCfg[1])
			end
		end
	end
	self.achievementBtnList={}
	local function onGetReward(tag,object)
		PlayEffect(audioCfg.mouseClick)
		local rewardIndex=tonumber(tag)
		if(rewardIndex)then
			local function callback()
				local rewardItem=self.achievementBtnList[rewardIndex]
				if(rewardItem and tolua.cast(rewardItem,"CCMenuItemSprite"))then
					rewardItem:setEnabled(false)
					local lb=tolua.cast(rewardItem:getChildByTag(101),"CCLabelTTF")
					if(lb)then
						lb:setString(getlocal("activity_hadReward"))
					end
				end
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)
			end
			acAnniversaryFourVoApi:getReward(2,rewardIndex,callback)
		end
	end
	local strSize2 = 16
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize2 = 22
	end
	for k,v in pairs(self.achievementList) do
		local iconBg=LuaCCSprite:createWithSpriteFrameName("acZnqd2017Bg1.png",onClickBox)
		iconBg:setTag(v)
		iconBg:setTouchPriority(-(self.layerNum-1)*20-2)
		iconBg:setPosition(space*(k - 0.5),achieveSize.height/2 + 50)
		achiveBg:addChild(iconBg,1)
		local icon
		local rewardCfg=acAnniversaryFourVoApi:getAchievementRewardCfg(v)
		local formatCfg=FormatItem(rewardCfg)
		if(#formatCfg>1)then
			icon=CCSprite:createWithSpriteFrameName("friendBtn.png")
		else
			icon=G_getItemIcon(formatCfg[1],100)
		end
		icon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2)
		iconBg:addChild(icon)
		local status=acAnniversaryFourVoApi:checkCanGetAchievementReward(v)
		local btnStr,enabled
		if(status==0)then
			btnStr=getlocal("noReached")
			enabled=false
		elseif(status==1)then
			btnStr=getlocal("daily_scene_get")
			enabled=true
		else
			btnStr=getlocal("activity_hadReward")
			enabled=false
		end
		local menuItem=GetButtonItem("acZnqd2017Btn.png","acZnqd2017Btn_down.png","acZnqd2017Btn_disable.png",onGetReward,v,btnStr,strSize2,101)
		menuItem:setScale(1.1)
		menuItem:setEnabled(enabled)
		self.achievementBtnList[v]=menuItem
		local rewardMenu=CCMenu:createWithItem(menuItem)
		rewardMenu:setTouchPriority(-(self.layerNum-1)*20-3)
		rewardMenu:setPosition(space*(k - 0.5),achieveSize.height/2 - 54)
		achiveBg:addChild(rewardMenu,1)
		local descLb=GetTTFLabelWrap(acAnniversaryFourVoApi:getAchievementDesc(v),22,CCSizeMake(iconBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0.5,1))
		descLb:setPosition(space*(k - 0.5),achieveSize.height/2 - 80)
		achiveBg:addChild(descLb)
		if(G_isIphone5()==false)then
			iconBg:setScale(0.9)
			iconBg:setPosition(space*(k - 0.5),achieveSize.height/2 + 20)
			rewardMenu:setPositionY(achieveSize.height/2 - 60)
			descLb:setPositionY(achieveSize.height/2 - 90)
		end
	end
end

function acAnniversaryFourTabWelfare:tick()
	self:updateAcTime()
end

function acAnniversaryFourTabWelfare:dispose()
	self.curExperiencePage=nil
	self.achievementBtnList=nil
	self.pageAction=false
	self.pageTouchArr=nil
	self.pageLayer=nil
	self.pageBtnTb=nil
	self.bgLayer=nil
end