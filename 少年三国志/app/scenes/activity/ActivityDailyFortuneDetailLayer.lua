-- 招财符详细信息界面

local ActivityDailyFortuneDetailLayer = class("ActivityDailyFortuneDetailLayer", UFCCSModelLayer)
 
local ActivityDailyFortuneDetailItem = require("app.scenes.activity.ActivityDailyFortuneDetailItem")

function ActivityDailyFortuneDetailLayer.show( ... )
	local layer = ActivityDailyFortuneDetailLayer.new( "ui_layout/activity_DailyFortuneDetailLayer.json", Colors.modelColor, ... )
	uf_sceneManager:getCurScene():addChild(layer)
end


function ActivityDailyFortuneDetailLayer:ctor( json, color, ... )
	self._listView = nil
	self._listData = G_Me.activityData.fortune:getFortuneDetailInfo()

	self:registerBtnClickEvent("Button_Close", function (  )
		self:animationToClose()
	end)

	self.super.ctor(self, json)
end


function ActivityDailyFortuneDetailLayer:onLayerEnter(  )
	require("app.common.effects.EffectSingleMoving").run(self:getImageViewByName("ImageView_Bg"), "smoving_bounce")
	self:closeAtReturn(true)
	self:showAtCenter(true)

	if not self._listView then
		self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_ListView"), LISTVIEW_DIR_VERTICAL)
		self._listView:setCreateCellHandler(function ( list, index )
			return ActivityDailyFortuneDetailItem.new()
		end)
		self._listView:setUpdateCellHandler(function ( list, index, cell )
			cell:update(self._listData[index + 1])
		end)
		self._listView:initChildWithDataLength(#self._listData)
	else
		self._listView:refreshAllCell()
	end

end





return ActivityDailyFortuneDetailLayer