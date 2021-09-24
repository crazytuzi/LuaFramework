allianceDialogTab1={

}

function allianceDialogTab1:new(searchName)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.bgLayer=nil;
    self.tableCell1={};
    self.layerNum=nil;
	
	self.rankLabel=nil
	self.nameLabel=nil
	self.numLabel=nil
	self.valueLabel=nil
	self.viewLabel=nil
	self.labelTab={}
	self.cellHeight=70
	self.tvBg=nil
	self.descLabel=nil
	self.searchBtn=nil
	self.resultLabel=nil
	self.noResultLabel=nil

	self.showType=0
	self.viewBtnTab={}
	self.applyTab={}
	self.parentDialog=nil

	self.checkBtn=nil
	self.checkBtnBg=nil
	self.canApplyLb=nil
	self.searchName=searchName

    return nc;

end

function allianceDialogTab1:init(parentDialog,layerNum,isGuide)
	--[[
	self.isGuide=isGuide;
    self.enTime=playerVoApi:getPlayerEnergycd()%1800
    self.enTimeCount=playerVoApi:getPlayerEnergycd()/1800
    if self.enTime==0 and self.enTimeCount>0 then
        self.enTime=1800
        self.enTimeCount=self.enTimeCount-1
    end
	]]
	self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum;
    self:initTableView()
	self:doUserHandler(self.searchName)
    
    return self.bgLayer
end

