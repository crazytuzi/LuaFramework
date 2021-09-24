acStormFortressGetRewardDialog=smallDialog:new()

function acStormFortressGetRewardDialog:new(layerNum,parent,tag)--tag:
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum=layerNum
	nc.wholeBgSp=nil
	self.awardShowTb={}
	nc.dialogWidth=nil
	nc.dialogHeight=nil
	nc.IconGoldInOne=nil
	nc.isTouch=nil
	nc.bgLayer=nil
	nc.bgSize=nil
	nc.OnceNeedGold=nil
	nc.dialogLayer=nil
	nc.lotsAward={}
	nc.bigReward ={}
	nc.timerSpriteLv=nil
	nc.timerSprite=nil
	nc.timer1=nil
	nc.showBar1=nil
	nc.showBar2=nil
	self.upLabelStr =nil
	nc.parent =parent
	self.particleS={}
	nc.whiTag=tag
	nc.llastDeHp =0
	if tag ==4 then
		nc.whiTag =2
	end
	

	nc.upTodayTime=nil ---用于更新时间戳，在开板子的时候保存后台返回的新时间戳，在关闭板子的时候 将时间戳从新设置
	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acStormFortressGetRewardDialog:init(callbackSure)
	  local strSize2 = 22
	  local strSize3 = 22
	  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
	    	strSize2 =29
	    	strSize3=25
	  end

	local isDied = acStormFortressVoApi:getIsDied()
	local iconShowTime = 0.6
	local ALLhp = acStormFortressVoApi:getStormFortressHP( )
    local lastDeHp = acStormFortressVoApi:getStormFortressLastHp()--获取上一次损失的血量
	local deHp = acStormFortressVoApi:getFortressHp() --当前损失的血量
	local lastAllHp = ALLhp-lastDeHp --上一次的总血量
	local nowAllHp = ALLhp-deHp --当前的总血量
	local showDeHp = deHp-lastDeHp
	local subHeight2 = 120
	local subHeight3 = 200
	local isShow = true
	if lastDeHp >= ALLhp then
		subHeight2 =270
		subHeight3 =100
		isShow =false		
	end
	self.dialogWidth=G_VisibleSizeWidth-60
	self.dialogHeight=G_VisibleSizeHeight-subHeight2
	self.isTouch=nil
	self.bigReward ={} --大奖的奖励库
	local isDied =acStormFortressVoApi:getIsDied()
	self.lotsAward =acStormFortressVoApi:getNowRewardTb()--{}------取配置奖励库
	if SizeOfTable(self.lotsAward) <5 then
		if G_isIphone5() ==true then
			self.dialogHeight =self.dialogHeight - 260
		else
			self.dialogHeight =self.dialogHeight - 240
		end

		if isDied ==1 and acStormFortressVoApi:getWillDied() ==true then  --
			if G_isIphone5() ==true then
				self.dialogHeight =self.dialogHeight - 180
			end
			subHeight3 =60
		elseif isDied ==0 then
			if G_isIphone5() ==true then
				self.dialogHeight =self.dialogHeight -200
			end
		end
		
	else
		if G_isIphone5() ==true then
			self.dialogHeight =self.dialogHeight - 180
		else
			self.dialogHeight =self.dialogHeight +10
		end
		if isDied ==1 and acStormFortressVoApi:getWillDied() ==true then  --
			subHeight3 =60
			self.dialogHeight =self.dialogHeight -50
		end
	end
	local addW = 110
	local addH = 130
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local scale=1.1

	local titleBg1=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg1:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight-25))
    titleBg1:setScale(scale)
    titleBg1:setAnchorPoint(ccp(0.5,0.5))
    dialogBg:addChild(titleBg1,1)

   
	if deHp > ALLhp then
		if lastDeHp >= ALLhp then
			showDeHp =0
		else
			showDeHp =deHp-lastDeHp
		end
	end
    local upTitle = "activity_stormFortress_attSucc"
    local upLabel ="activity_stormFortress_stormNormSucessLab"
    if  isDied ==1 then
    	upTitle ="activity_stormFortress_title"
    end
	local upTitleStr = GetTTFLabelWrap(getlocal(upTitle),strSize2,CCSizeMake(self.dialogWidth*0.5,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleBg1:addChild(upTitleStr)
	upTitleStr:setAnchorPoint(ccp(0.5,0.5))
	upTitleStr:setColor(G_ColorYellowPro)
	upTitleStr:setPosition(titleBg1:getContentSize().width*0.5,titleBg1:getContentSize().height*0.5+5)

	self.upLabelStr = GetTTFLabelWrap(getlocal(upLabel,{showDeHp}),strSize3,CCSizeMake(self.dialogWidth-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	dialogBg:addChild(self.upLabelStr)
	self.upLabelStr:setAnchorPoint(ccp(0,1))
	self.upLabelStr:setPosition(ccp(30,self.dialogHeight-70))


    if isDied ==1 and acStormFortressVoApi:getWillDied() ==true  then
      self.upLabelStr:setVisible(false)
      lastDeHp = ALLhp
    end
    local percentStr=(ALLhp-lastDeHp).."/"..ALLhp
	local per = tonumber((ALLhp-lastDeHp))/tonumber(ALLhp) * 100
	AddProgramTimer(dialogBg,ccp(self.dialogWidth*0.5,self.dialogHeight-150),999,12,nil,"platWarProgressBg.png","platWarProgress2.png",13,1.3,1)
    self.timerSpriteLv = dialogBg:getChildByTag(999)------------------------击破后第二个显示的掉血图片
    self.timerSpriteLvBg = dialogBg:getChildByTag(13)
    self.timerSpriteLv=tolua.cast(self.timerSpriteLv,"CCProgressTimer")
    self.timerSpriteLv:setMidpoint(ccp(0,1))
    self.timerSpriteLv:setPercentage(per)

	local changeRage = ccp(1,0)
	local psSprite1 = CCSprite:createWithSpriteFrameName("platWarProgress1.png");
	self.timerSprite = CCProgressTimer:create(psSprite1);------------------------击破后第  1  个显示的掉血图片
    self.timerSprite:setMidpoint(ccp(0,1));
    self.timerSprite:setBarChangeRate(changeRage);
    self.timerSprite:setType(kCCProgressTimerTypeBar);
    self.timerSprite:setTag(998);
    self.timerSprite:setScaleX(1.3)
    -- timerSprite:setScaleY(1)
    self.timerSprite:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight-150));
    self.timerSprite:setPercentage(per); 

    self.timer1 = GetTTFLabel(percentStr,24);
    self.timer1:setPosition(ccp(self.timerSprite:getPositionX(),self.timerSprite:getPositionY()-30))
    dialogBg:addChild(self.timer1,5);
    self.timer1:setTag(12);

    if isShow ==false then
    	self.timerSprite:setVisible(false)
    	self.timerSpriteLv:setVisible(false)
    	self.timer1:setVisible(false)
    	self.timerSpriteLvBg:setVisible(false)
    end

    dialogBg:addChild(self.timerSprite,2)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setScale(0.95)
    lineSp:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight-subHeight3))
    dialogBg:addChild(lineSp)
    if isDied ==1 and acStormFortressVoApi:getWillDied() ==true  then
    	lineSp:setVisible(false)
    end

    --thisReward
    local thisLb = GetTTFLabelWrap(getlocal("thisReward"),strSize2,CCSizeMake(self.dialogWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	dialogBg:addChild(thisLb)
	thisLb:setAnchorPoint(ccp(0.5,0.5))
	thisLb:setColor(G_ColorYellowPro)
	thisLb:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight-subHeight3-20))

	local function close()
		-- print("close()---------")
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end

	self:initTableView()
	 --确定
    local function sureHandler(tag,object)
    	-- print("tag--------",tag)
        if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)

		if tag ==111 then

			-- print("tag----->",tag)
			local needMoney,myAllMoney
			local paramTb = {} ---1-4 :action(1为金币抽奖 2为道具抽奖 3为领取任务奖励导弹 ),num(抽奖次数),free(是否免费抽奖，不是就别传这个参数),taskid(要领取奖励的任务ID)
		   if self.whiTag ==1 then --巨炮打击  使用道具
			paramTb ={2,nil,nil,nil}
		    needMoney = acStormFortressVoApi:getNeedBullet( )
		    myAllMoney = acStormFortressVoApi:getCurrentBullet( )
		   elseif self.whiTag ==2 then --单次 金币
		   	paramTb ={1,1,nil,nil}
		    needMoney =acStormFortressVoApi:getOneCostNeedGold( )
		    myAllMoney = playerVoApi:getGems()
		   elseif self.whiTag ==3 then --十次
		   	paramTb ={1,10,nil,nil}
		    myAllMoney =playerVoApi:getGems()
		    needMoney =acStormFortressVoApi:getTenCostNeedGold()
		   end
		  	 if SizeOfTable(paramTb) >0 then
		  	 	local function callback(fn,data)
			    	local ret,sData = base:checkServerData(data)
			        if ret==true then
			        	self.maskSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.5))
			        	self.maskSp:setVisible(true)
		        	    if self.whiTag==1 then
		                	acStormFortressVoApi:setCurrentBullet(myAllMoney-needMoney )
		                else
		                    playerVoApi:setGems(myAllMoney - needMoney )
		                end
			        	if sData and sData.data.stormFortress and sData.data.stormFortress.info then
			        		local info = sData.data.stormFortress.info
			        		self.llastDeHp = acStormFortressVoApi:getStormFortressLastHp()
			        		local lastDeHp = acStormFortressVoApi:getFortressHp()
			        		local ALLhp = acStormFortressVoApi:getStormFortressHP()
			        		local isDied = acStormFortressVoApi:getIsDied()
			        		acStormFortressVoApi:updateLastTime(info.t)--刷新最后一次时间
			        		acStormFortressVoApi:setCurrentBullet(info.missile)--重置炮弹数量
			                acStormFortressVoApi:setFortressHp(info.deHp) --击破的总血量
			                acStormFortressVoApi:setIsDied(info.destroyed) --是否死亡
			                acStormFortressVoApi:setNowRewardTb(sData.data.stormFortress.report)

			                if info.destroyed ~=nil and  isDied ~= info.destroyed then
			                	local bigAwardTb = acStormFortressVoApi:getBigReward()
			                	strs = G_showRewardTip(bigAwardTb,false,true)
						        local message={key="activity_chatMessageLabel",param={playerVoApi:getPlayerName(),strs,""}}
						        chatVoApi:sendSystemMessage(message)

			                end
			                -- print("lastDeHp---ALLhp-----info.deHp---self.llastDeHp->",lastDeHp,ALLhp,info.deHp,self.llastDeHp)
			                if self.llastDeHp < ALLhp and lastDeHp >= ALLhp and tonumber(info.deHp) >= ALLhp then
			                	acStormFortressVoApi:setWillDied(true)
			                	self.parent.getAwardDia=nil
			                	self.parent.getAwardDia=acStormFortressGetRewardDialog:new(self.layerNum + 1,self.parent,self.whiTag)
				                local dialog= self.parent.getAwardDia:init(nil)
				                self:close()
				            else
				                self:refresh( )
				            end
		            	end
			        end
			    end

		  	 	socketHelper:stormFortressSock(callback,paramTb[1],paramTb[2],paramTb[3],paramTb[4] )
		  	 end
		else
			self:close()
		end
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),strSize3)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.78,60))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-3);
    dialogBg:addChild(sureMenu)


    self.againItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("heroEquip_again"),strSize3)
    self.againItem:setTag(111)
    local againMenu=CCMenu:createWithItem(self.againItem);
    againMenu:setPosition(ccp(dialogBg:getContentSize().width*0.22,60))
    againMenu:setTouchPriority(-(self.layerNum-1)*20-3);
    dialogBg:addChild(againMenu)

    self:showGold(dialogBg)

    

    local function nilFunc() end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(0)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))


	local function tmpFunc()
        -- print("maskSp~~~~~~")

        self.maskSp:setPosition(ccp(G_VisibleSizeWidth*0.5,999999))
        self.maskSp:setVisible(false)
        self.bgLayer:stopAllActions()
		self.timerSpriteLv:stopAllActions()
        self.dialogLayer:stopAllActions()

        if self.particleS ~=nil then
        	self:removeParticles()
        end
        local isDied = acStormFortressVoApi:getIsDied()
		local iconShowTime = 0.6
		local ALLhp = acStormFortressVoApi:getStormFortressHP( )
		local deHp = acStormFortressVoApi:getFortressHp() --当前损失的血量
		if deHp >ALLhp then
			deHp =ALLhp
		end
        local per = tonumber(ALLhp-deHp)/tonumber(ALLhp) * 100
		local percentStr=(ALLhp-deHp).."/"..ALLhp
		self.timerSprite:setPercentage(per);
		self.timer1:setString(percentStr)
		self.timerSpriteLv:setPercentage(per)
		if self.awardShowTb and SizeOfTable(self.awardShowTb) > 0 then
			for k,v in pairs(self.awardShowTb) do
				v:setVisible(true)
			end
		end
    end
    self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    self.maskSp:setOpacity(0)
    local size=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.maskSp:setContentSize(size)
    self.maskSp:setAnchorPoint(ccp(0.5,0.5))
    self.maskSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.5))
    self.maskSp:setIsSallow(true)
    self.maskSp:setTouchPriority(-(self.layerNum-1)*20-10)
    self.bgLayer:addChild(self.maskSp,100)


	self:runActionNow()

	return self.dialogLayer
