local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTopBar = class("QUIWidgetTopBar", QUIWidget)

local QUIWidgetTopBarCell = import("..widgets.QUIWidgetTopBarCell")
local QUIWidgetSunWarTopBarCell = import("..widgets.QUIWidgetSunWarTopBarCell")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetSparFieldTopBarCell = import("..widgets.QUIWidgetSparFieldTopBarCell")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogTavernShowHero = import("..dialogs.QUIDialogTavernShowHero")

function QUIWidgetTopBar:ctor(options)
	QUIWidgetTopBar.super.ctor(self)

	self._bars = {}
	self._customNodes = {}
	self._barInfos = {}

	--[[
		存放topbar的配置信息

		kind，要显示的资源类型
		noSound，点击时不需要音效，默认为false 没有音效
		isShowAdd，是否显示加号，默认为true 显示加号
		itemType，资源的类型，主要用于设置icon和事件监听，特殊类型需要单独处理
					1，代表普通resource；2，代表普通item；3.代表特殊resource；4，代表特殊item
		noAutoUpdata, 是否自动刷新，默认为false 自动刷新
		class, 初始化的类型
		iconScale, 图标的缩放值：默认 0.6
	--]]
	--1，代表普通resource
	self._barInfos[TOP_BAR_TYPE.TOKEN_MONEY] = {kind = ITEM_TYPE.TOKEN_MONEY, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.MONEY] = {kind = ITEM_TYPE.MONEY, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.ENERGY] = {kind = ITEM_TYPE.ENERGY, noSound = true, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.THUNDER_MONEY] = {kind = ITEM_TYPE.THUNDER_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.ARENA_MONEY] = {kind = ITEM_TYPE.ARENA_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.INTRUSION_MONEY] = {kind = ITEM_TYPE.INTRUSION_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.SUNWELL_MONEY] = {kind = ITEM_TYPE.SUNWELL_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.SOULMONEY] = {kind = ITEM_TYPE.SOULMONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.TOWER_MONEY] = {kind = ITEM_TYPE.TOWER_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.CONSORTIA_MONEY] = {kind = ITEM_TYPE.CONSORTIA_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.SILVERMINE_MONEY] = {kind = ITEM_TYPE.SILVERMINE_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.ENCHANT_SCORE] = {kind = ITEM_TYPE.ENCHANT_SCORE, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.GEMSTONE_ENERGY] = {kind = ITEM_TYPE.GEMSTONE_ENERGY, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.GLYPH_MONEY] = {kind = ITEM_TYPE.GLYPH_MONEY, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.STORM_MONEY] = {kind = ITEM_TYPE.STORM_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.TEAM_MONEY] = {kind = ITEM_TYPE.TEAM_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.CRYSTAL_PRIZE] = {kind = ITEM_TYPE.CRYSTAL_PRIZE, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.MOCK_BATTLE_PRIZE] = {kind = ITEM_TYPE.MOCK_BATTLE_PRIZE, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.MOCK_BATTLE_MONEY] = {kind = ITEM_TYPE.MOCK_BATTLE_MONEY, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.GOD_ARM_MONEY] = {kind = ITEM_TYPE.GOD_ARM_MONEY, itemType = 1}	
	self._barInfos[TOP_BAR_TYPE.MARITIME_MONEY] = {kind = ITEM_TYPE.MARITIME_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.DRAGON_STONE] = {kind = ITEM_TYPE.DRAGON_STONE, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.RUSH_BUY_MONEY] = {kind = ITEM_TYPE.RUSH_BUY_MONEY, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.RUSH_BUY_SCORE] = {kind = ITEM_TYPE.RUSH_BUY_SCORE, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.DRAGON_WAR_MONEY] = {kind = ITEM_TYPE.DRAGON_WAR_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.JEWELRY_MONEY] = {kind = ITEM_TYPE.JEWELRY_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.SANCTUARY_MONEY] = {kind = ITEM_TYPE.SANCTUARY_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.MAGICHERB_MONEY] = {kind = ITEM_TYPE.MAGICHERB_MONEY, itemType = 1, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.PRIZE_WHEEL_MONEY] = {kind = ITEM_TYPE.PRIZE_WHEEL_MONEY, itemType = 1, noAutoUpdata = true}
	self._barInfos[TOP_BAR_TYPE.RAT_FESTIVAL_MONEY] = {kind = ITEM_TYPE.RAT_FESTIVAL_MONEY, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.CHECK_IN_MONEY] = {kind = ITEM_TYPE.CHECK_IN_MONEY, itemType = 1}
	
	self._barInfos[TOP_BAR_TYPE.SILVESARENA_SHOP_MONEY] = {kind = ITEM_TYPE.SILVESARENA_SHOP_MONEY, itemType = 1}
	self._barInfos[TOP_BAR_TYPE.SILVESARENA_SHOP_GOLD] = {kind = ITEM_TYPE.SILVESARENA_SHOP_GOLD, itemType = 1}

	--3.代表特殊resource
	self._barInfos[TOP_BAR_TYPE.BATTLE_FORCE] = {kind = ITEM_TYPE.BATTLE_FORCE, isShowAdd = false, itemType = 3, iconScale = 0.8}
	self._barInfos[TOP_BAR_TYPE.BATTLE_FORCE_FOR_SUNWAR] = {kind = ITEM_TYPE.BATTLE_FORCE, isShowAdd = false, itemType = 3, class = QUIWidgetSunWarTopBarCell, iconScale = 0.8}
	self._barInfos[TOP_BAR_TYPE.BATTLE_FORCE_FOR_LOCAL] = {kind = ITEM_TYPE.BATTLE_FORCE, isShowAdd = false, itemType = 3, iconScale = 0.8}
	self._barInfos[TOP_BAR_TYPE.BATTLE_FORCE_FOR_SPAR] = {kind = ITEM_TYPE.BATTLE_FORCE, isShowAdd = false, itemType = 3, class = QUIWidgetSparFieldTopBarCell, iconScale = 0.8}
	self._barInfos[TOP_BAR_TYPE.BATTLE_FORCE_FOR_UNIONAR] = {kind = ITEM_TYPE.BATTLE_FORCE, isShowAdd = false, itemType = 3, class = QUIWidgetUnionWarTopBarCell, iconScale = 0.8}
	self._barInfos[TOP_BAR_TYPE.MAZE_EXPLORE_ENERGY] = {kind = ITEM_TYPE.MAZE_EXPLORE_ENERGY, itemType = 3, iconScale = 0.5}
	--2，代表普通item
	self._barInfos[TOP_BAR_TYPE.GEMSTONE_EXCHANGE_TOKEN] = {kind = ITEM_TYPE.GEMSTONE_EXCHANGE_TOKEN, itemType = 2}
	self._barInfos[TOP_BAR_TYPE.STORM_EXCHANGE_TOKEN] = {kind = ITEM_TYPE.STORM_EXCHANGE_TOKEN, itemType = 2}
	self._barInfos[TOP_BAR_TYPE.MARITIME_EXCHANGE_TOKEN1] = {kind = ITEM_TYPE.MARITIME_EXCHANGE_TOKEN1, itemType = 2}
	self._barInfos[TOP_BAR_TYPE.MARITIME_EXCHANGE_TOKEN2] = {kind = ITEM_TYPE.MARITIME_EXCHANGE_TOKEN2, itemType = 2}
	self._barInfos[TOP_BAR_TYPE.DRAGON_STONE] = {kind = ITEM_TYPE.DRAGON_STONE, itemType = 2}
	self._barInfos[TOP_BAR_TYPE.DRAGON_SOUL] = {kind = ITEM_TYPE.DRAGON_SOUL, itemType = 2}
	self._barInfos[TOP_BAR_TYPE.MAGICHERB_UPLEVEL] = {kind = ITEM_TYPE.MAGICHERB_UPLEVEL, itemType = 2}
	self._barInfos[TOP_BAR_TYPE.SOULSPIRIT_XUEJIN] = {kind = ITEM_TYPE.SOULSPIRIT_XUEJIN, itemType = 2}
	self._barInfos[TOP_BAR_TYPE.TAVERN_NORMAL_MONEY] = {kind = ITEM_TYPE.TAVERN_NORMAL_MONEY, itemType = 2, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.TAVERN_ADVANCE_MONEY] = {kind = ITEM_TYPE.TAVERN_ADVANCE_MONEY, itemType = 2, iconScale = 0.5}
	self._barInfos[TOP_BAR_TYPE.SKIN_SHOP_ITEM] = {kind = ITEM_TYPE.SKIN_SHOP_ITEM,itemType = 2}
	self._barInfos[TOP_BAR_TYPE.MUSIC_GAME_NOTE] = {kind = ITEM_TYPE.MUSIC_GAME_NOTE,itemType = 2,iconScale = 0.45}

	self._barInfos[TOP_BAR_TYPE.ABYSS_EXCHANGE_TOKEN] = {kind = ITEM_TYPE.ABYSS_EXCHANGE_TOKEN, itemType = 2, iconScale = 0.5}
	

	for key, value in pairs(self._barInfos) do 
		if self._bars[key] == nil then
			local isShowAdd = value.isShowAdd == nil and true or false
			local soundEffect = value.soundEffect ~= nil and value.soundEffect or "money_add"

			if value.class == nil then
				value.class = QUIWidgetTopBarCell
			end
			self._bars[key] = value.class.new({kind = value.kind, isShowAdd = isShowAdd, soundEffect = soundEffect})
			self:addChild(self._bars[key])
			self._bars[key]:setVisible(false)
			if value.itemType == 1 or value.itemType == 3 then
				self:setIcon(value.kind, key)
			elseif value.itemType == 2 or value.itemType == 4 then
				self:setItemIcon(value.kind, key)
			end
		end
	end

	self._updateDataManual = {}

	self:_onUserDataUpdate()
	self:_onHeroDataUpdate()
	self:_onItemNumUpdate()

	self._cellW = 205 --单位宽度
	self._style = {}  -- top bar 类型
