--加速道具小面板
speedUpPropSmallDialog=smallDialog:new()

function speedUpPropSmallDialog:new(spType,spType2,callBack)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dialogWidth=600
	if G_isIphone5() then
		nc.dialogHeight=960
	else
		nc.dialogHeight=850
	end
	nc.tv = nil
	nc.propTb = nil
	nc.speedType = spType--加速类型(建筑加速/科技加速/生产加速/改造加速)
	nc.speedType1= spType2--若加速类型是建筑加速，这里是建筑id；若加速类型是科技加速，这里是科技id；若加速类型是生产加速，这里是舰船类型。
	nc.upgradeCallBack = callBack
	nc.firstCellBg = nil --显示被加速者状态变化，用于tick刷新状态
	nc.canSpeedTime = nil--vip免费加速的时间
	nc.costGem = nil --加速花费的钻石
	nc.btnState = nil --加速按钮当前的状态
	nc.speedUpSelectDialog = nil--道具使用数量选择面板
	spriteController:addPlist("public/acNewYearsEva.plist")
	spriteController:addTexture("public/acNewYearsEva.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	return nc
end

function speedUpPropSmallDialog:init(layerNum)
	if self.speedType==1 then--建筑加速
	    self.propTb={"p3401","p3402","p3403","p3404"}
	elseif self.speedType==2 then--科技加速
		self.propTb={"p3421","p3422","p3423","p3424"}
	elseif self.speedType==3 or self.speedType==4 then--坦克生产/改造加速
		self.propTb={"p3411","p3412","p3413","p3414"}
	end
	if self.propTb == nil then
		do  return  end
	end
	-- self:sortPropTb()
	if base.fs==1 and (self.speedType == 1 or self.speedType == 2) then
	    self.canSpeedTime=playerVoApi:getFreeTime()
	end
	self.isTouch=nil
	self.layerNum=layerNum
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
	base:addNeedRefresh(self)
	local function close()
		-- if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			PlayEffect(audioCfg.mouseClick)
			return self:close()
		-- end
	end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)
	
	local titleLb=GetTTFLabel(getlocal("accelerateBuild"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb,1)

	local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),nilFunc)
    backSprie:setContentSize(CCSizeMake(self.dialogWidth - 40,166-20))
	backSprie:setAnchorPoint(ccp(0,0))
	backSprie:setPosition(ccp(20,self.dialogHeight - backSprie:getContentSize().height - 90 + 10))
	dialogBg:addChild(backSprie)

	if self.speedType1 then
		if self.speedType == 1 then
			self:showBuildingContent(backSprie)
	    elseif self.speedType == 2 then
	    	self:showTechContent(backSprie)
	    elseif self.speedType == 3 or self.speedType==4 then
	    	self:showProduceContent(backSprie)
		end
		self.firstCellBg = backSprie
    end

    local function touchLuaSpr()
         
    end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)
    
	local function tvCallBack(...)
		return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth - 40,backSprie:getPositionY()-18 - 4 - 30),nil)--4是上下间隔
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-4)
    self.tv:setPosition(ccp(20,18))
    dialogBg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(80)

    local function nilFunc()
	end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),nilFunc)
    tvBg:setContentSize(CCSizeMake(self.dialogWidth - 40,backSprie:getPositionY()-18))
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(ccp(20,16))
	dialogBg:addChild(tvBg,1)
	local goldLineSp=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
	goldLineSp:setAnchorPoint(ccp(0.5,1))
	goldLineSp:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height-5))
	tvBg:addChild(goldLineSp)


	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))

	return self.dialogLayer
end

function speedUpPropSmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.propTb)
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(self.dialogWidth - 40,170)
    elseif fn=="tableCellAtIndex" then
    	local strSize2Sub = 3
    	local strPosX2 = 5
    	if G_getCurChoseLanguage() =="ru" then
    		strSize2Sub = 4
    	elseif G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
    		strSize2Sub = 0
    		strPosX2 = 20
    	end
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local function nilFunc()
		end
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
        
        backSprie:setContentSize(CCSizeMake(self.dialogWidth - 40,166))
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setPosition(ccp(0,4))
		cell:addChild(backSprie)
		backSprie:setOpacity(0)

		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScaleX((backSprie:getContentSize().width-80)/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(backSprie:getContentSize().width/2,0))
		backSprie:addChild(lineSp)

		local totalW = backSprie:getContentSize().width
	    local totalH = backSprie:getContentSize().height

		local pid=self.propTb[idx+1]
		local hadNum = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
		
	    local lbName=GetTTFLabelWrap(getlocal(propCfg[pid].name),26-strSize2Sub,CCSizeMake(270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    lbName:setAnchorPoint(ccp(0,1))
	    lbName:setPosition(120,totalH - 20)
	    backSprie:addChild(lbName)
        local labelColor=G_getLbColorByPid(pid)
	    lbName:setColor(labelColor)

	    
	    local lbNum=GetTTFLabel(getlocal("propOwned")..hadNum,22-strSize2Sub)
	    lbNum:setAnchorPoint(ccp(0,0))
	    lbNum:setPosition(strPosX2,10)
	    backSprie:addChild(lbNum,2)
	    
	    local rewardTb={p={}}
	    rewardTb.p[pid]=1
	    local reward=FormatItem(rewardTb) or {}
	    local sprite
	    if reward[1] then
			sprite=G_getItemIcon(reward[1],100)
		else
		    sprite = CCSprite:createWithSpriteFrameName(propCfg[pid].icon)
		end
	    sprite:setAnchorPoint(ccp(0.5,0.5))
	    sprite:setPosition(60,totalH/2 + 10)
	    backSprie:addChild(sprite,2)
	    
	    local lbDescription=GetTTFLabelWrap(getlocal(propCfg[pid].description),22-strSize2Sub,CCSize(270, 100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    lbDescription:setAnchorPoint(ccp(0,1))
	    lbDescription:setPosition(120,totalH-30-lbName:getContentSize().height)
	    backSprie:addChild(lbDescription,2)

	    if hadNum > 0 then
	        local function touchUse()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
	                if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
	                else
	                    base.setWaitTime=G_getCurDeviceMillTime()
	                end
	                PlayEffect(audioCfg.mouseClick)
	                
	                local function realUseProp( ... )
	                	self:useProp(pid,1)
	                end
	                
                    local isOverFlow,isStopAutoUpgrade=self:isTimeOverFlow(pid)
                    if isOverFlow==true then
                    	local addDesc=getlocal("speedUpProp_overflow")
                    	if isStopAutoUpgrade==true then
                    		addDesc=addDesc..getlocal("building_auto_upgrade_quick")
                    	end
                    	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),realUseProp,getlocal("dialog_title_prompt"),addDesc,nil,self.layerNum+1)
                    else
                    	realUseProp()
                    end
                end
            end
            
            local useBtnSize=26
            if G_getCurChoseLanguage()=="ru" then
                useBtnSize=22
            end
            local useMenuItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",touchUse,11,getlocal("use"),useBtnSize)
	        useMenuItem:setScale(0.9)
	        local useMenu = CCMenu:createWithItem(useMenuItem)
	        useMenu:setPosition(ccp(totalW-90,45))
	        useMenu:setTouchPriority(-(self.layerNum-1)*20-3)
	        backSprie:addChild(useMenu,3)
            
            local useType=tonumber(propCfg[pid].useType) or 0
	        if hadNum > 1 and useType == 1 then
		        local function touchUse2()
		        	if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		                if G_checkClickEnable()==false then
		                    do
		                        return
		                    end
		                else
		                    base.setWaitTime=G_getCurDeviceMillTime()
		                end
		                PlayEffect(audioCfg.mouseClick)
		                if self.speedUpSelectDialog then
		                    self.speedUpSelectDialog:close()
		                    self.speedUpSelectDialog = nil 
		                end              
		                local leftTime
		                if self.speedType == 1 then
		                	leftTime = buildingVoApi:getUpgradeLeftTime(self.speedType1)
                        elseif self.speedType == 2 then
                        	leftTime = technologyVoApi:leftTime(self.speedType1)
                        elseif self.speedType == 3 then
                        	leftTime = tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
                        elseif self.speedType == 4 then
                        	leftTime = tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
                        end
                        if leftTime and leftTime > 0 then
                        	local function sureUseProc(selectNum)--selectNum  所选择的要使用的道具数量
			                    if self.speedType == 1 then
				                	self:buildingSuperUpgrade(pid,selectNum)
		                        elseif self.speedType == 2 then
		                        	self:techSuperUpgrade(pid,selectNum)
		                        elseif self.speedType == 3 or self.speedType == 4 then
		                        	self:shipsSuperProduce(pid,selectNum)
		                        end
			                end
			                local function closeSelect()
			                	self.speedUpSelectDialog = nil
			                end
                        	require "luascript/script/componet/speedUpPropSelectDialog"
		                    self.speedUpSelectDialog=speedUpPropSelectDialog:new(pid,self.speedType,self.speedType1,sureUseProc,closeSelect,self)
		                    self.speedUpSelectDialog:init(self.layerNum+1)
                        end
	                end
	            end
	            
	            local useBtnSize=26
	            if G_getCurChoseLanguage()=="ru" then
	                useBtnSize=22
	            end
	            local useMenuItem2 = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",touchUse2,11,getlocal("prop_use_type1"),useBtnSize)
		        useMenuItem2:setScale(0.9)
		        local useMenu2 = CCMenu:createWithItem(useMenuItem2)
		        useMenu2:setPosition(ccp(totalW-90,totalH - 45))
		        useMenu2:setTouchPriority(-(self.layerNum-1)*20-3)
		        backSprie:addChild(useMenu2,4)
		    end
	    else
	    	local  function touch1()
	    		if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
	                if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
	                else
	                    base.setWaitTime=G_getCurDeviceMillTime()
	                end
	                PlayEffect(audioCfg.mouseClick)
	        		local  function touchBuy()
	                	self:useProp(pid,0)
	                end
	                local function buyGems()
			            if G_checkClickEnable()==false then
			                do
			                    return
			                end
			            end
			            vipVoApi:showRechargeDialog(self.layerNum+1)
			        end

			        if playerVo.gems<tonumber(propCfg[pid].gemCost) then
			            local num=tonumber(propCfg[pid].gemCost)-playerVo.gems
			            local smallD=smallDialog:new()
		                smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(propCfg[pid].gemCost),playerVo.gems,num}),nil,self.layerNum+1)
			        else
		                local addStr=""
	                    local isOverFlow,isStopAutoUpgrade=self:isTimeOverFlow(pid)
	                    if isOverFlow==true then
	                    	-- addStr="\n"..getlocal("speedUpProp_overflow")
	                    	if isStopAutoUpgrade==true then
	                    		addStr=addStr..getlocal("building_auto_upgrade_quick")
	                    	end
	                    end
			            local smallD=smallDialog:new()
			            smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{propCfg[pid].gemCost,getlocal(propCfg[pid].name)})..addStr,nil,self.layerNum+1)
			        end
			    end   
       		 end
            
            local btnSize=25
            if G_getCurChoseLanguage()=="ru" then
                btnSize=22
            end
       		local buyUseMenuItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touch1,11,getlocal("buyAndUse"),btnSize)
            buyUseMenuItem:setScale(0.9)
            local buyUseMenu = CCMenu:createWithItem(buyUseMenuItem)
            buyUseMenu:setPosition(ccp(totalW-90,50))
            buyUseMenu:setTouchPriority(-(self.layerNum-1)*20-3)
            backSprie:addChild(buyUseMenu,3)

            local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
            gemIcon:setAnchorPoint(ccp(1,0.5))
		    gemIcon:setPosition(ccp(totalW - 100,totalH/2 + 40))
		    backSprie:addChild(gemIcon,2)

		    local lbPrice=GetTTFLabel(propCfg[pid].gemCost,24)
		    lbPrice:setAnchorPoint(ccp(0,0.5))
		    lbPrice:setPosition(gemIcon:getPositionX()+10,gemIcon:getPositionY())
		    backSprie:addChild(lbPrice,2)
		    if(playerVoApi:getGems()<propCfg[pid].gemCost)then
				lbPrice:setColor(G_ColorRed)
			end

	    end
        return cell
    elseif fn=="ccTouchBegan" then
        isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function speedUpPropSmallDialog:showCommonContent(leftTime,totalTime,backSprie,superHandler)
	local totalW = backSprie:getContentSize().width
    local totalH = backSprie:getContentSize().height
    local changePosY = 40
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
    	changePosY = 60
    end
	AddProgramTimer(backSprie,ccp(250,changePosY),11,22,GetTimeStr(leftTime),"res_progressbg.png","resblue_progress.png",33)
    local progress= tolua.cast(backSprie:getChildByTag(11),"CCProgressTimer")
    progress:setPercentage((1-leftTime/totalTime)*100)
    progress:setScaleX(0.9)
    local progressBg= tolua.cast(backSprie:getChildByTag(33),"CCProgressTimer")
    progressBg:setScaleX(0.9)

    AddProgramTimer(backSprie,ccp(250,changePosY),12,23,GetTimeStr(leftTime),nil,"resyellow_progress.png",34)
    local progress1= tolua.cast(backSprie:getChildByTag(12),"CCProgressTimer")
    progress1:setPercentage((1-leftTime/totalTime)*100)
    progress1:setScaleX(0.9)
    progress1:setVisible(false)
    -- local progressBg1= tolua.cast(backSprie:getChildByTag(34),"CCProgressTimer")
    -- progressBg1:setScaleX(0.9)
    -- progressBg1:setOpacity(0)

    
    local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    gemIcon:setAnchorPoint(ccp(1,0.5))
	gemIcon:setPosition(ccp(totalW-100,totalH/2 + 40))
	backSprie:addChild(gemIcon)
	gemIcon:setTag(202)

    local needGemsNum=TimeToGems(leftTime)
    self.btnState = 0
    if base.fs==1 and self.canSpeedTime then
        if leftTime <= self.canSpeedTime then
            needGemsNum = 0
            self.btnState = 1

            progress:setVisible(false)
            progress1:setVisible(true)
        end
    end
    self.costGem = needGemsNum
    local gemLb=GetTTFLabel(needGemsNum,25)
	if(playerVoApi:getGems()<needGemsNum)then
		gemLb:setColor(G_ColorRed)
	end
	gemLb:setTag(201)
	gemLb:setAnchorPoint(ccp(0,0.5))
	gemLb:setPosition(ccp(gemIcon:getPositionX()+ 10,gemIcon:getPositionY()))
	backSprie:addChild(gemLb)

	local fontSize = 25
    if G_getCurChoseLanguage()=="de" then
        fontSize = 23
    end
    local superItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",superHandler,10,getlocal("accelerateBuild"),fontSize,11)--11为文字的Tag
    superItem:setScale(0.9)
    local superMenu=CCMenu:createWithItem(superItem)
    superMenu:setPosition(ccp(totalW-90,60))
    superMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    superMenu:setTag(101)
    backSprie:addChild(superMenu)

    local superItemFree=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",superHandler,10,getlocal("freeAccelerate"),fontSize,11)--11为文字的Tag
    superItemFree:setScale(0.9)
    local superMenuFree=CCMenu:createWithItem(superItemFree)
    superMenuFree:setPosition(ccp(totalW-90,60))
    superMenuFree:setTouchPriority(-(self.layerNum-1)*20-3)
    superMenuFree:setTag(102)
    backSprie:addChild(superMenuFree)

    if self.btnState == 0 then
    	superItemFree:setEnabled(false)
    	superMenuFree:setVisible(false)
    elseif self.btnState == 1 then
    	superItem:setEnabled(false)
    	superMenu:setVisible(false)

    end
