local data_kuafu_configelse_kuafu_configelse = require("data.data_kuafu_configelse_kuafu_configelse")

local xuanbaXuanbaLayer = class("xuanbaXuanbaLayer", function()
	return display.newLayer("xuanbaXuanbaLayer")
end)

local xuanbaMsg = {

getXuanBaInfo = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossRankList",
	type = 0
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

resetChallengeList = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossReset",
	type = param.type
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

resetChallengeListByGold = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossListReset",
	type = param.type
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

buyChallengeTimes = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "buyBattleNumber",
	number = param.num
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}

function xuanbaXuanbaLayer:ctor(param)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	self:setContentSize(param.size)
	local bgNode = CCBuilderReaderLoad("kuafu/xuanba_xuanba_bg.ccbi", self._proxy, self._rootnode, self, param.size)
	self:addChild(bgNode)
	self._parent = param.parent
	local boardWidth = self._rootnode.xuanba_listView:getContentSize().width
	local boardHeight = self._rootnode.xuanba_listView:getContentSize().height - self._rootnode.tag_normal_node:getContentSize().height
	local listViewSize = cc.size(boardWidth, boardHeight)
	self._challengeData = {}
	local function createFunc(index)
		local item = require("game.kuafuzhan.xuanbaItemCell").new()
		return item:create({
		itemData = self._challengeData[index + 1],
		challengeFunc = function(itemData)
			if KuafuModel.checkCurretntStep(enumKuafuState.xuanba, true) then
				if self._battleCount > 0 then
					KuafuModel.showChallengeEnemyForm(itemData, self._parent, 1)
				else
					show_tip_label(common:getLanguageString("@NotDareNumber"))
				end
			end
		end
		})
	end
	
	local function refreshFunc(cell, index)
		cell:refresh(self._challengeData[index + 1])
	end
	self.challengeList = nil
	self.hasInit = false
	local challengeList = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._challengeData,
	scrollFunc = function()
		if self.hasInit then
			PageMemoModel.saveOffset("xuanba_list", self.challengeList)
		end
	end,
	cellSize = require("game.kuafuzhan.xuanbaItemCell").new():getContentSize()
	})
	self.challengeList = challengeList
	self._rootnode.xuanba_listView:addChild(self.challengeList)
	
	--防守
	self._rootnode.defend_info_Btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if KuafuModel.checkCurretntStep(enumKuafuState.xuanba, true) then
			local defendInfoLayer = require("game.kuafuzhan.xuanbaDefendInfoLayer").new({
			battleCount = self._battleCount
			})
			display.getRunningScene():addChild(defendInfoLayer, 100)
		end
	end,
	CCControlEventTouchUpInside)
	
	--购买挑战次数
	self._rootnode.buy_times_btn:addHandleOfControlEvent(function(sender, eventName)
		if KuafuModel.checkCurretntStep(enumKuafuState.xuanba, true) then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			self:showBuyChallengeTimes()
		end
	end,
	CCControlEventTouchUpInside)
	
	--刷新对手
	self._rootnode.refresh_countdown:addHandleOfControlEvent(function(sender,eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:challengeListRefresh()
	end,
	CCControlEventTouchUpInside)
end

function xuanbaXuanbaLayer:updateLabelInfo()
	self._rootnode.jifen_num:setString(self._point)
	self._rootnode.rank_num:setString(self._rank)
	self._rootnode.time_num:setString(tostring(self._battleCount))
end

function xuanbaXuanbaLayer:getData()
	local function init(data)
		dump(data)
		self._battleNumber = data.battleNumber
		self._buyNumber = data.buyNumber or 0
		self._rank = data.rank
		self._endTime = data.battleRefresh / 1000
		self._point = data.point
		local sign = data.sign
		self._battleCount = data_kuafu_configelse_kuafu_configelse[1].value + self._buyNumber - data.battleNumber
		self._challengeData = data.result
		for key, _item in pairs(self._challengeData) do
			local tempKey = _item.serverId .. "#" .. _item.account
			_item.hasChallenge = false
			--[[
			if data.battleTags[tempKey] then
				_item.hasChallenge = false
			else
				_item.hasChallenge = true
			end
			]]
		end
		self.challengeList:resetListByNumChange(#self._challengeData)
		self.hasInit = true
		PageMemoModel.resetOffset("xuanba_list", self.challengeList)
		self:challengeRefreshTimeUpdate()
		self:updateLabelInfo()
	end
	self.dataInit = init
	self.hasInit = false
	xuanbaMsg.getXuanBaInfo({
	callback = function(data)
		dump(data)
		init(data)
	end
	})
end

function xuanbaXuanbaLayer:initData()
	self:getData()
end

function xuanbaXuanbaLayer:challengeListRefresh()
	if KuafuModel.checkCurretntStep(enumKuafuState.xuanba, true) then
		xuanbaMsg.resetChallengeList({
		type = 0,
		callback = function(data)
			self.dataInit(data)
		end
		})
		
		--[[
		if self._battleRefresh <= 0 then
			xuanbaMsg.resetChallengeList({
			type = 0,
			callback = function(data)
				self.dataInit(data)
			end
			})
		else
			local _cost = data_kuafu_configelse_kuafu_configelse[18].value
			local box = require("utility.CostTipMsgBox").new({
			tip = common:getLanguageString("@kfz_suaxin"),
			listener = function()
				if game.player:getGold() >= _cost then
					xuanbaMsg.resetChallengeListByGold({
					type = 1,
					callback = function(data)
						self.dataInit(data)
						game.player:setGold(game.player:getGold() - _cost)
					end
					})
				else
					ResMgr.showErr(400004)
				end
			end,
			cost = _cost
			})
			game.runningScene:addChild(box, 1001)
		end
		]]
	end
end

function xuanbaXuanbaLayer:challengeRefreshTimeUpdate()
	local function updateTime()
		self._battleRefresh = GameModel.getRestTimeInSec(self._endTime)
		if self._battleRefresh > 0 then
			self._battleRefresh = self._battleRefresh - 1
			local timeStr = tostring(format_time(self._battleRefresh))
			resetctrbtnString(self._rootnode.refresh_countdown, timeStr)
			self.timeNode:performWithDelay(updateTime, 1)
		else
			resetctrbtnString(self._rootnode.refresh_countdown, common:getLanguageString("@ShuaXinDuiShou"))
		end
	end
	if not self.timeNode then
		self.timeNode = display.newNode()
		self:addChild(self.timeNode)
	end
	updateTime()
end

function xuanbaXuanbaLayer:showBuyChallengeTimes()
	local price = data_kuafu_configelse_kuafu_configelse[2].value
	local addprice = data_kuafu_configelse_kuafu_configelse[3].value
	local count = data_kuafu_configelse_kuafu_configelse[4].value
	local param = {
	addPrice = addprice,
	baseprice = price,
	coinType = 1,
	desc = common:getLanguageString("@GetSilverCoin"),
	hadBuy = self._buyNumber,
	icon = "yidaiyinbi",
	id = 1,
	itemId = 4302,
	maxN = count - self._buyNumber,
	maxnum = count - self._buyNumber,
	name = common:getLanguageString("@kuafuChallegeTimes"),
	price = price,
	remainnum = count - self._buyNumber
	}
	local function callBackFunc(num, costNum)
		if costNum > game.player:getGold() then
			show_tip_label(data_error_error[100004].prompt)
			return
		end
		xuanbaMsg.buyChallengeTimes({
		num = num,
		callback = function(data)
			dump(data)
			if data.result == 1 then
				show_tip_label(data_error_error[1602].prompt)
			elseif data.result == 2 then
				show_tip_label(data_error_error[1500706].prompt)
			elseif data.result == 3 then
				self._buyNumber = self._buyNumber + num
				self._battleCount = self._battleCount + num
				self:updateLabelInfo()
				game.player:setGold(game.player:getGold() - costNum)
			end
		end
		})
	end
	CCDirector:sharedDirector():getRunningScene():addChild(require("game.Biwu.BiwuByTimesCountBox").new(param, callBackFunc), 100000)
end

function xuanbaXuanbaLayer:onEnter()
	print("xuanbaXuanbaLayer onEnter ~~~~~~~~")
end

function xuanbaXuanbaLayer:onExit()
	print("xuanbaXuanbaLayer onExit ~~~~~~~~")
end

return xuanbaXuanbaLayer