end

--[[
	设置icon
]]
function QUIWidgetTopBar:setIcon(type, topBarType)
	local info = remote.items:getWalletByType(type)
	local barInfo = self._barInfos[topBarType]
	local sp = self._bars[topBarType]:getIcon()
	if info ~= nil and info.alphaIcon ~= nil then
		local texture = CCTextureCache:sharedTextureCache():addImage(info.alphaIcon)
		if texture then
		    local size = texture:getContentSize()
		    local rect = CCRectMake(0, 3, size.width, size.height)
			sp:setTexture(texture)
			sp:setTextureRect(rect)
			if barInfo.iconScale ~= nil then
				sp:setScale(barInfo.iconScale)
			end
		end 
		self:_addEffect(topBarType, itemType)
	end
end

function QUIWidgetTopBar:_addEffect( topBarType )
	local effectName = ""
	if topBarType == TOP_BAR_TYPE.SUNWELL_MONEY then
		effectName = "effects/widget_tap_1.ccbi"
	elseif topBarType == TOP_BAR_TYPE.ARENA_MONEY then
		effectName = "effects/widget_tap_2.ccbi"
	elseif topBarType == TOP_BAR_TYPE.GEMSTONE_EXCHANGE_TOKEN then
		effectName = "effects/widget_tap_3.ccbi"
	elseif topBarType == TOP_BAR_TYPE.THUNDER_MONEY then
		effectName = "effects/widget_tap_4.ccbi"
	elseif topBarType == TOP_BAR_TYPE.SOULMONEY then
		effectName = "effects/widget_tap_5.ccbi"
	elseif topBarType == TOP_BAR_TYPE.INTRUSION_MONEY then
		effectName = "effects/widget_tap_6.ccbi"
	elseif topBarType == TOP_BAR_TYPE.DRAGON_WAR_MONEY or topBarType == TOP_BAR_TYPE.TOWER_MONEY or topBarType == TOP_BAR_TYPE.SILVERMINE_MONEY then
		effectName = "effects/widget_tap_8.ccbi"
	elseif topBarType == TOP_BAR_TYPE.MONEY then
		effectName = "effects/widget_tap_9.ccbi"
	elseif topBarType == TOP_BAR_TYPE.TOKEN_MONEY then
		effectName = "effects/widget_tap_7.ccbi"
	elseif topBarType == TOP_BAR_TYPE.ENERGY then
		effectName = "effects/widget_tap_10.ccbi"
	end

	if effectName == "" then
		return
	end
	
	local barInfo = self._barInfos[topBarType]
	local effect = QUIWidgetAnimationPlayer.new()
	local node = self._bars[topBarType]:getIconEffectNode()
	node:setVisible(true)
	effect:setScale(0.6)
	if barInfo.iconScale ~= nil then
		effect:setScale(barInfo.iconScale)
	end
	effect:playAnimation(effectName, nil, nil, false)
	node:addChild(effect)
	-- effect:setPosition(10, 0)
