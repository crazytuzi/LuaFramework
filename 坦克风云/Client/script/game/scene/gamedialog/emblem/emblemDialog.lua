--军徽初始面板
emblemDialog=commonDialog:new()

function emblemDialog:new(callBack,operatType,troopId)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.allEmblems={}
	nc.btnColorTb = {G_ColorWhite,G_ColorGreen,G_ColorBlue,G_ColorPurple,G_ColorOrange}
	nc.freeGetFlagIcon = nil--免费获取提示图标
	nc.qualityTabTb={}
	nc.selectedQuality=0
	nc.operatCallBack = callBack -- 装备上阵的回调方法，用于刷新装备了的超级装备
	nc.operatType=operatType --操作类型 1图鉴中显示 2装备基础操作  3装备上阵 4邮件中查看 5装配大师装配 
	nc.troopId=troopId
	return nc
end

function emblemDialog:resetTab()
	local strSize2 = 19
	local addPosX = 0
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =23
    elseif G_getCurChoseLanguage() =="ru" then
    	addPosX =25
    end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/emblem/emblemImage.plist")
	spriteController:addTexture("public/emblem/emblemImage.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
	spriteController:addTexture("public/allianceWar2/allianceWar2.png")
	local posY = G_VisibleSizeHeight - 120
	local posX=170
	local function onSelectQuality(object,fn,tag)
		if(tag)then
			if(tag==99)then
				if(self.selectedQuality==0)then
					do return end
				end
				for k,v in pairs(self.qualityTabTb) do
					v:setColor(ccc3(120,120,120))
					v:setScale(1)
				end
				self.selectedQuality=0
				local lb=tolua.cast(self.viewBtn:getChildByTag(101),"CCLabelTTF")
				lb:setColor(G_ColorWhite)
			elseif(self.selectedQuality==tag)then
				do return end
			else
				self.selectedQuality=tag
				for k,v in pairs(self.qualityTabTb) do
					if(k==tag)then
						v:setColor(G_ColorWhite)
						v:setScale(1.1)
					else
						v:setColor(ccc3(120,120,120))
						v:setScale(1)
					end
				end
				local lb=tolua.cast(self.viewBtn:getChildByTag(101),"CCLabelTTF")
				lb:setColor(ccc3(150,150,150))
			end
			self:refreshList()
		end
	end
	local viewLb=GetTTFLabel(getlocal("world_war_sub_title21"),strSize2)
	self.viewBtn=LuaCCScale9Sprite:createWithSpriteFrameName("emblemViewAll.png",CCRect(10,0,20,64),onSelectQuality)
	self.viewBtn:setContentSize(CCSizeMake(viewLb:getContentSize().width + 60,64))
	self.viewBtn:setTag(99)
	self.viewBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.viewBtn:setPosition(75,posY)
	self.bgLayer:addChild(self.viewBtn)
	viewLb:setTag(101)
	viewLb:setPosition(self.viewBtn:getContentSize().width/2 - 10,32)
	self.viewBtn:addChild(viewLb)
	for i=1,5 do
		local tabBtn=LuaCCSprite:createWithSpriteFrameName("emblemQ"..i..".png",onSelectQuality)
		tabBtn:setTag(i)
		tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		tabBtn:setPosition(posX+addPosX,posY)
		self.bgLayer:addChild(tabBtn,1)
		tabBtn:setColor(ccc3(120,120,120))
		self.qualityTabTb[i]=tabBtn
		posX=posX + 100
	end
	self:refreshList()
end

function emblemDialog:refreshList()
	self.allEmblems={}
	local listCfg=G_clone(emblemListCfg.equipListCfg)
	for k,v in pairs(emblemVoApi:getEquipList()) do
		if(self.selectedQuality==0 or self.selectedQuality==v.cfg.color)then
			table.insert(self.allEmblems,v)
		end
		listCfg[v.id]=nil
		if(v.cfg.lv and v.cfg.lv>0)then
			local start = string.find(v.id,"_")
			if start and start>1 then
				local originID=string.sub(v.id,1,start-1)
				listCfg[originID]=nil
			end
		end
	end
	local tmpTb={}
	for k,v in pairs(listCfg) do
		if(v and (self.selectedQuality==0 or self.selectedQuality==v.color) and (v.lv==0 or v.lv==nil) and v.isShow==1)then
			local eVo=emblemVo:new(v)
			eVo:initWithData(k,0)
			table.insert(tmpTb,eVo)
		end
	end
	local function sortFunc(a,b)
		if(a.cfg.color==b.cfg.color)then
			if(a.cfg.lv==b.cfg.lv)then
				return a.cfg.qiangdu>b.cfg.qiangdu
			else
				return a.cfg.lv>b.cfg.lv
			end
		else
			return a.cfg.color>b.cfg.color
		end
	end
	table.sort(tmpTb,sortFunc)
	for k,v in pairs(tmpTb) do
		table.insert(self.allEmblems,v)
	end
	if self.operatType==5 and self.troopId and emblemTroopVoApi then
		self.allEmblems=emblemTroopVoApi:checkIsCanEquip(self.troopId,self.allEmblems)
	end

	if(self.tv)then
		self.tv:reloadData()
	end
end

function emblemDialog:initTableView()
	local function callBack(...)
	   return self:eventHandler(...)
	end

	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 260),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(20,95))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
	local function onRefresh(event,data)
		if emblemVoApi:checkIfHadFreeCost() == true then
			self.freeGetFlagIcon:setVisible(true)
		else
			self.freeGetFlagIcon:setVisible(false)
		end
		if data then
			for k,v in pairs(data) do
				if(self.selectedQuality==0 or self.selectedQuality==v.cfg.color)then
					self:refreshList()
					break
				end
			end
		else
			self:refreshList()
		end
	end
	self.refreshListener = onRefresh
	eventDispatcher:addEventListener("emblem.data.refresh",self.refreshListener)
	if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==16)then
		otherGuideMgr:toNextStep()
	end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function emblemDialog:eventHandler(handler,fn,idx,cel)
	local strSize2 = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =24
    end
	if fn=="numberOfCellsInTableView" then
		return math.max(math.ceil((#self.allEmblems)/3),1)
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 40,250)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local startIndex=idx*3
		--为了防止一次渲染太多造成卡顿，因此后面的做一个延迟展示处理
		local function realShow()
			if(self and self.bgLayer)then
				local startIndex=idx*3
				local bgWidth=(G_VisibleSizeWidth - 40)/3
				for i=1,3 do
					local emblemVo=self.allEmblems[startIndex + i]
					if(emblemVo)then
						local function showInfo()
							if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
								if G_checkClickEnable()==false then
									do return end
								else
									base.setWaitTime=G_getCurDeviceMillTime()
								end
								emblemVoApi:showInfoDialog(emblemVo,self.layerNum + 1,nil,self.operatType,self.operatCallBack,self)
							end
						end
						local showItemCfg=emblemVo.cfg
						local emblemIcon = emblemVoApi:getEquipIcon(emblemVo.id,showInfo,startIndex + i,emblemVo.num,showItemCfg.qiangdu)
						emblemIcon:setTouchPriority(((-(self.layerNum-1)*20-2)))
						emblemIcon:setAnchorPoint(ccp(0.5,0))
						emblemIcon:setPosition(ccp(bgWidth/2 + (i - 1)*bgWidth,0))
						cell:addChild(emblemIcon)
						if(emblemVo.num==0)then
							local pos=getCenterPoint(emblemIcon)
							local lockBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),showInfo)
							lockBg:setOpacity(120)
							lockBg:setContentSize(emblemIcon:getContentSize())
							lockBg:setPosition(pos)
							emblemIcon:addChild(lockBg,5)
							local lbBg=CCSprite:createWithSpriteFrameName("emblemLockBg.png")
							lbBg:setPosition(pos)
							emblemIcon:addChild(lbBg,6)
							local lb=GetTTFLabel(getlocal("alien_tech_used_status_3"),strSize2,true)
							lb:setColor(G_ColorRed)
							lb:setPosition(pos)
							emblemIcon:addChild(lb,7)
						elseif emblemVo.num==emblemVo:getEquipBattleNum() or emblemVo.num==emblemVo:getTroopEquipNum() then
							local pos=getCenterPoint(emblemIcon)
							local outBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),showInfo)
							outBg:setOpacity(120)
							outBg:setContentSize(emblemIcon:getContentSize())
							outBg:setPosition(pos)
							emblemIcon:addChild(outBg,5)
							local lbBg=CCSprite:createWithSpriteFrameName("emblemUnlockBg.png")
							lbBg:setPosition(pos)
							emblemIcon:addChild(lbBg,6)
							local lbStr=""
							if emblemVo.num==emblemVo:getEquipBattleNum() then
								lbStr=getlocal("emblem_battle")
							else
								lbStr=getlocal("skill_equiped")
							end
							local lb=GetTTFLabel(lbStr,24,true)
							lb:setColor(G_ColorGreen)
							lb:setPosition(pos)
							emblemIcon:addChild(lb,7)
						end
					end
				end
			end
		end
		if(idx<=4)then
			realShow()
		else
			local delay=CCDelayTime:create((idx + 1)*0.1)
			local callFunc=CCCallFunc:create(realShow)
			local seq=CCSequence:createWithTwoActions(delay,callFunc)
			cell:runAction(seq)
		end
		return cell
	elseif fn=="ccTouchBegan" then
	   self.isMoved=false
	   return true
   elseif fn=="ccTouchMoved" then
		self.isMoved=true
   elseif fn=="ccTouchEnded"  then
	   
   end
