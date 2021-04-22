--[[	
	文件名称：QUIWidgetActivityTurntableScoreRank.lua
	创建时间：2016-07-30 09:55:41
	作者：nieming
	描述：QUIWidgetActivityTurntableScoreRank
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityTurntableScoreRank = class("QUIWidgetActivityTurntableScoreRank", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
--初始化
function QUIWidgetActivityTurntableScoreRank:ctor(options)
	local ccbFile = "Widget_WineGod_jifen2.ccbi"
	local callBacks = {
	}
	QUIWidgetActivityTurntableScoreRank.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetActivityTurntableScoreRank:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetActivityTurntableScoreRank:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetActivityTurntableScoreRank:setInfo(info, rankType)
	--代码
	self._info = info
	if rankType and rankType == "divination" then
		self._ccbOwner.scoreLable:setString("占卜积分:")
	else
		self._ccbOwner.scoreLable:setString("召唤积分:")
	end

	self._ccbOwner.first:setVisible(false)
	self._ccbOwner.second:setVisible(false)
	self._ccbOwner.third:setVisible(false)
	self._ccbOwner.other:setVisible(false)
	if info.rank == 1 then
		self._ccbOwner.first:setVisible(true)

	elseif info.rank == 2 then
		self._ccbOwner.second:setVisible(true)
	elseif info.rank == 3 then
		self._ccbOwner.third:setVisible(true)
	else
		self._ccbOwner.other:setVisible(true)
		self._ccbOwner.other:setString(info.rank )
	end

	self._ccbOwner.nickName:setString(info.name or "")
	self._ccbOwner.level:setString(string.format("LV.%d",info.level or 1))
	self._ccbOwner.score:setString(info.luckyDrawIntegral or "")
	self._ccbOwner.vip:setString("VIP "..info.vip)

	if not self._avatar then
		self._avatar = QUIWidgetAvatar.new(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	    self._ccbOwner.node_headPicture:addChild(self._avatar)
	else
		self._avatar:setInfo(info.avatar)
	end

	if not info.game_area_name or info.game_area_name == "" then
		if remote.selectServerInfo then
        	info.game_area_name = remote.selectServerInfo.name
    	end
	end

	self._ccbOwner.serverName:setString(info.game_area_name or "")

	-- if not self._itemBoxs then
	-- 	self._itemBoxs = {}
	-- end

	-- for i=1,4 do
	-- 	if info.awards[i] then
	-- 		local v = info.awards[i]
	-- 		self._ccbOwner["item"..i]:setVisible(true)
	-- 		self._ccbOwner["count"..i]:setVisible(true)
	-- 		local itemBox = self._itemBoxs[i]
	-- 		if not itemBox then
	-- 			itemBox = QUIWidgetItemsBox.new()
	-- 			-- itemBox:setScale(0.3)
	-- 			self._itemBoxs[i] = itemBox
	-- 			self._ccbOwner["item"..i]:addChild(itemBox)
	-- 		end

	-- 		local itemType = remote.items:getItemType(v.id)
	-- 		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
	-- 			itemBox:setGoodsInfo(v.id, itemType)		
	-- 		else
	-- 			itemBox:setGoodsInfo(v.id, ITEM_TYPE.ITEM)
	-- 		end
	-- 		self._ccbOwner["count"..i]:setString("x"..v.count)
	-- 	else
	-- 		self._ccbOwner["item"..i]:setVisible(false)
	-- 		self._ccbOwner["count"..i]:setVisible(false)
	-- 	end
	-- end
end


function QUIWidgetActivityTurntableScoreRank:onClickItem(  )
	-- body
	-- printTable(self._info)
	app:getClient():topRankUserRequest(self._info.userId, function(data)
			local fighter = data.rankingFighter
			local force = 0
			if fighter.heros ~= nil then
				for _,hero in pairs(fighter.heros) do
					force = force + hero.force
				end
			end
			if fighter.subheros ~= nil then
				for _,hero in pairs(fighter.subheros) do
					force = force + hero.force
				end
			end
			if fighter.sub2heros ~= nil then
				for _,hero in pairs(fighter.sub2heros) do
					force = force + hero.force
				end
			end
			if fighter.sub3heros ~= nil then
				for _,hero in pairs(fighter.sub3heros) do
					force = force + hero.force
				end
			end
			local heros = clone(fighter.heros or {})
			table.sort(heros, function(a, b)
				return a.force < b.force
			end)

			local subheros = clone(fighter.subheros or {})
			table.sort(subheros, function(a, b)
				return a.force < b.force
			end)

			local sub2heros = clone(fighter.sub2heros or {})
			table.sort(sub2heros, function(a, b)
				return a.force < b.force
			end)
			
			local sub3heros = clone(fighter.sub3heros or {})
			table.sort(sub3heros, function(a, b)
				return a.force < b.force
			end)

			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGeneralFigterInfo",
	    		options = {info = {name = self._info.name, level = self._info.level, avatar = self._info.avatar, number = self._info.luckyDrawIntegral, force = force, consortiaName = fighter.consortiaName,
	    		heros = heros or {}, subheros = subheros or {}, sub2heros = sub2heros or {}, sub3heros = sub3heros or {}, text = "召唤积分", vip = self._info.vip}}}, {isPopCurrentDialog = false})
		
		end)
end
--describe：getContentSize 
function QUIWidgetActivityTurntableScoreRank:getContentSize()
	--代码
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetActivityTurntableScoreRank
