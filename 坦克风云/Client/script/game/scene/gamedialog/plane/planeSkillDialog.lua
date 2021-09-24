planeSkillDialog={}

function planeSkillDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.allSkills={}
	nc.btnColorTb = {G_ColorWhite,G_ColorGreen,G_ColorBlue,G_ColorPurple,G_ColorOrange}
	nc.freeGetFlagIcon = nil--免费获取提示图标
	nc.qualityTabTb={}
	nc.selectedQuality=0

	return nc
end

function planeSkillDialog:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent

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
	local posY = G_VisibleSizeHeight - 200
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
				if tag>1000 then
					tag=tag-1000
				end
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
			self:refreshList(true)
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
		local tabBtn=LuaCCSprite:createWithSpriteFrameName("planeSkillTab"..i..".png",onSelectQuality)
		tabBtn:setTag(i)
		tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		tabBtn:setPosition(posX+addPosX,posY)
		self.bgLayer:addChild(tabBtn,1)
		tabBtn:setColor(ccc3(120,120,120))
		self.qualityTabTb[i]=tabBtn

	    local rect=CCSizeMake(90,90)
	    local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),onSelectQuality)
	    addTouchBg:setTouchPriority(-(self.layerNum-1)*20-4)
	    addTouchBg:setContentSize(rect)
	    addTouchBg:setOpacity(0)
	    addTouchBg:setTag(1000+i)
	    addTouchBg:setPosition(tabBtn:getPosition())
	    self.bgLayer:addChild(addTouchBg)

		posX=posX + 100
	end
	self:refreshList(true)

	local function callBack(...)
	   return self:eventHandler(...)
	end

	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 340),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(20,95))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
	local function onRefresh(event,data)		
		if data then
			if data.sid then
				local scfg,gcfg=planeVoApi:getSkillCfgById(data.sid)
				if (gcfg.color==self.selectedQuality) or self.selectedQuality==0 then
					self:refreshList()
				end
			end
		else
			self:refreshList()
		end
	end
	self.refreshListener=onRefresh
	eventDispatcher:addEventListener("plane.skillbag.refresh",self.refreshListener)
	return self.bgLayer
end

