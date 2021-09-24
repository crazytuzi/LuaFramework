acSecretshopDialogTab2={}

function acSecretshopDialogTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.selectPropTb={}
	return nc
end

function acSecretshopDialogTab2:init(layerNum)
	self.adaH = 0
	if G_getIphoneType() == G_iphoneX then
		self.adaH = 30
	end
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.inputTb=acSecretshopVoApi:getInputList()
	self:initLayer1()
	return self.bgLayer
end
function acSecretshopDialogTab2:initLayer1(  )
	local startH=G_VisibleSize.height-160
	local upBgH=282
	local function touchUp()
	end
	local bgWidth=613
	local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchUp)
	upBg:setContentSize(CCSizeMake(bgWidth,upBgH))
    upBg:ignoreAnchorPointForPosition(false)
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setTouchPriority(-(self.layerNum-1)*20-1)
	upBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,startH))
    self.bgLayer:addChild(upBg)
    self.upBg=upBg

    self:initUP()

    local downBgH=startH-upBgH-30

    local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(10,10,12,12),touchUp)
	downBg:setContentSize(CCSizeMake(bgWidth,downBgH))
    downBg:ignoreAnchorPointForPosition(false)
    downBg:setAnchorPoint(ccp(0.5,0))
    downBg:setTouchPriority(-(self.layerNum-1)*20-1)
	downBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
    self.bgLayer:addChild(downBg)
    self.downBg=downBg
    -- downBg:setOpacity(0)

    self:initDown()
end

