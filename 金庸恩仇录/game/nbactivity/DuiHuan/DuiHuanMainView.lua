require("game.Biwu.BiwuFuc")
local data_item_item = require("data.data_item_item")

local DuiHuanMainView = class("DuiHuanMainView", function()
	return display.newLayer("DuiHuanMainView")
end)

function DuiHuanMainView:setUpView(param)
	self:setContentSize(param.size)
	self:setUpExtraView(param)
	local listViewSize = self.mainFrameBng:getContentSize()
	local sizeGroup = {
	cc.size(listViewSize.width, 343.2),
	cc.size(listViewSize.width, 473.2),
	cc.size(listViewSize.width, 473.2)
	}
	local refreshCallFunc, exChangeCallFunc
	function refreshCallFunc(index, id)
		local function func(data)
			self._data[index + 1].exchExp = data.exchExp
			self._data[index + 1].refGold = data.refGold
			local countpre = self._data[index + 1].refFreeNum
			self._data[index + 1].refFreeNum = data.freeNum
			if self._data[index + 1].refFreeNum == 0 and countpre == 1 then
				show_tip_label(require("data.data_message_message")[24].text)
			end
			local param = {
			viewSize = sizeGroup[self._data[index + 1].type],
			data = self._data[index + 1],
			index = index,
			refreshFunc = refreshCallFunc,
			exChangeFunc = exChangeCallFunc
			}
			self._tableView:reloadCell(index, param)
		end
		self:refresh(func, id)
	end
	
	function exChangeCallFunc(index, id)
		local function func(data)
			self._data[index + 1].exchExp = data.exchExp
			self._data[index + 1].exchNum = data.exchNum
			local param = {
			viewSize = sizeGroup[self._data[index + 1].type],
			data = self._data[index + 1],
			index = index,
			refreshFunc = refreshCallFunc,
			exChangeFunc = exChangeCallFunc
			}
			self._tableView:reloadCell(index, param)
			local function func()
				self:getData(function()
					self._tableView:reArrangeCell(#self._data)
				end)
			end
			local data = {}
			for k, v in pairs(self._data[index + 1].exchExp.exchRst) do
				local temp = {}
				temp.id = v.id
				temp.num = v.num
				temp.type = v.type
				temp.iconType = ResMgr.getResType(v.type)
				temp.name = require("data.data_item_item")[v.id].name
				table.insert(data, temp)
			end
			local title = common:getLanguageString("@RewardList")
			local msgBox = require("game.Huodong.RewardMsgBox").new({
			title = title,
			cellDatas = data,
			confirmFunc = func
			})
			CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
		end
		self:exchange(func, id)
	end
	
	local function createFunc(index)
		local item = require("game.nbactivity.DuiHuan.DuiHuanItemView").new()
		return item:create({
		viewSize = sizeGroup[self._data[index + 1].type],
		data = self._data[index + 1],
		index = index,
		refreshFunc = refreshCallFunc,
		exChangeFunc = exChangeCallFunc
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		viewSize = sizeGroup[self._data[index + 1].type],
		data = self._data[index + 1],
		index = index,
		refreshFunc = refreshCallFunc,
		exChangeFunc = exChangeCallFunc
		})
	end
	local function cellSizeFunc(view, idx)
		dump(idx)
		return sizeGroup[self._data[idx + 1].type]
	end
	local boardWidth = listViewSize.width
	local boardHeight = listViewSize.height
	self._tableView = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight - 20),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._data,
	cellSize = sizeGroup[1],
	cellSizeFunc = cellSizeFunc,
	touchFunc = function(cell, x, y)
		for i = 1, #cell:getData() do
			local icon = cell:getIcon(i)
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			local itemdata = cell:getItemData(i)
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
				local endFunc = function()
					--CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111)
					--dump("click------")
				end
				if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
					if itemdata.type ~= 6 then
						do
							local iconItem = ResMgr.getRefreshIconItem(itemdata.id, itemdata.type)
							local itemInfo = require("game.Huodong.ItemInformation").new({
							id = iconItem.id,
							type = iconItem.type,
							name = iconItem.name,
							describe = iconItem.describe,
							endFunc = endFunc
							})
							CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 1000, 1111)
						end
						break
					end
					local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
					resId = itemdata.id
					}, nil, endFunc)
					CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 1000, 1111)
				end
				break
			end
		end
	end
	})
	self._tableView:setPosition(0, 10)
	self._tableView:setAnchorPoint(cc.p(0, 0))
	self.mainFrameBng:addChild(self._tableView)