end

--[[
	设置物品在资源条上的icon
]]
function QUIWidgetTopBar:setItemIcon(type, topBarType)
	local info = QStaticDatabase:sharedDatabase():getItemByID(tonumber(type))
	local barInfo = self._barInfos[topBarType]
	local sp = self._bars[topBarType]:getIcon()
	if info ~= nil and info.icon_1 ~= nil then
		local texture = CCTextureCache:sharedTextureCache():addImage(info.icon_1)
		if texture then
		    local size = texture:getContentSize()
		    local rect = CCRectMake(0, 3, size.width, size.height)
			sp:setTexture(texture)
			sp:setTextureRect(rect)
			if barInfo.iconScale ~= nil then
				sp:setScale(barInfo.iconScale)
			end
		end
		self:_addEffect(topBarType)
	end
end

function QUIWidgetTopBar:onEnter()
	QUIWidgetTopBar.super.onEnter(self)
	for _,value in pairs(self._bars) do
		value:addEventListener(QUIWidgetTopBarCell.EVENT_CLICK, handler(self, QUIWidgetTopBar._onTopClickHandler))
	end
	self._userEventProxy = cc.EventProxy.new(remote.user)
	self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self._onUserDataUpdate))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self._onHeroDataUpdate))
    -- self._remoteProxy:addEventListener(remote.USER_UPDATE_EVENT, handler(self, self._onHeroDataUpdate))    
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, QUIWidgetTopBar._exitFromBattle, self)

	self._itemsProxy = cc.EventProxy.new(remote.items)
	self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self._onItemNumUpdate))
