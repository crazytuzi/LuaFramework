acFyssTabTwo={}

function acFyssTabTwo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=nil
    self.bgLayer=nil
    self.acTab1=nil
    self.gridTab=nil
    self.prevRandomNum=0
    self.curAwardOfGridIndex=nil

    self.BTN_TAG_FREE=5001
    self.BTN_TAG_ONE =5002
    self.BTN_TAG_TEN =5003
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 1250 - 1136
    end
    return nc
end

function acFyssTabTwo:init(layerNum,acTab1)
	self.layerNum=layerNum
	self.acTab1=acTab1

	self.bgLayer=CCLayer:create()

	local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("acFyss_border1.png",CCRect(10,10,2,2),function()end)
	bgSp:setContentSize(CCSizeMake(560,(G_isIphone5()==true and 550 or 494)))
	bgSp:setAnchorPoint(ccp(0.5,1))
	bgSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-(G_isIphone5()==true and 350 or 315)-self.adaH)
	self.bgLayer:addChild(bgSp)
	local leftBorderSp=LuaCCScale9Sprite:createWithSpriteFrameName("acFyss_border2.png",CCRect(10,10,2,2),function()end)
	leftBorderSp:setContentSize(CCSizeMake(leftBorderSp:getContentSize().width,400))
	leftBorderSp:setRotation(180)
	leftBorderSp:setAnchorPoint(ccp(1,0.5))
	leftBorderSp:setPosition(0,bgSp:getContentSize().height/2)
	bgSp:addChild(leftBorderSp)
	local rightBorderSp=LuaCCScale9Sprite:createWithSpriteFrameName("acFyss_border2.png",CCRect(10,10,2,2),function()end)
	rightBorderSp:setContentSize(CCSizeMake(rightBorderSp:getContentSize().width,400))
	rightBorderSp:setAnchorPoint(ccp(1,0.5))
	rightBorderSp:setPosition(bgSp:getContentSize().width,bgSp:getContentSize().height/2)
	bgSp:addChild(rightBorderSp)

	local function recordHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        socketHelper:acFyssRequest({8},function(fn,data)
	        local ret,sData=base:checkServerData(data)
	        if ret==true then
	        	local _isShowTipsDialog=true
	        	if sData and sData.data and sData.data.log then
	        		acFyssVoApi:formatLog(sData.data.log)
	        		local lotteryLog = acFyssVoApi:getLotteryLog()
	        		if lotteryLog and SizeOfTable(lotteryLog)>0 then
	        			local logList={}
			            for k,v in pairs(lotteryLog) do
			                local num,reward,time=v.num,v.reward,v.time
			                local title={getlocal("activity_fyss_lotteryLogDesc",{num})}
			                local content={{reward}}
			                local log={title=title,content=content,ts=time}
			                table.insert(logList,log)
			            end
			            local logNum=SizeOfTable(logList)
			            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
			            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
	        			_isShowTipsDialog=nil
	        		end
	        	end
	        	if _isShowTipsDialog then
	        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
	        	end
	        end
	    end)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",recordHandler,11)
    recordBtn:setScale(0.6)
    recordBtn:setAnchorPoint(ccp(1,1))
    local menu=CCMenu:createWithItem(recordBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(bgSp:getContentSize().width-10,bgSp:getContentSize().height-10))
    bgSp:addChild(menu)
    local btnLb=GetTTFLabel(getlocal("serverwar_point_record"),20)
    btnLb:setAnchorPoint(ccp(0.5,1))
    btnLb:setPosition(menu:getPositionX()-recordBtn:getContentSize().width*recordBtn:getScale()/2-5,menu:getPositionY()-recordBtn:getContentSize().height*recordBtn:getScale())
    bgSp:addChild(btnLb)

    if base.hexieMode==1 then
	    local descStr=""
	    local hxReward=acFyssVoApi:getHxReward()
	    if hxReward then
	    	descStr=hxReward.name
	    end
		local descLb=GetTTFLabelWrap(getlocal("activity_fyss_lotteryDesc",{descStr}),22,CCSizeMake(bgSp:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		descLb:setAnchorPoint(ccp(0.5,1))
		descLb:setPosition(bgSp:getContentSize().width/2-30,bgSp:getContentSize().height-30)
		descLb:setColor(G_ColorYellowPro)
		bgSp:addChild(descLb)
	end

	local itemList = acFyssVoApi:getLotteryItemList()
    self.gridTab = {}
    local column = 4
    local _iconSize = 90
    local spaceX, spaceY = 35, 35
    local _startX, _startY = nil, nil
    local _uiSpace = 30
    -- if G_isIphone5() == true then
    --     _uiSpace = _uiSpace+176/2
    --     spaceX, spaceY = 50, 65
    -- end
    for i = 1, 12 do
        local itemBg, iconScale = G_getItemIcon(itemList[i],_iconSize,false,self.layerNum,function()
        	G_showNewPropInfo(self.layerNum+1,true,true,nil,itemList[i])
        end)
        itemBg:setTouchPriority(-(self.layerNum-1)*20-1)

        if _startX == nil and _startY == nil then
            _startX = (bgSp:getContentSize().width-(itemBg:getContentSize().width*itemBg:getScale()*column+spaceX*(column-1)))/2+(itemBg:getContentSize().width*itemBg:getScale()/2)
            _startY = bgSp:getContentSize().height/2-_uiSpace+itemBg:getContentSize().height*itemBg:getScale()+spaceY
        end
        local _x = _startX+(itemBg:getContentSize().width*itemBg:getScale()+spaceX)*((i-1)%column)
        local _y = _startY-(itemBg:getContentSize().height*itemBg:getScale()+spaceY)*math.floor((i-1)/column)
        itemBg:setPosition(_x,_y)
        bgSp:addChild(itemBg,1)

        local numLb=GetTTFLabel("x"..FormatNumber(itemList[i].num),20)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(itemBg:getContentSize().width-10,5))
        numLb:setScale(1/iconScale)
        itemBg:addChild(numLb,1)

        -- if acFyssVoApi:getAdvPropsId() == itemList[i].key then
        --     G_addRectFlicker(itemBg,iconScale,iconScale)
        -- end
        local _index = tostring(itemList[i].index)
        if acFyssVoApi:getFlicker() and type(acFyssVoApi:getFlicker()[_index])=="string" then
        	G_addRectFlicker2(itemBg,1.15,1.15,tonumber(_index),acFyssVoApi:getFlicker()[_index],nil,55)
        end

        self.gridTab[i] = itemBg
    end
    self:runRandAutoChoose()

	local btnPosY = (bgSp:getPositionY()-bgSp:getContentSize().height-20)/2
	--免费
    self.freeBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",function(...) self:lotteryHandler(...) end,self.BTN_TAG_FREE)
    -- self.freeBtn:setScale(0.7)
    self.freeBtn:setAnchorPoint(ccp(1,0.5))
    local freeMenu=CCMenu:createWithItem(self.freeBtn)
    freeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    freeMenu:setPosition(ccp(G_VisibleSizeWidth/2-30,btnPosY))
    self.bgLayer:addChild(freeMenu)
    self.freeBtnLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),24,true)
    self.freeBtnLb:setPosition(freeMenu:getPositionX()-self.freeBtn:getContentSize().width*self.freeBtn:getScale()/2,freeMenu:getPositionY())
    self.bgLayer:addChild(self.freeBtnLb)

	--买1次
    self.buyOneBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",function(...) self:lotteryHandler(...) end,self.BTN_TAG_ONE)
    -- self.buyOneBtn:setScale(0.7)
    self.buyOneBtn:setAnchorPoint(ccp(1,0.5))
    local oneMenu=CCMenu:createWithItem(self.buyOneBtn)
    oneMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    oneMenu:setPosition(ccp(G_VisibleSizeWidth/2-30,btnPosY))
    self.bgLayer:addChild(oneMenu)
    self.oneBtnLb=GetTTFLabel(getlocal("activity_fyss_btnStr",{1}),24,true)
    self.oneBtnLb:setPosition(oneMenu:getPositionX()-self.buyOneBtn:getContentSize().width*self.buyOneBtn:getScale()/2,oneMenu:getPositionY())
    self.bgLayer:addChild(self.oneBtnLb)

    --买10次
    self.buyTenBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",function(...) self:lotteryHandler(...) end,self.BTN_TAG_TEN)
    -- self.buyTenBtn:setScale(0.7)
    self.buyTenBtn:setAnchorPoint(ccp(0,0.5))
    local tenMenu=CCMenu:createWithItem(self.buyTenBtn)
    tenMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    tenMenu:setPosition(ccp(G_VisibleSizeWidth/2+30,btnPosY))
    self.bgLayer:addChild(tenMenu)
    local tenBtnLb=GetTTFLabel(getlocal("activity_fyss_btnStr",{10}),24,true)
    tenBtnLb:setPosition(tenMenu:getPositionX()+self.buyTenBtn:getContentSize().width*self.buyTenBtn:getScale()/2,tenMenu:getPositionY())
    self.bgLayer:addChild(tenBtnLb)

    self.oneGoldLb=GetTTFLabel(tostring(acFyssVoApi:getOneLotterPrice()),20)
    self.oneGoldLb:setAnchorPoint(ccp(1,0.5))
    self.oneGoldLb:setPosition(oneMenu:getPositionX()-self.buyOneBtn:getContentSize().width*self.buyOneBtn:getScale()/2,oneMenu:getPositionY()+self.buyOneBtn:getContentSize().height*self.buyOneBtn:getScale()/2+20)
    self.bgLayer:addChild(self.oneGoldLb)
    self.oneGoldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.oneGoldSp:setAnchorPoint(ccp(0,0.5))
    self.oneGoldSp:setPosition(self.oneGoldLb:getPosition())
    self.bgLayer:addChild(self.oneGoldSp)

    local tenGoldLb=GetTTFLabel(tostring(acFyssVoApi:getTenLotterPrice()),20)
    tenGoldLb:setAnchorPoint(ccp(1,0.5))
    tenGoldLb:setPosition(tenMenu:getPositionX()+self.buyTenBtn:getContentSize().width*self.buyTenBtn:getScale()/2,tenMenu:getPositionY()+self.buyTenBtn:getContentSize().height*self.buyTenBtn:getScale()/2+20)
    self.bgLayer:addChild(tenGoldLb)
    local tenGoldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    tenGoldSp:setAnchorPoint(ccp(0,0.5))
    tenGoldSp:setPosition(tenGoldLb:getPosition())
    self.bgLayer:addChild(tenGoldSp)

    self:refreshUI()

	return self.bgLayer
