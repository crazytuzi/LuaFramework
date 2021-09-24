	--旧技能系统的页签
playerDialogTabSkillNB={}

function playerDialogTabSkillNB:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent=parent
	nc.selectedType=0
	nc.isGuide=nil
	return nc;
end

function playerDialogTabSkillNB:init(layerNum,isGuide)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
 	spriteController:addPlist("public/youhuaUI4.plist")
    spriteController:addTexture("public/youhuaUI4.png")
   	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/nbSkill2.plist")
    spriteController:addTexture("public/nbSkill2.png")

	self.isGuide=isGuide
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initFunctionBar()
	self:initTableView()
	local function eventListener(event,data)
		self:refresh()
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("player.skill.change",eventListener)

	if newGuidMgr:isNewGuiding()==true and self.guideItem then
		newGuidMgr:setGuideStepField(40,self.guideItem)
	end
	return self.bgLayer
end

function playerDialogTabSkillNB:initFunctionBar()
	-- local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,50,50),function ( ... )end)
	-- upBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 350))
	-- upBg:setAnchorPoint(ccp(0,1))
	-- upBg:setPosition(30,G_VisibleSizeHeight - 170)
	-- self.bgLayer:addChild(upBg)
	self.sideTabSpTb={}
	local function onSwitchType(object,fn,tag)
		if(tag)then
			local type=tag - 100
			self:switchType(type)
		end
	end
	for i=0,4 do
		local sideTabSp=CCSprite:createWithSpriteFrameName("rankTab.png")
		sideTabSp:setAnchorPoint(ccp(1,0.5))
		sideTabSp:setPosition(131,G_VisibleSizeHeight - 200 - 55 - 110*i)
		sideTabSp:setScale(0.9)
		self.bgLayer:addChild(sideTabSp,2)
		local sideIcon=LuaCCSprite:createWithSpriteFrameName("playerSkill_tank_"..i..".png",onSwitchType)
		sideIcon:setTag(100 + i)
		sideIcon:setPosition(getCenterPoint(sideTabSp))
		sideIcon:setTouchPriority(-(self.layerNum-1)*20-3)
		sideTabSp:addChild(sideIcon,2)
		if i==0 then
			sideIcon:setScale(0.8)
		end

		self.sideTabSpTb[i+1]=sideTabSp
	end
	self:switchType(0)
	local propIcon1=CCSprite:createWithSpriteFrameName(propCfg["p19"].icon)
	propIcon1:setScale(50/propIcon1:getContentSize().width)
	propIcon1:setPosition(100,145)
	self.bgLayer:addChild(propIcon1)
	local p19NumLb=GetTTFLabel(FormatNumber(bagVoApi:getItemNumId(19)),20)
	p19NumLb:setTag(1)
	p19NumLb:setAnchorPoint(ccp(0,0.5))
	p19NumLb:setPosition(140,145)
	self.bgLayer:addChild(p19NumLb)
	local propIcon2=GetBgIcon(propCfg["p3302"].icon,nil,propCfg["p3302"].iconbg,90,50)
	propIcon2:setPosition(250,145)
	self.bgLayer:addChild(propIcon2)
	local p3302NumLb=GetTTFLabel(FormatNumber(bagVoApi:getItemNumId(3302)),20)
	p3302NumLb:setTag(2)
	p3302NumLb:setAnchorPoint(ccp(0,0.5))
	p3302NumLb:setPosition(290,145)
	self.bgLayer:addChild(p3302NumLb)
	local propIcon3=GetBgIcon(propCfg["p3303"].icon,nil,propCfg["p3303"].iconbg,90,50)
	propIcon3:setPosition(400,145)
	self.bgLayer:addChild(propIcon3)
	local p3303NumLb=GetTTFLabel(FormatNumber(bagVoApi:getItemNumId(3303)),20)
	p3303NumLb:setTag(3)
	p3303NumLb:setAnchorPoint(ccp(0,0.5))
	p3303NumLb:setPosition(440,145)
	self.bgLayer:addChild(p3303NumLb)
	local function onGetProp()
		self:showGetProp()
	end
	local getPropItem=GetButtonItem("yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png","yh_nbSkillGoto_Down.png",onGetProp)
	getPropItem:setScale(0.9)
	local getPropBtn=CCMenu:createWithItem(getPropItem)
	getPropBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	getPropBtn:setPosition(550,145)
	self.bgLayer:addChild(getPropBtn)
	local function onInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr = {"\n",getlocal("nbSkill_info"),"\n"}
		local tabColor = {nil,G_ColorYellow,nil}
		local td=smallDialog:new()
		local dialog1=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog1,self.layerNum+1)
	end
	local infoItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",onInfo)
	local infoBtn=CCMenu:createWithItem(infoItem)
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	infoBtn:setPosition(100,70)
	self.bgLayer:addChild(infoBtn)
	local function onReset()
		if(skillVoApi:getSkillIsAllZero())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("no_skill_to_clear"),28)
			do return end
		end
		local costGems=playerSkillCfg.resetGem
		if(playerVoApi:getGems()<costGems)then
			GemsNotEnoughDialog(nil,nil,costGems - playerVoApi:getGems(),10,costGems)
			do return end
		end
		local function onConfirm()
			local function callback()
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),28)
				self:refresh()
			end
			skillVoApi:reset(callback)
		end
		local sd=smallDialog:new()
		sd:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("player_info_clear_skill_tip",{costGems}),nil,self.layerNum+1)
	end
	local resetItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onReset,nil,getlocal("player_info_clear_skill"),24,100)
	local resetBtn=CCMenu:createWithItem(resetItem)
	resetBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	resetBtn:setPosition(280,70)
	self.bgLayer:addChild(resetBtn)
	local lb = resetItem:getChildByTag(100)
	if lb then
		lb = tolua.cast(lb, "CCLabelTTF")
		lb:setFontName("Helvetica-bold")
	end
	local function onAuto()
		local canUpgrade=false
		for sid,sVo in pairs(skillVoApi:getAllSkills()) do
			if(skillVoApi:checkCanUpgrade(sid)==0)then
				canUpgrade=true
				break
			end
		end
		if(canUpgrade==false)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("nbSkill_noSkillToUpgrade"),28)
			do return end
		end
		local function onConfirm()
			local function callback()
				self:refresh()
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_upgrade_success"),28)
			end
			skillVoApi:autoUpgrade(callback)			
		end
		local sd=smallDialog:new()
		sd:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("nbSkill_autoUpgrade"),nil,self.layerNum+1)
	end
	local autoItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onAuto,nil,getlocal("hero_skills_automatic_update"),24,100)
	local autoBtn=CCMenu:createWithItem(autoItem)
	autoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	autoBtn:setPosition(500,70)
	self.bgLayer:addChild(autoBtn)
	local lb = autoItem:getChildByTag(100)
	if lb then
		lb = tolua.cast(lb, "CCLabelTTF")
		lb:setFontName("Helvetica-bold")
	end
