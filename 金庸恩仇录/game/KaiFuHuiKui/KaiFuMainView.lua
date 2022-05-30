local MAX_ZORDER = 1111
local RADIO_TAG = 1111111
local DIS_PUPUTAG = 1000
local data_missiondefine_missiondefine = require("data.data_missiondefine_missiondefine")
local data_kaifurenwu_kaifurenwu = require("data.data_kaifurenwu_kaifurenwu")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
require("game.KaiFuHuiKui.KaiFuConst")
require("game.Biwu.BiwuFuc")
local RADIO_BUTTON_IMAGES, data_kuanghuan_kuanghuan
local KaiFuMainView = class("KaiFuMainView", function ()
	return require("utility.ShadeLayer").new()
end)
local DAYS_BACKGROUND = {
"kaifu_day%d.png",
"kaifu_day%d.png",
"chunjie_day%d.png"
}
function KaiFuMainView:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_kaifukuanghuanextra.plist", "ui/ui_kaifukuanghuanextra.png")
	self._type = param.type
	data_kuanghuan_kuanghuan = nil
	if self._type == KUANGHUAN_TYPE.KAIFU then
		data_kuanghuan_kuanghuan = require("data.data_kaifukuanghuan_kaifukuanghuan")
	elseif self._type == KUANGHUAN_TYPE.HEFU then
		data_kuanghuan_kuanghuan = require("data.data_hefukuanghuan_hefukuanghuan")
	elseif self._type == KUANGHUAN_TYPE.CHUNJIE then
		data_kuanghuan_kuanghuan = require("data.data_cjkuanghuan_cjkuanghuan")
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/kaifukuanghuan_main.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._bigIndex = 1
	self._smallIndex = 1
	if self._type == KUANGHUAN_TYPE.KAIFU then
		self._rootnode.huodong_title_2:setVisible(false)
		self._rootnode.huodong_bg_2:setVisible(false)
	else
		self._rootnode.huodong_title_2:setVisible(true)
		self._rootnode.huodong_bg_2:setVisible(true)
		self._rootnode.huodong_title_0:setVisible(false)
		self._rootnode.huodong_bg_0:setVisible(false)
		local jieriType
		if self._type == KUANGHUAN_TYPE.HEFU then
			jieriType = 1
		else
			jieriType = game.player:getAppOpenData().seven_day
		end
		if jieriType == 2 then
			display.addSpriteFramesWithFile("ui/ui_chunjie.plist", "ui/ui_chunjie.png")
			for i = 1, 7 do
				local str = string.format(DAYS_BACKGROUND[self._type + 1], i)
				self._rootnode["day" .. i]:setDisplayFrame(display.newSprite("#" .. str):getDisplayFrame())
			end
		end
		local titleSprite = display.newSprite("ui/ui_jieri7tian/" .. JieRi_head_name[jieriType] .. "_7day_title.png")
		self._rootnode.huodong_title_2:setDisplayFrame(titleSprite:getDisplayFrame())
		local bgSprite = display.newSprite("ui/ui_jieri7tian/jieri_7day_bg.png")
		self._rootnode.jieri_7day_bg:setDisplayFrame(bgSprite:getDisplayFrame())
		local titleSprite = display.newSprite("ui/ui_jieri7tian/" .. JieRi_head_name[jieriType] .. "_7day_sign.png")
		self._rootnode.jieri_7day_sign:setDisplayFrame(titleSprite:getDisplayFrame())
	end
	self:setUpView()
end
function KaiFuMainView:setUpView()
	self._rootnode.listbng:setZOrder(100)
	self._rootnode.closeBtn:addHandleOfControlEvent(function (eventName, sender)
		RequestHelper.getBaseInfo({
		callback = function (data)
			local basedata = data["1"]
			local param = {
			silver = basedata.silver,
			gold = basedata.gold,
			lv = basedata.level,
			zhanli = basedata.attack,
			vip = basedata.vip
			}
			param.exp = basedata.exp[1]
			param.maxExp = basedata.exp[2]
			param.naili = basedata.resisVal[1]
			param.maxNaili = basedata.resisVal[2]
			param.tili = basedata.physVal[1]
			param.maxTili = basedata.physVal[2]
			game.player:updateMainMenu(param)
			local checkAry = data["2"]
			game.player:updateNotification(checkAry)
		end
		})
		self:close()
	end,
	CCControlEventTouchUpInside)
	self._rootnode.disBtn:addHandleOfControlEvent(function (eventName, sender)
		sender:setTouchEnabled(false)
		self:performWithDelay(function ()
			sender:setTouchEnabled(true)
		end,
		1)
		local disLayer = require("game.KaiFuHuiKui.KaiFuPreView").new({
		type = self._type
		})
		self:addChild(disLayer)
	end,
	CCControlEventTouchUpInside)
	self:getData()
