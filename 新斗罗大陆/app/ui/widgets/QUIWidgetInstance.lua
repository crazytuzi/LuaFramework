--
-- Author: Your Name
-- Date: 2014-05-08 10:37:22
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetInstance = class("QUIWidgetInstance", QUIWidget)
local QUIWidgetInstanceHead = import("..widgets.QUIWidgetInstanceHead")
local QUIWidgetInstanceEgg = import("..widgets.QUIWidgetInstanceEgg")

function QUIWidgetInstance:ctor(options)
	local ccbFile
	self._instanceType = options.instanceType
	
	if self._instanceType == DUNGEON_TYPE.WELFARE then
		ccbFile = options.info.file
		self._data = options.info
		self._intMapId = self._data.int_instance_id
	else 
		ccbFile = options.info.data[1].file
		self._data = options.info.data
		self._intMapId = self._data[1].int_instance_id
	end

	self._eggWidget = QUIWidgetInstanceEgg.new({instanceType = self._instanceType, intMapId = self._intMapId, instanceWidget = self})

	local callBacks = {
		{ccbCallbackName = "onTriggerSpecialEgg", callback = handler(self, self._onTriggerSpecialEgg)},
    }
	QUIWidgetInstance.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if self._ccbOwner.node_gray ~= nil then
		makeNodeFromNormalToGray(self._ccbOwner.node_gray)
	end
	self._lastPassId = remote.instance:getLastPassId()
	self._contentWidth = 0
	self._index = options.index
	self._heads = {}
	self:showMapInfo()
end

function QUIWidgetInstance:onEnter()
	if not self._eggWidget then
		self._eggWidget = QUIWidgetInstanceEgg.new({instanceType = self._instanceType, intMapId = self._intMapId, instanceWidget = self})
	end
	self._eggWidget:onEnter()
end

function QUIWidgetInstance:onExit()
	self._heads = {}
	if self._eggWidget then
		self._eggWidget:onExit()
	end
end

function QUIWidgetInstance:addHeadEvent()
	for _,value in pairs(self._heads) do
		value:addEventListener(QUIWidgetInstanceHead.EVENT_CITY_CLICK, handler(self,self.dispatchEvent))
		value:addEventListener(QUIWidgetInstanceHead.EVENT_BOX_CLICK, handler(self,self.dispatchEvent))
	end
end

function QUIWidgetInstance:getWidth()
	-- return self._contentWidth
	return 1136 * 2
end

function QUIWidgetInstance:showMapInfo()
	if self._instanceType == DUNGEON_TYPE.WELFARE then
		for i, value in pairs(self._data.dungeons) do
			local name = ""
			if value.dungeon_isboss == true then
				name = "QUIWidgetInstanceWelfareBoss"
			else
				name = "QUIWidgetInstanceWelfareMonster"
			end
			local node = self._ccbOwner["node" .. #self._heads + 1]
			if node ~= nil then
				local pos = node:convertToWorldSpaceAR(ccp(0,0))
				if pos.x + 50 > self._contentWidth then
					self._contentWidth = pos.x + 200
				end
				local widgetClass = import(app.packageRoot .. ".ui.widgets." .. name)
				local head = widgetClass.new()
				node:addChild(head)
				local isLight = false
				if value.state == remote.welfareInstance.WEI_KAI_QI then
					isLight = false
				else
					isLight = true
				end
				local str = tostring(self._index) .. "-" .. i
				local monsetID = nil
				if value.monster_id ~= -1 then
					monsetID = value.monster_id
				end
				if not value.lastPassAt and value.state == remote.welfareInstance.YI_TONG_GUAN then
					value.lastPassAt = 1
				end
				if value.dungeon_isboss then
					if not value.bossBoxOpened then
						if value.boxState == remote.welfareInstance.KE_KAI_QI then
							value.bossBoxOpened = false
						elseif value.boxState == remote.welfareInstance.YI_KAI_QI then
							value.bossBoxOpened = true
						end
					end
				end
				head:setInfo({dungeon_isboss = value.dungeon_isboss
					, box_coordinate = value.box_coordinate
					, boss_size = value.boss_size
					, stars_high = value.stars_high
					, monster_id = monsetID
					, isLock = isLight
					, number = str
					, dungeon_id = value.dungeon_id
					, int_dungeon_id = value.int_dungeon_id
					, instance_name = self._data.instance_name
					, instance_id = self._data.instance_id
					, dungeon_type = value.dungeon_type
					, dungeon_icon = value.dungeon_icon
					, unlock_dungeon_id = self._data.unlock_dungeon_id
					, unlock_team_level = value.unlock_team_level
					, file = self._data.file
					, attack_num = value.attack_num
					, dungeonState = value.state
					, word_x = value.word_x
					, word_y = value.word_y
					, info = {
						lastPassAt = value.lastPassAt,
						bossBoxOpened = value.bossBoxOpened
					}})
				table.insert(self._heads, head)
			end
			-- if value.dungeon_isboss == true and value.state == remote.welfareInstance.WEI_KAI_QI then
			-- 	break
			-- end
		end
	else
		for _,value in pairs(self._data) do
			-- if isEnd == true then
			-- 	break
			-- end
			local name = ""
			if value.dungeon_isboss == true then
				if value.dungeon_type == DUNGEON_TYPE.NORMAL then
					name = "QUIWidgetInstanceNormalBoss"
				elseif value.dungeon_type == DUNGEON_TYPE.ELITE then
					name = "QUIWidgetInstanceEliteBoss"
				elseif value.dungeon_type == DUNGEON_TYPE.WELFARE then
					name = "QUIWidgetInstanceEliteBoss"
				end
			else
				if value.dungeon_type == DUNGEON_TYPE.NORMAL then
					name = "QUIWidgetInstanceNormalMonster"
				elseif value.dungeon_type == DUNGEON_TYPE.ELITE then
					name = "QUIWidgetInstanceEliteMonster"
				elseif value.dungeon_type == DUNGEON_TYPE.WELFARE then
					name = "QUIWidgetInstanceEliteMonster"
				end
			end
			local node = self._ccbOwner["node"..#self._heads+1]
			-- if value.dungeon_isboss == true and (value.info == nil or value.info.star == nil or value.info.star == 0) then
			-- 	isEnd = true
			-- end
			if node ~= nil then
				local pos = node:convertToWorldSpaceAR(ccp(0,0))
				if pos.x + 50 > self._contentWidth then
					self._contentWidth = pos.x + 200
				end
				local widgetClass = import(app.packageRoot .. ".ui.widgets." .. name)
				local head = widgetClass.new()
				node:addChild(head)
				head:setInfo(value, self._lastPassId == value.dungeon_id)

				table.insert(self._heads, head)
			end
		end
	end

	self:addHeadEvent()
end

function QUIWidgetInstance:getLastDungeon(id)
	for index,value in pairs(self._heads) do
		if value:getDungeonId() == id then
			return value
		end
	end
end

function QUIWidgetInstance:getLastHead()
	local index = 1
	while true do
		if self._ccbOwner["node"..index] == nil then
			return self._ccbOwner["node"..index-1]
		end
		index = index + 1
	end
end

function QUIWidgetInstance:_onTriggerSpecialEgg(e, target)
	if self._eggWidget then
		self._eggWidget:onTriggerSpecialEgg(e, target)
	end
end

return QUIWidgetInstance