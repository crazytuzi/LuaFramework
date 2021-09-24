--军团跨服战报名小面板
serverWarTeamApplySmallDialog=smallDialog:new()

--param allianceID: 获胜军团的ID
--param endTs: 战斗结束的时间
function serverWarTeamApplySmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dialogWidth=550
	nc.dialogHeight=530
	return nc
end

function serverWarTeamApplySmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function serverWarTeamApplySmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0)) 
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeBtn,2)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)
end

function serverWarTeamApplySmallDialog:initContent() 
	local title=getlocal("serverwarteam_apply_title")
	-- title="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
	local titleLb=GetTTFLabelWrap(title,35,CCSizeMake(self.dialogWidth-180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-52))
    self.bgLayer:addChild(titleLb)
    titleLb:setColor(G_ColorYellowPro)


    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScale((self.dialogWidth-100)/lineSp:getContentSize().width)
	lineSp:setPosition(ccp((self.dialogWidth-100)/2+50,self.dialogHeight-90))
	self.bgLayer:addChild(lineSp)


	local content={getlocal("serverwarteam_apply_desc1",{serverWarTeamCfg.joinlv}),"\n",getlocal("serverwarteam_apply_desc2",{serverWarTeamCfg.jointime}),"\n",getlocal("serverwarteam_apply_desc3")}
	local tabelLb = G_LabelTableView(CCSizeMake(self.dialogWidth-80,self.dialogHeight-250),content,25,kCCTextAlignmentLeft)
	tabelLb:setPosition(ccp(40,120))
	tabelLb:setAnchorPoint(ccp(0,0))
	tabelLb:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	tabelLb:setMaxDisToBottomOrTop(70)
	self.bgLayer:addChild(tabelLb,5)


	--报名的状态：返回，-2 未到报名时间 ，-1 军团没有资格报名(军团不是前几名)，0 团员不能报名，1 可以报名，2 已经报名，3 报名已截止，4 没有军团
	local applyStatus=serverWarTeamVoApi:canApplyStatus()
	local applyStr=getlocal("serverwarteam_apply")
	if applyStatus==2 then
		applyStr=getlocal("dimensionalWar_has_signup")
	end
	local function onConfirm()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local applyStatus=serverWarTeamVoApi:canApplyStatus()
		if applyStatus==1 then
			-- serverWarTeamVoApi:showSetBattleMemDialog(self.layerNum+1)
	    	local function applyCallback()
	            self:close()
	        end
	        serverWarTeamVoApi:serverWarTeamApply(applyCallback)
		elseif applyStatus==-1 then
			local list=serverWarTeamVoApi:getServerList()
			if list and SizeOfTable(list)>0 then
				local topNum=serverWarTeamCfg.sevbattleAlliance/SizeOfTable(list)
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_apply_error1",{topNum}),30)
			end
		elseif applyStatus==0 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_apply_error2"),30)
		end
	end
	local okItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onConfirm,1,applyStr,25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	okBtn:setPosition(ccp(self.dialogWidth/2,60))
	self.bgLayer:addChild(okBtn)
	if applyStatus==-1 or applyStatus==0 or applyStatus==1  then
	else
		okItem:setEnabled(false)
	end
end



