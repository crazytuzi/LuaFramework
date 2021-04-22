--[[	
	文件名称：QUIWidgetGloryArenaRank.lua
	创建时间：2016-07-30 09:55:41
	作者：nieming
	描述：QUIWidgetGloryArenaRank
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetGloryArenaRank = class("QUIWidgetGloryArenaRank", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIWidgetGloryArenaRank:ctor(options)
	local ccbFile = "Widget_GloryArena_phjl1.ccbi"
	local callBacks = {
	}
	QUIWidgetGloryArenaRank.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetGloryArenaRank:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetGloryArenaRank:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetGloryArenaRank:setInfo(info)
	--代码
	self._info = info

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
	
	self._ccbOwner.vip:setString("VIP "..info.vip)

	if not self._avatar then
		self._avatar = QUIWidgetAvatar.new(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	    self._ccbOwner.node_headPicture:addChild(self._avatar)
	else
		self._avatar:setInfo(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	end

	self._ccbOwner.serverName:setString(info.game_area_name or "")


	if not self._itemBoxs then
		self._itemBoxs = {}
	end

	if not self._richTextNode then
		self._richTextNode = QRichText.new()
		self._ccbOwner.richText:addChild(self._richTextNode)
	end
	local cfg = {}

	if info.isQuanqu then
		table.insert(cfg, {oType = "font", content = "称号奖励： ",size = 20,color = ccc3(95,43,0)})
		if info.title and info.title > 0 then
			local titleBox = QUIWidgetHeroTitleBox.new()
		    titleBox:setTitleId(info.title)
		    titleBox:setScale(0.5)
		   	local size = titleBox:boundingBox().size
            local defaultOffset = ccp(size.width/2, size.height/2 + 3)
		    table.insert(cfg, {oType = "node", node = titleBox, offset= defaultOffset})
		else
			table.insert(cfg, {oType = "font", content = "无",size = 20,color = ccc3(17,68,0)})
		end
		
	else
		table.insert(cfg, {oType = "font", content = "全服排行： ",size = 20,color = ccc3(95,43,0)})
		table.insert(cfg, {oType = "font", content = info.rankValue or "无",size = 20,color = ccc3(17,68,0)})
	end


	

	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(info.nightmareDungeonPassCount or 0)
	if config ~= nil then
		self._ccbOwner.sp_badge:setVisible(true)
		self._ccbOwner.sp_badge:setTexture(CCTextureCache:sharedTextureCache():addImage(config.alphaicon))
	else
		self._ccbOwner.sp_badge:setVisible(false)
	end

	self._richTextNode:setString(cfg)

	for i=1,4 do
		if info.awards[i] then
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


function QUIWidgetGloryArenaRank:onClickItem(  )
	-- body
	-- printTable(self._info)
	app:getClient():topGloryArenaRankUserRequest(self._info.userId, function(data)
			local fighter = (data.towerFightersDetail or {})[1] or {}
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
                options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
		end)
end
--describe：getContentSize 
function QUIWidgetGloryArenaRank:getContentSize()
	--代码
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetGloryArenaRank
