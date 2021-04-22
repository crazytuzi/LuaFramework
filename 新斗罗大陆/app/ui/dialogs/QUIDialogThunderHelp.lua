
--[[	
	文件名称：QUIDialogThunderHelp.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogThunderHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogThunderHelp = class("QUIDialogThunderHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogThunderHelp:ctor(options)
	QUIDialogThunderHelp.super.ctor(self,options)
end

function QUIDialogThunderHelp:initData( options )
	-- body
	local data = {}
	self._data = data
	

	table.insert(data,{oType = "describe", info = {
		helpType = "leidian_shuoming",
		}})

end

function QUIDialogThunderHelp:initListView( ... )
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
	          
	            item:setInfo(itemData.info or {}, itemData.customStr)
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 15,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end



return QUIDialogThunderHelp
