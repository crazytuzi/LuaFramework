------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/profile')
------------------------------------------------------
wnd_xinjue = i3k_class("wnd_xinjue",ui.wnd_profile)

local PROP_WIDGET = "ui/widgets/xinjuexxt2"
local MATERIAL_WIDGET = "ui/widgets/xinjuexxt1"
local PROPS_COUNT = 7
local TUPO_PROP_WIDGET = "ui/widgets/xinjuetpt1"
local MAX_PROP_WIDGET = "ui/widgets/xinjuemaxt1"
local TUPO_SKILL_WIDGET = "ui/widgets/xinjuetpt2"

function wnd_xinjue:ctor()
	self._children = {}
	self._props = {}
	self._propsNew = {}
	self._progressState = false
	self._timeCounter = 0
end

function wnd_xinjue:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.role_btn:onClick(self, self.onRoleBtn)
	widgets.roleTitle_btn:onClick(self, self.onRoleTitleBtn)
	widgets.reqBtn:onClick(self, self.onReputationBtn)
	widgets.xiuxin_btn:onClick(self, self.onXiuxinBtn)
	widgets.tupo_btn:onClick(self, self.onTupoBtn)
	widgets.xinjueBtn:stateToPressed()
	-- widgets.revolve:onTouchEvent(self, self.onRotateBtn, true)
	widgets.help_btn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(1428))
	end)
	self.hero_module = widgets.hero_module
	self.revolve = widgets.revolve
	self:initSkill()
	self:refresh()
end

function wnd_xinjue:onShow()
	self:updateRecover()
	self._layout.vars.xj_red:setVisible(g_i3k_game_context:checkXinjueRedpoint())
	self.hero_module:setRotation(math.pi/2,-0.3)
	self.hero_module:pushActionList("xinjue",1)
	self.hero_module:pushActionList("xinjueloop",-1)
	self.hero_module:playActionList()
end

function wnd_xinjue:onUpdate(dTime)
	self:updateProgressBar(dTime)
end

local totalTime = 1.5 -- 每次进度条在N秒内完成增长动画
function wnd_xinjue:updateProgressBar(dTime)
	if self._progressState then
		self._timeCounter = self._timeCounter + dTime
		local widgets = self._layout.vars
		local children = widgets.props_content:getAllChildren()

		if self._timeCounter > totalTime then
			self._timeCounter = 0
			for k, v in ipairs(self._propsNew) do
				self._props[k] = v -- 更新保存的旧属性
			end
			self._progressState = false
		end
		for k, v in ipairs(children) do
			local cur = self._props[k].cur
			local now = self._propsNew[k].cur
			local max = self._props[k].max
			local showValue = cur + (now - cur)/totalTime * self._timeCounter
			local bar = v.vars.prop_bar
			v.vars.prop_bar_text:setText(math.floor(showValue)..'/'..max)
			bar:setPercent(100 * showValue / max)
		end

	end
end

function wnd_xinjue:refresh()
	local _,roleLevel = g_i3k_game_context:GetRoleDetail()
	local xinjueGrade = g_i3k_game_context:getXinjueGrade()
	self._layout.vars.level_txt:setText(i3k_db_xinjue_level[xinjueGrade].des)

	local isAllPropMax = true
	local props = g_i3k_game_context:getXinjueProps()
	for i, v in ipairs(i3k_db_xinjue_level[xinjueGrade].props) do
		if not(props[v.id] and props[v.id] == v.max) then
			isAllPropMax = false
			break
		end
	end
	if not isAllPropMax then
		self:showXiuxin()
	elseif xinjueGrade == #i3k_db_xinjue_level then
		self:showMax()
	else
		self:showTupo()
	end
	self:refreshSkill()
	self._layout.vars.xj_red:setVisible(g_i3k_game_context:checkXinjueRedpoint())
end


function wnd_xinjue:initSkill()
	local widgets = self._layout.vars
	for k,v in ipairs(i3k_db_xinjue_skills) do
		if widgets['skill_img'..k] then
			widgets['skill_img'..k]:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
			widgets['skill_btn'..k]:onClick(self,self.onSkillBtn, k)
		end
	end
