--军徽分解的奖励面板
emblemSellRewardSmallDialog=smallDialog:new()

function emblemSellRewardSmallDialog:new(dataTb,callback,bulkFlag)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dataTb=dataTb
	nc.sellCallback=callback
	nc.bulkFlag=bulkFlag
	nc.dialogWidth=550
	nc.dialogHeight=250
	return nc
end

function emblemSellRewardSmallDialog:init(layerNum)
	self.layerNum=layerNum
	self.isTouch=nil
	self.isUseAmi=false
	
	local award
	if(self.bulkFlag)then
		award=emblemVoApi:getEquipDecomposeByElist(self.dataTb)
	else
		award=emblemVoApi:getEquipDecomposeByIdAndNum(self.dataTb[1].id,1)
	end
	local awardNum=#award
	self.dialogHeight=self.dialogHeight + math.ceil(awardNum/4)*150

	local function touchHandler()
	end
	self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	local dialogBg = G_getNewDialogBg(self.bgSize,getlocal("emblem_btn_decompose"),28,nil,layerNum,false,function () end)
	self.bgLayer=dialogBg
	self.bgLayer:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	
	self.dialogLayer=CCLayer:create()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	
	local fontSize = 20
	local sellNum=0
	if(self.bulkFlag)then
		for k,v in pairs(self.dataTb) do
			local usableNum=v:getUsableNum()
			if(usableNum>0)then
				sellNum=sellNum + usableNum
			end
		end
	else
		sellNum=1
	end
	local descStr = getlocal("emblem_bulk_sale_prompt",{sellNum})
	local descLb = GetTTFLabelWrap(descStr,fontSize,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
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

	local cancleItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn.png",cancleHandler,2,getlocal("cancel"),24/0.8)
	cancleItem:setScale(0.8)
	local cancleMenu=CCMenu:createWithItem(cancleItem)
	cancleMenu:setPosition(ccp(120,60))
	cancleMenu:setTouchPriority(-(layerNum-1)*20-3)
	dialogBg:addChild(cancleMenu)
	local num4,num5=0,0
	for k,v in pairs(self.dataTb) do
		if(v.cfg.color==4)then
			num4=num4 + v:getUsableNum()
		elseif(v.cfg.color==5)then
			num5=num5 + v:getUsableNum()
		end
	end
	--确定
	local function sureHandler()
		PlayEffect(audioCfg.mouseClick)
		local function onConfirm()
			self.sellCallback()
			self:close()
		end
		if(self.bulkFlag~=true)then
			if(num4>0)then
				num4=1
			end
			if(num5>0)then
				num5=1
			end
		end
		if num4>0 then
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("emblem_decompose_high_prompt",{num4,getlocal("emblem_tab_title_4")}),nil,layerNum+1)
		elseif num5>0 then
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("emblem_decompose_high_prompt",{num5,getlocal("emblem_tab_title_5")}),nil,layerNum+1)
		else
			onConfirm()
		end
	end
	local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,getlocal("confirm"),24/0.8)
	sureItem:setScale(0.8)
	local sureMenu=CCMenu:createWithItem(sureItem)
	sureMenu:setPosition(ccp(self.dialogWidth-120,60))
	sureMenu:setTouchPriority(-(layerNum-1)*20-3)
	dialogBg:addChild(sureMenu)

	self:show()	
	local function closeHandler()
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(0,0,10,10),closeHandler)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(0)
	touchDialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.dialogLayer:addChild(touchDialogBg)
	
	sceneGame:addChild(self.dialogLayer,layerNum)
	return self.dialogLayer
end