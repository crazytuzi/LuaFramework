local returnReportDialog={}--返回报告/采集报告

function returnReportDialog:new(report)
	local nc={
		report=report,
		showType=nil,
		cellHeightTb=nil,
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function returnReportDialog:initReportLayer(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()

	if self.report.type==3 then
		local report=self.report
		local returnStr=""
		local allianceName=""
		if report.allianceName and report.allianceName~="" then
			allianceName=getlocal("report_content_alliance",{report.allianceName})
		end
		if report.returnType==1 then
			if report.islandType==8 then
				returnStr=getlocal("return_content_protected_tip2",{report.name,report.place.x,report.place.y})
			elseif report.islandType == 9 then
				returnStr = getlocal("return_content_moved_tip3", {report.place.x,report.place.y})
			else
				returnStr=getlocal("return_content_protected_tip",{report.name..allianceName,report.place.x,report.place.y})
			end
		elseif report.returnType==2 then
			if report.islandType==8 then
				returnStr=getlocal("return_content_moved_tip2",{report.place.x,report.place.y})
			elseif report.islandType == 9 then
				returnStr = getlocal("return_content_moved_tip3", {report.place.x,report.place.y})
			else
				returnStr=getlocal("return_content_moved_tip",{report.place.x,report.place.y})
			end
		elseif report.returnType==3 then
			returnStr=getlocal("return_content_tip",{G_getIslandName(report.islandType),report.level,report.place.x,report.place.y})
		elseif report.returnType==4 then
			returnStr=getlocal("return_content_tip_1",{G_getIslandName(report.islandType),report.level,report.place.x,report.place.y})
        elseif report.returnType==5 then
            returnStr=getlocal("return_content_tip_2",{report.name..allianceName,report.place.x,report.place.y})
        elseif report.returnType==6 then
            returnStr=getlocal("return_content_tip_3")
        elseif report.returnType==7 then
            returnStr=getlocal("return_content_tip_4")
        elseif report.returnType==8 then
            returnStr=getlocal("return_content_tip_5")
        elseif report.returnType==9 then
        	local rebel=report.rebel or {}
        	local rebelLv,rebelID=rebel.rebelLv or 1,rebel.rebelID or 1
        	local energy = (rebel.energy and rebel.energy > 0) and rebel.energy or nil
        	local addTipStr = energy and getlocal("returnReport9AddTip",{energy}) or ""
        	local target=G_getIslandName(report.islandType,nil,rebelLv,rebelID,nil,rebel.rpic)
            returnStr=getlocal("return_content_tip_9",{target,report.place.x,report.place.y})..addTipStr
        elseif report.returnType==10 then
        	returnStr=getlocal("return_content_tip_10")
		end
		local msgLabel=GetTTFLabelWrap(returnStr,24,CCSizeMake(self.bgLayer:getContentSize().width-50, 30*10),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		msgLabel:setAnchorPoint(ccp(0,1))
		msgLabel:setPosition(ccp(25,self.bgLayer:getContentSize().height-110))
		self.bgLayer:addChild(msgLabel,2)
	elseif self.report.type==10 then
		local returnStr=getlocal("hitfly_email_content",{self.report.name})
		local msgLabel=GetTTFLabelWrap(returnStr,24,CCSizeMake(self.bgLayer:getContentSize().width-50, 30*10),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		msgLabel:setAnchorPoint(ccp(0,1))
		msgLabel:setPosition(ccp(25,self.bgLayer:getContentSize().height-110))
		self.bgLayer:addChild(msgLabel,2)
	else
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		local topBg=CCSprite:create("public/reportTopContentBg.jpg")
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		topBg:setAnchorPoint(ccp(0.5,1))
		topBg:setPosition(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-83)
		self.bgLayer:addChild(topBg)

		self:initTopContent(topBg)

		self.tvWidth,self.tvHeight=616,topBg:getPositionY()-topBg:getContentSize().height-90-5
		local function callBack(...)
			return self:eventHandler(...)
	    end
	    local hd=LuaEventHandler:createHandler(callBack)
		self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
		self.tv:setAnchorPoint(ccp(0,0))
	    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,90)
		self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
		self.bgLayer:addChild(self.tv)
	end

	return self.bgLayer
end

function returnReportDialog:initTopContent(_topBg)
	local _lbFontSize=20 --字体大小
	--岛屿图标
	local islandShowSize=150 --图标显示大小
	local islandSpPosX=35+islandShowSize/2
	local rebelData=self.report.rebel
	local islandSp=G_getIslandIcon(self.report.islandType,rebelData.rebelLv,rebelData.rebelID)
	if islandSp then
		islandSp:setPosition(islandSpPosX, _topBg:getContentSize().height/2+20)
		islandSp:setScale(islandShowSize/islandSp:getContentSize().width)
		_topBg:addChild(islandSp)

		--侦察时间
		local timeLb=GetTTFLabel(emailVoApi:getTimeStr(self.report.time),_lbFontSize)
		timeLb:setAnchorPoint(ccp(0.5,1))
		timeLb:setPosition(islandSpPosX,islandSp:getPositionY()-islandShowSize/2)
		timeLb:setColor(G_ColorYellowPro)
		_topBg:addChild(timeLb)

		--图标
		local iconName="emailNewUI_return1.png"
		if self.report.type==4 then --采集报告
			iconName="emailNewUI_gather1.png"
		end
		local typeIcon=CCSprite:createWithSpriteFrameName(iconName)
		typeIcon:setAnchorPoint(ccp(1,0.5))
		typeIcon:setPosition(timeLb:getPositionX()-timeLb:getContentSize().width/2,timeLb:getPositionY()-timeLb:getContentSize().height/2)
		typeIcon:setScale(0.9)
		_topBg:addChild(typeIcon)
	end

	local content=reportVoApi:getReportContent(self.report)
	if content and content[1] then
		local _lbSpaceY=10 --label之间的行间距
		local strSize=SizeOfTable(content)
		local lb=GetTTFLabel(content[1][1],_lbFontSize)
		local _lbTotalHeight=strSize*lb:getContentSize().height+(strSize-1)*_lbSpaceY
		local _posY=_topBg:getContentSize().height-(_topBg:getContentSize().height-_lbTotalHeight)/2
		_posY=_posY-lb:getContentSize().height/2
		for k,v in pairs(content) do
			local _str,_color
			if type(v)=="table" then
				_str=v[1]
				_color=v[2]
			else
				_str=v
			end
			if _str then
				local label=GetTTFLabel(_str,_lbFontSize)
				label:setAnchorPoint(ccp(0,0.5))
				label:setPosition(islandSpPosX+islandShowSize/2+20,_posY)
				if _color then
					label:setColor(_color)
				end
				_topBg:addChild(label)
				if k==2 then --坐标
					local menu,menuItem,posLb=G_createReportPositionLabel(ccp(self.report.place.x,self.report.place.y),_lbFontSize)
					menuItem:setAnchorPoint(ccp(0,0.5))
					menu:setAnchorPoint(ccp(0,0.5))
					menu:setPosition(label:getPositionX()+label:getContentSize().width,label:getPositionY())
					_topBg:addChild(menu)
				end
				_posY=label:getPositionY()-label:getContentSize().height-_lbSpaceY
			end
		end
	end
end

--侦查报告的处理
function returnReportDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if self.report.type==3 then --返回战报
			do return end
		elseif self.report.type==4 or self.report.type==7 or self.report.type==8 or self.report.type==9 then --4.采集报告/7.进攻军团城市返回/8.驻防军团城市返回报告/9.进攻方击飞奖励报告/10.被击飞玩家击飞报告
			return 1
		end
	elseif fn=="tableCellSizeForIndex" then
		if self.report.type==3 then --返回战报
			do return end
		end
		return CCSizeMake(self.tvWidth,self:getReportCellHeight(idx))
	elseif fn=="tableCellAtIndex" then
		if self.report.type==3 then --返回战报
			do return end
		end
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellWidth,cellHeight=self.tvWidth,self.cellHeightTb[idx+1]

        local _resourceData=self.report.resource
        local titleStr=getlocal("resource_gather_pro")
        if self.report.type==7 then --进攻军团城市返回
        	titleStr=getlocal("fight_content_fight_award")
        	_resourceData=G_getReportResource(self.report)
        elseif self.report.type==8 then --驻防军团城市返回报告
        	titleStr=getlocal("def_content_target_reward")
        	_resourceData=G_getReportResource(self.report)
    	elseif self.report.type==9 then --进攻方击飞玩家奖励报告
    		titleStr=getlocal("hitfly_email_title1")
        	_resourceData=G_getReportResource(self.report)
        end
        G_reportResourceLayout(cell,cellWidth,cellHeight,_resourceData,titleStr,self.layerNum)

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

--侦查报告每个显示元素的高度
function returnReportDialog:getReportCellHeight(idx)
	if self.cellHeightTb==nil then
		self.cellHeightTb={}
	end
	if self.cellHeightTb[idx+1]==nil then
		local height=0
		--4.采集报告/7.进攻军团城市返回/8.驻防军团城市返回报告
		if self.report.type==4 or self.report.type==7 or self.report.type==8 or self.report.type==9 then
			local _resourceData=self.report.resource
			if self.report.type==7 or self.report.type==8 or self.report.type==9 then
				_resourceData=G_getReportResource(self.report)
			end
			height=G_reportResourceCellHeight(_resourceData)
		end
		self.cellHeightTb[idx+1]=height
	end
	return self.cellHeightTb[idx+1]
end

function returnReportDialog:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.report=nil
	self.showType=nil
	self.cellHeightTb=nil
	self.layerNum=nil
	self.tvWidth=nil
	self.tvHeight=nil
	self.tv=nil
	self.isMoved=nil
end

return returnReportDialog