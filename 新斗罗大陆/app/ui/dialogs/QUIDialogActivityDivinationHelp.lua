
--[[	
	文件名称：QUIDialogActivityDivinationHelp.lua
	创建时间：2016-10-25 19:21:53
	作者：nieming
	描述：QUIDialogActivityDivinationHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogActivityDivinationHelp = class("QUIDialogActivityDivinationHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIDialogActivityDivinationHelp:ctor(options)
	QUIDialogActivityDivinationHelp.super.ctor(self,ccbFile,callBacks,options)
end


function QUIDialogActivityDivinationHelp:initData(  )
	-- body
	local data = {}

	local scoreConf = 0
	local imp = remote.activityRounds:getDivination()
	if imp  then
		local temp = QStaticDatabase:sharedDatabase():getDivinationShowInfo(imp.rowNum) or {}

		scoreConf = temp.rank_min or 0
	end
	

	table.insert(data,{oType = "describe", info = {
		helpType = "zhanbu_shuoming",
		paramArr = {scoreConf}
		}})

	self._data = data
end

function QUIDialogActivityDivinationHelp:initListView( ... )
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


return QUIDialogActivityDivinationHelp