end
function KaiFuMainView:initRadioView(dayIndex)
	self._bigIndex = dayIndex
	if self._rootnode.listview:getChildByTag(RADIO_TAG) then
		self._rootnode.listview:removeChildByTag(RADIO_TAG)
	end
	local posX, posY = self._rootnode.listbng:getPosition()
	local contentSize = self._rootnode.listbng:getContentSize()
	RADIO_BUTTON_IMAGES = nil
	RADIO_BUTTON_IMAGES = {}
	for index = 1, 4 do
		self._rootnode["note_0" .. index]:setVisible(false)
		if data_kuanghuan_kuanghuan[dayIndex]["label" .. index] ~= nil then
			local tempData = {}
			tempData.off = "#" .. data_kuanghuan_kuanghuan[dayIndex]["label" .. index] .. "_n.png"
			tempData.off_pressed = "#" .. data_kuanghuan_kuanghuan[dayIndex]["label" .. index] .. "_n.png"
			tempData.off_disabled = "#" .. data_kuanghuan_kuanghuan[dayIndex]["label" .. index] .. "_n.png"
			tempData.on = "#" .. data_kuanghuan_kuanghuan[dayIndex]["label" .. index] .. "_p.png"
			tempData.on_pressed = "#" .. data_kuanghuan_kuanghuan[dayIndex]["label" .. index] .. "_p.png"
			tempData.on_disabled = "#" .. data_kuanghuan_kuanghuan[dayIndex]["label" .. index] .. "_p.png"
			RADIO_BUTTON_IMAGES[index] = tempData
		end
	end
	self.group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
	for key, var in pairs(RADIO_BUTTON_IMAGES) do
		self.group:addButton(cc.ui.UICheckBoxButton.new(var):align(display.LEFT_CENTER))
	end
	
	local selectedButton = self.group:onButtonSelectChanged(function (event)
		for i = 1, self.group:getButtonsCount() do
			self.group:getButtonAtIndex(i):setZOrder(self.group:getButtonsCount() - i)
		end
		self.group:getButtonAtIndex(event.selected):setZOrder(10)
		self:selectPage(event.selected)
	end)
	selectedButton:setButtonsLayoutMargin(5, 0, 0)
	self.group:setAnchorPoint(cc.p(0.5, 0))
	self.group:setPosition(contentSize.width * 0.025, posY + contentSize.height - 22)
	self.group:getButtonAtIndex(1):setButtonSelected(true)
	self._rootnode.listview:addChild(self.group, 100, RADIO_TAG)
	for key = 1, 4 do
		self._rootnode["note_0" .. key]:setZOrder(100)
	end
	self:refreshDotState(self._bigIndex)
end
function KaiFuMainView:initListView()
	self._rootnode.touchNode:setZOrder(100)
	self._rootnode.touchNode:setTouchEnabled(true)
	local posX = 0
	local posY = 0
	self._rootnode.touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
		posX = event.x
		posY = event.y
	end)
	local boardWidth = self._rootnode.listview:getContentSize().width
	local boardHeight = self._rootnode.listview:getContentSize().height
	local function confirmCallBack(missionId, type)
		self:updateMissState(missionId, type)
	end
	local function createFunc(index)
		local item = require("game.KaiFuHuiKui.KaiFuItemView").new()
		return item:create({
		index = index,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		itemData = self._data[index + 1],
		confirmFunc = confirmCallBack,
		type = self._type
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = self._data[index + 1],
		confirmFunc = confirmCallBack,
		type = self._type
		})
	end
	local cellContentSize = require("game.KaiFuHuiKui.KaiFuItemView").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size = CCSizeMake(boardWidth, boardHeight),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._data,
	cellSize = cellContentSize,
	direction = kCCScrollViewDirectionVertical,
	touchFunc = function (cell)
		for i = 1, cell:getIconNum() do
			local icon = cell:getIcon(i)
			if icon == nil then
				return
			end
			local pos = icon:convertToNodeSpace(ccp(posX, posY))
			if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
				self:clickFunc(cell:getIconData())
				break
			end
		end
	end
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode.listview:addChild(self.ListTable, 1, 111)
	self._rootnode.listview:setPositionY(self._rootnode.listview:getPositionY())
	self._rootnode.mash:setZOrder(20)
	self._rootnode.mash:setTouchEnabled(true)
	local tutoCell = self.ListTable:cellAtIndex(0)
	local tutoBtn = tutoCell:getRewardBtn()
	if tutoBtn ~= nil then
		TutoMgr.addBtn("qitianle_page_lingqu_btn", tutoBtn)
	end
	TutoMgr.active()