end

function playerDialogTabSkillNB:switchType(type)
	local lastSideTabSp,sideTabSp = tolua.cast(self.sideTabSpTb[self.selectedType+1],"CCSprite"),tolua.cast(self.sideTabSpTb[type+1],"CCSprite")
	if lastSideTabSp and sideTabSp then
		local normalFrame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("rankTab.png")
		if normalFrame then
			lastSideTabSp:setDisplayFrame(normalFrame)
			lastSideTabSp:setScale(0.9)
		end
		local selectedFrame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("rankTab_Down.png")
		if selectedFrame then
			sideTabSp:setDisplayFrame(selectedFrame)
			sideTabSp:setScale(1)
		end
	end
	self.selectedType=type
	local tankType
	if(type==0)then
		tankType=0
	else
		tankType=math.pow(2,(type - 1))
	end
	local typeSkills=skillVoApi:getSkillListByType(tankType)
	self.typeSkills={}
	self.typeSkillNum=0
	for sid,sVo in pairs(typeSkills) do
		table.insert(self.typeSkills,sVo)
		self.typeSkillNum=self.typeSkillNum + 1
	end
	local function sortFunc(a,b)
		return a.cfg.sid<b.cfg.sid
	end
	table.sort(self.typeSkills,sortFunc)
	if(self.tv)then
		self.tv:reloadData()
	end
end

function playerDialogTabSkillNB:initTableView()
	self.tvBgWidth=470
	local tvLineSp=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,1,2,1),function ()end)
	tvLineSp:setContentSize(CCSizeMake(G_VisibleSizeHeight - 360,tvLineSp:getContentSize().height))
	tvLineSp:setPosition(134.5,G_VisibleSizeHeight - 175 - tvLineSp:getContentSize().width/2)
	tvLineSp:setRotation(-90)
	self.bgLayer:addChild(tvLineSp)
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvBgWidth,G_VisibleSizeHeight - 370),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20 - 3)
	self.tv:setPosition(ccp(152,190))
	self.bgLayer:addChild(self.tv,2)
	self.tv:setMaxDisToBottomOrTop(120)

	local downLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
    downLineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,downLineSp:getContentSize().height))
    downLineSp:setPosition(G_VisibleSizeWidth/2,180)
    downLineSp:setRotation(180)
    self.bgLayer:addChild(downLineSp)
