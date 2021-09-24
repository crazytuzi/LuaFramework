require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessSmallDialog"
acAnniversaryBlessFriendDialog=commonDialog:new()

function acAnniversaryBlessFriendDialog:new()
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

function acAnniversaryBlessFriendDialog:resetTab()

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
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight-180))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
	
end

--设置对话框里的tableView
function acAnniversaryBlessFriendDialog:initTableView()

	self.friendTb = friendMailVoApi:getFriendTb()
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-340),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,100))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    self.noLb=GetTTFLabel(getlocal("noFriends"),32)
    self.noLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.noLb:setColor(G_ColorGray)
    self.bgLayer:addChild(self.noLb,5)
    self.noLb:setVisible(false)
    if #self.friendTb==0 then
        self.noLb:setVisible(true)
    end
end

function acAnniversaryBlessFriendDialog:getDataByType(type)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acAnniversaryBlessFriendDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
	   
	   return #self.friendTb

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(400,self.cellHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
	
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)
		local backSprie

		local function cellClick()
			local friendUid=self.friendTb[idx+1].uid
		    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		    	local function donate()
		    		local function onDonate(fn,data)
    			        local ret,sData=base:checkServerData(data)
				        if ret==true then
				            acAnniversaryBlessVoApi:updateData(sData.data.anniversaryBless)
							acAnniversaryBlessVoApi:setRefreshWordsFlag(true)
            				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("donate_blessword_success"),30)

            				--同步当前集齐五福的人数
		                    local fullCount=acAnniversaryBlessVoApi:getPlayerCountFulled()
			                local params={}
			                params.finishNum=fullCount
			                params.uid=friendUid
			                chatVoApi:sendUpdateMessage(33,params)
			                acAnniversaryBlessVoApi:setRefreshRecordFlag(true)
				        end
		    		end
    		    	local selectKey=acAnniversaryBlessVoApi:getDonateWordKey()
    		    	local keyTb={}
    		    	keyTb[1]=selectKey
    		    	--发送捐赠好友福字的协议
    		    	socketHelper:donateWordToFriend(friendUid,keyTb,onDonate)
		    	end
				local isMyFriend = friendMailVoApi:isMyFriend(friendUid)
				smallDialog:showSendBlessWordDialog(isMyFriend,donate,"PanelHeaderPopup.png",CCSizeMake(550,580),CCRect(0, 0, 400, 400),CCRect(168, 86, 10, 10),getlocal("player_message_info_title"),self.friendTb[idx+1],self.layerNum+1)
    		end
		end
		
		backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick)
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
		
		local nameStr=self.friendTb[idx+1].nickname
		local levelStr=self.friendTb[idx+1].level
		local valueStr=self.friendTb[idx+1].fc
		local rankStr = playerVoApi:getRankIconName(tonumber(self.friendTb[idx+1].rank))
		local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
        mIcon:setScale(65/mIcon:getContentSize().width)
        mIcon:setAnchorPoint(ccp(0,0.5))
        mIcon:setPosition(ccp(15,36))
        cell:addChild(mIcon,5)
		
		local nameLabel=GetTTFLabel(nameStr,30)
		nameLabel:setPosition(widthSpace+150,height)
		cell:addChild(nameLabel,2)

		local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),30)
		levelLabel:setPosition(widthSpace+150*2+20,height)
		cell:addChild(levelLabel,2)

		local valueLabel=GetTTFLabel(FormatNumber(tonumber(valueStr)),30)
		valueLabel:setPosition(widthSpace+150*3,height)
		cell:addChild(valueLabel,2)
		

		return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function acAnniversaryBlessFriendDialog:tabClick(idx)
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
function acAnniversaryBlessFriendDialog:doUserHandler()
	local promptLabel=GetTTFLabel(getlocal("activity_anniversaryBless_prompt5"),25)
	promptLabel:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-120))
	promptLabel:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(promptLabel,1)

	local height=self.bgLayer:getContentSize().height-200
	local widthSpace=80
	if self.rankLabel==nil then
		local rklb = 25
		if G_getCurChoseLanguage() =="ru" then
			rklb =20
			widthSpace=widthSpace+25
		end
		self.rankLabel=GetTTFLabel(getlocal("help2_t1_t3"),rklb)
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
		self.valueLabel=GetTTFLabel(getlocal("showAttackRank"),25)
		self.valueLabel:setPosition(widthSpace+150*3,height)
		self.bgLayer:addChild(self.valueLabel,1)
	end

end

function acAnniversaryBlessFriendDialog:dispose()
	if self.searchDialog then
		self.searchDialog:close()
	end
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.valueLabel=nil
	self.labelTab=nil
	self.cellHeight=nil
	self=nil
end