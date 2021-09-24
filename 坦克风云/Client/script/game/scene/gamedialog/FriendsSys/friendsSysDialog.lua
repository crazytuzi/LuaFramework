--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/rank/rankVoApi"

friendsSysDialog=commonDialog:new()

function friendsSysDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.valueLabel=nil
	self.labelTab={}
	self.cellHeight=68
    return nc
end

function friendsSysDialog:resetTab()

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
function friendsSysDialog:initTableView()

	self.friendTb = friendMailVoApi:getFriendTb()
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-250),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,100))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    self.noLb=GetTTFLabel(getlocal("noFriends"),24)
    self.noLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.noLb:setColor(G_ColorGray)
    self.bgLayer:addChild(self.noLb,5)
    self.noLb:setVisible(false)
    if #self.friendTb==0 then
        self.noLb:setVisible(true)
    end

    local function search()
       self:showSearch()
    end
    self.searchBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",search,nil,getlocal("alliance_list_scene_search"),24,11)
    local lb=tolua.cast(self.searchBtn:getChildByTag(11),"CCLabelTTF")
    lb:setFontName("Helvetica-bold")
    local searchMenu=CCMenu:createWithItem(self.searchBtn)
    searchMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,67))
    searchMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(searchMenu,3)


end

function friendsSysDialog:getDataByType(type)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function friendsSysDialog:eventHandler(handler,fn,idx,cel)
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

		local function cellClick1()
			local isMyFriend = friendMailVoApi:isMyFriend(self.friendTb[idx+1].uid)
			local function callback()
				if isMyFriend then
					local function delcallback()
						local function callback(fn,data)
		                   local ret,sData=base:checkServerData(data)
		                   if ret==true then
		                   		-- G_removeMemberInMailListByUid(self.friendTb[idx+1].uid)
		                   		friendMailVoApi:delFriendByUid(self.friendTb[idx+1].uid)
		               
		                   		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("delFriendSuccess"),30)
		                   		self.friendTb=friendMailVoApi:getFriendTb()
		                   		if #self.friendTb==0 then
							        self.noLb:setVisible(true)
							        self.noLb:setString(getlocal("noFriends"))
							    end

		                     	self.tv:reloadData()
		                   end
		                end
		                if self.friendTb[idx+1] then
			                socketHelper:friendsDel(self.friendTb[idx+1].uid,self.friendTb[idx+1].nickname,callback)
			            end
					end

					smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),delcallback,getlocal("dialog_title_prompt"),getlocal("delFriendSure"),nil,self.layerNum+1)
				else
					local function addcallback()
						local function callback(fn,data)
			                local ret,sData=base:checkServerData(data)
			                if ret==true then
			                	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addFriendSuccess"),30)
			                	local toBlackTb={uid=self.friendTb[idx+1].uid,name=self.friendTb[idx+1].nickname}
								-- local isSuccess=G_saveNameAndUidInMailList(toBlackTb)
			                	local function callbackList(fn,data)
							          local ret,sData=base:checkServerData(data)
							          if ret==true then
							          		self.friendTb=friendMailVoApi:getFriendTb()
							          		self.tv:reloadData()
							          end
							     end
							     socketHelper:friendsList(callbackList)
			                	self.tv:reloadData()
			                end
			            end
						socketHelper:friendsAdd(self.friendTb[idx+1].nickname,callback)
					end

					smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),addcallback,getlocal("dialog_title_prompt"),getlocal("addFriendSure"),nil,self.layerNum+1)

				end
			end
			smallDialog:showFriendInfoSmallDialog(isMyFriend,callback,"PanelHeaderPopup.png",CCSizeMake(550,540),CCRect(0, 0, 400, 400),CCRect(168, 86, 10, 10),getlocal("player_message_info_title"),self.friendTb[idx+1],self.layerNum+1,true)
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
		
		local nameStr=self.friendTb[idx+1].nickname
		local levelStr=self.friendTb[idx+1].level
		local valueStr=self.friendTb[idx+1].fc
		local rankStr = playerVoApi:getRankIconName(tonumber(self.friendTb[idx+1].rank))
		local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
        mIcon:setScale(65/mIcon:getContentSize().width)
        mIcon:setAnchorPoint(ccp(0,0.5))
        mIcon:setPosition(ccp(15,36))
        cell:addChild(mIcon,5)
		
		local nameLabel=GetTTFLabel(nameStr,24)
		nameLabel:setPosition(widthSpace+150,height)
		cell:addChild(nameLabel,2)

		local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),24)
		levelLabel:setPosition(widthSpace+150*2+20,height)
		cell:addChild(levelLabel,2)

		local valueLabel=GetTTFLabel(FormatNumber(tonumber(valueStr)),24)
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