end
local doubleClickTag = true
function KaiFuMainView:clickFunc(itemData)
	if not doubleClickTag then
		return
	end
	doubleClickTag = false
	self:performWithDelay(function ()
		doubleClickTag = true
	end,
	1)
	local itemInfo
	if itemData.type ~= 6 then
		itemInfo = require("game.Huodong.ItemInformation").new({
		id = itemData.id,
		type = itemData.type,
		name = itemData.name,
		describe = data_item_item[itemData.id].describe
		})
	else
		itemInfo = require("game.Spirit.SpiritInfoLayer").new(4, {
		resId = tonumber(itemData.id)
		})
	end
	CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
end
function KaiFuMainView:initOtherView()
	local function confirmCallBack(missionId, type)
		self:updateMissState(missionId, type)
	end
	local function getLeftNum()
		dump(self._halfShopSurList)
		dump(self._bigIndex)
		return self._halfShopSurList[self._bigIndex]
	end
	local function updateNum(num)
		self._halfShopSurList[self._bigIndex] = num
	end
	local item = require("game.KaiFuHuiKui.KaiFuOtherView").new({
	itemData = self._data,
	confirm = confirmCallBack,
	getLeftNumFuc = getLeftNum,
	updateNumFuc = updateNum,
	type = self._type
	})
	self._rootnode.listview:addChild(item, 1, 111)
end
function KaiFuMainView:registToggleListener(dayIndex)
	self._toogles = {}
	local select_one = display.newSprite("#kaifu_selectone.png")
	local select_seven = display.newSprite("#kaifu_selectseven.png")
	local contentSize1 = self._rootnode.day1:getContentSize()
	local contentSize2 = self._rootnode.day7:getContentSize()
	local offset = 5
	select_one:setPosition(contentSize1.width / 2 - offset, contentSize1.height / 2 + offset)
	select_seven:setPosition(contentSize2.width / 2 - offset, contentSize2.height / 2 + offset)
	select_one:retain()
	select_seven:retain()
	for index = 1, 7 do
		do
			local toogle = self._rootnode["day" .. index]
			addTouchListener(toogle, function (sender, eventType)
				if eventType == EventType.ended then
					if index > self._dayIndex then
						show_tip_label(common:getLanguageString("@HintActivityPause"))
						return
					end
					for k, v in pairs(self._toogles) do
						v:removeAllChildren()
					end
					if index == 7 then
						toogle:addChild(select_seven)
					else
						toogle:addChild(select_one)
					end
					self:initRadioView(index)
				end
			end)
			table.insert(self._toogles, toogle)
		end
	end
	if dayIndex == 7 then
		self._rootnode["day" .. dayIndex]:addChild(select_seven)
	else
		self._rootnode["day" .. dayIndex]:addChild(select_one)
	end
	self._bigIndex = dayIndex
end
function KaiFuMainView:selectPage(index)
	self._smallIndex = self:changeIdByIndex(index)
	if self._rootnode.listview:getChildByTag(111) then
		self._rootnode.listview:removeChildByTag(111)
	end
	self._rootnode.listview:setZOrder(101)
	if data_kuanghuan_kuanghuan[self._bigIndex]["label" .. self._smallIndex] == "kf_banjiaqianggou" then
		self._data = self:getShopItemData(self._bigIndex, self._smallIndex)
		self:initOtherView()
	else
		self._data = self:getDataByIndex(self._bigIndex, self._smallIndex)
		dump(self._data)
		self:initListView()
	end
