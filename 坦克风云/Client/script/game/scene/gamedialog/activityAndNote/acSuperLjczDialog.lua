acSuperLjczDialog=commonDialog:new()

function acSuperLjczDialog:new()
    local nc={
    	totalMoneyLabel=nil,
    	goldIcon=nil,
    	rewardCfg=nil,
    	barH=130,
    	iconSize=70,
	}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acSuperLjczDialog:initTableView()
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.pageBg:getContentSize().height-10),nil)
	self.bgLayer:addChild(self.tv,3)
	self.tv:setPosition(ccp(20,self.pageBg:getPositionY()-self.pageBg:getContentSize().height+5))
	self.tv:setAnchorPoint(ccp(0,0))
	-- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(100)
end

function acSuperLjczDialog:eventHandler(handler,fn,idx,cel)
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
    local costCfg=acSuperLjczVoApi:getCost()
  	local totalH=barH*self.rechargeLv
    local totalW=G_VisibleSizeWidth-40
    local leftW=totalW*0.08
    local totalMoney=acSuperLjczVoApi:getTotalMoney()
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
        -- print("posY---->",posY)
        posY = self.cellHeight - posY+30--用于从小到大的顺序排列，如果不需要 注释掉就可以变回从大到小的排列
    	for kk,v in pairs(rewardlist) do
    		local function newCallBack(  )
    			G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil)
    		end 
			local icon, iconScale=G_getItemIcon(v,self.iconSize,false,self.layerNum,newCallBack)
			icon:ignoreAnchorPointForPosition(false)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(ccp(10+(kk-1)*spaceW+leftW,posY-15))
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
			if acSuperLjczVoApi:isAddFlicker(v.key) then
				G_addRectFlicker2(icon,1.1,1.1,2,"p")
			end
    	end

    	local posX=totalW-110
    	local pic="darkBrownBg.png"
		local flag=acSuperLjczVoApi:checkIfReward(k)
		if flag==1 then --未完成
			local noLabel=GetTTFLabelWrap(getlocal("noReached"),strSize3,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
	                	acSuperLjczVoApi:updateData(sData.data.ljcz3)
                       	for k,v in pairs(rewardlist) do
                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
                        end
            			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),28)
                        G_showRewardTip(rewardlist,true)
                        acSuperLjczVoApi:afterGetReward()
	                    self:update()
	                end
	            end
	            socketHelper:superLjczGetRechargeReward(k,rewardCallback)
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
	    -- local rwBg=LuaCCScale9Sprite:createWithSpriteFrameName(pic,CCRect(14,14,2,2),click)
	    local rwBg = LuaCCScale9Sprite:createWithSpriteFrameName("titlesDesBg.png",CCRect(50, 20, 1, 1),click)
		if rwBg then
	    	rwBg:setContentSize(CCSizeMake(self.pageBg:getContentSize().width-30,barH))
			rwBg:setAnchorPoint(ccp(0,0.5))
			rwBg:setPosition(ccp(10,posY))
			cell:addChild(rwBg)

			local needMoney = tostring(acSuperLjczVoApi:getCost()[k])
			local blank = " "
            if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="tw" then
                blank = ""
            end
			local rewardDaysDes = GetTTFLabel(getlocal("activity_vipAction_tab2")..blank..needMoney,23)
			rewardDaysDes:setAnchorPoint(ccp(0,1))
			rewardDaysDes:setPosition(ccp(10,rwBg:getContentSize().height-8))
			rwBg:addChild(rewardDaysDes,1)

			local titlesBg = LuaCCScale9Sprite:createWithSpriteFrameName("titlesBG.png",CCRect(35, 16, 1, 1),function ()end)
			titlesBg:setContentSize(CCSizeMake(rewardDaysDes:getContentSize().width+32,rewardDaysDes:getContentSize().height+8))
			titlesBg:setAnchorPoint(ccp(0,1))
			titlesBg:setPosition(ccp(8,rwBg:getContentSize().height-5))
			rwBg:addChild(titlesBg)
		end
        -- 刻度线
        -- local keduSp=CCSprite:createWithSpriteFrameName("acRadar_splitline.png")
        -- keduSp:setPosition(60,k*barH+spaceH)
        -- cell:addChild(keduSp,3)
        --充值等级
        -- local numBgSp=CCSprite:createWithSpriteFrameName("acRadar_numlabel.png")
        -- numBgSp:setAnchorPoint(ccp(0,1))
        -- numBgSp:setPosition(70,k*barH+8+spaceH)
        -- cell:addChild(numBgSp,3)

		-- local needMoney=costCfg[k]
  --       local numLb=GetTTFLabel(needMoney,22)
  --       numLb:setPosition(numBgSp:getContentSize().width/2+5,numBgSp:getContentSize().height/2)
  --       numBgSp:addChild(numLb)
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