end

function acStormFortressGetRewardDialog:showGold(dialogBg)
	-- local isShowBtnTb = {0,0,0,0}--------4个按钮显示判断值 :setEnabled(false)
  	local needBullet = acStormFortressVoApi:getNeedBullet( )
	local currBullet = acStormFortressVoApi:getCurrentBullet( )
	local costOneInGold = acStormFortressVoApi:getOneCostNeedGold( )
	local costTenInGold = acStormFortressVoApi:getTenCostNeedGold()
	local playerHasGold = playerVoApi:getGems()

	local iconPic = "IconGold.png"
	local showGoldStr = costOneInGold
	if self.whiTag ==1 then
		iconPic ="dartPic.png"
		showGoldStr = getlocal("scheduleChapter",{currBullet,needBullet})
	elseif self.whiTag==3 then
		showGoldStr =costTenInGold
	end

	self.IconGoldInOne=CCSprite:createWithSpriteFrameName(iconPic)
	self.IconGoldInOne:setAnchorPoint(ccp(0,0.5))
	self.IconGoldInOne:setPosition(ccp(dialogBg:getContentSize().width*0.23,110))
	dialogBg:addChild(self.IconGoldInOne)
	---------------------------------需要单抽金币数量
	
	self.OnceNeedGold =GetTTFLabelWrap(showGoldStr,23,CCSizeMake(50,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
  	self.OnceNeedGold:setAnchorPoint(ccp(1,0.5))
  	self.OnceNeedGold:setColor(G_ColorYellowPro)
  	self.OnceNeedGold:setPosition(ccp(self.IconGoldInOne:getPositionX(),self.IconGoldInOne:getPositionY()))
  	dialogBg:addChild(self.OnceNeedGold)

  	if self.whiTag ==1 then
  		if currBullet >= needBullet then
		else
			self.OnceNeedGold:setColor(G_ColorRed)
			self.againItem:setEnabled(false)
		end
	elseif self.whiTag ==2 or self.whiTag ==4 then
		if playerHasGold >= costOneInGold then
		else
			self.OnceNeedGold:setColor(G_ColorRed)
			self.againItem:setEnabled(false)
		end
	else --10连抽
		if playerHasGold >= costTenInGold then
		else
			self.OnceNeedGold:setColor(G_ColorRed)
			self.againItem:setEnabled(false)
		end
	end
end

function acStormFortressGetRewardDialog:refresh( )
	-- print("in refresh~~~~")
	-- local isShowBtnTb = {0,0,0,0}--------4个按钮显示判断值 :setEnabled(false)
  	local needBullet = acStormFortressVoApi:getNeedBullet( )
	local currBullet = acStormFortressVoApi:getCurrentBullet( )
	local costOneInGold = acStormFortressVoApi:getOneCostNeedGold( )
	local costTenInGold = acStormFortressVoApi:getTenCostNeedGold()
	local playerHasGold = playerVoApi:getGems()

	local lastDeHp = acStormFortressVoApi:getStormFortressLastHp()--获取上一次损失的血量
	local deHp = acStormFortressVoApi:getFortressHp() --当前损失的血量
	local showDeHp = deHp - lastDeHp
	local upLabel ="activity_stormFortress_stormNormSucessLab"
	if self.upLabelStr ~= nil then
		self.upLabelStr:setString(getlocal(upLabel,{showDeHp}))
	end

	if self.whiTag ==1 then
  		if currBullet >= needBullet then
			self.OnceNeedGold:setColor(G_ColorYellowPro)
			self.againItem:setEnabled(true)
		else
			self.OnceNeedGold:setColor(G_ColorRed)
			self.againItem:setEnabled(false)
		end
		showGoldStr = getlocal("scheduleChapter",{currBullet,needBullet})
		self.OnceNeedGold:setString(showGoldStr)
		if self.parent and self.parent.bombardNumsShow then
			tolua.cast(self.parent.bombardNumsShow,"CCLabelTTF"):setString(getlocal("scheduleChapter",{currBullet,needBullet}))
		end
	elseif self.whiTag ==2 or self.whiTag ==4 then
		if playerHasGold >= costOneInGold then
			self.OnceNeedGold:setColor(G_ColorYellowPro)
			self.againItem:setEnabled(true)
		else
			self.OnceNeedGold:setColor(G_ColorRed)
			self.againItem:setEnabled(false)
		end
	else --10连抽
		if playerHasGold >= costTenInGold then
			self.OnceNeedGold:setColor(G_ColorYellowPro)
			self.againItem:setEnabled(true)
		else
			self.OnceNeedGold:setColor(G_ColorRed)
			self.againItem:setEnabled(false)
		end
	end
	for k,v in pairs(self.awardShowTb) do
		v:setVisible(false)
	end
	self.awardShowTb={}

	local isDied =acStormFortressVoApi:getIsDied()
	self.lotsAward ={}
	self.lotsAward =acStormFortressVoApi:getNowRewardTb()--{}------取配置奖励库


	if self.tv then
		self.tv:reloadData()
	end
	self:runActionNow()
end


function acStormFortressGetRewardDialog:runActionNow( delayTime)
	-- print("in runAction~~~~")
	if delayTime ==nil then
		delayTime =1
	end
	local isDied = acStormFortressVoApi:getIsDied()
	local iconShowTime = 0.6
	local ALLhp = acStormFortressVoApi:getStormFortressHP( )
    local lastDeHp = acStormFortressVoApi:getStormFortressLastHp()--获取上一次损失的血量
	local deHp = acStormFortressVoApi:getFortressHp() --当前损失的血量
	local lastAllHp = ALLhp-lastDeHp --上一次的总血量
	local nowAllHp = ALLhp-deHp --当前的总血量
	local awardNums = SizeOfTable(self.awardShowTb)
	local awardShowNums = SizeOfTable(self.awardShowTb)
	


	local needNums = lastAllHp-nowAllHp
	if needNums <=0 then
		needNums =deHp
	end
	local delayNums2 = 0.09
	if deHp - lastDeHp >200 then
		delayNums2 =0.03
	elseif deHp - lastDeHp >100 then
		delayNums2 =0.05
	end
	if isDied ==0 then
		if awardNums ==1 then
			iconShowTime =0.3
		elseif awardNums <5 then
			iconShowTime =1.5/awardNums
		else
			iconShowTime =8/awardNums
		end
	else
		delayTime = 0.3
		if awardNums ==1 then
			iconShowTime =0.3
		elseif awardNums <5 then
			iconShowTime =1.5/awardNums
		else
			iconShowTime =8/awardNums
		end
	end
	
	local delay1 =CCDelayTime:create(delayTime)
	local delay2 =CCDelayTime:create(delayNums2)
	local acArr1=CCArray:create()
	local acArr2 = CCArray:create()
	local function showSmoke( )
		self:playParticles()
	end 
	local function endRunActionNow( )
		self.maskSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,999999))
		self.maskSp:setVisible(false)
		self:removeParticles()
	end
	local function endRunActionNow2( )
		if isDied ==1 and acStormFortressVoApi:getWillDied() ==true then
			self.maskSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,999999))
			self.maskSp:setVisible(false)
		end
		self:removeParticles()
	end 
	local function lossBlood(  )
		if lastDeHp <  deHp and lastDeHp < ALLhp then
			lastDeHp =lastDeHp+1
			local per = tonumber(ALLhp-lastDeHp)/tonumber(ALLhp) * 100
			local percentStr=(ALLhp-lastDeHp).."/"..ALLhp
			self.timerSprite:setPercentage(per);
			self.timer1:setString(percentStr)
		end
	end
	local smokeCall = CCCallFunc:create(showSmoke)
	local endR = CCCallFunc:create(endRunActionNow)
	local fc= CCCallFunc:create(lossBlood)
	acArr2:addObject(delay2)
	acArr2:addObject(fc)

	local seq2=CCSequence:create(acArr2)
	local repeatInTime=CCRepeat:create(seq2,needNums+10)
	acArr1:addObject(delay1)
	acArr1:addObject(repeatInTime)
	acArr1:addObject(endR)
	local seq1 = CCSequence:create(acArr1)
	

	local blinkNow= CCBlink:create(1, 2)
	local delay3 = CCDelayTime:create(delayTime+delayNums2*needNums)
	local acArr3 = CCArray:create()
	acArr3:addObject(delay3)
	acArr3:addObject(blinkNow)
	local function blinkCall( )
		local needDeHp = ALLhp-deHp
		local per = tonumber(needDeHp)/tonumber(ALLhp) * 100
		self.timerSpriteLv:setPercentage(per);
	end 
	local fc2 = CCCallFunc:create(blinkCall)
	acArr3:addObject(fc2)
	local seq3 = CCSequence:create(acArr3)
	if isDied ==0 or lastDeHp < ALLhp then
		self.bgLayer:runAction(seq1)
		self.timerSpriteLv:runAction(seq3);
	end
	local showNext = 1
	local function awardShowing( )
		if awardShowNums >= showNext then
			self.awardShowTb[showNext]:setVisible(true)
			showNext = showNext+1
		end
	end 
	
	local fc3 = CCCallFunc:create(awardShowing)
	local endR2 = CCCallFunc:create(endRunActionNow2)
	local acArr4 = CCArray:create()
	local delay4 = CCDelayTime:create(iconShowTime)
	acArr4:addObject(delay4)
	acArr4:addObject(fc3)
	local seq4=CCSequence:create(acArr4)
	local repeatInTime2=CCRepeat:create(seq4,awardShowNums+1)
	local acArr5 = CCArray:create()
	acArr5:addObject(delay1)
	acArr5:addObject(smokeCall)
	acArr5:addObject(repeatInTime2)
	acArr5:addObject(endR2)
	local seq5 = CCSequence:create(acArr5)
	
	self.wholeBgSp:runAction(seq5)
