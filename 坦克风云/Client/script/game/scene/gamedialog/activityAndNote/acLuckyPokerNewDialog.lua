acLuckyPokerNewDialog={}

function acLuckyPokerNewDialog:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	self:doUserHandler()

	return self.bgLayer
end
function acLuckyPokerNewDialog:doUserHandler()--VipLineYellow
	self.activeName=acLuckyPokerVoApi:getActiveName()
	self.isToday = acLuckyPokerVoApi:isToday()
	local allPosSubHeight = 50
	local needBgAddHeight =150
	local needAddPosH = 0
	if G_isIphone5() then
	    needBgAddHeight =300
	    needAddPosH =25
	end
	local nbAward = acLuckyPokerVoApi:getBigRewardTb()
	local function touch2( ) 
		-- print("wholeTouchBgSp~~~~~~~~") 
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
		self:clickFinishAnimation( )
	end 
	self.wholeTouchBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch2)--拉霸动画背景
	self.wholeTouchBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth+40,G_VisibleSizeHeight+needBgAddHeight))
	self.wholeTouchBgSp:setTouchPriority(-(self.layerNum-1)*20-20)
	self.wholeTouchBgSp:setIsSallow(true)
	self.wholeTouchBgSp:setAnchorPoint(ccp(0.5,0))
	self.wholeTouchBgSp:setOpacity(0)
	self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5500))
	self.bgLayer:addChild(self.wholeTouchBgSp,30)
	self.wholeTouchBgSp:setVisible(false)

	local function bgClick() end
	local w = G_VisibleSizeWidth - 40 -- 背景框的宽度
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
	backSprie:setContentSize(CCSizeMake(w, 160))
	backSprie:setAnchorPoint(ccp(0.5,1))
	backSprie:setPosition(ccp(G_VisibleSizeWidth*0.5, G_VisibleSizeHeight - 108-allPosSubHeight))
	self.bgLayer:addChild(backSprie)

	local middleBg=CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
	local scalXX = (backSprie:getContentSize().width-6)/middleBg:getContentSize().width
	local scalYY = (G_VisibleSizeHeight*0.33)/middleBg:getContentSize().height
	local needPosH = backSprie:getPositionY()-backSprie:getContentSize().height
	self.needScalYY = scalYY
	middleBg:setScaleX(scalXX)
	middleBg:setScaleY(scalYY)
	middleBg:setAnchorPoint(ccp(0.5,1))
	middleBg:setPosition(ccp(G_VisibleSizeWidth*0.5,needPosH))
	self.middleBg =middleBg
	self.bgLayer:addChild(middleBg)

	local needTbViewWidth = middleBg:getContentSize().width*scalXX
	self.needTbViewWidth =needTbViewWidth
	local needTbViewHeight = middleBg:getContentSize().height
	self:iniAwardPosBg(middleBg,scalXX,scalYY,self.bgLayer)
	self:initTableView_1(needPosH,needTbViewHeight,needTbViewWidth)
	self:initTableView_2(needPosH,needTbViewHeight,needTbViewWidth)
	-- self:initTableView_2()

	  local function touch(tag,object)
	    PlayEffect(audioCfg.mouseClick)

	    local tabStr={};
	    local tabColor ={nil,G_ColorRed,nil,nil,nil,nil,nil};
	    local td=smallDialog:new()
	    tabStr = {"\n",getlocal("activity_luckyPoker_iHelp_3"),"\n",getlocal("activity_luckyPoker_iHelp_2"),"\n",getlocal("activity_luckyPoker_iHelp_1",{nbAward.name}),"\n"}
	    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
	    sceneGame:addChild(dialog,self.layerNum+1)
	  end

	  w = w - 10 -- 按钮的x坐标
	  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
	  menuItemDesc:setAnchorPoint(ccp(1,1))
	  menuItemDesc:setScale(0.8)
	  local menuDesc=CCMenu:createWithItem(menuItemDesc)
	  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	  menuDesc:setPosition(ccp(w-10, backSprie:getContentSize().height-10))
	  backSprie:addChild(menuDesc)
	  
	  w = w - menuItemDesc:getContentSize().width

	  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
	  acLabel:setAnchorPoint(ccp(0.5,1))
	  acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)*0.5, backSprie:getContentSize().height-10))
	  backSprie:addChild(acLabel)
	  acLabel:setColor(G_ColorGreen)

	  local acVo = acLuckyPokerVoApi:getAcVo()
	  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	  local messageLabel=GetTTFLabel(timeStr,25)
	  messageLabel:setAnchorPoint(ccp(0.5,1))
	  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)*0.5, backSprie:getContentSize().height-40))
	  backSprie:addChild(messageLabel)
	  self.timeLb=messageLabel
	  self:updateAcTime()

	  local topLabel = getlocal("activity_luckyPoker_Lable_1",{nbAward.name})
	  local strSize3 = G_getCurChoseLanguage() =="ar" and 90 or 50
	  local desTv, desLabel = G_LabelTableView(CCSizeMake(G_VisibleSizeWidth - strSize3, 70),topLabel,25,kCCTextAlignmentLeft)
	  backSprie:addChild(desTv)
	  desTv:setPosition(ccp(10,10))
	  desTv:setAnchorPoint(ccp(0,0))
	  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	  desTv:setMaxDisToBottomOrTop(100)

	  local oneCost,tenCost = acLuckyPokerVoApi:getCostWithOneAndTenTimes( )

	  local function btnClick( tag,object)
			-- print("in btnClick----->tag",tag)
		local haveCost = playerVoApi:getGems()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local free = false --acLuckyPokerVoApi:isToday()
        local needSubCost =0
        if tag == 30 then
        	free =true
        elseif tag ==31 then 
        	if tonumber(oneCost) > haveCost then
	        	self:needMoneyDia(oneCost,haveCost,self.wholeTouchBgSp)--出板子 让玩家充值
	        	do return end
	        else
	        	needSubCost =oneCost
	        end
        elseif tag ==40 then
        	if  tonumber(tenCost) > haveCost then
	        	self:needMoneyDia(tenCost,haveCost,self.wholeTouchBgSp)--出板子 让玩家充值
	        	do return end
			else
	        	needSubCost =tenCost
	        	-- print("needSubCost ======tenCost",needSubCost,tenCost)
	        end
        end
        local acIdx =tag-30
    	local function realLotteryHandler()
    		-- print("needSubCost---acIdx-->",needSubCost,acIdx)
	        local function callback(fn,data)
	        	local ret,sData = base:checkServerData(data)
		        if ret==true then
		        	acLuckyPokerVoApi:setIsSeeRecord(false)
		        	self:refreshVisibleWithRecord()
		        	self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,0))
		        	self.wholeTouchBgSp:setVisible(true)
		        	playerVoApi:setGems(playerVoApi:getGems()-needSubCost)
		        	if sData and sData.data then
		        		local data = sData.data
		        		if data[self.activeName] then
		        			-- print("data.luckcard.t---->",data.luckcard.t)
		        			acLuckyPokerVoApi:updateLastTime(data[self.activeName].t)
		        		end
		        		if data.report then
		        			acLuckyPokerVoApi:setAllAwardTb(data.report)--用于奖励板子使用
		        			
		        		end
		        		self.nextShow[1] =1
		        		self:startPalyAnimation()
		        	end
			    	self:refreshVisible2()
		        end
	        end 
	    	socketHelper:acLuckyPokerSoc(free,1,self.activeName,acIdx,callback)----"luckcard"需要改成活的！！！！！！！！！！！！！！！！！！！！！！！！！！！！
    	end
     	if free == true then --免费的直接抽
        	realLotteryHandler()
        else --非免费的增加二次确认
            G_dailyConfirm("luckpokernew.lottery", getlocal("second_tip_des", {needSubCost}), realLotteryHandler, self.layerNum + 1)
        end
    end 
