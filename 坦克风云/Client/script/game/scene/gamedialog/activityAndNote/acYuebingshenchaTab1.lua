acYuebingshenchaTab1 = {}

function acYuebingshenchaTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.state = 0 -- 0 正常 1 点击抽取 2 后台返回结果 3 动画播放结束
	self.isToday=true
	self.geziSp={{},{},{},{}}
	self.tankSp={}
	self.adaH = 0 --iphoneX适配
	self.version= acYuebingshenchaVoApi:getVersion()
	self.vipLevel = playerVoApi:getVipLevel()
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	self.isIphone5DownHeightSize=0
	self.isIphone5UpHeightSize=0
	return nc
end

function acYuebingshenchaTab1:init(layerNum)
	if G_getIphoneType() == G_iphoneX then
		--iphoneX不走iphone5的逻辑
	elseif G_isIphone5() then
		self.isIphone5DownHeightSize = 50
		self.isIphone5UpHeightSize = 100
	end
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer()
	return self.bgLayer
end

function acYuebingshenchaTab1:initLayer()
	self.reward = acYuebingshenchaVoApi:getReward()

	local function touchDialog()
		if self.state == 1 then
			PlayEffect(audioCfg.mouseClick)
			self.state = 2
		end
	end
	--iphoneX适配
	if G_getIphoneType() == G_iphoneX then
		self.adaH = 35
	end
	self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	self.touchDialogBg:setContentSize(rect)
	self.touchDialogBg:setOpacity(0)
	self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
	self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
	self.bgLayer:addChild(self.touchDialogBg,1)

	local function cellClick(hd,fn,index)
	end

	local w = G_VisibleSizeWidth - 60 -- 背景框的宽度
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
	backSprie:setContentSize(CCSizeMake(w, 170+self.isIphone5DownHeightSize+self.adaH))
	backSprie:setAnchorPoint(ccp(0,0))
	backSprie:setPosition(ccp(30, G_VisibleSizeHeight - 330-self.isIphone5DownHeightSize-self.adaH))
	self.bgLayer:addChild(backSprie)

	local function touch(tag,object)
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)

		local td=smallDialog:new()
		local str1=getlocal("activity_yuebingshencha_tab1_tip1")
		local str2=getlocal("activity_yuebingshencha_tab1_tip2",{getlocal("activity_yuebingshencha_tab1_btn1")})
		if self.version==2 or self.version ==4 then
			str1=getlocal("activity_yuebingshencha_tab1_tip1_2")
			str2=getlocal("activity_yuebingshencha_tab1_tip2",{getlocal("activity_yuebingshencha_tab1_btn1_2")})
		end
		local tabStr = {"\n",getlocal("activity_yuebingshencha_tab1_tip4"),"\n",getlocal("activity_yuebingshencha_tab1_tip3"),"\n",str2,"\n",str1,"\n"}
		if acYuebingshenchaVoApi:getVipDiscount( ) then
			tabStr = {"\n",getlocal("activity_yuebingshencha_tab1_tip5"),"\n",getlocal("activity_yuebingshencha_tab1_tip4"),"\n",getlocal("activity_yuebingshencha_tab1_tip3"),"\n",str2,"\n",str1,"\n"}
		end

		local colorTb = {nil,nil,nil,nil}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTb)
		sceneGame:addChild(dialog,self.layerNum+1)
	end


	local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(w - 10, backSprie:getContentSize().height-50))
	backSprie:addChild(menuDesc)

	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-10))
	backSprie:addChild(acLabel)
	acLabel:setColor(G_ColorYellowPro)

	local acVo = acYuebingshenchaVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,28)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-50))
	backSprie:addChild(messageLabel)
	self.timeLb=messageLabel
	self:updateAcTime()

	local desStr = getlocal("activity_yuebingshencha_tab1_des",{getlocal(tankCfg[10095].name)})
	if self.version==2 or self.version ==4 then
		desStr = getlocal("activity_yuebingshencha_tab1_des_2")
	end
	local desTv, desLabel= G_LabelTableView(CCSizeMake(540, 70+self.isIphone5DownHeightSize+self.adaH/2),desStr,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(20,15))
    backSprie:addChild(desTv)
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(80)

	local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
	backSprie2:setContentSize(CCSizeMake(w, G_VisibleSizeHeight-510-self.isIphone5UpHeightSize-self.isIphone5DownHeightSize))--470
	backSprie2:setAnchorPoint(ccp(0,0))
	backSprie2:setPosition(ccp(30, 180+self.isIphone5UpHeightSize-self.adaH))--140
	self.bgLayer:addChild(backSprie2)

	self:setDownBg()

	-- 按钮
	local function touchBtn(tag)
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)

		local flag = tag
		if acYuebingshenchaVoApi:isToday()==false then
			flag=0
		end
		local cost = 0
		if flag == 0 then
		elseif flag==1 then
			cost=acYuebingshenchaVoApi:getCost()
		else
			cost=acYuebingshenchaVoApi:getMulCost()
		end
		if playerVoApi:getGems()<cost then
            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
            return
        end
		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret==true then
				playerVoApi:setValue("gems",playerVoApi:getGems()-cost)
				if sData and sData.data and sData.data.ybsc then
					acYuebingshenchaVoApi:updataData(sData.data.ybsc)
				end
				if sData and sData.data and sData.data.report then
					self:startPalyAnimation(flag,sData.data.report)
				end
				if sData and sData.data and sData.data.reward then
					self.jiangliTb= FormatItem(sData.data.reward)
					for k,v in pairs(self.jiangliTb) do
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
				end
				if flag==0 then
					self:refresh()
					self.isToday=true
				end
				
			end
				
		end
		socketHelper:acYuebingshenchaChoujiang(flag,callback)
		
	end

	local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
	local oneStr=getlocal("activity_yuebingshencha_tab1_btn1")
	if self.version==2 or self.version ==4 then
		oneStr=getlocal("activity_yuebingshencha_tab1_btn1_2")
	end
	local oneItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touchBtn,1,oneStr,strSize2)
	oneItem:setAnchorPoint(ccp(0.5,0))
	local oneBtn=CCMenu:createWithItem(oneItem);
	oneBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	oneBtn:setPosition(ccp(G_VisibleSizeWidth/2-150,40+self.isIphone5DownHeightSize*0.5))
	self.bgLayer:addChild(oneBtn)
	--按钮点击
	local tenStr=getlocal("activity_yuebingshencha_tab1_btn2")
	if self.version==2 or self.version ==4 then
		tenStr=getlocal("activity_yuebingshencha_tab1_btn2_2")
	end
	local tenItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touchBtn,2,tenStr,strSize2)
	tenItem:setAnchorPoint(ccp(0.5,0))
	local tenBtn=CCMenu:createWithItem(tenItem);
	tenBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	tenBtn:setPosition(ccp(G_VisibleSizeWidth/2+150,40+self.isIphone5DownHeightSize*0.5))
	self.bgLayer:addChild(tenBtn)
	self.tenItem=tenItem

	local oneCost,oldCost = acYuebingshenchaVoApi:getCost()
	local oneLb = GetTTFLabel(oneCost,25)
	oneItem:addChild(oneLb)
	oneLb:setPosition(oneItem:getContentSize().width/2-10, oneItem:getContentSize().height+15+self.isIphone5DownHeightSize*0.7)
	self.oneLb=oneLb

	local oneSp = CCSprite:createWithSpriteFrameName("IconGold.png")
	oneSp:setAnchorPoint(ccp(0,0.5))
	oneLb:addChild(oneSp)
	oneSp:setPosition(oneLb:getContentSize().width, oneLb:getContentSize().height/2)

	local mulCost,oldMulCost = acYuebingshenchaVoApi:getMulCost()
	local tenLb = GetTTFLabel(mulCost,25)
	tenItem:addChild(tenLb)
	tenLb:setPosition(tenItem:getContentSize().width/2-10, tenItem:getContentSize().height+15+self.isIphone5DownHeightSize*0.7)

	local tenSp = CCSprite:createWithSpriteFrameName("IconGold.png")
	tenSp:setAnchorPoint(ccp(0,0.5))
	tenLb:addChild(tenSp)
	tenSp:setPosition(tenLb:getContentSize().width, tenLb:getContentSize().height/2)

	local mianFeiLb = GetTTFLabel(getlocal("daily_lotto_tip_2"),25)
	oneItem:addChild(mianFeiLb)
	mianFeiLb:setPosition(oneItem:getContentSize().width/2, oneItem:getContentSize().height+15+self.isIphone5DownHeightSize*0.7)
	self.mianFeiLb=mianFeiLb

	if acYuebingshenchaVoApi:getVipDiscount() and self.vipLevel >0 then
		local fixdPosY1 = oneItem:getContentSize().height+15
		local fixdPosY2 = tenItem:getContentSize().height+15

		oneLb:setAnchorPoint(ccp(0,0.5))
		oneLb:setPosition(ccp(oneItem:getContentSize().width*0.5+5,fixdPosY1))

		tenLb:setAnchorPoint(ccp(0,0.5))
		tenLb:setPosition(ccp(tenItem:getContentSize().width*0.5+2,fixdPosY2))

		local oneOldLb = GetTTFLabel(oldCost,25)
		oneItem:addChild(oneOldLb)
		oneOldLb:setAnchorPoint(ccp(0,0.5))
		oneOldLb:setColor(G_ColorRed)
		oneOldLb:setPosition(13, fixdPosY1)
		self.oneOldLb =oneOldLb

		local rline=CCSprite:createWithSpriteFrameName("redline.jpg")
        rline:setAnchorPoint(ccp(0.5,0.5))
        rline:setScaleX((oneOldLb:getContentSize().width)/rline:getContentSize().width)
        rline:setPosition(ccp(oneOldLb:getContentSize().width*0.5,oneOldLb:getContentSize().height*0.5))
        oneOldLb:addChild(rline,1)
        self.rline =rline

		local oneOldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
		oneOldSp:setAnchorPoint(ccp(0,0.5))
		oneOldLb:addChild(oneOldSp)
		oneOldSp:setPosition(oneOldLb:getContentSize().width, oneOldLb:getContentSize().height/2)
		self.oneOldSp =oneOldSp

		local oldMulCostLb = GetTTFLabel(oldMulCost,25)
		tenItem:addChild(oldMulCostLb)
		oldMulCostLb:setAnchorPoint(ccp(0,0.5))
		oldMulCostLb:setColor(G_ColorRed)
		oldMulCostLb:setPosition(8, fixdPosY2)

		local rline2=CCSprite:createWithSpriteFrameName("redline.jpg")
        rline2:setAnchorPoint(ccp(0.5,0.5))
        rline2:setScaleX((oldMulCostLb:getContentSize().width)/rline2:getContentSize().width)
        rline2:setPosition(ccp(oldMulCostLb:getContentSize().width*0.5,oldMulCostLb:getContentSize().height*0.5))
        oldMulCostLb:addChild(rline2,1)

		local oldMulCostSp = CCSprite:createWithSpriteFrameName("IconGold.png")
		oldMulCostSp:setAnchorPoint(ccp(0,0.5))
		oldMulCostLb:addChild(oldMulCostSp)
		oldMulCostSp:setPosition(oldMulCostLb:getContentSize().width, oldMulCostLb:getContentSize().height/2)

		if self.isIphone5DownHeightSize >0 then

			oneLb:setAnchorPoint(ccp(0.5,0.5))
			oneLb:setPosition(ccp(oneItem:getContentSize().width*0.5-10,fixdPosY1+self.isIphone5DownHeightSize*0.3))

			tenLb:setAnchorPoint(ccp(0.5,0.5))
			tenLb:setPosition(ccp(tenItem:getContentSize().width*0.5-10,fixdPosY2+self.isIphone5DownHeightSize*0.3))

			oneOldLb:setAnchorPoint(ccp(0.5,0.5))
			oneOldLb:setPosition(ccp(oneItem:getContentSize().width*0.5-10,fixdPosY1+self.isIphone5DownHeightSize))

			oldMulCostLb:setAnchorPoint(ccp(0.5,0.5))
			oldMulCostLb:setPosition(ccp(tenItem:getContentSize().width*0.5-10,fixdPosY2+self.isIphone5DownHeightSize))

		end
	end

	self:refresh()

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(575,G_VisibleSizeHeight-510-self.isIphone5UpHeightSize-self.isIphone5DownHeightSize),nil)--470
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(30,180+self.isIphone5UpHeightSize-self.adaH))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(0)