end

--刷新相同的内容
function speedUpPropSmallDialog:updateCommonContent(leftTime,totalTime)
	local progress= tolua.cast(self.firstCellBg:getChildByTag(11),"CCProgressTimer")
    -- if progress~=nil then
    --     progress:setPercentage((1-leftTime/totalTime)*100)
    --     tolua.cast(progress:getChildByTag(22),"CCLabelTTF"):setString(GetTimeStr(leftTime))
    -- end
    local progress1= tolua.cast(self.firstCellBg:getChildByTag(12),"CCProgressTimer")

    local needGemsNum=TimeToGems(leftTime)
    local btnState = 0
    if base.fs==1 and self.canSpeedTime then
        if leftTime <= self.canSpeedTime then
            needGemsNum = 0
            btnState = 1
        end
    end
    if btnState==1 then
    	if progress~=nil then
	    	progress:setVisible(false)
	    end
	    if progress1~=nil then
            progress1:setVisible(true)
            progress1:setPercentage((1-leftTime/totalTime)*100)
	        tolua.cast(progress1:getChildByTag(23),"CCLabelTTF"):setString(GetTimeStr(leftTime))
        end
    else
    	if progress~=nil then
	    	progress:setVisible(true)
	    	progress:setPercentage((1-leftTime/totalTime)*100)
	        tolua.cast(progress:getChildByTag(22),"CCLabelTTF"):setString(GetTimeStr(leftTime))
	    end
	    if progress1~=nil then
            progress1:setVisible(false)
        end
    end
    if self.costGem ~= needGemsNum then
    	self.costGem = needGemsNum
    	if self.costGem>0 then
    		local gemIcon = tolua.cast(self.firstCellBg:getChildByTag(202),"CCSprite")
			if gemIcon then
		        gemIcon:setVisible(true)
		        local gemLb = tolua.cast(self.firstCellBg:getChildByTag(201),"CCLabelTTF")
		        if gemLb then
			        gemLb:setString(needGemsNum)
			        if(playerVoApi:getGems()<needGemsNum)then
						gemLb:setColor(G_ColorRed)
					else
						gemLb:setColor(G_ColorWhite)
					end
					gemLb:setAnchorPoint(ccp(0,0.5))
					gemLb:setPosition(ccp(gemIcon:getPositionX()+ 10,gemIcon:getPositionY()))
				end
		    end
		else
		    local gemIcon = tolua.cast(self.firstCellBg:getChildByTag(202),"CCSprite")
		    if gemIcon then
		        gemIcon:setVisible(false)
		        local gemLb = tolua.cast(self.firstCellBg:getChildByTag(201),"CCLabelTTF")
				if gemLb then
			        gemLb:setString(getlocal("daily_lotto_tip_2"))
			        gemLb:setColor(G_ColorYellowPro)
			        gemLb:setAnchorPoint(ccp(0.5,0.5))
					gemLb:setPosition(ccp(gemIcon:getPositionX()+ 10,gemIcon:getPositionY()))
			    end
		    end
		end
    end
	
	if self.btnState ~= btnState then
		self.btnState = btnState
		local superMenu = tolua.cast(self.firstCellBg:getChildByTag(101),"CCMenuItem")
		local superItem = tolua.cast(superMenu:getChildByTag(10),"CCMenuItemSprite")

		local superMenuFree = tolua.cast(self.firstCellBg:getChildByTag(102),"CCMenuItem")
		local superItemFree = tolua.cast(superMenuFree:getChildByTag(10),"CCMenuItemSprite")
		if self.btnState == 0 then
	    	superItemFree:setEnabled(false)
	    	superMenuFree:setVisible(false)
	    	superItem:setEnabled(true)
	    	superMenu:setVisible(true)
	    elseif self.btnState == 1 then
	    	superItemFree:setEnabled(true)
	    	superMenuFree:setVisible(true)
	    	superItem:setEnabled(false)
	    	superMenu:setVisible(false)
	    end
	end
