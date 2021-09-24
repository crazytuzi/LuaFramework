--弹出军徽信息小面板
planeSkillInfoDialog=smallDialog:new()

function planeSkillInfoDialog:new(skillVo)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	
	nc.skillVo=skillVo
	nc.fontSize=24
	nc.cellHeight={}

	return nc
end

--@refitSkillAttr : 战机改装中的增加技能槽位的技能属性值
function planeSkillInfoDialog:init(layerNum,isEquip,equipHandler,refitSkillAttr)
	self.layerNum=layerNum
	local dialogWidth=550
	local dialogHeight=80
	self.refitSkillAttr = refitSkillAttr
	self.tvWidth=dialogWidth-80
	self.textWidth=dialogWidth-140
	local titleSize=36
	local function nilFunc()
	end
	local function close()
		self:close()
	end
	local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(CCSizeMake(dialogWidth,dialogHeight),getlocal("plane_skill_info"),titleSize,nilFunc,layerNum,true,close)
	self.dialogLayer=CCLayer:create()
	
	local iconScale=1.2
	local function nilFunc()
	end
	local strong = nil
	if self.refitSkillAttr then
		local scfg,gcfg=planeVoApi:getSkillCfgById(self.skillVo.sid)
		strong = math.floor(gcfg.skillStrength * self.refitSkillAttr)
	end
	local icon=planeVoApi:getSkillIcon(self.skillVo.sid,nil,nilFunc,self.skillVo.num,2,strong)
	icon:setAnchorPoint(ccp(0.5,1))
	icon:setScale(iconScale)
	dialogBg:addChild(icon)
	dialogHeight=dialogHeight+icon:getContentSize().height*iconScale+20
	self.cellNum=2
	local cellHeight=0
	for i=1,self.cellNum do
		cellHeight=cellHeight+self:getCellHeight(i-1)
	end
	local tvHeight=cellHeight
	local maxHeight=340
	local scrollFlag=false
	if tvHeight>maxHeight then
		scrollFlag=true
		tvHeight=maxHeight
	end
	dialogHeight=dialogHeight+tvHeight
	local function callback(...)
	   return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,tvHeight),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	dialogBg:addChild(self.tv)
	if scrollFlag==true then
		self.tv:setMaxDisToBottomOrTop(80)
	else
		self.tv:setMaxDisToBottomOrTop(0)
	end
	local onlyTextFlag=false
	local menuTb = {}
	if self.skillVo.num>0 then
		if self.skillVo.equipFlag~=2 then
			local function onClickSell()
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				PlayEffect(audioCfg.mouseClick)
				self:sellOneEquip()
			end
			local scale=0.8
			local sellItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onClickSell,2,getlocal("skill_decompose"),self.fontSize/scale)
			sellItem:setScale(scale)
			local sellBtn=CCMenu:createWithItem(sellItem)
			sellBtn:setTouchPriority(-(layerNum-1)*20-2)
			dialogBg:addChild(sellBtn)
			table.insert(menuTb,sellBtn)
			local isMax
			local maxLv
			if(self.skillVo.gcfg.color==4)then
				maxLv=playerVoApi:getMaxLvByKey("pskillUpgrade4Lv")
			else
				maxLv=playerVoApi:getMaxLvByKey("pskillUpgrade5Lv")
			end
			if(maxLv and maxLv>0 and self.skillVo.gcfg.lv and self.skillVo.gcfg.lv>=maxLv)then
				isMax=true
			else
				isMax=false
			end
			if isEquip and isEquip==true then
				local function onEquip()
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					PlayEffect(audioCfg.mouseClick)
					if equipHandler then
						equipHandler()
					end
					self:close()
				end
				local scale=0.8
				local equipItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onEquip,2,getlocal("accessory_ware"),self.fontSize/scale)
				equipItem:setScale(scale)
				local equipBtn=CCMenu:createWithItem(equipItem)
				equipBtn:setTouchPriority(-(self.layerNum-1)*20-2)
				dialogBg:addChild(equipBtn)
				table.insert(menuTb,equipBtn)
			else
				if self.skillVo.gcfg.lvTo~=nil and isMax==false then
					local function onClickUpgradeBtn()
						if G_checkClickEnable()==false then
							do return end
						else
							base.setWaitTime=G_getCurDeviceMillTime()
						end
						PlayEffect(audioCfg.mouseClick)
						local activeFlag=false
						if skillVo.scfg and (skillVo.scfg.skillType==3 or skillVo.scfg.skillType==4) then
							activeFlag=true
						end
						planeVoApi:showUpgradeDialog(self.skillVo.sid,self.layerNum+1,nil,nil,activeFlag)
						self:close()
					end
					local scale=0.8
					local upgradeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onClickUpgradeBtn,2,getlocal("plane_skill_upgrade"),self.fontSize/scale)
					upgradeItem:setScale(scale)
					local upgradeBtn=CCMenu:createWithItem(upgradeItem)
					upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
					dialogBg:addChild(upgradeBtn)
					table.insert(menuTb,upgradeBtn)
				end
			end
		end
	elseif(self.skillVo.num==0)then
		local typeStr--需要判断装备的获取类型
		local getType=self.skillVo.gcfg.howToGet
		if getType==1 then
			typeStr=getlocal("skill_getType1")
		elseif getType==2 then
			typeStr=getlocal("skill_getType2",{getlocal("plane_skill_level_s"..(self.skillVo.gcfg.color-1))})
		elseif getType==3 then
			typeStr=getlocal("skill_getType3",{getlocal("plane_skill_level_s"..(self.skillVo.gcfg.color-1))})
		elseif getType==4 then
			typeStr=getlocal("skill_getType4")
		end
		local typeLb=GetTTFLabelWrap(typeStr,25,CCSizeMake(dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		dialogBg:addChild(typeLb)
		typeLb:setColor(G_ColorGreen)
		table.insert(menuTb,typeLb)
		dialogHeight=dialogHeight+typeLb:getContentSize().height
		onlyTextFlag=true
	end
	
	local px
	local btnWidth = 200
	local menuNum = SizeOfTable(menuTb)
	for k,v in pairs(menuTb) do
		px=dialogWidth/2-btnWidth/2*(menuNum-1)+btnWidth*(k-1)
		v:setPosition(ccp(px,60))
	end

	if SizeOfTable(menuTb)==0 then
		dialogHeight=dialogHeight+40
	else
		if onlyTextFlag==true then
			dialogHeight=dialogHeight+100
		else
			dialogHeight=dialogHeight+130
		end
		local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")--LineCross
		lineSp3:setScaleX((dialogWidth - 120)/lineSp3:getContentSize().width)
		lineSp3:setScaleY(2/lineSp3:getContentSize().height)
		lineSp3:setPosition(ccp(dialogWidth/2,120 - lineSp3:getContentSize().height/2))
		dialogBg:addChild(lineSp3)
	end
	icon:setPosition(dialogWidth/2,dialogHeight-80)
	self.tv:setPosition(40,icon:getPositionY()-icon:getContentSize().height*iconScale-tvHeight-20)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(CCSizeMake(dialogWidth,dialogHeight))
	self.bgLayer:setIsSallow(false)
	if closeBtn then
		closeBtn:setPosition(ccp(dialogWidth-closeBtnItem:getContentSize().width-4,dialogHeight-closeBtnItem:getContentSize().height-4))
	end
	if titleBg then
		titleBg:setPosition(dialogWidth/2,dialogHeight)
	end
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))

	--遮罩层
	local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg);

	return self.dialogLayer
