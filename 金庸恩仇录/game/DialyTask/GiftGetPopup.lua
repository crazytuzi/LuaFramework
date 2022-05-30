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

local GiftGetItemView = import(".GiftGetItemView")

local GiftGetPopup = class("GiftGetPopup", function()
	return display.newLayer("GiftGetPopup")
end)

function GiftGetPopup:ctor(mainscene)
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
	self.taskModel = TaskModel:getInstance()
	self._data = self.taskModel:getRewordList()
	dump(self._data)
	self._mainMenuScene = mainscene
	self:setUpView()
end

function GiftGetPopup:setUpView()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local mask = CCLayerColor:create()
	mask:setContentSize(winSize)
	mask:setColor(ccc3(0, 0, 0))
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
	
	--¹Ø±Õ°´Å¥
	
	local closeBtn = ResMgr.newNormalButton({
	scaleBegan = 1.1,
	sprite = btnCloseRes,
	handle = function ()
		self:getParent():update()
		self:removeFromParent()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end
	})
	closeBtn:align(display.CENTER, self._mainPopupSize.width - 30, self._mainPopupSize.height - 30)
	closeBtn:addTo(self._mianPopup)	
	
	self._titleDisLabel = ui.newBMFontLabel({
	text = common:getLanguageString("@RewardGet"),
	size = self._titleDisFontSize,
	align = ui.TEXT_ALIGN_CENTE,
	font = FONTS_NAME.font_title
	}):pos(self._mainPopupSize.width / 2, self._mainPopupSize.height - self._titleDisOffsetOfTop):addTo(self._mianPopup)
	self._titleDisLabel:setAnchorPoint(cc.p(0.5, 1))
	self:setUpTableView()
	self:createTitleTask()
	self:reloadData()
end

function GiftGetPopup:setUpTableView()
	self._tableContainer = display.newScale9Sprite(commonRes.tableViewBngRes, 0, 0, cc.size(self._innerContainerSize.width - self._tableContainerBorderOffset * 2, self._innerContainerSize.height - 10)):pos(self._tableContainerBorderOffset, self._tableContainerBorderOffset):addTo(self._innerContainer)
	self._tableContainer:setAnchorPoint(cc.p(0, 0))
	self._tableContainerSize = self._tableContainer:getContentSize()
	self:selectContent(self._tableContainer, index)
end

function GiftGetPopup:update()
	local leftAdgeOffset = 30
	local titleViewHeight = 110
	self._goldIcon:removeFromParent()
	local titleViewSize = self.titleView:getContentSize()
	local res
	if self.taskModel:checkHasReword() then
		res = goldStateRes.pressed
	else
		res = goldStateRes.normal
	end
	self._goldIcon = display.newSprite(res)
	self._goldIcon:setAnchorPoint(cc.p(0, 0.5))
	self._goldIcon:setPosition(cc.p(leftAdgeOffset, titleViewSize.height / 2 - 20))
	if not self.taskModel:checkHasReword() then
		self._goldIcon:removeChildByTag(111)
	else
		local xunhuanEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "fubenjiangli_shanguang",
		isRetain = true
		})
		xunhuanEffect:setPosition(self._goldIcon:getContentSize().width / 2, self._goldIcon:getContentSize().height / 2)
		self._goldIcon:addChild(xunhuanEffect, 0, 111)
	end
	self.titleView:addChild(self._goldIcon)
end

function GiftGetPopup:selectContent(innerContainer, index)
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

function GiftGetPopup:scrollViewDidScroll(view)
	dump("scrollViewDidScroll")
end

function GiftGetPopup:scrollViewDidZoom(view)
	dump("scrollViewDidZoom")
end

function GiftGetPopup:tableCellTouched(table, cell)
	dump("cell touched at index: " .. cell:getIdx())
end

function GiftGetPopup:cellSizeForTable(table, idx)
	return 220, self._tableContainerSize.width
end

function GiftGetPopup:tableCellAtIndex(table, idx)
	local cell = CCTableViewCell:new()
	local itemView = GiftGetItemView.new(cc.size(self._tableContainerSize.width, 220), self._data[idx + 1], self._mainMenuScene, self)
	cell:addChild(itemView)
	return cell
end

function GiftGetPopup:numberOfCellsInTableView(tableView)
	return table.maxn(self._data)
end

function GiftGetPopup:reloadData()
	self.tableView:setViewSize(cc.size(self._tableContainerSize.width, self._tableContainerSize.height - 130))
	self._tableContainer:setContentSize(cc.size(self._tableContainerSize.width, self._tableContainerSize.height - 90))
	self.tableView:reloadData()
end

