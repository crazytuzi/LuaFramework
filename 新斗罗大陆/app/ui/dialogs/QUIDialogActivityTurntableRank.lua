--[[	
	文件名称：QUIDialogActivityTurntableRank.lua
	创建时间：2016-07-30 09:49:53
	作者：nieming
	描述：QUIDialogActivityTurntableRank
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogActivityTurntableRank = class("QUIDialogActivityTurntableRank", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QUIWidgetActivityTurntableScoreRank = import("..widgets.QUIWidgetActivityTurntableScoreRank")
local QUIWidgetActivityTurntableAward = import("..widgets.QUIWidgetActivityTurntableAward")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText") 
local QVIPUtil = import("...utils.QVIPUtil")
--初始化
function QUIDialogActivityTurntableRank:ctor(options)
	local ccbFile = "Dialog_WineGod_jifen.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogActivityTurntableRank._onTriggerClose)},
		{ccbCallbackName = "onTriggerAwardsTab", callback = handler(self, QUIDialogActivityTurntableRank._onTriggerAwardsTab)},
		{ccbCallbackName = "onTriggerScoreRankTab", callback = handler(self, QUIDialogActivityTurntableRank._onTriggerScoreRankTab)},

		{ccbCallbackName = "onTriggerEliteAwardsTab", callback = handler(self, QUIDialogActivityTurntableRank._onTriggerEliteAwardsTab)},
		{ccbCallbackName = "onTriggerEliteScoreRankTab", callback = handler(self, QUIDialogActivityTurntableRank._onTriggerEliteScoreRankTab)},	
	}
	QUIDialogActivityTurntableRank.super.ctor(self,ccbFile,callBacks,options)
	--代码
	if not options then
		options = {}
	end
	self._curTab = options.curTab or 1
	-- self._scoreRankData = {}
	self._awardsData = {}
	self._eliteAwardsData = {}
	self._myRankInfo = {}
	self._myEliteRankInfo = {}

	self.isAnimation = true
	self._rowNum = options.rowNum or 1
	self._type = options.rankType or "turntable"

	-- setShadow5(self._ccbOwner.scoreTabName)
	-- setShadow5(self._ccbOwner.awardsTabName)
	-- setShadow5(self._ccbOwner.tabEliteAwardName)
	-- setShadow5(self._ccbOwner.tabEliteRankName)
	self:render()
end


function QUIDialogActivityTurntableRank:getAwardsData( ... )
	-- body
	if self._type == "turntable" then
		local staticData = QStaticDatabase:sharedDatabase():getTurntableRankAwardByRowNum(self._rowNum) or {}
		self._awardsData = {}
		self._eliteAwardsData = {}
		
		for k, v in pairs(staticData) do
			local temp = {}
			temp.rank_1 = v.rank_1
			temp.rank_2 = v.rank_2
			local awards = {}
			local items = string.split(v.awards, ";") 
			local count = #items
			for i=1,count,1 do
				local obj = string.split(items[i], "^")
		        if #obj == 2 then
		        	table.insert(awards, {id = obj[1], count = tonumber(obj[2])})
		        end
			end
			temp.awards = awards
			temp.description = v.description
			if v.super_list == 1 then
				table.insert(self._eliteAwardsData, temp)
			else
				table.insert(self._awardsData, temp)
			end
		end
	elseif self._type == "divination" then
		local divinationInfo = QStaticDatabase:sharedDatabase():getDivinationShowInfo(self._rowNum) or {}
		local curServerData, allServerData = QStaticDatabase:sharedDatabase():getDivinationRankAwards(divinationInfo.rank_reward_benfu, divinationInfo.rank_reward_quanfu) 
		self._awardsData = {}
		self._eliteAwardsData = {}
		for k ,v in pairs(curServerData) do
			local temp = {}
			if remote.user.level <= v.level_max and remote.user.level >= v.level_min then
				temp.rank_2 = v.rank
				temp.awards = QStaticDatabase.sharedDatabase():getluckyDrawById(v.lucky_draw) or {}
				table.insert(self._awardsData, temp)
			end
		end
		table.sort( self._awardsData, function ( a, b )
			-- body
			return a.rank_2 < b.rank_2
		end )

		for i = 1, #self._awardsData do
			local temp = self._awardsData[i]
			if i > 1 then
				temp.rank_1 = self._awardsData[i - 1].rank_2 + 1
				if temp.rank_1 == temp.rank_2 then
					temp.description = string.format("占卜积分本服第%d名奖励", temp.rank_1)
				else
					temp.description = string.format("占卜积分本服第%d-%d名奖励", temp.rank_1, temp.rank_2)
				end
			else
				temp.rank_1 = 1
				temp.description = string.format("占卜积分本服第%d奖励", temp.rank_1)
			end
		end


		for k ,v in pairs(allServerData) do
			local temp = {}
			if remote.user.level <= v.level_max and remote.user.level >= v.level_min then
				temp.rank_2 = v.rank
				temp.awards = QStaticDatabase.sharedDatabase():getluckyDrawById(v.lucky_draw) or {}
				table.insert(self._eliteAwardsData, temp)
			end
		end
		table.sort( self._eliteAwardsData, function ( a, b )
			-- body
			return a.rank_2 < b.rank_2
		end )

		for i = 1, #self._eliteAwardsData do
			local temp = self._eliteAwardsData[i]
			if i >1 then
				temp.rank_1 = self._eliteAwardsData[i - 1].rank_2 + 1
				if temp.rank_1 == temp.rank_2 then
					temp.description = string.format("占卜积分跨服第%d名奖励", temp.rank_1)
				else
					temp.description = string.format("占卜积分跨服第%d-%d名奖励", temp.rank_1, temp.rank_2)
				end
			else
				temp.rank_1 = 1
				temp.description = string.format("占卜积分跨服第%d奖励", temp.rank_1)
			end
		end
	end
end

function QUIDialogActivityTurntableRank:setRichText(  )
	-- body
	if not self._richtext  then
		self._richtext = QRichText.new(nil,560,{autoCenter = true})
		self._ccbOwner.richText:addChild(self._richtext)
	end
	local cfg = {}
	if self._type == "turntable" then
		if self._curTab == 4 then
			local scoreConf = tostring(remote.activityRounds:getTurntable():getRankScoreCondition() or 0)
			table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[12]})
			string.gsub(scoreConf,"([0-9])",function ( value )
				-- body
				table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[value+1]})

			end)
			table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[11]})
			table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[13]})
			
		else
			table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[13]})
		end
	elseif self._type == "divination" then
		if self._curTab == 4 then
			local imp = remote.activityRounds:getDivination()
			if imp  then
				local temp = QStaticDatabase:sharedDatabase():getDivinationShowInfo(imp.rowNum) or {}

				local scoreConf = temp.rank_min or 0

			table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[12]})
				string.gsub(scoreConf,"([0-9])",function ( value )
					table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[value+1]})

				end)
				table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[11]})
				table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[13]})
			end
		else
			table.insert(cfg, {oType = "img", fileName = QResPath("PageTreasureChestDraw2_DZP_")[13]})
		end
	end
	self._richtext:setString(cfg)
