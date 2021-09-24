acJsysDialogTabOne={}
function acJsysDialogTabOne:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent=parent
	nc.trackPosYTb = {}
	nc.curTrackPosTb={}
	nc.curTrackTb={}
	nc.nextTrackPosTb={}
	nc.nextTrackTb={}
	nc.isTodayFlag=true
	nc.isEnd=false
    nc.freeBtn=nil
    nc.lotteryBtn=nil
    nc.multiLotteryBtn=nil
	nc.curAwardPosTb = {}
	nc.cell =nil
	nc.adaH = 0
	if G_getIphoneType() == G_iphoneX then
		nc.adaH =  1250 -1136
	end
	nc.trackAniBg = {}
	nc.flickerTb = {}
	nc.curTrackIconTb = {}
	nc.nextTrackIconTb = {}
	nc.curTrackIconScaleTb = {}
	nc.nextTrackIconScaleTb = {}
	nc.gearSp = nil
	nc.gearSpRotation = 0
	nc.refreshNext = false
	nc.onlyChangeAwardShow = false
	nc.touchDialog = nil
	nc.realShow = nil
	nc.isIphone5 = false
	nc.perText = nil
	nc.perTextBg = nil
	nc.lbColor={}
	nc.tDialogHeight = nil
	nc.randShow = nil
	nc.isRandShow = true
	return nc
end
function acJsysDialogTabOne:dispose( )
	if self.bgLayer then
		self.bgLayer:stopAllActions()
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.isRandShow = nil
    self.tDialogHeight = nil
    self.lbColor=nil
	self.parent=nil
	self.trackPosYTb = nil
	self.curTrackPosTb=nil
	self.curTrackTb=nil
	self.nextTrackPosTb=nil
	self.nextTrackTb=nil
	self.isTodayFlag=nil
	self.isEnd=nil
    self.freeBtn=nil
    self.lotteryBtn=nil
    self.multiLotteryBtn=nil
	self.curAwardPosTb = nil
	self.cell = nil
	self.trackAniBg = nil
	self.flickerTb = nil
	self.curTrackIconTb = {}
	self.nextTrackIconTb = {}
	self.curTrackIconScaleTb = {}
	self.nextTrackIconScaleTb = {}
	self.gearSp = nil
	self.gearSpRotation = nil
	self.refreshNext = false
	self.onlyChangeAwardShow = false
	self.touchDialog = nil
	self.realShow = nil
	self.isIphone5 = nil
	self.perText = nil
	self.perTextBg = nil
	self.randShow = nil
	self.adaH = nil
end
function acJsysDialogTabOne:init(layerNum)
	if G_isIphone5() then
		self.isIphone5 = true
	end
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self.lbColor={G_ColorWhite,G_ColorBlue,G_ColorYellowPro}
	self:initTimeLabel()

	self.midBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	self.midBg:setAnchorPoint(ccp(0.5,1))
	self.midBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight*0.6+self.adaH/3))
	self.midBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.upbackSp:getPositionY() - self.upbackSp:getContentSize().height+25))
	self.bgLayer:addChild(self.midBg)

	self:initBar()
	self:initAwardAndRecord()
	self:initTableView()
	self:initBtn()

	self:runRandAutoChoose()
	return self.bgLayer
end

