--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/rank/rankVoApi"

medalsRankDialog=commonDialog:new()

function medalsRankDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.valueLabel=nil
	self.labelTab={}
	self.cellHeight=72
    return nc
end

function medalsRankDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight-115))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
	
end

--设置对话框里的tableView
function medalsRankDialog:initTableView()
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-240),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,50))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    if #playerVoApi.rankList==0 then
        local nameLb=GetTTFLabel(getlocal("activity_getRich_norank"),32)
        nameLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
        nameLb:setColor(G_ColorGray)
        self.bgLayer:addChild(nameLb,5);
    end
end

function medalsRankDialog:getDataByType(type)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function medalsRankDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
	   
	   return #playerVoApi.rankList
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(400,self.cellHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
		local num=rankVoApi:getRankNum(self.selectedTabIndex)
	
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)
		local backSprie

		local function cellClick1(hd,fn,idx)
		end
		
		backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)
		
		local height=backSprie:getContentSize().height/2
		local widthSpace=50
		
		local selfRank
		local rankData
		
		local rankStr=idx+1
		local nameStr=playerVoApi.rankList[idx+1][1]
		local levelStr=playerVoApi.rankList[idx+1][2]
		local valueStr=playerVoApi.rankList[idx+1][3]
		
		
		local rankLabel=GetTTFLabel(rankStr,30)
		rankLabel:setPosition(widthSpace,height)
		cell:addChild(rankLabel,2)
		table.insert(self.labelTab,idx+1,{rankLabel=rankLabel})
	

		local nameLabel=GetTTFLabel(nameStr,30)
		nameLabel:setPosition(widthSpace+150,height)
		cell:addChild(nameLabel,2)
		self.labelTab[idx+1].nameLabel=nameLabel

		local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),30)
		levelLabel:setPosition(widthSpace+150*2+20,height)
		cell:addChild(levelLabel,2)
		self.labelTab[idx+1].levelLabel=levelLabel

		local valueLabel=GetTTFLabel(FormatNumber(tonumber(valueStr)),30)
		valueLabel:setPosition(widthSpace+150*3,height)
		cell:addChild(valueLabel,2)
		self.labelTab[idx+1].valueLabel=valueLabel
		

		return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function medalsRankDialog:setColor(idx,color)
	self.labelTab[idx].rankLabel:setColor(color)
	self.labelTab[idx].nameLabel:setColor(color)
	self.labelTab[idx].levelLabel:setColor(color)
	self.labelTab[idx].valueLabel:setColor(color)
end

--点击tab页签 idx:索引
function medalsRankDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
            
            self.tv:reloadData()
            self:doUserHandler()
            --[[
                    local function rankingHandler(fn,data)
                        if base:checkServerData(data)==true then
                            self.tv:reloadData()
                            self:doUserHandler()
                        end
                    end
                    local rankData=rankVoApi:getRank(idx)
                    if rankData.selfRank==nil or SizeOfTable(rankData.selfRank)==0 then
                        socketHelper:ranking(idx+1,1,rankingHandler)
                    else
                        self.tv:reloadData()
                        self:doUserHandler()
                    end
            ]]
		else
			v:setEnabled(true)
		end
    end
end

--用户处理特殊需求,没有可以不写此方法
function medalsRankDialog:doUserHandler()
	local height=self.bgLayer:getContentSize().height-145
	local widthSpace=80
	if self.rankLabel==nil then
		self.rankLabel=GetTTFLabel(getlocal("RankScene_rank"),25)
		self.rankLabel:setPosition(widthSpace,height)
		self.bgLayer:addChild(self.rankLabel,1)
	end
	
	if self.nameLabel==nil then
		self.nameLabel=GetTTFLabel(getlocal("RankScene_name"),25)
		self.nameLabel:setPosition(widthSpace+150,height)
		self.bgLayer:addChild(self.nameLabel,1)
	end
	
	if self.levelLabel==nil then
		self.levelLabel=GetTTFLabel(getlocal("RankScene_level"),25)
		self.levelLabel:setPosition(widthSpace+150*2+20,height)
		self.bgLayer:addChild(self.levelLabel,1)
	end
	
	if self.valueLabel==nil then
		self.valueLabel=GetTTFLabel(getlocal("alliance_medals"),25)
		self.valueLabel:setPosition(widthSpace+150*3,height)
		self.bgLayer:addChild(self.valueLabel,1)
	end
	if self.selectedTabIndex==0 then
		self.valueLabel:setString(getlocal("alliance_medals"))
	elseif self.selectedTabIndex==1 then
		self.valueLabel:setString(getlocal("RankScene_star_num"))
	elseif self.selectedTabIndex==2 then
		self.valueLabel:setString(getlocal("RankScene_honor"))
	end
end


--点击了cell或cell上某个按钮
function medalsRankDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		local rData=rankVoApi:getRank(self.selectedTabIndex)
	    local hasMore=rankVoApi:hasMore(self.selectedTabIndex)
	    local num=rankVoApi:getRankNum(self.selectedTabIndex)
		if hasMore and tostring(idx)==tostring(num) then
			PlayEffect(audioCfg.mouseClick)
			local function rankingHandler(fn,data)
				if base:checkServerData(data)==true then
					--local nowNum=rankVoApi:getMore(self.selectedTabIndex)
					local nowNum=rankVoApi:getRankNum(self.selectedTabIndex)
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
		end
    end
end

function medalsRankDialog:dispose()
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.valueLabel=nil
	self.labelTab=nil
	self.cellHeight=nil
	self=nil
end





