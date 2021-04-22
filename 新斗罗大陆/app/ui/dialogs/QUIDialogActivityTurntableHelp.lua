--[[	
	文件名称：QUIDialogActivityTurntableHelp.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogActivityTurntableHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogActivityTurntableHelp = class("QUIDialogActivityTurntableHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogActivityTurntableHelp:ctor(options)
	QUIDialogActivityTurntableHelp.super.ctor(self,ccbFile,callBacks,options)
end


function QUIDialogActivityTurntableHelp:initData(  )
	-- body
	local data = {}

	table.insert(data,{oType = "describe", info = {
		helpType = "activity_turntable",
		paramArr = {remote.activityRounds:getTurntable():getRankScoreCondition() or 0, remote.activityRounds:getTurntable():getSpecialAwardRank() or 0},
		}})

	self._data = data
end

function QUIDialogActivityTurntableHelp:initListView( ... )
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


return QUIDialogActivityTurntableHelp