end

function QUIWidgetTopBar:onExit()
	QUIWidgetTopBar.super.onExit(self)
	for _,value in pairs(self._bars) do
		value:removeAllEventListeners()
	end
	if self._userEventProxy ~= nil then
		self._userEventProxy:removeAllEventListeners()
		self._userEventProxy = nil
	end
	if self._remoteProxy ~= nil then
		self._remoteProxy:removeAllEventListeners()
		self._remoteProxy = nil
	end
	if self._itemsProxy ~= nil then
		self._itemsProxy:removeAllEventListeners()
		self._itemsProxy = nil
	end
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, QUIWidgetTopBar._exitFromBattle, self)
end

--[[
	根据styles显示top bar内容
]]
function QUIWidgetTopBar:showWithStyle(styles, offset, spaceOffset, isReverse)
	spaceOffset = spaceOffset or 0
	self:hideAll()
	self._styles = styles

	if not offset then 
		offset = -126 
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		if page and page.getScalingVisible and not page:getScalingVisible() then
			offset = -20
		end
	end
	local totalCount = #self._styles
	for index,style in ipairs(self._styles) do
		self._bars[style]:setVisible(true)
		self._bars[style]:setSoundEffect(true)
		if isReverse then
			local posX = offset - (self._cellW + spaceOffset) * (index - 1)
			self._bars[style]:setPositionX(offset - (index - 1) * (self._cellW + spaceOffset))
		else
			local posX = offset - (self._cellW + spaceOffset) * (totalCount - index)
			self._bars[style]:setPositionX(posX)
		end
	end
	-- end
end

--[[
	隐藏所有
]]
function QUIWidgetTopBar:hideAll()
	for _,bar in pairs(self._bars) do
		bar:setVisible(false)
	end
end

