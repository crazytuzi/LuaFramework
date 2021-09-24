recommendAllianceTab={}

function recommendAllianceTab:new(searchName)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.bgLayer=nil;
    self.tableCell1={};
	
	self.cellHeight=70

	self.showType=0
	self.viewBtnTab={}
	self.applyTab={}
	self.parentDialog=nil
	self.searchName=searchName

    return nc;

end

function recommendAllianceTab:init(parentDialog,layerNum,isGuide)
	
	self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum;
    self:initTableView()
	self:doUserHandler(self.searchName)
   
    return self.bgLayer
end

function recommendAllianceTab:initTableView()
	local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function click(hd,fn,idx)
	end


	self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),click)
	self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-270))
	self.tvBg:ignoreAnchorPointForPosition(false)
	self.tvBg:setAnchorPoint(ccp(0.5,0))
	self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,105))
	self.bgLayer:addChild(self.tvBg)

	
	self.recommendList={}
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSize.height-250-70),nil)
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
function recommendAllianceTab:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
		local num=0
		-- if self.showType==1 then
		-- 	num=SizeOfTable(allianceVoApi:getNewSearchList())
		-- else
		-- 	num=SizeOfTable(allianceVoApi:getNewRankOrGoodList())
		-- end
		num=SizeOfTable(self.recommendList)
		if num>20 then
			num=20
		end
		return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(400,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
 		local hasMore=false
		local num=0

 		local cell=CCTableViewCell:new()
 		cell:autorelease()
 		local rect = CCRect(0, 0, 50, 50);
 		local capInSet = CCRect(40, 40, 10, 10);
 		local capInSetNew=CCRect(20, 20, 10, 10)

 		local allianceVo
		
 		local rankStr=0
 		local nameStr=""
 		local nameStr=0
 		local valueStr=0
 		local totalNumStr=""
 		
 		-- if self.showType==1 then
 		-- 	allianceVo=allianceVoApi:getNewSearchList()[idx+1]
	 	-- else
			-- allianceVo=allianceVoApi:getNewRankOrGoodList()[idx+1]
	 	-- end
	 	allianceVo=self.recommendList[idx+1]

	 	local function applyHandle(operationType)
			if operationType==1 then 		--申请
				if allianceVo.type==1 then 	--1 是需要审批，0 是直接加入
					if self.viewBtnTab[idx+1] and self.viewBtnTab[idx+1].viewBtn and self.viewBtnTab[idx+1].applyBtn then
			    		tolua.cast(self.viewBtnTab[idx+1].viewBtn,"CCMenuItemSprite"):setVisible(false)
			    		tolua.cast(self.viewBtnTab[idx+1].viewBtn,"CCMenuItemSprite"):setEnabled(false)
			    		tolua.cast(self.viewBtnTab[idx+1].applyBtn,"CCMenuItemSprite"):setVisible(true)
			    		tolua.cast(self.viewBtnTab[idx+1].applyBtn,"CCMenuItemSprite"):setEnabled(true)
					end

					self.applyTab[allianceVo.aid]={viewBtn=self.viewBtnTab[idx+1].viewBtn,applyBtn=self.viewBtnTab[idx+1].applyBtn}
					allianceVoApi:setNeedFlag(nil,1)
				else
					if self.parentDialog then
						self.parentDialog:close(true)
					end
				end
			elseif operationType==2 then 	--取消申请
				if self.viewBtnTab[idx+1] and self.viewBtnTab[idx+1].viewBtn and self.viewBtnTab[idx+1].applyBtn then
		    		tolua.cast(self.viewBtnTab[idx+1].viewBtn,"CCMenuItemSprite"):setVisible(true)
		    		tolua.cast(self.viewBtnTab[idx+1].viewBtn,"CCMenuItemSprite"):setEnabled(true)
		    		tolua.cast(self.viewBtnTab[idx+1].applyBtn,"CCMenuItemSprite"):setVisible(false)
		    		tolua.cast(self.viewBtnTab[idx+1].applyBtn,"CCMenuItemSprite"):setEnabled(false)
				end
				self.applyTab[allianceVo.aid]=nil
				allianceVoApi:setNeedFlag(nil,1)
			end
		end

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

            local function touchCallback()
            	if allianceVo then
					allianceSmallDialog:allianceInforDialog("PanelHeaderPopup.png",CCSizeMake(550,830),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,allianceVo,applyHandle)
				end
            end

            if tag2 and tag2==idx+1000 then
            	local fadeIn
            	local fadeOut

            	if idx%2 == 0 then
					fadeIn=CCFadeTo:create(0.2,255)
			   		fadeOut=CCFadeTo:create(0.2,0)            	
			   	else
					fadeIn=CCFadeTo:create(0.2,0)
			   		fadeOut=CCFadeTo:create(0.2,255)   
            	end
				local callFunc=CCCallFuncN:create(touchCallback)
			    local acArr=CCArray:create()
			    acArr:addObject(fadeIn)
			    acArr:addObject(fadeOut)
			    acArr:addObject(callFunc)
			    local seq=CCSequence:create(acArr)
			    local bsp=tolua.cast(cell:getChildByTag(idx+1000),"LuaCCScale9Sprite")
				bsp:runAction(seq)
			else
				touchCallback()
            end
            
		end

		cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.cellHeight))
	    local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),viewHandler)
	    grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.cellHeight))
	    grayBgSp:setAnchorPoint(ccp(0.5,1))
	    grayBgSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
	    grayBgSp:setIsSallow(false)
		grayBgSp:setTag(idx+1000)

		grayBgSp:setTouchPriority(-(self.layerNum-1)*20-1)
	    cell:addChild(grayBgSp) 
	    if (idx+1)%2 == 1 then
	      grayBgSp:setOpacity(0)
	    end

		-- local function cellClick(hd,fn,idx)
		-- 	-- self:cellClick(idx)
		-- end
		-- local backSprie
		-- backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),viewHandler)
		-- backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
		-- backSprie:ignoreAnchorPointForPosition(false)
		-- backSprie:setAnchorPoint(ccp(0,0))
		-- backSprie:setIsSallow(false)
		-- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		-- backSprie:setTag(idx+1000)
		-- cell:addChild(backSprie,1)
		-- backSprie:setOpacity(0)
		-- backSprie:setPosition(0,5)
		-- backSprie:setVisible(false)
			
 		local height=grayBgSp:getContentSize().height/2
 		local widthSpace=70
		
 		
		
		if allianceVo then
			rankStr=allianceVo.rank or 0
			nameStr=allianceVo.name or ""
			numStr=allianceVo.num or 0
			valueStr=allianceVo.fight or 0
			totalNumStr=allianceVo.maxnum or 0
		end
 		
 		local lbWidth=160
 		local nameLabel=GetTTFLabel(nameStr,25)
		nameLabel:setAnchorPoint(ccp(0.5,0.5))
		nameLabel:setPosition(widthSpace+15,height)
 		grayBgSp:addChild(nameLabel,2)

 		--local numLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),25)
		local numLabel=GetTTFLabel(numStr .. "/" .. totalNumStr,25)
		numLabel:setAnchorPoint(ccp(0.5,0.5))
 		numLabel:setPosition(widthSpace+150,height)
 		grayBgSp:addChild(numLabel,2)
		
		local valueLabel=GetTTFLabel(FormatNumber(valueStr),25)
		valueLabel:setAnchorPoint(ccp(0.5,0.5))
		valueLabel:setPosition(widthSpace+300,height)
		grayBgSp:addChild(valueLabel,2)
			--end


		local function applyHandler()            
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

            PlayEffect(audioCfg.mouseClick)


            if allianceVo.aid then
                local function applyCallback(fn,data)
                    if base:checkServerData(data)==true then
                        if allianceVo.type==1 then    --1 是需要审批，0 是直接加入
                            if allianceVoApi:requestsIsFull() then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_apply_num_max"),30)
                            else
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_shenqingTip",{allianceVo.name}),30)
                                allianceVoApi:addApply(allianceVo.aid)
                                -- self.parentDialog:close()
                                if applyHandle then
                                    applyHandle(1)
                                end
                            end
                            -- canClick=true
                        else
                            worldScene:updateAllianceName()
                        end
                    else
                        self.parentDialog:close()
                    end
                end
                -- if canClick then
                socketHelper:allianceJoin(allianceVo.aid,applyCallback)
                --     canClick=false
                -- end
            end
        end
		

		
		local hasApply=allianceVoApi:isHasApplyAlliance(allianceVo)

		local viewBtn = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",applyHandler,idx+100,getlocal("alliance_apply_menu"),28/0.7,idx+1)
	    viewBtn:setAnchorPoint(ccp(0.5,0.5))
		viewBtn:setScale(0.6)
		local viewMenu=CCMenu:createWithItem(viewBtn)
	    viewMenu:setPosition(ccp(widthSpace+450,height))
	    viewMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	    grayBgSp:addChild(viewMenu,3)

		local applyBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",viewHandler,idx+100,getlocal("alliance_list_have_apply"),28/0.7,idx+1)
	    applyBtn:setAnchorPoint(ccp(0.5,0.5))
		applyBtn:setScale(0.6)
		local applyMenu=CCMenu:createWithItem(applyBtn)
	    applyMenu:setPosition(ccp(widthSpace+450,height))
	    applyMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	    grayBgSp:addChild(applyMenu,3)

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
			
		-- local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
		-- lineSprite:setAnchorPoint(ccp(0.5,0))
		-- lineSprite:setPosition(ccp(290,0))
		-- cell:addChild(lineSprite,2)
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

