acZnkhTabOne={}

function acZnkhTabOne:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.turnSingleAreaH = 183 -- 转动区域每个图标占的高度
    self.turnNum = 10 -- 转动区域个数
    self.spTb1={}
    self.spTb2={}
    self.spTb3={}
    self.spTb4={}
    self.selectPositionY=0
    self.spTb1Speed=nil
    self.spTb2Speed=nil
    self.spTb3Speed=nil
    self.spTb4Speed=nil
    self.moveDis=0
    self.isStop1=nil
    self.isStop2=nil
    self.isStop3=nil
    self.isStop4=nil

    self.isRunningAction=false
    self.rewardType=nil

    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acZnkhEffect.plist")
    spriteController:addTexture("public/acZnkhEffect.png")

    return nc
end

function acZnkhTabOne:init(layerNum,parentTb)
	self.layerNum=layerNum
	self.parentTb=parentTb

	self.bgLayer=CCLayer:create()

	self:initUI()

	return self.bgLayer
end

function acZnkhTabOne:initUI()
	local fontSize,fontSize2 = 21,18
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		fontSize2 = 21
	end
	local function nilFunc()
	end
	-- local topBg=CCSprite:createWithSpriteFrameName("acZnkh_topBg.jpg")
	local topBgNode=CCNode:create()
	topBgNode:setContentSize(CCSizeMake(618,255))
	topBgNode:setAnchorPoint(ccp(0.5,1))
	topBgNode:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-158)
	self.bgLayer:addChild(topBgNode)
	self.url=G_downloadUrl("active/".."acZnkh_topBg.jpg")
	local function onLoadIcon(fn,topBg)
        if self and topBgNode and tolua.cast(topBgNode,"CCNode") then
            topBg:setAnchorPoint(ccp(0.5,0.5))
            topBgNode:addChild(topBg)
            topBg:setPosition(topBgNode:getContentSize().width/2,topBgNode:getContentSize().height/2)
        end
    end
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
 	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	-- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	-- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local topAlphaBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
	if acZnkhVoApi and acZnkhVoApi:getVersion()==3 then
		topAlphaBg:setContentSize(CCSizeMake(topBgNode:getContentSize().width,95))
	else
		topAlphaBg:setContentSize(CCSizeMake(topBgNode:getContentSize().width,80))
	end
	topAlphaBg:setAnchorPoint(ccp(0.5,1))
	topAlphaBg:setPosition(topBgNode:getContentSize().width/2,topBgNode:getContentSize().height)
	topBgNode:addChild(topAlphaBg,2)

	local descStr1=acZnkhVoApi:getTimeStr()
    local descStr2=acZnkhVoApi:getRewardTimeStr()
	local lbRollView,timeLb,rewardLb=G_LabelRollView(CCSizeMake(topBgNode:getContentSize().width-60,30),descStr1,fontSize,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
	lbRollView:setPosition(30,topBgNode:getContentSize().height-35)
	topBgNode:addChild(lbRollView,2)
	self.timeLb=timeLb
	self.rTimeLb=rewardLb

	local descSt = getlocal("activity_znkh_desc")
	if acZnkhVoApi:getVersion()==3 then
		descSt = getlocal("activity_znkh_desc_3")
	end
	local acDescLb=GetTTFLabelWrap(descSt,fontSize2,CCSizeMake(topBgNode:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	acDescLb:setAnchorPoint(ccp(0.5,1))
	if acZnkhVoApi:getVersion()==3 then
		acDescLb:setPosition(topBgNode:getContentSize().width/2-20,topBgNode:getContentSize().height-40)
	else
		acDescLb:setPosition(topBgNode:getContentSize().width/2,topBgNode:getContentSize().height-40)
	end
	topBgNode:addChild(acDescLb,2)

	local function showInfo()
		if G_checkClickEnable()==false then
			do return end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local itemName=""
		local hxReward=acZnkhVoApi:getHxReward()
	    if hxReward then
	    	itemName=hxReward.name
	    end
		local tabStr = {
			getlocal("activity_znkh_tabOneInfo1",{itemName}),
			getlocal("activity_znkh_tabOneInfo2"),
			getlocal("activity_znkh_tabOneInfo3"),
			getlocal("activity_znkh_tabOneInfo4",{itemName}),
			getlocal("activity_znkh_tabOneInfo5"),
		}
		local titleStr=getlocal("activity_baseLeveling_ruleTitle")
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	infoItem:setScale(0.8)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(topBgNode:getContentSize().width-30,topBgNode:getContentSize().height-30))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	topBgNode:addChild(infoBtn,2)

	local numReward = acZnkhVoApi:getNumReward()
	local size=0
	if numReward then
		size=SizeOfTable(numReward)
	end
	--创建灯泡
	for i=1,size do
		local _num = numReward[i][1]
		local lightLine=LuaCCScale9Sprite:createWithSpriteFrameName("acZnkh_topAlphaBg.png",CCRect(0,0,2,1),nilFunc)
		lightLine:setContentSize(CCSizeMake(lightLine:getContentSize().width,(i%2==0) and 155 or 110))
		lightLine:setAnchorPoint(ccp(0.5,1))
		lightLine:setPosition(topBgNode:getContentSize().width/(size+1)*i,topBgNode:getContentSize().height)
		topBgNode:addChild(lightLine,1)

		local lightTop=CCSprite:createWithSpriteFrameName("acZnkh_lightTop.png")
		lightTop:setAnchorPoint(ccp(0.5,1))
		lightTop:setPosition(lightLine:getPositionX(),lightLine:getPositionY()-lightLine:getContentSize().height)
		topBgNode:addChild(lightTop,2)

		local lightSp=LuaCCSprite:createWithSpriteFrameName("acZnkh_lightBtn.png",function()
			local sd
			local rewardList = FormatItem(numReward[i][2],nil,true)
			local function btnCallback()
				socketHelper:acZnkhCreward(function(fn,data)
					local ret,sData=base:checkServerData(data)
            		if ret==true then
            			acZnkhVoApi:updateData(sData.data.znkh)
            			if sd then
							sd:close()
						end
						for k,v in pairs(rewardList) do
                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                        end
						local function showEndHandler()
	                        G_showRewardTip(rewardList,true)
	                    end
						local titleStr=getlocal("activity_wheelFortune4_reward")
	                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
	                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardList,showEndHandler,titleStr)
	                	self:refreshUI()
            		end
				end,{_num})
			end
			local btnText = acZnkhVoApi:isGetNumReward(_num) and getlocal("activity_hadReward") or getlocal("daily_scene_get")
			local btnEnabled = true
			if acZnkhVoApi:getTotalLotteryNum()<_num or acZnkhVoApi:isGetNumReward(_num) then
				btnEnabled=false
			end
			local titleStr2=getlocal("activity_znkh_rewardDesc",{_num})
			local desc=getlocal("activity_znkh2017_lottery_num",{acZnkhVoApi:getTotalLotteryNum().."/".._num})
			local descColor=G_ColorYellowPro
			if acZnkhVoApi:getTotalLotteryNum()<_num then
				descColor=G_ColorRed
			end
			sd=smallDialog:showRewardPanel(self.layerNum+1,getlocal("award"),28,titleStr2,desc,descColor,rewardList,btnCallback,btnText,btnEnabled)
		end)
		lightSp:setTouchPriority(-(self.layerNum-1)*20-5)
		lightSp:setAnchorPoint(ccp(0.5,1))
		lightSp:setPosition(lightTop:getPositionX(),lightTop:getPositionY()-lightTop:getContentSize().height+10)
		topBgNode:addChild(lightSp,1)
		local lightFocus=CCSprite:createWithSpriteFrameName("acZnkh_focus.png")
		lightFocus:setPosition(lightSp:getContentSize().width/2,lightSp:getContentSize().height/2)
		lightFocus:setTag(1)
		lightSp:addChild(lightFocus)
		local scoreLb=GetTTFLabel(tostring(_num),24,true)
		scoreLb:setPosition(lightSp:getContentSize().width/2,lightSp:getContentSize().height/2)
		scoreLb:setTag(2)
		scoreLb:setColor(G_ColorBlack)
		lightSp:addChild(scoreLb)
		if self.lightSpTb==nil then
			self.lightSpTb={}
		end
		self.lightSpTb[i]=lightSp
		
		if acZnkhVoApi:getTotalLotteryNum()<_num then
			lightFocus:setVisible(false)
			local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acZnkh_lightUnBtn.png")
			if frame then
				lightSp:setDisplayFrame(frame)
			end
		else
			if acZnkhVoApi:isGetNumReward(_num) then
				lightFocus:setVisible(false)
			else
				lightFocus:setVisible(true)
				local seq = CCSequence:createWithTwoActions(CCScaleTo:create(0.5,1.1),CCScaleTo:create(0.5,0.95))
				lightSp:runAction(CCRepeatForever:create(seq))
			end
		end
	end

	local lotteryNumLb=GetTTFLabel(getlocal("activity_znkh_lotteryNum",{acZnkhVoApi:getTotalLotteryNum()}),fontSize)
	lotteryNumLb:setAnchorPoint(ccp(0,0))
	lotteryNumLb:setPosition(30,5)
	lotteryNumLb:setColor(G_ColorYellowPro)
	topBgNode:addChild(lotteryNumLb,1)
	self.lotteryNumLb=lotteryNumLb

	local rewardBgPosY = topBgNode:getPositionY()-topBgNode:getContentSize().height
	if G_isIphone5()==true then
		rewardBgPosY = rewardBgPosY - 35
	end
	local rewardBg=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
	rewardBg:setAnchorPoint(ccp(0.5,1))
	rewardBg:setPosition(self.bgLayer:getContentSize().width/2,rewardBgPosY)
	self.bgLayer:addChild(rewardBg)
	local rewardTitleBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    rewardTitleBg:setAnchorPoint(ccp(0.5,0.5))
    rewardTitleBg:setPosition(ccp(rewardBg:getPositionX(),rewardBg:getPositionY()-rewardBg:getContentSize().height-(G_isIphone5()==true and 5 or 0)))
    self.bgLayer:addChild(rewardTitleBg,1)
    local bigRewardLb=GetTTFLabel(getlocal("activity_mineExploreG_rewardShow"),fontSize,true)
    bigRewardLb:setPosition(rewardTitleBg:getPosition())
    self.bgLayer:addChild(bigRewardLb,2)

    local bigRewardTb=acZnkhVoApi:getBigReward()
    if bigRewardTb then
	    for i=1,3 do
	    	if bigRewardTb[i] then
	    		local function showNewPropDialog()
                	G_showNewPropInfo(self.layerNum+1,true,true,nil,bigRewardTb[i],nil,nil,nil,nil,true)
            	end
                local icon,scale=G_getItemIcon(bigRewardTb[i],90,false,self.layerNum,showNewPropDialog)
                if i==1 then
                	icon:setPositionX(self.bgLayer:getContentSize().width/2-140)
                elseif i==2 then
                	icon:setPositionX(self.bgLayer:getContentSize().width/2)
                else
                	icon:setPositionX(self.bgLayer:getContentSize().width/2+140)
                end
                icon:setPositionY(rewardBg:getPositionY()-rewardBg:getContentSize().height/2+5)
                icon:setTouchPriority(-(self.layerNum-1)*20-4)
                self.bgLayer:addChild(icon,2)

                local numLb=GetTTFLabel("x"..FormatNumber(bigRewardTb[i].num),23)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setScale(1/scale)
                numLb:setPosition(ccp(icon:getContentSize().width-5,2))
                icon:addChild(numLb,4)
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                numBg:setOpacity(150)
                icon:addChild(numBg,3)
            end
	    end
	end

	--奖励按钮
	local function rewardHandler()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local strSize2 = 20
        if G_isIOS() or G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        	strSize2 = 25
        end

        --显示奖池
        local poolTitleTb = {"activity_refitPlanT99_bigReward","activity_znkh_bigReward","activity_znkh_commonReward"}
        local content={}
        local pool=acZnkhVoApi:getRewardPool()
        local poolSize = SizeOfTable(pool)
        local k=1
        for i=poolSize,1,-1 do
            local item={}
            item.rewardlist=pool[i]
            item.title={getlocal(poolTitleTb[k]),G_ColorYellowPro,strSize2}
            if k==1 then
            	if acZnkhVoApi:getVersion()>=2 then
            		item.subTitle={getlocal("activity_znkh_rewardDesc"..k,{2014,2015,2016,2017,2018})}
            	else
            		item.subTitle={getlocal("activity_znkh_rewardDesc"..k,{2013,2014,2015,2016,2017})}
            	end
            else
            	item.subTitle={getlocal("activity_znkh_rewardDesc"..k)}
            end
            table.insert(content,item)
            k=k+1
        end
        local title={getlocal("award"),nil,30}
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
        acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),title,content,self.layerNum+1,nil,nil,nil,true)
	end
	local rewardBtn=GetButtonItem("propBox3.png","propBox3.png","propBox3.png",rewardHandler,11)
    rewardBtn:setScale(0.7)
    rewardBtn:setAnchorPoint(ccp(0,1))
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardMenu:setPosition(ccp(20,rewardBgPosY-(G_isIphone5()==true and 50 or 30)))
    self.bgLayer:addChild(rewardMenu)
    local rewardBtnLb=GetTTFLabel(getlocal("award"),20)
    rewardBtnLb:setAnchorPoint(ccp(0.5,1))
    rewardBtnLb:setPosition(rewardMenu:getPositionX()+rewardBtn:getContentSize().width*rewardBtn:getScale()/2+5,rewardMenu:getPositionY()-rewardBtn:getContentSize().height*rewardBtn:getScale())
    self.bgLayer:addChild(rewardBtnLb)

	--记录按钮
	local function recordHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        socketHelper:acZnkhLog(function(fn,data)
	        local ret,sData=base:checkServerData(data)
	        if ret==true then
	        	local _isShowTipsDialog=true
	        	if sData and sData.data and sData.data.log then
	        		acZnkhVoApi:formatLog(sData.data.log)
	        		local lotteryLog = acZnkhVoApi:getLotteryLog()
	        		if lotteryLog and SizeOfTable(lotteryLog)>0 then
	        			local logList={}
			            for k,v in pairs(lotteryLog) do
			            	local point=0
			            	for i,j in pairs(v.reward) do
			                	local _p=acZnkhVoApi:getRewardPoint(j.key)
			                	_p=_p*j.num
			                    point=point+_p
			            	end
			                local num,reward,time=v.num,v.reward,v.time
			                local title={getlocal("activity_jsss_hx_logt",{num,point})}
			                local content={{reward}}
			                local log={title=title,content=content,ts=time}
			                table.insert(logList,log)
			            end
			            -- local logNum=SizeOfTable(logList)
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
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",recordHandler,12)
    recordBtn:setScale(0.7)
    recordBtn:setAnchorPoint(ccp(1,1))
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(self.bgLayer:getContentSize().width-20,rewardBgPosY-(G_isIphone5()==true and 50 or 30)))
    self.bgLayer:addChild(recordMenu)
    local recordBtnLb=GetTTFLabel(getlocal("serverwar_point_record"),20)
    recordBtnLb:setAnchorPoint(ccp(0.5,1))
    recordBtnLb:setPosition(recordMenu:getPositionX()-recordBtn:getContentSize().width*recordBtn:getScale()/2-5,recordMenu:getPositionY()-recordBtn:getContentSize().height*recordBtn:getScale())
    self.bgLayer:addChild(recordBtnLb)

	local machineBg=LuaCCScale9Sprite:createWithSpriteFrameName("acZnkh_mainBg.png",CCRect(46,244,1,1),nilFunc)
	machineBg:setContentSize(CCSizeMake(526,machineBg:getContentSize().height))
	machineBg:setAnchorPoint(ccp(0.5,1))
	machineBg:setPosition(self.bgLayer:getContentSize().width/2,rewardTitleBg:getPositionY()-(G_isIphone5()==true and 60 or 25))
	self.bgLayer:addChild(machineBg)
	for i=1,4 do
		local sp = CCSprite:createWithSpriteFrameName("acZnkh_numberBg.png")
		sp:setAnchorPoint(ccp(0,0.5))
		sp:setPosition(49+(i-1)*(sp:getContentSize().width+3),machineBg:getContentSize().height/2)
		machineBg:addChild(sp)
		self.turnSingleAreaH=sp:getContentSize().height
	end
	self.tvSize=CCSizeMake(machineBg:getContentSize().width-46*2,self.turnSingleAreaH)
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,self.tvSize,nil)
	-- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(46,(machineBg:getContentSize().height-self.turnSingleAreaH)/2))
	self.tv:setMaxDisToBottomOrTop(120)
	machineBg:addChild(self.tv,1)
	local topSp=LuaCCScale9Sprite:createWithSpriteFrameName("acZnkh_numberBgAlpha.png",CCRect(10,10,85,12),function()end)
	topSp:setContentSize(CCSizeMake(self.tvSize.width,40))
	topSp:setRotation(180)
	topSp:setAnchorPoint(ccp(0.5,0))
	topSp:setPosition(machineBg:getContentSize().width/2,self.tv:getPositionY()+self.tvSize.height)
	machineBg:addChild(topSp,2)
	local bomSp=LuaCCScale9Sprite:createWithSpriteFrameName("acZnkh_numberBgAlpha.png",CCRect(10,10,85,12),function()end)
	bomSp:setContentSize(CCSizeMake(self.tvSize.width,40))
	bomSp:setAnchorPoint(ccp(0.5,0))
	bomSp:setPosition(machineBg:getContentSize().width/2,self.tv:getPositionY())
	machineBg:addChild(bomSp,2)
	self.machineBg=machineBg

	local recordPoint = self.tv:getRecordPoint()
	recordPoint.y = 0
	self.tv:recoverToRecordPoint(recordPoint)

	local hxReward=acZnkhVoApi:getHxReward()
	if hxReward then
	-- if base.hexieMode==1 then
	    local descStr=hxReward.name
		local descLb=GetTTFLabelWrap(getlocal("activity_fyss_lotteryDesc",{descStr}),22,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		descLb:setAnchorPoint(ccp(0.5,1))
		descLb:setPosition(self.bgLayer:getContentSize().width/2,machineBg:getPositionY()-machineBg:getContentSize().height- (G_isIphone5()==true and 25 or 10))
		descLb:setColor(G_ColorYellowPro)
		self.bgLayer:addChild(descLb)
	end

	--抽奖按钮逻辑
	local function lotteryHandler(tag,object)
		if G_checkClickEnable()==false then
	        do return end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime()
	    end
	    PlayEffect(audioCfg.mouseClick)

	    ------------------------------------------ TODO TEST --------------------------------------
	    -- if tag==12 then
	    -- 	self.rewardType={math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3)}
	    -- else
	    -- 	self.rewardType={math.random(1,3)}
	    -- end
	    -- self.typeIndex=1
	    -- self:randomNumber(self.rewardType[self.typeIndex])
	    -- self:startPalyAnimation()
	    -- do return end
	    ------------------------------------------ TODO TEST --------------------------------------

	    if acZnkhVoApi:isRewardTime() then
	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_notLottery"),30)
	    	do return end
	    end

	    local lotteryPrice=0
	    local lotteryNum=1
	    if tag==11 then --单抽
	    	lotteryNum=1
	    	lotteryPrice=acZnkhVoApi:getOneLotteryCost()
    	elseif tag==12 then --五抽
    		if acZnkhVoApi:isFree() then
    			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage2036"),30)
    			do return end
    		end
    		lotteryNum=5
    		lotteryPrice=acZnkhVoApi:getFiveLotteryCost()
    	end

    	if (not acZnkhVoApi:isFree()) and playerVoApi:getGems()<lotteryPrice then
	    	GemsNotEnoughDialog(nil,nil,lotteryPrice-playerVoApi:getGems(),self.layerNum+1,lotteryPrice)
			do return end
		end

		local function onSureLogic()
	        local function lotteryCallFunc(fn,data)
	        	local ret,sData=base:checkServerData(data)
	            if ret==true then
	            	if (not acZnkhVoApi:isFree()) and playerVoApi:getGems()>=lotteryPrice then
                		playerVoApi:setGems(playerVoApi:getGems()-lotteryPrice)
            		end
	            	acZnkhVoApi:updateData(sData.data.znkh)
	            	if sData.data.reward then
	            		local rewardList={}
	            		for k, v in pairs(sData.data.reward) do
	            			table.insert(rewardList,FormatItem(v)[1])
	            		end
	            		for k,v in pairs(rewardList) do
	                        G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
	                    end
	                    local hxReward=acZnkhVoApi:getHxReward()
						if hxReward then
							hxReward.num = hxReward.num * lotteryNum
							G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
							table.insert(rewardList,1,hxReward)
						end
	                    self.lotteryRewardList=rewardList
	            	end
	            	if self.parentTb and self.parentTb.tab2 then
	            		self.parentTb.tab2:initRankList()
	            	end
	            	if sData.data.rkeys then
	            		self.rewardType=sData.data.rkeys
	            		self.typeIndex=1
					    self:randomNumber(self.rewardType[self.typeIndex])
					    self:startPalyAnimation()
					    for k,v in pairs(self.rewardType) do
					    	if v==3 then
							    local sysMsg
							    if acZnkhVoApi:getVersion()==3 then
							    	sysMsg = getlocal("activity_znkh_sysMessage_3", {playerVoApi:getPlayerName()})
							    else
							    	sysMsg = getlocal("activity_znkh_sysMessage", {playerVoApi:getPlayerName()})
							    end
		                    	local paramTab={}
						    	paramTab.functionStr="znkh"
						        paramTab.addStr="goTo_see_see"
						        chatVoApi:sendSystemMessage(sysMsg,paramTab)
					    	end
				    	end
	            	end
		    	end
	    	end
	        local free=nil
	        if acZnkhVoApi:isFree() then
	        	free=1
	        end
	        socketHelper:acZnkhLottery(lotteryCallFunc,{free,lotteryNum})
	    end

        local function secondTipFunc(sbFlag)
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag("znkh",sValue)
        end
	    if (not acZnkhVoApi:isFree()) and G_isPopBoard("znkh") then
			G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{lotteryPrice}),true,onSureLogic,secondTipFunc)
		else
			onSureLogic()
		end
	end

	--单抽按钮
	local oneLotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler,11)
    oneLotteryBtn:setScale(0.8)
    oneLotteryBtn:setAnchorPoint(ccp(1,0.5))
    local oneLotteryMenu=CCMenu:createWithItem(oneLotteryBtn)
    oneLotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    oneLotteryMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2-65,G_isIphone5()==true and 95 or 50))
    self.bgLayer:addChild(oneLotteryMenu)
    local oneLotteryBtnLb=GetTTFLabel(getlocal("activity_fyss_btnStr",{1}),24,true)
    oneLotteryBtnLb:setPosition(oneLotteryMenu:getPositionX()-oneLotteryBtn:getContentSize().width*oneLotteryBtn:getScale()/2,oneLotteryMenu:getPositionY())
    self.bgLayer:addChild(oneLotteryBtnLb)

    --五抽按钮
	local fiveLotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",lotteryHandler,12)
    fiveLotteryBtn:setScale(0.8)
    fiveLotteryBtn:setAnchorPoint(ccp(0,0.5))
    local fiveLotteryMenu=CCMenu:createWithItem(fiveLotteryBtn)
    fiveLotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    fiveLotteryMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2+65,G_isIphone5()==true and 95 or 50))
    self.bgLayer:addChild(fiveLotteryMenu)
    local fiveLotteryBtnLb=GetTTFLabel(getlocal("activity_fyss_btnStr",{5}),24,true)
    fiveLotteryBtnLb:setPosition(fiveLotteryMenu:getPositionX()+fiveLotteryBtn:getContentSize().width*fiveLotteryBtn:getScale()/2,fiveLotteryMenu:getPositionY())
    self.bgLayer:addChild(fiveLotteryBtnLb)
    self.fiveLotteryBtn=fiveLotteryBtn

    local freeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),22)
    freeLb:setAnchorPoint(ccp(0.5,0))
    freeLb:setPosition(oneLotteryMenu:getPositionX()-oneLotteryBtn:getContentSize().width*oneLotteryBtn:getScale()/2,oneLotteryMenu:getPositionY()+oneLotteryBtn:getContentSize().height*oneLotteryBtn:getScale()/2+5)
    freeLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(freeLb)
    self.freeLb=freeLb

    local oneGoldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    oneGoldSp:setAnchorPoint(ccp(1,0.5))
    oneGoldSp:setPosition(oneLotteryMenu:getPositionX()-oneLotteryBtn:getContentSize().width*oneLotteryBtn:getScale()/2,oneLotteryMenu:getPositionY()+oneLotteryBtn:getContentSize().height*oneLotteryBtn:getScale()/2+20)
    self.bgLayer:addChild(oneGoldSp)
    local oneGoldLb=GetTTFLabel(tostring(acZnkhVoApi:getOneLotteryCost()),20)
    oneGoldLb:setAnchorPoint(ccp(0,0.5))
    oneGoldLb:setPosition(oneGoldSp:getPosition())
    oneGoldLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(oneGoldLb)
    self.oneGoldSp=oneGoldSp
    self.oneGoldLb=oneGoldLb

    local fiveGoldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    fiveGoldSp:setAnchorPoint(ccp(1,0.5))
    fiveGoldSp:setPosition(fiveLotteryMenu:getPositionX()+fiveLotteryBtn:getContentSize().width*fiveLotteryBtn:getScale()/2,fiveLotteryMenu:getPositionY()+fiveLotteryBtn:getContentSize().height*fiveLotteryBtn:getScale()/2+20)
    self.bgLayer:addChild(fiveGoldSp)
    local fiveGoldLb=GetTTFLabel(tostring(acZnkhVoApi:getFiveLotteryCost()),20)
    fiveGoldLb:setAnchorPoint(ccp(0,0.5))
    fiveGoldLb:setPosition(fiveGoldSp:getPosition())
    fiveGoldLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(fiveGoldLb)
    if G_isIOS() == false then
    	oneLotteryMenu:setPositionX(oneLotteryMenu:getPositionX() - 30)
    	oneLotteryBtnLb:setPosition(oneLotteryMenu:getPositionX()-oneLotteryBtn:getContentSize().width*oneLotteryBtn:getScale()/2,oneLotteryMenu:getPositionY())
    	fiveLotteryMenu:setPositionX(fiveLotteryMenu:getPositionX() - 30)
    	fiveLotteryBtnLb:setPosition(fiveLotteryMenu:getPositionX()+fiveLotteryBtn:getContentSize().width*fiveLotteryBtn:getScale()/2,fiveLotteryMenu:getPositionY())

    	freeLb:setAnchorPoint(ccp(0,0.5))
    	oneGoldSp:setAnchorPoint(ccp(0,0.5))
    	oneGoldLb:setAnchorPoint(ccp(0,0.5))
    	fiveGoldSp:setAnchorPoint(ccp(0,0.5))
    	fiveGoldLb:setAnchorPoint(ccp(0,0.5))

    	freeLb:setPosition(ccp(oneLotteryMenu:getPositionX() + 20,oneLotteryMenu:getPositionY()))
    	oneGoldSp:setPosition(ccp(oneLotteryMenu:getPositionX() + 5,oneLotteryMenu:getPositionY()))
    	oneGoldLb:setPosition(ccp(oneGoldSp:getPositionX() + oneGoldSp:getContentSize().width,oneLotteryMenu:getPositionY()))

    	fiveGoldSp:setPosition(ccp(fiveLotteryMenu:getPositionX() +fiveLotteryBtn:getContentSize().width*0.8 + 5,fiveLotteryMenu:getPositionY() ))
    	fiveGoldLb:setPosition(ccp(fiveGoldSp:getPositionX() + fiveGoldSp:getContentSize().width,oneLotteryMenu:getPositionY()))
    end
    --初次进入界面展示0403
    self:result({1,5,1,4})

    self:refreshUI()