function acJsysDialogTabOne:initTimeLabel( )
	local function bgClick()
    end
    local h=G_VisibleSizeHeight-160
    local w=G_VisibleSizeWidth-50 --背景框的宽度
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),bgClick)
    backSprie:setContentSize(CCSizeMake(w,120))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2,h))
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    self.upbackSp = backSprie
    backSprie:setOpacity(0)
    self.bgLayer:addChild(backSprie,1)

	local function touchDialog()
	end
	self.tDialogHeight = 80
	self.touchDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	self.touchDialog:setTouchPriority(-(self.layerNum-1)*20-99)
	self.touchDialog:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-self.tDialogHeight))
	self.touchDialog:setOpacity(0)
	self.touchDialog:setIsSallow(true) -- 点击事件透下去
	self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
	self.bgLayer:addChild(self.touchDialog,99)


    local descStr1=acJsysVoApi:getTimeStr()
    local descStr2=acJsysVoApi:getRewardTimeStr()
    local moveBgStarStr,timeLb,rewardLb=G_LabelRollView(CCSizeMake(backSprie:getContentSize().width,70),descStr1,23,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
    self.timeLb=timeLb
    self.rewardLb=rewardLb
    self:updateAcTime()
    moveBgStarStr:setPosition(ccp(0,backSprie:getContentSize().height-moveBgStarStr:getContentSize().height-40))
    backSprie:addChild(moveBgStarStr)

    local function infoHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr=acJsysVoApi:getTabOneHelpInfo()

        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end

    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",infoHandler)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(backSprie:getContentSize().width-10,backSprie:getContentSize().height-60))
    backSprie:addChild(menuDesc)
end

function acJsysDialogTabOne:initBar( )
	local midPosX = self.midBg:getContentSize().width*0.5

	local bgSp1=CCSprite:createWithSpriteFrameName("groupSelf.png")
	bgSp1:setPosition(ccp(midPosX,self.midBg:getContentSize().height-3));
	bgSp1:setAnchorPoint(ccp(0.5,1))
	local bgSp1ScalY = 50/bgSp1:getContentSize().height
	bgSp1:setScaleY(bgSp1ScalY)
	bgSp1:setScaleX(600/bgSp1:getContentSize().width)
	self.midBg:addChild(bgSp1)

	self.percent,self.limitIdx,self.poolLimitNum = acJsysVoApi:getCurScoreAndPercent( )

	self.awardLibraryLb = GetTTFLabelWrap(getlocal("activity_jsss_award"..self.limitIdx),25,CCSizeMake(600,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.awardLibraryLb:setColor(self.lbColor[self.limitIdx])
	self.awardLibraryLb:setPosition(ccp(midPosX,bgSp1:getPositionY()- bgSp1:getContentSize().height*bgSp1ScalY*0.5))
	self.midBg:addChild(self.awardLibraryLb)

	local subPosY = self.isIphone5 and 65 or 50

	if G_getIphoneType() == G_iphoneX then
		subPosY = subPosY + 40
	end

	local barPos = ccp(midPosX,bgSp1:getPositionY()- bgSp1:getContentSize().height*bgSp1ScalY-subPosY)
	self.barPosY = barPos.y
    local timerSprite,pgSprite = AddProgramTimer(self.midBg,barPos,11,nil,nil,"orangeProgressBarBg.png","orangeProgressBar.png",12,0.9,1,nil,ccp(1,0))
    --print("self.percent------>",self.percent)
    if self.percent < 0 then
		self.percent = 0
	end
    timerSprite:setPercentage(self.percent*100)----------------------
    self.timerSprite = timerSprite
    self.pgSprite = pgSprite
    self.barBg = tolua.cast(self.midBg:getChildByTag(12),"CCSprite")

    self.barLengh = self.barBg:getContentSize().width*0.9
    self.initGearPosX = (midPosX - self.barLengh*0.5)*0.9
    self.gearSp = CCSprite:createWithSpriteFrameName("gear.png")
    self.gearSp:setPosition(ccp(self.initGearPosX + self.barLengh*self.percent,barPos.y))----------------------
    self.midBg:addChild(self.gearSp,3)


    self.perTextBg = LuaCCScale9Sprite:createWithSpriteFrameName("tipBg.png",CCRect(28, 18, 1, 1),function ()end)
    self.perTextBg:setAnchorPoint(ccp(0.5,0))
    self.perTextBg:setPosition(ccp(self.initGearPosX + self.barLengh*self.percent,barPos.y+12))
    self.midBg:addChild(self.perTextBg)

    self.perText = GetTTFLabel(tostring(self.percent*100).."%",22)
    self.perTextBg:addChild(self.perText)
    self.perTextBg:setContentSize(CCSizeMake(self.perText:getContentSize().width+14,self.perText:getContentSize().height+14))
    self.perText:setPosition(self.perTextBg:getContentSize().width*0.5,self.perTextBg:getContentSize().height*0.65)
end

function acJsysDialogTabOne:initAwardAndRecord( )
    
	local btnPosY = self.upbackSp:getPositionY() - self.upbackSp:getContentSize().height
	if G_getIphoneType() == G_iphoneX then
		btnPosY = btnPosY - 30
    end
	--奖励库
	local function rewardPoolHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        --显示奖池
        local content={}
        local pool=acJsysVoApi:getRewardPool()
        for k,rewardlist in pairs(pool) do
            local item={}
            item.rewardlist=rewardlist
            item.title={getlocal("activity_jsss_award"..k),G_ColorYellowPro,25}
            table.insert(content,item)
        end
        local title={getlocal("award"),nil,30}
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
        acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),title,content,self.layerNum+1,nil,nil,nil,true)
    end
    local poolBtn=GetButtonItem("CommonBox.png","CommonBox.png","CommonBox.png",rewardPoolHandler,11)
    
    poolBtn:setAnchorPoint(ccp(0,1))
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    poolMenu:setPosition(ccp(30,btnPosY))
    self.bgLayer:addChild(poolMenu,1)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,1))
    poolBg:setContentSize(CCSizeMake(80,40))
    poolBg:setPosition(ccp(poolBtn:getContentSize().width/2,0))
    poolBg:setScale(1/poolBtn:getScale())
    poolBtn:addChild(poolBg)
    local poolLb=GetTTFLabelWrap(getlocal("award"),22,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    poolLb:setColor(G_ColorYellowPro)
    poolBg:addChild(poolLb)


    local function logHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:logHandler()
    end
   
    local logBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",logHandler,11)
    
    logBtn:setAnchorPoint(ccp(1,1))
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    logMenu:setPosition(ccp(G_VisibleSizeWidth-30,btnPosY))
    self.bgLayer:addChild(logMenu,1)
    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,0))
    logBg:setScale(1/logBtn:getScale())
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logLb:setColor(G_ColorYellowPro)
    logBg:addChild(logLb)

    if G_getIphoneType() == G_iphoneX then
    	poolBtn:setScale(0.6)
	    logBtn:setScale(0.8)
	    poolBg:setScale(1/poolBtn:getScale())
		logBg:setScale(1/logBtn:getScale())
		poolMenu:setPosition(ccp(15,btnPosY-25))
		logMenu:setPosition(ccp(G_VisibleSizeWidth-30,btnPosY-25))
    elseif self.isIphone5 then
	    poolBtn:setScale(0.6)
	    logBtn:setScale(0.8)
	    poolBg:setScale(1/poolBtn:getScale())
		logBg:setScale(1/logBtn:getScale())
		poolMenu:setPosition(ccp(15,btnPosY-25))
		logMenu:setPosition(ccp(G_VisibleSizeWidth-30,btnPosY-25))
	else
		poolBtn:setScale(0.4)
		logBtn:setScale(0.5)
		poolMenu:setPosition(ccp(40,btnPosY-30))
		logMenu:setPosition(ccp(G_VisibleSizeWidth-40,btnPosY-30))
		poolBg:setScale(1/poolBtn:getScale())
		logBg:setScale(1/logBtn:getScale())
	end
