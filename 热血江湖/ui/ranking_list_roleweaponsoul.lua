-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_ranking_list_weapon_soul = i3k_class("wnd_ranking_list_weapon_soul",ui.wnd_base)

local Proptipst = "ui/widgets/wuhuntipst"

function wnd_ranking_list_weapon_soul:ctor()
	self._partWidgets = {}
	self.info = nil
end

function wnd_ranking_list_weapon_soul:configure()
	local widgets = self._layout.vars
	self:initPartWidget(widgets)
	self.battle_power = widgets.battle_power
	self.gradeDesc = widgets.gradeDesc
	self.soulModule = widgets.soulModule
	self.propScroll = widgets.propScroll
	
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.wuhunBtn:stateToPressed(true)
	widgets.xingyaoBtn:onClick(self, self.openStarDish)
	widgets.shendouBtn:onClick(self, self.onShenDouBtnClick)
end

function wnd_ranking_list_weapon_soul:initPartWidget(widgets)
	for i=1, 8 do
		local partIcon = "partIcon"..i
		local partLvl = "partLvl"..i
		
		self._partWidgets[i] = {
			partIcon	= widgets[partIcon],
			partLvl		= widgets[partLvl],
		}
	end
end

function wnd_ranking_list_weapon_soul:refresh(info)
	self.info = info
	local name = i3k_db_martial_soul_rank[info.grade].rankName
	self.gradeDesc:setText(name)
	self.battle_power:setText(g_i3k_db.i3k_db_get_battle_power(g_i3k_game_context:GetWeaponSoulPropData(info.parts, info.grade, self.info.godStar.skills[g_SHEN_DOU_SKILL_MARTIAL_ID] or 0)))
	local mcfg = i3k_db_models[i3k_db_martial_soul_display[info.curShow].modelID];
	if mcfg then
		self.soulModule:setSprite(mcfg.path);
		self.soulModule:setSprSize(mcfg.uiscale);
		self.soulModule:playAction("show");
		self.soulModule:setColor( tonumber(mcfg.color, 16) or 0xFFFFFFF);
	end
	self:loadPartData(info.parts)
	self:loadPropList(info.parts, info.grade)
	
end

function wnd_ranking_list_weapon_soul:loadPartData(partsInfo)
	for i, e in ipairs(i3k_db_martial_soul_part) do
		local widget = self._partWidgets[i]
		local lvl = partsInfo[i].level
		widget.partIcon:setImage(g_i3k_db.i3k_db_get_icon_path(e.partIcon))
		widget.partLvl:setText(lvl)
	end
end

function wnd_ranking_list_weapon_soul:loadPropList(partsInfo, grade)
	self.propScroll:removeAllChildren()
	local ratio = g_i3k_db.i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_MARTIAL_ID, self.info.godStar.skills[g_SHEN_DOU_SKILL_MARTIAL_ID] or 0)
	for _, e in ipairs(self:sortProp(partsInfo, grade)) do
		local heroProperty = require(Proptipst)()
		local widget = heroProperty.vars
		local icon = g_i3k_db.i3k_db_get_property_icon(e.id)
		widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		widget.btn:onTouchEvent(self,self.showTips, e.id)
		widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(e.id))
		widget.propertyValue:setText(i3k_get_prop_show(e.id, math.modf(e.value * (1 + ratio))))
		self.propScroll:addItem(heroProperty)	
	end
end

function wnd_ranking_list_weapon_soul:sortProp(partsInfo, grade)
	local propList = {} --排序
	for k, v in pairs(g_i3k_game_context:GetWeaponSoulPropData(partsInfo, grade)) do
		table.insert(propList, {id = k, value = v})
	end
	table.sort(propList, function (a,b)
		return a.id < b.id
	end)
	return propList
end

function wnd_ranking_list_weapon_soul:openStarDish()
	if self.info.curStar > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_RankStarDish)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankStarDish, self.info)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1148))
	end
end

function wnd_ranking_list_weapon_soul:onShenDouBtnClick(sender)
	if self.info.godStar.curLevel == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1733))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_ShenDouRank)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouRank, self.info)
		self:onCloseUI()
	end
end
function wnd_create(layout)
	local wnd = wnd_ranking_list_weapon_soul.new()
	wnd:create(layout)
	return wnd
end
	