end

function acZnkhTabOne:refreshUI()
	if acZnkhVoApi:isFree() then
		self.freeLb:setVisible(true)
		self.oneGoldSp:setVisible(false)
    	self.oneGoldLb:setVisible(false)
    	self.fiveLotteryBtn:setEnabled(false)
	else
		self.freeLb:setVisible(false)
		self.oneGoldSp:setVisible(true)
    	self.oneGoldLb:setVisible(true)
    	self.fiveLotteryBtn:setEnabled(true)
	end
	if self.lotteryNumLb then
		self.lotteryNumLb:setString(getlocal("activity_znkh_lotteryNum",{acZnkhVoApi:getTotalLotteryNum()}))
	end
	if self.lightSpTb then
		local numReward = acZnkhVoApi:getNumReward()
		if numReward then
			for k,v in pairs(self.lightSpTb) do
				local _num=numReward[k][1]
				v:stopAllActions()
				local lightFocus = tolua.cast(v:getChildByTag(1),"CCSprite")
				if acZnkhVoApi:getTotalLotteryNum()<_num then
					lightFocus:setVisible(false)
					local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acZnkh_lightUnBtn.png")
					if frame then
						v:setDisplayFrame(frame)
					end
				else
					local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acZnkh_lightBtn.png")
					if frame then
						v:setDisplayFrame(frame)
					end
					if acZnkhVoApi:isGetNumReward(_num) then
						lightFocus:setVisible(false)
					else
						lightFocus:setVisible(true)
						local seq = CCSequence:createWithTwoActions(CCScaleTo:create(0.5,1.1),CCScaleTo:create(0.5,0.95))
						v:runAction(CCRepeatForever:create(seq))
					end
				end
			end
		end
	end