end

function acJsysDialogTabOne:logHandler()
	print("show record~~~~~")
    local function showLog()
        local rewardLog=acJsysVoApi:getRewardLog() or {}
        if rewardLog and SizeOfTable(rewardLog)>0 then
            local logList={}
            for k,v in pairs(rewardLog) do
                local num,reward,time,point=v.num,v.reward,v.time,v.point
                local title
                if base.hexieMode==1 then
                    title={getlocal("activity_jsss_hx_logt",{num,point})}
                else
                    title={getlocal("activity_jsss_logt",{num,point})}
                end
                local content={{reward}}
                local log={title=title,content=content,ts=time}
                table.insert(logList,log)
            end
            local logNum=SizeOfTable(logList)
            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
        end
    end
    local rewardLog=acJsysVoApi:getRewardLog()
    if rewardLog then
        showLog()
    else
        acJsysVoApi:acJsysRequest({action=3},showLog)
    end
end

function acJsysDialogTabOne:initTableView( )
	local tvPos = ccp((G_VisibleSizeWidth-self.midBg:getContentSize().width)*0.5+5,self.midBg:getPositionY()-self.midBg:getContentSize().height+10+self.adaH/10)
	local tvContentSize = CCSizeMake(self.midBg:getContentSize().width-10,self.midBg:getContentSize().height*0.75-10)
	self.tvContentSize = tvContentSize
	-- local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	-- tvBg:setAnchorPoint(ccp(0,0))
	-- tvBg:setContentSize(tvContentSize)

	-- tvBg:setPosition(tvPos)
	-- self.bgLayer:addChild(tvBg)

	local function eventHandler( ... )
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(eventHandler)
	self.tv=LuaCCTableView:createWithEventHandler(hd,tvContentSize,nil)
	self.tv:setPosition(tvPos)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setMaxDisToBottomOrTop(0)
	self.bgLayer:addChild(self.tv)
end

