local believerSuperManDialog=commonDialog:new()

function believerSuperManDialog:new(parent)
	local nc={
		parent=parent,
	}
	setmetatable(nc,self)
	self.__index=self
	nc.parent   = parent
	nc.layerNum = layerNum
	nc.curSuperManTb = {}
	nc.superManNum 	 = 0
	nc.superManTb  	 = {}
	spriteController:addPlist("public/ltzdz/ltzdzSegImages2.plist")
    spriteController:addTexture("public/ltzdz/ltzdzSegImages2.png")
	return nc
end

function believerSuperManDialog:dispose()
	self.curSuperManTb = nil
	self.superManNum   = nil
	self.superManTb    = nil
    self.layerNum    = nil
    if self.parent and self.parent.backToMainDialogHandler then
        self.parent:backToMainDialogHandler()
        self.parent=nil
    end
    spriteController:removePlist("public/ltzdz/ltzdzSegImages2.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzSegImages2.png")
end

function believerSuperManDialog:doUserHandler()
	self.panelLineBg:setVisible(false)
	self.panelTopLine:setVisible(true)
	self.topPosy = self.panelTopLine:getPositionY() + 70
	self.panelTopLine:setPositionY(self.topPosy)

	self.superManNum,self.superManTb = believerVoApi:getSuperManTbData()
	self.curSuperManTb = self.superManTb[1]
	----假数据----
	-- for i=1,21 do
	-- 	table.insert(self.superManTb,self.superManTb[1])
	-- end
	-------------
	table.remove(self.superManTb,1)
	self.superManNum = self.superManNum - 1 -- tableview里需要显示的数据数量

	self:initCurSuperManDia()
end

