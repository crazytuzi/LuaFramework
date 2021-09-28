local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local CrossPVPDoSelectPlayerLayer = class("CrossPVPDoSelectPlayerLayer", UFCCSModelLayer)
local CrossPVPConst = require("app.scenes.crosspvp.CrossPVPConst")

function CrossPVPDoSelectPlayerLayer.create(...)
	return CrossPVPDoSelectPlayerLayer.new("ui_layout/crosspvp_DoSelectPlayerLayer.json", Colors.modelColor, ...)
end

function CrossPVPDoSelectPlayerLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param)

	self._tListView = nil
	self._tDataList = {}

	self:_initWidgets()
end

function CrossPVPDoSelectPlayerLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- 状态切换后中，关掉自己
    uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onCloseSelf, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK, self._onReloadListView, self)

	self:_initListView()

	-- 发协议请求玩家列表
	G_HandlersManager.crossPVPHandler:sendGetLastRank(1, 1, 20)
end

function CrossPVPDoSelectPlayerLayer:onLayerExit()

end

function CrossPVPDoSelectPlayerLayer:_initWidgets()
	self:registerBtnClickEvent("Button_Close_RightTop", handler(self, self._closeWindow))
	self:registerBtnClickEvent("Button_Close", handler(self, self._closeWindow))
end

function CrossPVPDoSelectPlayerLayer:_initListView()
	if not self._tListView then
		local panel = self:getPanelByName("Panel_ListView")
		if panel then
			self._tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

			self._tListView:setCreateCellHandler(function(list, index)
				return require("app.scenes.crosspvp.CrossPVPDoSelectPlayerItem").new()
			end)

			self._tListView:setUpdateCellHandler(function(list, index, cell)
				local function clickCallback()
					self:_closeWindow()
				end
				local tRank = self._tDataList[index + 1]
				if tRank then
					cell:updateItem(tRank, clickCallback)
				end
			end)

			self._tListView:initChildWithDataLength(0)
		end
	end
end

function CrossPVPDoSelectPlayerLayer:_onReloadListView(tData)
	if self._tListView then
		for i, v in ipairs(tData.ranks) do
			local tRank = v
			local nRank = tRank.sp2
		--	table.insert(self._tDataList, nRank, v)
			table.insert(self._tDataList, #self._tDataList + 1, v)
		end

		self._tListView:reloadWithLength(table.nums(tData.ranks))
	end
end

function CrossPVPDoSelectPlayerLayer:_closeWindow()
	self:animationToClose()
end

function CrossPVPDoSelectPlayerItem:_onCloseSelf()
	self:close()
end

return CrossPVPDoSelectPlayerLayer