function acJsysDialogTabOne:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return  self.tvContentSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self.cell = cell
		self.trackPosYTb = {1,0.5,0}
		if G_getIphoneType() == G_iphoneX then
			self.trackPosYTb = {0.9,0.5,0.1}
		end
		-- local nodata,limitIdx,nodata2 = acJsysVoApi:getCurScoreAndPercent( )
		-- print("limitIdx---->",limitIdx)
		local curAwardTb = acJsysVoApi:getRewardPool(self.limitIdx)
		local awardNum = SizeOfTable(curAwardTb)+1
		local awardIdx = 1
		for i=1,3 do
			local trackPic = CCSprite:createWithSpriteFrameName("track.png")
			trackPic:setAnchorPoint(ccp(1,self.trackPosYTb[i]))
			self.curTrackPosTb[i] = ccp(self.tvContentSize.width,self.tvContentSize.height*self.trackPosYTb[i])
			self.curTrackTb[i] = trackPic
			trackPic:setPosition(self.curTrackPosTb[i])
			cell:addChild(trackPic)

			awardIdx = 1+ (i-1)*5
			for j=1,5 do
				local itemTb = curAwardTb[awardIdx]
				-- print("awardIdx---->",awardIdx)
				local function callback( )
					G_showNewPropInfo(self.layerNum+1,true,nil,nil,itemTb,nil,nil,nil)
				end 
				local icon,scale=G_getItemIcon(itemTb,85,false,self.layerNum,callback,nil)
				self.curTrackIconTb[awardIdx] = icon
				self.curTrackIconScaleTb[awardIdx] = scale
				trackPic:addChild(icon)
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				self.curAwardPosTb[j+(i-1)*5] = ccp(trackPic:getContentSize().width*0.167*j,trackPic:getContentSize().height*0.5)
				icon:setPosition(self.curAwardPosTb[j+(i-1)*5])
				awardIdx = awardIdx +1

				local numLabel=GetTTFLabel("x"..itemTb.num,21)
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon:getContentSize().width-5, 5)
                numLabel:setScale(1/scale)
                icon:addChild(numLabel,1)
			end
		end
		self.curAwardTb = curAwardTb
		local nextAwardTb = acJsysVoApi:getRewardPool( self.limitIdx == 3 and 1 or self.limitIdx+1)
		self.nextAwardTb = nextAwardTb
		local awardIdx2 = 1
		for i=1,3 do
			local trackPic = CCSprite:createWithSpriteFrameName("track.png")
			trackPic:setAnchorPoint(ccp(1,self.trackPosYTb[i]))
			self.nextTrackPosTb[i] = ccp(0,self.tvContentSize.height*self.trackPosYTb[i])
			self.nextTrackTb[i] = trackPic
			trackPic:setPosition(self.nextTrackPosTb[i])
			cell:addChild(trackPic)

			awardIdx2 = 1+ (i-1)*5
			for j=1,5 do
				local itemTb = nextAwardTb[awardIdx2]
				local function callback( )
					G_showNewPropInfo(self.layerNum+1,true,nil,nil,nextAwardTb[awardIdx2],nil,nil,nil)
				end 
				local icon,scale=G_getItemIcon(nextAwardTb[awardIdx2],85,false,self.layerNum,callback,nil)
				self.nextTrackIconTb[awardIdx2] = icon
				self.nextTrackIconScaleTb[awardIdx2] = scale
				trackPic:addChild(icon)
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				icon:setPosition(self.curAwardPosTb[j+(i-1)*5])
				awardIdx2 = awardIdx2 +1

				local numLabel=GetTTFLabel("x"..itemTb.num,21)
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon:getContentSize().width-5, 5)
                numLabel:setScale(1/scale)
                icon:addChild(numLabel,1)
			end
		end
		
		

		return cell
	end
end

function acJsysDialogTabOne:initBtn( )
	if base.hexieMode==1 then
        local offsetY,strSize2 =0,20
        if G_isIphone5()==true then
        	offsetY ,strSize2 = 10,25
        end
        local hxReward=acJsysVoApi:getHexieReward()
        local promptLb=GetTTFLabelWrap(getlocal("activity_jsss_hexiePro",{hxReward.name}),strSize2,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        promptLb:setAnchorPoint(ccp(0.5,1))
        promptLb:setPosition(ccp(self.midBg:getContentSize().width*0.5,-2-offsetY))
        promptLb:setColor(G_ColorYellowPro)
        self.midBg:addChild(promptLb)
    end

	local cost1,cost2=acJsysVoApi:getLotteryCost()
	local btnPosY = self.isIphone5 and 60 or 40
    local function lotteryHandler()
        self:lotteryHandler()
    end
    self.freeBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,btnPosY),lotteryHandler)
    self.lotteryBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,btnPosY),lotteryHandler,cost1)

    local function multiLotteryHandler()
        self:lotteryHandler(true)
    end
    local num=acJsysVoApi:getMultiNum()
    self.multiLotteryBtn=self:getLotteryBtn(num,ccp(G_VisibleSizeWidth/2+120,btnPosY),multiLotteryHandler,cost2,true)
    self:refreshLotteryBtn()
    self:tick()