end
function KaiFuMainView:initCountDownTimer()
	local actCountDownLabel = self._rootnode.actcountdown
	local rewCountDownLabel = self._rootnode.rewcountdown
	self._countDownTimeAct = self._actCountDown / 1000
	self._countDownTimeRew = self._rewCountDown / 1000
	local textConst = common:getLanguageString("@ActivityOver")
	if not self._schedulerTimeAct then
		self._schedulerTimeAct = require("framework.scheduler")
		local function countDown()
			self._countDownTimeAct = self._countDownTimeAct - 1
			if self._countDownTimeAct <= 0 then
				self._schedulerTimeAct.unscheduleGlobal(self._scheduleTimeAct)
				actCountDownLabel:setString(textConst)
				show_tip_label(textConst)
				self:resetALLToNULL()
			else
				actCountDownLabel:setString(self:timeFormat(self._countDownTimeAct))
			end
		end
		self._scheduleTimeAct = self._schedulerTimeAct.scheduleGlobal(countDown, 1, false)
	end
	if not self._schedulerTimeRew then
		self._schedulerTimeRew = require("framework.scheduler")
		local function countDown()
			self._countDownTimeRew = self._countDownTimeRew - 1
			if self._countDownTimeRew <= 0 then
				self._schedulerTimeRew.unscheduleGlobal(self._scheduleTimeRew)
				rewCountDownLabel:setString(textConst)
				show_tip_label(textConst)
				if self._type == KUANGHUAN_TYPE.KAIFU then
					game.player.m_isKaiFuKuangHuan = false
				elseif self._type == KUANGHUAN_TYPE.HEFU then
					game.player.m_isHeFuKuangHuan = false
				elseif self._type == KUANGHUAN_TYPE.CHUNJIE then
					game.player.m_isCJQiTianLe = false
				end
				PostNotice(NoticeKey.MainMenuScene_kaifukuanghuan)
			else
				rewCountDownLabel:setString(self:timeFormat(self._countDownTimeRew))
			end
		end
		self._scheduleTimeRew = self._schedulerTimeRew.scheduleGlobal(countDown, 1, false)
	end
end
function KaiFuMainView:timeFormat(timeAll)
	local baseday = 86400
	local basehour = 3600
	local basemin = 60
	local day = math.floor(timeAll / baseday)
	local time = timeAll - day * baseday
	local hour = math.floor(time / basehour)
	local time = time - hour * basehour
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
	local nowTimeStr = day .. common:getLanguageString("@Day") .. hour .. ":" .. min .. ":" .. sec .. ""
	return nowTimeStr
end
function KaiFuMainView:resetALLToNULL()
	KAIFU_ISSHOW_CONST = true
	self:initRadioView(self._bigIndex)
end
function KaiFuMainView:checkIsReceived(missionID, types, bigindex)
	for k, v in pairs(self._missionReceived) do
		if v.missionDefineId == missionID then
			local status, missionDetail
			if types == 1 then
				local state_temp = self:checkDialyTask(bigindex)
				if state_temp then
					status = 3
				else
					status = 2
				end
			elseif types == 2 then
				local state_temp = self:checkDialyChoice(bigindex)
				if state_temp then
					status = 3
				else
					status = 2
				end
			elseif types == 4 then
				local state_temp = self:checkHasBuy(bigindex)
				if state_temp then
					status = 3
				else
					status = 2
				end
			else
				status = v.status
			end
			return status, v.missionDetail
		end
	end
	return nil, nil
end
function KaiFuMainView:close()
	display.removeSpriteFramesWithFile("ui/ui_kaifukuanghuanextra.plist", "ui/ui_kaifukuanghuanextra.png")
	if self._scheduleTimeAct then
		self._schedulerTimeAct.unscheduleGlobal(self._scheduleTimeAct)
	end
	if self._scheduleTimeRew then
		self._schedulerTimeRew.unscheduleGlobal(self._scheduleTimeRew)
	end
	self:removeFromParent()
