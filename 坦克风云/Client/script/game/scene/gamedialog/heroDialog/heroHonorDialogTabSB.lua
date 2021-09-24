	--可授勋将领列表
heroHonorDialogTabSB={}
function heroHonorDialogTabSB:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.heroList=nil
	return nc
end

function heroHonorDialogTabSB:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local bigBg=CCSprite:create("public/emblem/emblemBlackBg.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	bigBg:setScaleY((G_VisibleSizeHeight - 194)/bigBg:getContentSize().height)
	bigBg:setScaleX((G_VisibleSizeWidth - 42)/bigBg:getContentSize().width)
	bigBg:setAnchorPoint(ccp(0,0))
	bigBg:setPosition(ccp(21,32))
	self.bgLayer:addChild(bigBg)
	self.heroList=heroVoApi:getCanHonorHeroList()
	self.curHero=heroVoApi:getCurrentHonorHero()
	local function honorListener(event,data)
		self:dealWithEvent(event,data)
	end
	self.honorListener=honorListener
	eventDispatcher:addEventListener("hero.honor",honorListener)
	self:initTableView()
	self.noHeroLb=GetTTFLabelWrap(getlocal("hero_honor_noCanHonor"),35,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.noHeroLb:setColor(G_ColorWhite)
	self.noHeroLb:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight - 135)/2 + 15))
	self.bgLayer:addChild(self.noHeroLb)
	if(#self.heroList==0)then
		self.noHeroLb:setVisible(true)
	else
		self.noHeroLb:setVisible(false)
	end
	return self.bgLayer
end

--设置对话框里的tableView
function heroHonorDialogTabSB:initTableView()
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 200),nil)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(30,30))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroHonorDialogTabSB:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #(self.heroList)
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 60,170)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(object,fn,tag)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				local index=tag - 1000
				self:showHonor(index)
			end
		end
		local height = 150
		local hero=self.heroList[idx+1]
		local mIcon=heroVoApi:getHeroIcon(hero.hid,hero.productOrder)
		mIcon:setPosition(ccp(90,height/2 + 5))
		mIcon:setScale(0.8)
		cell:addChild(mIcon,2)
		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocalTip.png",CCRect(40, 20, 40, 45),cellClick)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60 - 75, height - 30))
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setRotation(180)
		backSprie:setTag(1001 + idx)
		backSprie:setIsSallow(false)
		backSprie:setPosition((G_VisibleSizeWidth - 60)/2 + 30,height/2)
		cell:addChild(backSprie)

		local nameStr=getlocal(heroListCfg[hero.hid].heroName)
		if  heroVoApi:isInQueueByHid(hero.hid) then
			nameStr=nameStr..getlocal("designate")
		end
		if(self.curHero and self.curHero.hid==hero.hid)then
			local borderFlame1 = CCParticleSystemQuad:create("worldWar/fireBorder.plist")
			borderFlame1:setScaleX(1.2)
			borderFlame1.positionType=kCCPositionTypeGrouped
			borderFlame1:setPosition(ccp((G_VisibleSizeWidth - 60)/2 + 30,15))
			cell:addChild(borderFlame1,1)
			local borderFlame2 = CCParticleSystemQuad:create("worldWar/fireBorder.plist")
			borderFlame2:setScaleX(1.2)
			borderFlame2.positionType=kCCPositionTypeGrouped
			borderFlame2:setPosition(ccp((G_VisibleSizeWidth - 60)/2 + 30,height - 25))
			cell:addChild(borderFlame2,1)
			local borderFlame4 = CCParticleSystemQuad:create("worldWar/fireBorderVertical.plist")
			borderFlame4:setScaleY(0.3)
			borderFlame4.positionType=kCCPositionTypeGrouped
			borderFlame4:setPosition(ccp(G_VisibleSizeWidth - 75,height/2))
			cell:addChild(borderFlame4,1)
			self.flameTb={borderFlame1,borderFlame2,borderFlame3,borderFlame4}
		end
		local nameLb=GetTTFLabel(nameStr, 24, true)
		local color=heroVoApi:getHeroColor(hero.productOrder)
		nameLb:setColor(color)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(90 + mIcon:getContentSize().width/2,height/2 + 15))
		cell:addChild(nameLb)
		local lvStr=G_LV()..hero.level.."/"..G_LV()..heroCfg.heroLevel[hero.productOrder]
		local lvLb=GetTTFLabel(lvStr,22)
		lvLb:setAnchorPoint(ccp(0,0.5))
		lvLb:setPosition(ccp(90 + mIcon:getContentSize().width/2,height/2 - 20))
		cell:addChild(lvLb)

		local function onClickBtn(tag,object)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
	                do
	                    return
	                end
	            else
	                base.setWaitTime=G_getCurDeviceMillTime()
	            end
				local index=tag - 1000
				self:showHonor(index)
			end
		end
		local menuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickBtn,1001 + idx,getlocal("alliance_list_check_info"),24)
		menuItem:setAnchorPoint(ccp(1,0.5))
		local menuBtn=CCMenu:createWithItem(menuItem)
		menuBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		menuBtn:setPosition(ccp(G_VisibleSizeWidth - 90,height/2))
		cell:addChild(menuBtn)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function heroHonorDialogTabSB:showHonor(index)
	local hero=self.heroList[index]
	if(hero)then
		heroVoApi:showHonorTaskDialog(hero,self.layerNum + 1)
	end
end

function heroHonorDialogTabSB:dealWithEvent(event,data)
	if(data.type=="accept")then
		self.heroList=heroVoApi:getCanHonorHeroList()
		self.curHero=heroVoApi:getCurrentHonorHero()
		self.tv:reloadData()
	elseif(data.type=="success")then
		self.heroList=heroVoApi:getCanHonorHeroList()
		self.curHero=heroVoApi:getCurrentHonorHero()
		self.tv:reloadData()
		if(#self.heroList==0)then
			self.noHeroLb:setVisible(true)
		else
			self.noHeroLb:setVisible(false)
		end
	elseif(data.type=="cancel")then
		if(self.flameTb)then
			for k,v in pairs(self.flameTb) do
				if(v and v:getParent())then
					v:removeFromParentAndCleanup(true)
				end
			end
			self.flameTb=nil
		end
		self.heroList=heroVoApi:getCanHonorHeroList()
		self.curHero=heroVoApi:getCurrentHonorHero()
		self.tv:reloadData()
	elseif(data.type=="update")then
		self.heroList=heroVoApi:getCanHonorHeroList()
		self.curHero=heroVoApi:getCurrentHonorHero()
		self.tv:reloadData()
	end
end

function heroHonorDialogTabSB:tick()

end

function heroHonorDialogTabSB:dispose()
	eventDispatcher:removeEventListener("hero.honor",self.honorListener)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
	self.bgLayer=nil
end