planeEquipedDialog={}

function planeEquipedDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function planeEquipedDialog:init(layerNum,parent,planeId)
    self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self.nameFontSize=23
	self.desFontSize=20
	self.iconSize=80
	if planeId then
		self.planeList=planeVoApi:getPlaneList()
		for k,v in pairs(self.planeList) do
			if v.pid==planeId then
				self.selectIdx=k
			end
		end
	end
	self:initPlaneList()
	self:initSkillLayer()

	local function refreshSkills(event,data)
		self.planeList=planeVoApi:getPlaneList()
		local planeId=data.pid
		local slotIdx=data.idx
		local activeFlag=data.activeFlag
		if planeId and slotIdx and activeFlag~=nil then
			self.planeVo=planeVoApi:getPlaneVoById(planeId)
			self:refreshSkillSlot(slotIdx,activeFlag)
			self:initPlaneInfo(true)
		end
	end
	self.refreshListener=refreshSkills
	eventDispatcher:addEventListener("plane.skill.refresh",self.refreshListener)

	local function refreshPlaneInfo(event,data)
		self:initPlaneInfo(true)
    end
    self.refreshListener2=refreshPlaneInfo
    eventDispatcher:addEventListener("plane.newskill.refresh",self.refreshListener2)

	local function planeRefresh(event,data)
		self.planeList=planeVoApi:getPlaneList()
		if self.planeVo and self.planeVo.idx and self.planeList[self.planeVo.idx] then
			self.planeVo=self.planeList[self.planeVo.idx]
		end
		self:refreshPlaneList()
	end
	self.expeditionListener=planeRefresh
	eventDispatcher:addEventListener("plane.expedition.refresh",self.expeditionListener)

	if planeRefitVoApi then
  		self.listenerFunc = function(eventKey, eventData)
  			if self and type(eventData) == "table" and (eventData.eventType == 1 or eventData.eventType == 2) then
  				self.planeList = planeVoApi:getPlaneList()
  				self.planeVo = self.planeList[self.planeVo.idx]
  				self:initPlaneInfo(true)
  				self:refreshSkillSlot(5, false) --由于战机改装中新增的第5号位技能槽，所以只刷新5号槽位即可
  			end
  		end
  		planeRefitVoApi:addEventListener(self.listenerFunc)
  	end

	otherGuideMgr:endGuideStep(33)
  	
  	if otherGuideMgr:checkGuide(34)==false then --技能抽取教学
  		local list=planeVoApi:getSkillList()
  		if SizeOfTable(list)==0 and planeVoApi:hasPlaneEquip()==false then
  			otherGuideMgr:showGuide(34)
  		else
  			self:showEquipGuide()
  		end
  		otherGuideMgr:setGuideStepDone(34)
  	elseif self:showEquipGuide() == false then
  		if planeRefitVoApi and planeRefitVoApi:isCanEnter() == true and otherGuideMgr:checkGuide(85) == false and planeRefitVoApi:isFirstEnter() then --战机改装引导
	  		otherGuideMgr:showGuide(85)
	  		otherGuideMgr:setGuideStepDone(85)
	  	end
  	end

	return self.bgLayer
end

--显示装配主动技能的教学
function planeEquipedDialog:showEquipGuide()
	local step=37
	if otherGuideMgr:checkGuide(step)==false and planeVoApi:hasPlaneEquip()==false then
		otherGuideMgr:showGuide(step)
		otherGuideMgr:setGuideStepDone(step)
		return true
	end
	return false
end