end
function acJsysDialogTabOne:getLotteryBtn(num,pos,callback,cost,isMul)
    local btnZorder,btnFontSize=2,25
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
    end
    local lotteryBtn
    local btnScale=0.8
    if cost and tonumber(cost)>0 then
        local btnStr=""
        if base.hexieMode==1 then
            btnStr=getlocal("activity_qxtw_buy",{num})
        else
            btnStr=getlocal("activity_customLottery_common_btn",{num})
        end
        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,btnStr,btnFontSize/btnScale,11)
        local costLb=GetTTFLabel(tostring(cost),25)
        costLb:setAnchorPoint(ccp(0,0.5))
        costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1/btnScale)
        lotteryBtn:addChild(costLb)
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        costSp:setScale(1/btnScale)
        lotteryBtn:addChild(costSp)
        local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
        costLb:setPosition(lotteryBtn:getContentSize().width/2-lbWidth/2,lotteryBtn:getContentSize().height+costLb:getContentSize().height/2+8)
        costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
    else
        lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",lotteryHandler,nil,getlocal("daily_lotto_tip_2"),btnFontSize/btnScale,11)
    end
    lotteryBtn:setScale(btnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setPosition(pos)
    self.bgLayer:addChild(lotteryMenu,btnZorder)

    return lotteryBtn
end

function acJsysDialogTabOne:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then
        if acJsysVoApi:isEnd() ==false and acJsysVoApi:acIsStop() ==false then
             local freeFlag=acJsysVoApi:isFreeLottery()
             print("freeFlag------>",freeFlag)
            if freeFlag==1 then
                self.lotteryBtn:setVisible(false)
                self.freeBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(false)
            else
                self.freeBtn:setVisible(false)
                self.lotteryBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(true)
            end
        else
        	self.lotteryBtn:setEnabled(false)
            self.freeBtn:setEnabled(false)
            self.lotteryBtn:setVisible(true)
            self.freeBtn:setVisible(false)
            self.multiLotteryBtn:setEnabled(false)
        end
    end
end

function acJsysDialogTabOne:tick()
    local isEnd=acJsysVoApi:isEnd()
    if isEnd==false then
        local todayFlag=acJsysVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            acJsysVoApi:resetFreeLottery()
            self:refreshLotteryBtn()
        end
        -- if self then
        --   self:updateAcTime()
        -- end
    end
    self:updateAcTime()
end

function acJsysDialogTabOne:updateAcTime()
    local acVo=acJsysVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb,self.rewardLb)
    end
end
function acJsysDialogTabOne:returnRealShow( )
	
end
function acJsysDialogTabOne:lotteryHandler(multiFlag)
    local multiFlag=multiFlag or false
    local function realLottery(num,cost)
        local function callback(pt,point,rewardlist,hxReward)
        	self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then
                local function realShow()
                	self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
                    local function showEndHandler()
                        G_showRewardTip(rewardlist,true)
                        self:cleanAwardIconBorder()
                        self.isRandShow = true
                        self:runRandAutoChoose()
                    end
                    local addStrTb
                    if pt and SizeOfTable(pt)>0 then
                        addStrTb={}
                        for k,v in pairs(pt) do
                            local addStr=""
                            table.insert(addStrTb,getlocal("scoreAdd",{v or 0}))
                        end
                    end
                    if hxReward then
                        table.insert(rewardlist,1,hxReward)
                        table.insert(addStrTb,1,"")
                    end
                    local titleStr=getlocal("activity_wheelFortune4_reward")
                    local titleStr2=getlocal("activity_tccx_total_score")..getlocal("scoreAdd",{point})
                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr,titleStr2,addStrTb,nil,"jsss")
                end
                self.realShow = realShow
                self.isRandShow = false
                self:stopRandAutoChoose()
                self:showActionLayer(pt,point,rewardlist,realShow)---加自己的动画
            end
            self:refreshLotteryBtn()
        end
        local freeFlag=acJsysVoApi:isFreeLottery()
        print("num----free----->",num,freeFlag)
        acJsysVoApi:acJsysRequest({action=1,num=num,free=freeFlag},callback)
    end

    local cost1,cost2=acJsysVoApi:getLotteryCost()
    local cost,num=0,1
    if acJsysVoApi:isToday()==false then
        acJsysVoApi:resetFreeLottery()
    end
    local freeFlag=acJsysVoApi:isFreeLottery()
    if cost1 and cost2 then
        if multiFlag==false and freeFlag==0 then
            cost=cost1
        elseif multiFlag==true then
            cost=cost2
            num=acJsysVoApi:getMultiNum()
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        local function sureClick()
        	print("cost---sureClick-->",cost)
            realLottery(num,cost)
        end
        local function secondTipFunc(sbFlag)
            local keyName=acJsysVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if cost and cost>0 then
            local keyName=acJsysVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
        else
            sureClick()
        end
    end
end


function acJsysDialogTabOne:showActionLayer(pt,point,rewardlist,realShow)
	local awardPosTb,nextAwardPosTb,trackPosTb1,trackPosTb2 = acJsysVoApi:getCurAwardPos(self.curAwardTb,self.nextAwardTb,rewardlist)
	self:showTracking(trackPosTb1,awardPosTb,realShow,trackPosTb2,nextAwardPosTb)
