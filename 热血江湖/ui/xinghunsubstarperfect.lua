module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_xinghun_sub_star_perfect = i3k_class("wnd_xinghun_sub_star_perfect", ui.wnd_base)

function wnd_xinghun_sub_star_perfect:ctor()

end

function wnd_xinghun_sub_star_perfect:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)

	self.name = widgets.name
	self.fightPower = widgets.fightPower
	self.level = widgets.level
	self.effect = widgets.effect
end

function wnd_xinghun_sub_star_perfect:refresh(id,level)
	self.effect:removeAllChildren()

	local cfg = g_i3k_db.xinghun_getSubStarConfig(id, level)
	if cfg then
		self.name:setText(cfg.name)
		self.level:setText("等级" .. level .. "/" .. g_i3k_db.xinghun_getSubStarMaxLevel())

		self:setFightPower(cfg.props)
		local itemTb = g_i3k_game_context:xingHunSetProps(cfg.props)
		for _, v in ipairs(itemTb) do
            self.effect:addItem(v)
        end
	end
	self._layout.anis.c_dakai2.play()
end

function wnd_xinghun_sub_star_perfect:setFightPower(props)
	local tmp = {}
	for _, v in ipairs(props) do
		if v.id > 0 then
			tmp[v.id] = (tmp[v.id] or 0) + v.value
		end
	end
	local power = g_i3k_db.i3k_db_get_battle_power(tmp, true)
	self.fightPower:setText(power)
end


function wnd_create(layout, ...)
	local wnd = wnd_xinghun_sub_star_perfect.new();
		wnd:create(layout, ...);
	return wnd;
end