end

function acStormFortressGetRewardDialog:playParticles()
    --粒子效果
  self.particleS = {}
  local pX = nil
  local PY = nil
  for i=1,3 do
    pX = self.bgLayer:getContentSize().width/2 + (i - 2) * 200
    PY = self.bgLayer:getContentSize().height/2
    if i ~= 2 then
      PY = PY + 200
    end
    local p = CCParticleSystemQuad:create("public/SMOKE.plist")
    p.positionType = kCCPositionTypeFree
    p:setPosition(ccp(pX,PY))
    self.bgLayer:addChild(p,10)
    table.insert(self.particleS,p)
  end
  self.addParticlesTs = base.serverTime
end
function acStormFortressGetRewardDialog:removeParticles()
  for k,v in pairs(self.particleS) do
    v:removeFromParentAndCleanup(true)
  end
  self.particleS = nil
  self.addParticlesTs = nil
end

function acStormFortressGetRewardDialog:initTableView( ... )

	local tvHeight = self.dialogHeight*0.5
	if SizeOfTable(self.lotsAward)<5 then
		tvHeight =180
	else
		tvHeight =tvHeight+40
	end

	local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	middleBg:setContentSize(CCSizeMake(self.dialogWidth-30 ,tvHeight))
	middleBg:setAnchorPoint(ccp(0,0))
	middleBg:setPosition(ccp(15,140))
	self.bgLayer:addChild(middleBg)

	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-30 ,tvHeight),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setPosition(ccp(15,120))
	self.tv:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
	-- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(120)
	self.tv:setPosition(ccp(5,140))

	-- self:runActionNow()
