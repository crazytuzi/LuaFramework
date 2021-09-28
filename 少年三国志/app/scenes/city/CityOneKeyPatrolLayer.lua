local CityOneKeyPatrolLayer = class("CityOneKeyPatrolLayer", UFCCSModelLayer)

require("app.cfg.city_info")
require("app.cfg.city_end_event_info")
local BagConst  = require("app.const.BagConst")
local CityConst = require("app.const.CityConst")
local ShopVipConst = require("app.const.ShopVipConst")
local CityOneKeyPatrolItem = require("app.scenes.city.CityOneKeyPatrolItem")

function CityOneKeyPatrolLayer.show()
	local layer = CityOneKeyPatrolLayer.new("ui_layout/city_OneKeyPatrolLayer.json", Colors.modelColor)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CityOneKeyPatrolLayer:ctor(json, color)
	-- an array containing the patrol configuration of each city
	-- element = {city_id, hero_id, duration_type, interval_type}
	self._patrolConfigs = {}
	self._isConfigChanged = false

	-- number or spirit and gold needed
	self._needSpirit = 0
	self._needGold = 0

	-- the number of cities to patrol
	self._numToPatrol = 0

	-- initialize the patrol configuration
	self:_initCityConfigs()

	self.super.ctor(self, json, color)
end

function CityOneKeyPatrolLayer:onLayerLoad()
	-- label strokes
	self:enableLabelStroke("Label_UseSpirit", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SpiritNum", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_UseGold", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_GoldNum", Colors.strokeBrown, 1)

	-- button click events
	self:registerBtnClickEvent("Button_Save", handler(self, self._onClickSave))
	self:registerBtnClickEvent("Button_Patrol", handler(self, self._onClickPatrol))
	self:registerBtnClickEvent("Button_Close", handler(self, self.animationToClose))

	-- init list view
	self:_initListView()

	-- set current cost num
	self:_updateCost()
end

function CityOneKeyPatrolLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_ONEKEYPATROL_SET, self._onRcvPatrolSet, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_PATROL, self._onRcvPatrol, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_USE_ITEM, self._updateCost, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self._updateCost, self)
end

