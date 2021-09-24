
lotteryDialog=commonDialog:new()

function lotteryDialog:new()
    local nc=commonDialog:new()
    setmetatable(nc,self)
    self.__index=self
	
	self.characterSp=nil
	self.descBg=nil
	self.descLabel=nil
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

    return nc
end

--设置或修改每个Tab页签
function lotteryDialog:resetTab()

end

--设置对话框里的tableView
function lotteryDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-125),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    --self.tv:setPosition(ccp(10,40))
    --self.bgLayer:addChild(self.tv,1)
    --self.tv:setMaxDisToBottomOrTop(140)
	--self.panelLineBg:setVisible(false)

	local function tipTouch()
        local sd=smallDialog:new()
        local labelTab={" ",getlocal("active_lottery_tip8"),getlocal("active_lottery_tip7"),getlocal("active_lottery_tip6")," ",getlocal("active_lottery_tip5"),getlocal("active_lottery_tip4"),getlocal("active_lottery_tip3")," ",getlocal("active_lottery_tip2"),getlocal("active_lottery_tip1")," "}
        local colorTab={nil,G_ColorYellow,G_ColorWhite,G_ColorYellowPro,nil,G_ColorYellow,G_ColorWhite,G_ColorYellowPro,nil,G_ColorRed,G_ColorWhite,nil,}
       --  for i=(5*2+1),1,-1 do
       --  	if i%2==0 then
       --  		table.insert(labelTab,getlocal("active_lottery_tip"..(i/2)))
       --  		if (i/2)==2 or (i/2)==4 then
       --  			colorTab[i]=G_ColorYellowPro
    			-- else
    			-- 	colorTab[i]=G_ColorWhite
       --  		end
       --  	else
       --  		table.insert(labelTab," ")
       --  	end
       --  end
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(580,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,colorTab,nil,true)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    tipItem:setScale(1)
    local tipMenu = CCMenu:createWithItem(tipItem)
    --tipMenu:setPosition(ccp(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-110))
    tipMenu:setPosition(ccp(50,self.bgLayer:getContentSize().height-130))
    tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tipMenu,1)

	self:doUserHandler()
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function lotteryDialog:eventHandler(handler,fn,idx,cel)
	do return end	
end

