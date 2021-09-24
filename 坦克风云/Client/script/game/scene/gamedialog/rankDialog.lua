--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/rank/rankVoApi"

rankDialog=commonDialog:new()

function rankDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.valueLabel=nil
	self.chackLabel=nil
	self.labelTab={}
	self.cellHeight=68
    return nc
end

function rankDialog:resetTab()

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
end

--设置对话框里的tableView
function rankDialog:initTableView()
	--[[
	local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function cellClick(hd,fn,idx)
	end
	local backSprie1 =LuaCCScale9Sprite:create("panelItemBg.png",rect,capInSet,cellClick)
	backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.bgLayer:getContentSize().height-245))
	backSprie1:ignoreAnchorPointForPosition(false)
	backSprie1:setAnchorPoint(ccp(0,0))
	backSprie1:setPosition(20,20)
	backSprie1:setIsSallow(false)
	backSprie1:setTouchPriority(-41)
	self.bgLayer:addChild(backSprie1)
	]]
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/datebaseShow.plist")--acMjzx2Image
    spriteController:addTexture("public/datebaseShow.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	spriteController:addPlist("public/chatVipNoLevel.plist")
	spriteController:addTexture("public/chatVipNoLevel.png")
	if not self.layerNum then
		self.layerNum=3
	end
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-260),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,50))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function rankDialog:getDataByType(type)
	if type==nil then
		type=0
	end	
	if type <2 then
		local function rankingHandler(fn,data)
	        if base:checkServerData(data)==true then
	        	if self:isClosed()==true then
	        		do return end
	        	end
				if self~=nil and self.tv~=nil then
		            self.tv:reloadData()
		            self:doUserHandler()
				end
	        end
		end
	    local rankData=rankVoApi:getRank(type)
		if rankData.selfRank==nil or SizeOfTable(rankData.selfRank)==0 then
	        socketHelper:ranking(type+1,1,rankingHandler)
		end
	else
		local function callback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if self:isClosed()==true then
	        		do return end
	        	end
				if sData and sData.ranklist then
					local length=#(sData.ranklist)
					if(length<20)then
						playerVoApi.rankAllLoaded=true
					end
					for i=1,length do
						playerVoApi.rankList[i]=sData.ranklist[i]
					end
					self.tv:reloadData()
					self:doUserHandler()
				end
				
			end
		end
		if playerVoApi.rankList==nil or SizeOfTable(playerVoApi.rankList) == 0 then
			socketHelper:userGetnewranklist(1,callback)
		end
	end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function rankDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
	   local hasMore,num
	   if self.selectedTabIndex<2 then
		   hasMore =rankVoApi:hasMore(self.selectedTabIndex)
		   num =rankVoApi:getRankNum(self.selectedTabIndex)
	   else
	   	   if(playerVoApi.rankAllLoaded)then
	   	   		hasMore=false
	   	   else
	   	   		hasMore=true
	   	   end
	   	   num=#playerVoApi.rankList + 1
	   end
	   if hasMore then--and self.selectedTabIndex<2 then
		   num=num+1
	   end
	   return num
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(400,self.cellHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
		local hasMore=rankVoApi:hasMore(self.selectedTabIndex)
		local num=rankVoApi:getRankNum(self.selectedTabIndex)
		if self.selectedTabIndex==2 then
			if(playerVoApi.rankAllLoaded)then
				hasMore=false
			else
				hasMore=true
			end
			num=#playerVoApi.rankList + 1
		end
	
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)
		local backSprie
		if hasMore and idx==num then
			local function cellClick(hd,fn,idx)
				self:cellClick(idx)
			end
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSetNew,cellClick)
			backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
			backSprie:ignoreAnchorPointForPosition(false)
			backSprie:setAnchorPoint(ccp(0,0))
			backSprie:setIsSallow(false)
			backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
			backSprie:setTag(idx)
			cell:addChild(backSprie,1)
			
			local moreLabel=GetTTFLabel(getlocal("showMore"),24)
			moreLabel:setPosition(getCenterPoint(backSprie))
			backSprie:addChild(moreLabel,2)
			
			do return cell end
		end
		
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
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)
		
		local height=backSprie:getContentSize().height/2
		local widthSpace=50
		
		local selfRank
		local rankData
		
		local rankStr=""
		local nameStr=""
		local levelStr=""
		local valueStr=""
		local powerStr = ""
		if self.selectedTabIndex < 2 then
			if idx==0 then
				selfRank=rankVoApi:getRank(self.selectedTabIndex).selfRank
				if selfRank~=nil then
					uid=selfRank.id
					rankStr=selfRank.rank
					nameStr=selfRank.name
					levelStr=selfRank.level
					valueStr=selfRank.value
					if self.selectedTabIndex==0 then
						powerStr=rankVoApi:getRank(0).selfRank.value
					end
				end
			else
				if rankVoApi:getRank(self.selectedTabIndex).rankData~=nil then
					rankData=rankVoApi:getRank(self.selectedTabIndex).rankData[idx]
					if rankData~=nil then
						uid=rankData.id
						rankStr=rankData.rank
						nameStr=rankData.name
						levelStr=rankData.level
						valueStr=rankData.value
						if self.selectedTabIndex==0 then
							if rankVoApi:getRank(0).rankData[idx] then
								powerStr=rankVoApi:getRank(0).rankData[idx].value
							end
						end
					end
				end
			end
			
			local rankLabel=GetTTFLabel(rankStr,24)
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
		      	rankSp:setPosition(ccp(widthSpace,height))
				backSprie:addChild(rankSp,3)
				rankLabel:setVisible(false)
			end

			local nameLabel=GetTTFLabel(nameStr,24)
			nameLabel:setPosition(widthSpace+130,height)
			cell:addChild(nameLabel,2)
			self.labelTab[idx].nameLabel=nameLabel

			local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),24)
			levelLabel:setPosition(widthSpace+130*2,height)
			cell:addChild(levelLabel,2)
			self.labelTab[idx].levelLabel=levelLabel

			if self.selectedTabIndex==1 then
				local valueLabel=GetTTFLabel(valueStr,24)
				valueLabel:setPosition(widthSpace+130*3-25,height)
				cell:addChild(valueLabel,2)
				self.labelTab[idx].valueLabel=valueLabel
				
				local starIcon = CCSprite:createWithSpriteFrameName("StarIcon.png")
		      	starIcon:setPosition(ccp(widthSpace+130*3+25,height))
				cell:addChild(starIcon,2)
			else
				local valueLabel=GetTTFLabel(FormatNumber(valueStr),24)
				valueLabel:setPosition(widthSpace+130*3-10,height)
				cell:addChild(valueLabel,2)
				self.labelTab[idx].valueLabel=valueLabel
			end
			self.labelTab[idx].uid=uid
			self.labelTab[idx].powerStr=powerStr

			local function playerDetail(  )

	            -- 加入黑名单
	            local function shieldCallback()
	                do return end
	            end

	            local function nilFunc( ... )
	                
	            end
	            local function emailCallBack()
					if tonumber(self.labelTab[idx].uid)==tonumber(playerVoApi:getUid()) then
						--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("player_message_info_tip1"),30)
						smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("player_message_info_tip1"),true,self.layerNum+2)
						return false
					else
						local lyNum=self.layerNum+2
						emailVoApi:showWriteEmailDialog(lyNum,getlocal("email_write"),nameStr,nil,nil,nil,nil,self.labelTab[idx].uid)
						return true
					end
					--self.editMsgBox:setVisible(false)
				end
				local function whisperCallBack()
					if tonumber(self.labelTab[idx].uid)==tonumber(playerVoApi:getUid()) then
						smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("message_scene_whiper_prompt"),true,self.layerNum+2)
						return false
					else
						local senderName=nameStr
						chatVoApi:showChatDialog(self.layerNum+1,1,self.labelTab[idx].uid,senderName,true)
						return true
					end
				end
	            local function func(  )
	            	local userInfoList = rankVoApi:getUserInfo(self.labelTab[idx].uid)
		            local nameContent = nameStr
		            local levelContent = getlocal("alliance_info_level").." Lv."..levelStr
		            local powerContent
		            if self.selectedTabIndex>0 then
		            	powerContent=userInfoList.power
		            else
		            	powerContent=self.labelTab[idx].powerStr
		            end
		            local fcContent=getlocal("player_message_info_power")..": "..tonumber(powerContent)
		            local allianceContent
		            if userInfoList.alliance then
		                allianceContent=getlocal("player_message_info_alliance")..": "..userInfoList.alliance
		            else
		                allianceContent=getlocal("player_message_info_alliance")..": "..getlocal("alliance_info_content")
		            end
		            local content={{nameContent,28,G_ColorYellowPro},{levelContent,22},{fcContent,22},{allianceContent,27}}

		            local vipPicStr = nil
		            -- 日本平台特殊处理，不展示VIP的具体等级
		            local isShowVip = chatVoApi:isJapanV()
		            if userInfoList.vipLevel then
		                if isShowVip then
		                    vipPicStr = "vipNoLevel.png"
		                else
		                    vipPicStr = "Vip"..userInfoList.vipLevel..".png"
		                end
		            end
		            if self.labelTab[idx].uid==playerVoApi:getUid() then
						smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,450),CCRect(0, 0, 400, 400),CCRect(170,80,22,10),getlocal("player_message_info_email"),emailCallBack,getlocal("player_message_info_whisper"),whisperCallBack,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,userInfoList.playerIcon,nil,nil,nil,nil,userInfoList.militaryRank,nil,nil,userInfoList.title,nameContent,vipPicStr,nil,nil,userInfoList.headFrame,self.labelTab[idx].uid)
					else
						smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,530),CCRect(0, 0, 400, 400),CCRect(170,80,22,10),getlocal("player_message_info_email"),emailCallBack,getlocal("player_message_info_whisper"),whisperCallBack,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,userInfoList.playerIcon,getlocal("shield"),shieldCallback,getlocal("addFriends_title"),nilFunc,userInfoList.militaryRank,nil,nil,userInfoList.title,nameContent,vipPicStr,nil,nil,userInfoList.headFrame,self.labelTab[idx].uid)
					end
	            end
	            rankVoApi:socketUserInfo( self.labelTab[idx].uid ,func)
	        end 
			local chackLabel=GetButtonItem("datebaseShow2.png","datebaseShow2.png","datebaseShow2.png",playerDetail,nil,nil,nil)
			local chackLabelMenu=CCMenu:createWithItem(chackLabel)
    		chackLabelMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    		chackLabelMenu:setPosition(G_VisibleSizeWidth-widthSpace-60,height)
			cell:addChild(chackLabelMenu,2)

		else
			
			local rankIconStr =nil--"military_rank_1.png"
			local topIdx = SizeOfTable(rankCfg.rank)
			local listIdx = nil
			local uid
			if idx==0 then
				rankStr=0
				nameStr=playerVoApi:getPlayerName()
				levelStr=playerVoApi:getPlayerLevel()
				valueStr=playerVoApi:getRankPoint()-playerVoApi:getTodayRankPoint()
				uid=tonumber(playerVoApi:getUid())
				for i,v in ipairs(playerVoApi.rankList) do
					if v[4] then --玩家id
						if tonumber(v[4])==tonumber(playerVoApi:getUid()) and v[2]==levelStr then
							listIdx=i
						end
					else
						if v[1] ==nameStr and v[2] ==levelStr then
							listIdx = i
						end
					end
				end
			else
				 rankStr=idx+1
				 nameStr=playerVoApi.rankList[idx][1]
				 levelStr=playerVoApi.rankList[idx][2]
				 valueStr=playerVoApi.rankList[idx][3]
				 uid=playerVoApi.rankList[idx][4]
			 	 listIdx =idx
			end
			if idx >SizeOfTable(self.labelTab)-1 then
				table.insert(self.labelTab,idx,{rankLabel=rankStr})--新增的排名未创建 因为目前不需要
			end
			for i=1,topIdx do
				local topNum = topIdx+1
				local rankTb = rankCfg.rank[topNum-i]
				if levelStr >= rankTb.lv and valueStr >=rankTb.point and ((SizeOfTable(rankTb.ranking) > 0 and listIdx and  rankTb.ranking[2] >= listIdx) or SizeOfTable(rankTb.ranking) == 0 )then
					rankIconStr =rankTb.icon
					do break end
				end
			end
			if rankIconStr ==nil then
				rankIconStr =rankCfg.rank[1].icon
			end
			rankSp = CCSprite:createWithSpriteFrameName(rankIconStr)
		 	rankSp:setPosition(ccp(widthSpace,height))
			backSprie:addChild(rankSp,3)

			local nameLabel=GetTTFLabel(nameStr,24)
			nameLabel:setPosition(widthSpace+130,height)
			cell:addChild(nameLabel,2)
			self.labelTab[idx].nameLabel=nameLabel

			local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),24)
			levelLabel:setPosition(widthSpace+130*2,height)
			cell:addChild(levelLabel,2)
			self.labelTab[idx].levelLabel=levelLabel

			local valueLabel=GetTTFLabel(FormatNumber(valueStr),24)
			valueLabel:setPosition(widthSpace+130*3-10,height)
			cell:addChild(valueLabel,2)
			self.labelTab[idx].valueLabel=valueLabel
			self.labelTab[idx].uid=uid

			local function playerDetail(  )

	            -- 加入黑名单
	            local function shieldCallback()
	                do return end
	            end

	            local function nilFunc( ... )
	                
	            end
	            local function emailCallBack()
					if tonumber(self.labelTab[idx].uid)==tonumber(playerVoApi:getUid()) then
						--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("player_message_info_tip1"),30)
						smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("player_message_info_tip1"),true,self.layerNum+2)
						return false
					else
						local lyNum=self.layerNum+2
						emailVoApi:showWriteEmailDialog(lyNum,getlocal("email_write"),nameStr,nil,nil,nil,nil,self.labelTab[idx].uid)
						return true
					end
					--self.editMsgBox:setVisible(false)
				end
				local function whisperCallBack()
					if tonumber(self.labelTab[idx].uid)==tonumber(playerVoApi:getUid()) then
						--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("player_message_info_tip2"),30)
						smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("message_scene_whiper_prompt"),true,self.layerNum+2)
						return false
					else
						local senderName=nameStr
						chatVoApi:showChatDialog(self.layerNum+1,1,self.labelTab[idx].uid,senderName,true)
						return true
					end
				end
	            local function func(  )
	            	local userInfoList = rankVoApi:getUserInfo(self.labelTab[idx].uid)
		            local nameContent = nameStr
		            local levelContent = getlocal("alliance_info_level").." Lv."..levelStr
		            local powerContent
		            if self.selectedTabIndex>0 then
		            	powerContent=userInfoList.power
		            else
		            	powerContent=self.labelTab[idx].powerStr
		            end
		            local fcContent=getlocal("player_message_info_power")..": "..tonumber(powerContent)
		            local allianceContent
		            if userInfoList.alliance then
		                allianceContent=getlocal("player_message_info_alliance")..": "..userInfoList.alliance
		            else
		                allianceContent=getlocal("player_message_info_alliance")..": "..getlocal("alliance_info_content")
		            end
		            local content={{nameContent,28,G_ColorYellowPro},{levelContent,22},{fcContent,22},{allianceContent,27}}

		            local vipPicStr = nil
		            -- 日本平台特殊处理，不展示VIP的具体等级
		            local isShowVip = chatVoApi:isJapanV()
		            if userInfoList.vipLevel then
		                if isShowVip then
		                    vipPicStr = "vipNoLevel.png"
		                else
		                    vipPicStr = "Vip"..userInfoList.vipLevel..".png"
		                end
		            end
		            if self.labelTab[idx].uid==playerVoApi:getUid() then
						smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,450),CCRect(0, 0, 400, 400),CCRect(170,80,22,10),getlocal("player_message_info_email"),emailCallBack,getlocal("player_message_info_whisper"),whisperCallBack,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,userInfoList.playerIcon,nil,nil,nil,nil,userInfoList.militaryRank,nil,nil,userInfoList.title,nameContent,vipPicStr,nil,nil,userInfoList.headFrame,self.labelTab[idx].uid)
					else
						smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,530),CCRect(0, 0, 400, 400),CCRect(170,80,22,10),getlocal("player_message_info_email"),emailCallBack,getlocal("player_message_info_whisper"),whisperCallBack,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,userInfoList.playerIcon,getlocal("shield"),shieldCallback,getlocal("addFriends_title"),nilFunc,userInfoList.militaryRank,nil,nil,userInfoList.title,nameContent,vipPicStr,nil,nil,userInfoList.headFrame,self.labelTab[idx].uid)
					end
	            end
	            rankVoApi:socketUserInfo( self.labelTab[idx].uid ,func)          
	        end 
			local chackLabel=GetButtonItem("datebaseShow2.png","datebaseShow2.png","datebaseShow2.png",playerDetail,nil,nil,nil)
			local chackLabelMenu=CCMenu:createWithItem(chackLabel)
    		chackLabelMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    		chackLabelMenu:setPosition(G_VisibleSizeWidth-widthSpace-60,height)
			cell:addChild(chackLabelMenu,2)
		end
		--[[
		if idx==0 then
			self:setColor(idx,G_ColorYellow)
		elseif idx==1 then
			self:setColor(idx,G_ColorOrange)
		elseif idx==2 then
			self:setColor(idx,G_ColorPurple)
		elseif idx==3 then
			self:setColor(idx,G_ColorBlue)
		end
		]]
		return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function rankDialog:setColor(idx,color)
	self.labelTab[idx].rankLabel:setColor(color)
	self.labelTab[idx].nameLabel:setColor(color)
	self.labelTab[idx].levelLabel:setColor(color)
	self.labelTab[idx].valueLabel:setColor(color)