function planeSkillDialog:refreshList()
	self.showList={}
	local newFlag=planeVoApi:getSkillRfreshFlag()
	if newFlag==true then
		planeVoApi:setSkillRfreshFlag(false)

		self.allSkills={}
		local listCfg=G_clone(planeGrowCfg.grow)
		--已经装配的
		local planeList=planeVoApi:getPlaneList()
		local equipTb={}
		local function insertSkill(skillTb)
			for k,sid in pairs(skillTb) do
				if sid~=0 then
					local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
					local flag=false
					for k,vo in pairs(equipTb) do
						if vo.sid==sid then
							flag=true
							do break end
						end
					end
					if flag==false then
						local nameStr=planeVoApi:getSkillInfoById(sid)
						local skillVo=planeSkillVo:new(scfg,gcfg)
						skillVo:initWithData(sid,0,2)
						table.insert(equipTb,skillVo)
					end
				end
			end
		end
		for k,planeVo in pairs(planeList) do
			local aSkills=planeVo:getASkills()
			local pSkills=planeVo:getPSkills()
			insertSkill(aSkills)
			insertSkill(pSkills)
		end
		planeVoApi:sortSkillList(equipTb)

		for k,vo in pairs(equipTb) do
			listCfg[vo.sid]=nil
			table.insert(self.allSkills,vo)
			listCfg=planeVoApi:getLockSkill(vo.sid,listCfg)
		end

		--已经拥有的
		local ownList=planeVoApi:getSkillList()
		planeVoApi:sortSkillList(ownList)
		for k,v in pairs(ownList) do
			table.insert(self.allSkills,v)
			listCfg[v.sid]=nil
			listCfg=planeVoApi:getLockSkill(v.sid,listCfg)
		end

		--未解锁的
		local lockTb={}
		for k,v in pairs(listCfg) do
			if(v and (v.lv==0 or v.lv==nil))then
				local scfg,gcfg=planeVoApi:getSkillCfgById(k)
				local skillVo=planeSkillVo:new(scfg,gcfg)
				skillVo:initWithData(k,0)
				table.insert(lockTb,skillVo)
			end
		end
		planeVoApi:sortSkillList(lockTb)
		for k,v in pairs(lockTb) do
			table.insert(self.allSkills,v)
		end
	end
	if self.selectedQuality==0 then
		self.showList=self.allSkills
	else
		for k,v in pairs(self.allSkills) do
			local scfg,gcfg=planeVoApi:getSkillCfgById(v.sid)
			if(v and (self.selectedQuality==gcfg.color))then
				table.insert(self.showList,v)
			end
		end
	end
	self.cellNum=math.max(math.ceil((#self.showList)/4),1)

	if(self.tv) then
	 	-- local recordPoint=self.tv:getRecordPoint()
    	self.tv:reloadData()
        -- self.tv:recoverToRecordPoint(recordPoint)
	end
end

function planeSkillDialog:initTableView()

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function planeSkillDialog:eventHandler(handler,fn,idx,cel)
	local strSize2,strSize3 = 21,21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2,strSize3 =25,25
    elseif G_getCurChoseLanguage() =="ru" then
    	strSize3 = 15
    end
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 40,230)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local startIndex=idx*4
		--为了防止一次渲染太多造成卡顿，因此后面的做一个延迟展示处理
		local function realShow()
			if(self and self.bgLayer)then
				local startIndex=idx*4
				local bgWidth=(G_VisibleSizeWidth - 40)/4
				for i=1,4 do
					local skillVo=self.showList[startIndex + i]
					if(skillVo)then
						local skillIcon
						local function showInfo()
							if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
								if G_checkClickEnable()==false then
									do return end
								else
									base.setWaitTime=G_getCurDeviceMillTime()
								end
					            PlayEffect(audioCfg.mouseClick)
								local function realShow()
									planeVoApi:showInfoDialog(skillVo,self.layerNum + 1)
								end
								if skillIcon then
									G_touchedItem(skillIcon,realShow)
								end
							end
						end
						skillIcon=planeVoApi:getSkillIcon(skillVo.sid,nil,showInfo,skillVo.num,2)
						skillIcon:setTouchPriority(((-(self.layerNum-1)*20-2)))
						skillIcon:setAnchorPoint(ccp(0.5,0.5))
						skillIcon:setPosition(ccp(bgWidth/2 + (i - 1)*bgWidth,skillIcon:getContentSize().height*skillIcon:getScale()/2))
						cell:addChild(skillIcon)
						if skillVo.equipFlag==2 then
							local pos=getCenterPoint(skillIcon)
							local lbBg=CCSprite:createWithSpriteFrameName("emblemUnlockBg.png")
							lbBg:setPosition(pos)
							lbBg:setScaleX(skillIcon:getContentSize().width/lbBg:getContentSize().width)
							skillIcon:addChild(lbBg,6)
							local lb=GetTTFLabel(getlocal("skill_equiped"),strSize3)
							lb:setColor(G_ColorGreen)
							lb:setPosition(pos)
							skillIcon:addChild(lb,7)
						elseif(skillVo.num==0)then
							local pos=getCenterPoint(skillIcon)
							local lockBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),showInfo)
							lockBg:setOpacity(120)
							lockBg:setContentSize(skillIcon:getContentSize())
							lockBg:setPosition(pos)
							skillIcon:addChild(lockBg,5)
							local lbBg=CCSprite:createWithSpriteFrameName("emblemLockBg.png")
							lbBg:setScaleX(skillIcon:getContentSize().width/lbBg:getContentSize().width)
							lbBg:setPosition(pos)
							skillIcon:addChild(lbBg,6)
							local lb=GetTTFLabel(getlocal("emblem_noHad"),strSize2)
							lb:setColor(G_ColorRed)
							lb:setPosition(pos)
							skillIcon:addChild(lb,7)
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

function planeSkillDialog:updateUI()
	-- if self.tv then
	-- 	self:refreshList()
	-- end
end

function planeSkillDialog:tick()
	
end

function planeSkillDialog:dispose()
	eventDispatcher:removeEventListener("plane.skillbag.refresh",self.refreshListener)
	spriteController:removePlist("public/emblem/emblemImage.plist")
	spriteController:removeTexture("public/emblem/emblemImage.png")
end