end

function speedUpPropSmallDialog:useProp(pid,selectNum)
	local hadNums = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
	local bid = nil
	local slotid,slot
    if self.speedType == 1 then
    	bid = self.speedType1
    elseif self.speedType == 2 then
    	slotid = technologySlotVoApi:getSlotByTid(self.speedType1).slotid
    elseif self.speedType == 3 or self.speedType == 4 then
    	bid = self.speedType1[1]
    	slotid= tonumber(self.speedType1[2])
    	if self.speedType == 3 then
	    	slot=tankSlotVoApi:getSlotBySlotid(bid,slotid)
	    elseif self.speedType == 4 then
	    	slot=tankUpgradeSlotVoApi:getSlotBySlotid(bid,slotid)
	    end
    end
    
    local function callbackUseProc(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            --统计使用物品
            statisticsHelper:useItem(pid,selectNum)
            local str = getlocal("use_prop_success",{getlocal(propCfg[pid].name)})
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
            if self.speedType == 1 then
		    	local bvo=buildingVoApi:getBuildiingVoByBId(self.speedType1)
			    --升级完成
			    if bvo.status==1 then
			    	if buildingVoApi:superUpgradeBuild(self.speedType1,true) then --加速成功
				        base:tick()
				    end
			    end
		    elseif self.speedType == 2 then
		    	local techVo=technologyVoApi:getTechVoByTId(self.speedType1)
		    	if techVo.status == 0 then
		    		--升级完成
                    technologyVoApi:superUpgrade(self.speedType1,true)
		    	end
		    elseif self.speedType == 3 then
		    	local result,reason=tankVoApi:checkSuperUpgradeBeforeSendServer(bid,slotid)
		    	if reason == 1 then
		    		eventDispatcher:dispatchEvent("tankslot.speedup")
		    		local tankname=getlocal(tankCfg[slot.itemId].name)
                    local tankInfo = getlocal("task_name_group_t",{slot.itemNum,tankname})
                    local finishedTip = getlocal("promptProduceFinish",{tankInfo})
                    local rewardTb={o={}}
                    rewardTb.o["a"..slot.itemId]=slot.itemNum
                    local reward=FormatItem(rewardTb)
        			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),finishedTip,28,nil,true,reward)
                    G_cancelPush("t"..bid.."_"..slotid,G_TankProduceTag)
		    	end
		    elseif self.speedType == 4 then
		    	local result,reason=tankVoApi:checkUpgradeReBeforeSendServer(bid,slotid)
		    	if reason == 1 then
		    		eventDispatcher:dispatchEvent("tankslot.speedup")
		    		local tankName=getlocal(tankCfg[slot.itemId].name)
		    		local getTip = getlocal("promptProduceFinish",{tankName})
		    		local rewardTb={o={}}
                    rewardTb.o["a"..slot.itemId]=slot.itemNum
                    local reward=FormatItem(rewardTb)
		    		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getTip,28,nil,true,reward)
                    G_cancelPush("t"..bid.."_"..slotid,G_TankUpgradeTag)
		    	end
		    end
            -- self:close()
            self:refreshUI()
		    eventDispatcher:dispatchEvent("speedUpProp.useProp",{type=self.speedType})
        end
    end

	if selectNum == 0 and hadNums == 0 then
		socketHelper:useSpeedUpProp(tonumber(RemoveFirstChar(pid)),1,callbackUseProc,nil,bid,slotid)
    elseif selectNum > 0 and selectNum <= hadNums then
        socketHelper:useSpeedUpProp(tonumber(RemoveFirstChar(pid)),nil,callbackUseProc,selectNum,bid,slotid)
	end
