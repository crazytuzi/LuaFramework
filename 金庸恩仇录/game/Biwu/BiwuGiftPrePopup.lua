local btnCloseRes = {
normal = "#win_base_close.png",
pressed = "#win_base_close.png",
disabled = "#win_base_close.png"
}
local goldStateRes = {
normal = "#gold_close.png",
pressed = "#gold_open.png",
disabled = "#gold_none.png"
}
local RADIO_BUTTON_IMAGES = {
task = {
off = "#task_p.png",
off_pressed = "#task_p.png",
off_disabled = "#task_p.png",
on = "#task_n.png",
on_pressed = "#task_n.png",
on_disabled = "#task_n.png"
},
road = {
off = "#road_p.png",
off_pressed = "#road_p.png",
off_disabled = "#road_p.png",
on = "#road_n.png",
on_pressed = "#road_n.png",
on_disabled = "#road_n.png"
},
collect = {
off = "#collect_p.png",
off_pressed = "#collect_p.png",
off_disabled = "#collect_p.png",
on = "#collect_n.png",
on_pressed = "#collect_n.png",
on_disabled = "#collect_n.png"
}
}
local commonRes = {
mainFrameRes = "#win_base_bg2.png",
mainInnerRes = "#win_base_inner_bg_light.png",
tableViewBngRes = "#win_base_bg3.png",
progressNoneBng = "#progress_zero.png",
progressFullBng = "#progress_full.png",
goldOpen = "#gold_open.png"
}

local typeEnum = {
task = 1,
road = 2,
collect = 3
}

local titleDis = {
task = common:getLanguageString("@DailyTask"),
road = common:getLanguageString("@GrowUp"),
collect = common:getLanguageString("@Collection")
}

local GiftGetItemView = require("game.Biwu.BiwuGiftPreItemView")
require("game.DialyTask.TaskModel")

local BiwuGiftRrePopup = class("BiwuGiftRrePopup", function()
	return display.newLayer("BiwuGiftRrePopup")
end)

function BiwuGiftRrePopup:ctor(rank)
	self._mainFrameHeightOffset = 100
	self._mainFrameWidthOffset = 20
	self._mainPopupSize = nil
	self._innerContainerBorderOffset = 10
	self._innerContainerHeight = 100
	self._innerContainerSize = nil
	self._titleDisOffsetOfTop = 20
	self._titleDisFontSize = 25
	self._checkBoxMargin = -10
	self._mianPopup = nil
	self._innerContainer = nil
	self._tableContainer = nil
	self._tableContainerSize = nil
	self._tableContainerBorderOffset = 10
	self._titleDisLabel = nil
	self._tableCellHeight = 130
	self._rank = rank
	self:initData()
	self:setUpView()
end