function allianceDialogTab1:initTableView()
	local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function click(hd,fn,idx)
	end
	self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),click)
	self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-300))
	self.tvBg:ignoreAnchorPointForPosition(false)
	self.tvBg:setAnchorPoint(ccp(0.5,0))
	--self.tvBg:setIsSallow(false)
	--self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
	self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,105))
	self.bgLayer:addChild(self.tvBg)
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSize.height-310),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,110))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

    if self.noResultLabel==nil then
		self.noResultLabel=GetTTFLabel(getlocal("alliance_search_no_result"),25)
		self.noResultLabel:setAnchorPoint(ccp(0.5,0.5))
		self.noResultLabel:setPosition(getCenterPoint(self.tvBg))
		self.tvBg:addChild(self.noResultLabel)
		self.noResultLabel:setVisible(false)
		self.noResultLabel:setColor(G_ColorRed)
	end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceDialogTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
		local hasMore=false
		local num=0

		if self.showType==1 then
			--num=allianceVoApi:getSearchNum()
			num=allianceVoApi:getShowSearchNum()
			hasMore=allianceVoApi:hasMore(1)
		else
			num=allianceVoApi:getShowNum()
			--num=allianceVoApi:getRankOrGoodNum()
			if allianceVoApi:isHasAlliance() then
				num=num+1
			end
			hasMore=allianceVoApi:hasMore(0)
		end
		
		if hasMore then
			num=num+1
		end
		return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(400,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
 		local hasMore=false
		local num=0

		if self.showType==1 then
			--num=allianceVoApi:getSearchNum()
			num=allianceVoApi:getShowSearchNum()
			hasMore=allianceVoApi:hasMore(1)
		else
			--num=allianceVoApi:getRankOrGoodNum()
			num=allianceVoApi:getShowNum()
			if allianceVoApi:isHasAlliance() then
				num=num+1
			end
			hasMore=allianceVoApi:hasMore(0)
		end

 		local cell=CCTableViewCell:new()
 		cell:autorelease()
 		local rect = CCRect(0, 0, 50, 50);
 		local capInSet = CCRect(40, 40, 10, 10);
 		local capInSetNew=CCRect(20, 20, 10, 10)
 		if hasMore and idx==num then
 			local function cellClick(hd,fn,idx)
 				self:cellClick(idx)
 			end
			local backSprie
 			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSetNew,cellClick)
 			backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
 			backSprie:ignoreAnchorPointForPosition(false)
 			backSprie:setAnchorPoint(ccp(0,0))
 			backSprie:setIsSallow(false)
 			backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
 			backSprie:setTag(idx)
 			cell:addChild(backSprie,1)
			
 			local moreLabel=GetTTFLabel(getlocal("showMore"),25)
 			moreLabel:setPosition(getCenterPoint(backSprie))
 			backSprie:addChild(moreLabel,2)
			
 			do return cell end
 		end
		--[[
 		local function cellClick1(hd,fn,idx)
 		end
 		if idx==0 then
 			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
 		elseif idx==1 then
 			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
 		elseif idx==2 then
 			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
 		elseif idx==3 then
 			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
 		else
 			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
 		end
 		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
 		backSprie:ignoreAnchorPointForPosition(false)
 		backSprie:setAnchorPoint(ccp(0,0))
 		backSprie:setIsSallow(false)
 		backSprie:setTouchPriority(-42)
 		cell:addChild(backSprie,1)
		]]
 		local height=self.cellHeight/2+5
 		local widthSpace=50
		
 		--local selfAlliance
 		local allianceVo
		
 		local rankStr=0
 		local nameStr=""
 		local nameStr=0
 		local valueStr=0
 		
 		if self.showType==1 then
 			allianceVo=allianceVoApi:getSearchList()[idx+1]
 		elseif allianceVoApi:isHasAlliance() then
 			if idx==0 then
 				--allianceVo=allianceVoApi:getSelfAlliance()
 				allianceVo=allianceVoApi:getSelfAllianceByList()

 				local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
				--bgSp:setAnchorPoint(ccp(0,0))
				bgSp:setPosition(ccp(310,self.cellHeight/2+2))
				bgSp:setScaleY((self.cellHeight-2)/bgSp:getContentSize().height)
				bgSp:setScaleX(1200/bgSp:getContentSize().width)
				cell:addChild(bgSp)
	 		else
	 			if allianceVoApi:getRankOrGoodList()~=nil then
	 				allianceVo=allianceVoApi:getRankOrGoodList()[idx]
	 			end
	 		end
	 	else
	 		if allianceVoApi:getRankOrGoodList()~=nil then
 				allianceVo=allianceVoApi:getRankOrGoodList()[idx+1]
 			end
	 	end
		
		if allianceVo then
			rankStr=allianceVo.rank or 0
			nameStr=allianceVo.name or ""
			numStr=allianceVo.num or 0
			valueStr=allianceVo.fight or 0
		end

		local rankLabel=GetTTFLabel(rankStr,25)
		rankLabel:setAnchorPoint(ccp(0.5,0.5))
 		rankLabel:setPosition(widthSpace,height)
 		cell:addChild(rankLabel,2)
 		table.insert(self.labelTab,idx,{rankLabel=rankLabel})
		
 		local rankSp
 		if tonumber(rankStr)==1 then
 			rankSp=CCSprite:createWithSpriteFrameName("top1.png")
 		elseif tonumber(rankStr)==2 then
 			rankSp=CCSprite:createWithSpriteFrameName("top2.png")
 		elseif tonumber(rankStr)==3 then
 			rankSp=CCSprite:createWithSpriteFrameName("top3.png")
 		end
 		if rankSp then
			rankSp:setAnchorPoint(ccp(0.5,0.5))
 	      	rankSp:setPosition(ccp(widthSpace,height))
 			cell:addChild(rankSp,3)
 			rankLabel:setVisible(false)
 		end
 		
 		local lbWidth=160
 		local nameLabel=GetTTFLabel(nameStr,25)
 		-- if nameLabel:getContentSize().width>lbWidth then
 		-- 	nameLabel=GetTTFLabelWrap(nameStr,25,CCSize(160,30),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
 		-- 	--nameLabel:setPosition(widthSpace+120,height)
 		-- 	print("nameLabel:getString()",nameLabel:getString())
 		-- 	print("nameLabel:getContentSize().width",nameLabel:getContentSize().width)
 		-- 	print("nameLabel:getContentSize().height",nameLabel:getContentSize().height)

 		-- 	local pointLabel=GetTTFLabel("...",25)
	 	-- 	pointLabel:setAnchorPoint(ccp(0,0.5))
	 	-- 	pointLabel:setPosition(widthSpace+120+70,height)
	 	-- 	cell:addChild(pointLabel,2)
	 	-- 	self.labelTab[idx].pointLabel=pointLabel
 		-- end
		nameLabel:setAnchorPoint(ccp(0.5,0.5))
		nameLabel:setPosition(widthSpace+120,height)
 		cell:addChild(nameLabel,2)
 		self.labelTab[idx].nameLabel=nameLabel

 		--local numLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),25)
		local numLabel=GetTTFLabel(numStr,25)
		numLabel:setAnchorPoint(ccp(0.5,0.5))
 		numLabel:setPosition(widthSpace+250,height)
 		cell:addChild(numLabel,2)
 		self.labelTab[idx].numLabel=numLabel
		
		--[[
 		if self.selectedTabIndex==1 then
 			local valueLabel=GetTTFLabel(valueStr,25)
 			valueLabel:setPosition(widthSpace+150*3-15,height)
 			cell:addChild(valueLabel,2)
 			self.labelTab[idx].valueLabel=valueLabel
			
 			local starIcon = CCSprite:createWithSpriteFrameName("StarIcon.png")
 	      	starIcon:setPosition(ccp(widthSpace+150*3+35,height))
 			cell:addChild(starIcon,2)
 		else
		]]
		local valueLabel=GetTTFLabel(FormatNumber(valueStr),25)
		valueLabel:setAnchorPoint(ccp(0.5,0.5))
		valueLabel:setPosition(widthSpace+350,height)
		cell:addChild(valueLabel,2)
		self.labelTab[idx].valueLabel=valueLabel
			--end
		

		local function viewHandler(tag,object,tag2)
            if self.tv:getIsScrolled()==true then
                do
                    return
                end
            end
			if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
			if allianceVo then
				local function applyHandle(operationType)
					if operationType==1 then 		--申请
						if allianceVo.type==1 then 	--1 是需要审批，0 是直接加入
							if self.viewBtnTab[idx+1] and self.viewBtnTab[idx+1].viewBtn and self.viewBtnTab[idx+1].applyBtn then
								-- self.viewBtnTab[idx+1].viewBtn:setVisible(false)
								-- self.viewBtnTab[idx+1].viewBtn:setEnabled(false)
								-- self.viewBtnTab[idx+1].applyBtn:setVisible(true)
								-- self.viewBtnTab[idx+1].applyBtn:setEnabled(true)
					    		tolua.cast(self.viewBtnTab[idx+1].viewBtn,"CCMenuItemSprite"):setVisible(false)
					    		tolua.cast(self.viewBtnTab[idx+1].viewBtn,"CCMenuItemSprite"):setEnabled(false)
					    		tolua.cast(self.viewBtnTab[idx+1].applyBtn,"CCMenuItemSprite"):setVisible(true)
					    		tolua.cast(self.viewBtnTab[idx+1].applyBtn,"CCMenuItemSprite"):setEnabled(true)
							end
							-- if self.viewBtnTab[idx+1] then
							-- 	tolua.cast(self.viewBtnTab[idx+1]:getChildByTag(idx+1),"CCLabelTTF"):setString(getlocal("alliance_list_have_apply"))
							-- end
							self.applyTab[allianceVo.aid]={viewBtn=self.viewBtnTab[idx+1].viewBtn,applyBtn=self.viewBtnTab[idx+1].applyBtn}
							allianceVoApi:setNeedFlag(nil,1)
						else
							if self.parentDialog then
								self.parentDialog:close(true)
							end
						end
					elseif operationType==2 then 	--取消申请
						if self.viewBtnTab[idx+1] and self.viewBtnTab[idx+1].viewBtn and self.viewBtnTab[idx+1].applyBtn then
							-- self.viewBtnTab[idx+1].viewBtn:setVisible(true)
							-- self.viewBtnTab[idx+1].viewBtn:setEnabled(true)
							-- self.viewBtnTab[idx+1].applyBtn:setVisible(false)
							-- self.viewBtnTab[idx+1].applyBtn:setEnabled(false)
				    		tolua.cast(self.viewBtnTab[idx+1].viewBtn,"CCMenuItemSprite"):setVisible(true)
				    		tolua.cast(self.viewBtnTab[idx+1].viewBtn,"CCMenuItemSprite"):setEnabled(true)
				    		tolua.cast(self.viewBtnTab[idx+1].applyBtn,"CCMenuItemSprite"):setVisible(false)
				    		tolua.cast(self.viewBtnTab[idx+1].applyBtn,"CCMenuItemSprite"):setEnabled(false)
						end
						self.applyTab[allianceVo.aid]=nil
						--tolua.cast(self.viewBtnTab[idx+1]:getChildByTag(idx+1),"CCLabelTTF"):setString(getlocal("alliance_list_check_info"))
						allianceVoApi:setNeedFlag(nil,1)
					end
				end
				local function touchCallback()
					allianceSmallDialog:allianceInforDialog("PanelHeaderPopup.png",CCSizeMake(550,830),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,allianceVo,applyHandle)
	            end
	            if tag2 and tag2==idx+1000 then
	            	local fadeIn=CCFadeIn:create(0.2)
			    --local delay=CCDelayTime:create(2)
				    local fadeOut=CCFadeOut:create(0.2)
					local callFunc=CCCallFuncN:create(touchCallback)
				    local acArr=CCArray:create()
				    acArr:addObject(fadeIn)
				    --acArr:addObject(delay)
				    acArr:addObject(fadeOut)
				    acArr:addObject(callFunc)
				    local seq=CCSequence:create(acArr)
				    local bsp=tolua.cast(cell:getChildByTag(idx+1000),"LuaCCScale9Sprite")
					bsp:runAction(seq)
				else
					touchCallback()
	            end
				-- allianceSmallDialog:allianceInforDialog("PanelHeaderPopup.png",CCSizeMake(550,830),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,4,allianceVo,applyHandle)
			end
		end

		local hasApply=allianceVoApi:isHasApplyAlliance(allianceVo)
		local viewBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",viewHandler,idx+100,getlocal("alliance_list_check_info"),28,idx+1)
	    viewBtn:setAnchorPoint(ccp(0.5,0.5))
		viewBtn:setScale(0.6)
		local viewMenu=CCMenu:createWithItem(viewBtn)
	    viewMenu:setPosition(ccp(self.bgLayer:getContentSize().width-viewBtn:getContentSize().width/2-40,height))
	    viewMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	    cell:addChild(viewMenu,3)

		local applyBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",viewHandler,idx+100,getlocal("alliance_list_have_apply"),28,idx+1)
	    applyBtn:setAnchorPoint(ccp(0.5,0.5))
		applyBtn:setScale(0.6)
		local applyMenu=CCMenu:createWithItem(applyBtn)
	    applyMenu:setPosition(ccp(self.bgLayer:getContentSize().width-applyBtn:getContentSize().width/2-40,height))
	    applyMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	    cell:addChild(applyMenu,3)

	    if hasApply then
	    	viewBtn:setVisible(false)
	    	viewBtn:setEnabled(false)
	    	applyBtn:setVisible(true)
	    	applyBtn:setEnabled(true)
	    	self.applyTab[allianceVo.aid]={viewBtn=viewBtn,applyBtn=applyBtn}
	    else
	    	viewBtn:setVisible(true)
	    	viewBtn:setEnabled(true)
	    	applyBtn:setVisible(false)
	    	applyBtn:setEnabled(false)
	    end
	    self.viewBtnTab[idx+1]={viewBtn=viewBtn,applyBtn=applyBtn}
			
		local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSprite:setAnchorPoint(ccp(0.5,0))
		lineSprite:setPosition(ccp(290,0))
		cell:addChild(lineSprite,2)

		local backSprie
		backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),viewHandler)
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setTag(idx+1000)
		cell:addChild(backSprie,1)
		backSprie:setOpacity(0)
		backSprie:setPosition(0,5)
		--lineSprite:setScale(0.8)
			
 		return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function allianceDialogTab1:tick()
	local requestsList=allianceVoApi:getRequestsList()
	if self.applyTab then
		for k,v in pairs(self.applyTab) do
			local isApply=false
			if requestsList then
				for m,n in pairs(requestsList) do
					if tostring(n)==tostring(k) then
						isApply=true
					end
				end
			end
			if isApply then

			else
				if self and self.applyTab and self.applyTab[k] then
					if self.applyTab[k].viewBtn then
						-- self.applyTab[k].viewBtn:setVisible(true)
						-- self.applyTab[k].viewBtn:setEnabled(true)
						tolua.cast(self.applyTab[k].viewBtn,"CCMenuItemSprite"):setVisible(true)
						tolua.cast(self.applyTab[k].viewBtn,"CCMenuItemSprite"):setEnabled(true)
					end
					if self.applyTab[k].applyBtn then
						-- self.applyTab[k].applyBtn:setVisible(false)
						-- self.applyTab[k].applyBtn:setEnabled(false)
				    	tolua.cast(self.applyTab[k].applyBtn,"CCMenuItemSprite"):setVisible(false)
						tolua.cast(self.applyTab[k].applyBtn,"CCMenuItemSprite"):setEnabled(false)
					end
					self.applyTab[k]=nil
				end
			end
		end
	end
