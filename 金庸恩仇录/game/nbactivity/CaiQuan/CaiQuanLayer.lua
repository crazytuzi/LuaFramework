local data_item_item = require("data.data_card_card")
local data_card_card = require("data.data_item_item")
require("data.data_error_error")
local CHUI_ZI = 1
local JIAN_ZI = 2
local BU = 3

local CaiQuanLayer = class("CaiQuanLayer", function()
	return display.newNode()
end
)

function CaiQuanLayer:onFanPaiView()
	self._rootnode.main_node:setVisible(false)
	self._rootnode.jiujianxian:setVisible(false)
	self._rootnode.fanpai_node:setVisible(true)
	if self.firstShowFanPai == nil then
		self.firstShowFanPai = 1
		self._rootnode.fanpai_confirm:addHandleOfControlEvent(function()
			if self.isTimeOut == true then
				show_tip_label(common:getLanguageString("@ActivityOver"))
				return
			end
			self:onMainView()
		end,
		CCControlEventTouchUpInside)
		
		for k,v in pairs(self.caiQuanModel.choosePosList) do
			local itemIcon = self._rootnode["card_" .. tonumber(k) + 1]
			local cellData = self.caiQuanModel.itemList[v + 1]
			itemIcon:setTouchEnabled(false)
			ResMgr.refreshItemWithTagNumName({itemType = cellData.t, id = cellData.id, itemNum = cellData.n, itemBg = itemIcon})
		end
	end
	self:setChooseCnt(self.caiQuanModel.chooseCount)
end


function CaiQuanLayer:setChooseCnt(num)
	self.caiQuanModel.chooseCount = num
	self._rootnode.rest_ttf:setString(common:getLanguageString("@DrawCardTimeLeft") .. self.caiQuanModel.chooseCount)
	self._rootnode.fan_pai_rest:setString(common:getLanguageString("@DrawCardTimeLeft") .. self.caiQuanModel.chooseCount)
end

function CaiQuanLayer:timeSchedule(param)
	self.restTime = param.time / 1000
	local timeLabel = param.label
	local callBack = param.callBack
	timeLabel:setString(common:getLanguageString("@WineSwordGod") .. format_time_unit(self.restTime) .. common:getLanguageString("@AfterLeave"))
	local update = function(dt)
		if timeLabel == nil or timeLabel:getParent() == nil or self.restTime <= 0 then
			self.scheduler.unscheduleGlobal(self.timeData)
			if self.restTime <= 0 then
				timeLabel:setString(common:getLanguageString("@WineSwordGodLeave"))
				callBack()
			else
				self.restTime = self.restTime - 1
				local timeStr = common:getLanguageString("@WineSwordGod") .. format_time_unit(self.restTime) .. common:getLanguageString("@AfterLeave")
				timeLabel:setString(timeStr)
			end
		end
	end
	self.scheduler = require("framework.scheduler")
	if self.timeData ~= nil then
		self.scheduler.unscheduleGlobal(self.timeData)
	end
	self.timeData = self.scheduler.scheduleGlobal(update, 1, false)
end

