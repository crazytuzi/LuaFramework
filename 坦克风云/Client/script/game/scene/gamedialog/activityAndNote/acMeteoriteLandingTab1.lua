acMeteoriteLandingTab1={}

function acMeteoriteLandingTab1:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil
	self.oneOrMul=nil
	self.costGoldLb=nil
	self.goldSp=nil
	self.collect=nil
	self.ShowWidth=600
	self.ShowHeight=G_VisibleSize.height-160
	self.flag = true
	 CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acMeteoriteLanding.plist")
	return nc
end

function acMeteoriteLandingTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum =layerNum
	self:initUpShow(self.layerNum)
	self:initDownShow(self.layerNum)
	return self.bgLayer
end

function acMeteoriteLandingTab1:initUpShow( layerNum )

	local bgSp = CCSprite:create("public/acMeteoriteLanding_3.jpg")
	bgSp:setAnchorPoint(ccp(0.5,1))
	bgSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.ShowHeight))
	self.bgLayer:addChild(bgSp)
	bgSp:setScale(0.97)

	if(G_isIphone5())then
		bgSp:setScaleY(1.15)
	end

	local function nilFunc( )

		
	end 
	local maybeBorder = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),nilFunc);
	maybeBorder:setContentSize(CCSizeMake(self.ShowWidth-4,self.ShowHeight*0.3))
	maybeBorder:setAnchorPoint(ccp(0.5,1))
	maybeBorder:setOpacity(180)
	maybeBorder:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.ShowHeight))
	self.bgLayer:addChild(maybeBorder,1);


	local upLb = getlocal("activity_meteoriteLanding_Tab1Lb")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(maybeBorder:getContentSize().width*0.8, 160),upLb,25,kCCTextAlignmentLeft)
	maybeBorder:addChild(desTv)
	desTv:setPosition(ccp(maybeBorder:getContentSize().width*0.1,20))
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(130)
	self.descLb=desLabel


   local timeSize = 23
   local timeShowWidth = 0
   local rewardHeightloc =0
   local needPosWIdht = 0
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage()=="ru" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        timeSize =20
        timeShowWidth =30
        needPosWIdht = -20
        rewardHeightloc =-15
   end
    local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
    timeTitle:setAnchorPoint(ccp(0,1))
	timeTitle:setPosition(ccp(110+needPosWIdht, maybeBorder:getContentSize().height-20))
	maybeBorder:addChild(timeTitle)
	timeTitle:setColor(G_ColorGreen)



  local timeLabel = GetTTFLabelWrap(acMeteoriteLandingVoApi:getTimeStr(),timeSize,CCSizeMake(maybeBorder:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  timeLabel:setAnchorPoint(ccp(0.5,1))
  timeLabel:setPosition(ccp(maybeBorder:getContentSize().width/2+50+timeShowWidth,maybeBorder:getContentSize().height-20))
  maybeBorder:addChild(timeLabel)

    local rewardTimeTitle = GetTTFLabel(getlocal("recRewardTime"),timeSize)
    rewardTimeTitle:setAnchorPoint(ccp(0,1))
    rewardTimeTitle:setPosition(ccp(110+needPosWIdht, maybeBorder:getContentSize().height-50))
    maybeBorder:addChild(rewardTimeTitle)
    rewardTimeTitle:setColor(G_ColorYellowPro)

    local rechargeTimeLabel = GetTTFLabelWrap(acMeteoriteLandingVoApi:getRewardTimeStr(),timeSize,CCSizeMake(maybeBorder:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rechargeTimeLabel:setAnchorPoint(ccp(0.5,1))
    rechargeTimeLabel:setPosition(ccp(maybeBorder:getContentSize().width/2+50+timeShowWidth,maybeBorder:getContentSize().height-50))
    maybeBorder:addChild(rechargeTimeLabel)
    -- self.descLb2=rechargeTimeLabel

	-- local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
	-- acLabel:setAnchorPoint(ccp(0.5,1))
	-- acLabel:setPosition(ccp((maybeBorder:getContentSize().width - 20)*0.5, maybeBorder:getContentSize().height-10))
	-- maybeBorder:addChild(acLabel)
	-- acLabel:setColor(G_ColorGreen)

	-- local acVo = acMeteoriteLandingVoApi:getAcVo() 					--有接口后需要改过来
	-- local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	-- local messageLabel=GetTTFLabel(timeStr,25)
	-- messageLabel:setAnchorPoint(ccp(0.5,1))
	-- messageLabel:setPosition(ccp((maybeBorder:getContentSize().width - 20)*0.5, maybeBorder:getContentSize().height-40))
	-- maybeBorder:addChild(messageLabel)

	local function tipTouch()
        local sd=smallDialog:new()
        local labelTab={"\n",getlocal("activity_meteoriteLanding_Tab1_tip4"),"\n",getlocal("activity_meteoriteLanding_Tab1_tip3"),"\n",getlocal("activity_meteoriteLanding_Tab1_tip2"),"\n",getlocal("activity_meteoriteLanding_Tab1_tip1"),"\n",}
        local colorTab={nil,nil,nil}
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(580,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,colorTab,nil,true)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    tipItem:setScale(0.8)
    local tipMenu = CCMenu:createWithItem(tipItem)
    tipMenu:setPosition(ccp(maybeBorder:getContentSize().width-50,maybeBorder:getContentSize().height-65))
    tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    maybeBorder:addChild(tipMenu,1)
end

function acMeteoriteLandingTab1:initDownShow(layerNum)
	
	local function bgClick()
		if self.callFunc then
			self.bgLayer:stopAllActions()
			if self.child then
				for k,v in pairs(self.child) do
					self.child[k]:stopAllActions()
					self.child[k]:setScale(1)
				end
			end
			self.callFunc=nil
			self:showReward(self.content,0,self.downBackSprie)
		end
		
	end
	downBackSprie = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),bgClick)
	downBackSprie:setContentSize(CCSizeMake(self.ShowWidth-4,self.ShowHeight*0.7-100))
	downBackSprie:setAnchorPoint(ccp(0.5,1))
	downBackSprie:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.ShowHeight*0.7-2))
	downBackSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(downBackSprie)
	self.downBackSprie=downBackSprie

	local downY = 30
	local upY = downBackSprie:getContentSize().height-50
	local addW=110
	local startW=20
	for i=1,5 do
		local upSp = CCSprite:createWithSpriteFrameName("acMeteoriteLanding_1.png")
		downBackSprie:addChild(upSp)
		upSp:setPosition(startW+(i-1)*addW, upY)
		upSp:setAnchorPoint(ccp(0,1))

		local downSp = CCSprite:createWithSpriteFrameName("acMeteoriteLanding_2.png")
		downBackSprie:addChild(downSp)
		downSp:setPosition(startW+(i-1)*addW, downY)
		downSp:setAnchorPoint(ccp(0,0))
	end

	self.oneOrMul=1

	local function choose()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
       
         PlayEffect(audioCfg.mouseClick)
		local isFree = acMeteoriteLandingVoApi:canReward()
		if isFree then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("isfree"),30)
			return
		end

		if self.oneOrMul==1 then
			self.chooseSp:setVisible(true)
			self.oneOrMul=2
		elseif self.oneOrMul ==2 then 
			self.chooseSp:setVisible(false)
			self.oneOrMul=1
		end

		-- 设置消耗金币颜色
		self:setCostGoldLbCorlor(costGold)
		self:changeGold()

		
	end
	local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",choose)
	checkBox:setTouchPriority(-(self.layerNum-1)*20-4)
	checkBox:setAnchorPoint(ccp(0,0))
	checkBox:setPosition(ccp(30,40))
	self.bgLayer:addChild(checkBox)

	self.chooseSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",choose)
	self.chooseSp:setPosition(getCenterPoint(checkBox))
	checkBox:addChild(self.chooseSp)
	self.chooseSp:setVisible(false)

   local tenSiz = 25
   local tenWidthSiz = 200
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage()=="ru" then
        tenSiz =20
        tenWidthSiz = 300
   end

	local descLb2=GetTTFLabelWrap(getlocal("ten"),tenSiz,CCSizeMake(tenWidthSiz,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb2:setAnchorPoint(ccp(0,0.5))
    descLb2:setColor(G_ColorYellow)
	descLb2:setPosition(ccp(checkBox:getContentSize().width+5,checkBox:getContentSize().height/2))
	checkBox:addChild(descLb2)

	local costGold = acMeteoriteLandingVoApi:getCostGems(1)
	self.costGoldLb = GetTTFLabel(costGold,25)
    self.costGoldLb:setAnchorPoint(ccp(1,0))
    self.costGoldLb:setPosition(downBackSprie:getContentSize().width-250,50)
    self.bgLayer:addChild(self.costGoldLb)

    self.goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    --self.goldSp:setScale(0.3)
    self.goldSp:setAnchorPoint(ccp(0,0.5))
    self.goldSp:setPosition(ccp(self.costGoldLb:getContentSize().width+2,self.costGoldLb:getContentSize().height/2))
    self.costGoldLb:addChild(self.goldSp)

    local isFree = acMeteoriteLandingVoApi:canReward()
    if isFree then
		self:changeGold(0)
	elseif costGold>playerVoApi:getGems() then
    	self.costGoldLb:setColor(G_ColorRed)
  	end

 	local function rechargeCallback( )
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if self.flag then
		else
			return
		end
		PlayEffect(audioCfg.mouseClick)

		local isFree = acMeteoriteLandingVoApi:canReward()
		local costGold
		if isFree then
		else
			if self.oneOrMul==1 then
				costGold=acMeteoriteLandingVoApi:getCostGems(1)
			else
				costGold=acMeteoriteLandingVoApi:getCostGems(10)
			end
			if costGold>playerVoApi:getGems() then
				GemsNotEnoughDialog(nil,nil,costGold-playerVoApi:getGems(),self.layerNum+1,costGold)
				return
			end
		end

		local function callback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if isFree then
					-- 设置时间
					acMeteoriteLandingVoApi:setT(sData.ts)
					self:refresh()
					self:changeGold()
					self.lbOne:setString(getlocal("activity_meteoriteLanding_collect"))
				else
					playerVoApi:setValue("gems",playerVoApi:getGems()-costGold)
				end
				self:setCostGoldLbCorlor()
				self.flag=false

				if sData and sData.data and sData.data.report then
					local report = sData.data.report
					local itemList={}
					local pointList={}
					for k,v in pairs(report) do
						local item = FormatItem(v[1])
						itemList[k] = item[1]
						pointList[k]=v[2]
					end
					self:showAction(itemList,downBackSprie,addW,pointList)
				end
				self:addParticleAction(downBackSprie,addW)

			end
		end

		

		if self.oneOrMul==1 then 
			socketHelper:acMeteoriteLandingChoujiang(0,callback)
		else
			socketHelper:acMeteoriteLandingChoujiang(1,callback)
		end
 		
 		
 	end

    local singleOrMulStr
    local isFree = acMeteoriteLandingVoApi:canReward()
    if isFree then
    	singleOrMulStr =getlocal("daily_lotto_tip_2")
    else
    	singleOrMulStr =getlocal("activity_meteoriteLanding_collect")
    end
	self.collect=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rechargeCallback,nil,singleOrMulStr,25,11)
	self.collect:setAnchorPoint(ccp(1,0))
    local startMenu=CCMenu:createWithItem(self.collect)
    startMenu:setPosition(ccp(downBackSprie:getContentSize().width-10,30))
    startMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(startMenu,1)

	self.lbOne=tolua.cast(self.collect:getChildByTag(11),"CCLabelTTF")

end

function acMeteoriteLandingTab1:showAction(itemList,downBackSprie,addW,pointList)
	local startW=70
	local startH=downBackSprie:getContentSize().height/2
	if self.child==nil then
		self.child={}
	end
	for k,v in pairs(self.child) do
		v:removeFromParentAndCleanup(true)
	end
	self:removeParticleAction()
	if self.shanSp then
		self.shanSp:setVisible(false)
	end
	self.child={}
	for i=1,5 do
		local display1 = CCSprite:createWithSpriteFrameName(itemList[i].pic)
		display1:setPosition(ccp(startW+(i-1)*addW,startH))
		downBackSprie:addChild(display1,5)
		display1:setScale(0)
		self.child[i]=display1
	end

	local content={}
	self.count=0
	for k,v in pairs(itemList) do
		local award = {}
		local point = {}
		local name,num,pic,desc,id,index,eType,equipId=v.name,v.num,v.pic,v.desc,v.id,v.index,v.eType,v.equipId
		if self.oneOrMul==1 then 
			num=num
		else
			num=num*10	
			-- pointList[k]=pointList[k]*10
		end
		local count = 0
		for kk,vv in pairs(itemList) do
			if v.type==vv.type and v.key==vv.key then
				count=count+1
			end
		end
		num=num*acMeteoriteLandingVoApi:getRewardNum(count)
		if self.count<count then
			self.count=count
		end
		award={name=name,num=num,pic=pic,desc=desc,id=id,type=v.type,index=index,key=v.key,eType=eType,equipId=equipId}
		G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true,false)
		table.insert(content,{award=award,point=pointList[k]})
	end

	eventDispatcher:dispatchEvent("MeteoriteLanding.Change",{})

	 

	local function actionCallback1()
		for k,v in pairs(self.child) do
			self.child[k]:setScale(0)
			local scale = CCScaleTo:create(0.5,1)
			local delayAc = CCDelayTime:create(0.3)
			local seq=CCSequence:createWithTwoActions(delayAc,scale)
			self.child[k]:runAction(seq)
		end
		
	end

	self.callFunc=CCCallFunc:create(actionCallback1)
	self.bgLayer:runAction(self.callFunc)

	self.content=content
	self:showReward(content,0.8,downBackSprie)

	