-- initialize the patrol configuration of all unlocked cities saved in server
function CityOneKeyPatrolLayer:_initCityConfigs()
	local cities = G_Me.cityData:getCityList()
	for i, v in ipairs(cities) do
		if not v.isLock and v.state == G_Me.cityData.CITY_NEED_PATROL then
			local config = { city_id = v.id,
							 hero_id = rawget(v, "skac") or 0,
							 duration_type = math.max(rawget(v, "sduration") or 0, 1),
							 interval_type = math.max(rawget(v, "sefficiency") or 0, 1) }
			self._patrolConfigs[#self._patrolConfigs + 1] = config

			-- check whether the saved hero still exists
			local knight = G_Me.bagData.knightsData:getKnightByKnightId(config.hero_id)
			if not knight then
				config.hero_id = 0
			end
		end
	end
end

function CityOneKeyPatrolLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return CityOneKeyPatrolItem.new(self)
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1, self._patrolConfigs[index + 1])
		end)
	end

	self._listView:reloadWithLength(#self._patrolConfigs)
end

-- update the spirit or gold number to cost
function CityOneKeyPatrolLayer:_updateCost()
	self._needSpirit = 0
	self._needGold   = 0
	for i, v in ipairs(self._patrolConfigs) do
		if v.hero_id > 0 then
			local cityInfo = city_info.get(v.city_id)
			local costType = cityInfo["patrol_cost_type_" .. v.interval_type]
			local costUnit = cityInfo["patrol_cost_value_" .. v.interval_type]

			local priceType = G_Path.getPriceType(costType)
			local hours     = CityConst.PATROL_DURAION[v.duration_type]
			local priceNum  = costUnit * hours

			if priceType == G_Goods.TYPE_JINGLI then
				self._needSpirit = self._needSpirit + priceNum
			elseif priceType == G_Goods.TYPE_GOLD then
				self._needGold = self._needGold + priceNum
			end
		end
	end

	-- set price number
	local spriteLabel = self:getLabelByName("Label_SpiritNum")
	local goldLabel = self:getLabelByName("Label_GoldNum")
	spriteLabel:setText(self._needSpirit)
	goldLabel:setText(self._needGold)

	-- set as red if sprite or gold is not enough
	local isSpriteEnough = G_Me.userData.spirit >= self._needSpirit
	local isGoldEnough = G_Me.userData.gold >= self._needGold
	spriteLabel:setColor(isSpriteEnough and Colors.darkColors.DESCRIPTION or Colors.uiColors.RED)
	goldLabel:setColor(isGoldEnough and Colors.darkColors.DESCRIPTION or Colors.uiColors.RED)
end

function CityOneKeyPatrolLayer:_isNoHeroSelected()
	for i, v in ipairs(self._patrolConfigs) do
		if v.hero_id ~= 0 then
			return false
		end
	end

	return true
end

function CityOneKeyPatrolLayer:_isHeroSelected(advanceCode)
	for i, v in ipairs(self._patrolConfigs) do
		if v.hero_id > 0 then
			local knightData = G_Me.bagData.knightsData:getKnightByKnightId(v.hero_id)
			local knightInfo = knight_info.get(knightData.base_id)
			if knightInfo.advance_code == advanceCode then
				return true
			end
		end
	end

	return false
end

function CityOneKeyPatrolLayer:_onClickSave()
	if self._numToPatrol > 0 then return end

	if self:_isNoHeroSelected() then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_CONFIG_NO_HERO_SET"))
	elseif self._isConfigChanged then
		G_HandlersManager.cityHandler:sendCityOneKeyPatrolSet(self._patrolConfigs)
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_CONFIG_ALREADY_SAVED"))
	end
end

function CityOneKeyPatrolLayer:_onClickPatrol()
	if self._numToPatrol > 0 then return end

	if self:_isNoHeroSelected() then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_CONFIG_NO_HERO_SET"))
	elseif self._needSpirit > G_Me.userData.spirit then
		G_GlobalFunc.showPurchasePowerDialog(ShopVipConst.JING_LI_DAN)
	elseif self._needGold > G_Me.userData.gold then
		require("app.scenes.shop.GoldNotEnoughDialog").show()
	else
		for i, v in ipairs(self._patrolConfigs) do
			if v.hero_id > 0 then
				self._numToPatrol = self._numToPatrol + 1
				G_HandlersManager.cityHandler:sendCityPatrol(v.city_id, v.hero_id, v.duration_type, v.interval_type)
			end
		end
	end
end

-- receive the message of setting the patrol config successfully
function CityOneKeyPatrolLayer:_onRcvPatrolSet()
	G_Me.cityData:setOnekeyPatrolConfig(self._patrolConfigs)
	G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_CONFIG_SAVE_SUCCEED"))
	self._isConfigChanged = false
end

-- receive the message of one-key patrolling
function CityOneKeyPatrolLayer:_onRcvPatrol()
	self._numToPatrol = self._numToPatrol - 1
	if self._numToPatrol == 0 then
		self:animationToClose()
	end
end

-- sort the knight list
function CityOneKeyPatrolLayer:_sortSelectList(knightArr)
	--上阵武将 > 上阵武将同阵营 > 资质 > ID
	local knightNumOfGroup = G_Me.formationData:getMainTeamCountryIds()
	local sortFunc = function(a, b)
		        local infoA = knight_info.get(a.base_id)
        local infoB = knight_info.get(b.base_id)

        -- 上阵武将
        local isAInTeam = G_Me.formationData:hasKnightOnTeam(infoA.advance_code, 1)
        local isBInTeam = G_Me.formationData:hasKnightOnTeam(infoB.advance_code, 1)

        if isAInTeam ~= isBInTeam then
            return isAInTeam
        end

        -- 上阵武将同阵营
        if infoA.group ~= infoB.group then
            numA = knightNumOfGroup[infoA.group]
            numB = knightNumOfGroup[infoB.group]

            if numA and numB then
                return numA > numB
            elseif numA or numB then
                return numA ~= nil
            end
        end

        -- 资质
        if a.potential ~= b.potential then
            return a.potential > b.potential
        end

        -- 阵营
        if infoA.group ~= infoB.group then
            return infoA.group < infoB.group
        end

        -- ID
        return infoA.advance_code < infoB.advance_code
	end

	table.sort(knightArr, sortFunc)
end

-- get selectable knight list
function CityOneKeyPatrolLayer:getSelectList()
	local knights = {}
	local allKnights = G_Me.bagData.knightsData:getKnightsList()
	local mainRoleID = G_Me.bagData.knightsData:getBaseIdByKnightId(G_Me.formationData:getMainKnightId())

	for k, v in pairs(allKnights) do
		local knightInfo = knight_info.get(v.base_id)
		local advanceCode = knightInfo.advance_code
		local quality = knightInfo.quality

		if city_end_event_info.get(advanceCode, 1, 1) ~= nil and
		   quality >= BagConst.QUALITY_TYPE.PURPLE and
		   not self:_isHeroSelected(advanceCode) then

			local oldKnight = knights[advanceCode]
			if oldKnight then
				local replace = false
				if v.level > oldKnight.level then
					replace = true
				elseif v.level == oldKnight.level and G_Me.formationData:hasKnightOnTeam(knightInfo.advance_code, 1) then
					replace = true
				end

				if replace then
					knights[advanceCode] = clone(v)
					knights[advanceCode].potential = knightInfo.potential
				end
			else
				knights[advanceCode] = clone(v)
				knights[advanceCode].potential = knightInfo.potential
			end
		end
	end

	-- move knights to an array
	local knightArr = {}
	for k, v in pairs(knights) do
		knightArr[#knightArr + 1] = v
	end

	-- sort
	self:_sortSelectList(knightArr)

	return knightArr
end

-- set the configured hero
function CityOneKeyPatrolLayer:setHeroID(index, id)
	if self._patrolConfigs[index].hero_id ~= id then
		self._patrolConfigs[index].hero_id = id
		self._isConfigChanged = true
		self:_updateCost()
	end
end

-- set the configured patrolling duration type
function CityOneKeyPatrolLayer:setDurationType(index, durType)
	if self._patrolConfigs[index].duration_type ~= durType then
		self._patrolConfigs[index].duration_type = durType
		self._isConfigChanged = true
		self:_updateCost()
	end
end

-- set the configured patrolling interval type
function CityOneKeyPatrolLayer:setIntervalType(index, intType)
	if self._patrolConfigs[index].interval_type ~= intType then
		self._patrolConfigs[index].interval_type = intType
		self._isConfigChanged = true
		self:_updateCost()
	end
end

return CityOneKeyPatrolLayer