function planeEquipedDialog:initPlaneList()
	self.planeTb={}
	self.planeList=planeVoApi:getPlaneList()
	local num=SizeOfTable(planeCfg.plane)
	local space=10
	local iconW=140
	local posX=(G_VisibleSizeWidth-(num-1)*space-num*iconW)/2
	if self.selectIdx==nil then
		self.selectIdx=1
	end
	self.planeVo=self.planeList[self.selectIdx]
	local playerLv=playerVoApi:getPlayerLevel()
	local openCfg=planeVoApi:getOpenLevelCfg()
	for i=1,num do
		local lockFlag=false
		if playerLv<openCfg[i] then
			lockFlag=true
		end
		local iconBg
		local function touchHandler()
			if lockFlag==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_unlock_str2",{openCfg[i]}),30)
				do return end
			end
			if self.selectIdx~=i then
				self.selectIdx=i
				if self.selectSp then
					self.selectSp:setPosition(iconBg:getPosition())
				end
				self.planeVo=self.planeList[self.selectIdx]
				self:initPlaneInfo(true)
				self:refershSkillLayer()
			end
		end
		local picBg="plane_unlockbg.png"
		local pic="plane_lock_icon.png"
		local scale=0.4
		local unlockStr
		if lockFlag then
			picBg="plane_lockbg.png"
			unlockStr=getlocal("alliance_unlock_str2",{openCfg[i]})
			scale=1
		else
			local planeVo=self.planeList[i]
			pic=planeVo:getPic()
			if planeVo.pid=="p1" then
				scale=0.45
			end
		end
		iconBg=LuaCCSprite:createWithSpriteFrameName(picBg,touchHandler)
		iconBg:setAnchorPoint(ccp(0,0))
		iconBg:setTouchPriority(-(self.layerNum-1)*20-4)
		-- iconBg:setScale(iconW/iconBg:getContentSize().width)
		iconBg:setPosition(posX+(i-1)*(space+iconW),G_VisibleSizeHeight-280)
		self.bgLayer:addChild(iconBg)
		self.planeTb=iconBg

		local planeSp=CCSprite:createWithSpriteFrameName(pic)
		planeSp:setPosition(getCenterPoint(iconBg))
		planeSp:setScale(scale)
		iconBg:addChild(planeSp)

		if unlockStr then
			local unlockLb=GetTTFLabelWrap(getlocal("alliance_unlock_str2",{openCfg[i]}),18,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		    unlockLb:setAnchorPoint(ccp(0.5,0))
			unlockLb:setColor(G_ColorRed)
			unlockLb:setPosition(iconBg:getContentSize().width/2,5)
			iconBg:addChild(unlockLb)
		end

		if i==self.selectIdx then
			local capInSet=CCRect(46,46,2,2)
			local function nilFunc()
			end
			local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("plane_selectFrame.png",capInSet,nilFunc)
			selectSp:setAnchorPoint(ccp(0,0))
			selectSp:setContentSize(iconBg:getContentSize())
			selectSp:setPosition(iconBg:getPosition())
			self.bgLayer:addChild(selectSp,2)
			self.selectSp=selectSp

			local arrowSp=CCSprite:createWithSpriteFrameName("select_arrow.png")
			arrowSp:setAnchorPoint(ccp(0.5,1))
			arrowSp:setPosition(selectSp:getContentSize().width/2,10)
			selectSp:addChild(arrowSp)
		end
		local battleFlag=planeVoApi:getIsBattleEquip(i)
		if battleFlag==true then
			local pos=getCenterPoint(iconBg)
			local lbBg=CCSprite:createWithSpriteFrameName("emblemUnlockBg.png")
			local lb=GetTTFLabel(getlocal("emblem_battle"),22)
			lbBg:setPosition(pos)
			lbBg:setTag(1001)
			lbBg:setScaleX(iconBg:getContentSize().width/lbBg:getContentSize().width)
			lbBg:setScaleY((lb:getContentSize().height+20)/lbBg:getContentSize().height)
			iconBg:addChild(lbBg,6)
			lb:setColor(G_ColorGreen)
			lb:setPosition(pos)
			lb:setTag(1002)
			iconBg:addChild(lb,7)
		end
	end
	self:initPlaneInfo()
end

function planeEquipedDialog:refreshPlaneList()
	for k,planeBg in pairs(self.planeTb) do
		local battleFlag=planeVoApi:getIsBattleEquip(k)
		local lbBg=tolua.cast(planeBg:getChildByTag(1001),"CCSprite")
		local lb=tolua.cast(planeBg:getChildByTag(1002),"CCLabelTTF")
		if battleFlag==true then
			if lbBg==nil and lb==nil then
				local pos=getCenterPoint(planeBg)
				local lbBg=CCSprite:createWithSpriteFrameName("emblemUnlockBg.png")
				local lb=GetTTFLabel(getlocal("emblem_battle"),22)
				lbBg:setPosition(pos)
				lbBg:setTag(1001)
				lbBg:setScaleX(planeBg:getContentSize().width/lbBg:getContentSize().width)
				lbBg:setScaleY((lb:getContentSize().height+20)/lbBg:getContentSize().height)
				planeBg:addChild(lbBg,6)
				lb:setColor(G_ColorGreen)
				lb:setPosition(pos)
				lb:setTag(1002)
				planeBg:addChild(lb,7)
			end
		else
			if lbBg and lb then
				lbBg:removeFromParentAndCleanup(true)
				lbBg=nil
				lb:removeFromParentAndCleanup(true)
				lb=nil
			end
		end
	end
end

function planeEquipedDialog:initPlaneInfo(refreshFlag)
	if self.planeVo==nil then
		do return end
	end
	local planeVo=self.planeVo
	self.tvWidth=G_VisibleSizeWidth-300
	self.normalHeight=260
	if G_isIphone5()==true then
		self.normalHeight=300
	end
	self.tvHeight=self.normalHeight-70
	local cfg=planeVoApi:getPlaneCfgById(planeVo.pid)
	if cfg then
		local strengthV=planeVo:getStrength()
		local strengthStr=getlocal("skill_power",{FormatNumber(strengthV)})
		self.cellHeightTb,self.detailTb=self:getCellHeight(planeVo)
		if self.infoBg==nil then
			local function nilFunc()
			end
			local infoBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png",CCRect(50,20,1,1),nilFunc)
			infoBg:setAnchorPoint(ccp(0.5,1))
			infoBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.normalHeight))
			infoBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-285))
			self.bgLayer:addChild(infoBg)
			self.infoBg=infoBg

			--飞机名字
		    local nameLb=GetTTFLabelWrap(planeVo:getName(),self.nameFontSize,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		    nameLb:setAnchorPoint(ccp(0,0.5))
			self.nameLb=nameLb
		    local nameLb2=GetTTFLabel(planeVo:getName(),self.nameFontSize)
			local titleW=nameLb2:getContentSize().width
			if titleW>nameLb:getContentSize().width then
				titleW=nameLb:getContentSize().width
			end
			titleW=titleW+50
			local titleH=nameLb:getContentSize().height+10
			if titleH<33 then
				titleH=33
			end
			if titleW<70 then
				titleW=70
			end
			local titlesBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesBG.png",CCRect(25,16,1,1),nilFunc)
			titlesBg:setContentSize(CCSizeMake(titleW,titleH))
			titlesBg:setAnchorPoint(ccp(0,1))
			titlesBg:setPosition(ccp(8,infoBg:getContentSize().height-5))
			infoBg:addChild(titlesBg)
			nameLb:setPosition(ccp(10,titlesBg:getContentSize().height/2))
			titlesBg:addChild(nameLb)
			self.titlesBg=titlesBg

			local function touchHandler()
			end
			local planeSp=LuaCCSprite:createWithSpriteFrameName(planeVo:getPic(),touchHandler)
			planeSp:setPosition(planeSp:getContentSize().width/2-20,self.normalHeight/2)
			infoBg:addChild(planeSp)
			local scale=0.6
			if planeVo.pid=="p1" then
				scale=0.65
			elseif planeVo.pid=="p2" then
				scale=0.55
			end
			planeSp:setScale(scale)
			self.planeSp=planeSp

			--飞机强度
		    local strengthLb=GetTTFLabelWrap(strengthStr,self.nameFontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		    strengthLb:setAnchorPoint(ccp(0.5,0))
			strengthLb:setColor(G_ColorYellowPro)
			strengthLb:setPosition(ccp(planeSp:getPositionX()-10,20))
			infoBg:addChild(strengthLb)
			self.strengthLb=strengthLb

			local function callBack(...)
		        return self:eventHandler(...)
		    end
		    local hd=LuaEventHandler:createHandler(callBack)
		    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
		    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
		    self.tv:setPosition(ccp(230,20))
		    self.tv:setMaxDisToBottomOrTop(80)
		    infoBg:addChild(self.tv)

	    	local function showInfo()
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				PlayEffect(audioCfg.mouseClick)
				local tabStr={}
				for i=1,8 do
					table.insert(tabStr,getlocal("plane_rule_"..i))
				end
				local titleStr=getlocal("activity_baseLeveling_ruleTitle")
		        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		        local textSize = 25
		        if G_getCurChoseLanguage() =="ru" then
			        textSize = 20 
			    end
		        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
			end
			local infoItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
			infoItem:setScale(0.6)
			local infoBtn=CCMenu:createWithItem(infoItem)
			infoBtn:setPosition(ccp(150,80))
			-- infoBtn:setPosition(ccp(200,190))

			infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
			local rect=CCSizeMake(100,100)
		    local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),showInfo)
		    addTouchBg:setTouchPriority(-(self.layerNum-1)*20-4)
		    addTouchBg:setContentSize(rect)
		    addTouchBg:setOpacity(0)
		    addTouchBg:setPosition(infoBtn:getPosition())
		    infoBg:addChild(addTouchBg)
			infoBg:addChild(infoBtn)
		elseif refreshFlag and refreshFlag==true then
			if self.planeSp and self.nameLb and self.strengthLb and self.tv and self.titlesBg then
				local scale=0.6
				if planeVo.pid=="p1" then
					scale=0.65
				elseif planeVo.pid=="p2" then
					scale=0.55
				end
				self.planeSp:initWithSpriteFrameName(planeVo:getPic())
				self.planeSp:setScale(scale)
				self.nameLb:setString(planeVo:getName())
				self.strengthLb:setString(strengthStr)
			    local nameLb2=GetTTFLabel(planeVo:getName(),self.nameFontSize)
				local titleW=nameLb2:getContentSize().width
				if titleW>self.nameLb:getContentSize().width then
					titleW=self.nameLb:getContentSize().width
				end
				titleW=titleW+50
				local titleH=self.nameLb:getContentSize().height+10
				if titleH<33 then
					titleH=33
				end	
				if titleW<70 then
					titleW=70
				end
				self.titlesBg:setContentSize(CCSizeMake(titleW,titleH))
				self.tv:reloadData()
			end
		end
	end