end

function QUIDialogActivityTurntableRank:getScoreRankData( rankType )
	-- body
	if self._type == "turntable" then
		remote.activityRounds:getTurntable():getRankData(rankType, function ( data )
			-- body
			if rankType == 1 then
				self._curTab = 4
			else
				self._curTab = 2
			end
			local rankData = {}
			local ranks = data.luckyDrawDirectionalGetRanksResponse.ranks or {}
			for k, v in pairs(ranks) do
				local temp = {}
				temp.level = v.level
				temp.avatar = v.avatar
				temp.luckyDrawIntegral = v.luckyDrawIntegral
				temp.vip = v.vip
				temp.name = v.name
				temp.rank = v.rank
				temp.userId = v.userId
				temp.game_area_name = v.game_area_name
				table.insert(rankData, temp)
			end
			if #rankData == 0 then
				self:setRichText()
			end

			local temp = {}
			local myRankInfo = data.luckyDrawDirectionalGetRanksResponse.myself or {}
			temp.level = myRankInfo.level
			temp.avatar = myRankInfo.avatar
			temp.luckyDrawIntegral = myRankInfo.luckyDrawIntegral
			temp.vip = myRankInfo.vip
			temp.name = myRankInfo.name
			temp.rank = myRankInfo.rank
			
			remote.activityRounds:getTurntable():udpateMyRankInfo(rankType == 1, myRankInfo.rank)

			if rankType == 0 then
				for k1,v1 in pairs(self._awardsData) do
					if myRankInfo.rank >= v1.rank_1 and myRankInfo.rank <= v1.rank_2 then
						temp.awards = v1.awards
						break;
					end
				end

				self._scoreRankData = rankData
				self._myRankInfo = temp
				
			else
				for k1,v1 in pairs(self._eliteAwardsData) do
					if myRankInfo.rank >= v1.rank_1 and myRankInfo.rank <= v1.rank_2 then
						temp.awards = v1.awards
						break;
					end
				end

				self._scoreEliteRankData = rankData
				self._myEliteRankInfo = temp
				
			end
		
			self:render()
		end)

	elseif self._type == "divination" then
		remote.activityRounds:getDivination():getRankData(rankType, function ( data )
			-- body
			if rankType == 1 then
				self._curTab = 4
			else
				self._curTab = 2
			end
			local rankData = {}
			local ranks = data.divinationGetRankInfoResponse.top50 or {}
			for k, v in pairs(ranks) do
				local temp = {}
				temp.level = v.level
				temp.avatar = v.avatar
				temp.luckyDrawIntegral = v.divination_score
				temp.vip = v.vip
				temp.name = v.name
				temp.rank = v.rank
				temp.userId = v.userId
				temp.game_area_name = v.game_area_name
				table.insert(rankData, temp)
			end
			if #rankData == 0 then
				self:setRichText()
			end

			local temp = {}
			local myRankInfo = data.divinationGetRankInfoResponse.myself or {}
			myRankInfo.rank = myRankInfo.rank or 0
			temp.level = myRankInfo.level
			temp.avatar = myRankInfo.avatar
			temp.luckyDrawIntegral = myRankInfo.divination_score
			temp.vip = myRankInfo.vip
			temp.name = myRankInfo.name
			temp.rank = myRankInfo.rank
			
			remote.activityRounds:getDivination():udpateMyRankInfo(rankType == 1, myRankInfo.rank)

			if rankType == 0 then
				for k1,v1 in pairs(self._awardsData) do
					if myRankInfo.rank >= v1.rank_1 and myRankInfo.rank <= v1.rank_2 then
						temp.awards = v1.awards
						break;
					end
				end

				self._scoreRankData = rankData
				self._myRankInfo = temp
				
			else
				for k1,v1 in pairs(self._eliteAwardsData) do
					-- print(myRankInfo.rank, v1.rank_1,v1.rank_2)
					if myRankInfo.rank >= v1.rank_1 and myRankInfo.rank <= v1.rank_2 then
						temp.awards = v1.awards
						break;
					end
				end

				self._scoreEliteRankData = rankData
				self._myEliteRankInfo = temp
				
			end
		
			self:render()
		end)
	end


