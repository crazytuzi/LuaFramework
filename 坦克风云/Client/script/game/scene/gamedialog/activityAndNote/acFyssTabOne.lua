acFyssTabOne={}

function acFyssTabOne:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=nil
    self.bgLayer=nil
    self.exchangeData=nil
    self.gemNumLabel=nil
    self.haveNum=0
    self.propTab=nil
    self.effectTabSp=nil
    self.frameTab = { A=15, B=10, C=9, D=10, E=10, F=10 }
    self.version = acFyssVoApi:getVersion()
    local function addPlist()
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
    end
    G_addResource8888(addPlist)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFyssEffect.plist")

    return nc
end

function acFyssTabOne:init(layerNum)
	local strSize2,strSize3 = 15,22
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2,strSize3 = 20,24
    end
	self.layerNum=layerNum

	self.bgLayer=CCLayer:create()

	self.effectTabSp={}
	local awardBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png",CCRect(50,20,1,1),function()end)
	awardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,130))
	awardBg:setAnchorPoint(ccp(0.5,1))
	awardBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-310)
	self.bgLayer:addChild(awardBg,1)
	local awardIcon = CCSprite:createWithSpriteFrameName("iconGoldNew6.png")
	awardIcon:setAnchorPoint(ccp(0,0.5))
	awardIcon:setPosition(15,awardBg:getContentSize().height/2)
	awardBg:addChild(awardIcon)
	self.effectTabSp.awardIcon=awardIcon
	local curAwardLb=GetTTFLabel(getlocal("activity_fyss_desc1"),strSize3)
	curAwardLb:setAnchorPoint(ccp(0,0.5))
	curAwardLb:setPosition(awardIcon:getPositionX()+awardIcon:getContentSize().width+10,awardBg:getContentSize().height/2+30)
	awardBg:addChild(curAwardLb)
	local awardNumLb=GetTTFLabel("00000",24)
	awardNumLb:setColor(G_ColorYellowPro)
	awardNumLb:setAnchorPoint(ccp(0,0.5))
	awardNumLb:setPosition(curAwardLb:getPositionX()+curAwardLb:getContentSize().width,curAwardLb:getPositionY())
	awardBg:addChild(awardNumLb)
	self.gemNumLabel=awardNumLb
	local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldSp:setAnchorPoint(ccp(0,0.5))
	goldSp:setPosition(awardNumLb:getPositionX()+awardNumLb:getContentSize().width,awardNumLb:getPositionY())
	awardBg:addChild(goldSp)
	awardNumLb:setString("0")

	local function awardHandler()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        socketHelper:acFyssRequest({6},function(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.words then
                    acFyssVoApi:setItem(sData.data.fuyunshuangshou.words)
                end
                if sData and sData.data and sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.crow then
                    acFyssVoApi:updateAcStatus(sData.data.fuyunshuangshou.crow)
                end
                if sData and sData.data and sData.data.reward then
                    playerVoApi:setGems(playerVoApi:getGems()+sData.data.reward[1])
                    -- --恭喜获得金币 弹框
                    local pData = {u={}}
			        pData.u["gems"]=sData.data.reward[1]
			        local rewardList = FormatItem(pData)
			        local titleStr=getlocal("activity_wheelFortune4_reward")
			        require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
			        rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardList,nil,titleStr)
			        if self.effectSpF and tolua.cast(self.effectSpF,"CCSprite") then
			        	self.effectSpF:removeFromParentAndCleanup(true)
			        	self.effectSpF = nil
			        end
			        acFyssVoApi:updateShow()
                end
                self:refreshRewardStatus()
            end
        end)
	end
	local awardBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",awardHandler,11)
    awardBtn:setScale(0.5)
    awardBtn:setAnchorPoint(ccp(1,0.5))
    local awardMenu=CCMenu:createWithItem(awardBtn)
    awardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    awardMenu:setPosition(ccp(awardBg:getContentSize().width-20,awardBg:getContentSize().height/2))
    awardBg:addChild(awardMenu)
    local awardBtnLb=GetTTFLabel(getlocal("daily_scene_get"),22,true)
    awardBtnLb:setPosition(awardMenu:getPositionX()-awardBtn:getContentSize().width*awardBtn:getScale()/2,awardMenu:getPositionY())
    awardBg:addChild(awardBtnLb)
    awardBtn:setEnabled(false)
    awardBtn:setVisible(false)
    awardBtnLb:setVisible(false)

    local descStr=getlocal("activity_fyss_desc2")
    if acFyssVoApi:getVersion()~=1 and acFyssVoApi:getVersion() ~= 3 then
    	descStr=getlocal("activity_fyss_desc2_2")
    end
    
    local descLbPosY = curAwardLb:getPositionY()-curAwardLb:getContentSize().height/2-5
    local awardDescLbSize=CCSizeMake(awardBg:getContentSize().width-curAwardLb:getPositionX()-awardBtn:getContentSize().width*awardBtn:getScale()-30,descLbPosY-10)
	local awardDescLb=GetTTFLabelWrap(descStr,strSize2,awardDescLbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	awardDescLb:setAnchorPoint(ccp(0,1))
	awardDescLb:setPosition(curAwardLb:getPositionX(),descLbPosY)
	awardBg:addChild(awardDescLb)
	awardDescLb:setString("")

	local colorTab={nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil}
	local awardDescRichText=G_getRichTextLabel(descStr,colorTab,strSize2,awardDescLbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	awardDescRichText:setAnchorPoint(ccp(0,1))
	awardDescRichText:setPosition(curAwardLb:getPositionX(),descLbPosY)
	awardBg:addChild(awardDescRichText)

	self.awardDescLb=awardDescLb
	self.awardDescRichText=awardDescRichText
	self.awardBtn=awardBtn
	self.awardBtnLb=awardBtnLb
	self:refreshRewardStatus()

	self.haveNum = 0
	local itemData = acFyssVoApi:getItemData()
	local propPosY = awardBg:getPositionY()-awardBg:getContentSize().height-50
	local propPosX = 60
	-- local ltterBg=LuaCCScale9Sprite:createWithSpriteFrameName("acFyss_ltterBg.png",CCRect(0,0,1,1),function()end)
	local ltterBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function()end)
	ltterBg:setContentSize(CCSizeMake(awardBg:getContentSize().width,110))
	ltterBg:setPosition(G_VisibleSizeWidth/2,propPosY)
	self.bgLayer:addChild(ltterBg)
	self.propTab={}
	for k, v in pairs(itemData) do
		local num = acFyssVoApi:getItemByNum(v.key)
		local propBg=LuaCCSprite:createWithSpriteFrameName("acFyss_propBg.png", function()
            local _propData = propCfg[v.key]
            local _num = acFyssVoApi:getItemByNum(v.key)
            local pData = {p={{}}}
            pData.p[1][v.key]=_num
            local _item = FormatItem(pData)
            G_showNewPropInfo(self.layerNum+1,true,true,nil,_item[1])
        end)
        propBg:setScale(77/propBg:getContentSize().width)
		propBg:setTouchPriority(-(self.layerNum-1)*20-3)
		propBg:setPosition(propPosX,propPosY)
		self.bgLayer:addChild(propBg)
		propPosX=propPosX+propBg:getContentSize().width*propBg:getScale()+15
		local propSp=CCSprite:createWithSpriteFrameName(propCfg[v.key].icon)
		propSp:setPosition(propBg:getContentSize().width/2,propBg:getContentSize().height/2)
		propSp:setTag(1001)
		propBg:addChild(propSp)
		local shadeSp=CCSprite:createWithSpriteFrameName("acFyss_propShade.png")
		shadeSp:setPosition(propBg:getContentSize().width/2,propBg:getContentSize().height/2)
		shadeSp:setTag(1003)
		shadeSp:setVisible(true)
		propBg:addChild(shadeSp)
		local numLb=GetTTFLabel("x"..num,24)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(propBg:getContentSize().width-10,5)
		numLb:setTag(1002)
		propBg:addChild(numLb)
		if num > 0 then
            self.haveNum = self.haveNum + 1
            shadeSp:setVisible(false)
        end
        self.propTab[v.key]=propBg
	end

	local function giveUpHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        -- if playerVoApi:getPlayerLevel() < acFyssVoApi:getGiveUpLevel() then
        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_givingLimitTip",{acFyssVoApi:getGiveUpLevel()}),30)
        --     do return end
        -- end
        -- if acFyssVoApi:getItemTotalNum() == 0 then
        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_noItem"),30)
        --     do return end
        -- end

        local function friendsList(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data then
                    acFyssVoApi:setFriendTb(friendMailVoApi:getFriendTb())
                end
                if sData and sData.data and sData.data.aclist and sData.data.aclist.fuyunshuangshou then
                	if sData.data.aclist.fuyunshuangshou.friend then
                    	acFyssVoApi:setGivingTab(sData.data.aclist.fuyunshuangshou.friend)
                    end
                    if sData.data.aclist.fuyunshuangshou.num then
                    	acFyssVoApi:setGiveUpCount(sData.data.aclist.fuyunshuangshou.num)
                    end
                end
                -- if acFyssVoApi:getGiveUpCount() >= acFyssVoApi:getMaxGiveUpCount() then
                -- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_noGivingNum"),30)
                -- 	do return end
                -- end
				acFyssSmallDialog:showGiving(self.layerNum+1,getlocal("rechargeGifts_giveLabel"),self)
            end
        end
        socketHelper:friendsList(friendsList,"fuyunshuangshou")
    end
    local giveUpBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",giveUpHandler,11)
    giveUpBtn:setScale(0.7)
    giveUpBtn:setAnchorPoint(ccp(1,0.5))
    local menu=CCMenu:createWithItem(giveUpBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(G_VisibleSizeWidth-20,propPosY))
    self.bgLayer:addChild(menu)
    local btnLb=GetTTFLabel(getlocal("rechargeGifts_giveLabel"),24,true)
    btnLb:setPosition(menu:getPositionX()-giveUpBtn:getContentSize().width*giveUpBtn:getScale()/2,menu:getPositionY())
    self.bgLayer:addChild(btnLb)

    self.exchangeData = acFyssVoApi:getExchangeList()

    local listViewBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    listViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,propPosY-50-15))
    listViewBg:setAnchorPoint(ccp(0.5,1))
    listViewBg:setPosition(G_VisibleSizeWidth/2,propPosY-50)
    self.bgLayer:addChild(listViewBg)
    local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,listViewBg:getContentSize(),nil)
	-- self.tv:setAnchorPoint(ccp(0,0))
	-- self.tv:setPosition(ccp(0,0))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
	self.tv:setMaxDisToBottomOrTop(100)
	listViewBg:addChild(self.tv)

	self:refreshRewardGold()

	G_addForbidForSmallDialog2(self.bgLayer,listViewBg,-(self.layerNum-1)*20-2,nil,1)

	if acFyssVoApi:getAcStatus() == 1 then 
		local effectSpF, animateF = self:createAnim("F")
		effectSpF:setPosition(self.effectTabSp.awardIcon:getContentSize().width/2,self.effectTabSp.awardIcon:getContentSize().height/2)
		self.effectTabSp.awardIcon:addChild(effectSpF)
		effectSpF:runAction(CCRepeatForever:create(animateF))
		if self.effectSpF and tolua.cast(self.effectSpF,"CCSprite") then
        	self.effectSpF:removeFromParentAndCleanup(true)
        	self.effectSpF = nil
        end
		self.effectSpF = effectSpF
	end

	return self.bgLayer
