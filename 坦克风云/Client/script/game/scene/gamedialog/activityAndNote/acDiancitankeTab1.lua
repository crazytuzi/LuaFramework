acDiancitankeTab1 = {}

function acDiancitankeTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.isMulc=false -- 是否勾选10倍收益
	self.isToday=true
	self.lastScore=0
	self.state = 0
	self.tag=1
	return nc
end

function acDiancitankeTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer()
	return self.bgLayer
end

function acDiancitankeTab1:initLayer()

	self.lastScore=acDiancitankeVoApi:getScore()
	local function touchDialog()
		if self.state == 1 then
			PlayEffect(audioCfg.mouseClick)
			self.state = 2
		end
	end
	self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	self.touchDialogBg:setContentSize(rect)
	self.touchDialogBg:setOpacity(0)
	self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
	self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
	self.bgLayer:addChild(self.touchDialogBg,1)

	local h = self.bgLayer:getContentSize().height-170
	local acLabel = GetTTFLabel(getlocal("activity_timeLabel") .. ": ",25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setColor(G_ColorGreen)
	acLabel:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(acLabel,1)

	local acVo = acDiancitankeVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,25)
	messageLabel:setAnchorPoint(ccp(0,0.5))
	messageLabel:setPosition(ccp(acLabel:getContentSize().width, acLabel:getContentSize().height/2))
	acLabel:addChild(messageLabel,3)
	acLabel:setPosition(ccp(G_VisibleSizeWidth/2-messageLabel:getContentSize().width/2, h))
	self.timeLb=messageLabel
	self:updateAcTime()

	local function touchI()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
		local tabColor ={nil,nil,nil,G_ColorRed,nil,nil};
		local td=smallDialog:new()
		tabStr = {"\n",getlocal("activity_diancitanke_tab1_tip3"),"\n",getlocal("activity_diancitanke_tab1_tip2",{acDiancitankeVoApi:getDecay(1)*100 .. "%%"}),"\n",getlocal("activity_diancitanke_tab1_tip1"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local menuItem1 = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchI,0,nil,25)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(560,h-60));
    menu1:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(menu1,3);

    -- acDctk_Dial.png
    local biaoPanSp = CCSprite:createWithSpriteFrameName("acDctk_Dial.png")
    self.bgLayer:addChild(biaoPanSp)
    biaoPanSp:setScale(0.95)

    h=h-biaoPanSp:getContentSize().height/2-30
    biaoPanSp:setPosition(self.bgLayer:getContentSize().width/2, h)

    local function touchShouFei(tag,object)
    	if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local cost = acDiancitankeVoApi:getCost(tag,self.isMulc)
        local free = acDiancitankeVoApi:canReward()
        if free then
        	cost=0
        end
		if playerVoApi:getGems()<cost then
			GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
			return
		end
		self:clearMengSp()
		self.lastScore=acDiancitankeVoApi:getScore()
		local function callBack(fn,data)
			 local ret,sData = base:checkServerData(data)
			 if ret==true then
			 	playerVoApi:setGems(playerVoApi:getGems()-cost)
			 	self.tag=tag
			 	if free then
					acDiancitankeVoApi:setLastTime(sData.ts)
			        self.isToday=true
			        self:refresh()
				end
				if sData and sData.data and sData.data.diancitanke then
					acDiancitankeVoApi:setScore(sData.data.diancitanke.n)
				end
				
				self:startPalyAnimation()
				self:getRunAction(tag)
				self:setMengSp(tag)
			 end
		end
		socketHelper:acDiancitankeChoujiang(self.isMulc,tag,free,callBack)

    end
    local shouFeiH = 45
    shouFeiH=20
    local shouFeiItem1 = GetButtonItem("acDctk_BtnUp.png","acDctk_BtnDown.png","acDctk_BtnDown.png",touchShouFei,1,nil,25)
    local shouFeiMenu1 = CCMenu:createWithItem(shouFeiItem1);
    shouFeiMenu1:setPosition(ccp(140,shouFeiH));
    shouFeiMenu1:setTouchPriority(-(self.layerNum-1)*20-4);
    biaoPanSp:addChild(shouFeiMenu1,3);

    local shouFeiItem2 = GetButtonItem("acDctk_BtnUp.png","acDctk_BtnDown.png","acDctk_BtnDown.png",touchShouFei,2,nil,25)
    local shouFeiMenu2 = CCMenu:createWithItem(shouFeiItem2);
    shouFeiMenu2:setPosition(ccp(305,shouFeiH));
    shouFeiMenu2:setTouchPriority(-(self.layerNum-1)*20-4);
    biaoPanSp:addChild(shouFeiMenu2,3);
    self.shouFeiItem2=shouFeiItem2

    local shouFeiItem3 = GetButtonItem("acDctk_BtnUp.png","acDctk_BtnDown.png","acDctk_BtnDown.png",touchShouFei,3,nil,25)
    local shouFeiMenu3 = CCMenu:createWithItem(shouFeiItem3);
    shouFeiMenu3:setPosition(ccp(470,shouFeiH));
    shouFeiMenu3:setTouchPriority(-(self.layerNum-1)*20-4);
    biaoPanSp:addChild(shouFeiMenu3,3)
    self.shouFeiItem3=shouFeiItem3

     -- 添加指针刻度
    local rangeTb = acDiancitankeVoApi:getRange()
    self.rangeTb=rangeTb
    self.MaxRange = rangeTb[4]
    for i=1,4 do
    	local keduLb = GetTTFLabel(rangeTb[i],20)
    	biaoPanSp:addChild(keduLb)
    	if i==1 then
    		keduLb:setPosition(170, 140)
		elseif i==2 then
			keduLb:setPosition(230, 250)
		elseif i==3 then
			keduLb:setPosition(375, 250)
		else
			keduLb:setPosition(430, 140)
    	end
    end

    -- 添加三个波动范围
    local rangeH = 10
    rangeH=60
    local addValTb = acDiancitankeVoApi:getAddval()
    self.addValSmall = addValTb[1][2]
    self.addValMid = addValTb[2][2]
    self.addValBig = addValTb[3][2]
    for i=1,3 do
    	local rangeLb = GetTTFLabel(addValTb[i][1] .. "V" .. "-" .. addValTb[i][2] .. "V",20)
    	biaoPanSp:addChild(rangeLb)
    	if i==1 then
    		rangeLb:setPosition(140, rangeH)
		elseif i==2 then
			rangeLb:setPosition(305, rangeH)
		elseif i==3 then
			rangeLb:setPosition(470, rangeH)
    	end
    end


    -- acDctk_Pointer
    local zhizhenSp = CCSprite:createWithSpriteFrameName("acDctk_Pointer.png")
    zhizhenSp:setAnchorPoint(ccp(11/23,14/191))
    zhizhenSp:setPosition(biaoPanSp:getContentSize().width/2+2, 136)
    biaoPanSp:addChild(zhizhenSp)
    zhizhenSp:setScale(0.95)
    zhizhenSp:setRotation(-90)
    self.zhizhenSp=zhizhenSp

    self:setRotation(acDiancitankeVoApi:getScore())

    local smallBiaopanSp = CCSprite:createWithSpriteFrameName("acDctk_biaopan.png")
    smallBiaopanSp:setPosition(biaoPanSp:getContentSize().width/2+1, 152)
    smallBiaopanSp:setScale(0.95)
    biaoPanSp:addChild(smallBiaopanSp)

    -- smallBiaopanSp
    local myScore = 0
    if self.lastScore then
    	myScore= self.lastScore
    end
    local numLb = GetTTFLabel(myScore,25)
    smallBiaopanSp:addChild(numLb)
    numLb:setPosition(smallBiaopanSp:getContentSize().width/2, smallBiaopanSp:getContentSize().height/2-10)
    self.numLb=numLb


    AddProgramTimer(biaoPanSp,ccp(140,93),101,12,nil,"acDctk_di.png","acDctk_yellow.png",13,1,1)
    local timerSprite = biaoPanSp:getChildByTag(101)
    timerSprite=tolua.cast(timerSprite,"CCProgressTimer")
    timerSprite:setPercentage(100)
    self.oneMeng={}
    for i=1,6 do
    	local mengSp = CCSprite:createWithSpriteFrameName("acDctk_meng.png")
    	timerSprite:addChild(mengSp)
    	if i==1 then
    		mengSp:setPosition(12.5, 15 )
		elseif i==2 then
    		mengSp:setPosition(22, 31 )
    		mengSp:setRotation(30)
		elseif i==3 then
    		mengSp:setPosition(40, 40)
    		mengSp:setRotation(60)
		elseif i==4 then
    		mengSp:setPosition(60, 40)
    		mengSp:setRotation(90)
		elseif i==5 then
    		mengSp:setPosition(77.5, 30)
    		mengSp:setRotation(120)
		elseif i==6 then
    		mengSp:setPosition(86, 12)
    		mengSp:setRotation(150)
    	end
    	self.oneMeng[i]=mengSp
    	
    end

    AddProgramTimer(biaoPanSp,ccp(305,93),103,12,nil,"acDctk_di.png","acDctk_cheng.png",13,1,1)
    local timerSprite = biaoPanSp:getChildByTag(103)
    timerSprite=tolua.cast(timerSprite,"CCProgressTimer")
    timerSprite:setPercentage(100)
     self.twoMeng={}

      for i=1,6 do
    	local mengSp = CCSprite:createWithSpriteFrameName("acDctk_meng.png")
    	timerSprite:addChild(mengSp)
    	if i==1 then
    		mengSp:setPosition(12.5, 15 )
		elseif i==2 then
    		mengSp:setPosition(22, 31 )
    		mengSp:setRotation(30)
		elseif i==3 then
    		mengSp:setPosition(40, 40)
    		mengSp:setRotation(60)
		elseif i==4 then
    		mengSp:setPosition(60, 40)
    		mengSp:setRotation(90)
		elseif i==5 then
    		mengSp:setPosition(77.5, 30)
    		mengSp:setRotation(120)
		elseif i==6 then
    		mengSp:setPosition(86, 12)
    		mengSp:setRotation(150)
    	end
    	self.twoMeng[i]=mengSp
    	
    end

    AddProgramTimer(biaoPanSp,ccp(470,93),104,12,nil,"acDctk_di.png","acDctk_red.png",13,1,1)
    local timerSprite = biaoPanSp:getChildByTag(104)
    timerSprite=tolua.cast(timerSprite,"CCProgressTimer")
    timerSprite:setPercentage(100)
    self.threeMeng={}
      for i=1,6 do
    	local mengSp = CCSprite:createWithSpriteFrameName("acDctk_meng.png")
    	timerSprite:addChild(mengSp)
    	if i==1 then
    		mengSp:setPosition(12.5, 15 )
		elseif i==2 then
    		mengSp:setPosition(22, 31 )
    		mengSp:setRotation(30)
		elseif i==3 then
    		mengSp:setPosition(40, 40)
    		mengSp:setRotation(60)
		elseif i==4 then
    		mengSp:setPosition(60, 40)
    		mengSp:setRotation(90)
		elseif i==5 then
    		mengSp:setPosition(77.5, 30)
    		mengSp:setRotation(120)
		elseif i==6 then
    		mengSp:setPosition(86, 12)
    		mengSp:setRotation(150)
    	end
    	self.threeMeng[i]=mengSp
    	
    end
	

    for i=1,3 do
    	local item
    	if i==1 then
    		item=shouFeiItem1
		elseif i==2 then
    		item=shouFeiItem2
    	else
    		item=shouFeiItem3
		end
    	local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
		gemIcon:setAnchorPoint(ccp(0,0.5))
		gemIcon:setPosition(ccp(15, item:getContentSize().height/2))
		item:addChild(gemIcon)

		-- self.isMulc=true
		local cost = acDiancitankeVoApi:getCost(i,self.isMulc)
		local costLb = GetTTFLabel(cost, 28)
		costLb:setAnchorPoint(ccp(0,0.5))
		costLb:setPosition(ccp(50, item:getContentSize().height/2))
		item:addChild(costLb)

		if i==1 then
			self.costLb1=costLb
			self.gemIcon=gemIcon
		elseif i==2 then
			self.costLb2=costLb
		else
			self.costLb3=costLb
		end

    end


    -- 添加奖励图片
    self.reward = {}
    local reward = acDiancitankeVoApi:getReward()
    for i=1,SizeOfTable(reward) do
    	local item = FormatItem(reward[i])
    	self.reward[i]=item[1]
    end

    for i=1,SizeOfTable(reward) do
    	local callback = nil
    	local isShowInfo=true
    	if self.reward[i].type=="o" then
    		local function touchTankInfo()
    			local tankId = tonumber(RemoveFirstChar(self.reward[i].key))
		        tankInfoDialog:create(nil,tankId,self.layerNum+1)
		    end
    		callback=touchTankInfo
    		isShowInfo=false
		else
			local function touchInfo()
    			propInfoDialog:create(sceneGame,self.reward[i],self.layerNum+1,nil,nil,
    				nil,nil,nil,nil,true)
		    end
		    callback=touchInfo
		    isShowInfo=false
    	end
    	local sp,iconScale = G_getItemIcon(self.reward[i],80,isShowInfo,self.layerNum,callback,nil)
        sp:setTouchPriority(-(self.layerNum-1)*20-5)
    	-- local sp = CCSprite:createWithSpriteFrameName(self.reward[i].pic)
    	biaoPanSp:addChild(sp)
    	-- sp:setScale(0.8)
    	if i==1 then
    		sp:setPosition(70, 140)
		elseif i==2 then
			sp:setPosition(200, 340)
		elseif i==3 then
			sp:setPosition(400, 340)
		else
			sp:setPosition(540, 140)
    	end
    end

    local function touchHander()

	end

	local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchHander)
	backSprie:setAnchorPoint(ccp(0.5,0))
	backSprie:setContentSize(CCSize(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight - 625))
	backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
	self.bgLayer:addChild(backSprie)

	if(G_isIphone5())then
		acLabel:setPositionY(acLabel:getPositionY()-10)
		menu1:setPositionY(menu1:getPositionY()-30)
		biaoPanSp:setPositionY(biaoPanSp:getPositionY()-40)
		backSprie:setContentSize(CCSize(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight - 710))
		backSprie:setPositionY(backSprie:getPositionY()+25)
	end

	local function touchMulItem()
	  	if G_checkClickEnable()==false then
	        do
	            return
	        end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
	    end

	    PlayEffect(audioCfg.mouseClick)
	    if acDiancitankeVoApi:canReward() == true then
	    	-- 加提示文字
	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("isfree"),30)
	    	return
	    end

	    if self.isMulc == false then
	    	self.isMulc = true
	    	self.mulSp:setVisible(true)

	    else
	    	self.isMulc = false
	    	self.mulSp:setVisible(false)
	    end
	    self:refreshCost()
	end

	local mulX = 110
	local mulY = 40
	local bgSp = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touchMulItem,5,nil)
	bgSp:setAnchorPoint(ccp(0,0.5))
	self.selectBtn=CCMenu:createWithItem(bgSp)
	self.selectBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.selectBtn:setPosition(mulX-80,mulY)
	backSprie:addChild(self.selectBtn)


	-- 选中状态
	self.mulSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	self.mulSp:setAnchorPoint(ccp(0,0.5))
	self.mulSp:setPosition(mulX-80,mulY)
	backSprie:addChild(self.mulSp)
	self.mulSp:setVisible(false)

	mulX = mulX + bgSp:getContentSize().width + 10
	local widthSize = G_VisibleSizeWidth - mulX-10
	local PosW = mulX-80
	if G_getCurChoseLanguage() =="ar" then
		widthSize =mulX+10
		PosW =mulX-150
	end
	self.mulDesc=GetTTFLabelWrap(getlocal("activity_diancitanke_2tencostdes"),25,CCSizeMake(widthSize,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.mulDesc:setAnchorPoint(ccp(0,0.5))
	self.mulDesc:setPosition(PosW,mulY)
	backSprie:addChild(self.mulDesc)

	-- t10144_1.png
	local _,tankId = acDiancitankeVoApi:getTankID()
	local tankStr = "t" .. tankId .. "_1.png"
	local function touchaTank()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        tankInfoDialog:create(nil,tankId,self.layerNum+1)

	end
	local tankSp = LuaCCSprite:createWithSpriteFrameName(tankStr,touchaTank)
	tankSp:setAnchorPoint(ccp(1,0.5))
	tankSp:setScale(1.8)
	tankSp:setTouchPriority(-(self.layerNum-1)*20-4)
	tankSp:setPosition(backSprie:getContentSize().width-20,backSprie:getContentSize().height/2+20)
	backSprie:addChild(tankSp)
	-- tankSp:setVisible(false)

	local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(tankId);
    local baseAttack=tonumber(tankCfg[tankId].attack)+baseAttackAdd
    local baseLife=tonumber(tankCfg[tankId].life)+baseLifeAdd

	local typeStr = "pro_ship_attacktype_"..tankCfg[tankId].attackNum

	local iconHeight
	local startY=backSprie:getContentSize().height/2+30
	local addH=15
	if(G_isIphone5())then
		iconHeight=startY
	else
		iconHeight=startY
	end

	local scale = 0.7
	local starX=30
	local addIconW=80
	local addIconH=70

	local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
	attackTypeSp:setAnchorPoint(ccp(0,0.5));
	attackTypeSp:setPosition(ccp(starX,iconHeight+addIconH+addH))
	attackTypeSp:setScale(scale)
	backSprie:addChild(attackTypeSp,2)

	starX=starX+addIconW
	local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),20,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	attTypeLb:setAnchorPoint(ccp(0,0.5))
	attTypeLb:setPosition(ccp(starX,iconHeight+addIconH+addH))
	backSprie:addChild(attTypeLb)

    -- 攻击
    starX=30
    local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
	attackSp:setAnchorPoint(ccp(0,0.5));
	attackSp:setPosition(ccp(starX,iconHeight))
	attackSp:setScale(scale)
	backSprie:addChild(attackSp,2)

	starX=starX+addIconW
	local attLb=GetTTFLabel(tankCfg[tankId].attack,20)
	attLb:setAnchorPoint(ccp(0,0.5))
	attLb:setPosition(ccp(starX,iconHeight))
	backSprie:addChild(attLb)

	-- -- 生命
	starX=30
	local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
	lifeSp:setAnchorPoint(ccp(0,0.5))
	lifeSp:setPosition(ccp(starX,iconHeight-(addIconH+addH)))
	lifeSp:setScale(scale)
	backSprie:addChild(lifeSp,2)

	starX=starX+addIconW
	local lifeLb=GetTTFLabel(tankCfg[tankId].life,20)
	lifeLb:setAnchorPoint(ccp(0,0.5))
	lifeLb:setPosition(ccp(starX,iconHeight-(addIconH+addH)))
	backSprie:addChild(lifeLb)

	self:refresh()

	--播放动画按钮 first
	local function touchAction(tag,object )
		self:showBattle()
	end 
	local actionTouchFir = GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn.png",touchAction,nil,nil,0)
	actionTouchFir:setAnchorPoint(ccp(1,0))
	local actionTouchFirMenu = CCMenu:createWithItem(actionTouchFir)
	actionTouchFirMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	actionTouchFirMenu:setPosition(ccp(backSprie:getContentSize().width-20,10))
	backSprie:addChild(actionTouchFirMenu)
    

end

function acDiancitankeTab1:showBattle()
	local battleStr=acDiancitankeVoApi:returnTankData()
	local report=G_Json.decode(battleStr)
	local isAttacker=true
	local data={data={report=report},isAttacker=isAttacker,isReport=true}
	battleScene:initData(data)
end

-- 刷新金币显示
function acDiancitankeTab1:refresh()
	local isCanReward = acDiancitankeVoApi:canReward()
	self:refreshCost()
	if isCanReward then
		self.shouFeiItem2:setEnabled(false)
		self.shouFeiItem3:setEnabled(false)
		self.costLb1:setString(getlocal("daily_lotto_tip_2"))
		local costLbWidthPos = 20
		if G_getCurChoseLanguage() =="ru" then
			self.costLb1:setFontSize(19)
			costLbWidthPos=40
		end
		self.costLb1:setPositionX(self.costLb2:getPositionX()-costLbWidthPos)
		self.gemIcon:setVisible(false)
	else
		self.shouFeiItem2:setEnabled(true)
		self.shouFeiItem3:setEnabled(true)
		self.costLb1:setPositionX(self.costLb2:getPositionX())
		self.costLb1:setVisible(true)
		self.costLb1:setFontSize(28)
		self.gemIcon:setVisible(true)
	end
end

-- 刷新金币
function acDiancitankeTab1:refreshCost()
	local cost1 = acDiancitankeVoApi:getCost(1,self.isMulc)
	local cost2 = acDiancitankeVoApi:getCost(2,self.isMulc)
	local cost3 = acDiancitankeVoApi:getCost(3,self.isMulc)
	self.costLb1:setString(cost1)
	self.costLb2:setString(cost2)
	self.costLb3:setString(cost3)
end

-- 刷新十倍模式
function acDiancitankeTab1:refreshNb()
	self.isMulc=false
	self.mulSp:setVisible(false)

end

function acDiancitankeTab1:tick()
	if acDiancitankeVoApi:isToday()==false and self.isToday==true then
	    self.isToday=false
	    self:refreshNb()
	  	self:refresh()
	  	self:clearMengSp()
	end
	self:updateAcTime()
end

function acDiancitankeTab1:fastTick()
	if self.state == 2 then
		self.zhizhenSp:stopAllActions()
		self:setRotation(acDiancitankeVoApi:getScore())
		self:stopPlayAnimation()
	end
end

function acDiancitankeTab1:startPalyAnimation()
	self.state = 1
	self.touchDialogBg:setIsSallow(true) -- 防止事件透下去
	
end

function acDiancitankeTab1:stopPlayAnimation()
	self.state = 0
	self:aftetGetReward()
	self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
end

function acDiancitankeTab1:aftetGetReward()
	local score = acDiancitankeVoApi:getScore()
	self.numLb:setString(score)
	local itemY
	if score>=self.rangeTb[4] then
		itemY=self.reward[4]
	elseif score>=self.rangeTb[3] then
		itemY=self.reward[3]
	elseif score>=self.rangeTb[2] then
		itemY=self.reward[2]
	elseif score>=self.rangeTb[1] then
		itemY=self.reward[1]
	end

	local item = G_clone(itemY)
	if self.isMulc then
		item.num=item.num*acDiancitankeVoApi:getMul()
	end
	local reward={item}
	local str = getlocal("activity_diancitanke_getReward",{self:getChaScore(self.tag),item.name,item.num})
	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
	G_addPlayerAward(item.type,item.key,item.id,item.num,nil,true)
	if  self.isMulc and score>=self.rangeTb[4] then
		local message={key="activity_diancitanke_reward",param={playerVoApi:getPlayerName(),getlocal("activity_diancitanke_title1"),item.name,item.num}}
          chatVoApi:sendSystemMessage(message)
	end
		
    -- G_showRewardTip(reward,true)
end

function acDiancitankeTab1:getChaScore(tag)
	local score = acDiancitankeVoApi:getScore()
	local shuaijianScore = math.ceil(self.lastScore*acDiancitankeVoApi:getDecay(tag))
	return score-shuaijianScore
end



function acDiancitankeTab1:scoreToRadial(score)
	return score*(180/self.MaxRange)
end

function acDiancitankeTab1:setRotation(score)
	local rotation = self:scoreToRadial(score)
	if rotation>180 then
		rotation=180
	elseif rotation<0 then
		rotation=0
	end
	self.zhizhenSp:setRotation(rotation-90)
end

function acDiancitankeTab1:getRotation(score)
	local rotation = self:scoreToRadial(score)
	if rotation>180 then
		rotation=180
	elseif rotation<0 then
		rotation=0
	end
	return rotation
end

function acDiancitankeTab1:getRunAction(tag)
	local shuaijianScore = math.ceil(self.lastScore*acDiancitankeVoApi:getDecay(tag))
	local rotation0 = self:getRotation(self.lastScore)
	local rotation1 = self:getRotation(shuaijianScore)
	local s1 = math.abs((rotation1-rotation0)/60)
	local rotation2 = self:getRotation(acDiancitankeVoApi:getScore())
	local s2 = math.abs((rotation2-rotation1)/60)
	local rotation3 = rotation2+5
	local s3 = 5/60
	local rotation4 = rotation2-5
	local s4 = 10/60

	
	if rotation3>180 then
		rotation3=180
	end
	if rotation4<0 then
		rotation4=0
	end
	local acArr=CCArray:create()
	local actRo1 = CCRotateTo:create(s1,rotation1-90)
	local actRo2 = CCRotateTo:create(s2,rotation2-90)
	local actRo3 = CCRotateTo:create(s3,rotation3-90)
	local actRo4 = CCRotateTo:create(s4,rotation4-90)
	local actRo5 = CCRotateTo:create(s3,rotation2-90)

	local function setChuaijian()
		self.numLb:setString(shuaijianScore)
	end
	local callFunc1=CCCallFunc:create(setChuaijian)

	local function stopac()
		self:stopPlayAnimation()
	end
	local callFunc2=CCCallFunc:create(stopac)
	local delay=CCDelayTime:create(0.5)

	 acArr:addObject(actRo1) -- 衰减
	 acArr:addObject(callFunc1)  -- 设置衰减值
	 acArr:addObject(delay)  -- 停顿
	 acArr:addObject(actRo2)  -- 回复到正确
	 acArr:addObject(actRo3)  -- 正确+5
	 acArr:addObject(actRo4)  -- 正确-5
	 acArr:addObject(actRo5)  -- 正确
	 acArr:addObject(callFunc2)  -- 设置停止状态

	local seq=CCSequence:create(acArr)
	self.zhizhenSp:runAction(seq)

end

function acDiancitankeTab1:clearMengSp()
	for i=1,6 do
		self.oneMeng[i]:setVisible(true)
		self.twoMeng[i]:setVisible(true)
		self.threeMeng[i]:setVisible(true)
	end
end

function acDiancitankeTab1:setMengSp(tag)
	local mengTb
	local bianhuaScore = self:getChaScore(tag)
	-- local score = acDiancitankeVoApi:getScore()
	local num=0
	if tag==1 then
		mengTb=self.oneMeng
		num=math.ceil(bianhuaScore*6/self.addValSmall)
	elseif tag==2 then
		mengTb=self.twoMeng
		num=math.ceil(bianhuaScore*6/self.addValMid)
	elseif tag==3 then
		mengTb=self.threeMeng
		num=math.ceil(bianhuaScore*6/self.addValBig)
	end
	for i=1,6 do
		if i>num then
			mengTb[i]:setVisible(true)
		else
			mengTb[i]:setVisible(false)
		end
		
	end
	
end

function acDiancitankeTab1:updateAcTime()
    local acVo=acDiancitankeVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acDiancitankeTab1:dispose()
	self.bgLayer=nil
    self.layerNum=nil
	self.mulSp=nil
	self.isMulc=nil
	self.costLb1=nil
	self.gemIcon=nil
	self.shouFeiItem2=nil
	self.shouFeiItem3=nil
	self.isToday=nil
	self.touchDialogBg=nil
	self.lastScore=nil
	self.state = nil
	self.MaxRange = nil
	self.addValSmall = nil
    self.addValMid = nil
    self.addValBig = nil
    self.rangeTb = nil
    self.tag = nil
    self.timeLb=nil

end