--[[
	获取某个top bar
]]
function QUIWidgetTopBar:getBarForType(typeName)
	return self._bars[typeName]
end

--[[
	Author: xurui
	获取当前界面上 top bar 的具体类型
	为了点金手新手引导
 ]]
function QUIWidgetTopBar:getTopBarStyle()
	return self._style
end

--[[
	关闭所有cell的音效
]]
function QUIWidgetTopBar:setAllSound(isSound)
	for _,bar in pairs(self._bars) do
		bar:setSoundEffect(isSound)
	end
end

------------------------------------show enum-----------------------------------------

--在主界面显示
function QUIWidgetTopBar:showWithMainPage()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.ENERGY}
	self:showWithStyle(style)
end

--在普通召將显示
function QUIWidgetTopBar:showWithTavernNormal()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.TAVERN_NORMAL_MONEY}
	self:showWithStyle(style)
end

--在高級召將显示
function QUIWidgetTopBar:showWithTavernAdvance()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.TAVERN_ADVANCE_MONEY}
	self:showWithStyle(style)
end

--在界面显示金币钻石
function QUIWidgetTopBar:showWithMainBar()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY}
	self:showWithStyle(style)
end

--在考古界面显示
function QUIWidgetTopBar:showWithArchaeology()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在斗魂场界面显示
function QUIWidgetTopBar:showWithArena()
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.ARENA_MONEY}
	self:showWithStyle(style)
end

--在斗魂场界面显示
function QUIWidgetTopBar:showWithStormArena()
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.MARITIME_MONEY}
	self:showWithStyle(style)
end

--在雷电王座界面显示
function QUIWidgetTopBar:showWithThunder()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.THUNDER_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在要塞界面显示
function QUIWidgetTopBar:showWithInvasion()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.INTRUSION_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在大师赛界面显示
function QUIWidgetTopBar:showWithMockBattle()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY,  TOP_BAR_TYPE.MOCK_BATTLE_MONEY}
	self:showWithStyle(style)
end
function QUIWidgetTopBar:showWithMockBattle2()
	local style = { TOP_BAR_TYPE.TOKEN_MONEY,  TOP_BAR_TYPE.MOCK_BATTLE_MONEY}
	self:showWithStyle(style)
end
--在神器界面显示
function QUIWidgetTopBar:showWithGodarm()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY,  TOP_BAR_TYPE.GOD_ARM_MONEY,TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在太阳井界面显示
function QUIWidgetTopBar:showWithSunWar()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.SUNWELL_MONEY, TOP_BAR_TYPE.BATTLE_FORCE_FOR_SUNWAR}
	local offsetX = -40
	if ENABLE_PVP_FORCE then
		offsetX = -90
	end
	self:showWithStyle(style, offsetX)
end

--在魂师总览界面显示
function QUIWidgetTopBar:showWithHeroOverView()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE]:setSoundEffect(false)
end

--在魂师装备界面显示
function QUIWidgetTopBar:showWithHeroDetail()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE]:setSoundEffect(false)
end

--在魂师宝石界面显示
function QUIWidgetTopBar:showWithGemstone()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.GEMSTONE_ENERGY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
    self._bars[TOP_BAR_TYPE.SILVERMINE_MONEY]:update(remote.user.silvermineMoney or 0)
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE]:setSoundEffect(false)
end

--在魂师暗器界面显示
function QUIWidgetTopBar:showWithMount()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE]:setSoundEffect(false)
end

--在魂师暗器重生界面显示
function QUIWidgetTopBar:showWithMountReborn()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.STORM_MONEY}
	self:showWithStyle(style)
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE]:setSoundEffect(false)
end

--在魂师武魂真身重生界面显示
function QUIWidgetTopBar:showWithArtifactReborn()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.MARITIME_MONEY}
	self:showWithStyle(style)
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE]:setSoundEffect(false)
end

--在重生殿界面显示
function QUIWidgetTopBar:showWithHeroReborn()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.SOULMONEY}
	self:showWithStyle(style)
end

--在重生殿宝石回收界面显示
function QUIWidgetTopBar:showWithGem()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.SILVERMINE_MONEY}
	self:showWithStyle(style)
