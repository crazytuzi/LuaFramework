--技能升级材料转换的面板
playerSkillPropDialog=commonDialog:new()

function playerSkillPropDialog:new(data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function playerSkillPropDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)

	self.nameFontSize,self.desFontSize=22,20
    self.tvWidth,self.tvHeight = G_VisibleSizeWidth - 30,G_VisibleSizeHeight - 230
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20 - 3)
	self.tv:setPosition(ccp((G_VisibleSizeWidth-self.tvWidth)/2,130))
	self.tv:setMaxDisToBottomOrTop(60)
	self.bgLayer:addChild(self.tv,2)

    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ( ... )end)
    tvBg:setContentSize(CCSizeMake(self.tvWidth+4,self.tvHeight+4))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(G_VisibleSizeWidth/2,self.tv:getPositionY()-2)
    self.bgLayer:addChild(tvBg)

	local propIcon1=CCSprite:createWithSpriteFrameName(propCfg["p19"].icon)
	propIcon1:setScale(50/propIcon1:getContentSize().width)
	propIcon1:setPosition(60,60)
	self.bgLayer:addChild(propIcon1)
	local p19NumLb=GetTTFLabel(FormatNumber(bagVoApi:getItemNumId(19)),25)
	p19NumLb:setTag(1)
	p19NumLb:setAnchorPoint(ccp(0,0.5))
	p19NumLb:setPosition(90,60)
	self.bgLayer:addChild(p19NumLb)
	local propIcon2=GetBgIcon(propCfg["p3302"].icon,nil,propCfg["p3302"].iconbg,90,50)
	propIcon2:setPosition(200,60)
	self.bgLayer:addChild(propIcon2)
	local p3302NumLb=GetTTFLabel(FormatNumber(bagVoApi:getItemNumId(3302)),25)
	p3302NumLb:setTag(2)
	p3302NumLb:setAnchorPoint(ccp(0,0.5))
	p3302NumLb:setPosition(230,60)
	self.bgLayer:addChild(p3302NumLb)
	local propIcon3=GetBgIcon(propCfg["p3303"].icon,nil,propCfg["p3303"].iconbg,90,50)
	propIcon3:setPosition(340,60)
	self.bgLayer:addChild(propIcon3)
	local p3303NumLb=GetTTFLabel(FormatNumber(bagVoApi:getItemNumId(3303)),25)
	p3303NumLb:setTag(3)
	p3303NumLb:setAnchorPoint(ccp(0,0.5))
	p3303NumLb:setPosition(370,60)
	self.bgLayer:addChild(p3303NumLb)
end

