shamBattleDialog = commonDialog:new()

function shamBattleDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.normalHeight=107
    self.itemTb={}
    return nc
end

function shamBattleDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 270))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36-190/2))
end

function shamBattleDialog:initTableView()
	self.attacklist=arenaVoApi:getAttacklist()

	local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function () do return end end)
    backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-100-200-100-80-5))
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setPosition(self.bgLayer:getContentSize().width/2,105)
    self.bgLayer:addChild(backSprie2)




	local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-100-200-100-80-15),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,110))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

    self:judgeCd()
end

function shamBattleDialog:doUserHandler()
	local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),function () do return end end)
	backSprie1:setContentSize(CCSizeMake(600,170))
	backSprie1:setAnchorPoint(ccp(0.5,1))
	backSprie1:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-90)
	self.bgLayer:addChild(backSprie1)


	local personPhotoName=playerVoApi:getPersonPhotoName(playerVoApi:getPic())
	local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName);
	photoSp:setScale(120/photoSp:getContentSize().width)
	photoSp:setAnchorPoint(ccp(0,0.5))
	photoSp:setPosition(ccp(15,backSprie1:getContentSize().height/2))
	backSprie1:addChild(photoSp,2)

	-- 连胜
	local lianshengLb = GetTTFLabelWrap(getlocal("arena_straightTimes",{arenaVoApi:getArenaVo().victory}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	backSprie1:addChild(lianshengLb)
	lianshengLb:setAnchorPoint(ccp(0,0.5))
	lianshengLb:setPosition(150, backSprie1:getContentSize().height/4*3)
	self.lianshengLb=lianshengLb

	-- 排名
	local rankLb = GetTTFLabelWrap(getlocal("shanBattle_rank",{arenaVoApi:getRanking()}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	backSprie1:addChild(rankLb)
	rankLb:setAnchorPoint(ccp(0,0.5))
	rankLb:setPosition(150, backSprie1:getContentSize().height/4*2)
	self.rankLb=rankLb

	-- 战斗力
	local powerLb = GetTTFLabelWrap(getlocal("world_war_power",{FormatNumber(playerVoApi:getPlayerPower())}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	backSprie1:addChild(powerLb)
	powerLb:setAnchorPoint(ccp(0,0.5))
	powerLb:setPosition(150, backSprie1:getContentSize().height/4)
	self.powerLb=powerLb

	-- 战报
	local function touchBattleReport()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		arenaVoApi:showShamBattleReportDialog(self.layerNum+1)
	end
	local battleReportItem=GetButtonItem("mainBtnMail.png","mainBtnMail_Down.png","mainBtnMail_Down.png",touchBattleReport,1,nil,0)
	battleReportItem:setAnchorPoint(ccp(1,0.5))
	-- battleReportItem:setScale(0.8)
	local battleReportMenu=CCMenu:createWithItem(battleReportItem)
	battleReportMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	battleReportMenu:setPosition(ccp(backSprie1:getContentSize().width-15, backSprie1:getContentSize().height/2))
	backSprie1:addChild(battleReportMenu,2)

	local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
	tipSp:setAnchorPoint(ccp(0,1))
	tipSp:setPosition(0, battleReportItem:getContentSize().height)
	battleReportItem:addChild(tipSp)
	self.tipSp=tipSp

	



	-- 1部队 2商店 3排名 4奖励 5帮助
	local functionTb={}
	local function callback1(tag)
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end

		if tag==1 then
			arenaVoApi:showShamBattleFleetDialog(self.layerNum+1)
		elseif tag==2 then
			arenaVoApi:showShamBattleShopDialog(self.layerNum+1)
		elseif tag==3 then
			arenaVoApi:showShamBattleRankDialog(self.layerNum+1)
		elseif tag==4 then
			arenaVoApi:showShamBattleRewardDialog(self.layerNum+1)
		else
		end

	end

	local fleetTb = {bName1="mainBtnTeam.png",bName2="mainBtnTeam_Down.png",btnLb="mainFleet",callback=callback1,tag=1}
	local shopTb = {bName1="mainBtnItems.png",bName2="mainBtnItems_Down.png",btnLb="market",callback=callback1,tag=2}
	local rankTb = {bName1="mainBtnRank.png",bName2="mainBtnRank_Down.png",btnLb="mainRank",callback=callback1,tag=3}
	local rewardTb = {bName1="mainBtnGift.png",bName2="mainBtnGiftDown.png",btnLb="award",callback=callback1,tag=4}
	local helpTb = {bName1="mainBtnHelp.png",bName2="mainBtnHelp_Down.png",btnLb="help",callback=callback1,tag=5}
	table.insert(functionTb,fleetTb)
	table.insert(functionTb,shopTb)
	table.insert(functionTb,rankTb)
	table.insert(functionTb,rewardTb)
	-- table.insert(functionTb,helpTb)

	-- print("SizeOfTable(functionTb)",SizeOfTable(functionTb))
	for i=1,SizeOfTable(functionTb) do
		local tb = functionTb[i]
		local menuItem = GetButtonItem(tb.bName1,tb.bName2,tb.bName2,tb.callback,tb.tag,nil,0)
		local menu=CCMenu:createWithItem(menuItem)
		menu:setTouchPriority(-(self.layerNum-1)*20-5)
		menu:setPosition(ccp(100+(i-1)*110, self.bgLayer:getContentSize().height-320))
		self.bgLayer:addChild(menu,2)

		local nameLb = GetTTFLabel(getlocal(tb.btnLb),22)
		nameLb:setPosition(ccp(menuItem:getContentSize().width/2,0))
        -- nameLb:setColor(G_ColorGreen)
        menuItem:addChild(nameLb,6)

		if i==4 then
			local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
			tipSp:setAnchorPoint(ccp(0,1))
			tipSp:setPosition(0, menuItem:getContentSize().height)
			menuItem:addChild(tipSp)
			self.RewardTip = tipSp
		end
	end

	self:refreshTip()

	-- 挑战次数
	local challengeLb = GetTTFLabel(getlocal("super_weapon_challenge_num"),25)
	self.bgLayer:addChild(challengeLb)
	challengeLb:setAnchorPoint(ccp(0,0.5))
	challengeLb:setPosition(30, 70)

	local numStr = arenaVoApi:getAttack_count() .. "/" .. arenaVoApi:getAttack_num()
	local numLb=GetTTFLabel(numStr,25)
    numLb:setAnchorPoint(ccp(0,0.5))
    numLb:setPosition(ccp(challengeLb:getContentSize().width+30,70))
    -- numLb:setColor(G_ColorRed)
    self.bgLayer:addChild(numLb)
    self.numLb=numLb

    self:refreshNumLb()

    local function addnum()
    	if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end

		local gold = arenaVoApi:goldForAnotherBatch()
		local cost=playerVoApi:getGems()-gold
        if cost<0 then
            local function jumpGemDlg()
                vipVoApi:showRechargeDialog(self.layerNum+1)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),jumpGemDlg,getlocal("dialog_title_prompt"),getlocal("alliance_createAllianceNoGem"),nil,self.layerNum+1)
            return
        end

        local function callback()
            local function anotherBatch(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    self:refresh()
                end
            end
            socketHelper:shamBattleRefreshAttaklist(anotherBatch)
        end
		

        if gold==0 then
            callback()
        else
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callback,getlocal("dialog_title_prompt"),getlocal("shanBattle_anotherBatch_tip",{gold}),nil,self.layerNum+1)
        end

    end
    -- 换一批
    local addItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",addnum,nil,getlocal("shanBattle_anotherBatch"),24/0.8,101)
    addItem:setScale(0.8)
    local btnLb = addItem:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local addMenu=CCMenu:createWithItem(addItem);
    addMenu:setPosition(ccp(540,60))
    addMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    self.bgLayer:addChild(addMenu)
    self.addMenu=addMenu


    local cdSize =0
    local cdPos =0
    local textSize = 25
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" then
        cdSize= 5
        cdPos =30
    end
    self.cdLb = GetTTFLabel(getlocal("shanBattle_acCD"),textSize-cdSize);
    self.cdLb:setAnchorPoint(ccp(0,0.5));
    self.cdLb:setPosition(ccp(30,40));
    self.bgLayer:addChild(self.cdLb,2);

    local cdTime=arenaVoApi:getCDTime()
    local timestr=G_getTimeStr(cdTime,1)
    self.cdTimeLb = GetTTFLabel(timestr,textSize);
    self.cdTimeLb:setAnchorPoint(ccp(0,0.5));
    self.cdTimeLb:setPosition(ccp(self.cdLb:getContentSize().width+35,40));
    self.bgLayer:addChild(self.cdTimeLb,2)

    local function accelerate()
        local function accelerateNum()
            local cdTime=arenaVoApi:getCDTime()
            local costGold=arenaCfg.getGoldByTime(cdTime)
            local function accelerateCallback(fn,data)
                if base:checkServerData(data)==true then
                    local gem=playerVoApi:getGems()-costGold
                    playerVoApi:setGems(gem)
                end
            end

            socketHelper:militaryBuy(1,accelerateCallback)
        end
        local cdTime=arenaVoApi:getCDTime()
        local costGold=arenaCfg.getGoldByTime(cdTime)

        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),accelerateNum,getlocal("dialog_title_prompt"),getlocal("arena_buyAccelerate",{costGold}),nil,self.layerNum+1)
        
    end
    local accelerateItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",accelerate,nil,getlocal("accelerateBuild"),25)
    self.accelerateMenu=CCMenu:createWithItem(accelerateItem);
    self.accelerateMenu:setPosition(ccp(540,60))
    self.accelerateMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    self.bgLayer:addChild(self.accelerateMenu)

    self:judgeCd()

end

function shamBattleDialog:refreshNumLb()
	if self.numLb then
		local numStr = arenaVoApi:getAttack_count() .. "/" .. arenaVoApi:getAttack_num()
	    self.numLb:setString(numStr)
	    if arenaVoApi:getAttack_count()==arenaVoApi:getAttack_num() then
	    	self.numLb:setColor(G_ColorRed)
	    else
	    	self.numLb:setColor(G_ColorWhite)
	    end

	end
end

function shamBattleDialog:refreshUserInfo()
	if self.lianshengLb then
		self.lianshengLb:setString(getlocal("arena_straightTimes",{arenaVoApi:getArenaVo().victory}))
	end

	if self.rankLb then
		self.rankLb:setString(getlocal("shanBattle_rank",{arenaVoApi:getRanking()}))
	end

	if self.powerLb then
		self.powerLb:setString(getlocal("world_war_power",{FormatNumber(playerVoApi:getPlayerPower())}))
	end
end

function shamBattleDialog:buyChangeNum()
	-- print("++++++++++",bagVoApi:getItemNumId(292)>0)
	if bagVoApi:getItemNumId(292)>0 then

        local function buyNum()
            local function callback(fn,data)
                if base:checkServerData(data)==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arena_propSuccess"),30)
                    bagVoApi:useItemNumId(292,1)
                    self:refreshNumLb()
                end
            end

            socketHelper:militaryBuy(2,callback)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyNum,getlocal("dialog_title_prompt"),getlocal("arena_buyFightNumByP292"),nil,self.layerNum+1)
    else
    	-- 首先判断是否可以购买
    	if arenaVoApi:isCanBuyChallengeTimes()==false then
    		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage10005"),nil,self.layerNum+1,nil)
    		return
    	end

    	-- 购买次数
    	local needCost = arenaVoApi:needGoldForchallenge()
        local gem=playerVoApi:getGems()-needCost
        if gem<0 then
            local function jumpGemDlg()
                vipVoApi:showRechargeDialog(self.layerNum+1)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),jumpGemDlg,getlocal("dialog_title_prompt"),getlocal("alliance_createAllianceNoGem"),nil,self.layerNum+1)

            do
                return
            end

        end

        local function buyNum()
            local function callback(fn,data)
                if base:checkServerData(data)==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arena_buyFightNumSuccess"),30)
                    local gem=playerVoApi:getGems()-needCost
                    playerVoApi:setGems(gem)
                    self:refreshNumLb()
                end
            end

            socketHelper:militaryBuy(2,callback)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyNum,getlocal("dialog_title_prompt"),getlocal("shanBattle_buyFightNum",{needCost,arenaCfg.buyNum}),nil,self.layerNum+1)
    end
