-- @Author: xurui
-- @Date:   2016-10-31 14:54:56
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-10-31 14:57:48

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogWorldBossRule = class("QUIDialogWorldBossRule", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogWorldBossRule:ctor(options)
	QUIDialogWorldBossRule.super.ctor(self, ccbFile, callBack, options)
end
function QUIDialogWorldBossRule:initData(  )
	-- body
	local data = {}

	table.insert(data,{oType = "describe", info = {
		helpType = "yaosai_boss_shuoming",
		-- paramArr = {remote.activityRounds:getTurntable():getRankScoreCondition() or 0, remote.activityRounds:getTurntable():getSpecialAwardRank() or 0},
		}})

	self._data = data
end

function QUIDialogWorldBossRule:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	if itemData.oType == "describe" then
	            		item = QUIWidgetHelpDescribe.new()
	            	end
	            	isCacheNode = false
	            end
	            item:setInfo(itemData.info)
	            info.tag = itemData.oType
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 20,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end


return QUIDialogWorldBossRule