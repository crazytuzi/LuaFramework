localWarRepairSmallDialog=smallDialog:new()

function localWarRepairSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=550
	self.dialogHeight=450

	-- self.parent=parent
	-- self.cityID=1
	return nc
end

function localWarRepairSmallDialog:init(time,layerNum,callback)
	self.time=time
	self.layerNum=layerNum
	local function nilFunc()
	end

	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
	self.dialogLayer=CCLayer:create()
	
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

    local lbSize = 30
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        lbSize =40
    end
    local titleLb=GetTTFLabel(getlocal("local_war_troops_quick_repair"),lbSize)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)


    local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
	descBg:setContentSize(CCSizeMake(350,100))
    descBg:ignoreAnchorPointForPosition(false)
    descBg:setAnchorPoint(ccp(0.5,0.5))
    descBg:setIsSallow(false)
    descBg:setTouchPriority(-(self.layerNum-1)*20-1)
	descBg:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-170))
    dialogBg:addChild(descBg)

    -- self.str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local repairTimeLb=GetTTFLabelWrap(getlocal("local_war_troops_repair_time"),25,CCSizeMake(descBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- local repairTimeLb=GetTTFLabelWrap(self.str,25,CCSizeMake(descBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    repairTimeLb:setPosition(ccp(descBg:getContentSize().width/2,descBg:getContentSize().height/2+20))
    descBg:addChild(repairTimeLb)
    local cdTime=time-base.serverTime
    if cdTime<0 then
    	cdTime=0
    end
    self.timeLb=GetTTFLabel(GetTimeStr(cdTime),25)
    self.timeLb:setPosition(ccp(descBg:getContentSize().width/2,descBg:getContentSize().height/2-20))
    descBg:addChild(self.timeLb)
    self.timeLb:setColor(G_ColorYellowPro)

    local costGems=cdTime+localWarCfg.reviveCost
    self.descLb=GetTTFLabelWrap(getlocal("local_war_troops_repair_desc",{costGems}),25,CCSizeMake(self.dialogWidth-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- self.descLb=GetTTFLabelWrap(self.str,25,CCSizeMake(descBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.descLb:setPosition(ccp(self.dialogWidth/2,160))
    dialogBg:addChild(self.descLb)


    --取消
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         self:close()
    end
    local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,getlocal("cancel"),25)
    local cancleMenu=CCMenu:createWithItem(cancleItem)
    cancleMenu:setPosition(ccp(size.width-120,60))
    cancleMenu:setTouchPriority(-(layerNum-1)*20-2)
    dialogBg:addChild(cancleMenu)
    --确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)

        if time then
            local costGems=(time-base.serverTime)+localWarCfg.reviveCost
            if(playerVoApi:getGems()<costGems)then
                local needGem=costGems - playerVoApi:getGems()
                GemsNotEnoughDialog(nil,nil,needGem,layerNum+1,costGems)
                do return end
            end
            local function reviveCallback()
            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_troops_repair_success"),30)
                if callBack then
			        callBack()
			    end
		        self:close()
            end
            localWarFightVoApi:revive(reviveCallback)
        end
    end
    local leftStr=getlocal("ok")
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,leftStr,25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(120,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2)
    dialogBg:addChild(sureMenu)


	--遮罩层
    local function touchLuaSpr()     
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))

	base:addNeedRefresh(self)
end

function localWarRepairSmallDialog:tick()
	if self and self.time then
		local cdTime=self.time-base.serverTime
		if cdTime<0 then
			self:close()
		else
			if self.timeLb then
				local timeStr=GetTimeStr(cdTime)
				self.timeLb:setString(timeStr)
			end
			if self.descLb then
				local costGems=cdTime+localWarCfg.reviveCost
			    self.descLb:setString(getlocal("local_war_troops_repair_desc",{costGems}))
			    -- self.descLb:setString(self.str)
			end
		end
	end
end