function friendsSysDialog:setColor(idx,color)


end

--点击tab页签 idx:索引
function friendsSysDialog:tabClick(idx)
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

function friendsSysDialog:showSearch()

	local function searchHandle(name,isNotMatch)

		if name==nil or name=="" then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_enterNo"),30)
			do
				return
			end
		end
		local function callback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                     self.friendTb={}
                     -- print("uid---->",sData.data.info[1].uid,GM_UidCfg[sData.data.info[1].uid])
                     if sData.data.info~=nil and sData.data.info[1] then
                     	self.friendTb=sData.data.info
                     	self.noLb:setVisible(false)
                     else
                     	self.noLb:setVisible(true)
                     	self.noLb:setString(getlocal("friend_searchNo"))

	                 end
                     self.tv:reloadData()
                end
        end
        --后台交互
		socketHelper:friendsSearch(name,callback)
	end
	self.searchDialog=allianceSmallDialog:allianceSearchDialog("PanelHeaderPopup.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,5,searchHandle,1)


end



--用户处理特殊需求,没有可以不写此方法
function friendsSysDialog:doUserHandler()
	local height=self.bgLayer:getContentSize().height-125
	local widthSpace=80
	if self.rankLabel==nil then
		local rklb = 24
		if G_getCurChoseLanguage() =="ru" then
			rklb =20
			widthSpace=widthSpace+25
		end
		self.rankLabel=GetTTFLabel(getlocal("help2_t1_t3"),rklb)
		self.rankLabel:setPosition(widthSpace,height)
		self.bgLayer:addChild(self.rankLabel,1)
	end
	
	if self.nameLabel==nil then
		self.nameLabel=GetTTFLabel(getlocal("RankScene_name"),24)
		self.nameLabel:setPosition(widthSpace+150,height)
		self.bgLayer:addChild(self.nameLabel,1)
	end
	
	if self.levelLabel==nil then
		self.levelLabel=GetTTFLabel(getlocal("RankScene_level"),24)
		self.levelLabel:setPosition(widthSpace+150*2+20,height)
		self.bgLayer:addChild(self.levelLabel,1)
	end
	
	if self.valueLabel==nil then
		self.valueLabel=GetTTFLabel(getlocal("showAttackRank"),24)
		self.valueLabel:setPosition(widthSpace+150*3,height)
		self.bgLayer:addChild(self.valueLabel,1)
	end

end


--点击了cell或cell上某个按钮
function friendsSysDialog:cellClick(idx)
  --   if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		-- local rData=rankVoApi:getRank(self.selectedTabIndex)
	 --    local hasMore=rankVoApi:hasMore(self.selectedTabIndex)
	 --    local num=rankVoApi:getRankNum(self.selectedTabIndex)
		-- if hasMore and tostring(idx)==tostring(num) then
		-- 	PlayEffect(audioCfg.mouseClick)
		-- 	local function rankingHandler(fn,data)
		-- 		if base:checkServerData(data)==true then
		-- 			--local nowNum=rankVoApi:getMore(self.selectedTabIndex)
		-- 			local nowNum=rankVoApi:getRankNum(self.selectedTabIndex)
		-- 			local nextHasMore=rankVoApi:hasMore(self.selectedTabIndex)
		-- 			local recordPoint = self.tv:getRecordPoint()
		-- 			self.tv:reloadData()
		-- 	        self:doUserHandler()
		-- 			if nextHasMore then
		-- 				recordPoint.y=(num-nowNum)*self.cellHeight+recordPoint.y
		-- 			else
		-- 				recordPoint.y=(num-nowNum+1)*self.cellHeight+recordPoint.y
		-- 			end
		-- 			self.tv:recoverToRecordPoint(recordPoint)
		-- 		end
		-- 	end
		-- 	local page=rData.page+1
		-- 	socketHelper:ranking(self.selectedTabIndex+1,page,rankingHandler)
		-- end
  --   end
end

function friendsSysDialog:dispose()
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





