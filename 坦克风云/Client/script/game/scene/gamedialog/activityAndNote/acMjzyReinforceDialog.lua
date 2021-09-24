-- @Author hj
-- @Description 名将增援抽奖板子
-- @Date 2018-06-11

acMjzyReinforceDialog = {} 

function acMjzyReinforceDialog:new(layer)
	local nc = {
		layerNum = layer,
		mapArea = {},
		mapLine = {},
		randomArr = {},
        repeatArr = {},
        adaH = 0,
        adaH1 = 0,
		actionFlag1 = 0,
        actionFlag2 = 0,
		rewardCallback = nil,
		lineLength = nil,
		attackpos = {ccp(207.5,307.5),ccp(500.5,318.5),ccp(480.5,140.5),ccp(203,124),ccp(372.5,230)},
		pos = {ccp(207.5,307.5),ccp(500.5,318.5),ccp(498.5,113.5),ccp(203,114),ccp(372.5,230)}
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acMjzyReinforceDialog:init()
    if G_getIphoneType() ~= G_iphone4 then
        self.adaH = 30
    else
        self.adaH1 = 30
    end
	self.bgLayer=CCLayer:create()
	self:doUserHandler()
	return self.bgLayer
end

function acMjzyReinforceDialog:doUserHandler()

	local function nilFunc( ... )
		do return end
	end

	--顶框
	local topBorder = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),nilFunc)
	self.bgLayer:addChild(topBorder)
	topBorder:setAnchorPoint(ccp(0.5,1))
	topBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth,85))
	topBorder:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))

	--倒计时 
	local timeLb = GetTTFLabel(acMjzyVoApi:getAcTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-170))
	self.timeLb = timeLb
	self.bgLayer:addChild(timeLb)

	local function touchInfo()
        local tabStr={}
        for i=1,4 do
        	table.insert(tabStr,getlocal("activity_mjzy_tip"..i))
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
	end 

    local tipButton = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-160-30),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,0.8,-(self.layerNum-1)*20-4)
   	
   	local mapBg=CCSprite:create("public/mjzy_map.jpg")
    self.bgLayer:addChild(mapBg)
    mapBg:setAnchorPoint(ccp(0.5,0))
    mapBg:setPosition(ccp(G_VisibleSizeWidth/2,180+self.adaH-self.adaH1))
    self.mapBg = mapBg

    for i=1,5 do
		local mapArea = CCSprite:createWithSpriteFrameName("map_"..i..".png")
		mapArea:setVisible(false)
		mapArea:setPosition(self.pos[i])
		self.mapBg:addChild(mapArea)
		self.mapArea[i] = mapArea		
	end
    local tipFontSize,tipPosY = 22,160+self.adaH-self.adaH1/6*5
    if G_getIphoneType() == G_iphone4 then
        tipFontSize = 20
        tipPosY = mapBg:getPositionY()-2
    end
    local rewardLb = GetTTFLabelWrap(getlocal("activity_mjzy_buyPrompt"),tipFontSize,CCSize(580,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rewardLb:setColor(G_ColorYellowPro)
    rewardLb:setAnchorPoint(ccp(0.5,1))
    rewardLb:setPosition(ccp(G_VisibleSizeWidth/2,tipPosY))
    self.bgLayer:addChild(rewardLb)

    local strSize = G_isAsia() and 22 or 20

	-- 奖池回调
	local function rewardCallback( ... )
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local rewardTb = FormatItem(acMjzyVoApi:getRewardTb(),true,true)
        local titleStr,descStr = getlocal("award"),getlocal("activity_mjzy_awardShowTip")
        local needTb = {"mjzx",titleStr,descStr,rewardTb,SizeOfTable(rewardTb)}
        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        sd:init()
	end 
	local poolBtn = G_createBotton(self.bgLayer,ccp(50,260+self.adaH-self.adaH1),nil,"taskBox5.png","taskBox5.png","taskBox5.png",rewardCallback,0.8,-(self.layerNum-1)*20-4)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,1))
    poolBg:setContentSize(CCSizeMake(poolBtn:getContentSize().width+10,40))
    poolBg:setPosition(ccp(poolBtn:getContentSize().width/2,0))
    poolBg:setScale(1/poolBtn:getScale())
    poolBg:setOpacity(0)
    poolBtn:addChild(poolBg)
    local poolLb=GetTTFLabelWrap(getlocal("award"),strSize,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    poolBg:addChild(poolLb)

    -- 记录回调
	local function recordCallback( ... )
		local function showLog(rewardLog)
            if #rewardLog == 0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            else
    			local logList={}
                for k,v in pairs(rewardLog) do
                    local num,reward,time=v.num,v.rewardlist,v.time
                    local title = {getlocal("activity_mjzy_logtip",{num})}
                    local content={{reward}}
                    local log={title=title,content=content,ts=time}
                    table.insert(logList,log)
                end
                local logNum=SizeOfTable(logList)
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
                acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_gangtieronglu_record_title"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
            end
        end
      	acMjzyVoApi:getLog(showLog)
	end
	local logBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-50,260+self.adaH-self.adaH1),nil,"bless_record.png","bless_record.png","bless_record.png",recordCallback,0.8,-(self.layerNum-1)*20-4)
	local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,0))
    logBg:setScale(1/logBtn:getScale())
    logBg:setOpacity(0)
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),strSize,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logBg:addChild(logLb)

    local function heroChoseCallback( ... )
    	if acMjzyVoApi:getRewardNum() < acMjzyVoApi:getUpRateCostNum() then
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("activity_mjzy_limit",{acMjzyVoApi:getUpRateCostNum(),acMjzyVoApi:getShowRate()}),nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
    	else
			require "luascript/script/game/scene/gamedialog/activityAndNote/acMjzySmallDialog" 
			acMjzySmallDialog:showHeroSettingSmallDialog(CCSizeMake(550,900),getlocal("dailyTask_sub_title_4"),30,G_ColorWhite,self.layerNum+1,self)
    	end
    end

    local function heroDeleteCallBack( ... )
    	if acMjzyVoApi:getHeroSet() ~= "" then
		    local function callback(fn,data)
	             local ret,sData = base:checkServerData(data)
	             if ret==true then
	                 if sData.data and sData.data.mjzy then
	                     acMjzyVoApi:updateSpecialData(sData.data.mjzy)
	                     self:refreshRateSprite()
	                 end     
	             end
	        end
        	socketHelper:acMjzyHeroSetting("",2,callback)
    	else
            do return end
    	end
    end

    local rateSp =  LuaCCSprite:createWithSpriteFrameName("hero_base.png",heroChoseCallback)
    rateSp:setTouchPriority(-(self.layerNum-1)*20-3)
    rateSp:setAnchorPoint(ccp(0.5,1))
    rateSp:setPosition(ccp(45,571+self.adaH-self.adaH1))
   	self.bgLayer:addChild(rateSp,5)
    self.rateSp = rateSp

    local rateHeroSp = CCSprite:createWithSpriteFrameName("hero_green.png")
    rateHeroSp:setTag(1016)
    rateHeroSp:setAnchorPoint(ccp(0.5,0.5))
    rateHeroSp:setPosition(getCenterPoint(rateSp))
    rateSp:addChild(rateHeroSp)
    rateHeroSp:setVisible(false)

    local rateDelSp = CCSprite:createWithSpriteFrameName("hero_close.png")
    rateDelSp:setTag(1017)
    rateDelSp:setAnchorPoint(ccp(1,1))
    rateDelSp:setPosition(ccp(80,80))
    rateSp:addChild(rateDelSp,3)
    rateDelSp:setVisible(false)

    local touchDelSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),heroDeleteCallBack)
    touchDelSp:setTouchPriority(-(self.layerNum-1)*20-4)
    touchDelSp:setIsSallow(true)
    touchDelSp:setTag(1030)
    touchDelSp:setContentSize(CCSizeMake(30,30))
    touchDelSp:setAnchorPoint(ccp(0,1))
    touchDelSp:setPosition(ccp(65,80))
    rateSp:addChild(touchDelSp,4)
    touchDelSp:setVisible(false)

    local plusSp = CCSprite:createWithSpriteFrameName("greenPlus.png")
    plusSp:setTag(1018)
    plusSp:setAnchorPoint(ccp(0.5,0.5))
    plusSp:setPosition(getCenterPoint(rateSp))
    rateSp:addChild(plusSp)
    plusSp:setVisible(false)


    local numLb = GetTTFLabel(acMjzyVoApi:getRewardNum(),22,true)
    numLb:setColor(G_ColorRed)
    numLb:setTag(1019)
    numLb:setAnchorPoint(ccp(1,0))
    numLb:setPosition(ccp(getCenterPoint(rateSp).x-3,2))
    rateSp:addChild(numLb)
    numLb:setVisible(false)

    local numLb1 = GetTTFLabel("/"..acMjzyVoApi:getUpRateCostNum(),22,true)
    numLb1:setTag(1020)
    numLb1:setAnchorPoint(ccp(0,0))
    numLb1:setPosition(ccp(numLb:getPositionX(),2))
    rateSp:addChild(numLb1)
    numLb1:setVisible(false)

    local str = acMjzyVoApi:getShowRate()
    local rateLabel = GetBMLabel(str,G_GoldFontSrc) 
    rateLabel:setAnchorPoint(ccp(0.5,0.5))
    rateLabel:setPosition(ccp(80,0))
    rateLabel:setTag(1021)
    rateSp:addChild(rateLabel,2)
    rateLabel:setScale(0.5)
    rateLabel:setVisible(false)

    local multiply = GetBMLabel("+",G_GoldFontSrc) 
    multiply:setAnchorPoint(ccp(0.5,0.5))
    multiply:setPosition(ccp(50,0))
    multiply:setRotation(50)
    multiply:setTag(1022)
    multiply:setScale(0.5)
    self.rateSp:addChild(multiply,2)
    multiply:setVisible(false)


    local function nilFunc( ... )
        -- body
    end
    local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),nilFunc)
    newsIcon:setContentSize(CCSizeMake(36,36))
    newsIcon:setAnchorPoint(ccp(0.5,0.5))
    newsIcon:setPosition(ccp(5,80))
    newsIcon:setScale(0.5)
    newsIcon:setTag(1023)
    newsIcon:setVisible(false)
    rateSp:addChild(newsIcon)

    self:refreshRateSprite()


    local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setPosition(ccp(G_VisibleSizeWidth * 0.5,topBorder:getPositionY() - topBorder:getContentSize().height + 10))
    self.bgLayer:addChild(titleBg)
    local strSize2 = G_isAsia() and 25 or 22
    local titleStr = GetTTFLabel(getlocal("activity_mjzx_tab1_title"),strSize2,"Helvetica-bold")
    titleStr:setPosition(getCenterPoint(titleBg))
    titleStr:setColor(G_ColorYellowPro2)
    titleBg:addChild(titleStr)

    local bigRewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)--"greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    bigRewardBg:setContentSize(CCSizeMake(616,150+self.adaH*2))
    bigRewardBg:setPosition(ccp(G_VisibleSizeWidth*0.5,titleBg:getPositionY() - titleBg:getContentSize().height * 0.5 - 2-self.adaH/3))
    bigRewardBg:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(bigRewardBg)

    local upRedLine = CCSprite:createWithSpriteFrameName("monthlyBar.png")
    upRedLine:setPosition(ccp(bigRewardBg:getContentSize().width * 0.5,bigRewardBg:getContentSize().height))
    upRedLine:setAnchorPoint(ccp(0.5,1))
    bigRewardBg:addChild(upRedLine)

    local useWidth = bigRewardBg:getContentSize().width
    local heroList = acMjzyVoApi:getHerolist()
   
    local hBgScale,costLbFontSize,btnY,goldScale = 1,24,50,1
    if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" and G_getIphoneType() == G_iphone4 then
        hBgScale,costLbFontSize,btnY,goldScale= 0.8,22,45,0.85
    end
    -- 将领图标的添加
    for k,v in pairs(heroList) do
        local hBg = CCSprite:createWithSpriteFrameName("mjzxIconBg.png")
        hBg:setPosition(ccp(useWidth*0.195*k - 111*0.6 + 5*k,bigRewardBg:getContentSize().height * 0.5+3))
        bigRewardBg:addChild(hBg)
        hBg:setScale(hBgScale)

        --添加将领点击事件
        local function touchHeroIcon(...)
            PlayEffect(audioCfg.mouseClick)        
            require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
            local hid = heroList[k].name
            local heroProductOrder = heroList[k].quality
            local td = acHuoxianmingjiangHeroInfoDialog:new(hid,heroProductOrder,"mjzx",true)
            local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
            sceneGame:addChild(dialog,self.layerNum+1)
        end   

        local hid = heroList[k].name
        local heroProductOrder = heroList[k].quality
        local heroIcon = heroVoApi:getHeroIcon(hid,heroProductOrder,false,touchHeroIcon)
        heroIcon:setTouchPriority(-(self.layerNum-1)*20-3)
        heroIcon:setPosition(getCenterPoint(hBg))
        heroIcon:setScale(80/heroIcon:getContentSize().width)
        hBg:addChild(heroIcon,1)

        local strSize5 = G_isAsia() and 20 or 17
        local heroNameStr = GetTTFLabelWrap(heroVoApi:getHeroName(hid),strSize5,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
        heroNameStr:setAnchorPoint(ccp(0.5,1))
        heroNameStr:setColor(G_ColorYellowPro)
        heroNameStr:setPosition(ccp(hBg:getContentSize().width *0.5, 6-self.adaH/3))
        hBg:addChild(heroNameStr)
    end

  
    local function getFreeRewardCallback()

        
        if self.actionFlag1 == 1 then
            do return end
        end

        if self.actionFlag2 == 1 then
            self:cleanRewardTb()
        end

        self:cleanRewardTb()

    	local isFree = acMjzyVoApi:getFirstFree()
    	if isFree == 0 then
	    	local function callback(fn,data)
	    		local ret,sData = base:checkServerData(data)
	    		if ret==true then
	    			local time
					local rewardTb = {}
					local num = 1
	    			if sData.data and sData.data.mjzy then
	    				if sData.data.mjzy.t then
	    					time = sData.data.mjzy.t
	    				end
	    				acMjzyVoApi:updateSpecialData(sData.data.mjzy)
	    				self:refreshBtn()
	    				self:refreshRateSprite()
	    			end
	    			if sData.data and sData.data.reward then
                        local hxReward = acMjzyVoApi:getHexieReward()
                        table.insert(rewardTb,hxReward)
	    				for k,v in pairs(sData.data.reward) do
	    					for kk,vv in pairs(v) do
	    						local reward = FormatItem(vv,nil,true)[1]
	    						table.insert(rewardTb,reward)
		    				end
	    				end
	        			for k,v in pairs(rewardTb) do
                            if v.type == "h" then
                                heroVoApi:addSoul(v.key,v.num)
                            else
                                G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
	        			end
	        			local function callBack(randomArr)
	                    	G_showRewardTip(rewardTb,true)
	                    	local function showNewPropInfo()
                                G_showNewPropInfo(self.layerNum+1,true,true,nil,rewardTb[2])
							end
						    local icon,scale=G_getItemIcon(rewardTb[2],80,false,self.layerNum+1,showNewPropInfo,nil,nil,nil,nil,nil,true)
                            icon:setTag(1)
						    icon:setAnchorPoint(ccp(0.5,0.5))
						    icon:setPosition(ccp(self.attackpos[randomArr[5]].x,self.attackpos[randomArr[5]].y+180))
						    icon:setTouchPriority(-(self.layerNum-1)*20-2)
						    self.touchSp1:addChild(icon)
						    local numLb=GetTTFLabel("x"..FormatNumber(rewardTb[2].num),18)
						    numLb:setAnchorPoint(ccp(1,0))
						    numLb:setPosition(ccp(icon:getContentSize().width-5,5))
						    icon:addChild(numLb,1)
						    numLb:setScale(1/scale)
						    local function callfunc( ... )
						    	if icon then
						    		icon:removeFromParentAndCleanup(true)
						    		icon = nil
						    		self.actionFlag2 = 0
						    	end
						    end
						    local delay = CCDelayTime:create(10)
						    local func = CCCallFunc:create(callfunc)
						    local seq = CCSequence:createWithTwoActions(delay,func)
						    icon:runAction(seq)
		        		end
		        		self.rewardCallback = callBack
		    			self:runSingleRewardAction(callBack)
	    			end
	    			acMjzyVoApi:insertLog(num,rewardTb,time)
	    		end
	    	end
	    	socketHelper:acMjzyGetReward(1,isFree,callback)
    	end
    end

    local function getSingleRewardCallback()

        if self.actionFlag1 == 1 then
            do return end
        end

    	if self.actionFlag2 == 1 then
            self:cleanRewardTb()
    	end

        self:cleanRewardTb()

    	local isFree = acMjzyVoApi:getFirstFree()
    	if playerVoApi:getGems() < acMjzyVoApi:getSingleCost() then
            GemsNotEnoughDialog(nil,nil,acMjzyVoApi:getSingleCost()-playerVoApi:getGems(),self.layerNum+1,acMjzyVoApi:getSingleCost())
        else
        	local function confirmHandler( ... )
        		local function callback(fn,data)
	    			local ret,sData = base:checkServerData(data)
	    			if ret==true then
	    				local time
						local rewardTb = {}
						local num = 1
		    			if sData.data and sData.data.mjzy then
		    				if sData.data.mjzy.t then
	    						time = sData.data.mjzy.t
	    					end
		    				acMjzyVoApi:updateSpecialData(sData.data.mjzy)
		    				self:refreshBtn()
		    				self:refreshRateSprite()
		    			end
		    			if sData.data and sData.data.reward then
		    				local hxReward = acMjzyVoApi:getHexieReward()
	    					table.insert(rewardTb,hxReward)
		    				playerVoApi:setGems(playerVoApi:getGems()- acMjzyVoApi:getSingleCost())
		    				for k,v in pairs(sData.data.reward) do
		    					for kk,vv in pairs(v) do
		    						local reward = FormatItem(vv,nil,true)[1]
		    						table.insert(rewardTb,reward)
		    					end
		    				end
		        			for k,v in pairs(rewardTb) do
                                if v.type == "h" then
                                    heroVoApi:addSoul(v.key,v.num)
                                else
                                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                end
		        			end
		        			local function callBack(randomArr)
                                self.actionFlag1 = 0
                                self.actionFlag2 = 1
                                G_showRewardTip(rewardTb,true)
		                    	local function showNewPropInfo()
								    G_showNewPropInfo(self.layerNum+1,true,true,nil,rewardTb[2])
								end
							    local icon,scale=G_getItemIcon(rewardTb[2],80,false,self.layerNum+1,showNewPropInfo,nil,nil,nil,nil,nil,true)
                                icon:setAnchorPoint(ccp(0.5,0.5))
							    icon:setPosition(ccp(self.attackpos[randomArr[5]].x,self.attackpos[randomArr[5]].y+180+self.adaH-self.adaH1))
							    icon:setTouchPriority(-(self.layerNum-1)*20-2)
							    self.touchSp1:addChild(icon)
							    local numLb=GetTTFLabel("x"..FormatNumber(rewardTb[2].num),18)
							    numLb:setAnchorPoint(ccp(1,0))
							    numLb:setPosition(ccp(icon:getContentSize().width-5,5))
							    icon:addChild(numLb,1)
							    numLb:setScale(1/scale)
                              
							    local function callfunc( ... )
							    	if icon then
							    		icon:removeFromParentAndCleanup(true)
							    		icon = nil
							    		self.actionFlag2 = 0
							    	end
							    end
							    local delay = CCDelayTime:create(10)
							    local func = CCCallFunc:create(callfunc)
							    local seq = CCSequence:createWithTwoActions(delay,func)
							    icon:runAction(seq)
			        		end
		        			self.rewardCallback = callBack
			    			self:runSingleRewardAction(callBack)
		    			end
	    				acMjzyVoApi:insertLog(num,rewardTb,time)
	    			end
        		end
        		socketHelper:acMjzyGetReward(1,isFree,callback)	
        	end 
    	 	local function secondTipFunc(sbFlag)
                local keyName = "mjzy"
                local sValue=base.serverTime .. "_" .. sbFlag
                G_changePopFlag(keyName,sValue)
            end
            local keyName = "mjzy"
            if G_isPopBoard(keyName) then
               G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{acMjzyVoApi:getSingleCost()}),true,confirmHandler,secondTipFunc)
            else
                confirmHandler()
            end
        end
    end

    local function getMutiRewardCallback()

    	if self.actionFlag1 == 1 then
            do return end
        end

        if self.actionFlag2 == 1 then
            self:cleanRewardTb()
        end

        self:cleanRewardTb()

    	local isFree = acMjzyVoApi:getFirstFree()
    	if playerVoApi:getGems() < acMjzyVoApi:getMultiCost() then
            GemsNotEnoughDialog(nil,nil,acMjzyVoApi:getSingleCost()-playerVoApi:getGems(),self.layerNum+1,acMjzyVoApi:getSingleCost())
        else
        	local function confirmHandler( ... )
        		local function callback(fn,data)
	    			local ret,sData = base:checkServerData(data)
	    			if ret==true then
	    				local time
	    				local areaNum = 5
						local rewardTb = {}
						local displayTb = {}
						local num = 5
		    			if sData.data and sData.data.mjzy then
		    				acMjzyVoApi:updateSpecialData(sData.data.mjzy)
		    				if sData.data.mjzy.t then
	    						time = sData.data.mjzy.t
	    					end
		    				self:refreshBtn()
		    				self:refreshRateSprite()
		    			end
		    			if sData.data and sData.data.reward then
							areaNum = SizeOfTable(sData.data.reward)
		    				playerVoApi:setGems(playerVoApi:getGems()-acMjzyVoApi:getMultiCost())
		    				local hxReward = acMjzyVoApi:getHexieReward()
		    				hxReward.num = hxReward.num *5
	    					table.insert(displayTb,hxReward)
		    				for k,v in pairs(sData.data.reward) do
		    					for kk,vv in pairs(v) do
		    						local reward = FormatItem(vv,nil,true)[1]
		    						table.insert(displayTb,reward)
                                    table.insert(rewardTb,reward)
	    						end
		    				end
		        			for k,v in pairs(displayTb) do
                                if v.type == "h" then
                                    heroVoApi:addSoul(v.key,v.num)
                                else
								    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                end
		        			end
		        			local function callBack(randomArr)

                                self.actionFlag1 = 0
                                self.actionFlag2 = 1

                                G_showRewardTip(displayTb,true)
		        				for k,v in pairs(rewardTb) do
			                    	local function showNewPropInfo()
									    G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
									end
								    local icon,scale=G_getItemIcon(v,80,false,self.layerNum+1,showNewPropInfo,nil,nil,nil,nil,nil,true)
                                    if self.repeatArr and #self.repeatArr > 0 then
                                        local flag = 0
                                        for kk,vv in pairs(self.repeatArr) do
                                            if randomArr[k] == vv then
                                                if acMjzyVoApi:judgeFirst(randomArr,vv,k) == true then
                                                    icon:setAnchorPoint(ccp(1,0.5))
                                                    icon:setPosition(ccp(self.attackpos[randomArr[k]].x,self.attackpos[randomArr[k]].y+180+self.adaH-self.adaH1))
                                                else
                                                    icon:setAnchorPoint(ccp(0,0.5))
                                                    icon:setPosition(ccp(self.attackpos[randomArr[k]].x,self.attackpos[randomArr[k]].y+180+self.adaH-self.adaH1))
                                                end
                                                flag = 1
                                            end
                                        end
                                        if flag == 0 then
                                            icon:setAnchorPoint(ccp(0.5,0.5))
                                            icon:setPosition(ccp(self.attackpos[randomArr[k]].x,self.attackpos[randomArr[k]].y+180+self.adaH-self.adaH1))
                                        end
                                    else
                                        icon:setAnchorPoint(ccp(0.5,0.5))
                                        icon:setPosition(ccp(self.attackpos[randomArr[k]].x,self.attackpos[randomArr[k]].y+180+self.adaH-self.adaH1))
                                    end

								    icon:setTouchPriority(-(self.layerNum-1)*20-2)
								    self.touchSp1:addChild(icon)
								    local numLb=GetTTFLabel("x"..FormatNumber(v.num),18)
								    numLb:setAnchorPoint(ccp(1,0))
								    numLb:setPosition(ccp(icon:getContentSize().width-5,5))
								    icon:addChild(numLb,1)
								    numLb:setScale(1/scale)
								    local function callfunc( ... )
								    	if icon then
								    		icon:removeFromParentAndCleanup(true)
								    		icon = nil
								    		if k == #rewardTb then
								    			self.actionFlag2 = 0
								    		end
								    	end
				    				end
								    local delay = CCDelayTime:create(10)
								    local func = CCCallFunc:create(callfunc)
								    local seq = CCSequence:createWithTwoActions(delay,func)
								    icon:runAction(seq)
		        				end
				        	end
		        			self.rewardCallback = callBack
		                    self:runMutliRewardAction(areaNum,callBack)
		    			end
	    				acMjzyVoApi:insertLog(num,displayTb,time)
	    			end
        		end
        		socketHelper:acMjzyGetReward(5,isFree,callback)	
        	end
        	local function secondTipFunc(sbFlag)
                local keyName = "mjzy"
                local sValue=base.serverTime .. "_" .. sbFlag
                G_changePopFlag(keyName,sValue)
            end
            local keyName = "mjzy"
            if G_isPopBoard(keyName) then
               G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{acMjzyVoApi:getMultiCost()}),true,confirmHandler,secondTipFunc)
            else
                confirmHandler()
            end
        end
    end

    local freeBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/4,btnY),{getlocal("daily_lotto_tip_2"),24},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getFreeRewardCallback,0.8,-(self.layerNum-1)*20-4)
    freeBtn:setVisible(false)
    self.freeBtn = freeBtn

    local singleBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/4,btnY),{getlocal("emblem_getBtnLbHexie",{1}),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",getSingleRewardCallback,0.8,-(self.layerNum-1)*20-4)
    singleBtn:setVisible(false)
    self.singleBtn = singleBtn

    local costLb=GetTTFLabel(tostring(acMjzyVoApi:getSingleCost()),costLbFontSize)
    costLb:setAnchorPoint(ccp(0,0.5))
    costLb:setColor(G_ColorYellowPro)
    costLb:setScale(1/0.8)
    singleBtn:addChild(costLb)
    local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    costSp:setAnchorPoint(ccp(0,0.5))
    costSp:setScale(1/0.8*goldScale)
    singleBtn:addChild(costSp)
    local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
    costLb:setPosition(singleBtn:getContentSize().width/2-lbWidth/2,singleBtn:getContentSize().height+costLb:getContentSize().height/2+10)
    costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())

    local multiBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/4*3,btnY),{getlocal("emblem_getBtnLbHexie",{5}),costLbFontSize},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",getMutiRewardCallback,0.8,-(self.layerNum-1)*20-4)
    multiBtn:setVisible(false)
    self.multiBtn = multiBtn

    local costLb=GetTTFLabel(tostring(acMjzyVoApi:getMultiCost()),costLbFontSize)
    costLb:setAnchorPoint(ccp(0,0.5))
    costLb:setColor(G_ColorYellowPro)
    costLb:setScale(1/0.8)
    multiBtn:addChild(costLb)

    local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    costSp:setAnchorPoint(ccp(0,0.5))
    costSp:setScale(1/0.8*goldScale)
    multiBtn:addChild(costSp)

    local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
	costLb:setPosition(multiBtn:getContentSize().width/2-lbWidth/2,multiBtn:getContentSize().height+costLb:getContentSize().height/2+10)
    costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())

    self:refreshBtn()

   	-- 触摸停止动画
   	local function touchHandler( ... )

   		if self.actionFlag1 == 1 then
   			if self.mapBg then
   				self.mapBg:removeAllChildrenWithCleanup(true)
   				for i=1,5 do
					local mapArea = CCSprite:createWithSpriteFrameName("map_"..i..".png")
					mapArea:setVisible(false)
					mapArea:setPosition(self.pos[i])
					self.mapBg:addChild(mapArea)
					self.mapArea[i] = mapArea		
				end
		       	if self.rewardCallback then
                    self.actionFlag1 = 0
                    self.actionFlag2 = 1
                    self.rewardCallback(self.randomArr)
                    self.touchSp:setPosition(ccp(9999,0))
		       	end
   			end
   		end
   	end
    
    self.touchHandler = touchHandler
	local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler)
	touchSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-160))
	touchSp:setAnchorPoint(ccp(0.5,0))
	touchSp:setPosition(ccp(9999,0))
	touchSp:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(touchSp)
	touchSp:setIsSallow(true)
    touchSp:setVisible(false)
    self.touchSp = touchSp



    local function nilFunc( ... )
        -- body
    end
    local touchSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchSp1:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-160))
    touchSp1:setAnchorPoint(ccp(0.5,0))
    touchSp1:setPosition(ccp(G_VisibleSizeWidth/2,0))
    touchSp1:setTouchPriority(-1)
    self.bgLayer:addChild(touchSp1,4)
    touchSp1:setOpacity(0)
    self.touchSp1 = touchSp1