end
--isNext 判断是否为递归的第二次 （最大次数应该就两次）
function acJsysDialogTabOne:showTracking(trackPosTb,awardPosTb,rewardDialogCall,trackPosTb2,nextAwardPosTb,isNext)
	local onceDo = 0
	for k,v in pairs(trackPosTb) do
		if v and self.cell then
			onceDo = onceDo + 1
			local needPosy = 0
			local trackAniBg = CCSprite:createWithSpriteFrameName("tracking_1.png")

			if k == 1 then
				needPosy = (trackAniBg:getContentSize().height - self.curTrackTb[k]:getContentSize().height)*0.5 
			elseif k == 3 then
				needPosy = -(trackAniBg:getContentSize().height - self.curTrackTb[k]:getContentSize().height)*0.5 
			end
			-- print("needPosy----->",needPosy,k)
			trackAniBg:setAnchorPoint(ccp(1,self.trackPosYTb[k]))
			trackAniBg:setPosition(ccp(self.curTrackPosTb[k].x , self.curTrackPosTb[k].y + needPosy))
			trackAniBg:setVisible(false)
			self.trackAniBg[k] = trackAniBg--点击屏幕 停止动画的时候时候
			self.cell:addChild(trackAniBg,10)

			  local pzArr=CCArray:create()
			  for kk=1,18 do
	              local nameStr="tracking_"..kk..".png"
	              local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	              pzArr:addObject(frame)
	          end
	          local animation=CCAnimation:createWithSpriteFrames(pzArr)
	          animation:setDelayPerUnit(0.05)
	          local animate=CCAnimate:create(animation)  

	          local function showFun( )
	          		trackAniBg:setVisible(true)
	          end 
	          local function onlyRemoveSelf( )
	          		self.trackAniBg[k] = nil
		          	trackAniBg:removeFromParentAndCleanup(true)
	          end 
	          local function gearingCall()
	          	-- print(" in gearingCall~~~~~~~!!!!!!@@@@@######")
	          	self.trackAniBg[k] = nil
	          	trackAniBg:removeFromParentAndCleanup(true)
	          		if isNext then
	          			for k,v in pairs(awardPosTb) do
		          			G_addRectFlicker(self.nextTrackIconTb[v],1.1/self.nextTrackIconScaleTb[v],1.1/self.nextTrackIconScaleTb[v])
		          			-- G_addRectFlicker2(self.nextTrackIconTb[v],1.1/self.nextTrackIconScaleTb[v],1.1/self.nextTrackIconScaleTb[v],3,"y")
		          		end
	          		else
		          		for k,v in pairs(awardPosTb) do
		          			G_addRectFlicker(self.curTrackIconTb[v],1.1/self.curTrackIconScaleTb[v],1.1/self.curTrackIconScaleTb[v])
		          			-- G_addRectFlicker2(self.curTrackIconTb[v],1.1/self.curTrackIconScaleTb[v],1.1/self.curTrackIconScaleTb[v],3,"y")
		          		end
		          	end
		          	self:runBarAction(rewardDialogCall,trackPosTb2,nextAwardPosTb)--跑起进度条
	          end 
	          local shwoCall = CCCallFunc:create(showFun)
	          local gearCall = CCCallFunc:create(onceDo == 1 and gearingCall or onlyRemoveSelf)
	          local acArr=CCArray:create()
	          acArr:addObject(shwoCall)
	          acArr:addObject(animate)
	          acArr:addObject(gearCall)
              local seq=CCSequence:create(acArr)
              trackAniBg:runAction(seq)
		end
	end
end

function acJsysDialogTabOne:runBarAction(rewardDialogCall,trackPosTb2,nextAwardPosTb)
	local percent,newPercent = nil,nil

		percent,self.limitIdx,self.poolLimitNum,newPercent = acJsysVoApi:getPercentActionData(self.limitIdx,self.poolLimitNum,nextAwardPosTb,self.refreshNext)
		local function runningBar(rewardDialogCall,trackPosTb2,nextAwardPosTb)
			if self.percent < 0 then
				self.percent = 0
			end
			local function loopRun( )
				-- print("self.percent ,percent,newPercent",self.percent , percent,newPercent,nextAwardPosTb)
				if self.percent < percent then
					-- print("self.percent ,percent",self.percent , percent)
					self.percent = self.percent + 0.02
					if self.percent > percent then
						self.percent = percent 
					end
					self.gearSpRotation = self.gearSpRotation +14
					self.timerSprite:setPercentage(self.percent*100)
					self.gearSp:setPosition(ccp(self.initGearPosX + self.barLengh*self.percent,self.barPosY))
					self.gearSp:setRotation(self.gearSpRotation)

					self.perTextBg:setPosition(ccp(self.initGearPosX + self.barLengh*self.percent,self.barPosY+12))
					self.perText:setString(tostring(self.percent*100).."%")
			    	self.perTextBg:setContentSize(CCSizeMake(self.perText:getContentSize().width+14,self.perText:getContentSize().height+14))
				    self.perText:setPosition(self.perTextBg:getContentSize().width*0.5,self.perTextBg:getContentSize().height*0.65)

					runningBar(rewardDialogCall,trackPosTb2,nextAwardPosTb)
				elseif newPercent then
					percent = tonumber(newPercent)
					newPercent = nil
					self.percent = 0
					self.timerSprite:setPercentage(self.percent*100)
					self.gearSp:setPosition(ccp(self.initGearPosX + self.barLengh*self.percent,self.barPosY))

					self.perTextBg:setPosition(ccp(self.initGearPosX + self.barLengh*self.percent,self.barPosY+15))
					self.perText:setString(tostring(self.percent*100).."%")
					self.perTextBg:setContentSize(CCSizeMake(self.perText:getContentSize().width+14,self.perText:getContentSize().height+14))
				    self.perText:setPosition(self.perTextBg:getContentSize().width*0.5,self.perTextBg:getContentSize().height*0.65)

					if nextAwardPosTb then
						self:changeAwardShowAction(rewardDialogCall,trackPosTb2,nextAwardPosTb)
					else
						self.onlyChangeAwardShow = true
						runningBar(rewardDialogCall)
					end
				elseif rewardDialogCall then
					local function callDial( )
						self.percent = percent 
						if self.onlyChangeAwardShow then
							self.onlyChangeAwardShow = false
							self:onlyChangeAwardShowAwardAction(rewardDialogCall)
						else
							rewardDialogCall()	
						end
					end 
					local ccfun = CCCallFunc:create(callDial)
					local delayT = CCDelayTime:create(0.3)
					local arr = CCArray:create()
					arr:addObject(delayT)
					arr:addObject(ccfun)
					local seq = CCSequence:create(arr)
					self.midBg:runAction(seq)
					
				end
			end 
			local delayT = CCDelayTime:create(0.001)
			local ccfun = CCCallFunc:create(loopRun)
			local arr = CCArray:create()
			arr:addObject(delayT)
			arr:addObject(ccfun)
			local seq = CCSequence:create(arr)
			self.midBg:runAction(seq)

		end 
		runningBar(rewardDialogCall,trackPosTb2,nextAwardPosTb)
	-- end
