------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_wujue_soul_skill = i3k_class("wnd_wujue_soul_skill",ui.wnd_base)

--潜魂状态
local State_Name = {
	[g_WUJUE_SOUL_STATE_MAX] = "圆满",
	[g_WUJUE_SOUL_STATE_UP_RANK] = "升阶",
	[g_WUJUE_SOUL_STATE_UNLOCK] = "启动",
	[g_WUJUE_SOUL_STATE_UP_STAR] = "升星",
}

local Rank_Icon = {}
for i = 0, 10 do
	Rank_Icon[i] = 5534 + i
end

local Star_icon = {
	[0] = 405,
	[1] = 409,
	[2] = 410,
	[3] = 411,
	[4] = 412,
	[5] = 413,
}

local PROP = "ui/widgets/wujuet"
local ITEM = "ui/widgets/wujuekzt"

function wnd_wujue_soul_skill:ctor()
	self.soulCfg = i3k_db_wujue.soulCfg
end

function wnd_wujue_soul_skill:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	for i,v in ipairs(self.soulCfg) do
		widgets["up"..i]:onClick(self, self.onUpSkillBtnClick, i)
		widgets["maskbtn"..i]:onClick(self, self.onMaskClick, i)
	end
end

function wnd_wujue_soul_skill:refresh(soulId)
	for i,v in ipairs(self.soulCfg) do
		self:setSkill(i)
	end
	self:onMaskClick(nil, soulId)
end

function wnd_wujue_soul_skill:setSkill(soulId)
	local widget = self._layout.vars
	local lvl = g_i3k_game_context:getWujueSoulLvl(soulId)
	local state = g_i3k_db.i3k_db_get_wujue_soul_state(soulId, lvl)
	local soulCfg = i3k_db_wujue.soulCfg[soulId]
	local soulDataCfg = i3k_db_wujue_soul[soulId][lvl]
	local nextSoulDataCfg = i3k_db_wujue_soul[soulId][lvl + 1]
	-- widget.img:setImage(g_i3k_db.i3k_db_get_icon_path(soulCfg.soulImg))
	-- widget.name:setText(i3k_get_string(soulCfg.nameId))
	widget["consumePart"..soulId]:setVisible(state ~= g_WUJUE_SOUL_STATE_MAX)
	widget["maxLevel"..soulId]:setVisible(state == g_WUJUE_SOUL_STATE_MAX)
	if state == g_WUJUE_SOUL_STATE_MAX then
		self._layout.anis["c_max"..soulId].play()
	end
	widget["maxLevel"..soulId]:setVisible(state == g_WUJUE_SOUL_STATE_MAX)
	-- widget.rank:setVisible(state ~= g_WUJUE_SOUL_STATE_UNLOCK)
	local cond = widget["cond"..soulId]
	cond:setVisible(state ~= g_WUJUE_SOUL_STATE_MAX)
	if state ~= g_WUJUE_SOUL_STATE_MAX then
		cond:setText(i3k_get_string(soulCfg.limitStrId, nextSoulDataCfg.upLvlNeedSum))
		local curLvlSum = g_i3k_game_context:getWuJueSkillsLvSum(soulCfg.upLvLimitSkillGroup)
		cond:setTextColor(g_i3k_get_cond_color(curLvlSum >= nextSoulDataCfg.upLvlNeedSum))
		self:setConsume(soulId)
	end
	local descUI = widget["desc"..soulId]
	local rankUI = widget["rank"..soulId]
	if state ~= g_WUJUE_SOUL_STATE_UNLOCK then
		local rank, star = soulDataCfg.rank, soulDataCfg.star
		rankUI:setImage(g_i3k_db.i3k_db_get_icon_path(Rank_Icon[rank]))
		descUI:show()
		local propValue = soulCfg.propsValues[rank] / 100
		if state == g_WUJUE_SOUL_STATE_MAX then
			descUI:setText(i3k_get_string(soulCfg.propMaxStrId, propValue))
		else
			local nextRankPropValue = soulCfg.propsValues[rank + 1] / 100
			descUI:setText(i3k_get_string(soulCfg.propStrId, propValue, nextRankPropValue))
		end
	else
		rankUI:setImage(g_i3k_db.i3k_db_get_icon_path(Rank_Icon[0]))
		local propValue = soulCfg.propsValues[1] / 100
		descUI:setText(i3k_get_string(soulCfg.initTxtId, propValue))
	end
	self:setProps(soulId)
	self:setStar(soulId, lvl)
	widget["upTxt"..soulId]:setText(State_Name[state])
