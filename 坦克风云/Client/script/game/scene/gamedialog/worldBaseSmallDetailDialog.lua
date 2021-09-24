worldBaseSmallDetailDialog=smallDialog:new()

function worldBaseSmallDetailDialog:new(data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=500
	self.dialogHeight=400

	self.data=data
	return nc
end

function worldBaseSmallDetailDialog:init(layerNum)
	local myChenghaoH=0

	if playerVoApi:getSwichOfGXH() and self.data.title and tostring(self.data.title)~="" and tostring(self.data.title)~="0" then
        myChenghaoH=45
        self.dialogHeight=self.dialogHeight+myChenghaoH
    end
	self.isTouch=nil
	self.layerNum=layerNum
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleLb=GetTTFLabel(getlocal("playerInfo"),32,true)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	if self.data.pic then
		--local personPhotoName="photo"..self.data.pic..".png"
		--local playerPic = GetBgIcon(personPhotoName)
        local mypic =self.data.pic
        local mybpic = self.data.bpic
        if self.data.oid==playerVoApi:getUid() then
            mypic=playerVoApi:getPic()
            mybpic=playerVoApi:getHfid()
        end

        local personPhotoName=playerVoApi:getPersonPhotoName(mypic)
        local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,nil,mybpic)
		playerPic:setAnchorPoint(ccp(0,1))
		playerPic:setPosition(ccp(20,self.dialogHeight-100))
		dialogBg:addChild(playerPic,1)
	end

	local nameLb=GetTTFLabel(self.data.name,24,true)
	nameLb:setAnchorPoint(ccp(0,1))
	nameLb:setPosition(ccp(110,self.dialogHeight-95))
	nameLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(nameLb)

	local rank=tonumber(self.data.rank)
	if rank==nil or rank==0 then
		rank=1
	end
	local rankLb=GetTTFLabelWrap(getlocal("lower_level")..". "..self.data.level.." "..playerVoApi:getRankName(rank),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	rankLb:setAnchorPoint(ccp(0,0))
	rankLb:setPosition(ccp(110,self.dialogHeight-185))     --
	self.bgLayer:addChild(rankLb)

	local function onSendMail()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:sendMail()
	end
	local emailItem=GetButtonItem("worldBtnModify.png","worldBtnModify_Down.png","worldBtnModify_Down.png",onSendMail,nil,nil,nil)
	local emailBtn=CCMenu:createWithItem(emailItem)
	emailBtn:setPosition(ccp(400,self.dialogHeight-140))
	self.bgLayer:addChild(emailBtn)

	if playerVoApi:getSwichOfGXH() and self.data.title and tostring(self.data.title)~="" and tostring(self.data.title)~="0" then
		local chenghaoLb = GetTTFLabel(getlocal("player_title"),20)
		chenghaoLb:setAnchorPoint(ccp(0,0))
		chenghaoLb:setPosition(ccp(20,self.dialogHeight-230))
		self.bgLayer:addChild(chenghaoLb)

		local CtitleLb = GetTTFLabel("    " .. getlocal("player_title_name_" .. self.data.title),20)
			CtitleLb:setAnchorPoint(ccp(0,0))
		CtitleLb:setPosition(ccp(20+chenghaoLb:getContentSize().width,self.dialogHeight-230))
		self.bgLayer:addChild(CtitleLb)
		CtitleLb:setColor(G_ColorOrange)

	end
	
	

	local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-200-myChenghaoH))
	self.bgLayer:addChild(lineSp)

	local powerLb=GetTTFLabel(getlocal("player_message_info_power").."    "..self.data.power,20)
	powerLb:setAnchorPoint(ccp(0,0))
	powerLb:setPosition(ccp(20,self.dialogHeight-240-myChenghaoH))
	self.bgLayer:addChild(powerLb)

	local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleY(self.dialogWidth/lineSp:getContentSize().width)
	lineSp2:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-260-myChenghaoH))
	self.bgLayer:addChild(lineSp2)

	local allianceName
	if self.data.allianceName and self.data.allianceName~="" then
		allianceName=getlocal("player_message_info_alliance").."    "..self.data.allianceName
	else
		allianceName=getlocal("player_message_info_alliance").."    "..getlocal("alliance_info_content")
	end
	local allianceLb=GetTTFLabel(allianceName,20)
	allianceLb:setAnchorPoint(ccp(0,0))
	allianceLb:setPosition(ccp(20,self.dialogHeight-300-myChenghaoH))
	self.bgLayer:addChild(allianceLb)

	local confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",close,2,getlocal("confirm"),24,101)
	confirmItem:setScale(0.8)
	local lb = confirmItem:getChildByTag(101)
	if lb then
		lb = tolua.cast(lb,"CCLabelTTF")
		lb:setFontName("Helvetica-bold")
	end
	local confirmBtn=CCMenu:createWithItem(confirmItem)
	confirmBtn:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-350-myChenghaoH))
	confirmBtn:setTouchPriority(-(layerNum-1)*20-2)
	self.bgLayer:addChild(confirmBtn)

	local itemNum=bagVoApi:getItemNumId(3305) or 0
	if itemNum and itemNum>0 then
		local function showSelectSmallDialog()
	        if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
	        -- bagVoApi:showSelectSearchSmallDialog(self.data.name,layerNum+1)
	    	
	    	local function onConfirm( ... )
				local function mapRadarscanCallback()
		        	self:close()
		        end
		        local targetName=self.data.name or ""
			    bagVoApi:mapRadarscan("p3305",targetName,layerNum,mapRadarscanCallback)
	    	end
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("use_prop_confirm_desc"),nil,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,3305)
	    end
	    local selectItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",showSelectSmallDialog,101,getlocal("search_fleet_btn"),24,100)
	    selectItem:setScale(0.8)
	    local lb = selectItem:getChildByTag(100)
		if lb then
			lb = tolua.cast(lb,"CCLabelTTF")
			lb:setFontName("Helvetica-bold")
		end
	    local selectMenu=CCMenu:createWithItem(selectItem)
	    selectMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2-120,self.dialogHeight-350-myChenghaoH))
	    selectMenu:setTouchPriority(-(layerNum-1)*20-2)
	    self.bgLayer:addChild(selectMenu)

	    confirmBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2+120,self.dialogHeight-350-myChenghaoH))
	end

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

--写邮件
function worldBaseSmallDetailDialog:sendMail()
	if self.data.type~=6 then
		do return end
	end
	local target=self.data.name
	local lyNum=4
	self:realClose()
	emailVoApi:showWriteEmailDialog(lyNum,getlocal("email_write"),target,nil,nil,nil,nil,self.data.oid)
	PlayEffect(audioCfg.mouseClick)
end

