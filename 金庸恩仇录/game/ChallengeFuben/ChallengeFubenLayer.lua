local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")

local ChallengeFubenLayer = class("ChallengeFubenLayer", function()
	return require("utility.ShadeLayer").new()
end)

function ChallengeFubenLayer:ctor(param)
	dump(param.rtnObj)
	local refreshCellFunc = param.refreshCellFunc
	self._parentCell = param.parentCell
	self._fbId = param.fbId
	self._isAllowPlay = self._parentCell:getIsAllowPlay()
	rtnObj = param.rtnObj
	local attrack = rtnObj.attrack
	self._level = rtnObj.level
	self._cards = self:sortCards(rtnObj.cards)
	dump(self._cards)
	for _, card in pairs(self._cards) do
		card.life = nil
	end
	self._formHero = {}
	local fbInfo = self:getFbInfo(self._fbId)
	local height = display.height
	if height > 960 then
		height = 960
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/challenge/challengeFuben_layer.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, height))
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	self._rootnode.titleLabel:setString(common:getLanguageString("@DareElite"))
	self._rootnode.rest_num:setString(tostring(HuoDongFuBenModel.getRestNum(self._fbId)))
	self:setFormation(self._cards, attrack)
	--关闭
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	local buyBtn = self._rootnode.buy_btn
	dump(fbInfo.isbuy)
	if self._isAllowPlay == false then
		buyBtn:setVisible(false)
	elseif self._isAllowPlay == true then
		if fbInfo.isbuy == 1 then
			--购买次数
			buyBtn:setVisible(true)
			buyBtn:addHandleOfControlEvent(function(sender, eventName)
				if HuoDongFuBenModel.getRestNum(self._fbId) > 0 then
					ResMgr.showMsg(6)
				else
					buyBtn:setEnabled(false)
					GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
					local buyMsgBox = require("game.Challenge.HuoDongBuyMsgBox").new({
					aid = self._fbId,
					closeFunc = function()
						buyBtn:setEnabled(true)
					end,
					removeListener = function()
						self._rootnode.rest_num:setString(tostring(HuoDongFuBenModel.getRestNum(self._fbId)))
						if refreshCellFunc ~= nil then
							refreshCellFunc()
						end
						buyBtn:setEnabled(true)
					end
					})
					game.runningScene:addChild(buyMsgBox, self:getZOrder() + 1)
				end
			end,
			CCControlEventTouchUpInside)
			
		elseif fbInfo.isbuy == 0 then
			buyBtn:setVisible(false)
		end
	end
	
	--副本奖励
	local checkBtn = self._rootnode.check_reward_btn
	checkBtn:addHandleOfControlEvent(function(sender, eventName)
		checkBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local layer = require("game.ChallengeFuben.ChallengeFubenRewardLayer").new({
		rewardList = self._rewardList,
		closeFunc = function()
			checkBtn:setEnabled(true)
		end
		})
		game.runningScene:addChild(layer, self:getZOrder() + 1)
	end,
	CCControlEventTouchUpInside)
	
	local function getHeros()
		local formHero = {}
		for i, v in ipairs(self._cards) do
			v.id = v.id or v.cardId
		end
		for i, v in ipairs(self._formHero) do
			table.insert(formHero, {
			index = v.index,
			pos = v.pos
			})
		end
		return self._cards, formHero
	end
	
	--布阵
	local buzhenBtn = self._rootnode.buzhen_btn
	buzhenBtn:addHandleOfControlEvent(function(sender, eventName)
		buzhenBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local cards, formHero = getHeros()
		local needLeadRole
		if fbInfo.lead_role == 0 then
			needLeadRole = false
		elseif fbInfo.lead_role == 1 then
			needLeadRole = true
		end
		push_scene(require("game.scenes.formSettingBaseScene").new({
		fbId = self._fbId,
		sysId = fbInfo.sys_id,
		needLeadRole = needLeadRole,
		heros = cards,
		formHero = formHero,
		formSettingType = FormSettingType.HuoDongFuBenType,
		showFunc = function()
			buzhenBtn:setEnabled(true)
		end,
		changeFormaitonFunc = function(cards, power, fmt)
			self._cards = cards
			self._fmt = fmt
			self:setFormation(self._cards, power)
		end
		}))
	end,
	CCControlEventTouchUpInside)
	
	local sizeH = node:getContentSize().height - self._rootnode.top_node:getContentSize().height - self._rootnode.bottom_node:getPositionY()
	local sizeW = self._rootnode.tag_zhenrong:getContentSize().width
	local bottomBg = display.newScale9Sprite("#levelinfo_boss_bg2.png", 0, 0, CCSizeMake(sizeW, sizeH))
	bottomBg:setAnchorPoint(0.5, 0)
	bottomBg:setPosition(node:getContentSize().width / 2, 0)
	self._rootnode.bottom_node:addChild(bottomBg)
	self._listViewSize = cc.size(sizeW, sizeH - self._rootnode.listTile_icon:getContentSize().height / 2 - 5)
	self._listViewNode = display.newNode()
	self._listViewNode:setContentSize(self._listViewSize)
	self._listViewNode:setAnchorPoint(0.5, 0)
	self._listViewNode:setPosition(node:getContentSize().width / 2, 3)
	self._rootnode.bottom_node:addChild(self._listViewNode)
	self._rootnode.title_lbl:setString(common:getLanguageString("@Dare", fbInfo.title))
	self._rootnode.describe_lbl:setString(fbInfo.description)
	local fbDataList = {}
	self._rewardList = {}
	for i = 1, fbInfo.diff_cnt do
		local fbData = {}
		fbData.diffBg = fbInfo.arr_diff_bg[i]
		fbData.needLv = fbInfo.arr_prebattle[i]
		fbData.fight = fbInfo.arr_fight[i]
		fbData.hardMsg = fbInfo.arr_diff_name[i]
		if self._level >= fbData.needLv then
			fbData.isOpen = true
		else
			fbData.isOpen = false
		end
		table.insert(fbDataList, fbData)
		local rewardItem = {}
		rewardItem.arr_id = fbInfo.dropid[i]
		rewardItem.arr_type = fbInfo.droptype[i]
		rewardItem.iconName = fbInfo.arr_diff[i]
		table.insert(self._rewardList, rewardItem)
	end
	self:createFbListView(fbDataList)