end

function QUIDialogActivityTurntableRank:render(  )
	-- body
	if self._curTab == 1 then
		self:initAwardsListView()
		self._ccbOwner.tabAwards:setHighlighted(true)
		self._ccbOwner.tabScoreRank:setHighlighted(false)
		self._ccbOwner.tabEliteAward:setHighlighted(false)
		self._ccbOwner.tabEliteRank:setHighlighted(false)

		self._ccbOwner.bgShort:setVisible(false)
		self._ccbOwner.bgLong:setVisible(true)
		-- self._ccbOwner.scoreTabName_an:setVisible(true)
		-- self._ccbOwner.scoreTabName:setVisible(false)
		-- self._ccbOwner.tabEliteAwardName_an:setVisible(true)
		-- self._ccbOwner.tabEliteAwardName:setVisible(false)
		-- self._ccbOwner.tabEliteRankName_an:setVisible(true)
		-- self._ccbOwner.tabEliteRankName:setVisible(false)

		-- self._ccbOwner.awardsTabName_an:setVisible(false)
		-- self._ccbOwner.awardsTabName:setVisible(true)

		if self._scoreRanklistviewLayout then
			self._scoreRanklistviewLayout:clear()
			self._scoreRanklistviewLayout:setVisible(false)
		end

		if self._listviewLayout then
			self._listviewLayout:setVisible(true)
		end
		self._ccbOwner.myRankWidget:setVisible(false)
		self._ccbOwner.richText:setVisible(false)
	elseif self._curTab == 2 then
		if #self._scoreRankData == 0  then
			self:setRichText()	
			self._ccbOwner.richText:setVisible(true)
		else
			self._ccbOwner.richText:setVisible(false)
		end

		self:initScroeRankListView()
		-- self._ccbOwner.awardsTabName_an:setVisible(true)
		-- self._ccbOwner.awardsTabName:setVisible(false)
		-- self._ccbOwner.scoreTabName_an:setVisible(false)
		-- self._ccbOwner.scoreTabName:setVisible(true)
		-- self._ccbOwner.tabEliteAwardName_an:setVisible(true)
		-- self._ccbOwner.tabEliteAwardName:setVisible(false)
		-- self._ccbOwner.tabEliteRankName_an:setVisible(true)
		-- self._ccbOwner.tabEliteRankName:setVisible(false)


		self._ccbOwner.tabAwards:setHighlighted(false)
		self._ccbOwner.tabScoreRank:setHighlighted(true)
		self._ccbOwner.tabEliteAward:setHighlighted(false)
		self._ccbOwner.tabEliteRank:setHighlighted(false)

		self._ccbOwner.bgShort:setVisible(true)
		self._ccbOwner.bgLong:setVisible(false)
		if self._scoreRanklistviewLayout then
			self._scoreRanklistviewLayout:setVisible(true)
		end

		if self._listviewLayout then
			self._listviewLayout:clear()
			self._listviewLayout:setVisible(false)
		end
		self:setMyRankWidgetInfo(self._myRankInfo)
		self._ccbOwner.myRankWidget:setVisible(true)
	elseif self._curTab == 3 then
		self:initAwardsListView()
		self._ccbOwner.tabAwards:setHighlighted(false)
		self._ccbOwner.tabScoreRank:setHighlighted(false)
		self._ccbOwner.tabEliteAward:setHighlighted(true)
		self._ccbOwner.tabEliteRank:setHighlighted(false)

		self._ccbOwner.bgShort:setVisible(false)
		self._ccbOwner.bgLong:setVisible(true)

		-- self._ccbOwner.scoreTabName_an:setVisible(true)
		-- self._ccbOwner.scoreTabName:setVisible(false)
		-- self._ccbOwner.tabEliteAwardName_an:setVisible(false)
		-- self._ccbOwner.tabEliteAwardName:setVisible(true)
		-- self._ccbOwner.tabEliteRankName_an:setVisible(true)
		-- self._ccbOwner.tabEliteRankName:setVisible(false)
		-- self._ccbOwner.awardsTabName_an:setVisible(true)
		-- self._ccbOwner.awardsTabName:setVisible(false)

		if self._scoreRanklistviewLayout then
			self._scoreRanklistviewLayout:clear()
			self._scoreRanklistviewLayout:setVisible(false)
		end

		if self._listviewLayout then
			self._listviewLayout:setVisible(true)
		end
		self._ccbOwner.myRankWidget:setVisible(false)
		self._ccbOwner.richText:setVisible(false)
	else
		if #self._scoreEliteRankData == 0 then
			self:setRichText()		
			self._ccbOwner.richText:setVisible(true)
		else
			self._ccbOwner.richText:setVisible(false)
		end
		self:initScroeRankListView()
		-- self._ccbOwner.awardsTabName_an:setVisible(true)
		-- self._ccbOwner.awardsTabName:setVisible(false)
		-- self._ccbOwner.scoreTabName_an:setVisible(true)
		-- self._ccbOwner.scoreTabName:setVisible(false)
		-- self._ccbOwner.tabEliteAwardName_an:setVisible(true)
		-- self._ccbOwner.tabEliteAwardName:setVisible(false)
		-- self._ccbOwner.tabEliteRankName_an:setVisible(false)
		-- self._ccbOwner.tabEliteRankName:setVisible(true)


		self._ccbOwner.tabAwards:setHighlighted(false)
		self._ccbOwner.tabScoreRank:setHighlighted(false)
		self._ccbOwner.tabEliteAward:setHighlighted(false)
		self._ccbOwner.tabEliteRank:setHighlighted(true)

		self._ccbOwner.bgShort:setVisible(true)
		self._ccbOwner.bgLong:setVisible(false)
		if self._scoreRanklistviewLayout then
			self._scoreRanklistviewLayout:setVisible(true)
		end

		if self._listviewLayout then
			self._listviewLayout:clear()
			self._listviewLayout:setVisible(false)
		end
		self:setMyRankWidgetInfo(self._myEliteRankInfo)
		self._ccbOwner.myRankWidget:setVisible(true)
	end
