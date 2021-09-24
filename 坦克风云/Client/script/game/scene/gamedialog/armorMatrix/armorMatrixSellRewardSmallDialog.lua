--军徽分解的奖励面板
armorMatrixSellRewardSmallDialog=smallDialog:new()

-- dataInfo={reward=reward,sellNum=n,num4=n,num5=n}
-- reward :奖励  sellNum：分解的总个数 num4：品质为4的个数  num5：品质为5的个数
function armorMatrixSellRewardSmallDialog:new(callback,dataInfo)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.sellCallback=callback
	nc.dialogWidth=550
	nc.dialogHeight=250
	nc.dataInfo=dataInfo
	return nc
end

function armorMatrixSellRewardSmallDialog:init(layerNum,titleStr,desStr)
	self.layerNum=layerNum
	self.isTouch=nil
	self.isUseAmi=false
	local function touchHandler()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),touchHandler)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	local award=self.dataInfo.reward
	local awardNum=#award
	self.dialogHeight=self.dialogHeight + math.ceil(awardNum/4)*150

	self.bgLayer:setContentSize(CCSizeMake(self.dialogWidth,self.dialogHeight))
	self.bgLayer:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local fontSize = 35
	if G_getCurChoseLanguage()~="cn" then
		fontSize = 30
	end
	local titleLb=GetTTFLabelWrap(titleStr,fontSize,CCSizeMake(self.dialogWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setPosition(ccp(self.dialogWidth/2,self.bgLayer:getContentSize().height-45))
	self.bgLayer:addChild(titleLb,1)
	
	fontSize = 25
	if G_getCurChoseLanguage()~="cn" then
		fontSize = 22
		if G_isIOS()==false then
			fontSize = fontSize - 2
		end
	end
	local sellNum=self.dataInfo.sellNum
	local descLb = GetTTFLabelWrap(desStr,fontSize,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	descLb:setAnchorPoint(ccp(0,1))
	descLb:setPosition(ccp(30,self.bgLayer:getContentSize().height-100))
	self.bgLayer:addChild(descLb,1)

	local awardHeight = descLb:getPositionY() - descLb:getContentSize().height-35
	local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),function ( ... ) end)
	awardBg:setContentSize(CCSizeMake(self.dialogWidth - 30,150*math.ceil(awardNum/4)))
	awardBg:setAnchorPoint(ccp(0.5,1))
	awardBg:setPosition(ccp(self.dialogWidth/2,awardHeight + 20))
	self.bgLayer:addChild(awardBg,1)
	local startX
	if(awardNum<5)then
		startX=(self.dialogWidth - awardNum*132)/2 + 66
	else
		startX=96
	end
	for k,v in pairs(award) do
		if v and v.name and v.num then
			local awidth = startX+((k-1)%4)*132
			local iconSize = 80
			local aheight = awardHeight - math.floor((k-1)/4)*(iconSize+50)
			local icon,scale = G_getItemIcon(v,iconSize,true,layerNum)
			if icon then
				icon:setAnchorPoint(ccp(0.5,1))
				icon:setPosition(ccp(awidth,aheight))
				icon:setTouchPriority(-(layerNum-1)*20-3)
				self.bgLayer:addChild(icon,1)
				icon:setScale(scale)
			end
			local numLable = GetTTFLabel("x"..FormatNumber(v.num),25)
			numLable:setAnchorPoint(ccp(0.5,1))
			numLable:setPosition(ccp(icon:getPositionX(),icon:getPositionY()-icon:getContentSize().height*scale-5))
			self.bgLayer:addChild(numLable,1)
		end
	end

	--取消
	local function cancleHandler()
		 PlayEffect(audioCfg.mouseClick)
		 self:close()
	end

	local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,getlocal("cancel"),25)
	local cancleMenu=CCMenu:createWithItem(cancleItem)
	cancleMenu:setPosition(ccp(self.dialogWidth-120,60))
	cancleMenu:setTouchPriority(-(layerNum-1)*20-3)
	dialogBg:addChild(cancleMenu)
	local num4,num5=self.dataInfo.num4,self.dataInfo.num5
	--确定
	local function sureHandler()
		PlayEffect(audioCfg.mouseClick)
		local function onConfirm()
			self.sellCallback()
			self:close()
		end
		if num4>0 then
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("armorMatrix_decompose_des2",{num4,getlocal("armorMatrix_color_4")}),nil,layerNum+1)
		elseif num5>0 then
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("armorMatrix_decompose_des2",{num5,getlocal("armorMatrix_color_5")}),nil,layerNum+1)
		else
			onConfirm()
		end
	end
	local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
	local sureMenu=CCMenu:createWithItem(sureItem)
	sureMenu:setPosition(ccp(120,60))
	sureMenu:setTouchPriority(-(layerNum-1)*20-3)
	dialogBg:addChild(sureMenu)

	self:show()	
	local function closeHandler()
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(0,0,10,10),closeHandler)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(120)
	touchDialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.dialogLayer:addChild(touchDialogBg)
	
	sceneGame:addChild(self.dialogLayer,layerNum)
	return self.dialogLayer
end