function recommendAllianceTab:tick()
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
function recommendAllianceTab:doUserHandler(searchName)



	  local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
  wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,40))
  wholeBgSp:setAnchorPoint(ccp(0.5,1))
  wholeBgSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-170))
  self.bgLayer:addChild(wholeBgSp)

  local height=self.bgLayer:getContentSize().height-190
  local lbSize=22
  local widthSpace=80
    local color=G_ColorYellowPro2
  
  if self.nameLabel==nil then
    self.nameLabel=GetTTFLabel(getlocal("alliance_scene_alliance_name_title"),lbSize,true)
    self.nameLabel:setPosition(widthSpace+40,height)
    self.bgLayer:addChild(self.nameLabel,1)
    self.nameLabel:setColor(color)
  end
  
  if self.numLabel==nil then
    self.numLabel=GetTTFLabel(getlocal("alliance_scene_alliance_num_title"),lbSize,true)
    self.numLabel:setPosition(widthSpace+170,height)
    self.bgLayer:addChild(self.numLabel,1)
        self.numLabel:setColor(color)
  end
  
  if self.valueLabel==nil then
    self.valueLabel=GetTTFLabel(getlocal("alliance_scene_alliance_power_title"),lbSize,true)
    self.valueLabel:setPosition(widthSpace+320+5,height)
    self.bgLayer:addChild(self.valueLabel,1)
        self.valueLabel:setColor(color)
  end
  
  if self.viewLabel==nil then
    self.viewLabel=GetTTFLabel(getlocal("state"),lbSize,true)
    self.viewLabel:setPosition(widthSpace+467,height)
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
      self.searchBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",searchAlliance,nil,getlocal("alliance_list_scene_search"),28/0.7)
      self.searchBtn:setScale(0.7)
      local searchMenu=CCMenu:createWithItem(self.searchBtn)
      searchMenu:setPosition(ccp(self.bgLayer:getContentSize().width-self.searchBtn:getContentSize().width/2-10,55))
      searchMenu:setTouchPriority(-(self.layerNum-1)*20-4)
      self.bgLayer:addChild(searchMenu,3)

      if searchName then
        searchAlliance()
      end
  end