end

function QUIDialogActivityTurntableRank:setMyRankWidgetInfo( info )
	-- body
	if not info  then
		info = {}
		info.rank = 0
	end
	info.name = info.name or remote.user.nickname
	info.level = info.level or remote.user.level
	info.rank = info.rank or 0
	info.vip = info.vip or QVIPUtil:VIPLevel()
	info.avatar = info.avatar or remote.user.avatar


	if info.rank > 0 then
		self._ccbOwner.rank:setVisible(true)
		self._ccbOwner.rank:setString(info.rank )
		self._ccbOwner.noRank:setVisible(false)
	else
		self._ccbOwner.rank:setVisible(false )
		self._ccbOwner.noRank:setVisible(true)
	end
	
	if self._type == "divination" then
		self._ccbOwner.scoreLabel:setString("占卜积分:")
	end

	self._ccbOwner.nickName:setString(info.name)
	self._ccbOwner.level:setString(string.format("LV.%d",info.level))
	self._ccbOwner.score:setString(info.luckyDrawIntegral or 0)
	self._ccbOwner.vip:setString("VIP "..info.vip)

	if not self._avatar then
		self._avatar = QUIWidgetAvatar.new(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	    self._ccbOwner.node_headPicture:addChild(self._avatar)
	else
		self._avatar:setInfo(info.avatar)
	end

	if not self._itemBoxs then
		self._itemBoxs = {}
	end


	if not info.awards then
		local emptyStr = "无（积分%d以上可进入排行榜）"
		local condition = 0
		if self._type == "divination" then
			emptyStr = "无（积分%d以上可进入排行榜）"
			local imp = remote.activityRounds:getDivination()
			if imp  then
				local temp = QStaticDatabase:sharedDatabase():getDivinationShowInfo(imp.rowNum) or {}
				condition = temp.rank_min or 0
			end
		else
			condition = remote.activityRounds:getTurntable():getRankScoreCondition() or 0
		end
		self._ccbOwner.noAwards:setVisible(true)
		if self._curTab == 4 then
			self._ccbOwner.noAwards:setString(string.format(emptyStr, condition))
		else
			self._ccbOwner.noAwards:setString("无")
		end
	else
		self._ccbOwner.noAwards:setVisible(false)
	end

	for i=1,4 do
		if info.awards and info.awards[i] then
			local v = info.awards[i]
			self._ccbOwner["item"..i]:setVisible(true)
			self._ccbOwner["count"..i]:setVisible(true)
			local itemBox = self._itemBoxs[i]
			if not itemBox then
				itemBox = QUIWidgetItemsBox.new()
				-- itemBox:setScale(0.3)
				self._itemBoxs[i] = itemBox
				self._ccbOwner["item"..i]:addChild(itemBox)
			end


			local itemType 
			if v.typeName then
				itemType = remote.items:getItemType(v.typeName)
			else
				itemType = remote.items:getItemType(v.id)
			end

			if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
				itemBox:setGoodsInfo(v.id, itemType)		
			else
				itemBox:setGoodsInfo(v.id, ITEM_TYPE.ITEM)
			end
			self._ccbOwner["count"..i]:setString("x"..v.count)
		else
			self._ccbOwner["item"..i]:setVisible(false)
			self._ccbOwner["count"..i]:setVisible(false)
		end
	end

end

function QUIDialogActivityTurntableRank:initScroeRankListView(  )
	-- body
	if not self._scoreRanklistviewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._curTab == 2 and self._scoreRankData[index] or self._scoreEliteRankData[index]

	            local item = list:getItemFromCache()
	            if not item then	            	
	            	item = QUIWidgetActivityTurntableScoreRank.new()
	                isCacheNode = false
	            end
	            item:setInfo(data, self._type)
	            info.item = item
	            info.size = item:getContentSize()
	            --注册事件
	            -- list:registerClickHandler(index,"self", function (  )
             -- 		return true
             -- 	end, nil, "onClickItem")

	            return isCacheNode
	        end,
	        curOffset = 20,
	        
	     	ignoreCanDrag = true,
	      	spaceY = 5,
	        -- enableShadow = false,
	        totalNumber = self._curTab == 2 and #self._scoreRankData or #self._scoreEliteRankData
		}
		self._scoreRanklistviewLayout = QListView.new(self._ccbOwner.listviewShort,cfg)
	else
		self._scoreRanklistviewLayout:reload({totalNumber = self._curTab == 2 and #self._scoreRankData or #self._scoreEliteRankData})
	end
end

function QUIDialogActivityTurntableRank:initAwardsListView()
	-- body

	if not self._listviewLayout then
		
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._curTab == 1 and self._awardsData[index] or self._eliteAwardsData[index]

	            local item = list:getItemFromCache()
	            if not item then
	            	
	            	item = QUIWidgetActivityTurntableAward.new()
	                isCacheNode = false
	            end
	            item:setInfo(data, self._curTab == 1, self._type)
	           

	            info.item = item
	            info.tag = self._curTab
	            info.size = item:getContentSize()
	            --注册事件
                item:registerItemBoxPrompt(index,list)
                
	            return isCacheNode
	        end,
	     	curOffset = 15,
	      	spaceY = 10,
	        -- enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = self._curTab == 1 and #self._awardsData or #self._eliteAwardsData,
		}
		self._listviewLayout = QListView.new(self._ccbOwner.listview,cfg)
	else
		self._listviewLayout:reload({totalNumber = self._curTab == 1 and #self._awardsData or #self._eliteAwardsData})
	end
end

--describe：
function QUIDialogActivityTurntableRank:_onTriggerClose()
	--代码
	app.sound:playSound("common_cancel")
	self:close()
end

--describe：
function QUIDialogActivityTurntableRank:_onTriggerAwardsTab()
	--代码
	if self._curTab  == 1 then
		self._ccbOwner.tabAwards:setHighlighted(true)
		return 
	end
	app.sound:playSound("common_switch")
	self._curTab = 1
	self:render()
end

--describe：
function QUIDialogActivityTurntableRank:_onTriggerScoreRankTab()
	--代码

	if self._curTab  == 2 then
		self._ccbOwner.tabScoreRank:setHighlighted(true)
		return 
	end
	app.sound:playSound("common_switch")
	
	if self._scoreRankData then
		self._curTab = 2
		self:render()
	else
		if self._scoreRanklistviewLayout then
			self._scoreRanklistviewLayout:clear()
		end
		self:getScoreRankData(0)
	end
	
	
end

function QUIDialogActivityTurntableRank:_onTriggerEliteAwardsTab()
	--代码

	if self._curTab  == 3 then
		self._ccbOwner.tabEliteAward:setHighlighted(true)
		return 
	end
	app.sound:playSound("common_switch")
	self._curTab = 3
	self:render()
end

function QUIDialogActivityTurntableRank:_onTriggerEliteScoreRankTab()
	--代码

	if self._curTab  == 4 then
		self._ccbOwner.tabEliteRank:setHighlighted(true)
		return 
	end
	app.sound:playSound("common_switch")
	
	if self._scoreEliteRankData then
		self._curTab = 4
		self:render()
	else
		if self._scoreRanklistviewLayout then
			self._scoreRanklistviewLayout:clear()
		end
		self:getScoreRankData(1)
	end
	
end

--describe：关闭对话框
function QUIDialogActivityTurntableRank:close( )

	self:playEffectOut()
end



function QUIDialogActivityTurntableRank:viewDidAppear()
	QUIDialogActivityTurntableRank.super.viewDidAppear(self)
	--代码

	
end

function QUIDialogActivityTurntableRank:viewWillDisappear()
	QUIDialogActivityTurntableRank.super.viewWillDisappear(self)
	--代码
end

function QUIDialogActivityTurntableRank:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

--describe：viewAnimationInHandler 
function QUIDialogActivityTurntableRank:viewAnimationInHandler()
	--代码
	self:getAwardsData()
	self:render()
	-- self:getScoreRankData()
end

--describe：点击Dialog外  事件处理 
function QUIDialogActivityTurntableRank:_backClickHandler()
	--代码
	app.sound:playSound("common_cancel")
	self:close()
end

return QUIDialogActivityTurntableRank
