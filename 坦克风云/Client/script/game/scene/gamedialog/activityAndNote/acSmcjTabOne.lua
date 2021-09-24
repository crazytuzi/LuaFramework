acSmcjTabOne={}
function acSmcjTabOne:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent    = parent
	nc.bgLayer   = nil
	nc.isIphone5 = G_isIphone5()

	nc.url       = G_downloadUrl("active/".."acSmcjImage.jpg") or nil
	nc.upPosY    = G_VisibleSizeHeight-160
	nc.upHeight  = 160 + 240
	nc.boxSpTb   = {}
	nc.lightSpTb = {}
	nc.boxPosTb  = {}
	return nc
end
function acSmcjTabOne:dispose( )
	if self.dlist then
        for k,v in pairs(self.dlist) do
            if v and v.dispose then
                v:dispose()
            end
        end
    end
    if self and self.taskLayer and self.taskLayer.dispose then
        self.taskLayer:dispose()
    end
    self.list=nil
    self.dlist=nil
    self.taskLayer=nil
    self.curTankTab=nil

	self.boxPosTb = nil
	self.lightSpTb = nil
	self.boxSp = nil
	self.bgLayer   = nil
	self.parent    = nil
	self.isIphone5 = nil
	self.timerSpriteLv = nil

end
function acSmcjTabOne:init(layerNum)

	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	
	local function realInit()
		self:initUpPanel()
		self:initDownPanel()
		self.initFlag=true	
	end

	local curday = acSmcjVoApi:getNumDayOfActive()
	if curday<=7 then
		local tskTb
		local taskList = acSmcjVoApi:getDailyTaskList(curday)
		for k,v in pairs(taskList) do
			local idx = tonumber(RemoveFirstChar(k))
			local tkey = acSmcjVoApi:getTaskKey(curday,idx)
			local isfull = false
			if tkey=="au" then
				if accessoryVoApi:strengIsFull() then
					isfull = true
				end
			elseif tkey=="wp" then
				if superWeaponVoApi:isCanPlunder() then
					isfull = true
				end
			elseif tkey=="hu" then
				if heroEquipVoApi:isCanStreng() then
					isfull = true
				end
			elseif tkey=="rc" then
				if alienTechVoApi:isCanUpdate() then
					isfull = true
				end
			end
			if isfull==true then --某些功能满级相关任务自动完成
				if tskTb == nil then
					tskTb = {}
				end
				table.insert(tskTb,tkey) --插入到自动完成的列表中
			end
		end
		if tskTb then
			acSmcjVoApi:socketGet(tskTb,realInit) --通知服务器相关任务完成
		else
			realInit()
		end
	else
		realInit()
	end

	return self.bgLayer
end