end

function acFyssTabOne:refreshRewardGold()
    socketHelper:acFyssRequest({7},function(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.servergems then
                if self.gemNumLabel then
                    self.gemNumLabel:setString(tostring(sData.data.servergems))
                end
            end
            if sData and sData.data and sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.words then
                acFyssVoApi:setItem(sData.data.fuyunshuangshou.words)
                self:refreshUI()
            end
        end
    end)
end

function acFyssTabOne:refreshRewardStatus()
	self.awardDescLb:setString("")
	self.awardDescRichText:setVisible(false)
	if acFyssVoApi:getAcStatus() == 0 then
		if acFyssVoApi:isRewardTime() then
			self.awardDescLb:setString(getlocal("activity_fyss_desc3"))
			--领奖时间无法瓜分金币：  activity_fyss_desc3="尚未获得瓜分资格，无法领取金币！"
		else
			-- if acFyssVoApi:getVersion()==1 then
			-- 	self.awardDescLb:setString(getlocal("activity_fyss_desc2"))
			-- else
			-- 	self.awardDescLb:setString(getlocal("activity_fyss_desc2_"..acFyssVoApi:getVersion()))
			-- end
			self.awardDescRichText:setVisible(true)
			--未获得瓜分资格：  activity_fyss_desc2="首次消耗5种字母立即赠送瓜分资格！"
		end
	elseif acFyssVoApi:getAcStatus() == 1 then
		self.awardDescLb:setString(getlocal("activity_fyss_desc4"))
		if acFyssVoApi:isRewardTime() then
			--领奖时间可瓜分金币：   activity_fyss_desc4="恭喜获得瓜分资格，请在领奖时间领取！"
			--新增'领取'按钮
			self.awardBtn:setEnabled(true)
		    self.awardBtn:setVisible(true)
		    self.awardBtnLb:setVisible(true)
		    self.awardBtnLb:setString(getlocal("daily_scene_get"))
		else
			--已获得瓜分资格：   activity_fyss_desc4="恭喜获得瓜分资格，请在领奖时间领取！"
		end
	elseif acFyssVoApi:getAcStatus() == 2 then
		self.awardDescLb:setString(getlocal("activity_fyss_desc4"))
		--领奖时间已瓜分金币：   activity_fyss_desc4="恭喜获得瓜分资格，请在领奖时间领取！"
		--新增'领取'按钮，置灰且不可点击
		self.awardBtn:setEnabled(false)
	    self.awardBtn:setVisible(true)
	    self.awardBtnLb:setVisible(true)
	    self.awardBtnLb:setString(getlocal("activity_hadReward"))
	end
end

function acFyssTabOne:refreshUI()
	if self.propTab and SizeOfTable(self.propTab)>0 then
		local itemData = acFyssVoApi:getItemData()
		self.haveNum = 0
		for k, v in pairs(itemData) do
			local num = acFyssVoApi:getItemByNum(v.key)
			local numLb = self.propTab[v.key]:getChildByTag(1002)
			local shadeSp = self.propTab[v.key]:getChildByTag(1003)
			numLb = tolua.cast(numLb,"CCLabelTTF")
			shadeSp = tolua.cast(shadeSp,"CCSprite")
			numLb:setString("x"..num)
			shadeSp:setVisible(true)
			if num > 0 then
				shadeSp:setVisible(false)
	            self.haveNum = self.haveNum + 1
	        end
		end
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acFyssTabOne:eventHandler(handler,fn,idx,cel)
	local strSize2,strSize3 = 18,20
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2,strSize3 = 20,24
    elseif G_getCurChoseLanguage() == "en" then
    	strSize2,strSize3 = 16,20
    elseif G_getCurChoseLanguage() =="ru" then
    	strSize3 = 16
    end
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
    	adaH = 9
    end
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.exchangeData)
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth-30,130+adaH)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellW,cellH=G_VisibleSizeWidth-30,130+adaH

		local _data=self.exchangeData[idx+1]
		local _isAllExchange=false
		if _data.needNum==SizeOfTable(self.exchangeData) then
			_isAllExchange=true
		end

		local titleBgFileName="panelSubTitleBg.png"
		if _isAllExchange then
			titleBgFileName="acFyss_yellowTitleBg.png"
		end
		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName(titleBgFileName,CCRect(105,16,1,1),function()end)
		titleBg:setContentSize(CCSizeMake(cellW-25,titleBg:getContentSize().height))
		titleBg:setAnchorPoint(ccp(0,1))
		titleBg:setPosition(3,cellH-3)
		cell:addChild(titleBg)
		local titleStr,colorTab
		if _isAllExchange then
			if acFyssVoApi:getVersion()==1 or acFyssVoApi:getVersion()==3 then
				titleStr=getlocal("activity_fyss_exchangeDesc1")
			else
				titleStr=getlocal("activity_fyss_exchangeDesc1_2")
			end
			colorTab={nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil}
		else
			titleStr=getlocal("activity_fyss_exchangeDesc2",{_data.needNum})
			colorTab={nil,G_ColorGreen,nil}
		end
		local titleLb=G_getRichTextLabel(titleStr,colorTab,strSize2,titleBg:getContentSize().width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		titleLb:setAnchorPoint(ccp(0,1))
		titleLb:setPosition(15,titleBg:getContentSize().height-3)
		titleBg:addChild(titleLb,3)

		local itemPosY=(cellH-titleBg:getContentSize().height)/2
		local itemList=FormatItem(_data.clientReward,nil,true)
		for k,v in pairs(itemList) do
			local icon, iconScale = G_getItemIcon(v,85,false,self.layerNum,function()
				G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
			end)
            icon:setTouchPriority(-(self.layerNum-1)*20-1)
            icon:setPosition(50+icon:getContentSize().width*iconScale/2+(k-1)*(30+icon:getContentSize().width*iconScale),itemPosY)
            local numLb=GetTTFLabel("x"..FormatNumber(v.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(icon:getContentSize().width-10,5))
            icon:addChild(numLb,1)
            numLb:setScale(1/iconScale)
            cell:addChild(icon)
            if _data.flicker and type(_data.flicker[tostring(v.index)])=="string" then
            	G_addRectFlicker2(icon,1.15,1.15,v.index,_data.flicker[tostring(v.index)],nil,55)
            end
		end

		if self.haveNum < _data.needNum then
			local label=GetTTFLabel(getlocal("activity_fyss_propNoEnough"),strSize3,true)
			label:setAnchorPoint(ccp(1,0.5))
			label:setPosition(cellW-25,itemPosY)
			label:setColor(G_ColorGray)
			cell:addChild(label)

			if self.version > 2 and idx+1 == 1 then
		    	label:setPositionY(itemPosY - 20)

		    	local hadEx,lNum = acFyssVoApi:getHadExNumAndLimitNum( )
		    	local curExTimeStr = GetTTFLabel(getlocal("super_weapon_challenge_troops_schedule",{hadEx,lNum}),24)
		    	curExTimeStr:setPosition(cellW-25 - label:getContentSize().width * 0.5,itemPosY + 25)
		    	cell:addChild(curExTimeStr)
		    	if hadEx >= lNum then
		    		curExTimeStr:setColor(G_ColorRed)
		    	end
		    end
		else
			local function exchangeHandler()
		        if G_checkClickEnable()==false then
		            do return end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
		        
		        local advPropId = acFyssVoApi:getAdvPropsId()
                local _isShowSureDialog = false

                local _needNum = _data.needNum
                local _numTab = {}
                local _itemData = acFyssVoApi:getItemData()
                for k, v in pairs(_itemData) do
                    if v.key ~= advPropId then
                        local _num = acFyssVoApi:getItemByNum(v.key)
                        if _num > 0 then
                            _numTab[#_numTab+1]={key=v.key,num=_num}
                        end
                    end
                end
                local _itemIds = {}
                if #_numTab < _needNum then
                    _numTab[#_numTab+1]={key=advPropId,num=acFyssVoApi:getItemByNum(advPropId)}
                    for k, v in pairs(_numTab) do
                        _itemIds[k]="props_"..v.key
                    end
                    _isShowSureDialog = true
                elseif #_numTab == _needNum then
                    for k, v in pairs(_numTab) do
                        _itemIds[k]="props_"..v.key
                    end
                else
                    local function sortAsc(a, b)
                        if a and b and a.num and b.num then
                            return a.num > b.num
                        end
                    end
                    table.sort(_numTab,sortAsc)
                    for k=1, _needNum do
                        _itemIds[k]="props_".._numTab[k].key
                    end
                end
                if self.version > 2 and idx+1 == 1 then
                	local hadEx,lNum = acFyssVoApi:getHadExNumAndLimitNum( )
                	if hadEx >= lNum then
                		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notExchangeTip"),30)
			            do return end
                	end
                end
                local function onExchangeEvent()
                	local function onRequestCallback(fn,data)
                		local ret,sData=base:checkServerData(data)
                        if ret==true then
                        	if sData and sData.data and sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.words then
                                acFyssVoApi:setItem(sData.data.fuyunshuangshou.words)
                            end
                            if sData and sData.data and sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.c then
                            	 acFyssVoApi:setNewHadExNum(sData.data.fuyunshuangshou.c )
                            end
                            for k,v in pairs(itemList) do
                                G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                            end
                            local function onShowResult()
                            	local function showEndHandler()
			                        G_showRewardTip(itemList,true)
			                    end
								local titleStr=getlocal("activity_wheelFortune4_reward")
			                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
			                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,itemList,showEndHandler,titleStr,nil,nil,nil,_data.flicker)
			                	self:refreshUI()
			                	if _isAllExchange then
			                		acFyssVoApi:updateShow()
			                	end
                            end
                            if _isAllExchange and acFyssVoApi:getAcStatus()==0 and acFyssVoApi:isRewardTime()==false then
                            	acFyssVoApi:updateAcStatus(1)
                            	local sysMsg = getlocal("activity_fyss_sysMessage", {playerVoApi:getPlayerName()})
                            	local paramTab={}
						    	paramTab.functionStr="fuyunshuangshou"
						        paramTab.addStr="goTo_see_see"
						        chatVoApi:sendSystemMessage(sysMsg,paramTab)
                            	self:runEffect(function()
                            		self:refreshRewardStatus()
                            		onShowResult()
                            	end)
                            else
                            	onShowResult()
                            end
                		end
                	end
                	socketHelper:acFyssRequest({5,_data.index,_itemIds},onRequestCallback)
                end
                if _isShowSureDialog == true then
                    local contenStr = getlocal("activity_fyss_exchangePrompt",{getlocal(propCfg[advPropId].name)})
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onExchangeEvent,getlocal("dialog_title_prompt"),contenStr,nil,self.layerNum+1)
                else
                    onExchangeEvent()
                end
		    end
		    local exchangeBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",exchangeHandler,11)
		    exchangeBtn:setScale(0.7)
		    exchangeBtn:setAnchorPoint(ccp(1,0.5))
		    local menu=CCMenu:createWithItem(exchangeBtn)
		    menu:setTouchPriority(-(self.layerNum-1)*20-1)
		    menu:setPosition(ccp(cellW-5,itemPosY))
		    if self.version > 2 and idx+1 == 1 then
		    	menu:setPositionY(itemPosY - 20)

		    	local hadEx,lNum = acFyssVoApi:getHadExNumAndLimitNum( )
		    	local curExTimeStr = GetTTFLabel(getlocal("super_weapon_challenge_troops_schedule",{hadEx,lNum}),24)
		    	curExTimeStr:setPosition(cellW-5 - exchangeBtn:getContentSize().width * 0.5 * 0.7,itemPosY + 25)
		    	cell:addChild(curExTimeStr)
		    	if hadEx >= lNum then
		    		curExTimeStr:setColor(G_ColorRed)
		    	end
		    end
		    cell:addChild(menu)
		    local btnLbStr=getlocal("code_gift")
		    if _isAllExchange and acFyssVoApi:getAcStatus()==0 and acFyssVoApi:isRewardTime()==false then
		    	btnLbStr=getlocal("activity_fyss_firstExchange")
		    end
		    local btnLb=GetTTFLabel(btnLbStr,24,true)
		    btnLb:setPosition(menu:getPositionX()-exchangeBtn:getContentSize().width*exchangeBtn:getScale()/2,menu:getPositionY())
		    cell:addChild(btnLb)

		    if _isAllExchange then
		    	self.effectTabSp.titleBg=titleBg
		    	self.effectTabSp.exchangeBtn=exchangeBtn
		    	self.effectTabSp.exchangeMenu=menu
		    	self:showExchangeBtnEffect()
		    end
		end

		-- local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine4.png",CCRect(3,0,1,1),function()end)
        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake((cellW-10),2))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(cellW/2,0)
        cell:addChild(lineSp)

		return cell
	elseif fn=="ccTouchBegan" then
		-- self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		-- self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acFyssTabOne:setTouchEnabled(_enabled)
	local sp = self.bgLayer:getChildByTag(-99999)
	if _enabled then
		if sp then
			sp:removeFromParentAndCleanup(true)
		end
	else
		if sp==nil then
			sp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()end)
		    sp:setTouchPriority(-self.layerNum*20-10)
		    sp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
		    sp:setOpacity(0)
		    sp:setTag(-99999)
		    self.bgLayer:addChild(sp,99999)
		end
	    sp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	end