end

function acMjzyReinforceDialog:runSingleRewardAction(rewardShow)
	
	self.actionFlag1 = 1
	self.touchSp:setPosition(ccp(G_VisibleSizeWidth/2,0))
	local randomArr = acMjzyVoApi:getRandomArr(5)
	self.randomArr = randomArr
	local attackSpOut = CCSprite:createWithSpriteFrameName("attack.png")
	local attackSpIn = CCSprite:createWithSpriteFrameName("attack.png")
	attackSpIn:setScale(24/attackSpOut:getContentSize().width)
	attackSpIn:setPosition(self.attackpos[randomArr[1]])
	attackSpOut:setPosition(self.attackpos[randomArr[1]])
	attackSpOut:setScale(36/attackSpOut:getContentSize().width)
	self.mapBg:addChild(attackSpOut,2)
	self.mapBg:addChild(attackSpIn,2)

	local u,d,l,r = self:getLineLength(randomArr[1])
	for i=1,4 do
		local lineSp = CCSprite:createWithSpriteFrameName("attackLine.png")
		self.mapBg:addChild(lineSp)
		self.lineLength = lineSp:getContentSize().width
		if i == 1 then
			lineSp:setScaleX(u/lineSp:getContentSize().width)
			lineSp:setRotation(-90)
			lineSp:setAnchorPoint(ccp(0,0.5))
			lineSp:setPosition(ccp(self.attackpos[randomArr[1]].x,self.attackpos[randomArr[1]].y+20))
			self.mapLine[1] = lineSp
		elseif i == 2 then
			lineSp:setScaleX(d/lineSp:getContentSize().width)
			lineSp:setRotation(90)
			lineSp:setAnchorPoint(ccp(0,0.5))
			lineSp:setPosition(ccp(self.attackpos[randomArr[1]].x,self.attackpos[randomArr[1]].y-20))
			self.mapLine[2] = lineSp
		elseif i == 3 then
			lineSp:setScaleX(l/lineSp:getContentSize().width)
			lineSp:setAnchorPoint(ccp(1,0.5))
			lineSp:setPosition(ccp(self.attackpos[randomArr[1]].x-20,self.attackpos[randomArr[1]].y))
			self.mapLine[3] = lineSp
		else
			lineSp:setScaleX(r/lineSp:getContentSize().width)
			lineSp:setAnchorPoint(ccp(0,0.5))
			lineSp:setPosition(ccp(self.attackpos[randomArr[1]].x+20,self.attackpos[randomArr[1]].y))
			self.mapLine[4] = lineSp
		end
	end
	self:runRealAction(1,randomArr,attackSpIn,attackSpOut,rewardShow)
