ltzdzSeasonSmallDialog=smallDialog:new()

function ltzdzSeasonSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- state 1:结算 2:开始
function ltzdzSeasonSmallDialog:showSeason(layerNum,istouch,isuseami,callBack,seaInfo,state)
	local sd=ltzdzSeasonSmallDialog:new()
    sd:initSeason(layerNum,istouch,isuseami,callBack,seaInfo,state)
    return sd
end

function ltzdzSeasonSmallDialog:initSeason(layerNum,istouch,isuseami,callBack,seaInfo,state)
	self.layerNum=layerNum
	self.istouch=istouch
	self.isuseami=isuseami
	self.state=state

	-- seaInfo={lastrp=200,currp=300,addpoint=100,rank=3}

	self.dialogLayer=CCLayer:create()
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchHandler()
    	if self.state==2 then
    		PlayEffect(audioCfg.mouseClick)
			self:close()
    	end
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,40,40),touchHandler)
    dialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(0,0)
    dialogBg:setAnchorPoint(ccp(0,0))
    dialogBg:setTouchPriority(-(self.layerNum-1)*20-1)

    G_addBlackLayer(dialogBg,120)
    -- dialogBg:setOpacity(0)
    self.bgLayer=dialogBg
    self:show()

    local dialogSize=dialogBg:getContentSize()

    local seasonPos=ccp(dialogSize.width/2,dialogSize.height/2+170)
    local seasonBg
    local function addSeasonBg()
    	seasonBg=CCSprite:create("public/ltzdz/ltzdz_season_bg.png")
	    self.bgLayer:addChild(seasonBg)
	    seasonBg:setPosition(seasonPos)
    end
    G_addResource8888(addSeasonBg)

    local titleStr=""
    local clancrossinfo=ltzdzVoApi.clancrossinfo
    if self.state==1 then
    	titleStr=getlocal("ltzdz_season_settlement",{(clancrossinfo.season or 1)-1})
    else
    	titleStr=getlocal("ltzdz_season_start",{(clancrossinfo.season or 1)})
    end

    local titleLb=GetTTFLabelWrap(titleStr,28,CCSizeMake(dialogSize.width - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    titleLb:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(titleLb)
    titleLb:setPosition(dialogSize.width/2,seasonPos.y+seasonBg:getContentSize().height/2-35)
    titleLb:setColor(G_ColorYellowPro)

    local displayPoint
    if self.state==1 then
    	displayPoint=seaInfo.lastrp or 0
    else
    	displayPoint=seaInfo.currp or 0
    end
    local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment(displayPoint)
	local function touchSeg()
	end
	local segIcon=ltzdzVoApi:getSegIcon(seg,smallLevel,touchSeg)
	-- segIcon:setScale(0.5)
	self.bgLayer:addChild(segIcon)
	segIcon:setPosition(seasonPos)

	local segNamePosY=seasonPos.y-segIcon:getContentSize().height/2-20
	local segName=ltzdzVoApi:getSegName(seg,smallLevel)
	local segNameLb=GetTTFLabelWrap(segName,25,CCSizeMake(dialogSize.width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	segNameLb:setAnchorPoint(ccp(0.5,1))
	self.bgLayer:addChild(segNameLb)
	segNameLb:setPosition(dialogSize.width/2,seasonPos.y-segIcon:getContentSize().height/2-20)

	local progressY=segNamePosY-60
	local perNum,proStr=ltzdzVoApi:getNextSegInfo(seaInfo.lastrp)
    local percent=perNum
    AddProgramTimer(self.bgLayer,ccp(dialogSize.width/2,progressY),518,nil,nil,"res_progressbg.png","resyellow_progress.png",519)
            
    local powerBar = tolua.cast(self.bgLayer:getChildByTag(518),"CCProgressTimer")
    local setScaleX=350/powerBar:getContentSize().width
    local setScaleY=40/powerBar:getContentSize().height
    powerBar:setScaleX(setScaleX)
    powerBar:setScaleY(setScaleY)
    powerBar:setPercentage(percent)

    local powerBarBg=tolua.cast(self.bgLayer:getChildByTag(519),"CCSprite")
    powerBarBg:setScaleX(setScaleX)
    powerBarBg:setScaleY(setScaleY)

    local percentLb=GetTTFLabel(proStr,23)
    percentLb:setAnchorPoint(ccp(0.5,0.5))
    percentLb:setPosition(powerBar:getContentSize().width/2,powerBar:getContentSize().height/2)
    powerBar:addChild(percentLb,4)
    percentLb:setScaleX(1/setScaleX)
    percentLb:setScaleY(1/setScaleY)

    -- 奖励
    if self.state==1 then

	    local rewardH=progressY-60
	    local rewardBg=G_getThreePointBg(CCSizeMake(dialogSize.width-60,140),nil,ccp(0.5,1),ccp(dialogSize.width/2,rewardH),self.bgLayer)

	    local rewardDesLb=GetTTFLabelWrap(getlocal("ltzdz_get_reward"),25,CCSizeMake(130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    rewardBg:addChild(rewardDesLb)
	    rewardDesLb:setAnchorPoint(ccp(0,0.5))
	    rewardDesLb:setPosition(10,rewardBg:getContentSize().height/2)

	    -- local warCfg=ltzdzVoApi:getWarCfg()
	    -- local rewardTb=warCfg.reward[tonumber(seaInfo.rank or 1)].reward
	    -- local itemTb=FormatItem(rewardTb,nil,true)
	    local itemTb=ltzdzVoApi:getFinalRewards(tonumber(seaInfo.rank or 1))

	    local startW=140
	    local rewardListH=rewardBg:getContentSize().height/2
	    for k,v in pairs(itemTb) do
	    	G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true,nil)
	    	local icon=G_getItemIcon(v,100,true,self.layerNum)
	    	icon:setAnchorPoint(ccp(0,0.5))
	    	icon:setPosition(startW+(k-1)*110,rewardListH)
	    	rewardBg:addChild(icon)
	    	icon:setTouchPriority(-(self.layerNum-1)*20-3)
	    end


		local function touchGetFunc()
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			PlayEffect(audioCfg.mouseClick)
			self:close()
			ltzdzVoApi:showSeasonSettle(self.layerNum,true,true,nil,seaInfo,2)
		end
		local btnH=70
		if(G_isIphone5()==false)then
			btnH=70
		else
			btnH=100
		end
		local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchGetFunc,2,getlocal("ltzdz_confirm_get"),25)
		local sureMenu=CCMenu:createWithItem(sureItem);
		sureMenu:setPosition(ccp(dialogSize.width/2,btnH))
		sureMenu:setTouchPriority(-(layerNum-1)*20-4);
		self.bgLayer:addChild(sureMenu)
	else
		local desH=progressY-60
		local desLb=GetTTFLabelWrap(getlocal("ltzdz_season_des1"),25,CCSizeMake(dialogSize.width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		self.bgLayer:addChild(desLb)
		desLb:setPosition(dialogSize.width/2,progressY)

		local arrowH=140
		if(G_isIphone5()==false)then
			arrowH=140
		else
			arrowH=170
		end
		G_addArrowPrompt(self.bgLayer,nil,arrowH)
	end


    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(0,0)
    return self.dialogLayer
end

function ltzdzSeasonSmallDialog:dispose()
	if self.state==2 then
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/ltzdz/ltzdz_season_bg.png")
	end
	self.state=nil
end