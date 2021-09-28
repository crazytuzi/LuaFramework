------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_martial_soul_shen_dou = i3k_class("wnd_martial_soul_shen_dou",ui.wnd_base)

local PROP_WIDGET = "ui/widgets/shendout2"
local ITEM_WIDGET = "ui/widgets/shendout1"


local NODE_CNT = i3k_db_martial_soul_cfg.nodeCount--相当于多少个节点  比实际ui上的多一个

function wnd_martial_soul_shen_dou:ctor()
	self.starType = nil --当前装备星耀的类型
	self.lvl = nil --神斗等级
	self.skillData = nil --技能等级
	self.PROP_WIDGET = PROP_WIDGET --子类重写
	self.ACTIVE = 8526
	self.LOCK = 8530
end

function wnd_martial_soul_shen_dou:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.helpBtn:onClick(self, self.onHelpBtn)
	widgets.soulBtn:onClick(self, self.onSoulBtn)
	widgets.starBtn:onClick(self, self.onStarBtn)
	widgets.okBtn:onClick(self, self.onOkBtn)
	widgets.shenDouBtn:stateToPressed()
end

function wnd_martial_soul_shen_dou:refresh()
	local widgets = self._layout.vars
	local curStar = g_i3k_game_context:GetCurStar()
	-- local power = g_i3k_db.i3k_db_get_battle_power(g_i3k_db.i3k_db_get_shen_dou_prop())
	self.starType = i3k_db_star_soul[curStar].type
	self.lvl = g_i3k_game_context:GetWeaponSoulGodStarCurLvl()
	self.skillData = g_i3k_game_context:GetWeaponSoulGodStarSkills()
	self.ACTIVE = i3k_db_martial_soul_type[self.starType].starIcon
	-- widgets.battle_power:setText(power)
	widgets.btnTxt:setText(i3k_get_string(self.lvl % NODE_CNT == (NODE_CNT - 1) and 1741 or 1740))

	self:setMainPart()
	self:setPropScorll()
	self:setNeedItem()
	self:updateAllRed()
end

function wnd_martial_soul_shen_dou:setMainPart()
	local widgets = self._layout.vars
	widgets.rank:setText(i3k_db_martial_soul_shen_dou_grade[math.modf(self.lvl / NODE_CNT)])
	widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_martial_soul_type[self.starType].icon))
	self:setPoints(self.lvl)
	self:setSkills()
end

function wnd_martial_soul_shen_dou:setPoints(lvl)
	local widgets = self._layout.vars
	local cnt = lvl % NODE_CNT
	for i = 1, NODE_CNT - 1 do
		widgets["point"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(i > cnt and self.LOCK or self.ACTIVE))
		widgets["point"..i]:setVisible(i <= cnt)
	end
	if cnt == NODE_CNT - 1 then--最后一个节点不需要额外的旋转
		cnt = cnt - 1
	end
	widgets.pointRoot:setRotation(-cnt * 360 / (NODE_CNT - 1))
end

function wnd_martial_soul_shen_dou:setSkills()
	local widgets = self._layout.vars
	local rank = math.modf(self.lvl / NODE_CNT)
	for i = 1, 7 do
		local skillCfg = i3k_db_matrail_soul_shen_dou_xing_shu[i]
		local skillLvl = self.skillData[i] or 0
		local cfg = skillCfg[skillLvl == 0 and 1 or skillLvl]
		widgets['skillRoot'..i]:setVisible(skillCfg[1].needGrade <= rank)
		widgets['skillIcon'..i]:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconID))
		widgets['skillIcon'..i]:SetIsableWithChildren(skillLvl > 0)
		widgets['skillBtn'..i]:onClick(self, self.onSkillBtn, i)
		widgets['skillLvl'..i]:setVisible(skillLvl ~= 0)
		widgets['skillLvl'..i]:setText(skillLvl)
		if next(cfg.needXinShu) then--小星术
			local line1 = widgets['line'..cfg.needXinShu[1].id..i]
			local line2 = widgets['line'..cfg.needXinShu[2].id..i]
			line1:setVisible(widgets['skillRoot'..i]:isVisible())
			line2:setVisible(widgets['skillRoot'..i]:isVisible())
			line1:disable()
			line2:disable()
			if skillLvl > 0 then
				line1:enable()
				line2:enable()
				--TODO  小星术激活后线的特效
			else
				local lvl1 = g_i3k_game_context:GetWeaponSoulGodStarSkillLvl(cfg.needXinShu[1].id)
				local lvl2 = g_i3k_game_context:GetWeaponSoulGodStarSkillLvl(cfg.needXinShu[2].id)
				if lvl1 >= cfg.needXinShu[1].level then
					line1:enable()
				end
				if lvl2 >= cfg.needXinShu[2].level then
					line2:enable()
				end
			end
		end
	end
