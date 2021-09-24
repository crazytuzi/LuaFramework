acXiaofeisongliSmallDialog2=smallDialog:new()

function acXiaofeisongliSmallDialog2:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acXiaofeisongliSmallDialog2:init(callback,id,dijige,activityFlag)
	self.dialogWidth=550
	self.dialogHeight=480

	self.id = id 
	self.dijige = dijige
	local selectReward
	if activityFlag==nil then
		selectReward = acXiaofeisongliVoApi:getR1()
	elseif activityFlag==1 then
		selectReward = acChongzhisongliVoApi:getR1()
	elseif activityFlag==2 then
		selectReward = acDanrixiaofeiVoApi:getR1()
	elseif activityFlag==3 then
		selectReward = acDanrichongzhiVoApi:getR1()
	end
	local reward = selectReward[self.id]
	local item = FormatItem(reward[self.dijige])

	self.isTouch=nil
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
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
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)

	local titleStr=getlocal("dialog_title_prompt")
	local titleLb=GetTTFLabel(titleStr,30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	local jiliSp = G_getItemIcon(item[1])
	dialogBg:addChild(jiliSp)
	jiliSp:setPosition(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height-170)

	local desLb = GetTTFLabelWrap(getlocal("activity_xiaofeisongli_small2_des",{item[1].name}),25,CCSizeMake(self.dialogWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	dialogBg:addChild(desLb)
	desLb:setPosition(dialogBg:getContentSize().width/2+20, self.dialogHeight-290)


	 --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
        callback()
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(120,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

     --取消
    local function CancelHandler()
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
        -- callBack()
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",CancelHandler,2,getlocal("cancel"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(self.dialogWidth-120,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)





	local function nilFunc()
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function acXiaofeisongliSmallDialog2:dispose()
	self.id = nil
	self.dijige = nil
end