end

function playerDialogTabSkillNB:eventHandler(handler,fn,idx,cel)
	local strSize2 = 18
	local strSize3 = 18
	local strH = 110
	local posw = 425
	local posh = 65
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		strSize2=24
		strSize3 =20
		strH = 100
		posw = 420
		posh = 75
	end
	if fn=="numberOfCellsInTableView" then
		return self.typeSkillNum
	elseif fn=="tableCellSizeForIndex" then
		local data=self.typeSkills[idx + 1]
		if(data.cfg.nblv==1)then
			return CCSizeMake(self.tvBgWidth,128)
		else
			return CCSizeMake(self.tvBgWidth,150)
		end
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local data=self.typeSkills[idx + 1]
		local cellBg
		local function onTouchBg(object,fn,tag)
			if(self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false)then
				if(tag)then
					local index=tag - 100 + 1
					self:showSkillDetail(index)
				end
			end
		end
		if(data.cfg.nblv==1)then
			cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("nbSkillBorder.png",CCRect(116, 58, 1, 1),onTouchBg)
		elseif(data.cfg.nblv==2)then
			cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("nbSkillBorder1.png",CCRect(116, 58, 1, 1),onTouchBg)
		else
			cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("nbSkillBorder2.png",CCRect(119, 68, 1, 1),onTouchBg)
		end
		cellBg:setTag(100 + idx)
		cellBg:setTouchPriority(-(self.layerNum-1)*20-1)
		if(data.cfg.nblv==1)then
			cellBg:setContentSize(CCSizeMake(self.tvBgWidth,118))
			cellBg:setPosition(self.tvBgWidth/2,60)
		else
			cellBg:setContentSize(CCSizeMake(self.tvBgWidth,140))
			cellBg:setPosition(self.tvBgWidth/2,75)
		end
		cell:addChild(cellBg)
		local skillIcon=skillVoApi:getSkillIconById(data.sid)
		skillIcon:setScale(90/skillIcon:getContentSize().width)
		if(data.cfg.nblv==1)then
			skillIcon:setPosition(60,60)
		else
			skillIcon:setPosition(60,75)
		end
		cell:addChild(skillIcon)
		local skillName=GetTTFLabel(getlocal(data.cfg.name).." "..getlocal("fightLevel",{data.lv}),strSize2,true)
		skillName:setAnchorPoint(ccp(0,0.5))
		if(data.cfg.nblv==1)then
			skillName:setPosition(120,strH-10)
		else
			skillName:setPosition(120,strH)
		end
		cell:addChild(skillName)
		local function onUpgrade(tag,object)
			if(tag)then
				local index=tag - 100 + 1
				local upData=self.typeSkills[index]
				if(upData)then
					local function callback()
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("skillLevelUp",{getlocal(skillVoApi:getSkillNameById(upData.sid)),upData.lv}),28)
						self:refresh()
						if newGuidMgr:isNewGuiding() then
							if idx==0 then
								newGuidMgr:toNextStep()
							end
						end
					end
					skillVoApi:upgrade(upData.sid,upData.lv + 1,callback)
				end
			end
		end
		local upItem=GetButtonItem("yh_BtnUp.png","yh_BtnUp_Down.png","yh_BtnUp_Down.png",onUpgrade,100 + idx)
		local upBtn=CCMenu:createWithItem(upItem)
		upBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		if(data.cfg.nblv==1)then
			upBtn:setPosition(posw,posh-15)
		else
			upBtn:setPosition(posw,posh)
		end
		if idx==0 then
			self.guideItem=upItem
		end

		cell:addChild(upBtn)
		local canUpgrade=skillVoApi:checkCanUpgrade(data.sid)
		if(canUpgrade~=0)then
			upItem:setEnabled(false)
			if(canUpgrade==3)then
				upBtn:setVisible(false)
				local maxLv=GetTTFLabel(getlocal("alliance_lvmax"),strSize3)
				maxLv:setColor(G_ColorGreen)
				maxLv:setAnchorPoint(ccp(0,0.5))
				if(data.cfg.nblv==1)then
					maxLv:setPosition(120,65-10)
				else
					maxLv:setPosition(120,65)
				end
				cell:addChild(maxLv)
			else
				local conditionLb1=GetTTFLabel(getlocal("activity_dayRecharge_no"),strSize3)
				conditionLb1:setColor(G_ColorRed)
				conditionLb1:setAnchorPoint(ccp(0,0.5))
				if(data.cfg.nblv==1)then
					conditionLb1:setPosition(120,70-10)
				else
					conditionLb1:setPosition(120,70)
				end
				cell:addChild(conditionLb1)
				local conditionLb2=GetTTFLabel(getlocal("activity_chunjiepansheng_click_kan"),strSize3)
				conditionLb2:setColor(G_ColorRed)
				conditionLb2:setAnchorPoint(ccp(0,0.5))
				if(data.cfg.nblv==1)then
					conditionLb2:setPosition(120,45-10)
				else
					conditionLb2:setPosition(120,45)
				end
				cell:addChild(conditionLb2)
			end
		else
			local propNeed=skillVoApi:getPropRequireByIdAndLv(data.sid)
			local propTb={}
			for pid,pNum in pairs(propNeed) do
				table.insert(propTb,{pid,pNum})
			end
			local function sortFunc(a,b)
				return tonumber(RemoveFirstChar(a[1]))<tonumber(RemoveFirstChar(b[1]))
			end
			table.sort(propTb,sortFunc)
			for k,v in pairs(propTb) do
				local propIcon
				if(v[1]=="p19")then
					propIcon=CCSprite:createWithSpriteFrameName(propCfg["p19"].icon)
					propIcon:setScale(50/propIcon:getContentSize().width)
				elseif(v[1]=="p3302")then
					propIcon=GetBgIcon(propCfg["p3302"].icon,nil,propCfg["p3302"].iconbg,90,50)
				elseif(v[1]=="p3303")then
					propIcon=GetBgIcon(propCfg["p3303"].icon,nil,propCfg["p3303"].iconbg,90,50)
				end
				if(data.cfg.nblv==1)then
					propIcon:setPosition(150 + 110*(k - 1),55-10)
				else
					propIcon:setPosition(150 + 110*(k - 1),55)
				end
				cell:addChild(propIcon)
				local propNumLb=GetTTFLabel(FormatNumber(v[2]),20)
				propNumLb:setAnchorPoint(ccp(0,0.5))
				if(data.cfg.nblv==1)then
					propNumLb:setPosition(180 + 110*(k - 1),55-10)
				else
					propNumLb:setPosition(180 + 110*(k - 1),55)
				end
				cell:addChild(propNumLb)
			end
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	elseif fn=="ccScrollEnable" then
		if newGuidMgr:isNewGuiding()==true then
			return 0
		else
			return 1
		end
	end
