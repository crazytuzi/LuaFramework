--[[	
	文件名称：QUIDialogGloryArenaRank.lua
	创建时间：2016-09-01 22:54:18
	作者：nieming
	描述：QUIDialogGloryArenaRank
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogGloryArenaRank = class("QUIDialogGloryArenaRank", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetGloryArenaRank = import("..widgets.QUIWidgetGloryArenaRank")
local QRichText = import("...utils.QRichText")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
--初始化
function QUIDialogGloryArenaRank:ctor(options)
	local ccbFile = "Dialog_GloryArena_phjl.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogGloryArenaRank._onTriggerClose)},
		{ccbCallbackName = "onTriggerQuanfu", callback = handler(self, QUIDialogGloryArenaRank._onTriggerQuanfu)},
		{ccbCallbackName = "onTriggerBenfu", callback = handler(self, QUIDialogGloryArenaRank._onTriggerBenfu)},
	}
	QUIDialogGloryArenaRank.super.ctor(self,ccbFile,callBacks,options)
	--代码
	if not options then
		options = {}
	end
	self.isAnimation = true
	self._curTab = options.curTab or 1
	self._quanfuServerData = options.quanfuServerData

	self._data = {}
	self._myInfo = {}
	setShadow5(self._ccbOwner.tab_benfu_label)
	setShadow5(self._ccbOwner.tab_quanfu_label)

	self._quanFuMyInfo = {}
	self._quanFuMyInfo.isQuanqu = true 
	self._benFuMyInfo = {}

	if self._curTab == 1 then
		self._myInfo = self._quanFuMyInfo
	else
		self._myInfo = self._benFuMyInfo
	end

	self._animationFinish = false
	self:getDataFromServer()


	self:render(true)
end



function QUIDialogGloryArenaRank:getDataFromServer(  )
	-- body
	if self._curTab == 1 then
		local function getQuanFuData( data )
			-- body
			if data.rankings == nil or data.rankings.top50 == nil then 
				self:render()
				return 
			end
			local tempList = {}
			tempList = clone(data.rankings.top50)
			table.sort(tempList, function (x, y)
				return x.rank < y.rank
			end)

			local quanFuAwards =  QStaticDatabase.sharedDatabase():getGloryArenaQuanfuAwards()
			for _, rankInfo in pairs(tempList) do
				for _, value in pairs(quanFuAwards) do
					if value.rank_1 <= rankInfo.rank and value.rank_2 >= rankInfo.rank then
						local awardStr = value.awards or ""
						local awardsStrArr = string.split(awardStr, ";")
						local awardsArr = {}
						for k, v in pairs(awardsStrArr) do
							local tempAwards = string.split(v, "^")
							if tempAwards and #tempAwards == 2 then
								table.insert(awardsArr, {id = tempAwards[1],count = tempAwards[2]})
							end 
						end
						rankInfo.isQuanqu = true
						rankInfo.awards = awardsArr
					end
				end


				rankInfo.title = QStaticDatabase.sharedDatabase():getGloryArenaChenghaoID(rankInfo.rank)
			end
			self._quanfuData = tempList

			if remote.tower.canJoinGloryArena then

				local myInfo = data.rankings.myself

				for _, value in pairs(quanFuAwards) do
					if value.rank_1 <= myInfo.rank and value.rank_2 >= myInfo.rank then
						local awardStr = value.awards or ""
						local awardsStrArr = string.split(awardStr, ";")
						local awardsArr = {}
						for k, v in pairs(awardsStrArr) do
							local tempAwards = string.split(v, "^")
							if tempAwards and #tempAwards == 2 then
								table.insert(awardsArr, {id = tempAwards[1],count = tempAwards[2]})
							end 
						end
						myInfo.awards = awardsArr
					end
				end
				myInfo.isQuanqu = true
				myInfo.title = QStaticDatabase.sharedDatabase():getGloryArenaChenghaoID(myInfo.rank)

				self._quanFuMyInfo = myInfo
			end
			self._data = self._quanfuData
			self._myInfo = self._quanFuMyInfo

			
			if self._animationFinish then
				self:render()
			end
		end

		if self._quanfuServerData then
			getQuanFuData(self._quanfuServerData)			
		else
			app:getClient():top50RankRequest("GLORY_COMPETITION_REALTIME_TOP_50", remote.user.userId, getQuanFuData)
		end
	else
		local function getBenFuData( data )
			if data.rankings == nil or data.rankings.top50 == nil then 
				self:render()
				return 
			end
			local tempList = {}
			tempList = clone(data.rankings.top50)
			table.sort(tempList, function (x, y)
				return x.rank < y.rank
			end)

			local benfuAwards =  QStaticDatabase.sharedDatabase():getGloryArenaBenfuAwards()
			for _, rankInfo in pairs(tempList) do
				for _, value in pairs(benfuAwards) do
					if value.rank_1 <= rankInfo.rank and value.rank_2 >= rankInfo.rank then
						local awardStr = value.awards or ""
						local awardsStrArr = string.split(awardStr, ";")
						local awardsArr = {}
						for k, v in pairs(awardsStrArr) do
							local tempAwards = string.split(v, "^")
							if tempAwards and #tempAwards == 2 then
								table.insert(awardsArr, {id = tempAwards[1],count = tempAwards[2]})
							end 
						end
						rankInfo.awards = awardsArr
					end
				end
			end
			self._benfuData = tempList

			if remote.tower.canJoinGloryArena then
				local myInfo = data.rankings.myself
				for _, value in pairs(benfuAwards) do
					if value.rank_1 <= myInfo.rank and value.rank_2 >= myInfo.rank then
						local awardStr = value.awards or ""
						local awardsStrArr = string.split(awardStr, ";")
						local awardsArr = {}
						for k, v in pairs(awardsStrArr) do
							local tempAwards = string.split(v, "^")
							if tempAwards and #tempAwards == 2 then
								table.insert(awardsArr, {id = tempAwards[1],count = tempAwards[2]})
							end 
						end
						myInfo.awards = awardsArr
					end
				end
				self._benFuMyInfo = myInfo
			end

			self._data = self._benfuData
			self._myInfo = self._benFuMyInfo
			if self._animationFinish then
				self:render()
			end
		end
		app:getClient():top50RankRequest("GLORY_COMPETITION_ENV_REALTIME_TOP_50", remote.user.userId, getBenFuData)
	end
end


function QUIDialogGloryArenaRank:render( notInitListView )
	-- body
	if self._curTab == 1 then
		self._ccbOwner.tab_quanfu:setHighlighted(true)
		self._ccbOwner.tab_benfu:setHighlighted(false)

		self._ccbOwner.tab_benfu_label_an:setVisible(true)
		self._ccbOwner.tab_benfu_label:setVisible(false)
		self._ccbOwner.tab_quanfu_label_an:setVisible(false)
		self._ccbOwner.tab_quanfu_label:setVisible(true)

	else
		self._ccbOwner.tab_quanfu:setHighlighted(false)
		self._ccbOwner.tab_benfu:setHighlighted(true)

		self._ccbOwner.tab_benfu_label_an:setVisible(false)
		self._ccbOwner.tab_benfu_label:setVisible(true)
		self._ccbOwner.tab_quanfu_label_an:setVisible(true)
		self._ccbOwner.tab_quanfu_label:setVisible(false)

	end
	
	if not notInitListView then
		self:initListView()	
		if #self._data == 0 then
			self._ccbOwner.empty:setVisible(true)
		else
			self._ccbOwner.empty:setVisible(false)
		end
	end
	self:setMyRankWidgetInfo(self._myInfo)
	
end

--describe：
function QUIDialogGloryArenaRank:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:close()
end


function QUIDialogGloryArenaRank:initListView(  )
	-- body
	if not self._listviewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._data[index]

	            local item = list:getItemFromCache()
	            if not item then	            	
	            	item = QUIWidgetGloryArenaRank.new()
	                isCacheNode = false
	            end
	            item:setInfo(data)
	            info.item = item
	            info.size = item:getContentSize()
	            --注册事件
	    	    list:registerClickHandler(index,"self", function (  )
             		return true
             	end, nil, "onClickItem")
	            return isCacheNode
	        end,
	     
	     	ignoreCanDrag = true,
	      	-- spaceY = 2,
	        topShadow = self._ccbOwner.top_shadow,
	        bottomShadow = self._ccbOwner.bottom_shadow,

	        totalNumber = #self._data
		}

		-- if remote.tower.canJoinGloryArena then
			self._listviewLayout = QListView.new(self._ccbOwner.listview,cfg)
		-- else
		-- 	self._listviewLayout = QListView.new(self._ccbOwner.listviewLong,cfg)
		-- end
	else
		self._listviewLayout:reload({totalNumber = #self._data})
	end
end


function QUIDialogGloryArenaRank:setMyRankWidgetInfo( info )
	-- body
	if not info then
		info = {}
	end
	info.name = info.name or remote.user.nickname
	info.level = info.level or remote.user.level
	info.rank = info.rank or 0
	info.vip = info.vip or QVIPUtil:VIPLevel()
	info.avatar = info.avatar or remote.user.avatar
	info.game_area_name = info.game_area_name or remote.selectServerInfo.name
    

	self._ccbOwner.serverName:setString(info.game_area_name)

	if info.rank > 0 then
		self._ccbOwner.rank:setVisible(true)
		self._ccbOwner.rank:setString(info.rank )
		self._ccbOwner.noRank:setVisible(false)
	else
		self._ccbOwner.rank:setVisible(false )
		self._ccbOwner.noRank:setVisible(true)
	end
	
	self._ccbOwner.nickName:setString(info.name)
	self._ccbOwner.level:setString(string.format("LV.%d",info.level))
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

	if not info.awards or #info.awards == 0 then
		self._ccbOwner.noAwards:setVisible(true)
		-- self._ccbOwner.noAwards:setString("无")
	else
		self._ccbOwner.noAwards:setVisible(false)
	end


	if not self._richTextNode then
		self._richTextNode = QRichText.new()
		self._ccbOwner.richText:addChild(self._richTextNode)
	end
	local cfg = {}

	if info.isQuanqu then
		table.insert(cfg, {oType = "font", content = "称号奖励： ",size = 20,color = ccc3(255,255,255)})
		if info.title and info.title > 0 then
			local titleBox = QUIWidgetHeroTitleBox.new()
		    titleBox:setTitleId(info.title)
		    titleBox:setScale(0.5)
		    local size = titleBox:boundingBox().size
            local defaultOffset = ccp(size.width/2, size.height/2 + 3)
		    table.insert(cfg, {oType = "node", node = titleBox, offset= defaultOffset})
		else
			table.insert(cfg, {oType = "font", content = "无",size = 20,color = ccc3(84,248,0)})
		end
		
	else
		table.insert(cfg, {oType = "font", content = "全服排行： ",size = 20,color = ccc3(255,255,255)})
		table.insert(cfg, {oType = "font", content = info.rankValue or "未入榜" or "无",size = 20,color = ccc3(84,248,0)})
	end

	self._richTextNode:setString(cfg)
	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(remote.user.nightmareDungeonPassCount or 0)
	if config ~= nil then
		self._ccbOwner.sp_badge:setVisible(true)
		self._ccbOwner.sp_badge:setTexture(CCTextureCache:sharedTextureCache():addImage(config.alphaicon))
	else
		self._ccbOwner.sp_badge:setVisible(false)
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

			local itemType = remote.items:getItemType(v.id)
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


--describe：
function QUIDialogGloryArenaRank:_onTriggerQuanfu()
	--代码
	if self._curTab  == 1 then
		self._ccbOwner.tab_quanfu:setHighlighted(true)
		return 
	end
	app.sound:playSound("common_switch")
	self._curTab = 1
	self._listviewLayout:clear()
	if self._quanfuData then
		self._data = self._quanfuData
		self._myInfo = self._quanFuMyInfo
		self:render()
	else
		self:getDataFromServer()
	end
	
end

--describe：
function QUIDialogGloryArenaRank:_onTriggerBenfu()
	--代码
	if self._curTab  == 2 then
		self._ccbOwner.tab_benfu:setHighlighted(true)
		return 
	end
	app.sound:playSound("common_switch")
	self._curTab = 2
	self._listviewLayout:clear()
	if self._benfuData then
		self._data = self._benfuData
		self._myInfo = self._benFuMyInfo
		self:render()
	else
		self:getDataFromServer()
	end
end

--describe：关闭对话框
function QUIDialogGloryArenaRank:close( )
	self:playEffectOut()
end



--describe：viewAnimationOutHandler 
function QUIDialogGloryArenaRank:viewAnimationOutHandler()
	--代码
end

function QUIDialogGloryArenaRank:viewDidAppear()
	QUIDialogGloryArenaRank.super.viewDidAppear(self)
	--代码
end

function QUIDialogGloryArenaRank:viewWillDisappear()
	QUIDialogGloryArenaRank.super.viewWillDisappear(self)
	--代码
end

function QUIDialogGloryArenaRank:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

--describe：viewAnimationInHandler 
function QUIDialogGloryArenaRank:viewAnimationInHandler()
	--代码
	self._animationFinish = true
	self:render()
end

--describe：点击Dialog外  事件处理 
function QUIDialogGloryArenaRank:_backClickHandler()
	--代码
	app.sound:playSound("common_cancel")
	self:close()
end

return QUIDialogGloryArenaRank