--------
	self.freeBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnClick,30,getlocal("daily_lotto_tip_2"),25)
    self.freeBtn:setAnchorPoint(ccp(0.5,0.5))
    self.freeBtnMenu=CCMenu:createWithItem(self.freeBtn)
    self.freeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width*0.25,self.freeBtn:getContentSize().height*0.6+25+needAddPosH))
    self.freeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.freeBtnMenu,2)  
--------
    self.talkBtn1 =GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnClick,31,getlocal("activity_luckyPoker_btnLb",{"1"}),25)
    self.talkBtn1:setAnchorPoint(ccp(0.5,0.5))
    self.talkBtn1Menu=CCMenu:createWithItem(self.talkBtn1)
    self.talkBtn1Menu:setPosition(ccp(self.bgLayer:getContentSize().width*0.25,self.talkBtn1:getContentSize().height*0.6+25+needAddPosH))
    self.talkBtn1Menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.talkBtn1Menu)  

    self.oneCostStr = GetTTFLabel(oneCost,25)
    self.oneCostStr:setAnchorPoint(ccp(1,0))
    self.talkBtn1:addChild(self.oneCostStr)
    self.oneCostStr:setColor(G_ColorYellowPro)

    self.gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon1:setAnchorPoint(ccp(0,0))
	self.talkBtn1:addChild(self.gemIcon1,1)

    self.talkBtn2 =GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnClick,40,getlocal("activity_luckyPoker_btnLb",{"10"}),25);
    self.talkBtn2:setAnchorPoint(ccp(0.5,0.5))
    self.talkBtn2Menu=CCMenu:createWithItem(self.talkBtn2)
    self.talkBtn2Menu:setPosition(ccp(self.bgLayer:getContentSize().width*0.75,self.talkBtn2:getContentSize().height*0.6+25+needAddPosH))
    self.talkBtn2Menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.talkBtn2Menu)

    self.tenCostStr = GetTTFLabel(tenCost,25)
    self.tenCostStr:setAnchorPoint(ccp(1,0))
    self.talkBtn2:addChild(self.tenCostStr)
    self.tenCostStr:setColor(G_ColorYellowPro)

    self.gemIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon2:setAnchorPoint(ccp(0,0))
	self.talkBtn2:addChild(self.gemIcon2,1)

    self:refreshVisible2()

	local function showRewardsInfo()
		-- print("ye~~~~~~")
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function callback(fn,data)
        	local ret,sData = base:checkServerData(data)
	        if ret==true then
	        	acLuckyPokerVoApi:setIsSeeRecord(true)
	        	self:refreshVisibleWithRecord()
	        	if sData and sData.data then
	        		local data  = sData.data
	        		if data.report then
	        			acLuckyPokerVoApi:setAwardAllTbRecord( data.report )
	        		end
	        		self:openRecordDia()
	        	end
	        end
        end 
    	socketHelper:acLuckyPokerSoc(0,2,self.activeName,0,callback)----"luckcard"需要改成活的！！！！！！！！！！！！！！！！！！！！！！！！！！！！
    end
    local rewardInfoItem = GetButtonItem("bless_record.png","bless_record.png","bless_record.png",showRewardsInfo,11,nil,nil)
    rewardInfoItem:setRotation(10)
    local rewardInfoBtn = CCMenu:createWithItem(rewardInfoItem)
    rewardInfoItem:setAnchorPoint(ccp(1,0))
    local bookNeedPosH = 90
    if G_isIphone5() ==true then
    	bookNeedPosH =120
    end
    rewardInfoBtn:setPosition(ccp(G_VisibleSizeWidth-50,self.talkBtn2:getContentSize().height+bookNeedPosH))
    rewardInfoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rewardInfoBtn)

    self.tipIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
    self.tipIcon:setAnchorPoint(ccp(0.5,0.5))
    self.tipIcon:setPosition(ccp(rewardInfoItem:getContentSize().width-20,rewardInfoItem:getContentSize().height-15))
    rewardInfoItem:addChild(self.tipIcon,10)

    self:refreshVisibleWithRecord()

    local promptBg = CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    promptBg:setAnchorPoint(ccp(0.5,0.5))
    promptBg:setPosition(ccp(G_VisibleSizeWidth*0.5+10,G_VisibleSizeHeight*0.16))
    self.bgLayer:addChild(promptBg)
    
    local nbAwardName = GetTTFLabel(nbAward.name,25)
    nbAwardName:setAnchorPoint(ccp(0.5,0.5))
    nbAwardName:setColor(G_ColorYellowPro)
    nbAwardName:setPosition(getCenterPoint(promptBg))
    promptBg:addChild(nbAwardName)

    local unFloorHeightScale =0.18
    local aid,tankID = nbAward.key,nbAward.id
    local subPosH = 40
    local tankScale = 1
    -- print("tankID----->2",tankID)
    if G_isIphone5() then
    	-- subPosH = 0 
    	tankScale = 1.5
    	if tankID == 20125 then
	    	subPosH = 10
		elseif tankID == 10145 then
	   		subPosH = 85
	   	elseif tankID == 20055 then
	   		subPosH = 30
	   	elseif tankID == 10075 then
	   		subPosH = 35
	   		tankScale = 1.4
	   	elseif tankID == 10084 then
	   		subPosH = 60
	   		tankScale = 1.2
	   	elseif tankID == 10045 then
	   		subPosH = 55
	   	elseif tankID == 10165 then
	   		tankScale = 1.2
	   		subPosH = 60
	    end
    else
    	if tankID == 20125 then
	    	subPosH = 10
		elseif tankID == 20115 then
			subPosH = 30
		elseif tankID == 10145 then
	   		subPosH = 60
	   	elseif tankID == 20055 then
	   		subPosH = 20
	   	elseif tankID == 10075 then
	   		subPosH = 30
	   	elseif tankID == 20065 then
	   		subPosH = 30
	   	elseif tankID == 10084 then
	   		subPosH = 45
	   		tankScale = 0.85
	   	elseif tankID == 10165 then
	   		tankScale = 0.85
	   		subPosH = 50
	    end
    end 
	  local function showTankInfo( ... )
	    local function callback()
	      self:showBattle()
	    end
	  	tankInfoDialog:create(nil,tankID,self.layerNum+1, nil,true,callback)
	  end

	  local orderId=GetTankOrderByTankId(tonumber(tankID))
	  local tankStr="t"..orderId.."_1.png"
	  local tankSp=LuaCCSprite:createWithSpriteFrameName(tankStr,showTankInfo)
	  tankSp:setTouchPriority(-(self.layerNum-1)*20-4)
	  tankSp:setAnchorPoint(ccp(0.5,0))
	  tankSp:setPosition(ccp(G_VisibleSizeWidth*0.4,G_VisibleSizeHeight*unFloorHeightScale-subPosH))
	  tankSp:setScale(tankScale)
	  self.bgLayer:addChild(tankSp)

	  local tankBarrel="t"..orderId.."_1_1.png"  --炮管 第6层
	  local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
	  if tankBarrelSP then
	    tankBarrelSP:setPosition(ccp(tankSp:getContentSize().width*0.5,tankSp:getContentSize().height*0.5))
	    tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
	    tankSp:addChild(tankBarrelSP)
	  end
	  --GetBMLabel(giftNums,G_GoldFontSrc,25)
	  local xStr = GetBMLabel("+",G_GoldFontSrc,25)
	  xStr:setAnchorPoint(ccp(0,0))
	  xStr:setRotation(45)
	  xStr:setPosition(ccp(G_VisibleSizeWidth*0.53,G_VisibleSizeHeight*unFloorHeightScale+15))
	  self.bgLayer:addChild(xStr)
	  local tankNumsStr = GetBMLabel(nbAward.num,G_GoldFontSrc,25)
	  tankNumsStr:setAnchorPoint(ccp(0,0))
	  tankNumsStr:setPosition(ccp(G_VisibleSizeWidth*0.55+xStr:getContentSize().width,G_VisibleSizeHeight*unFloorHeightScale))
	  self.bgLayer:addChild(tankNumsStr)

	local titleNeedScale = 0.34
	if G_isIphone5() ==true then
		titleNeedScale =0.37
	end
	local titleBg1=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg1:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*titleNeedScale-allPosSubHeight))
    -- titleBg1:setScaleY(0.9)
    titleBg1:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(titleBg1)
    local luckyStr = GetTTFLabel(getlocal("sample_prop_name_1306"),25)
    luckyStr:setAnchorPoint(ccp(0.5,0.5))
    luckyStr:setColor(G_ColorYellowPro)
    luckyStr:setPosition(ccp(titleBg1:getContentSize().width*0.5,titleBg1:getContentSize().height*0.5+5))
    titleBg1:addChild(luckyStr)
