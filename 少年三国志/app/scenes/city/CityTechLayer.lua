local CityTechLayer = class("CityTechLayer", UFCCSNormalLayer)

require("app.cfg.city_technology_info")
local CityConst = require("app.const.CityConst")
local CityTechItem = require("app.scenes.city.CityTechItem")

function CityTechLayer.create(jumpCallback)
	return CityTechLayer.new("ui_layout/city_TechLayer.json", nil, jumpCallback)
end

function CityTechLayer:ctor(jsonFile, fun, jumpCallback)
	self._jumpCallback = jumpCallback
	self._listView = nil

	-- technology state of each city
	-- element = {city_id, city_state, level, can_open, can_up}
	self._techStates = {}

	self.super.ctor(self, jsonFile, fun)
end

function CityTechLayer:onLayerLoad()
	-- label strokes
	self:enableLabelStroke("Label_PatrolAccu", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_TotalHour", Colors.strokeBrown, 1)

	-- button events
	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))

	-- initialize list view
	self:_initListView()
end

function CityTechLayer:onLayerEnter()
	self:_updatePatrolTime()
	self:_updateListView()

	-- event listener
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_TECH_UP, self._updateListView, self)
end

function CityTechLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

-- initialize technology state of each city
function CityTechLayer:_initTechStates()
	self._techStates = {}

	-- prepare base data
	local cities = G_Me.cityData:getCityList()
	for i, v in ipairs(cities) do
		local state = { city_id = v.id, city_state = v.state or 0, level = v.level, can_open = false, can_up = false}
		if v.level < CityConst.MAX_TECH_LEVEL then
			local nextTechInfo = city_technology_info.get(v.id, v.level + 1)
			if self._totalPatrolTime >= nextTechInfo.require_patroltime then
				state.can_open = v.level == 0 and state.city_state > G_Me.cityData.CITY_NEED_ATTACK
				state.can_up   = v.level > 0
			end
		end

		self._techStates[i] = state
	end

	-- sort by state:可开启 > 可提升 > 不可提升 > 未开启 > 满级
	local sortFunc = function(a, b)
		if a.can_open ~= b.can_open then
			return a.can_open
		end

		if a.can_up ~= b.can_up then
			return a.can_up
		end

		if a.level == CityConst.MAX_TECH_LEVEL and b.level ~= CityConst.MAX_TECH_LEVEL then
			return false
		elseif a.level ~= CityConst.MAX_TECH_LEVEL and b.level == CityConst.MAX_TECH_LEVEL then
			return true
		end

		return a.city_id < b.city_id
	end

	table.sort(self._techStates, sortFunc)
end

function CityTechLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		local panelSize = panel:getContentSize()
		local layerHeight = self:getContentSize().height
		local rootHeight = self:getRootWidget():getContentSize().height
		local hDiff = layerHeight - rootHeight - 80 -- 80是底部按钮栏的高度
		panel:setSize(CCSize(panelSize.width, panelSize.height + hDiff))
		panel:setPositionY(panel:getPositionY() - hDiff)

		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return CityTechItem.new(self._jumpCallback)
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(self._techStates[index + 1])
		end)
	end
end

function CityTechLayer:_updatePatrolTime()
	-- set total patrol time
	self._totalPatrolTime = G_Me.cityData:getTotalPatrolTime()
	local strTime = self._totalPatrolTime .. G_lang:get("LANG_HOUR")
	self:showTextWithLabel("Label_TotalHour", strTime)
end

function CityTechLayer:_updateListView()
	-- initialize technology state of each city
	self:_initTechStates()

	-- reload list view
	self._listView:reloadWithLength(#self._techStates)
end

function CityTechLayer:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_CITY_TECHNOLOGY"), content = G_lang:get("LANG_CITY_TECH_HELP")}
		})
end

return CityTechLayer