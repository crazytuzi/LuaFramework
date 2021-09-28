
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_starDishRank = i3k_class("wnd_starDishRank",ui.wnd_base)

local PointBg	= 4780;
local starPoint	= "ui/widgets/xingyaot1"
local propArg5	= "ui/widgets/xingyaosxt5"
local starPart 	= "ui/widgets/xingyaot2"
local propArg4	= "ui/widgets/phbxyt"
local starX = i3k_db_martial_soul_cfg.starLength
local starY = i3k_db_martial_soul_cfg.starWide

function wnd_starDishRank:ctor()
	self.info = nil
end

function wnd_starDishRank:configure()
	local widgets = self._layout.vars
	widgets.xingyaoBtn:stateToPressed(true)
	widgets.wuhunBtn:onClick(self, self.openWeaponSoul)
	widgets.shendouBtn:onClick(self, self.onShenDouBtnClick)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_starDishRank:refresh(info)
	self.info = info
	local widgets = self._layout.vars


	widgets.starScroll:removeAllChildren()
	widgets.starScroll:setBounceEnabled(false)
	local cfg = i3k_db_martial_soul_cfg;
	local starId = info.curStar
	local all_layer = widgets.starScroll:addItemAndChild(starPoint, starX, starX*starY)
	for  i=1, starX*starY do
		local widget = all_layer[i].vars
		widget.poinText:hide()
		widget.point:hide()
		widget.pointBg:setImage(g_i3k_db.i3k_db_get_icon_path(PointBg))
	end

	local star = i3k_db_star_soul[starId]
	if star then
		for i,e in ipairs(star.starDisk) do
			local widget = all_layer[e + 1].vars
			local color = i3k_db_star_soul_colored_color[star.color[i]].iconID;
			widget.point:show():setImage(g_i3k_db.i3k_db_get_icon_path(color))
		end
	end

	local power = math.modf(g_i3k_db.i3k_db_get_battle_power(g_i3k_game_context:GetStarPropData(starId,info.curGradeCount, info.godStar.skills[g_SHEN_DOU_SKILL_STAR_ID] or 0)))
	widgets.powerText:setText(power)
	local rankCfg = i3k_db_star_soul[starId]
	widgets.starName:setText(rankCfg.name)

	if rankCfg.bgIcon > 0 then
		widgets.starBg:show():setImage(g_i3k_db.i3k_db_get_icon_path(rankCfg.bgIcon))
	else
		widgets.starBg:hide();
	end
	local addition = i3k_db_martial_soul_cfg.addition[info.curGradeCount] or 0;
	local ratio = g_i3k_db.i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_STAR_ID, self.info.godStar.skills[g_SHEN_DOU_SKILL_STAR_ID] or 0)
	for _, e in ipairs(rankCfg.propTb) do
		if e.propID ~= 0 then
			local node = require(propArg4)()
			local icon = g_i3k_db.i3k_db_get_property_icon(e.propID)
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			node.vars.name:setText(g_i3k_db.i3k_db_get_property_name(e.propID))
			node.vars.value:setText(i3k_get_prop_show(e.propID, math.modf(e.propValue * (1 + addition) * (1 + ratio))))
			widgets.propScroll:addItem(node)
		end
	end

	if rankCfg.specialpropID and rankCfg.specialpropID ~= 0 then
		local selecticon = require(propArg5)()
		selecticon.vars.name:setText(rankCfg.specialDes)
		selecticon.vars.name:setTextColor(g_i3k_get_green_color());
		widgets.propScroll:addItem(selecticon)
	end

	local part = info.parts
	for i=1, 8 do
		local partBtn = "part"..i;
		local partdata = part[i].balls;
		local logsBar = require(starPart)()
		widgets[partBtn]:addChild(logsBar)
		local starName = i3k_db_martial_soul_part[i].starName;
		logsBar.vars.wordTxt:setImage(g_i3k_db.i3k_db_get_icon_path(starName))
		logsBar.vars.rootGird:setSizePercent(1.211, 1.211)
		logsBar.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(PartBg1))
		for n = 1 , 9 do
			logsBar.vars["x"..(n)]:hide();
		end
		for k,v in pairs(partdata) do
			logsBar.vars["x"..(k+1)]:show()
			local color = i3k_db_star_soul_colored_color[v].partIcon;
			logsBar.vars["x"..(k+1)]:setImage(g_i3k_db.i3k_db_get_icon_path(color))
		end
	end
end

function wnd_starDishRank:openWeaponSoul()
	g_i3k_ui_mgr:OpenUI(eUIID_RankListWeaponSoul)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListWeaponSoul, self.info)
	self:onCloseUI()
end

function wnd_starDishRank:onShenDouBtnClick(sender)
	if self.info.godStar.curLevel == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1733))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_ShenDouRank)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouRank, self.info)
		self:onCloseUI()
	end
end
function wnd_create(layout, ...)
	local wnd = wnd_starDishRank.new()
	wnd:create(layout, ...)
	return wnd;
end

