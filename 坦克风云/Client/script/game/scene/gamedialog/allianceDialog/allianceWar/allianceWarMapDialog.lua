allianceWarMapDialog={}

function allianceWarMapDialog:new(parent,index)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.parent=parent
	self.areaIndex=index
	self.cityCfgList={}
	self.tagOffset=518
	self.isRunningAction=false
	return nc
end

function allianceWarMapDialog:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	self:initMapBg()
	self.cityCfgList=allianceWarVoApi:getCityCfgListByArea(self.areaIndex)
	for k,v in pairs(self.cityCfgList) do
		local function onClickCityIcon(object,name,tag)
			self:onClickCity(tag)
		end
		local cityIcon=LuaCCSprite:createWithSpriteFrameName("IconWar.png",onClickCityIcon)
		if(v.type==2)then
			cityIcon:setScale(1.2)
		else
			cityIcon:setScale(0.9)
		end
		cityIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		cityIcon:setTag(self.tagOffset+k)
		cityIcon:setPosition(ccp(v.pos[1],v.pos[2]))
		self.bgLayer:addChild(cityIcon,3)

		local nameLb=GetTTFLabelWrap(getlocal(v.name),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop);
		nameLb:setAnchorPoint(ccp(0.5,1))
		nameLb:setPosition(ccp(v.pos[1],v.pos[2]-50))
		self.bgLayer:addChild(nameLb)
		if(v.id==allianceWarVoApi.ownCity)then
			local flag=CCSprite:createWithSpriteFrameName("IconWarRedFlage.png")
			flag:setAnchorPoint(ccp(0,0))
			if(v.type==2)then
				flag:setPosition(ccp(v.pos[1]-5,v.pos[2]+30))
			else
				flag:setPosition(ccp(v.pos[1]-5,v.pos[2]+18))
			end
			self.bgLayer:addChild(flag,2)
		end
	end
	self.lastSelectedCityID=self.cityCfgList[1].id
	self.selectedBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),function ( ... ) end)
	self.selectedBg:setContentSize(CCSizeMake(110,110))
	self.selectedBg:setVisible(false)
	self.bgLayer:addChild(self.selectedBg,1)

	local function onClickDesc()
		if(self and self.hideCityDesc)then
			self:hideCityDesc()
		end
	end
	self.cityResourceDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(20,20,10,10),onClickDesc)
	self.cityResourceDescBg:setTouchPriority(-(self.layerNum-1)*20-2)
	self.cityResourceDescBg:setVisible(false)
	self.cityResourceDescBg:setPositionX(999333)

	self.cityResourceDescLb=GetTTFLabelWrap(getlocal("allianceWar_cityResourceDesc",{"100%"}),25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
	local lbSize=self.cityResourceDescLb:getContentSize()
	self.cityResourceDescBg:setContentSize(CCSizeMake(lbSize.width+10,lbSize.height+10))
	self.cityResourceDescLb:setPosition(getCenterPoint(self.cityResourceDescBg))
	self.cityResourceDescBg:addChild(self.cityResourceDescLb)
	self.bgLayer:addChild(self.cityResourceDescBg,3)
	return self.bgLayer
end

function allianceWarMapDialog:initMapBg()
	local center=CCSprite:createWithSpriteFrameName("IconWarMap.jpg")
	if(self.areaIndex==2)then
		center:setColor(ccc3(248, 185, 182))
	end
	center:setAnchorPoint(ccp(0,0))
	local upSide=CCSprite:createWithSpriteFrameName("IconWarMapLine_Up.png")
	upSide:setAnchorPoint(ccp(0,0))
	local downSide=CCSprite:createWithSpriteFrameName("IconWarMapLine_Down.png")
	downSide:setAnchorPoint(ccp(0,0))
	local leftSide=CCSprite:createWithSpriteFrameName("IconWarMapLine_Left.png")
	leftSide:setAnchorPoint(ccp(0,0))
	local rightSide=CCSprite:createWithSpriteFrameName("IconWarMapLine_Right.png")
	rightSide:setAnchorPoint(ccp(1,0))
	
	local map=downSide
	local downSize=downSide:getContentSize()
	leftSide:setPosition(ccp(0,downSize.height))
	map:addChild(leftSide)
	rightSide:setPosition(ccp(downSize.width,downSize.height))
	map:addChild(rightSide)
	local leftSize=leftSide:getContentSize()
	center:setPosition(ccp(leftSize.width,downSize.height))
	map:addChild(center)
	upSide:setPosition(ccp(0,leftSize.height+downSize.height))
	map:addChild(upSide)

	map:setScaleX((G_VisibleSizeWidth-60)/map:getContentSize().width)
	map:setScaleY(500/(downSize.height+leftSize.height+upSide:getContentSize().height))
	self.bgLayer:addChild(map)
end

function allianceWarMapDialog:onClickCity(tag)
	local index=tag-self.tagOffset
	local cityID=self.cityCfgList[index].id
	self.parent:showCityInfo(cityID)
end

function allianceWarMapDialog:switchCityDesc(cityID)
	if(self.curShowDescID==cityID)then
		self:hideCityDesc()
	else
		self:showCityDesc(cityID)
	end
end

function allianceWarMapDialog:hideCityDesc()
	if(self.isRunningAction)then
		do return end
	end
	self.isRunningAction=true
	local scaleTo=CCScaleTo:create(0.3,0.1,1)
	local function callBack()
		self.cityResourceDescBg:setVisible(false)
		self.cityResourceDescBg:setPositionX(999333)
		self.curShowDescID=nil
		self.isRunningAction=false
	end
	local callFunc=CCCallFunc:create(callBack)
	local seq=CCSequence:createWithTwoActions(scaleTo,callFunc)
	self.cityResourceDescBg:runAction(seq)
end

function allianceWarMapDialog:showCityDesc(cityID)
	if(self.isRunningAction)then
		do return end
	end
	self.isRunningAction=true
	local cityIcon
	local cityType
	local cityAddResource=allianceWarCfg.resourceAddition[cityID]
	if(cityAddResource==nil)then
		do return end
	end
	if(self.cityCfgList[cityID] and self.cityCfgList[cityID].id==cityID)then
		cityIcon=self.bgLayer:getChildByTag(cityID+self.tagOffset)
		cityType=self.cityCfgList[cityID].type
	else
		for k,v in pairs(self.cityCfgList) do
			if(v.id==cityID)then
				cityIcon=self.bgLayer:getChildByTag(k+self.tagOffset)
				cityType=v.type
				break
			end
		end
	end
	local cityPosX,cityPosY=cityIcon:getPosition()
	local cityWidthOffset
	if(cityType==2)then
		cityWidthOffset=60
	else
		cityWidthOffset=45
	end
	self.cityResourceDescLb:setString(getlocal("allianceWar_cityResourceDesc",{cityAddResource.."%%"}))
    self.cityResourceDescBg:setContentSize(CCSizeMake(self.cityResourceDescLb:getContentSize().width+10,self.cityResourceDescLb:getContentSize().height+10))
    self.cityResourceDescLb:setPosition(getCenterPoint(self.cityResourceDescBg))
	self.cityResourceDescBg:setScaleX(0.1)
	if(cityPosX>G_VisibleSizeWidth/2)then
		self.cityResourceDescBg:setAnchorPoint(ccp(1,0.5))
		self.cityResourceDescBg:setPosition(ccp(cityPosX-cityWidthOffset,cityPosY))
	else
		self.cityResourceDescBg:setAnchorPoint(ccp(0,0.5))
		self.cityResourceDescBg:setPosition(ccp(cityPosX+cityWidthOffset,cityPosY))
	end
	self.cityResourceDescBg:setVisible(true)
	local scaleTo=CCScaleTo:create(0.3,1,1)
	local function callBack()
		self.curShowDescID=cityID
		self.isRunningAction=false
	end
	local callFunc=CCCallFunc:create(callBack)
	local seq=CCSequence:createWithTwoActions(scaleTo,callFunc)
	self.cityResourceDescBg:runAction(seq)
end

--被选中的城市显示特效
function allianceWarMapDialog:showSelectedEffect(cityID)
	local cityIcon
	local cityType
	if(self.cityCfgList[cityID] and self.cityCfgList[cityID].id==cityID)then
		cityIcon=self.bgLayer:getChildByTag(cityID+self.tagOffset)
		cityType=self.cityCfgList[cityID].type
	else
		for k,v in pairs(self.cityCfgList) do
			if(v.id==cityID)then
				cityIcon=self.bgLayer:getChildByTag(k+self.tagOffset)
				cityType=v.type
				break
			end
		end
	end
	self.selectedBg:setPosition(cityIcon:getPosition())
	self.selectedBg:setVisible(true)
	if(cityType==2)then
		self.selectedBg:setContentSize(CCSizeMake(110,110))
	else
		self.selectedBg:setContentSize(CCSizeMake(90,90))
	end
	self:switchCityDesc(cityID)
	self.lastSelectedCityID=cityID
end