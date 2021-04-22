-- @Author: xurui
-- @Date:   2016-10-31 14:54:56
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-19 14:28:52

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogBlackRockRule = class("QUIDialogBlackRockRule", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogBlackRockRule:ctor(options)

	self.index = options.index
	self._dialogType = options.dialogType

	QUIDialogBlackRockRule.super.ctor(self, ccbFile, callBack, options)
end
function QUIDialogBlackRockRule:initData(  )
	-- body
	local data = {}
	if self._dialogType == "customsIntroduction" then
		if app.unlock:checkLock("UNLOCK_CHUANLINGTA_SAODANG2", false) then
			table.insert(data,{oType = "describe", info = { helpType = "help_chuanlingta_saodang2"}})
		else 
			table.insert(data,{oType = "describe", info = { helpType = "help_chuanlingta_saodang"}})
		end
	else
		table.insert(data,{oType = "describe", info = { helpType = "black_rock_shuoming_1"}})
		table.insert(data,{oType = "describe", info = { helpType = "black_rock_shuoming_2"}})
		table.insert(data,{oType = "describe", info = { helpType = "black_rock_shuoming_3"}})
		table.insert(data,{oType = "describe", info = { helpType = "black_rock_shuoming_4"}})
		table.insert(data,{oType = "describe", info = { helpType = "black_rock_shuoming_5"}})
		table.insert(data,{oType = "rank"})
		table.insert(data,{oType = "describe", info = { helpType = "black_rock_shuoming_6"}})
	end

	self._data = data
end

function QUIDialogBlackRockRule:initListView( ... )
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
            		elseif itemData.oType == "rank" then
            			item = self:getRankNode()
	            	end
	            	isCacheNode = false
	            end
            	if itemData.oType == "describe" then
	            	item:setInfo(itemData.info)
	            end
	            info.tag = itemData.oType
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 20,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	headIndex = self.index,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end

function QUIDialogBlackRockRule:getRankNode()
	local node = CCNode:create()
	local rewards = QStaticDatabase:sharedDatabase():getBlackRockRewardGropByLevel(remote.user.level)
	local height = 30
	for _,reward in ipairs(rewards) do
		local awards = remote.items:analysisServerItem(reward.awards)
		local widget = QUIWidget.new("ccb/Widget_RewardRules_client3.ccbi")
		local rank = reward.rank
		if reward.rank ~= reward.rank_2 then
			rank = rank.."~"..reward.rank_2
		end
		widget._ccbOwner.tf_1:setString(string.format("第%s名", rank))
		widget._ccbOwner.rank:setString("")
		widget._ccbOwner.tf_2:setString("")
		local posX = 70--widget._ccbOwner.tf_1:getContentSize().width - 70
		if posX < 0 then posX = 0 end
		for i=1,5 do
			if awards[i] ~= nil then
				local itemBox = QUIWidgetItemsBox.new()
				itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
				itemBox:setScale(0.5)
				widget._ccbOwner["item"..i]:addChild(itemBox)
				widget._ccbOwner["reward_nums"..i]:setString("x "..awards[i].count)
				widget._ccbOwner["item"..i]:setPositionX(widget._ccbOwner["item"..i]:getPositionX() + posX)
				widget._ccbOwner["reward_nums"..i]:setPositionX(widget._ccbOwner["reward_nums"..i]:getPositionX() + posX)
			else
				widget._ccbOwner["reward_nums"..i]:setString("")
			end
		end
		widget:setPosition(ccp(430, -height))
		node:addChild(widget)
		height = height + 40
	end
	node:setContentSize(CCSize(100,height))
	return node
end


return QUIDialogBlackRockRule