function believerSuperManDialog:initCurSuperManDia( )
	self.topBgHeight = math.ceil(G_VisibleSizeHeight/6)--5.19 是4寸释义图比例

	local smBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function ( ) end)
	smBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,self.topBgHeight))
	smBg:setAnchorPoint(ccp(0.5,1))
	smBg:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.topPosy - 5))
	self.bgLayer:addChild(smBg)
	local smBgWidth = smBg:getContentSize().width

	local lposx = 15
	-- local topOneSp = CCSprite:createWithSpriteFrameName("top1.png")
	-- topOneSp:setScale(0.9)
	-- topOneSp:setPosition(ccp(lposx,self.topBgHeight * 0.5))
	-- smBg:addChild(topOneSp)

	local needSize = self.topBgHeight * 0.65
	local picName=playerVoApi:getPersonPhotoName(self.curSuperManTb[4])
    local superManIcon = playerVoApi:GetPlayerBgIcon(picName,nil,nil,nil,needSize,"h3001")
    superManIcon:setPosition(ccp(needSize * 0.5 + lposx ,self.topBgHeight * 0.5))
    smBg:addChild(superManIcon)
    -- believerVoApi:addIconBorder(smBg,superManIcon,needSize)

    local lbTb,posyScaleTb = {},{0.9,0.56,0.33,0.1}
    lbTb[1] = GetServerNameByID(self.curSuperManTb[3],true).."-"..self.curSuperManTb[5]
    lbTb[2] = getlocal("serverwar_point").."："..self.curSuperManTb[6]
    lbTb[3] = getlocal("believer_dmgRate",{(self.curSuperManTb[7]/10)}).."%"
    lbTb[4] = getlocal("believer_battleNumStr").."："..self.curSuperManTb[8]

    for i=1,4 do
    	local showLb = GetTTFLabelWrap(lbTb[i],24,CCSizeMake(255,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    	showLb:setAnchorPoint(ccp(0,0.5))
    	showLb:setPosition(ccp(superManIcon:getPositionX() + needSize/2 + 15,(self.topBgHeight - needSize) * 0.5 + needSize * posyScaleTb[i]))
    	smBg:addChild(showLb)

    	if i == 1 then
    		if showLb:getContentSize().width > 255 then
		    	showLb:setScale(251/showLb:getContentSize().width)
		    end
		end
    end

    local topIconSp = CCSprite:createWithSpriteFrameName("believerSeasonIcon.png")
    topIconSp:setScale(needSize/topIconSp:getContentSize().height)
    topIconSp:setAnchorPoint(ccp(1,0.5))
    topIconSp:setPosition(ccp(smBgWidth - 10,self.topBgHeight * 0.5 + 10))
    smBg:addChild(topIconSp)
    believerVoApi:showRandomStr(topIconSp)

    local seasonStr="S"..self.curSuperManTb[1]
    local seasonLb = GetTTFLabel(seasonStr,38,"Helvetica-bold")
    seasonLb:setPosition(ccp(topIconSp:getContentSize().width * 0.5,0))
    seasonLb:setColor(G_ColorYellowPro2)
    topIconSp:addChild(seasonLb,1)
    seasonLb:setScale(topIconSp:getContentSize().height/(needSize - 20))
    G_addStroke(topIconSp,seasonLb,seasonStr,38,true) --加描边
end

function believerSuperManDialog:initTableView()
	-- local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
 --    tvBg:setPosition(ccp(0,10))
 --    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.topPosy - self.topBgHeight - 20))
 --    tvBg:setAnchorPoint(ccp(0,0))
 --    self.tvBg = tvBg
 --    self.bgLayer:addChild(tvBg)
 	if self.superManTb == 0 then
 		do return end
 	end
 	self.superManIdx = 1
 	self.cellNum = math.ceil(SizeOfTable(self.superManTb)/4)
    self.cellHeight = 190
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,self.topPosy - self.topBgHeight - 20),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(0,10))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function believerSuperManDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
            return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        --(i-1)*2.5+1.25
        for i=1,4 do
        	if self.superManTb[self.superManIdx] then
        		local curUseData = self.superManTb[self.superManIdx]
        		local curUsePosx = G_VisibleSizeWidth*((i-1)*0.25+0.125)

		        local nameLb = GetTTFLabel(curUseData[5],24,"Helvetica-bold")
		        nameLb:setPosition(ccp(curUsePosx,5))
		        nameLb:setAnchorPoint(ccp(0.5,0))
		        cell:addChild(nameLb)
		        if nameLb:getContentSize().width > 120 then
			    	nameLb:setScale(116/nameLb:getContentSize().width)
			    end
		        local fId = GetTTFLabel(GetServerNameByID(curUseData[3],true),24,"Helvetica-bold")
		        fId:setPosition(ccp(curUsePosx,nameLb:getContentSize().height + 5))
		        fId:setAnchorPoint(ccp(0.5,0))
		        cell:addChild(fId)

		        if fId:getContentSize().width > 120 then
		        	fId:setScale(120/fId:getContentSize().width)
		        end

		        local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("newKuang5.png",CCRect(12,63,1,1),function ()end)
		        upBg:setContentSize(CCSizeMake(120,130))
		        upBg:setAnchorPoint(ccp(0.5,0))
		        upBg:setPosition(ccp(curUsePosx,fId:getPositionY() + fId:getContentSize().height + 5))	
		        cell:addChild(upBg)

		        local topIconSp = CCSprite:createWithSpriteFrameName("believerSeasonIcon.png")
			    topIconSp:setScale(100/topIconSp:getContentSize().height)
			    topIconSp:setPosition(ccp(upBg:getContentSize().width *0.5,upBg:getContentSize().height*0.5 + 15))
			    upBg:addChild(topIconSp)
			    believerVoApi:showRandomStr(topIconSp)

			    local seasonStr="S"..curUseData[1]
			    local seasonLb = GetTTFLabel(seasonStr,33,true)
			    seasonLb:setPosition(ccp(topIconSp:getContentSize().width * 0.5,0))
			    seasonLb:setColor(G_ColorYellowPro2)
			    topIconSp:addChild(seasonLb,1)
			    seasonLb:setScale(topIconSp:getContentSize().height/100)
				G_addStroke(topIconSp,seasonLb,seasonStr,33,true) --加描边
		        self.superManIdx = self.superManIdx + 1
		    end
        end
        


		return cell
    end
end













return believerSuperManDialog