end

--在魂师大赛界面显示
function QUIWidgetTopBar:showWithTower()
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.TOWER_MONEY}
	self:showWithStyle(style)
end

-- 宗门建设
function QUIWidgetTopBar:showWithUnionNormal()
	local style = {ITEM_TYPE.MONEY, ITEM_TYPE.TOKEN_MONEY, ITEM_TYPE.CONSORTIA_MONEY}
	self:showWithStyle(style)
end

--
function QUIWidgetTopBar:showWithUnionSkill()
	local style = {ITEM_TYPE.MONEY, ITEM_TYPE.CONSORTIA_MONEY, ITEM_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end


-- 在觉醒宝箱积分兑换界面显示
function QUIWidgetTopBar:showWithEnchantOrient()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.ENCHANT_SCORE}
	self:showWithStyle(style)
    self._bars[TOP_BAR_TYPE.ENCHANT_SCORE]:update(remote.user.enchantScore or 0)        
end

-- 在副本界面显示
function QUIWidgetTopBar:showWithDungeon()
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.ENERGY, TOP_BAR_TYPE.BATTLE_FORCE_FOR_LOCAL}
	self:showWithStyle(style)
end

--在魂兽森林界面显示
function QUIWidgetTopBar:showWithSilverMine()
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.SILVERMINE_MONEY}
	self:showWithStyle(style)
end

--在魂兽森林界面显示
function QUIWidgetTopBar:showWithPlunder()
	local style = {TOP_BAR_TYPE.TOKEN_MONEY}
	self:showWithStyle(style)
end

--在豪华轮盘活动界面显示
function QUIWidgetTopBar:showWithActivityTurntable()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.ENERGY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--魂力试炼界面显示
function QUIWidgetTopBar:showWithSoulTrial()
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在体技界面显示
function QUIWidgetTopBar:showWithGlyph()
	local style = {TOP_BAR_TYPE.GLYPH_MONEY, TOP_BAR_TYPE.SOULMONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在魂灵秘术界面显示
function QUIWidgetTopBar:showWithSoulSpiritOccult()
	local style = {TOP_BAR_TYPE.SOULSPIRIT_XUEJIN, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

function QUIWidgetTopBar:showWithSkinShopPage( )
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.SKIN_SHOP_ITEM}
	self:showWithStyle(style)
end

function QUIWidgetTopBar:showMusicGamePage( )
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.MUSIC_GAME_NOTE}
	self:showWithStyle(style)	
end
--在洗炼界面显示
function QUIWidgetTopBar:showWithRefine()
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在武魂真身界面显示
function QUIWidgetTopBar:showWithArtifact()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在黑石界面显示
function QUIWidgetTopBar:showWithBlackRock( ... )
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.TEAM_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在黑石队伍面显示
function QUIWidgetTopBar:showWithBlackRockTeam( )
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.TEAM_MONEY}
	self:showWithStyle(style)
end

--在6元夺宝显示
function QUIWidgetTopBar:showWithRushBuy( ... )
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.RUSH_BUY_MONEY, TOP_BAR_TYPE.RUSH_BUY_SCORE}
	self:showWithStyle(style)
end

--在晶石碎片分解显示
function QUIWidgetTopBar:showWithSparPieceRecycle( ... )
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.JEWELRY_MONEY}
	self:showWithStyle(style)
end

--在地狱杀戮场显示
function QUIWidgetTopBar:showWithFightClub( ... )
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.JEWELRY_MONEY}
	self:showWithStyle(style)
end

--在地狱杀戮场显示
function QUIWidgetTopBar:showWithSanctuary( ... )
	local style = {TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.SANCTUARY_MONEY}
	self:showWithStyle(style)
end

--在仙品显示
function QUIWidgetTopBar:showWithMagicHerb( ... )
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.MAGICHERB_UPLEVEL}
	self:showWithStyle(style)
end

--在大富翁显示
function QUIWidgetTopBar:showWithMonopoly()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY}
	self:showWithStyle(style, -220)
end
	
