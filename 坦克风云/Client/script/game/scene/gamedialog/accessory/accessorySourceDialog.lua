accessorySourceDialog=smallDialog:new()

--param type: 1是配件, 2是碎片, 3是道具
--param id: id
function accessorySourceDialog:new(type,id)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=400
	self.dialogWidth=550

	self.type=type
	self.id=id
	self.tagOffset=518
	return nc
end

function accessorySourceDialog:init(layerNum)
	self.layerNum=layerNum
	local function nilFunc()
	end

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end

	local titleStr
	if(self.type==1)then
		titleStr=getlocal("accessory_name_"..self.id)
	elseif(self.type==2)then
		titleStr=getlocal("fragment_name_"..self.id)
	elseif(self.type==3)then
		titleStr=getlocal("accessory_smelt_p"..self.id)
	else
		titleStr=""
	end

	local size = CCSizeMake(self.dialogWidth, self.dialogHeight)

	self.dialogLayer=CCLayer:create()
	local dialogBg = G_getNewDialogBg(size, titleStr, 36, nil, layerNum, true, close)
	self.bgLayer=dialogBg
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

	local icon
	if(self.type==1)then
		icon=accessoryVoApi:getAccessoryIcon(self.id,80,80,nil)
	elseif(self.type==2)then
		icon=accessoryVoApi:getFragmentIcon(self.id,80,80,nil)
	elseif(self.type==3)then
		icon=GetBgIcon(accessoryCfg.propCfg["p"..self.id].icon,nil,nil,80,80)
	end
	icon:setPosition(ccp(100,200))
	dialogBg:addChild(icon)

	local sourceStr=getlocal("accessory_sourceDesc")
	local sourceTb
	if(self.type==3)then
		sourceStr=getlocal(accessoryCfg.propCfg["p"..self.id].desc).."\n"..sourceStr
		sourceTb=accessoryCfg.propCfg["p"..self.id].source
	end
	for k,v in pairs(sourceTb) do
		sourceStr=sourceStr.." "..getlocal("accessory_sourceWay_"..v)..","
	end
	sourceStr=string.sub(sourceStr,1,string.len(sourceStr)-1)
	local sourceLb=GetTTFLabelWrap(sourceStr,25,CCSizeMake(self.dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	sourceLb:setAnchorPoint(ccp(0,0.5))
	sourceLb:setPosition(ccp(180,200))
	dialogBg:addChild(sourceLb)

	local function onGoto()
		self:gotoGet()
		self:close()
	end
	local gotoItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onGoto,nil,getlocal("confirm"),24/0.7)
	gotoItem:setScale(0.7)
	local gotoBtn=CCMenu:createWithItem(gotoItem);
	gotoBtn:setTouchPriority(-(layerNum-1)*20-2);
	gotoBtn:setPosition(ccp(self.dialogWidth/2,60))
	dialogBg:addChild(gotoBtn)

	local function onclose()
		self:close()
	end
	local cancelItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onclose,nil,getlocal("cancel"),24/0.7)
	cancelItem:setScale(0.7)
	local cancelBtn=CCMenu:createWithItem(cancelItem)
	cancelBtn:setTouchPriority(-(layerNum-1)*20-2)
	cancelBtn:setAnchorPoint(ccp(1,0.5))
	cancelBtn:setPosition(ccp(self.dialogWidth-120,60))
	cancelBtn:setVisible(false)
	cancelBtn:setPosition(ccp(999333,0))
	dialogBg:addChild(cancelBtn)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function accessorySourceDialog:gotoGet()
end