function acSecretshopDialogTab2:initUP()

	local function touchTip()
        local tabStr={getlocal("activity_secretshop_tip1"),getlocal("activity_secretshop_tip2"),getlocal("activity_secretshop_tip3")}

        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
	local pos=ccp(self.upBg:getContentSize().width-50,self.upBg:getContentSize().height-50)
	local tabStr={}
	G_addMenuInfo(self.upBg,self.layerNum,pos,tabStr,nil,nil,28,touchTip,true)

	local bgSp=CCSprite:createWithSpriteFrameName("acSecretshop_bg2.png")
	self.upBg:addChild(bgSp)
	bgSp:setPosition(getCenterPoint(self.upBg))
	self.bgSp=bgSp

	-- 选择兑换的道具

	local function touchAdd()
		local function refreshFunc(selectInfo)

			if self.targetInfo and self.targetInfo.key==selectInfo.key then
				do return end
			else
				self:clear()
			end
			self.targetInfo=selectInfo

			local value=self.targetInfo.value
			local reward=value.r
			local rewardItem=FormatItem(reward)[1]
			self.inputTb=acSecretshopVoApi:getInputList(rewardItem)
			local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)

			self:refreshAddSp()
			self:setSelectId(1)
			self:setSliderLimit()
		end
		acSecretshopVoApi:showChangeDialog(self.layerNum+1,true,true,refreshFunc,getlocal("activity_secretshop_select_target"))
	end
	local addSp=LuaCCSprite:createWithSpriteFrameName("acSecretshop_add.png",touchAdd)
	bgSp:addChild(addSp)
	addSp:setPosition(getCenterPoint(bgSp))
	addSp:setTouchPriority(-(self.layerNum-1)*20-4)
	self.addSp=addSp

	local fadeTo = CCFadeTo:create(1, 55)
	local fadeBack = CCFadeTo:create(1, 255)
	local acArr = CCArray:create()
	acArr:addObject(fadeTo)
	acArr:addObject(fadeBack)
	local seq = CCSequence:create(acArr)
	addSp:runAction(CCRepeatForever:create(seq))



	local timerSp1 = CCSprite:createWithSpriteFrameName("acSecretshop_blueCircle.png")
	local progressTimer1 = CCProgressTimer:create(timerSp1)
	progressTimer1:setPosition(getCenterPoint(bgSp))
	progressTimer1:setType(kCCProgressTimerTypeRadial)
	bgSp:addChild(progressTimer1)
	progressTimer1:setPercentage(0)
	self.progressTimer1=progressTimer1

	local timerSp2 = CCSprite:createWithSpriteFrameName("acSecretshop_yellowCircle.png")
	local progressTimer2 = CCProgressTimer:create(timerSp2)
	progressTimer2:setPosition(getCenterPoint(bgSp))
	progressTimer2:setType(kCCProgressTimerTypeRadial)
	bgSp:addChild(progressTimer2)
	progressTimer2:setPercentage(0)
	self.progressTimer2=progressTimer2

	local selectTargetLb=GetTTFLabelWrap(getlocal("activity_secretshop_select_des"),22,CCSizeMake(bgSp:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	bgSp:addChild(selectTargetLb)
	selectTargetLb:setPosition(bgSp:getContentSize().width/2,15)
	selectTargetLb:setColor(G_ColorYellowPro)
	self.selectTargetLb=selectTargetLb

	local targetNameLb=GetTTFLabelWrap("",22,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	bgSp:addChild(targetNameLb)
	targetNameLb:setPosition(bgSp:getContentSize().width/2,15)
	self.targetNameLb=targetNameLb
	targetNameLb:setVisible(false)

	local alreadyChangeLb=GetTTFLabelWrap(getlocal("activity_secretshop_already_change",{0}),22,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	bgSp:addChild(alreadyChangeLb)
	alreadyChangeLb:setAnchorPoint(ccp(0,0.5))
	alreadyChangeLb:setPosition(10,15)
	self.alreadyChangeLb=alreadyChangeLb
	alreadyChangeLb:setVisible(false)

	local addNumLb=GetTTFLabel("",22)
	bgSp:addChild(addNumLb)
	addNumLb:setAnchorPoint(ccp(0,0.5))
	addNumLb:setPosition(bgSp:getContentSize().width/2+100,15)
	addNumLb:setColor(G_ColorGreen)
	self.addNumLb=addNumLb

	local maxLb=GetTTFLabel("Max",22)
	bgSp:addChild(maxLb)
	maxLb:setAnchorPoint(ccp(0,0.5))
	maxLb:setPosition(bgSp:getContentSize().width/2+250,15)
	maxLb:setColor(G_ColorYellowPro)
	self.maxLb=maxLb
	self.maxLb:setVisible(false)

	local numBg=CCSprite:createWithSpriteFrameName("acSecretshop_numBg.png")
	bgSp:addChild(numBg)
	numBg:setPosition(bgSp:getContentSize().width/2,bgSp:getContentSize().height-20)
	self.numBg=numBg
	self.numBg:setVisible(false)

	local totalNumLb=GetTTFLabel("",18)
	numBg:addChild(totalNumLb)
	totalNumLb:setPosition(numBg:getContentSize().width/2,numBg:getContentSize().height/2+5)
	self.totalNumLb=totalNumLb

end

function acSecretshopDialogTab2:refreshAddSp()
	local value=self.targetInfo.value
	local reward=value.r
	local rewardItem=FormatItem(reward)[1]

	local rewardSp=tolua.cast(self.addSp:getChildByTag(133),"CCSprite")
	if rewardSp then
		rewardSp:removeFromParentAndCleanup(true)
	end
	rewardSp=G_getItemIcon(rewardItem,100,nil,self.layerNum + 1)
	self.addSp:addChild(rewardSp)
	rewardSp:setPosition(getCenterPoint(self.addSp))
	rewardSp:setTag(133)

	local pointBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),function ( ... )end)
    pointBg:setContentSize(CCSizeMake(95,30))
    rewardSp:addChild(pointBg)
    pointBg:setScale(1/rewardSp:getScale())
    pointBg:setPosition(rewardSp:getContentSize().width/2,15)
    pointBg:setOpacity(120)

	local pointLb=GetTTFLabel("+" .. value.needp,22)
    rewardSp:addChild(pointLb)
    pointLb:setAnchorPoint(ccp(0.5,0))
    pointLb:setScale(1/rewardSp:getScale())
    pointLb:setPosition(rewardSp:getContentSize().width/2,5)
    pointLb:setColor(G_ColorGreen)

    local kuangSp=CCSprite:createWithSpriteFrameName("TeamTankSelected.png")
    rewardSp:addChild(kuangSp)
    kuangSp:setPosition(getCenterPoint(rewardSp))
    kuangSp:setScale(110/kuangSp:getContentSize().width)


	self.selectTargetLb:setVisible(false)
	self.targetNameLb:setString(rewardItem.name)
	self.targetNameLb:setVisible(true)


	local changeNum=acSecretshopVoApi:getChangeNum(self.targetInfo.key)
	self.alreadyChangeLb:setString(getlocal("activity_secretshop_already_change",{changeNum .. "/" .. value.maxtimes}))
	self.numBg:setVisible(true)
	if value.maxtimes==0 then
		self.alreadyChangeLb:setVisible(false)
		-- self.numBg:setVisible(false)
		self.totalNumLb:setString(0)
	else
		self.alreadyChangeLb:setVisible(true)
		-- self.numBg:setVisible(true)
		self.totalNumLb:setString(0 .. "/" .. (value.maxtimes-changeNum)*value.needp)
	end
	
	
end

function acSecretshopDialogTab2:initDown()

	local selectPosY=self.downBg:getContentSize().height-10
	local selectLb=GetTTFLabelWrap(getlocal("activity_secretshop_select_prop"),24,CCSizeMake(610-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	selectLb:setAnchorPoint(ccp(0,1))
	self.downBg:addChild(selectLb)
	selectLb:setPosition(20,selectPosY-self.adaH/3)
	selectPosY = selectPosY - self.adaH

	local tvH=395

	if(G_isIphone5()==false)then
		tvH=230
	end

	local tvPosY=selectPosY-selectLb:getContentSize().height-tvH-10


	self.cellHight=400
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.downBg:getContentSize().width,tvH),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(0,tvPosY)
	self.downBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)

	local function forbidClick()
	end
	local upforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),forbidClick)
	self.downBg:addChild(upforbidSp)
	upforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	upforbidSp:setAnchorPoint(ccp(0.5,0))
	upforbidSp:setPosition(G_VisibleSizeWidth/2,tvPosY+tvH)
	-- 下
	local downforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),forbidClick)
	self.downBg:addChild(downforbidSp)
	downforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	downforbidSp:setAnchorPoint(ccp(0.5,1))
	downforbidSp:setPosition(G_VisibleSizeWidth/2,tvPosY)
	upforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	downforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	upforbidSp:setVisible(false)
	downforbidSp:setVisible(false)


	if G_getIphoneType() == G_iphoneX then
		tvPosY = tvPosY - 30
	end	
	-- slider
	local numLbH=tvPosY-5-10
	local selectNumLb=GetTTFLabelWrap(getlocal("activity_secretshop_select_num"),24,CCSizeMake(610-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	selectNumLb:setAnchorPoint(ccp(0,1))
	self.downBg:addChild(selectNumLb)
	selectNumLb:setPosition(20,numLbH+self.adaH/2)

	local sliderH=numLbH-selectNumLb:getContentSize().height-30

	local function sliderTouch(handler,object)
		local valueNum = tonumber(string.format("%.2f", object:getValue()))
		local count = math.ceil(valueNum)
		if self.m_numLb then
	        self.m_numLb:setString(count)
	    end
        self:setChangeList(count)
	end
	local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png");
    local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png")
    self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    self.slider:setTouchPriority(-(self.layerNum-1)*20-5);
    self.slider:setIsSallow(true)
    self.slider:setPosition(ccp(340,sliderH))
    self.downBg:addChild(self.slider,2)
    self.slider:setValue(0)

    local function touchAdd()
        self.slider:setValue(self.slider:getValue()+1);
    end
    
    local function touchMinus()
        if self.slider:getValue()-1>=0 then
            self.slider:setValue(self.slider:getValue()-1);
        end
    
    end
    
    local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
    addSp:setPosition(ccp(560,sliderH))
    self.downBg:addChild(addSp,1)
    -- addSp:setTouchPriority(-(self.layerNum-1)*20-4);

	local addSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,6,6),touchAdd)
	addSp:setContentSize(CCSizeMake(100,50))
	addSp:setAnchorPoint(ccp(0,0.5))
	addSp:setPosition(ccp(535,sliderH))
	addSp:setTouchPriority(-(self.layerNum-1)*20-4)
	self.downBg:addChild(addSp)
	addSp:setVisible(false)
    
    
    local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
    minusSp:setPosition(ccp(125,sliderH))
    self.downBg:addChild(minusSp,1)
    -- minusSp:setTouchPriority(-(self.layerNum-1)*20-4);

    local minusSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,6,6),touchMinus)
	minusSp:setContentSize(CCSizeMake(100,50))
	minusSp:setAnchorPoint(ccp(1,0.5))
	minusSp:setPosition(ccp(150,sliderH))
	minusSp:setTouchPriority(-(self.layerNum-1)*20-4)
	self.downBg:addChild(minusSp)
	minusSp:setVisible(false)

    local bgSp = CCSprite:createWithSpriteFrameName("proBar_n2.png");
    bgSp:setScaleX(85/bgSp:getContentSize().width)
    bgSp:setAnchorPoint(ccp(0.5,0.5));
    bgSp:setPosition(60,sliderH);
    self.downBg:addChild(bgSp,1)

    local m_numLb=GetTTFLabel(0,30)
    m_numLb:setPosition(60,sliderH);
    self.downBg:addChild(m_numLb,2);
    self.m_numLb=m_numLb

    local menuH=sliderH-30-60

	if G_getIphoneType() == G_iphoneX then
 		menuH = menuH - 30
	end
    local function touchAddFunc()
		if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		    if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime()
		    end
		    PlayEffect(audioCfg.mouseClick)

		    -- 兑换
		    if self.targetInfo==nil then
		    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_secretshop_select_des"),30)
		    	do return end
		    end

		    local sid=self.targetInfo.key
		    local value=self.targetInfo.value
		    local needp=value.needp
		    local maxtimes=value.maxtimes

		    local totalNeedPoint=0
		    if maxtimes==0 then
		    	totalNeedPoint=1000*value.needp
		    else
		    	local changeNum=acSecretshopVoApi:getChangeNum(sid)
		    	totalNeedPoint=(maxtimes-changeNum)*needp
		    end

		    -- table.insert(self.changeList,{p1Sp=p1Sp,numLb=numLb,haveNum=v.haveNum,rewardSp=rewardSp})

		    local totalPoint=totalNeedPoint
		    for k,v in pairs(self.inputTb) do
		    	if v.haveNum==0 then
		    		break
		    	else
		    		local count=0
		    		if totalPoint<=0 then
		    			count=0
		    		else
		    			local provideExp=v.haveNum*v.point
		    			if provideExp<totalPoint then
		    				totalPoint=totalPoint-provideExp
		    				count=v.haveNum
		    			else
		    				count=math.ceil(totalPoint/v.point)
		    				totalPoint=0
		    			end
		    		end

		    		self:setChangeList(count,k)

					if k==self.selectId then
						self.slider:setValue(count)
					end
					
		    	end

		    end
		   
		end
	end
	local scale=160/207
	local addMenuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touchAddFunc,1,getlocal("activity_secretshop_key_add"),24/scale)
	addMenuItem:setScale(scale)
	local addMenu = CCMenu:createWithItem(addMenuItem)
	self.downBg:addChild(addMenu,1)
	addMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	addMenu:setBSwallowsTouches(true)
	addMenu:setPosition(self.downBg:getContentSize().width/2-140,menuH)

	local function touchChangeFunc()
		if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		    if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime()
		    end
		    PlayEffect(audioCfg.mouseClick)

		    -- 兑换
		    if self.targetInfo==nil then
		    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_secretshop_select_des"),30)
		    	do return end
		    end

		    local sid=self.targetInfo.key
		    local value=self.targetInfo.value
		    local needp=value.needp
		    local resp={}
		    -- self.inputTb
		    local totalNum=0
		    for k,v in pairs(self.selectPropTb) do
		    	if v>0 then
		    		local key=self.inputTb[k].key
		    		resp[key]=v
		    		totalNum=totalNum+self.inputTb[k].point*v
		    	end
		    end

		    if totalNum<needp then
		    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_secretshop_change_des1"),30)
		    	do return end
		    end

		    local cost=tonumber(self.costLb1:getString())
		    local gems=playerVoApi:getGems() or 0
            if cost>gems then
                local function onSure()
                    activityAndNoteDialog:closeAllDialog()
                end
                GemsNotEnoughDialog(nil,nil,cost-gems,self.layerNum+1,cost,onSure)
                return
            end

		    -- print("++++++totalNum",totalNum,sid)
		    local function refreshFunc()
		    	playerVoApi:setGems(playerVoApi:getGems() - cost)
		    	for k,v in pairs(self.selectPropTb) do
		    		if v>0 then
		    			local rewardItem=self.inputTb[k].rewardItem
		    			local rType=rewardItem.type
			    		local RKey=rewardItem.key
			    		if rType=="p" then
			    			local id=(tonumber(RKey) or tonumber(RemoveFirstChar(RKey)))
							bagVoApi:useItemNumId(id,v)
		    			end
			    	end
				end	
		    	local num=math.floor(totalNum/needp)
				local reward=value.r
				local rewardItem=FormatItem(reward)
				rewardItem[1].num=rewardItem[1].num*num
				G_addPlayerAward(rewardItem[1].type,rewardItem[1].key,rewardItem[1].id,rewardItem[1].num,nil,true)

		    	local function endCallback()
		    		G_showRewardTip(rewardItem,true,nil,true)
			    end
		        local titleStr=getlocal("activity_wheelFortune4_reward")
		        require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
		        rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardItem,endCallback,titleStr)

		    	self:clear()
		    end
		    
		    local function sureClick1()
			    local function sureClick()
	                acSecretshopVoApi:socketchange(sid,resp,refreshFunc)
	            end
	            local function secondTipFunc(sbFlag)
	                local keyName=acSecretshopVoApi:getActiveName()
	                local sValue=base.serverTime .. "_" .. sbFlag
	                G_changePopFlag(keyName,sValue)
	            end
	            if cost and cost>0 then
	                local keyName=acSecretshopVoApi:getActiveName()
	                if G_isPopBoard(keyName) then
	                    self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,sureClick,secondTipFunc)
	                else
	                    sureClick()
	                end
	            else
	                sureClick()
	            end
			end
			if totalNum%needp==0 then
				sureClick1()
			else
				local shang=math.floor(totalNum/needp)
				G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("activity_secretshop_change_des2",{totalNum-shang*needp}),false,sureClick1)
			end
		    

		end
	end
	local scale=160/207
	local changeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touchChangeFunc,1,getlocal("code_gift"),24/scale)
	changeItem:setScale(scale)
	local changeMenu = CCMenu:createWithItem(changeItem)
	self.downBg:addChild(changeMenu,1)
	changeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	changeMenu:setBSwallowsTouches(true)
	changeMenu:setPosition(self.downBg:getContentSize().width/2+140,menuH)
	self.changeItem=changeItem

	local costLb1=GetTTFLabel("0",22/scale)
	changeItem:addChild(costLb1)
	costLb1:setPositionY(changeItem:getContentSize().height+20)
	costLb1:setVisible(false)
	self.costLb1=costLb1
	local iconGold1=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold1:setScale(1/scale*0.8)
	changeItem:addChild(iconGold1)
	iconGold1:setPositionY(changeItem:getContentSize().height+20)
	G_setchildPosX(changeItem,costLb1,iconGold1)
	iconGold1:setVisible(false)
	self.iconGold1=iconGold1

	self:setSliderLimit()