function playerSkillPropDialog:eventHandler(handler,fn,idx,cel)
	local cellH2 = 200
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		cellH2=150
	end
	if fn=="numberOfCellsInTableView" then
		return 3
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.tvWidth,cellH2)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		-- local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ( ... )end)
		-- cellBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,cellH2-5))
		-- cellBg:setPosition((G_VisibleSizeWidth - 60)/2,cellH2*0.5)
		-- cell:addChild(cellBg)
		local function onGet(tag,object)
			if(tag)then
				self:getProp(tag)
			end
		end
		local btnScale = 0.64
		local icon,propNameLb,propDescLb,getItem,getBtn,costIcon,costLb
		if(idx==2)then
			icon=GetBgIcon(propCfg["p3303"].icon,nil,propCfg["p3303"].iconbg,90,100)
			propNameLb=GetTTFLabel(getlocal(propCfg["p3303"].name),self.nameFontSize,true)			
			propDescLb=GetTTFLabelWrap(getlocal(propCfg["p3303"].description),self.desFontSize,CCSizeMake(G_VisibleSizeWidth - 340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		elseif(idx==1)then
			icon=GetBgIcon(propCfg["p3302"].icon,nil,propCfg["p3302"].iconbg,90,100)
			propNameLb=GetTTFLabel(getlocal("vip_tequanlibao_geshihua",{getlocal(propCfg["p3302"].name),playerSkillCfg.getPropList.p3302.getNum}),self.nameFontSize,true)
			propDescLb=GetTTFLabelWrap(getlocal(propCfg["p3302"].description),self.desFontSize,CCSizeMake(G_VisibleSizeWidth - 340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			getItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onGet,2,getlocal("activity_recycling_tip3"),28)
			getBtn=CCMenu:createWithItem(getItem)
			costIcon=CCSprite:createWithSpriteFrameName(propCfg["p19"].icon)
			costIcon:setScale(40/costIcon:getContentSize().width)
			costLb=GetTTFLabel(playerSkillCfg.getPropList.p3302.costProp["p19"],22)
			if(skillVoApi:checkPropCanChange("p3302")==false)then
				getBtn:setVisible(false)
				self.cdLb=GetTTFLabel(GetTimeStr(skillVoApi:getChangeCD("p3302") - base.serverTime),self.nameFontSize)
				self.cdLb:setColor(G_ColorRed)
				self.cdLb:setPosition(G_VisibleSizeWidth - 140,60)
				cell:addChild(self.cdLb)
			end
		else
			icon=CCSprite:createWithSpriteFrameName(propCfg["p19"].icon)
			propNameLb=GetTTFLabel(getlocal("vip_tequanlibao_geshihua",{getlocal(propCfg["p19"].name),playerSkillCfg.getPropList.p19.getNum}),self.nameFontSize,true)
			propDescLb=GetTTFLabelWrap(getlocal(propCfg["p19"].description),self.desFontSize,CCSizeMake(G_VisibleSizeWidth - 340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			getItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onGet,1,getlocal("buy"),24/btnScale)
			getBtn=CCMenu:createWithItem(getItem)
			costIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
			costLb=GetTTFLabel(playerSkillCfg.getPropList.p19.costGem,self.desFontSize)
		end
		icon:setPosition(60,cellH2*0.5)
		cell:addChild(icon)		
		propNameLb:setAnchorPoint(ccp(0,0.5))
		propNameLb:setPosition(120,cellH2-30)
		cell:addChild(propNameLb)
		propDescLb:setAnchorPoint(ccp(0,0.5))
		propDescLb:setPosition(120,cellH2*0.5-20)
		cell:addChild(propDescLb)
		if(getBtn)then
			getItem:setScale(btnScale)
			getBtn:setTouchPriority(-(self.layerNum-1)*20-4)
			getBtn:setPosition(G_VisibleSizeWidth - 140,cellH2*0.5-15)
			cell:addChild(getBtn)
			costIcon:setPosition(G_VisibleSizeWidth - 160,cellH2-40)
			cell:addChild(costIcon)
			costLb:setPosition(G_VisibleSizeWidth - 110,cellH2-40)
			cell:addChild(costLb)
		end

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake(self.tvWidth-18, lineSp:getContentSize().height))
        lineSp:setRotation(180)
        lineSp:setPosition(self.tvWidth/2,lineSp:getContentSize().height/2)
        cell:addChild(lineSp)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function playerSkillPropDialog:getProp(type)
	local confirmStr
	local pid
	if(type==1)then
		local costGems=playerSkillCfg.getPropList.p19.costGem
		if(playerVoApi:getGems()<costGems)then
			GemsNotEnoughDialog(nil,nil,costGems - playerVoApi:getGems(),10,costGems)
			do return end
		end
		confirmStr=getlocal("buyConfirm",{costGems,playerSkillCfg.getPropList.p19.getNum,getlocal(propCfg["p19"].name)})
		pid="p19"
	elseif(type==2)then
		local costProps=playerSkillCfg.getPropList.p3302.costProp["p19"]
		if(bagVoApi:getItemNumId(19)<costProps)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9033"),28)
			do return end
		end
		confirmStr=getlocal("nbSkill_switchConfirm",{costProps,getlocal(propCfg["p19"].name),playerSkillCfg.getPropList.p3302.getNum,getlocal(propCfg["p3302"].name)})
		if(skillVoApi:checkPropCanChange("p3302")==false)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("not_to_time"),28)
			do return end
		end
		pid="p3302"
	end
	local function onConfirm()
		local function callback()
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
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),28)
			self.cdLb=nil
			self.tv:reloadData()
			eventDispatcher:dispatchEvent("player.skill.change")
		end
		skillVoApi:changeProp(pid,callback)
	end
	local sd=smallDialog:new()
	sd:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),confirmStr,nil,self.layerNum+1)
end

function playerSkillPropDialog:tick()
	if(self.cdLb)then
		local cdTime=skillVoApi:getChangeCD("p3302") - base.serverTime
		if(cdTime<=0)then
			self.cdLb=nil
			self.tv:reloadData()
		else
			self.cdLb:setString(GetTimeStr(skillVoApi:getChangeCD("p3302") - base.serverTime))
		end
	end
end

function playerSkillPropDialog:dispose()
	self.tvWidth=nil
	self.tvHeight=nil
	self.nameFontSize=nil
	self.desFontSize=nil
end