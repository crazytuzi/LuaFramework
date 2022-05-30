local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001
local JIEFUJIPIN_ID = 1
local data_jiefujipin_jiefujipin = require("data.data_jiefujipin_jiefujipin")

local HuoDongBattleScene = class("HuoDongBattleScene", function(msg)
	return display.newScene("HuoDongBattleScene")
end)

function HuoDongBattleScene:sendReq(curWave)
	local function backFunc(data)
		dump("huodong fuben data")
		dump(data)
		self.totalData = data
		self._zhanli = data["8"]
		self.battleLayer:battleCallBack(data)
	end
	if self.fubenid == JIEFUJIPIN_ID then
		RequestHelper.HuoDongBattle({
		callback = function(data)
			backFunc(data)
		end,
		aid = self.fubenid,
		npc = curWave
		})
	elseif self._viewType == CHALLENGE_TYPE.ZHENSHEN_VIEW then
		RequestHelper.challengeFuben.rbPveBattle({
		id = self.fubenid,
		fmt = self._fmt,
		npc = curWave,
		errback = function()
			dump("errback")
			if self._errback ~= nil then
				self._errback()
			end
		end,
		callback = function(data)
			dump(data)
			if data["0"] ~= "" then
				if self._errback ~= nil then
					self._errback()
				end
			else
				backFunc(data)
			end
		end
		})
	else
		RequestHelper.challengeFuben.actPve({
		aid = self.fubenid,
		sysId = self._sysId,
		npc = curWave,
		npcLv = self._npcLv,
		fmt = self._fmt,
		errback = function()
			dump("errback")
			if self._errback ~= nil then
				self._errback()
			end
		end,
		callback = function(data)
			dump(data)
			if data["0"] ~= "" then
				if self._errback ~= nil then
					self._errback()
				end
			else
				backFunc(data)
			end
		end
		})
	end
end

function HuoDongBattleScene:result(data)
	self.battleData = data["2"][1]
	local atkData = self.battleData.d[#self.battleData.d]
	local win = atkData.win
	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]
	local bIsWin = false
	if win == 1 then
		bIsWin = true
	end
	local resultLayer = require("game.Battle.BattleResult").new({
	zhanli = self._zhanli,
	npcLv = self._npcLv,
	win = win,
	rewardItem = self.rewardItem,
	rewardCoin = self.rewardCoin,
	viewType = self._viewType,
	jumpFunc = function()
		if self._endFunc ~= nil then
			self._endFunc(bIsWin)
		else
			GameStateManager:ChangeState(GAME_STATE.STATE_TIAOZHAN, self._viewType)
		end
	end
	})
	self:addChild(resultLayer, RESULT_ZORDER)
end

function HuoDongBattleScene:jieFuResult(data)
	dump("dummmmmmm")
	dump(data)
	self.totoNumValue = data["6"]
	self.moneyValue = data["4"][1].n
	local resultLayer = require("game.Huodong.jieFuJiPinResult").new({
	totalDamage = self.totoNumValue,
	totalMoney = self.moneyValue,
	jumpFunc = function()
		GameStateManager:ChangeState(GAME_STATE.STATE_TIAOZHAN, 2)
	end
	})
	self:addChild(resultLayer, RESULT_ZORDER)
end