function BiwuGiftRrePopup:setUpView()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local mask = CCLayerColor:create()
	mask:setContentSize(winSize)
	mask:setColor(cc.c3b(0, 0, 0))
	mask:setOpacity(150)
	mask:setAnchorPoint(cc.p(0, 0))
	mask:setTouchEnabled(true)
	self:addChild(mask)
	self._mianPopup = display.newScale9Sprite(commonRes.mainFrameRes, 0, 0, cc.size(display.width - self._mainFrameWidthOffset, display.height - 100)):pos(display.cx, display.cy):addTo(self)
	self._mainPopupSize = self._mianPopup:getContentSize()
	self._innerContainerHeight = self._mainPopupSize.height - 80
	self._innerContainer = display.newScale9Sprite(commonRes.mainInnerRes, 0, 0, cc.size(self._mainPopupSize.width - self._innerContainerBorderOffset * 2, self._innerContainerHeight)):pos(self._mainPopupSize.width / 2, self._innerContainerBorderOffset):addTo(self._mianPopup)
	self._innerContainerSize = self._innerContainer:getContentSize()
	self._innerContainer:setAnchorPoint(cc.p(0.5, 0))
	
	local closeBtn = display.newSprite(btnCloseRes.normal)
	addTouchListener(closeBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			self:removeFromParent()
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	
	closeBtn:pos(self._mainPopupSize.width - 30, self._mainPopupSize.height - 30)
	closeBtn:addTo(self._mianPopup):setAnchorPoint(cc.p(0.5, 0.5))
	self._titleDisLabel = ui.newBMFontLabel({
	text = common:getLanguageString("@RewardsPreview"),
	size = self._titleDisFontSize,
	align = ui.TEXT_ALIGN_CENTE,
	font = "fonts/font_title.fnt"
	}):pos(self._mainPopupSize.width / 2, self._mainPopupSize.height - self._titleDisOffsetOfTop):addTo(self._mianPopup)
	self._titleDisLabel:setAnchorPoint(cc.p(0.5, 1))
	self:setUpTableView()
	self:createTitleTask()
	self:reloadData()
end

function BiwuGiftRrePopup:setUpTableView()
	local titleDis = ui.newTTFLabel({
	text = common:getLanguageString("@SaturdayTxt"),
	color = cc.c3b(92, 38, 1),
	size = 22,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	:pos(self._innerContainerSize.width / 2, self._innerContainerSize.height - 30):addTo(self._innerContainer)
	self._tableContainer = display.newScale9Sprite(commonRes.tableViewBngRes, 0, 0, cc.size(self._innerContainerSize.width - self._tableContainerBorderOffset * 2, self._innerContainerSize.height + 20)):pos(self._tableContainerBorderOffset, self._tableContainerBorderOffset):addTo(self._innerContainer)
	self._tableContainer:setAnchorPoint(cc.p(0, 0))
	self._tableContainerSize = self._tableContainer:getContentSize()
	self:selectContent(self._tableContainer, index)
end

function BiwuGiftRrePopup:selectContent(innerContainer, index)
	local innerSize = innerContainer:getContentSize()
	self.tableView = CCTableView:create(cc.size(innerSize.width, innerSize.height - 40))
	self.tableView:setPosition(cc.p(0, 20))
	self.tableView:setAnchorPoint(cc.p(0.5, 0.5))
	self.tableView:setDelegate()
	innerContainer:addChild(self.tableView)
	local listenerEnum = {
	CCTableView.kNumberOfCellsInTableView,
	CCTableView.kTableViewScroll,
	CCTableView.kTableViewZoom,
	CCTableView.kTableCellTouched,
	CCTableView.kTableCellSizeForIndex,
	CCTableView.kTableCellSizeAtIndex
	}
	local listenerFuc = {
	"numberOfCellsInTableView",
	"scrollViewDidScroll",
	"scrollViewDidZoom",
	"tableCellTouched",
	"cellSizeForTable",
	"tableCellAtIndex"
	}
	for key, var in pairs(listenerEnum) do
		self.tableView:registerScriptHandler(function(...)
			return self[listenerFuc[key]](self, ...)
		end,
		var)
	end
	self.tableView:setDirection(kCCScrollViewDirectionVertical)
	self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

function BiwuGiftRrePopup:scrollViewDidScroll(view)
	--dump("scrollViewDidScroll")
end

function BiwuGiftRrePopup:scrollViewDidZoom(view)
	--dump("scrollViewDidZoom")
end

function BiwuGiftRrePopup:tableCellTouched(table, cell)
	--dump("cell touched at index: " .. cell:getIdx())
end

function BiwuGiftRrePopup:cellSizeForTable(table, idx)
	return 220, self._tableContainerSize.width
end

function BiwuGiftRrePopup:tableCellAtIndex(table, idx)
	local cell = CCTableViewCell:new()
	local itemView = GiftGetItemView.new(cc.size(self._tableContainerSize.width, 220), self._data[idx + 1], self._mainMenuScene, self)
	cell:addChild(itemView)
	return cell
end

function BiwuGiftRrePopup:numberOfCellsInTableView(tableView)
	return table.maxn(self._data)
end

function BiwuGiftRrePopup:reloadData()
	self.tableView:setViewSize(cc.size(self._tableContainerSize.width, self._tableContainerSize.height - 130))
	self._tableContainer:setContentSize(cc.size(self._tableContainerSize.width, self._tableContainerSize.height - 90))
	self.tableView:reloadData()
end

function BiwuGiftRrePopup:createTitleTask()
	local leftAdgeOffset = 30
	local titleViewHeight = 110
	self.titleView = CCLayer:create()
	self.titleView:setContentSize(cc.size(self._tableContainerSize.width, titleViewHeight))
	self.titleView:setAnchorPoint(cc.p(0, 1))
	self.titleView:setPosition(cc.p(0, self._innerContainerHeight - 100))
	self._innerContainer:addChild(self.titleView)
end

function BiwuGiftRrePopup:initData()
	self._data = {}
	local data_item_item = require("data.data_item_item")
	local data_biwu_jiangli_biwu_jiangli = require("data.data_biwu_jiangli_biwu_jiangli")
	for k, v in pairs(data_biwu_jiangli_biwu_jiangli) do
		local dataBase = v
		local giftData = {}
		local dataTemp = {}
		dataTemp.id = 2
		dataTemp.iconType = ResMgr.getResType(7)
		dataTemp.type = 7
		dataTemp.num = v.fix + v.ratio * game.player:getLevel()
		dataTemp.name = common:getLanguageString("@SilverCoin")
		table.insert(giftData, dataTemp)
		if type(dataBase.rewardIds) == "table" then
			for k, v in pairs(dataBase.rewardIds) do
				local dataTemp = {}
				dataTemp.id = v
				dataTemp.iconType = ResMgr.getResType(dataBase.rewardTypes[k])
				dataTemp.type = dataBase.rewardTypes[k]
				dataTemp.num = dataBase.rewardNums[k]
				dataTemp.name = data_item_item[dataTemp.id].name
				table.insert(giftData, dataTemp)
			end
		else
			local dataTemp = {}
			dataTemp.id = dataBase.rewardIds
			dataTemp.iconType = ResMgr.getResType(dataBase.rewardTypes)
			dataTemp.num = dataBase.rewardNums
			dataTemp.name = data_item_item[dataTemp.id].name
			dataTemp.type = dataBase.rewardTypes
			table.insert(giftData, dataTemp)
		end
		v.giftData = giftData
		table.insert(self._data, v)
	end
	table.sort(self._data, function(a, b)
		return a.min < b.min
	end)
end

return BiwuGiftRrePopup