end

function wnd_martial_soul_shen_dou:setPropScorll()
	local widgets = self._layout.vars
	local cfg = i3k_db_matrail_soul_shen_dou_level[self.lvl]
	local nextCfg = i3k_db_matrail_soul_shen_dou_level[self.lvl + 1]
	local propCnt = #((nextCfg or cfg).props[self.starType])
	widgets.propScroll:removeAllChildren()
	local ratio = g_i3k_db.i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_GOD_STAR_ID, self.skillData[g_SHEN_DOU_SKILL_GOD_STAR_ID])
	local prop = {}
	for i = 1, propCnt do
		local ui = require(self.PROP_WIDGET)()
		local vars = ui.vars
		local curProp = cfg.props[self.starType][i]
		local nextProp = nextCfg and nextCfg.props[self.starType][i]
		local propId = (curProp or nextProp).id
		vars.name:setText(g_i3k_db.i3k_db_get_property_name(propId))
		vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(propId)))
		local curValue = curProp and curProp.value or 0
		vars.value:setText(math.modf(curValue * (1 + ratio)))
		prop[propId] = math.modf(curValue * (1 + ratio))
		if vars.nextValue then
			vars.nextValue:setText(nextProp and '+'..math.modf((nextProp.value - curValue) * (1 + ratio)) or "")
		end
		widgets.propScroll:addItem(ui)
	end
	widgets.battle_power:setText(g_i3k_db.i3k_db_get_battle_power(prop))
end

--右侧红点
function wnd_martial_soul_shen_dou:updateTabRed()
	local widgets = self._layout.vars
	widgets.soulRed:setVisible(g_i3k_game_context:IsWeaponSoulCanUp())
	widgets.shenDouRed:setVisible(g_i3k_db.i3k_db_get_shen_dou_red())
end

--技能红点
function wnd_martial_soul_shen_dou:updateSkillRed()
	local widgets = self._layout.vars
	for i, v in ipairs(i3k_db_matrail_soul_shen_dou_xing_shu) do
		widgets['skillRed'..i]:setVisible(g_i3k_db.i3k_db_get_shen_dou_skill_can_level_up(i))
	end
end
--全部红点
function wnd_martial_soul_shen_dou:updateAllRed()
	self:updateTabRed()
	self:updateSkillRed()
end

function wnd_martial_soul_shen_dou:setNeedItem()
	local widgets = self._layout.vars
	local isMax = self.lvl == #i3k_db_matrail_soul_shen_dou_level
	widgets.max:setVisible(isMax)
	widgets.consumeRoot:setVisible(not isMax)
	widgets.okBtn:setVisible(not isMax)
	if not isMax then
		local nextCfg = i3k_db_matrail_soul_shen_dou_level[self.lvl + 1]
		local consume = nextCfg.consume
		self.materialEnouth = true
		widgets.itemScroll:removeAllChildren()
		for i, v in ipairs(consume) do
			local ui = require(ITEM_WIDGET)()
			local vars = ui.vars
			local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id))
			vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
			vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
			vars.item_name:setTextColor(name_colour)
			vars.bt:onClick(self, function()g_i3k_ui_mgr:ShowCommonItemInfo(v.id)end)
			if v.id == g_BASE_ITEM_DIAMOND or v.id == g_BASE_ITEM_COIN then
				vars.item_count:setText(v.count)
			else
				vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .."/".. (v.count))
			end
			local enough = g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= (v.count)
			vars.item_count:setTextColor(g_i3k_get_cond_color(enough))
			if self.materialEnouth then
				self.materialEnouth = enough
			end
			widgets.itemScroll:addItem(ui)
		end
	end
end

function wnd_martial_soul_shen_dou:onUpdate(dTime)
	if self.mainCoroutine then
		coroutine.resume(self.mainCoroutine, dTime)
	end
end

--升级回调
function wnd_martial_soul_shen_dou:onShenDouLevelUp(level) --level 是升级前的等级
	if level == #i3k_db_matrail_soul_shen_dou_level - 1 then--达到最大值
		self:refresh()
		return
	end
	if level % NODE_CNT == (NODE_CNT - 1) then--突破成功了
		self.mainCoroutine = coroutine.create(function() self:breakUpCoroutine(0, level) end)
	else
		self.mainCoroutine = coroutine.create(function() self:levelUpCoroutine(0, level) end)
	end
	coroutine.resume(self.mainCoroutine, 0)
end