end

function acZnkhTabOne:setTouchEnabled(_enabled,_callbackFunc)
	local sp = self.bgLayer:getChildByTag(-99999)
	if _enabled then
		if sp then
			sp:removeFromParentAndCleanup(true)
		end
	else
		if sp==nil then
			sp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() if _callbackFunc then _callbackFunc() end end)
		    sp:setTouchPriority(-self.layerNum*20-10)
		    sp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
		    sp:setOpacity(0)
		    sp:setTag(-99999)
		    self.bgLayer:addChild(sp,99999)
		end
	    sp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	end
end

--1是普通的。  2 是 连数的   3是年的（2013-2017）
function acZnkhTabOne:randomNumber(_type)
	self.playIds=nil
	if _type==1 then
		local num1=math.random(1,10)
		local num2=math.random(1,10)
		local num3=math.random(1,10)
		local num4=math.random(1,10)
		local num=tonumber((num1-1)..(num2-1)..(num3-1)..(num4-1))
		if num1==num2 and num2==num3 and num3==num4 then
			self:randomNumber(_type)
		elseif (acZnkhVoApi:getVersion()==1 and num==2013) or num==2014 or num==2015 or num==2016 or num==2017 or (acZnkhVoApi:getVersion()>=2 and num==2018) then
			self:randomNumber(_type)
		else
			self.playIds={ num1,num2,num3,num4 }
		end
	elseif _type==2 then
		local num=math.random(1,10)
		self.playIds={num,num,num,num}
	elseif _type==3 then
		if acZnkhVoApi:getVersion()>=2 then
			--201x		2014~2018
			self.playIds={3,1,2,math.random(5,9)}
		else
			--201x		2013~2017
			self.playIds={3,1,2,math.random(4,8)}
		end
	end

	if self.playIds then
    	local numStr=""
    	for k,v in pairs(self.playIds) do
    		numStr=numStr..(v-1)
    	end
    	local numDes={"普通奖","连号奖","年份奖"}
    	print("cjl -------->>> "..numDes[_type], numStr)
    end