function acSmcjTabOne:initUpPanel( )
	
	local function onLoadIcon(fn,icon)
		if icon and self and self.bgLayer then
		    icon:setAnchorPoint(ccp(0.5,1))
		    icon:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
		    self.bgLayer:addChild(icon)
		end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	--顶框
	local topBorder = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function() end)
	self.bgLayer:addChild(topBorder,1)
	topBorder:setAnchorPoint(ccp(0.5,1))
	topBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth,85))
	topBorder:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight-160))

	--倒计时 
	local timeLb = GetTTFLabel(acSmcjVoApi:getTimer(),25)
	timeLb:setColor(G_ColorYellowPro3)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight-170))
	self.timeLb = timeLb
	self.bgLayer:addChild(timeLb,1)

	local function touchInfo()
        local tabStr={}
        for i=1,6 do
        	if i == 4 then
        		table.insert(tabStr,getlocal("activity_smcj_tab1_tip"..i,{acSmcjVoApi:getMinRecharge()}))
        	else
        		table.insert(tabStr,getlocal("activity_smcj_tab1_tip"..i))
        	end
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
	end 

    local tipButton = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-160-40),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,-(self.layerNum-1)*20-4,1)

    -----------------------------------------------------------------------------------

    local bgWidth = G_VisibleSizeWidth
    local pox1,poy1 = 60 , G_VisibleSizeHeight - self.upHeight + 60
    local barWidth=500
    local curScore=acSmcjVoApi:getCurScore()
	local maxPoint=acSmcjVoApi:getNeedTopScore()

	local percentStr=""
	-- print("curScore===>>>",curScore)
	local per=acSmcjVoApi:getPer(curScore)--tonumber(curScore)/tonumber(maxPoint) * 100
	AddProgramTimer(self.bgLayer,ccp(bgWidth * 0.5 + 20,poy1),11,12,percentStr,"platWarProgressBg.png","taskBlueBar.png",13,1,1)
    local timerSpriteLv=self.bgLayer:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    self.timerSpriteLv = timerSpriteLv
    local timerSpriteBg=self.bgLayer:getChildByTag(13)
    timerSpriteBg=tolua.cast(timerSpriteBg,"CCSprite")
    local scalex=barWidth/timerSpriteLv:getContentSize().width
    timerSpriteBg:setScaleX(scalex)
    timerSpriteLv:setScaleX(scalex)

    local strSize3,strWidth2 = 17,500
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" then
		strSize3 = 20
	end

	local acSp=CCSprite:createWithSpriteFrameName("taskActiveSp.png")
	acSp:setPosition(ccp(pox1,poy1))
	self.bgLayer:addChild(acSp,2)
	local curScoreLb=GetBMLabel(curScore,G_GoldFontSrc,10)
	curScoreLb:setPosition(ccp(acSp:getContentSize().width * 0.5,acSp:getContentSize().height * 0.5-2))
	acSp:addChild(curScoreLb,2)
	curScoreLb:setScale(0.5)

	local todayAcPointLb=GetTTFLabelWrap(getlocal("totalScore"),21,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	todayAcPointLb:setAnchorPoint(ccp(0.5,0.5))
	todayAcPointLb:setPosition(ccp(pox1,poy1+70))
	self.bgLayer:addChild(todayAcPointLb,2)
	todayAcPointLb:setColor(G_ColorYellowPro2)

	local allScoreReward,nodeNum = acSmcjVoApi:getScoreReward( )
	print("nodeNum===>>>",nodeNum)
	for i=1,nodeNum do
		local needScore = allScoreReward[i].needScore
		local spacex=barWidth/nodeNum
		local px,py=pox1+i*spacex+27,poy1
		local acSp1=CCSprite:createWithSpriteFrameName("taskActiveSp1.png")
		acSp1:setPosition(ccp(px,py))
		self.bgLayer:addChild(acSp1,2)
		acSp1:setScale(1.4)
		local acSp2=CCSprite:createWithSpriteFrameName("taskActiveSp2.png")
		acSp2:setPosition(ccp(px,py))
		self.bgLayer:addChild(acSp2,2)
		acSp2:setScale(1.4)
		if curScore>=needScore then
			acSp1:setVisible(false)
		else
			acSp2:setVisible(false)
		end
		local numLb=GetBMLabel(needScore,G_GoldFontSrc,10)
		numLb:setPosition(ccp(px,py))
		self.bgLayer:addChild(numLb,3)
		numLb:setScale(0.3)

		local function clickBoxHandler( ... )
			if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local isNewReward=acSmcjVoApi:scoreOverIsReward(i)

            local function rewardPointCallback( ... )
				self:refreshScoreRewardInfo()
			end
			acSmcjVoApi:taskRewardSmallDialog(i,self.layerNum + 1,rewardPointCallback, allScoreReward[i].reward,curScore, needScore,isNewReward)
		end 
		px,py=px,py+55
		local boxScale=0.7
		local boxSp=LuaCCSprite:createWithSpriteFrameName("taskBox"..i..".png",clickBoxHandler)
		boxSp:setTouchPriority(-(self.layerNum-1)*20-5)
		boxSp:setPosition(ccp(px,py))
		self.boxPosTb[i] = ccp(px,py)
		self.bgLayer:addChild(boxSp,3)
		boxSp:setScale(boxScale)
		local isReward=acSmcjVoApi:scoreOverIsReward(i)
		-- if curScore>=needScore and isReward==false then
		-- 	local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
		--     lightSp:setAnchorPoint(ccp(0.5,0.5))
		--     lightSp:setPosition(ccp(px+5,py))
		--     self.bgLayer:addChild(lightSp)
		--     lightSp:setScale(0.7)
		--     self.lightSpTb[i] = lightSp
  --           local time = 0.1--0.07
	 --        local rotate1=CCRotateTo:create(time, 30)
	 --        local rotate2=CCRotateTo:create(time, -30)
	 --        local rotate3=CCRotateTo:create(time, 20)
	 --        local rotate4=CCRotateTo:create(time, -20)
	 --        local rotate5=CCRotateTo:create(time, 0)
	 --        local delay=CCDelayTime:create(1)
	 --        local acArr=CCArray:create()
	 --        acArr:addObject(rotate1)
	 --        acArr:addObject(rotate2)
	 --        acArr:addObject(rotate3)
	 --        acArr:addObject(rotate4)
	 --        acArr:addObject(rotate5)
	 --        acArr:addObject(delay)
	 --        local seq=CCSequence:create(acArr)
	 --        local repeatForever=CCRepeatForever:create(seq)
	 --        boxSp:runAction(repeatForever)
	 --        self.boxSpTb[i] = boxSp

		-- end
		if isReward==true then
			local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
	        lbBg:setScaleX(150/lbBg:getContentSize().width)
	        lbBg:setPosition(ccp(px,py))
	        self.bgLayer:addChild(lbBg,4)
	        lbBg:setScale(0.7)
	        local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),20)
			hasRewardLb:setPosition(ccp(px,py))
			self.bgLayer:addChild(hasRewardLb,5)
		end
	end
end