end

function acLuckyPokerNewDialog:getAllAwardToShowWithDialog(isClick)
	if self.isFinished ==true then
		self.isFinished =false
		local needDelayNum = 0
		-- if isClick ==nil then
			needDelayNum =1
		-- end
		local function callbackShowDia( )
			local function closeSure( )
				-- print("in closeSure~~~~~~~~")
				self:cleanData()
			end
			local sd=acLuckyPokerGetRewardDialog:new(self.layerNum + 1)
		  	local dialog= sd:init(closeSure)
		  	self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5000))
		end 
	  	local delay=CCDelayTime:create(needDelayNum)
	  	local callFunc=CCCallFuncN:create(callbackShowDia)
	  	local acArr=CCArray:create()
	  	acArr:addObject(delay)
	  	acArr:addObject(callFunc)
	  	local seq=CCSequence:create(acArr)

	  	self.bgLayer:runAction(seq)
	end
end
function acLuckyPokerNewDialog:openRecordDia()
	local recordTb = acLuckyPokerVoApi:getAwardAllTbRecord( )
	if recordTb ==nil or #recordTb ==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
	else
		local sd=acLuckyPokerRecordDialog:new(self.layerNum + 1)
	  	local dialog= sd:init(nil)
   end
end


function acLuckyPokerNewDialog:showBattle()
  
  local battleStr=acLuckyPokerVoApi:returnTankData()
  local report=G_Json.decode(battleStr)
  local isAttacker=true
  local data={data={report=report},isAttacker=isAttacker,isReport=true}
  battleScene:initData(data)
