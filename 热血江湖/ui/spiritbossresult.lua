-- 2018.6.20
-- zhangbing
-- eUIID_SpiritBossResult
-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_spiritBossResult = i3k_class("wnd_spiritBossResult", ui.wnd_base)

local WIDGET_RANKJST = "ui/widgets/julinggongchengjst1"
local WIDGET_REARED = "ui/widgets/julinggongchengjst2"
local COUNT_DOWN = i3k_clone(i3k_db_spirit_boss.common.autoClose) --倒计时自动关闭时间

function wnd_spiritBossResult:ctor()
	self._timer = 0
	self._count = 0
	self._isLeave = false -- 确定按钮是否离开副本
end

function wnd_spiritBossResult:configure()
	local widgets = self._layout.vars
	self.widget = {}
	self.widget.modelWidget = {}
	self:initModelWidgets(widgets)
	self.widget.rankingScroll		= widgets.rankingScroll
	self.widget.selfRanking			= widgets.selfRanking
	self.widget.rewardScroll		= widgets.rewardScroll
	self.widget.rankingDesc			= widgets.rankingDesc
	self.widget.countDown			= widgets.countDown
	self.widget.tipsDesc			= widgets.tipsDesc

	widgets.closeBtn:onClick(self, self.onCloseUI)
end

-- 初始化前三名控件
function wnd_spiritBossResult:initModelWidgets(widgets)
	for i=1, 3 do
		self.widget.modelWidget[i] = {
			modelRoot	= widgets["modelRoot"..i],
			heroModule	= widgets["heroModule"..i],
			name		= widgets["name"..i],
			damage 		= widgets["damage"..i],
			emptyDesc	= widgets["emptyDesc"..i],
		}
	end
end

function wnd_spiritBossResult:refresh(info)
	local selfRank = info.selfRank
	local cfg = i3k_db_spirit_boss.common
	self:loadRankScroll(info.rank)
	self:loadModelInfo(info.top3, info.rank)
	self:loadRewardScroll(info.rewards)
	self:loadRankingDesc(info.bossID, info.selfRank)
	self:updateCountDown(COUNT_DOWN)
	local rankDesc = (selfRank > cfg.showRanking or selfRank == 0) and i3k_get_string(17327) or selfRank
	self.widget.selfRanking:setText(rankDesc)
	-- info.dead 0:boss未死亡 1:boss死亡 2:boss死亡并且是最后一个boss
	--dead大于零击杀奖励描述
	self._layout.vars.rewardType:setText(info.dead > 0 and i3k_get_string(17338) or i3k_get_string(17339))
	self.widget.tipsDesc:setVisible(info.dead == 2)
	self._isLeave = info.dead == 2
	self.widget.tipsDesc:setText(i3k_get_string(17344))
end

-- 排行列表
function wnd_spiritBossResult:loadRankScroll(rankInfo)
	self.widget.rankingScroll:removeAllChildren()
	for i, e in ipairs(rankInfo) do
		if i > 3 then
			local node = require(WIDGET_RANKJST)()
			node.vars.rankTxt:setText(i3k_get_string(17340, i))
			node.vars.name:setText(e.roleName)
			self.widget.rankingScroll:addItem(node)
		end
	end
end

-- 前三名模型
function wnd_spiritBossResult:loadModelInfo(topInfo, rankInfo)
	for i, e in ipairs(self.widget.modelWidget) do
		local info = rankInfo[i]
		e.modelRoot:setVisible(info ~= nil)
		if info then
			local roleID = info.roleID
			if topInfo[roleID] then
				self:createModule(e.heroModule, topInfo[roleID])
			else
				e.emptyDesc:show()
			end
			e.name:setText(info.roleName)
			e.damage:setText(i3k_get_string(17341, info.damage))
		end
	end
end

-- 奖励列表
function wnd_spiritBossResult:loadRewardScroll(rewards)
	self.widget.rewardScroll:removeAllChildren()
	local rewardsSort = {}
	for k, v in pairs(rewards) do
		table.insert(rewardsSort, {id = k, count = v, sortId = g_i3k_db.i3k_db_get_common_item_rank(k)})
	end
	table.sort(rewardsSort, function (a, b)
		return a.sortId > b.sortId
	end)
	for _, j in ipairs(rewardsSort) do
		local node = require(WIDGET_REARED)()
		node.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(j.id))
		node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(j.id, g_i3k_game_context:IsFemaleRole()))
		node.vars.item_count:setText(j.count)
		node.vars.bt:onClick(self, self.onItemTips, j.id)
		self.widget.rewardScroll:addItem(node)
	end
end

-- 排名描述
function wnd_spiritBossResult:loadRankingDesc(bossID, selfRank)
	local cfg = i3k_db_spirit_boss.common
	local needRank = g_i3k_db.i3k_db_get_spiritBoss_rank_desc(bossID, selfRank)
	local desc = (selfRank > cfg.showRanking or selfRank == 0) and i3k_get_string(17330) or i3k_get_string(17329, needRank)
	self.widget.rankingDesc:setVisible(selfRank > cfg.showRanking or selfRank == 0 or needRank > 0)
	self.widget.rankingDesc:setText(desc)
end

-- 倒计时更新
function wnd_spiritBossResult:updateCountDown(time)
	self.widget.countDown:setText(math.floor(time).."s")
end

-- 创建模型
function wnd_spiritBossResult:createModule(moduleWidget, roleDetail)
	local overview = roleDetail.overview
	local model = roleDetail.model
	local modelTable = {}
	modelTable.node = moduleWidget
	modelTable.id = overview.type
	modelTable.bwType = overview.bwType
	modelTable.gender = overview.gender
	modelTable.face = model.face
	modelTable.hair = model.hair
	modelTable.equips = model.equips
	modelTable.fashions = model.curFashions
	modelTable.isshow = model.showFashionTypes
	modelTable.equipparts = model.equipParts
	modelTable.armor = model.armor
	modelTable.weaponSoulShow = model.weaponSoulShow
	modelTable.isEffectFashion = nil
	modelTable.soaringDisplay = model.soaringDisplay
	self:createModelWithCfg(modelTable)
end

function wnd_spiritBossResult:onUpdate(dTime)
	self._timer = self._timer + dTime
	self._count = self._count + dTime
	if self._timer >= 1 then --每秒倒计时
		self._timer = 0
		self:updateCountDown(COUNT_DOWN - self._count)
		if self._count >= COUNT_DOWN then
			self:onCloseUI() -- 倒计时结束自动关闭ui
		end
	end
end

function wnd_spiritBossResult:onCloseUI(sender)
	if self._isLeave then
		i3k_sbean.mapcopy_leave()
	else
		g_i3k_ui_mgr:CloseUI(eUIID_SpiritBossResult)	
	end
end

function wnd_spiritBossResult:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_spiritBossResult.new()
	wnd:create(layout)
	return wnd
end
