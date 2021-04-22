--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 公会副本二级界面地图
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyDungeonMap = class("QUIWidgetSocietyDungeonMap", QUIWidget)

function QUIWidgetSocietyDungeonMap:ctor(options)
	self._mapIndex = options.mapIndex or 1
	local ccbFile = "ccb/Widget_society_fuben_map"..self._mapIndex..".ccbi"
	assert(ccbFile ~= nil, "QUIWidgetSocietyDungeonMap ccbFile is nil ! mapIndex = "..self._mapIndex)
	local callBacks = {}
	QUIWidgetSocietyDungeonMap.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._config = options.config

	self:_init()
end

function QUIWidgetSocietyDungeonMap:onEnter()
end

function QUIWidgetSocietyDungeonMap:onExit()
end

function QUIWidgetSocietyDungeonMap:_init()
	local index = 1
	while true do
		local nodeBoss = self._ccbOwner["node_boss_"..index]
		if nodeBoss then
			nodeBoss:removeAllChildren()
			-- nodeBoss:removeAllChildrenWithCleanup(true)
			-- nodeBoss:setVisible(false)
			local spriteFrameName = QSpriteFrameByPath("ui/socity_fuben/society_shitou.png")
			local sprite = CCSprite:createWithSpriteFrame(spriteFrameName)
			nodeBoss:addChild(sprite)
		end
		local nodeChest = self._ccbOwner["node_chest_"..index]
		if nodeChest then
			nodeChest:removeAllChildren()
			-- nodeChest:removeAllChildrenWithCleanup(true)
			nodeChest:setVisible(false)
		end
		if not nodeBoss then
			break
		end
		index = index + 1
	end

	-- self:_chooseMapSp()
end

-- function QUIWidgetSocietyDungeonMap:_chooseMapSp()
-- 	-- QPrintTable(self._config)
-- 	if self._mapIndex == 1 then
-- 		if self._config then
-- 			-- 地图一，有2张地图，一张有wave5的坑，一张没有，所以要看下量表配置里面有没有wave5的怪。这是策划要求的，无奈。
-- 			local isFind = false
-- 			for _, value in pairs(self._config) do
-- 				-- print("第一张地图：", value.wave)
-- 				if value.wave == 5 then
-- 					isFind = true
-- 					break
-- 				end
-- 			end
-- 			if not isFind then
-- 				QSetDisplayFrameByPath(self._ccbOwner.sp_bg, "map/socity_fuben_map/summer1_2.jpg")
-- 			end
-- 		end
-- 	elseif self._mapIndex == 2 then
-- 		if self._config then
-- 			-- 地图二，有2张地图，一张有wave5的坑，一张没有，所以要看下量表配置里面有没有wave5的怪。这是策划要求的，无奈。
-- 			local isFind = false
-- 			for _, value in pairs(self._config) do
-- 				-- print("第二张地图：", value.wave)
-- 				if value.wave == 5 then
-- 					isFind = true
-- 					break
-- 				end
-- 			end
-- 			if not isFind then
-- 				QSetDisplayFrameByPath(self._ccbOwner.sp_bg, "map/socity_fuben_map/spring1_1.jpg")
-- 			end
-- 		end
-- 	end
-- end

function QUIWidgetSocietyDungeonMap:getBossNodeByIndex( index )
	local nodeBoss = self._ccbOwner["node_boss_"..index]
	return nodeBoss
end

function QUIWidgetSocietyDungeonMap:getChestNodeByIndex( index )
	local nodeChest = self._ccbOwner["node_chest_"..index]
	return nodeChest
end

function QUIWidgetSocietyDungeonMap:getMapIndex()
	return self._mapIndex
end

function QUIWidgetSocietyDungeonMap:getMapSpByIndex(index)
	return self._ccbOwner["sp_bg"..index]
end

function QUIWidgetSocietyDungeonMap:getMapWidth()
	local mapWidth = 0
	local sp = self._ccbOwner.sp_bg
	if sp then
		mapWidth = sp:getContentSize().width * sp:getScaleX()
	end
	local index = 1
	while true do
		sp = self._ccbOwner["sp_bg"..index]
		if sp then
			mapWidth = mapWidth + sp:getContentSize().width * sp:getScaleX()
			index = index + 1
		else
			break
		end
	end
	return mapWidth
end


return QUIWidgetSocietyDungeonMap