end

function emblemDialog:tabClickColor(idx)
	local index=0
	for k,v in pairs(self.allTabs) do
		 if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
			-- local tabBtnItem = v
			-- local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
			-- tabBtnLabel:setColor(G_ColorWhite)

		 else
			v:setEnabled(true)
			-- local tabBtnItem = v
			-- local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
			-- tabBtnLabel:setColor(self.btnColorTb[index + 1])

		 end
		 index=index+1
	end
end

function emblemDialog:doUserHandler()
	local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =24
    end
	local function getHandler()
		if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==17)then
			otherGuideMgr:toNextStep()
		end
		emblemVoApi:showGetDialog(self.layerNum + 1)
	end
	local tempBtnScale = 0.7
	-- 军徽获取
	local itemGet = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",getHandler,2,getlocal("emblem_btn_get"),strSize2/tempBtnScale)
	itemGet:setPosition(ccp(120,60))
	itemGet:setScale(tempBtnScale)
	local capInSet1 = CCRect(17, 17, 1, 1)
	local function touchClick()
	end
	self.freeGetFlagIcon=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
	self.freeGetFlagIcon:setPosition(ccp(190,55))
	itemGet:addChild(self.freeGetFlagIcon)
	if emblemVoApi:checkIfHadFreeCost() == true then
		self.freeGetFlagIcon:setVisible(true)
	else
		self.freeGetFlagIcon:setVisible(false)
	end

	local function bulkSaleHandler()
		emblemVoApi:showBulkSaleDialog(self.layerNum + 1)
	end
	-- 军徽分解
	local itemDecompose = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",bulkSaleHandler,3,getlocal("emblem_btn_decompose"),strSize2/tempBtnScale)
	itemDecompose:setPosition(ccp(G_VisibleSizeWidth/2,60))
	itemDecompose:setScale(tempBtnScale)

	local function advanceHandler()
		emblemVoApi:showAdvanceDialog(self.layerNum + 1)
	end
	-- 军徽进阶
	local itemAdvance = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",advanceHandler,4,getlocal("emblem_btn_advance"),strSize2/tempBtnScale)
	itemAdvance:setPosition(ccp(G_VisibleSizeWidth - 120,60))
	itemAdvance:setScale(tempBtnScale)

	local menu = CCMenu:create()
	menu:addChild(itemGet)
	menu:addChild(itemDecompose)
	menu:addChild(itemAdvance)
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority((-(self.layerNum-1)*20-4))
	self.bgLayer:addChild(menu)
	if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==16)then
		otherGuideMgr:setGuideStepField(17,itemGet,true)
		otherGuideMgr:showGuide(17)
	end
end

function emblemDialog:tick()
	
end

function emblemDialog:dispose()
	eventDispatcher:removeEventListener("emblem.data.refresh",self.refreshListener)
	spriteController:removePlist("public/emblem/emblemImage.plist")
	spriteController:removeTexture("public/emblem/emblemImage.png")
	spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
	spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.png")
	for k,v in pairs(emblemListCfg.equipListCfg) do
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemIcon_"..k..".png")
	end	
end