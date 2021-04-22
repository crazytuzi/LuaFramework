
--[[	
	文件名称：QUIDialogPlunderHelp.lua
	创建时间：2016-10-25 19:21:53
	作者：nieming
	描述：QUIDialogPlunderHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogPlunderHelp = class("QUIDialogPlunderHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIDialogPlunderHelp:ctor(options)
	QUIDialogPlunderHelp.super.ctor(self,ccbFile,callBacks,options)
end


function QUIDialogPlunderHelp:initData(  )
	-- body
	local data = {}

	local scoreConf = 0
	local imp = remote.activityRounds:getDivination()
	if imp  then
		local temp = QStaticDatabase:sharedDatabase():getDivinationShowInfo(imp.rowNum) or {}

		scoreConf = temp.rank_min or 0
	end
	

	table.insert(data,{oType = "describe", info = {
		helpType = "gonghui_kuangzhan",
		paramArr = {scoreConf}
		}})

	self._data = data
end

function QUIDialogPlunderHelp:initListView( ... )
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


return QUIDialogPlunderHelp