end

function acMeteoriteLandingTab1:showReward(content,time,downBackSprie)
	local function callback()
		if content and SizeOfTable(content)>0 then
		    local function confirmHandler(awardIdx)
		    end
		    smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
		end
		self.callFunc=nil
		if self.count==5 and self.shanSp then 
			-- local message={key="activity_meteoriteLanding_chat",param={playerVoApi:getPlayerName(),getlocal("activity_meteoriteLanding_title"),content[1].award.name}}
			local message={key="activity_meteoriteLanding_chat",param={playerVoApi:getPlayerName(),{key="activity_meteoriteLanding_title",param={}},content[1].award.name}}
			chatVoApi:sendSystemMessage(message)
			self.shanSp:setVisible(true)
		end
		self.flag=true
	end
	
	
	if self.shanSp then
		
	else
		local function nilFunc()
		end
		self.shanSp = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),nilFunc)
		self.shanSp:setContentSize(CCSizeMake(570,120))
		self.shanSp:setPosition(downBackSprie:getContentSize().width/2-5,downBackSprie:getContentSize().height/2)
		downBackSprie:addChild(self.shanSp,6)
		self.shanSp:setVisible(false)
	end
	
	if self.count==5 then
		local delayAc = CCDelayTime:create(time)
		local blink = CCBlink:create(2, 3)
		local seq = CCSequence:createWithTwoActions(delayAc,blink)
		
		self.shanSp:runAction(seq)
		time=time+2
	end
	local callFunc = CCCallFunc:create(callback)
	local delayAc = CCDelayTime:create(time)
	local seq=CCSequence:createWithTwoActions(delayAc,callFunc)
	self.bgLayer:runAction(seq)
	
	
	