end

--用户处理特殊需求,没有可以不写此方法
function allianceDialogTab1:doUserHandler(searchName)
	local height=self.bgLayer:getContentSize().height-179
	local lbSize=22
	local widthSpace=80
    local color=G_ColorGreen
	if self.rankLabel==nil then
		self.rankLabel=GetTTFLabel(getlocal("alliance_scene_rank_title"),lbSize)
		self.rankLabel:setPosition(widthSpace,height)
		self.bgLayer:addChild(self.rankLabel,1)
        self.rankLabel:setColor(color)
	end
	
	if self.nameLabel==nil then
		self.nameLabel=GetTTFLabel(getlocal("alliance_scene_alliance_name_title"),lbSize)
		self.nameLabel:setPosition(widthSpace+120,height)
		self.bgLayer:addChild(self.nameLabel,1)
        self.nameLabel:setColor(color)
	end
	
	if self.numLabel==nil then
		self.numLabel=GetTTFLabel(getlocal("alliance_scene_alliance_num_title"),lbSize)
		self.numLabel:setPosition(widthSpace+250,height)
		self.bgLayer:addChild(self.numLabel,1)
        self.numLabel:setColor(color)
	end
	
	if self.valueLabel==nil then
		self.valueLabel=GetTTFLabel(getlocal("alliance_scene_alliance_power_title"),lbSize)
		self.valueLabel:setPosition(widthSpace+350+5,height)
		self.bgLayer:addChild(self.valueLabel,1)
        self.valueLabel:setColor(color)
	end
	
	if self.viewLabel==nil then
		self.viewLabel=GetTTFLabel(getlocal("alliance_scene_check"),lbSize)
		self.viewLabel:setPosition(widthSpace+470,height)
		self.bgLayer:addChild(self.viewLabel,1)
        self.viewLabel:setColor(color)
	end
	if self.resultLabel==nil then
		-- self.resultLabel=GetTTFLabelWrap(getlocal("alliance_search_result",{""}),25,CCSize(240,60),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		-- self.resultLabel:setAnchorPoint(ccp(0.5,0.5))
		-- self.resultLabel:setPosition(self.bgLayer:getContentSize().width/2,68)
		--self.resultLabel=GetTTFLabelWrap(getlocal("alliance_search_result",{""}),25,CCSize(240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.resultLabel=GetTTFLabel(getlocal("alliance_search_result",{""}),25)
		self.resultLabel:setAnchorPoint(ccp(0,0.5))
		self.resultLabel:setPosition(30,68)
		self.bgLayer:addChild(self.resultLabel,1)
		self.resultLabel:setVisible(false)
	end
	--[[
	if allianceVoApi:isHasAlliance()==false then
		self.rankLabel:setString(getlocal("alliance_list_recommend"))
	else
		self.rankLabel:setString(getlocal("RankScene_rank"))
	end
	]]
	if self.searchBtn==nil then
		local function searchAlliance(tag,object)
			if searchName then
			else
				if G_checkClickEnable()==false then
	                do
	                    return
	                end
	            else
	                base.setWaitTime=G_getCurDeviceMillTime()
	            end
			end
			
			local function searchHandle(name,isNotMatch)
				self.noResultLabel:setVisible(false)
				if name~=nil and name~="" then
					self.showType=1
					self.resultLabel:setString(getlocal("alliance_search_result",{name}))
					self.resultLabel:setVisible(true)
					if isNotMatch==true then
						allianceVoApi:clearSearchList()
						self.noResultLabel:setString(getlocal("alliance_search_no_result"))
						self.noResultLabel:setVisible(true)
					else
						if allianceVoApi:getSearchNum()>0 then
						else
							self.noResultLabel:setString(getlocal("alliance_search_no_result"))
							self.noResultLabel:setVisible(true)
						end
					end
				else
					self.showType=0
					self.resultLabel:setVisible(false)
					allianceVoApi:setPage(1)
				end
				self:refresh()
			end
			self.searchDialog=allianceSmallDialog:allianceSearchDialog("PanelHeaderPopup.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,searchHandle,nil,nil,searchName)
	    end
	    self.searchBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",searchAlliance,nil,getlocal("alliance_list_scene_search"),28)
	    self.searchBtn:setScale(0.7)
	    local searchMenu=CCMenu:createWithItem(self.searchBtn)
	    searchMenu:setPosition(ccp(self.bgLayer:getContentSize().width-self.searchBtn:getContentSize().width/2-10,67))
	    searchMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.bgLayer:addChild(searchMenu,3)

	    if searchName then
	    	searchAlliance()
	    end
	end


	local function touch1(object,name,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if allianceVoApi:isHasAlliance()==false then
        	local function refreshUI()
        		if self.resultLabel then
					self.resultLabel:setVisible(false)
				end
				local getShowNum=allianceVoApi:getRankOrGoodNum()
				-- local getShowNum=0
				-- if allianceVoApi:getShowListType()==0 then
				-- 	getShowNum=allianceVoApi:getGoodNum()
				-- else
				-- 	getShowNum=allianceVoApi:getReqAndRankNum()
				-- end
				if tag==1 and getShowNum==0 then
					self.noResultLabel:setString(getlocal("alliance_join_no_result"))
					self.noResultLabel:setVisible(true)
				else
					self.noResultLabel:setVisible(false)
				end
				self.showType=0
				allianceVoApi:setPage(1)
				self:refresh()
        	end
        	local function reqAndRankHandle(fn,data)
	            if base:checkServerData(data)==true then
	            	refreshUI()

	                allianceVoApi:setLastListTime(base.serverTime)
	            end
	        end
	        if tag==1 then
	        	allianceVoApi:setShowListType(0)
	        	if allianceVoApi:getNeedGetList() or allianceVoApi:getRankOrGoodNum()==0 then
		   --      	if allianceVoApi:getShowListType()==0 then
					-- 	socketHelper:allianceList(reqAndRankHandle)
					-- else
						socketHelper:allianceList(reqAndRankHandle,0)
					-- end
				else
					refreshUI()
				end
	        else
	        	allianceVoApi:setShowListType(1)
	        	if allianceVoApi:getNeedGetList() or allianceVoApi:getRankOrGoodNum()==0 then
		        	-- if allianceVoApi:getShowListType()==0 then
						socketHelper:allianceList(reqAndRankHandle,1)
					-- else
					-- 	socketHelper:allianceList(reqAndRankHandle,0)
					-- end
				else
					refreshUI()
				end
	        end
	  --       if allianceVoApi:getNeedGetList() or allianceVoApi:getRankOrGoodNum()==0 then
	  --       	if allianceVoApi:getShowListType()==0 then
			-- 		socketHelper:allianceList(reqAndRankHandle)
			-- 	else
			-- 		socketHelper:allianceList(reqAndRankHandle,0)
			-- 	end
			-- end
		end
    end
    if self.checkBtnBg==nil then
	    self.checkBtnBg=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch1)
	    self.checkBtnBg:setAnchorPoint(ccp(0,0.5));
	    self.checkBtnBg:setTag(1)
	    self.checkBtnBg:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.checkBtnBg:setPosition(10+self.checkBtnBg:getContentSize().width/2,67)
	    self.bgLayer:addChild(self.checkBtnBg,2)
	end
    if self.checkBtn==nil then
	    self.checkBtn=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",touch1)
	    self.checkBtn:setAnchorPoint(ccp(0,0.5));
	    self.checkBtn:setTag(2)
	    self.checkBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.checkBtn:setPosition(10+self.checkBtn:getContentSize().width/2,67)
	    self.bgLayer:addChild(self.checkBtn,2)
	end
	if self.canApplyLb==nil then
		self.canApplyLb=GetTTFLabelWrap(getlocal("alliance_can_join"),25,CCSize(self.bgLayer:getContentSize().width-230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.canApplyLb:setAnchorPoint(ccp(0,0.5))
		self.canApplyLb:setPosition(self.checkBtnBg:getContentSize().width+40,67)
		self.bgLayer:addChild(self.canApplyLb,1)
	end

	if allianceVoApi:isHasAlliance()==false and self.showType==0 then
		self.canApplyLb:setVisible(true)
		if allianceVoApi:getShowListType()==0 then
			self.checkBtnBg:setVisible(false)
			self.checkBtnBg:setPosition(10000,0)
			self.checkBtn:setVisible(true)
			self.checkBtn:setPosition(10+self.checkBtn:getContentSize().width/2,67)
			-- self.canApplyLb:setString(getlocal("coverFleetBack"))
		else
			self.checkBtnBg:setVisible(true)
			self.checkBtnBg:setPosition(10+self.checkBtnBg:getContentSize().width/2,67)
			self.checkBtn:setVisible(false)
			self.checkBtn:setPosition(10000,0)
			-- self.canApplyLb:setString(getlocal("alliance_can_join"))
		end
	else
		self.checkBtnBg:setVisible(false)
		self.checkBtnBg:setPosition(10000,0)
		self.checkBtn:setVisible(false)
		self.checkBtn:setPosition(10000,0)
		self.canApplyLb:setVisible(false)
	end


end

--点击了cell或cell上某个按钮
function allianceDialogTab1:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
    	local hasMore=false
    	local num=0
    	local isHasAlliance=allianceVoApi:isHasAlliance()
    	if self.showType==1 then
    		num=allianceVoApi:getShowSearchNum()
	    	hasMore=allianceVoApi:hasMore(1)
	    else
	    	--local num=allianceVoApi:getRankOrGoodNum(self.selectedTabIndex)
	    	num=allianceVoApi:getShowNum()
	    	hasMore=allianceVoApi:hasMore(0)
	    	if isHasAlliance then
		    	num=num+1
		    end
	    end
		if hasMore and tostring(idx)==tostring(num) then
			PlayEffect(audioCfg.mouseClick)
			--local showList=allianceVoApi:getShowList()
			local showList={}
			local hasMoreNew=false
			if self.showType==1 then
				showList=allianceVoApi:getShowSearchList()
				hasMoreNew=allianceVoApi:hasMore(1)
			else
				showList=allianceVoApi:getShowList()
				hasMoreNew=allianceVoApi:hasMore(0)
			end
			if showList then
				local recordPoint = self.tv:getRecordPoint()
				self.tv:removeCellAtIndex(idx)
				local addNum=SizeOfTable(showList)
				for k,v in pairs(showList) do
					local cellIndex=v.index
					if hasMoreNew then
						cellIndex=cellIndex-1
					else
						if addNum-1>0 then
							addNum=addNum-1
						end
					end
					if self.showType~=1 and isHasAlliance then
						--self.tv:insertCellAtIndex(v.index)
					else
						cellIndex=cellIndex-1
						--self.tv:insertCellAtIndex(v.index-1)
					end
					self.tv:insertCellAtIndex(cellIndex)
					recordPoint.y=recordPoint.y-self.cellHeight*addNum
					self.tv:recoverToRecordPoint(recordPoint)
					do return end
				end
			end
			
			--[[
			local rData=allianceVoApi:getRank(self.selectedTabIndex)
			local function rankingHandler(fn,data)
				if base:checkServerData(data)==true then
					--local nowNum=rankVoApi:getMore(self.selectedTabIndex)
					local nowNum=rankVoApi:getRankOrGoodNum(self.selectedTabIndex)
					local nextHasMore=rankVoApi:hasMore(self.selectedTabIndex)
					local recordPoint = self.tv:getRecordPoint()
					self.tv:reloadData()
			        self:doUserHandler()
					if nextHasMore then
						recordPoint.y=(num-nowNum)*self.cellHeight+recordPoint.y
					else
						recordPoint.y=(num-nowNum+1)*self.cellHeight+recordPoint.y
					end
					self.tv:recoverToRecordPoint(recordPoint)
				end
			end
			local page=rData.page+1
			socketHelper:ranking(self.selectedTabIndex+1,page,rankingHandler)
			]]
		end
    end
end

--点击了cell或cell上某个按钮
function allianceDialogTab1:refresh(isTabClick)
	if self and self.tv then
		local showType=allianceVoApi:getShowListType()
		if allianceVoApi:getNeedFlag(showType)==1 then
			self.showType=0
			allianceVoApi:setPage(1)
			if self.resultLabel then
				self.resultLabel:setVisible(false)
			end
			self.noResultLabel:setVisible(false)
			self.applyTab={}
			self.tv:reloadData()
			self:doUserHandler()
		elseif isTabClick then
			if self.showType==1 then
				self.showType=0
				allianceVoApi:setPage(1)
				if self.resultLabel then
					self.resultLabel:setVisible(false)
				end
				self.noResultLabel:setVisible(false)
				self.applyTab={}
				self.tv:reloadData()
			end
			self:doUserHandler()
		else
			-- if self.resultLabel then
			-- 	self.resultLabel:setVisible(false)
			-- end
   --          self.noResultLabel:setVisible(false)
			self.applyTab={}
			self.tv:reloadData()
			self:doUserHandler()
		end
	end
end

function allianceDialogTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.tv=nil;
    self.tableCell1={};
    self.tableCell1=nil;
    self.layerNum=nil;

    if self and self.searchDialog then
    	self.searchDialog:close()
    	self.searchDialog=nil
    end
	self.rankLabel=nil
	self.nameLabel=nil
	self.numLabel=nil
	self.valueLabel=nil
	self.viewLabel=nil
	self.labelTab=nil
	self.cellHeight=nil
	self.tvBg=nil
	self.searchBtn=nil
	self.resultLabel=nil
	self.noResultLabel=nil

	self.showType=nil
	self.viewBtnTab=nil
	self.applyTab=nil
	self.reqAndRankBtn=nil
	self.checkBtn=nil
	self.checkBtnBg=nil
	self.canApplyLb=nil

	self=nil
end
