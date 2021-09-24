worldWarReportDialog=commonDialog:new()

function worldWarReportDialog:new(dType,bType)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
	self.normalHeight=120
	self.writeBtn=nil
	self.deleteBtn=nil
	self.unreadLabel=nil
	self.totalLabel=nil
	self.tvHeight=nil
	self.canClick=false
	self.mailClick=0
	self.noEmailLabel=nil
	
    self.bgLayer=nil
    self.layerNum=nil
    self.dType=dType
    self.bType=bType
    self.reportNum=0
	
    return nc
end

function worldWarReportDialog:updateReportNum()
	local num=worldWarVoApi:getMyReportNum(self.dType) or 0
	if self.reportNum~=num then
		self.reportNum=num
	end
end
function worldWarReportDialog:getReportList()
	local list=worldWarVoApi:getMyReportList(self.dType)
	if list==nil then
		return {}
	else
		return list
	end
end

--设置对话框里的tableView
function worldWarReportDialog:initTableView()
	self.tvWidth=G_VisibleSizeWidth-70
	self.tvHeight=self.bgLayer:getContentSize().height-215+80

	self.panelLineBg:setContentSize(CCSizeMake(self.tvWidth+40,G_VisibleSize.height-110))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))


	local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function click(hd,fn,idx)
	end
	self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,click)
	self.tvBg:setContentSize(CCSizeMake(self.tvWidth+20,self.tvHeight+10))
	self.tvBg:ignoreAnchorPointForPosition(false)
	self.tvBg:setAnchorPoint(ccp(0.5,0))
	--self.tvBg:setIsSallow(false)
	--self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
	self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.bgLayer:addChild(self.tvBg)
	
	self.noEmailLabel=GetTTFLabel(getlocal("alliance_war_no_record"),30)
	self.noEmailLabel:setPosition(getCenterPoint(self.tvBg))
	self.noEmailLabel:setColor(G_ColorGray)
	self.tvBg:addChild(self.noEmailLabel,2)
	self.noEmailLabel:setVisible(false)

	-- local flag=arenaReportVoApi:getFlag()
	-- -- local listNum=self.reportNum
	-- -- local totalNum=arenaReportVoApi:getTotalNum()
	-- -- if totalNum>listNum then
	-- if flag==-1 then
	-- 	local function militaryGetlogCallback(fn,data)
 --            local ret,sData=base:checkServerData(data)
 --            if ret==true then
 --            	if sData.data and sData.data.userarenalog then
	--         		arenaReportVoApi:addReport(sData.data.userarenalog)
	-- 	        	self:initTv()
	-- 	            if self.reportNum==0 and self.noEmailLabel then
	-- 					self.noEmailLabel:setVisible(true)
	-- 				end
	-- 				arenaReportVoApi:setFlag(1)
	-- 			end
	--         end
	--     end
	--     local isPage=nil
	--     -- local minrid,maxrid=arenaReportVoApi:getMinAndMaxRid()
	--     -- if minrid>0 or maxrid>0 then
	--     -- 	isPage=true
	--     -- end
	--     local minrid,maxrid=0,0
	--     socketHelper:militaryGetlog(minrid,maxrid,isPage,militaryGetlogCallback)
	-- else
	-- 	self:initTv()
	-- 	if self.reportNum==0 and self.noEmailLabel then
	-- 		self.noEmailLabel:setVisible(true)
	-- 	end
	-- end

	
	if self.dType==1 then
		local function callback(isSuccess)
			self:updateReportNum()
			self:initTv()
			if self.reportNum==0 and self.noEmailLabel then
				self.noEmailLabel:setVisible(true)
			end
		end
		worldWarVoApi:formatMyReportList(callback)
	else
		self:updateReportNum()
		self:initTv()
		if self.reportNum==0 and self.noEmailLabel then
			self.noEmailLabel:setVisible(true)
		end
	end
end