end
function acLuckyPokerNewDialog:refreshVisibleWithRecord()
	
	local isSee = acLuckyPokerVoApi:getIsSeeRecord()
	if isSee ==true then
		self.tipIcon:setVisible(false)
	else
		self.tipIcon:setVisible(true)
	end
end
function acLuckyPokerNewDialog:refreshVisible2()

    local goldNum1,goldNum2=acLuckyPokerVoApi:getCostWithOneAndTenTimes()
	local haveCost = playerVoApi:getGems()

    if acLuckyPokerVoApi:canReward()==true then
        self.freeBtn:setVisible(true)
    	self.talkBtn1:setEnabled(false)
    	self.talkBtn2:setEnabled(false)
    	self.oneCostStr:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5-5,self.talkBtn1:getContentSize().height*0.5-250))
    	self.gemIcon1:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5-250))
    	self.tenCostStr:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5-5,self.talkBtn2:getContentSize().height*0.5-250))
    	self.gemIcon2:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5-250))
    else
        self.freeBtn:setVisible(false)
    	self.talkBtn1:setEnabled(true)
    	self.talkBtn2:setEnabled(true)
    	self.oneCostStr:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5+35))
    	self.gemIcon1:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5+35))
    	self.tenCostStr:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5+35))
    	self.gemIcon2:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5+35))

    	if haveCost<goldNum1 then
	    	self.oneCostStr:setColor(G_ColorRed)
	    else
	    	self.oneCostStr:setColor(G_ColorYellowPro)
	    end
	    if haveCost<goldNum2 then
	    	self.tenCostStr:setColor(G_ColorRed)
	    else
	    	self.tenCostStr:setColor(G_ColorYellowPro)
	    end
    end
    -- self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+5000))
end
function acLuckyPokerNewDialog:tick()
	local acVo = acLuckyPokerVoApi:getAcVo()
	if acVo ~= nil then
		if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
			if self ~= nil then
				self:close()
			end
		end
	end
	if acLuckyPokerVoApi:isToday()==false and self.isToday==true then
		self.isToday=false
		self:refreshVisible2()
	end
	self:updateAcTime()
