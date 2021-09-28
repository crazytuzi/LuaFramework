module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battleNPChp = i3k_class("wnd_battleNPChp", ui.wnd_base)

function wnd_battleNPChp:ctor()

end

function wnd_battleNPChp:configure()
    local monster = {}--------小怪
	monster.root = self._layout.vars.xiaoguai--------小怪__控制显隐
	monster.nameLabel = self._layout.vars.xiaoname--------小怪名字Label
	monster.bloodBar = self._layout.vars.xiaoblood--------小怪血量LoadingBar
	monster.levelLabel = self._layout.vars.levellabel ------小怪等级Label
	-- monster.root:hide()
    self._widgets = {}
	self._widgets.monster = monster
end

function wnd_battleNPChp:refresh()

end

function wnd_battleNPChp:updateTargetMonster(monsterId, curHp, maxHp, buffs, isPet, showName, isSummoned)-- InvokeUIFunction
	local monster = self._widgets.monster
    if isPet then -- temporary set
        local monsterName = i3k_db_fightpet[monsterId].name
        monster.nameLabel:setText(monsterName)
		monster.levelLabel:hide()
	elseif isSummoned then
		local monsterName = i3k_db_summoned[monsterId].name
        monster.nameLabel:setText(monsterName)
		monster.levelLabel:hide()
    else
    	local monsterName = g_i3k_db.i3k_db_get_monster_sect_name(monsterId, showName)
    	monster.nameLabel:setText(monsterName)
		local level = i3k_db_monsters[monsterId].level
		monster.levelLabel:setText(level);
		monster.levelLabel:setTextColor(g_i3k_db.i3k_db_get_monster_level_color(level))
    end
    self:updateTargetHp(curHp, maxHp)
	
end

function wnd_battleNPChp:updateTargetHp(curHp, maxHp, isNpc)
	local monster = self._widgets.monster
	monster.bloodBar:setPercent(curHp/maxHp * 100)
end

function wnd_battleNPChp:onHide()
	g_i3k_game_context:SetSelectName()
	g_i3k_game_context:SetSelectNpcId()
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleNPChp.new();
		wnd:create(layout);
	return wnd;
end
