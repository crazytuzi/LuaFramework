accessoryBulkSaleDialog=smallDialog:new()

--param type: 1是分解配件, 2是分解碎片
function accessoryBulkSaleDialog:new(type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.type=type
	self.tagOffset=518

	self.dialogHeight=550
	self.dialogWidth=550

	self.maxQuality=3

	return nc
end

function accessoryBulkSaleDialog:init(layerNum)
	self.layerNum=layerNum
	local function nilFunc()
	end

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end

	--先算一下有可能换行的文本框高度，然后再确定整个对话框的高度
    local descLb=GetTTFLabelWrap(getlocal("accessory_bulkSale_title"),25,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,1))
	descLb:setColor(G_ColorYellowPro)
    self.dialogHeight=self.dialogHeight+descLb:getContentSize().height-25
	descLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-90))

	local titleStr = getlocal("bulksale")
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	local dialogBg = G_getNewDialogBg(size, titleStr, 36, nil, layerNum, true, close)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true)

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
    local posY=self.dialogHeight-90-descLb:getContentSize().height-3
	for i=startIndex,self.maxQuality do
		local function onSelect(object,fn,tag)
			local quality=tag-self.tagOffset
			self:onSelectQuality(quality)
		end
		local offset=i
		local background =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),onSelect)
		background:setTouchPriority(-(layerNum-1)*20-2)
		background:setAnchorPoint(ccp(0,1))
		background:setContentSize(CCSizeMake(self.dialogWidth-60,100))
		background:setPosition(ccp(30,posY-105*(offset-1)))
		background:setTag(self.tagOffset+i)

		local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",nilFunc)
		checkBox:setPosition(ccp(50,50))
		checkBox:setVisible(false)
		self.checkBoxList[i]=checkBox
		background:addChild(checkBox)

		local uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",nilFunc)
		uncheckBox:setPosition(ccp(50,50))
		self.uncheckBoxList[i]=uncheckBox
		background:addChild(uncheckBox)

		local param
		if(self.type==1)then
			param=getlocal("accessory")
		else
			param=getlocal("fragment")
		end
		local qualityLb=GetTTFLabel(getlocal("accessory_quality_"..i,{param}),28)
		qualityLb:setAnchorPoint(ccp(0,0.5))
		qualityLb:setPosition(ccp(100,50))
		background:addChild(qualityLb)

		dialogBg:addChild(background)
	end

	local function onSelectAll()
		self:selectAll()
	end
	local selectAllItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onSelectAll,nil,getlocal("selectAll"),24/0.7)
	selectAllItem:setScale(0.7)
	local selectAllBtn=CCMenu:createWithItem(selectAllItem);
	selectAllBtn:setTouchPriority(-(layerNum-1)*20-2);
	selectAllBtn:setPosition(ccp(120,60))
	dialogBg:addChild(selectAllBtn)

	local function onConfirmSell()
		self:sell()
	end
	local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfirmSell,nil,getlocal("confirm"),24/0.7)
	okItem:setScale(0.7)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(layerNum-1)*20-2)
	okBtn:setAnchorPoint(ccp(1,0.5))
	okBtn:setPosition(ccp(self.dialogWidth-120,60))
	dialogBg:addChild(okBtn)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function accessoryBulkSaleDialog:onSelectQuality(quality)
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

function accessoryBulkSaleDialog:selectAll()
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

function accessoryBulkSaleDialog:sell()
	local sellQualityTb={}
	for i=1,self.maxQuality do
		if(self.selectQualityList[i])then
			table.insert(sellQualityTb,i)
		end
	end
	if(#sellQualityTb<=0)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_bulkSale_title"),30)
		do return end
	end
	local function onConfirm()
		local function callback(reward)
			local str=getlocal("accessory_sell_success")
			for k,v in pairs(reward) do
				local tmp
				if(k=="resource")then
					tmp=getlocal("money").." x"..FormatNumber(v)..","
				else
					tmp=getlocal("accessory_smelt_"..k).." x"..FormatNumber(v)..","
				end
				str=str..tmp
			end
			str=string.sub(str,1,string.len(str)-1)
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
			self:close()
		end
		if(self.type==1)then
			accessoryVoApi:sellAccessory(2,sellQualityTb,callback)
		elseif(self.type==2)then
			accessoryVoApi:sellFragment(2,sellQualityTb,callback)
		end
	end
	local bulkSaleDesc=self:getBulkSaleString()
	if(bulkSaleDesc==false)then
		if(self.type==1)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_noAccessoryTosell"),30)
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_noFragmentTosell"),30)
		end
		do return end
	end
	local isShow = false
	for k,v in pairs(sellQualityTb) do
		if v>=3 then
			isShow = true
			break
		end
	end
	if isShow then
		local desc=getlocal("promptBreakDown")
		bulkSaleDesc=desc.."\n"..bulkSaleDesc
	end
	
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),bulkSaleDesc,nil,self.layerNum+1)
end

function accessoryBulkSaleDialog:getBulkSaleString()
	local totalProp={0,0,0,0,0,0,0,0,0,0}
	local totalResource=0
	local sellStr=""
	local bagData
	if(self.type==1)then
		bagData=accessoryVoApi:getAccessoryBag()
	else
		bagData=accessoryVoApi:getFragmentBag()
	end
	for k,v in pairs(bagData) do
		if(self.selectQualityList[tonumber(v:getConfigData("quality"))])then
			local sellMaterials,sellResource=accessoryVoApi:getSellItem(self.type,v)
			for k,v in pairs(sellMaterials) do
				local index=tonumber(string.sub(k,2))
				totalProp[index]=totalProp[index]+v
			end
			totalResource=totalResource+sellResource
		end
	end
	for k,v in pairs(totalProp) do
		if(v>0)then
			sellStr=sellStr..getlocal("accessory_smelt_p"..k).." x"..FormatNumber(v)..","
		end
	end
	if(totalResource>0)then
		sellStr=sellStr..getlocal("money").." x"..FormatNumber(totalResource)..","
	end
	if(sellStr~="")then
		local desc=getlocal("accessory_sell_desc2")
		sellStr=string.sub(sellStr,1,string.len(sellStr)-1)
		sellStr=getlocal("accessory_sell_desc")..sellStr
		return sellStr.."\n"..desc
	else
		return false
	end
end
