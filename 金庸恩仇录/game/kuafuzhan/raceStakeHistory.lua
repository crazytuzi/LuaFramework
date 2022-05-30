local kuafuMsg = {
getStakeHistoryBonus = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossStakeHistoryBonus",
	id = param.id
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}
local raceTitle = {
[1] = common:getLanguageString("@raceType3"),
[2] = common:getLanguageString("@raceType2"),
[4] = common:getLanguageString("@raceType1", 8, 4),
[8] = common:getLanguageString("@raceType1", 16, 8),
[16] = common:getLanguageString("@raceType1", 16, 8)
}

local stakeInfoItem = class("stakeInfoItem", function()
	return CCTableViewCell:new()
end)

function stakeInfoItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("kuafu/my_detain_item.ccbi", proxy, rootnode)
	local contentSize = node:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return contentSize
end

function stakeInfoItem:create(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("kuafu/my_detain_item.ccbi", proxy, self._rootnode)
	local contentSize = node:getContentSize()
	node:setPosition(contentSize.width * 0.5, contentSize.height)
	self:addChild(node, 0)
	alignNodesOneByOne(self._rootnode.detain_num_label, self._rootnode.detain_num)
	alignNodesOneByOne(self._rootnode.detain_reward_label, self._rootnode.detain_reward)
	self._rootnode.rewardBtn:addHandleOfControlEvent(function(sender, eventName)
		self:getReard()
	end,
	CCControlEventTouchUpInside)
	
	self.bgSize = self._rootnode.player_bg_1:getContentSize()
	self:refresh(param.battleInfo)
	for key = 1, 2 do
		setTTFLabelOutline({
		label = self._rootnode["player_name_" .. key]
		})
		setTTFLabelOutline({
		label = self._rootnode["player_server_" .. key]
		})
	end
	return self
end

function stakeInfoItem:refresh(battleInfo)
	self.battleInfo = battleInfo
	local pngPath = "ui/ui_CommonResouces/"
	local selectSide = battleInfo.select == 1 and 1 or 2
	if self.battleInfo.action == 0 then
		for i = 1, 2 do
			self._rootnode["player_result_" .. i]:setVisible(false)
			self._rootnode["player_bg_" .. i]:setSpriteFrame(display.newSprite("ui/ui_9Sprite/ui_sh_bg_25.png"):getDisplayFrame())
			self._rootnode["player_bg_" .. i]:setContentSize(self.bgSize)
			self._rootnode["player_stake_" .. i]:setVisible(i == selectSide)
		end
	else
		local winSide = battleInfo.win == 1 and 1 or 2
		for i = 1, 2 do
			local resultPath, bgPath
			if i == winSide then
				resultPath = pngPath .. "ui_victory.png"
				bgPath = "ui/ui_9Sprite/ui_sh_bg_4.png"
			else
				resultPath = pngPath .. "ui_defeated.png"
				bgPath = "ui/ui_9Sprite/ui_sh_bg_29.png"
			end
			self._rootnode["player_result_" .. i]:setVisible(true)
			self._rootnode["player_result_" .. i]:setDisplayFrame(display.newSprite(resultPath):getDisplayFrame())
			self._rootnode["player_bg_" .. i]:setSpriteFrame(display.newSprite(bgPath):getDisplayFrame())
			self._rootnode["player_bg_" .. i]:setContentSize(self.bgSize)
			self._rootnode["player_stake_" .. i]:setVisible(i == selectSide)
		end
	end
	for key, user in pairs(battleInfo.userInfo) do
		self._rootnode["player_name_" .. key]:setString(user.name)
		self._rootnode["player_server_" .. key]:setString(user.serverName)
		ResMgr.refreshIcon({
		id = user.res[1].resId,
		itemBg = self._rootnode["player_icon_" .. key],
		resType = ResMgr.HERO,
		cls = user.res[1].cls
		})
	end
	local text = battleInfo.userInfo[1].viewType == 1 and "@MasterHero" or "@NameDynamic"
	self._rootnode.comp_name:setString(common:getLanguageString(text) .. raceTitle[battleInfo.popNum])
	self:updateRewardInfo()
end

function stakeInfoItem:updateRewardInfo()
	local state_png = self.battleInfo.action > 0 and "ui_complete.png" or "ui_not_start.png"
	self._rootnode.detain_state:setDisplayFrame(display.newSprite("ui/ui_CommonResouces/" .. state_png):getDisplayFrame())
	local Label = common:getLanguageString("@SilverLabel")
	self._rootnode.detain_num:setString(self.battleInfo.set .. Label)
	self._rootnode.detain_reward:setString(self.battleInfo.get .. Label)
	local visible = self.battleInfo.action == 1
	self._rootnode.rewardBtn:setVisible(visible)
	self._rootnode.tag_has_get:setVisible(self.battleInfo.action == 3)
end

function stakeInfoItem:getReard()
	if self.battleInfo.action ~= 1 then
		show_tip_label(common:getLanguageString("@RewardConfuse"))
	else
		kuafuMsg.getStakeHistoryBonus({
		id = self.battleInfo.id,
		callback = function(data)
			dump(data)
			self.battleInfo.action = 3
			self:updateRewardInfo()
			game.player:addSilver(data.rtnObj)
			show_tip_label(common:getLanguageString("@lingjiang") .. common:getLanguageString("@SuccessLabel"))
		end
		})
	end
end

local raceStakeHistory = class("raceStakeHistory", function(param)
	return require("utility.ShadeLayer").new()
end)

function raceStakeHistory:ctor(param)
	viewType = param.viewType
	self._userInfo = param.userInfo
	self._stakeHistoryList = param.stakeHistoryList
	self._title = param.title or ""
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("kuafu/mydetain_Msgbox.ccbi", rootProxy, self._rootnode)
	self:addChild(rootnode, 1)
	rootnode:setPosition(display.cx, display.cy)
	self._rootnode.detain_title:setString(self._title)
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	local boardWidth = self._rootnode.detain_layer:getContentSize().width
	local boardHeight = self._rootnode.detain_layer:getContentSize().height
	local listViewSize = cc.size(boardWidth, boardHeight)
	local itemSize = stakeInfoItem.new():getContentSize()
	local function createFunc(index)
		index = index + 1
		return stakeInfoItem.new():create({
		battleInfo = self._stakeHistoryList[index]
		})
	end
	local function refreshFunc(cell, index)
		index = index + 1
		cell:refresh(self._stakeHistoryList[index])
	end
	self.rankListTableView = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._stakeHistoryList,
	cellSize = itemSize
	})
	self._rootnode.detain_layer:addChild(self.rankListTableView)
end

return raceStakeHistory