end

function acJsysDialogTabOne:onlyChangeAwardShowAwardAction(rewardDialogCall)
	for k,v in pairs(self.curTrackTb) do
		local newPos = ccp(v:getPositionX()+self.tvContentSize.width,v:getPositionY())
		local movTo = CCMoveTo:create(0.3,newPos)
		v:runAction(movTo)
	end
	
	for k,v in pairs(self.nextTrackTb) do
		local newPos = ccp(v:getPositionX()+self.tvContentSize.width,v:getPositionY())
		local movTo = CCMoveTo:create(0.3,newPos)
		if k ==1 then
			local function nextAwardShowAction( )
				--清除上一次奖励图标，交替tb
				self.awardLibraryLb:setString(getlocal("activity_jsss_award"..self.limitIdx))
				self.awardLibraryLb:setColor(self.lbColor[self.limitIdx])
				self.refreshNext = true
				if rewardDialogCall then
					rewardDialogCall()
				end
			end 
			local ccfun = CCCallFunc:create(nextAwardShowAction)
			local delayT = CCDelayTime:create(0.3)
			local arr = CCArray:create()
			arr:addObject(movTo)
			arr:addObject(delayT)
			arr:addObject(ccfun)
			local seq = CCSequence:create(arr)
			v:runAction(seq)
		else 
			v:runAction(movTo)
		end
	end	
end

function acJsysDialogTabOne:changeAwardShowAction(rewardDialogCall,trackPosTb2,nextAwardPosTb)
	for k,v in pairs(self.curTrackTb) do
		local newPos = ccp(v:getPositionX()+self.tvContentSize.width,v:getPositionY())
		local movTo = CCMoveTo:create(0.3,newPos)
		v:runAction(movTo)
	end
	
	for k,v in pairs(self.nextTrackTb) do
		local newPos = ccp(v:getPositionX()+self.tvContentSize.width,v:getPositionY())
		local movTo = CCMoveTo:create(0.3,newPos)
		if k ==1 then
			local function nextAwardShowAction( )
				--清除上一次奖励图标，交替tb
				self.awardLibraryLb:setString(getlocal("activity_jsss_award"..self.limitIdx))
				self.awardLibraryLb:setColor(self.lbColor[self.limitIdx])
				self.refreshNext = true
				self:showTracking(trackPosTb2,nextAwardPosTb,rewardDialogCall,nil,nil,true)
			end 
			local ccfun = CCCallFunc:create(nextAwardShowAction)
			local delayT = CCDelayTime:create(0.1)
			local arr = CCArray:create()
			arr:addObject(movTo)
			arr:addObject(delayT)
			arr:addObject(ccfun)
			local seq = CCSequence:create(arr)
			v:runAction(seq)
		else 
			v:runAction(movTo)
		end
	end	
