-- 2018.10.24
-- zhangbing
-- eUIID_DesertTeamResult
-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/desertPersonalResult")

-------------------------------------------------------

wnd_desertTeamResult = i3k_class("wnd_desertTeamResult", ui.wnd_desertPersonalResult)

local WIDGET_SCORET = "ui/widgets/juezhanhuangmojs2t"
local WIDGET_REARED = "ui/widgets/julinggongchengjst2"
local COUNT_DOWN = i3k_clone(i3k_db_desert_battle_base.autoCloseTimeWhenGameEnd) --倒计时自动关闭时间

function wnd_desertTeamResult:ctor()
	self._timer = 0
	self._count = 0
end

function wnd_desertTeamResult:configure()
	local widgets = self._layout.vars
	self.widget = {}
	self.widget.rank 					= widgets.rank
	self.widget.winDesc					= widgets.winDesc
	self.widget.scoreScroll				= widgets.scoreScroll
	self.widget.selfRewardScroll		= widgets.selfRewardScroll
	self.widget.teamRewardScroll		= widgets.teamRewardScroll
	self.widget.countDown 				= widgets.countDown

	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.leaveBtn:onClick(self, self.onLeave)
end

function wnd_desertTeamResult:refresh(result, selfRewards, teamRewards)
	self.widget.rank:setText(result.rank)
	self.widget.winDesc:setText(i3k_db_desert_rank[result.rank].rankDesc)
	self:loadTeamScroll(result.roles)
	self:loadPersonalReward(selfRewards)
	self:laodTeamReward(teamRewards)
	self:updateCountDown(COUNT_DOWN)
end

-- 积分列表
function wnd_desertTeamResult:loadTeamScroll(roles)
	local roleID = g_i3k_game_context:GetRoleId()
	self.widget.scoreScroll:removeAllChildren()
	for _, e in ipairs(self:sortRoles(roles)) do
		local node = require(WIDGET_SCORET)()
		local info = e.info
		local scores = info.scores
		local isSelf = roleID == e.roleID
		node.vars.name:setText(info.name)
		if isSelf then
			node.vars.name:setTextColor("fff27c26")
		end
		for i = 1, 4 do
			node.vars["score"..i]:setText(scores[i] or 0)
			if isSelf then
				node.vars["score"..i]:setTextColor("fff27c26")
			end
		end
		node.vars.totalScoreTxt:setText(e.totalScore)
		if isSelf then
			node.vars.bgIcon:show()
			node.vars.totalScoreTxt:setTextColor("fff27c26")
		end
		self.widget.scoreScroll:addItem(node)
	end
end

function wnd_desertTeamResult:sortRoles(roles)
	local rolesList = {}
	for roleID, info in pairs(roles) do
		local totalScore = 0
		for scoreType, score in pairs(info.scores) do
			totalScore = totalScore + score
		end
		table.insert(rolesList, {info = info, totalScore = totalScore, roleID = roleID})
	end
	table.sort(rolesList, function (a, b)
		return a.totalScore > b.totalScore
	end)
	return rolesList
end

-- 奖励列表
function wnd_desertTeamResult:loadPersonalReward(rewards)
	self.widget.selfRewardScroll:removeAllChildren()
	self.widget.selfRewardScroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	for _, item in ipairs(rewards) do
		local node = require(WIDGET_REARED)()
		self:updateCells(node, item)
		self.widget.selfRewardScroll:addItem(node)
	end
	
end

function wnd_desertTeamResult:laodTeamReward(rewards)
	self.widget.teamRewardScroll:removeAllChildren()
	self.widget.teamRewardScroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	for _, item in ipairs(rewards) do
		local node = require(WIDGET_REARED)()
		self:updateCells(node, item)
		self.widget.teamRewardScroll:addItem(node)
	end
end

function wnd_create(layout)
	local wnd = wnd_desertTeamResult.new()
	wnd:create(layout)
	return wnd
end
