--
-- Author: wkwang
-- Date: 2014-08-26 21:26:37
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetItemDropInfoCell = class("QUIWidgetItemDropInfoCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")

QUIWidgetItemDropInfoCell.EVENT_LINK = "EVENT_LINK"

function QUIWidgetItemDropInfoCell:ctor(options)
	local ccbFile = options.ccbFile or "ccb/Widget_ItemDropInfo.ccbi"
	local callbacks = {
 		{ccbCallbackName = "onTriggerGoto", callback = handler(self, QUIWidgetItemDropInfoCell._onTriggerGoto)},
  	}
	QUIWidgetItemDropInfoCell.super.ctor(self, ccbFile, callbacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	-- self._ccbOwner.tf_title = setShadow5(self._ccbOwner.tf_title)
	-- self._ccbOwner.tf_count = setShadow5(self._ccbOwner.tf_count)

	self._options = options
	-- printTable(options)
	self._ccbOwner.tf_count:setString("")
	self._ccbOwner.tf_count:setVisible(true)
	self._isOtherType = true
	if options ~= nil and options.map ~= nil and options.dungeon ~= nil then
		self._isOtherType = false
		self:_showDungeonInfo(options.map, options.dungeon, options.targetId, options.needNum)
	else
		self._isOtherType = true
		self:_showOtherInfo(options)
	end

	if options.icon then
		local icon = CCSprite:create( options.icon )
		icon:setVisible(true)
		self._ccbOwner.node_icon:addChild(icon)
	end
	
	self._enabled = true
end

function QUIWidgetItemDropInfoCell:onExit()
	self:removeAllEventListeners()
end

function QUIWidgetItemDropInfoCell:_showDungeonInfo(map, dungeon, targetId, needNum)
	self.map = map
	self.dungeon = dungeon
	self.targetId = targetId
	self.needNum = needNum
	self._ccbOwner.node_pass:setVisible(false)
	self._ccbOwner.node_no_pass:setVisible(false)
	self._ccbOwner.sp_recomm:setVisible(false)
	self._ccbOwner.tf_title:setPositionX(170)
	self._ccbOwner.node_info:setPositionX(0)
	local isRecomm = false

	if self.map.isLock == true and self.map.unlock_team_level <= remote.user.level then
		self._ccbOwner.node_pass:setVisible(true)
		if self.map.dungeon_type == DUNGEON_TYPE.ELITE then
			local fightCount = remote.instance:getFightCountBydungeonId(self.dungeon.id)
			local dungeonConfig = remote.instance:getDungeonById(self.dungeon.id)
			self._ccbOwner.tf_count:setString("（"..fightCount.."/"..dungeonConfig.attack_num.."次）")
		end
		local targetItem = QStaticDatabase:sharedDatabase():getItemByID(targetId)
		-- print("......", targetId, targetItem, targetItem.type, self.map.dungeon_type, DUNGEON_TYPE.ELITE)
		if targetItem and targetItem.break_through and self.dungeon.break_through and targetItem.break_through < self.dungeon.break_through and self.map.dungeon_type == DUNGEON_TYPE.NORMAL then
			self._ccbOwner.sp_recomm:setVisible(true)
			isRecomm = true
		elseif targetItem and targetItem.recommended_type and targetItem.recommended_type == 0 and self.map.dungeon_type == DUNGEON_TYPE.ELITE then
			self._ccbOwner.sp_recomm:setVisible(true)
			isRecomm = true
		elseif targetItem and targetItem.recommended_type and targetItem.recommended_type == 1 and self.map.dungeon_type == DUNGEON_TYPE.NORMAL then
			self._ccbOwner.sp_recomm:setVisible(true)
			isRecomm = true
		elseif targetItem and targetItem.type == ITEM_CONFIG_TYPE.SOUL and self.map.dungeon_type == DUNGEON_TYPE.ELITE then
			self._ccbOwner.sp_recomm:setVisible(true)
			isRecomm = true
		end
	else
		self._ccbOwner.node_no_pass:setVisible(true)
		self._ccbOwner.tf_weitongguan:setString("未通关")
		self._ccbOwner.tf_weitongguan:setVisible(true)
		self._ccbOwner.tf_jiesuo:setVisible(false)
	end

	if isRecomm == false then
		self._ccbOwner.tf_title:setPositionX(100)
	end

	self._ccbOwner.tf_number:setString(self.map.number)
	if self._options.name then
		self._ccbOwner.tf_title:setString(self._options.name)
	end

	local name = self.dungeon.name or ""
	self._ccbOwner.tf_name:setString(name)
end

function QUIWidgetItemDropInfoCell:_showOtherInfo( options )
	self._ccbOwner.tf_number:setString("")
	self._ccbOwner.tf_title:setString( options.name )
	if options.description then
		self._ccbOwner.tf_name:setString( options.description )
	else
		self._ccbOwner.tf_name:setString( "" )
	end
	self._ccbOwner.sp_recomm:setVisible(false)
	self._ccbOwner.node_info:setPositionX(-70)

	local isUnlock = true  -- 是否解锁，默认为解锁
	local isExist = true -- 解锁后是否存在，目前只用于黑市商店
	local isCannotGo = false -- 是否禁止前往
	-- printTable(options)
	if options.configuration then
		isUnlock = app.unlock:checkLock( options.configuration )

		--xurui: WOW-11181 检查黑市商店是否存在
		if options.cname == "BLACK_SHOP" then
			if QVIPUtil:enableBlackMarketPermanent() then
				isExist = true
			else 
				isExist = remote.stores:checkMystoryStoreTimeOut(SHOP_ID.blackShop) 
			end
		elseif options.cname == "WELFARE" then
			isExist = remote.welfareInstance:getLastActiveInstance() > 0
		end
	end

	if options.level_min then
		isUnlock = remote.user.level >= options.level_min
	end

	if options.society_level_min then
		if remote.union.hasUnion() and remote.union.consortia and remote.union.consortia.level then
			isUnlock = (remote.union.consortia.level or 0) >= options.society_level_min
		else
			isUnlock = false
		end
	end

	if options.cname and options.cname == "UNION_FATE" then
		if not remote.union.hasUnion() then
			isUnlock = false
		end
	end

	if options.cname and options.cname == "YUNYING_HUODONG" then
		-- local itemConfig = db:getItemByID(options.targetId)
		-- if itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.ZUOQI then 
			isCannotGo = true
		-- end
	end

	if options.cname and options.cname == "SOCIATY_DRAGON_SHOP" then
		local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
		local openDragonLevel = configuration["sociaty_dragon_fight_open_dragon_level"].value or 5
		local dragonInfo = remote.dragon:getDragonInfo() 
		if (dragonInfo.level or 1) < openDragonLevel then
			isExist = false
		end
	end

	-- 不可前往
	if isCannotGo then
		self._ccbOwner.node_no_pass:setVisible(false)
		self._ccbOwner.node_pass:setVisible(false)
	elseif isUnlock and isExist then
		-- 可跳转
		self._ccbOwner.node_no_pass:setVisible(false)
		self._ccbOwner.node_pass:setVisible(true)
	elseif isUnlock and isExist == false then
		-- 不可跳转，虽然已经开启，但是功能目前关闭，例如黑市时间不到
		self._ccbOwner.node_no_pass:setVisible(true)
		self._ccbOwner.node_pass:setVisible(false)
		self._ccbOwner.tf_weitongguan:setString("未开启")
		self._ccbOwner.tf_weitongguan:setVisible(true)
		self._ccbOwner.tf_jiesuo:setVisible(false)
	else
		-- 不可跳转，功能未开启或者其他条件不符合，比如等级不到
		self._ccbOwner.node_no_pass:setVisible(true)
		self._ccbOwner.node_pass:setVisible(false)
		self._ccbOwner.tf_weitongguan:setVisible(false)
		self._ccbOwner.tf_jiesuo:setVisible(true)
		
		local unlockInfo = app.unlock:getConfigByKey( options.configuration )
		-- QPrintTable(unlockInfo)
		self._ccbOwner.tf_jiesuo:setScale(1)
		if unlockInfo then
			if options.level_min and options.level_min >= unlockInfo.team_level then
				self._ccbOwner.tf_jiesuo:setString(options.level_min.."级解锁")
			elseif options.society_level_min and remote.user.level >= unlockInfo.team_level then
				self._ccbOwner.tf_jiesuo:setString("宗门"..options.society_level_min.."级解锁")
				self._ccbOwner.tf_jiesuo:setPositionX(self._ccbOwner.tf_jiesuo:getPositionX() - 12)
			elseif options.cname and options.cname == "UNION_FATE" then
				self._ccbOwner.tf_jiesuo:setString("加入宗门解锁")
				self._ccbOwner.tf_jiesuo:setPositionX(self._ccbOwner.tf_jiesuo:getPositionX() - 18)
			elseif not unlockInfo.team_level and options.configuration == "UNLOCK_NIGHTMARE" then
				local dungeonConfig = remote.instance:getDungeonById(unlockInfo.dungeon)
				self._ccbOwner.tf_jiesuo:setString("普通副本\n"..dungeonConfig.number.."解锁")
				self._ccbOwner.tf_jiesuo:setScale(0.8)
			else
				self._ccbOwner.tf_jiesuo:setString(unlockInfo.team_level.."级解锁")
			end
		elseif options.level_min then
			self._ccbOwner.tf_jiesuo:setString(options.level_min.."级解锁")
		elseif options.society_level_min then
			self._ccbOwner.tf_jiesuo:setString("宗门"..options.society_level_min.."级解锁")
		end
	end
end

function QUIWidgetItemDropInfoCell:getContentSize()
	return self._ccbOwner.node_bg:getContentSize()
end

function QUIWidgetItemDropInfoCell:setEnabled(b)
	self._enabled = b
end

function QUIWidgetItemDropInfoCell:_onTriggerGoto(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_goto) == false then return end
	app.sound:playSound("common_confirm")
	if self._isOtherType then
		self:dispatchEvent({name = QUIWidgetItemDropInfoCell.EVENT_LINK, shortcutInfo = self._options})
	else
		self:dispatchEvent({name = QUIWidgetItemDropInfoCell.EVENT_LINK, info = self.map, targetId = self.targetId, targetNum = self.needNum})
	end
end

return QUIWidgetItemDropInfoCell