end

--建筑加速升级
function speedUpPropSmallDialog:buildingSuperUpgrade(pid,selectNum)
	local bvo=buildingVoApi:getBuildiingVoByBId(self.speedType1)
	local bsv=buildingSlotVoApi:getSlotByBid(bvo.id)
    if bsv==nil then
        return
    end
	local leftTime=buildingVoApi:getUpgradeLeftTime(bvo.id)
    --升级进度条
    if bvo.status==2 and leftTime > 0 then		
	    if base.fs == 1 and self.canSpeedTime and leftTime<=self.canSpeedTime then
	        local function serverSuperUpgrade(fn,data)
				if base:checkServerData(data)==true then  
				    if buildingVoApi:superUpgradeBuild(self.speedType1) then --加速成功
				        base:tick()
				    end
				    self:close()
				end
			end

			if buildingVoApi:checkSuperUpgradeBuildBeforeServer(self.speedType1)==true then
			     socketHelper:freeUpgradeBuild(self.speedType1,bvo.type,serverSuperUpgrade)
			end
	    elseif pid and selectNum and selectNum > 0 then
	    	self:useProp(pid,selectNum)
	    else
	        if self.upgradeCallBack then
	         	self:upgradeCallBack()
	        end
	    end
	end
end

--显示建筑加速信息
function speedUpPropSmallDialog:showBuildingContent(backSprie)
	local totalW = backSprie:getContentSize().width
    local totalH = backSprie:getContentSize().height
	local bvo=buildingVoApi:getBuildiingVoByBId(self.speedType1)
    --升级进度条
    if bvo.status==2 then
    	local bcfg=buildingCfg[bvo.type]
	    local itemImgContainer=CCSprite:createWithSpriteFrameName(bcfg.icon)
	    itemImgContainer:setAnchorPoint(ccp(0.5,0.5))
	    itemImgContainer:setPosition(ccp(60,totalH/2))
	    backSprie:addChild(itemImgContainer,1)

	    local bNameStr = getlocal(bcfg.buildName)
	    if bvo.type == 17 then
	    	local iconWidth = 100
		    local iconBg = CCSprite:createWithSpriteFrameName("Icon_BG.png")
		    iconBg:setScale(iconWidth / iconBg:getContentSize().width)
		    iconBg:setPosition(ccp(60,totalH/2))
		    backSprie:addChild(iconBg)

		    bNameStr = getlocal("repair_factory")
	    end

	    local bNameLb= GetTTFLabel(bNameStr,26) 
	    bNameLb:setAnchorPoint(ccp(0,1))
	    if base.newMainUi==1 then
	        bNameLb:setColor(G_ColorYellowTask)  
	    end
	    bNameLb:setPosition(ccp(115,totalH/2 + itemImgContainer:getContentSize().height/2))
	    backSprie:addChild(bNameLb)

        local leftTime= buildingVoApi:getUpgradeLeftTime(self.speedType1)
        local totalTime=buildingVoApi:getUpgradingTotalUpgradeTime(self.speedType1)

        --加速升级按钮
	    local function superHandler()
	        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                self:buildingSuperUpgrade()
            end
	    end
        self:showCommonContent(leftTime,totalTime,backSprie,superHandler) 
	else
		self:close()
    end   