end

function wnd_wujue_soul_skill:setStar(soulId, lvl)
	local widget = self._layout.vars
	local cfg = i3k_db_wujue_soul[soulId]
	local soulCfg = i3k_db_wujue_soul[soulId][lvl]
	if lvl == #i3k_db_wujue_soul[soulId] then
		for i = 1, 5 do
			widget["starIcon"..soulId..i]:show()
		end
	else
		for i = 1, 5 do
			widget["starIcon"..soulId..i]:setVisible(soulCfg and i <= soulCfg.star)
		end
	end
end

function wnd_wujue_soul_skill:setProps(soulId)
	local lvl = g_i3k_game_context:getWujueSoulLvl(soulId)
	local cfg = i3k_db_wujue_soul[soulId][lvl]
	local nextCfg = i3k_db_wujue_soul[soulId][lvl+1]
	local scroll = self._layout.vars["propScroll"..soulId]
	scroll:removeAllChildren()
	if not cfg then
		for i,v in ipairs(nextCfg.props) do
			local ui = require(PROP)()
			local vars = ui.vars
			scroll:addItem(ui)
			vars.from:setText(0)
			vars.to:setText(v.value)
			local prop = i3k_db_prop_id[v.id] --属性的相关信息
			vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(prop.icon))
			vars.name:setText(prop.desc)
		end
	else
		for i,v in ipairs(cfg.props) do
			local ui = require(PROP)()
			local vars = ui.vars
			scroll:addItem(ui)
			vars.from:setText(v.value)
			if nextCfg then
				vars.to:setText(nextCfg.props[i].value - v.value)
			else
				vars.to:hide()
				vars.arrow:hide()
			end
			local prop = i3k_db_prop_id[v.id] --属性的相关信息
			vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(prop.icon))
			vars.name:setText(prop.desc)
		end
	end
end

function wnd_wujue_soul_skill:setConsumes()
	for i,v in ipairs(self.soulCfg) do
		self:setConsume(i)
	end
end

local BG_ICON_ID = {
	[1] = 9819,
	[2] = 9818,
}
function wnd_wujue_soul_skill:setConsume(soulId)
	local scroll = self._layout.vars["consumeScroll"..soulId]
	scroll:removeAllChildren()
	self["isMaterialEnough"..soulId] = true
	local lvl = g_i3k_game_context:getWujueSoulLvl(soulId)
	local cfg = i3k_db_wujue_soul[soulId][lvl + 1]
	if not cfg then return end --满级了
	local consumes = i3k_db_wujue_soul[soulId][lvl + 1].needItems
	for i,v in ipairs(consumes) do
		local ui = require(ITEM)()
		local vars = ui.vars
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id))
		vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
		vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		if v.id == g_BASE_ITEM_DIAMOND or v.id == g_BASE_ITEM_COIN or v.id == g_BASE_ITEM_BOOK_ENERGY then
			vars.item_count:setText(v.count)
		else
			vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .."/".. v.count)
		end
		if self["isMaterialEnough"..soulId] then
			self["isMaterialEnough"..soulId] = g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= v.count
		end
		vars.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= (v.count)))
		vars.bt:onClick(self, self.onItemTips, v.id)
		vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(BG_ICON_ID[soulId]))
		scroll:addItem(ui)
	end
end

function wnd_wujue_soul_skill:onUpSkillBtnClick(sender, soulId)
	local lvl = g_i3k_game_context:getWujueSoulLvl(soulId)
	local soulCfg = i3k_db_wujue.soulCfg[soulId]
	if self["isMaterialEnough"..soulId] then
		local curLvlSum = g_i3k_game_context:getWuJueSkillsLvSum(soulCfg.upLvLimitSkillGroup)
		if not i3k_db_wujue_soul[soulId][lvl + 1] then return end--点太快了
		local soulDataCfg = i3k_db_wujue_soul[soulId][lvl + 1]
		if soulDataCfg.upLvlNeedSum > curLvlSum then
			g_i3k_ui_mgr:PopupTipMessage("前提条件不满足")
		else
			i3k_sbean.wujue_soul_up_lvl(soulId)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end
end

function wnd_wujue_soul_skill:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_wujue_soul_skill:onMaskClick(sender, soulId)
	local widget = self._layout.vars
	for i,v in ipairs(self.soulCfg) do
		widget["mask"..i]:setVisible(i ~= soulId)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_wujue_soul_skill.new()
	wnd:create(layout,...)
	return wnd
end