end

function acFyssTabTwo:setTouchEnabled(_enabled)
	local sp = self.bgLayer:getChildByTag(-99999)
	if _enabled then
		if sp then
			sp:removeFromParentAndCleanup(true)
		end
	else
		if sp==nil then
			sp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()
				self.isSkipRandAutoChoose=true
			end)
		    sp:setTouchPriority(-self.layerNum*20-10)
		    sp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
		    sp:setOpacity(0)
		    sp:setTag(-99999)
		    self.bgLayer:addChild(sp,99999)
		end
	    sp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	end
end

function acFyssTabTwo:setVisibleOneBtn(_visible)
	self.buyOneBtn:setEnabled(_visible)
    self.buyOneBtn:setVisible(_visible)
    self.oneBtnLb:setVisible(_visible)
    self.oneGoldLb:setVisible(_visible)
    self.oneGoldSp:setVisible(_visible)
end

function acFyssTabTwo:setVisibleFreeBtn(_visible)
	self.freeBtn:setEnabled(_visible)
	self.freeBtn:setVisible(_visible)
	self.freeBtnLb:setVisible(_visible)
end

function acFyssTabTwo:refreshUI()
	if acFyssVoApi:isFreeLottery() then
    	self:setVisibleOneBtn(false)
    	self.buyTenBtn:setEnabled(false)
    	self:setVisibleFreeBtn(true)
    else
    	self:setVisibleFreeBtn(false)
    	self:setVisibleOneBtn(true)
    	self.buyTenBtn:setEnabled(true)
    end

    --处理领奖时间不可抽奖
    if acFyssVoApi:isRewardTime() then
    	self.freeBtn:setEnabled(false)
    	self.buyOneBtn:setEnabled(false)
    	self.buyTenBtn:setEnabled(false)
    end