function CaiQuanLayer:onMainView(data)
	self._rootnode.main_node:setVisible(true)
	self._rootnode.jiujianxian:setVisible(true)
	self._rootnode.fanpai_node:setVisible(false)
	if self.isFirstShow then
		self.isFirstShow = false
		for i = 1, #self.caiQuanModel.itemList do
			do
				local cellData = self.caiQuanModel.itemList[i]
				do
					dump(cellData)
					self._rootnode["item_icon_" .. i]:removeAllChildrenWithCleanup(true)
					ResMgr.refreshItemWithTagNumName({itemType = cellData.t, id = cellData.id, itemNum = cellData.n, itemBg = self._rootnode["item_icon_" .. i]})
					self._rootnode["item_icon_" .. i]:setTouchEnabled(true)
					self._rootnode["item_icon_" .. i]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
						local itemInfo = require("game.Huodong.ItemInformation").new({id = cellData.id, type = cellData.t})
						display.getRunningScene():addChild(itemInfo, 100000)
					end)
				end
			end
		end
		for i = 1, 3 do
			self._rootnode["hand_btn_" .. i]:addHandleOfControlEvent(function()
				if self.isTimeOut == true then
					show_tip_label(common:getLanguageString("@ActivityOver"))
					return
				end
				if self.caiQuanModel.guessCount > 0 then
					self.caiQuanModel.curState = i
					self:sendGuessRes()
				else
					show_tip_label(common:getLanguageString("@FingerGuessingTimeNotEnough"))
				end
			end,
			CCControlEventTouchUpInside)
		end
		
		self._rootnode.jingjiu_btn:addHandleOfControlEvent(function()
			if self.isTimeOut == true then
				show_tip_label(common:getLanguageString("@ActivityOver"))
				return
			end
			local choseCount = 0
			for k,v in pairs(self.caiQuanModel.choosePosList) do
				choseCount = choseCount + 1
			end
			if self.caiQuanModel.guessCount > 0 then
				show_tip_label(common:getLanguageString("@HintNoNeetToGiveWine"))
			else
				if game.player.m_gold < self.caiQuanModel.buyGold then
					show_tip_label(common:getLanguageString("@WineGoldNotEnough"))
				else
					if self.caiQuanModel.chooseCount + (choseCount) > 2 then
						show_tip_label(common:getLanguageString("@AllPropertyGotToday"))
					else
						local layer = require("utility.MsgBox").new({size = cc.size(500, 300), leftBtnName = common:getLanguageString("@DI"), rightBtnName = common:getLanguageString("@Confirm"), content = common:getLanguageString("@HintGiveChance"), rightBtnFunc = function()
							self:sendGuessBuy()
						end
						})
						display.getRunningScene():addChild(layer, 100)
					end
				end
			end
		end,
		CCControlEventTouchUpInside)
	end
	self:setChooseCnt(self.caiQuanModel.chooseCount)
	self:updateDown()
end

function CaiQuanLayer:sendGuessBuy()
	RequestHelper.buyGuessTime({
	callback = function(data)
		dump("bugguessTime")
		dump(data)
		self:setGuessCount(1)
		game.player.m_gold = data.gold
		self.caiQuanModel.buyGold = data.spend
		self:setBuyGold(self.caiQuanModel.buyGold)
	end
	})
end

function CaiQuanLayer:sendGuessRes()
	RequestHelper.guessing({
	callback = function(data)
		dump("sendguessRes")
		dump(data)
		self:onGuessShow(data.win)
		self:setGuessCount(data.guessCount)
		self:setChooseCnt(data.chooseCount)
	end
	})
end

