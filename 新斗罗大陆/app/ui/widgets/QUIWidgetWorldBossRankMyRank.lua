-- @Author: xurui
-- @Date:   2016-11-01 17:50:21
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-04-15 21:14:23
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetWorldBossRankMyRank = class("QUIWidgetWorldBossRankMyRank", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetWorldBossRankMyRank:ctor(options)
	local ccbFile = "ccb/Widget_Panjun_paihang2.ccbi"
	local callBack = {
		{ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetWorldBossRankMyRank.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetWorldBossRankMyRank:onEnter()
end

function QUIWidgetWorldBossRankMyRank:onExit()
end

function QUIWidgetWorldBossRankMyRank:setSoulTowerInfo(info, awardsType)
	self._info = info

	self._ccbOwner.node_award:setVisible(false)
	if not info  then
		info = {}
		info.rank = 0
	end
	info.name = info.name or remote.user.nickname
	info.level = info.level or remote.user.level
	info.rank = info.rank or 0	
	self._ccbOwner.serverName:setVisible(false)

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
	if info.vip then
		self._ccbOwner.vip:setVisible(true)
		self._ccbOwner.vip:setString("VIP "..info.vip)
	else
		self._ccbOwner.vip:setVisible(false)
	end		
	self._ccbOwner.tf_name1:setString("最高击退：")
	self._ccbOwner.score:setString((self._info.dungeonId or 0).."-"..(self._info.wave or 0))

	self._ccbOwner.tf_name2:setString("击退时间：")
	local passTime = string.format("%0.2f秒", tonumber(info.passTime or 0) / 1000.0 )	
	self._ccbOwner.noAwards:setString(passTime)
	q.autoLayerNode({self._ccbOwner.tf_name2,self._ccbOwner.noAwards},"x",5)
	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	local avatar = self._info.avatar
	if self._info.avatar then
		self._avatar = QUIWidgetAvatar.new()
	elseif self._info.icon then
		self._avatar = QUnionAvatar.new()
		self._avatar:setConsortiaWarFloor(self._info.consortiaWarFloor)
		avatar = self._info.icon
	end
	if self._avatar then
		self._avatar:setInfo(avatar)
		self._avatar:setSilvesArenaPeak(self._info.championCount)
	    self._ccbOwner.node_headPicture:addChild(self._avatar)
	end

end

function QUIWidgetWorldBossRankMyRank:setInfo(info, awardsType)
	self._info = info

	if not info  then
		info = {}
		info.rank = 0
	end
	info.name = info.name or remote.user.nickname
	info.level = info.level or remote.user.level
	info.rank = info.rank or 0

	self._ccbOwner.serverName:setVisible(false)

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
	if info.vip then
		self._ccbOwner.vip:setVisible(true)
		self._ccbOwner.vip:setString("VIP "..info.vip)
	else
		self._ccbOwner.vip:setVisible(false)
	end

	local score = self._info.intrusionAllHurt or 0
	self._ccbOwner.tf_name1:setString("个人荣誉:")
	if awardsType == 3 then
		score = self._info.worldBossHurt or 0
		self._ccbOwner.tf_name1:setString("宗门荣誉:")
	end
	local num, str = q.convertLargerNumber(math.floor(score/1000))
	self._ccbOwner.score:setString(num..(str or ""))

	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	local avatar = self._info.avatar
	if self._info.avatar then
		self._avatar = QUIWidgetAvatar.new()
	elseif self._info.icon then
		self._avatar = QUnionAvatar.new()
		self._avatar:setConsortiaWarFloor(self._info.consortiaWarFloor)
		avatar = self._info.icon
	end
	if self._avatar then
		self._avatar:setInfo(avatar)
		self._avatar:setSilvesArenaPeak(self._info.championCount)
	    self._ccbOwner.node_headPicture:addChild(self._avatar)
	end


	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(remote.user.nightmareDungeonPassCount or 0)
	if config ~= nil then
		self._ccbOwner.sp_badge:setVisible(true)
		self._ccbOwner.sp_badge:setTexture(CCTextureCache:sharedTextureCache():addImage(config.alphaicon))
	else
		self._ccbOwner.sp_badge:setVisible(false)
	end

	if not self._itemBoxs then
		self._itemBoxs = {}
	end

	local awardsRank = self:getAwardsRank(info.rank, awardsType)
	local items = QStaticDatabase:sharedDatabase():getLuckyDraw(awardsRank)
	for i=1,4 do
		if items and items["type_"..i] then
			self._ccbOwner["item"..i]:setVisible(true)
			self._ccbOwner["count"..i]:setVisible(true)
			local itemBox = self._itemBoxs[i]
			if not itemBox then
				itemBox = QUIWidgetItemsBox.new()
				-- itemBox:setScale(0.3)
				self._itemBoxs[i] = itemBox
				self._ccbOwner["item"..i]:addChild(itemBox)
			end

			itemBox:setGoodsInfo(items["id_"..i], items["type_"..i])
			self._ccbOwner["count"..i]:setString("x"..items["num_"..i])
		else
			self._ccbOwner["item"..i]:setVisible(false)
			self._ccbOwner["count"..i]:setVisible(false)
		end
	end
end

function QUIWidgetWorldBossRankMyRank:getAwardsRank(rank, awardsType)
	if rank == nil then return nil end
	local data = QStaticDatabase:sharedDatabase():getIntrusionRankAwardByLevel(awardsType, remote.user.level)
	table.sort( data, function(a, b) return a.rank < b.rank end )

	for i = 1, #data do
		if ( data[i-1] ~= nil and rank > data[i-1].rank and rank <= data[i].rank ) 
			or data[i].rank == rank then
			return data[i].intrusion_rank
		end
	end
end

return QUIWidgetWorldBossRankMyRank