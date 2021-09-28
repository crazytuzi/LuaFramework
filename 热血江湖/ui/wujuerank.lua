module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_wujueRank = i3k_class("wnd_wujueRank", ui.wnd_base)

local SKILL_COUNT = 8

function wnd_wujueRank:ctor()
	self.level = 0
	self.rank = 0
	self.skills = {}
end

function wnd_wujueRank:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
end

function wnd_wujueRank:refresh(data)
	self.level = data.level
	self.rank = data.rank
	self.skills = data.skills
	self.soul = data.hiddenSoul
	self:setBaseInfo()
	self:setProps()
	self:updateSkills()
end

function wnd_wujueRank:setBaseInfo()
	local widgets = self._layout.vars
	widgets.battle_power:setText(g_i3k_game_context:getWujueForce(self.level, self.soul, self.skills))
	local str = i3k_get_string(17709, self.level)
	widgets.level:setText(str)
	str = i3k_get_string(17710, self.rank)
	widgets.rank:setText(str)
end

function wnd_wujueRank:setProps()
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local curProp = i3k_clone(g_i3k_db.i3k_db_get_wujue_level_prop(self.level))
	local soulProps = g_i3k_db.i3k_db_get_wujue_all_soul_props(self.soul)
	local rank = self.rank
	for i, v in ipairs(curProp) do
		if soulProps[v.id] then
			v.value = soulProps[v.id] + v.value
			soulProps[v.id] = nil
		end
	end
	for k, v in pairs(soulProps) do
		table.insert(curProp, {id = k, value = v})
	end
	table.sort(curProp, function(a,b) return a.id < b.id end)
	for i, v in ipairs(curProp) do
		local prop = i3k_db_prop_id[v.id] --属性的相关信息
		local ui = require("ui/widgets/wujuephbt")()
		ui.vars.from:setText(v.value)
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(prop.icon))
		ui.vars.name:setText(prop.desc)
		scroll:addItem(ui)
	end
end

-- 更新技能
function wnd_wujueRank:updateSkills()
	local widgets = self._layout.vars
	for i = 1, SKILL_COUNT do
		local skillLevel = self.skills[i] or 0
		local showLevel = skillLevel == 0 and 1 or skillLevel
		local skillCfg = i3k_db_wujue_skill[i][showLevel]
		local uiID = g_i3k_db.i3k_db_get_wujue_skill_ui_id(i)
		if widgets["line"..uiID] then
			widgets["line"..uiID]:setImage(g_i3k_db.i3k_db_get_icon_path(skillLevel > 0 and 7881 or 7882))
		end
		widgets["groove"..uiID]:setVisible(skillLevel > 0)
		widgets["level"..uiID]:setVisible(skillLevel > 0)
		widgets["level"..uiID]:setText(skillLevel)
		widgets["skillCover"..uiID]:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.coverImg))
		widgets["icon"..uiID]:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
	end
	for i,v in ipairs(i3k_db_wujue.soulCfg) do
		local lvl = self.soul[i] or 0
		local soulCfg = i3k_db_wujue.soulCfg[i]
		local soulDataCfg = i3k_db_wujue_soul[i][lvl]
		widgets["qh_icon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(v.soulIcon))
		widgets["qh_lvl_bg"..i]:setVisible(lvl ~= 0)
		widgets["qh_lvl"..i]:setText(lvl ~= 0 and soulDataCfg.rank or "")
	end
end
function wnd_wujueRank:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_WujueRank)
end
function wnd_create(layout)
	local wnd = wnd_wujueRank.new()
	wnd:create(layout)
	return wnd
end