end

--点击tab页签 idx:索引
function rankDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
            self.tv:reloadData()
            self:doUserHandler()
			self:getDataByType(idx)
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
function rankDialog:doUserHandler()
	local height=self.bgLayer:getContentSize().height-185
	local widthSpace=80
	if self.rankLabel==nil then
		self.rankLabel=GetTTFLabel(getlocal("RankScene_rank"),24)
		self.rankLabel:setPosition(widthSpace,height)
		self.bgLayer:addChild(self.rankLabel,1)
	end
	
	if self.nameLabel==nil then
		self.nameLabel=GetTTFLabel(getlocal("RankScene_name"),24)
		self.nameLabel:setPosition(widthSpace+130,height)
		self.bgLayer:addChild(self.nameLabel,1)
	end
	
	if self.levelLabel==nil then
		self.levelLabel=GetTTFLabel(getlocal("RankScene_level"),24)
		self.levelLabel:setPosition(widthSpace+130*2,height)
		self.bgLayer:addChild(self.levelLabel,1)
	end
	
	if self.valueLabel==nil then
		self.valueLabel=GetTTFLabel(getlocal("RankScene_power"),24)
		self.valueLabel:setPosition(widthSpace+130*3-10,height)
		self.bgLayer:addChild(self.valueLabel,1)
	end
	if self.chackLabel==nil then
		self.chackLabel=GetTTFLabel(getlocal("alliance_list_check_info"),24)
		self.chackLabel:setPosition(G_VisibleSizeWidth - widthSpace,height)
		self.bgLayer:addChild(self.chackLabel,1)
	end
	if self.selectedTabIndex==0 then
		self.rankLabel:setString(getlocal("RankScene_rank"))
		self.valueLabel:setString(getlocal("RankScene_power"))
	elseif self.selectedTabIndex==1 then
		self.rankLabel:setString(getlocal("RankScene_rank"))
		self.valueLabel:setString(getlocal("RankScene_star_num"))
	elseif self.selectedTabIndex==2 then
		-- self.valueLabel:setString(getlocal("RankScene_honor"))
		self.rankLabel:setString(getlocal("help2_t1_t3"))
		self.valueLabel:setString(getlocal("alliance_medals"))
	end