end

function acSecretshopDialogTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(610,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cellWidth=610

		local startH=self.cellHight-5-50
		local startW=20+50
		local subH=130
		local numLbH
		local inputTb=self.inputTb

		self.changeList={}
		for k,v in pairs(inputTb) do
	        local rewardItem=v.rewardItem
	        local ys=k%5
	        if ys==0 then
	            ys=5
	        end
	        local shang=math.ceil(k/5)

	        local posX=startW+(ys-1)*117
	        local posY=startH-(shang-1)*subH
	        numLbH=posY
	        local function touchInfo()
	        	if v.haveNum==0 then
	        		return false
	        	end
	        	if self.targetInfo==nil then
	        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_secretshop_select_des"),30)
	        		return false
	        	end
	        	if self.selectId==nil then
	        		return false
	        	end
	        	if self.selectPropTb[k] and self.selectPropTb[k]>0 then
	        		if self.selectId==k then
	        			self.m_numLb:setString(0)
	        		end
	        		self:setChangeList(0,k)
	        		return false
	        	end
	        	self:setSelectId(k)
	        	self.slider:setValue(0)
	        	self:setSliderLimit()
	        	return false
	        end
	        local rewardSp=G_getItemIcon(rewardItem,100,true,self.layerNum + 1,touchInfo)
	        cell:addChild(rewardSp)
	        rewardSp:setPosition(posX,posY)
	        rewardSp:setTouchPriority(-(self.layerNum-1)*20-2)

	        local pointBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),function ( ... )end)
	        pointBg:setContentSize(CCSizeMake(95,30))
	        rewardSp:addChild(pointBg)
	        pointBg:setScale(1/rewardSp:getScale())
	        pointBg:setPosition(rewardSp:getContentSize().width/2,15)
	        pointBg:setOpacity(120)

	        local pointLb=GetTTFLabel("+" .. v.point,22)
	        rewardSp:addChild(pointLb)
	        pointLb:setAnchorPoint(ccp(0.5,0))
	        pointLb:setScale(1/rewardSp:getScale())
	        pointLb:setPosition(rewardSp:getContentSize().width/2,5)
	        pointLb:setColor(G_ColorGreen)

	        local numLb=GetTTFLabel(0 .. "/" .. v.haveNum,22)
	        cell:addChild(numLb)
	        numLb:setPosition(posX,posY-65)

	        local p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
	        rewardSp:addChild(p1Sp)
	        p1Sp:setAnchorPoint(ccp(1,1))
	        p1Sp:setPosition(rewardSp:getContentSize().width,rewardSp:getContentSize().height)
	        p1Sp:setScale(1/p1Sp:getScale())
	        p1Sp:setVisible(false)

	        table.insert(self.changeList,{p1Sp=p1Sp,numLb=numLb,haveNum=v.haveNum,rewardSp=rewardSp})
	        if self.selectPropTb and self.selectPropTb[k] and self.selectPropTb[k]>0 then
	        	p1Sp:setVisible(true)
	        	numLb:setString(self.selectPropTb[k] .. "/" .. v.haveNum)
	        	numLb:setColor(G_ColorYellowPro)
	        end
	        if k==1 then
	        	self.selectSp=CCSprite:createWithSpriteFrameName("TeamTankSelected.png")
                cell:addChild(self.selectSp,3)
                self.selectSp:setPosition(posX-3,posY+4)
                self.selectSp:setVisible(false)
                self.selectSp:setScale(110/self.selectSp:getContentSize().width)
	        end

	        if v.haveNum==0 then
	        	local blackBg = CCSprite:createWithSpriteFrameName("acSecretshop_gray.png")
	        	cell:addChild(blackBg)
	        	blackBg:setPosition(posX,posY)
	        	blackBg:setOpacity(120)
	        	numLb:setColor(G_ColorGray)
	        end
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end



