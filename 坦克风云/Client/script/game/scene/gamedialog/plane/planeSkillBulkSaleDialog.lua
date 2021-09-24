--技能批量分解的面板
planeSkillBulkSaleDialog=smallDialog:new()

function planeSkillBulkSaleDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.tagOffset=518
	nc.dialogHeight=640
	nc.dialogWidth=550
	nc.maxQuality=4

	return nc
end

function planeSkillBulkSaleDialog:init(layerNum)
	local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
	self.layerNum=layerNum
	local descFontSize = 25
	if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
		descFontSize = 22
	end
	--先算一下有可能换行的文本框高度，然后再确定整个对话框的高度
    local descLb=GetTTFLabelWrap(getlocal("accessory_bulkSale_title"),descFontSize,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,0.5))
	descLb:setColor(G_ColorYellowPro)
    self.dialogHeight=self.dialogHeight+descLb:getContentSize().height-25
	descLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-105))
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	local function nilFunc()
	end
	local function close()
		return self:close()
	end
	local dialogBg=G_getNewDialogBg(size,getlocal("bulksale"),36,nilFunc,layerNum,true,close)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);
	
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
		local background = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),onSelect)
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

		local qualityLb=GetTTFLabel(getlocal("plane_skill_level_s"..i),28)
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
	  	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:selectAll()
	end
	local scale=0.8
	local selectAllItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onSelectAll,nil,getlocal("selectAll"),strSize2/scale)
	selectAllItem:setScale(scale)
	local selectAllBtn=CCMenu:createWithItem(selectAllItem);
	selectAllBtn:setTouchPriority(-(layerNum-1)*20-2);
	selectAllBtn:setPosition(ccp(120,60))
	dialogBg:addChild(selectAllBtn)

	local function onConfirmSell()
	  	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:sell()
	end
	local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfirmSell,nil,getlocal("confirm"),strSize2/scale)
	okItem:setScale(scale)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(layerNum-1)*20-2)
	okBtn:setAnchorPoint(ccp(1,0.5))
	okBtn:setPosition(ccp(self.dialogWidth-120,60))
	dialogBg:addChild(okBtn)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function planeSkillBulkSaleDialog:onSelectQuality(quality)
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

function planeSkillBulkSaleDialog:selectAll()
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

function planeSkillBulkSaleDialog:sell()
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
	local slist=planeVoApi:getSkillList()
	local sVoTb={}
	for k,v in pairs(slist) do
		if(self.selectQualityList[v.gcfg.color] and v.num>0)then
			table.insert(sVoTb,v)
		end
	end
	if(#sVoTb==0)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("skill_no_equip_bulk_sale"),30)
		do return end
	end
	local function onSale()
		local function callback()
			self:close()
		end
		planeVoApi:sell(nil,sellQualityTb,callback)
	end
	planeVoApi:showSellSkillDialog(sVoTb,self.layerNum + 1,onSale,true)
end