end

function acMeteoriteLandingTab1:addParticleAction(downBackSprie,addW)
	local startH=80
	local startW=70
	self.ParticleChild1={}
	for i=1,5 do
		local display1 = CCParticleSystemQuad:create("public/lineFLY.plist")
		display1.positionType=kCCPositionTypeFree
		display1:setPosition(ccp(startW+(i-1)*addW,startH))
		downBackSprie:addChild(display1)
		display1:setScaleX(1.5)
		-- display1:setScale(1.5)
		self.ParticleChild1[i]=display1
	end

	startH=downBackSprie:getContentSize().height-80
	startW=70
	self.ParticleChild2={}
	for i=1,5 do
		local display1 = CCParticleSystemQuad:create("public/lineFLY.plist")
		display1.positionType=kCCPositionTypeFree
		display1:setPosition(ccp(startW+(i-1)*addW,startH))
		downBackSprie:addChild(display1)
		display1:setRotation(180)
		-- display1:setScale(1.5)
		display1:setScaleX(1.5)
		self.ParticleChild2[i]=display1
	end

end

function acMeteoriteLandingTab1:removeParticleAction()
	if self.ParticleChild1==nil then
		self.ParticleChild1={}
	end
	for k,v in pairs(self.ParticleChild1) do
		v:stopAllActions()
		v:removeFromParentAndCleanup(true)
		v=nil
	end
	self.ParticleChild1={}

	if self.ParticleChild2==nil then
		self.ParticleChild2={}
	end
	for k,v in pairs(self.ParticleChild2) do
		v:removeFromParentAndCleanup(true)
		v=nil
	end
	self.ParticleChild2={}
