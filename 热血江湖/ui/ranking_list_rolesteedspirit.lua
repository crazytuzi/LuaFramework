-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/steedRankBase")

-------------------------------------------------------
local WIDGET_ZQQZT3 = "ui/widgets/zqqzt3"

wnd_ranking_list_RoleSteedSpirit = i3k_class("wnd_ranking_list_RoleSteedSpirit",ui.wnd_steedRankBase)

function wnd_ranking_list_RoleSteedSpirit:ctor()
	self._info = nil
	self._id = nil
	self._showIDs = nil
	self._tag = nil
	self._masters = nil
	self._steedSpirit = nil
	self._steedEquip = nil
	self._rank = 0
end

function wnd_ranking_list_RoleSteedSpirit:configure()
	-- 重写父类
	ui.wnd_steedRankBase.configure(self)	

	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.mashu = widgets.mashu
	self.steedJd = widgets.steedJd
	self.steedSpiritRoot = widgets.steedSpiritRoot


	widgets.steedSpiritBtn:stateToPressed()

	self.spiritWidgets = {}
	self.spiritWidgets.spiritModule = widgets.steedSpiritModel
	self.spiritWidgets.steedSpiritPower = widgets.steedSpiritPower
	self.spiritWidgets.spiritRankIcon = widgets.spiritRankIcon
	self.spiritWidgets.spiritPropScroll = widgets.spiritPropScroll
	self.spiritWidgets.starIcons = self:initSpiritStar(widgets)
	self.spiritWidgets.skillWidgets = self:initSpiritSkillWidget(widgets)
end

function wnd_ranking_list_RoleSteedSpirit:initSpiritStar(widgets)
	local starNodes = {}
	for i = 1, i3k_db_steed_fight_base.rankStarCount do
		starNodes[i] = widgets["starIcon"..i]
	end
	return starNodes
end

function wnd_ranking_list_RoleSteedSpirit:initSpiritSkillWidget(widgets)
	local skillNodes = {}
	for i = 1, 2 do
		skillNodes[i] = {
			skillIcon = widgets["skillIcon"..i],
			skillBtn = widgets["skillBtn"..i],
			skillName = widgets["skillName"..i],
			skillLvl = widgets["skillLvl"..i],
			skillFlicker = widgets["skillFlicker"..i], -- 闪烁
			skillRed = widgets["skillRed"..i],
		}
	end
	return skillNodes
end

function wnd_ranking_list_RoleSteedSpirit:refresh(data)
	-- 重写父类
	ui.wnd_steedRankBase.setSteedRankBaseData(self, data)

	local widgets = self._layout.vars
	self._id = data.id
	self._info = data.info
	self._showIDs = data.showIDs
	self._masters = data.masters
	self._steedSpirit = data.steedSpirit
	self._steedEquip = data.steedEquip

	widgets.mashu:hide()
	widgets.steedJd:hide()
	if self._masters and (next(self._masters) ~= nil or self._steedSpirit.star > 0) then
		widgets.steedFightBtn:show();
	else
		widgets.steedFightBtn:hide();
	end
	widgets.steedSpiritBtn:setVisible(self._steedSpirit.star > 0)
	widgets.steedEquipBtn:setVisible(data.roleOverview.level >= i3k_db_steed_equip_cfg.openLevel)
	widgets.steedSpiritRoot:show()

	self:loadSpiritStarInfo()
	self:loadPropScroll()
	self:loadSpiritSkillsInfo()
	self:loadSteedSpiritModel()
end

function wnd_ranking_list_RoleSteedSpirit:loadSpiritStarInfo()
	local spiritDB = i3k_db_steed_fight_spirit
	local star = self._steedSpirit.star
	self._rank = math.modf(star / i3k_db_steed_fight_base.rankStarCount)
	local rankIconID = i3k_db_steed_fight_spirit_rank[self._rank + 1].rankIcon
	self.spiritWidgets.spiritRankIcon:setImage(g_i3k_db.g_i3k_db.i3k_db_get_icon_path(rankIconID))
	for i, e in ipairs(self.spiritWidgets.starIcons) do
		e:setVisible(star == #spiritDB or i <= star % i3k_db_steed_fight_base.rankStarCount)
	end
end

function wnd_ranking_list_RoleSteedSpirit:loadPropScroll()
	local spiritDB = i3k_db_steed_fight_spirit
	local star = self._steedSpirit.star
	local nowCfg = spiritDB[star] and spiritDB[star].propTb or {}
	self.spiritWidgets.spiritPropScroll:removeAllChildren()
	local propData = {}
	for _, e in ipairs(nowCfg) do
		if e.propID ~= 0 then
		    propData[e.propID] = (propData[e.propID] or 0) + e.propValue
		end
	end
	self.spiritWidgets.steedSpiritPower:setText(g_i3k_db.i3k_db_get_battle_power(propData, true))
	for i, v in ipairs(nowCfg) do --下一级的数据
		if v.propID ~= 0 then
			local node = require(WIDGET_ZQQZT3)()
			local widget = node.vars
			local propID = g_i3k_game_context:dealXingHunPropId(v.propID, self._steedSpirit.amuletId)
			local icon = g_i3k_db.i3k_db_get_property_icon(propID)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(propID))
			widget.propertyValue:setText("+"..i3k_get_prop_show(propID, nowCfg[i].propValue or 0))
			widget.differValue:setVisible(false)
			self.spiritWidgets.spiritPropScroll:addItem(node)
		end
	end
end

function wnd_ranking_list_RoleSteedSpirit:loadSpiritSkillsInfo()
	local skills = self:sortSkills(self._steedSpirit.skills)
	local spiritRank = self._rank
	for i, e in ipairs(skills) do
		local info = e.info
		local dbCfg = i3k_db_steed_fight_spirit_skill[info.id]
		local widget = self.spiritWidgets.skillWidgets[i]
		local showLvl = info.level == 0 and 1 or info.level
		local desc =  info.level <= 0 and i3k_get_string(1298) or i3k_get_string(467, info.level)
		widget.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(dbCfg[showLvl].skillIconID))
		widget.skillName:setText(dbCfg[showLvl].skillName)
		widget.skillLvl:setText(desc)
	end
end

-- 排序
function wnd_ranking_list_RoleSteedSpirit:sortSkills(skills)
	local skillsInfo = {}
	if self._steedSpirit then
		for k, v in pairs(i3k_db_steed_fight_spirit_skill) do
			if self._steedSpirit.skills and self._steedSpirit.skills[k] then
				skillsInfo[k] = {id = self._steedSpirit.skills[k].id, level = self._steedSpirit.skills[k].level}
			else
				skillsInfo[k] = {id = k, level = 0}
			end
		end
	end	
	local tmp = {}
	for k, v in ipairs(skillsInfo) do
		table.insert(tmp, {id = k, info = v})
	end
	table.sort(tmp, function (a,b)
		return a.id < b.id
	end)
	return tmp
end

function wnd_ranking_list_RoleSteedSpirit:loadSteedSpiritModel()
	local modelID = i3k_db_steed_fight_spirit_show[self._steedSpirit.curShowID].UIModelID
	local mcfg = i3k_db_models[modelID];
	if mcfg then
		self.spiritWidgets.spiritModule:setSprite(mcfg.path);
		self.spiritWidgets.spiritModule:setSprSize(mcfg.uiscale);
		self.spiritWidgets.spiritModule:playAction(i3k_db_steed_fight_base.defaultAction)
	end
end

function wnd_create(layout)
	local wnd = wnd_ranking_list_RoleSteedSpirit.new()
	wnd:create(layout)
	return wnd
end
