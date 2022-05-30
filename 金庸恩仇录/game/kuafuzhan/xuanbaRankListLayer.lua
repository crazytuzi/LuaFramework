local xuanbaRankListLayer = class("xuanbaRankListLayer", function()
	return display.newLayer("xuanbaRankListLayer")
end)

local rankListMsg = {

--获取排行榜
getRankList = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossRankList",
	type = 1
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

--查看排行榜整容
lookRankForm = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "showTeam",
	targetAcc = param.targetAcc,
	targetIdx = param.targetServerId
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}

function xuanbaRankListLayer:ctor(param)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	self:setContentSize(param.size)
	local bgNode = CCBuilderReaderLoad("kuafu/xuanba_ranklist_bg.ccbi", self._proxy, self._rootnode, self, param.size)
	self:addChild(bgNode)
	self._parent = param.parent
	local boardWidth = self._rootnode.rank_listView:getContentSize().width
	local boardHeight = self._rootnode.rank_listView:getContentSize().height - self._rootnode.tag_normal_node:getContentSize().height
	local listViewSize = CCSizeMake(boardWidth, boardHeight)
	self._rankListData = {}
	local function createFunc(index)
		local item = require("game.kuafuzhan.xuanbaItemCell").new()
		return item:create({
		itemData = self._rankListData[index + 1],
		formationFunc = function(itemData)
			self:showEnmeyForm(itemData)
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(self._rankListData[index + 1])
	end
	self.rankListTableView = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._rankListData,
	cellSize = require("game.kuafuzhan.xuanbaItemCell").new():getContentSize()
	})
	self._rootnode.rank_listView:addChild(self.rankListTableView)
	self._rootnode.reward_show_btn:addHandleOfControlEvent(function(sender, eventName)
		local param = {}
		param.miPageId = 3
		param.typeTbl = {1}
		param.props_title = common:getLanguageString("@ViewRewardText")
		local layer = require("game.huashan.HuaShanRewardShow").new(param)
		self._parent:addChild(layer, 100)
	end,
	CCControlEventTouchUpInside)
end

function xuanbaRankListLayer:updateLabelInfo()
	self._rootnode.dangqianjf_num:setString(self._point)
	self._rootnode.CurrentRanking_num:setString(self._rank)
end

function xuanbaRankListLayer:showEnmeyForm(itemData)
	rankListMsg.lookRankForm({
	targetAcc = itemData.account,
	targetServerId = itemData.serverId,
	callback = function(data)
		enemyForm = data
		--dump(data)
		--[[
		local j = require("framework.json")
		local tempData = j.decode(data.rtnObj.info)
		enemyForm = {}
		for key, value in pairs(tempData) do
			local index = tostring(tonumber(key) - 1)
			enemyForm[index] = value
		end
		for key, hero in pairs(enemyForm["1"]) do
			if hero.viewBase then
				hero.base = hero.viewBase
				hero.levelLimit = enemyForm["1"][1].level
			end
		end
		for key, equipGroup in pairs(enemyForm["2"]) do
			for _, equip in pairs(equipGroup) do
				if equip.viewBase then
					equip.base = equip.viewBase
				end
				if equip.baseViewRate then
					equip.baseRate = equip.baseViewRate
				end
			end
		end
		]]
		local layer = require("game.form.EnemyFormLayer").new(1, enemyForm)
		self._parent:addChild(layer, 100)
	end
	})
end

function xuanbaRankListLayer:getData()
	rankListMsg.getRankList({
	callback = function(data)
		dump(data)
		--local j = require("framework.json")
		--for key, item in pairs(data.rtnObj.result) do
		--	item.resTeam = j.decode(item.resTeam)
		--end
		
		self._rankListData = data.result
		self._battleNum = data.battleNumber
		self._point = data.point
		self._rank = data.rank
		self._battleRefresh = data.battleRefresh
		self.rankListTableView:resetListByNumChange(#self._rankListData)
		self:updateLabelInfo()
	end
	})
end

function xuanbaRankListLayer:initData()
	self:getData()
end

function xuanbaRankListLayer:onEnter()
	display.addSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
end

function xuanbaRankListLayer:onExit()
	display.removeSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
end

return xuanbaRankListLayer