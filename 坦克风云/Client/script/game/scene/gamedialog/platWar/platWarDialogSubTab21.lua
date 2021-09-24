platWarDialogSubTab21={}
function platWarDialogSubTab21:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellWidth=G_VisibleSizeWidth-60
	self.cellHeight=400
	self.status=nil
	return nc
end

function platWarDialogSubTab21:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initLayer()
	self.status=platWarVoApi:checkStatus()
	local function onUpdateListener()
        if self and self.refresh then
            self:refresh()
        end
	end
	self.onUpdateListener=onUpdateListener
	if(eventDispatcher:hasEventHandler("platWar.updateDonateTroops",onUpdateListener)==false)then
		eventDispatcher:addEventListener("platWar.updateDonateTroops",onUpdateListener)
	end
	return self.bgLayer
end

function platWarDialogSubTab21:initLayer()
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,G_VisibleSizeHeight-255),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,40)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
	return self.bgLayer
end

function platWarDialogSubTab21:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(platWarCfg.troopsDonate)
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.cellWidth,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local function nilFunc()
		end
		local headSp=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20,20,10,10),nilFunc)
		headSp:setContentSize(CCSizeMake(self.cellWidth,50))
		headSp:setAnchorPoint(ccp(0,1))
		headSp:setPosition(ccp(0,self.cellHeight-5))
		cell:addChild(headSp)
		
		local donateNum=platWarVoApi:getDonateTroopsNumByIndex(idx+1)
		local cfg=platWarCfg.troopsDonate[idx+1]
		local maxDonateNum=cfg.donateNum
		local tankTb={}
		if cfg and cfg.troops then
			tankTb=cfg.troops
		end
		

		local titleStr=getlocal("plat_war_donate_troops_"..(idx+1))..getlocal("plat_war_donate_troops_num",{donateNum})
        if donateNum>=maxDonateNum then
			titleStr=getlocal("plat_war_donate_troops_"..(idx+1))..getlocal("plat_war_donate_full")
			donateNum=maxDonateNum
		end
		local titleLb=GetTTFLabel(titleStr,25)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(ccp(10,headSp:getContentSize().height/2))
		headSp:addChild(titleLb)

		local bgHeight=self.cellHeight-headSp:getContentSize().height-10
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function () end)
		background:setContentSize(CCSizeMake(self.cellWidth,bgHeight))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(0,0))
		cell:addChild(background)

		-- local tankItemTb={o={a10007=10,a10017=10,a10027=10,a10037=10,a10113=10}}
		-- local itemTb=FormatItem(tankItemTb)
		-- local itemNum=SizeOfTable(itemTb)
		local wSpace=185
		local hSpece=115
		local iconSize=100
		for k,v in pairs(tankTb) do
			local px,py=0,0
			-- if itemNum%2==0 then
			-- 	px=self.cellWidth/2-(iconSize+wSpace)*((itemNum-1)/2)+(iconSize+wSpace)*(k-1)
			-- else
			-- 	px=self.cellWidth/2-(iconSize+wSpace)*math.floor(itemNum/2)+(iconSize+wSpace)*(k-1)
			-- end
			px=iconSize/2+20+wSpace*((k-1)%3)
			py=bgHeight-iconSize/2-20-hSpece*(math.ceil(k/3)-1)
			local tid=v[1]
			local num=v[2]
			local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
			local donateTroops=platWarVoApi:getDonateTroopsByIndex(idx+1)
			local needNum=num
	        for i,j in pairs(donateTroops) do
				if j and j[1] and j[1]==id and j[2] then
					needNum=((donateNum+1)*num-j[2])
					if needNum<0 then
						needNum=0
					end
				end
	        end
			-- local item=v
			-- local icon=G_getItemIcon(item,iconSize)
			local function showTankInfo()
	            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
	                if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
	                else
	                    base.setWaitTime=G_getCurDeviceMillTime()
	                end
	                PlayEffect(audioCfg.mouseClick)

	                tankInfoDialog:create(nil,id,self.layerNum+1)
	            end
			end
			-- local icon=LuaCCSprite:createWithSpriteFrameName(tankCfg[id].icon,showTankInfo)
			local icon=G_getETankIcon(1,id,showTankInfo)
			icon:setScale(iconSize/icon:getContentSize().width)
			icon:setPosition(ccp(px,py))
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			cell:addChild(icon)
			local needStr=getlocal("plat_war_donate_need_num")
			-- needStr="aaaaaaawwwwwwwwwllllllll"
			local needLb=GetTTFLabelWrap(needStr,22,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			needLb:setAnchorPoint(ccp(0,0.5))
			-- needLb:setPosition(px,py-iconSize/2-25)
			needLb:setPosition(ccp(px+iconSize/2+5,py+30))
			cell:addChild(needLb)
			-- local numLb
			-- if(item.num>1)then
				local numLb=GetTTFLabel("x"..FormatNumber(needNum),22)
				numLb:setAnchorPoint(ccp(0,0.5))
				numLb:setPosition(ccp(px+iconSize/2+5,py-30))
				cell:addChild(numLb)
			-- end
		end

		local function onClickDonate(tag,object)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                if platWarVoApi:checkStatus()>=30 then
		            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_end"),30)
		            do return end
		        end

		        if playerVoApi:getPlayerLevel()<platWarCfg.donateLevel then
		            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_cannot_donate_tip",{platWarCfg.donateLevel}),30)
		            do return end
		        end

                local num=platWarVoApi:getDonateTroopsNumByIndex(idx+1)
                if platWarCfg.troopsDonate and platWarCfg.troopsDonate[idx+1] and platWarCfg.troopsDonate[idx+1].donateNum then
	                if num>=platWarCfg.troopsDonate[idx+1].donateNum then
	                	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_donate_max"),30)
	                	do return end
	                end
	            end

		        local function callBack()
		            self:refresh()
		        end
		        local cfg=G_clone(platWarCfg.troopsDonate)
		        local rate=platWarVoApi:getPlatRate()
		        local troopsData=cfg[idx+1].troops
		        
		        local donateNum=platWarVoApi:getDonateTroopsNumByIndex(idx+1)
		        local donateTroops=platWarVoApi:getDonateTroopsByIndex(idx+1)
		        for k,v in pairs(troopsData) do
	        		for i,j in pairs(donateTroops) do
	        			if v and v[1] and j and j[1] then
	        				local id1=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
	        				local id2=(tonumber(j[1]) or tonumber(RemoveFirstChar(j[1])))
	        				if id1==id2 then
	        					local maxNum=v[2]
	        					v[2]=(donateNum+1)*v[2]-j[2]
		        				if v[2]<0 then
		        					v[2]=0
		        				end
		        				if v[2]>maxNum then
		        					v[2]=maxNum
		        				end
		        			end
	        			end
	        		end
		        end
		        for k,v in pairs(troopsData) do
		        	if v and v[1] and v[2] then
		        		v[2]=math.ceil(v[2]/rate)
		        	end
		        end
		        local tankData={{},{}}
		        local troopsLimit={}
		        for k,v in pairs(troopsData) do
		        	local tid=v[1]
		        	local num=tonumber(v[2])
		        	local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
		        	if num and num>0 then
		        		troopsLimit[id]=num
			        	local hasNum=tankVoApi:getTankCountByItemId(id)
			        	if hasNum>0 then
			        		table.insert(tankData[1],{key=id})
				        	tankData[2][id]={hasNum}
			        	end
			        end
		        end
		        platWarVoApi:showSelectTankDialog(self.layerNum,callBack,tankData,troopsLimit,idx+1)
            end
		end
		local donateItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickDonate,idx+1,getlocal("plat_war_donate_troops_btn"),25)
		-- donateItem:setScale(0.8)
		local donateMenu=CCMenu:createWithItem(donateItem)
		donateMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		donateMenu:setPosition(ccp(self.cellWidth/2,50))
		cell:addChild(donateMenu)
		if platWarVoApi:checkStatus()>=30 then
			donateItem:setEnabled(false)
		else
			local num=platWarVoApi:getDonateTroopsNumByIndex(idx+1)
			if platWarCfg.troopsDonate and platWarCfg.troopsDonate[idx+1] and platWarCfg.troopsDonate[idx+1].donateNum then
	            if num>=platWarCfg.troopsDonate[idx+1].donateNum then
					donateItem:setEnabled(false)
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
function platWarDialogSubTab21:refresh()
	if self and self.tv then
    	local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
    end
end
function platWarDialogSubTab21:tick()
	local status=platWarVoApi:checkStatus()
	if self and self.status~=status and status>=30 then
        self:refresh()
    end
end

function platWarDialogSubTab21:dispose()
	eventDispatcher:removeEventListener("platWar.updateDonateTroops",self.onUpdateListener)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
	self.bgLayer=nil
end