end

function planeSkillInfoDialog:getCellHeight(idx)
	if self.cellHeight[idx+1]==nil then
		local nameStr,descStr,typeStr,privilegeStr=planeVoApi:getSkillInfoById(self.skillVo.sid,nil,(self.refitSkillAttr ~= nil),self.refitSkillAttr)	
		local height=0
		if idx==0 then
			typeStr=getlocal("plane_skill_type").."<rayimg>"..typeStr.."<rayimg>"
			local colorTb={G_ColorYellowPro,G_ColorWhite}
	        local descLb,lbHeight=G_getRichTextLabel(typeStr,colorTb,self.fontSize,self.textWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			if privilegeStr==nil then
				privilegeStr=getlocal("custom_planeSkill")
			end
			privilegeStr=getlocal("equip_limited").."<rayimg>"..privilegeStr.."<rayimg>"
			local privilegeLb,lbHeight2=G_getRichTextLabel(privilegeStr,colorTb,self.fontSize,self.textWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			height=height+lbHeight2
			height=height+lbHeight+41
		elseif idx==1 then
			local titleLb=GetTTFLabelWrap(getlocal("plane_skill_desc_title"),self.fontSize,CCSizeMake(self.textWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			if self.refitSkillAttr then
				local descLb,lbHeight=G_getRichTextLabel(descStr,{nil,G_ColorYellowPro,nil},self.fontSize,self.textWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				height=height+titleLb:getContentSize().height+lbHeight+41
			else
				local descLb=GetTTFLabelWrap(descStr,self.fontSize,CCSizeMake(self.textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				height=height+titleLb:getContentSize().height+descLb:getContentSize().height+41
			end
		end
		self.cellHeight[idx+1]=height
	end
	return self.cellHeight[idx+1]
end

function planeSkillInfoDialog:eventHandler(handler,fn,idx,cel)
	local strSubSize3 = 5
	local subPosX = 60
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSubSize3 =0
		subPosX =0
	end
   	if fn=="numberOfCellsInTableView" then
   	   	   return self.cellNum
   	elseif fn=="tableCellSizeForIndex" then
   		local cellHeight=self:getCellHeight(idx)
	   	return  CCSizeMake(self.tvWidth,cellHeight)
   	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellHeight=self:getCellHeight(idx)
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setAnchorPoint(ccp(0.5,1))
		lineSp:setScaleX((self.tvWidth-40)/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(self.tvWidth/2,cellHeight))
		cell:addChild(lineSp)
		local nameStr,descStr,typeStr,privilegeStr=planeVoApi:getSkillInfoById(self.skillVo.sid,nil,(self.refitSkillAttr ~= nil),self.refitSkillAttr)	
		if idx==0 then
			local posY=cellHeight-21
			typeStr=getlocal("plane_skill_type").."<rayimg>"..typeStr.."<rayimg>"
			local colorTb={G_ColorYellowPro,G_ColorWhite}
	        local typeLb,lbHeight=G_getRichTextLabel(typeStr,colorTb,self.fontSize,self.textWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			typeLb:setAnchorPoint(ccp(0,1))
			typeLb:setPosition(25,posY)
			cell:addChild(typeLb)
			posY=posY-lbHeight-10
			if privilegeStr==nil then
				privilegeStr=getlocal("custom_planeSkill")
			end
			privilegeStr=getlocal("equip_limited").."<rayimg>"..privilegeStr.."<rayimg>"
			local privilegeLb,lbHeight2=G_getRichTextLabel(privilegeStr,colorTb,self.fontSize,self.textWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			privilegeLb:setAnchorPoint(ccp(0,1))
			privilegeLb:setPosition(25,posY)
			cell:addChild(privilegeLb)
		elseif idx==1 then
			local posY=cellHeight-21
			local titleLb=GetTTFLabelWrap(getlocal("plane_skill_desc_title"),self.fontSize,CCSizeMake(self.textWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			titleLb:setAnchorPoint(ccp(0.5,1))
			titleLb:setPosition(self.tvWidth/2,posY)
			titleLb:setColor(G_ColorYellowPro)
			cell:addChild(titleLb)
			posY=posY-titleLb:getContentSize().height-10
			if self.refitSkillAttr then
				local descLb, descLbHeight = G_getRichTextLabel(descStr, {nil, G_ColorYellowPro, nil}, self.fontSize, self.textWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
				descLb:setAnchorPoint(ccp(0.5,0.5))
				descLb:setPosition(self.tvWidth/2,posY)
				cell:addChild(descLb)
			else
				local descLb=GetTTFLabelWrap(descStr,self.fontSize,CCSizeMake(self.textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				descLb:setAnchorPoint(ccp(0.5,1))
				descLb:setPosition(self.tvWidth/2,posY)
				cell:addChild(descLb)
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

-- 分解单件装备
function planeSkillInfoDialog:sellOneEquip()
	local function onSell()
		if(self.skillVo==nil or self.skillVo.num==nil)then
			do return end
		end
		local function callback()
			self:close()
		end
		planeVoApi:sell(self.skillVo.sid,nil,callback)
	end
	planeVoApi:showSellSkillDialog({self.skillVo},self.layerNum + 1,onSell)
end

function planeSkillInfoDialog:dispose()
	self.tv=nil
	self.skillVo=nil
	self.cellHeight={}
end