end

function DuiHuanMainView:setUpExtraView(param)
	local titleBng = display.newSprite("#titlebng.png")
	titleBng:setTouchEnabled(true)
	titleBng:setAnchorPoint(cc.p(0.5, 1))
	titleBng:setPosition(cc.p(param.size.width * 0.5, param.size.height * 1))
	self:addChild(titleBng, 10)
	local titleBngSize = titleBng:getContentSize()
	local piaodaiBng = display.newSprite("#piaodai.png")
	piaodaiBng:setAnchorPoint(cc.p(0.5, 1))
	piaodaiBng:setPosition(cc.p(titleBngSize.width * 0.6, titleBngSize.height * 0.9))
	titleBng:addChild(piaodaiBng)
	local piaodaiBngSize = piaodaiBng:getContentSize()
	local titleLabel = display.newSprite("#duihuanxianshi.png")
	titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
	titleLabel:setPosition(cc.p(piaodaiBngSize.width * 0.5, piaodaiBngSize.height * 0.7))
	piaodaiBng:addChild(titleLabel)
	dump(self._data)
	local startTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._start) / 1000))
	local endTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._end) / 1000))
	local startTimeStr = string.split(startTimeStr, "-")
	local startTime
	startTime = startTimeStr[1] .. common:getLanguageString("@Year")
	startTime = startTime .. startTimeStr[2] .. common:getLanguageString("@Month")
	startTime = startTime .. startTimeStr[3] .. common:getLanguageString("@Day")
	local endTimeStr = string.split(endTimeStr, "-")
	local endTime
	endTime = endTimeStr[1] .. common:getLanguageString("@Year")
	endTime = endTime .. endTimeStr[2] .. common:getLanguageString("@Month")
	endTime = endTime .. endTimeStr[3] .. common:getLanguageString("@Day")
	local disLabelValue1 = ui.newTTFLabelWithOutline({
	text = startTime .. common:getLanguageString("@DateTo") .. endTime,
	size = 23,
	color = cc.c3b(0, 254, 60),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	
	disLabelValue1:align(display.CENTER, titleBngSize.width/2, titleBngSize.height/2)
	disLabelValue1:addTo(titleBng)
	
	
	--活动剩余时间
	local disLabel2 = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@ActivityTimeLeft"),
	size = 23,
	color = FONT_COLOR.WHITE,
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTE,
	font = FONTS_NAME.font_fzcy
	})
	disLabel2:align(display.LEFT_CENTER, titleBngSize.width * 0.07, titleBngSize.height * 0.35)
	disLabel2:addTo(titleBng)
	local timeAll = math.floor((self._end - self._now) / 1000)
	local disLabelValue2 = ui.newTTFLabelWithOutline({
	text = self:timeFormat(timeAll),
	size = 23,
	color = cc.c3b(0, 254, 60),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	
	disLabelValue2:align(display.LEFT_CENTER, titleBngSize.width * 0.34, titleBngSize.height * 0.35)
	disLabelValue2:addTo(titleBng)
	alignNodesOneByOne(disLabel2, disLabelValue2, 4)
	local function countDown()
		timeAll = timeAll - 1
		if timeAll <= 0 then
			self._scheduler.unscheduleGlobal(self._schedule)
			disLabelValue2:setString(common:getLanguageString("@ActivityOver"))
			disLabelValue2:setPositionX(disLabelValue2:getPositionX() + 20)
			show_tip_label(common:getLanguageString("@ActivityOver"))
		else
			disLabelValue2:setString(self:timeFormat(timeAll))
		end
	end
	self._scheduler = require("framework.scheduler")
	self._schedule = self._scheduler.scheduleGlobal(countDown, 1, false)
	
	--兑换预览
	local yulanBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#duihuanyulan.png",
	handle = function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if not CCDirector:sharedDirector():getRunningScene():getChildByTag(10000000) then
			CCDirector:sharedDirector():getRunningScene():addChild(require("game.nbactivity.DuiHuan.DuiHuanGiftPopup").new(), 1222222, 10000000)
		end
	end
	})
	yulanBtn:align(display.CENTER, titleBngSize.width * 0.92, titleBngSize.height * 0.75)
	yulanBtn:addTo(titleBng)
	
	self.mainFrameBng = display.newScale9Sprite("#month_item_bg_bg.png", 0, 0, cc.size(param.size.width, param.size.height - titleBng:getContentSize().height + 30))
	self.mainFrameBng:align(display.CENTER_BOTTOM, param.size.width * 0.5, 10)
	self.mainFrameBng:addTo(self)
	