local ROTATE_TIME = 0.5
function wnd_martial_soul_shen_dou:levelUpCoroutine(dTime, level)
	self:onBeginLevelUpAnimation(level)
	if level % NODE_CNT ~= (NODE_CNT - 2) then--不是从第11颗到第12颗的时候才用转
		local timer = 0
		local img = self._layout.vars.pointRoot
		local from = -(level % NODE_CNT) * 360 / (NODE_CNT - 1)
		local to = -((level + 1) % NODE_CNT) * 360 / (NODE_CNT - 1)
		while timer < ROTATE_TIME do
			local cur = from + (to - from) * timer / ROTATE_TIME
			img:setRotation(cur)
			timer = dTime + timer
			dTime = coroutine.yield()
		end
	end
	self:onEndAnimation()
end

local BREAK_ROTATE_TIME = 0.5--旋转时间
local BREAK_NODE_TIME = 0.1--每个节点持续时间
function wnd_martial_soul_shen_dou:breakUpCoroutine(dTime, level)
	self:onBeginBreakUpAnimation(level)
	local timer = 0
	local widget = self._layout.vars
	local img = widget.pointRoot
	while timer < BREAK_ROTATE_TIME do
		timer = math.min(timer + dTime, BREAK_ROTATE_TIME)--防止转过
		img:setRotation(timer * 360 / BREAK_ROTATE_TIME)
		dTime = coroutine.yield()
	end
	local cnt = NODE_CNT - 1
	for i = 1, cnt do
		timer = 0
		while timer < BREAK_NODE_TIME do
			timer = timer + dTime
			dTime = coroutine.yield()
		end
		widget['point'..i]:hide()--setImage(g_i3k_db.i3k_db_get_icon_path(LOCK))
	end
	self:onEndAnimation()
end

function wnd_martial_soul_shen_dou:onBeginLevelUpAnimation(level)
	self:setPoints(level)--初始化位置
	local widgets = self._layout.vars
	local cnt = (level + 1) % NODE_CNT
	widgets['point'..cnt]:show()
	widgets['point'..cnt]:setImage(g_i3k_db.i3k_db_get_icon_path(self.ACTIVE))
	--TODO 播放特效什么的
end

function wnd_martial_soul_shen_dou:onBeginBreakUpAnimation(level)
	g_i3k_logic:ShowSuccessAnimation("break")
end

function wnd_martial_soul_shen_dou:onEndAnimation()
	self:refresh()
	self.mainCoroutine = nil
end
-----btn click ----
function wnd_martial_soul_shen_dou:onSoulBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ShenDou)
	g_i3k_ui_mgr:OpenUI(eUIID_MartialSoul)
	g_i3k_ui_mgr:RefreshUI(eUIID_MartialSoul)
end

function wnd_martial_soul_shen_dou:onStarBtn(sender)
	if g_i3k_game_context:GetLevel() >= i3k_db_martial_soul_cfg.starOpenLvl  then
		if not g_i3k_ui_mgr:GetUI(eUIID_StarDish) then
			g_i3k_ui_mgr:CloseUI(eUIID_ShenDou)
			g_i3k_ui_mgr:OpenUI(eUIID_StarDish)
			g_i3k_ui_mgr:RefreshUI(eUIID_StarDish)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1715, i3k_db_martial_soul_cfg.starOpenLvl ))
	end
end

function wnd_martial_soul_shen_dou:onSkillBtn(sender, skillId)
	local level = g_i3k_game_context:GetWeaponSoulGodStarSkillLvl(skillId)
	local cfg = i3k_db_matrail_soul_shen_dou_xing_shu[skillId][math.max(1, level)]
	if level == #i3k_db_matrail_soul_shen_dou_xing_shu[skillId] then--满级
		g_i3k_ui_mgr:OpenUI(eUIID_ShenDouSkillMax)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouSkillMax, skillId)
	elseif level == 0 then
		if next(cfg.needXinShu) then--小星术激活
			g_i3k_ui_mgr:OpenUI(eUIID_ShenDouSmallSkillActive)
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouSmallSkillActive, skillId)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_ShenDouBigSkillActive)
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouBigSkillActive, skillId)
		end
	else
		if next(cfg.needXinShu) then --小星术升级
			g_i3k_ui_mgr:OpenUI(eUIID_ShenDouSmallSkillUp)
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouSmallSkillUp, skillId)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_ShenDouBigSkillUp)
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouBigSkillUp, skillId)
		end
	end
end

function wnd_martial_soul_shen_dou:onOkBtn(sender)
	if not self.mainCoroutine then
		if self.materialEnouth then
			i3k_sbean.god_star_levelup(self.lvl)
		else
			local isBreak = self.lvl % NODE_CNT == (NODE_CNT - 1)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(isBreak and 1720 or 1719))
		end
	end
end

function wnd_martial_soul_shen_dou:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1743))
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_martial_soul_shen_dou.new()
	wnd:create(layout,...)
	return wnd
end