end

function acYuebingshenchaTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
	 	return 1
    elseif fn=="tableCellSizeForIndex" then
	   	local tmpSize
        tmpSize=CCSizeMake(575,G_VisibleSizeHeight-515-self.isIphone5UpHeightSize-self.isIphone5DownHeightSize)--470
       return  tmpSize
    elseif fn=="tableCellAtIndex" then
	   	local cell=CCTableViewCell:new()
        cell:autorelease()

        local function cellClick(hd,fn,index)
		end
        local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
		backSprie2:setContentSize(CCSizeMake(575, G_VisibleSizeHeight-510-self.isIphone5UpHeightSize-self.isIphone5DownHeightSize))--470
		backSprie2:setAnchorPoint(ccp(0,0))
		backSprie2:setPosition(ccp(0, 0))
		cell:addChild(backSprie2)
		self.backSprie2=backSprie2
		backSprie2:setOpacity(0)

		local bgSp = CCSprite:create("public/acYbscBg.jpg")
		backSprie2:addChild(bgSp)
		bgSp:setAnchorPoint(ccp(0.5,0))
		bgSp:setScale(0.97)
		bgSp:setPosition(backSprie2:getContentSize().width/2+2, 3)

		-- 四个奖励
		self.posTb={{},{},{},{}}
		for i=1,#self.reward do
			local name,pic,desc,id,index,eType,equipId,bgname
			if i<#self.reward then
				name,pic,desc,id,index,eType,equipId,bgname = getItem(self.reward[i][2],"o")
			else
				name,pic,desc,id,index,eType,equipId,bgname = getItem(self.reward[i][2],"p")
			end
			local item={name=name,pic=pic,desc=desc,id=id}
			local function callback()
				if i<#self.reward then
					 tankInfoDialog:create(nil,id,self.layerNum+1, true)
				else
					propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
				end
				
			end

			local iconSp = GetBgIcon(pic,callback,nil,80,80)
			backSprie2:addChild(iconSp)
			iconSp:setAnchorPoint(ccp(0,0))
			iconSp:setPosition(10, backSprie2:getContentSize().height-70*i)
			iconSp:setScale(60/80)
			iconSp:setTouchPriority(-(self.layerNum-1)*20-4);

			local numStr = "x" .. self.reward[i][4]
			local numlb = GetTTFLabel(numStr,25)
			iconSp:addChild(numlb)
			numlb:setAnchorPoint(ccp(1,0))
			numlb:setPosition(iconSp:getContentSize().width-5, 5)

			
			for j=1,self.reward[i][3] do
				local spDi = CCSprite:createWithSpriteFrameName("acYbscAn.png")
				backSprie2:addChild(spDi)
				spDi:setAnchorPoint(ccp(0,0))
				spDi:setPosition(50+j*26*0.9, backSprie2:getContentSize().height-70*i+15)
				spDi:setScale(0.9)
				if j==self.reward[i][3] then
					self.posTb[i].x=50+(j+1)*26*0.9
					self.posTb[i].y=backSprie2:getContentSize().height-70*i+15
				end

				local liangSp = CCSprite:createWithSpriteFrameName("acYbscLiang.png")
				spDi:addChild(liangSp)
				liangSp:setPosition(spDi:getContentSize().width/2, spDi:getContentSize().height/2)
				self.geziSp[i][self.reward[i][3]-j+1]=liangSp
			end
		end

		-- if acYuebingshenchaVoApi:getVersion()==2 then
			--播放动画按钮 first
		local function touchAction(tag,object )
			self:showBattle()
		end 
		local actionTouchFir = GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn.png",touchAction,nil,nil,0)
		actionTouchFir:setAnchorPoint(ccp(1,0))
		local actionTouchFirMenu = CCMenu:createWithItem(actionTouchFir)
		actionTouchFirMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		actionTouchFirMenu:setPosition(ccp(backSprie2:getContentSize().width-10,5))
		backSprie2:addChild(actionTouchFirMenu)
		-- end
	



		

		self:setGezi()
        
        return cell
   	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end

