-- GroupBuyAwardLayer.lua

local GroupBuyConst = require("app.const.GroupBuyConst")
local GroupBuyCommon = require("app.scenes.groupbuy.GroupBuyCommon")
require("app.cfg.group_buy_award_info")

local table = table

local GroupBuyAwardLayer = class("GroupBuyAwardLayer", UFCCSModelLayer)

function GroupBuyAwardLayer.show(...)
	local layer = GroupBuyAwardLayer.new("ui_layout/groupbuy_AwardLayer.json", Colors.modelColor, ...)
	if layer then 
		uf_sceneManager:getCurScene():addChild(layer)
	end
end

function GroupBuyAwardLayer:ctor( ... )
	self.super.ctor(self, ...)

	self._listView = nil

	self._data    = GroupBuyCommon.getData()
	self._handler = GroupBuyCommon.getHandler()

	self:registerBtnClickEvent("Button_TopClose", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCancelClick))

	self:_initScrollView()
end

function GroupBuyAwardLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_BG"), "smoving_bounce")

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GROUPBUY_DAILY_AWARD_GET, self._onGetReward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GROUPBUY_DAILY_AWARD_LOAD, self._onLoadView, self)

	self._handler:sendGetGroupBuyTaskAwardInfo()
end

function GroupBuyAwardLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end

function GroupBuyAwardLayer:_initScrollView()
    self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_List"), LISTVIEW_DIR_VERTICAL)
    self._listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.groupbuy.GroupBuyAwardCell").new(list, index)
    end)
    self._listView:setUpdateCellHandler(function ( list, index, cell)
    	local list = self:_getAwardData()
    	cell:updateItem(list[index + 1])
    end)
    self._listView:initChildWithDataLength(0)
end

function GroupBuyAwardLayer:_onCancelClick()
	self:animationToClose()
end

function GroupBuyAwardLayer:_getAwardData()
	local list = self._data:getAwardData()
	local function sortFunc(lhs, rhs)
		local ls = self._data:isDailyAwardAlreadyGet(lhs.id) and 1 or 2
		local rs = self._data:isDailyAwardAlreadyGet(rhs.id) and 1 or 2
		if ls ~= rs then
			return ls > rs
		end
		-- if lhs.task_type == GroupBuyConst.DAILY_AWARD_TYPE.BACKGOLD then
		-- 	return true
		if lhs.task_type == rhs.task_type then
			return lhs.id < rhs.id
		else
			return lhs.task_type > rhs.task_type
		end
	end
	table.sort(list, sortFunc)

	return list
end

function GroupBuyAwardLayer:_onLoadView()
	self._listView:reloadWithLength(#self:_getAwardData())
end

function GroupBuyAwardLayer:_onGetReward(data)
	if type(data) ~= "table" then data = {} end
	if data.awards then
		GroupBuyCommon.showGetItemLayer(data.awards)
	end
	self._listView:refreshAllCell()
end

return GroupBuyAwardLayer