function worldWarReportDialog:initTv()
	local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp((G_VisibleSizeWidth-self.tvWidth)/2,35))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function worldWarReportDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=self.reportNum
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.tvWidth,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		
		local list=self:getReportList()
		-- local hasMore=worldWarVoApi:getReportHasMore()
		-- local num=self.reportNum

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
			return self:cellClick(idx)
		end
		local backSprie
		-- if hasMore and idx==num then
		-- 	backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
		-- 	backSprie:setContentSize(CCSizeMake(self.tvWidth,self.normalHeight-2))
		-- 	backSprie:ignoreAnchorPointForPosition(false);
		-- 	backSprie:setAnchorPoint(ccp(0,0));
		-- 	backSprie:setTag(idx)
		-- 	backSprie:setIsSallow(false)
		-- 	backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		-- 	backSprie:setPosition(ccp(0,0));
		-- 	-- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
		-- 	cell:addChild(backSprie,1)
			
		-- 	local moreLabel=GetTTFLabel(getlocal("showMoreTen"),30)
		-- 	moreLabel:setPosition(getCenterPoint(backSprie))
		-- 	backSprie:addChild(moreLabel,2)
			
		-- 	return cell
		-- end

		local reportVo=list[idx+1] or {}
		local battleVo=reportVo.battleData or {}
		local selfID=playerVoApi:getUid().."-"..base.curZoneID
		local isVictory=0
		local id1=battleVo.id1
		local id2=battleVo.id2
		local player1=battleVo.player1
		local player2=battleVo.player2
		local roundID=battleVo.roundID
		local battleID=battleVo.battleID
		if battleVo.winnerID==selfID then
			isVictory=1
		end
		local isEmpty=false
		if id1==nil or id2==nil or id1=="" or id2=="" then
			isEmpty=true
		end

		local isRead=reportVo.isRead
		local point=reportVo.point or 0
		local rankPoint=reportVo.rankPoint or 0
		local roundIndex=reportVo.roundIndex or 0
		local serverName=""
		local enemyName=""
		if selfID==id1 then
			-- if player1 then
			-- 	point=player1.point or 0
			-- 	rankPoint=player1.rankPoint or 0
			-- end
			if player2 then
				enemyName=player2.name or ""
				serverName=player2.serverName or ""
			end
		else
			-- if player2 then
			-- 	point=player2.point or 0
			-- 	rankPoint=player2.rankPoint or 0
			-- end
			if player1 then
				enemyName=player1.name or ""
				serverName=player1.serverName or ""
			end
		end
	
		if isRead==1 then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgRead.png",capInSet,cellClick)
		else
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgNoRead.png",capInSet,cellClick)
		end
		backSprie:setContentSize(CCSizeMake(self.tvWidth,self.normalHeight-2))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setTag(idx)
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(0,0));
		-- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
		cell:addChild(backSprie,1)

		local bgWidth=backSprie:getContentSize().width
		local bgHeight=backSprie:getContentSize().height
		
		local emailIcon
		if isRead==1 then
			emailIcon=CCSprite:createWithSpriteFrameName("letterIconRead.png")
		else
			emailIcon=CCSprite:createWithSpriteFrameName("letterIconNoRead.png")
		end
		emailIcon:setPosition(ccp(50,bgHeight/2))
		backSprie:addChild(emailIcon,2)

		



		local titleStr=""
		if self.dType==1 then
			titleStr=getlocal("world_war_point_report",{roundIndex})
		else
			titleStr=worldWarVoApi:getRoundTitleStr(roundID,battleID,self.bType)
		end
		-- titleStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local titleLabel=GetTTFLabelWrap(titleStr,22,CCSizeMake(bgWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		titleLabel:setAnchorPoint(ccp(0,0.5))
		cell:addChild(titleLabel,2)
		titleLabel:setPosition(100,bgHeight-25)
		titleLabel:setColor(G_ColorYellowPro)

		local reportPointLb
		if self.dType==1 then
			local reportPointStr=getlocal("world_war_report_point")..rankPoint
			local color=G_ColorRed
			if rankPoint>=0 then
				reportPointStr=getlocal("world_war_report_point").."+"..rankPoint
				color=G_ColorGreen
				if rankPoint==0 then
					color=G_ColorWhite
				end
			end
			reportPointLb=GetTTFLabel(reportPointStr,20)
			reportPointLb:setAnchorPoint(ccp(0,0.5))
			cell:addChild(reportPointLb,2)
			reportPointLb:setPosition(100,bgHeight/2)
			reportPointLb:setColor(color)
		end

		local shopPointStr=getlocal("world_war_shop_point").."+"..point
		local shopPointLb=GetTTFLabel(shopPointStr,20)
		shopPointLb:setAnchorPoint(ccp(0,0.5))
		cell:addChild(shopPointLb,2)
		if reportPointLb then
			shopPointLb:setPosition(100+reportPointLb:getContentSize().width+20,bgHeight/2)
		else
			shopPointLb:setPosition(100,bgHeight/2)
		end
		if point>0 then
			shopPointLb:setColor(G_ColorGreen)
		end

		local descStr=""
		local dStr1=getlocal("world_war_report_desc1",{serverName,enemyName})
		if isEmpty==true then
			dStr1=getlocal("world_war_battle_empty")
		end
		descStr=getlocal("world_war_report_desc",{dStr1})
		local descLabel=GetTTFLabelWrap(descStr,20,CCSizeMake(bgWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLabel:setAnchorPoint(ccp(0,0.5))
		cell:addChild(descLabel,2)
		descLabel:setPosition(100,25)

		local resultSp
		local scale=0.8
		if isVictory==1 then
			resultSp=CCSprite:createWithSpriteFrameName("winnerMedal.png")
		else
			resultSp=CCSprite:createWithSpriteFrameName("loserMedal.png")
		end
		resultSp:setScale(scale)
    	resultSp:setPosition(ccp(bgWidth-resultSp:getContentSize().width/2*scale-10,bgHeight/2+5))
    	cell:addChild(resultSp,2)


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
function worldWarReportDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		if battleScene.isBattleing==true then
			do return end
		end
        PlayEffect(audioCfg.mouseClick)

		-- local num=self.reportNum
		-- local hasMore=worldWarVoApi:getReportHasMore()
		-- local nextHasMore=false
		-- if hasMore and tostring(idx)==tostring(num) then
		-- 	local function addReportCallback()
		-- 		self.canClick=true
		-- 		local newNum=self.reportNum
		-- 		local diffNum=newNum-num
		-- 		local nextHasMore=worldWarVoApi:getReportHasMore()
		-- 		if nextHasMore then
		-- 			diffNum=diffNum+1
		-- 		end
		-- 		local recordPoint = self.tv:getRecordPoint()
		-- 		self:refresh()
		-- 		recordPoint.y=-(diffNum-1)*self.normalHeight+recordPoint.y
		-- 		self.tv:recoverToRecordPoint(recordPoint)
		-- 		self.canClick=false
		-- 	end
		-- 	if self.canClick==false then
	 --    		worldWarVoApi:addReport(addReportCallback)
		-- 	end
		-- else
			if self.mailClick==0 then
				self.mailClick=1
				local reportVoTab=self:getReportList()
				local reportVo=reportVoTab[idx+1]
				if reportVo==nil then
					do return end
				end

				-- if reportVo.isRead==0 then
				-- 	local function readCallback(fn,data)
	   --                  -- local ret,sData=base:checkServerData(data)
	   --                  -- if ret==true then
				-- 			worldWarVoApi:setIsRead(reportVo.rid)
				-- 			if self==nil or self.tv==nil then
				-- 				do return end
				-- 			end
				-- 			local recordPoint = self.tv:getRecordPoint()
				-- 			self:refresh()
				-- 			self.tv:recoverToRecordPoint(recordPoint)
				-- 			self:showDetailDialog(reportVo)
				-- 		-- end
				-- 	end
				-- 	-- socketHelper:militaryRead(reportVo.rid,readCallback)
				-- 	readCallback()
				-- else
					self:showDetailDialog(reportVo)
				-- end
			end
		-- end
    end
end

function worldWarReportDialog:showDetailDialog(report)
	if report and report.battleData then
	    local isPointMatch
	    if self.dType==1 then
	    	isPointMatch=true
	    else
	    	isPointMatch=false
	    end
		worldWarVoApi:showBattleDialog(self.bType,report.battleData,isPointMatch,self.layerNum+1,report)
	end
end

function worldWarReportDialog:tick()
	if self.mailClick>0 then
		self.mailClick=0
	end
end

function worldWarReportDialog:refresh()
	if self~=nil then
		self:updateReportNum()
		if self.noEmailLabel then
			if self.reportNum==0 then
				self.noEmailLabel:setVisible(true)
			else
				self.noEmailLabel:setVisible(false)
			end
		end
		if self.tv~=nil then
			self.tv:reloadData()
		end
	end
end

function worldWarReportDialog:dispose()
	self.mailClick=nil
	self.canClick=nil
	self.normalHeight=nil
	self.writeBtn=nil
	self.deleteBtn=nil
	self.unreadLabel=nil
	self.totalLabel=nil
	self.tvHeight=nil
	self.noEmailLabel=nil
	
    self.bgLayer=nil
    self.layerNum=nil
    self.dType=nil
    self.bType=nil
    self.reportNum=0
end






