-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arenaEnemyLineup = i3k_class("wnd_arenaEnemyLineup", ui.wnd_base)

local star_icon = {405,409,410,411,412,413}

function wnd_arenaEnemyLineup:ctor()

end

function wnd_arenaEnemyLineup:configure()

	self._layout.vars.bgBtn:onClick(self, self.onCloseUI)

	local pet1 = {}
	local icon2 = self._layout.vars.icon2
	local lvl2 = self._layout.vars.lvlLabel2
	local star1 = self._layout.vars.star1
	pet1.icon = icon2
	pet1.lvl = lvl2
	pet1.star = star1

	local pet2 = {}
	local icon3 = self._layout.vars.icon3
	local lvl3 = self._layout.vars.lvlLabel3
	local star2 = self._layout.vars.star2
	pet2.icon = icon3
	pet2.lvl = lvl3
	pet2.star = star2

	local pet3 = {}
	local icon4 = self._layout.vars.icon4
	local lvl4 = self._layout.vars.lvlLabel4
	local star3 = self._layout.vars.star3
	pet3.icon = icon4
	pet3.lvl = lvl4
	pet3.star = star3
	self._mercenaryTable = {pet1, pet2, pet3}

	self._root = {self._layout.vars.pet1Root, self._layout.vars.pet2Root, self._layout.vars.pet3Root}
	self.hiedDesc = self._layout.vars.hiedDesc
end

function wnd_arenaEnemyLineup:onShow()

end

function wnd_arenaEnemyLineup:refresh(enemy, pets, sectData, hideDefence)
	local petsTable = {}
	local petsPower = 0
	for k,v in pairs(pets) do
		if v.id ~= 0 then
			table.insert(petsTable, v)
		end
		petsPower = petsPower + v.fightPower
	end
	if enemy then
		self._layout.vars.iconType:setImage(g_i3k_get_head_bg_path(enemy.bwType, enemy.headBorder))
		self._layout.vars.zhiyeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[enemy.type].classImg))
		self._layout.vars.name:setText(enemy.name)
		local icon = self._layout.vars.icon1
		local lvl = self._layout.vars.lvlLabel1
		if icon and lvl then
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(enemy.headIcon, g_i3k_db.eHeadShapeCircie);
			if hicon and hicon > 0 then
				icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
			end
			lvl:setText(enemy.level)
		end
		self._layout.vars.powerLabel:setText(enemy.fightPower + petsPower)
	end
	for i,v in pairs(self._root) do
		v:hide()
	end
	if petsTable then
		for i,v in pairs(petsTable) do
			self._root[i]:show()
			local iconId = g_i3k_db.i3k_db_get_head_icon_id(v.id)
			self._mercenaryTable[i].icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
			self._mercenaryTable[i].lvl:setText(v.level)
			self._mercenaryTable[i].star:setImage(i3k_db_icons[star_icon[v.star+1]].path)
			self._layout.vars["bg"..i]:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[v.id].rank))
		end
	end
	if sectData.sectId~=0 then
		self._layout.vars.sectName:setText(sectData.sectName)
		if sectData.personalMsg~="" then
			self._layout.vars.personalMsg:setText(sectData.personalMsg)
		end
	end
	self.hiedDesc:setText(i3k_get_string(15359))
	self.hiedDesc:setVisible(hideDefence == 1)--(#petsTable == 0 and #pets ~= 0)
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaEnemyLineup.new();
		wnd:create(layout, ...);
	return wnd;
end
