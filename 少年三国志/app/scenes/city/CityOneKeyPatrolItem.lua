local CityOneKeyPatrolItem = class("CityOneKeyPatrolItem", function()
	return CCSItemCellBase:create("ui_layout/city_OneKeyPatrolItem.json")
end)

require("app.cfg.city_info")
require("app.cfg.knight_info")
local CityConst = require("app.const.CityConst")
local CityAddListLayer = require("app.scenes.city.CityAddListLayer")

function CityOneKeyPatrolItem:ctor(patrolLayer)
	self._patrolLayer = patrolLayer
	self._index = nil
	self._configData = nil

	-- label strokes
	self:enableLabelStroke("Label_CityName", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Desc", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_HeroName", Colors.strokeBrown, 1)

	-- button click events
	self:registerBtnClickEvent("Button_HeadBg", handler(self, self._onClickHead))
	self:registerBtnClickEvent("Button_SelectTime", handler(self, self._onClickDuration))
	self:registerBtnClickEvent("Button_SelectType", handler(self, self._onClickInterval))
	self:registerBtnClickEvent("Button_Remove", handler(self, self._onClickHead))

	-- blink the select button
	local fadeIn = CCFadeIn:create(1.5)
	local fadeOut = CCFadeOut:create(1.5)
	local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
	self:getWidgetByName("Image_Add"):runAction(CCRepeatForever:create(seq))
end

function CityOneKeyPatrolItem:update(index, data)
	self._index = index
	self._configData = data

	-- set city name
	local cityInfo = city_info.get(data.city_id)
	self:showTextWithLabel("Label_CityName", cityInfo.name)

	-- info of the hero patrolling this city
	local heroID = data.hero_id
	self:_updateHeroInfo(heroID)

	-- patrol info
	local durationType = math.max(data.duration_type, 1)
	local intervalType = math.max(data.interval_type, 1)

	self:_updateDuration(durationType)
	self:_updateInterval(intervalType)
end

function CityOneKeyPatrolItem:_updateHeroInfo(heroID)
	local hasHero = heroID ~= 0
	self:showWidgetByName("Label_HeroName", hasHero)
	self:showWidgetByName("Image_Head", hasHero)
	self:showWidgetByName("Image_QualityFrame", hasHero)
	self:showWidgetByName("Button_Remove", hasHero)

	if hasHero then
		self:showTextWithLabel("Label_Desc", G_lang:get("LANG_CITY_PATROLLING_HERO"))

		local knightData = G_Me.bagData.knightsData:getKnightByKnightId(heroID)
		local knightInfo = knight_info.get(knightData.base_id)

		-- name
		local nameLabel = self:getLabelByName("Label_HeroName")
		nameLabel:setText(knightInfo.name)
		nameLabel:setColor(Colors.qualityColors[knightInfo.quality])

		-- head icon
		local iconPath = G_Path.getKnightIcon(knightInfo.res_id)
		self:getImageViewByName("Image_Head"):loadTexture(iconPath)

		-- quality frame
		local qualityFramePath = G_Path.getEquipColorImage(knightInfo.quality, G_Goods.TYPE_KNIGHT)
		self:getImageViewByName("Image_QualityFrame"):loadTexture(qualityFramePath, UI_TEX_TYPE_PLIST)
	else
		self:showTextWithLabel("Label_Desc", G_lang:get("LANG_CITY_ADD_PATROL_HERO"))
	end
end

function CityOneKeyPatrolItem:_updateDuration(durationType)
	local desc = G_lang:get("LANG_CITY_PATROL_SELECT_TIME_DESC", {hour = CityConst.PATROL_DURAION[durationType]})
	self:showTextWithLabel("Label_PatrolTime", desc)
end

function CityOneKeyPatrolItem:_updateInterval(intervalType)
	local desc = G_lang:get("LANG_CITY_PATROL_STYPE_DESC" .. intervalType)
	self:showTextWithLabel("Label_PatrolType", desc)
end

function CityOneKeyPatrolItem:_onClickHead()
	if self._configData.hero_id > 0 then
		-- remove current selected hero
		self._patrolLayer:setHeroID(self._index, 0)
		self:_updateHeroInfo(0)
	else
		-- prepare selectable heros
		local knightArr = self._patrolLayer:getSelectList()

		-- open the selecting layer
		local layer = nil
		layer = CityAddListLayer.create(knightArr, nil, nil, function()
			local selKnight = layer:getSelecteds()[1]
			self._patrolLayer:setHeroID(self._index, selKnight.id)
			self:_updateHeroInfo(selKnight.id)
			layer:removeFromParentAndCleanup(true)
		end)
		uf_sceneManager:getCurScene():addChild(layer)
	end
end

function CityOneKeyPatrolItem:_onClickDuration()
	local callback = function(durationType)
		self._patrolLayer:setDurationType(self._index, durationType)
		self:_updateDuration(durationType)
	end
	require("app.scenes.city.CityPatrolTimeLayer").show(callback)
end

function CityOneKeyPatrolItem:_onClickInterval()
	local callback = function(intervalType)
		self._patrolLayer:setIntervalType(self._index, intervalType)
		self:_updateInterval(intervalType)
	end
	require("app.scenes.city.CityPatrolStyleLayer").show(callback)
end

return CityOneKeyPatrolItem