end

function acFyssTabTwo:lotteryHandler(tag,object)
	if G_checkClickEnable()==false then
        do return end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)

    -- if acFyssVoApi:isFreeLottery() then
    -- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_wheelFortune3_has_free"),30)
    -- 	do return end
    -- end

    if acFyssVoApi:isRewardTime() then
    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_notLottery"),30)
    	do return end
    end

    local lotteryPrice=0
    if tag==self.BTN_TAG_FREE then
		lotteryPrice=0
	elseif tag==self.BTN_TAG_ONE then
		lotteryPrice=acFyssVoApi:getOneLotterPrice()
	elseif tag==self.BTN_TAG_TEN then
		lotteryPrice=acFyssVoApi:getTenLotterPrice()
	end

    if tag~=self.BTN_TAG_FREE and playerVoApi:getGems()<lotteryPrice then
    	GemsNotEnoughDialog(nil,nil,lotteryPrice-playerVoApi:getGems(),self.layerNum+1,lotteryPrice)
		do return end
	end
	local function onRequestCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
        	if tag~=self.BTN_TAG_FREE and playerVoApi:getGems()>=lotteryPrice then
                playerVoApi:setGems(playerVoApi:getGems()-lotteryPrice)
                if self.acTab1 then --刷新奖池
                    self.acTab1:refreshRewardGold()
                end
            end
            if sData.data then
                if sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.f then
                    acFyssVoApi:setUseFreeLotterNum(sData.data.fuyunshuangshou.f)
                end
                if sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.t then
                    acFyssVoApi:updateLastTime(sData.data.fuyunshuangshou.t)
                end
                if sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.words then
                    acFyssVoApi:setItem(sData.data.fuyunshuangshou.words)
                    if self.acTab1 then
                    	self.acTab1:refreshUI()
                    end
                end
                local rewards = sData.data.report
                if rewards then
                	local rewardlist = {}
                	for k,v in pairs(rewards) do
						local reward=FormatItem(v,nil,true)[1]
						local itemList = acFyssVoApi:getLotteryItemList()
						for _i,_n in pairs(itemList) do
							if _n.key==reward.key then
								reward.index=_n.index
								break
							end
						end
						table.insert(rewardlist,reward)
						G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
					end

					local hxReward=acFyssVoApi:getHxReward()
					if hxReward then
						if tag==self.BTN_TAG_TEN then
							hxReward.num = hxReward.num * 10
						else
							hxReward.num = hxReward.num * 1
						end
						G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
					end

					local _index = nil
					if SizeOfTable(rewardlist)==1 then
						local itemList = acFyssVoApi:getLotteryItemList()
						for i = 1, 12 do
							if itemList[i].key==rewardlist[1].key and itemList[i].type==rewardlist[1].type then
								_index=i
								break
							end
						end
					end

					if hxReward then
						table.insert(rewardlist,1,hxReward)
					end

					self:runRandAutoChoose(function()
						local function showEndHandler()
	                        G_showRewardTip(rewardlist,true)
	                        self:runRandAutoChoose()
	                    end
						local titleStr=getlocal("activity_wheelFortune4_reward")
	                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
	                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr,nil,nil,nil,acFyssVoApi:getFlicker())
	                	self:refreshUI()
	                	acFyssVoApi:updateShow()
    				end, _index)

                end
            end
        end
    end

    local function onSureLogic()
    	if tag==self.BTN_TAG_FREE then
			socketHelper:acFyssRequest({4,1,1},onRequestCallback)
		elseif tag==self.BTN_TAG_ONE then
			socketHelper:acFyssRequest({4,1},onRequestCallback)
		elseif tag==self.BTN_TAG_TEN then
			socketHelper:acFyssRequest({4,2},onRequestCallback)
		end
    end
    if tag~=self.BTN_TAG_FREE then
    	local function secondTipFunc(sbFlag)
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag("fyss",sValue)
        end
	    if G_isPopBoard("fyss") then
			G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{lotteryPrice}),true,onSureLogic,secondTipFunc)
		else
			onSureLogic()
		end
	else
		onSureLogic()
	end
    
