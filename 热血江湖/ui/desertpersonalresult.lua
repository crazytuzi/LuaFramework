-- 2018.10.24
-- zhangbing
-- eUIID_DesertPersonalResult
-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_desertPersonalResult = i3k_class("wnd_desertPersonalResult", ui.wnd_base)

local WIDGET_SCORE = "ui/widgets/juezhanhuangmojs1t"
local WIDGET_REARED = "ui/widgets/julinggongchengjst2"
local COUNT_DOWN = i3k_clone(i3k_db_desert_battle_base.autoCloseTimeWhenGameEnd) --倒计时自动关闭时间
local scoreDesc = {
		17633,	--击杀
		17634,	--淘汰
		17635, 	--杀怪
		17636, 	--助攻
	}

function wnd_desertPersonalResult:ctor()
	self._timer = 0
	self._count = 0
end

function wnd_desertPersonalResult:configure()
	local widgets = self._layout.vars
	self.widget = {}
	self.widget.scoreScroll		= widgets.scoreScroll
	self.widget.rewardScroll		= widgets.rewardScroll
	self.widget.countDown			= widgets.countDown

	widgets.closeBtn:onClick(self, self.onLeave)
end

function wnd_desertPersonalResult:refresh(result, rewards)
	self:loadScoreScroll(result.scores)
	self:loadRewardScroll(rewards)
	self:updateCountDown(COUNT_DOWN)	
end

-- 积分列表
function wnd_desertPersonalResult:loadScoreScroll(scores)
	self.widget.scoreScroll:removeAllChildren()
	local totalScores = 0
	for i = 1, 4 do
		local node = require(WIDGET_SCORE)()
		local score = scores[i] or 0
		totalScores = totalScores + score
		node.vars.desc:setText(i3k_get_string(scoreDesc[i]))
		node.vars.value:setText(score)
		self.widget.scoreScroll:addItem(node)
	end

	local totalNode = require(WIDGET_SCORE)()
	totalNode.vars.desc:setText(i3k_get_string(17637))
	totalNode.vars.value:setText(totalScores)
	totalNode.vars.desc:setTextColor("ff5037a2")
	totalNode.vars.value:setTextColor("ff5037a2")
	self.widget.scoreScroll:addItem(totalNode)

	self.widget.scoreScroll:stateToNoSlip()
end

-- 奖励列表
function wnd_desertPersonalResult:loadRewardScroll(rewards)
	self.widget.rewardScroll:removeAllChildren()
	for _, item in ipairs(rewards) do
		local node = require(WIDGET_REARED)()
		self:updateCells(node, item)
		self.widget.rewardScroll:addItem(node)
	end
end

function wnd_desertPersonalResult:updateCells(node, item)
	node.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
	node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id, g_i3k_game_context:IsFemaleRole()))
	node.vars.item_count:setText(item.count)
	node.vars.bt:onClick(self, self.onItemTips, item.id)
end

-- 倒计时更新
function wnd_desertPersonalResult:updateCountDown(time)
	self.widget.countDown:setText(math.floor(time).."s")
end

function wnd_desertPersonalResult:onUpdate(dTime)
	self._timer = self._timer + dTime
	self._count = self._count + dTime
	if self._timer >= 1 then --每秒倒计时
		self._timer = 0
		self:updateCountDown(COUNT_DOWN - self._count)
		if self._count >= COUNT_DOWN then
			self:onLeave() -- 倒计时结束自动关闭ui
		end
	end
end

function wnd_desertPersonalResult:onLeave(sender)
	i3k_sbean.mapcopy_leave()
end

function wnd_desertPersonalResult:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_desertPersonalResult.new()
	wnd:create(layout)
	return wnd
end