end 

function acMjzyReinforceDialog:runRealAction(i,randomArr,attackSpIn,attackSpOut,rewardShow)
	
	self.mapArea[randomArr[i]]:setVisible(true)
	if i < #randomArr then

		local acArrAllIn = CCArray:create()
		local acArrAllOut = CCArray:create()

		local acArrLine1 = CCArray:create()
		local acArrLine2 = CCArray:create()
		local acArrLine3 = CCArray:create()
		local acArrLine4 = CCArray:create()
		
		local delayIn=CCDelayTime:create(0.1)
		local delayOut=CCDelayTime:create(0.1)

		local delay1=CCDelayTime:create(0.1)
		local delay2=CCDelayTime:create(0.1)
		local delay3=CCDelayTime:create(0.1)
		local delay4=CCDelayTime:create(0.1)

		local moveTo1 = CCMoveTo:create(0.5,ccp(self.attackpos[randomArr[i+1]].x,self.attackpos[randomArr[i+1]].y+20))
		local moveTo2 = CCMoveTo:create(0.5,ccp(self.attackpos[randomArr[i+1]].x,self.attackpos[randomArr[i+1]].y-20))
		local moveTo3 = CCMoveTo:create(0.5,ccp(self.attackpos[randomArr[i+1]].x-20,self.attackpos[randomArr[i+1]].y))
		local moveTo4 = CCMoveTo:create(0.5,ccp(self.attackpos[randomArr[i+1]].x+20,self.attackpos[randomArr[i+1]].y))

		local u,d,l,r = self:getLineLength(randomArr[i+1])
		local scaleTo1 = CCScaleTo:create(0.5,u/self.lineLength,1)
		local scaleTo2 = CCScaleTo:create(0.5,d/self.lineLength,1)
		local scaleTo3 = CCScaleTo:create(0.5,l/self.lineLength,1)
		local scaleTo4 = CCScaleTo:create(0.5,r/self.lineLength,1)

		local acArrLineSp1 = CCArray:create()
		local acArrLineSp2 = CCArray:create()
		local acArrLineSp3 = CCArray:create()
		local acArrLineSp4 = CCArray:create()

		acArrLineSp1:addObject(moveTo1)
		acArrLineSp2:addObject(moveTo2)
		acArrLineSp3:addObject(moveTo3)
		acArrLineSp4:addObject(moveTo4)
		acArrLineSp1:addObject(scaleTo1)
		acArrLineSp2:addObject(scaleTo2)
		acArrLineSp3:addObject(scaleTo3)
		acArrLineSp4:addObject(scaleTo4)

		local spawn1 = CCSpawn:create(acArrLineSp1)
		local spawn2 = CCSpawn:create(acArrLineSp2)
		local spawn3 = CCSpawn:create(acArrLineSp3)
		local spawn4 = CCSpawn:create(acArrLineSp4)

	 	acArrLine1:addObject(delay1)
	 	acArrLine2:addObject(delay2)
	 	acArrLine3:addObject(delay3)
	 	acArrLine4:addObject(delay4)

	 	acArrLine1:addObject(spawn1)
	 	acArrLine2:addObject(spawn2)
	 	acArrLine3:addObject(spawn3)
	 	acArrLine4:addObject(spawn4)

		local seqLine1 = CCSequence:create(acArrLine1)
		local seqLine2 = CCSequence:create(acArrLine2)
		local seqLine3 = CCSequence:create(acArrLine3)
		local seqLine4 = CCSequence:create(acArrLine4)

		self.mapLine[1]:runAction(seqLine1)
		self.mapLine[2]:runAction(seqLine2)
		self.mapLine[3]:runAction(seqLine3)
		self.mapLine[4]:runAction(seqLine4)

		local function callback1( ... )
		end

		local function callback2( ... )
			self.mapArea[randomArr[i]]:setVisible(false)
		end

		local callFunc1 = CCCallFunc:create(callback1)
		local callFunc2 = CCCallFunc:create(callback2)

		local acArrIn = CCArray:create()
		local acArrOut = CCArray:create()

		-- 瞄准图标旋转
		local rotateCW=CCRotateBy:create(0.5,720)
		local rotateCCW=CCRotateBy:create(0.5,-720)

		-- 瞄准图标移动
		local moveToIn=CCMoveTo:create(0.5,self.attackpos[randomArr[i+1]])
		local moveToOut=CCMoveTo:create(0.5,self.attackpos[randomArr[i+1]])

		-- 边转边动
		acArrIn:addObject(rotateCW)
		acArrIn:addObject(moveToIn)
		acArrOut:addObject(rotateCCW)
		acArrOut:addObject(moveToOut)

		local spawnIn = CCSpawn:create(acArrIn)
		local spawnOut = CCSpawn:create(acArrOut)

		acArrAllIn:addObject(delayIn)
		acArrAllIn:addObject(callFunc1)
		acArrAllIn:addObject(spawnIn)
		acArrAllOut:addObject(delayOut)
		acArrAllOut:addObject(callFunc2)
		acArrAllOut:addObject(spawnOut)

		local seq1 = CCSequence:create(acArrAllIn)
		local seq2 = CCSequence:create(acArrAllOut)

		local function callFuncIn( ... )

		end
		local function callBackOut( ... )
			i = i+1
			self:runRealAction(i,randomArr,attackSpIn,attackSpOut,rewardShow)
		end 

		local callFuncIn = CCCallFunc:create(callFuncIn)
		local callFuncOut = CCCallFunc:create(callBackOut)
		local seqOut = CCSequence:createWithTwoActions(seq2,callFuncOut)
		local seqIn = CCSequence:createWithTwoActions(seq1,callFuncIn)
		attackSpIn:runAction(seqIn)
		attackSpOut:runAction(seqOut)

	else
		local blinkIn = CCBlink:create(1,2)
		local blinkOut = CCBlink:create(1,2)
		local function callBackOut( ... )
			self.mapArea[randomArr[i]]:setVisible(false)
			if rewardShow then
                self.actionFlag1 = 0
				self.touchSp:setPosition(ccp(9999,0))
				rewardShow(randomArr)
			end
			attackSpIn:removeFromParentAndCleanup(true)
			attackSpIn = nil
			attackSpOut:removeFromParentAndCleanup(true)
			attackSpOut = nil
			for k,v in pairs(self.mapLine) do
				if v then
					v:removeFromParentAndCleanup(true)
					v = nil
				end
			end
            -- 控制第一套动画的
		end 
		local function callBackIn( ... )

		end
		local callFuncIn = CCCallFunc:create(callBackIn)
		local callFuncOut = CCCallFunc:create(callBackOut)
		local seqIn = CCSequence:createWithTwoActions(blinkIn,callFuncIn)		
		local seqOut = CCSequence:createWithTwoActions(blinkOut,callFuncOut)
		attackSpIn:runAction(seqIn)
		attackSpOut:runAction(seqOut)
	end

