-- @Author: xurui
-- @Date:   2020-01-02 12:28:17
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-02 12:29:52
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogTotemChallengeHelp = class("QUIDialogTotemChallengeHelp", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")
--初始化
function QUIDialogTotemChallengeHelp:ctor(options)
	QUIDialogTotemChallengeHelp.super.ctor(self,options)
end

function QUIDialogTotemChallengeHelp:initData( options )
	-- body
	local options = self:getOptions() 
	self.info = options.info or {} 

	local data = {}
	self._data = data
	table.insert(data, {oType = "describe", info = {helpType = "shengzhutiaozhan", lineSpacing = 0}})

	table.insert(data, {oType = "title", info = {name = "每周结算奖励:", pos = ccp(30, -10), size = CCSizeMake(720, 40)}})
	table.insert(data, {oType = "title", info = {name2 = "困难模式下，对应关卡圣柱币奖励增加20%。", pos = ccp(30, -10), size = CCSizeMake(720, 40)}})

	local i  = 1
	while true do

		local rewardConfig = remote.totemChallenge:getDungeonRewardConfigById(i)
		if  not q.isEmpty(rewardConfig)  then
			local reward = db:getLuckyDrawAwardTable(rewardConfig.week_reward)
			if not q.isEmpty(reward) and i <= 21 then -- 21关之后为困难模式的奖励，不需要重新显示
				print("i ---- ",i)
				QPrintTable(reward)
				local temp = {}
				local awardsArr = {}
				for i,v in ipairs(reward) do
					table.insert(awardsArr, {id = v.id or v.itemType, count = v.count})
				end

				temp.awardsArr = awardsArr
				local intStr,floatStr = math.floor(i/7),math.fmod(i,7)
				if floatStr == 0 then
					floatStr = 7
				else
					intStr = intStr + 1
				end
				temp.rankStr = intStr .. "-" ..floatStr

				table.insert(data, {oType = "award", info = temp})	
				i = i + 1
			else
				break
			end
		else
			break
		end
	end

end

function QUIDialogTotemChallengeHelp:initListView( ... )
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

return QUIDialogTotemChallengeHelp
