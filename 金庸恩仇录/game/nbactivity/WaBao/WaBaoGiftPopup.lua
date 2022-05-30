local btnCloseRes = {
normal = "#win_base_close.png",
pressed = "#win_base_close.png",
disabled = "#win_base_close.png"
}
local commonRes = {
mainFrameRes = "#win_base_bg2.png",
mainInnerRes = "#win_base_inner_bg_light.png",
tableViewBngRes = "#win_base_inner_bg_dark.png",
progressNoneBng = "#progress_zero.png",
progressFullBng = "#progress_full.png"
}
local typeEnum = {
task = 1,
road = 2,
collect = 3
}
local GiftGetItemView = require("game.nbactivity.WaBao.WaBaoGiftItemView")
local data_item_item = require("data.data_item_item")

local WaBaoGiftPopup = class("WaBaoGiftPopup", function()
	return require("utility.ShadeLayer").new(cc.c4b(0,0,0,150))
end)

function WaBaoGiftPopup:ctor(libId)
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
	self._libId = libId
	self._rank = rank
	self:load()
	local function init()
		self:setUpView()
	end
	self:initData(init)
end

function WaBaoGiftPopup:setUpView()
	local winSize = CCDirector:sharedDirector():getWinSize()
	self._mianPopup = display.newScale9Sprite(commonRes.mainFrameRes, 0, 0, cc.size(display.width - self._mainFrameWidthOffset, display.height - 100)):pos(display.cx, display.cy):addTo(self)
	self._mainPopupSize = self._mianPopup:getContentSize()
	self._innerContainerHeight = self._mainPopupSize.height - 80
	self._innerContainer = display.newScale9Sprite(commonRes.mainInnerRes, 0, 0, cc.size(self._mainPopupSize.width - self._innerContainerBorderOffset * 2, self._innerContainerHeight)):pos(self._mainPopupSize.width / 2, self._innerContainerBorderOffset):addTo(self._mianPopup)
	self._innerContainerSize = self._innerContainer:getContentSize()
	self._innerContainer:setAnchorPoint(cc.p(0.5, 0))
	
	--¹Ø±Õ°´¼ü
	local closeBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = btnCloseRes.normal,
	handle = function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end
	})
	closeBtn:align(display.CENTER, self._mainPopupSize.width - 30, self._mainPopupSize.height - 35)
	closeBtn:addTo(self._mianPopup)
	
	
	self._titleDisLabel = ui.newBMFontLabel({
	text = common:getLanguageString("@RewardsPreview"),
	size = self._titleDisFontSize,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_title
	}):pos(self._mainPopupSize.width / 2, self._mainPopupSize.height - self._titleDisOffsetOfTop):addTo(self._mianPopup)
	self._titleDisLabel:align(display.CENTER_TOP)
	self:setUpTableView()
	self:createTitleTask()
	self:reloadData()
end

function WaBaoGiftPopup:setUpTableView()
	self._tableContainer = display.newScale9Sprite(commonRes.tableViewBngRes, 0, 0, cc.size(self._innerContainerSize.width - self._tableContainerBorderOffset * 2, self._innerContainerSize.height + 70)):pos(self._tableContainerBorderOffset, self._tableContainerBorderOffset):addTo(self._innerContainer)
	self._tableContainer:setAnchorPoint(cc.p(0, 0))
	self._tableContainerSize = self._tableContainer:getContentSize()
	self:selectContent(self._tableContainer, index)
end

function WaBaoGiftPopup:selectContent(innerContainer, index)
	local innerSize = innerContainer:getContentSize()
	self.tableView = CCTableView:create(cc.size(innerSize.width, innerSize.height - 20))
	self.tableView:setPosition(cc.p(0, 10))
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

function WaBaoGiftPopup:scrollViewDidScroll(view)
end

function WaBaoGiftPopup:scrollViewDidZoom(view)
end

function WaBaoGiftPopup:tableCellTouched(view, cell, x, y)
	for i = 1, cell:getChildByTag(1):getIconNum() do
		local icon, data = cell:getChildByTag(1):getIcon(i)
		local pos = icon:convertToNodeSpace(cc.p(x, y))
		if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
			self:onIconClick(data)
			break
		end
	end
end

function WaBaoGiftPopup:onIconClick(data)
	local sceneLayer = self
	if tonumber(data.type) ~= 6 then
		if not sceneLayer:getChildByTag(1111) then
			local function closeFunc()
			end
			local itemInfo = require("game.Huodong.ItemInformation").new({
			id = tonumber(data.id),
			type = tonumber(data.type),
			name = data_item_item[tonumber(data.id)].name,
			describe = data_item_item[tonumber(data.id)].describe,
			endFunc = closeFunc
			})
			sceneLayer:addChild(itemInfo, 1000, 1111)
		end
	else
		local function closeFunc()
		end
		if not sceneLayer:getChildByTag(1111) then
			local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
			resId = tonumber(data.id)
			}, nil, closeFunc)
			sceneLayer:addChild(descLayer, 1000, 1111)
		end
	end
end

function WaBaoGiftPopup:cellSizeForTable(table, idx)
	local count = math.ceil(#self._data[idx + 1] / 4)
	return 60 + math.ceil(count * 130) + 10, self._tableContainerSize.width
end

function WaBaoGiftPopup:tableCellAtIndex(table, idx)
	local cell = CCTableViewCell:new()
	local count = #self._data[idx + 1]
	local itemView = GiftGetItemView.new(cc.size(self._tableContainerSize.width, 60 + math.ceil(count / 4) * 130), self._data[idx + 1], self._mainMenuScene, self)
	itemView:setPositionY(itemView:getPositionY() - 15)
	cell:addChild(itemView, 1, 1)
	return cell
end

function WaBaoGiftPopup:numberOfCellsInTableView(tableView)
	return table.maxn(self._data)
end

function WaBaoGiftPopup:reloadData()
	self.tableView:setViewSize(cc.size(self._tableContainerSize.width, self._tableContainerSize.height - 110))
	self._tableContainer:setContentSize(cc.size(self._tableContainerSize.width, self._tableContainerSize.height - 90))
	self.tableView:reloadData()
end

function WaBaoGiftPopup:createTitleTask()
	local leftAdgeOffset = 30
	local titleViewHeight = 110
	self.titleView = CCLayer:create()
	self.titleView:setContentSize(cc.size(self._tableContainerSize.width, titleViewHeight))
	self.titleView:setAnchorPoint(cc.p(0, 1))
	self.titleView:setPosition(cc.p(0, self._innerContainerHeight - 100))
	self._innerContainer:addChild(self.titleView)
end

function WaBaoGiftPopup:initData(func)
	self._data = {}
	local dataBase = require("data.data_daojuku_daojuku")[tonumber(self._libId)]
	local dataTemp = {}
	for k, v in pairs(dataBase.arr_item) do
		local _dataTemp = {}
		_dataTemp.type = dataBase.arr_type[k]
		_dataTemp.id = dataBase.arr_item[k]
		_dataTemp.num = dataBase.arr_num[k]
		table.insert(dataTemp, _dataTemp)
	end
	self._data = {dataTemp}
	func()
end

function WaBaoGiftPopup:load()
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
end

return WaBaoGiftPopup