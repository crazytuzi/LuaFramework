--军徽批量分解的面板
armorBulkSaleDialog=smallDialog:new()

function armorBulkSaleDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.tagOffset=518
	nc.dialogHeight=640
	nc.dialogWidth=550
	nc.maxQuality=4

	return nc
end

function armorBulkSaleDialog:init(layerNum,sellBack)
	local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
	self.layerNum=layerNum
	self.sellBack=sellBack
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
	self.dialogLayer=CCLayer:create()

	local descFontSize = 25
	if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
		descFontSize = 22
	end
	--先算一下有可能换行的文本框高度，然后再确定整个对话框的高度
    local descLb=GetTTFLabelWrap(getlocal("accessory_bulkSale_title"),descFontSize,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,0.5))
	descLb:setColor(G_ColorYellowPro)
    self.dialogHeight=self.dialogHeight+descLb:getContentSize().height-25
	descLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-115))

	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
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
	
    local titleSize=36
    local titleOffX=0
    if G_getCurChoseLanguage()=="ru" then
        titleSize=30
        titleOffX=40
    end
	local titleLb=GetTTFLabel(getlocal("armorMatrix_batch_severance"),36)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2-titleOffX,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	dialogBg:addChild(descLb,2)

	self.checkBoxList={}
	self.uncheckBoxList={}
	self.selectQualityList={}
	local capInSet = CCRect(20, 20, 10, 10);
	local startIndex=1
    local posY=self.dialogHeight-110-descLb:getContentSize().height-3
    local colorTb = {G_ColorWhite,G_ColorGreen,G_ColorBlue,G_ColorPurple}
	for i=startIndex,self.maxQuality do
		local function onSelect(object,fn,tag)
			local quality=tag-self.tagOffset
			self:onSelectQuality(quality)
		end
		local offset=i
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,onSelect)
		background:setTouchPriority(-(layerNum-1)*20-2)
		background:setAnchorPoint(ccp(0,1))
		background:setContentSize(CCSizeMake(self.dialogWidth-60,90))
		background:setPosition(ccp(30,posY-100*(offset-1)))
		background:setTag(self.tagOffset+i)

		local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",nilFunc)
		checkBox:setPosition(ccp(50,45))
		checkBox:setVisible(false)
		self.checkBoxList[i]=checkBox
		background:addChild(checkBox)

		local uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",nilFunc)
		uncheckBox:setPosition(ccp(50,45))
		self.uncheckBoxList[i]=uncheckBox
		background:addChild(uncheckBox)

		local qualityLb=GetTTFLabel(getlocal("armorMatrix_color_"..i),28)
		qualityLb:setAnchorPoint(ccp(0,0.5))
		qualityLb:setPosition(ccp(100,45))
		qualityLb:setColor(colorTb[i])
		background:addChild(qualityLb)

		dialogBg:addChild(background)

		-- 默认选择白装
		if i==1 then
			onSelect(nil,nil,self.tagOffset+i)
		end
	end

	local function onSelectAll()
		self:selectAll()
	end
	local selectAllItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onSelectAll,nil,getlocal("selectAll"),strSize2)
	local selectAllBtn=CCMenu:createWithItem(selectAllItem);
	selectAllBtn:setTouchPriority(-(layerNum-1)*20-2);
	selectAllBtn:setPosition(ccp(120,60))
	dialogBg:addChild(selectAllBtn)

	local function onConfirmSell()
		self:sell()
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirmSell,nil,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(layerNum-1)*20-2)
	okBtn:setAnchorPoint(ccp(1,0.5))
	okBtn:setPosition(ccp(self.dialogWidth-120,60))
	dialogBg:addChild(okBtn)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function armorBulkSaleDialog:onSelectQuality(quality)
	if(self.selectQualityList[quality]==true)then
		self.selectQualityList[quality]=false
		self.checkBoxList[quality]:setVisible(false)
		self.uncheckBoxList[quality]:setVisible(true)
	else
		self.selectQualityList[quality]=true
		self.checkBoxList[quality]:setVisible(true)
		self.uncheckBoxList[quality]:setVisible(false)
	end
end

function armorBulkSaleDialog:selectAll()
	local startIndex=1
	local hasSelectAll=true
	for i=startIndex,self.maxQuality do
		if(self.selectQualityList[i]~=true)then
			hasSelectAll=false
			self.selectQualityList[i]=true
			self.checkBoxList[i]:setVisible(true)
			self.uncheckBoxList[i]:setVisible(false)
		end
	end
	if(hasSelectAll)then
		for i=startIndex,self.maxQuality do
			if(self.selectQualityList[i]==true)then
				self.selectQualityList[i]=false
				self.checkBoxList[i]:setVisible(false)
				self.uncheckBoxList[i]:setVisible(true)
			end
		end
	end
end

function armorBulkSaleDialog:sell()
	local sellQualityTb={}
	for i=1,self.maxQuality do
		if self.selectQualityList[i]==true then
			table.insert(sellQualityTb,i)
		end
	end
	-- 判断选择
	if(#sellQualityTb<=0)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_bulkSale_title"),30)
		do return end
	end
	local function closeFunc()
		self:close()
	end
	if self.sellBack then
		self.sellBack(self.selectQualityList,closeFunc)
	end
	-- local eVoTb={}
	-- for k,v in pairs(emblemVoApi:getEquipList()) do
	-- 	if(self.selectQualityList[v.cfg.color] and v:getUsableNum()>0)then
	-- 		table.insert(eVoTb,v)
	-- 	end
	-- end
	-- if(#eVoTb==0)then
	-- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_no_bulk_sale"),30)
	-- 	do return end
	-- end
	-- local function onSale()
	-- 	local function callback()
	-- 		self:close()
	-- 	end
	-- 	emblemVoApi:sell(nil,sellQualityTb,callback)
	-- end
	-- emblemVoApi:showSellRewardDialog(eVoTb,self.layerNum + 1,onSale,true)
end