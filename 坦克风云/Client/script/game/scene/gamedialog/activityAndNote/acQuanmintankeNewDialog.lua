acQuanmintankeNewDialog=commonDialog:new()

function acQuanmintankeNewDialog:new(parent,layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.parent=parent
	self.layerNum=layerNum
	self.isToday=true
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	return nc
end

function acQuanmintankeNewDialog:initTableView()
	self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
	
end


--用户处理特殊需求
function acQuanmintankeNewDialog:doUserHandler()
	local function onRechargeChange(event,data)
		self:checkCost()
	end
	self.qmtkListener=onRechargeChange
	eventDispatcher:addEventListener("acQuanmintanke.recharge",onRechargeChange)
	local h = G_VisibleSizeHeight - 115
	
	local acLabel = GetTTFLabel(getlocal("activity_timeLabel") .. ": ",25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(acLabel,1)

	local acVo = acQuanmintankeVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,25)
	messageLabel:setAnchorPoint(ccp(0,0.5))
	messageLabel:setPosition(ccp(acLabel:getContentSize().width, acLabel:getContentSize().height/2))
	acLabel:addChild(messageLabel,3)
	self.timeLb=messageLabel
	self:updateAcTime()

	acLabel:setPosition(ccp(G_VisibleSizeWidth/2-messageLabel:getContentSize().width/2, h))

	local function touchInfo()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local tabStr = {"\n",getlocal("activity_quanmintankeNew_tip3"),"\n",getlocal("activity_quanmintankeNew_tip2"),"\n",getlocal("activity_quanmintankeNew_tip1"),"\n"}
		local disCount = acQuanmintankeVoApi:getVipdiscoun()
		if disCount>=2 then
			table.insert(tabStr,1,getlocal("activity_quanmintankeNew_tip4",{"*" .. disCount}))
		elseif disCount==1 then
			 table.insert(tabStr,1,getlocal("activity_quanmintankeNew_tip4",{""}))
		end
		table.insert(tabStr,1,"\n")
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
		sceneGame:addChild(dialog,self.layerNum+1)

		
	end
	local menuItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,1,nil,0)
	menuItem:setAnchorPoint(ccp(1,0.5))
	menuItem:setScale(0.8)
	local menuBtn=CCMenu:createWithItem(menuItem)
	menuBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	menuBtn:setPosition(ccp(self.bgLayer:getContentSize().width-40, h-70))
	self.bgLayer:addChild(menuBtn,2)

	-- alien_tech_special_tank
	local addH=0
	if G_isIphone5() then
		addH=20
	end
	local libaoLb=GetTTFLabelWrap(getlocal("buying_spree"),32,CCSizeMake(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	libaoLb:setAnchorPoint(ccp(0,0.5))
	libaoLb:setPosition(60,h-80-addH)
	self.bgLayer:addChild(libaoLb)

	local sendH = h-80-libaoLb:getContentSize().height/2-addH-10
	local sendLb = GetTTFLabel(getlocal("send"),48)
	sendLb:setColor(G_ColorYellowPro)
	sendLb:setAnchorPoint(ccp(0.5,0))
	sendLb:setPosition(ccp(G_VisibleSizeWidth/2-15,sendH-sendLb:getContentSize().height))
	self.bgLayer:addChild(sendLb,1)

	local tankLb = GetTTFLabelWrap(getlocal("alien_tech_special_tank") .. "!",32,CCSizeMake(230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	tankLb:setAnchorPoint(ccp(0,0))
	tankLb:setPosition(sendLb:getPositionX()+30+sendLb:getContentSize().width/2,sendH-sendLb:getContentSize().height)
	self.bgLayer:addChild(tankLb)

	local desLb=GetTTFLabelWrap(getlocal("activity_quanmintankeNew_des"),28,CCSizeMake(540,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	desLb:setColor(G_ColorYellowPro)
	if G_isIphone5() then
		desLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-70)
	else
		desLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-40)
	end
	
	self.bgLayer:addChild(desLb)


	self.tankTb = acQuanmintankeVoApi:getTankTb()
	local tankNum = SizeOfTable(self.tankTb)

	local startY1 = G_VisibleSizeHeight/2+140
	local startY2 = G_VisibleSizeHeight/2+40
	local startX = 110
	local scale = 0.8
	local intervalTankW=140

	if G_isIphone5() then
		startY1 = G_VisibleSizeHeight/2+160
		startY2 = G_VisibleSizeHeight/2+40
	end

	local function callBack(object,name,tag)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local tankID = tonumber(RemoveFirstChar(self.tankTb[tag]))
        tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
	end

	for i=1,tankNum do
		local bgStr = "expedition_bg1.png"
		local bgSp = LuaCCSprite:createWithSpriteFrameName(bgStr,callBack)
		bgSp:setTag(i)
		bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
		bgSp:setAnchorPoint(ccp(0.5,0.5))
		bgSp:setScale(scale)

		if i<=4 then
			bgSp:setPosition(startX+(i-1)*intervalTankW,startY1)
		else
			bgSp:setPosition(startX+(i-5)*intervalTankW,startY2)
		end
		self.bgLayer:addChild(bgSp)


		local tankId = tonumber(RemoveFirstChar(self.tankTb[i]))
		local orderId=GetTankOrderByTankId(tonumber(tankId))
		local tankStr="t"..orderId.."_1.png"
		local tankSp = CCSprite:createWithSpriteFrameName(tankStr)
		
		if tonumber(tankId)==10082 then
			tankSp:setPosition(ccp(bgSp:getContentSize().width/2-5,bgSp:getContentSize().height/2+35))
		else
			tankSp:setPosition(ccp(bgSp:getContentSize().width/2-5,bgSp:getContentSize().height/2+20))
		end
		bgSp:addChild(tankSp)
		tankSp:setScale(1/scale*0.8)

		local tankBarrel="t"..orderId.."_1_1.png"  --炮管 第6层
		local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
		if tankBarrelSP then
			tankBarrelSP:setPosition(ccp(tankSp:getContentSize().width*0.5,tankSp:getContentSize().height*0.5))
			tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
			tankSp:addChild(tankBarrelSP)
		end
	end

	local startH = 40
	local interval = 20
	local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
	local backSpH=170
	local function bgClick()
	end

	local function  btnClick(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local method = 1
        if tag==1 then
        	method=2
        else
        	method=1
        end
        self:getReward(method)
	end
	-- i=2 是抽一次 i=1是抽10次
	for i=1,2 do
		local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
		backSprie:setContentSize(CCSizeMake(w, backSpH))
		backSprie:setAnchorPoint(ccp(0.5,0))
		self.bgLayer:addChild(backSprie)

		local mustReward
		if i==1 then
			backSprie:setPosition(ccp(G_VisibleSizeWidth/2, startH))
			mustReward=acQuanmintankeVoApi:getMustReward2()
		else
			backSprie:setPosition(ccp(G_VisibleSizeWidth/2, startH+backSpH+interval))
			mustReward=acQuanmintankeVoApi:getMustReward1()
		end
		local reward = mustReward.reward
		local rewardItem = FormatItem(reward)

		if i==1 then
			self.rewardItem2 = rewardItem
		else
			self.rewardItem1 = rewardItem
		end

		local icon,scale=G_getItemIcon(rewardItem[1],100,true,self.layerNum)
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		icon:setPosition(60,backSprie:getContentSize().height/2)
		backSprie:addChild(icon)
		G_addRectFlicker(icon,1/scale*1.35,1/scale*1.3)

		local nameLb=GetTTFLabelWrap(
			rewardItem[1].name .. "x" .. rewardItem[1].num,25,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
		nameLb:setAnchorPoint(ccp(0,0))
		backSprie:addChild(nameLb)
		nameLb:setPosition(ccp(120,backSprie:getContentSize().height/2+20)
			)

		local desLb=GetTTFLabelWrap(
		getlocal("activity_quanmintankeNew_des" .. i),22,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		desLb:setAnchorPoint(ccp(0,1))
		backSprie:addChild(desLb)
		desLb:setPosition(ccp(120,backSprie:getContentSize().height/2+5)
		)

		local btnW=G_VisibleSizeWidth-140
		local btnItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",btnClick,i,getlocal("buy"),25)
		btnItem:setAnchorPoint(ccp(0.5,0))
		btnItem:setScale(0.9)
		local btn=CCMenu:createWithItem(btnItem);
		btn:setTouchPriority(-(self.layerNum-1)*20-4);
		btn:setPosition(ccp(btnW,15))
		backSprie:addChild(btn)

		local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
		goldIcon:setAnchorPoint(ccp(0,0.5))
		goldIcon:setPosition(btnW-btnItem:getContentSize().width/4, 15+btnItem:getContentSize().height+15)
		backSprie:addChild(goldIcon)

		local goldIconD = CCSprite:createWithSpriteFrameName("IconGold.png")
		goldIconD:setAnchorPoint(ccp(0,0.5))
		goldIconD:setPosition(btnW-btnItem:getContentSize().width/4, 15+btnItem:getContentSize().height+15+30)
		backSprie:addChild(goldIconD)




		local goldNum = 0 
		local goldNumD = 0
		if i==1 then
			goldNum=acQuanmintankeVoApi:getVipCost(2)
			goldNumD=acQuanmintankeVoApi:getCost(2)
			self.btnItem2=btnItem
		else
			goldNum=acQuanmintankeVoApi:getVipCost(1)
			goldNumD=acQuanmintankeVoApi:getCost(1)
		end
		local costLb = GetTTFLabel(goldNum, 25)
		costLb:setAnchorPoint(ccp(0,0.5))
		costLb:setPosition(ccp(btnW+btnItem:getContentSize().width/4-40, 15+btnItem:getContentSize().height+15))
		backSprie:addChild(costLb)

		local costLbD = GetTTFLabel(goldNumD, 25)
		costLbD:setAnchorPoint(ccp(0,0.5))
		costLbD:setPosition(ccp(btnW+btnItem:getContentSize().width/4-40, 15+btnItem:getContentSize().height+15+30))
		backSprie:addChild(costLbD)

		local line = CCSprite:createWithSpriteFrameName("redline.jpg")
		line:setScaleX((costLbD:getContentSize().width+50)/line:getContentSize().width)
		line:setPosition(ccp(costLbD:getContentSize().width/2-20,costLbD:getContentSize().height/2))
		costLbD:addChild(line)

		if i==2 then
			local freeLb = GetTTFLabel(getlocal("daily_lotto_tip_2"), 25)
			freeLb:setPosition(ccp(btnW, 15+btnItem:getContentSize().height+20))
			freeLb:setColor(G_ColorGreen)
			backSprie:addChild(freeLb)
			self.freeLb=freeLb
		end
		if i==2 then
			self.costLb1 = costLb
			self.goldIcon = goldIcon
			self.costLbD1=costLbD
			self.goldIconD1=goldIconD
		else
			self.costLb2 = costLb
			self.costLbD2=costLbD
			self.goldIconD2=goldIconD
		end
		
	end
	self:checkCost()

end

function acQuanmintankeNewDialog:checkCost()
	local haveCost = playerVoApi:getGems()
	local goldNum2=acQuanmintankeVoApi:getVipCost(2)
	local goldNum1=acQuanmintankeVoApi:getVipCost(1)
	self.costLb1:setString(goldNum1)
	self.costLb2:setString(goldNum2)
	if acQuanmintankeVoApi:canReward()==true then
		self.freeLb:setVisible(true)
		self.costLb1:setVisible(false)
		self.goldIcon:setVisible(false)
		self.btnItem2:setEnabled(false)
		local tenCost = acQuanmintankeVoApi:getVipCost(2)
		if tenCost>haveCost then
			self.costLb2:setColor(G_ColorRed)
		else
			self.costLb2:setColor(G_ColorYellowPro)
		end
		self.costLbD1:setVisible(false)
		self.goldIconD1:setVisible(false)
		
	else
		self.costLbD1:setVisible(true)
		self.costLbD2:setVisible(true)
		self.goldIconD1:setVisible(true)
		self.goldIconD2:setVisible(true)

		self.btnItem2:setEnabled(true)
		self.freeLb:setVisible(false)
		self.costLb1:setVisible(true)
		self.goldIcon:setVisible(true)
		local oneCost = acQuanmintankeVoApi:getVipCost(1)
		local tenCost = acQuanmintankeVoApi:getVipCost(2)
		if tenCost>haveCost then
			self.costLb2:setColor(G_ColorRed)
		else
			self.costLb2:setColor(G_ColorYellowPro)
		end
		if oneCost>haveCost then
			self.costLb1:setColor(G_ColorRed)
		else
			self.costLb1:setColor(G_ColorYellowPro)
		end
	end

	local disCount = acQuanmintankeVoApi:getVipdiscoun()
	local vipLevel = playerVoApi:getVipLevel()
	if disCount==0 or vipLevel==0 then
		self.costLbD1:setVisible(false)
		self.costLbD2:setVisible(false)
		self.goldIconD1:setVisible(false)
		self.goldIconD2:setVisible(false)
	end
end


-- 抽取奖励
function acQuanmintankeNewDialog:getReward(method)
	local free=false
	if acQuanmintankeVoApi:canReward()==true then
		method=1
		free=true
	else
		local cost = acQuanmintankeVoApi:getVipCost(method)
		if cost>playerVoApi:getGems() then
			GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost,nil)
			return
		end
	end

	local function getRawardCallback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
		-- 这里数据包了slotMachine和show两层，是为了防止每次后台返回数据，前台自动通过
		--base:formatPlayerData(data)这个方法同步数据时有不同数据用了同一个标识的情况
			if sData and sData.data and sData.data.report then
				self.playIds = sData.data.report
				acQuanmintankeVoApi:updateLastResult(self.playIds)
			end
			if sData and sData.data and sData.data.reward then
				local reward = FormatItem(sData.data.reward)
				
				self.reward=reward
			end
			if sData and sData.data and sData.data.tanktype then
				self.tanktype=sData.data.tanktype
				acQuanmintankeVoApi:setRewardTank(sData.data.tanktype)
			end
			if free then
				acQuanmintankeVoApi:setLastTime(sData.ts)
		        self.isToday=true
			end
			local getTable= self:resetData(self.playIds)
			self:aftetGetReward(getTable,method)

			self:addRewardAndCostMoney(free,method)
			self:checkCost()

			local titleTb = {getlocal("but_get"),getlocal("other_ger")}
			acQuanmintankeVoApi:showRewardSmallDialog(true,true,self.layerNum + 1,titleTb,"TankInforPanel.png",CCSizeMake(500,540),CCRect(130, 50, 1, 1),self["rewardItem" .. method],self.reward,btnStr,onConfirm)
			
		end
	end
	socketHelper:acQuanmintankeChoujiang(method,getRawardCallback)
end

-- 后台返回结果之后马上扣除金币并且给予奖励
function acQuanmintankeNewDialog:addRewardAndCostMoney(free,num)
	if free then
	else
		local playerGem=playerVoApi:getGems()
		local cost = acQuanmintankeVoApi:getVipCost(num)
		playerVoApi:setGems(playerGem-cost)
	end
end

-- 根据后台返回的结果{2，3，3}得到个数累加的格式
function acQuanmintankeNewDialog:resetData(data)
	local getTable = {}
	for k,v in pairs(data) do
		if getTable[tonumber(v)] == nil then
			getTable[tonumber(v)] = 1
		else
			getTable[tonumber(v)] = getTable[tonumber(v)] + 1
		end
	end
	return getTable
end

-- 处理后台得到返回抽取结构后前台的处理
function acQuanmintankeNewDialog:aftetGetReward(getTable,method)
  -- 遍历得到所有可获得的奖励并整合
	for k,v in pairs(getTable) do
		if v ~= nil and v > 0 then
		    -- 根据最终获得奖励的特效处理
			if tonumber(v) == 3 then
				local message={key="activity_tianjiangxiongshi_reward",param={playerVoApi:getPlayerName(),self.reward[1].name,self.reward[1].num}}
				chatVoApi:sendSystemMessage(message)
			end

		end
	end
	G_addPlayerAward(self.reward[1].type,self.reward[1].key,self.reward[1].id,self.reward[1].num,nil,true)
	local rewardItem
	if method==1 then
		rewardItem = self.rewardItem1
	else
		rewardItem = self.rewardItem2
	end
	G_addPlayerAward(rewardItem[1].type,rewardItem[1].key,rewardItem[1].id,rewardItem[1].num,nil,true)
	-- G_showRewardTip(self.reward,true)
end

function acQuanmintankeNewDialog:tick()
	local acVo = acQuanmintankeVoApi:getAcVo()
	if acVo ~= nil then
		if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
			if self ~= nil then
				self:close()
				do return end
			end
		end
	end

	if acQuanmintankeVoApi:isToday()==false and self.isToday==true then
		self.isToday=false
		self:checkCost()
	end

	self:updateAcTime()
end

function acQuanmintankeNewDialog:updateAcTime()
    local acVo=acQuanmintankeVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acQuanmintankeNewDialog:dispose()
	eventDispatcher:removeEventListener("acQuanmintanke.recharge",self.qmtkListener)
	self.layerNum=nil
	self.bgLayer=nil
	self.isToday=true
	self.timeLb=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
end