end

--返回m~n之间与_v不相等随机数
function acFyssTabTwo:random(m,n,_v)
	local value = math.random(m,n)
	while (_v==value) do
		value = math.random(m,n)
	end
	return value
end

function acFyssTabTwo:G_removeFlicker(_sprite)
	if _sprite~=nil then
        local temSp=tolua.cast(_sprite,"CCNode")
        local metalSp=nil;
        if temSp~=nil then
            metalSp=tolua.cast(temSp:getChildByTag(10101),"CCSprite")
        end
        if metalSp~=nil then
            metalSp:removeFromParentAndCleanup(true)
            metalSp=nil
        end
	end
end

function acFyssTabTwo:G_addRectFlicker(_sprite,_scaleX,_scaleY,_zorder)
	if _sprite and _sprite:getChildByTag(10101) == nil then
		local metalSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
        local m_iconScaleX,m_iconScaleY=_scaleX,_scaleY
        metalSp:setAnchorPoint(ccp(0.5,0.5))
        if m_iconScaleX~=nil then
            metalSp:setScaleX(m_iconScaleX)
        end
        if m_iconScaleY~=nil then
            metalSp:setScaleY(m_iconScaleY)
        end
        metalSp:setPosition(ccp(_sprite:getContentSize().width/2,_sprite:getContentSize().height/2))
        metalSp:setTag(10101)
        if _zorder==nil then
            _zorder=5
        end
        _sprite:addChild(metalSp,_zorder)
        return metalSp
    end
