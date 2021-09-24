searchSmallDialog=smallDialog:new()

function searchSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.reward={}
	self.dialogHeight=650
	self.dialogWidth=550
	-- self.pageCellNum=10
	self.cellHeight=120
	return nc
end

function searchSmallDialog:init(layerNum,pid,callback,targetStr)
	self.layerNum=layerNum
	self.pid=pid

	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgSize=size
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)


	local lbSize2 = 30
	if G_getCurChoseLanguage() =="ko" then
		lbSize2 =25
	end
	if propCfg[self.pid] then
		local nameStr=getlocal(propCfg[self.pid].name)
		local titleLb=GetTTFLabelWrap(nameStr,lbSize2,CCSizeMake(self.dialogWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		titleLb:setAnchorPoint(ccp(0.5,0.5))
		titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
		dialogBg:addChild(titleLb)
	end

	local inputLable = GetTTFLabelWrap(getlocal("target_name"),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
	-- local inputLable = GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",25,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
    inputLable:setAnchorPoint(ccp(0,0.5))
    inputLable:setPosition(ccp(50,self.bgSize.height-140))
    self.bgLayer:addChild(inputLable,1)
    
    local function callBackTargetHandler(fn,eB,str)

    end
    local function tthandler()
    end
    local editTargetBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
    editTargetBox:setContentSize(CCSizeMake(250,50))
    editTargetBox:setIsSallow(false)
    editTargetBox:setTouchPriority(-(layerNum-1)*20-4)
    editTargetBox:setPosition(ccp(editTargetBox:getContentSize().width/2+240,self.bgSize.height-140))
    if not targetStr then
    	targetStr=""
    end
    local targetBoxLabel=GetTTFLabel(targetStr,25)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,editTargetBox:getContentSize().height/2))
    local customEditBox=customEditBox:new()
    local length=100
    local editBox=customEditBox:init(editTargetBox,targetBoxLabel,"mail_input_bg.png",nil,-(layerNum-1)*20-4,length,callBackTargetHandler,nil,nil)
    self.bgLayer:addChild(editTargetBox,2)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScale(size.width/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(size.width/2,size.height-210))
	self.bgLayer:addChild(lineSp)

    if self.pid then
    	local pid=(tonumber(self.pid) or tonumber(RemoveFirstChar(self.pid)))
	    local decsLb=GetTTFLabelWrap(getlocal("use_prop_"..pid.."_desc"),25,CCSizeMake(self.bgSize.width-100,1000),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    decsLb:setAnchorPoint(ccp(0,0.5))
	    decsLb:setPosition(ccp(50,300))
	    self.bgLayer:addChild(decsLb,1)
	end

    	--确定
    local function sureHandler()
    	local targetName=targetBoxLabel:getString()
    	if targetName == "" or targetName == nil then
    		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("please_input_target_name"),30)
    		do return end
    	end
    	
    	local function callSure()
    		if G_checkClickEnable()==false then
			    do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)

	        local function mapRadarscanCallback()
	        	self:close()
	        end
	        local function errorCallback()
	        	if targetBoxLabel then
	        		targetBoxLabel:setString("")
	            end
		        if editBox then
					editBox:setText("")
				end
            end	
            
	        bagVoApi:mapRadarscan(self.pid,targetName,layerNum,mapRadarscanCallback,errorCallback,callback)
        end
    	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callSure,getlocal("dialog_title_prompt"),getlocal("spy_satellite_radar"..self.pid),nil,layerNum+1)
    	
    end
	--确定
   --[[ local function sureHandler()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        local function mapRadarscanCallback()
        	self:close()
        end
        local function errorCallback()
        	if targetBoxLabel then
	        	targetBoxLabel:setString("")
	        end
	        if editBox then
				editBox:setText("")
			end
        end	
        local targetName=targetBoxLabel:getString()
	    bagVoApi:mapRadarscan(self.pid,targetName,layerNum,mapRadarscanCallback,errorCallback,callback)
    end--]]
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.dialogWidth/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2)
    dialogBg:addChild(sureMenu)

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end