function HuoDongBattleScene:initJiefuJiPin()
	self.totoNumValue = 0
	local proxy = CCBProxy:create()
	self._numrootnode = {}
	local node = CCBuilderReaderLoad("huodong/jiefujipin.ccbi", proxy, self._numrootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node, RESULT_ZORDER - 1)
	
	--造成伤害
	self.curDamageNum = ui.newTTFLabelWithShadow({
	text = "0",
	size = 21,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_LEFT,
	color = cc.c3b(255, 240, 0),
	shadowColor = FONT_COLOR.BLACK,
	})
	
	local curDamageImgSize = self._numrootnode.cur_damage:getContentSize()
	self.curDamageNum:align(display.LEFT_CENTER, curDamageImgSize.width + 10, curDamageImgSize.height / 2)
	self._numrootnode.cur_damage:addChild(self.curDamageNum)
	
	--获得银币
	self.curSilverNum = ui.newTTFLabelWithShadow({
	text = "0",
	size = 21,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_LEFT,
	color = cc.c3b(231, 230, 228),
	shadowColor = FONT_COLOR.BLACK,
	})
	
	local curSilverImgSize = self._numrootnode.get_silver:getContentSize()
	self.curSilverNum:align(display.LEFT_CENTER, curSilverImgSize.width + 10, curSilverImgSize.height / 2)
	self._numrootnode.get_silver:addChild(self.curSilverNum)
	
	--回合数
	self.restRoundNum = ui.newTTFLabelWithShadow({
	text = "0/5",
	size = 21,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_LEFT,
	color = cc.c3b(4, 246, 38),
	shadowColor = FONT_COLOR.BLACK,
	})
	local roundImgSize = self._numrootnode.rest_round:getContentSize()
	self.restRoundNum:align(display.LEFT_CENTER, roundImgSize.width + 10, roundImgSize.height / 2)
	self._numrootnode.rest_round:addChild(self.restRoundNum)
end

function HuoDongBattleScene:updateTotalDamgeNum(num)
	if type(num) == "number" then
		self.totoNumValue = math.ceil(self.totoNumValue + num)
		self.curDamageNum:setString(self.totoNumValue)
		self:updataMoneyNum(self.totoNumValue)
	else
		assert(false, common:getLanguageString("@ErrorType"))
	end
end

function HuoDongBattleScene:updataMoneyNum(damageNum)
	local jiefuData = data_jiefujipin_jiefujipin
	local setMoneyNum = function(moneyNume)
	end
	for i = self.activeId, #jiefuData do
		if damageNum < jiefuData[i].damage then
			if i > 1 then
				self.moneyValue = jiefuData[i - 1].sumsilver + (damageNum - jiefuData[i - 1].damage) * jiefuData[i - 1].per / 1000
				break
			else
				self.moneyValue = damageNum * jiefuData[i].per / 1000
				break
			end
		else
			self.activeId = i
		end
	end
	if self.activeId == #jiefuData and damageNum >= jiefuData[self.activeId].damage then
		dump("jiefuDatajiefuDatajiefuDatajiefuData")
		self.moneyValue = jiefuData[self.activeId].sumsilver + (damageNum - jiefuData[self.activeId].per / 1000)
	end
	self.moneyValue = math.ceil(self.moneyValue)
	self.curSilverNum:setString(self.moneyValue)
end

function HuoDongBattleScene:updateRound(num)
	self.restRoundNum:setString(num .. "/5")
end

function HuoDongBattleScene:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	game.runningScene = self
	self.activeId = 1
	self.fubenid = param.fubenid
	self._sysId = param.sysId
	self._npcLv = param.npcLv
	self._fmt = param.fmt
	self._errback = param.errback
	self._endFunc = param.endFunc
	self._zhanli = param.zhanli
	self._viewType = param.viewType or CHALLENGE_TYPE.HUODONG_VIEW
	self.timeScale = 1
	if self.fubenid == JIEFUJIPIN_ID then
		self:initJiefuJiPin()
		
		function self.jiefuCB(num)
			self:updateTotalDamgeNum(num)
		end
		
		function self.roundCB(num)
			self:updateRound(num)
		end
	end
	self.timeScale = ResMgr.battleTimeScale
	
	function self.reqFunc(curWave)
		self:sendReq(curWave)
	end
	
	function self.resultFunc(data)
		if self.fubenid == JIEFUJIPIN_ID then
			self:jieFuResult(data)
		else
			self:result(data)
		end
	end
	
	self.totalData = nil
	local fubenType = HUODONG_FUBEN
	if self._viewType == CHALLENGE_TYPE.ZHENSHEN_VIEW then
		fubenType = ZHENSHEN_FUBEN
	end
	local data = param.data
	local initData = {
	fubenType = fubenType,
	fubenId = self.fubenid,
	reqFunc = self.reqFunc,
	resultFunc = self.resultFunc,
	damageCB = self.jiefuCB,
	roundCB = self.roundCB,
	battleData = data
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

function HuoDongBattleScene:onExit()
	display.removeSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
end

return HuoDongBattleScene