function CaiQuanLayer:onGuessShow(win)
	if self.isTimeOut == true then
		show_tip_label(common:getLanguageString("@ActivityOver"))
		return
	end
	local left = self.caiQuanModel.curState
	local right = 0
	if win == 1 then
		right = left + 1
	else
		right = left - 1
	end
	if right > 3 then
		right = 1
	elseif right < 1 then
		right = 3
	end
	local getHand = function(num)
		if num == 1 then
			return "caiquan_shitou"
		elseif num == 2 then
			return "caiquan_jiandao"
		elseif num == 3 then
			return "caiquan_bu"
		end
	end
	self.maskLayer = require("utility.ShadeLayer").new()
	display.getRunningScene():addChild(self.maskLayer)
	local bgWidth = self._rootnode.cai_bg:getContentSize().width
	local bgHeight = self._rootnode.cai_bg:getContentSize().height
	local leftHandAnim = ResMgr.createArma({resType = ResMgr.UI_EFFECT, armaName = getHand(left), isRetain = false})
	leftHandAnim:setPosition(0, display.cy)
	display.getRunningScene():addChild(leftHandAnim, 100)
	local rightHandAnim = ResMgr.createArma({resType = ResMgr.UI_EFFECT, armaName = getHand(right), isRetain = false, frameFunc = function()
		local resultAnimName, resultFunc = nil, nil
		if win == 1 then
			resultAnimName = "caiquan_chenggong"
			resultFunc = function()
				show_tip_label(common:getLanguageString("@GetCardTime"))
			end
			local path = "sound/sfx/" .. "u_caiquanshengli" .. ".mp3"
			GameAudio.playSound(path, false)
		else
			resultAnimName = "caiquan_shibai"
			local path = "sound/sfx/" .. "u_caiquanshibai" .. ".mp3"
			GameAudio.playSound(path, false)
		end
		local resultAnim = ResMgr.createArma({resType = ResMgr.UI_EFFECT, armaName = resultAnimName, isRetain = false, finishFunc = resultFunc})
		resultAnim:setPosition(display.width / 2, display.height / 2)
		display.getRunningScene():addChild(resultAnim, 1000000)
	end,
	finishFunc = function()
		self.maskLayer:removeSelf()
		if win == 1 then
			self:onFanPaiView()
		else
			self:onMainView()
		end
	end
	})
	rightHandAnim:setPosition(display.width, display.cy)
	rightHandAnim:setScaleX(-1)
	display.getRunningScene():addChild(rightHandAnim, 100)
end

function CaiQuanLayer:setGuessCount(num)
	self.caiQuanModel.guessCount = num
	self._rootnode.rest_cai_num:setString(num)
end

function CaiQuanLayer:updateDown()
	self:setGuessCount(self.caiQuanModel.guessCount)
	self:setBuyGold(self.caiQuanModel.buyGold)
end

function CaiQuanLayer:showRace(data)
	self._rootnode.main_node:setVisible(false)
	self._rootnode.fanpai_node:setVisible(false)
	self._rootnode.jiujianxian:setVisible(true)
end

function CaiQuanLayer:initModel()
	self.caiQuanModel = {}
	self.caiQuanModel.guessCount = 0
	self.caiQuanModel.chooseCount = 0
	self.caiQuanModel.itemList = {}
	self.caiQuanModel.allGuessCount = 0
	self.caiQuanModel.choosePosList = {}
	self.caiQuanModel.buyCount = 0
	self.caiQuanModel.buyGold = 0
	self.caiQuanModel.curState = 0
end

function CaiQuanLayer:setBuyGold(num)
	self.caiQuanModel.buyGold = num
	self._rootnode.jingjiu_cost:setString(self.caiQuanModel.buyGold)
end

function CaiQuanLayer:sendInitRes()
	RequestHelper.getGuessInfo({callback = function(data)
		dump("ininini")
		dump(data)
		self:setGuessCount(data.guessCount)
		self:setChooseCnt(data.chooseCount)
		self:setBuyGold(data.buyGold)
		self.caiQuanModel.itemList = data.itemList
		self.caiQuanModel.allGuessCount = data.allGuessCount
		self.caiQuanModel.choosePosList = data.choosePosList
		self.caiQuanModel.buyCount = data.buyCount
		self.caiQuanModel.endTime = data.endTime
		self.endTimeLabel = ResMgr.createShadowMsgTTF({color = FONT_COLOR.GREEN})
		self._rootnode.fan_yan:addChild(self.endTimeLabel)
		self.endTimeLabel:setPosition(self._rootnode.fan_yan:getContentSize().width / 2, self._rootnode.fan_yan:getContentSize().height * 0.6)
		self:timeSchedule({time = self.caiQuanModel.endTime, label = self.endTimeLabel, callBack = function()
			self.isTimeOut = true
			dump("time out")
		end
		})
		self:onMainView()
	end
	})
end

