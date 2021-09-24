allianceHelpTab1={}

function allianceHelpTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	-- self.cellHeight1=320
	-- self.cellHeight2=200
	self.cellHeight=120
	self.curIndex=1
	self.noRecordLb=nil

	return nc
end

function allianceHelpTab1:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initTableView()
	return self.bgLayer
end

function allianceHelpTab1:initTableView()

	local function touch( ... )
		-- body
	end

	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-160-20-100))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160-20))
    self.bgLayer:addChild(backSprie)

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-160-20-100-10),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(20,105))
	self.tv:setMaxDisToBottomOrTop(120)
	self.bgLayer:addChild(self.tv)

	self.noRecordLb = GetTTFLabelWrap(getlocal("alliance_help_no_msg"),30,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer:addChild(self.noRecordLb,1)
    self.noRecordLb:setColor(G_ColorGray)

	local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
	if num and num>0 then
		self.noRecordLb:setVisible(false)
	else
		self.noRecordLb:setVisible(true)
	end

	local function helpAllHandler(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local list=allianceHelpVoApi:getList(self.curIndex)
        if list and SizeOfTable(list)>0 then
	        local selfAlliance=allianceVoApi:getSelfAlliance()
	        if selfAlliance then
	        	local aid=selfAlliance.aid
	        	local httpUrl="http://"..base.serverIp.."/tank-server/public/index.php/api/alliancehelp/help"
				local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&aid="..aid
				-- print(httpUrl)
	   --          print(reqStr)
	            -- HttpRequestHelper:sendAsynHttpRequest(httpUrl.."?"..reqStr,"")
	            G_sendAsynHttpRequestNoResponse(httpUrl.."?"..reqStr)
	   --          local retStr=G_sendHttpRequest(httpUrl.."?"..reqStr,"")
	   --          print(retStr)
				-- if(retStr~="")then
				-- 	local retData=G_Json.decode(retStr)
				-- 	if (retData["ret"]==0 or retData["ret"]=="0") and retData.data then
						allianceHelpVoApi:clearList(self.curIndex)
						allianceHelpVoApi:setHasMore(false)
						self:refresh()
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_help_help_all_success"),30)
						local selfAlliance=allianceVoApi:getSelfAlliance()
	                    if selfAlliance and selfAlliance.aid then
	                        local aid=selfAlliance.aid
	                        local params={uid=playerVoApi:getUid()}
	                        chatVoApi:sendUpdateMessage(31,params,aid+1)
	                    end
				-- 	end
				-- end
	        end
	    else
	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_help_no_msg"),30)
	    end
	end
	local scale=0.8
	self.helpAllBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",helpAllHandler,nil,getlocal("alliance_help_all"),30,11)
	self.helpAllBtn:setScale(scale)
	local rewardMenu=CCMenu:createWithItem(self.helpAllBtn)
	rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,55))
	rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(rewardMenu)
end

function allianceHelpTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
		local hasMore=allianceHelpVoApi:getHasMore()
		if hasMore==true then
			num=num+1
		end
		return num
	elseif fn=="tableCellSizeForIndex" then
		local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
		local hasMore=allianceHelpVoApi:getHasMore()
		if hasMore==true and idx==num then
			tmpSize = CCSizeMake(G_VisibleSizeWidth-40,80)
		else
			tmpSize = CCSizeMake(G_VisibleSizeWidth-40,self.cellHeight)
		end
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=G_VisibleSizeWidth-40
		local cellHeight=self.cellHeight
		local bgWidth=cellWidth-10
		local bgHeight=cellHeight-5

		local hasMore=allianceHelpVoApi:getHasMore()
		local list=allianceHelpVoApi:getList(self.curIndex)
	    local num=SizeOfTable(list)
	    local capInSetNew=CCRect(20, 20, 10, 10)
	    local backSprie
	    if hasMore and idx==num then
			local function cellClick(hd,fn,idx)
				self:cellClick(idx)
			end
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSetNew,cellClick)
			backSprie:setContentSize(CCSizeMake(cellWidth, 75))
			backSprie:ignoreAnchorPointForPosition(false)
			backSprie:setAnchorPoint(ccp(0,0))
			backSprie:setIsSallow(false)
			backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
			backSprie:setTag(idx)
			cell:addChild(backSprie,1)

			local moreLabel=GetTTFLabel(getlocal("showMore"),30)
			moreLabel:setPosition(getCenterPoint(backSprie))
			backSprie:addChild(moreLabel,2)

			do 
				return cell 
			end
	    end
		local capInSet = CCRect(20, 20, 10, 10)
		local function touch()
		end
		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
        backSprie:setContentSize(CCSizeMake(bgWidth,bgHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(ccp(cellWidth/2,cellHeight-5))
		backSprie:setOpacity(0)
		cell:addChild(backSprie)
		
		local hvo=list[idx+1]
		local id=hvo.id
		local name=hvo.name--"name"..(idx+1)
		local pic=hvo.pic--playerVoApi:getPic()
		local personPhotoName=playerVoApi:getPersonPhotoName(pic)
		local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName)
        playerPic:setPosition(ccp(50,bgHeight/2))
		backSprie:addChild(playerPic,1)

		local scale=0.9
		local level=hvo.level
		local hPoint=hvo.num or 0
		local maxPoint=hvo.maxNum or 0
		local targetName=""
		local hType=hvo.hType
		if hType=="techs" then
			local tid=hvo.tid
			if tid then
				tid=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
				if techCfg[tid] and techCfg[tid].name then
					targetName=getlocal(techCfg[tid].name)
				end
			end
		else
			local bType=hvo.bType
			if bType then
				bType=(tonumber(bType) or tonumber(RemoveFirstChar(bType)))
				if buildingCfg[bType] and buildingCfg[bType].buildName then
					targetName=getlocal(buildingCfg[bType].buildName)
				end
			end
		end

		local per = hPoint/maxPoint*100
		local percentStr = hPoint.."/"..maxPoint
		AddProgramTimer(backSprie,ccp(100+352*scale/2,28),101,201,percentStr,"skillBg.png","skillBar.png",301)
	    local timerSpriteLv = backSprie:getChildByTag(101)
	    -- print("timerSpriteLv:getContentSize().width",timerSpriteLv:getContentSize().width)
		timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
		timerSpriteLv:setPercentage(per)
		timerSpriteLv:setScaleX(scale)
		local bg = backSprie:getChildByTag(301)
		bg:setScaleX(scale)
		local lb = timerSpriteLv:getChildByTag(201)
		lb:setScaleX(1/scale)

		local function nilFunc( ... )
			-- body
		end
		local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
	    titleSpire:setContentSize(CCSizeMake(bgWidth-300,32))
	    titleSpire:setAnchorPoint(ccp(0,0.5))
	    backSprie:addChild(titleSpire)
	    titleSpire:setPosition(ccp(100,backSprie:getContentSize().height-20))


		local nameLb=GetTTFLabel(name,22,true)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(15,titleSpire:getContentSize().height/2))
		titleSpire:addChild(nameLb,1)
		nameLb:setColor(G_ColorYellowPro)

		local desc=getlocal("alliance_help_desc",{targetName,level})
		local descLb=GetTTFLabelWrap(desc,22,CCSizeMake(cellWidth-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(ccp(100,bgHeight/2+5))
		backSprie:addChild(descLb,1)

		local function helpHandler(tag,object)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)

		        if id then
		        	local function helpCallback(fn,data)
						local ret,sData=base:checkServerData(data)
						if ret==true then
							allianceHelpVoApi:removeHelpData(self.curIndex,id)
			        		self:refresh(true)
			        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_help_help_success"),30)
			        		local selfAlliance=allianceVoApi:getSelfAlliance()
		                    if selfAlliance and selfAlliance.aid then
		                        local aid=selfAlliance.aid
		                        local params={uid=playerVoApi:getUid(),id=id}
		                        chatVoApi:sendUpdateMessage(31,params,aid+1)
		                    end
			        	elseif sData.ret==-8200 or sData.ret==-8201 or sData.ret==-8202 then
			        		local function refCallback()
			        			self:refresh()
			        		end
			        		allianceHelpVoApi:formatData(self.curIndex,refCallback)
			        	end
		        	end
			        socketHelper:allianceHelp(id,helpCallback)
			    end
		    end
		end
		local scale=0.6
		local helpItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",helpHandler,nil,getlocal("help"),30,11)
		helpItem:setScale(scale)
		local helpMenu=CCMenu:createWithItem(helpItem)
		helpMenu:setPosition(ccp(cellWidth-80,bgHeight/2))
		helpMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(helpMenu,2)

		local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
        lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40-10, 2))
        lineSp:setPosition((G_VisibleSizeWidth-40)/2,0)
        cell:addChild(lineSp, 2)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end


function allianceHelpTab1:cellClick(idx)
	if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		local hasMore=allianceHelpVoApi:getHasMore()
		local list=allianceHelpVoApi:getList(self.curIndex)
	    local num=SizeOfTable(list)
		local function pageCallback()
			local nextHasMore=allianceHelpVoApi:getHasMore()
			local list1=allianceHelpVoApi:getList(self.curIndex)
			local nowNum=SizeOfTable(list1)
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			if nextHasMore then
				recordPoint.y=(num-nowNum)*self.cellHeight+recordPoint.y
			else
				recordPoint.y=(num-nowNum)*self.cellHeight+recordPoint.y+80
			end
			self.tv:recoverToRecordPoint(recordPoint)
		end
		allianceHelpVoApi:formatData(self.curIndex,pageCallback,true)
	end
end

function allianceHelpTab1:refresh(isTvMove)
	if self.noRecordLb then
		local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
		if num and num>0 then
			self.noRecordLb:setVisible(false)
		else
			self.noRecordLb:setVisible(true)
		end
	end
	if self and self.tv then
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		if isTvMove==true then
			local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
			if num>5 then
				recordPoint.y=recordPoint.y+self.cellHeight
				self.tv:recoverToRecordPoint(recordPoint)
			end
		end
	end
end

function allianceHelpTab1:tick()
	if allianceHelpVoApi:getFlag(self.curIndex)==0 then
		self:refresh()
		allianceHelpVoApi:setFlag(self.curIndex,1)
	end
end

function allianceHelpTab1:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
	self.layerNum=nil
	-- self.cellHeight1=nil
	-- self.cellHeight2=nil
	self.cellHeight=nil
	self.curIndex=nil
	self.noRecordLb=nil
end