end

function acFyssTabOne:createAnim(_type)
	local effectSp = CCSprite:createWithSpriteFrameName("acFyss_effect".._type.."_1.png")
	local arr = CCArray:create()
	for i=1,self.frameTab[_type] do
		local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acFyss_effect".._type.."_"..i..".png")
    	arr:addObject(frame)
	end
	local animation = CCAnimation:createWithSpriteFrames(arr)
	animation:setDelayPerUnit(0.8/self.frameTab[_type])
	local animate = CCAnimate:create(animation)
	return effectSp, animate
end

function acFyssTabOne:showExchangeBtnEffect()
	if self.effectTabSp and self.effectTabSp.exchangeMenu then
		local effectSpA, animateA = self:createAnim("A")
		effectSpA:setScale(1.1)
		effectSpA:setPosition(self.effectTabSp.exchangeMenu:getPositionX()-self.effectTabSp.exchangeBtn:getContentSize().width*self.effectTabSp.exchangeBtn:getScale()/2,self.effectTabSp.exchangeMenu:getPositionY())
		self.effectTabSp.exchangeMenu:getParent():addChild(effectSpA)
		local effectSpB, animateB = self:createAnim("B")
		effectSpB:setPosition(effectSpA:getPosition())
		self.effectTabSp.exchangeMenu:getParent():addChild(effectSpB,1)

		effectSpA:runAction(CCRepeatForever:create(animateA))
		effectSpB:runAction(CCRepeatForever:create(animateB))
		if self.exchangeBtnEffectSpA and tolua.cast(self.exchangeBtnEffectSpA,"CCSprite") then
			self.exchangeBtnEffectSpA:removeFromParentAndCleanup(true)
			self.exchangeBtnEffectSpA = nil
		end
		self.exchangeBtnEffectSpA = effectSpA
		if self.exchangeBtnEffectSpB and tolua.cast(self.exchangeBtnEffectSpB,"CCSprite") then
			self.exchangeBtnEffectSpB:removeFromParentAndCleanup(true)
			self.exchangeBtnEffectSpB = nil
		end
		self.exchangeBtnEffectSpB = effectSpB
	end