end

function DuiHuanMainView:clear()
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
	require("game.Spirit.SpiritCtrl").clear()
	self:release()
end

function DuiHuanMainView:timeFormat(timeAll)
	local basehour = 3600
	local basemin = 60
	local hour = math.floor(timeAll / basehour)
	local time = timeAll - hour * basehour
	local min = math.floor(time / basemin)
	local time = time - basemin * min
	local sec = math.floor(time)
	if hour < 10 then
		hour = "0" .. hour or hour
	end
	if min < 10 then
		min = "0" .. min or min
	end
	if sec < 10 then
		sec = "0" .. sec or sec
	end
	local nowTimeStr = hour .. common:getLanguageString("@Hour") .. min .. common:getLanguageString("@Minute") .. sec .. common:getLanguageString("@Sec")
	return nowTimeStr
end

function DuiHuanMainView:ctor(param)
	self:load()
	local bng = display.newScale9Sprite("#month_bg.png", 0, 0, param.size)
	bng:setAnchorPoint(cc.p(0, 0))
	self:addChild(bng)
	local function func()
		self:setUpView(param)
	end
	self:getData(func)
end

function DuiHuanMainView:getData(func)
	local function init(data)
		self._data = data.list
		self._start = data.start
		self._end = data["end"]
		self._now = data.now
		func()
	end
	RequestHelper.exchangeSystem.getExchangeList({
	callback = function(data)
		dump(data)
		init(data)
	end
	})
end

function DuiHuanMainView:refresh(func, id)
	local function init(data)
		func(data)
	end
	RequestHelper.exchangeSystem.refresh({
	callback = function(data)
		dump(data)
		init(data)
	end,
	id = id
	})
end

function DuiHuanMainView:exchange(func, id)
	local function init(data)
		if data.checkBag and #data.checkBag > 0 then
			local layer = require("utility.LackBagSpaceLayer").new({
			bagObj = data.checkBag
			})
			self:addChild(layer, 10)
		else
			func(data)
		end
	end
	RequestHelper.exchangeSystem.exchange({
	callback = function(data)
		dump(data)
		init(data)
		
	end,
	id = id
	})
end

function DuiHuanMainView:load()
	display.addSpriteFramesWithFile("ui/ui_nbactivity_duihuan.plist", "ui/ui_nbactivity_duihuan.png")
	display.addSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
	display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.addSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
end

function DuiHuanMainView:release()
	display.removeSpriteFramesWithFile("ui/ui_nbactivity_duihuan.plist", "ui/ui_nbactivity_duihuan.png")
	display.removeSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
	display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.removeSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.removeSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
	display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
end

return DuiHuanMainView