end

function shamBattleDialog:judgeCd()
    if arenaVoApi:getCDTime()<=0 then
        self.cdLb:setVisible(false)
        self.cdTimeLb:setVisible(false)
        self.accelerateMenu:setVisible(false)
        self.addMenu:setVisible(true)

        for k,v in pairs(self.itemTb) do
            
                v=tolua.cast(v,"CCMenuItem")
            if v then
                v:setEnabled(true)
            end
        end

    elseif arenaVoApi:getCDTime()>0 then
        self.cdLb:setVisible(true)
        self.cdTimeLb:setVisible(true)
        self.accelerateMenu:setVisible(true)
        local cdTime=arenaVoApi:getCDTime()
        local timestr=G_getTimeStr(cdTime,1)
        self.cdTimeLb:setString(timestr)
        self.addMenu:setVisible(false)
        for k,v in pairs(self.itemTb) do
            
                v=tolua.cast(v,"CCMenuItem")
            if v then                
                v:setEnabled(false)
            end
        end
        

    end
end


function shamBattleDialog:eventHandler(handler,fn,idx,cel)
	 if fn=="numberOfCellsInTableView" then	 	
        return SizeOfTable(self.attacklist)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.normalHeight)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease() 

        
        local function touch()
		end
		local capInSet = CCRect(20, 20, 10, 10)
		local backsprite =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
		backsprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.normalHeight-5))
		backsprite:setAnchorPoint(ccp(0,0))
		backsprite:setPosition(ccp(0,5))
		cell:addChild(backsprite,1)
		backsprite:setOpacity(0)

		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp:setAnchorPoint(ccp(0,0));
        lineSp:setPosition(ccp(0,-5));
        cell:addChild(lineSp,1)

        local pic = self.attacklist[idx+1][6] or 1
		local personPhotoName=playerVoApi:getPersonPhotoName(pic)
		local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName);
		photoSp:setScale(90/photoSp:getContentSize().width)
		photoSp:setAnchorPoint(ccp(0,0.5))
		photoSp:setPosition(ccp(15,backsprite:getContentSize().height/2))
		backsprite:addChild(photoSp,2)

		local nameStr = self.attacklist[idx+1][3]
        if self.attacklist[idx+1][2]<=450 then
            nameStr=arenaVoApi:getNpcNameById(self.attacklist[idx+1][2])
        end
		local playerNameLb = GetTTFLabelWrap(nameStr,20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		backsprite:addChild(playerNameLb)
		playerNameLb:setAnchorPoint(ccp(0,0.5))
		playerNameLb:setPosition(140, backsprite:getContentSize().height/4*3-10)

		local rankLb = GetTTFLabelWrap(getlocal("shanBattle_rank",{self.attacklist[idx+1][1]}),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		backsprite:addChild(rankLb)
		rankLb:setAnchorPoint(ccp(0,0.5))
		rankLb:setPosition(140, backsprite:getContentSize().height/4+10)

		local function anemyInfo()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
			    
			    if self.attacklist[idx+1][2]<1000000 then
			    	arenaVoApi:showEnemyInfoSmallDialog(self.layerNum+1,self.attacklist[idx+1])
			    else
			    	local function getInfo(fn,data)
			    		local ret,sData=base:checkServerData(data)
			    		if ret==true then
			    			arenaVoApi:showEnemyInfoSmallDialog(self.layerNum+1,self.attacklist[idx+1],sData.data)
			    		end
			    	end
			    	
			    	socketHelper:shamBattleGetFleetInfo(self.attacklist[idx+1][2],getInfo)
			    end
			end

		end
		local infoItem = GetButtonItem("mainBtnTask.png","mainBtnTask_Down.png","mainBtnTask_Down.png",anemyInfo,11,nil,nil)
        
       
        local infoMenu = CCMenu:createWithItem(infoItem);
        infoMenu:setPosition(ccp(480,backsprite:getContentSize().height/2));
        infoMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        infoItem:setScale(0.9)
        backsprite:addChild(infoMenu,2);

		local function fight()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end

			     if arenaVoApi:getArenaVo().attack_num-arenaVoApi:getArenaVo().attack_count<=0 then
			     	self:buyChangeNum()
			     	return
			     end

			    if self:judgeTroops()==false then
	                do
	                    return
	                end
	            end

               if arenaVoApi:isCanBattle() then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage10011"),30)
                    return
                end


	            local function callback(fn,data)
	                local cresult,retTb=base:checkServerData(data)
	                if cresult==true then
	                    if retTb.data.reward~=nil then
	                        local award=FormatItem(retTb.data.reward) or {}
	                        for k,v in pairs(award) do
	                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
	                        end
	                    end
	                    local reporttb=retTb.data.report
	                    if retTb.data~=nil and reporttb~=nil and SizeOfTable(reporttb)>0 then
	                        local dateTb={}
	                        local dateTb1={}
	                        dateTb.data=dateTb1
	                        dateTb.data.report=reporttb
	                        dateTb.isFuben=true
                            dateTb.battleType=5
	                        battleScene:initData(dateTb)
	                        if dateTb.data.report.w~=nil and dateTb.data.report.w==1 then
	                            local tarvictory = retTb.data.tarvictory
	                            if tarvictory>=10 then

	                                local message={key="arena_fightNumDesc8",param={dateTb.data.report.p[2][1],dateTb.data.report.p[1][1],tarvictory}}
	                                chatVoApi:sendSystemMessage(message)   
	                            end
	                        end
	                    else
	                        local name=self.attacklist[idx+1][3]
	                        local function onSure()
	                            eventDispatcher:dispatchEvent("battle.close",{win=true})
	                        end
	                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("arena_fightSurprise",{name}),nil,self.layerNum+1,nil,onSure)
	          
	                    end
	                    
	                    local function getcallback(fn,data)
	                        if base:checkServerData(data)==true then
	                            if self.attacklist[idx+1][1]==1 and arenaVoApi:getArenaVo().ranking==1 then
	                                local name=self.attacklist[idx+1][3]
	                                if tonumber(name)~=nil then
	                                    name=arenaVoApi:getNpcNameById(tonumber(name))
	                                end
	                                local message={key="arena_fightNumDesc7",param={playerVoApi:getPlayerName(),name}}
	                                chatVoApi:sendSystemMessage(message)
	                            end
	                            self:refresh()
	                            for k,v in pairs(arenaCfg.noticeStreak) do
	                                if arenaVoApi:getArenaVo().victory>arenaCfg.noticeStreak[4] then
	                                    local num=arenaVoApi:getArenaVo().victory
	                                    if num%100==0 then
	                                        local message={key="arena_fightNumDesc6",param={playerVoApi:getPlayerName(),arenaVoApi:getArenaVo().victory}}
	                                        chatVoApi:sendSystemMessage(message)
	                                        break
	                                    end
	                                else
	                                    if arenaVoApi:getArenaVo().victory==v then
	                                        local keyFight="arena_fightNumDesc"..k
	                                        local message={key=keyFight,param={playerVoApi:getPlayerName(),arenaVoApi:getArenaVo().victory}}
	                                        chatVoApi:sendSystemMessage(message)
	                                        break
	                                    end
	                                end
	                            end
	                            
	                        end
	                    end
	                    socketHelper:militaryGet(getcallback)
	                end
	            end
	            socketHelper:militaryBattle(self.attacklist[idx+1][1],callback)

			end
		end
		local fightItem = GetButtonItem("yh_IconAttackBtn.png","yh_IconAttackBtn_Down.png","yh_IconAttackBtn.png",fight,11,nil,nil)
        
        if tonumber(self.attacklist[idx+1][2])==tonumber(playerVoApi:getUid()) then
            fightItem:setEnabled(false)
            fightItem:setVisible(false)

            infoItem:setEnabled(false)
            infoItem:setVisible(false)
        else
            self.itemTb[idx+1]=fightItem
        end
        local fightMenu = CCMenu:createWithItem(fightItem);
        fightMenu:setPosition(ccp(550,backsprite:getContentSize().height/2));
        fightMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        fightItem:setScale(0.9)
        backsprite:addChild(fightMenu,2);

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function shamBattleDialog:judgeTroops()
    local isEableAttack=true
    local num=0;
    for k,v in pairs(tankVoApi:getTanksTbByType(5)) do
        if SizeOfTable(v)==0 then
            num=num+1;
        end
    end
    if num==6 then
        isEableAttack=false
    end
    if isEableAttack==false then

        local function setTroops()
            arenaVoApi:showShamBattleFleetDialog(self.layerNum+1)
        end 
        
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),setTroops,getlocal("dialog_title_prompt"),getlocal("backstage10001"),nil,self.layerNum+1)
    end


    return isEableAttack
end

function shamBattleDialog:refreshTip()
	if self.RewardTip then
		if arenaVoApi:isHaveScoreReward() then
			self.RewardTip:setVisible(true)
		else
			self.RewardTip:setVisible(false)
		end
	end
	
	if self.tipSp then
		local unreadNum=arenaReportVoApi:getUnreadNum() or 0
		if unreadNum>0 then
			self.tipSp:setVisible(true)
		else
			self.tipSp:setVisible(false)
		end
	end
	
end

function shamBattleDialog:refresh()

	self.attacklist=arenaVoApi:getAttacklist()
	self.itemTb={}

    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)

	self:refreshNumLb()
	self:refreshUserInfo()
	self:refreshTip()
end

function shamBattleDialog:tick()
	local isToday = arenaVoApi:isToday()
    if isToday==false and self.tv then
        local function reCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                self:refresh()
            end
        end
        socketHelper:militaryGet(reCallback)
    end

	self:refreshTip()
	self:judgeCd()
end


function shamBattleDialog:dispose()
	self.numLb=nil
	self.tipSp=nil
	self.itemTb={}
	self.lianshengLb=nil
	self.rankLb=nil
	self.powerLb=nil
end