end

function acFyssTabOne:runEffect(_callFunc)
	local function createAnim(_type,_callbackFunc)
		local effectSp = CCSprite:createWithSpriteFrameName("acFyss_effect".._type.."_1.png")
		local arr = CCArray:create()
		for i=1,self.frameTab[_type] do
			local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acFyss_effect".._type.."_"..i..".png")
        	arr:addObject(frame)
		end
		local animation = CCAnimation:createWithSpriteFrames(arr)
    	animation:setDelayPerUnit(0.8/self.frameTab[_type])
    	local animate = CCAnimate:create(animation)
    	if _callbackFunc then
    		effectSp:runAction(CCSequence:createWithTwoActions(animate, CCCallFunc:create(function()
    			effectSp:removeFromParentAndCleanup(true)
    			_callbackFunc()
    		end)))
    	else
    		effectSp:runAction(CCRepeatForever:create(animate))
    	end
    	return effectSp, animate
	end
	if self.effectTabSp and self.effectTabSp.titleBg then
		self:setTouchEnabled(false)
		--[[
		local effectSpA, animateA = createAnim("A")
		effectSpA:setScale(1.1)
		effectSpA:setPosition(self.effectTabSp.exchangeMenu:getPositionX()-self.effectTabSp.exchangeBtn:getContentSize().width*self.effectTabSp.exchangeBtn:getScale()/2,self.effectTabSp.exchangeMenu:getPositionY())
		self.effectTabSp.exchangeMenu:getParent():addChild(effectSpA)
		local effectSpB = createAnim("B")
		effectSpB:setPosition(effectSpA:getPosition())
		self.effectTabSp.exchangeMenu:getParent():addChild(effectSpB,1)
		--]]
		local effectSpG = CCSprite:createWithSpriteFrameName("acFyss_effectG.png")
		effectSpG:setAnchorPoint(ccp(0,0.5))
		effectSpG:setPosition(0,self.effectTabSp.titleBg:getContentSize().height/2)
		self.effectTabSp.titleBg:addChild(effectSpG)
		local arrG = CCArray:create()
		arrG:addObject(CCFadeTo:create(0.5,55))
		arrG:addObject(CCFadeTo:create(0.5,255))
		effectSpG:runAction(CCRepeatForever:create(CCSequence:create(arrG)))
		local effectSpE = createAnim("E")
		effectSpE:setPosition(self.effectTabSp.titleBg:getContentSize().width/2,self.effectTabSp.titleBg:getContentSize().height/2)
		self.effectTabSp.titleBg:addChild(effectSpE)
		-- local effectSpC = createAnim("C")
		-- effectSpC:setAnchorPoint(ccp(0,0.5))
		-- effectSpC:setPosition(0,self.effectTabSp.titleBg:getContentSize().height/2)
		-- self.effectTabSp.titleBg:addChild(effectSpC)

		local function callBack2()
			-- local effectSpF = createAnim("F",function()
			-- 	if _callFunc then
			-- 		_callFunc()
			-- 	end
			-- 	self:setTouchEnabled(true)
			-- end)
			local effectSpF = createAnim("F")
			effectSpF:setPosition(self.effectTabSp.awardIcon:getContentSize().width/2,self.effectTabSp.awardIcon:getContentSize().height/2)
			self.effectTabSp.awardIcon:addChild(effectSpF)

			self.effectSpF = effectSpF
			self.bgLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1),CCCallFunc:create(function()
				if _callFunc then
					_callFunc()
				end
				self:setTouchEnabled(true)
			end)))
		end
		local function callBack1()
			local effectSpD = createAnim("D",callBack2)
			effectSpD:setPosition(self.effectTabSp.awardIcon:getContentSize().width/2,self.effectTabSp.awardIcon:getContentSize().height/2)
			self.effectTabSp.awardIcon:addChild(effectSpD)
		end
		local function callBack()
			local effectSpC = createAnim("C",callBack1)
			effectSpC:setAnchorPoint(ccp(0,0.5))
			effectSpC:setPosition(0,self.effectTabSp.titleBg:getContentSize().height/2)
			effectSpG:removeFromParentAndCleanup(true)
			effectSpE:removeFromParentAndCleanup(true)
			self.effectTabSp.titleBg:addChild(effectSpC)

			local particleSp = CCSprite:create()
			local particleEffect = CCParticleSystemQuad:create("public/acFyssParticleLine.plist")
			-- particleEffect:setPositionType(kCCPositionTypeRelative)
			-- particleEffect:setPositionType(kCCPositionTypeGrouped)
			particleEffect:setPositionType(kCCPositionTypeFree)
			particleSp:addChild(particleEffect)
			local posY = self.effectTabSp.awardIcon:getParent():getPositionY()-self.effectTabSp.awardIcon:getParent():getContentSize().height-130
			particleSp:setPosition(G_VisibleSizeWidth/2,posY)
			self.bgLayer:addChild(particleSp,10)
			local array = CCArray:create()
			array:addObject(CCMoveTo:create(0.8,ccp(85,self.effectTabSp.awardIcon:getParent():getPositionY()-self.effectTabSp.awardIcon:getParent():getContentSize().height/2)))
			array:addObject(CCCallFunc:create(function()
				particleSp:removeFromParentAndCleanup(true)
			end))
			particleSp:runAction(CCSequence:create(array))
		end
		--[[
		local arrA = CCArray:create()
		arrA:addObject(CCRepeat:create(animateA,3))
		-- arrA:addObject(CCScaleTo:create(1.2,1.5))
		arrA:addObject(CCCallFunc:create(function()
			effectSpA:removeFromParentAndCleanup(true)
			effectSpB:removeFromParentAndCleanup(true)

			local arrG = CCArray:create()
			arrG:addObject(CCFadeTo:create(0.1,55))
			arrG:addObject(CCFadeTo:create(0.1,255))
			arrG:addObject(CCRepeat:create(CCSequence:create(arrG),3))
			arrG:addObject(CCCallFunc:create(callBack))
			effectSpG:runAction(CCSequence:create(arrG))
    	end))
    	effectSpA:runAction(CCSequence:create(arrA))
    	--]]

		-- local effectSpD = createAnim("D")
		-- effectSpD:setPosition(self.effectTabSp.awardIcon:getContentSize().width/2,self.effectTabSp.awardIcon:getContentSize().height/2)
		-- self.effectTabSp.awardIcon:addChild(effectSpD)
		
		-- local effectSpF = createAnim("F")
		-- effectSpF:setPosition(self.effectTabSp.awardIcon:getContentSize().width/2,self.effectTabSp.awardIcon:getContentSize().height/2)
		-- self.effectTabSp.awardIcon:addChild(effectSpF)





		if self.exchangeBtnEffectSpB and tolua.cast(self.exchangeBtnEffectSpB,"CCSprite") then
			-- self.exchangeBtnEffectSpB:removeFromParentAndCleanup(true)
			-- self.exchangeBtnEffectSpB = nil
			local array = CCArray:create()
			array:addObject(CCScaleTo:create(0.3,1.5))
			array:addObject(CCScaleTo:create(0.3,1))
			self.exchangeBtnEffectSpB:runAction(CCSequence:create(array))
		end
        if self.exchangeBtnEffectSpA and tolua.cast(self.exchangeBtnEffectSpA,"CCSprite") then
			-- self.exchangeBtnEffectSpA:removeFromParentAndCleanup(true)
			-- self.exchangeBtnEffectSpA = nil
			local array = CCArray:create()
			array:addObject(CCScaleTo:create(0.2,1.5))
			array:addObject(CCScaleTo:create(0.3,1.1))
			array:addObject(CCCallFunc:create(function()

				local arrG = CCArray:create()
				arrG:addObject(CCFadeTo:create(0.1,55))
				arrG:addObject(CCFadeTo:create(0.1,255))
				arrG:addObject(CCRepeat:create(CCSequence:create(arrG),3))
				arrG:addObject(CCCallFunc:create(callBack))
				effectSpG:runAction(CCSequence:create(arrG))
			end))
			self.exchangeBtnEffectSpA:runAction(CCSequence:create(array))
		end
	end
end

function acFyssTabOne:tick()
end

function acFyssTabOne:dispose()
	self.layerNum=nil
	self.bgLayer=nil
	self.exchangeData=nil
	self.gemNumLabel=nil
	self.haveNum=0
	self.propTab=nil
	self.effectTabSp=nil

	spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFyssEffect.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acFyssEffect.png")
end