end

function acLuckyPokerNewDialog:updateAcTime()
    local acVo=acLuckyPokerVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acLuckyPokerNewDialog:iniAwardPosBg(bgPic,scalXX,scalYY,bgLayer)--BgEmptyTank.png 
	local posW = bgPic:getContentSize().width
	local posH = bgPic:getContentSize().height
	local posWidthScalTb = {0.125,0.375,0.625,0.875}
	local function notCall() end 
	local needNum = 25
	local needSubNum = 42	
	if G_isIphone5() ==true then
		needNum =228
		needSubNum =85
	end
	for i=1,8 do
		local aHeight = math.floor((i-1)/4)
		local awidth = i%4
		if awidth==0 then
			awidth=4
		end
		if i ==1 then
			self.needBgPosScal_1 =(posH*0.5+20-aHeight*120)/posH
		elseif i ==5 then
			self.needBgPosScal_2 =(posH*0.5+20-aHeight*120)/posH
		end
		local iconBg = CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
		iconBg:setAnchorPoint(ccp(0.5,0))
		iconBg:setPosition(ccp(posW*posWidthScalTb[awidth],posH*0.5+20-aHeight*120))
		iconBg:setScaleX(0.98/scalXX)
		iconBg:setScaleY(0.98/scalYY)
		bgPic:addChild(iconBg)
		local parPos1 = bgPic:convertToNodeSpace(ccp(iconBg:getPositionX(),iconBg:getPositionY()))
		table.insert(self.yellBoderPosEndTb,ccp((parPos1.x+iconBg:getContentSize().width*0.29)*scalXX+20-awidth*4,0))

		local iconOrederBg = CCSprite:createWithSpriteFrameName("BgEmptyTank.png")
		iconOrederBg:setAnchorPoint(ccp(0.5,0.5))
		iconOrederBg:setPosition(getCenterPoint(iconBg))
		iconOrederBg:setScale(0.55)
		iconBg:addChild(iconOrederBg)

		local grayBoder=LuaCCSprite:createWithSpriteFrameName("whiteBorder.png",notCall)
	    grayBoder:setAnchorPoint(ccp(0.5,0.5))
	    grayBoder:setScale(0.85)
	    grayBoder:setTouchPriority(0)
	    grayBoder:setColor(G_ColorGray)
	    grayBoder:setVisible(false)
	    grayBoder:setPosition(getCenterPoint(iconBg))
	    iconBg:addChild(grayBoder)
	    table.insert(self.grayBoderTb,grayBoder)
	end

	local needNum = self.needBgPosScal_1+0.035
	local needNum2 = self.needBgPosScal_2+0.034
	if G_isIphone5() ==true then
		needNum = self.needBgPosScal_1+0.03
		needNum2 = self.needBgPosScal_2+0.03
	end
	local boderPosY_1 = self.middleBg:getPositionY()-self.middleBg:getContentSize().height*self.needScalYY*(1-needNum)+37.5
	local boderPosY_2 = self.middleBg:getPositionY()-self.middleBg:getContentSize().height*self.needScalYY*(1-needNum2)+37.5
	for i=1,8 do
		if i<5 then
			self.yellBoderPosEndTb[i].y =boderPosY_1
		else
			self.yellBoderPosEndTb[i].y =boderPosY_2
		end
	end
end



function acLuckyPokerNewDialog:needMoneyDia(cost,playerGems,wholeTouchBgSp)
	local function buyGems()
      if G_checkClickEnable()==false then
          do
              return
          end
      end
	  activityAndNoteDialog:closeAllDialog()
      vipVoApi:showRechargeDialog(self.layerNum+1)
  	end
  	local function cancleCallBack( )
  		if wholeTouchBgSp then
  			wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+5000))
  		end
  	end 
	local num=tonumber(cost)-playerGems
	local smallD=smallDialog:new()
	smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(cost),playerGems,num}),nil,self.layerNum+1,nil,nil,cancleCallBack)
end


function acLuckyPokerNewDialog:initTableView_1(needPosH,needTbViewHeight,needTbViewWidth)
	local needNum = self.needBgPosScal_1+0.035
	if G_isIphone5() ==true then
		needNum = self.needBgPosScal_1+0.03
	end
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	local posW_here = (G_VisibleSizeWidth-needTbViewWidth)*0.5

	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(needTbViewWidth,75),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setPosition(ccp(posW_here,self.middleBg:getPositionY()-self.middleBg:getContentSize().height*self.needScalYY*(1-needNum)))--0.535  (1-0.61)
	self.tv:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(0)
end