end

function acYuebingshenchaTab1:showBattle()
	local battleStr=acYuebingshenchaVoApi:returnTankData()
	local report=G_Json.decode(battleStr)
	local isAttacker=true
	local data={data={report=report},isAttacker=isAttacker,isReport=true}
	battleScene:initData(data)
end

function acYuebingshenchaTab1:setGezi(cnum1,cnum2,cnum3,cnum4)
	local num1
	local num2
	local num3
	local num4
	if cnum1 then
		num1=cnum1
		num2=cnum2
		num3=cnum3
		num4=cnum4
	else
		local nowP = acYuebingshenchaVoApi:getNowP()
		num1 = nowP.p1 or 0
		num2 = nowP.p2 or 0
		num3 = nowP.p3 or 0
		num4 = nowP.p4 or 0
		self.num1=num1
		self.num2=num2
		self.num3=num3
		self.num4=num4
	end

	for i=1,#self.geziSp[1] do
		if i>num1 then
			self.geziSp[1][i]:setVisible(false)
		else
			self.geziSp[1][i]:setVisible(true)
		end
	end

	
	for i=1,#self.geziSp[2] do
		if i>num2 then
			self.geziSp[2][i]:setVisible(false)
		else
			self.geziSp[2][i]:setVisible(true)
		end
	end

	-- local num3 = nowP.p3 or 0
	for i=1,#self.geziSp[3] do
		if i>num3 then
			self.geziSp[3][i]:setVisible(false)
		else
			self.geziSp[3][i]:setVisible(true)
		end
	end

	-- local num4 = nowP.p4 or 0
	for i=1,#self.geziSp[4] do
		if i>num4 then
			self.geziSp[4][i]:setVisible(false)
		else
			self.geziSp[4][i]:setVisible(true)
		end
	end
	