end
--刷新建筑加速信息
function speedUpPropSmallDialog:updateBuildingContent()
	if self.speedType1 and self.firstCellBg then
		local bvo=buildingVoApi:getBuildiingVoByBId(self.speedType1)
	    if bvo.status==2 then--建筑状态 -1:未解锁 0:未建造 1:正常 2:升级 
	        local leftTime=buildingVoApi:getUpgradeLeftTime(self.speedType1)
	        local totalTime=buildingVoApi:getUpgradingTotalUpgradeTime(self.speedType1)
            self:updateCommonContent(leftTime,totalTime)
	    else
	    	self:close()
		end
	end
end

--科技加速升级
function speedUpPropSmallDialog:techSuperUpgrade(pid,selectNum)
	local techVo=technologyVoApi:getTechVoByTId(self.speedType1)
	local leftTime=technologyVoApi:leftTime(techVo.id) or 0
    if techVo.status == 1  and leftTime > 0 then
		if base.fs==1 and self.canSpeedTime and leftTime<=self.canSpeedTime then
		    local function superServerHandler(fn,data)
	            if base:checkServerData(data)==true then
	                technologyVoApi:superUpgrade(techVo.id)
	            end
	        end
	        local result,reason=technologyVoApi:checkSuperUpgradeBeforeSendServer(techVo.id,true)
	        if result==false then
	            if reason==1 then --升级已完成
	                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("indexisSpeed"),nil,self.layerNum+1)
	            end
	        else
	            socketHelper:freeUpgradeTech(techVo.id,superServerHandler) --通知服务器
	        end
	    elseif pid and selectNum and selectNum > 0 then
	    	self:useProp(pid,selectNum)
		else
		    if self.upgradeCallBack then
		     	self:upgradeCallBack()
		    end
		end
	end