function acSmcjTabOne:refreshScoreRewardInfo() -- 目前仅用于领完奖励后干掉对应动画的需求
	local curScore=acSmcjVoApi:getCurScore()
	local allScoreReward,nodeNum = acSmcjVoApi:getScoreReward( )
	for i=1,nodeNum do
		local isReward=acSmcjVoApi:scoreOverIsReward(i)
		local needScore = allScoreReward[i].needScore
		-- if self.lightSpTb[i] and  curScore>=needScore and isReward then
		-- 	self.lightSpTb[i]:setVisible(false)
		-- 	self.lightSpTb[i]:removeFromParentAndCleanup(true)
		-- 	self.lightSpTb[i] = nil
		-- 	-- self.boxSpTb[i]:stopAllActions()
		-- 	-- self.boxSpTb[i]:setRotation(0)
		if isReward then
			local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
	        lbBg:setScaleX(150/lbBg:getContentSize().width)
	        lbBg:setPosition(self.boxPosTb[i])
	        self.bgLayer:addChild(lbBg,4)
	        lbBg:setScale(0.7)
	        local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),20)
			hasRewardLb:setPosition(self.boxPosTb[i])
			self.bgLayer:addChild(hasRewardLb,5)

		end
	end
end
function acSmcjTabOne:tick( )
	if self.initFlag~=true then
    	do return end
    end
	if self.timeLb then
    	self.timeLb:setString(acSmcjVoApi:getTimer())
    end
    local page=acSmcjVoApi:getNumDayOfActive()
    -- if page>self.num then
    -- 	for k,v in pairs(self.dlist) do
    --         if(v~=nil) and (self.page-k==1 or self.page==k) then
    --             v:refreshUI()
    --             v:refreshGoldRecharged()
    --         end
    --     end
    	
    --     return
    -- end
    if self.page~=page then
        self.page=page
        for k,v in pairs(self.dlist) do
            if(v~=nil) and (self.page-k==1 or self.page==k) then
                v:refreshUI()
                v:refreshGoldRecharged()
            end
        end
    end

 --    local curScore=acSmcjVoApi:getCurScore()
	-- local maxPoint=acSmcjVoApi:getNeedTopScore()
	-- local per=tonumber(curScore)/tonumber(maxPoint) * 100
	-- if self.timerSpriteLv then
	-- 	self.timerSpriteLv:setPercentage(per)
	-- end
end

function acSmcjTabOne:initDownPanel( )
	self.tvWidth,self.tvHeight = G_VisibleSizeWidth - 24, G_VisibleSizeHeight - self.upHeight - 15
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(12,15))
    self.bgLayer:addChild(tvBg)


    local sideLineSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("sideLine1.png",CCRect(2,2,1,1),function() end)
    sideLineSp1:setAnchorPoint(ccp(0,0))
    sideLineSp1:setContentSize(CCSizeMake(14,self.tvHeight + 10))
    sideLineSp1:setPosition(0,0)
    self.bgLayer:addChild(sideLineSp1,9999)

    local sideLineSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("sideLine2.png",CCRect(2,2,1,1),function() end)
    sideLineSp2:setAnchorPoint(ccp(1,0))
    sideLineSp2:setContentSize(CCSizeMake(14,self.tvHeight + 10))
    sideLineSp2:setPosition(G_VisibleSizeWidth,0)
    self.bgLayer:addChild(sideLineSp2,9999)
    

    self.list={}
    self.dlist={}
    local num=acSmcjVoApi:getNumOfDay()
    self.num=num
    for i=1,num do
        local atDialog=acSmcjTask:new(self)
        local layer=atDialog:init(self.layerNum, i, self.tvWidth, self.tvHeight)
        self.bgLayer:addChild(layer,1)

        layer:setPosition(ccp(0,0))

        self.list[i]=layer
        self.dlist[i]=atDialog
    end

    self.taskLayer=pageDialog:new()
    local page=acSmcjVoApi:getNumDayOfActive()
    -- print("++++++++page,num",page,num)
    if page>num then
        self.page=1
    else
        self.page=page
    end
    
    local isShowBg=false
    local isShowPageBtn=true
    local function onPage(topage)
        self.curTankTab=self.dlist[topage]
    end
    local posY=self.tvHeight - 20
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(self.tvWidth,posY)
    -- local version = acSmcjVoApi:getVersion()
    local pageLayer=self.taskLayer:create("panelItemBg.png",CCSizeMake(self.tvWidth,self.tvHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(20,15),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,nil,nil,nil,nil,nil,{true})
    self.curTankTab=self.dlist[1]
end

function acSmcjTabOne:initPageFlag()
end

function acSmcjTabOne:hidePageLayer()
    if self and self.taskLayer then
        if self.taskLayer.hide then
            self.taskLayer:hide()
        end
    end
end
function acSmcjTabOne:showPageLayer()
    if self and self.taskLayer then
        if self.taskLayer.show then
            self.taskLayer:show()
        end
    end
end