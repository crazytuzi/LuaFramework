
acMonsterComebackDialog=commonDialog:new()

function acMonsterComebackDialog:new()
    local nc=commonDialog:new()
    setmetatable(nc,self)
    self.__index=self
	
	self.characterSp=nil
	self.descBg=nil
	self.rewardBg=nil
	self.tankPic=nil
	self.isMoving=nil
	self.goldSp1=nil
	self.goldSp2=nil
	self.gemsLabel1=nil
	self.gemsLabel2=nil
	self.lotteryOneBtn=nil
	self.lotteryTenBtn=nil
	self.make1Btn=nil
	self.make2Btn=nil
	self.tank1progress=nil
	self.tank2progress=nil
	self.pieceSp1=nil
	self.pieceSp2=nil
	self.tank1Label=nil
	self.tank2Label=nil
	self.selectedBox=nil
	self.lightSp=nil

	self.isToday=nil

	self.supplyBtn=nil
	self.supplyProgress=nil
	self.cellHeight=nil
	-- self.flicker1=nil
	-- self.flicker2=nil
	-- self.flicker3=nil

    return nc
end

--设置或修改每个Tab页签
function acMonsterComebackDialog:resetTab()

end

--设置对话框里的tableView
function acMonsterComebackDialog:initTableView()
	local function touch()
	end
	local capInSet = CCRect(20, 20, 10, 10)
    self.descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    self.descBg:setContentSize(CCSizeMake(400, 180))
    self.descBg:setAnchorPoint(ccp(0,1))
    self.descBg:setPosition(ccp(220-30,self.bgLayer:getContentSize().height-130))
    self.bgLayer:addChild(self.descBg,1)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local calX = 55
    local calWidth = 330
    if G_getCurChoseLanguage() =="ar" then
        calX = 35
        calWidth = 380
    end
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(calWidth,150),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(calX,15))
    self.descBg:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(50)

	local function tipTouch()
        local sd=smallDialog:new()
        local labelTab={" ",getlocal("activity_monsterComeback_tip8"),getlocal("activity_monsterComeback_tip7"),getlocal("activity_monsterComeback_tip6")," ",getlocal("activity_monsterComeback_tip5"),getlocal("activity_monsterComeback_tip4"),getlocal("activity_monsterComeback_tip3")," ",getlocal("activity_monsterComeback_tip2"),getlocal("activity_monsterComeback_tip1")," "}
        local colorTab={nil,G_ColorYellow,G_ColorWhite,G_ColorYellowPro,nil,G_ColorYellow,G_ColorWhite,G_ColorYellowPro,nil,G_ColorRed,G_ColorWhite,nil,}
       --  for i=(5*2+1),1,-1 do
       --  	if i%2==0 then
       --  		table.insert(labelTab,getlocal("activity_monsterComeback_tip"..(i/2)))
       --  		if (i/2)==2 or (i/2)==4 then
       --  			colorTab[i]=G_ColorYellowPro
    			-- else
    			-- 	colorTab[i]=G_ColorWhite
       --  		end
       --  	else
       --  		table.insert(labelTab," ")
       --  	end
       --  end
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(600,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,colorTab,nil,true)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    tipItem:setScale(1)
    local tipMenu = CCMenu:createWithItem(tipItem)
    --tipMenu:setPosition(ccp(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-110))
    tipMenu:setPosition(ccp(50,self.bgLayer:getContentSize().height-130))
    tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tipMenu,3)

	self:doUserHandler()
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acMonsterComebackDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
	    local tmpSize
	    if self.cellHeight==nil then
	    	local descLabel=GetTTFLabelWrap(getlocal("activity_monsterComeback_desc"),22,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    	self.cellHeight=descLabel:getContentSize().height+25
	    end
	    tmpSize=CCSizeMake(300,self.cellHeight)
	    return  tmpSize
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local descLabel=GetTTFLabelWrap(getlocal("activity_monsterComeback_desc"),22,CCSizeMake(330,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight==nil then
	    	self.cellHeight=descLabel:getContentSize().height+25
	    end	
	    descLabel:setAnchorPoint(ccp(0,1))
	    descLabel:setPosition(ccp(0,self.cellHeight))
	    cell:addChild(descLabel,1)
		descLabel:setColor(G_ColorGreen)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

--用户处理特殊需求,没有可以不写此方法
function acMonsterComebackDialog:doUserHandler()

	local vo=acMonsterComebackVoApi:getAcVo()

	local isFree=true			--是否是第一次免费
	if acMonsterComebackVoApi:isToday()==true then
		isFree=false
	end

	local cfg=acMonsterComebackVoApi:getAcCfg()
	local gemCost=cfg.serverreward.gemCost
	local makeupCost=cfg.serverreward.upgradePartConsume
	local oneGems=gemCost 				--一次抽奖需要金币
	local tenGems=gemCost*10 			--十次抽奖需要金币
	local pieceNeed=makeupCost 			--合成一次需要碎片数量
	local tank1Num=vo.rart1Num 			--黑鹰坦克碎片数量
	local tank2Num=vo.rart2Num 			--T90坦克碎片数量
	local pointCost=cfg.serverreward.pointCost	--抽奖一次需要的点数
	local point=vo.point or 0			--拥有的点数
	
	local reduceSpace=32
	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,390-reduceSpace))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+20-reduceSpace/2+5))
	if G_isIphone5()==true then
		self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+80-reduceSpace/2+5))
	end

	local function touch()
	end
	local capInSet = CCRect(20, 20, 10, 10)
	if self.characterSp==nil then
        if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            self.characterSp=CCSprite:create("public/guide.png")
        else
            self.characterSp=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
        end
		self.characterSp:setAnchorPoint(ccp(0,1))
		self.characterSp:setPosition(ccp(40-30,self.bgLayer:getContentSize().height-90))
		self.bgLayer:addChild(self.characterSp,2)
	end

	if self.selectedBox==nil then
		self.selectedBox=CCSprite:createWithSpriteFrameName("SeniorBox.png")
	    self.selectedBox:setAnchorPoint(ccp(0.5,0.5))
	    self.selectedBox:setPosition(ccp(self.bgLayer:getContentSize().width-self.selectedBox:getContentSize().width/2-10,self.bgLayer:getContentSize().height-300))
	    self.bgLayer:addChild(self.selectedBox,3)

	    self.lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
	    self.lightSp:setAnchorPoint(ccp(0.5,0.5))
	    self.lightSp:setPosition(getCenterPoint(self.selectedBox))
	    self.selectedBox:addChild(self.lightSp,1)
	    self.lightSp:setScale(0.6)
		self.lightSp:setVisible(false)
	end


	local rect = CCRect(0, 0, 50, 50)
	local capInSet = CCRect(15, 15, 1, 1)
	local function cellClick(hd,fn,idx)
	end

	if self.rewardBg==nil then
		self.rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),cellClick)
		-- self.rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-self.characterSp:getContentSize().height-self.panelLineBg:getContentSize().height-120))
		self.rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,188-reduceSpace))
		self.rewardBg:ignoreAnchorPointForPosition(false)
		self.rewardBg:setAnchorPoint(ccp(0.5,1))
		self.rewardBg:setIsSallow(false)
		self.rewardBg:setTouchPriority(-(self.layerNum-1)*20-2)
	    self.bgLayer:addChild(self.rewardBg,3)
	    self.rewardBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-self.characterSp:getContentSize().height-85))
	end

	if self.tankPic==nil then
		self.tankPic=LuaCCSprite:createWithFileName("public/Battleshow1.jpg",cellClick)
		-- self.tankPic=CCSprite:createWithFileName("public/Battleshow1.jpg")
		self.tankPic:setAnchorPoint(ccp(0.5,1))
		self.tankPic:setPosition(ccp(self.panelLineBg:getContentSize().width/2,self.panelLineBg:getContentSize().height-2))
		self.panelLineBg:addChild(self.tankPic,1)
		self.tankPic:setScaleX(1.2)
	end

	local spSize=50
	-- local spScale=1

	local function btnCallback(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
		if self.isMoving==true then
			do return end
		end		
        PlayEffect(audioCfg.mouseClick)

        local vo=acMonsterComebackVoApi:getAcVo()
        -- if activityVoApi:isStart(vo)==false then
        -- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage1986"),28)
        -- 	do return end
        -- end
		local isFree=true							--是否是第一次免费
		if acMonsterComebackVoApi:isToday()==true then
			isFree=false
		end
		
		local cfg=acMonsterComebackVoApi:getAcCfg()
		local gemCost=cfg.serverreward.gemCost
		local makeupCost=cfg.upgradePartConsume
		local oneGems=gemCost 				--一次抽奖需要金币
		local tenGems=gemCost*10 			--十次抽奖需要金币
		local pieceNeed=makeupCost 			--合成一次需要碎片数量
		local oldTank1Num=vo.rart1Num 		--黑鹰坦克碎片数量
		local oldTank2Num=vo.rart2Num 		--T90坦克碎片数量
		local pointCost=cfg.serverreward.pointCost	--抽奖一次需要的点数
		local point=vo.point or 0			--拥有的点数

		local action
		local part
		local num
		local usePoint=nil
		if tag==5 then
			if point<pointCost then
				do return end
			end
			action=1
			num=1
			usePoint=1
		elseif tag==1 or tag==2 then
			action=1
			if tag==1 then
				if isFree==false and playerVoApi:getGems()<oneGems then
					GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems)
					do return end
				end
				num=1
			elseif tag==2 then
				if playerVoApi:getGems()<tenGems then
					GemsNotEnoughDialog(nil,nil,tenGems-playerVoApi:getGems(),self.layerNum+1,tenGems)
					do return end
				end
				num=10
			end
		elseif tag==3 or tag==4 then
			action=2
			if tag==3 then
				part=1
			elseif tag==4 then
				part=2
			end
		end
		
		local function monsterComebackCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
            	self.isMoving=true
            	if sData.data==nil then
            		do return end
            	end
            	
            	if tag==1 then
            		if isFree==false then
	            		playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
	            	end
	            elseif tag==2 then
					playerVoApi:setValue("gems",playerVoApi:getGems()-tenGems)
				end

				--刷新活动数据
            	local tipStr=""
            	local getTank1=false
            	local getTank2=false

            	if sData.data.reward and (tag==1 or tag==2 or tag==5) then
					local award=FormatItem(sData.data.reward) or {}
					for k,v in pairs(award) do
						G_addPlayerAward(v.type,v.key,v.id,v.num)
					end
					tipStr=G_showRewardTip(award,false)
				end

				local useractive=sData.data.useractive
				if useractive and useractive.monsterComeback then
					local acticeData=useractive.monsterComeback
					if acticeData then
						if acticeData.t then--当前已抽到的碎片
							if acticeData.t.part1 then
								local part1Num=tonumber(acticeData.t.part1)
								if part1Num and part1Num>oldTank1Num then
									getTank1=true
									if tipStr~="" then
										tipStr=tipStr..","
									else
										tipStr=getlocal("daily_lotto_tip_10")
									end
									tipStr=tipStr..getlocal("activity_monsterComeback_tank1").." x"..(part1Num-oldTank1Num)
									acMonsterComebackVoApi:setTankPartNum(1,part1Num)
								end
							end
							if acticeData.t.part2 then
								local part2Num=tonumber(acticeData.t.part2)
								if part2Num and part2Num>oldTank2Num then
									getTank2=true
									if tipStr~="" then
										tipStr=tipStr..","
									else
										tipStr=getlocal("daily_lotto_tip_10")
									end
									tipStr=tipStr..getlocal("activity_monsterComeback_tank2").." x"..(part2Num-oldTank2Num)
								end
								acMonsterComebackVoApi:setTankPartNum(2,part2Num)
							end
							
						end
						if acticeData.d then
							-- acticeData.d.n--抽奖总次数
							-- acticeData.d.ts--上一次抽奖所在天的凌晨时间戳
							if acticeData.d.ts then
								acMonsterComebackVoApi:setLastTime(acticeData.d.ts)
							end
						end
						if acticeData.point then
							local newPoint=acticeData.point
							acMonsterComebackVoApi:setPoint(newPoint)

							local percentStr3=newPoint.."/"..pointCost
						    local percent3=(newPoint/pointCost)*100
							if self.supplyProgress then
								self.supplyProgress:setPercentage(percent3)
								tolua.cast(self.supplyProgress:getChildByTag(203),"CCLabelTTF"):setString(percentStr3)
							end
							if self.supplyBtn then
								if newPoint>=pointCost then
									self.supplyBtn:setEnabled(true)
								else
									self.supplyBtn:setEnabled(false)
								end
							end

						end
					end
				end

				if (tag==1 or tag==2 or tag==5) and tipStr~="" then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)
				end

				if (tag==3 or tag==4) then
					local makeTankTip=""
					local getTankNum=0
					if tag==3 then
						getTankNum=math.floor(oldTank1Num/20)*10
						if getTankNum>0 and tankCfg[10073] then
							local tankName=getlocal(tankCfg[10073].name)
							-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage6",{playerVoApi:getPlayerName(),tankName}))
							local nameData={key=tankCfg[10073].name,param={}}
							local message={key="chatSystemMessage6",param={playerVoApi:getPlayerName(),nameData}}
                			chatVoApi:sendSystemMessage(message)
							makeTankTip=makeTankTip..getlocal("active_lottery_reward_tank",{tankName," x"..getTankNum})
						end
					elseif tag==4 then
						getTankNum=math.floor(oldTank2Num/20)*10
						if getTankNum>0 and tankCfg[10063] then
							local tankName=getlocal(tankCfg[10063].name)
							-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage6",{playerVoApi:getPlayerName(),tankName}))
							local nameData={key=tankCfg[10063].name,param={}}
							local message={key="chatSystemMessage6",param={playerVoApi:getPlayerName(),nameData}}
                			chatVoApi:sendSystemMessage(message)
							makeTankTip=makeTankTip..getlocal("active_lottery_reward_tank",{tankName," x"..getTankNum})
						end
					end
					if makeTankTip~="" then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),makeTankTip,28)
					end
				end
				
				if (getTank1==true or getTank2==true) and (tag==1 or tag==2 or tag==5) then
					local leftPosX=self.rewardBg:getContentSize().width/2-150+10
					local rightPosX=self.rewardBg:getContentSize().width/2+150+10
					if getTank1==true and (tag==1 or tag==2 or tag==5) then
						self.lightSp:setVisible(true)
						local pointY=self.bgLayer:getContentSize().height-self.rewardBg:getContentSize().height-self.characterSp:getContentSize().height-30

					    local pieceSp=CCSprite:createWithSpriteFrameName("BattleParts1.png")
					    pieceSp:setAnchorPoint(ccp(0.5,0.5))
					    -- if tag==1 then
					    -- 	pieceSp:setPosition(ccp(leftPosX,pointY))
					    -- elseif tag==2 then
					    -- 	pieceSp:setPosition(ccp(rightPosX,pointY))
					    -- end
					    pieceSp:setPosition(ccp(self.bgLayer:getContentSize().width-self.selectedBox:getContentSize().width/2-10,self.bgLayer:getContentSize().height-300))
					    self.bgLayer:addChild(pieceSp,4)

					    -- spScale=spSize/pieceSp:getContentSize().width
					    -- pieceSp:setScale(spScale)

					    local function playEndCallback1()
							pieceSp:removeFromParentAndCleanup(true)
							pieceSp=nil

							self.isMoving=false

							self:doUserHandler()
						end
						local callFunc=CCCallFuncN:create(playEndCallback1)

						local function hideLight()
							if self.lightSp then
								self.lightSp:setVisible(false)
							end
						end
						local callFunc1=CCCallFuncN:create(hideLight)

						local delay=CCDelayTime:create(0.5)
						local mvTo0=CCMoveTo:create(0.5,ccp(leftPosX+15,125))
						if G_isIphone5()==true then
							mvTo0=CCMoveTo:create(0.5,ccp(leftPosX+15,125+60))
						end
					    local scaleTo=CCScaleTo:create(0.2,2)
						local scaleTo1=CCScaleTo:create(0.3,0.2)

					    local acArr=CCArray:create()
					    acArr:addObject(delay)
					    acArr:addObject(callFunc1)
						acArr:addObject(mvTo0)

						acArr:addObject(scaleTo)
						acArr:addObject(scaleTo1)
					    acArr:addObject(callFunc)
					    local seq=CCSequence:create(acArr)
					    pieceSp:runAction(seq)
					end

					if getTank2==true and (tag==1 or tag==2 or tag==5) then 
						self.lightSp:setVisible(true)           		
						local pointY=self.bgLayer:getContentSize().height-self.rewardBg:getContentSize().height-self.characterSp:getContentSize().height-30

					    local pieceSp=CCSprite:createWithSpriteFrameName("BattleParts2.png")
					    pieceSp:setAnchorPoint(ccp(0.5,0.5))
					    -- if tag==1 then
					    -- 	pieceSp:setPosition(ccp(leftPosX,pointY))
					    -- elseif tag==2 then
					    -- 	pieceSp:setPosition(ccp(rightPosX,pointY))
					    -- end
					    pieceSp:setPosition(ccp(self.bgLayer:getContentSize().width-self.selectedBox:getContentSize().width/2-10,self.bgLayer:getContentSize().height-300))
					    self.bgLayer:addChild(pieceSp,4)

					    -- spScale=spSize/pieceSp:getContentSize().width
					    -- pieceSp:setScale(spScale)

					    local function playEndCallback2()
							pieceSp:removeFromParentAndCleanup(true)
							pieceSp=nil

							self.isMoving=false
							self:doUserHandler()
						end
						local callFunc=CCCallFuncN:create(playEndCallback2)

						local function hideLight()
							if self.lightSp then
								self.lightSp:setVisible(false)
							end
						end
						local callFunc1=CCCallFuncN:create(hideLight)

						local delay=CCDelayTime:create(0.5)
						local mvTo0=CCMoveTo:create(0.5,ccp(rightPosX+15,125))
						if G_isIphone5()==true then
							mvTo0=CCMoveTo:create(0.5,ccp(rightPosX+15,125+60))
						end
					    local scaleTo=CCScaleTo:create(0.2,2)
						local scaleTo1=CCScaleTo:create(0.3,0.2)

					    local acArr=CCArray:create()
					    acArr:addObject(delay)
					    acArr:addObject(callFunc1)
						acArr:addObject(mvTo0)

						acArr:addObject(scaleTo)
						acArr:addObject(scaleTo1)
					    acArr:addObject(callFunc)
					    local seq=CCSequence:create(acArr)
					    pieceSp:runAction(seq)
	            	end
	            else
	            	self.isMoving=false
					self:doUserHandler()
	            end
            end
		end
        socketHelper:activeMonsterComeback(action,part,num,monsterComebackCallback,usePoint)
    end

    local leftPosX=self.rewardBg:getContentSize().width/2-150
    local rightPosX=self.rewardBg:getContentSize().width/2+150

	local lbY=117
	if self.goldSp1==nil then
	    self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
	    self.goldSp1:setAnchorPoint(ccp(1,0.5))
	    self.goldSp1:setPosition(ccp(leftPosX-10,lbY))
	    self.rewardBg:addChild(self.goldSp1)
	    self.goldSp1:setScale(1.5)
	end
	if self.gemsLabel1==nil then
		self.gemsLabel1=GetTTFLabel(oneGems,25)
	    self.gemsLabel1:setAnchorPoint(ccp(0,0.5))
	    self.gemsLabel1:setPosition(ccp(leftPosX,lbY))
	    self.rewardBg:addChild(self.gemsLabel1,1)
	end
	if isFree==true then
		self.goldSp1:setVisible(false)
		self.gemsLabel1:setString(getlocal("daily_lotto_tip_2"))
		self.gemsLabel1:setPosition(leftPosX-25,lbY)
	else
		self.goldSp1:setVisible(true)
		self.gemsLabel1:setString(oneGems)
		self.gemsLabel1:setPosition(leftPosX,lbY)
	end
	
	if self.goldSp2==nil then
	    self.goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
	    self.goldSp2:setAnchorPoint(ccp(1,0.5))
	    self.goldSp2:setPosition(ccp(rightPosX-10,lbY))
	    self.rewardBg:addChild(self.goldSp2)
	    self.goldSp2:setScale(1.5)
	end
	if self.gemsLabel2==nil then
		self.gemsLabel2=GetTTFLabel(tenGems,25)
	    self.gemsLabel2:setAnchorPoint(ccp(0,0.5))
	    self.gemsLabel2:setPosition(ccp(rightPosX,lbY))
	    self.rewardBg:addChild(self.gemsLabel2,1)
	end

	local btnY=50
	if self.lotteryOneBtn==nil then
		self.lotteryOneBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,1,getlocal("active_lottery_btn1"),25)
	    self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
	    local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
	    lotteryMenu:setPosition(ccp(leftPosX,btnY))
	    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.rewardBg:addChild(lotteryMenu,2)
		--self.lotteryOneBtn:setVisible(false)
	end
	if self.lotteryTenBtn==nil then
		self.lotteryTenBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,2,getlocal("active_lottery_btn2"),25)
	    self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
	    local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
	    lotteryMenu1:setPosition(ccp(rightPosX,btnY))
	    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.rewardBg:addChild(lotteryMenu1,2)
		--self.lotteryTenBtn:setVisible(false)
	end

	if self.make1Btn==nil then
		self.make1Btn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,3,getlocal("active_lottery_makeup"),25)
	    self.make1Btn:setAnchorPoint(ccp(0.5,0.5))
	    local lotteryMenu2=CCMenu:createWithItem(self.make1Btn)
	    lotteryMenu2:setPosition(ccp(self.panelLineBg:getContentSize().width/2-150,50))
	    lotteryMenu2:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.panelLineBg:addChild(lotteryMenu2,2)
		--self.make1Btn:setVisible(false)
	end
	if self.make2Btn==nil then
		self.make2Btn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,4,getlocal("active_lottery_makeup"),25)
	    self.make2Btn:setAnchorPoint(ccp(0.5,0.5))
	    local lotteryMenu3=CCMenu:createWithItem(self.make2Btn)
	    lotteryMenu3:setPosition(ccp(self.panelLineBg:getContentSize().width/2+150,50))
	    lotteryMenu3:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.panelLineBg:addChild(lotteryMenu3,2)
		--self.make2Btn:setVisible(false)
	end
	if tank1Num>=pieceNeed then
		self.make1Btn:setEnabled(true)
		-- if self.flicker1==nil then
		-- 	self.flicker1=G_RotateFlicker(self.make1Btn,3.8,0.98)
		-- end
	else
		self.make1Btn:setEnabled(false)
		-- if self.flicker1~=nil then
		-- 	G_removeFlicker(self.make1Btn)
		-- end
		-- self.flicker1=nil
	end
	if tank2Num>=pieceNeed then
		self.make2Btn:setEnabled(true)
		-- if self.flicker2==nil then
		-- 	self.flicker2=G_RotateFlicker(self.make2Btn,3.8,0.98)
		-- end
	else
		self.make2Btn:setEnabled(false)
		-- if self.flicker2~=nil then
		-- 	G_removeFlicker(self.make2Btn)
		-- end
		-- self.flicker2=nil
	end


    local percentStr1=tank1Num.."/"..pieceNeed
    local percent1=(tank1Num/pieceNeed)*100
    if percent1>100 then
    	percent1=100
    end
    local percentStr2=tank2Num.."/"..pieceNeed
    local percent2=(tank2Num/pieceNeed)*100
    if percent2>100 then
    	percent2=100
    end

    local proScaleX=0.6
    if self.tank1progress==nil then
	    AddProgramTimer(self.panelLineBg,ccp(leftPosX+15,self.make1Btn:getContentSize().height+40),101,201,percentStr1,"skillBg.png","skillBar.png",301,proScaleX)
	    self.tank1progress=self.panelLineBg:getChildByTag(101)
	    self.tank1progress=tolua.cast(self.tank1progress,"CCProgressTimer")
	end
	self.tank1progress:setPercentage(percent1)
	tolua.cast(self.tank1progress:getChildByTag(201),"CCLabelTTF"):setString(percentStr1)

	if self.tank2progress==nil then
		AddProgramTimer(self.panelLineBg,ccp(rightPosX+15,self.make2Btn:getContentSize().height+40),102,202,percentStr2,"skillBg.png","skillBar.png",302,proScaleX)
		self.tank2progress=self.panelLineBg:getChildByTag(102)
		self.tank2progress=tolua.cast(self.tank2progress,"CCProgressTimer")
	end
	self.tank2progress:setPercentage(percent2)
	tolua.cast(self.tank2progress:getChildByTag(202),"CCLabelTTF"):setString(percentStr2)

	-- local spScale=1
	if self.pieceSp1==nil then
	    self.pieceSp1=CCSprite:createWithSpriteFrameName("BattleParts1.png")
	    self.pieceSp1:setAnchorPoint(ccp(0.5,0.5))
	    self.pieceSp1:setPosition(ccp(leftPosX-115,self.make1Btn:getContentSize().height+40))
	    self.panelLineBg:addChild(self.pieceSp1)

	    -- spScale=spSize/self.pieceSp1:getContentSize().width
	    -- self.pieceSp1:setScale(spScale)
	end
	if self.pieceSp2==nil then
	    self.pieceSp2=CCSprite:createWithSpriteFrameName("BattleParts2.png")
	    self.pieceSp2:setAnchorPoint(ccp(0.5,0.5))
	    self.pieceSp2:setPosition(ccp(rightPosX-115,self.make2Btn:getContentSize().height+40))
	    self.panelLineBg:addChild(self.pieceSp2)

	    -- spScale=spSize/self.pieceSp2:getContentSize().width
	    -- self.pieceSp2:setScale(spScale)
	end

	if self.tank1Label==nil then
		self.tank1Label=GetTTFLabelWrap(getlocal("activity_monsterComeback_tank1"),25,CCSizeMake(self.panelLineBg:getContentSize().width/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    self.tank1Label:setAnchorPoint(ccp(0.5,0))
	    self.tank1Label:setPosition(ccp(leftPosX,self.make1Btn:getContentSize().height+70))
	    self.panelLineBg:addChild(self.tank1Label,1)
	end
	if self.tank2Label==nil then
		self.tank2Label=GetTTFLabelWrap(getlocal("activity_monsterComeback_tank2"),25,CCSizeMake(self.panelLineBg:getContentSize().width/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    self.tank2Label:setAnchorPoint(ccp(0.5,0))
	    self.tank2Label:setPosition(ccp(rightPosX,self.make2Btn:getContentSize().height+70))
	    self.panelLineBg:addChild(self.tank2Label,1)
	end


	--点数抽奖
	local rewardBgX,rewardBgY=self.rewardBg:getPosition()
	local topY=rewardBgY-self.rewardBg:getContentSize().height
	local panelLineBgX,panelLineBgY=self.panelLineBg:getPosition()
	local bottomY=panelLineBgY+self.panelLineBg:getContentSize().height/2
	local sHeight=topY-(topY-bottomY)/2

	local percentStr3=point.."/"..pointCost
    local percent3=(point/pointCost)*100
	if self.supplyProgress==nil then
	    AddProgramTimer(self.bgLayer,ccp(205,sHeight),103,203,percentStr3,"skillBg.png","skillBar.png",303,0.95)
	    self.supplyProgress=self.bgLayer:getChildByTag(103)
	    self.supplyProgress=tolua.cast(self.supplyProgress,"CCProgressTimer")
	end
	self.supplyProgress:setPercentage(percent3)
	tolua.cast(self.supplyProgress:getChildByTag(203),"CCLabelTTF"):setString(percentStr3)

    local btnScale=0.8
	if self.supplyBtn==nil then
		self.supplyBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,5,getlocal("activity_monsterComeback_supplyBtn"),24,105)
	    self.supplyBtn:setAnchorPoint(ccp(0.5,0.5))
	    self.supplyBtn:setScale(btnScale)
	    local lotteryMenu4=CCMenu:createWithItem(self.supplyBtn)
	    lotteryMenu4:setPosition(ccp(self.bgLayer:getContentSize().width-self.supplyBtn:getContentSize().width/2-10,sHeight))
	    lotteryMenu4:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.bgLayer:addChild(lotteryMenu4,2)

	    tolua.cast(self.supplyBtn:getChildByTag(105),"CCLabelTTF"):setScale(1/btnScale)
	end
	if point>=pointCost then
		self.supplyBtn:setEnabled(true)
		-- if self.flicker3==nil then
		-- 	self.flicker3=G_RotateFlicker(self.supplyBtn,3.8,0.98)
		-- end
	else
		self.supplyBtn:setEnabled(false)
		-- if self.flicker3~=nil then
		-- 	G_removeFlicker(self.supplyBtn)
		-- end
		-- self.flicker3=nil
	end

end


--点击tab页签 idx:索引
function acMonsterComebackDialog:tabClick(idx)

end

function acMonsterComebackDialog:tick()
	local vo=acMonsterComebackVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
	if self and self.bgLayer then 
		local today=acMonsterComebackVoApi:isToday()
		if self.isToday~=today then
			self:doUserHandler()
			self.isToday=today
		end
	end
end

function acMonsterComebackDialog:update()
	-- body
end

function acMonsterComebackDialog:dispose()
	-- CCTextureCache:sharedTextureCache():removeTextureForKey("public/Battleshow1.jpg")
	-- if self.make1Btn then
	-- 	G_removeFlicker(self.make1Btn)
	-- end
	-- if self.make2Btn then
	-- 	G_removeFlicker(self.make2Btn)
	-- end
	-- if self.supplyBtn then
	-- 	G_removeFlicker(self.supplyBtn)
	-- end
	self.characterSp=nil
	self.descBg=nil
	self.rewardBg=nil
	self.tankPic=nil
	self.isMoving=nil
	self.goldSp1=nil
	self.goldSp2=nil
	self.gemsLabel1=nil
	self.gemsLabel2=nil
	self.lotteryOneBtn=nil
	self.lotteryTenBtn=nil
	self.make1Btn=nil
	self.make2Btn=nil
	self.tank1progress=nil
	self.tank2progress=nil
	self.pieceSp1=nil
	self.pieceSp2=nil
	self.tank1Label=nil
	self.tank2Label=nil
	self.selectedBox=nil
	self.lightSp=nil
	self.isToday=nil
	self.supplyBtn=nil
	self.supplyProgress=nil
	self.cellHeight=nil
	-- self.flicker1=nil
	-- self.flicker2=nil
	-- self.flicker3=nil
    self=nil
end




