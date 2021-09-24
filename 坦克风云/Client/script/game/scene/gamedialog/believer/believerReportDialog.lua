local believerReportDialog=commonDialog:new() 

function believerReportDialog:new(parent)
    local nc={
    	noReportLb=nil,
    	reportList=nil,
    	reportNum=nil,
    	parent=parent,
	}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

-- 初始化战报列表
function believerReportDialog:initReportList()
	self.reportList=believerVoApi:getBattleReportList()
	self.reportNum=SizeOfTable(self.reportList)
end

function believerReportDialog:doUserHandler()
	self.panelLineBg:setVisible(false)
	if self.panelTopLine then
		self.panelTopLine:setVisible(true)
    	self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)
	end

	self:initReportList()
	self.noReportLb=GetTTFLabel(getlocal("alliance_war_no_record"),30)
	self.noReportLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.noReportLb:setColor(G_ColorGray)
	self.bgLayer:addChild(self.noReportLb,2)
	self.noReportLb:setVisible(false)
	if self.reportNum<=0 then
		self.noReportLb:setVisible(true)
	end

	local fontSize=22
    if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
        fontSize=20
    end
	local tipLb=GetTTFLabelWrap(getlocal("believer_record_only_save"),fontSize,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	tipLb:setAnchorPoint(ccp(0.5,0.5))
	tipLb:setPosition(G_VisibleSizeWidth/2,25+tipLb:getContentSize().height/2)
	tipLb:setColor(G_ColorRed)
	self.bgLayer:addChild(tipLb,2)
end

function believerReportDialog:initTableView()
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	local function callBack(...)
    	return self:eventHandler(...)
    end
    self.tvWidth,self.tvHeight,self.cellHeight=G_VisibleSizeWidth-40,G_VisibleSizeHeight-95-60,125
    local hd=LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,60)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv,2)
end

function believerReportDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.reportNum
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.tvWidth,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local reportVo=self.reportList[idx+1]
		if reportVo then
			local itemHeight=self.cellHeight-6
			-- 段位是否变化
			local changeFlag=false
			if (reportVo.gradeUp and reportVo.gradeUp>0) and (reportVo.queueUp and reportVo.queueUp>0) then
				changeFlag=true
			end
			
			local fontSize=22
		    if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
		        fontSize=20
		    end

			local function cellClick(object,name,tag)
				self:cellClick(reportVo)
			end
			local itemBg
            if reportVo.isRead==1 then
                itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newReadBg.png",CCRect(5,5,1,1),cellClick)
            else
                itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),cellClick)
            end
            itemBg:setContentSize(CCSizeMake(self.tvWidth,itemHeight))
			itemBg:setTag(reportVo.id)
			itemBg:setTouchPriority(-(self.layerNum-1)*20-2)
			itemBg:setPosition(self.tvWidth/2,self.cellHeight/2)
			cell:addChild(itemBg,1)

			local timeLabel=GetTTFLabel(reportVo.timeStr,fontSize)
			timeLabel:setAnchorPoint(ccp(0,0.5))
			timeLabel:setColor(G_ColorYellowPro)
			timeLabel:setPosition(15,itemHeight-10-timeLabel:getContentSize().height/2)
			itemBg:addChild(timeLabel,2)
			
			local challengeStr=getlocal("believer_battle_record_desc",{reportVo.enemyName})
			local challengeLabel=GetTTFLabelWrap(challengeStr,fontSize,CCSizeMake(self.tvWidth-230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			challengeLabel:setAnchorPoint(ccp(0,0.5))
			challengeLabel:setPosition(15,10+challengeLabel:getContentSize().height/2)
			itemBg:addChild(challengeLabel,2)

			if reportVo.score then
				local pointLb=GetTTFLabelWrap(getlocal("serverwar_point").."+"..reportVo.score,fontSize,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				pointLb:setAnchorPoint(ccp(1,0.5))
				pointLb:setPosition(ccp(self.tvWidth-8,timeLabel:getPositionY()))
				pointLb:setColor(G_ColorBlue)
				itemBg:addChild(pointLb,2)
			end
			local victoryStr=getlocal("fight_content_result_win")
			local victoryColor=G_ColorYellowPro
			if reportVo.isVictory<0 then
				victoryStr=getlocal("fight_content_result_defeat")
				victoryColor=G_ColorRed
			end
			local victorySize=30
			if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
				victorySize=25
			end
			--是否获胜
			local victoryLb=GetTTFLabelWrap(victoryStr,victorySize,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			victoryLb:setAnchorPoint(ccp(0.5,0.5))
			victoryLb:setPosition(ccp(self.tvWidth-65,challengeLabel:getPositionY()))
			victoryLb:setColor(victoryColor)
			itemBg:addChild(victoryLb,2)
			--段位提升
			if changeFlag==true then
				--晋级
				local gradeUpLabel=GetTTFLabelWrap(getlocal("believer_seg_change_1"),fontSize,CCSizeMake(self.tvWidth/2-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				gradeUpLabel:setAnchorPoint(ccp(0,0.5))
				gradeUpLabel:setPosition(ccp(self.tvWidth/2,timeLabel:getPositionY()))
				gradeUpLabel:setColor(G_ColorGreen)
				itemBg:addChild(gradeUpLabel,2)
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

--点击了cell或cell上某个按钮
function believerReportDialog:cellClick(reportVo)
    if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local isRead=reportVo.isRead
		local function showDetailHandler(detail)
			if self.tv and isRead==0 then
				self.reportList=believerVoApi:getBattleReportList()
				self.reportNum=SizeOfTable(self.reportList)
		        local recordPoint=self.tv:getRecordPoint()
		        self.tv:reloadData()
		        self.tv:recoverToRecordPoint(recordPoint)
			end
			believerVoApi:showReportDetailDialog(self.layerNum+1,detail)
		end
		if reportVo.detail then --已经读取过战报
			showDetailHandler(reportVo)
		else
			believerVoApi:readReportHttpRequest(reportVo.id,showDetailHandler,reportVo.isRead)
		end
    end
end

function believerReportDialog:tick()
end

function believerReportDialog:dispose()
	self.bgLayer=nil
    self.layerNum=nil
    self.noReportLb=nil
	self.tv=nil
    self.reportList=nil
    self.reportNum=nil
    self.tvWidth=nil
    self.tvHeight=nil
    self.cellHeight=nil
    if self.parent and self.parent.backToMainDialogHandler then
        self.parent:backToMainDialogHandler()
        self.parent=nil
    end
end

return believerReportDialog