end

function planeEquipedDialog:initSkillLayer()
	self.skillInfoH=300
	local skillBgPosY=G_VisibleSizeHeight-550
	if G_isIphone5()==true then
		self.skillInfoH=380
		skillBgPosY=G_VisibleSizeHeight-600
	end
	local function nilFunc()
	end
	local skillBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
	skillBg:setAnchorPoint(ccp(0.5,1))
	skillBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.skillInfoH))
	skillBg:setPosition(G_VisibleSizeWidth/2,skillBgPosY)
	self.bgLayer:addChild(skillBg)
	self.skillBg=skillBg

	local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp1:setPosition(ccp(2,skillBg:getContentSize().height/2))
	skillBg:addChild(pointSp1)
	local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
	pointSp2:setPosition(ccp(skillBg:getContentSize().width-2,skillBg:getContentSize().height/2))
	skillBg:addChild(pointSp2)

    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(26,0,2,6),nilFunc)
    lineSp:setContentSize(CCSizeMake(self.skillInfoH-50,6))
    lineSp:setRotation(90)
    lineSp:setPosition(200,skillBg:getContentSize().height/2-15)
    skillBg:addChild(lineSp,1)

	local function getTitle(titleStr,px,py,width,height)
		local function nilFunc()
		end
		local  skillTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),nilFunc)
		skillTitleBg:setAnchorPoint(ccp(0,1))
		skillTitleBg:setPosition(px,py)
		skillTitleBg:setContentSize(CCSizeMake(width,height))
		skillBg:addChild(skillTitleBg)

		local nameLb=GetTTFLabel(titleStr,self.nameFontSize)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(10,skillTitleBg:getContentSize().height/2)
		skillTitleBg:addChild(nameLb)
	end
	getTitle(getlocal("plane_skill_active"),5,skillBg:getContentSize().height-5,200,32)
	getTitle(getlocal("plane_skill_passive"),210,skillBg:getContentSize().height-5,320,32)

	self.aSlotSpTb={}
	self.pSlotSpTb={}
	if self.planeVo==nil then
		do return end
	end
	--初始化主动技能槽
 	local function clickSkillSlot()
		local battleFlag=planeVoApi:getIsBattleEquip(self.planeVo.idx)
		if battleFlag==true then
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plane_battling"),30)
			do return end
		end
		planeVoApi:showSelectDialog(self.planeVo,1,true,self.layerNum+1)
		if otherGuideMgr.isGuiding and otherGuideMgr.curStep==37 then
	        otherGuideMgr:toNextStep()
	    end
	end
	local slotSp=self:getSkillSlot(skillBg,100,skillBg:getContentSize().height/2+10,clickSkillSlot,true)
	slotSp:setScale(1)
	self.aSlotSpTb[1]=slotSp
	self:refreshSkillSlot(1,true)
	--初始化被动技能槽
	if planeRefitVoApi:isOpen() == true then
		local slotCount = 4 + 1 --飞机改装中增加一个被动技能槽位
		local pSlotTvSize = CCSizeMake(365, skillBg:getContentSize().height - 40)
		local pSlotTv = G_createTableView(pSlotTvSize, 1, CCSizeMake(pSlotTvSize.width, 130 * math.ceil(slotCount / 2) + 10), function(cell, cellSize, idx, cellNum)
			self.pSlotCell = cell
			local py
			for i = 1, slotCount do
				local px = (i % 2 == 0) and (cellSize.width / 2 + cellSize.width / 2 / 2) or (cellSize.width / 2 / 2)
				if py == nil then
					py = cellSize.height - 50
				end
				--把最新增加的技能槽放在最前面
				local index = (i + 4 <= slotCount) and (slotCount - (i - 1)) or (i - (slotCount - 4))
				local function onClickSkillSlot()
					if planeVoApi:getIsBattleEquip(self.planeVo.idx) == true then
						G_showTipsDialog(getlocal("plane_battling"), 30)
						do return end
					end
					if index == 5 then --判断是否解锁该技能槽
						local isUnlockSlot, unlockAttrValue, unlockSkillId = planeRefitVoApi:isUnlockPlaneSkillSlot(self.planeVo.pid)
						if isUnlockSlot == true then
							planeVoApi:showSelectDialog(self.planeVo, index, false, self.layerNum + 1)
						else
							if unlockAttrValue then
								G_showTipsDialog(getlocal("planeRefit_refitUnlockOfPlaceTips", {planeRefitVoApi:getPlaceName(unlockAttrValue)}))
							end
						end
					else
						planeVoApi:showSelectDialog(self.planeVo, index, false, self.layerNum + 1)
					end
				end
				self.pSlotSpTb[index] = self:getSkillSlot(cell, px, py, onClickSkillSlot, false)
				self:refreshSkillSlot(index, false)
				if i % 2 == 0 then
					py = py - 130
				end
			end
		end)
		pSlotTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
		pSlotTv:setMaxDisToBottomOrTop(0)
		pSlotTv:setPosition(205, 3)
		skillBg:addChild(pSlotTv)
	else
		local firstX=G_VisibleSizeWidth/2-20
		local py=skillBg:getContentSize().height-80
		local addH=0
		if G_isIphone5()==true then
			addH=-40
		end
	    for i=1,4 do
	    	local px=firstX
	    	if i%2==0 then
	    		px=firstX+180
			elseif i>1 and i%2==1 then
	    		py=py-130
	    	end
	    	local function clickSkillSlot()
				local battleFlag=planeVoApi:getIsBattleEquip(self.planeVo.idx)
				if battleFlag==true then
	            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plane_battling"),30)
					do return end
				end
				planeVoApi:showSelectDialog(self.planeVo,i,false,self.layerNum+1)
	    	end
	    	local slotSp=self:getSkillSlot(skillBg,px,py+addH,clickSkillSlot,false)
	    	self.pSlotSpTb[i]=slotSp
			self:refreshSkillSlot(i,false)
		end
	end

	otherGuideMgr:setGuideStepField(37,slotSp)
end

function planeEquipedDialog:refershSkillLayer()
	for slotIdx,v in pairs(self.aSlotSpTb) do
		self:refreshSkillSlot(slotIdx,true)
	end
	for slotIdx,v in pairs(self.pSlotSpTb) do
		self:refreshSkillSlot(slotIdx,false)
	end
end

function planeEquipedDialog:refreshSkillSlot(slotIdx,activeFlag)
	if self.aSlotSpTb and self.pSlotSpTb and slotIdx and self.skillBg then
		if self.planeVo==nil then
			do return end
		end
		local tag=1000
		if activeFlag and activeFlag==true then
			tag=2000
		end
		tag=tag+slotIdx
		local targetSp
		local bgObjKey = "skillBg"
		local isUnlockSlot, unlockAttrValue
		if activeFlag and activeFlag==true then --主动技能刷新
			targetSp=self.aSlotSpTb[slotIdx]
		else --被动技能刷新
			targetSp=self.pSlotSpTb[slotIdx]
			if planeRefitVoApi:isOpen() == true then
				bgObjKey = "pSlotCell"
				if self[bgObjKey] == nil then
					do return end
				end
				if slotIdx == 5 then
					isUnlockSlot, unlockAttrValue = planeRefitVoApi:isUnlockPlaneSkillSlot(self.planeVo.pid)
				end
			end
		end
		local equipFlag,sid=self.planeVo:isSkillSlotEquiped(slotIdx,activeFlag)
		if targetSp then
			local skillIcon=self[bgObjKey]:getChildByTag(tag)
			local nameLb=self[bgObjKey]:getChildByTag(tag*10)
			local strongLb=self[bgObjKey]:getChildByTag(tag*100)
			local lockSp = self[bgObjKey]:getChildByTag(tag * 1000)
        	if skillIcon then
        		skillIcon:removeFromParentAndCleanup(true)
        		skillIcon=nil
        	end
        	if nameLb then
        		nameLb:removeFromParentAndCleanup(true)
        		nameLb=nil
        	end
        	if strongLb then
        		strongLb:removeFromParentAndCleanup(true)
        		strongLb=nil
        	end
        	if lockSp then
        		lockSp:removeFromParentAndCleanup(true)
        		lockSp = nil
        	end
			if equipFlag==true then
				if activeFlag and activeFlag==true and otherGuideMgr.curStep<37 then --如果主动技能已经装配了则结束教学
					planeVoApi:endPlaneGuide()
				end
				targetSp:setVisible(false)
  				local function showInfo()
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
		            PlayEffect(audioCfg.mouseClick)
  					local function realShow()
  						local battleFlag=planeVoApi:getIsBattleEquip(self.planeVo.idx)
  						if battleFlag==true then
			                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plane_battling"),30)
  							do return end
  						end
						planeVoApi:showInfoSmallDialog(sid,self.layerNum+1,true,self.planeVo,slotIdx,activeFlag)
  					end
  					if skillIcon then
  						local scale=skillIcon:getScale()-0.1
  						G_touchedItem(skillIcon,realShow,scale)
  					end
		        end
				skillIcon=planeVoApi:getSkillIcon(sid,self.iconSize,showInfo)
				if activeFlag and activeFlag==true then
					skillIcon:setScale(1)
				end
				skillIcon:setTouchPriority(-(self.layerNum-1)*20-5)
	            skillIcon:setPosition(targetSp:getPosition())
	            skillIcon:setTag(tag)
	            self[bgObjKey]:addChild(skillIcon,5)
				
				local scale=skillIcon:getScale()
				-- 装备名称
				local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
				local nameStr=planeVoApi:getSkillInfoById(sid,true)
				nameLb=GetTTFLabelWrap(nameStr,self.nameFontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				nameLb:setAnchorPoint(ccp(0.5,1))
				-- nameLb:setPosition(ccp(skillIcon:getContentSize().width/2,-3))
				-- skillIcon:addChild(nameLb,2)
				nameLb:setPosition(ccp(skillIcon:getPositionX(),skillIcon:getPositionY()-skillIcon:getContentSize().height*scale/2-3))
				nameLb:setScale(scale)
				nameLb:setTag(tag*10)
				self[bgObjKey]:addChild(nameLb)
				local color=planeVoApi:getColorByQuality(gcfg.color)
				nameLb:setColor(color)

				-- 装备强度
				local strong=gcfg.skillStrength or 0
				if unlockAttrValue then
					strong = math.floor(strong * unlockAttrValue)
				end
				strongLb=GetTTFLabelWrap(getlocal("skill_power",{strong}),self.nameFontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				strongLb:setAnchorPoint(ccp(0.5,1))
				-- strongLb:setPosition(ccp(skillIcon:getContentSize().width/2,nameLb:getPositionY()-nameLb:getContentSize().height))
				-- skillIcon:addChild(strongLb)
				strongLb:setScale(scale)
				strongLb:setTag(tag*100)
				strongLb:setPosition(nameLb:getPositionX(),nameLb:getPositionY()-nameLb:getContentSize().height*scale)
				self[bgObjKey]:addChild(strongLb)

				local betterFlag=planeVoApi:hasBetterEquip(self.planeVo.pid,sid,activeFlag)
				-- print("betterFlag-------->",betterFlag)
				if betterFlag==true then
					local function nilFunc()
					end
				    local tipSp=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17,17,1,1),nilFunc)
		           	tipSp:setAnchorPoint(CCPointMake(0,0.5))
		           	tipSp:setScale(0.6)
		           	tipSp:setPosition(skillIcon:getContentSize().width/2+10,skillIcon:getContentSize().height-20)
		           	skillIcon:addChild(tipSp)
				end
			else
				targetSp:setVisible(true)
				if (not (activeFlag and activeFlag==true)) and slotIdx == 5 then --飞机改装新增的第5个槽位
					local addSp = targetSp:getChildByTag(-100)
					if isUnlockSlot == true then --判断是否解锁该技能槽
						if addSp then
							addSp:setVisible(true)
						end
					else
						if addSp then
							addSp:setVisible(false)
						end
						lockSp = CCSprite:createWithSpriteFrameName("alienTechLock.png")
						lockSp:setPosition(targetSp:getPositionX() + 2, targetSp:getPositionY())
						lockSp:setTag(tag * 1000)
						self[bgObjKey]:addChild(lockSp, 3)
						nameLb=GetTTFLabelWrap(getlocal("planeRefit_refitUnlockTips"),18,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
						nameLb:setAnchorPoint(ccp(0.5,1))
						nameLb:setPosition(ccp(targetSp:getPositionX(),targetSp:getPositionY()-targetSp:getContentSize().height/2))
						nameLb:setTag(tag*10)
						self[bgObjKey]:addChild(nameLb)
					end
				end
			end
		end
	end
end

function planeEquipedDialog:getSkillSlot(target,px,py,callBack,activeFlag)
	if target==nil then
		return nil
	end
	local function clickHandler()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callBack then
        	callBack()
        end
	end
    local px=px or 0
    local py=py or 0
    local pic="passiveSelect.png"
    if activeFlag and activeFlag==true then
    	pic="activeSelect.png"
    end
	local slotSp=LuaCCSprite:createWithSpriteFrameName(pic,clickHandler)
	slotSp:setTouchPriority(-(self.layerNum-1)*20-2)
    slotSp:setPosition(ccp(px,py))
    target:addChild(slotSp,1)
    slotSp:setScale(self.iconSize/slotSp:getContentSize().width)
    -- 加号
    local addSp=CCSprite:createWithSpriteFrameName("ProduceTankIconMore.png")
    addSp:setScale(1.8)
    addSp:setPosition(slotSp:getContentSize().width/2+2,slotSp:getContentSize().height/2)
    addSp:setTag(-100)
    slotSp:addChild(addSp)
    -- 忽隐忽现
    local fade1=CCFadeTo:create(0.8,55)
    local fade2=CCFadeTo:create(0.8,255)
    local seq=CCSequence:createWithTwoActions(fade1,fade2)
    local repeatEver=CCRepeatForever:create(seq)
    addSp:runAction(repeatEver)

    return slotSp
end

function planeEquipedDialog:getCellHeight(planeVo)
	local cellHeight1=0
	local cellHeight2=0
	local cfg=planeVoApi:getPlaneCfgById(planeVo.pid)
	if cfg==nil then
		return 0
	end
	local subWidth = -5
	if G_getCurChoseLanguage() =="ar" then
		subWidth = -20
	end
	local textWidth=self.tvWidth+subWidth
	local peculiarityLb=GetTTFLabelWrap(getlocal("peculiarity",{planeVoApi:getPlanePeculiarityById(planeVo.pid)}),self.desFontSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	local lbheight1=peculiarityLb:getContentSize().height
	cellHeight1=cellHeight1+lbheight1+10

	local colorTb={G_ColorWhite,G_ColorGreen}
	local descLb,lbheight2=G_getRichTextLabel(planeVo:getDesc(),colorTb,self.desFontSize,textWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	cellHeight1=cellHeight1+lbheight2+15

	--buff加成
	local addStr=planeVoApi:getPlaneAddStr(planeVo.pid)
	local addLb,lbheight3=G_getRichTextLabel(getlocal("add_attribute",{addStr}),colorTb,self.desFontSize,textWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	cellHeight2=cellHeight2+lbheight3+20
	--能量点上限
	local addBuffTb=planeVoApi:getPlaneAddBuffByPlaneId(planeVo.pid) --战机革新各个技能加成buff
	local energyStr=tostring(cfg.energy+(addBuffTb.energy or 0))
	if addBuffTb.energy then
		energyStr=energyStr.."("..cfg.energy.."<rayimg>+"..addBuffTb.energy.."<rayimg>)"
	end
	energyStr=getlocal("energy_uplimit",{energyStr})
	local energyLb,lbheight4=G_getRichTextLabel(energyStr,colorTb,self.desFontSize,textWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	local energyLb2=GetTTFLabel(energyStr,self.desFontSize)
    local realW=energyLb2:getContentSize().width
    if realW>textWidth then
        realW=textWidth
    end
	cellHeight2=cellHeight2+lbheight4+10

	local skillNumLb=GetTTFLabelWrap(getlocal("carry_skill_uplimit",{cfg.skillSlot}),self.desFontSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	local lbheight5=skillNumLb:getContentSize().height
	cellHeight2=cellHeight2+lbheight5+20
	local cellHeightTb={cellHeight1,cellHeight2}
	local detailTb={
		{
			{peculiarityLb,lbheight1},
			{descLb,lbheight2}
		},
		{
			{addLb,lbheight3},
			{energyLb,lbheight4,3,realW},
			{skillNumLb,lbheight5}
		}
	}
	return cellHeightTb,detailTb
end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function planeEquipedDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
    	return 2
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.tvWidth,self.cellHeightTb[idx+1])
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellHeight=self.cellHeightTb[idx+1]
        local details=self.detailTb[idx+1]
        local descBg
		local function nilFunc()
		end
		if idx==0 then
			descBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
			descBg:setContentSize(CCSizeMake(self.tvWidth,cellHeight-5))
			local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
			pointSp1:setPosition(ccp(2,descBg:getContentSize().height/2))
			descBg:addChild(pointSp1)
			local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
			pointSp2:setPosition(ccp(descBg:getContentSize().width-2,descBg:getContentSize().height/2))
			descBg:addChild(pointSp2)
		elseif idx==1 then
			descBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),nilFunc)
			descBg:setContentSize(CCSizeMake(self.tvWidth,cellHeight))
		end
		if descBg then
			descBg:setAnchorPoint(ccp(0.5,1))
			descBg:setPosition(self.tvWidth/2,cellHeight)
			cell:addChild(descBg)

	        local posY=descBg:getContentSize().height-10
	        if details then
	        	for k,v in pairs(details) do
	        		local strLb,lbheight=v[1],v[2]
	        		local itype=v[3]
	        		if strLb and lbheight then
	        			if idx == 1 and k == 3 then --表示可携带技能数量
	        				local isUnlockSlot, unlockAttrValue, unlockSkillId = planeRefitVoApi:isUnlockPlaneSkillSlot(self.planeVo.pid)
	        				local cfg=planeVoApi:getPlaneCfgById(self.planeVo.pid)
	        				if isUnlockSlot == true then
								strLb:setString(getlocal("carry_skill_uplimit", {cfg.skillSlot + 1}))
							else
								strLb:setString(getlocal("carry_skill_uplimit", {cfg.skillSlot}))
	        				end
	        			end
	        			strLb:setAnchorPoint(ccp(0,1))
		        		strLb:setPosition(10,posY)
		        		descBg:addChild(strLb)
		        		posY=posY-lbheight
		        		if idx==1 then
		        			posY=posY-10
		        		end
		        		if itype==3 then --itype为3时表示显示的能量点上限
		        			local realW=v[4] or 0
 							local energyIcon=CCSprite:createWithSpriteFrameName("planeEnergy.png")
						    energyIcon:setAnchorPoint(ccp(0,0.5))
						    energyIcon:setPosition(strLb:getPositionX()+realW+5,strLb:getPositionY()-lbheight/2)
						    descBg:addChild(energyIcon)
		        		end
	        		end
	        	end
	        end
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

function planeEquipedDialog:refresh(idx)
end

function planeEquipedDialog:tick()
	
end

function planeEquipedDialog:fastTick()
	
end

function planeEquipedDialog:dispose()
	eventDispatcher:removeEventListener("plane.skill.refresh",self.refreshListener)
	eventDispatcher:removeEventListener("plane.expedition.refresh",self.expeditionListener)
	if self.refreshListener2 then
		eventDispatcher:removeEventListener("plane.newskill.refresh",self.refreshListener2)
		self.refreshListener2=nil
	end
	self.refreshListener=nil
	if planeRefitVoApi then
		planeRefitVoApi:removeEventListener(self.listenerFunc)
  	end
  	self.listenerFunc = nil
end