end

function acYuebingshenchaTab1:startPalyAnimation(flag,report)
	self.state = 1
	self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
	self:beginAction(flag,report)
end

function acYuebingshenchaTab1:stopPlayAnimation()
  self.state = 0
  self:aftetGetReward()
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  self:setGezi()
  self:stopAction()
end

function acYuebingshenchaTab1:aftetGetReward()
	if self.jiangliTb then
		G_showRewardTip(self.jiangliTb,true)
	end
	self.jiangliTb=nil
	
end


function acYuebingshenchaTab1:stopAction()
	for k,v in pairs(self.tankSp) do
		v:stopAllActions()
		v:setVisible(false)
	end
end

function acYuebingshenchaTab1:beginAction(flag,report)
	local count = 1
	if flag == 2 then
		count=10
	end
	local countNum=0
	for j=1,count do
		 for i=1,4 do
		 	if self.tankSp[i*100+j]==nil then
		 		local orderId=GetTankOrderByTankId(tonumber(10095))
		 		if self.version==2 or self.version ==4 then
		 			orderId=GetTankOrderByTankId(tonumber(20155))
		 		end
	            local tankStr="t"..orderId.."_1.png"
		 		self.tankSp[i*100+j]=CCSprite:createWithSpriteFrameName(tankStr)

		 		local tankBarrel="t"..orderId.."_1_1.png"  --炮管 第6层
	            local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
	            if tankBarrelSP then
	                tankBarrelSP:setPosition(ccp(self.tankSp[i*100+j]:getContentSize().width*0.5,self.tankSp[i*100+j]:getContentSize().height*0.5))
	                tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
	                self.tankSp[i*100+j]:addChild(tankBarrelSP)
	            end
		 		-- self.tankSp[i*100+j]:setScale(0.8)
		 		self.backSprie2:addChild(self.tankSp[i*100+j])
		 	end
		 	self.tankSp[i*100+j]:setScale(0.7)
		 	self.tankSp[i*100+j]:setVisible(true)

	 		self.tankSp[i*100+j]:setPosition(400+i*40+190, 330-i*27+95)--95
			
		 	local moveTo=CCMoveTo:create(3,CCPointMake(100+i*40, 170-i*27))--170
		 	local delayTime =  CCDelayTime:create((j-1)*1.4)

		 	countNum=countNum+1

		 	local posX,posY
		 	local num1=self.num1
		 	local num2=self.num2
		 	local num3=self.num3
		 	local num4=self.num4
		 	if report and report[countNum] then
		 		for k,v in pairs(report[countNum]) do
		 			if k=="p1" then
		 				posX=self.posTb[1].x
		 				posY=self.posTb[1].y

		 				num1=num1+1
		 				if num1>self.reward[1][3] then
		 					num1=1
		 				end
		 				self.num1=num1
	 				elseif k=="p2" then
	 					posX=self.posTb[2].x
		 				posY=self.posTb[2].y

		 				num2=num2+1
		 				if num2>self.reward[2][3] then
		 					num2=1
		 				end
		 				self.num2=num2
	 				elseif k=="p3" then
	 					posX=self.posTb[3].x
		 				posY=self.posTb[3].y
		 				
		 				num3=num3+1
		 				if num3>self.reward[3][3] then
		 					num3=1
		 				end
		 				self.num3=num3
	 				elseif k=="p4" then
	 					posX=self.posTb[4].x
		 				posY=self.posTb[4].y
		 				
		 				num4=num4+1
		 				if num4>self.reward[4][3] then
		 					num4=1
		 				end
		 				self.num4=num4
		 			end
		 		end
		 	end
		 	
		 	local delayTime1 =  CCDelayTime:create((i-1)*0.2)
		 	local moveTo1=CCMoveTo:create(0.3,ccp(posX,posY))
		 	local function callback()
		 		self:setGezi(num1,num2,num3,num4)
		 		if j==count and i==4 then
		 			self:stopPlayAnimation()
		 		end
		 	end
		 	local callFunc=CCCallFunc:create(callback)

		 	local acScale = CCScaleTo:create(0.5,0)
		 	local acArr2=CCArray:create()
		 	acArr2:addObject(acScale)
		 	acArr2:addObject(moveTo1)
		 	local spawn=CCSpawn:create(acArr2)

		 	local acArr=CCArray:create()
            acArr:addObject(delayTime)
            acArr:addObject(moveTo)
            acArr:addObject(delayTime1)
            acArr:addObject(spawn)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
			self.tankSp[i*100+j]:runAction(seq)
		 end

	end
	