end

function acZnkhTabOne:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(self.tvSize.width,self.turnSingleAreaH * self.turnNum)
        -- return  CCSizeMake(380,self.turnSingleAreaH * self.turnNum)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        for i=1,4 do
        	for id=1,self.turnNum do
        		local icon = CCSprite:createWithSpriteFrameName("acZnkh_number_"..(id-1)..".png")
        		local picX = 3 + 105/2 + (i-1)*(105+3)
        		local picY = 33 + (id-1)*self.turnSingleAreaH
        		icon:setAnchorPoint(ccp(0.5,0))
        		icon:setPosition(ccp(picX, picY))
		        cell:addChild(icon)

		        if id==1 then
		            self.selectPositionY=icon:getPositionY()
		        end

		        self["spTb"..i][id]={}
		        self["spTb"..i][id].id=id
		        self["spTb"..i][id].sp=icon
        	end
        end

        return cell
    elseif fn=="ccTouchBegan" then
    	self.isMoved=false
    	return true
  	elseif fn=="ccTouchMoved" then
    	self.isMoved=true
  	elseif fn=="ccTouchEnded" then
    end
end

function acZnkhTabOne:moveSp(tb)
	self.moveDis=self.moveDis+1

	for i=1,4 do
		for k,v in pairs(self["spTb"..i]) do
			-- if self.moveDis>=self["spTb"..i.."moveDisNum"] then
			if self.moveDis>=(i-1)*2 then
				v.sp:setPositionY(v.sp:getPositionY()-self["spTb"..i.."Speed"])
				if v.sp:getPositionY()<=-self.turnSingleAreaH then
					local key=k-1
					if key==0 then
						key=10
					end
					v.sp:setPositionY(self["spTb"..i][key].sp:getPositionY()+self.turnSingleAreaH)
				end
				-- if self.moveDis>self.moveDisNum and v.id==tb[i] and v.sp:getPositionY()==self.selectPositionY and self["isStop"..i]==false then
				if self.moveDis>self["spTb"..i.."moveDisNum"]+(i-1)*5 and v.id==tb[i] and self["isStop"..i]==false then
					local _y = v.sp:getPositionY()-self.selectPositionY
					if _y>=0 and _y<=self.turnSingleAreaH then
						local _isStop=true
						for n=1,i-1 do
							if self["isStop"..n]==false then
								_isStop=false
								break
							end
						end
						if _isStop then
							v.sp:setPositionY(self.selectPositionY)
							self["spTb"..i.."Speed"]=0
			                self["isStop"..i]=true
			                self:fuwei(v.id,self["spTb"..i])
		            	end
	            	end
				end
			end
		end
	end

	if self["isStop1"]==true and self["isStop2"]==true and self["isStop3"]==true and self["isStop4"]==true then
        self.state = 3
        -- print("动画播放结束： ", self.state)
    end