--在仙品養成——升級界面顯示
function QUIWidgetTopBar:showWithMagicHerbUpLevel()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.MAGICHERB_UPLEVEL, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在魂灵主界面显示
function QUIWidgetTopBar:showWithSoulSpirit()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE}
	self:showWithStyle(style)
end

--在魂灵碎片分解显示
function QUIWidgetTopBar:showWithSoulSpiritFragment()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.TEAM_MONEY}
	self:showWithStyle(style)
end

--转盘显示
function QUIWidgetTopBar:showWithPrizeWheel()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.PRIZE_WHEEL_MONEY}
	self:showWithStyle(style)
end

--鼠年春节活动显示
function QUIWidgetTopBar:showWithRatFestival()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.RAT_FESTIVAL_MONEY}
	self:showWithStyle(style)
end

--月度签到显示
function QUIWidgetTopBar:showWithMonthSignIn()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.CHECK_IN_MONEY}
	self:showWithStyle(style)
end

--在西尔维斯界面显示
function QUIWidgetTopBar:showWithSilvesArena()
	local style = {TOP_BAR_TYPE.SILVESARENA_SHOP_MONEY, TOP_BAR_TYPE.SILVESARENA_SHOP_GOLD}
	self:showWithStyle(style)
end

--在西尔维斯商店界面显示
function QUIWidgetTopBar:showWithSilvesArenaShop()
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.SILVESARENA_SHOP_MONEY, TOP_BAR_TYPE.SILVESARENA_SHOP_GOLD}
	self:showWithStyle(style)
end
--在破碎位面中显示
function QUIWidgetTopBar:showMazeExplore(engry)
	local style = {TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.MAZE_EXPLORE_ENERGY}
	self:showWithStyle(style)
    self._bars[TOP_BAR_TYPE.MAZE_EXPLORE_ENERGY]:update(engry or 0) 
end
-- 根据类型设置相应货币是否手动更新
function QUIWidgetTopBar:setUpdateDataByManual(type, trueorFalse )
	if self._barInfos[type] then
		self._barInfos[type].noAutoUpdata = trueorFalse
	end
end

function QUIWidgetTopBar:setDisableTopClick( trueorFalse )
	-- body
	self._disableTopClick = trueorFalse
end

function QUIWidgetTopBar:manualUpdateConsortiaMoney(  )
	-- body
	self._bars[TOP_BAR_TYPE.CONSORTIA_MONEY]:update(remote.user.consortiaMoney)
end

function QUIWidgetTopBar:updateForceTopBar()
	-- body
	self:_onHeroDataUpdate()
end

------------------------------------event area-------------------------------------
--[[
	更新玩家信息
]]
function QUIWidgetTopBar:_onUserDataUpdate(event)
	for key, value in pairs(self._barInfos) do
		local noAutoUpdata = false 
		if value.noAutoUpdata ~= nil then
			noAutoUpdata = value.noAutoUpdata
		end
		if self._bars[key] ~= nil and value.itemType == 1 and noAutoUpdata == false then		
			local text1 = remote.user[value.kind] or 0
			local text2 = nil
			if value.kind == ITEM_TYPE.ENERGY then
				text2 = QStaticDatabase:sharedDatabase():getConfig().max_energy or 150
			end
			self._bars[key]:update(text1, text2)
		end
	end
end