function acSecretshopDialogTab2:tick()
end

function acSecretshopDialogTab2:refresh()
	local posX,posY
	if self.targetInfo then
		local value=self.targetInfo.value
		local reward=value.r
		local rewardItem=FormatItem(reward)[1]
		self.inputTb=acSecretshopVoApi:getInputList(rewardItem)
		posX,posY=self.selectSp:getPosition()
	else
		self.inputTb=acSecretshopVoApi:getInputList()
	end

	local recordPoint=self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)

	if self.targetInfo then
		self.selectSp:setVisible(true)
		self.selectSp:setPosition(posX,posY)
	end
	
end


function acSecretshopDialogTab2:fastTick()
	
end

function acSecretshopDialogTab2:setSliderLimit()
	-- self.slider
	if self.targetInfo==nil or self.selectId==nil then
		self.slider:setMinimumValue(0)
	    self.slider:setMaximumValue(0)
	    do return end
	end
	local info=self.inputTb[self.selectId]
	if info.haveNum==0 then
		self.slider:setMinimumValue(0)
	    self.slider:setMaximumValue(0)
	    self.selectId=nil
	    do return end
	end

	self.slider:setMinimumValue(0)
    self.slider:setMaximumValue(info.haveNum)

end


function acSecretshopDialogTab2:setSelectId(selectId)
	self.selectId=selectId
	if self.selectId==nil then
		self.selectSp:setVisible(false)
	else
		self.selectSp:setVisible(true)
		local rewardSp=self.changeList[self.selectId].rewardSp
		self.selectSp:setPosition(rewardSp:getPosition())
	end