end


--点击了cell或cell上某个按钮
function rankDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
    	if self.selectedTabIndex < 2 then
			local rData=rankVoApi:getRank(self.selectedTabIndex)
		    local hasMore=rankVoApi:hasMore(self.selectedTabIndex)
		    local num=rankVoApi:getRankNum(self.selectedTabIndex)
			if hasMore and tostring(idx)==tostring(num) then
				PlayEffect(audioCfg.mouseClick)
				local function rankingHandler(fn,data)
					if base:checkServerData(data)==true then
						if self:isClosed()==true then
							do return end
						end
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
		else
			if(playerVoApi.rankAllLoaded==false)then
				local length=#(playerVoApi.rankList)
				local page=math.ceil(length/20)
				page=page + 1
				num=#playerVoApi.rankList
				local function callback(fn,data)
					local ret,sData=base:checkServerData(data)
					if ret==true then
						if self:isClosed()==true then
							do return end
						end
						local length=#(sData.ranklist)
						if(length<20)then
							playerVoApi.rankAllLoaded=true
						end
						if(length==0)then
							do return end
						end
						local startIndex=(page - 1)*20
						for i=1,length do
							table.insert(playerVoApi.rankList,sData.ranklist[i])
						end
						local nowNum=#playerVoApi.rankList
						local recordPoint = self.tv:getRecordPoint()
						self.tv:reloadData()
						if playerVoApi.rankAllLoaded==false then
							recordPoint.y=(num-nowNum)*self.cellHeight+recordPoint.y
						else
							recordPoint.y=(num-nowNum+1)*self.cellHeight+recordPoint.y
						end
						self.tv:recoverToRecordPoint(recordPoint)
						self:doUserHandler()
					end
				end
				socketHelper:userGetnewranklist(page,callback)
			end
		end
    end
end

function rankDialog:dispose()
	spriteController:removePlist("public/datebaseShow.plist")
	spriteController:removeTexture("public/datebaseShow.png")
	spriteController:removePlist("public/chatVipNoLevel.plist")
	spriteController:removeTexture("public/chatVipNoLevel.png")
	self.bgLayer=nil
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.valueLabel=nil
	self.labelTab=nil
	self.cellHeight=nil
	self.chackLabel=nil
	self=nil
end