end

function ChallengeFubenLayer:setLeftTimes(times)
	HuoDongFuBenModel.setRestNum(self._fbId, times)
	self._rootnode.rest_num:setString(tostring(times))
	self._parentCell:setLeftCnt(times)
	game.player:setHuodongNum(game.player:getHuodongNum() - 1)
end

function ChallengeFubenLayer:sortCards(cards)
	local data_card_card = require("data.data_card_card")
	local getIsHasAdd = function(index, indexList)
		local bHas = false
		for i, v in ipairs(indexList) do
			if v == index then
				bHas = true
				break
			end
		end
		return bHas
	end
	local zizhiList = {}
	local clsList = {}
	local qianghuaList = {}
	local sameIdList = {}
	local function getItemByZizhi(indexList)
		local max = -1
		zizhiList = {}
		for i, v in ipairs(cards) do
			local zizhi = data_card_card[v.resId].arr_zizhi[v.cls + 1]
			if getIsHasAdd(i, indexList) == false and max < zizhi then
				max = zizhi
			end
		end
		for i, v in ipairs(cards) do
			local zizhi = data_card_card[v.resId].arr_zizhi[v.cls + 1]
			if getIsHasAdd(i, indexList) == false and zizhi == max then
				table.insert(zizhiList, i)
			end
		end
	end
	local function getItemByCls(indexList)
		local max = -1
		clsList = {}
		for i, v in ipairs(zizhiList) do
			if getIsHasAdd(v, indexList) == false and max < cards[v].cls then
				max = cards[v].cls
			end
		end
		for i, v in ipairs(zizhiList) do
			if getIsHasAdd(v, indexList) == false and cards[v].cls == max then
				table.insert(clsList, v)
			end
		end
	end
	
	local function getItemByQianghua(indexList)
		local max = -1
		qianghuaList = {}
		for i, v in ipairs(clsList) do
			if getIsHasAdd(v, indexList) == false and max < cards[v].level then
				max = cards[v].level
			end
		end
		for i, v in ipairs(clsList) do
			if getIsHasAdd(v, indexList) == false and cards[v].level == max then
				table.insert(qianghuaList, v)
			end
		end
	end
	local cardData = {}
	local indexList = {}
	local function addToList(index)
		if index ~= -1 and getIsHasAdd(index, indexList) == false then
			local itemData = cards[index]
			table.insert(indexList, index)
			table.insert(cardData, itemData)
		end
	end
	for i, v in ipairs(cards) do
		if v.resId == 1 or v.resId == 2 then
			addToList(i)
			break
		end
	end
	for _, _ in ipairs(cards) do
		getItemByZizhi(indexList)
		for _, _ in ipairs(zizhiList) do
			getItemByCls(indexList)
			for _, _ in ipairs(clsList) do
				getItemByQianghua(indexList)
				for _, v in ipairs(qianghuaList) do
					local id = cards[v].resId
					for _, value in ipairs(qianghuaList) do
						if id == cards[value].resId then
							addToList(value)
						end
					end
				end
			end
		end
	end
	dump(cards)
	dump(cardData)
	return cardData
end

function ChallengeFubenLayer:getfmtstr()
	if #self._formHero <= 0 then
		self._formHero = {}
		for i = 1, 6 do
			for j, v in ipairs(self._cards) do
				if v.pos == i then
					table.insert(self._formHero, {
					index = j,
					pos = v.pos
					})
					break
				end
			end
		end
	end
	local str = "["
	for k, v in ipairs(self._formHero) do
		local hero = self._cards[v.index]
		if hero ~= nil then
			str = str .. string.format("[%s,%d],", hero.cardId, v.pos)
		end
	end
	str = str .. "]"
	return str
end