end

function playerDialogTabSkillNB:showSkillDetail(index)
	if newGuidMgr:isNewGuiding() then --新手引导
		do return end
	end
	local data=self.typeSkills[index]
	if(data)then
		require "luascript/script/game/scene/gamedialog/playerDialog/playerSkillDetailDialog"
		local td=playerSkillDetailDialog:new(data)
		local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("heroSkillUpdate"),false,self.layerNum + 1)
		sceneGame:addChild(dialog,self.layerNum + 1)
	end
end

function playerDialogTabSkillNB:showGetProp()
	if newGuidMgr:isNewGuiding() then --新手引导
		do return end
	end
	require "luascript/script/game/scene/gamedialog/playerDialog/playerSkillPropDialog"
	local td=playerSkillPropDialog:new(data)
	local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("accessory_material"),true,self.layerNum + 1)
	sceneGame:addChild(dialog,self.layerNum + 1)
end

function playerDialogTabSkillNB:tick()
end

function playerDialogTabSkillNB:refresh()
	if(self.tv)then
		local point=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(point)
	end
	local p19NumLb=tolua.cast(self.bgLayer:getChildByTag(1),"CCLabelTTF")
	if(p19NumLb)then
		p19NumLb:setString(FormatNumber(bagVoApi:getItemNumId(19)))
	end
	local p3302NumLb=tolua.cast(self.bgLayer:getChildByTag(2),"CCLabelTTF")
	if(p3302NumLb)then
		p3302NumLb:setString(FormatNumber(bagVoApi:getItemNumId(3302)))
	end
	local p3303NumLb=tolua.cast(self.bgLayer:getChildByTag(3),"CCLabelTTF")
	if(p3303NumLb)then
		p3303NumLb:setString(FormatNumber(bagVoApi:getItemNumId(3303)))
	end
end

function playerDialogTabSkillNB:dispose()
	self.selectedTank=0
	self.guideItem=nil
	self.sideTabSpTb=nil
	eventDispatcher:removeEventListener("player.skill.change",self.eventListener)
	spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
    spriteController:removePlist("public/nbSkill2.plist")
    spriteController:removeTexture("public/nbSkill2.png")
end
