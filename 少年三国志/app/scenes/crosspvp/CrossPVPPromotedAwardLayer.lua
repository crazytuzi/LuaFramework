-- 4个战场的晋级奖励预览

require("app.cfg.crosspvp_rank_award_info")
local CrossPVPConst = require("app.const.CrossPVPConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local CrossPVPPromotedAwardLayer = class("CrossPVPPromotedAwardLayer", UFCCSModelLayer)

local tNameList = {
   "Primary", "Middle", "Advanced", "Extreme"
}


function CrossPVPPromotedAwardLayer.show(nField, isPromoteAward)
	local layer = CrossPVPPromotedAwardLayer.new("ui_layout/crosspvp_PromotedAwardLayer.json", Colors.modelColor, nField, isPromoteAward)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossPVPPromotedAwardLayer:ctor(json, param, nField, isPromoteAward)
	self._nCurBattleField = nField ~= 0 and nField or CrossPVPConst.BATTLE_FIELD_TYPE.EXTREME
	self._isPromoteAward = isPromoteAward
	self._awardType = isPromoteAward and 1 or 2 -- 1是晋级奖励，2是参与奖励
	self._tDataList = {}

	self:_prepareData()

	self.super.ctor(self, json, param)
end

function CrossPVPPromotedAwardLayer:onLayerLoad()
	-- title
	local title = G_Path.getTitleTxt(self._isPromoteAward and "jinjijiangli-1.png" or "canyujiangli-1.png")
	self:getImageViewByName("Image_Title"):loadTexture(title)

	-- hint
	local hint = G_lang:get(self._isPromoteAward and "LANG_CROSS_PVP_PROMOTED_AWARD_HINT" or "LANG_CROSS_PVP_JOIN_AWARD_HINT")
	self:showTextWithLabel("Label_Hint", hint)

	-- initialize listview
	self:_initListView()

	-- initialize tabs
	self:_initTabs()

	-- stroke
	self:enableLabelStroke("Label_Hint", Colors.strokeBrown, 1)

 	-- register button events
	self:registerBtnClickEvent("Button_Close", handler(self, self._closeWindow))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._closeWindow))
end

function CrossPVPPromotedAwardLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- register event listner
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._closeWindow, self)
end

function CrossPVPPromotedAwardLayer:_prepareData()
	if not self._tDataList then
		self._tDataList = {}
	end
	for i=1, 4 do
		local nField = i
		if not self._tDataList[nField] then
			self._tDataList[nField] = {}
		end
	end

	for i=1, 4 do
		local nField = i
		for j=1, crosspvp_rank_award_info.getLength() do
			local tTmpl = crosspvp_rank_award_info.indexOf(j)
			if tTmpl and tTmpl.award_type == self._awardType and nField == tTmpl.type then
				table.insert(self._tDataList[nField], #self._tDataList[nField] + 1, tTmpl)
			end
		end
	end
end

function CrossPVPPromotedAwardLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onTabChecked, self._onTabUnchecked)
	for i = CrossPVPConst.BATTLE_FIELD_NUM, 1, -1 do
		self._tabs:add("CheckBox_" .. i, nil, "Label_" .. i)
	end
	
	-- check the first tab in default
	self._tabs:checked("CheckBox_" .. self._nCurBattleField)
end

function CrossPVPPromotedAwardLayer:_onTabChecked(szCheckBoxName)
	self._nCurBattleField = self:getWidgetByName(szCheckBoxName):getTag()
	self:_switchPage()
end

function CrossPVPPromotedAwardLayer:_onTabUnchecked()
	
end

function CrossPVPPromotedAwardLayer:_switchPage()
	self._listView:reloadWithLength(#self._tDataList[self._nCurBattleField])
end

function CrossPVPPromotedAwardLayer:_initListView(nBattleFieldType)
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return require("app.scenes.crosspvp.CrossPVPAwardPreviewItem").new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			local tData = self._tDataList[self._nCurBattleField]
			if tData then
				local tTmpl = tData[index + 1]
				if tTmpl then
					cell:updateItem(tTmpl)
				end
			end
		end)

		self._listView:initChildWithDataLength(0)
	end
end

function CrossPVPPromotedAwardLayer:_closeWindow()
	self:animationToClose()
end


return CrossPVPPromotedAwardLayer