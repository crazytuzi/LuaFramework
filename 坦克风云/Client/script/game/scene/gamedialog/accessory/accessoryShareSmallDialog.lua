accessoryShareSmallDialog=shareSmallDialog:new()
function accessoryShareSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function accessoryShareSmallDialog:showAccessorySmallDialog(player,accessory,layerNum,bgSrc,inRect)
    local sd=accessoryShareSmallDialog:new()
    sd:create(bgSrc,inRect,CCSizeMake(550,500),player,accessory,layerNum,nil,true)
end

function accessoryShareSmallDialog:init()
    if newGuidMgr:isNewGuiding()==true then
        do
            return
        end
    end
    spriteController:addPlist("public/nbSkill.plist")
    spriteController:addTexture("public/nbSkill.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/tankImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/refiningImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acItemBg.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")

    local accessory=self.share
    local bgWidth=550
    local bgHeight=0
    local titleBgH=80
    bgHeight=bgHeight+titleBgH

    local tankId=accessory.tid
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	local tankBg=CCSprite:create("public/accessoryOperateBg.jpg")
	local scale=(bgWidth-20)/tankBg:getContentSize().width
	tankBg:setScale(scale)
	self.bgLayer:addChild(tankBg)
    bgHeight=bgHeight+tankBg:getContentSize().height*scale+10

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local tankIcon=CCSprite:createWithSpriteFrameName("LineTank"..tankId..".png")
	self.bgLayer:addChild(tankIcon)
	tankIcon:setScale(scale)

    local cellWidth=bgWidth-20
    local lbSize=CCSize(440,0)
    local iconSize=60
    local labelWidth=160
    local labelsize=22
    local property=accessory.p --属性加成
    local tech=accessory.tech --配件科技
    local purify=accessory.purify --配件精炼
    local purifyContent --精炼激活的信息
    local techContent --配件科技信息
    local function getCellHeight()
        local cellHeight=0
        local count=SizeOfTable(property)
        if count>0 then
            if count%2>0 then
                count=math.floor(count/2)+1
            else
                count=math.floor(count/2)
            end
            cellHeight=cellHeight+count*iconSize+(count-1)*10+20
        end
        if purify then
            local totalHeight=0
            local point=purify[1]
            if point>0 then
                purifyContent={}
                local data=purify[2]
                local count=SizeOfTable(data)
                for k,v in pairs(data) do
                    local key=v[1]
                    local value=v[2]
                    local pointSp=CCSprite:createWithSpriteFrameName("circlenormal.png")
                    local lb=GetTTFLabelWrap(getlocal("accessory_addAtt",{G_getPropertyStr(key),value.."%%"}),labelsize,CCSizeMake(cellWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    totalHeight=totalHeight+lb:getContentSize().height
                    table.insert(purifyContent,{pointSp,lb})
                end
                cellHeight=cellHeight+totalHeight+iconSize+30
            end
        end
        if tech then
            local point=tech[1]
            if point>0 then
                techContent={}
                local totalHeight=0
                local data=tech[2]
                local count=SizeOfTable(data)
                for k,v in pairs(data) do
                    local skillID=v[1]
                    local lv=v[2]
                    if lv>0 then
                        local skillName=getlocal(abilityCfg[skillID][lv].name)
                        local skillNameLb=GetTTFLabelWrap(getlocal("allianceSkillName",{skillName,lv}),labelsize,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        totalHeight=totalHeight+skillNameLb:getContentSize().height
                        local param={}
                        if(abilityCfg[skillID][lv].value1)then
                            param[1]=abilityCfg[skillID][lv].value1*100
                        end
                        if(abilityCfg[skillID][lv].value2)then
                            param[2]=abilityCfg[skillID][lv].value2*100
                        end
                        local skillDesc=getlocal(abilityCfg[skillID][lv].desc,param)
                        local skillDescLb=GetTTFLabelWrap(skillDesc,labelsize,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        table.insert(techContent,{skillNameLb,skillDescLb})
                        totalHeight=totalHeight+skillDescLb:getContentSize().height
                    end
                end
                cellHeight=cellHeight+totalHeight+iconSize+30
            end
        end
        return cellHeight
    end
    local cellHeight=getCellHeight()
    local scrollFlag=false
    local tvHeight=cellHeight
    if tvHeight>300 then
        tvHeight=300
        scrollFlag=true
    end

	local infoHeight=tvHeight+20
    self.detailBg:setContentSize(CCSizeMake(cellWidth,infoHeight))
    bgHeight=bgHeight+infoHeight+20
    self.bgLayer:setContentSize(CCSizeMake(bgWidth,bgHeight))

    local posY=bgHeight-titleBgH-tankBg:getContentSize().height*scale/2-8
    tankBg:setPosition(bgWidth/2,posY)
    tankIcon:setPosition(bgWidth/2,tankBg:getPositionY())

    local leftFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0,0.5))
    leftFrameBg1:setScaleX(0.8)
    leftFrameBg1:setScaleY((tankBg:getContentSize().height+20)/leftFrameBg1:getContentSize().height)
    leftFrameBg1:setPosition(ccp(5,tankBg:getPositionY()))
    self.bgLayer:addChild(leftFrameBg1)
    local rightFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1,0.5))
    rightFrameBg1:setScaleX(0.8)
    rightFrameBg1:setScaleY((tankBg:getContentSize().height+20)/rightFrameBg1:getContentSize().height)
    rightFrameBg1:setPosition(ccp(bgWidth-5,tankBg:getPositionY()))
    self.bgLayer:addChild(rightFrameBg1)

    local centerX=bgWidth/2
    local centerY=tankIcon:getPositionY()
    local posCfg=self:getPosCfg(bgWidth,bgHeight,centerX,centerY,scale)
    self:initAccessory(posCfg,accessory,scale) --初始化各部位配件

    posY=posY-tankBg:getContentSize().height*scale/2+50
    local itemBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    itemBg:setAnchorPoint(ccp(0.5,1))
    itemBg:setScaleX((bgWidth+140)/itemBg:getContentSize().width)
    itemBg:setScaleY(60/itemBg:getContentSize().height)
    itemBg:setPosition(bgWidth/2+20,posY)
    self.bgLayer:addChild(itemBg)
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setScaleX((bgWidth-30)/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(bgWidth/2,itemBg:getPositionY()-2))
    self.bgLayer:addChild(lineSp)
    local titleSp=CCSprite:createWithSpriteFrameName("nbSkillTitle1.png")
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setPosition((bgWidth)/2,posY)
    self.bgLayer:addChild(titleSp,1)
    local gsNum=accessory.gsNum
    local titleLb=GetTTFLabel(getlocal("accessory_gsAdd",{gsNum}),25)
    titleLb:setAnchorPoint(ccp(0.5,1))
    titleLb:setPosition(bgWidth/2,posY-titleSp:getContentSize().height)
    self.bgLayer:addChild(titleLb,1)
    self.detailBg:setPosition(bgWidth/2,posY-itemBg:getContentSize().height*itemBg:getScaleY())

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local posY=cellHeight-10
            local firstPosX=20
            for k,value in pairs(property) do
				local icon
				if(k==1)then
					icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[100].icon)
				elseif(k==2)then
					icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[108].icon)
				elseif(k==3)then
					icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[201].icon)
				elseif(k==4)then
					icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[202].icon)
				end
				if icon then
			     	local posX=firstPosX
                    if k%2==0 then
                        posX=cellWidth/2+20
                    end
					icon:setScale(iconSize/icon:getContentSize().width)
					icon:setAnchorPoint(ccp(0,1))
					icon:setPosition(posX,posY-math.floor((k-1)/2)*(iconSize+10))
					cell:addChild(icon)
					local lb
					if accessoryCfg and accessoryCfg.attEffect and accessoryCfg.attEffect[k] and (accessoryCfg.attEffect[k]==1)then
						lb=GetTTFLabelWrap(getlocal("accessory_attAdd_"..k,{value.."%%"}),labelsize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					else
						lb=GetTTFLabelWrap(getlocal("accessory_attAdd_"..k,{value}),labelsize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					end
					if lb then
						lb:setAnchorPoint(ccp(0,0.5))
						lb:setPosition(icon:getPositionX()+iconSize+10,icon:getPositionY()-iconSize/2)
						cell:addChild(lb)
					end
				end
            end
            local count=SizeOfTable(property)
            if count%2>0 then
                count=math.floor(count/2)+1
            else
                count=math.floor(count/2)
            end
            posY=posY-count*iconSize-(count-1)*10-10

            if purify then
        	    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp:setAnchorPoint(ccp(0.5,1))
                lineSp:setPosition(cellWidth/2,posY)
                cell:addChild(lineSp,2)
                lineSp:setScaleX((cellWidth-50)/lineSp:getContentSize().width)
                posY=posY-20

				local iconSp=CCSprite:createWithSpriteFrameName("accessoryPurify.png")
				iconSp:setAnchorPoint(ccp(0,1))
				iconSp:setPosition(firstPosX,posY)
				iconSp:setScale(iconSize/iconSp:getContentSize().width)
				cell:addChild(iconSp)

            	local point=purify[1]
        		local purifyTitle=GetTTFLabelWrap(getlocal("accessory_purifyAdd",{point}),labelsize,CCSizeMake(cellWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        		purifyTitle:setAnchorPoint(ccp(0,0.5))
        		purifyTitle:setPosition(iconSp:getPositionX()+iconSize+10,posY-iconSize/2)
        		cell:addChild(purifyTitle)
        		posY=posY-iconSize
        		if purifyContent then
	           		for k,v in pairs(purifyContent) do
						local pointSp=v[1]
						local lb=v[2]
						if pointSp and lb then
							lb:setAnchorPoint(ccp(0,1))
							lb:setPosition(ccp(60,posY))
							cell:addChild(lb)
							pointSp:setAnchorPoint(ccp(0,0.5))
	        				pointSp:setPosition(ccp(20,posY-lb:getContentSize().height/2))
							cell:addChild(pointSp)
							posY=posY-lb:getContentSize().height
						end
		            end
	        		posY=posY-10
        		end
            end
            if tech then
    		    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp:setAnchorPoint(ccp(0.5,1))
                lineSp:setPosition(cellWidth/2,posY)
                cell:addChild(lineSp,2)
                lineSp:setScaleX((cellWidth-50)/lineSp:getContentSize().width)

                posY=posY-20
				local iconSp=CCSprite:createWithSpriteFrameName("accessoryPurify.png")
				iconSp:setAnchorPoint(ccp(0,1))
				iconSp:setPosition(firstPosX,posY)
				iconSp:setScale(iconSize/iconSp:getContentSize().width)
				cell:addChild(iconSp)
            	local point=tech[1]
        		local techTitle=GetTTFLabelWrap(getlocal("accessory_techPoint",{point}),labelsize,CCSizeMake(cellWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        		techTitle:setAnchorPoint(ccp(0,0.5))
        		techTitle:setPosition(iconSp:getPositionX()+iconSize+10,posY-iconSize/2)
        		cell:addChild(techTitle)
        		posY=posY-iconSize-5
        		if techContent then
		            for k,v in pairs(techContent) do
						local skillNameLb=v[1]
						local skillDescLb=v[2]
						if skillNameLb and skillDescLb then
							skillNameLb:setAnchorPoint(ccp(0,1))
							skillNameLb:setPosition(ccp(20,posY))
							cell:addChild(skillNameLb)
							skillDescLb:setAnchorPoint(ccp(0,1))
	        				skillDescLb:setPosition(ccp(20,posY-skillNameLb:getContentSize().height))
							cell:addChild(skillDescLb)
							posY=posY-skillNameLb:getContentSize().height-skillDescLb:getContentSize().height
						end
		            end
        		end
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,10))
    self.detailBg:addChild(self.tv,2)
    if scrollFlag==true then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
end

function accessoryShareSmallDialog:getPosCfg(bgWidth,bgHeight,centerX,centerY,scale)
	local posCfg={}
	local tankWidth=416
	local tankHeight=256
	local leftX=centerX-tankWidth/2--35
	local midLeftX=centerX-80
	local midRightX=centerX+80
	local rightX=centerX+tankWidth/2--+35
	local upY=centerY+tankHeight/2--+35
	local midUpY=centerY+tankHeight/2-80*scale
	local midBtmY=centerY-tankHeight/2+80*scale
	local btmY=centerY-tankHeight/2--35
	posCfg[1]=ccp(leftX,midBtmY)
	posCfg[2]=ccp(rightX,midUpY)
	posCfg[3]=ccp(midLeftX,upY)
	posCfg[4]=ccp(leftX,midUpY)
	posCfg[5]=ccp(rightX,midBtmY)
	posCfg[6]=ccp(midRightX,btmY)
	posCfg[7]=ccp(midLeftX,btmY)
	posCfg[8]=ccp(midRightX,upY)

	return posCfg
end
function accessoryShareSmallDialog:initAccessory(posCfg,accessory,scale)
	local accessoryTb=accessory.acc
	for k,v in pairs(posCfg) do
		local aIcon
		local item=accessoryTb[k]
		if item and item~="-" then
			local atype=item.rt
			local rank=item.rf --改造等级
			local level=item.lv --强化等级
            local promoteLv = item.promoteLv --红配晋升等级
			local bindFlag=item.bd --是否绑定
			local quality=item.ql --配件品质
			local tech=item.tech
			local techId=tech[1]
			local techLv=tech[2]

			aIcon=accessoryVoApi:getAccessoryIcon(atype,60,80*scale)
			local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
			local rankLb=GetTTFLabel(rank,30)
			rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
			rankTip:addChild(rankLb)
			rankTip:setScale(0.5)
			rankTip:setAnchorPoint(ccp(0,1))
			rankTip:setPosition(ccp(0,100))
			aIcon:addChild(rankTip)
			local lvLb=GetTTFLabel(getlocal("fightLevel",{level}),20)
			lvLb:setAnchorPoint(ccp(1,0))
			lvLb:setPosition(ccp(85,5))
			aIcon:addChild(lvLb)
			if bindFlag==1 then
				local blingSp=CCSprite:createWithSpriteFrameName("accessoryBling.png")
				blingSp:setOpacity(0)
				blingSp:setPosition(aIcon:getContentSize().width/2,aIcon:getContentSize().height-blingSp:getContentSize().height/4 - 5)
				aIcon:addChild(blingSp)
				local fadeIn=CCFadeIn:create(0.6)
				local moveTo1=CCMoveTo:create(0.6,ccp(aIcon:getContentSize().width/2,aIcon:getContentSize().height/2-5))
				local fadeInArr=CCArray:create()
				fadeInArr:addObject(fadeIn)
				fadeInArr:addObject(moveTo1)
				local fadeInSpawn=CCSpawn:create(fadeInArr)
				local fadeOut=CCFadeOut:create(0.6)
				local moveTo2=CCMoveTo:create(0.6,ccp(aIcon:getContentSize().width/2,blingSp:getContentSize().height/4-5))
				local fadeOutArr=CCArray:create()
				fadeOutArr:addObject(fadeOut)
				fadeOutArr:addObject(moveTo2)
				local fadeOutSpawn=CCSpawn:create(fadeOutArr)
				local delay=CCDelayTime:create(0.8)
				local function onMoveEnd()
					blingSp:setPosition(aIcon:getContentSize().width/2,aIcon:getContentSize().height-blingSp:getContentSize().height/4 - 5)
				end
				local moveEndFunc=CCCallFunc:create(onMoveEnd)
				local acArr=CCArray:create()
				acArr:addObject(fadeInSpawn)
				acArr:addObject(fadeOutSpawn)
				acArr:addObject(delay)
				acArr:addObject(moveEndFunc)
				local seq=CCSequence:create(acArr)
				local repeatForever=CCRepeatForever:create(seq)
				blingSp:runAction(repeatForever)
				if (quality>3 and base.accessoryTech==1) then
					local techTip=CCSprite:createWithSpriteFrameName("IconLevelBlue.png")
					local techLb=GetTTFLabel(techLv or 0,30)
					techLb:setPosition(getCenterPoint(techTip))
					techTip:addChild(techLb)
					techTip:setScale(0.5)
					techTip:setAnchorPoint(ccp(1,1))
					techTip:setPosition(ccp(98,100))
					aIcon:addChild(techTip)
				end
                --红配晋升开关开启 && 红色配件 && 已经绑定
                if base.redAccessoryPromote == 1 and quality == 5 then
                    local promoteLvBg = CCSprite:createWithSpriteFrameName("accessoryPromote_IconLevel.png")
                    local promoteLvLb = GetTTFLabel(promoteLv or 0, 30)
                    promoteLvLb:setPosition(getCenterPoint(promoteLvBg))
                    promoteLvBg:addChild(promoteLvLb)
                    promoteLvBg:setScale(0.5)
                    promoteLvBg:setAnchorPoint(ccp(0, 0))
                    promoteLvBg:setPosition(ccp(0, 0))
                    aIcon:addChild(promoteLvBg)
                end
			end
		else
			aIcon=GetBgIcon("accessoryshadow_"..k..".png",nil,nil,60,80*scale)
		end
		if aIcon then
			aIcon:setPosition(v)
			self.bgLayer:addChild(aIcon,1)
		end
	end
end

function accessoryShareSmallDialog:tick()
end

function accessoryShareSmallDialog:dispose() --释放方法
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.touchDialogBg=nil
    spriteController:removePlist("public/nbSkill.plist")
    spriteController:removeTexture("public/nbSkill.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/tankImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/tankImage.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acItemBg.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/acItemBg.png")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/refiningImage.plist")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/refiningImage.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
end