end

--点击了cell或cell上某个按钮
function recommendAllianceTab:cellClick(idx)
end

--点击了cell或cell上某个按钮
function recommendAllianceTab:refresh(isTabClick)
	if self and self.tv then
		
		local showType=allianceVoApi:getShowListType()
		if allianceVoApi:getNeedFlag(showType)==1 then
			self.showType=0
			if self.resultLabel then
				self.resultLabel:setVisible(false)
			end
			self.noResultLabel:setVisible(false)
			self.applyTab={}
			self.recommendList=allianceVoApi:getNewRankOrGoodList()
			self.tv:reloadData()
			self:doUserHandler()
		elseif isTabClick then
			if self.showType==1 then
				self.showType=0
				if self.resultLabel then
					self.resultLabel:setVisible(false)
				end
				self.noResultLabel:setVisible(false)
				self.applyTab={}

			end
			self.recommendList=allianceVoApi:getNewRankOrGoodList()
			self.tv:reloadData()
			self:doUserHandler()
		else
			if self.showType==0 then
				self.recommendList=allianceVoApi:getNewRankOrGoodList()
			else
				self.recommendList=allianceVoApi:getNewSearchList()
			end
			self.applyTab={}
			self.tv:reloadData()
			self:doUserHandler()
		end
		self:judgeHaveRecommedList()
	end
end

function recommendAllianceTab:judgeHaveRecommedList()
	if self.showType==0 then
		if SizeOfTable(self.recommendList)==0 then
			if self.noRecommendLb==nil then
				self.noRecommendLb=GetTTFLabelWrap(getlocal("noRecommendList_lbDes"),25,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
				self.noRecommendLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2+40)
				self.bgLayer:addChild(self.noRecommendLb)
				self.noRecommendLb:setColor(G_ColorYellowPro)
			end
			if self.createItem==nil then
				local function createFunc()
					if G_checkClickEnable()==false then
					    do
					        return
					    end
					else
					    base.setWaitTime=G_getCurDeviceMillTime()
					end
					self.parentDialog:tabClick(1)
				end
				self.createItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",createFunc,2,getlocal("createRole"),25,101)
				local createMenu=CCMenu:createWithItem(self.createItem)
				createMenu:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40)
				createMenu:setTouchPriority(-(self.layerNum-1)*20-4)
				self.bgLayer:addChild(createMenu)
			end

			self.noRecommendLb:setVisible(true)
			self.createItem:setVisible(true)
			self.createItem:setEnabled(true)
		else
			if self.noRecommendLb then
				self.noRecommendLb:setVisible(false)
			end
			if self.createItem then
				self.createItem:setVisible(false)
				self.createItem:setEnabled(false)
			end
			
		end
	else
		if self.noRecommendLb then
			self.noRecommendLb:setVisible(false)
		end
		if self.createItem then
			self.createItem:setVisible(false)
			self.createItem:setEnabled(false)
		end
	end
end

function recommendAllianceTab:dispose()
	if base.joinReward==0 and allianceVoApi:isHasAlliance() then
		local sd=allianceJoinSmallDialog:new()
        sd:showJoinAllianceDialog("panelBg.png",CCSizeMake(525,440),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,3,getlocal("alliance_list_scene_name"),true)
	end
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