end

function acSecretshopDialogTab2:setChangeList(count,selectId)
	if self.selectId==nil then
		do return end
	end
	if selectId==nil then
		selectId=self.selectId
	end
	self.selectPropTb[selectId]=count
	local totalExp=self:getTotalExp()
	local value=self.targetInfo.value
    local needp=value.needp

    if value.maxtimes~=0 then
    	local canChangeNum=math.floor(totalExp/needp)
    	local alreadyNum=acSecretshopVoApi:getChangeNum(self.targetInfo.key)
    	if canChangeNum>=value.maxtimes-alreadyNum and (not self.setFlag) and selectId==self.selectId then
    		-- 计算 count
    		local myCount=count-1
    		while (true) do 
    			self.selectPropTb[selectId]=myCount
    			local totalExp=self:getTotalExp()
    			local canChangeNum=math.floor(totalExp/needp)
    			if canChangeNum>=value.maxtimes-alreadyNum then
    				myCount=myCount-1
    			else
    				break
    			end
    		end

    		-- 防止死循环
    		self.setFlag=true
    		-- print("myCountmyCount",myCount)
    		self.slider:setValue(myCount+1)
    		return
    	end
    	self.setFlag=false

    	if canChangeNum>=value.maxtimes-alreadyNum then
    		self.maxLb:setVisible(true)
    	else
    		self.maxLb:setVisible(false)
    	end
    		
    else

    end

    local alreadyNum=acSecretshopVoApi:getChangeNum(self.targetInfo.key)
    if value.maxtimes==0 then
    	self.totalNumLb:setString(totalExp)
    else
    	self.totalNumLb:setString(totalExp .. "/" .. (value.maxtimes-alreadyNum)*value.needp)
    end
    

	local p1Sp=self.changeList[selectId].p1Sp
	local haveNum=self.changeList[selectId].haveNum
	local numLb=self.changeList[selectId].numLb
	numLb:setString(count .. "/" .. haveNum)

	if count>0 then
		p1Sp:setVisible(true)
		numLb:setColor(G_ColorYellowPro)
	else
		p1Sp:setVisible(false)
		numLb:setColor(G_ColorWhite)
	end
	

	

    -- print("totalExptotalExptotalExp",totalExp)
    if totalExp<needp then
    	self.costLb1:setString(math.ceil(value.cost))
    	self.addNumLb:setVisible(false)

    	self.progressTimer1:setPercentage(totalExp/needp*100)
    	self.progressTimer2:setPercentage(0)
    else
    	local num=math.floor(totalExp/needp)
    	self.costLb1:setString(math.ceil(num*value.cost))

    	self.addNumLb:setString(getlocal("activity_secretshop_can_change",{"+" .. FormatNumber(num)}))
    	self.addNumLb:setVisible(true)

    	if num%2==0 then

    		self.progressTimer1:setPercentage((totalExp%needp)/needp*100)
	    	self.progressTimer2:setPercentage(100)
	    	self.bgSp:reorderChild(self.progressTimer1,2)
	    	self.bgSp:reorderChild(self.progressTimer2,1)
    	else
    		self.progressTimer1:setPercentage(100)
	    	self.progressTimer2:setPercentage((totalExp%needp)/needp*100)
	    	self.bgSp:reorderChild(self.progressTimer1,1)
	    	self.bgSp:reorderChild(self.progressTimer2,2)
    	end
    end
    self.costLb1:setVisible(true)
    self.iconGold1:setVisible(true)
    G_setchildPosX(self.changeItem,self.costLb1,self.iconGold1)