end

function acZnkhTabOne:fuwei(key,tb)
	if key==1 then
		for i=2, self.turnNum do
			local sp = tolua.cast(tb[i].sp,"CCNode")
			sp:setPositionY(33 + (i-1)*self.turnSingleAreaH)
		end
	elseif key==self.turnNum then
		for i=1, self.turnNum-1 do
			local sp = tolua.cast(tb[i].sp,"CCNode")
			sp:setPositionY(33 + i*self.turnSingleAreaH)
		end
	else
		local _posY
		local _yIndex = 1
		for i=key+1,self.turnNum do
			local sp = tolua.cast(tb[i].sp,"CCNode")
			sp:setPositionY(33 + _yIndex*self.turnSingleAreaH)
			_yIndex=_yIndex+1
			_posY=sp:getPositionY()
		end
		for i=1,key-1 do
			local sp = tolua.cast(tb[i].sp,"CCNode")
			sp:setPositionY(_posY+i*self.turnSingleAreaH)
		end
	end
end

function acZnkhTabOne:result(tb)
    self.spTb1Speed=0
    self.spTb2Speed=0
    self.spTb3Speed=0
    self.spTb4Speed=0
    self.isStop1=true
    self.isStop2=true
    self.isStop3=true
    self.isStop4=true
    for i=1,4 do
        for k,v in pairs(self["spTb"..i]) do
            if v.id==tb[i] then
                v.sp:setPositionY(self.selectPositionY)
                self:fuwei(v.id, self["spTb"..i])
            end
        end
    end