function acSuperLjczDialog:doUserHandler()
	local strSize3 = 21
	local strColor = G_ColorWhite
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize3 = 28
		strColor = G_ColorYellowPro
	end
	--
    spriteController:addPlist("public/acRadar_images.plist")
    spriteController:addTexture("public/acRadar_images.png")
	spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/acChunjiepansheng3.plist")
    spriteController:addTexture("public/acChunjiepansheng3.png")
    --
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    -- local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    -- blueBg:setAnchorPoint(ccp(0.5,0))
    -- blueBg:setScaleX((G_VisibleSizeWidth-20)/blueBg:getContentSize().width)
    -- blueBg:setScaleY((G_VisibleSizeHeight-110)/blueBg:getContentSize().height)
    -- blueBg:setPosition(G_VisibleSizeWidth/2,20)
    -- self.bgLayer:addChild(blueBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function tmpFunc( ... )
    end
    local panelLineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),tmpFunc)
   	panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-36))
   	panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-90))
   	self.bgLayer:addChild(panelLineBg)
   	self.panelLineBg:setVisible(false)
    if G_isIphone5() then
    	self.barH=160
    	self.iconSize=85
    end

	self.rewardCfg=acSuperLjczVoApi:getRewardCfg()
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
	local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(w,backSprie:getContentSize().height-50))
	backSprie:addChild(menuDesc)

	w=w-menuItemDesc:getContentSize().width

	-- local acLabel=GetTTFLabel(getlocal("activity_timeLabel"),28)
	-- acLabel:setAnchorPoint(ccp(0.5,1))
	-- acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 210))
	-- acLabel:setColor(strColor)
	-- backSprie:addChild(acLabel)

	-- local acVo=acSuperLjczVoApi:getAcVo()
	-- local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	-- local messageLabel=GetTTFLabel(timeStr,28)
	-- messageLabel:setAnchorPoint(ccp(0.5,1))
	-- messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 170))
	-- messageLabel:setColor(strColor)
	-- backSprie:addChild(messageLabel)
	-- self.timeLb=messageLabel
	local acTimeLb=GetTTFLabel(acSuperLjczVoApi:getTimeStr(),28)
	acTimeLb:setPosition((G_VisibleSizeWidth-80)/2+15,170)
	acTimeLb:setColor(strColor)
	backSprie:addChild(acTimeLb)
	self.timeLb=acTimeLb
	self:updateAcTime()

	AddProgramTimer(backSprie,ccp(backSprie:getContentSize().width*0.5,backSprie:getContentSize().height*0.42),11,12,nil,"PanelBuildUpBarBg.png","PanelBuildUpBar.png",13,1,1,nil)
    local per=acSuperLjczVoApi:getRechargePercent()
    local timerSpriteLv=backSprie:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    local bg=backSprie:getChildByTag(13)

    local maxCost = tostring(acSuperLjczVoApi:getCost()[SizeOfTable(acSuperLjczVoApi:getCost())])
    local totalMoneyLabel=GetTTFLabel(tostring(acSuperLjczVoApi:getTotalMoney()).."/"..maxCost,25)
	totalMoneyLabel:setAnchorPoint(ccp(0.5,0.5))
	totalMoneyLabel:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getContentSize().height*0.42))
	backSprie:addChild(totalMoneyLabel,99)

	self.totalMoneyLabel=totalMoneyLabel

	local desLabel=GetTTFLabel(getlocal("activity_ljcz_desc"),25)
	if desLabel:getContentSize().width > G_VisibleSizeWidth*0.9 then
	    desLabel = GetTTFLabelWrap(getlocal("activity_ljcz_desc"),23,CCSizeMake(550, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
    local pageBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(20,20,20,20),click) 
    pageBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-270-backSprie:getContentSize().height))
    pageBg:setAnchorPoint(ccp(0.5,1))
    pageBg:setPosition(ccp(G_VisibleSizeWidth/2,backSprie:getPositionY()))
    pageBg:setOpacity(0)
    self.bgLayer:addChild(pageBg,1)	
    self.pageBg=pageBg
  

	local function rechargeHandler(tag,object)
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		--跳转至充值页面
        vipVoApi:showRechargeDialog(self.layerNum+1)
	end

	local rechargeBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechargeHandler,0,getlocal("new_recharge_recharge_now"),28)
	local menuRecharge=CCMenu:createWithItem(rechargeBtn)
	menuRecharge:setPosition(ccp(G_VisibleSizeWidth/2,60))
	menuRecharge:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(menuRecharge,1)

	local nextMoney=acSuperLjczVoApi:getNextMoney()
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
	local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth*0.5,menuRecharge:getPositionY()+ rechargeBtn:getContentSize().height*0.9))
    mLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-26,mLine:getContentSize().height))
    mLine:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(mLine,1)
end

-- 更新今日充值金额
function acSuperLjczDialog:updatetotalMoneyLabel()
	if self==nil then
		do 
			return
		end
	end
	-- if self.totalMoneyLabel then
	-- 	self.totalMoneyLabel:setString(tostring(acSuperLjczVoApi:getTotalMoney()))
	-- end
end

function acSuperLjczDialog:openInfo()
	-- local td=smallDialog:new()
	-- local tabStr = {"\n",getlocal("activity_ljcz_rule3"),"\n",getlocal("activity_ljcz_rule2"),"\n", getlocal("activity_ljcz_rule1"),"\n"}
	-- local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
	-- sceneGame:addChild(dialog,self.layerNum+1)


	if G_checkClickEnable()==false then
		do return end
	else
		base.setWaitTime=G_getCurDeviceMillTime()
	end
	PlayEffect(audioCfg.mouseClick)
	local tabStr={}
	for i=1,3 do
		table.insert(tabStr,getlocal("activity_ljcz_rule"..i))
	end
	local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    local textSize = 25
    if G_getCurChoseLanguage() =="ru" then
        textSize = 20 
    end
    tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
end

function acSuperLjczDialog:tick()
  	local acVo=acSuperLjczVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==false then
        self:close()
        do return end
    end
    self:updateAcTime()
end

function acSuperLjczDialog:update()
  	local acVo=acSuperLjczVoApi:getAcVo()
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
	    local nextMoney=acSuperLjczVoApi:getNextMoney()
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

function acSuperLjczDialog:updateAcTime()
	-- local acVo = acSuperLjczVoApi:getAcVo()
	-- if acVo and self.timeLb then
	-- 	G_updateActiveTime(acVo,self.timeLb)
	-- end
	if self then
		if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
    		self.timeLb:setString(acSuperLjczVoApi:getTimeStr())
        end
	end
end

function acSuperLjczDialog:dispose()
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