end

function acFyssTabTwo:runRandAutoChoose(_callbackFunc,_index)
	if _callbackFunc then
		self:setTouchEnabled(false)
		local randCallBack
		local _flagNum=0
		local function endCallFunc()
			_callbackFunc()
			self:setTouchEnabled(true)
		end
		randCallBack=function()
			if self.isSkipRandAutoChoose==true then
				self.bgLayer:stopAllActions()
				endCallFunc()
				self.isSkipRandAutoChoose=nil
				do return end
			end
			if _flagNum >= 15 then
				self.bgLayer:stopAllActions()
				if _index and self.gridTab then
					for k,v in pairs(self.gridTab) do
						-- G_removeFlicker(self.gridTab[k])
						self:G_removeFlicker(self.gridTab[k])
					end
					-- local randShow = G_addRectFlicker(self.gridTab[_index],1.3,1.3,nil,56)
					local randShow = self:G_addRectFlicker(self.gridTab[_index],0.9,0.9,56)
					randShow:setPosition(self.gridTab[_index]:getContentSize().width/2,self.gridTab[_index]:getContentSize().height/2)
					self.prevRandomNum = _index
					local arr = CCArray:create()
					arr:addObject(CCScaleTo:create(0.2,120/self.gridTab[_index]:getContentSize().width))
					arr:addObject(CCScaleTo:create(0.1,90/self.gridTab[_index]:getContentSize().width))
					arr:addObject(CCDelayTime:create(0.2))
					arr:addObject(CCCallFunc:create(endCallFunc))
					self.gridTab[_index]:runAction(CCSequence:create(arr))
				else
					endCallFunc()
				end
				do return end
			end
			if self.gridTab then
				local randomNum = self:random(1,SizeOfTable(self.gridTab),self.prevRandomNum)
				for k,v in pairs(self.gridTab) do
					-- G_removeFlicker(self.gridTab[k])
					self:G_removeFlicker(self.gridTab[k])
				end
				-- local randShow = G_addRectFlicker(self.gridTab[randomNum],1.3,1.3,nil,56)
				local randShow = self:G_addRectFlicker(self.gridTab[randomNum],0.9,0.9,56)
				randShow:setPosition(self.gridTab[randomNum]:getContentSize().width/2,self.gridTab[randomNum]:getContentSize().height/2)
				self.prevRandomNum = randomNum
			end
			local delayT = CCDelayTime:create(0.2)
			local randCall = CCCallFunc:create(randCallBack)
			local arr = CCArray:create()
			arr:addObject(delayT)
			arr:addObject(randCall)
			local seq = CCSequence:create(arr)
			self.bgLayer:runAction(seq)
			_flagNum=_flagNum+1
		end
		randCallBack()
	else
		local function randCallBack()
			if self.gridTab then
				local randomNum = self:random(1,SizeOfTable(self.gridTab),self.prevRandomNum)
				for k,v in pairs(self.gridTab) do
					-- G_removeFlicker(self.gridTab[k])
					self:G_removeFlicker(self.gridTab[k])
				end
				-- local randShow = G_addRectFlicker(self.gridTab[randomNum],1.3,1.3,nil,56)
				local randShow = self:G_addRectFlicker(self.gridTab[randomNum],0.9,0.9,56)
				randShow:setPosition(self.gridTab[randomNum]:getContentSize().width/2,self.gridTab[randomNum]:getContentSize().height/2)
				self.prevRandomNum = randomNum
			end
			local delayT = CCDelayTime:create(1.2)
			local randCall = CCCallFunc:create(randCallBack)
			local arr = CCArray:create()
			arr:addObject(delayT)
			arr:addObject(randCall)
			local seq = CCSequence:create(arr)
			self.bgLayer:runAction(seq)
		end
		local delayT = CCDelayTime:create(2)
		local randCall = CCCallFunc:create(randCallBack)
		local arr = CCArray:create()
		arr:addObject(delayT)
		arr:addObject(randCall)
		local seq = CCSequence:create(arr)
		self.bgLayer:runAction(seq)
	end
end

function acFyssTabTwo:tick()
	if acFyssVoApi:isToday()==false and acFyssVoApi:isRewardTime()==false then
		acFyssVoApi:setUseFreeLotterNum(0)
		self:refreshUI()
	end
end

function acFyssTabTwo:dispose()
	self.layerNum=nil
	self.bgLayer=nil
	self.gridTab=nil
	self.acTab1=nil
	self.prevRandomNum=0
	self.curAwardOfGridIndex=nil
end