end
function acJsysDialogTabOne:cleanAwardIconBorder( )
	
	for k,v in pairs(self.curTrackIconTb) do
		G_removeFlicker(v)
	end
	for k,v in pairs(self.nextTrackIconTb) do
		G_removeFlicker(v)
	end
	if self.refreshNext then
		print("in self.refreshNext~~@#~#@!#@~#~#@#@~#@!~#@!")
		for k,v in pairs(self.curTrackIconTb) do
			v:removeFromParentAndCleanup(true)
		end
		for k,v in pairs(self.nextTrackIconTb) do
			v:removeFromParentAndCleanup(true)
		end
		self.nextTrackIconTb = {}
		self.nextTrackIconTb = {}
		self.curTrackIconScaleTb = {}
		self.nextTrackIconScaleTb = {}
		--交替 重置轨道
		local localTrackTb = self.curTrackTb
		self.curTrackTb = self.nextTrackTb
		self.nextTrackTb = localTrackTb
		for k,v in pairs(self.nextTrackTb) do
			v:setPosition(self.nextTrackPosTb[k])
		end

		self.curAwardTb = acJsysVoApi:getRewardPool(self.limitIdx)
		self.nextAwardTb = acJsysVoApi:getRewardPool( self.limitIdx == 3 and 1 or self.limitIdx+1)

		local awardIdx = 1
		for i=1,3 do
			awardIdx = 1+ (i-1)*5
			for j=1,5 do
				local itemTb = self.curAwardTb[awardIdx]

				local function callback( )
					G_showNewPropInfo(self.layerNum+1,true,nil,nil,itemTb,nil,nil,nil)
				end 
				local icon,scale=G_getItemIcon(itemTb,85,false,self.layerNum,callback,nil)
				self.curTrackIconTb[awardIdx] = icon
				self.curTrackIconScaleTb[awardIdx] = scale
				self.curTrackTb[i]:addChild(icon)
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				icon:setPosition(self.curAwardPosTb[j+(i-1)*5])
				awardIdx = awardIdx +1
				local numLabel=GetTTFLabel("x"..itemTb.num,21)
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon:getContentSize().width-5, 5)
                numLabel:setScale(1/scale)
                icon:addChild(numLabel,1)
			end
		end

		local awardIdx2 = 1
		for i=1,3 do
			awardIdx2 = 1 + (i-1)*5
			for j=1,5 do
				local itemTb = self.nextAwardTb[awardIdx2]
				local function callback( )
					G_showNewPropInfo(self.layerNum+1,true,nil,nil,itemTb,nil,nil,nil)
				end 
				local icon,scale=G_getItemIcon(itemTb,85,false,self.layerNum,callback,nil)
				self.nextTrackIconTb[awardIdx2] = icon
				self.nextTrackIconScaleTb[awardIdx2] = scale
				self.nextTrackTb[i]:addChild(icon)
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				icon:setPosition(self.curAwardPosTb[j+(i-1)*5])
				awardIdx2 = awardIdx2 +1

				local numLabel=GetTTFLabel("x"..itemTb.num,21)
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon:getContentSize().width-5, 5)
                numLabel:setScale(1/scale)
                icon:addChild(numLabel,1)
			end
		end
		self.refreshNext = false
	end
	
end

function acJsysDialogTabOne:runRandAutoChoose()
    if self == nil or self.bgLayer == nil then
        return
    end

	local function randCallBack( )
		if self.curTrackIconTb then
			self.randNum0 = math.random(1,3)
			self.randNum = math.random(self.randNum0+(self.randNum0-1)*5,self.randNum0*5)--self.curTrackTb
			if self.isRandShow then
				if self.randShow == nil then
					self.randShow = G_addRectFlicker(self.curTrackTb[self.randNum0],1.1,1.1) --G_addRectFlicker2(self.curTrackTb[self.randNum0],1,1,3,"y",nil,55)
					self.randShow:setPosition(self.curAwardPosTb[self.randNum])
				else
					for k,v in pairs(self.curTrackTb) do
						G_removeFlicker(self.curTrackTb[k])
					end
					
					self.randShow = G_addRectFlicker(self.curTrackTb[self.randNum0],1.1,1.1)--G_addRectFlicker2(self.curTrackTb[self.randNum0],1,1,3,"y",nil,55)
					self.randShow:setPosition(self.curAwardPosTb[self.randNum])
				end
			end
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

	if self.curAwardTb and SizeOfTable(self.curAwardTb) > 0 then
		local specShowTb = {p3351="b",p3345="p",p3346="p",p3360="y"}
		local specNumTb = {p3351=1,p3345=2,p3346=2,p3360=3}
		for k,v in pairs(self.curAwardTb) do
			if specShowTb[v.key] then
				G_addRectFlicker2(self.curTrackIconTb[k],1.1,1.1,specNumTb[v.key],specShowTb[v.key],nil,55)
			end
		end
	end
end

function acJsysDialogTabOne:stopRandAutoChoose( )
	self.bgLayer:stopAllActions()
	if self.curTrackIconTb then
		for k,v in pairs(self.curTrackIconTb) do
			G_removeFlicker2(v)	
		end
	end
	for k,v in pairs(self.curTrackTb) do
		G_removeFlicker(self.curTrackTb[k])
	end
end

