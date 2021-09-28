local CrossPVPBetSelectLayer = class("CrossPVPBetSelectLayer", UFCCSModelLayer)

local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPBetSelectItem = require("app.scenes.crosspvp.CrossPVPBetSelectItem")

function CrossPVPBetSelectLayer.create(betType, callback)
	return CrossPVPBetSelectLayer.new("ui_layout/crosspvp_BetSelectLayer.json", Colors.modelColor, betType, callback)
end

function CrossPVPBetSelectLayer:ctor(jsonFile, color, betType, callback)
	self._betType  = betType
	self._callback = callback
	self._rankList = {}
	self._selField = 0
	self.super.ctor(self, jsonFile, color)
end

function CrossPVPBetSelectLayer:onLayerLoad()
	-- initialize hint
	self:_initBetHint()

	-- initialize listview
	self:_initListView()

	-- initialize tabs
	self:_initTabs()

	self:registerBtnClickEvent("Button_Close_RightTop", handler(self, self._onClose))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClose))
end

function CrossPVPBetSelectLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- pop in
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function CrossPVPBetSelectLayer:_initBetHint()
	local isFinal = G_Me.crossPVPData:getCourse() == CrossPVPConst.COURSE_FINAL
	local hint = ""

	if isFinal then
		hint = G_lang:get("LANG_CROSS_PVP_BET_FINAL_HINT_" .. self._betType)
	else
		hint = G_lang:get("LANG_CROSS_PVP_BET_HINT_" .. self._betType)
	end

	self:showTextWithLabel("Label_Hint", hint)
	self:enableLabelStroke("Label_Hint", Colors.strokeBrown, 1)
end

function CrossPVPBetSelectLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onTabChecked, self._onTabUnchecked)
	for i = CrossPVPConst.BATTLE_FIELD_NUM, 1, -1 do
		self._tabs:add("CheckBox_" .. i, nil, "Label_" .. i)
	end

	-- check the first tab in default
	self._tabs:checked("CheckBox_" .. CrossPVPConst.BATTLE_FIELD_NUM)
end

function CrossPVPBetSelectLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		local selectCallBack = function(selData)
			if self._callback then
				self._callback(selData)
			end

			self:_onClose()
		end

		self._listView:setCreateCellHandler(function(list, index)
			return CrossPVPBetSelectItem.new(selectCallBack)
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			local data = self._rankList[self._selField][index + 1]
			data.battlefield = self._selField
			cell:update(data)
		end)
	end

	self._listView:reloadWithLength(0)
end

function CrossPVPBetSelectLayer:_reloadListView()
	self._listView:reloadWithLength(#self._rankList[self._selField])
end

function CrossPVPBetSelectLayer:_onRcvRankList(data)
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK)
	self._rankList[self._selField] = clone(data.ranks)
	self:_reloadListView()
end

function CrossPVPBetSelectLayer:_onTabChecked(btnName)
	self._selField = self:getWidgetByName(btnName):getTag()

	local dataList = self._rankList[self._selField]
	if dataList and #dataList > 0 then
		self:_reloadListView()
	else
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK, self._onRcvRankList, self)
		G_HandlersManager.crossPVPHandler:sendGetLastRank(self._selField, 0, 1)
	end
end

function CrossPVPBetSelectLayer:_onTabUnchecked()

end

function CrossPVPBetSelectLayer:_onClose()
	self:animationToClose()
end

return CrossPVPBetSelectLayer