function CaiQuanLayer:ctor(param)
	local viewSize = param.viewSize
	self:setNodeEventEnabled(true)
	self.isFirstShow = true
	self:initModel()
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local contentNode = CCBuilderReaderLoad("nbhuodong/caiquan_layer.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(contentNode)
	for i = 1, 3 do
		do
			local itemIcon = self._rootnode["card_" .. i]
			do
				local isCurPosTouch = true
				local cellData = nil
				dump("self.caiQuanModel.choosePosList")
				dump(self.caiQuanModel.choosePosList)
				for k,v in pairs(self.caiQuanModel.choosePosList) do
					if i == tonumber(k) + 1 then
						dump("isTouchchch")
						isCurPosTouch = false
						cellData = self.caiQuanModel.itemList[v + 1]
					end
				end
				if isCurPosTouch == true then
					itemIcon:setTouchEnabled(true)
					itemIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
						if event.name == "began" then
							if self.isTimeOut == true then
								show_tip_label(common:getLanguageString("@ActivityOver"))
								return
							end
							if self.caiQuanModel.chooseCount > 0 then
								ResMgr.createMaskLayer()
								RequestHelper.guessChoseCard({pos = i - 1, callback = function(data)
									self:setChooseCnt(data.chooseCnt)
									itemIcon:setTouchEnabled(false)
									ResMgr.removeMaskLayer()
									local itemData = data.item
									self.caiQuanModel.choosePosList[tostring(i - 1)] = data.index
									ResMgr.flipCard(itemIcon, function()
										ResMgr.refreshItemWithTagNumName({itemType = itemData.t, id = itemData.id, itemNum = itemData.n, itemBg = itemIcon})
									end)
								end
								})
							else
								show_tip_label(common:getLanguageString("@DrawCardTimeNotEnough"))
							end
							return true
						end
					end)
				else
					itemIcon:setTouchEnabled(false)
					ResMgr.refreshItemWithTagNumName({itemType = cellData.t, id = cellData.id, itemNum = cellData.n, itemBg = self._rootnode["card_" .. i]})
				end
			end
		end
	end
	self._rootnode.start_fan_pai_btn:addHandleOfControlEvent(function()
		if self.isTimeOut == true then
			show_tip_label(common:getLanguageString("@ActivityOver"))
			return
		end
		self:onFanPaiView()
	end,
	CCControlEventTouchUpInside)
	self:sendInitRes()
end

function CaiQuanLayer:onExit()
	if self.timeData ~= nil then
		self.scheduler.unscheduleGlobal(self.timeData)
	end
end

function CaiQuanLayer:updateRefreshMsg()
	if self._refreshNum > 0 then
		if self._refreshType == RefreshType.Free and self._vipFreeTimes <= self._refreshNum then
			self._rootnode.freeLimit:setVisible(true)
		else
			self._rootnode.freeLimit:setVisible(false)
		end
		if self._refreshType == RefreshType.Free then
			self._rootnode.refresh_free_lbl:setString(tostring(self._refreshNum))
			self._rootnode.free_node:setVisible(true)
			self._rootnode.shuaxinling_node:setVisible(false)
			self._rootnode.gold_node:setVisible(false)
		else
			if self._refreshType == RefreshType.Token then
				self._rootnode.refresh_shuaxinling_lbl:setString(tostring(self._refreshNum))
				self._rootnode.shuaxinling_node:setVisible(true)
				self._rootnode.gold_node:setVisible(false)
				self._rootnode.free_node:setVisible(false)
			else
				if self._refreshType == RefreshType.Gold then
					game.player:setGold(self._refreshNum)
					self._rootnode.refresh_gold_lbl:setString(tostring(self._goldRefreshTimes))
					self._rootnode.gold_node:setVisible(true)
					self._rootnode.shuaxinling_node:setVisible(false)
					self._rootnode.free_node:setVisible(false)
				end
			end
		end
	end
end

return CaiQuanLayer