end

function acZnkhTabOne:fastTick()
    if self.state == 2 then
        -- print("动画播放中： ", self.state)
        if self.playIds ~= nil then
            self:moveSp(self.playIds)
        end
    elseif self.state == 3 then
        -- print("动画播放结束： ", self.state)
        self:result(self.playIds)
        self:stopPlayAnimation()
    end
end

function acZnkhTabOne:startPalyAnimation()
	self:setTouchEnabled(false,function() 
		PlayEffect(audioCfg.mouseClick)
		if SizeOfTable(self.rewardType)>1 then
			self.isSkipFiveLottery=true
		end
        self.state = 3
    end)

    for i=1,4 do
    	self["spTb"..i.."Speed"]=35 --控制滚动速度
    	self["spTb"..i.."moveDisNum"]=55 --控制相邻数字间的停顿间隔
    end

    self.moveDis=0
    self.isStop1=false
    self.isStop2=false
    self.isStop3=false
    self.isStop4=false
    self.state = 2
end

function acZnkhTabOne:stopPlayAnimation()
	self.state = 0

    if self.playIds then
    	local numStr=""
    	for k,v in pairs(self.playIds) do
    		numStr=numStr..(v-1)
    	end
    	print("cjl -------->>> 展示结果：", numStr)
    end

    self:showLightEffect(function()
    	self.typeIndex=self.typeIndex+1
		if self.rewardType[self.typeIndex] then
		    self:randomNumber(self.rewardType[self.typeIndex])
		    if self.isSkipFiveLottery then
		    	self.state = 3
		    else
				self:startPalyAnimation()
			end
		else
	    	if self.lotteryRewardList then
	    		local point=0
	    		local addStrTb
                addStrTb={}
                local hxReward=acZnkhVoApi:getHxReward()
                for k,v in pairs(self.lotteryRewardList) do
                	if hxReward==nil or k>1 then
	                	local _p=acZnkhVoApi:getRewardPoint(v.key)
	                	_p=_p*v.num
	                    table.insert(addStrTb,getlocal("scoreAdd",{_p}))
	                    point=point+_p
                	end
                end
                if hxReward then
                    table.insert(addStrTb,1,"")
                end

			    local function showEndHandler()
			        G_showRewardTip(self.lotteryRewardList,true)
			        self.lotteryRewardList=nil
			    end
				local titleStr=getlocal("activity_wheelFortune4_reward")
				local titleStr2=getlocal("activity_tccx_total_score").." "..getlocal("scoreAdd",{point})
			    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
			    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,self.lotteryRewardList,showEndHandler,titleStr,titleStr2,addStrTb)
		    end
		    self:refreshUI()
		    self:setTouchEnabled(true)
		    self.isSkipFiveLottery=nil
		end
    end)