end

function acStormFortressGetRewardDialog:eventHandler(handler,fn,idx,cel)
	local needHeight = 50
	local tvHeight = self.dialogHeight*0.5
	local isDied = acStormFortressVoApi:getIsDied()
	local ALLhp = acStormFortressVoApi:getStormFortressHP( )
	if SizeOfTable(self.lotsAward)>8 then
		-- tvHeight =280
		needHeight =tvHeight
	end

   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
   		
       return  CCSizeMake(self.dialogWidth ,285)-- -self.dialogHeight*0.5+needHeight
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       local needHeight2 = 95
       local subHeight4 = 0
		if SizeOfTable(self.lotsAward)>5 then
			needHeight2 =240
		end
		
		if SizeOfTable(self.lotsAward)<5 then
			tvHeight =180
			needHeight2 =200
		end
       	local function touch( )
       	end 
		self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
		self.wholeBgSp:setContentSize(CCSizeMake(self.dialogWidth ,tvHeight-40))
		self.wholeBgSp:setAnchorPoint(ccp(0,1))
		self.wholeBgSp:setOpacity(0)
		self.wholeBgSp:setPosition(ccp(15,285))
		cell:addChild(self.wholeBgSp)
		local addW = 130
		local addH = 130
		local addH2 = 80

		
	    local lastDeHp = acStormFortressVoApi:getStormFortressLastHp()--获取上一次损失的血量
		if lastDeHp > ALLhp then
			addH2 =65
			addH =120
		end
		if SizeOfTable(self.lotsAward)<5 then
			addH2 = 80
		end
		local cellHeight = self.wholeBgSp:getContentSize().height
		for k,v in pairs(self.lotsAward) do
			local aHeight = math.floor((k-1)/4)
			local awidth = k%4
			if awidth==0 then
				awidth=4
			end
			local bgSp,scale =G_getItemIcon(v,100,true,self.layerNum,nil)
			bgSp:setTouchPriority(-(self.layerNum-1)*20-2)		
			bgSp:setPosition(ccp(70+addW*(awidth-1), cellHeight-addH2-addH*aHeight))
			if SizeOfTable(self.lotsAward) ==1 then
				bgSp:setPosition(ccp(self.wholeBgSp:getContentSize().width*0.5-20, cellHeight-addH2-addH*aHeight))
			end
			self.wholeBgSp:addChild(bgSp)
			if k<13 then
				table.insert(self.awardShowTb,bgSp)
			end
			bgSp:setVisible(false)

			local numLabel=GetTTFLabel("x"..v.num,21)
			numLabel:setAnchorPoint(ccp(1,0))
			numLabel:setPosition(bgSp:getContentSize().width-5, 5)
			numLabel:setScale(1/scale)
			bgSp:addChild(numLabel,1)
		end
       cell:autorelease()
       -- self:runActionNow()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acStormFortressGetRewardDialog:close(isCloseParent)
	if self.parent and isCloseParent ==nil then
		self.parent:refresh()
	end
	-- print("in close~~~~")
	self.parent.getAwardBg:setVisible(false)
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.awardShowTb=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.IconGoldInOne=nil
	self.OnceNeedGold=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.lotsAward=nil
	self.bigReward =nil
	self.upTodayTime=nil
	self.timerSpriteLv=nil
	self.timerSprite=nil
	self.timer1=nil
	self.whiTag =nil
	self.llastDeHp =nil
	self.particleS =nil
	self.upLabelStr =nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    base:removeFromNeedRefresh(self)
end