alienMinesRankDialog = commonDialog:new()

function alienMinesRankDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil
    return nc
end

function alienMinesRankDialog:resetTab()
	local index=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		end

		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
	
    self.selectedTabIndex = 0
end

function alienMinesRankDialog:initTableView() 
    self:tabClick(0,false)
    if alienMinesVoApi:checkIsActive5()==true then
        self:addMengban()
    end
    
end

function alienMinesRankDialog:tabClick(idx,isEffect)
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    if(idx==0)then
        if(self.acTab1==nil)then 
            local function callback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    alienMinesVoApi:setPersonalList(sData.data.ranking)
                    alienMinesVoApi:setMcount(sData.data.mcount)

                    self.acTab1=alienMinesRankTab1:new()
                    self.layerTab1=self.acTab1:init(self.layerNum)
                    self.bgLayer:addChild(self.layerTab1)
                end
            end
            if alienMinesVoApi:checkIsActive4()==true and alienMinesVoApi:getRefreshRankTime()==0 then
                alienMinesVoApi:setRefreshRankTime(-1)
                socketHelper:alienMinesGetRank(1,callback)
            elseif alienMinesVoApi:checkIsActive4()==true and alienMinesVoApi:getRefreshRankTime()==-1 then
                self.acTab1=alienMinesRankTab1:new()
                self.layerTab1=self.acTab1:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab1)
            elseif alienMinesVoApi:getRefreshRankTime()-base.serverTime<0 then
                 alienMinesVoApi:setRefreshRankTime(base.serverTime+300)
                 socketHelper:alienMinesGetRank(1,callback)
            else
                self.acTab1=alienMinesRankTab1:new()
                self.layerTab1=self.acTab1:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab1)
            end
            
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
    elseif(idx==1)then
        
        if(self.acTab2==nil)then 
             local function callback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    alienMinesVoApi:setAlianList(sData.data.ranking)

                    self.acTab2=alienMinesRankTab2:new()
                    self.layerTab2=self.acTab2:init(self.layerNum)
                    self.bgLayer:addChild(self.layerTab2)
                end
            end  
           -- 每隔五分钟掉一次
            if alienMinesVoApi:checkIsActive4()==true and alienMinesVoApi:getRefreshRankTime2()==0 then
                alienMinesVoApi:setRefreshRankTime2(-1)
                socketHelper:alienMinesGetRank(2,callback)
            elseif alienMinesVoApi:checkIsActive4()==true and alienMinesVoApi:getRefreshRankTime2()==-1 then
                self.acTab2=alienMinesRankTab2:new()
                self.layerTab2=self.acTab2:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab2)
            elseif alienMinesVoApi:getRefreshRankTime2()-base.serverTime<0 then
                 alienMinesVoApi:setRefreshRankTime2(base.serverTime+300)
                 socketHelper:alienMinesGetRank(2,callback)
            else
                self.acTab2=alienMinesRankTab2:new()
                self.layerTab2=self.acTab2:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab2)
            end
			
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then          
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
        end
    end
end


function alienMinesRankDialog:tick()

	if self and self.bgLayer and self.acTab1 and self.layerTab1 then
		self.acTab1:tick()		
	end

	if self and self.bgLayer and self.acTab2 and self.layerTab2 then
		self.acTab2:tick()		
	end

    -- 触发邮件
    if alienMinesVoApi:getEmailFlag()==false then
        alienMinesVoApi:checkIsActive3()
    end

    -- 结算朦板的处理
    if alienMinesVoApi:checkIsActive5()==false then
        if self.touchDialogBg then
            self.touchDialogBg:removeFromParentAndCleanup(true)
            self.touchDialogBg=nil
        end
    else
        if self.touchDialogBg and self.timeLb then
           local ts = G_getWeeTs(base.serverTime)
           local difTs=base.serverTime-ts
           local _,endTime = alienMinesVoApi:getBeginAndEndtime()
           local endTs = endTime[1]*3600+endTime[2]*60
           local timeStr=300 -(difTs-endTs)
            self.timeLb:setString(GetTimeStr(timeStr))
        end
    end
end
function alienMinesRankDialog:addMengban()
    local function nilFunc()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-6)
    local rect=CCSizeMake(640,G_VisibleSizeHeight-240)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(240)
    touchDialogBg:setAnchorPoint(ccp(0,0))
    touchDialogBg:setPosition(ccp(0,85))
    self.bgLayer:addChild(touchDialogBg,10)
    self.touchDialogBg=touchDialogBg

    local titleLb=GetTTFLabelWrap(getlocal("alienMines_rankClearing"),30,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(touchDialogBg:getContentSize().width/2, touchDialogBg:getContentSize().height/2+10)
    titleLb:setColor(G_ColorYellowPro)
    touchDialogBg:addChild(titleLb)

    local ts = G_getWeeTs(base.serverTime)
    local difTs=base.serverTime-ts
    local _,endTime=alienMinesVoApi:getBeginAndEndtime()
    local endTs = endTime[1]*3600+endTime[2]*60
    local timeStr=300 -(difTs-endTs)
    
    local timeLb = GetTTFLabel(G_getTimeStr(timeStr),30)
    timeLb:setPosition(touchDialogBg:getContentSize().width/2, touchDialogBg:getContentSize().height/2-titleLb:getContentSize().height/2-10)
    timeLb:setColor(G_ColorYellowPro)
    self.timeLb=timeLb
    touchDialogBg:addChild(timeLb)
end

function alienMinesRankDialog:dispose()
    if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.touchDialogBg=nil
    self.timeLb=nil
end