function acLuckyPokerNewDialog:eventHandler(handler,fn,idx,cel)
	local strSize2 = 21
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =23
	end

   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
   		
       return  CCSizeMake(self.needTbViewWidth,75)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       	if self.cellBgSp1 ==nil then
	        local function touch( ) end
			self.cellBgSp1=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
			self.cellBgSp1:setContentSize(CCSizeMake(self.needTbViewWidth,75))
			self.cellBgSp1:setAnchorPoint(ccp(0,0))
			self.cellBgSp1:setOpacity(0)
			self.cellBgSp1:setPosition(ccp(0,0))
			cell:addChild(self.cellBgSp1)

			local rawTb,tbNums = acLuckyPokerVoApi:getPoolRewardTb( )
			local formatTb = acLuckyPokerVoApi:formatPoolRewardTb(rawTb)
			local posWidthScalTb = {0.125,0.375,0.625,0.875}
			for k,v in pairs(formatTb) do
				if k <5 then
					if self.nextShow[k] ==nil then
						self.nextShow[k] =0
					end
					local awidth = k%4
					if awidth==0 then
						awidth=4
					end
					local oneTb = {}
					local speedTb ={}
					local fuwei = {}
					local awardTigTb = {}
					for m,n in pairs(v) do
						local icon,iconScale = G_getItemIcon(n,75,false,self.layerNum,nil,nil)
				        icon:setTouchPriority(-(self.layerNum-1)*20-2)
				        icon:setAnchorPoint(ccp(0.5,0))
				        icon:setPosition(ccp(self.needTbViewWidth*posWidthScalTb[awidth],self.constPosH*m))
				        -- print("(G_VisibleSizeWidth-29)*posWidthScalTb[awidth]------>",(G_VisibleSizeWidth-29)*posWidthScalTb[awidth])
				        self.cellBgSp1:addChild(icon)

				        local num = GetTTFLabel("x"..n.num,25/iconScale)
				        num:setAnchorPoint(ccp(1,0))
				        num:setPosition(icon:getContentSize().width-5,5)
				        icon:addChild(num)

				        table.insert(awardTigTb,{id = n.id,num = n.num,name = n.name})
				        table.insert(fuwei,icon:getPositionY())
				        table.insert(oneTb,icon)
				        table.insert(speedTb,self.constPosH)
					end
					table.insert(self.awardTigTb,awardTigTb)
					table.insert(self.fuWei,fuwei)
					table.insert(self.poolSpTb1,oneTb)
					table.insert(self.speedTb1,speedTb)
				end
			end

		end


	   cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acLuckyPokerNewDialog:initTableView_2(needPosH,needTbViewHeight,needTbViewWidth)
	local needNum = self.needBgPosScal_2+0.034
	if G_isIphone5() ==true then
		needNum = self.needBgPosScal_2+0.03
	end
	local function callBack(...)
	   return self:eventHandle2(...)
	end
	local posW_here = (G_VisibleSizeWidth-needTbViewWidth)*0.5

	local hd= LuaEventHandler:createHandler(callBack)
	self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(needTbViewWidth,75),nil)
	self.bgLayer:addChild(self.tv2)
	self.tv2:setPosition(ccp(posW_here,self.middleBg:getPositionY()-self.middleBg:getContentSize().height*self.needScalYY*(1-needNum)))--(1-0.158)
	self.tv2:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
	self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv2:setMaxDisToBottomOrTop(0)
end
function acLuckyPokerNewDialog:eventHandle2(handler,fn,idx,cel)
	local strSize2 = 21
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =23
	end

   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
   		
       return  CCSizeMake(self.needTbViewWidth,75)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       	if self.cellBgSp2 ==nil then
	        local function touch( ) end
			self.cellBgSp2=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
			self.cellBgSp2:setContentSize(CCSizeMake(self.needTbViewWidth,75))
			self.cellBgSp2:setAnchorPoint(ccp(0,0))
			self.cellBgSp2:setOpacity(0)
			self.cellBgSp2:setPosition(ccp(0,0))
			cell:addChild(self.cellBgSp2)

			local rawTb,tbNums = acLuckyPokerVoApi:getPoolRewardTb( )
			local formatTb = acLuckyPokerVoApi:formatPoolRewardTb(rawTb)
			local posWidthScalTb = {0.125,0.375,0.625,0.875}
			for k,v in pairs(formatTb) do
				if k >4 then
					if self.nextShow[k] ==nil then
						self.nextShow[k] =0
					end
					local awidth = k%4
					if awidth==0 then
						awidth=4
					end
					local oneTb = {}
					local speedTb ={}
					local fuwei = {}
					local awardTigTb = {}
					for m,n in pairs(v) do
						local icon,iconScale = G_getItemIcon(n,75,false,self.layerNum,nil,nil)
				        icon:setTouchPriority(-(self.layerNum-1)*20-2)
				        icon:setAnchorPoint(ccp(0.5,0))
				        icon:setPosition(ccp(self.needTbViewWidth*posWidthScalTb[awidth],self.constPosH*m))
				        self.cellBgSp2:addChild(icon)

				        local num = GetTTFLabel("x"..n.num,25/iconScale)
				        num:setAnchorPoint(ccp(1,0))
				        num:setPosition(icon:getContentSize().width-5,5)
				        icon:addChild(num)

				        table.insert(awardTigTb,{id = n.id,num = n.num,name = n.name})
				        table.insert(fuwei,icon:getPositionY())
				        table.insert(oneTb,icon)
				        table.insert(speedTb,self.constPosH)
					end
					table.insert(self.awardTigTb,awardTigTb)
					table.insert(self.fuWei,fuwei)
					table.insert(self.poolSpTb1,oneTb)
					table.insert(self.speedTb1,speedTb)
				end
			end

		end


	   cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acLuckyPokerNewDialog:cleanData( )
	for i=1,#self.nextShow do
		self.nextShow[i] = 0
	end
	for i=1,#self.grayBoderTb do
		self.grayBoderTb[i]:setVisible(false)
	end
	self:removeJARrectParticles()
	for k,v in pairs(self.poolSpTb1) do
		local fuwei =self.fuWei[k]
		for m,n in pairs(v) do
			n:setPosition(ccp(n:getPositionX(),fuwei[m]))
		end

	end
	self:removeParticles()
	self.isFinished =true