--[[
	魂师发生变化更新战斗力
]]
function QUIWidgetTopBar:_onHeroDataUpdate(event)
	local force = remote.herosUtil:getMostHeroBattleForce() or 0
	-- 功能暂时屏蔽
	-- app.tip:floatForce(force)
	local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force),true)
	if fontInfo ~= nil then
		self._bars[TOP_BAR_TYPE.BATTLE_FORCE]:setFntFile(fontInfo.force_color)
	end
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE]:update(force,nil)

	local force = remote.herosUtil:getMostHeroBattleForce(true) or 0
	local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force),true)
	if fontInfo ~= nil then
		self._bars[TOP_BAR_TYPE.BATTLE_FORCE_FOR_LOCAL]:setFntFile(fontInfo.force_color)
	end
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE_FOR_LOCAL]:update(force, nil, true)

	local sunWarForce = force
	if app.unlock:checkLock("UNLOCK_SUNWELL") then
	    remote.sunWar:addBuff( false )
		sunWarForce = remote.herosUtil:getMostHeroBattleForce(true) or 0
	    remote.sunWar:removeBuff(false)
	end
	if fontInfo ~= nil then
		self._bars[TOP_BAR_TYPE.BATTLE_FORCE_FOR_SUNWAR]:setFntFile(fontInfo.force_color)
	end
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE_FOR_SUNWAR]:update(sunWarForce, nil, true)

	if fontInfo ~= nil then
		self._bars[TOP_BAR_TYPE.BATTLE_FORCE_FOR_UNIONAR]:setFntFile(fontInfo.force_color)
	end
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE_FOR_UNIONAR]:update(force, nil, true)

	if fontInfo ~= nil then
		self._bars[TOP_BAR_TYPE.BATTLE_FORCE_FOR_SPAR]:setFntFile(fontInfo.force_color)
	end
	self._bars[TOP_BAR_TYPE.BATTLE_FORCE_FOR_SPAR]:update(force, nil, true)
end

--[[
	从副本退出的时候更新
]]
function QUIWidgetTopBar:_exitFromBattle()
	self:_onUserDataUpdate()
	self:_onHeroDataUpdate()
	self:_onItemNumUpdate()
end

--[[
	物品数量发生变化时更新
]]
function QUIWidgetTopBar:_onItemNumUpdate()
	for key, value in pairs(self._barInfos) do
		local noAutoUpdata = false 
		if value.noAutoUpdata ~= nil then
			noAutoUpdata = value.noAutoUpdata
		end
		if self._bars[key] ~= nil and value.itemType == 2 and noAutoUpdata == false then
			self._bars[key]:update(remote.items:getItemsNumByID(tonumber(value.kind)))
		end
	end
end

--手动更新物品数量
function QUIWidgetTopBar:updateNumByTopBarType(key, num)
	if self._bars[key] then
		self._bars[key]:update(num)
	end
end

--[[
	点击+号
]]
function QUIWidgetTopBar:_onTopClickHandler(event)
	print(event.kind)
	if self._disableTopClick  then
		return
	end

	local barInfo = {}
	for key, value in pairs(self._barInfos) do
		if event.kind == value.kind then
			barInfo = value
			break
		end
	end

	if event.kind == ITEM_TYPE.TOKEN_MONEY then --充值
		if not ENABLE_GAME_CHARGE then
		    app.tip:floatTip("魂师大人，充值暂未开放")
		    return
		end
		if ENABLE_CHARGE() then
			return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
		else
        	app.tip:floatTip("暂未开放")
		end
	elseif event.kind == ITEM_TYPE.MONEY then --购买金魂币
		local config = QStaticDatabase:sharedDatabase():getConfiguration()
		if app.unlock:getUnlockAddMoney(true) == false then
			return 
		end
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual",
			options = {typeName=ITEM_TYPE.MONEY}})
	elseif event.kind == ITEM_TYPE.ENERGY then --购买体力
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual",
			options = {typeName=ITEM_TYPE.ENERGY}})
	elseif event.kind == ITEM_TYPE.BATTLE_FORCE then
        if remote.herosUtil:getIsHasExtendsProp() then
        	app.tip:floatTip("徽章加成仅对普通，经验，史诗，噩梦副本有效")
    	end  
    elseif event.kind == ITEM_TYPE.RUSH_BUY_MONEY then
    	if ENABLE_CHARGE() then
			return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
		end
	elseif event.kind == ITEM_TYPE.TAVERN_ADVANCE_MONEY then
		QUIDialogTavernShowHero:gotoBuy()
	elseif barInfo.itemType == 2 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, tonumber(event.kind), nil, nil, false)
   	elseif barInfo.itemType == 1 then
   		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, event.kind, nil, nil, false)
   	elseif event.kind == ITEM_TYPE.MAZE_EXPLORE_ENERGY then --购买行动力
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual",
			options = {typeName=ITEM_TYPE.MAZE_EXPLORE_ENERGY}})
	end
end



return QUIWidgetTopBar