end

function acZnkhTabOne:showLightEffect(_callbackFunc)
	if self.isRunningAction or self.rewardType==nil or self.typeIndex==nil or self.rewardType[self.typeIndex]==nil then
		do return end
	end
	local _type = self.rewardType[self.typeIndex]
	self.isRunningAction=true
	for i=1,4 do
	    local p = CCParticleSystemQuad:create("public/acZnkhParticle".._type.."_1.plist")
	    if i==1 then
	    	p:setPosition(50,self.machineBg:getContentSize().height/2)
	    elseif i==2 then
	    	p:setPosition(155,self.machineBg:getContentSize().height-30)
	    elseif i==3 then
	    	p:setPosition(365,self.machineBg:getContentSize().height-30)
	    elseif i==4 then
	    	p:setPosition(self.machineBg:getContentSize().width-50,self.machineBg:getContentSize().height/2)
	    end
	    p.positionType=kCCPositionTypeFree
	    p:setTag(100+i)
	    self.machineBg:addChild(p,5)
	end
	self.machineBg:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(function()
		local p = CCParticleSystemQuad:create("public/acZnkhParticle".._type..".plist")
		p:setPosition(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2)
		p.positionType=kCCPositionTypeFree
		p:setTag(115)
	    self.machineBg:addChild(p,5)
	end)))

	local lightFrameSp = CCSprite:createWithSpriteFrameName("acZnkh_lightFrame.png")
	lightFrameSp:setPosition(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2)
	lightFrameSp:setOpacity(55)
	lightFrameSp:setVisible(false)
	self.machineBg:addChild(lightFrameSp,4)
	local arry=CCArray:create()
	arry:addObject(CCDelayTime:create(0.7))
	arry:addObject(CCCallFunc:create(function() lightFrameSp:setVisible(true) end))
	arry:addObject(CCFadeTo:create(0.4,255))
	arry:addObject(CCFadeTo:create(0.4,55))
	arry:addObject(CCCallFunc:create(function()
		lightFrameSp:removeFromParentAndCleanup(true)
		lightFrameSp=nil
		if _type~=2 and _type~=3 then
			for i=1,5 do
				local p = self.machineBg:getChildByTag(100+i)
				if p then
					p:removeFromParentAndCleanup(true)
					p=nil
				end
			end

			self.isRunningAction=false

			if _callbackFunc then
				_callbackFunc()
			end
		end
	end))
	lightFrameSp:runAction(CCSequence:create(arry))

	if _type==2 or _type==3 then
		local lightEffectSp = CCSprite:createWithSpriteFrameName("acZnkh_effect_1.png")
		lightEffectSp:setVisible(false)
		local animArr = CCArray:create()
	    for i=1,9 do
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acZnkh_effect_"..i..".png")
	        animArr:addObject(frame)
	    end
	    local animation = CCAnimation:createWithSpriteFrames(animArr)
	    animation:setDelayPerUnit(0.8/9)
	    local animate = CCAnimate:create(animation)
	    lightEffectSp:setPosition(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2)
		local function actionCallback()
			for i=1,5 do
				local p = self.machineBg:getChildByTag(100+i)
				if p then
					p:removeFromParentAndCleanup(true)
					p=nil
				end
			end
			lightEffectSp:removeFromParentAndCleanup(true)
			lightEffectSp=nil
			if lightFrameSp then
				lightFrameSp:stopAllActions()
				lightFrameSp:removeFromParentAndCleanup(true)
				lightFrameSp=nil
			end
			self.isRunningAction=false

			if _callbackFunc then
				_callbackFunc()
			end
		end
		local arry=CCArray:create()
		arry:addObject(CCDelayTime:create(0.7))
		arry:addObject(CCCallFunc:create(function() lightEffectSp:setVisible(true) end))
		arry:addObject(animate)
		-- arry:addObject(CCRepeat:create(animate,1))
		arry:addObject(CCCallFunc:create(actionCallback))
		lightEffectSp:runAction(CCSequence:create(arry))
		self.machineBg:addChild(lightEffectSp,4)
	end
end

function acZnkhTabOne:updateAcTime()
    -- local acVo=acZnkhVoApi:getAcVo()
    -- if acVo then
    	if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
    		self.timeLb:setString(acZnkhVoApi:getTimeStr())
        end
        if self.rTimeLb and tolua.cast(self.rTimeLb,"CCLabelTTF") then
        	self.rTimeLb:setString(acZnkhVoApi:getRewardTimeStr())
        end
    -- end
end

function acZnkhTabOne:tick()
	self:updateAcTime()
	if acZnkhVoApi:isToday()==false then
		acZnkhVoApi:updateFree()
		if acZnkhVoApi:isFree() then
			self.freeLb:setVisible(true)
			self.oneGoldSp:setVisible(false)
	    	self.oneGoldLb:setVisible(false)
	    	self.fiveLotteryBtn:setEnabled(false)
		else
			self.freeLb:setVisible(false)
			self.oneGoldSp:setVisible(true)
	    	self.oneGoldLb:setVisible(true)
	    	self.fiveLotteryBtn:setEnabled(true)
		end
	end
end

function acZnkhTabOne:dispose()
	self.isRunningAction=false

	spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acZnkhEffect.plist")
    spriteController:removeTexture("public/acZnkhEffect.png")
end