end

function acLuckyPokerNewDialog:startPalyAnimation()
	self:playJARrectParticles(1)
	self.actionWithAwardTb = acLuckyPokerVoApi:getAwardWithAction()
	self.yellBoderStartScale =0.5

	self.rate=15--初始化 速率
	self.loopNum =0
	self.state = 2
	

end

function acLuckyPokerNewDialog:finishPalyAnimation(isClick)
	self.isClickStop =false
	self.boderIsShow = false
	
	self.wholeTouchBgSp:setVisible(false)
	self:getAllAwardToShowWithDialog(isClick)-----显示奖励的板子
end
function acLuckyPokerNewDialog:clickFinishAnimation( )
	print("here????")
	self.isClickStop =true
	self.state =3
	for k,v in pairs(self.poolSpTb1) do
		local speedTb = self.speedTb1[k]
		local actionAwardTb = self.actionWithAwardTb[k]
		local awardTigTb = self.awardTigTb[k]

		for m,n in pairs(v) do

			if  actionAwardTb ~= nil and actionAwardTb.name == awardTigTb[m].name and actionAwardTb.id == awardTigTb[m].id  and (actionAwardTb.num == awardTigTb[m].num or actionAwardTb.num == awardTigTb[m].num*10) then

				n:setPosition(ccp(n:getPositionX(),0))
				if actionAwardTb.type =="o" and self.yellBoderTb[k] ==nil then
					self:playJARrectParticles(k)
					-- self.yellBoderTb[k]:setVisible(false)
				end
					-- self.yellBoderTb[k]:setVisible(true)
				if self.yellBoderTb[k] ~=nil then	
					self.yellBoderTb[k]:setPosition(self.yellBoderPosEndTb[k])
					-- self.yellBoderTb[k]:setScale(self.yellBoderEndScale)
					-- self.yellBoderTb[k]:setRotation(0)
					if actionAwardTb.type ~="o" then
						self.yellBoderTb[k]:setVisible(false)
					end
				end
			else
				n:setPosition(ccp(n:getPositionX(),75))
			end
		end
	end
	self.state = 0
	self:finishPalyAnimation(1)