end
--显示科技加速信息
function speedUpPropSmallDialog:showTechContent(backSprie)
	local totalW = backSprie:getContentSize().width
    local totalH = backSprie:getContentSize().height
    --status--0:正常  1：正在升级 2：等待
    local techVo=technologyVoApi:getTechVoByTId(self.speedType1)
    if techVo.status == 1 then
	    local tcfg=techCfg[tonumber(techVo.id)]
		local sp=CCSprite:createWithSpriteFrameName(tcfg.icon)
		sp:setAnchorPoint(ccp(0.5,0.5))
		sp:setPosition(ccp(60,totalH/2))
		backSprie:addChild(sp)
		local nameLb
		if techVo.status~=0 then
		    nameLb=GetTTFLabelWrap(getlocal(tcfg.name).." LV."..techVo.level.."->LV."..(techVo.level+1),21,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		else
		    nameLb=GetTTFLabelWrap(getlocal(tcfg.name).."("..G_LV()..techVo.level..")",21,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		  end
		nameLb:setColor(G_ColorGreen)
		nameLb:setAnchorPoint(ccp(0,1))
		nameLb:setPosition(ccp(115,totalH/2 + sp:getContentSize().height/2))
		backSprie:addChild(nameLb)

        local leftTime,totalTime=technologyVoApi:leftTime(techVo.id)

		--加速升级按钮
	    local function superHandler()
	        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                self:techSuperUpgrade()
            end
	    end
	    self:showCommonContent(leftTime,totalTime,backSprie,superHandler)
    else
    	self:close()
    end
end
--刷新科技加速信息
function speedUpPropSmallDialog:updateTechContent()
	if self.speedType1 and self.firstCellBg then
		local techVo=technologyVoApi:getTechVoByTId(self.speedType1)
	    if techVo.status == 1 then
	        local leftTime,totalTime=technologyVoApi:leftTime(techVo.id)
	        self:updateCommonContent(leftTime,totalTime)
	    else
	    	self:close()
		end
	end
end

--坦克加速生产
function speedUpPropSmallDialog:shipsSuperProduce(pid,selectNum)
	local slot   
    if self.speedType == 3 then
    	slot=tankSlotVoApi:getSlotBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
    elseif self.speedType == 4 then
    	slot=tankUpgradeSlotVoApi:getSlotBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
    end
    if slot and slot.status == 1 then
    	local leftTime,totalTime
		if self.speedType == 3 then
			leftTime,totalTime=tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
        elseif self.speedType == 4 then
        	leftTime,totalTime=tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
        end
        if leftTime and leftTime > 0 then
        	if pid and selectNum and selectNum > 0 then
                self:useProp(pid,selectNum)
            else
            	if self.upgradeCallBack then
                 	self:upgradeCallBack()
                end
            end
        end
    end
end
--显示坦克生产加速信息
function speedUpPropSmallDialog:showProduceContent(backSprie)
	local totalW = backSprie:getContentSize().width
    local totalH = backSprie:getContentSize().height
    local slot
    if self.speedType == 3 then
    	slot=tankSlotVoApi:getSlotBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
    elseif self.speedType == 4 then
    	slot=tankUpgradeSlotVoApi:getSlotBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
    end
    if slot and slot.status == 1 then
		local sprite = tankVoApi:getTankIconSp(slot.itemId)--CCSprite:createWithSpriteFrameName(tankCfg[tonumber(slot.itemId)].icon)
		sprite:setAnchorPoint(ccp(0.5,0.5))
		sprite:setPosition(60,totalH/2)
		sprite:setScale(100/sprite:getContentSize().width)
		backSprie:addChild(sprite)

		local strName = getlocal(tankCfg[slot.itemId].name).."*"..slot.itemNum
		local lbName=GetTTFLabelWrap(strName,24,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		lbName:setAnchorPoint(ccp(0,1))
		lbName:setPosition(115,totalH/2 + 100/2)
		backSprie:addChild(lbName)

		local leftTime,totalTime
		if self.speedType == 3 then
			leftTime,totalTime=tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
        elseif self.speedType == 4 then
        	leftTime,totalTime=tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
        end

		--加速升级按钮
	    local function superHandler()
	        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                self:shipsSuperProduce()
            end
	    end
	    self:showCommonContent(leftTime,totalTime,backSprie,superHandler)
	else
		self:close()
	end
end
--刷新坦克生产加速信息
function speedUpPropSmallDialog:updateProduceContent()
	if self.speedType1 and self.firstCellBg then
		local slot
	    if self.speedType == 3 then
	    	slot=tankSlotVoApi:getSlotBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
	    elseif self.speedType == 4 then
	    	slot=tankUpgradeSlotVoApi:getSlotBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
	    end
	    if slot and slot.status == 1 then
	        local leftTime,totalTime
	        if self.speedType == 3 then
				leftTime,totalTime=tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
	        elseif self.speedType == 4 then
	        	leftTime,totalTime=tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
	        end
	        self:updateCommonContent(leftTime,totalTime)
	    else
	    	self:close()
		end
	end
end

function speedUpPropSmallDialog:tick()
	if self.speedType == 1 then
		self:updateBuildingContent()
    elseif self.speedType == 2 then
        self:updateTechContent()
    elseif self.speedType == 3 or self.speedType == 4 then
        self:updateProduceContent()
	end

	if self.speedUpSelectDialog then
		self.speedUpSelectDialog:tick()
	end
end

function speedUpPropSmallDialog:sortPropTb()
	if self.propTb then
		local tmpTb={}
		for k,v in pairs(self.propTb) do
			local pid=(tonumber(v) or tonumber(RemoveFirstChar(v)))
			local num=bagVoApi:getItemNumId(pid) or 0
			table.insert(tmpTb,{id=v,num=num,pid=pid})
		end
		local function sortFunc(a,b)
			if (a.num>0 and b.num>0) or (a.num<=0 and b.num<=0) then
				return a.pid<b.pid
			else
				return a.num>b.num
			end
		end
		table.sort(tmpTb,sortFunc)
		self.propTb={}
		for k,v in pairs(tmpTb) do
			table.insert(self.propTb,v.id)
		end
	end
end

function speedUpPropSmallDialog:isTimeOverFlow(pid)
	local isOverFlow,isStopAutoUpgrade=false
	if pid and propCfg[pid] then
		local leftTime
	    if self.speedType == 1 then
	    	leftTime = buildingVoApi:getUpgradeLeftTime(self.speedType1)
	    elseif self.speedType == 2 then
	    	leftTime = technologyVoApi:leftTime(self.speedType1)
	    elseif self.speedType == 3 then
	    	leftTime = tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
	    elseif self.speedType == 4 then
	    	leftTime = tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.speedType1[1],tonumber(self.speedType1[2]))
	    end
	    if leftTime then
	    	local useTimeDecrease=propCfg[pid].useTimeDecrease
	    	if leftTime<useTimeDecrease then
	    		isOverFlow=true
	    	end
	    end
	end
    if self.speedType == 1 and base.autoUpgrade==1 and buildingVoApi:getAutoUpgradeBuilding()==1 and buildingVoApi:getAutoUpgradeExpire()-base.serverTime>0 then
    	isStopAutoUpgrade=true
    end
    return isOverFlow,isStopAutoUpgrade
end

function speedUpPropSmallDialog:refreshUI()
	if self then
		self:tick()
	    if self.tv then
	    	-- self:sortPropTb()
	    	local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
	    end
	end
end

function speedUpPropSmallDialog:dispose()
	base:removeFromNeedRefresh(self)
	if self.speedUpSelectDialog then
		self.speedUpSelectDialog:close()
		self.speedUpSelectDialog = nil
	end
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.tv = nil
	self.propTb = nil
	self.speedType = nil--加速类型(建筑加速/科技加速/生产加速)
	self.speedType1= nil--若加速类型是建筑加速，这里是建筑类型；若加速类型是科技加速，这里是科技类型；若加速类型是生产加速，这里是舰船类型。
	self.firstCellBg = nil
	self.canSpeedTime = nil--vip免费加速的时间
	self.costGem = nil --加速花费的钻石
	self.btnState = nil --加速按钮当前的状态
	spriteController:removePlist("public/acNewYearsEva.plist")
	spriteController:removeTexture("public/acNewYearsEva.png")
	spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
    self = nil
end