end

function acSecretshopDialogTab2:getTotalExp()
	local totalNum=0
	if self.selectPropTb then
		for k,v in pairs(self.selectPropTb) do
    		totalNum=totalNum+self.inputTb[k].point*v
		end
	end
	return totalNum
end

function acSecretshopDialogTab2:clear()
	self:setSelectId(nil)
	self:setSliderLimit()
	self.selectPropTb={}
	local rewardSp=tolua.cast(self.addSp:getChildByTag(133),"CCSprite")
	if rewardSp then
		rewardSp:removeFromParentAndCleanup(true)
	end
	self.targetInfo=nil
	self.alreadyChangeLb:setVisible(false)
	self.targetNameLb:setVisible(false)
	self.addNumLb:setVisible(false)
	self.progressTimer1:setPercentage(0)
	self.progressTimer2:setPercentage(0)

	self.costLb1:setVisible(false)
    self.iconGold1:setVisible(false)

    self.numBg:setVisible(false)
    self.maxLb:setVisible(false)

	self.inputTb=acSecretshopVoApi:getInputList()
	local recordPoint=self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)
end

function acSecretshopDialogTab2:updateAcTime()
end

function acSecretshopDialogTab2:dispose()
	self.downBg=nil
	self.upBg=nil
	self.selectId=nil
	self.targetInfo=nil
	self.changeList=nil
	self.selectPropTb=nil
end