end
function acLuckyPokerNewDialog:moveSp( )
	local isStop = false
	local isShow = nil
	local isTank = false
	for k,v in pairs(self.poolSpTb1) do
		local speedTb = self.speedTb1[k]
		local actionAwardTb = self.actionWithAwardTb[k]
		local awardTigTb = self.awardTigTb[k]
		
		if self.nextShow[k] ==1 then
			isShow =k
			for m,n in pairs(v) do
				if n:getPositionY() == -self.constPosH*(#v-2)+self.rate then
					speedTb[m] =self.constPosH*2
					if m >4 or m == #v then
						if self.loopNum == 0 then
							self.loopNum =2
							self.boderScaleSpeed = 0.03
						end
						
					end
				else
					speedTb[m] = n:getPositionY() - self.rate
				end
				n:setPosition(ccp(n:getPositionX(),speedTb[m]))
				if self.loopNum == 2 and n:getPositionY() ==0 and actionAwardTb ~= nil and actionAwardTb.name == awardTigTb[m].name and actionAwardTb.id == awardTigTb[m].id  and (actionAwardTb.num == awardTigTb[m].num or actionAwardTb.num == awardTigTb[m].num*10) then
					if actionAwardTb.type =="o" then
						isTank =true
					end
					isStop =true
				end
			end
		end
	end
	if isStop ==true then
		self.rate =15
		self.loopNum =0
		self.nextShow[isShow] =0

		self.boderIsShow = false
		self:playParticles(isTank,self.yellBoderPosEndTb[isShow],self.bgLayer)

		if isTank ==false then
			self.yellBoderTb[isShow]:setVisible(false)
			self.grayBoderTb[isShow]:setVisible(true)
		end
		if isShow+1 <= #self.actionWithAwardTb then
			self:playJARrectParticles(isShow+1)
			self.nextShow[isShow+1]=1
			-- print("isShow~~~~~~~~~~~~~",isShow)
		else
			self.state = 3
			-- print("is OVER~~~~~~~~~~~~~")
		end
	end
end

function acLuckyPokerNewDialog:fastTick( )
	if self.state ==2 then
		self:moveSp()
	elseif self.state ==3 then
		self.state = 0
		if self.isClickStop ==false then
			self:finishPalyAnimation( )
		end
	end
end

function acLuckyPokerNewDialog:playJARrectParticles(idx)
	local yellBoder =CCParticleSystemQuad:create("public/JARrect.plist")
	yellBoder:setAnchorPoint(ccp(0.5,0.5))
	yellBoder.positionType = kCCPositionTypeFree
	yellBoder:setScale(self.yellBoderStartScale)
	-- yellBoder:setPosition(self.yellBoderPosStart)
	yellBoder:setPosition(self.yellBoderPosEndTb[idx])
	self.bgLayer:addChild(yellBoder,11)
	table.insert(self.yellBoderTb,yellBoder)
end
function acLuckyPokerNewDialog:playParticles(isTrue,needPos,parentBg)
    --粒子效果
	self.particleS = {}

	local needParticle = "public/YELLOWrect.plist"
	if isTrue ==nil or isTrue ==false then
		needParticle ="public/REDrect.plist"
	end
	local p = CCParticleSystemQuad:create(needParticle)
	p.positionType = kCCPositionTypeFree
	p:setPosition(needPos)
	parentBg:addChild(p,10)
	table.insert(self.particleS,p)
	self.addParticlesTs = base.serverTime

end
function acLuckyPokerNewDialog:removeParticles()
	if self.particleS ~= nil then
	  for k,v in pairs(self.particleS) do
	    v:removeFromParentAndCleanup(true)
	  end
	end
  self.particleS = nil
  
end

function acLuckyPokerNewDialog:removeJARrectParticles( )
	if self.yellBoderTb ~=nil then
		for k,v in pairs(self.yellBoderTb) do
			v:removeFromParentAndCleanup(true)
		end
	end
	self.yellBoderTb = {}
end

function acLuckyPokerNewDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self


	self.isTouch=nil
	self.isToday=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.freeBtn =nil
	self.freeBtnMenu=nil
	self.talkBtn1=nil
	self.talkBtn1Menu=nil
	self.talkBtn2=nil
	self.talkBtn2Menu=nil
	self.oneCostStr =nil
	self.gemIcon1 =nil
	self.tenCostStr=nil
	self.gemIcon2 =nil
	self.wholeTouchBgSp=nil
	self.tv=nil
	self.tv2=nil
	self.cellBgSp1=nil
	self.cellBgSp2=nil
	self.poolSpTb1={}
	self.poolSpTb2={}
	self.speedTb1={}
	self.speedTb2={}
	self.rate=0
	self.state = 0 -- 0 正常 1 点击抽取 2 后台返回结果 3 动画播放结束
	self.fuWei ={}
	self.loopNum =0--0 未开始 1 第一圈结束 2 随时结束
	self.constPosH=75
	self.grayBoderTb={}
	self.actionWithAwardTb ={}
	self.awardTigTb ={}
	self.nextShow ={}
	self.isClickStop =false
	self.yellBoderPosEndTb={}
	self.yellBoderTb={}
	self.yellBoderPosStart=nil
	self.yellBoderEndScale =0.5
	self.yellBoderStartScale=0.5
	self.boderRevolutionX=0
	self.boderRevolutionY=0
	self.boderRotation =0
	self.boderScaleSpeed =0.06
	self.boderRoSpeed =6
	self.middleBg =nil
	self.boderIsShow =false
	self.isFinished =true
	self.needScalYY =0
	self.needBgPosScal_1 =0
	self.needBgPosScal_2 =0
	return nc
end
function acLuckyPokerNewDialog:dispose( )
	self.needBgPosScal_1 =nil
	self.needBgPosScal_2 =nil
	self.needScalYY =nil
	self.addParticlesTs = nil
	self.isFinished =nil
	self.grayBoderTb=nil
	self.boderRevolutionX=nil
	self.boderRevolutionY=nil
	self.boderScaleSpeed =nil
	self.boderRoSpeed =nil
	self.boderIsShow =nil
	self.boderRotation =nil
	self.yellBoderEndScale =nil
	self.yellBoderStartScale=nil
	self.yellBoderPosEndTb=nil
	self.yellBoderTb=nil
	self.yellBoderPosStartTb=nil
	self.isClickStop=nil
	self.nextShow=nil
	self.awardTigTb=nil
	self.actionWithAwardTb=nil
	self.loopNum =nil
	self.fuWei=nil
	self.constPosH =nil
	self.rate=nil
	self.isToday=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.freeBtn =nil
	self.freeBtnMenu=nil
	self.talkBtn1=nil
	self.talkBtn1Menu=nil
	self.talkBtn2=nil
	self.talkBtn2Menu=nil
	self.oneCostStr =nil
	self.gemIcon1 =nil
	self.tenCostStr=nil
	self.gemIcon2 =nil
	self.wholeTouchBgSp=nil
	self.tv=nil
	self.tv2=nil
	self.cellBgSp1=nil
	self.cellBgSp2=nil
	self.poolSpTb1=nil
	self.poolSpTb2=nil
	self.speedTb1=nil
	self.speedTb2=nil
	self.state=nil
	self.middleBg =nil

    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("serverWar/serverWar.plist")
end