function GiftGetPopup:createTitleTask()
	local leftAdgeOffset = 30
	local titleViewHeight = 110
	self.titleView = CCLayer:create()
	self.titleView:setContentSize(cc.size(self._tableContainerSize.width, titleViewHeight))
	self.titleView:setAnchorPoint(cc.p(0, 1))
	self.titleView:setPosition(cc.p(0, self._innerContainerHeight - 100))
	self._innerContainer:addChild(self.titleView)
	local titleViewSize = self.titleView:getContentSize()
	local goldIcon = display.newSprite(commonRes.goldOpenRes)
	goldIcon:setAnchorPoint(cc.p(0, 0.5))
	goldIcon:setPosition(cc.p(leftAdgeOffset, titleViewSize.height / 2 + 10))
	self.titleView:addChild(goldIcon)
	local titleViewSize = self.titleView:getContentSize()
	local res
	if self.taskModel:checkHasReword() then
		res = goldStateRes.pressed
	else
		res = goldStateRes.normal
	end
	local xunhuanEffect
	if self.taskModel:checkHasReword() then
		xunhuanEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "fubenjiangli_shanguang",
		isRetain = true
		})
	else
		res = goldStateRes.normal
	end
	self._goldIcon = display.newSprite(res)
	self._goldIcon:setTouchEnabled(true)
	if self.taskModel:checkHasReword() then
		xunhuanEffect:setPosition(self._goldIcon:getContentSize().width / 2, self._goldIcon:getContentSize().height / 2)
		self._goldIcon:addChild(xunhuanEffect, 0, 111)
	end
	self._goldIcon:setAnchorPoint(cc.p(0, 0.5))
	self._goldIcon:setPosition(cc.p(leftAdgeOffset, titleViewSize.height / 2 - 20))
	self.titleView:addChild(self._goldIcon)
	local countDisLeftOffset = 5
	local iconSize = self._goldIcon:getContentSize()
	local countDis = ui.newTTFLabel({
	text = common:getLanguageString("@CurrentScore"),
	font = FONTS_NAME.font_fzcy,
	size = 22,
	color = cc.c3b(64, 37, 7),
	align = ui.TEXT_ALIGN_LEFT
	})
	countDis:setAnchorPoint(cc.p(0, 1))
	countDis:setPosition(cc.p(leftAdgeOffset + iconSize.width + countDisLeftOffset, titleViewSize.height - 30))
	self.titleView:addChild(countDis)
	local jifen = TaskModel:getInstance():getJifen()
	local posX = countDis:getPositionX()
	local offset = countDis:getContentSize().width + 10
	local countDis = ui.newTTFLabel({
	text = jifen,
	font = FONTS_NAME.font_fzcy,
	size = 22,
	color = cc.c3b(147, 5, 5),
	align = ui.TEXT_ALIGN_LEFT
	})
	countDis:setAnchorPoint(cc.p(0, 1))
	countDis:setPosition(cc.p(posX + offset, titleViewSize.height - 30))
	self.titleView:addChild(countDis)
	local posX = countDis:getPositionX()
	local offset = countDis:getContentSize().width + 10
	local countDis = ui.newTTFLabel({
	text = "/" .. TaskModel:getInstance():getMaxJIfen(),
	font = FONTS_NAME.font_fzcy,
	size = 22,
	color = ccc3(64, 37, 7),
	align = ui.TEXT_ALIGN_LEFT
	})
	countDis:setAnchorPoint(cc.p(0, 1))
	countDis:setPosition(cc.p(posX + offset, titleViewSize.height - 30))
	self.titleView:addChild(countDis)
	local progress = display.newSprite(commonRes.progressNoneBng)
	local fill = display.newProgressTimer(commonRes.progressFullBng, display.PROGRESS_TIMER_BAR)
	fill:setMidpoint(CCPoint(0, 0.5))
	fill:setBarChangeRate(CCPoint(1, 0))
	fill:setPosition(progress:getContentSize().width * 0.5, progress:getContentSize().height * 0.5)
	progress:addChild(fill)
	progress:setPosition(leftAdgeOffset + iconSize.width + countDisLeftOffset, titleViewSize.height - 70)
	fill:setPercentage(self.taskModel:getJifen() / TaskModel:getInstance():getMaxJIfen() * 100)
	progress:setAnchorPoint(cc.p(0, 1))
	self.titleView:addChild(progress)
	local margin = 10
	local progressBngSize = progress:getContentSize()
	local beginLabel = ui.newTTFLabel({
	text = "0",
	size = 20,
	align = ui.TEXT_ALIGN_LEFT
	}):pos(margin, progressBngSize.height / 2):addTo(progress)
	beginLabel:setAnchorPoint(cc.p(0, 0.5))
	local endLabel = ui.newTTFLabel({
	text = TaskModel:getInstance():getMaxJIfen(),
	size = 20,
	align = ui.TEXT_ALIGN_LEFT
	}):pos(progressBngSize.width - margin, progressBngSize.height / 2):addTo(progress)
	endLabel:setAnchorPoint(cc.p(1, 0.5))
	beginLabel:setVisible(false)
end

return GiftGetPopup