end

function wnd_xinjue:refreshSkill()
	local xinjueGrade = g_i3k_game_context:getXinjueGrade()
	local widgets = self._layout.vars
	for k,v in ipairs(i3k_db_xinjue_skills) do
		if widgets['skill_img'..k] then
			local active = v.needLevel <= xinjueGrade and 'enable' or 'disable'
			widgets['skill_img'..k][active](widgets['skill_img'..k])
		end
	end
end

function wnd_xinjue:showXiuxin()
	local _,roleLevel = g_i3k_game_context:GetRoleDetail()
	local xinjueGrade = g_i3k_game_context:getXinjueGrade()
	local widgets = self._layout.vars
	local xinjueProp = g_i3k_game_context:getXinjueProps()
	local fightpower = g_i3k_db.i3k_db_get_battle_power(xinjueProp)
	widgets.xiuxin:setVisible(true)
	widgets.max:setVisible(false)
	widgets.tupo:setVisible(false)
	widgets.xiuxin_zhanli:setText(tostring(fightpower))
	local cfg = i3k_db_xinjue_level[xinjueGrade]
	local props = g_i3k_game_context:getXinjueProps()
	local propsWidgets = widgets.props_content:addChildWithCount(PROP_WIDGET, 1, PROPS_COUNT, true)
	local matsWidgets = widgets.material_content:addChildWithCount(MATERIAL_WIDGET, 1, #cfg.fixConsume, true)

	for k,v in ipairs(propsWidgets) do
		local prop_cfg = cfg.props[k]
		local prop_value = props[prop_cfg.id] or 0
		v.propId = prop_cfg.id
		v.vars.prop_name:setText(g_i3k_db.i3k_db_get_property_name(prop_cfg.id)..":")
		v.vars.propIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(prop_cfg.id)))
		v.vars.prop_bar_text:setText(prop_value..'/'..prop_cfg.max)
		v.vars.prop_bar:setPercent(100 * prop_value / prop_cfg.max)
		if not self._props[k] then
			self._props[k] = {cur = prop_value, max = prop_cfg.max} -- 存一份
		else
			self._props[k].max = prop_cfg.max
		end
		self._propsNew[k] = {cur = prop_value, max = prop_cfg.max} -- 存一份
		local inc = prop_value - (self._props[k] and self._props[k].cur or 0)
		if inc > 0 and self._props[k].cul ~= 0 then
			v.vars.prop_inc:setText('+'..inc)
			v.vars.prop_inc:setVisible(true)
			v.anis.c_shenji:stop()
			local tempFunc = function()
				v.vars.prop_inc:setVisible(false)
			end
			v.anis.c_shenji.play(tempFunc)
		end
	end
	self._progressState = true
	for k,v in pairs(matsWidgets) do
		local consume = cfg.fixConsume[k]
		self:setItem(v,consume.id, consume.count)
	end
end

