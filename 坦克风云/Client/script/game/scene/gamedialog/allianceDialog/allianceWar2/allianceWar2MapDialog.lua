allianceWar2MapDialog={}

function allianceWar2MapDialog:new(parent,index)
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

function allianceWar2MapDialog:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	self:initMapBg()
	self.cityCfgList=allianceWar2VoApi:getCityCfgListByArea(self.areaIndex)

	for k,v in pairs(self.cityCfgList) do
		local function onClickCityIcon(object,name,tag)
			self:onClickCity(tag)
		end
		local cityIcon
		if v.icon then
			cityIcon=LuaCCSprite:createWithSpriteFrameName(v.icon,onClickCityIcon)
			cityIcon:setScale(0.6)
		else
			cityIcon=LuaCCSprite:createWithSpriteFrameName("IconWar.png",onClickCityIcon)
			if(v.type==2)then
				cityIcon:setScale(1.2)
			else
				cityIcon:setScale(0.9)
			end
		end
		cityIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		cityIcon:setTag(self.tagOffset+k)
		cityIcon:setPosition(ccp(v.pos[1],v.pos[2]))
		self.bgLayer:addChild(cityIcon,3)

    	local nameLb=GetTTFLabelWrap(getlocal(v.name),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop);
		nameLb:setAnchorPoint(ccp(0.5,1))
		nameLb:setPosition(ccp(v.pos[1],v.pos[2]-60))
		self.bgLayer:addChild(nameLb,1)

    	local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ()end)
	    lbBg:setContentSize(CCSizeMake(nameLb:getContentSize().width+30,nameLb:getContentSize().height+10))
	    lbBg:ignoreAnchorPointForPosition(false)
	    lbBg:setAnchorPoint(ccp(0.5,1))
	    lbBg:setTouchPriority(-(self.layerNum-1)*20-1)
	    lbBg:setPosition(ccp(v.pos[1],v.pos[2]-60+5))
	    self.bgLayer:addChild(lbBg)
	    lbBg:setOpacity(180)

		-- if(v.id==allianceWar2VoApi.ownCity)then
		-- 	local flag=CCSprite:createWithSpriteFrameName("IconWarRedFlage.png")
		-- 	flag:setAnchorPoint(ccp(0,0))
		-- 	if(v.type==2)then
		-- 		flag:setPosition(ccp(v.pos[1]-5,v.pos[2]+30))
		-- 	else
		-- 		flag:setPosition(ccp(v.pos[1]-5,v.pos[2]+18))
		-- 	end
		-- 	self.bgLayer:addChild(flag,2)
		-- end

		local nameBgSp=CCSprite:createWithSpriteFrameName("awNameBg.png")
		-- nameBgSp:setAnchorPoint(ccp(0,0))
		nameBgSp:setPosition(ccp(v.pos[1],v.pos[2]+60))
		nameBgSp:setScale(1.2)
		self.bgLayer:addChild(nameBgSp,2)
		local occupyLb=GetTTFLabel(getlocal("allianceWar2_no_occupied"),25)
		occupyLb:setPosition(ccp(nameBgSp:getContentSize().width/2,nameBgSp:getContentSize().height/2+5))
		nameBgSp:addChild(occupyLb,5)
		occupyLb:setScale(1/1.2)
		occupyLb:setTag(400+k)
		nameBgSp:setTag(300+k)

		if G_isGlobalServer()==true then
			local leftTimeStr="0"
			local isInOccupy,et=allianceWar2VoApi:getIsInOccupy(v.id)
			if isInOccupy==true and et and et>0 then
				local countdown=et-base.serverTime
				leftTimeStr=G_formatActiveDate(countdown)
			end
			local leftTimeLb=GetTTFLabel(leftTimeStr,25)
			leftTimeLb:setPosition(ccp(0.5,1))
			nameBgSp:addChild(leftTimeLb,1)
			leftTimeLb:setTag(500+k)

			occupyLb:setPosition(ccp(nameBgSp:getContentSize().width/2,nameBgSp:getContentSize().height/2+5+7))
			leftTimeLb:setPosition(ccp(nameBgSp:getContentSize().width/2,nameBgSp:getContentSize().height/2+5-7))
			nameBgSp:setScaleY(1.8)
			occupyLb:setScaleY(1/1.8)
			leftTimeLb:setScaleX(1/1.2)
			leftTimeLb:setScaleY(1/1.8)
		end
	end
	self.lastSelectedCityID=self.cityCfgList[1].id
	-- self.selectedBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),function ( ... ) end)
	-- self.selectedBg:setContentSize(CCSizeMake(110,110))
	self.selectedBg=CCSprite:createWithSpriteFrameName("serverWarLocalCircle.png")
	-- self.selectedBg:setContentSize(CCSizeMake(110,110))
	self.selectedBg:setVisible(false)
	self.bgLayer:addChild(self.selectedBg,1)
	self.selectedBg1=CCSprite:createWithSpriteFrameName("serverWarLocalCircle.png")
	-- self.selectedBg1:setContentSize(CCSizeMake(110,110))
	self.selectedBg1:setVisible(false)
	self.selectedBg1:setScale(0.8)
	self.bgLayer:addChild(self.selectedBg1,1)
	local fadeOut=CCFadeOut:create(0.5)
	local fadeIn=CCFadeIn:create(0.5)
	local acArr=CCArray:create()
	acArr:addObject(fadeIn)
	acArr:addObject(fadeOut)
	local seq=CCSequence:create(acArr)
	self.selectedBg1:runAction(CCRepeatForever:create(seq))
	local scaleSmall=CCScaleTo:create(0.5,0.6)
	local scaleBig=CCScaleTo:create(0.5,0.8)
	local acArr=CCArray:create()
	acArr:addObject(scaleSmall)
	acArr:addObject(scaleBig)
	local seq=CCSequence:create(acArr)
	self.selectedBg:runAction(CCRepeatForever:create(seq))


	-- local function onClickDesc()
	-- 	if(self and self.hideCityDesc)then
	-- 		self:hideCityDesc()
	-- 	end
	-- end
	-- self.cityResourceDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(20,20,10,10),onClickDesc)
	-- self.cityResourceDescBg:setTouchPriority(-(self.layerNum-1)*20-2)
	-- self.cityResourceDescBg:setVisible(false)
	-- self.cityResourceDescBg:setPositionX(999333)

	-- self.cityResourceDescLb=GetTTFLabelWrap(getlocal("allianceWar_cityResourceDesc",{"100%"}),25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
	-- local lbSize=self.cityResourceDescLb:getContentSize()
	-- self.cityResourceDescBg:setContentSize(CCSizeMake(lbSize.width+10,lbSize.height+10))
	-- self.cityResourceDescLb:setPosition(getCenterPoint(self.cityResourceDescBg))
	-- self.cityResourceDescBg:addChild(self.cityResourceDescLb)
	-- self.bgLayer:addChild(self.cityResourceDescBg,3)

	self:refreshOccupy()

	return self.bgLayer
end

function allianceWar2MapDialog:refreshOccupy()
	self.cityCfgList=allianceWar2VoApi:getCityCfgListByArea(self.areaIndex)
	if self and self.cityCfgList then
		for k,v in pairs(self.cityCfgList) do
			if v and v.id and self.bgLayer:getChildByTag(300+k) then
				local nameBgSp=self.bgLayer:getChildByTag(300+k)
				nameBgSp=tolua.cast(nameBgSp,"CCSprite")
				if nameBgSp and nameBgSp:getChildByTag(400+k) then
					local occupyLb=nameBgSp:getChildByTag(400+k)
					local leftTimeLb
					if nameBgSp and nameBgSp:getChildByTag(500+k) then
						leftTimeLb=nameBgSp:getChildByTag(500+k)
						if leftTimeLb then
							leftTimeLb:removeFromParentAndCleanup(true)
							leftTimeLb=nil
						else
							leftTimeLb=nil
						end
					end
					occupyLb=tolua.cast(occupyLb,"CCLabelTTF")
					if occupyLb then
						nameBgSp:setScaleY(1.2)
						occupyLb:setScaleY(1/1.2)
						occupyLb:setPosition(ccp(nameBgSp:getContentSize().width/2,nameBgSp:getContentSize().height/2+5))

						local str=""
						local status=allianceWar2VoApi:getStatus(v.id)
						if status==30 then
							str=getlocal("serverWarLocal_status_4")
							local cityData=allianceWar2VoApi:getCityDataByID(v.id)
							if cityData and cityData.allianceID1==nil and cityData.allianceID2==nil then
								str=getlocal("allianceWar2_no_occupied")
							end
						else
							-- print("v.id",v.id)
							local hasOwn=false
							local isInOccupy=allianceWar2VoApi:getIsInOccupy(v.id)
							-- print("isInOccupy",isInOccupy)
							-- print("status",status)
							if isInOccupy==true and (status==40 or G_isGlobalServer()==true) then
								local ownsData=allianceWar2VoApi:getOwnsData()
								if ownsData then
									for m,n in pairs(ownsData) do
										if n and n.areaid and n.areaid==v.id then
											str=n.oName
											hasOwn=true
											if G_isGlobalServer()==true then
												local leftTimeStr="0"
												local isInOccupy,et=allianceWar2VoApi:getIsInOccupy(v.id)
												if isInOccupy==true and et and et>0 then
													local countdown=et-base.serverTime
													leftTimeStr=G_formatActiveDate(countdown)
												end
												local leftTimeLb=GetTTFLabel(leftTimeStr,25)
												leftTimeLb:setPosition(ccp(0.5,1))
												nameBgSp:addChild(leftTimeLb,1)
												leftTimeLb:setTag(500+k)

												occupyLb:setPosition(ccp(nameBgSp:getContentSize().width/2,nameBgSp:getContentSize().height/2+5+7))
												leftTimeLb:setPosition(ccp(nameBgSp:getContentSize().width/2,nameBgSp:getContentSize().height/2+5-7))
												nameBgSp:setScaleY(1.8)
												occupyLb:setScaleY(1/1.8)
												leftTimeLb:setScaleX(1/1.2)
												leftTimeLb:setScaleY(1/1.8)
											end
										end
									end
								end
							end
							-- local cityData=allianceWar2VoApi:getCityDataByID(v.id)
							-- print("hasOwn",hasOwn)
							if hasOwn==false then
							-- if cityData and cityData.ownerName then
							-- 	str=cityData.ownerName
							-- else
								str=getlocal("allianceWar2_no_occupied")
							end
						end
						occupyLb:setString(str)
					end
				end
			end
		end
	end
end

function allianceWar2MapDialog:initMapBg()
	-- local center=CCSprite:createWithSpriteFrameName("IconWarMap.jpg")
	-- if(self.areaIndex==2)then
	-- 	center:setColor(ccc3(248, 185, 182))
	-- end
	-- center:setAnchorPoint(ccp(0,0))
	-- local upSide=CCSprite:createWithSpriteFrameName("IconWarMapLine_Up.png")
	-- upSide:setAnchorPoint(ccp(0,0))
	-- local downSide=CCSprite:createWithSpriteFrameName("IconWarMapLine_Down.png")
	-- downSide:setAnchorPoint(ccp(0,0))
	-- local leftSide=CCSprite:createWithSpriteFrameName("IconWarMapLine_Left.png")
	-- leftSide:setAnchorPoint(ccp(0,0))
	-- local rightSide=CCSprite:createWithSpriteFrameName("IconWarMapLine_Right.png")
	-- rightSide:setAnchorPoint(ccp(1,0))
	
	-- local map=downSide
	-- local downSize=downSide:getContentSize()
	-- leftSide:setPosition(ccp(0,downSize.height))
	-- map:addChild(leftSide)
	-- rightSide:setPosition(ccp(downSize.width,downSize.height))
	-- map:addChild(rightSide)
	-- local leftSize=leftSide:getContentSize()
	-- center:setPosition(ccp(leftSize.width,downSize.height))
	-- map:addChild(center)
	-- upSide:setPosition(ccp(0,leftSize.height+downSize.height))
	-- map:addChild(upSide)

	-- map:setScaleX((G_VisibleSizeWidth-60)/map:getContentSize().width)
	-- map:setScaleY(500/(downSize.height+leftSize.height+upSide:getContentSize().height))
	-- self.bgLayer:addChild(map)

	local center1=CCSprite:create("public/serverWarLocal/serverWarLocalMapBg.jpg")
	local scale=(G_VisibleSizeWidth/2-25)/center1:getContentSize().width
	center1:setScale(scale)
	center1:setPosition(ccp(-5+center1:getContentSize().width/2*scale,center1:getContentSize().height/2*scale+200))
	self.bgLayer:addChild(center1)
	local center2=CCSprite:create("public/serverWarLocal/serverWarLocalMapBg.jpg")
	center2:setScale(scale)
	center2:setPosition(ccp(-5+center2:getContentSize().width*3/2*scale,center2:getContentSize().height/2*scale+200))
	self.bgLayer:addChild(center2)
end

function allianceWar2MapDialog:onClickCity(tag)
	local index=tag-self.tagOffset
	local cityID=self.cityCfgList[index].id
	self.parent:showCityInfo(cityID)
end

function allianceWar2MapDialog:switchCityDesc(cityID)
	-- if(self.curShowDescID==cityID)then
	-- 	self:hideCityDesc()
	-- else
	-- 	self:showCityDesc(cityID)
	-- end
end

function allianceWar2MapDialog:hideCityDesc()
	-- if(self.isRunningAction)then
	-- 	do return end
	-- end
	-- self.isRunningAction=true
	-- local scaleTo=CCScaleTo:create(0.3,0.1,1)
	-- local function callBack()
	-- 	self.cityResourceDescBg:setVisible(false)
	-- 	self.cityResourceDescBg:setPositionX(999333)
	-- 	self.curShowDescID=nil
	-- 	self.isRunningAction=false
	-- end
	-- local callFunc=CCCallFunc:create(callBack)
	-- local seq=CCSequence:createWithTwoActions(scaleTo,callFunc)
	-- self.cityResourceDescBg:runAction(seq)
end

function allianceWar2MapDialog:showCityDesc(cityID)
	-- if(self.isRunningAction)then
	-- 	do return end
	-- end
	-- self.isRunningAction=true
	-- local cityIcon
	-- local cityType
	-- local cityAddResource=allianceWar2Cfg.resourceAddition[cityID]
	-- if(cityAddResource==nil)then
	-- 	do return end
	-- end
	-- if(self.cityCfgList[cityID] and self.cityCfgList[cityID].id==cityID)then
	-- 	cityIcon=self.bgLayer:getChildByTag(cityID+self.tagOffset)
	-- 	cityType=self.cityCfgList[cityID].type
	-- else
	-- 	for k,v in pairs(self.cityCfgList) do
	-- 		if(v.id==cityID)then
	-- 			cityIcon=self.bgLayer:getChildByTag(k+self.tagOffset)
	-- 			cityType=v.type
	-- 			break
	-- 		end
	-- 	end
	-- end
	-- local cityPosX,cityPosY=cityIcon:getPosition()
	-- local cityWidthOffset
	-- if(cityType==2)then
	-- 	cityWidthOffset=60
	-- else
	-- 	cityWidthOffset=45
	-- end
	-- self.cityResourceDescLb:setString(getlocal("allianceWar_cityResourceDesc",{cityAddResource.."%%"}))
 --    self.cityResourceDescBg:setContentSize(CCSizeMake(self.cityResourceDescLb:getContentSize().width+10,self.cityResourceDescLb:getContentSize().height+10))
 --    self.cityResourceDescLb:setPosition(getCenterPoint(self.cityResourceDescBg))
	-- self.cityResourceDescBg:setScaleX(0.1)
	-- if(cityPosX>G_VisibleSizeWidth/2)then
	-- 	self.cityResourceDescBg:setAnchorPoint(ccp(1,0.5))
	-- 	self.cityResourceDescBg:setPosition(ccp(cityPosX-cityWidthOffset,cityPosY))
	-- else
	-- 	self.cityResourceDescBg:setAnchorPoint(ccp(0,0.5))
	-- 	self.cityResourceDescBg:setPosition(ccp(cityPosX+cityWidthOffset,cityPosY))
	-- end
	-- self.cityResourceDescBg:setVisible(true)
	-- local scaleTo=CCScaleTo:create(0.3,1,1)
	-- local function callBack()
	-- 	self.curShowDescID=cityID
	-- 	self.isRunningAction=false
	-- end
	-- local callFunc=CCCallFunc:create(callBack)
	-- local seq=CCSequence:createWithTwoActions(scaleTo,callFunc)
	-- self.cityResourceDescBg:runAction(seq)
end

--被选中的城市显示特效
function allianceWar2MapDialog:showSelectedEffect(cityID)
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
	local px,py=cityIcon:getPosition()
	self.selectedBg:setPosition(ccp(px,py-10))
	self.selectedBg:setVisible(true)
	self.selectedBg1:setPosition(ccp(px,py-10))
	self.selectedBg1:setVisible(true)
	-- if(cityType==2)then
	-- 	self.selectedBg:setContentSize(CCSizeMake(110,110))
	-- else
	-- 	self.selectedBg:setContentSize(CCSizeMake(90,90))
	-- end
	-- self:switchCityDesc(cityID)
	self.lastSelectedCityID=cityID
end

function allianceWar2MapDialog:tick()
	if self and self.areaIndex and G_isGlobalServer()==true then
		self.cityCfgList=allianceWar2VoApi:getCityCfgListByArea(self.areaIndex)
		if self and self.cityCfgList then
			for k,v in pairs(self.cityCfgList) do
				if v and v.id and self.bgLayer:getChildByTag(300+k) then
					local nameBgSp=self.bgLayer:getChildByTag(300+k)
					nameBgSp=tolua.cast(nameBgSp,"CCSprite")

					if nameBgSp and nameBgSp:getChildByTag(500+k) then
						leftTimeLb=tolua.cast(nameBgSp:getChildByTag(500+k),"CCLabelTTF")
						if leftTimeLb then
							local leftTimeStr="0"
							local isInOccupy,et=allianceWar2VoApi:getIsInOccupy(v.id)
							if isInOccupy==true and et and et>0 then
								local countdown=et-base.serverTime
								if countdown<0 then
									countdown=0
								end
								leftTimeStr=G_formatActiveDate(countdown)
								leftTimeLb:setString(leftTimeStr)
							end
						end
					end
				end
			end
		end
	end
end