end



function acYuebingshenchaTab1:refresh()
	if acYuebingshenchaVoApi:isToday()==false then
		self.mianFeiLb:setVisible(true)
		self.oneLb:setVisible(false)
		self.tenItem:setEnabled(false)
		if self.oneOldLb then
			self.oneOldLb:setVisible(false)
			self.oneOldSp:setVisible(false)
			self.rline:setVisible(false)
		end
	else
		self.mianFeiLb:setVisible(false)
		self.oneLb:setVisible(true)
		self.tenItem:setEnabled(true)
		if self.oneOldLb then
			self.oneOldLb:setVisible(true)
			self.oneOldSp:setVisible(true)
			self.rline:setVisible(true)
		end
	end
end

function acYuebingshenchaTab1:tick()
	if acYuebingshenchaVoApi:isToday()==false and self.isToday==true then
	    self.isToday=false
	    self:refresh()
	end
	self:updateAcTime()
end


function acYuebingshenchaTab1:fastTick()
	if self.state == 2 then
		self:stopPlayAnimation()
	end
end

function acYuebingshenchaTab1:setDownBg( )
	if acYuebingshenchaVoApi:getVipDiscount() then
		local function noData()
		end
		self.downBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
		self.downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-58,G_VisibleSizeHeight*0.16-2-self.isIphone5DownHeightSize+self.isIphone5UpHeightSize))
		self.downBg:setAnchorPoint(ccp(0.5,0))
		self.downBg:setPosition(ccp(G_VisibleSizeWidth*0.5,30))
		self.bgLayer:addChild(self.downBg)

		self.rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),noData)
		self.rewardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-56,G_VisibleSizeHeight*0.16-self.isIphone5DownHeightSize+self.isIphone5UpHeightSize))
		self.rewardBg:ignoreAnchorPointForPosition(false)
		self.rewardBg:setAnchorPoint(ccp(0.5,0))
		self.rewardBg:setIsSallow(false)
		self.rewardBg:setTouchPriority(-(self.layerNum-1)*20-2)
		self.downBg:addChild(self.rewardBg)
		self.rewardBg:setPosition(ccp(self.downBg:getContentSize().width*0.5,-2))

		self.vippIcon=LuaCCScale9Sprite:createWithSpriteFrameName("VipIconYellow.png",CCRect(110, 60, 1, 1),noData)
	  	self.vippIcon:setScale(0.8)
	  	if G_getCurChoseLanguage() =="en" then
	  		self.vippIcon:setScaleX(1.5)
	  		self.vippIcon:setScaleY(1)
	  	end
	    self.vippIcon:setAnchorPoint(ccp(0.5,0.5))
	    self.vippIcon:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.downBg:getContentSize().height-10))
	    self.downBg:addChild(self.vippIcon,1)

	   	local vipLevel=GetTTFLabel(getlocal("VIPStr1",{self.vipLevel}),30)
		vipLevel:setAnchorPoint(ccp(0.5,0.5))
		vipLevel:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.downBg:getContentSize().height-10))
		self.downBg:addChild(vipLevel,1)
		vipLevel:setColor(G_ColorYellow)
	end
end

function acYuebingshenchaTab1:updateAcTime()
    local acVo = acYuebingshenchaVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acYuebingshenchaTab1:dispose()
	self.bgLayer=nil
    self.layerNum=nil
    self.oneLb=nil
    self.mianFeiLb=nil
    self.geziSp=nil
    self.tankSp={}
    self.num1=nil
	self.num2=nil
	self.num3=nil
	self.num4=nil
	self.geziSp=nil
	self.tankSp=nil
	self.version =nil
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
	self.isIphone5DownHeightSize=nil
end