end


function acMeteoriteLandingTab1:setCostGoldLbCorlor()
	local costGold
	if self.oneOrMul==2 then
		costGold = acMeteoriteLandingVoApi:getCostGems(10)
	else
		costGold = acMeteoriteLandingVoApi:getCostGems(1)
	end
	if costGold>playerVoApi:getGems() then
		self.costGoldLb:setColor(G_ColorRed)
	else
		self.costGoldLb:setColor(G_ColorWhite)
	end
end


function acMeteoriteLandingTab1:changeGold(gold)
	local costGold
	if gold then
		costGold=gold
	else
		if self.oneOrMul==2 then
			costGold = acMeteoriteLandingVoApi:getCostGems(10)
		else
			costGold = acMeteoriteLandingVoApi:getCostGems(1)
		end
	end
	self.costGoldLb:setString(costGold)
	self.goldSp:setPosition(ccp(self.costGoldLb:getContentSize().width+2,self.costGoldLb:getContentSize().height/2))
	if tonumber(costGold)==0 then
		self.costGoldLb:setVisible(false)
		self.goldSp:setVisible(false)
	else
		self.costGoldLb:setVisible(true)
		self.goldSp:setVisible(true)
	end
end

function acMeteoriteLandingTab1:refresh( )
   if self and self.bgLayer then
		local isToday = acMeteoriteLandingVoApi:isToday()
	    if isToday then
	    else
	       	self:changeGold(0)
	       	self:setCostGoldLbCorlor()
	        self.lbOne:setString(getlocal("daily_lotto_tip_2"))
			if self.oneOrMul ==2 then 
				self.chooseSp:setVisible(false)
				self.oneOrMul=1
			end
	    end

		if acMeteoriteLandingVoApi:checkCanSearch()==false then
		    self.collect:setEnabled(false)
		end

		if self.descLb then
		    if acMeteoriteLandingVoApi:acIsStop()==true then
		        self.descLb:setString(getlocal("activity_equipSearch_time_end"))
		    end
		end
	end

end

function acMeteoriteLandingTab1:dispose( )
	self.bgLayer=nil
	self.layerNum =nil
	self.oneOrMul =nil
	self.ShowWidth=nil
	self.ShowHeight=nil
	self.costGoldLb=nil
	self.goldSp=nil
	self.collect=nil
	self.descLb=nil
	self.shanSp=nil
	self.ParticleChild2=nil
	self.ParticleChild1=nil
	self.flag = nil
	self.ShowWidth=nil
	self.ShowHeight=nil
	self.downBackSprie=nil
	self.child=nil
	self=nil
	 CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acMeteoriteLanding.plist")
end