end


function acMjzyReinforceDialog:runRealMultiAction(i,randomArr,rewardShow)

    local attackSpOut = CCSprite:createWithSpriteFrameName("attack.png")
    local attackSpIn = CCSprite:createWithSpriteFrameName("attack.png")
    attackSpIn:setScale(24/attackSpOut:getContentSize().width)
    attackSpIn:setPosition(attackSpOut:getContentSize().width/2,attackSpOut:getContentSize().height/2)
    attackSpOut:setPosition(self.attackpos[randomArr[i]])
    attackSpOut:setScale(36/attackSpOut:getContentSize().width)
    self.mapBg:addChild(attackSpOut,2)
    attackSpOut:addChild(attackSpIn)

	local u,d,l,r = self:getLineLength(randomArr[i])

	for index=1,4 do
		local lineSp = CCSprite:createWithSpriteFrameName("attackLine.png")
		self.mapBg:addChild(lineSp)
		if index == 1 then
            lineSp:setAnchorPoint(ccp(0,0.5))
			lineSp:setScaleX(u/lineSp:getContentSize().width)
			lineSp:setRotation(-90)
			lineSp:setPosition(ccp(self.attackpos[randomArr[i]].x,self.attackpos[randomArr[i]].y+20))
		elseif index == 2 then
			lineSp:setScaleX(d/lineSp:getContentSize().width)
			lineSp:setRotation(90)
			lineSp:setAnchorPoint(ccp(0,0.5))
			lineSp:setPosition(ccp(self.attackpos[randomArr[i]].x,self.attackpos[randomArr[i]].y-20))
		elseif index == 3 then
			lineSp:setScaleX(l/lineSp:getContentSize().width)
			lineSp:setAnchorPoint(ccp(1,0.5))
			lineSp:setPosition(ccp(self.attackpos[randomArr[i]].x-20,self.attackpos[randomArr[i]].y))
		else
			lineSp:setScaleX(r/lineSp:getContentSize().width)
			lineSp:setAnchorPoint(ccp(0,0.5))
			lineSp:setPosition(ccp(self.attackpos[randomArr[i]].x+20,self.attackpos[randomArr[i]].y))
		end
	end
	
    self.mapArea[randomArr[i]]:setVisible(true)
    local blink = CCBlink:create(0.5, 1)
    local function callBack( ... )
        self.mapArea[randomArr[i]]:setVisible(false)
        self:initMapBg()
        if i< #randomArr then
            self:runRealMultiAction(i+1,randomArr,rewardShow)
        else
            for k=1,#randomArr do
                local attackSpOut = CCSprite:createWithSpriteFrameName("attack.png")
                local attackSpIn = CCSprite:createWithSpriteFrameName("attack.png")
                attackSpIn:setScale(24/attackSpOut:getContentSize().width)
                attackSpIn:setPosition(attackSpOut:getContentSize().width/2,attackSpOut:getContentSize().height/2)
                attackSpOut:setPosition(self.attackpos[randomArr[k]])
                attackSpOut:setScale(36/attackSpOut:getContentSize().width)
                self.mapBg:addChild(attackSpOut,2)
                attackSpOut:addChild(attackSpIn)
                self.mapArea[randomArr[k]]:setVisible(true)
                local blink = CCBlink:create(1,2)
                local function callBack( ... )
                    self.mapArea[randomArr[k]]:setVisible(false)
                    if attackSpOut then
                        attackSpOut:removeFromParentAndCleanup(true)
                        attackSpOut = nil
                    end
                    if k == #randomArr and rewardShow then
                        self.actionFlag1 = 0
                        self.touchSp:setPosition(ccp(9999,0))
                        rewardShow(randomArr)
                    end
                end
                local callFunc = CCCallFunc:create(callBack)
                local seq = CCSequence:createWithTwoActions(blink,callFunc) 
                attackSpOut:runAction(seq)          
            end
        end
    end
    local callFunc = CCCallFunc:create(callBack)
    local seq = CCSequence:createWithTwoActions(blink,callFunc) 
    attackSpOut:runAction(seq)  