function wnd_xinjue:showTupo()
	local _,roleLevel = g_i3k_game_context:GetRoleDetail()
	local xinjueGrade = g_i3k_game_context:getXinjueGrade()
	local widgets = self._layout.vars
	widgets.xiuxin:setVisible(false)
	widgets.max:setVisible(false)
	widgets.tupo:setVisible(true)
	local cfg = i3k_db_xinjue_level[xinjueGrade]
	local nextcfg = i3k_db_xinjue_level[xinjueGrade + 1]
	widgets.nextLevel:setText(nextcfg.des)
	widgets.levelLimit:setText(nextcfg.needLevel)
	widgets.levelLimit:setTextColor(g_i3k_get_cond_color(roleLevel >= nextcfg.needLevel))
	widgets.successRate:setText((nextcfg.successRate / 100)..'%')
	local successNum = nextcfg.successNum - g_i3k_game_context:getXinjueBreakTimes()
	widgets.successTime:setText(successNum == 1 and i3k_get_string(1430) or i3k_get_string(1429, successNum))
	local propsWidgets = widgets.tupo_content:addChildWithCount(TUPO_PROP_WIDGET, 1, PROPS_COUNT, true)
	local matsWidgets = widgets.tupo_mats:addChildWithCount(MATERIAL_WIDGET, 1, #nextcfg.breakConsume, true)
	for k, v in ipairs(propsWidgets) do
		v.vars.name:setText(i3k_get_string(1431, g_i3k_db.i3k_db_get_property_name(cfg.props[k].id)))
		v.vars.old:setText(tostring(cfg.props[k].max))
		v.vars.next:setText(nextcfg.props[k].max)
		v.vars.next:setTextColor(g_COLOR_VALUE_GREEN)
	end
	for k, v in ipairs(matsWidgets) do
		local consume = nextcfg.breakConsume[k]
		self:setItem(v, consume.id, consume.count)
	end
	for i, v in ipairs(i3k_db_xinjue_skills) do
		if v.needLevel == xinjueGrade + 1 then
			local skill = require(TUPO_SKILL_WIDGET)()
			skill.vars.des:setText(i3k_get_string(1432, v.name))
			widgets.tupo_content:addItem(skill)
			break
		end
	end
end

function wnd_xinjue:showMax()
	local _,roleLevel = g_i3k_game_context:GetRoleDetail()
	local widgets = self._layout.vars
	widgets.xiuxin:setVisible(false)
	widgets.max:setVisible(true)
	widgets.tupo:setVisible(false)
	local xinjueProp = g_i3k_game_context:getXinjueProps()
	local fightpower = g_i3k_db.i3k_db_get_battle_power(xinjueProp)
	widgets.max_zhanli:setText(fightpower)
	local props = widgets.max_content:addChildWithCount(MAX_PROP_WIDGET, 1, PROPS_COUNT, true)
	local props_cfg = i3k_db_xinjue_level[#i3k_db_xinjue_level].props
	for k, v in ipairs(props) do
		v.vars.name:setText(g_i3k_db.i3k_db_get_property_name(props_cfg[k].id))
		v.vars.value:setText(tostring(props_cfg[k].max))
	end
end

function wnd_xinjue:setItem(v, id, count)
	v.vars.mat_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	v.vars.mat_img:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	local have = g_i3k_game_context:GetCommonItemCanUseCount(id)
	if math.abs(id) == g_BASE_ITEM_COIN then
		v.vars.mat_count:setText(tostring(count))
	else
		v.vars.mat_count:setText(have..'/'..count)
	end
	v.vars.mat_count:setTextColor(g_i3k_get_cond_color(have >= count))
	v.vars.mat_btn:onClick(self, function()
		g_i3k_ui_mgr:ShowCommonItemInfo(id)
	end)
end

---------------------------------------
function wnd_xinjue:onSkillBtn(sender, btnId)
	g_i3k_ui_mgr:OpenUI(eUIID_XinJueTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_XinJueTips, btnId)
end

function wnd_xinjue:onXiuxinBtn()
	if i3k_db.i3k_db_check_xinjue_consume_fix() then
		i3k_sbean.soulspell_props()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1433))
	end
end

function wnd_xinjue:onTupoBtn(sender)
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < i3k_db_xinjue_level[g_i3k_game_context:getXinjueGrade() + 1].needLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1434))
		return
	end
	if not g_i3k_db.i3k_db_check_xinjue_consume_break() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1435))
		return
	end
	i3k_sbean.soulspell_break()
end

function wnd_xinjue:onRoleBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_XinJue)
	g_i3k_logic:OpenRoleLyUI()
end

function wnd_xinjue:onRoleTitleBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_XinJue)
	g_i3k_logic:OpenRoleTitleUI()
end

function wnd_xinjue:onReputationBtn(sender)
	local openLevel = g_i3k_db.i3k_db_power_rep_get_open_min_level()
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1436, openLevel))
		return
	end
	g_i3k_ui_mgr:CloseUI(eUIID_XinJue)
	g_i3k_logic:OpenReputationUI()
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_xinjue.new()
	wnd:create(layout,...)
	return wnd
end
