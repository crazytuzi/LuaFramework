-- @Author: xurui
-- @Date:   2019-05-16 11:01:51
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-05-16 12:08:02
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogSoulLetterHelp = class("QUIDialogSoulLetterHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")
--初始化
function QUIDialogSoulLetterHelp:ctor(options)
	QUIDialogSoulLetterHelp.super.ctor(self,options)
end

function QUIDialogSoulLetterHelp:initData( options )
	-- body
	local data = {}
	self._data = data
	
	local helpType = self:getOptions().helpType or "help_battle_pass1"
	table.insert(data,{oType = "describe", info = {
		helpType = helpType,
		}})

	-- 去掉是否多倍信息，由策划在describe配置
	-- local expInfo = self:getTaskExpInfoStr()
	-- if expInfo ~= "" then
	-- 	table.insert(data,{oType = "describe", customStr = expInfo, info = {lineHeight = 50}})
	-- end
end

function QUIDialogSoulLetterHelp:getTaskExpInfoStr()
	local info = ""
	local tStr = ""

	local multipleTime = db:getConfigurationValue("shouzha_multiple_time") or "6,7"
	multipleTime = string.split(multipleTime, ",")
	if not q.isEmpty(multipleTime) then
		for _, wday in ipairs(multipleTime) do
			tStr = q.numToWord(tonumber(wday))
			if wday == "7" then
				tStr = "日"
			end
			info = info .. "周" .. tStr
		end

		local multipleNum = db:getConfigurationValue("shouzha_multiple") or 2
		tStr = q.numToWord(multipleNum)
		if multipleNum == 2 then
			tStr = "双"
		end
		info = info .. "完成任务可获得" .. tStr .. "倍经验"
	end

	return info
end

function QUIDialogSoulLetterHelp:initListView( ... )
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
	            	elseif itemData.oType == "title" then
	            		item = QUIWidgetBaseHelpTitle.new()
	            	elseif itemData.oType == "award" then
	            		item = QUIWidgetBaseHelpAward.new()
	            	elseif itemData.oType == "line" then
	            		item = QUIWidgetBaseHelpLine.new()
	            	elseif itemData.oType == "empty" then
	            		item = QUIWidgetQlistviewItem.new()
	            	end
	            	isCacheNode = false
	            end
	            if itemData.oType == "empty" then
	            	item:setContentSize(CCSizeMake(0, itemData.height))
	            elseif itemData.oType == "describe" then
	            	item:setInfo(itemData.info or {}, itemData.customStr)
	            else
	            	item:setInfo(itemData.info)
	            end
	           
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

return QUIDialogSoulLetterHelp