function ChallengeFubenLayer:setFormation(cards, power)
	self._zhanli = power
	self._rootnode.zhanli_lbl:setString(tostring(power))
	self._formHero = {}
	local indexList = {}
	for i, v in ipairs(cards) do
		if v.pos > 0 then
			table.insert(indexList, i)
			dump(v.pos .. ", " .. v.order)
		end
	end
	for i = 1, 6 do
		for _, v in ipairs(indexList) do
			if cards[v].order == i then
				table.insert(self._formHero, {
				index = v,
				pos = cards[v].pos
				})
				break
			end
		end
	end
	for i = 1, #self._formHero do
		local v = cards[self._formHero[i].index]
		local icon = self._rootnode["zhenrong_icon_" .. i]
		icon:setVisible(true)
		ResMgr.refreshIcon({
		id = v.resId,
		cls = v.cls,
		resType = ResMgr.HERO,
		itemBg = icon,
		iconNum = 1,
		isShowIconNum = false
		})
	end
	if #self._formHero < 6 then
		for i = #self._formHero + 1, 6 do
			self._rootnode["zhenrong_icon_" .. i]:setVisible(false)
		end
	end
end

function ChallengeFubenLayer:getFbInfo(fbId)
	local fbInfo = data_huodongfuben_huodongfuben[fbId]
	ResMgr.showAlert(fbInfo, "data_huodongfuben_huodongfuben表里没有此id: " .. fbId)
	return fbInfo
end

function ChallengeFubenLayer:createFbListView(fbDataList)
	local itemFileName = "game.ChallengeFuben.ChallengeFubenCell"
	local function toBat(cell, fmt)
		local fbInfo = self:getFbInfo(self._fbId)
		local scene = require("game.Challenge.HuoDongBattleScene").new({
		fubenid = self._fbId,
		sysId = fbInfo.sys_id,
		npcLv = cell:getIdx() + 1,
		fmt = fmt,
		zhanli = self._zhanli,
		errback = function()
			cell:setBtnEnabled(true)
		end,
		endFunc = function(bIsWin)
			pop_scene()
			cell:setBtnEnabled(true)
			if bIsWin == true then
				local times = HuoDongFuBenModel.getRestNum(self._fbId) - 1
				self:setLeftTimes(times)
			end
		end
		})
		push_scene(scene)
	end
	local function extendBag(data)
		if self._bagObj[1].curCnt < data["1"] then
			table.remove(self._bagObj, 1)
		else
			self._bagObj[1].cost = data["4"]
			self._bagObj[1].size = data["5"]
		end
		if #self._bagObj > 0 then
			game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = self._bagObj,
			callback = function(data)
				extendBag(data)
			end
			}), self:getZOrder() + 1)
		end
	end
	local function checkBag(cell)
		RequestHelper.challengeFuben.check({
		aid = self._fbId,
		errback = function()
			cell:setBtnEnabled(true)
		end,
		callback = function(data)
			dump(data)
			self._bagObj = data
			if #self._bagObj > 0 then
				game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
				bagObj = self._bagObj,
				callback = function(data)
					extendBag(data)
				end
				}), self:getZOrder() + 1)
				cell:setBtnEnabled(true)
			elseif 0 >= #self._formHero then
				ResMgr.showErr(800016)
				cell:setBtnEnabled(true)
			else
				if self._fmt == nil then
					self._fmt = self:getfmtstr()
				end
				--[[
				if #self._formHero < 6 then
					local tipLayer = require("game.huashan.HuaShanHeroLessTip").new({
					listener = function()
						toBat(cell, self._fmt)
					end,
					closeFunc = function()
						cell:setBtnEnabled(true)
					end
					})
					game.runningScene:addChild(tipLayer, self:getZOrder() + 1)
				else
					toBat(cell, self._fmt)
				end
				]]
				toBat(cell, self._fmt)
			end
		end
		})
	end
	local function createFunc(index)
		local item = require(itemFileName).new()
		return item:create({
		bIsAllowPlay = self._isAllowPlay,
		viewSize = self._listViewSize,
		itemData = fbDataList[index + 1],
		challengFunc = function(cell)
			if HuoDongFuBenModel.getRestNum(self._fbId) <= 0 then
				ResMgr.showErr(800004)
				cell:setBtnEnabled(true)
			else
				checkBag(cell)
			end
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(fbDataList[index + 1])
	end
	local cellContentSize = require(itemFileName).new():getContentSize()
	local listTable = require("utility.TableViewExt").new({
	size = self._listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #fbDataList,
	cellSize = cellContentSize
	})
	listTable:setPosition(0, 0)
	self._listViewNode:addChild(listTable)
	local openIdx = 0
	for i, v in ipairs(fbDataList) do
		if v.isOpen == true then
			openIdx = openIdx + 1
		end
	end
	dump(listTable:getContentOffset().y)
	local pageCount = listTable:getViewSize().height / cellContentSize.height
	if openIdx > pageCount then
		local dis = openIdx - pageCount
		local maxMove = #fbDataList - pageCount
		if dis > maxMove then
			dis = maxMove
		end
		listTable:setContentOffset(cc.p(0, listTable:getContentOffset().y + dis * cellContentSize.height))
	end
end

function ChallengeFubenLayer:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return ChallengeFubenLayer