end
function KaiFuMainView:getData(func)
	local function init(data)
		self._dayIndex = data.dayIndex
		if self._dayIndex > 7 then
			self._dayIndex = 7
			self._dayOver7 = true
		else
			self._dayOver7 = false
		end
		self._actCountDown = data.actTimeCountDown
		self._rewCountDown = data.acceptTimeCountDown
		self._missionReceived = data.missionList
		self._halfBuyStatus = data.halfBuyStatus
		self._halfShopItemNum = data.halfShopItemNum
		self._loginAcceptStatus = data.loginAcceptStatus
		self._loginChoicAcceptStatus = data.loginChoicAcceptStatus
		self._halfShopSurList = data.halfShopSurList
		self:registToggleListener(self._dayIndex)
		self:initRadioView(self._dayIndex)
		self:initCountDownTimer()
		self:refreshRadioState()
	end
	RequestHelper.kaifukuanghuan.getBaseInfo({
	type = self._type,
	callback = function (data)
		dump(data)
		if data["0"] ~= "" then
			dump(data["0"])
		else
			init(data.rtnObj)
		end
	end
	})
end
function KaiFuMainView:getDataByIndex(bigIndex, smallIndex)
	local baseData = data_kuanghuan_kuanghuan[bigIndex]["act_id" .. smallIndex]
	local ret = {}
	for k, v in pairs(baseData) do
		local temp = {}
		temp.id = data_kaifurenwu_kaifurenwu[v].id
		temp.type = data_kaifurenwu_kaifurenwu[v].type
		temp.achid = data_kaifurenwu_kaifurenwu[v].achieve_id
		temp.rewords = self:getRewords(temp.achid)
		temp.dis = data_missiondefine_missiondefine[temp.achid].description
		temp.dayIndex = self._bigIndex
		temp.description = data_kaifurenwu_kaifurenwu[v].arr_description
		temp.isshow = data_kaifurenwu_kaifurenwu[v].show
		temp.parent = self
		local state, step = self:checkIsReceived(temp.achid, temp.type, bigIndex)
		if temp.isshow == 1 then
			temp.curStep = step
			local Temp = string.split(data_missiondefine_missiondefine[temp.achid].prams, ",")
			local ret = Temp[#Temp]
			local bigan = #Temp == 1 and 2 or 1
			temp.totalStep = string.sub(ret, bigan, string.len(ret) - 1)
		end
		if state then
			temp.state = state
			table.insert(ret, temp)
		end
	end
	local readayData = {}
	local unreadayData = {}
	for k, v in pairs(ret) do
		if v.state == 2 then
			table.insert(readayData, v)
		else
			table.insert(unreadayData, v)
		end
	end
	for k, v in pairs(unreadayData) do
		table.insert(readayData, v)
	end
	return readayData
end
function KaiFuMainView:changeIdByIndex(index)
	local smallIndex = 1
	local i = 1
	for key, var in pairs(RADIO_BUTTON_IMAGES) do
		if i == index then
			smallIndex = key
			break
		end
		i = i + 1
	end
	return smallIndex
end
function KaiFuMainView:checkDotState(bigIndex, smallIndex)
	local baseData = data_kuanghuan_kuanghuan[bigIndex]["act_id" .. smallIndex]
	if baseData ~= nil then
		local ret = {}
		for k, v in pairs(baseData) do
			local temp = {}
			temp.achid = data_kaifurenwu_kaifurenwu[v].achieve_id
			local state
			if data_kaifurenwu_kaifurenwu[v].type == 4 then
				if self:checkHasBuy(bigIndex) then
					state = 1
				else
					state = 2
				end
			else
				state = self:checkIsReceived(temp.achid, data_kaifurenwu_kaifurenwu[v].type, bigIndex)
			end
			if state == 2 then
				return true
			end
		end
	end
	return false
end
function KaiFuMainView:refreshDotState(bigIndex)
	local index = 1
	for key, var in pairs(RADIO_BUTTON_IMAGES) do
		if self:checkDotState(bigIndex, key) then
			self._rootnode["note_0" .. index]:setVisible(true)
		else
			self._rootnode["note_0" .. index]:setVisible(false)
		end
		index = index + 1
	end
end
function KaiFuMainView:refreshRadioState()
	local dotTags = {}
	for index = 1, self._dayIndex do
		for key = 1, 4 do
			if self:checkDotState(index, key) then
				table.insert(dotTags, index)
				break
			end
		end
	end
	for index = 1, 7 do
		self._rootnode["red_0" .. index]:setVisible(false)
	end
	for k, v in pairs(dotTags) do
		self._rootnode["red_0" .. v]:setVisible(true)
	end
	if #dotTags == 0 then
		game.player.m_kuangHuanNum = 0
		PostNotice(NoticeKey.MainMenuScene_kaifukuanghuan)
	end
end
function KaiFuMainView:getShopItemData(bigIndex, smallIndex)
	local id = data_kuanghuan_kuanghuan[bigIndex]["act_id" .. smallIndex][1]
	local temp = {}
	temp.id = data_kaifurenwu_kaifurenwu[id].shop_id
	temp.type = data_kaifurenwu_kaifurenwu[id].type
	temp.iconType = ResMgr.getResType(data_kaifurenwu_kaifurenwu[id].shop_type)
	temp.num = data_kaifurenwu_kaifurenwu[id].shop_num
	temp.shop_type = data_kaifurenwu_kaifurenwu[id].shop_type
	if temp.shop_type ~= 8 or not data_card_card[temp.id].name then
	end
	temp.name = data_item_item[temp.id].name
	temp.shop_num = data_kaifurenwu_kaifurenwu[id].shop_num
	temp.limit_cnt = data_kaifurenwu_kaifurenwu[id].limit_cnt
	temp.shop_sale = data_kaifurenwu_kaifurenwu[id].shop_sale
	temp.shop_price = data_kaifurenwu_kaifurenwu[id].shop_price
	temp.achieve_id = data_kaifurenwu_kaifurenwu[id].achieve_id
	temp.hasBuy = self:checkHasBuy(self._bigIndex)
	temp.dayIndex = self._bigIndex
	temp.curIndex = self._dayIndex
	temp.numleft = self._halfShopItemNum
	dump(temp)
	return temp
end
function KaiFuMainView:checkHasBuy(key)
	for k, v in pairs(self._halfBuyStatus or {}) do
		if key == tonumber(k) then
			return true
		end
	end
	return false
end
function KaiFuMainView:checkDialyTask(key)
	for k, v in pairs(self._loginAcceptStatus or {}) do
		if key == tonumber(v) then
			return true
		end
	end
	return false
end
function KaiFuMainView:checkDialyChoice(key)
	for k, v in pairs(self._loginChoicAcceptStatus or {}) do
		if key == tonumber(v) then
			return true
		end
	end
	return false
end
function KaiFuMainView:insertDialyData(type, dayIndex)
	if type == 1 then
		table.insert(self._loginAcceptStatus, dayIndex)
	elseif type == 2 then
		table.insert(self._loginChoicAcceptStatus, dayIndex)
	elseif type == 4 then
		self._halfBuyStatus[tostring(dayIndex)] = 1
	end
	dump(self._loginAcceptStatus)
	dump(self._loginChoicAcceptStatus)
	dump(self._loginAcceptStatus)
end
function KaiFuMainView:updateMissState(missId, type)
	if type == 1 or type == 2 or type == 4 then
		self:insertDialyData(type, self._bigIndex)
	else
		for k, v in pairs(self._missionReceived) do
			if missId == v.missionDefineId then
				v.status = 3
			end
		end
	end
	self:refreshDotState(self._bigIndex)
	self:refreshRadioState()
end
function KaiFuMainView:getRewords(id)
	local result = {}
	local dataBase = data_missiondefine_missiondefine[id]
	if type(dataBase.rewardIds) == "table" then
		for k, v in pairs(dataBase.rewardIds) do
			local dataTemp = {}
			dataTemp.id = v
			dataTemp.iconType = ResMgr.getResType(dataBase.rewardTypes[k])
			dataTemp.type = dataBase.rewardTypes[k]
			dataTemp.num = dataBase.rewardNums[k]
			local baseData
			if dataTemp.type == 8 then
				baseData = data_card_card
			else
				baseData = data_item_item
			end
			dataTemp.name = baseData[dataTemp.id].name
			table.insert(result, dataTemp)
		end
	else
		local dataTemp = {}
		dataTemp.id = dataBase.rewardIds
		dataTemp.iconType = ResMgr.getResType(dataBase.rewardTypes)
		dataTemp.num = dataBase.rewardNums
		dataTemp.type = dataBase.rewardTypes
		local baseData
		if dataTemp.type == 8 then
			baseData = data_card_card
		else
			baseData = data_item_item
		end
		dataTemp.name = baseData[dataTemp.id].name
		table.insert(result, dataTemp)
	end
	return result
end

return KaiFuMainView