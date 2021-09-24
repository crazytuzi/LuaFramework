acLjczDialog=commonDialog:new()

function acLjczDialog:new()
    local nc={
    	totalMoneyLabel=nil,
    	goldIcon=nil,
    	rewardCfg=nil,
    	barH=80,
    	iconSize=70,
	}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acLjczDialog:initTableView()
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.cellHeight),nil)
	self.bgLayer:addChild(self.tv,3)
	self.tv:setPosition(ccp(20,self.pageBg:getPositionY()-self.pageBg:getContentSize().height+10))
	self.tv:setAnchorPoint(ccp(0,0))
	-- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(0)
end

function acLjczDialog:eventHandler(handler,fn,idx,cel)
  local strSize3 = 20
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
    strSize3 = 25
  end
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth-40,self.cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local barH=self.barH
    local costCfg=acLjczVoApi:getCost()
  	local totalH=barH*self.rechargeLv
    local totalW=G_VisibleSizeWidth-40
    local leftW=totalW*0.27
    local totalMoney=acLjczVoApi:getTotalMoney()
    local per=0
    local spaceH=(self.cellHeight-totalH)/2+10
    local spaceW=90
    local btnScale=0.8
    if G_isIphone5() then
    	spaceW=100
    	btnScale=1
    end
    for k,rewardlist in pairs(self.rewardCfg) do
        local posY=barH/2+(k-1)*barH+spaceH
    	for kk,v in pairs(rewardlist) do
			local icon, iconScale=G_getItemIcon(v,self.iconSize,true,self.layerNum)
			icon:ignoreAnchorPointForPosition(false)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(ccp(10+(kk-1)*spaceW+leftW,posY))
			icon:setIsSallow(false)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			cell:addChild(icon,1)
			icon:setTag(kk)

			if tostring(v.name)~=getlocal("honor") then
				local numLabel=GetTTFLabel("x"..FormatNumber(v.num),24)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(icon:getContentSize().width-10,3)
				icon:addChild(numLabel,1)
			end
			if acLjczVoApi:isAddFlicker(v.key) then
				G_addRectFlicker2(icon,1.3,1.3,2,"p")
			end
    	end

    	local posX=totalW-70
    	local pic="darkBrownBg.png"
		local flag=acLjczVoApi:checkIfReward(k)
		if flag==1 then --未完成
			local noLabel=GetTTFLabelWrap(getlocal("noReached"),strSize3,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			noLabel:setPosition(ccp(posX,posY))
			cell:addChild(noLabel,1)
		elseif flag==2 then --可领取
			pic="BrightBrownBg.png"
			local function rewardHandler(tag,object)
                PlayEffect(audioCfg.mouseClick)
	            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
	            end

                local function rewardCallback(fn,data)
	                local ret,sData=base:checkServerData(data)
	                if ret==true then
	                	acLjczVoApi:updateData(sData.data.ljcz)
                       	for k,v in pairs(rewardlist) do
                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
                        end
            			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),28)
                        G_showRewardTip(rewardlist,true)
                        acLjczVoApi:afterGetReward()
	                    self:update()
	                end
	            end
	            socketHelper:ljczGetRechargeReward(k,rewardCallback)
	        end
			local menuItemAward=GetButtonItem("taskReward.png","taskReward_down.png","taskReward_down.png",rewardHandler,nil,nil,0)
		    G_addFlicker(menuItemAward,2,2)
		    menuItemAward:setScale(btnScale)
			local menuAward=CCMenu:createWithItem(menuItemAward)
	        menuAward:setPosition(ccp(posX,posY))
		    menuAward:setTouchPriority(-(self.layerNum-1)*20-2)
		    cell:addChild(menuAward,1)
		elseif flag==3 then --已领取
			pic="lightGreyBrownBg.png"
			local hasRewardLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(28*7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			hasRewardLb:setPosition(ccp(posX,posY))
			hasRewardLb:setColor(G_ColorGray)
			cell:addChild(hasRewardLb,1)
		end
		local function click(hd,fn,idx)
	    end
	    local rwBg=LuaCCScale9Sprite:createWithSpriteFrameName(pic,CCRect(14,14,2,2),click)
		if rwBg then
	    	rwBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-220,barH))
			rwBg:setAnchorPoint(ccp(0,0.5))
			rwBg:setPosition(ccp(160,posY))
			cell:addChild(rwBg)
		end
        -- 刻度线
        local keduSp=CCSprite:createWithSpriteFrameName("acRadar_splitline.png")
        keduSp:setPosition(60,k*barH+spaceH)
        cell:addChild(keduSp,3)
        --充值等级
        local numBgSp=CCSprite:createWithSpriteFrameName("acRadar_numlabel.png")
        numBgSp:setAnchorPoint(ccp(0,1))
        numBgSp:setPosition(70,k*barH+8+spaceH)
        cell:addChild(numBgSp,3)

		local needMoney=costCfg[k]
        local numLb=GetTTFLabel(needMoney,22)
        numLb:setPosition(numBgSp:getContentSize().width/2+5,numBgSp:getContentSize().height/2)
        numBgSp:addChild(numLb)
    end  

    local function click(hd,fn,idx)
    end
    local barSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acRadar_progressBg.png", CCRect(15,50,50,80),click)
    barSprie:setContentSize(CCSizeMake(86,self.cellHeight))
    barSprie:setPosition(ccp(60,self.cellHeight/2))
    cell:addChild(barSprie,1)

    AddProgramTimer(cell,ccp(60,self.cellHeight/2+10),11,12,nil,"acChunjiepansheng_progress2.png","acChunjiepansheng_progress1.png",13,1,1,nil,ccp(0,1))
    -- AddProgramTimer(cell,ccp(50,barWidth/2),11,12,nil,"acChunjiepansheng_progress2.png","acChunjiepansheng_progress1.png",13,1,1)
    local per=acLjczVoApi:getRechargePercent()
    local timerSpriteLv=cell:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    timerSpriteLv:setScaleY((totalH)/timerSpriteLv:getContentSize().height)
    timerSpriteLv:setRotation(180)
    local bg=cell:getChildByTag(13)
    bg:setScaleY((totalH)/bg:getContentSize().height)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acLjczDialog:doUserHandler()
	local strSize3 = 21
	local strColor = G_ColorWhite
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize3 = 28
		strColor = G_ColorYellowPro
	end
    spriteController:addPlist("public/acRadar_images.plist")
    spriteController:addTexture("public/acRadar_images.png")
	spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/acChunjiepansheng3.plist")
    spriteController:addTexture("public/acChunjiepansheng3.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX((G_VisibleSizeWidth-20)/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-110)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,20)
    self.bgLayer:addChild(blueBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function tmpFunc( ... )
    end
    local panelLineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),tmpFunc)
   	panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-36))
   	panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-90))
   	self.bgLayer:addChild(panelLineBg)

    if G_isIphone5() then
    	self.barH=110
    	self.iconSize=85
    end

	self.rewardCfg=acLjczVoApi:getRewardCfg()
	self.rechargeLv=SizeOfTable(self.rewardCfg)
	self.cellHeight=self.rechargeLv*self.barH+50

	local w=G_VisibleSizeWidth-20 -- 背景框的宽度
	local backSprie=CCSprite:createWithSpriteFrameName("goldAndTankBg_1.jpg")
	backSprie:setAnchorPoint(ccp(0.5,0))
	backSprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-295))
	self.bgLayer:addChild(backSprie)

	local function touch(tag,object)
		self:openInfo()
	end

	w=w-10 -- 按钮的x坐标
	local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(w,backSprie:getContentSize().height-50))
	backSprie:addChild(menuDesc)

	w=w-menuItemDesc:getContentSize().width

	local acLabel=GetTTFLabel(getlocal("activity_timeLabel"),28)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 210))
	acLabel:setColor(strColor)
	backSprie:addChild(acLabel)

	local acVo=acLjczVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,28)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 170))
	messageLabel:setColor(strColor)
	backSprie:addChild(messageLabel)
	self.timeLb=messageLabel
	self:updateAcTime()

	local desLabel=GetTTFLabel(getlocal("activity_ljcz_desc"),28)
	if desLabel:getContentSize().width > G_VisibleSizeWidth*0.9 then
	    desLabel = GetTTFLabelWrap(getlocal("activity_ljcz_desc"),25,CCSizeMake(450, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    end
	desLabel:setAnchorPoint(ccp(0.5,0))
	desLabel:setPosition(ccp(backSprie:getContentSize().width*0.5,15))
	backSprie:addChild(desLabel,1)

	local desLabelBg=CCSprite:createWithSpriteFrameName("blackGradualChange.png")
	desLabelBg:setAnchorPoint(ccp(0.5,0.5))
	local nScaleX=(desLabel:getContentSize().width+6)/desLabelBg:getContentSize().width
	desLabelBg:setScaleX(nScaleX)
	desLabelBg:setScaleY((desLabel:getContentSize().height+6)/desLabelBg:getContentSize().height)
	desLabelBg:setPosition(ccp(backSprie:getContentSize().width*0.5,desLabel:getContentSize().height*0.5+desLabel:getPositionY()))
	backSprie:addChild(desLabelBg)

	for i=1,2 do
		local posY = i ==1 and desLabel:getPositionY()+desLabel:getContentSize().height+3 or desLabel:getPositionY()-3
		local yellowLine = CCSprite:createWithSpriteFrameName("yellowLightPoint.png")
		yellowLine:setAnchorPoint(ccp(0.5,0.5))
		yellowLine:setScaleX((desLabel:getContentSize().width+6)/yellowLine:getContentSize().width)
		yellowLine:setScaleY(1.2)
		yellowLine:setPosition(ccp(backSprie:getContentSize().width*0.5,posY))
		backSprie:addChild(yellowLine)	    

		local addPosX = i == 1 and 40 or -50
		local yellowStar = CCSprite:createWithSpriteFrameName("yellowLightPointBg.png")
		yellowStar:setAnchorPoint(ccp(0.5,0.5))
		yellowStar:setPosition(yellowLine:getPositionX()+addPosX,yellowLine:getPositionY())
		yellowStar:setScaleY(0.9)
		backSprie:addChild(yellowStar)
	end

	local function click(hd,fn,idx)
    end
    -- local pageBg=LuaCCScale9Sprite:createWithSpriteFrameName("threeyear_numbg.png",CCRect(10,10,10,10),click) 
    local pageBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,20,20),click) 
    pageBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,self.cellHeight+80))
    pageBg:setAnchorPoint(ccp(0.5,1))
    pageBg:setPosition(ccp(G_VisibleSizeWidth/2,backSprie:getPositionY()))
    self.bgLayer:addChild(pageBg,1)
    self.pageBg=pageBg

    local lineSp=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setPosition(pageBg:getContentSize().width/2,pageBg:getContentSize().height)
    pageBg:addChild(lineSp)

	local rechargeLabel=GetTTFLabel(getlocal("activity_totalRecharge_totalMoney"),28)
	rechargeLabel:setAnchorPoint(ccp(0,0.5))
	rechargeLabel:setPosition(ccp(10,pageBg:getContentSize().height-40))
	pageBg:addChild(rechargeLabel)
  
	local totalMoneyLabel=GetTTFLabel(tostring(acLjczVoApi:getTotalMoney()),28)
	totalMoneyLabel:setAnchorPoint(ccp(0,0.5))
	totalMoneyLabel:setPosition(ccp(rechargeLabel:getPositionX()+rechargeLabel:getContentSize().width,rechargeLabel:getPositionY()))
	totalMoneyLabel:setColor(G_ColorYellowPro)
	pageBg:addChild(totalMoneyLabel)

	self.totalMoneyLabel=totalMoneyLabel

	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon:setAnchorPoint(ccp(0,0.5))
	goldIcon:setPosition(ccp(totalMoneyLabel:getPositionX()+totalMoneyLabel:getContentSize().width+10,totalMoneyLabel:getPositionY()))
	pageBg:addChild(goldIcon)
	self.goldIcon=goldIcon

	local function rechargeHandler(tag,object)
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		--跳转至充值页面
        vipVoApi:showRechargeDialog(self.layerNum+1)
	end

	local rechargeBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rechargeHandler,0,getlocal("new_recharge_recharge_now"),28)
	local menuRecharge=CCMenu:createWithItem(rechargeBtn)
	menuRecharge:setPosition(ccp(G_VisibleSizeWidth/2,60))
	menuRecharge:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(menuRecharge,1)

	local nextMoney=acLjczVoApi:getNextMoney()
	if nextMoney>0 then
		local tipStr=getlocal("activity_ljcz_tip",{nextMoney})
		local tipLb=GetTTFLabelWrap(tipStr,strSize3,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		tipLb:setPosition(ccp(G_VisibleSizeWidth/2,(menuRecharge:getPositionY()+37)/2+(pageBg:getPositionY()-pageBg:getContentSize().height)/2))
		tipLb:setColor(G_ColorYellowPro)
		self.bgLayer:addChild(tipLb,1)
		self.tipLb=tipLb
	else
		menuRecharge:setPosition(G_VisibleSizeWidth/2,10+(pageBg:getPositionY()-pageBg:getContentSize().height-10)/2)
	end
end

-- 更新今日充值金额
function acLjczDialog:updatetotalMoneyLabel()
	if self==nil then
		do 
			return
		end
	end
	if self.totalMoneyLabel and self.goldIcon then
		self.totalMoneyLabel:setString(tostring(acLjczVoApi:getTotalMoney()))
		self.goldIcon:setPosition(ccp(self.totalMoneyLabel:getPositionX()+self.totalMoneyLabel:getContentSize().width+10,self.goldIcon:getPositionY()))
	end
end

function acLjczDialog:openInfo()
	local td=smallDialog:new()
	local tabStr = {"\n",getlocal("activity_ljcz_rule3"),"\n",getlocal("activity_ljcz_rule2"),"\n", getlocal("activity_ljcz_rule1"),"\n"}
	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
	sceneGame:addChild(dialog,self.layerNum+1)
end

function acLjczDialog:tick()
  	local acVo=acLjczVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==false then
        self:close()
        do return end
    end
    self:updateAcTime()
end

function acLjczDialog:update()
  	local acVo=acLjczVoApi:getAcVo()
	if acVo ~= nil then
	    if activityVoApi:isStart(acVo)==false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
			if self ~= nil then
			self:close()
			end
	    elseif self~=nil and self.tv~=nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
			self:updatetotalMoneyLabel()
			local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
	    end
	    local nextMoney=acLjczVoApi:getNextMoney()
	    if self.tipLb then
	    	if nextMoney>0 then
				local tipStr=getlocal("activity_ljcz_tip",{nextMoney})
				self.tipLb:setString(tipStr)
	    	else
	    		self.tipLb:setVisible(false)
	    	end
	    end
	end
end

function acLjczDialog:updateAcTime()
	local acVo = acLjczVoApi:getAcVo()
	if acVo and self.timeLb then
		G_updateActiveTime(acVo,self.timeLb)
	end
end

function acLjczDialog:dispose()
	self.totalMoneyLabel = nil
	self.goldIcon = nil
	self.tipLb=nil
	self.rewardCfg=nil
	self.barH=120
	self.iconSize=90
	self.timeLb=nil
	self=nil

	spriteController:removePlist("public/acRadar_images.plist")
	spriteController:removeTexture("public/acRadar_images.png")
	spriteController:removePlist("public/acNewYearsEva.plist")
	spriteController:removeTexture("public/acNewYearsEva.png")
	spriteController:removePlist("public/activePicUseInNewGuid.plist")
	spriteController:removeTexture("public/activePicUseInNewGuid.png")
	spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/acChunjiepansheng3.plist")
    spriteController:removeTexture("public/acChunjiepansheng3.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
end