--用户处理特殊需求,没有可以不写此方法
function lotteryDialog:doUserHandler()

	local lotteryVo=acMoscowGamblingVoApi:getAcVo()
	--数据
	local isFree=true			--是否是第一次免费
	if acMoscowGamblingVoApi:isToday()==true then
		isFree=false
	end
	local oneGems=lotteryVo.gemCost 			--一次抽奖需要金币
	local tenGems=lotteryVo.gemCost*10 			--十次抽奖需要金币
	local pieceNeed=lotteryVo.makeupCost 		--合成一次需要碎片数量
	local tank1Num=lotteryVo.rart1Num 			--黑鹰坦克碎片数量
	local tank2Num=lotteryVo.rart2Num 			--T90坦克碎片数量

	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,390))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+20))
	if G_isIphone5()==true then
		self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+80))
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
	if self.descBg==nil then
	    self.descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
	    self.descBg:setContentSize(CCSizeMake(400, 180))
	    self.descBg:setAnchorPoint(ccp(0,1))
	    self.descBg:setPosition(ccp(220-30,self.bgLayer:getContentSize().height-130))
	    self.bgLayer:addChild(self.descBg,1)
	end
	if self.descLabel==nil then
		self.descLabel=GetTTFLabelWrap(getlocal("active_lottery_desc"),22,CCSizeMake(self.descBg:getContentSize().width-100,150),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    self.descLabel:setAnchorPoint(ccp(0,0.5))
	    self.descLabel:setPosition(ccp(75,self.descBg:getContentSize().height/2))
	    self.descBg:addChild(self.descLabel,1)
		self.descLabel:setColor(G_ColorGreen)
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
		self.rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,188))
		self.rewardBg:ignoreAnchorPointForPosition(false)
		self.rewardBg:setAnchorPoint(ccp(0.5,1))
		self.rewardBg:setIsSallow(false)
		self.rewardBg:setTouchPriority(-(self.layerNum-1)*20-2)
	    self.bgLayer:addChild(self.rewardBg)
	    self.rewardBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-self.characterSp:getContentSize().height-90))
	end

	if self.tankPic==nil then
		self.tankPic=LuaCCSprite:createWithFileName("public/Battleshow.jpg",cellClick)
		-- self.tankPic=CCSprite:createWithFileName("public/Battleshow.jpg")
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

        local lotteryVo=acMoscowGamblingVoApi:getAcVo()
        -- if activityVoApi:isStart(lotteryVo)==false then
        -- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage1986"),28)
        -- 	do return end
        -- end
		local isFree=true							--是否是第一次免费
		if acMoscowGamblingVoApi:isToday()==true then
			isFree=false
		end
		local oneGems=lotteryVo.gemCost 			--一次抽奖需要金币
		local tenGems=lotteryVo.gemCost*10 			--十次抽奖需要金币
		local pieceNeed=lotteryVo.makeupCost 		--合成一次需要碎片数量
		local oldTank1Num=lotteryVo.rart1Num 		--黑鹰坦克碎片数量
		local oldTank2Num=lotteryVo.rart2Num 		--T90坦克碎片数量

		local action
		local part
		local num
		if tag==1 or tag==2 then
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
		
		local function moscowgamblingCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
            	if sData.data==nil then
            		do return end
            	end
            	self.isMoving=true

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

            	if sData.data.reward and (tag==1 or tag==2) then
					local award=FormatItem(sData.data.reward) or {}
					for k,v in pairs(award) do
						G_addPlayerAward(v.type,v.key,v.id,v.num)
					end
					tipStr=G_showRewardTip(award,false)
				end

				local useractive=sData.data.useractive
				if useractive and useractive.moscowGambling then
					local acticeData=useractive.moscowGambling
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
									tipStr=tipStr..getlocal("active_lottery_tank1").." x"..(part1Num-oldTank1Num)
									acMoscowGamblingVoApi:setTankPartNum(1,part1Num)
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
									tipStr=tipStr..getlocal("active_lottery_tank2").." x"..(part2Num-oldTank2Num)
								end
								acMoscowGamblingVoApi:setTankPartNum(2,part2Num)
							end
							
						end
						if acticeData.d then
							-- acticeData.d.n--抽奖总次数
							-- acticeData.d.ts--上一次抽奖所在天的凌晨时间戳
							if acticeData.d.ts then
								acMoscowGamblingVoApi:setLastTime(acticeData.d.ts)
							end
						end
					end
				end

				if (tag==1 or tag==2) and tipStr~="" then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)
				end

				if (tag==3 or tag==4) then
					local makeTankTip=""
					local getTankNum=0
					if tag==3 then
						getTankNum=math.floor(oldTank1Num/20)*10
						if getTankNum>0 and tankCfg[10053] then
							local tankName=getlocal(tankCfg[10053].name)
							-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage6",{playerVoApi:getPlayerName(),tankName}))
							local nameData={key=tankCfg[10053].name,param={}}
							local message={key="chatSystemMessage6",param={playerVoApi:getPlayerName(),nameData}}
                			chatVoApi:sendSystemMessage(message)
							makeTankTip=makeTankTip..getlocal("active_lottery_reward_tank",{tankName," x"..getTankNum})
						end
					elseif tag==4 then
						getTankNum=math.floor(oldTank2Num/20)*10
						if getTankNum>0 and tankCfg[10043] then
							local tankName=getlocal(tankCfg[10043].name)
							-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage6",{playerVoApi:getPlayerName(),tankName}))
							local nameData={key=tankCfg[10043].name,param={}}
							local message={key="chatSystemMessage6",param={playerVoApi:getPlayerName(),nameData}}
                			chatVoApi:sendSystemMessage(message)
							makeTankTip=makeTankTip..getlocal("active_lottery_reward_tank",{tankName," x"..getTankNum})
						end
					end
					if makeTankTip~="" then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),makeTankTip,28)
					end
				end
				
				if (getTank1==true or getTank2==true) and (tag==1 or tag==2) then
					local leftPosX=self.rewardBg:getContentSize().width/2-150+10
					local rightPosX=self.rewardBg:getContentSize().width/2+150+10
					if getTank1==true and (tag==1 or tag==2) then
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
						local mvTo0=CCMoveTo:create(0.5,ccp(leftPosX+15,135))
						if G_isIphone5()==true then
							mvTo0=CCMoveTo:create(0.5,ccp(leftPosX+15,135+60))
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

					if getTank2==true and (tag==1 or tag==2) then 
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
						local mvTo0=CCMoveTo:create(0.5,ccp(rightPosX+15,135))
						if G_isIphone5()==true then
							mvTo0=CCMoveTo:create(0.5,ccp(rightPosX+15,135+60))
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
        socketHelper:activeMoscowgambling(action,part,num,moscowgamblingCallback)
    end

    local leftPosX=self.rewardBg:getContentSize().width/2-150
    local rightPosX=self.rewardBg:getContentSize().width/2+150

	if self.goldSp1==nil then
	    self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
	    self.goldSp1:setAnchorPoint(ccp(1,0.5))
	    self.goldSp1:setPosition(ccp(leftPosX-10,130))
	    self.rewardBg:addChild(self.goldSp1)
	    self.goldSp1:setScale(1.5)
	end
	if self.gemsLabel1==nil then
		self.gemsLabel1=GetTTFLabel(oneGems,25)
	    self.gemsLabel1:setAnchorPoint(ccp(0,0.5))
	    self.gemsLabel1:setPosition(ccp(leftPosX,130))
	    self.rewardBg:addChild(self.gemsLabel1,1)
	end
	if isFree==true then
		self.goldSp1:setVisible(false)
		self.gemsLabel1:setString(getlocal("daily_lotto_tip_2"))
		self.gemsLabel1:setPosition(leftPosX-25,130)
	else
		self.goldSp1:setVisible(true)
		self.gemsLabel1:setString(oneGems)
		self.gemsLabel1:setPosition(leftPosX,130)
	end
	
	if self.goldSp2==nil then
	    self.goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
	    self.goldSp2:setAnchorPoint(ccp(1,0.5))
	    self.goldSp2:setPosition(ccp(rightPosX-10,130))
	    self.rewardBg:addChild(self.goldSp2)
	    self.goldSp2:setScale(1.5)
	end
	if self.gemsLabel2==nil then
		self.gemsLabel2=GetTTFLabel(tenGems,25)
	    self.gemsLabel2:setAnchorPoint(ccp(0,0.5))
	    self.gemsLabel2:setPosition(ccp(rightPosX,130))
	    self.rewardBg:addChild(self.gemsLabel2,1)
	end

	if self.lotteryOneBtn==nil then
		self.lotteryOneBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,1,getlocal("active_lottery_btn1"),25)
	    self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
	    local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
	    lotteryMenu:setPosition(ccp(leftPosX,60))
	    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.rewardBg:addChild(lotteryMenu,2)
		--self.lotteryOneBtn:setVisible(false)
	end
	if self.lotteryTenBtn==nil then
		self.lotteryTenBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,2,getlocal("active_lottery_btn2"),25)
	    self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
	    local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
	    lotteryMenu1:setPosition(ccp(rightPosX,60))
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
	else
		self.make1Btn:setEnabled(false)
	end
	if tank2Num>=pieceNeed then
		self.make2Btn:setEnabled(true)
	else
		self.make2Btn:setEnabled(false)
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
		self.tank1Label=GetTTFLabel(getlocal("active_lottery_tank1"),25)
	    self.tank1Label:setAnchorPoint(ccp(0.5,0))
	    self.tank1Label:setPosition(ccp(leftPosX,self.make1Btn:getContentSize().height+70))
	    self.panelLineBg:addChild(self.tank1Label,1)
	end
	if self.tank2Label==nil then
		self.tank2Label=GetTTFLabel(getlocal("active_lottery_tank2"),25)
	    self.tank2Label:setAnchorPoint(ccp(0.5,0))
	    self.tank2Label:setPosition(ccp(rightPosX,self.make2Btn:getContentSize().height+70))
	    self.panelLineBg:addChild(self.tank2Label,1)
	end

end


--点击tab页签 idx:索引
function lotteryDialog:tabClick(idx)

end

function lotteryDialog:tick()
	if self and self.bgLayer then 
		local today=acMoscowGamblingVoApi:isToday()
		if self.isToday~=today then
			self:doUserHandler()
			self.isToday=today
		end
	end
end

function lotteryDialog:update()
	-- body
end

function lotteryDialog:dispose()
	-- CCTextureCache:sharedTextureCache():removeTextureForKeyForce("public/Battleshow.jpg")
	self.characterSp=nil
	self.descBg=nil
	self.descLabel=nil
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
    self=nil
end




