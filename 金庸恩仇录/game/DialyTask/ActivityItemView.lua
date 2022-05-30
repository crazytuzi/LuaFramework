local btnGetRes = {
normal = "#btn_get_n.png",
pressed = "#btn_get_p.png",
disabled = "#btn_get_p.png"
}
local GiftGetOkPopup = import(".GiftGetOkPopup")

local ActivityItemView = class("ActivityItemView", function()
	return display.newLayer("ActivityItemView")
end)

function ActivityItemView:ctor(size, data, mainscene)
	self:setContentSize(size)
	self._leftToRightOffset = 10
	self._topToDownOffset = 2
	self._frameSize = size
	self._containner = nil
	self._padding = {
	left = 20,
	right = 20,
	top = 15,
	down = 20
	}
	self._data = data
	self:setUpView()
	self._mainMenuScene = mainscene
	self._parent = parent
	self._icon = nil
end

function ActivityItemView:setUpView()
	self._containner = display.newScale9Sprite("#reward_item_bg.png", 0, 0, cc.size(self._frameSize.width - self._leftToRightOffset * 2, self._frameSize.height - self._topToDownOffset * 2)):pos(self._frameSize.width / 2, self._frameSize.height / 2)
	local containnerSize = self._containner:getContentSize()
	self._containner:setAnchorPoint(cc.p(0.5, 0.5))
	self:addChild(self._containner)
	local titleBngHeight = 45
	local titleBng = display.newScale9Sprite("#heroinfo_cost_st_bg.png", 0, 0, cc.size(containnerSize.width - self._padding.left - self._padding.right, titleBngHeight)):pos(self._padding.left, containnerSize.height - self._padding.top):addTo(self._containner)
	titleBng:setAnchorPoint(cc.p(0, 1))
	local titleBngSize = titleBng:getContentSize()
	display.newSprite("#reward_item_title_bg.png"):pos(0, titleBngSize.height / 2):addTo(titleBng):setAnchorPoint(cc.p(0, 0.5))
	local marginLeft = 20
	local dislabel = ui.newTTFLabel({
	text = self._data.title,
	size = 20,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	}):pos(marginLeft, titleBngSize.height / 2):addTo(titleBng)
	dislabel:setAnchorPoint(cc.p(0, 0.5))
	local marginTop = 10
	local marginLeft = 30
	local y = titleBng:getPositionY() - titleBngSize.height - marginTop
	local startTimeStr = os.date("%Y-%m-%d,%H:%M:%S", math.ceil(tonumber(self._data.startTime) / 1000))
	local endTimeStr = os.date("%Y-%m-%d,%H:%M:%S", math.ceil(tonumber(self._data.endTime) / 1000))
	local activitylabel = ui.newTTFLabel({
	text = common:getLanguageString("@ActivityTime", startTimeStr, endTimeStr),
	size = 20,
	color = cc.c3b(6, 129, 18),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	}):pos(marginLeft, y):addTo(self._containner)
	activitylabel:setAnchorPoint(cc.p(0, 1))
	local marginTop = 10
	local marginLeft = 30
	local y = activitylabel:getPositionY() - activitylabel:getContentSize().height - marginTop
	local txt = string.gsub(self._data.dis, "\r\n", "\n")
	local label = CCLabelTTF:create(txt, FONTS_NAME.font_fzcy, 18, cc.size(self._containner:getContentSize().width - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	label:setPosition(cc.p(marginLeft, y))
	self._containner:addChild(label)
	label:setAnchorPoint(cc.p(0, 1))
	label:setColor(cc.c3b(99, 47, 8))
	for i = 1, #self._data do
		local marginTop = 10
		local marginLeft = 30
		local y = rolelabel:getPositionY() - activitylabel:getContentSize().height * i - marginTop * i
		local label = ui.newTTFLabel({
		text = common:getLanguageString("@ActivityTerm", i),
		size = 18,
		color = ccc3(6, 129, 18),
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		}):pos(marginLeft, y):addTo(self._containner)
		label:setAnchorPoint(cc.p(0, 1))
	end
	local marginTop = 20
	local offset = 10
	local marginRight = 120
	local height = 180
	local itemsViewBngs = display.newScale9Sprite("#heroinfo_title_bg.png", 0, 0, cc.size(containnerSize.width - self._padding.left - self._padding.right, height)):pos(self._padding.left, self._padding.down):addTo(self._containner)
	itemsViewBngs:setAnchorPoint(cc.p(0, 0))
	local rolelabel = ui.newTTFLabel({
	text = common:getLanguageString("@Rewards"),
	size = 18,
	color = ccc3(6, 129, 18),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	}):pos(offset, itemsViewBngs:getContentSize().height - offset):addTo(itemsViewBngs)
	rolelabel:setAnchorPoint(cc.p(0, 1))
	if #self._data.rewords == 0 then
		itemsViewBngs:setVisible(false)
	end
	local scrollView = CCScrollView:create()
	scrollView:setViewSize(cc.size(itemsViewBngs:getContentSize().width - self._padding.right - 110, itemsViewBngs:getContentSize().height))
	scrollView:setPosition(cc.p(0, 0))
	scrollView:setDirection(kCCScrollViewDirectionHorizontal)
	scrollView:setClippingToBounds(false)
	scrollView:setBounceable(true)
	itemsViewBngs:addChild(scrollView)
	scrollView:setAnchorPoint(cc.p(0, 0))
	self._giftData = self._data.rewords
	local innerWidth = 100 * table.maxn(self._giftData)
	local innerHeight = itemsViewBngs:getContentSize().height
	local innnerlayout = CCNode:create()
	innnerlayout:setContentSize(cc.size(innerWidth, innerHeight))
	scrollView:setContainer(innnerlayout)
	for i = 1, #self._giftData do
		self:createItem(i, innnerlayout, itemsViewBngs:getContentSize())
	end
	local getBtn
	getBtn = cc.ui.UIPushButton.new(btnGetRes):onButtonClicked(function()
		RequestHelper.dialyTask.getTaskGift({
		id = self._data.id,
		callback = function(data)
			dump(data)
			if data["0"] ~= "" then
				dump(data["0"])
			else
				display.newSprite("#getok.png"):pos(getBtn:getPosition()):addTo(self._containner):setAnchorPoint(cc.p(1, 0.5))
				getBtn:setVisible(false)
				TaskModel:getInstance():upDateTaskStateById(self._data.id, 3)
				for k, v in pairs(self._giftData) do
					if v.id == 1 then
						game.player:setGold(game.player.m_gold + v.num)
					elseif v.id == 2 then
						game.player:setSilver(game.player.m_silver + v.num)
					end
				end
				self._mainMenuScene:refreshPlayerBoard()
				local title = common:getLanguageString("@GetRewards")
				local msgBox = require("game.Huodong.RewardMsgBox").new({
				title = title,
				cellDatas = self._data.rewords
				})
				CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
			end
		end
		})
	end)
	:pos(containnerSize.width - self._padding.right - 20, itemsViewBngs:getContentSize().height / 2)
	getBtn:setAnchorPoint(cc.p(1, 0.5))
	local getTag = display.newSprite("#getok.png"):pos(getBtn:getPosition()):addTo(self._containner)
	getTag:setAnchorPoint(cc.p(1, 0.5))
	getBtn:setVisible(self._data.state == 2)
	getTag:setVisible(self._data.state == 3)
	self._containner:addChild(getBtn)
	local getBtnSize = getBtn:getContentSize()
end

function ActivityItemView:setData()
end

function ActivityItemView:createItem(index, itemsViewBngs, containnerSize)
	local i = index
	local marginTop = 10
	local marginLeft = 10
	local offset = 100
	self._icon = ResMgr.refreshIcon({
	id = self._giftData[i].id,
	resType = self._giftData[i].iconType,
	iconNum = self._giftData[i].num,
	isShowIconNum = true,
	numLblSize = 22,
	numLblColor = cc.c3b(0, 255, 0),
	numLblOutColor = cc.c3b(0, 0, 0),
	itemType = self._giftData[index].type
	})
	self._icon:setAnchorPoint(cc.p(0, 0.5))
	self._icon:setPosition(cc.p(self._padding.left + (index - 1) * offset, containnerSize.height / 2 + marginTop))
	local iconSize = self._icon:getContentSize()
	local iconPosX = self._icon:getPositionX()
	local iconPosY = self._icon:getPositionY()
	itemsViewBngs:addChild(self._icon)
	local nameColor = ResMgr.getItemNameColorByType(self._giftData[i].id, self._giftData[index].iconType)
	ui.newTTFLabelWithShadow({
	text = self._giftData[i].name,
	size = 20,
	color = nameColor,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER
	}):pos(iconSize.width / 2, -20):addTo(self._icon):setAnchorPoint(cc.p(0, 1))
	return self._icon
end

return ActivityItemView