end

function acMjzyReinforceDialog:runMutliRewardAction(areaNum,rewardShow)

	self.actionFlag1 = 1
	self.touchSp:setPosition(ccp(G_VisibleSizeWidth/2,0))
	local randomArr,repeatArr = acMjzyVoApi:getRandomArr(areaNum)
	self.randomArr = randomArr
    self.repeatArr = repeatArr
    self:runRealMultiAction(1,randomArr,rewardShow)
end

function acMjzyReinforceDialog:getLineLength(id)
	local u,d,l,y 
	local pos = self.attackpos[id]
	u = 396 - pos.y - 20
	d = pos.y - 20
	l = pos.x - 20
	r = 640 - pos.x -20
	return u,d,l,r
end

function acMjzyReinforceDialog:cleanRewardTb( ... )
    if self.touchSp1 then
        self.touchSp1:removeAllChildrenWithCleanup(true)
        self.actionFlag2 = 0
    end
end

function acMjzyReinforceDialog:tick( ... )
	self.timeLb:setString(acMjzyVoApi:getAcTimeStr())
	if acMjzyVoApi:isToday() == false then
		self:refreshBtn()
	end
end

function acMjzyReinforceDialog:refreshRateSprite( ... )
	if acMjzyVoApi:getRewardNum() < acMjzyVoApi:getUpRateCostNum() then
		tolua.cast(self.rateSp:getChildByTag(1016),"CCSprite"):setVisible(true)
		tolua.cast(self.rateSp:getChildByTag(1017),"CCSprite"):setVisible(false)
		tolua.cast(self.rateSp:getChildByTag(1018),"CCSprite"):setVisible(false)
		if self.heroIcon then
			self.heroIcon:removeFromParentAndCleanup(true)
			self.heroIcon = nil
		end
		local reinForceLb = tolua.cast(self.rateSp:getChildByTag(1019),"CCLabelTTF")
		reinForceLb:setString(acMjzyVoApi:getRewardNum())
		reinForceLb:setVisible(true)
        tolua.cast(self.rateSp:getChildByTag(1020),"CCLabelTTF"):setVisible(true)
        tolua.cast(self.rateSp:getChildByTag(1021),"CCLabelBMFont"):setVisible(false)
		tolua.cast(self.rateSp:getChildByTag(1022),"CCLabelBMFont"):setVisible(false)
        tolua.cast(self.rateSp:getChildByTag(1023),"LuaCCSprite"):setVisible(false)
	else
        if acMjzyVoApi:getHeroReward() then
            tolua.cast(self.rateSp:getChildByTag(1023),"LuaCCSprite"):setVisible(false)
        else
            tolua.cast(self.rateSp:getChildByTag(1023),"LuaCCSprite"):setVisible(true)
        end
		if acMjzyVoApi:getHeroSet() ~= "" then
			
            if self.heroIcon then
                self.heroIcon:removeFromParentAndCleanup(true)
                self.heroIcon = nil
            end
            local function touchHeroIcon( ... )
            end
            local key = "h"..RemoveFirstChar(acMjzyVoApi:getHeroSet())
            local heroIcon = heroVoApi:getHeroIconOnly(key)
            heroIcon:setAnchorPoint(ccp(0.5,0))
            heroIcon:setPosition(ccp(40,2))
            heroIcon:setScaleX(80/heroIcon:getContentSize().width)
            heroIcon:setScaleY(75/heroIcon:getContentSize().height)
            self.heroIcon = heroIcon
            self.rateSp:addChild(heroIcon)
            tolua.cast(self.rateSp:getChildByTag(1016),"CCSprite"):setVisible(false)
            tolua.cast(self.rateSp:getChildByTag(1017),"CCSprite"):setVisible(true)
            tolua.cast(self.rateSp:getChildByTag(1018),"CCSprite"):setVisible(false)
            tolua.cast(self.rateSp:getChildByTag(1019),"CCLabelTTF"):setVisible(false)
            tolua.cast(self.rateSp:getChildByTag(1020),"CCLabelTTF"):setVisible(false)
            tolua.cast(self.rateSp:getChildByTag(1021),"CCLabelBMFont"):setVisible(true)
            tolua.cast(self.rateSp:getChildByTag(1022),"CCLabelBMFont"):setVisible(true)
        else
            tolua.cast(self.rateSp:getChildByTag(1016),"CCSprite"):setVisible(true)
            tolua.cast(self.rateSp:getChildByTag(1017),"CCSprite"):setVisible(false)
            if self.heroIcon then
                self.heroIcon:removeFromParentAndCleanup(true)
                self.heroIcon = nil
            end
            local addSp = tolua.cast(self.rateSp:getChildByTag(1018),"CCSprite")
            addSp:setVisible(true)
            tolua.cast(self.rateSp:getChildByTag(1019),"CCLabelTTF"):setVisible(false)
            tolua.cast(self.rateSp:getChildByTag(1021),"CCLabelBMFont"):setVisible(false)
            tolua.cast(self.rateSp:getChildByTag(1022),"CCLabelBMFont"):setVisible(false)
            tolua.cast(self.rateSp:getChildByTag(1020),"CCLabelTTF"):setVisible(false)

            local fadeTo = CCFadeTo:create(1, 55)
            local fadeBack = CCFadeTo:create(1, 255)
            local acArr = CCArray:create()
            acArr:addObject(fadeTo)
            acArr:addObject(fadeBack)
            local seq = CCSequence:create(acArr)
            addSp:runAction(CCRepeatForever:create(seq))
		end

	end
end


function acMjzyReinforceDialog:initMapBg(  )

    if self.mapBg then
        self.mapBg:removeAllChildrenWithCleanup(true)
    end

    for i=1,5 do
        local mapArea = CCSprite:createWithSpriteFrameName("map_"..i..".png")
        mapArea:setVisible(false)
        mapArea:setPosition(self.pos[i])
        self.mapBg:addChild(mapArea)
        self.mapArea[i] = mapArea       
    end

end

function acMjzyReinforceDialog:refreshBtn( ... )
	local isNotEnd=activityVoApi:isStart(acMjzyVoApi:getAcVo())
	if isNotEnd then
		if acMjzyVoApi:getFirstFree() == 0 then
			self.freeBtn:setVisible(true)
			self.singleBtn:setVisible(false)
			self.multiBtn:setVisible(true)
			self.multiBtn:setEnabled(false)
		else
			self.freeBtn:setVisible(false)
			self.singleBtn:setVisible(true)
			self.multiBtn:setVisible(true)
			self.multiBtn:setEnabled(true)
		end
	else
		self.freeBtn:setEnabled(false)
		self.singleBtn:setEnabled(false)
		self.multiBtn:setEnabled(false)
	end
end


function acMjzyReinforceDialog:dispose( ... )
end
